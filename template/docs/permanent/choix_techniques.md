---
type: architecture
statut: stable
priorite: haute
tags: [permanent/architecture, adr]
derniere_maj: 2026-08-08
---

# Choix techniques et architecture (ADR)

Décisions majeures d'architecture du projet. Retour à l'[[INDEX]].

---

## Tableau des technologies

| Composant | Technologie | Version | Rôle |
| :--- | :--- | :--- | :--- |
| [Composant 1] | [Techno] | [Version] | [Rôle] |
| [Composant 2] | [Techno] | [Version] | [Rôle] |
| **Documentation** | Markdown / Obsidian | — | Base de connaissances Context Bridge |

---

## Décisions d'architecture

### ADR #001 — Mémoire projet en Markdown versionné

- **Date** : [AAAA-MM-JJ]
- **Contexte** : plusieurs agents IA et développeurs travaillent sur ce projet et perdent le contexte entre les sessions.
- **Décision** : mémoire partagée en fichiers Markdown interconnectés, stockée dans `docs/` et versionnée avec Git, protocole de passation dans `AGENTS.md`.
- **Conséquences** :
  - Aucune dépendance externe, la mémoire suit le dépôt
  - Compatible avec tous les agents (Claude Code, Cursor, Codex, Copilot, Windsurf)
  - Visualisable dans Obsidian
  - Demande une discipline de mise à jour en fin de session, appliquée par le hook `Stop`

---

> Ajoutez un ADR pour chaque décision structurante : choix de framework, changement d'architecture, migration, format de données.
