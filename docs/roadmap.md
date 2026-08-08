---
type: roadmap
statut: actif
derniere_maj: 2026-08-08
tags: [meta/roadmap]
---

# Roadmap du projet

> Objectifs et tâches. Mis à jour à chaque fin de session. Retour à l'[[INDEX]].

## Objectif principal

Faire en sorte qu'un projet suivi par plusieurs agents IA ne perde jamais son contexte, sans dépendance externe et sans discipline manuelle : la mémoire vit dans Git et la passation est appliquée par un hook.

## En cours

- Aucune tâche en cours.

## À faire — priorité haute

- [ ] Publier le paquet npm sous un nom disponible (`@neibesan/context-bridge`) pour rétablir une installation `npx`
- [ ] Étendre l'application du protocole hors Claude Code : hook Git `pre-push` qui refuse un push sans entrée de journal correspondante

## À faire — priorité basse

- [ ] Commande de vérification `context-bridge doctor` : signale les gabarits jamais remplis et les journaux périmés
- [ ] Traduction anglaise du protocole (`AGENTS.en.md`)
- [ ] Exemple de dépôt de démonstration montrant trois sessions successives avec trois agents différents

## Terminé

- [x] 2026-08-08 — Fichier canonique `AGENTS.md` et suppression de la duplication du protocole dans quatre fichiers
- [x] 2026-08-08 — Correction des chemins de directives (Cursor, Windsurf, Copilot, Codex)
- [x] 2026-08-08 — Hook `Stop` de vérification de passation et commande `/handoff`
- [x] 2026-08-08 — Licence MIT ajoutée, mention `npx` erronée retirée
- [x] 2026-08-08 — Séparation `template/docs/` et `docs/`
- [x] 2026-08-08 — Mise à jour d'une installation existante via `--update`
- [x] 2026-08-08 — CI GitHub Actions sur les deux installeurs
- [x] 2026-06-19 — Restructuration en Context Bridge, architecture rendue agnostique
