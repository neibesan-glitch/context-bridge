---
type: carte_code
statut: stable
derniere_maj: 2026-08-08
tags: [meta/carte, permanent]
---

# Carte du code

Ce document décrit l'architecture du projet. Mettez-le à jour dès qu'un module est ajouté ou change de responsabilité. Retour à l'[[INDEX]].

## Architecture des dossiers

```text
/ (racine)
├── AGENTS.md               # Protocole de passation (fait foi)
├── CLAUDE.md               # Import du protocole pour Claude Code
├── docs/                   # Base de connaissances Context Bridge
│   ├── INDEX.md
│   ├── CODE_MAP.md         # Ce document
│   ├── state.md
│   ├── roadmap.md
│   ├── permanent/
│   │   ├── choix_techniques.md
│   │   └── regles_projet.md
│   └── journal/
│       ├── journal_bord.md
│       └── journal_erreurs.md
└── [votre code source]     # À compléter
```

> Remplacez cette arborescence par celle de votre projet.

---

## Modules du projet

### Module 1 — [Nom du module]

- **Chemin** : `[chemin/vers/module]`
- **Rôle** : [Ce que fait ce module]
- **Fichiers clés** : [Fichiers importants]
- **Dépend de** : [Autres modules, ou « Aucun »]

### Module 2 — [Nom du module]

- **Chemin** : `[chemin/vers/module]`
- **Rôle** : [Ce que fait ce module]
- **Fichiers clés** : [Fichiers importants]
- **Dépend de** : [Autres modules, ou « Aucun »]

---

## Points d'entrée

- **Démarrage de l'application** : [commande ou fichier]
- **Tests** : [commande]
- **Build** : [commande]
