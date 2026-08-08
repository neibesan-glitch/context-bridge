---
type: regles
statut: stable
priorite: haute
tags: [permanent/regles]
derniere_maj: 2026-06-19
---

# Regles du Projet

Conventions et bonnes pratiques a respecter. Retour a l'[[INDEX]].

---

## Securite

1. **Zero credentials en dur** : Aucun token, mot de passe ou secret dans le code source. Utiliser des fichiers `.env` (exclus via `.gitignore`).
2. **Validation des entrees** : Toutes les donnees externes (API, formulaires, fichiers) doivent etre validees avant traitement.
3. **Gestion des erreurs** : Ne jamais laisser un bloc `catch` vide. Logger les erreurs avec un niveau de severite clair.

## Conventions de code

> Adaptez cette section au langage et framework de votre projet.

- [Convention 1 : ex. nommage des variables, format des fichiers]
- [Convention 2 : ex. structure des modules, organisation des imports]
- [Convention 3 : ex. patterns de gestion d'erreurs]

## Git

- Commits atomiques (un seul objectif par commit)
- Messages de commit clairs et actionnables (ex: `feat: add user login`, `fix: resolve db connection leak`)
- Ne jamais push sur la branche principale sans verification

## Documentation

- Mettre a jour la [[CODE_MAP]] a chaque nouveau module
- Documenter les bugs resolus dans le [[journal_erreurs]]
- Consigner les decisions d'architecture dans [[choix_techniques]]
