# Workshop "The Agent Strikes Back" — Design Document

**Data design**: 2026-05-24
**Autori**: Gerardo Greco (speaker) + co-speaker
**Stato**: Draft per review utente
**Evento**: GitHub Copilot Workshop 2026

---

## 1. Contesto e obiettivi

### Pitch dell'evento (esistente)

> **The Agent Strikes Back: l'anno in cui gli agenti hanno preso il controllo.**
> Un anno fa raccontavamo il "risveglio" degli agenti di GitHub Copilot. Oggi gli agenti non sono più una promessa, ma strumenti di produzione che stanno ridisegnando come scriviamo, revisioniamo e rilasciamo software. In questa sessione esploriamo AGENTS.md come standard condiviso, le Skills come unità componibili, gli agenti end-to-end dal backlog alla pull request, gli MCP server e — implicitamente — come governare gli agenti nei team senza perdere controllo su qualità, sicurezza e sostenibilità del codice.

### Obiettivo del workshop

In **90 minuti hands-on**, ogni partecipante esce con un repo personale in cui ha **toccato con mano** le 6 primitive che hanno trasformato Copilot da assistente passivo a tool agentic di produzione:

1. `AGENTS.md`
2. Skills
3. Subagents
4. MCP server (uso, non creazione)
5. Hooks
6. Plugins & Marketplace

### Promessa al partecipante (frase di apertura)

> *"A fine workshop avrai nel tuo GitHub un repo personale con un agente Copilot configurato, una skill custom, un MCP server attivo, un subagent dedicato, un hook che blocca azioni pericolose, e un plugin bundle pronto da pubblicare. Te lo porti a casa."*

### Cosa NON è questo workshop (gestione aspettative)

- **Non** si crea un MCP server da zero — solo uso (esplicita richiesta).
- **Non** si fa Spec-Driven Development hands-on — è presentato come **intro concettuale finale** dal co-speaker, all'interno della stessa sessione (vedi §4.5).
- **Non** si pubblica un plugin sul Marketplace pubblico — si vede *come* si farebbe.

### Tre principi guida

1. **Tempo reale > completezza.** Meglio fare un esercizio piccolo davvero che 10 perfetti in slide.
2. **Copia, modifica, capisci.** Niente è scritto da zero in 90 min. Si parte da starter ready-to-run.
3. **Tre linguaggi, una pedagogia.** .NET / TypeScript / Python sono "sapori"; il modello mentale è lo stesso.

---

## 2. Audience e parametri operativi

| Parametro | Valore |
|---|---|
| Durata | 90 minuti |
| Formato | Hands-on (i partecipanti fanno, non solo guardano) |
| Audience | Mista junior → senior |
| Superficie primaria | GitHub Copilot in **VS Code** (con cenni a Copilot CLI e Claude Code in M4 — stesso bundle plugin, tre superfici) |
| Lingua materiali | Italiano per testi rivolti ai partecipanti, inglese per nomi tecnici/codice/branch |
| Ambiente | GitHub Codespaces (devcontainer pre-configurato) |
| Starter linguaggi | .NET, TypeScript, Python (3 starter per modulo) |
| Speaker in aula | 2 (Gerardo + co-speaker che gira durante hands-on) |
| Timer | Gestito dagli speaker dal palco (no timer integrato nel repo) |
| Prerequisiti partecipante | Account GitHub + idealmente Copilot Pro/Business/Enterprise attivo |

### Nota sui piani Copilot (maggio 2026)

- **Copilot Free**: funziona ma ha limiti stretti (~50 chat msg/mese). Esauribili in metà workshop. Plan B: pair con il vicino.
- **Copilot Pro/Pro+**: dal **20 aprile 2026 nuovi signup pausati**. Chi non ce l'ha già non può attivarlo ora.
- **Copilot Business/Enterprise**: ideale per partecipanti aziendali.

---

## 3. Approccio strutturale: 4 moduli macro

Tra 3 approcci valutati (6 moduli 1:1 / 4 moduli accoppiati / 6 moduli low-floor-high-ceiling), scelto **4 moduli macro per accoppiamenti naturali**.

**Motivazione**:
- 18 min/modulo permettono di fare davvero qualcosa, non solo "guardare e copy-paste".
- Gli accoppiamenti raccontano una storia coerente: **istruzioni → capacità → governance → distribuzione**.
- Con 18 min c'è naturalmente spazio per uno "stretch goal" per i senior senza ramificare formalmente.

### Timeline 90 minuti

```
00:00 – 00:05  Intro + setup check (apri Codespace, verifica Copilot)  (5')
00:05 – 00:23  M1 "Istruzioni" — AGENTS.md + Skills                    (18')
00:23 – 00:41  M2 "Capacità"   — Subagents + MCP (Context7)            (18')
00:41 – 00:55  M3 "Governance" — Hooks (safety guard)                  (14')
00:55 – 01:09  M4 "Distribuzione" — Plugins & Marketplace              (14')
01:09 – 01:21  M5 "Spec-Driven Development" — intro paradigma          (12')
01:21 – 01:30  Q&A + outro ("cosa portarti a casa")                    (9')
```

**Nota su M5/SDD**: è presentato dal **co-speaker** (collega di Gerardo) nella stessa sessione, come *chiusura concettuale*. Non hands-on — è un'intro al paradigma SDD che dà senso a tutto quello che si è costruito nei moduli 1-4 (*"hai i mattoni, ora vediamo come si combinano in un nuovo modo di lavorare"*).

### Indipendenza dei moduli

Ogni modulo è **autosufficiente**: cartella propria, starter propri, **cartella `solution/` con lo stato finale del modulo** già pronto (una sottocartella per ognuno dei 3 linguaggi). Se un partecipante si blocca o arriva in ritardo, apre il modulo successivo e riparte pulito.

**Repo a branch unico**: niente branch dedicati per modulo o per soluzione — tutto convive nello stesso branch principale. Le `solution/` sono semplici cartelle (più semplice per i partecipanti, niente `git checkout` durante il workshop).

**Sync point** a fine di ogni modulo (1 min): lo speaker fa partire dal proiettore lo stato `modules/Mn/solution/` e tutti possono allinearsi prima di iniziare il successivo. Nessuno resta indietro per più di 18 minuti.

---

## 4. I 4 moduli in dettaglio

### M1 — "Istruzioni" · AGENTS.md + Skills · 18 min

**Pedagogia**: la prima cosa che fa un agente moderno è leggere "chi sei" (AGENTS.md) e "cosa sai fare" (Skills). Sono i mattoni più basici e portabili.

**Teoria (5')**

*AGENTS.md (2')*
- Standard condiviso (Copilot/Claude/altri coding agent) — il "system prompt" del repo, **iniettato in ogni prompt** della sessione agentica.
- **Cosa deve contenere** (best practice):
  - regole architetturali del progetto (stack, layering)
  - convenzioni di codice (naming, error handling, validation, test pattern)
  - vincoli "non negoziabili" (es. "mai modificare X", "sempre eseguire Y prima di commit")
  - punti di ingresso utili (file/cartelle dove cercare cosa)
- **Cosa NON deve contenere**: documentazione esaustiva del progetto, esempi prolissi, storie/decisioni storiche, contenuto che cambia spesso.
- **Vincoli di lunghezza**: idealmente **< 200 righe**, hard-cap pratico ~500 righe. Sopra questa soglia: (a) costa token a ogni prompt, (b) l'agente "annacqua" l'attenzione, (c) sintomo che andrebbe spezzato in Skill. La regola: *"se serve solo a volte, non sta in AGENTS.md, sta in una Skill"*.

*Skill (2')*
- Unità componibile, on-demand, caricata dal'agente quando rilevante (non sempre).
- **Anatomia di una Skill**:
  ```
  skills/<nome-skill>/
  ├── SKILL.md          ← frontmatter YAML + corpo istruzioni
  ├── scripts/          ← (opzionale) script/helper invocabili
  └── resources/        ← (opzionale) template, esempi, schema
  ```
- **Frontmatter SKILL.md** (cosa scrivere):
  ```yaml
  ---
  name: endpoint-creator
  description: Come si crea un nuovo endpoint REST in questo repo (validazione, test, error handling)
  ---
  ```
  Il `description` è critico: è la **frase su cui l'agente decide se caricare la skill**. Va scritta bene, in termini di *quando* è utile, non di *cosa* contiene.

*Differenza pratica (1')*
- AGENTS.md = identità/regole costanti, sempre attivo, paga token sempre.
- Skill = know-how specifico, attivato on-demand, paga token solo se serve.
- Cheat mnemonico: *"AGENTS.md = chi sei, Skill = cosa sai fare bene"*.

**Hands-on (10')**
1. *(3')* Aprire `AGENTS.md` esistente nello starter scelto (dotnet/ts/python). Chiedere in agent mode: *"aggiungi un endpoint `GET /tasks/stats` con conteggio task per stato"*. Osservare che l'agente segue le convenzioni del file (naming, validazione, struttura test).
2. *(5')* Creare `skills/endpoint-creator/SKILL.md` con regole "come si fa un endpoint qui" (zod / FluentValidation / pydantic; test obbligatorio; error handling tipato). Rifare la stessa richiesta — confrontare l'output.
3. *(2')* Diff visivo: prima senza skill / dopo con skill.

**Wrap (3')**: quando usare AGENTS.md vs Skill. AGENTS.md per regole sempre valide nel repo; Skill per know-how specifico richiamato on-demand.

**Output portabile**: AGENTS.md letto e capito, una skill custom in `skills/endpoint-creator/`.

---

### M2 — "Capacità" · Subagents + MCP (Context7) · 18 min

**Pedagogia**: un agente da solo è limitato dal suo training. I subagent espandono la sua capacità computazionale (delega); MCP espande la sua capacità sensoriale (tool nuovi).

**Teoria (5')**

*Subagent (2.5')*
- Task delegato a un agente "figlio" che parte con **contesto isolato** (non eredita la chat precedente, solo il prompt che gli passi). Restituisce un risultato strutturato al main agent.
- **Perché contesto isolato**: (a) il subagent non "annacqua" la sua attenzione con la conversazione precedente, (b) il main agent riceve un riassunto pulito invece dei dettagli intermedi, (c) parallelizzabile (più subagent in parallelo per task indipendenti).
- **Quando usare un subagent vs ask mode**: subagent quando il task è ben definito e isolabile (review di un file, refactor di una funzione, ricerca focalizzata, generazione di test). Ask mode quando vuoi una conversazione iterativa.
- **Anatomia di un subagent**:
  ```
  agents/<nome-agent>.agent.md      ← frontmatter YAML + system prompt
  ```
- **Frontmatter `.agent.md`** (cosa scrivere):
  ```yaml
  ---
  name: code-reviewer
  description: Subagent specializzato in code review (correttezza, sicurezza, conformità ad AGENTS.md di questo repo)
  tools: [Read, Grep, Bash]        # tool che ha a disposizione (allowlist)
  model: claude-sonnet-4-6         # opzionale: modello da usare
  ---
  ```
  Il `description` è il criterio con cui il main agent decide *quando* invocarlo. `tools` permette di restringere cosa il subagent può fare (principio del minimo privilegio).

*MCP (1.5')*
- "USB-C per i tool dell'agente". È *come* estendi le capacità, non *chi* le usa.
- Un MCP server espone tool (funzioni invocabili) e/o risorse (dati leggibili) via protocollo standard. Copilot può connettersi a MCP locali o remoti.
- **Quando un MCP ha senso**: quando il problema **non è già risolto** da una CLI standard. Esempio: `gh-mcp` ha senso meno (`gh` CLI esiste già). **Context7** ha senso: porta docs aggiornate delle librerie, problema non risolto da CLI standard.

*Insieme (1')*
- Subagent = chi fa il lavoro, con quale contesto, su quale slice di scope.
- MCP = quali tool e quali dati ha in mano.
- Combinazione: un subagent code-reviewer che usa Context7 per verificare API attuali → pattern componibile.

**Scelta MCP server**: **Context7**.
Motivo: molti MCP "famosi" (es. `github-mcp`) hanno controparte CLI (`gh`) che le rende meno didattiche — *"perché chiamare MCP se ho già `gh`?"*. Context7 invece risolve un problema **vero e non risolto altrimenti**: portare a Copilot le **docs aggiornate** delle librerie del progetto. Un MCP che ha senso davvero.

**Hands-on (10')**
1. *(4')* Attivare Context7 (già preconfigurato nel devcontainer). Da agent mode: *"usando le docs attuali di [libreria scelta nello starter], rifattorizza l'handler di POST /tasks per usare l'API più recente"*. Osservare l'MCP fetchare le docs in chat.
2. *(4')* Aprire `agents/code-reviewer.agent.md` precompilato. Invocare il subagent: *"@code-reviewer revisiona `tasks_controller`"*. Vedere contesto isolato + risposta strutturata.
3. *(2')* Combinare: chiedere al subagent di **usare Context7** per verificare che il codice rispetti l'API attuale della libreria. *"Lo stesso pattern, scalato."*

**Wrap (3')**: subagent = chi, MCP = con cosa. Insieme = sistema componibile.

**Output portabile**: Context7 attivo + un subagent custom funzionante.

---

### M3 — "Governance" · Hooks · 14 min

**Pedagogia**: gli hook sono **policy-as-code per gli agenti**. Sono il modo per portarli in produzione senza paura: li lasci liberi di fare, ma con barriere esplicite e auditabili.

**Teoria (4')**
- Cos'è un hook: event handler che intercetta il ciclo di vita Copilot (`PreToolUse`, `PostToolUse`, `UserPromptSubmit`, `SubagentStart`, ecc.).
- Use case: **guardrail** (blocca azioni pericolose), **audit** (logga cosa fa l'agente), **automazione** (esegui qualcosa a fine sessione).
- Punto chiave: gli hook sono **dell'organizzazione**, non dell'LLM. Non si possono "prompt-injectare via". Sono enforcement vero.

**Hands-on (7') — un singolo esercizio profondo: safety guard**

Configurare un `PreToolUse` hook che intercetta le invocazioni di Bash/Edit/Write/MultiEdit e le valuta contro una policy file (`.copilot/policy.yml` o JSON con regex/regole). Se la chiamata viola la policy, l'hook **blocca** restituendo errore + messaggio leggibile dall'agente.

**Pattern bloccati (preset nel repo)**:
- shell: `rm -rf`, `git push --force`, `git reset --hard`, `DROP TABLE`, `DELETE FROM ... ` senza `WHERE`
- file: scritture su `.env`, `secrets/`, `*.key`, `*.pem`
- bonus aziendale: `prod-config.yaml` immutabile

**Flusso**:
1. *(2')* Aprire `.copilot/policy.yml` di partenza (con `rm -rf` già bloccato). Chiedere a Copilot: *"fai pulizia di /tmp"*. L'agente prova `rm -rf /tmp/*`, l'hook blocca, l'agente riformula con `find ... -delete`. Vedere il behaviour change.
2. *(3')* Estendere la policy con 1-2 regole nuove (es. blocco scrittura `.env`). Provarle: *"crea un file `.env` con credenziali demo"* → blocco visibile.
3. *(2')* Customizzare il messaggio di blocco. L'agente reagisce diversamente se gli spieghi *perché* è bloccato vs un secco "no".

**Wrap (3')**: hook = fiducia controllata. Il punto della frase finale: *"questo `policy.yml` puoi copiarlo nel repo aziendale lunedì mattina"*.

**Output portabile**: `.copilot/policy.yml` riusabile + hook PreToolUse funzionante.

**Bridge a M4**: *"questo stesso pattern di hook lo trovi dentro `dev-guardian/hooks/postToolUse` del marketplace che useremo tra poco — stesso meccanismo, applicato all'audit"*.

---

### M4 — "Distribuzione" · Plugins & Marketplace · 14 min

**Pedagogia**: un plugin è un bundle versionato e installabile (agent + skill + hook + MCP config). Trasforma il lavoro privato in artefatto condivisibile col team / l'organizzazione.

**Teoria (4')**
- Plugin = bundle (agent custom + skill + hook + MCP config) con manifest.
- Marketplace:
  - **Awesome GitHub Copilot** come default per CLI e VS Code Chat.
  - **Enterprise-managed plugins** per distribuzione interna controllata.
- **Portabilità sottolineata**: stesso bundle, due superfici (CLI + VS Code), una pipeline.

**Hands-on (7')**

**Step 1 — Installare un plugin reale** *(3')*
- Speaker dal proiettore (Copilot CLI):
  ```
  copilot plugin marketplace add https://github.com/render93/gh-copilot-dev-days-2026.git
  copilot plugin install dev-guardian
  ```
- In parallelo i partecipanti dal Codespace (VS Code Copilot Chat) installano lo stesso plugin dal marketplace UI.
- **Cenno a Claude Code**: lo stesso plugin (essendo bundle di artefatti standard: skill, agent, hook, MCP config) è compatibile anche con **Claude Code** — l'evento dimostra concretamente che AGENTS.md non è l'unico standard cross-tool: l'intero modello plugin lo è.
- **Frase chiave dal palco**: *"Hai imparato AGENTS.md come standard cross-tool. Lo stesso vale per i plugin: stesso bundle, **tre superfici** (Copilot CLI, Copilot Chat in VS Code, Claude Code), una pipeline di distribuzione."*
- Esplorare cosa fornisce `dev-guardian` (3 skill + agent `test-writer` + MCP filesystem + 2 hook `postToolUse`/`sessionStart`). Bridge a M3: *"l'hook che hai costruito tu segue lo stesso pattern di questi"*.

**Step 2 — Impacchettare il proprio plugin** *(4')*
- Prendere skill (M1) + subagent (M2) + hook safety (M3) e impacchettarli come **plugin locale** in `plugins/copilot-safety-guard/`.
- Creare manifest (`plugin.json` o equivalente) che lista i 3 componenti.
- **Punto pedagogico**: questo è un asset tematico vendibile (*"un plugin che chiunque vorrebbe nel repo aziendale: skill compliance + reviewer + safety hook"*) — non un mix eterogeneo.
- Si vede *come* si pubblicherebbe (`copilot plugin marketplace add <url-del-tuo-fork>`). Non si pubblica davvero per non spammare i marketplace pubblici.

**Wrap (3')**: da artefatto privato → artefatto distribuibile. Plugin = unit of distribution dell'agentic dev.

**Output portabile**: `plugins/copilot-safety-guard/` con manifest e tutti i componenti, pronto in teoria da pubblicare.

---

### M5 — "Spec-Driven Development" · 12 min · presentato dal co-speaker

**Pedagogia**: i 4 moduli precedenti hanno costruito **i mattoni** dell'agentic dev (istruzioni, capacità, governance, distribuzione). SDD è **il paradigma** che li unisce in un nuovo modo di lavorare: definisci una spec macchina-leggibile del comportamento desiderato → l'agente la usa come oracolo per generare, validare, mantenere il codice.

**Format**: **non hands-on** — è un'intro concettuale + demo guidata dal proiettore. Il co-speaker (collega di Gerardo) prende la sala per 12 min.

**Suggerimento contenuto (da rifinire col co-speaker)**
- *(3')* **Cos'è SDD**: la spec come "fonte di verità" su cui l'agente lavora. Non più "codice → cerca di capire l'intento", ma "intento esplicito → codice e test derivati".
- *(5')* **Demo proiettata**: il co-speaker mostra un mini-esempio end-to-end (es. partendo da una spec si genera codice + test + verifica conformità). Idealmente usa **gli stessi mattoni del workshop**: AGENTS.md per le regole, una skill per il flusso SDD, MCP per arricchire la spec con docs aggiornate.
- *(3')* **Perché dopo i 4 moduli**: SDD ha senso solo se hai i mattoni. Mostrare il loop: spec → agent → review (subagent) → guardrail (hook) → distribuzione (plugin). Tutto torna.
- *(1')* **Call to action**: link al materiale del co-speaker in `docs/follow-up.md` per chi vuole approfondire.

**Coordinamento con il co-speaker** (da fare nei giorni prima del workshop):
- Allineare il vocabolario (es. "skill" significhi la stessa cosa in entrambe le metà).
- Concordare la frase di bridge che Gerardo dice in chiusura di M4 → "ora il microfono passa a [collega] per chiudere il cerchio con il paradigma SDD".
- Decidere quale esempio usa il co-speaker (idealmente collegato alla Task API del workshop, per continuità — ma è una scelta del co-speaker).

**Output portabile (per il partecipante)**: la **comprensione concettuale** del paradigma SDD + i link nel follow-up per approfondire. Niente artefatti hands-on in M5.

---

## 5. Architettura del repo

### Struttura

```
copilot-workshop-2026/
├── README.md                       ← landing italiano: obiettivi, setup, Codespace button
├── .devcontainer/
│   ├── devcontainer.json           ← Node + .NET SDK + Python, Copilot ext, GH CLI loggata
│   ├── post-create.sh              ← restore deps, MCP demo setup
│   └── mcp-servers/
│       └── context7/               ← Context7 pre-configurato
├── AGENTS.md                       ← root AGENTS.md di esempio (unica fonte di verità — niente copilot-instructions.md per non duplicare/confondere)
├── docs/
│   ├── 00-intro.md                 ← teoria base: agent mode, AGENTS.md, glossario rapido
│   ├── glossario.md                ← cheat-sheet termini agentic
│   ├── timing-conduzione.md        ← runbook speaker: cosa dire/cliccare al minuto
│   └── follow-up.md                ← link post-workshop (Awesome Copilot, docs, Context7, repo dev-days)
└── modules/
    ├── M1-istruzioni/
    │   ├── README.md               ← teoria (5') + hands-on (10') + wrap (3')
    │   ├── starters/
    │   │   ├── dotnet/             ← Task API funzionante
    │   │   ├── typescript/         ← Task API funzionante
    │   │   └── python/             ← Task API funzionante
    │   └── solution/               ← cartella con stato finale del modulo (3 sottocartelle per linguaggio)
    ├── M2-capacita/                ← stessa struttura
    ├── M3-governance/              ← stessa struttura
    └── M4-distribuzione/           ← stessa struttura
```

### Convenzioni

- **Lingua**: italiano nei `.md` rivolti ai partecipanti (README, teoria, hint); inglese per nomi file, branch, codice, slug.
- **Cartella `modules/Mn/solution/`** in ogni modulo: chi si blocca apre la `solution/` e copia. Nessuna vergogna — la promessa è *"a fine workshop hai tutto"*, non *"hai scritto tutto"*.
- **Starter triplo per modulo**: dentro ogni `modules/Mn/starters/{dotnet,typescript,python}/` la stessa Task API. Stesso comportamento, 3 implementazioni.

### Scenario applicativo condiviso: Task API

Per dare contesto concreto a tutti gli esercizi, gli starter implementano una **Task API minimale** con 3 endpoint:
- `GET /tasks` — lista task
- `POST /tasks` — crea task
- `PATCH /tasks/:id` — aggiorna stato

Già funzionante in tutti e 3 i linguaggi. Gli esercizi del workshop **non aggiungono feature di business** — usano questa API come "campo di gioco" su cui far lavorare l'agente.

### Codespace

- **Un solo `devcontainer.json` di root** con tutti e 3 gli SDK (Node, .NET, Python). Immagine grossa ma è in cloud, non importa.
- Estensione Copilot preinstallata, GitHub CLI autenticata.
- Context7 MCP già configurato in `.devcontainer/mcp-servers/`.
- **Tasto "Open in Codespace"** prominente nel README.
- **Fallback locale** documentato (uno solo dei 3 SDK è sufficiente per chi sceglie un linguaggio).

---

## 6. Setup pre-workshop e gestione errori

### Email pre-workshop (1 settimana prima)

```
Per il workshop di [data] ti serve:

✅ Account GitHub
✅ Almeno UNO di questi sblocca l'esperienza completa:
   - Copilot Pro/Pro+/Business attivo, OPPURE
   - Licenza Copilot via organizzazione, OPPURE
   - Copilot gratis come studente/teacher/OSS maintainer
   ⚠️ Copilot Free funziona ma con limiti molto stretti (~50 chat msg/mese)

✅ Browser moderno

NON serve installare niente in locale — usiamo GitHub Codespaces.

Test "ready":
1. Apri [URL repo workshop]
2. Click "Open in Codespace"
3. Attendi ~2 min
4. Verifica icona Copilot attiva
5. Problemi → rispondi a questa mail entro [data -2gg]
```

### Setup check in apertura (primi 5 minuti)

1. Slide con QR code + URL repo.
2. *"Chi ha Codespace aperto e Copilot attivo? Alza la mano."* — conteggio rapido.
3. Co-speaker gira tra chi non ha la mano alzata.
4. **Plan B se nulla funziona**: pair col vicino. Funziona anche meglio (uno guida, uno osserva).

### I 5 guasti più probabili e i Plan B

| Guasto | Sintomo | Plan B |
|---|---|---|
| Codespace non parte | Spinner / errore quota | github.dev oppure pair col vicino |
| Copilot non si autentica | Icona spenta | Palette → "GitHub Copilot: Sign In" |
| Limite Copilot Free raggiunto | Chat non risponde | Pair col vicino che ha Pro |
| Agent mode assente | Solo "Ask" | Verifica versione estensione, reload window |
| MCP server non parte | Errore in chat | la `solution/` del modulo include un fallback mock offline |

### Convenzioni rescue durante i moduli

- **Cartellino verde/giallo** (post-it sul laptop): 🟢 ok / 🟡 bloccato → co-speaker arriva.
- **`modules/Mn/solution/`** cartella sempre disponibile: bloccato per >90s? Copia la solution e prosegui.
- **Sync point** di 1 min a fine ogni modulo: speaker proietta `modules/Mn/solution/`, tutti si allineano.
- **Timer dal palco**, gestito dagli speaker (no timer integrato nel repo).

---

## 7. Materiali di follow-up (`docs/follow-up.md`)

Risorse curate da consultare dopo:
- **Awesome GitHub Copilot** — il marketplace ufficiale + curato.
- **render93/gh-copilot-dev-days-2026** — il marketplace di Gerardo come reference completa di 3 plugin reali.
- **Microsoft Learn** — pagine ufficiali su agent mode, AGENTS.md, MCP, plugins.
- **Context7** — guida all'uso esteso (link al sito ufficiale).
- **Awesome MCP servers** — directory di MCP utili.
- **SDD (a cura del co-speaker)** — link/materiali per approfondire dopo il workshop, allineati a quanto presentato in M5.

---

## 8. Definition of Done del repo (prima del workshop)

Il repo è "pronto" quando:

- [ ] Devcontainer apre in Codespace in <3 min, Copilot attivo, GH CLI autenticata, Context7 funzionante.
- [ ] Task API gira nei 3 linguaggi in ogni starter di modulo.
- [ ] M1, M2, M3, M4 con README italiano, starter ×3, cartella `modules/Mn/solution/` (3 sottocartelle per linguaggio), artefatti pronti.
- [ ] M5/SDD allineato col co-speaker: slide/demo, frase di bridge, link follow-up.
- [ ] `docs/timing-conduzione.md` scritto come runbook minuto-per-minuto per i 2 speaker.
- [ ] `docs/glossario.md` e `docs/follow-up.md` popolati.
- [ ] **Dry-run end-to-end completo** fatto almeno 1 volta dai due speaker, cronometrato.
- [ ] Email pre-workshop scritta e schedulata.
- [ ] QR code / shortlink al repo pronti per la slide di apertura.

---

## 9. Decisioni di design (registro)

| Decisione | Scelta | Motivazione |
|---|---|---|
| Durata | 90 min hands-on | Dato di input fisso |
| Struttura | 4 moduli macro (B) | Realistico per timing + audience mista; storia coerente |
| Superficie | VS Code Copilot Chat | Richiesto da Gerardo |
| Coppie di moduli | Istruzioni / Capacità / Governance / Distribuzione | Accoppiamenti pedagogici naturali |
| Indipendenza moduli | Sì + cartella `solution/` per modulo | Audience mista, no "perde-tutto-se-blocca" |
| Linguaggi | dotnet / typescript / python | Audience italiana eterogenea per stack |
| Lingua materiali | italiano (testi) + inglese (codice/nomi) | Accessibilità + standard tecnico |
| Ambiente | Codespaces, devcontainer unico | Zero setup locale |
| MCP server vetrina | **Context7** | Risolve problema vero non coperto da CLI come `gh` |
| Plugin reale in M4 | **render93/gh-copilot-dev-days-2026** | Autentico, tematico, gira in CLI + VS Code |
| Hook in M3 | Safety guard (PreToolUse + policy.yml) | Più didattico + tema vendibile |
| Plugin del partecipante | "copilot-safety-guard" coerente | Bundle tematico, non mix eterogeneo |
| Plugin reale in M4 step 1 | `dev-guardian` | Continuità narrativa: stesso pattern hook visto in M3 |
| SDD | **Dentro la sessione**, 12 min finali, presentato dal co-speaker (non hands-on) | Chiude il cerchio: i 4 moduli costruiscono i mattoni, SDD è il paradigma che li unisce |
| Cenni cross-tool | Copilot CLI + Claude Code in M4 | Sottolinea che il modello plugin è standard cross-vendor, non solo cross-superficie Copilot |
| Branch | Repo a branch unico, niente branch per soluzione | Cartella `solution/` per modulo è più semplice (no `git checkout` durante workshop) |
| `copilot-instructions.md` | **Non usato** | Specifico Copilot; AGENTS.md è già la fonte di verità — duplicarli crea confusione |
| Speaker | 2 (Gerardo + co-speaker) | Co-speaker gira tra i banchi durante hands-on |
| Timer | Dal palco, non integrato | Gestito dagli speaker |

---

## 10. Questioni ancora aperte (da risolvere prima di iniziare l'implementazione)

1. **Confermare Context7 funzionante dal devcontainer.**
   Va testato che la sua configurazione MCP parta in Codespace senza interventi. Se troppo flaky, fallback su un MCP più stabile (es. `mcp-filesystem`).

2. **Codespace ha senso anche per chi sceglie .NET?**
   L'immagine devcontainer con .NET SDK + Node + Python è grossa (~2-3 GB). Verificare che parta in tempi accettabili (~2-3 min). Se non, valutare 3 devcontainer separati (più complesso ma più snello).

3. **Awesome Copilot vs solo render93 in `docs/follow-up.md`?**
   Confermare quali link "vetrina" mettere come prossimi passi.

4. **Allineamento col co-speaker su M5/SDD**: agenda, demo da usare, frase di bridge, link da inserire nel follow-up. Da fare nei giorni prima del workshop.

---

## 11. Prossimi passi

1. **Review utente di questo documento** (Gerardo).
2. Modifiche eventuali → re-review.
3. Una volta approvato, transizione a **writing-plans** per produrre un piano implementativo step-by-step (creazione repo, devcontainer, moduli, starter, cartelle solution, docs, dry-run).
