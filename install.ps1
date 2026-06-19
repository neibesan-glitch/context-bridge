# Context Bridge — Installation rapide (Windows PowerShell)
# Usage: irm https://raw.githubusercontent.com/neibesan-glitch/context-bridge/main/install.ps1 | iex

$ErrorActionPreference = "Stop"

$Repo = "neibesan-glitch/context-bridge"
$Branch = "main"
$Base = "https://raw.githubusercontent.com/$Repo/$Branch"

Write-Host ""
Write-Host "+==============================================+" -ForegroundColor Cyan
Write-Host "|         Context Bridge Installer             |" -ForegroundColor Cyan
Write-Host "|    Memoire partagee entre agents IA          |" -ForegroundColor Cyan
Write-Host "+==============================================+" -ForegroundColor Cyan
Write-Host ""

# Verification : ne pas ecraser
if (Test-Path "docs/INDEX.md") {
    Write-Host "[!] Un dossier docs/ avec INDEX.md existe deja." -ForegroundColor Yellow
    Write-Host "    Pour eviter d'ecraser votre travail, l'installation est annulee."
    Write-Host "    Supprimez docs/INDEX.md si vous voulez reinstaller."
    exit 1
}

Write-Host "[1/4] Creation de la structure docs/..."
New-Item -ItemType Directory -Path "docs/permanent" -Force | Out-Null
New-Item -ItemType Directory -Path "docs/journal" -Force | Out-Null

Write-Host "[2/4] Telechargement des fichiers de documentation..."
$files = @(
    @("docs/INDEX.md", "docs/INDEX.md"),
    @("docs/CODE_MAP.md", "docs/CODE_MAP.md"),
    @("docs/state.md", "docs/state.md"),
    @("docs/roadmap.md", "docs/roadmap.md"),
    @("docs/permanent/choix_techniques.md", "docs/permanent/choix_techniques.md"),
    @("docs/permanent/regles_projet.md", "docs/permanent/regles_projet.md"),
    @("docs/journal/journal_bord.md", "docs/journal/journal_bord.md"),
    @("docs/journal/journal_erreurs.md", "docs/journal/journal_erreurs.md")
)

foreach ($f in $files) {
    Invoke-WebRequest -Uri "$Base/$($f[0])" -OutFile $f[1] -UseBasicParsing
}

Write-Host "[3/4] Creation des fichiers de directives agents..."

# CLAUDE.md
if (Test-Path "CLAUDE.md") {
    Write-Host "  CLAUDE.md existe deja - ajout du protocole en fin de fichier" -ForegroundColor Yellow
    Add-Content -Path "CLAUDE.md" -Value "`n# --- Context Bridge Protocol ---`n"
    $content = (Invoke-WebRequest -Uri "$Base/CLAUDE.md" -UseBasicParsing).Content
    Add-Content -Path "CLAUDE.md" -Value $content
} else {
    Invoke-WebRequest -Uri "$Base/CLAUDE.md" -OutFile "CLAUDE.md" -UseBasicParsing
}

# CODEX.md
if (-not (Test-Path "CODEX.md")) {
    Invoke-WebRequest -Uri "$Base/CODEX.md" -OutFile "CODEX.md" -UseBasicParsing
}

# .cursorrules
if (-not (Test-Path ".cursorrules")) {
    Invoke-WebRequest -Uri "$Base/.cursorrules" -OutFile ".cursorrules" -UseBasicParsing
}

# .github/copilot.md
New-Item -ItemType Directory -Path ".github" -Force | Out-Null
if (-not (Test-Path ".github/copilot.md")) {
    Invoke-WebRequest -Uri "$Base/.github/copilot.md" -OutFile ".github/copilot.md" -UseBasicParsing
}

Write-Host "[4/4] Mise a jour du .gitignore..."
if (Test-Path ".gitignore") {
    $content = Get-Content ".gitignore" -Raw
    if ($content -notmatch "\.obsidian/workspace\.json") {
        Add-Content -Path ".gitignore" -Value "`n# Context Bridge - Obsidian cache"
        Add-Content -Path ".gitignore" -Value ".obsidian/workspace.json"
        Add-Content -Path ".gitignore" -Value ".obsidian/workspace-mobile.json"
        Add-Content -Path ".gitignore" -Value ".obsidian/plugins/*/data.json"
        Add-Content -Path ".gitignore" -Value ".obsidian/graph.json"
    }
} else {
    Invoke-WebRequest -Uri "$Base/.gitignore" -OutFile ".gitignore" -UseBasicParsing
}

Write-Host ""
Write-Host "Context Bridge installe avec succes." -ForegroundColor Green
Write-Host ""
Write-Host "Fichiers crees :"
Write-Host "  docs/INDEX.md              - Point d'entree"
Write-Host "  docs/state.md              - Etat du projet"
Write-Host "  docs/roadmap.md            - Objectifs"
Write-Host "  docs/CODE_MAP.md           - Architecture"
Write-Host "  docs/permanent/            - Decisions et regles"
Write-Host "  docs/journal/              - Sessions et erreurs"
Write-Host "  CLAUDE.md                  - Directives Claude Code"
Write-Host "  CODEX.md                   - Directives Codex"
Write-Host "  .cursorrules               - Directives Cursor/Windsurf"
Write-Host "  .github/copilot.md         - Directives GitHub Copilot"
Write-Host ""
Write-Host "Prochaines etapes :"
Write-Host "  1. Remplissez docs/state.md avec l'etat actuel de votre projet"
Write-Host "  2. Remplissez docs/roadmap.md avec vos objectifs"
Write-Host "  3. Adaptez docs/CODE_MAP.md a votre architecture"
Write-Host "  4. (Optionnel) Ouvrez docs/ dans Obsidian pour le graphe visuel"
Write-Host ""
