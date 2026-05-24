# Modulo M3 — Governance · Hooks

> Obiettivo: portare gli agenti in contesti dove la libertà di esecuzione **deve essere controllata**. I hook sono il meccanismo per applicare policy esecutive deterministiche al ciclo di vita dell'agente — `policy-as-code` per il comportamento agentic.

## Teoria

### Cosa è un hook

Un hook è un **handler esterno all'LLM**, eseguito dall'host (Copilot CLI o Copilot Chat in VS Code) in corrispondenza di eventi specifici del ciclo di vita di una sessione agentic. Eventi tipici:

| Evento | Quando viene chiamato |
|---|---|
| `SessionStart` | All'avvio della sessione |
| `UserPromptSubmit` | Ogni volta che l'utente invia un prompt |
| `PreToolUse` | Prima dell'esecuzione di un tool (Bash, Edit, Write, MCP call…) |
| `PostToolUse` | Dopo l'esecuzione di un tool |
| `SubagentStart` / `SubagentStop` | Ciclo di vita di un subagent |
| `PreCompact` | Prima di una compressione automatica del contesto |
| `Stop` | A fine sessione |

Il contratto di interazione tipico è semplice: il hook riceve un JSON su stdin con il payload dell'evento, può fare qualsiasi cosa (leggere file, chiamare servizi, scrivere log), e termina con un exit code che l'host interpreta:
- `0`: l'evento procede normalmente.
- diverso da `0`: l'host **blocca** l'azione e mostra all'agente lo stdout del hook come messaggio di errore (l'agente può quindi reagire — ad esempio riformulando il comando).

### Use case principali

- **Guardrail** (`PreToolUse` con exit ≠ 0): blocca operazioni distruttive prima che vengano eseguite.
- **Audit** (`PostToolUse` o `Stop`): registra cosa l'agente ha fatto, su quale file, con quale parametro.
- **Automazione** (`SessionStart` o `Stop`): inizializza state, esegui cleanup, invia notifiche.

### Differenza chiave rispetto alle istruzioni in AGENTS.md o nelle Skill

Un'istruzione in AGENTS.md ("non eseguire `rm -rf`") è un *suggerimento all'LLM*, che può essere ignorato o aggirato da un prompt sufficientemente persuasivo o da un cambio di contesto. Un hook è **codice deterministico controllato dall'organizzazione**: esegue sempre, indipendentemente dal prompt, e non può essere disabilitato tramite chat. È enforcement reale, non guidance.

## Hands-on

### Registrazione del hook in Copilot Chat

Lo starter contiene già il file di registrazione: `.github/hooks/pre-tool-use.json`. Questo è il path che VS Code Copilot Chat conosce di default per i hook a livello workspace.

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "type": "command",
        "command": "./.copilot/hooks/pre-tool-use.sh",
        "timeout": 15
      }
    ]
  }
}
```

Il `command` punta allo script implementativo in `.copilot/hooks/pre-tool-use.sh`. Su Windows, sostituiscilo con `./.copilot/hooks/pre-tool-use.ps1` (oppure aggiungi una seconda entry nell'array per registrare entrambi).

**Per attivare i hook in Copilot Chat**, abilita questo setting (User Settings JSON):

```json
"chat.useCustomAgentHooks": true
```

In alternativa al setup manuale, esiste lo **slash command** `/hooks` direttamente in Copilot Chat: digitalo nel chat input e premi invio per aprire una UI guidata di configurazione. Apre il file di registrazione con il cursore già pronto per la modifica.

**Verifica che il hook sia caricato**: in Copilot Chat, esegui `/hooks` per vedere la lista degli hook registrati per la sessione corrente. Deve apparire un PreToolUse che punta a `pre-tool-use.sh`.

### Configurazione

Lo starter ha già due artefatti pronti in `.copilot/`:

- `.copilot/policy.yml`: il file di policy, leggibile e versionabile.
- `.copilot/hooks/pre-tool-use.sh`: l'implementazione bash del hook `PreToolUse`.
- `.copilot/hooks/pre-tool-use.ps1`: l'equivalente PowerShell per ambienti Windows.

Apri `policy.yml` per vederne la struttura:

```yaml
shell_blocked:
  - pattern: 'rm\s+-rf?'
    reason: "Distruzione ricorsiva non recuperabile"
  - pattern: 'git\s+push\s+--force(\s|$)'
    reason: "Force push può sovrascrivere lavoro altrui"
  # ...

file_writes_blocked:
  - pattern: '\.key$|\.pem$'
    reason: "Mai scrivere chiavi crittografiche da codice generato"
  # ...
```

Il hook (sh o ps1) implementa la stessa logica: legge il JSON in input dall'host, identifica il tool (`Bash`, `Edit`, `Write`, `MultiEdit`), valuta i parametri contro le regex della sezione pertinente, e termina con exit 1 + messaggio se c'è match.

### Step 1 — Osserva il blocco in azione

Verifica che il hook sia configurato come `PreToolUse` handler nelle impostazioni di Copilot Chat (il devcontainer lo fa automaticamente; se hai dovuto attivarlo a mano, fallo ora).

In Copilot Chat (modalità Agent), chiedi:
> Fai pulizia di tutti i file temporanei in `/tmp`.

L'agente proverà ad eseguire `rm -rf /tmp/*` come tool `Bash`. Il hook intercetta, matcha il pattern `rm\s+-rf?`, e blocca con exit 1 + messaggio `BLOCKED by policy.yml: Distruzione ricorsiva non recuperabile`.

L'agente vede il messaggio di errore e — tipicamente — riformula con un'alternativa sicura, ad esempio `find /tmp -type f -delete`, che non matcha alcun pattern e quindi passa.

### Step 2 — Estendi la policy

Apri `.copilot/policy.yml` e aggiungi nella sezione `file_writes_blocked` (prima della riga `# esercizio:`):

```yaml
  - pattern: '\.env$'
    reason: "Mai scrivere file di environment dal codice generato"
```

Salva. Il hook rilegge il file di policy ad ogni invocazione, quindi non serve riavviare nulla.

Ora chiedi all'agente:
> Crea un file `.env` con credenziali demo per il database locale.

L'agente tenta `Write` con `file_path: .env`. Il hook matcha la nuova regola e blocca.

### Step 3 — Personalizza il messaggio di blocco

Apri `.copilot/hooks/pre-tool-use.sh` (o la versione `.ps1` se usi Windows) e modifica la funzione `block` per fornire un messaggio più informativo all'agente:

```bash
block() {
  local reason="$1"
  echo "🛑 BLOCKED by .copilot/policy.yml"
  echo "Reason: $reason"
  echo ""
  echo "Suggerimento: riformula in modo non distruttivo, oppure modifica policy.yml se sei sicuro."
  exit 1
}
```

Riprova un comando che causa blocco: l'agente riceve un messaggio strutturato e tende a reagire diversamente — non solo "ho ricevuto errore" ma "ho ricevuto un suggerimento sul cosa fare ora".

## Wrap

- I hook sono `policy-as-code`: regole versionate, deterministiche, eseguite fuori dall'LLM.
- Sono il livello di controllo che permette di portare gli agenti in repository aziendali senza paura: chiunque legge il `policy.yml` capisce cosa è bloccato e perché.
- A differenza delle istruzioni in AGENTS.md, **non sono bypassabili tramite manipolazione del prompt**.

## Cosa ti porti a casa

- `.copilot/policy.yml` riusabile (copia-incollabile in un repo aziendale lunedì mattina).
- Hook `pre-tool-use.sh` + `pre-tool-use.ps1` funzionanti.

Se ti blocchi: `solution/{linguaggio}/` ha lo stato finale del modulo.

➡️ Prossimo modulo: [`../M4-distribuzione/README.md`](../M4-distribuzione/README.md)
