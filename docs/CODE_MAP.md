---
type: carte_code
statut: stable
derniere_maj: 2026-06-02
tags: [meta/carte, permanent]
---

# 🗺️ Carte du Code (Code Map)

Ce document liste la structure de l'application, les responsabilités de chaque module et les règles de développement spécifiques à chaque partie du code. Retour à l'[[INDEX]].

## 📁 Architecture Globale des Dossiers

Voici l'architecture du projet, y compris la structure de documentation Obsidian :

```text
📁 / (Racine)
├── 📁 .antigravity/       # Instructions spécifiques pour l'IA Antigravity
├── 📁 docs/              # Base de connaissances Obsidian
│   ├── 📄 INDEX.md       # Aiguillage principal
│   ├── 📄 CODE_MAP.md    # Ce document
│   ├── 📁 permanent/     # Règles et choix permanents
│   │   ├── 📄 choix_techniques.md
│   │   └── 📄 regles_de_code.md
│   └── 📁 journal/       # Notes de flux et journal immunitaire
│       ├── 📄 journal_erreurs.md
│       └── 📄 journal_bord.md
├── 📁 src/               # Code source de l'application (à adapter)
│   ├── 📁 config/        # Fichiers de configuration globale
│   ├── 📁 controllers/   # Logique métier et routage
│   ├── 📁 models/        # Modèles de données (Base de données)
│   ├── 📁 views/         # Interface utilisateur (si applicable)
│   └── 📁 utils/         # Fonctions utilitaires partagées
```

---

## 🔍 Responsabilités et Règles des Modules

### ⚙️ Module 1 : Configuration (`src/config/`)
* **Rôle** : Charger les variables d'environnement et configurer les modules tiers.
* **Fichiers clés** :
  * `src/config/database.js` : Connexion à la BDD.
* **Règles spécifiques** :
  * Ne jamais commiter de clés d'API ou de secrets. Se référer à [[regles_de_code|Règles de Code]].
  * Valider l'existence des variables critiques au démarrage du serveur.

### 💼 Module 2 : Logique Métier / API (`src/controllers/`)
* **Rôle** : Gérer les requêtes et les réponses HTTP.
* **Règles spécifiques** :
  * Toujours renvoyer des codes de statut HTTP standardisés (`200 OK`, `400 Bad Request`, etc.).
  * Gérer les erreurs pour éviter les crashs (voir le [[journal_erreurs|Journal des Erreurs]]).

### 📦 Utilitaires (`src/utils/`)
* **Rôle** : Fonctions d'aide transversales (formatage, dates, cryptage).
* **Règles spécifiques** :
  * Les fonctions doivent être pures (sans effets de bord) et testées unitairement.

---

> [!NOTE]
> **Mise à jour** : Ce document doit être mis à jour dès qu'un nouveau module est ajouté ou qu'un dossier change de responsabilité.
