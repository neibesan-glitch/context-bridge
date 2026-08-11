# Context Bridge

Mémoire partagée et continuité entre agents IA et développeurs humains, sur n'importe quel projet.

**Version 1.2.0** — licence MIT

---

## Le problème

Quand plusieurs outils IA travaillent sur un même projet — Claude Code, Cursor, Windsurf, Codex, Copilot — chacun repart de zéro à chaque session. Les bugs reviennent, les décisions se contredisent, le travail se répète.

## La solution

Un protocole de passation. Chaque agent lit l'état du projet au démarrage et écrit ce qu'il a fait à la fin. La mémoire vit dans Git, à côté du code, accessible à tous les outils et à toute l'équipe.

Et surtout : le protocole est **appliqué**, pas seulement écrit. Un hook de fin de session refuse de laisser partir un agent qui a modifié du code sans documenter son passage.

---

## Installation

### Une seule commande

À la racine de votre projet :

```bash
curl -fsSL https://raw.githubusercontent.com/neibesan-glitch/context-bridge/main/install.sh | bash
```

Windows (PowerShell) :

```powershell
irm https://raw.githubusercontent.com/neibesan-glitch/context-bridge/main/install.ps1 | iex
```

L'installeur n'écrase jamais un fichier existant : il complète ou affiche ce qu'il faut ajouter à la main.

### Mise à jour

Rafraîchit le protocole, les pointeurs et les hooks. Ne touche jamais au contenu de votre `docs/` :

```bash
curl -fsSL https://raw.githubusercontent.com/neibesan-glitch/context-bridge/main/install.sh | bash -s -- --update
```

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/neibesan-glitch/context-bridge/main/install.ps1))) -Update
```

### Comme skill Claude Code

Copiez `SKILL.md` dans `~/.claude/skills/context-bridge/`, puis lancez `/context-bridge` dans n'importe quel projet. Le skill analyse le projet et pré-remplit la carte du code.

### Template GitHub

Cliquez sur **Use this template**, clonez, puis réinitialisez la base de connaissances — le dossier `docs/` du dépôt contient la mémoire de Context Bridge lui-même, pas la vôtre :

```bash
rm -rf docs && cp -r template/docs docs && rm -rf template
```

---

## Comment ça marche

### Le protocole

**Au démarrage de session**, l'agent lit dans l'ordre :

1. `docs/state.md` — l'état courant en 5 lignes
2. `docs/roadmap.md` — les objectifs en cours
3. `docs/journal/journal_bord.md` — ce que la session précédente a fait
4. `docs/journal/journal_erreurs.md` — les bugs déjà résolus, à ne pas reproduire
5. `docs/CODE_MAP.md` — l'architecture

**En fin de session**, il écrit :

1. `docs/state.md` mis à jour
2. Une entrée datée dans `docs/journal/journal_bord.md`
3. `docs/roadmap.md` mis à jour
4. Commit et push

### L'application du protocole

| Mécanisme | Effet |
| :--- | :--- |
| Hook `SessionStart` | Pose un repère silencieux au début de la session : volume déjà écrit dans les fichiers de passation, et commit courant s'il existe. |
| Hook `Stop` | Si la session a modifié le projet sans écrire de passation réelle, le hook bloque une fois et rappelle la procédure. L'agent écrit la passation, puis termine. |
| Commande `/handoff` | Exécute la passation complète en une commande. |
| Journal des erreurs | Chaque bug résolu devient une fiche que les agents suivants lisent avant de coder. |

Le hook `Stop` mesure les **lignes de contenu réel** ajoutées à `docs/state.md` et `docs/journal/journal_bord.md` — minimum trois. Un fichier simplement ouvert, une ligne blanche ou un espace ne passent pas. Il fonctionne dans un dépôt Git (comparaison `git diff` depuis le début de session, ce qui couvre aussi une passation déjà commitée) comme dans un dossier ordinaire (comparaison avec le repère du `SessionStart`).

Les deux hooks sont des scripts locaux, déterministes : ils n'appellent aucun modèle et **ne consomment aucun token**.

### Ce que le contrôle garantit — et ce qu'il ne garantit pas

**Il garantit** qu'une session productive ne se termine pas sans qu'un rappel explicite ait été envoyé à l'agent, avec la procédure à appliquer.

**Il ne garantit pas** que la passation sera écrite. Le rappel ne se déclenche qu'une fois par session : Claude Code fournit le drapeau `stop_hook_active` précisément pour interdire qu'un hook bloque en boucle, sans quoi un agent ne pourrait plus jamais terminer une session. Un agent qui ignore le rappel peut donc conclure quand même. C'est un garde-fou ferme, pas un verrou.

**Il ne juge pas la qualité** de ce qui est écrit. Trois lignes de contenu réel suffisent à le satisfaire : il mesure un volume, pas la pertinence d'une analyse.

Le hook reste par ailleurs totalement silencieux hors d'un projet Context Bridge, et dans un projet sans dépôt Git où le hook `SessionStart` n'a pas encore tourné.

---

## Structure installée

```text
/
├── AGENTS.md                          # Le protocole — seule source de vérité
├── CLAUDE.md                          # Claude Code (importe AGENTS.md)
├── .cursor/rules/context-bridge.mdc   # Cursor
├── .windsurf/rules/context-bridge.md  # Windsurf
├── .github/copilot-instructions.md    # GitHub Copilot
├── .cursorrules, .windsurfrules       # Formats hérités (pointeurs)
│
├── .claude/
│   ├── settings.json                  # Déclaration des hooks
│   ├── hooks/                         # Repère de début + vérification de passation
│   └── commands/handoff.md            # Commande /handoff
│
└── docs/
    ├── INDEX.md                       # Point d'entrée, wiki-links
    ├── CODE_MAP.md                    # Architecture du projet
    ├── state.md                       # État courant
    ├── roadmap.md                     # Objectifs et tâches
    ├── permanent/                     # Connaissances stables
    │   ├── choix_techniques.md        # Décisions d'architecture (ADR)
    │   └── regles_projet.md           # Conventions
    └── journal/                       # Flux d'activité
        ├── journal_bord.md            # Historique des sessions
        └── journal_erreurs.md         # Mémoire immunitaire
```

---

## Agents supportés

| Agent | Fichier lu | Détection |
| :--- | :--- | :--- |
| Claude Code | `CLAUDE.md`, qui importe `AGENTS.md` | Automatique |
| Codex | `AGENTS.md` | Automatique, format natif |
| Cursor | `.cursor/rules/context-bridge.mdc` | Automatique (`alwaysApply`) |
| Windsurf | `.windsurf/rules/context-bridge.md` | Automatique (`always_on`) |
| GitHub Copilot | `.github/copilot-instructions.md` | Automatique |

Un seul fichier porte le protocole : `AGENTS.md`. Tous les autres sont des pointeurs de quelques lignes. Pour modifier le protocole, modifiez `AGENTS.md` et rien d'autre.

---

## Intégration Obsidian (optionnel)

Ouvrez le dossier `docs/` comme coffre. Les fichiers sont reliés par des wiki-links `[[NomDuFichier]]` et la vue graphe montre la structure de la mémoire du projet.

---

## Licence

MIT — voir [LICENSE](LICENSE).
