#!/bin/sh
# Context Bridge — hook Stop (Claude Code)
#
# Empeche de clore une session qui a modifie le projet sans avoir ecrit la
# passation (docs/state.md + docs/journal/journal_bord.md).
#
# Ce que le hook mesure : le nombre de lignes non vides ajoutees aux deux
# fichiers de passation pendant la session. Une ligne blanche, un espace ou un
# fichier simplement touche ne suffisent pas.
#
# Deux modes, choisis automatiquement :
#   - depot Git      : comparaison via git diff (depuis le commit de debut de
#                      session si le repere existe, sinon l'arbre de travail)
#   - hors depot Git : comparaison avec le repere pose par le hook SessionStart
#                      (.claude/.cache/session-<id>). Sans repere, le hook se
#                      tait.
#
# Aucun modele n'est appele : ce script est deterministe et ne consomme aucun
# token.
#
# Sort en 0 : rien a signaler, Claude peut s'arreter.
# Sort en 2 : blocage, le message stderr est renvoye a Claude qui poursuit.
#
# Le hook ne bloque qu'une seule fois par session — Claude Code fournit
# stop_hook_active precisement pour interdire une boucle de blocage infinie.

set -u

# Minimum de lignes non vides attendues dans la passation.
CB_MIN_LIGNES=3

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

# 3. Un seul blocage par session.
session=$(printf '%s' "$input" | sed -n 's/.*"session_id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
[ -n "$session" ] || session="sans-session"
session=$(printf '%s' "$session" | sed 's/[^A-Za-z0-9_.-]/_/g')
stamp=".claude/.cache/handoff-$session"
[ -f "$stamp" ] && exit 0

marker=".claude/.cache/session-$session"

# Lignes non vides d'un fichier. 0 si absent ou illisible.
cb_lignes_utiles() {
  [ -f "$1" ] || { echo 0; return; }
  cb_n=$(grep -c '[^[:space:]]' "$1" 2>/dev/null) || cb_n=0
  [ -n "$cb_n" ] || cb_n=0
  echo "$cb_n"
}

# Valeur d'une cle du repere de session ("state", "bord", "head").
cb_repere() {
  [ -f "$marker" ] || { echo ""; return; }
  sed -n "s/^$1=//p" "$marker" 2>/dev/null | head -n 1
}

# Lignes non vides ajoutees a un fichier, en mode Git.
cb_ajout_git() {
  cb_f="$1"
  [ -f "$cb_f" ] || { echo 0; return; }
  if ! git ls-files --error-unmatch "$cb_f" >/dev/null 2>&1; then
    # Fichier non suivi : tout son contenu est nouveau.
    cb_a=$(grep -c '[^[:space:]]' "$cb_f" 2>/dev/null) || cb_a=0
  elif [ -n "$cb_head" ]; then
    # Depuis le debut de session : couvre le commite comme le non commite.
    cb_a=$(git diff -U0 "$cb_head" -- "$cb_f" 2>/dev/null \
           | grep '^+' | grep -v '^+++' | cut -c2- | grep -c '[^[:space:]]') || cb_a=0
  else
    cb_a=$( { git diff -U0 -- "$cb_f"; git diff --cached -U0 -- "$cb_f"; } 2>/dev/null \
            | grep '^+' | grep -v '^+++' | cut -c2- | grep -c '[^[:space:]]') || cb_a=0
  fi
  [ -n "$cb_a" ] || cb_a=0
  echo "$cb_a"
}

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  # ---- Mode depot Git ----------------------------------------------------

  # Commit de debut de session, s'il est connu et toujours valide.
  cb_head=$(cb_repere head)
  if [ -n "$cb_head" ]; then
    git rev-parse --verify --quiet "$cb_head^{commit}" >/dev/null 2>&1 || cb_head=""
  fi

  # Du travail a-t-il ete produit hors base de connaissances ?
  # -uall est indispensable : sans lui, Git regroupe les fichiers non suivis
  # sous leur dossier parent et docs/journal/journal_bord.md n'apparait jamais.
  status=$(git status --porcelain -uall 2>/dev/null) || exit 0
  [ -n "$status" ] || exit 0

  paths=$(printf '%s\n' "$status" | cut -c4-)
  work=$(printf '%s\n' "$paths" | grep -v '^docs/' | grep -v '^\.claude/' | grep -v '^$')
  [ -n "$work" ] || exit 0

  ecrit=$(( $(cb_ajout_git docs/state.md) + $(cb_ajout_git docs/journal/journal_bord.md) ))
else
  # ---- Mode hors depot Git ----------------------------------------------

  # Sans repere de debut de session, aucune comparaison n'est possible.
  [ -f "$marker" ] || exit 0

  # Fichiers modifies depuis le debut de session, hors base de connaissances.
  work=$(find . \
      \( -name .git -o -name node_modules -o -name .venv -o -name venv \
         -o -name __pycache__ -o -name .next -o -name .obsidian -o -name .cache \
         -o -name dist -o -name build \) -prune \
      -o -path './docs' -prune \
      -o -path './.claude' -prune \
      -o -type f -newer "$marker" -print 2>/dev/null \
      | sed 's|^\./||' | grep -v '^$' | head -n 40)
  [ -n "$work" ] || exit 0

  base_state=$(cb_repere state); [ -n "$base_state" ] || base_state=0
  base_bord=$(cb_repere bord);   [ -n "$base_bord" ]  || base_bord=0

  ecrit=$(( ($(cb_lignes_utiles docs/state.md) - base_state) \
          + ($(cb_lignes_utiles docs/journal/journal_bord.md) - base_bord) ))
  [ "$ecrit" -lt 0 ] && ecrit=0
fi

# La passation a-t-elle un contenu reel ?
[ "$ecrit" -ge "$CB_MIN_LIGNES" ] && exit 0

mkdir -p ".claude/.cache" 2>/dev/null
: > "$stamp" 2>/dev/null

changed=$(printf '%s\n' "$work" | head -n 8 | sed 's/^/  - /')
cat >&2 <<EOF
Context Bridge : passation manquante.

Cette session a modifie des fichiers hors de docs/ :
$changed

Lignes ecrites dans la passation : $ecrit (minimum attendu : $CB_MIN_LIGNES).
Toucher un fichier ne suffit pas : il faut du contenu.

Avant de conclure, appliquez le protocole de fin de session (AGENTS.md, section 3) :
  1. Mettre a jour docs/state.md (ce qui fonctionne, en cours, bloque)
  2. Ajouter une entree datee dans docs/journal/journal_bord.md
  3. Mettre a jour docs/roadmap.md si des taches ont avance
  4. Si un bug non trivial a ete resolu : fiche dans docs/journal/journal_erreurs.md
  5. Si une decision d'architecture a ete prise : ADR dans docs/permanent/choix_techniques.md

Puis terminez normalement. Ce rappel ne se declenche qu'une fois par session.
EOF
exit 2
