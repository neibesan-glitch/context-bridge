---
type: carte_code
statut: stable
derniere_maj: 2026-08-08
tags: [meta/carte, permanent]
---

# Carte du code

Structure du dépôt Context Bridge. Retour à l'[[INDEX]].

## Architecture des dossiers

```text
/ (racine)
├── AGENTS.md                          # Protocole canonique — seule source de vérité
├── CLAUDE.md                          # Claude Code : import @AGENTS.md + spécificités
├── .cursor/rules/context-bridge.mdc   # Cursor (alwaysApply)
├── .windsurf/rules/context-bridge.md  # Windsurf (always_on)
├── .github/copilot-instructions.md    # GitHub Copilot (seul chemin reconnu)
├── .cursorrules / .windsurfrules      # Formats hérités, pointeurs seulement
│
├── .claude/
│   ├── settings.json                  # Déclaration du hook Stop
│   ├── hooks/context-bridge-stop.sh   # Vérification de passation (POSIX)
│   ├── hooks/context-bridge-stop.ps1  # Vérification de passation (Windows)
│   └── commands/handoff.md            # Commande /handoff
│
├── install.sh / install.ps1           # Installation et mise à jour
├── SKILL.md                           # Installation comme skill Claude Code
│
├── template/docs/                     # Gabarits VIERGES installés chez l'utilisateur
├── docs/                              # Mémoire de CE dépôt (ne pas confondre)
└── .github/workflows/ci.yml           # Tests des installeurs et du protocole
```

---

## Modules du projet

### Protocole

- **Chemin** : `AGENTS.md` et les pointeurs par outil
- **Rôle** : définir ce que chaque agent doit lire au démarrage et écrire en fin de session
- **Règle** : le protocole n'existe qu'à un seul endroit. Les autres fichiers pointent vers `AGENTS.md` et ne recopient jamais son contenu. La CI échoue si un pointeur se met à contenir le protocole.

### Application du protocole

- **Chemin** : `.claude/`
- **Rôle** : transformer une convention en contrainte. Le hook `Stop` bloque une fois par session si `git status` montre des modifications hors `docs/` sans mise à jour de `docs/state.md` ni de `docs/journal/journal_bord.md`.
- **Fichiers clés** : `hooks/context-bridge-stop.sh`, `hooks/context-bridge-stop.ps1`, `settings.json`, `commands/handoff.md`
- **Garde-fous** : sortie silencieuse hors dépôt Git, hors projet Context Bridge, ou si `stop_hook_active` est vrai ; un seul blocage par `session_id`, tracé dans `.claude/.cache/`
- **Limite connue** : dans un dépôt sans aucun commit, `docs/state.md` est lui-même non suivi et compte donc comme passation écrite. Le hook ne bloque pas tant que le premier commit n'a pas eu lieu, ce qui est le comportement voulu pour une installation fraîche.

### Installation

- **Chemin** : `install.sh`, `install.ps1`
- **Rôle** : déposer le protocole, les gabarits et les hooks dans un projet existant
- **Modes** : installation complète, ou `--update` / `-Update` qui rafraîchit directives et hooks sans jamais toucher au contenu de `docs/`
- **Variables** : `CONTEXT_BRIDGE_BRANCH` et `CONTEXT_BRIDGE_BASE` redirigent la source, utilisées par la CI

### Gabarits

- **Chemin** : `template/docs/`
- **Rôle** : les huit fichiers vierges copiés dans le `docs/` de l'utilisateur
- **Règle** : aucun contenu propre à Context Bridge ici, uniquement des placeholders

---

## Points d'entrée

- **Installer dans un projet** : `curl -fsSL .../install.sh | bash`
- **Mettre à jour** : `curl -fsSL .../install.sh | bash -s -- --update`
- **Tests** : `.github/workflows/ci.yml` (installeurs, liens wiki, non-duplication)
