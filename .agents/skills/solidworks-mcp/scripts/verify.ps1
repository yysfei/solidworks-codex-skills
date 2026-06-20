# Verify SolidWorks MCP for Codex
param(
    [string]$InstallRoot = "$env:USERPROFILE\Projects\Solidworks-MCP",
    [string]$CodexProjectRoot = ""
)

$ErrorActionPreference = "Continue"
if (-not $CodexProjectRoot) {
    $CodexProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..\..\..")).Path
}

$VenvPy = Join-Path $InstallRoot ".venv\Scripts\python.exe"
$Server = Join-Path $InstallRoot "solidworks_mcp_server.py"
$ProjectConfig = Join-Path $CodexProjectRoot ".codex\config.toml"
$fail = 0

function Check($name, $cond) {
    if ($cond) { Write-Host "[OK] $name" -ForegroundColor Green }
    else { Write-Host "[FAIL] $name" -ForegroundColor Red; $script:fail++ }
}

Check "MCP repo" (Test-Path $InstallRoot)
Check "venv python" (Test-Path $VenvPy)
Check "MCP server" (Test-Path $Server)
Check "Codex .codex/config.toml" (Test-Path $ProjectConfig)

if (Test-Path $ProjectConfig) {
    $cfg = Get-Content $ProjectConfig -Raw
    Check "config has mcp_servers.solidworks" ($cfg -match 'mcp_servers\.solidworks')
}

if (Test-Path $VenvPy) {
    $importTest = & $VenvPy -c "import mcp; import win32com.client; print('ok')" 2>&1
    Check "Python imports" ($importTest -match 'ok')

    $detectScript = @"
import json, sys
sys.path.insert(0, r'$InstallRoot')
from solidworks_mcp.utils.sw_finder import get_solidworks_info
print(json.dumps(get_solidworks_info()))
"@
    $infoJson = & $VenvPy -c $detectScript 2>&1 | Out-String
    Check "SOLIDWORKS detected" ($infoJson -match '"found": true')

    $connScript = @"
import json, sys
sys.path.insert(0, r'$InstallRoot')
from solidworks_mcp.automation.base import SolidWorksAutomation
print(json.dumps(SolidWorksAutomation().connect()))
"@
    $connJson = & $VenvPy -c $connScript 2>&1 | Out-String
    if ($connJson -match '"success": true') {
        Write-Host "[OK] COM connection" -ForegroundColor Green
    } else {
        Write-Host "[WARN] COM failed — start SOLIDWORKS and re-run" -ForegroundColor Yellow
    }
}

if ($fail -gt 0) { exit 1 }
Write-Host "`nAll checks passed." -ForegroundColor Green
