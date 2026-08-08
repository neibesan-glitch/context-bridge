#!/bin/sh
# Context Bridge — hook Stop (Claude Code)
#
# Empeche de clore une session qui a modifie le projet sans avoir ecrit la
# passation (docs/state.md + docs/journal/journal_bord.md).
#
# Sort en 0 : rien a signaler, Claude peut s'arreter.
# Sort en 2 : blocage, le message stderr est renvoye a Claude qui poursuit.
#
# Le hook ne bloque qu'une seule fois par session et ne bloque jamais dans un
# projet ou Context Bridge n'est pas installe.

set -u

ROOT="${CLAUDE_PROJECT_DIR:-$PWD}"
cd "$ROOT" 2>/dev/null || exit 0

input=$(cat 2>/dev/null) || input=""

# 1. Garde anti-recursion fournie par Claude Code.
case "$input" in
  *'"stop_hook_active":true'* | *'"stop_hook_active": true'*) exit 0 ;;
esac

# 2. Context Bridge doit etre installe dans ce projet.
[ -f docs/state.md ] || exit 0
[ -f docs/journal/journal_bord.md ] || exit 0

# 3. Et le projet doit etre un depot Git.
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

# 4. Un seul blocage par session.
session=$(printf '%s' "$input" | sed -n 's/.*"session_id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
[ -n "$session" ] || session="sans-session"
stamp=".claude/.cache/handoff-$session"
[ -f "$stamp" ] && exit 0

# 5. Du travail a-t-il ete produit hors base de connaissances ?
# -uall est indispensable : sans lui, Git regroupe les fichiers non suivis sous
# leur dossier parent et docs/journal/journal_bord.md n'apparait jamais.
status=$(git status --porcelain -uall 2>/dev/null) || exit 0
[ -n "$status" ] || exit 0

paths=$(printf '%s\n' "$status" | cut -c4-)
work=$(printf '%s\n' "$paths" | grep -v '^docs/' | grep -v '^\.claude/' | grep -v '^$')
[ -n "$work" ] || exit 0

# 6. La passation a-t-elle deja ete ecrite ?
logged=$(printf '%s\n' "$paths" | grep -E '^docs/(state\.md|journal/journal_bord\.md)$')
[ -z "$logged" ] || exit 0

mkdir -p ".claude/.cache" 2>/dev/null
: > "$stamp" 2>/dev/null

changed=$(printf '%s\n' "$work" | head -n 8 | sed 's/^/  - /')
cat >&2 <<EOF
Context Bridge : passation manquante.

Cette session a modifie des fichiers hors de docs/ :
$changed

Avant de conclure, appliquez le protocole de fin de session (AGENTS.md, section 3) :
  1. Mettre a jour docs/state.md (ce qui fonctionne, en cours, bloque)
  2. Ajouter une entree datee dans docs/journal/journal_bord.md
  3. Mettre a jour docs/roadmap.md si des taches ont avance
  4. Si un bug non trivial a ete resolu : fiche dans docs/journal/journal_erreurs.md
  5. Si une decision d'architecture a ete prise : ADR dans docs/permanent/choix_techniques.md

Puis terminez normalement. Ce rappel ne se declenche qu'une fois par session.
EOF
exit 2
