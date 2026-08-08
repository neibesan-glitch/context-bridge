---
type: architecture
statut: stable
priorite: haute
tags: [permanent/architecture, adr]
derniere_maj: 2026-06-19
---

# Choix Techniques & Architecture (ADR)

Decisions majeures d'architecture du projet. Retour a l'[[INDEX]].

---

## Tableau des Technologies

| Composant | Technologie | Version | Role |
| :--- | :--- | :--- | :--- |
| [Composant 1] | [Techno] | [Version] | [Role] |
| [Composant 2] | [Techno] | [Version] | [Role] |
| **Documentation** | Markdown / Obsidian | - | Base de connaissances Context Bridge |

---

## Decisions d'Architecture (ADR)

### ADR #001 : Base de connaissances locale en Markdown

- **Date** : 2026-06-19
- **Contexte** : Besoin d'une memoire partagee entre agents IA et developpeurs sans dependance externe.
- **Decision** : Fichiers Markdown interconnectes par Wiki-links, stockes dans `/docs` et versiones avec Git.
- **Consequences** :
  - Persistence locale dans Git, aucune dependance externe
  - Compatible avec tous les agents IA (Claude, Cursor, Codex, Copilot)
  - Visualisable dans Obsidian (Vue Graphe)
  - Necessite une discipline de mise a jour en fin de session

---

> Ajoutez un nouvel ADR pour chaque decision technique majeure (choix de framework, changement d'architecture, migration).
