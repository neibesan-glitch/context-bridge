#!/bin/bash
# Context Bridge — Installation rapide
# Usage: curl -fsSL https://raw.githubusercontent.com/neibesan-glitch/context-bridge/main/install.sh | bash

set -e

REPO="neibesan-glitch/context-bridge"
BRANCH="main"
BASE="https://raw.githubusercontent.com/$REPO/$BRANCH"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo "╔══════════════════════════════════════╗"
echo "║       Context Bridge Installer       ║"
echo "║  Memoire partagee entre agents IA    ║"
echo "╚══════════════════════════════════════╝"
echo ""

# Verification : ne pas ecraser un projet existant
if [ -f "docs/INDEX.md" ]; then
  echo -e "${YELLOW}[!] Un dossier docs/ avec INDEX.md existe deja.${NC}"
  echo "    Pour eviter d'ecraser votre travail, l'installation est annulee."
  echo "    Supprimez docs/INDEX.md si vous voulez reinstaller."
  exit 1
fi

echo "[1/4] Creation de la structure docs/..."
mkdir -p docs/permanent docs/journal

echo "[2/4] Telechargement des fichiers de documentation..."
curl -fsSL "$BASE/docs/INDEX.md" -o docs/INDEX.md
curl -fsSL "$BASE/docs/CODE_MAP.md" -o docs/CODE_MAP.md
curl -fsSL "$BASE/docs/state.md" -o docs/state.md
curl -fsSL "$BASE/docs/roadmap.md" -o docs/roadmap.md
curl -fsSL "$BASE/docs/permanent/choix_techniques.md" -o docs/permanent/choix_techniques.md
curl -fsSL "$BASE/docs/permanent/regles_projet.md" -o docs/permanent/regles_projet.md
curl -fsSL "$BASE/docs/journal/journal_bord.md" -o docs/journal/journal_bord.md
curl -fsSL "$BASE/docs/journal/journal_erreurs.md" -o docs/journal/journal_erreurs.md

echo "[3/4] Creation des fichiers de directives agents..."

# CLAUDE.md — ne pas ecraser si existant
if [ -f "CLAUDE.md" ]; then
  echo -e "  ${YELLOW}CLAUDE.md existe deja — ajout du protocole en fin de fichier${NC}"
  echo "" >> CLAUDE.md
  echo "# --- Context Bridge Protocol ---" >> CLAUDE.md
  curl -fsSL "$BASE/CLAUDE.md" >> CLAUDE.md
else
  curl -fsSL "$BASE/CLAUDE.md" -o CLAUDE.md
fi

# CODEX.md
if [ ! -f "CODEX.md" ]; then
  curl -fsSL "$BASE/CODEX.md" -o CODEX.md
fi

# .cursorrules
if [ ! -f ".cursorrules" ]; then
  curl -fsSL "$BASE/.cursorrules" -o .cursorrules
fi

# .github/copilot.md
mkdir -p .github
if [ ! -f ".github/copilot.md" ]; then
  curl -fsSL "$BASE/.github/copilot.md" -o .github/copilot.md
fi

echo "[4/4] Mise a jour du .gitignore..."
if [ -f ".gitignore" ]; then
  if ! grep -q ".obsidian/workspace.json" .gitignore 2>/dev/null; then
    echo "" >> .gitignore
    echo "# Context Bridge — Obsidian cache" >> .gitignore
    echo ".obsidian/workspace.json" >> .gitignore
    echo ".obsidian/workspace-mobile.json" >> .gitignore
    echo ".obsidian/plugins/*/data.json" >> .gitignore
    echo ".obsidian/graph.json" >> .gitignore
  fi
else
  curl -fsSL "$BASE/.gitignore" -o .gitignore
fi

echo ""
echo -e "${GREEN}Context Bridge installe avec succes.${NC}"
echo ""
echo "Fichiers crees :"
echo "  docs/INDEX.md              — Point d'entree"
echo "  docs/state.md              — Etat du projet"
echo "  docs/roadmap.md            — Objectifs"
echo "  docs/CODE_MAP.md           — Architecture"
echo "  docs/permanent/            — Decisions et regles"
echo "  docs/journal/              — Sessions et erreurs"
echo "  CLAUDE.md                  — Directives Claude Code"
echo "  CODEX.md                   — Directives Codex"
echo "  .cursorrules               — Directives Cursor/Windsurf"
echo "  .github/copilot.md         — Directives GitHub Copilot"
echo ""
echo "Prochaines etapes :"
echo "  1. Remplissez docs/state.md avec l'etat actuel de votre projet"
echo "  2. Remplissez docs/roadmap.md avec vos objectifs"
echo "  3. Adaptez docs/CODE_MAP.md a votre architecture"
echo "  4. (Optionnel) Ouvrez docs/ dans Obsidian pour le graphe visuel"
echo ""
