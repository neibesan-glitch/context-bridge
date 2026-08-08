#!/usr/bin/env bash
# Context Bridge — installation
#
# Installation :  curl -fsSL https://raw.githubusercontent.com/neibesan-glitch/context-bridge/main/install.sh | bash
# Mise a jour  :  curl -fsSL https://raw.githubusercontent.com/neibesan-glitch/context-bridge/main/install.sh | bash -s -- --update
#
# --update rafraichit uniquement les fichiers de directives, les hooks et la
# commande /handoff. Le contenu de docs/ n'est jamais touche.

set -euo pipefail

VERSION="1.1.0"
REPO="neibesan-glitch/context-bridge"
BRANCH="${CONTEXT_BRIDGE_BRANCH:-main}"
# CONTEXT_BRIDGE_BASE permet de pointer vers une autre source (branche de test,
# copie locale via file://). Utilise par la CI.
BASE="${CONTEXT_BRIDGE_BASE:-https://raw.githubusercontent.com/$REPO/$BRANCH}"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

MODE="install"
for arg in "$@"; do
  case "$arg" in
    --update) MODE="update" ;;
    --help|-h)
      echo "Usage: install.sh [--update]"
      echo "  (sans option)  installe Context Bridge dans le repertoire courant"
      echo "  --update       met a jour directives, hooks et commandes sans toucher a docs/"
      exit 0
      ;;
    *) echo "Option inconnue : $arg" >&2; exit 1 ;;
  esac
done

info()  { printf '%s\n' "$1"; }
warn()  { printf "${YELLOW}%s${NC}\n" "$1"; }
ok()    { printf "${GREEN}%s${NC}\n" "$1"; }
fail()  { printf "${RED}%s${NC}\n" "$1" >&2; exit 1; }

command -v curl >/dev/null 2>&1 || fail "curl est requis."

# Telecharge $1 (chemin dans le depot) vers $2 (chemin local).
fetch() {
  mkdir -p "$(dirname "$2")"
  curl -fsSL "$BASE/$1" -o "$2" || fail "Telechargement impossible : $1"
}

# Telecharge $1 vers $2 uniquement si $2 n'existe pas.
fetch_if_absent() {
  if [ -f "$2" ]; then
    return 1
  fi
  fetch "$1" "$2"
  return 0
}

echo ""
echo "+----------------------------------------------+"
echo "|            Context Bridge $VERSION               |"
echo "|      Memoire partagee entre agents IA        |"
echo "+----------------------------------------------+"
echo ""

if [ "$MODE" = "install" ] && [ -f "docs/INDEX.md" ]; then
  warn "[!] docs/INDEX.md existe deja : Context Bridge semble installe."
  info "    Pour rafraichir les directives sans toucher a votre documentation :"
  info "    curl -fsSL $BASE/install.sh | bash -s -- --update"
  exit 1
fi

if [ "$MODE" = "update" ] && [ ! -f "docs/INDEX.md" ]; then
  warn "[!] Aucune installation detectee (docs/INDEX.md absent)."
  info "    Lancez l'installation sans --update."
  exit 1
fi

STEPS=4
[ "$MODE" = "update" ] && STEPS=3

if [ "$MODE" = "install" ]; then
  info "[1/$STEPS] Base de connaissances docs/..."
  for f in \
    docs/INDEX.md \
    docs/CODE_MAP.md \
    docs/state.md \
    docs/roadmap.md \
    docs/permanent/choix_techniques.md \
    docs/permanent/regles_projet.md \
    docs/journal/journal_bord.md \
    docs/journal/journal_erreurs.md
  do
    # Les gabarits vierges vivent dans template/, la memoire du depot dans docs/.
    fetch "template/$f" "$f"
  done
  STEP=2
else
  info "Mode mise a jour : docs/ conserve en l'etat."
  STEP=1
fi

info "[$STEP/$STEPS] Protocole et directives par outil..."
fetch AGENTS.md AGENTS.md
fetch .cursor/rules/context-bridge.mdc .cursor/rules/context-bridge.mdc
fetch .windsurf/rules/context-bridge.md .windsurf/rules/context-bridge.md
fetch .github/copilot-instructions.md .github/copilot-instructions.md
fetch .cursorrules .cursorrules
fetch .windsurfrules .windsurfrules

# CLAUDE.md : ne jamais ecraser un fichier existant.
if [ -f "CLAUDE.md" ]; then
  if grep -q "^@AGENTS.md" CLAUDE.md 2>/dev/null; then
    info "  CLAUDE.md importe deja AGENTS.md — inchange"
  else
    warn "  CLAUDE.md existe deja — ajout de l'import Context Bridge en fin de fichier"
    {
      echo ""
      echo "@AGENTS.md"
      echo ""
      echo "<!-- Ligne ajoutee par Context Bridge : le protocole vit dans AGENTS.md -->"
    } >> CLAUDE.md
  fi
else
  fetch CLAUDE.md CLAUDE.md
fi

STEP=$((STEP + 1))
info "[$STEP/$STEPS] Execution du protocole (hook Claude Code + commande /handoff)..."
fetch .claude/hooks/context-bridge-stop.sh .claude/hooks/context-bridge-stop.sh
fetch .claude/hooks/context-bridge-stop.ps1 .claude/hooks/context-bridge-stop.ps1
fetch .claude/commands/handoff.md .claude/commands/handoff.md
chmod +x .claude/hooks/context-bridge-stop.sh 2>/dev/null || true

if fetch_if_absent .claude/settings.json .claude/settings.json; then
  info "  .claude/settings.json cree (hook Stop actif)"
else
  if grep -q "context-bridge-stop" .claude/settings.json 2>/dev/null; then
    info "  .claude/settings.json declare deja le hook — inchange"
  else
    warn "  .claude/settings.json existe deja et n'est pas modifie."
    warn "  Ajoutez-y ce bloc pour activer la verification de passation :"
    cat <<'SNIPPET'

  "hooks": {
    "Stop": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "sh",
            "args": ["${CLAUDE_PROJECT_DIR}/.claude/hooks/context-bridge-stop.sh"],
            "timeout": 15
          }
        ]
      }
    ]
  }

SNIPPET
  fi
fi

STEP=$((STEP + 1))
info "[$STEP/$STEPS] .gitignore..."
GITIGNORE_LINES=".claude/.cache/
.obsidian/workspace.json
.obsidian/workspace-mobile.json
.obsidian/plugins/*/data.json
.obsidian/graph.json"

if [ -f ".gitignore" ]; then
  if ! grep -q "^\.claude/\.cache/" .gitignore 2>/dev/null; then
    {
      echo ""
      echo "# Context Bridge"
      echo "$GITIGNORE_LINES"
    } >> .gitignore
  else
    info "  .gitignore deja a jour"
  fi
else
  fetch .gitignore .gitignore
fi

echo ""
if [ "$MODE" = "update" ]; then
  ok "Context Bridge mis a jour en $VERSION."
  echo ""
  info "Directives, hooks et commande /handoff rafraichis. docs/ inchange."
else
  ok "Context Bridge $VERSION installe."
  echo ""
  info "Cree :"
  info "  AGENTS.md                          Protocole canonique"
  info "  CLAUDE.md                          Claude Code (import de AGENTS.md)"
  info "  .cursor/rules/                     Cursor"
  info "  .windsurf/rules/                   Windsurf"
  info "  .github/copilot-instructions.md    GitHub Copilot"
  info "  .claude/hooks/                     Verification de passation en fin de session"
  info "  .claude/commands/handoff.md        Commande /handoff"
  info "  docs/                              Base de connaissances"
  echo ""
  info "Prochaines etapes :"
  info "  1. Remplir docs/state.md et docs/roadmap.md"
  info "  2. Adapter docs/CODE_MAP.md a votre architecture"
  info "  3. Redemarrer Claude Code pour charger le hook"
  info "  4. (Optionnel) Ouvrir docs/ dans Obsidian pour la vue graphe"
fi
echo ""
