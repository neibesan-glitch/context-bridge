---
description: Exécute la passation Context Bridge de fin de session
allowed-tools: Read, Edit, Write, Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(git add:*), Bash(git commit:*)
---

Exécute la passation Context Bridge décrite dans `AGENTS.md`, section 3.

Contexte de la session en cours :

- Fichiers modifiés : !`git status --porcelain`
- Derniers commits : !`git log --oneline -5`

Effectue dans l'ordre, sans poser de question quand l'information est déjà dans la session :

1. Relis `docs/state.md` et réécris-le pour refléter l'état réel du projet maintenant : la phrase de résumé, ce qui fonctionne, ce qui est en cours, ce qui bloque, et le bloc « Dernière session » (date du jour, agent « Claude Code », résumé en 1–2 lignes).
2. Ajoute une entrée en tête de la liste des sessions dans `docs/journal/journal_bord.md`, au format imposé par `AGENTS.md` (date du jour, agent, réalisé avec cases cochées, décisions, prochaines étapes). N'écrase aucune entrée existante.
3. Mets à jour `docs/roadmap.md` : coche les tâches terminées, déplace ce qui a changé de statut, ajoute les tâches découvertes pendant la session.
4. Si un bug non trivial a été résolu pendant la session, ajoute une fiche numérotée dans `docs/journal/journal_erreurs.md`.
5. Si une décision d'architecture a été prise, ajoute un ADR numéroté dans `docs/permanent/choix_techniques.md`.
6. Si un module ou un dossier a été ajouté ou a changé de responsabilité, mets à jour `docs/CODE_MAP.md`.
7. Mets à jour le champ `derniere_maj` du frontmatter de chaque fichier que tu as modifié.

Termine en affichant la liste des fichiers de `docs/` que tu as mis à jour, puis propose le commit correspondant. Ne commite pas sans validation.

$ARGUMENTS
