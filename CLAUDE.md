# Projet : Base de Connaissances IA Agnostique (Directives Claude Code)

Ce fichier fournit aux agents Claude Code les directives nécessaires pour comprendre l'état du projet et collaborer sans perte de contexte.

## 🚀 Étape obligatoire au démarrage (Dès la première interaction)

Avant de proposer un plan d'action, d'écrire ou de modifier du code :
1. **Lisez le fichier d'index principal** : Ouvrez et lisez [docs/INDEX.md](docs/INDEX.md).
2. **Consultez la Code Map** : Lisez [docs/CODE_MAP.md](docs/CODE_MAP.md) pour comprendre l'architecture.
3. **Consultez l'historique** : Lisez le dernier log de session dans [docs/journal/journal_bord.md](docs/journal/journal_bord.md) pour savoir où s'est arrêté le précédent agent.
4. **Vérifiez la mémoire immunitaire** : Consultez [docs/journal/journal_erreurs.md](docs/journal/journal_erreurs.md) pour ne pas répéter des erreurs passées.

## 🛠️ Règles de mise à jour (Pendant le projet)

Chaque fois que vous modifiez le projet :
* **Nouveau module/dossier** : Mettez à jour la `CODE_MAP.md` pour refléter la nouvelle architecture.
* **Nouvelle directive ou style** : Ajoutez la règle dans `docs/permanent/regles_de_code.md`.

## 💾 Protocole Obligatoire de Fin de Session (Handoff)

> [!IMPORTANT]
> Avant de clore votre session, ou lorsque vous approchez de la limite de contexte ou de tokens, vous devez impérativement :
> 1. **Mettre à jour [docs/journal/journal_bord.md](docs/journal/journal_bord.md)** avec le compte-rendu précis de ce que vous avez fait et des tâches restantes.
> 2. **Mettre à jour [docs/permanent/choix_techniques.md](docs/permanent/choix_techniques.md)** si vous avez pris une décision d'architecture ou un choix technologique majeur (ADR).
> 3. **Mettre à jour [docs/journal/journal_erreurs.md](docs/journal/journal_erreurs.md)** si vous avez résolu un bug complexe pour inscrire la leçon apprise (mémoire immunitaire).
