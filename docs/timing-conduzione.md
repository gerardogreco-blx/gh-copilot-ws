# Runbook Conduzione — 90 minuti

> Documento operativo per i 2 speaker. Cosa dire, cosa cliccare, in che minuto.

## Pre-workshop (T-15 min)

- [ ] Proietta la slide di apertura con QR code al repo
- [ ] Pre-apri 1 Codespace di prova per verificare che parta
- [ ] Apri 2 finestre del terminale: una per CLI demo, una di backup
- [ ] Pre-apri il marketplace `gh-copilot-dev-days-2026` su GitHub (tab browser)
- [ ] Co-speaker prepara la sua macchina per M5 (SDD)

---

## T+00:00 — 00:05 · Intro + setup check (5')

**Gerardo:**
> "Un anno fa raccontavamo il risveglio degli agenti Copilot. Oggi gli agenti scrivono codice in produzione. In 90 minuti vediamo le 6 primitive che hanno reso possibile la transizione, e ne tocchiamo 5 con le mani."

**Verifiche di setup** (in ordine, sulla slide o lavagna):
1. *"Chi ha già fatto fork del repo nel suo account?"* — chi non l'ha fatto: link diretto `github.com/render93/gh-copilot-ws/fork`, fork → 5 secondi.
2. *"Chi ha già aperto un Codespace sul SUO fork con uno dei 3 devcontainer?"* — chi non l'ha fatto: dal proprio fork → Code → Codespaces → New con options → dropdown devcontainer.
3. *"Chi vede l'icona Copilot attiva in VS Code?"* — alzata di mano.

**Co-speaker:** gira tra i banchi, aiuta chi è bloccato in uno dei 3 step.

**Promessa**:
> "A fine workshop avrai un repo personale (il tuo fork!) con: AGENTS.md, una skill custom, un MCP attivo, un subagent, un hook di safety, un plugin bundle. Te lo porti a casa, lo committi, lo pushi."

**Anti-pattern da evitare in apertura**:
- Non lasciare che qualcuno apra il Codespace dal repo di Gerardo direttamente: non potrà pushare. Spingere TUTTI sul fork prima.

---

## T+00:05 — 00:23 · M1 Istruzioni (18')

- [00:05] Teoria (5'): AGENTS.md (best practice, <200 righe, iniettato ogni prompt) + Skill (frontmatter, on-demand).
- [00:10] Step 1 (3'): chiediamo `/tasks/stats`. Tutti seguono.
- [00:13] Step 2 (5'): creiamo skill `endpoint-creator`. Rifacciamo la richiesta.
- [00:18] Step 3 (2'): diff prima/dopo.
- [00:20] Wrap (3'): AGENTS.md = chi sei, Skill = cosa sai fare bene.

**Sync point [00:23]:** *"Chi è indietro: copia da `solution/`. Si riparte tutti insieme."*

---

## T+00:23 — 00:41 · M2 Capacità (18')

- [00:23] Teoria (5'): Subagent (frontmatter, contesto isolato) + MCP.
- [00:28] Step 1 (4'): attivare Context7, vedere docs in chat.
- [00:32] Step 2 (4'): invocare `@code-reviewer`.
- [00:36] Step 3 (2'): composizione subagent + Context7.
- [00:38] Wrap (3').

**Sync point [00:41]:** *"Si chiude M2. Aprite M3."*

---

## T+00:41 — 00:55 · M3 Governance (14')

- [00:41] Teoria (4'): hook = policy-as-code. Eventi. Hook non prompt-injectable.
- [00:45] Step 1 (2'): blocco `rm -rf` visibile.
- [00:47] Step 2 (3'): estendere policy con `.env`.
- [00:50] Step 3 (2'): customizzare messaggio.
- [00:52] Wrap (3'): bridge a M4: *"stesso pattern di hook lo vedete in dev-guardian tra 10 secondi."*

**Sync point [00:55]:** transizione naturale.

---

## T+00:55 — 01:09 · M4 Distribuzione (14')

- [00:55] Teoria (4'): plugin bundle, marketplace, 3 superfici.
- [00:59] Step 1 (3'): Gerardo proietta CLI:
  ```
  copilot plugin marketplace add https://github.com/render93/gh-copilot-dev-days-2026.git
  copilot plugin install dev-guardian
  ```
  I partecipanti installano da VS Code Chat marketplace UI.
  **Frase chiave**: *"Stesso bundle, tre superfici (CLI + VS Code + Claude Code), una pipeline."*
- [01:02] Step 2 (4'): impacchettare `copilot-safety-guard`.
- [01:06] Wrap (3').

**Sync point [01:09]:** Gerardo passa il microfono.

---

## T+01:09 — 01:21 · M5 Spec-Driven Development (12')

**Co-speaker** prende la sala.

Bridge da Gerardo:
> "I 4 moduli ti hanno dato i mattoni. Ora [co-speaker] ti mostra il paradigma che li unisce."

(Contenuto da definire col co-speaker prima del workshop.)

---

## T+01:21 — 01:30 · Q&A + outro (9')

**Gerardo + co-speaker insieme**.

Domande tipiche:
- Hook in CI?
- Versionare policy.yml col repo? (sì)
- Quando MCP custom?
- Plugin private aziendali?
- SDD per legacy?

**Outro:**
> "Cosa porti a casa: il tuo fork con tutto dentro. Lunedì mattina copia il policy.yml in un repo aziendale. Grazie."

---

## Gestione guasti

Vedi tabella in §6 del design doc.

## Strumenti aperti per Gerardo
- Browser: tab repo workshop + tab marketplace
- Terminale 1: Copilot CLI loggato
- Terminale 2: backup
- VS Code: Codespace dal proiettore
