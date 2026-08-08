---
name: context-bridge
description: Installe ou met à jour Context Bridge dans le projet courant — un protocole de mémoire partagée entre agents IA (Claude Code, Cursor, Codex, Copilot, Windsurf) basé sur un dossier docs/ versionné avec Git, un fichier AGENTS.md canonique et un hook de fin de session. À utiliser quand l'utilisateur dit "context-bridge", "initialise la mémoire projet", "ajoute le protocole de handoff", "mets en place la continuité entre agents", ou demande que les agents arrêtent de perdre le contexte d'une session à l'autre.
---

# Context Bridge

Protocole de mémoire partagée et de continuité entre agents IA. Installe dans le projet courant la structure de documentation et les fichiers de directives qui permettent à chaque agent de reprendre exactement là où le précédent s'est arrêté.

## Ce que fait ce skill

1. Crée la base de connaissances `docs/` (état, roadmap, carte du code, ADR, journaux)
2. Crée `AGENTS.md`, le fichier canonique qui porte le protocole
3. Crée les pointeurs natifs de chaque outil, qui renvoient tous vers `AGENTS.md`
4. Installe le hook Claude Code qui vérifie la passation en fin de session
5. Pré-remplit la carte du code à partir du projet réel

Tout est en Markdown, versionné avec Git, compatible Obsidian.

## Instructions

### Étape 1 — Vérifier l'existant

Cherche `docs/INDEX.md`, `AGENTS.md` et `CLAUDE.md` à la racine.

- Si `docs/INDEX.md` existe : Context Bridge est déjà installé. Propose une mise à jour (rafraîchir uniquement les fichiers de directives et les hooks, sans jamais toucher au contenu de `docs/`) plutôt qu'une réinstallation.
- Si `CLAUDE.md` existe sans Context Bridge : ne l'écrase pas, ajoute l'import en tête de fichier.

### Étape 2 — Créer la base de connaissances

```
docs/
├── INDEX.md                      # Point d'entrée, wiki-links
├── CODE_MAP.md                   # Architecture du projet
├── state.md                      # État courant (résumé 5 lignes)
├── roadmap.md                    # Objectifs et tâches
├── permanent/
│   ├── choix_techniques.md       # ADR
│   └── regles_projet.md          # Conventions et règles
└── journal/
    ├── journal_bord.md           # Historique des sessions
    └── journal_erreurs.md        # Bugs résolus (mémoire immunitaire)
```

Chaque fichier porte un frontmatter YAML (`type`, `statut`, `derniere_maj`, `tags`) et renvoie à `[[INDEX]]`.

### Étape 3 — Créer AGENTS.md, fichier canonique

`AGENTS.md` à la racine contient l'intégralité du protocole :

- **Démarrage** : lire `state.md`, `roadmap.md`, `journal_bord.md`, `journal_erreurs.md`, `CODE_MAP.md`
- **Pendant** : tenir à jour `CODE_MAP.md`, `choix_techniques.md`, `journal_erreurs.md`
- **Fin de session** : mettre à jour `state.md`, ajouter une entrée dans `journal_bord.md`, mettre à jour `roadmap.md`, commit et push

### Étape 4 — Créer les pointeurs par outil

Aucun de ces fichiers ne doit contenir une copie du protocole. Ils pointent tous vers `AGENTS.md` :

| Fichier | Outil |
| :--- | :--- |
| `CLAUDE.md` | Claude Code — commence par la ligne d'import `@AGENTS.md` |
| `.cursor/rules/context-bridge.mdc` | Cursor — frontmatter `alwaysApply: true` |
| `.windsurf/rules/context-bridge.md` | Windsurf — frontmatter `trigger: always_on` |
| `.github/copilot-instructions.md` | GitHub Copilot — seul chemin reconnu |
| `.cursorrules`, `.windsurfrules` | Formats hérités, pointeurs de 4 lignes |

Codex lit `AGENTS.md` nativement : aucun fichier supplémentaire n'est nécessaire.

### Étape 5 — Installer l'exécution du protocole

Sans mécanisme d'exécution, la passation de fin de session est oubliée dès que le contexte sature. Installe donc :

- `.claude/hooks/context-bridge-stop.sh` (et `.ps1` sous Windows) : hook `Stop` qui bloque une fois par session si du code a été modifié sans mise à jour de `docs/state.md` ni de `docs/journal/journal_bord.md`
- `.claude/settings.json` : déclaration du hook. Si le fichier existe déjà, ne l'écrase pas — montre le bloc `hooks.Stop` à ajouter.
- `.claude/commands/handoff.md` : commande `/handoff` qui exécute la passation complète

### Étape 6 — Pré-remplir la carte du code

Analyse l'arborescence réelle du projet et remplis `docs/CODE_MAP.md` avec les dossiers et modules existants, leur rôle et leurs fichiers clés. Ne laisse pas les placeholders entre crochets.

### Étape 7 — Mettre à jour .gitignore

Ajoute si absentes les exclusions du cache Obsidian et du cache des hooks :

```
.claude/.cache/
.obsidian/workspace.json
.obsidian/workspace-mobile.json
.obsidian/plugins/*/data.json
.obsidian/graph.json
```

### Étape 8 — Confirmer

Liste les fichiers créés et indique :

- Le protocole est actif pour Claude Code, Cursor, Windsurf, Copilot et Codex
- `docs/` peut s'ouvrir dans Obsidian pour la vue graphe
- Prochaine action : remplir `docs/state.md` et `docs/roadmap.md`, qui sont encore des gabarits
- Sous Claude Code, redémarrer la session pour que le hook soit chargé
