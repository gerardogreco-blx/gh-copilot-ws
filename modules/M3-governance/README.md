# Modulo M3 — Governance · Hooks · 14 min

> Obiettivo: configurare un **safety guard** che intercetta i tool che Copilot sta per invocare e blocca quelli pericolosi.

## Teoria (4 min)

### Cos'è un hook
Un hook è un **event handler** che intercetta il ciclo di vita di Copilot. Eventi disponibili:
- `SessionStart` — inizio sessione
- `UserPromptSubmit` — ogni prompt che invii
- `PreToolUse` — **prima** che l'agente esegua un tool (Bash, Edit, Write, ...)
- `PostToolUse` — dopo l'esecuzione
- `SubagentStart` / `SubagentStop` — ciclo di vita subagent
- `PreCompact` / `Stop` — compressione contesto / fine sessione

### Use case
- **Guardrail** — blocca azioni pericolose (PreToolUse + exit code != 0).
- **Audit** — logga cosa fa l'agente (PostToolUse).
- **Automazione** — esegui hook a fine sessione.

### Differenza chiave
Gli hook sono **dell'organizzazione**, non dell'LLM. Non si possono "prompt-injectare via". Sono enforcement vero, policy-as-code.

## Hands-on (7 min) — un solo esercizio: safety guard

Lo starter ha:
- `.copilot/policy.yml` — file di policy con pattern bloccati (preset)
- `.copilot/hooks/pre-tool-use.sh` — hook che valuta tool call vs policy

### Step 1 — Vedi il blocco in azione (2')

In Copilot Chat (Agent):
> Fai pulizia di tutti i file temporanei in `/tmp`.

L'agente prova `rm -rf /tmp/*` → l'hook blocca → l'agente riformula con `find /tmp -type f -delete`.

### Step 2 — Estendi la policy (3')

Apri `.copilot/policy.yml`. Aggiungi nella sezione `file_writes_blocked`:

```yaml
  - pattern: '\.env$'
    reason: "Mai scrivere file di environment dal codice generato"
```

Poi:
> Crea un file `.env` con credenziali demo per il database locale.

Osserva: blocco visibile.

### Step 3 — Customizza il messaggio (2')

Nell'hook `pre-tool-use.sh`, cambia il messaggio di blocco aggiungendo riga di spiegazione/suggerimento. Riprova: l'agente reagisce diversamente.

## Wrap (3')

- Hook = fiducia controllata.
- Il `policy.yml` lo copi nel repo aziendale lunedì.
- Bridge a M4: stesso pattern in `dev-guardian` del marketplace.

## Output del modulo
- `.copilot/policy.yml` riusabile.
- Hook `pre-tool-use.sh` funzionante.

Se sei bloccato: `solution/{linguaggio}/`.

➡️ Prossimo: [`../M4-distribuzione/README.md`](../M4-distribuzione/README.md)
