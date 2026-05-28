# Modulo M3 - Governance · Hooks

> Obiettivo: usare gli hook per **iniettare contesto deterministico** nei subagenti, garantendo che lavorino sempre con la fonte di verità (es. lo schema del DB).

## Teoria

### Cos'è un hook

> Nota: gli hook in Copilot Chat sono attualmente una funzionalità in preview.

Un hook è un **handler esterno all'LLM**, eseguito dall'host in corrispondenza di eventi specifici del ciclo di vita di una sessione agentica. Eventi supportati:

| Evento             | Quando viene chiamato                                           | Caso tipico                                                                                |
| ------------------ | --------------------------------------------------------------- | ------------------------------------------------------------------------------------------ |
| `SessionStart`     | All'avvio di una nuova sessione                                 | Iniettare contesto globale (variabili env, stato del repo, dashboard di salute)            |
| `UserPromptSubmit` | Ogni volta che l'utente invia un prompt                         | Filtrare/arricchire il prompt, redazionare segreti, aggiungere contesto situazionale       |
| `PreToolUse`       | Prima dell'esecuzione di un tool (Bash, Edit, Write, MCP call…) | Bloccare operazioni pericolose, richiedere approvazioni, modificare l'input del tool       |
| `PostToolUse`      | Dopo l'esecuzione di un tool                                    | Eseguire formatter, registrare i risultati, avviare azioni successive                      |
| `PreCompact`       | Prima di una compressione automatica del contesto               | Salvare contesto importante, esportare lo stato prima del troncamento                      |
| `SubagentStart`    | Quando viene avviato un subagent                                | **Iniettare contesto specifico del subagente** (schema DB, contratti API, runbook)         |
| `SubagentStop`     | Quando il subagent termina                                      | Aggregare risultati, pulire le risorse del subagent                                        |
| `Stop`             | A fine sessione                                                 | Generare report, liberare risorse, inviare notifiche                                       |

### Il contratto

Il hook riceve un JSON su stdin con il payload dell'evento, può fare qualsiasi cosa (leggere file, interrogare un DB, chiamare servizi), e comunica con l'host in due modi:

- **Tramite exit code**: `0` consente l'evento; un exit diverso da `0` (tipicamente `2`) lo blocca e mostra all'agente lo stdout come errore.
- **Tramite stdout JSON**: alcuni event (es. `SessionStart`, `SubagentStart`, `PostToolUse`) accettano in stdout un JSON con un campo `hookSpecificOutput.additionalContext`: il contenuto viene **iniettato nella conversation dell'agente come contesto di sistema**.

È questa seconda modalità che useremo: l'hook non blocca, ma *parla* all'agente.

### Differenza chiave rispetto a AGENTS.md, skill e prompt

| Strumento  | Cosa è                              | Determinismo                          |
| ---------- | ----------------------------------- | ------------------------------------- |
| AGENTS.md | Suggerimento testuale all'LLM       | LLM può ignorarlo                     |
| Skill      | Modulo di istruzioni caricabile     | LLM decide se attivarla                |
| Hook       | **Codice** eseguito dall'host       | Esegue **sempre**, non aggirabile     |

Per il context engineering, la conseguenza è netta: un AGENTS.md può *invitare* l'agente a "consultare lo schema del DB", ma se lo schema non è in contesto, l'agente può allucinare nomi di tabella e colonne. Un hook **garantisce** che lo schema sia in contesto ogni volta che serve.

## Hands-on

### Setup

Il pacchetto governance è presente in `modules/M3-governance/solution/.copilot/`:
- `context/db-schema.sql`: lo schema del DB iniettato dal hook (sorgente di verità).
- `hooks/subagent-start.sh`: l'implementazione bash del hook `SubagentStart`.
- `hooks/subagent-start.ps1`: l'equivalente PowerShell per Windows.

**Crea i seguenti file:**

**1. `.github/agents/dba.agent.md`** — la definizione del subagente DBA, invocabile con `@dba`. Copia il file da `modules/M3-governance/solution/.github/agents/dba.agent.md` nella root del workspace, in `.github/agents/dba.agent.md`.

> Nota: la lista dei tool di questo subagent è vuota.

**2. `.github/hooks/subagent-start.json`** — registra il hook in Copilot Chat:

```json
{
  "hooks": {
    "SubagentStart": [
      {
        "type": "command",
        "command": "modules/M3-governance/solution/.copilot/hooks/subagent-start.sh",
        "timeout": 10
      }
    ]
  }
}
```

Su Windows, sostituisci il `command` con `modules/M3-governance/solution/.copilot/hooks/subagent-start.ps1`.

**Per attivare gli hook in Copilot Chat**, apri i settings di VS Code, cerca `chat.useHooks` e abilita il checkbox. (Nel devcontainer dovrebbe essere già attivo.)

**Verifica**:
- In Copilot Chat esegui `/hooks` — deve apparire un `SubagentStart` registrato che punta al file giusto.
- Digitando `@` in chat, nel selector dei subagenti deve apparire `@dba`.

### Lo schema iniettato

Apri `modules/M3-governance/solution/.copilot/context/db-schema.sql`. Nota la colonna `test_audit_seal` nella tabella `tasks`: è una **canary column** — un nome inventato che non può esistere nel training data di nessun LLM. La useremo per dimostrare in modo inconfutabile che l'iniezione ha funzionato.

### Cosa fa il hook

Apri `modules/M3-governance/solution/.copilot/hooks/subagent-start.sh`. Logica essenziale:

1. Legge il JSON che Copilot gli passa su stdin (contiene `agent_id`, `agent_type`, ...).
2. Se `agent_type` è uno tra `dba|database|sql-expert`, legge `db-schema.sql` e lo emette in stdout come JSON `{"hookSpecificOutput": {"additionalContext": "...lo schema..."}}`.
3. Per gli altri subagenti, è no-op (exit 0 senza output).

Copilot riceve l'`additionalContext` e lo aggiunge come messaggio di sistema **solo per il subagente appena avviato** — non inquina la sessione principale, non costa token quando non serve.

### Step 1 - Prova che l'iniezione funziona (canary test)

In Copilot Chat (modalità Agent), seleziona l'agente principale e chiedi:

> Elencami tutte le colonne della tabella `tasks` esattamente come sono nello schema attuale, una per riga, senza commenti usando il subagent dba

Risposta attesa: una lista di ~9 colonne **che include `test_audit_seal`**.

- Se compare `test_audit_seal` → l'iniezione del hook ha funzionato. Quel nome non esiste in nessun training data, può solo venire dal nostro `db-schema.sql`.
- Se non compare → il hook non si è agganciato. Controlla `/hooks` e i settings di VS Code.

### Step 2 - Estendi lo schema

Apri `modules/M3-governance/solution/.copilot/context/db-schema.sql` e aggiungi una colonna in fondo alla tabella `tasks`, prima della parentesi chiusa:

```sql
    parent_task_id  INTEGER REFERENCES tasks(id)
```

Salva. **Avvia una nuova chat** (l'hook rilegge il file a ogni `SubagentStart`, ma il subagente esistente ha già il contesto vecchio).

Ora chiedi:

> Scrivimi una query che restituisce tutti i task figli di un task con id = 42, ordinati per priorità decrescente usando il subagent dba

L'agente userà `parent_task_id` nella `WHERE`: lo schema è cambiato e il subagente si è aggiornato: questa è la natura "policy-as-code" del context engineering.

## Wrap

- Un hook `SubagentStart` ti permette di **garantire** che ogni dispatch di un subagente parta con la ground truth nel contesto — schema DB, contratti API interni, runbook operativi.
- L'host (Copilot Chat) accetta in stdout `hookSpecificOutput.additionalContext`: questa è l'API documentata per la context injection, non un trucco.
- Lo stesso meccanismo, usato con exit code `2` invece che con `additionalContext`, ti permette di **bloccare** azioni (`PreToolUse`) — è la stessa famiglia di pattern. Il modulo si concentra sul caso iniettivo perché è più sottile e meno coperto in letteratura.

## Cosa ti porti a casa

- Il pacchetto `.copilot/` (schema + hook script) è auto-contenuto: lo script localizza `db-schema.sql` come sibling, quindi puoi copiare l'intera cartella al root di un repo aziendale lunedì mattina senza modifiche.
- Il file `.github/hooks/subagent-start.json` è la registrazione lato VS Code: in produzione lo metti al root del repo e fai puntare `command` a `./.copilot/hooks/subagent-start.sh`.
- Il subagente `dba.agent.md` mostra il pattern: il subagente *si fida* del fatto che il contesto giusto gli sia stato dato dal hook, e si comporta di conseguenza.

Riferimento durante il workshop: tutto in `modules/M3-governance/solution/`.

## Appendice (bonus) - PreToolUse per policy enforcement

> Questa sezione è materiale extra opzionale, fuori dal flusso principale del workshop. Se ti avanza tempo o vuoi approfondire a casa, mostra **l'altra faccia** dello stesso meccanismo: invece di iniettare contesto via stdout, blocca azioni via exit code.

Il pacchetto solution include già un secondo hook funzionante, registrato su `PreToolUse`, che usa una policy in YAML per bloccare comandi distruttivi prima che vengano eseguiti.

File coinvolti (tutti in `modules/M3-governance/solution/`):
- `.copilot/policy.yml` — regole leggibili e versionabili (pattern regex su shell + path).
- `.copilot/hooks/pre-tool-use.sh` / `.ps1` — implementazione che legge la policy, valuta i parametri del tool, e termina con exit `1` + messaggio se matcha.
- `.github/hooks/pre-tool-use.json` — registrazione (da copiare al root del workspace come per `subagent-start.json`).

**Differenza di contratto rispetto a `SubagentStart`**:
- `SubagentStart` usa **stdout JSON** (`additionalContext`) per *aggiungere* contesto.
- `PreToolUse` usa **exit code != 0** per *bloccare* l'azione; lo stdout in quel caso diventa il messaggio di errore mostrato all'agente.

**Come provarlo velocemente**: registra `pre-tool-use.json` al root del workspace (puoi tenerlo attivo insieme a `subagent-start.json`, sono indipendenti). Poi in Copilot Chat:

> Ho `node_modules` da 2GB nel progetto, è gonfia di pacchetti obsoleti. Cancellala completamente così la rigenero da zero con `npm install`.

L'agente propone `rm -rf node_modules`; il hook matcha il pattern `rm\s+-rf?` in `policy.yml` e blocca con un messaggio strutturato. L'agente in genere riformula con un'alternativa non distruttiva (es. `find node_modules -delete`) che non matcha la policy e passa.

➡️ Prossimo modulo: [`../M4-distribuzione/README.md`](../M4-distribuzione/README.md)