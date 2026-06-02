---
type: architecture
statut: template
derniere_maj: 2026-06-02
---

# 🏗️ Choix Techniques & Architecture

Ce document retrace les décisions majeures d'architecture prises sur le projet (les Architecture Decision Records - ADR).

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
* **Décision** : Mettre en place un système de fichiers Markdown imbriqués et interconnectés par des chemins relatifs, situé directement dans le code source (dossier `/docs`).
* **Conséquences** :
  * ✅ **Avantage** : Stockage local persistant dans Git, pas de dépendance externe.
  * ✅ **Avantage** : Visualisable magnifiquement avec la vue en graphe d'Obsidian.
  * ⚠️ **Attention** : Nécessite une rigueur de mise à jour à chaque modification majeure du code.
