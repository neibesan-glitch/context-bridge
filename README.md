# 🧠 Squelette de Base de Connaissances Réutilisable (Multi-Agents & Obsidian)

Ce dépôt est un modèle (template) d'architecture documentaire conçu comme un **protocole d'interopérabilité et de transmission (handoff) entre développeurs humains et assistants IA** (tels que Claude Code, Antigravity, Cursor, ou Windsurf). 

Il permet de maintenir une mémoire de projet partagée et persistante, d'éviter la répétition de bugs et d'assurer une transition fluide d'un outil d'IA à l'autre sans perte de contexte.

---

## 📁 Structure du Squelette

```text
├── 📁 .antigravity/
│   └── 📄 instructions.md          # Directives système pour Antigravity
├── 📄 CLAUDE.md                    # Directives système pour Claude Code
├── 📄 .cursorrules                 # Directives système pour Cursor / Windsurf
│
└── 📁 docs/
    ├── 📄 INDEX.md                 # Point d'entrée et navigation principale (Wiki)
    ├── 📄 CODE_MAP.md              # Carte de l'arborescence et responsabilités du code
    │
    ├── 📁 permanent/               # Connaissances stables (évoluent peu)
    │   ├── 📄 choix_techniques.md  # Décisions d'architecture majeures (ADR)
    │   └── 📄 regles_de_code.md    # Conventions de développement et de sécurité
    │
    └── 📁 journal/                 # Flux d'activité (évoluent fréquemment)
        ├── 📄 journal_erreurs.md   # Journal immunitaire (bugs résolus et leçons apprises)
        └── 📄 journal_bord.md      # Chronologie des sessions (historique de handoff)
```

---

## 🔄 Le Protocole de Transmission (Handoff)

Le maillon faible du travail multi-agents est la persistance des sessions. Pour éviter que chaque IA ne stocke ses avancées dans sa propre mémoire locale inaccessible aux autres, ce squelette impose un **protocole de handoff obligatoire**.

### 1. Démarrage de session (Lecture)
Dès qu'un agent IA démarre sur le projet, ses instructions lui imposent de lire :
1. Le point d'entrée correspondant à sa plateforme (`CLAUDE.md`, `.cursorrules` ou `.antigravity/instructions.md`).
2. L'[[INDEX]] principal de la documentation (`docs/INDEX.md`).
3. Le **[[journal_bord|Journal de Bord]]** pour comprendre la dernière tâche effectuée et par qui.
4. Le **[[journal_erreurs|Journal des Erreurs]]** pour éviter de réintroduire des régressions.

### 2. Fin de session (Écriture)
Avant de clore la session ou lorsqu'elle atteint ses limites de contexte/tokens, l'IA doit **automatiquement** documenter son travail dans la base partagée :
1. Ajouter une entrée datée dans `docs/journal/journal_bord.md` décrivant les tâches accomplies et les tâches restantes.
2. Si un bug complexe a été résolu, documenter la fiche d'erreur dans `docs/journal/journal_erreurs.md`.
3. Commiter et pousser les modifications sur Git.

---

## 🚀 Comment l'utiliser pour un nouveau projet ?

1. Créez un nouveau dépôt sur GitHub en utilisant ce dépôt comme **Modèle (Template)**.
2. Clonez votre nouveau dépôt localement.
3. Le squelette de mémoire IA est immédiatement opérationnel. Tout agent IA configuré se conformera automatiquement à ces règles en lisant les fichiers de directives à la racine.

---

## 🔗 Intégration Obsidian

1. Ouvrez l'application **Obsidian**.
2. Sélectionnez **"Ouvrir un dossier existant comme coffre"** (*Open folder as vault*).
3. Sélectionnez le dossier racine de votre projet ou spécifiquement le sous-dossier `docs/`.
4. Visualisez vos connexions logiques à l'aide de la **Vue Graphe** (*Graph View*). Les fichiers sont interconnectés par des Wiki-links `[[NomDuFichier]]` natifs d'Obsidian.
