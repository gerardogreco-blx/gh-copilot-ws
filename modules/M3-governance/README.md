# Modulo M3 - Governance · Hooks

> Obiettivo: usare gli hook per **iniettare contesto deterministico** nei subagenti, garantendo che lavorino sempre con la fonte di verità (es. lo schema del DB).

> 🔵 **Claude Code (estensione VS Code)?** Modulo identico nei concetti. Anche Claude Code ha l'hook **`SubagentStart`** (stesso meccanismo: inietta `additionalContext` quando parte un subagent). Differenze solo tecniche: la registrazione vive in `.claude/settings.json` (non in `.github/hooks/*.json`), gli hook sono **attivi di default** (niente `chat.useHooks`), e si filtra il subagent con il campo `matcher`. Sotto ogni passo trovi un blocco 🔵. Tutti i file di riferimento Claude sono in `modules/M3-governance/solution/.claude/`.

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

Lo hook riceve un JSON su stdin con il payload dell'evento, può fare qualsiasi cosa (leggere file, interrogare un DB, chiamare servizi), e comunica con l'host in due modi:

- **Tramite exit code**: `0` consente l'evento; un exit diverso da `0` (tipicamente `1`) lo blocca e mostra all'agente lo stdout come errore.
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
- `context/db-schema.sql`: lo schema del DB iniettato dallo hook (sorgente di verità).
- `hooks/subagent-start.sh`: l'implementazione bash dello hook `SubagentStart`.
- `hooks/subagent-start.ps1`: l'equivalente PowerShell per Windows.

**Crea i seguenti file:**

**1. `.github/agents/dba.agent.md`** — la definizione del subagente DBA, invocabile con `@dba`. Copia il file da `modules/M3-governance/solution/.github/agents/dba.agent.md` nella root del workspace, in `.github/agents/dba.agent.md`.

> Nota: la lista dei tool di questo subagent è vuota.

**2. `.github/hooks/subagent-start.json`** — registra lo hook in Copilot Chat:

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

<details>
<summary>🔵 <b>Claude Code — Setup</b></summary>

Il pacchetto governance per Claude è in `modules/M3-governance/solution/.claude/`:
- `context/db-schema.sql` — lo schema (stesso contenuto, stessa canary column `test_audit_seal`).
- `hooks/subagent-start.sh` / `.ps1` — l'hook `SubagentStart` in versione Claude.

**Crea i seguenti file al root del workspace:**

**1. `.claude/agents/dba.md`** — copia il file da `modules/M3-governance/solution/.claude/agents/dba.md`. È lo stesso subagent DBA (corpo identico); il frontmatter usa `model: sonnet` e `tools: []` (lista vuota: il subagent non usa tool, si fida dello schema iniettato). Lo invochi con `@agent-dba`.

**2. `.claude/settings.json`** — registra l'hook (gli hook in Claude Code sono attivi di default, nessuna impostazione da spuntare):

```json
{
  "hooks": {
    "SubagentStart": [
      {
        "matcher": "dba",
        "hooks": [
          { "type": "command", "command": "$CLAUDE_PROJECT_DIR/modules/M3-governance/solution/.claude/hooks/subagent-start.sh", "timeout": 10 }
        ]
      }
    ]
  }
}
```

Il `matcher: "dba"` fa sì che l'hook giri **solo** quando parte il subagent `dba` (il matcher di `SubagentStart` filtra sul nome dell'agente). Su Windows usa la versione PowerShell: `"command": "pwsh -File $CLAUDE_PROJECT_DIR/modules/M3-governance/solution/.claude/hooks/subagent-start.ps1"`.

**Verifica**:
- Esegui `/hooks` nel pannello Claude Code — deve comparire un `SubagentStart` registrato.
- Digitando `@` (o `@agent-`) compare `dba` tra i subagenti.

</details>

### Lo schema iniettato

Apri `modules/M3-governance/solution/.copilot/context/db-schema.sql`. Nota la colonna `test_audit_seal` nella tabella `tasks`: è una **canary column** — un nome inventato che non può esistere nel training data di nessun LLM. La useremo per dimostrare in modo inconfutabile che l'iniezione ha funzionato.

> 🔵 Claude Code: lo schema di riferimento è in `modules/M3-governance/solution/.claude/context/db-schema.sql` (contenuto identico, stessa canary column).

### Cosa fa lo hook

Apri `modules/M3-governance/solution/.copilot/hooks/subagent-start.sh`. Logica essenziale:

1. Legge il JSON che Copilot gli passa su stdin (contiene `agent_id`, `agent_type`, ...).
2. Se `agent_type` è uno tra `dba|database|sql-expert`, legge `db-schema.sql` e lo emette in stdout come JSON `{"hookSpecificOutput": {"additionalContext": "...lo schema..."}}`.
3. Per gli altri subagenti, è no-op (exit 0 senza output).

Copilot riceve l'`additionalContext` e lo aggiunge come messaggio di sistema **solo per il subagente appena avviato** — non inquina la sessione principale, non costa token quando non serve.

<details>
<summary>🔵 <b>Claude Code — cosa fa lo hook</b></summary>

`modules/M3-governance/solution/.claude/hooks/subagent-start.sh`. La logica è la stessa, ancora più semplice perché il filtro sul subagent è fatto dal `matcher: "dba"` in `settings.json` (non serve leggere il tipo di agente nello script):

1. Legge `db-schema.sql` (sibling in `../context/`).
2. Lo emette su stdout come JSON `{"hookSpecificOutput": {"hookEventName": "SubagentStart", "additionalContext": "...schema..."}}`.

`SubagentStart` è un evento "context only": Claude aggiunge l'`additionalContext` come contesto **solo per il subagent appena avviato**, esattamente come Copilot. Stessa garanzia, stesso effetto.

</details>

### Step 1 - Prova che l'iniezione funziona (canary test)

In Copilot Chat (modalità Agent), seleziona l'agente principale e chiedi:

> Elencami tutte le colonne della tabella `tasks` esattamente come sono nello schema attuale, una per riga, senza commenti usando il subagent dba

Risposta attesa: una lista di ~9 colonne **che include `test_audit_seal`**.

- Se compare `test_audit_seal` → l'iniezione dello hook ha funzionato. Quel nome non esiste in nessun training data, può solo venire dal nostro `db-schema.sql`.
- Se non compare → lo hook non si è agganciato. Controlla `/hooks` e i settings di VS Code.

<details>
<summary>🔵 <b>Claude Code — Step 1 (canary test)</b></summary>

Identico. Nel pannello Claude Code usa **lo stesso prompt** (elenca le colonne di `tasks` usando il subagent dba). Se compare `test_audit_seal` l'iniezione via `SubagentStart` ha funzionato. Se non compare, verifica con `/hooks` che l'hook sia registrato e che il `matcher` sia `dba`.

</details>

### Step 2 - Estendi lo schema

Apri `modules/M3-governance/solution/.copilot/context/db-schema.sql` e aggiungi una colonna in fondo alla tabella `tasks`, prima della parentesi chiusa:

```sql
    parent_task_id  INTEGER REFERENCES tasks(id)
```

Salva. **Avvia una nuova chat** (l'hook rilegge il file a ogni `SubagentStart`, ma il subagente esistente ha già il contesto vecchio).

Ora chiedi:

> Scrivimi una query che restituisce tutti i task figli di un task con id = 42, ordinati per priorità decrescente usando il subagent dba

L'agente userà `parent_task_id` nella `WHERE`: lo schema è cambiato e il subagente si è aggiornato: questa è la natura "policy-as-code" del context engineering.

<details>
<summary>🔵 <b>Claude Code — Step 2 (estendi lo schema)</b></summary>

Identico: aggiungi la colonna `parent_task_id` in fondo alla tabella in `modules/M3-governance/solution/.claude/context/db-schema.sql`, salva, e **avvia una nuova conversazione** (l'hook rilegge il file a ogni `SubagentStart`). Stesso prompt sui task figli: il subagent `dba` userà `parent_task_id` perché lo schema iniettato è cambiato.

</details>

## Wrap

- Un hook `SubagentStart` ti permette di **garantire** che ogni dispatch di un subagente parta con la ground truth nel contesto — schema DB, contratti API interni, runbook operativi.
- L'host (Copilot Chat) accetta in stdout `hookSpecificOutput.additionalContext`: questa è l'API documentata per la context injection, non un trucco.
- Lo stesso meccanismo, usato con exit code `1` invece che con `additionalContext`, ti permette di **bloccare** azioni (`PreToolUse`) — è la stessa famiglia di pattern. Il modulo si concentra sul caso iniettivo perché è più sottile e meno coperto in letteratura.

## Cosa ti porti a casa

- Il pacchetto `.copilot/` (schema + hook script) è auto-contenuto: lo script localizza `db-schema.sql` come sibling, quindi puoi copiare l'intera cartella al root di un repo aziendale lunedì mattina senza modifiche.
- Il file `.github/hooks/subagent-start.json` è la registrazione lato VS Code: in produzione lo metti al root del repo e fai puntare `command` a `./.copilot/hooks/subagent-start.sh`.
- Il subagente `dba.agent.md` mostra il pattern: il subagente *si fida* del fatto che il contesto giusto gli sia stato dato dallo hook, e si comporta di conseguenza.

Riferimento durante il workshop: tutto in `modules/M3-governance/solution/`.

> 🔵 Claude Code: i file di riferimento sono in `modules/M3-governance/solution/.claude/` (agents `dba.md` + `code-reviewer.md`, `settings.json`, `hooks/`, `context/db-schema.sql`, `policy.yml`).

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

L'agente propone `rm -rf node_modules`; lo hook matcha il pattern `rm\s+-rf?` in `policy.yml` e blocca con un messaggio strutturato. L'agente in genere riformula con un'alternativa non distruttiva (es. `find node_modules -delete`) che non matcha la policy e passa.

<details>
<summary>🔵 <b>Claude Code — Appendice (PreToolUse)</b></summary>

Stesso meccanismo. File di riferimento in `modules/M3-governance/solution/.claude/`:
- `policy.yml` — stesse regole (regex su shell + path).
- `hooks/pre-tool-use.sh` / `.ps1` — implementazione Claude: legge da stdin `tool_name` e `tool_input` (non `tool`/`parameters`) e **blocca con `exit 2`** scrivendo il motivo su stderr (in Copilot era `exit 1` + stdout).

Registra l'hook aggiungendo a `.claude/settings.json` un blocco `PreToolUse` (puoi tenerlo insieme a `SubagentStart`):

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash|Edit|Write|MultiEdit",
        "hooks": [
          { "type": "command", "command": "$CLAUDE_PROJECT_DIR/modules/M3-governance/solution/.claude/hooks/pre-tool-use.sh", "timeout": 15 }
        ]
      }
    ]
  }
}
```

Poi prova con **lo stesso prompt** (cancellare `node_modules`): Claude propone `rm -rf node_modules`, l'hook matcha `rm\s+-rf?` in `policy.yml` e blocca; Claude riformula con un'alternativa non distruttiva. La versione completa di `settings.json` (con entrambi gli hook) è in `modules/M3-governance/solution/.claude/settings.json`.

</details>

➡️ Prossimo modulo: [`../M4-distribuzione/README.md`](../M4-distribuzione/README.md)