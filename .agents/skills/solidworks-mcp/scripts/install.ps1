# Install SolidWorks MCP for OpenAI Codex (Windows)
param(
    [string]$InstallRoot = "$env:USERPROFILE\Projects\Solidworks-MCP",
    [string]$CodexProjectRoot = ""
)

$ErrorActionPreference = "Stop"
if (-not $CodexProjectRoot) {
    # scripts/ -> solidworks-mcp/ -> skills/ -> .agents/ -> project root
    $CodexProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..\..\..")).Path
}
$SkillRoot = Split-Path -Parent $PSScriptRoot
$RepoUrl = "https://github.com/alisamsam/Solidworks-MCP.git"
$VenvPy = Join-Path $InstallRoot ".venv\Scripts\python.exe"
$VenvPip = Join-Path $InstallRoot ".venv\Scripts\pip.exe"
$Server = Join-Path $InstallRoot "solidworks_mcp_server.py"
$ProjectConfig = Join-Path $CodexProjectRoot ".codex\config.toml"

function Write-Step($msg) { Write-Host "[solidworks-mcp] $msg" -ForegroundColor Cyan }

# --- 1. Clone ---
if (-not (Test-Path $InstallRoot)) {
    Write-Step "Cloning Solidworks-MCP to $InstallRoot"
    New-Item -ItemType Directory -Force -Path (Split-Path $InstallRoot) | Out-Null
    git clone $RepoUrl $InstallRoot
} else {
    Write-Step "Repo exists: $InstallRoot"
}

# --- 2. Venv + deps ---
if (-not (Test-Path $VenvPy)) {
    Write-Step "Creating virtual environment"
    python -m venv (Join-Path $InstallRoot ".venv")
}
Write-Step "Installing Python packages"
& $VenvPy -m pip install --upgrade pip --quiet
& $VenvPip install "mcp>=1.0.0" "python-dotenv>=1.0.0" "pywin32>=306" --quiet

# --- 3. Patches ---
$PatchScript = Join-Path $SkillRoot "scripts\patch-sw2019.ps1"
if (Test-Path $PatchScript) {
    Write-Step "Applying SOLIDWORKS 2019 patches"
    & $PatchScript -RepoRoot $InstallRoot
}

# --- 4. SW config.json ---
Write-Step "Detecting SOLIDWORKS"
$detectScript = @"
import json, os, sys
sys.path.insert(0, r'$InstallRoot')
from solidworks_mcp.utils.sw_finder import get_solidworks_info
info = get_solidworks_info()
cfg_path = os.path.join(r'$InstallRoot', 'solidworks_mcp', 'config.json')
with open(cfg_path, 'r', encoding='utf-8') as f:
    cfg = json.load(f)
if info.get('exe_path'):
    cfg['exe_path'] = info['exe_path'].replace('/', '\\')
if info.get('templates', {}).get('part'):
    cfg['part_template'] = info['templates']['part'].replace('/', '\\')
with open(cfg_path, 'w', encoding='utf-8') as f:
    json.dump(cfg, f, indent=2)
    f.write('\n')
print(json.dumps(info, indent=2))
"@
$prevEap = $ErrorActionPreference
$ErrorActionPreference = "Continue"
$detectOut = & $VenvPy -c $detectScript 2>&1 | Out-String
$ErrorActionPreference = $prevEap
Write-Host $detectOut

# --- 5. Write .codex/config.toml ---
Write-Step "Writing Codex config: $ProjectConfig"
New-Item -ItemType Directory -Force -Path (Split-Path $ProjectConfig) | Out-Null

$pyToml = $VenvPy.Replace('\', '\\')
$serverToml = $Server.Replace('\', '\\')

$toml = @"
# SolidWorks MCP — project-scoped (Codex merges with ~/.codex/config.toml)
# Regenerate: .agents/skills/solidworks-mcp/scripts/install.ps1

[features]
skills = true

[mcp_servers.solidworks]
command = "$pyToml"
args = ["$serverToml"]
startup_timeout_sec = 30
tool_timeout_sec = 120
default_tools_approval_mode = "auto"

[mcp_servers.solidworks.env]
SOLIDWORKS_VISIBLE = "1"
"@

Set-Content -Path $ProjectConfig -Value $toml.TrimEnd() -Encoding UTF8

# --- 6. Verify ---
$VerifyScript = Join-Path $SkillRoot "scripts\verify.ps1"
if (Test-Path $VerifyScript) {
    Write-Step "Running verification"
    & $VerifyScript -InstallRoot $InstallRoot -CodexProjectRoot $CodexProjectRoot
}

Write-Host ""
Write-Host "=== Codex SolidWorks MCP install complete ===" -ForegroundColor Green
Write-Host "Project: $CodexProjectRoot"
Write-Host "Config:  $ProjectConfig"
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. cd $CodexProjectRoot"
Write-Host "  2. codex"
Write-Host "  3. In TUI: /mcp  (confirm solidworks is listed)"
Write-Host "  4. Open SOLIDWORKS, then run skill: solidworks-mcp connect test"
