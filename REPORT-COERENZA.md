# Report di coerenza — Workshop "The Agent Strikes Back" (M1–M4)

> Analisi di sola lettura dei materiali didattici. **Nessun file dei moduli è stato modificato.**
> Metodo: 1 agente di analisi per modulo + verifica di coerenza globale dell'agente principale, con spot-check diretti sui finding critici.
> Cartella `docs/` esclusa come richiesto. Artefatti di build (`bin/`, `obj/`, `.venv/`, `node_modules/`) ignorati.
> Data: 2026-05-31.

---

## 1. Sintesi esecutiva

I 4 moduli sono **didatticamente solidi e ben strutturati**: titoli, scheletro delle sezioni (Teoria → Hands-on → Wrap → Cosa ti porti a casa), tono e progressione concettuale sono coerenti. La skill `endpoint-creator/SKILL.md` è **identica byte-per-byte** in tutti e 4 i moduli e nel plugin (cumulatività perfetta).

Tuttavia emergono **3 BLOCKER** (uno per "esperienza partecipante", due tecnici) e diverse **incoerenze cross-modulo** che minano l'autonomia dei README e la promessa di "customizations cumulative" dichiarata in `AGENTS.md`.

| # | Severità | Problema | Dove |
|---|---|---|---|
| B1 | 🔴 BLOCKER | Starter .NET di M2 non compila i test (manca `ProjectReference`) | `M2/starters/dotnet/Tasks.Tests/Tasks.Tests.csproj` |
| B2 | 🔴 BLOCKER | Hook PowerShell di M3 non blocca `DELETE FROM ...;` (bug nel parser) | `M3/solution/.copilot/hooks/pre-tool-use.ps1:35` |
| B3 | 🔴 BLOCKER | Plugin M4 non impacchetta `policy.yml` → hook inerte (`exit 0`) una volta installato | `M4/solution/plugins/copilot-safety-guard/` |
| C1 | 🟡 MEDIO | `code-reviewer.agent.md` ha **due versioni diverse**: M3 ≠ (M2 = M4) | vedi §3.1 |
| C2 | 🟡 MEDIO | Regressione cumulativa: M4 perde `dba`, `subagent-start`, `db-schema.sql` di M3 | §3.2 |
| C3 | 🟡 MEDIO | `AGENTS.md` descrive M3 in modo errato (cita PreToolUse, ma l'esercizio principale è SubagentStart) | `AGENTS.md:12` |
| C4 | 🟡 MEDIO | `SOLUTION.md` esiste solo in M2 | `M2/solution/SOLUTION.md` |
| C5 | 🟡 MEDIO | Numerazione step rotta in M4 (Step 1 → Step 3) | `M4/README.md` |

**Tutti i 3 BLOCKER e le incoerenze C1–C2 sono stati verificati direttamente dall'agente principale**, non solo riportati dai sub-agenti.

---

## 2. Verifica di coerenza GLOBALE (cross-modulo)

Questa è la parte richiesta esplicitamente: stesse strutture, stessi testi/riferimenti, terminologia coerente.

### ✅ Cosa è coerente
- **Titoli H1**: formato uniforme `# Modulo Mn - <Nome> · <Tecnologie>`
  - M1 `Istruzioni · AGENTS.md + Skills` · M2 `Capacità · Subagents + MCP` · M3 `Governance · Hooks` · M4 `Distribuzione · Plugins & Marketplace`
- **Scheletro README**: tutti seguono `Teoria → Hands-on → Wrap → Cosa ti porti a casa` (M3 aggiunge `Appendice (bonus)`). Coerente.
- **Navigazione in avanti**: M1→M2→M3→M4 con riga finale uniforme `➡️ Prossimo modulo: [...]`. (M4 non ha link finale — è l'ultimo, ma manca un rimando a una conclusione / al README root.)
- **Skill `endpoint-creator`**: `md5 = 6ffb1e38...` **identica** in M1, M2, M3, M4 e nel plugin di M4. Cumulatività e coerenza perfette.
- **API e test cross-linguaggio** (dotnet/typescript/python): stessi 5 endpoint (`GET/POST/PATCH/PUT/DELETE /tasks`), stessa validazione, 6 test per linguaggio in ogni modulo.
- **Boilerplate "customizations al root"**: ripetuto coerentemente nei README dei moduli e nel README root.

### ❌ Incoerenze cross-modulo (le più importanti)

**C1 — Lo stesso `code-reviewer.agent.md` esiste in due versioni divergenti.**
L'agent viene "creato in M2" e dovrebbe essere portato avanti invariato. Invece (verificato con `diff`):
- **M2 = M4** (identici): `tools: [read, 'context7/*', search]`, **senza** sezione "Available tools".
- **M3 diverge**: `tools: [Read, Grep, Bash]` **+** una sezione `## Available tools` extra (Read/Grep/Bash).

Due problemi in uno:
1. **Contenuto cumulativo non coerente**: il file "trascinato" cambia tra M3 e M2/M4.
2. **Naming dei tool incoerente**: minuscolo + stile-MCP (`read`, `search`, `context7/*`) vs maiuscolo (`Read`, `Grep`, `Bash`). Solo **una** delle due grafie è quella corretta per gli agent di Copilot — va deciso quale e uniformato in tutti i moduli. (Da verificare contro la doc ufficiale del formato `.agent.md`.)

*Suggerimento*: scegliere UNA versione canonica di `code-reviewer.agent.md` e renderla identica in M2, M3, M4 e nel plugin (come già fatto per `SKILL.md`).

**C2 — Regressione cumulativa M3 → M4.**
`AGENTS.md` (righe 9–13) dichiara le customizations **cumulative al root**. Ma la solution di M4 **ha perso** artefatti presenti in M3:
- `.github/agents/dba.agent.md`
- `.copilot/hooks/subagent-start.{sh,ps1}` + `.github/hooks/subagent-start.json`
- `.copilot/context/db-schema.sql`

In M3 questi **non** sono accessori: sono l'**esercizio principale** (demo canary-column con `@dba`), mentre `pre-tool-use` + `policy.yml` erano un'**appendice bonus**. M4 costruisce il plugin **solo** dall'appendice, scartando il cuore di M3. Il README di M4 non lo spiega → il subagent `@dba` e l'iniezione di contesto diventano un vicolo cieco narrativo.

*Suggerimento*: decidere e dichiarare la scelta. O (a) M4 mantiene/impacchetta anche gli artefatti di M3, o (b) il README di M4 dichiara esplicitamente che il plugin impacchetta un sottoinsieme e che dba/subagent-start restano standalone/dimostrativi.

**C3 — `AGENTS.md` descrive M3 in modo sfasato.**
`AGENTS.md:12` elenca per M3 solo `pre-tool-use.json` + `policy.yml` + `pre-tool-use.{sh,ps1}`. Ma il flusso **principale** del README di M3 è `subagent-start` + `dba.agent.md` + `db-schema.sql` (PreToolUse è relegato all'appendice). Il "system prompt del repo" descrive quindi un modulo diverso da quello reale.
*Suggerimento*: aggiornare `AGENTS.md:12` elencando dba/subagent-start/db-schema come artefatti canonici di M3.

**C4 — `SOLUTION.md` solo in M2.**
M2 è l'unico modulo con `solution/SOLUTION.md`; M1/M3/M4 trasmettono lo stesso "stato atteso" via la sezione `Cosa ti porti a casa`. Inoltre quel file **contraddice** la regola "customization al root": dice che `code-reviewer.agent.md` è "presente nella tua **starter**" (`SOLUTION.md:7`) e ne abbrevia il path (`agents/...` invece di `.github/agents/...`).
*Suggerimento*: uniformare — o estendere `SOLUTION.md` a tutti i moduli, o rimuoverlo da M2 spostandone i contenuti in `Cosa ti porti a casa`; in ogni caso correggere "starter" → "root del workspace".

---

## 3. Finding per modulo

### M1 — Istruzioni · AGENTS.md + Skills
Stato: **buono**. Starter validi, solution completa, skill identica al README. Problemi minori:
- 🟡 **DELETE → 204 mai definito nelle convenzioni.** Le 3 solution implementano DELETE con `204 No Content`, ma `AGENTS.md:50` e `SKILL.md §3` elencano solo 200/201/200/404/400. Un partecipante guidato dalle convenzioni non ha motivo di produrre 204 → la sua soluzione diverge dalla reference pur essendo corretta. *Aggiungere "204 (DELETE)" alle convenzioni e alla skill, oppure usare 200.*
- 🟡 **Location header su POST solo in .NET.** `AGENTS.md:50` impone "201 POST con Location header", ma TS (`routes.ts`) e Python (`main.py`) non lo emettono. Difetto trasversale, emerge per primo in M1.
- 🟢 Bold rotto: `README.md:78` `*...nella root del workspace**` (asterischi sbilanciati).
- 🟢 Grammatica obiettivo: `README.md:3` "come si descrive un repo **a** un file AGENTS.md".
- 🟢 Refuso nel README **root**: riga 45 "dpvresti" → "dovresti".
- 🟢 README **root** riga 129: "Lo starter contiene già `.vscode/mcp.json`" — in realtà è al root del repo, non nello starter.
- 🟢 `solution/python/` non ha un proprio `requirements.txt` (dotnet/typescript hanno csproj/package.json); asimmetria di autoconsistenza.

### M2 — Capacità · Subagents + MCP
Stato: **un BLOCKER + incoerenze strutturali.**
- 🔴 **B1 — Starter .NET non compila i test.** `M2/starters/dotnet/Tasks.Tests/Tasks.Tests.csproj` **non** contiene `<ProjectReference Include="..\TaskApi.csproj" />`. Verificato: M1, M3, M4 starter hanno la reference (count = 1), M2 starter = 0, M2 solution = 1. `dotnet test`/`build` falliscono per i partecipanti .NET. *Aggiungere l'`ItemGroup` con la ProjectReference (come negli altri moduli).*
- 🟡 **C4** `SOLUTION.md` solo qui + contraddice "al root" (vedi §2).
- 🟢 Body errore Python `{"detail":...}` invece di `{"error":...}` (AGENTS.md:49) — pre-esistente/cross-modulo.
- 🟢 Mancano i test del caso 400 (POST/PATCH/PUT) — regola "1 happy + 1 error" (AGENTS.md:51) non pienamente rispettata; cross-modulo.
- 🟢 `solution/{typescript,python}` identici allo starter (M2 non tocca il codice): atteso, ma può confondere — utile una nota nel README.

### M3 — Governance · Hooks
Stato: **un BLOCKER tecnico + incoerenze.** Sospetti iniziali risolti **a favore del README**: `dba`, `subagent-start`, `db-schema.sql` **non** sono file orfani — sono l'esercizio principale, ben spiegato. È `AGENTS.md` a essere incompleto (C3).
- 🔴 **B2 — PowerShell non blocca `DELETE FROM <tab>;` mentre bash sì.** In `pre-tool-use.ps1`, la funzione `Read-Section` all'header di una nuova sezione esegue `$currentPattern = $null` (riga 35) **prima** del flush finale (riga 45), scartando l'ultima regola di ogni sezione non terminale. Per `shell_blocked` si perde la 5ª regola (`DELETE\s+FROM\s+\w+\s*;`, `policy.yml:16`). Risultato: su Windows il "safety guard" lascia passare un `DELETE FROM tasks;`. *Fare il flush della regola pendente anche alla chiusura di sezione, prima del reset.*
- 🟡 **Path `command` incoerente tra i due JSON.** `subagent-start.json:7` punta a `modules/M3-governance/solution/.copilot/hooks/subagent-start.sh` (dentro la solution), mentre `pre-tool-use.json:6` usa `./.copilot/hooks/pre-tool-use.sh` (root-relative). Contraddice il modello "tutto al root" e la Wrap stessa del README (`README.md:132`). *Uniformare a `./.copilot/hooks/...`.*
- 🟡 **C3** `AGENTS.md:12` incompleto (vedi §2).
- 🟡 Quote non strippate nel parser PS (`pre-tool-use.ps1:37,41`): il char class `['""]?` lascia gli apici nel pattern catturato — innocuo sui casi attuali, fragile per pattern ancorati.
- 🟢 Exit code incoerente: `README.md:28,127` dicono "tipicamente `2`" per bloccare, ma gli script usano `exit 1` (e l'appendice dice 1). Funziona, ma è internamente incoerente.
- 🟢 Refuso ricorrente: "il hook"/"i hook" → "lo hook"/"gli hook".

### M4 — Distribuzione · Plugins & Marketplace
Stato: **due BLOCKER + incoerenze.** Artefatti interni del plugin identici alle versioni standalone (nessuna duplicazione "rotta").
- 🔴 **B3 — Plugin inerte una volta distribuito.** Gli script bundlati cercano la policy in `${COPILOT_REPO_ROOT:-$PWD}/.copilot/policy.yml` (`scripts/pre-tool-use.sh:9`), ma il bundle **non include** `policy.yml` (verificato: la cartella del plugin non contiene alcun `.yml`). In M3 lo script la trovava come sibling (`$SCRIPT_DIR/../policy.yml`); in M4 è stato riscritto root-relative. Installando il plugin da marketplace in un repo senza `.copilot/policy.yml`, l'hook fa `exit 0` e non blocca nulla. *Includere `policy.yml` nel bundle e cercarla relativa alla cartella del plugin, oppure documentare la dipendenza.*
- 🔴 **C2 — Regressione cumulativa** (vedi §2): persi dba/subagent-start/db-schema di M3, senza spiegazione.
- 🟡 **C5 — Numerazione step rotta**: si passa da "Step 1" a "Step 3" (manca Step 2). `M4/README.md`.
- 🟡 **`policy.yml` mai menzionato nel README di M4** (né nello skeleton tree né nella lista "copiato da"): chi segue alla lettera produce un plugin senza la dipendenza chiave. Collegato a B3.
- 🟡 **Modulo "Distribuzione" senza la distribuzione effettiva**: non mostra come creare l'indice del marketplace e pubblicarlo (solo "pronto in teoria per essere pubblicato"). Per un modulo così intitolato è una lacuna. *Aggiungere uno step che chiuda il cerchio con lo Step 1 (registrazione in `chat.plugins.marketplaces`).*
- 🟢 Procedura duplicata in "1b" (ripete la registrazione del marketplace già fatta in "1a").
- 🟢 La teoria cita "configurazioni di MCP server" tra i componenti packageabili, ma il bundle non ne include e M4 non riprende Context7.
- 🟢 `plugin.json` minimale (`version 0.1.0`, manca es. `displayName`/`repository`): verificare i campi obbligatori contro lo schema plugin ufficiale.

---

## 4. Problemi trasversali (workshop-wide)

Da affrontare a monte (M1) perché ereditati da tutti i moduli:
1. 🟡 **Body errore Python non conforme**: FastAPI `HTTPException(detail=...)` → `{"detail":...}`, mentre `AGENTS.md:49` impone `{"error":...}` (rispettato solo da .NET/TS). *Aggiungere un exception handler che riformatti in `{"error": ...}`.*
2. 🟡 **Location header su POST** presente solo in .NET (vedi M1).
3. 🟢 **Copertura test "1 happy + 1 error"** (AGENTS.md:51) non rispettata: mancano i test del caso 400.
4. 🟢 **`204 No Content` per DELETE** non documentato in `AGENTS.md`/`SKILL.md`.

---

## 5. Lista azioni prioritizzata

**Da correggere prima del workshop (🔴):**
1. M2: aggiungere `ProjectReference` allo starter .NET (`Tasks.Tests.csproj`).
2. M3: correggere il flush in `pre-tool-use.ps1` (Windows non blocca `DELETE FROM`).
3. M4: includere `policy.yml` nel bundle del plugin e farla risolvere relativa alla cartella del plugin; citarla nel README.

**Coerenza dei materiali (🟡):**
4. Uniformare `code-reviewer.agent.md` (una versione canonica in M2/M3/M4 + plugin) e decidere il naming corretto dei tool.
5. Decidere e dichiarare la sorte di dba/subagent-start/db-schema in M4 (cumulatività vs sottoinsieme).
6. Aggiornare `AGENTS.md:12` per riflettere il vero contenuto di M3.
7. Uniformare l'approccio `SOLUTION.md` (tutti o nessuno) e correggere "starter" → "root".
8. M4: sistemare la numerazione degli step e aggiungere lo step di pubblicazione/marketplace.
9. M3: uniformare i path `command` nei JSON degli hook; allineare il testo sull'exit code (1 vs 2).
10. Trasversale: handler errore Python `{"error":...}`; Location header su TS/Python; test caso 400; documentare DELETE 204.

**Rifiniture (🟢):**
11. Refusi/markdown: M1 `README.md:78` (bold), M1 `README.md:3` (grammatica), README root riga 45 ("dpvresti") e 129 (path `mcp.json`), M3 "il/i hook" → "lo/gli hook", M4 sezione "1b" duplicata.
12. Aggiungere `solution/python/requirements.txt` a M1 per simmetria.
13. Aggiungere a M4 un link di chiusura (al README root o a una conclusione).

---

*Report generato da analisi multi-agente (1 agente per modulo) + verifica di coerenza globale con spot-check diretti. Nessun materiale del workshop è stato modificato.*
