#!/bin/sh
# Context Bridge — hook SessionStart (Claude Code)
#
# Pose un repere de debut de session dans .claude/.cache/session-<id> :
#   - la date de creation du fichier sert de reference pour les mtime
#   - state= et bord= memorisent le volume deja ecrit dans les deux fichiers
#     de passation
#
# Ce repere permet au hook Stop de mesurer le travail d'une session dans un
# projet qui n'est pas un depot Git. Dans un depot Git, le hook Stop utilise
# git diff et ignore ce repere.
#
# Ce hook n'ecrit JAMAIS sur stdout : Claude Code injecte la sortie standard
# d'un hook SessionStart dans le contexte de la session. Rester silencieux
# garantit un cout de zero token.
#
# Sort toujours en 0 : ce hook ne doit jamais empecher une session de demarrer.

set -u

ROOT="${CLAUDE_PROJECT_DIR:-$PWD}"
cd "$ROOT" 2>/dev/null || exit 0

input=$(cat 2>/dev/null) || input=""

# Context Bridge doit etre installe dans ce projet.
[ -f docs/state.md ] || exit 0
[ -f docs/journal/journal_bord.md ] || exit 0

session=$(printf '%s' "$input" | sed -n 's/.*"session_id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
[ -n "$session" ] || session="sans-session"
session=$(printf '%s' "$session" | sed 's/[^A-Za-z0-9_.-]/_/g')

mkdir -p .claude/.cache 2>/dev/null || exit 0

# Lignes non vides d'un fichier. 0 si le fichier est absent ou illisible.
lignes_utiles() {
  [ -f "$1" ] || { echo 0; return; }
  n=$(grep -c '[^[:space:]]' "$1" 2>/dev/null) || n=0
  [ -n "$n" ] || n=0
  echo "$n"
}

# Commit courant, s'il y en a un. Permet au hook Stop de mesurer ce que la
# session a ecrit meme si la passation a deja ete commitee.
head=$(git rev-parse --verify --quiet HEAD 2>/dev/null) || head=""

marker=".claude/.cache/session-$session"
{
  echo "state=$(lignes_utiles docs/state.md)"
  echo "bord=$(lignes_utiles docs/journal/journal_bord.md)"
  echo "head=$head"
} > "$marker" 2>/dev/null || exit 0

exit 0
