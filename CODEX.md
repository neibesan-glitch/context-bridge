# Context Bridge — Directives Codex

Ce fichier impose le protocole de continuite entre sessions. Suivez-le a chaque interaction.

## Demarrage de session (Lecture obligatoire)

Avant toute action, lisez dans cet ordre :
1. `docs/state.md` — etat courant du projet (resume en 5 lignes)
2. `docs/roadmap.md` — objectifs et taches en cours
3. `docs/journal/journal_bord.md` — derniere session (qui a fait quoi)
4. `docs/journal/journal_erreurs.md` — bugs resolus (ne pas les reproduire)
5. `docs/CODE_MAP.md` — architecture du projet

## Pendant la session

- Si vous creez un nouveau module ou dossier : mettez a jour `docs/CODE_MAP.md`
- Si vous prenez une decision technique importante : documentez dans `docs/permanent/choix_techniques.md`
- Si vous resolvez un bug non trivial : ajoutez une fiche dans `docs/journal/journal_erreurs.md`

## Fin de session (Ecriture obligatoire)

> IMPORTANT : Avant de clore la session ou a l'approche de la limite de contexte :

1. Mettez a jour `docs/state.md` avec l'etat actuel du projet
2. Ajoutez une entree dans `docs/journal/journal_bord.md` :
   - Date, auteur/agent
   - Travail realise (avec taches cochees)
   - Decisions prises
   - Taches restantes
3. Mettez a jour `docs/roadmap.md` si des taches sont completees ou ajoutees
4. Commit et push
