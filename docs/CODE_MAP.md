---
type: code_map
statut: template
derniere_maj: 2026-06-02
---

# 🗺️ Carte du Code (Code Map)

Ce document liste la structure de l'application, les responsabilités de chaque module et les règles de développement spécifiques à chaque partie du code.

## 📁 Architecture Globale des Dossiers

*(Voici un modèle type à adapter selon votre projet)*

```text
📁 src/
├── 📁 config/         # Fichiers de configuration globale
├── 📁 controllers/    # Logique métier et routage
├── 📁 models/         # Modèles de données (Base de données)
├── 📁 views/          # Interface utilisateur (si applicable)
└── 📁 utils/          # Fonctions utilitaires partagées
```

---

## 🔍 Responsabilités et Règles des Modules

### ⚙️ Module 1 : Configuration (`src/config/`)
* **Rôle** : Charger les variables d'environnement et configurer les modules tiers.
* **Fichiers clés** :
  * `[src/config/database.js](file:///c:/Users/herbe/OneDrive/Documents/antigravity/test/src/config/database.js)` : Connexion à la BDD.
* **Règles spécifiques** :
  * Ne jamais commiter de clés d'API ou de secrets. Utiliser toujours `process.env`.
  * Valider l'existence des variables critiques au démarrage du serveur.

### 💼 Module 2 : Logique Métier / API (`src/controllers/`)
* **Rôle** : Gérer les requêtes et les réponses HTTP.
* **Règles spécifiques** :
  * Toujours renvoyer des codes de statut HTTP standardisés (`200 OK`, `400 Bad Request`, etc.).
  * Gérer les erreurs avec un bloc `try/catch` global pour éviter les crashs du serveur.

### 📦 Utilitaires (`src/utils/`)
* **Rôle** : Fonctions d'aide transversales (formatage, dates, cryptage).
* **Règles spécifiques** :
  * Les fonctions doivent être pures (sans effets de bord) et testées unitairement.

---

> [!NOTE]
> **Mise à jour** : Ce document doit être mis à jour dès qu'un nouveau module est ajouté ou qu'un dossier change de responsabilité.
