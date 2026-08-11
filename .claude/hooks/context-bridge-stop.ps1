# Context Bridge - hook Stop (Claude Code, Windows)
#
# Equivalent de context-bridge-stop.sh. Compatible Windows PowerShell 5.1 et PowerShell 7+.
#
# Ce que le hook mesure : le nombre de lignes non vides ajoutees aux deux
# fichiers de passation pendant la session. Une ligne blanche, un espace ou un
# fichier simplement touche ne suffisent pas.
#
# Deux modes, choisis automatiquement :
#   - depot Git      : comparaison via git diff (depuis le commit de debut de
#                      session si le repere existe, sinon l'arbre de travail)
#   - hors depot Git : comparaison avec le repere pose par le hook SessionStart
#                      (.claude/.cache/session-<id>). Sans repere, le hook se tait.
#
# Aucun modele n'est appele : ce script est deterministe et ne consomme aucun token.
#
# Sortie 0 : rien a signaler, Claude peut s'arreter.
# Sortie 2 : blocage, le message stderr est renvoye a Claude qui poursuit.

$ErrorActionPreference = "SilentlyContinue"

# Minimum de lignes non vides attendues dans la passation.
$cbMinLignes = 3

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

# 3. Un seul blocage par session.
$session = "sans-session"
if ($input_json -match '"session_id"\s*:\s*"([^"]+)"') { $session = $Matches[1] }
$session = ($session -replace '[^A-Za-z0-9_.-]', '_')
$stamp = ".claude/.cache/handoff-$session"
if (Test-Path -LiteralPath $stamp) { exit 0 }

$marker = ".claude/.cache/session-$session"

# Lignes non vides d'un fichier. 0 si absent ou illisible.
function Get-CBLignesUtiles {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) { return 0 }
    return @(Get-Content -LiteralPath $Path | Where-Object { $_ -match '\S' }).Count
}

# Valeur d'une cle du repere de session ("state", "bord", "head").
function Get-CBRepere {
    param([string]$Cle)
    if (-not (Test-Path -LiteralPath $marker)) { return "" }
    foreach ($ligne in @(Get-Content -LiteralPath $marker)) {
        if ($ligne -match "^$Cle=(.*)$") { return $Matches[1].Trim() }
    }
    return ""
}

# Lignes non vides ajoutees a un fichier, en mode Git.
function Get-CBAjoutGit {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) { return 0 }

    git ls-files --error-unmatch $Path 2>$null | Out-Null
    if ($LASTEXITCODE -ne 0) {
        # Fichier non suivi : tout son contenu est nouveau.
        return (Get-CBLignesUtiles $Path)
    }

    if ([string]::IsNullOrEmpty($cbHead)) {
        $diff = @(git diff -U0 -- $Path 2>$null) + @(git diff --cached -U0 -- $Path 2>$null)
    } else {
        # Depuis le debut de session : couvre le commite comme le non commite.
        $diff = @(git diff -U0 $cbHead -- $Path 2>$null)
    }

    return @($diff |
        Where-Object { $_ -like '+*' -and $_ -notlike '+++*' } |
        ForEach-Object { $_.Substring(1) } |
        Where-Object { $_ -match '\S' }).Count
}

# Un chemin relatif compte-t-il comme du travail ?
function Test-CBTravail {
    param([string]$Rel)
    if ($Rel -like 'docs/*' -or $Rel -like '.claude/*') { return $false }
    foreach ($seg in @('.git', 'node_modules', '.venv', 'venv', '__pycache__',
                       '.next', '.obsidian', '.cache', 'dist', 'build')) {
        if (("/" + $Rel) -like "*/$seg/*") { return $false }
    }
    return $true
}

git rev-parse --is-inside-work-tree 2>$null | Out-Null
$dansGit = ($LASTEXITCODE -eq 0)

if ($dansGit) {
    # ---- Mode depot Git ----------------------------------------------------

    # Commit de debut de session, s'il est connu et toujours valide.
    $cbHead = Get-CBRepere "head"
    if (-not [string]::IsNullOrEmpty($cbHead)) {
        git rev-parse --verify --quiet "$cbHead^{commit}" 2>$null | Out-Null
        if ($LASTEXITCODE -ne 0) { $cbHead = "" }
    }

    # -uall est indispensable : sans lui, Git regroupe les fichiers non suivis
    # sous leur dossier parent et docs/journal/journal_bord.md n'apparait jamais.
    $status = @(git status --porcelain -uall 2>$null)
    if ($status.Count -eq 0) { exit 0 }

    $paths = $status | ForEach-Object { if ($_.Length -gt 3) { $_.Substring(3) } }
    $work = @($paths | Where-Object { $_ -and (Test-CBTravail $_) })
    if ($work.Count -eq 0) { exit 0 }

    $ecrit = (Get-CBAjoutGit "docs/state.md") + (Get-CBAjoutGit "docs/journal/journal_bord.md")
} else {
    # ---- Mode hors depot Git ----------------------------------------------

    # Sans repere de debut de session, aucune comparaison n'est possible.
    if (-not (Test-Path -LiteralPath $marker)) { exit 0 }
    $repereTime = (Get-Item -LiteralPath $marker).LastWriteTime
    $racine = (Get-Location).Path

    # On evite de descendre dans les dossiers lourds de premier niveau.
    $lourds = @('.git', 'node_modules', '.venv', 'venv', '__pycache__',
                '.next', '.obsidian', '.cache', 'dist', 'build', 'docs', '.claude')
    $recents = New-Object System.Collections.ArrayList
    foreach ($item in @(Get-ChildItem -LiteralPath $racine -Force)) {
        if ($item.PSIsContainer) {
            if ($lourds -contains $item.Name) { continue }
            foreach ($f in @(Get-ChildItem -LiteralPath $item.FullName -Recurse -File -Force |
                             Where-Object { $_.LastWriteTime -gt $repereTime })) {
                [void]$recents.Add($f.FullName)
            }
        } elseif ($item.LastWriteTime -gt $repereTime) {
            [void]$recents.Add($item.FullName)
        }
    }

    $work = @($recents |
        ForEach-Object { ($_.Substring($racine.Length).TrimStart('\', '/')) -replace '\\', '/' } |
        Where-Object { $_ -and (Test-CBTravail $_) } |
        Select-Object -First 40)
    if ($work.Count -eq 0) { exit 0 }

    $baseState = Get-CBRepere "state"; if (-not $baseState) { $baseState = 0 }
    $baseBord = Get-CBRepere "bord";   if (-not $baseBord)  { $baseBord = 0 }

    $ecrit = ((Get-CBLignesUtiles "docs/state.md") - [int]$baseState) +
             ((Get-CBLignesUtiles "docs/journal/journal_bord.md") - [int]$baseBord)
    if ($ecrit -lt 0) { $ecrit = 0 }
}

# La passation a-t-elle un contenu reel ?
if ($ecrit -ge $cbMinLignes) { exit 0 }

New-Item -ItemType Directory -Path ".claude/.cache" -Force | Out-Null
Set-Content -LiteralPath $stamp -Value "" -Encoding UTF8

$changed = ($work | Select-Object -First 8 | ForEach-Object { "  - $_" }) -join "`n"
$message = @"
Context Bridge : passation manquante.

Cette session a modifie des fichiers hors de docs/ :
$changed

Lignes ecrites dans la passation : $ecrit (minimum attendu : $cbMinLignes).
Toucher un fichier ne suffit pas : il faut du contenu.

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
