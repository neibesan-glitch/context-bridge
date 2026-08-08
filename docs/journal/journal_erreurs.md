---
type: journal/erreurs
statut: actif
priorite: moyenne
tags: [journal/erreurs, immunite]
derniere_maj: 2026-08-08
---

# Journal des erreurs (mémoire immunitaire)

Bugs résolus et leçons apprises sur ce dépôt. À lire avant de modifier les installeurs ou les fichiers de directives. Retour à l'[[INDEX]].

---

## Modèle de fiche

```markdown
### Erreur #NNN — [Titre court]
- **Module** : [Module ou fichier concerné]
- **Problème** : [Comportement indésirable observé]
- **Cause** : [Pourquoi le bug s'est produit]
- **Anti-pattern** : [Ce qu'il ne faut PAS refaire]
- **Solution** : [La façon correcte]
```

---

## Erreurs répertoriées

### Erreur #001 — Fichiers de directives ignorés par leur propre outil

- **Module** : `CODEX.md`, `.github/copilot.md`, `.cursorrules`
- **Problème** : trois des quatre fichiers de directives n'étaient lus par aucun agent. Le protocole ne s'appliquait qu'à Claude Code, alors que le README annonçait une détection automatique pour les quatre.
- **Cause** : noms de fichiers inventés par analogie avec `CLAUDE.md`, sans vérification des conventions réelles. Codex lit `AGENTS.md`, Copilot ne reconnaît que `.github/copilot-instructions.md`, et Windsurf ne lit jamais `.cursorrules`.
- **Anti-pattern** : déduire le chemin de configuration d'un outil à partir de son nom.
- **Solution** : vérifier la documentation officielle de chaque outil avant d'ajouter un fichier de directives, et laisser `AGENTS.md` porter le protocole puisqu'il est devenu le format commun.

### Erreur #002 — Commande `npx` pointant vers un paquet tiers

- **Module** : `README.md`, méthode d'installation 4
- **Problème** : le README proposait `npx context-bridge init`. Le nom `context-bridge` est déjà pris sur npm par une bibliothèque sans rapport, qui ne fournit aucun binaire. La commande téléchargeait et tentait d'exécuter le code d'un tiers.
- **Cause** : commande documentée avant que le paquet ne soit publié, et sans vérifier la disponibilité du nom.
- **Anti-pattern** : documenter une commande d'installation qui n'a jamais été exécutée.
- **Solution** : ne documenter que des commandes testées. Un nom npm se réserve avant d'être annoncé ; l'installation `npx` reviendra sous un nom disponible.

### Erreur #003 — `exit` dans un script exécuté via `iex`

- **Module** : `install.ps1`
- **Problème** : le garde-fou « docs/INDEX.md existe déjà » appelait `exit 1`. Exécuté via `irm ... | iex`, ce script tourne dans la session interactive : `exit` fermait la console de l'utilisateur, et tout ce qui y tournait.
- **Cause** : script écrit comme un fichier autonome alors que son mode d'exécution documenté est l'injection dans la session courante.
- **Anti-pattern** : `exit`, et toute modification durable de `$ErrorActionPreference`, dans un script destiné à `iex`.
- **Solution** : `return` pour rendre la main, et restauration des préférences de session dans un bloc `finally`.

### Erreur #004 — Le gabarit livré contenait la mémoire du dépôt

- **Module** : `docs/`, `install.sh`, `install.ps1`
- **Problème** : `docs/` servait à la fois de gabarit installé et de mémoire de Context Bridge. Chaque installation copiait donc le journal de bord du dépôt dans le projet de l'utilisateur.
- **Cause** : un même dossier avec deux rôles incompatibles.
- **Anti-pattern** : livrer aux utilisateurs le dossier que le projet utilise pour lui-même.
- **Solution** : `template/docs/` pour les gabarits vierges, `docs/` pour la mémoire du dépôt. Les installeurs lisent le premier et écrivent dans le second.
