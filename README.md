# 🧠 Antigravity & Obsidian - Template de Base de Connaissances Réutilisable

Ce dépôt est un modèle (template) d'architecture documentaire conçu pour interconnecter les développeurs, l'IA (comme Antigravity) et un éditeur de notes local (comme Obsidian). Il permet de maintenir une base de connaissances évolutive, d'éviter les bugs répétitifs et d'économiser drastiquement les tokens lors de vos conversations IA.

## 📁 Structure du Modèle

```text
├── 📁 .antigravity/
│   └── 📄 instructions.md          # Guide système pour l'IA (Antigravity)
│
└── 📁 docs/
    ├── 📄 INDEX.md                 # Point d'entrée principal (Root Index)
    ├── 📄 CODE_MAP.md              # Carte de votre architecture de code
    │
    ├── 📁 memoire/
    │   ├── 📄 journal_erreurs.md   # Leçons apprises et corrections de bugs passés
    │   └── 📄 regles_de_code.md    # Conventions et directives de code
    │
    └── 📁 architecture/
        └── 📄 choix_techniques.md  # Décisions d'architecture (ADR)
```

---

## 🚀 Comment l'utiliser pour un nouveau projet ?

### Option A : Depuis GitHub (Recommandé)
1. Créez un nouveau dépôt sur GitHub en utilisant ce dépôt comme **Modèle (Template)**.
2. Clonez votre nouveau dépôt sur votre ordinateur.
3. Commencez à coder ! La structure et les règles système IA y seront déjà incluses.

### Option B : Copie manuelle
1. Copiez les dossiers `.antigravity/` et `docs/` à la racine de votre nouveau projet de code.

---

## 🔗 Intégration Obsidian

1. Ouvrez l'application **Obsidian**.
2. Cliquez sur **"Ouvrir un dossier existant comme coffre"** (*Open folder as vault*).
3. Sélectionnez le dossier racine de votre projet ou spécifiquement le sous-dossier `docs/`.
4. Vous pouvez maintenant naviguer visuellement dans vos fichiers grâce à la **Vue Graphe (Graph View)** et lier vos notes en utilisant des liens relatifs ou la syntaxe Obsidian `[[NomDuFichier]]`.

---

## 🤖 Comment interagir avec l'IA ?

Lors de votre première conversation sur un projet utilisant ce template, donnez simplement cette instruction à Antigravity :
> *"Bonjour. Lis le fichier d'instructions système à la racine (`.antigravity/instructions.md`) avant de commencer le projet."*

L'IA lira le fichier, comprendra la structure de votre projet, consultera le journal des erreurs, et se mettra immédiatement au diapason sans que vous ayez à lui réexpliquer le projet de zéro.

---

## 💾 Comment publier ce template sur votre propre GitHub ?

1. Initialisez git dans votre dossier (si ce n'est pas déjà fait) :
   ```bash
   git init
   ```
2. Ajoutez tous les fichiers et faites un premier commit :
   ```bash
   git add .
   git commit -m "feat: initialiser le template de base de connaissances"
   ```
3. Créez un nouveau dépôt **public ou privé** vide sur GitHub (nommez-le par exemple `antigravity-kb-template`).
4. Liez votre dossier local et poussez le code :
   ```bash
   git branch -M main
   git remote add origin https://github.com/VOTRE_NOM_UTILISATEUR/antigravity-kb-template.git
   git push -u origin main
   ```
5. Dans les paramètres (*Settings*) de votre dépôt sur GitHub, cochez l'option **"Template repository"** pour pouvoir le dupliquer en 1 clic pour vos prochains projets.
