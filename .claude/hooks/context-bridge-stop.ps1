# Context Bridge - hook Stop (Claude Code, Windows)
#
# Equivalent de context-bridge-stop.sh. Compatible Windows PowerShell 5.1 et PowerShell 7+.
#
# Sortie 0 : rien a signaler, Claude peut s'arreter.
# Sortie 2 : blocage, le message stderr est renvoye a Claude qui poursuit.

$ErrorActionPreference = "SilentlyContinue"

$root = $env:CLAUDE_PROJECT_DIR
if ([string]::IsNullOrEmpty($root)) { $root = (Get-Location).Path }
if (-not (Test-Path -LiteralPath $root)) { exit 0 }
Set-Location -LiteralPath $root

$input_json = [Console]::In.ReadToEnd()
if ($null -eq $input_json) { $input_json = "" }

# 1. Garde anti-recursion fournie par Claude Code.
if ($input_json -match '"stop_hook_active"\s*:\s*true') { exit 0 }

# 2. Context Bridge doit etre installe dans ce projet.
if (-not (Test-Path "docs/state.md")) { exit 0 }
if (-not (Test-Path "docs/journal/journal_bord.md")) { exit 0 }

# 3. Et le projet doit etre un depot Git.
git rev-parse --is-inside-work-tree 2>$null | Out-Null
if ($LASTEXITCODE -ne 0) { exit 0 }

# 4. Un seul blocage par session.
$session = "sans-session"
if ($input_json -match '"session_id"\s*:\s*"([^"]+)"') { $session = $Matches[1] }
$session = ($session -replace '[^A-Za-z0-9_.-]', '_')
$stamp = ".claude/.cache/handoff-$session"
if (Test-Path -LiteralPath $stamp) { exit 0 }

# 5. Du travail a-t-il ete produit hors base de connaissances ?
# -uall est indispensable : sans lui, Git regroupe les fichiers non suivis sous
# leur dossier parent et docs/journal/journal_bord.md n'apparait jamais.
$status = @(git status --porcelain -uall 2>$null)
if ($status.Count -eq 0) { exit 0 }

$paths = $status | ForEach-Object { if ($_.Length -gt 3) { $_.Substring(3) } }
$work = @($paths | Where-Object { $_ -and $_ -notlike "docs/*" -and $_ -notlike ".claude/*" })
if ($work.Count -eq 0) { exit 0 }

# 6. La passation a-t-elle deja ete ecrite ?
$logged = @($paths | Where-Object { $_ -eq "docs/state.md" -or $_ -eq "docs/journal/journal_bord.md" })
if ($logged.Count -gt 0) { exit 0 }

New-Item -ItemType Directory -Path ".claude/.cache" -Force | Out-Null
Set-Content -LiteralPath $stamp -Value "" -Encoding UTF8

$changed = ($work | Select-Object -First 8 | ForEach-Object { "  - $_" }) -join "`n"
$message = @"
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
"@

[Console]::Error.WriteLine($message)
exit 2
