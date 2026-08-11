---
type: etat
statut: actif
derniere_maj: 2026-08-10
tags: [meta/etat]
---

# État du projet

> Résumé rapide de l'état actuel. Mis à jour à chaque fin de session. Retour à l'[[INDEX]].

## En une phrase

Context Bridge 1.2.0 est un template Git fonctionnel qui installe un protocole de passation inter-agents, appliqué par deux hooks qui mesurent le contenu réellement écrit et fonctionnent aussi sur un projet non versionné.

## Ce qui fonctionne

- Protocole canonique unique dans `AGENTS.md`, relayé par des pointeurs vers les chemins réellement lus par Claude Code, Cursor, Windsurf, Copilot et Codex
- Hook `SessionStart` qui pose un repère silencieux (volume écrit, commit courant), en version POSIX et PowerShell
- Hook `Stop` qui bloque une fois par session si le projet a été modifié sans qu'au moins trois lignes de contenu réel aient été ajoutées à la passation
- Détection en dépôt Git (`git diff` depuis le commit de début de session, passation commitée incluse) comme hors dépôt Git (comparaison avec le repère)
- Commande `/handoff` qui exécute la passation complète
- Installation et mise à jour en une commande, sous Bash et PowerShell, non destructives, avec message dédié pour une installation 1.1.0 à compléter
- Gabarits vierges isolés dans `template/docs/`, séparés de la mémoire du dépôt
- CI qui vérifie les deux installeurs, les deux hooks dans les deux modes, le contrôle de substance, le silence du `SessionStart` sur stdout, l'intégrité des liens wiki et l'absence de duplication du protocole
- Licence MIT présente

## Ce qui est en cours

- Aucune tâche en cours.

## Ce qui bloque

- Aucun. Réserve connue : aucune installation externe n'a encore été testée en conditions réelles, donc aucun retour d'usage tiers à ce jour.

## Dernière session

- **Date** : 2026-08-10
- **Agent** : Claude Code
- **Résumé** : le hook `Stop` mesurait la présence d'une modification et non le contenu écrit, et restait muet hors dépôt Git. Ajout d'un hook `SessionStart` posant un repère, mesure des lignes non vides ajoutées (minimum trois), fonctionnement sur projet non versionné, et documentation explicite dans le README de ce que le contrôle garantit et ne garantit pas. Passage en 1.2.0.
