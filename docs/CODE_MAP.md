---
type: carte_code
statut: stable
derniere_maj: 2026-06-19
tags: [meta/carte, permanent]
---

# Carte du Code (Code Map)

Ce document decrit l'architecture du projet. Mettez-le a jour des qu'un module est ajoute ou modifie. Retour a l'[[INDEX]].

## Architecture des Dossiers

```text
/ (Racine)
├── docs/                   # Base de connaissances (Context Bridge)
│   ├── INDEX.md            # Aiguillage principal
│   ├── CODE_MAP.md         # Ce document
│   ├── state.md            # Etat courant du projet
│   ├── roadmap.md          # Objectifs et taches
│   ├── permanent/          # Connaissances stables
│   │   ├── choix_techniques.md
│   │   └── regles_projet.md
│   └── journal/            # Flux d'activite
│       ├── journal_erreurs.md
│       └── journal_bord.md
├── [votre code source]     # A adapter selon le projet
```

> Completez cette section avec l'architecture specifique de votre projet.

---

## Modules du Projet

### Module 1 : [Nom du module]
- **Chemin** : `[chemin/vers/module]`
- **Role** : [Description du role]
- **Fichiers cles** : [Listez les fichiers importants]

### Module 2 : [Nom du module]
- **Chemin** : `[chemin/vers/module]`
- **Role** : [Description du role]
- **Fichiers cles** : [Listez les fichiers importants]

---

> Ce document doit etre mis a jour des qu'un nouveau module est ajoute ou qu'un dossier change de responsabilite.
