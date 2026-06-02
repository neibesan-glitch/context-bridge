---
type: architecture
statut: stable
priorite: haute
tags: [permanent/architecture, adr]
derniere_maj: 2026-06-02
---

# 🏗️ Choix Techniques & Architecture (ADR)

Ce document retrace les décisions majeures d'architecture prises sur le projet. Pour revenir à l'accueil, voir l'[[INDEX]].

## 📊 Tableau des Choix Technologiques

| Composant | Technologie | Version | Rôle principal |
| :--- | :--- | :--- | :--- |
| **Backend** | Node.js | v20+ | Serveur applicatif principal |
| **Base de Données**| PostgreSQL | v15 | Stockage relationnel persistant |
| **Documentation** | Markdown / Obsidian | - | Base de connaissances et d'apprentissage IA |

---

## 🏛️ Décisions d'Architecture Majeures (ADR)

### ADR #001 : Base de connaissances locale au format Markdown
* **Date** : 2026-06-02
* **Contexte** : Nous avons besoin d'un moyen pour que les développeurs humains et les assistants IA partagent la même mémoire du projet sans surcharger les contextes et les coûts de tokens.
* **Décision** : Mettre en place un système de fichiers Markdown imbriqués et interconnectés par des Wiki-links, situé directement dans le code source (dossier `/docs`).
* **Conséquences** :
  * ✅ **Avantage** : Stockage local persistant dans Git, pas de dépendance externe.
  * ✅ **Avantage** : Visualisable magnifiquement avec la vue en graphe d'Obsidian.
  * ⚠️ **Attention** : Nécessite une rigueur de mise à jour de la documentation à chaque modification majeure du code. Se référer aux [[regles_de_code|Règles de Code]] pour la discipline de mise à jour.
