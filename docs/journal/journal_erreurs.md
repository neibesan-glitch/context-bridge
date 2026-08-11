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

### Erreur #005 — Un contrôle de présence pris pour un contrôle de contenu

- **Module** : `.claude/hooks/context-bridge-stop.sh`, `.ps1`
- **Problème** : le hook validait la passation dès que `docs/state.md` ou `docs/journal/journal_bord.md` apparaissait dans `git status`. Une ligne blanche, un espace ou un simple réenregistrement suffisaient à le satisfaire, et la mémoire du projet restait vide sans que rien ne le signale.
- **Cause** : `git status` répond « ce fichier a changé », pas « ce fichier contient quelque chose ». La sortie de `status` avait été prise pour une mesure de contenu.
- **Anti-pattern** : déduire qu'un travail a été fait de l'existence d'une modification. Vérifier un horodatage quand on veut vérifier une écriture.
- **Solution** : compter les lignes non vides ajoutées, via `git diff -U0` filtré sur les lignes `+`, et exiger un minimum. La même règle vaut hors Git par comparaison de compteurs avec le repère de `SessionStart`.

### Erreur #006 — Un hook silencieux hors dépôt Git, sans le dire

- **Module** : `.claude/hooks/context-bridge-stop.sh`, `.ps1`, `README.md`
- **Problème** : le hook sortait en 0 dès que `git rev-parse --is-inside-work-tree` échouait. Sur un projet non versionné, il ne s'est jamais déclenché, et le README laissait croire que le protocole était appliqué partout.
- **Cause** : la seule méthode de détection implémentée dépendait de Git ; l'absence de méthode de repli avait été traitée comme une absence de besoin.
- **Anti-pattern** : faire dépendre un garde-fou d'un outil optionnel, puis documenter le garde-fou comme inconditionnel.
- **Solution** : un hook `SessionStart` pose un repère indépendant de Git ; le hook `Stop` choisit sa méthode selon le contexte. Les conditions exactes de silence sont désormais écrites dans le README.

### Erreur #007 — Un hook `SessionStart` qui écrit sur stdout coûte des tokens

- **Module** : `.claude/hooks/context-bridge-start.sh`, `.ps1`
- **Problème** : un hook `SessionStart` bavard voit sa sortie standard injectée par Claude Code dans le contexte de la session, à chaque démarrage, sur tous les projets installés.
- **Cause** : `SessionStart` n'est pas un hook de diagnostic mais un hook d'injection de contexte ; son stdout est du contenu, pas un journal.
- **Anti-pattern** : ajouter un `echo` de confirmation ou de débogage dans un hook `SessionStart`.
- **Solution** : les deux hooks n'écrivent jamais sur stdout. Un test de CI vérifie que la sortie standard du `SessionStart` est vide.
