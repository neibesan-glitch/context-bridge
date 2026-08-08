---
type: regles
statut: stable
priorite: haute
tags: [permanent/regles]
derniere_maj: 2026-08-08
---

# Règles du projet

Conventions et bonnes pratiques à respecter. Ces règles font partie du protocole défini dans `AGENTS.md`. Retour à l'[[INDEX]].

---

## Sécurité

1. **Zéro identifiant en dur** — aucun jeton, mot de passe ou secret dans le code source. Utilisez des fichiers `.env`, exclus par `.gitignore`.
2. **Validation des entrées** — toute donnée externe (API, formulaire, fichier) est validée avant traitement.
3. **Gestion des erreurs** — jamais de bloc `catch` vide. Les erreurs sont journalisées avec un niveau de sévérité explicite.

## Conventions de code

> Adaptez cette section au langage et au framework du projet.

- [Convention 1 : nommage des variables, format des fichiers]
- [Convention 2 : structure des modules, organisation des imports]
- [Convention 3 : gestion des erreurs, style des tests]

## Git

- Commits atomiques : un seul objectif par commit
- Messages clairs et actionnables (`feat: ajoute la connexion utilisateur`, `fix: corrige la fuite de connexion BDD`)
- Jamais de push direct sur la branche principale sans vérification

## Documentation

- Mettre à jour la [[CODE_MAP]] à chaque nouveau module
- Documenter les bugs résolus dans le [[journal_erreurs]]
- Consigner les décisions d'architecture dans [[choix_techniques]]
- Écrire la passation avant de clore une session
