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

### ADR #005 — Mesurer le contenu de la passation, et fonctionner sans Git

- **Date** : 2026-08-10
- **Contexte** : le hook `Stop` de la 1.1.0 se contentait de vérifier que `docs/state.md` ou `docs/journal/journal_bord.md` apparaissait dans `git status`. Une ligne blanche ajoutée suffisait à le satisfaire. Il sortait par ailleurs silencieusement hors d'un dépôt Git, ce qui le rendait inopérant sur les projets non versionnés — cas fréquent des projets de contenu.
- **Décision** :
  - Le hook compte les lignes non vides **ajoutées** aux deux fichiers de passation pendant la session, et exige un minimum de trois.
  - Un hook `SessionStart` pose un repère dans `.claude/.cache/session-<id>` : nombre de lignes déjà présentes dans les deux fichiers, et `HEAD` courant. Ce hook n'écrit rien sur stdout, car Claude Code injecte la sortie standard d'un hook `SessionStart` dans le contexte de la session.
  - En dépôt Git, la mesure se fait par `git diff` depuis le commit mémorisé, ce qui couvre aussi une passation déjà commitée. Hors dépôt Git, elle se fait par comparaison des compteurs et des dates de modification avec le repère.
  - Sans repère (hook `SessionStart` pas encore chargé), le hook `Stop` se tait plutôt que de deviner.
- **Conséquences** :
  - Le contrôle porte sur un contenu réel, plus sur un horodatage de fichier
  - Le protocole s'applique aux projets non versionnés
  - Les deux hooks restent déterministes : aucun modèle appelé, aucun token consommé, coût constant quelle que soit la taille du projet
  - Deux hooks à maintenir en double implémentation (POSIX et PowerShell) au lieu d'un
  - Une installation 1.1.0 dont le `settings.json` ne déclare que `Stop` continue de fonctionner sans le repère : le mode Git retombe sur la comparaison de l'arbre de travail. L'installeur signale le bloc `SessionStart` à ajouter.
- **Limite assumée** : le rappel ne se déclenche qu'une fois par session. Claude Code fournit `stop_hook_active` précisément pour interdire une boucle de blocage infinie ; un verrou strict rendrait toute fin de session impossible. Le README documente donc explicitement que le mécanisme est un garde-fou ferme et non une garantie.
- **Alternative écartée** : faire relire la transcription de session par un modèle pour rédiger la passation automatiquement, à la manière de `claude-memory-compiler`. Rejetée : le coût en tokens croît avec l'historique du projet, ce qui contredit l'objectif de coût constant de Context Bridge.

---

> Ajoutez un ADR pour chaque décision structurante.
