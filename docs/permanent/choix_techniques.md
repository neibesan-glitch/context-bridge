---
type: architecture
statut: stable
priorite: haute
tags: [permanent/architecture, adr]
derniere_maj: 2026-08-08
---

# Choix techniques et architecture (ADR)

Décisions structurantes du dépôt Context Bridge. Retour à l'[[INDEX]].

---

## Tableau des technologies

| Composant | Technologie | Version | Rôle |
| :--- | :--- | :--- | :--- |
| Protocole | Markdown | — | `AGENTS.md`, lisible par tous les agents |
| Mémoire | Git | — | Persistance et partage, sans service externe |
| Installation | Bash + PowerShell | — | Une commande sur les trois systèmes |
| Application | Hooks Claude Code | — | Vérification de passation en fin de session |
| Visualisation | Obsidian | — | Vue graphe sur `docs/`, optionnelle |
| CI | GitHub Actions | — | Test des installeurs et des invariants |

---

## Décisions d'architecture

### ADR #001 — Mémoire projet en Markdown versionné

- **Date** : 2026-06-19
- **Contexte** : besoin d'une mémoire partagée entre agents IA et développeurs, sans dépendance externe.
- **Décision** : fichiers Markdown interconnectés par wiki-links, stockés dans `docs/`, versionnés avec Git.
- **Conséquences** : persistance locale, compatibilité universelle, visualisation Obsidian, discipline de mise à jour requise.

### ADR #002 — `AGENTS.md` comme fichier canonique unique

- **Date** : 2026-08-08
- **Contexte** : le protocole était recopié à l'identique dans quatre fichiers, dont trois n'étaient lus par aucun outil. `CODEX.md` et `.github/copilot.md` n'existent dans aucune convention, et `.cursorrules` n'est pas lu par Windsurf.
- **Décision** : `AGENTS.md` porte l'intégralité du protocole. Chaque outil reçoit un pointeur court à l'emplacement qu'il lit réellement : `CLAUDE.md` avec l'import `@AGENTS.md`, `.cursor/rules/context-bridge.mdc`, `.windsurf/rules/context-bridge.md`, `.github/copilot-instructions.md`. Les formats hérités `.cursorrules` et `.windsurfrules` sont conservés comme pointeurs de quatre lignes.
- **Conséquences** :
  - Une seule source à modifier, donc plus de dérive entre agents
  - Codex fonctionne sans fichier dédié, `AGENTS.md` étant son format natif
  - Un invariant de CI interdit qu'un pointeur recopie le protocole
- **Alternative écartée** : générer les quatre fichiers depuis un gabarit à chaque commit. Rejetée : ajoute une étape de build à un projet qui n'en a aucune.

### ADR #003 — Le protocole est appliqué, pas seulement écrit

- **Date** : 2026-08-08
- **Contexte** : la passation de fin de session est demandée précisément au moment où la fenêtre de contexte sature, donc au moment où l'agent l'oublie. Une instruction en Markdown n'est pas une contrainte.
- **Décision** : un hook `Stop` Claude Code inspecte `git status` à la fin de chaque tour. Si des fichiers hors `docs/` et `.claude/` ont été modifiés sans que `docs/state.md` ni `docs/journal/journal_bord.md` ne l'aient été, il sort en code 2 et son message est renvoyé à l'agent, qui poursuit et écrit la passation. Une commande `/handoff` permet de la déclencher manuellement.
- **Conséquences** :
  - Le protocole tient sans discipline humaine
  - Risque de blocage intempestif maîtrisé par trois garde-fous : `stop_hook_active`, un seul blocage par `session_id`, sortie silencieuse hors projet Context Bridge
  - Deux implémentations à maintenir, POSIX et PowerShell, choisies par l'installeur selon la plateforme
- **Alternative écartée** : hook `PreToolUse` sur `git commit`. Rejetée : bloque un geste légitime en cours de session au lieu de vérifier la fin de session.

### ADR #004 — Séparation des gabarits et de la mémoire du dépôt

- **Date** : 2026-08-08
- **Contexte** : `docs/` servait à la fois de gabarit livré et de mémoire du dépôt. L'installeur copiait donc l'historique de sessions de Context Bridge dans le projet des utilisateurs.
- **Décision** : `template/docs/` contient les gabarits vierges installés, `docs/` contient la mémoire de ce dépôt. Les installeurs lisent `template/docs/` et écrivent dans `docs/`.
- **Conséquences** : le dépôt peut appliquer son propre protocole sans polluer les installations ; la voie « Use this template » de GitHub demande une commande de réinitialisation, documentée dans le README.

---

> Ajoutez un ADR pour chaque décision structurante.
