# Glossario — Termini Agentic Copilot

## Agent (in "Agent mode")
Modalità di Copilot Chat in cui l'AI può eseguire tool (Bash, Edit, Write, MCP) per portare a termine task multi-step. Diversa da "Ask mode" (solo conversazione).

## AGENTS.md
File a livello repo che descrive convenzioni, regole, contesto del progetto. Iniettato in ogni prompt della sessione agentica. Standard cross-tool.

## Hook
Event handler che intercetta il ciclo di vita Copilot (`PreToolUse`, `PostToolUse`, ecc.). Policy-as-code per gli agenti.

## MCP (Model Context Protocol)
Protocollo standard per esporre **tools** e **resources** a un agente. Un MCP server è un processo che parla questo protocollo.

## Marketplace
Registry da cui scaricare plugin. Default: "Awesome GitHub Copilot". Aziende: "Enterprise-managed plugins".

## Plugin
Bundle versionato (agent + skill + hook + MCP config) installabile come unità. Funziona in Copilot CLI, Copilot Chat (VS Code), Claude Code.

## Skill
Cartella con `SKILL.md` (frontmatter YAML + istruzioni) + script/resource. Caricata on-demand dall'agente.

## Spec-Driven Development (SDD)
Paradigma in cui una spec macchina-leggibile è la fonte di verità: l'agente genera, valida e mantiene il codice in conformità. Presentato in M5.

## Subagent
Agente "figlio" invocato dal main agent. Parte con contesto isolato. Definito in `agents/<nome>.agent.md`.
