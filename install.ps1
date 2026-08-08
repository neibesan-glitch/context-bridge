param([switch]$Update)

# Context Bridge - installation (Windows PowerShell 5.1 et PowerShell 7+)
#
# Installation :  irm https://raw.githubusercontent.com/neibesan-glitch/context-bridge/main/install.ps1 | iex
# Mise a jour  :  & ([scriptblock]::Create((irm https://raw.githubusercontent.com/neibesan-glitch/context-bridge/main/install.ps1))) -Update
#
# -Update rafraichit uniquement les fichiers de directives, les hooks et la
# commande /handoff. Le contenu de docs/ n'est jamais touche.
#
# Le script ne modifie pas les preferences de votre session et n'appelle jamais
# `exit` : il rend la main proprement, meme execute via `iex`.

$script:CBVersion = "1.1.0"

$cbBase = $env:CONTEXT_BRIDGE_BASE
if ([string]::IsNullOrEmpty($cbBase)) {
    $cbBranch = $env:CONTEXT_BRIDGE_BRANCH
    if ([string]::IsNullOrEmpty($cbBranch)) { $cbBranch = "main" }
    $cbBase = "https://raw.githubusercontent.com/neibesan-glitch/context-bridge/$cbBranch"
}

$cbPrevEap = $ErrorActionPreference
$ErrorActionPreference = "Stop"

try {
    if ([Net.ServicePointManager]::SecurityProtocol -notmatch 'Tls12') {
        [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
    }
} catch { }

function Write-Utf8Append {
    param([string]$Path, [string]$Text)
    $existing = ""
    if (Test-Path -LiteralPath $Path) {
        $existing = [System.IO.File]::ReadAllText((Resolve-Path -LiteralPath $Path))
    }
    $utf8 = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText((Join-Path (Get-Location).Path $Path), $existing + $Text, $utf8)
}

function Get-CBFile {
    param([string]$Source, [string]$Target)
    $dir = Split-Path -Parent $Target
    if ($dir -and -not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    if ($cbBase -like "http*") {
        Invoke-WebRequest -Uri "$cbBase/$Source" -OutFile $Target -UseBasicParsing
    } else {
        # Base locale : utilise par la CI pour tester sans reseau.
        $local = Join-Path $cbBase ($Source -replace '/', [System.IO.Path]::DirectorySeparatorChar)
        Copy-Item -LiteralPath $local -Destination $Target -Force
    }
}

function Write-CBInfo { param([string]$m) Write-Host $m }
function Write-CBWarn { param([string]$m) Write-Host $m -ForegroundColor Yellow }
function Write-CBOk   { param([string]$m) Write-Host $m -ForegroundColor Green }

try {
    Write-Host ""
    Write-Host "+----------------------------------------------+" -ForegroundColor Cyan
    Write-Host "|            Context Bridge $($script:CBVersion)               |" -ForegroundColor Cyan
    Write-Host "|      Memoire partagee entre agents IA        |" -ForegroundColor Cyan
    Write-Host "+----------------------------------------------+" -ForegroundColor Cyan
    Write-Host ""

    $installed = Test-Path "docs/INDEX.md"

    if (-not $Update -and $installed) {
        Write-CBWarn "[!] docs/INDEX.md existe deja : Context Bridge semble installe."
        Write-CBInfo "    Pour rafraichir les directives sans toucher a votre documentation :"
        Write-CBInfo "    & ([scriptblock]::Create((irm $cbBase/install.ps1))) -Update"
        return
    }

    if ($Update -and -not $installed) {
        Write-CBWarn "[!] Aucune installation detectee (docs/INDEX.md absent)."
        Write-CBInfo "    Lancez l'installation sans -Update."
        return
    }

    $steps = 4
    if ($Update) { $steps = 3 }
    $step = 1

    if (-not $Update) {
        Write-CBInfo "[$step/$steps] Base de connaissances docs/..."
        $docs = @(
            "docs/INDEX.md",
            "docs/CODE_MAP.md",
            "docs/state.md",
            "docs/roadmap.md",
            "docs/permanent/choix_techniques.md",
            "docs/permanent/regles_projet.md",
            "docs/journal/journal_bord.md",
            "docs/journal/journal_erreurs.md"
        )
        # Les gabarits vierges vivent dans template/, la memoire du depot dans docs/.
        foreach ($f in $docs) { Get-CBFile -Source "template/$f" -Target $f }
        $step++
    } else {
        Write-CBInfo "Mode mise a jour : docs/ conserve en l'etat."
    }

    Write-CBInfo "[$step/$steps] Protocole et directives par outil..."
    $directives = @(
        "AGENTS.md",
        ".cursor/rules/context-bridge.mdc",
        ".windsurf/rules/context-bridge.md",
        ".github/copilot-instructions.md",
        ".cursorrules",
        ".windsurfrules"
    )
    foreach ($f in $directives) { Get-CBFile -Source $f -Target $f }

    if (Test-Path "CLAUDE.md") {
        $claude = [System.IO.File]::ReadAllText((Resolve-Path "CLAUDE.md"))
        if ($claude -match '(?m)^@AGENTS\.md') {
            Write-CBInfo "  CLAUDE.md importe deja AGENTS.md - inchange"
        } else {
            Write-CBWarn "  CLAUDE.md existe deja - ajout de l'import Context Bridge en fin de fichier"
            Write-Utf8Append -Path "CLAUDE.md" -Text "`r`n@AGENTS.md`r`n`r`n<!-- Ligne ajoutee par Context Bridge : le protocole vit dans AGENTS.md -->`r`n"
        }
    } else {
        Get-CBFile -Source "CLAUDE.md" -Target "CLAUDE.md"
    }

    $step++
    Write-CBInfo "[$step/$steps] Execution du protocole (hook Claude Code + commande /handoff)..."
    Get-CBFile -Source ".claude/hooks/context-bridge-stop.sh"  -Target ".claude/hooks/context-bridge-stop.sh"
    Get-CBFile -Source ".claude/hooks/context-bridge-stop.ps1" -Target ".claude/hooks/context-bridge-stop.ps1"
    Get-CBFile -Source ".claude/commands/handoff.md"           -Target ".claude/commands/handoff.md"

    # Sous Windows, le hook est appele via PowerShell plutot que via sh.
    $settingsJson = @'
{
  "hooks": {
    "Stop": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "powershell.exe",
            "args": [
              "-NoProfile",
              "-ExecutionPolicy", "Bypass",
              "-File", "${CLAUDE_PROJECT_DIR}/.claude/hooks/context-bridge-stop.ps1"
            ],
            "timeout": 15,
            "statusMessage": "Context Bridge : verification de la passation..."
          }
        ]
      }
    ]
  }
}
'@

    if (-not (Test-Path ".claude/settings.json")) {
        New-Item -ItemType Directory -Path ".claude" -Force | Out-Null
        $utf8 = New-Object System.Text.UTF8Encoding($false)
        [System.IO.File]::WriteAllText((Join-Path (Get-Location).Path ".claude/settings.json"), $settingsJson, $utf8)
        Write-CBInfo "  .claude/settings.json cree (hook Stop actif)"
    } elseif ((Get-Content ".claude/settings.json" -Raw) -match "context-bridge-stop") {
        Write-CBInfo "  .claude/settings.json declare deja le hook - inchange"
    } else {
        Write-CBWarn "  .claude/settings.json existe deja et n'est pas modifie."
        Write-CBWarn "  Ajoutez-y le bloc hooks.Stop suivant :"
        Write-Host $settingsJson
    }

    $step++
    Write-CBInfo "[$step/$steps] .gitignore..."
    $ignore = ".claude/.cache/`r`n.obsidian/workspace.json`r`n.obsidian/workspace-mobile.json`r`n.obsidian/plugins/*/data.json`r`n.obsidian/graph.json`r`n"
    if (Test-Path ".gitignore") {
        $current = Get-Content ".gitignore" -Raw
        if ($current -notmatch [regex]::Escape(".claude/.cache/")) {
            Write-Utf8Append -Path ".gitignore" -Text "`r`n# Context Bridge`r`n$ignore"
        } else {
            Write-CBInfo "  .gitignore deja a jour"
        }
    } else {
        Get-CBFile -Source ".gitignore" -Target ".gitignore"
    }

    Write-Host ""
    if ($Update) {
        Write-CBOk "Context Bridge mis a jour en $($script:CBVersion)."
        Write-Host ""
        Write-CBInfo "Directives, hooks et commande /handoff rafraichis. docs/ inchange."
    } else {
        Write-CBOk "Context Bridge $($script:CBVersion) installe."
        Write-Host ""
        Write-CBInfo "Cree :"
        Write-CBInfo "  AGENTS.md                          Protocole canonique"
        Write-CBInfo "  CLAUDE.md                          Claude Code (import de AGENTS.md)"
        Write-CBInfo "  .cursor/rules/                     Cursor"
        Write-CBInfo "  .windsurf/rules/                   Windsurf"
        Write-CBInfo "  .github/copilot-instructions.md    GitHub Copilot"
        Write-CBInfo "  .claude/hooks/                     Verification de passation en fin de session"
        Write-CBInfo "  .claude/commands/handoff.md        Commande /handoff"
        Write-CBInfo "  docs/                              Base de connaissances"
        Write-Host ""
        Write-CBInfo "Prochaines etapes :"
        Write-CBInfo "  1. Remplir docs/state.md et docs/roadmap.md"
        Write-CBInfo "  2. Adapter docs/CODE_MAP.md a votre architecture"
        Write-CBInfo "  3. Redemarrer Claude Code pour charger le hook"
        Write-CBInfo "  4. (Optionnel) Ouvrir docs/ dans Obsidian pour la vue graphe"
    }
    Write-Host ""
}
catch {
    Write-Host ""
    Write-Host "Installation interrompue : $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
}
finally {
    $ErrorActionPreference = $cbPrevEap
}
