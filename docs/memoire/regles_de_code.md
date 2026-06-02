---
type: rules
statut: template
derniere_maj: 2026-06-02
---

# 📜 Règles de Code et Directives

Ce fichier regroupe les conventions de développement, de formatage et de sécurité à respecter sur le projet.

## 🔒 Règles de Sécurité Générales
1. **Zéro Credentials en dur** : Aucun token d'API, mot de passe ou secret ne doit figurer dans le code source. Utilisez des fichiers d'environnement `.env` (exclus du dépôt Git via `.gitignore`).
2. **Validation des Entrées (Sanitization)** : Toutes les données provenant des utilisateurs (API, formulaires) doivent être nettoyées et validées avant d'être insérées en Base de Données ou traitées (ex: utiliser `Zod` ou `Validator`).
3. **Traitement des Erreurs** : Ne jamais laisser un bloc `catch` vide. Toujours logger les erreurs proprement avec un niveau de log approprié (`error`, `warn`).

## ✍️ Style de Code et Syntaxe
* **Typage / Variables** : 
  * Préférer `const` pour toutes les variables. Utiliser `let` uniquement si la réaffectation est nécessaire. Ne jamais utiliser `var`.
* **Asynchronisme** : 
  * Privilégier la syntaxe `async / await` par rapport aux chaînes de promesses `.then().catch()`.
* **Fonctions** :
  * Garder les fonctions courtes (idéalement moins de 30 lignes) et spécialisées sur une seule tâche (Single Responsibility Principle).

## 🚀 Bonnes Pratiques Git
* Faire des commits atomiques (un seul objectif par commit).
* Rédiger les messages de commits en anglais ou français, au présent, sous forme d'action (ex: `feat: add user login route` ou `fix: resolve db connection pool leak`).
