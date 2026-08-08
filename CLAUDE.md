@AGENTS.md

# Context Bridge — spécificités Claude Code

Le protocole complet est dans le fichier importé ci-dessus. Cette section ajoute ce qui est propre à Claude Code.

## Passation assistée

- La commande `/handoff` exécute la passation de fin de session (points 1 à 4 du protocole) en une fois.
- Un hook `Stop` (`.claude/hooks/`) vérifie qu'une session ayant modifié du code a bien mis à jour `docs/state.md` et `docs/journal/journal_bord.md`. S'il bloque, exécutez la passation avant de conclure : ce n'est pas une erreur, c'est le protocole.
- Avant un `/compact`, faites la passation. Le résumé de compaction n'est pas versionné, le journal si.

## Auto memory

L'auto memory de Claude Code est locale à votre machine et n'est pas partagée avec les autres agents ni avec l'équipe. Elle ne remplace pas `docs/`. Tout ce qui doit survivre à un changement d'outil ou de machine va dans `docs/`.
