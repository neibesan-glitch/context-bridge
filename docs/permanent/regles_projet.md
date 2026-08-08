---
type: regles
statut: stable
priorite: haute
tags: [permanent/regles]
derniere_maj: 2026-08-08
---

# Règles du projet

Conventions du dépôt Context Bridge. Retour à l'[[INDEX]].

---

## Sécurité

1. **Zéro identifiant en dur** — aucun jeton ni secret dans le dépôt.
2. **Installeurs non destructifs** — aucun fichier existant de l'utilisateur n'est écrasé. En cas de conflit, on ajoute en fin de fichier ou on affiche le bloc à ajouter à la main.
3. **Aucun `exit` dans `install.ps1`** — le script est exécuté via `iex` dans la session de l'utilisateur, où `exit` ferme la console. On utilise `return`, et les préférences de session sont restaurées dans un bloc `finally`.

## Invariant du protocole

Le protocole n'existe qu'une fois, dans `AGENTS.md`. Les fichiers de directives par outil ne contiennent qu'un pointeur. Toute modification du protocole se fait dans `AGENTS.md` uniquement. La CI vérifie cet invariant.

## Conventions de code

- **Scripts shell** : `#!/usr/bin/env bash`, `set -euo pipefail`, fonctions préfixées, sans accent dans les chaînes affichées en console (compatibilité des terminaux Windows).
- **PowerShell** : compatible Windows PowerShell 5.1 et PowerShell 7. Pas d'opérateur ternaire, pas de `??`. Écriture de fichiers via `[System.IO.File]::WriteAllText` avec UTF-8 sans BOM, jamais via `Add-Content`, dont l'encodage par défaut diffère entre 5.1 et 7.
- **Markdown** : français avec accents, encodé en UTF-8. Les scripts sont la seule exception.
- **Frontmatter** : chaque fichier de `docs/` porte `type`, `statut`, `derniere_maj`, `tags`.

## Git

- Commits atomiques, messages en anglais au format conventionnel (`feat:`, `fix:`, `docs:`, `refactor:`)
- Pas de push direct sur `main` : passer par une branche et une pull request
- La version du protocole est portée par le commentaire `context-bridge:version` en tête de `AGENTS.md` et par `VERSION` dans les deux installeurs. Les trois doivent rester synchronisés.

## Documentation

- Mettre à jour la [[CODE_MAP]] à chaque nouveau fichier structurant
- Documenter les bugs résolus dans le [[journal_erreurs]]
- Consigner les décisions dans [[choix_techniques]]
- Écrire la passation avant de clore une session, `/handoff` le fait en une commande
