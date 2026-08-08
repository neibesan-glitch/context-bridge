---
type: etat
statut: actif
derniere_maj: 2026-08-08
tags: [meta/etat]
---

# État du projet

> Résumé rapide de l'état actuel. Mis à jour à chaque fin de session. Retour à l'[[INDEX]].

## En une phrase

Context Bridge 1.1.0 est un template Git fonctionnel qui installe un protocole de passation inter-agents, désormais appliqué par un hook de fin de session et non plus seulement recommandé.

## Ce qui fonctionne

- Protocole canonique unique dans `AGENTS.md`, relayé par des pointeurs vers les chemins réellement lus par Claude Code, Cursor, Windsurf, Copilot et Codex
- Hook `Stop` Claude Code qui bloque une fois par session si du code a été modifié sans passation, en version POSIX et PowerShell
- Commande `/handoff` qui exécute la passation complète
- Installation et mise à jour en une commande, sous Bash et PowerShell, non destructives
- Gabarits vierges isolés dans `template/docs/`, séparés de la mémoire du dépôt
- CI qui vérifie les deux installeurs, l'intégrité des liens wiki et l'absence de duplication du protocole
- Licence MIT présente

## Ce qui est en cours

- Aucune tâche en cours.

## Ce qui bloque

- Aucun.

## Dernière session

- **Date** : 2026-08-08
- **Agent** : Claude Code
- **Résumé** : audit complet du dépôt puis correction des quatre défauts bloquants (commande `npx` pointant vers un paquet tiers, trois chemins de directives sur quatre jamais lus par leur outil, licence absente, protocole non appliqué). Passage en 1.1.0.
