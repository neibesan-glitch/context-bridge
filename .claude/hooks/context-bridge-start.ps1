# Context Bridge - hook SessionStart (Claude Code, Windows)
#
# Equivalent de context-bridge-start.sh. Compatible Windows PowerShell 5.1 et PowerShell 7+.
#
# Pose un repere de debut de session dans .claude/.cache/session-<id> :
#   - la date de creation du fichier sert de reference pour les LastWriteTime
#   - state= et bord= memorisent le volume deja ecrit dans les deux fichiers
#     de passation
#
# N'ecrit JAMAIS sur stdout : Claude Code injecte la sortie standard d'un hook
# SessionStart dans le contexte de la session. Le silence garantit zero token.
#
# Sortie toujours 0 : ce hook ne doit jamais empecher une session de demarrer.

$ErrorActionPreference = "SilentlyContinue"

$root = $env:CLAUDE_PROJECT_DIR
if ([string]::IsNullOrEmpty($root)) { $root = (Get-Location).Path }
if (-not (Test-Path -LiteralPath $root)) { exit 0 }
Set-Location -LiteralPath $root

$input_json = [Console]::In.ReadToEnd()
if ($null -eq $input_json) { $input_json = "" }

# Context Bridge doit etre installe dans ce projet.
if (-not (Test-Path "docs/state.md")) { exit 0 }
if (-not (Test-Path "docs/journal/journal_bord.md")) { exit 0 }

$session = "sans-session"
if ($input_json -match '"session_id"\s*:\s*"([^"]+)"') { $session = $Matches[1] }
$session = ($session -replace '[^A-Za-z0-9_.-]', '_')

New-Item -ItemType Directory -Path ".claude/.cache" -Force | Out-Null

# Lignes non vides d'un fichier. 0 si le fichier est absent ou illisible.
function Get-LignesUtiles {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) { return 0 }
    $lignes = @(Get-Content -LiteralPath $Path | Where-Object { $_ -match '\S' })
    return $lignes.Count
}

# Commit courant, s'il y en a un. Permet au hook Stop de mesurer ce que la
# session a ecrit meme si la passation a deja ete commitee.
$head = (git rev-parse --verify --quiet HEAD 2>$null)
if ($null -eq $head) { $head = "" }
$head = ($head | Out-String).Trim()

$marker = ".claude/.cache/session-$session"
$contenu = "state=$(Get-LignesUtiles 'docs/state.md')`nbord=$(Get-LignesUtiles 'docs/journal/journal_bord.md')`nhead=$head`n"
$utf8 = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText((Join-Path (Get-Location).Path $marker), $contenu, $utf8)

exit 0
