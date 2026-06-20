# Apply SOLIDWORKS 2019 compatibility patches to alisamsam/Solidworks-MCP
param(
    [Parameter(Mandatory = $true)]
    [string]$RepoRoot
)

$ErrorActionPreference = "Stop"

$basePy = Join-Path $RepoRoot "solidworks_mcp\automation\base.py"
$finderPy = Join-Path $RepoRoot "solidworks_mcp\utils\sw_finder.py"
$reqTxt = Join-Path $RepoRoot "requirements.txt"

# --- requirements.txt: remove asyncio-compat ---
if (Test-Path $reqTxt) {
    $req = Get-Content $reqTxt -Raw
    if ($req -match 'asyncio-compat') {
        $req = $req -replace '(?m)^asyncio-compat.*\r?\n', ''
        Set-Content -Path $reqTxt -Value $req.TrimEnd() -Encoding UTF8
        Write-Host "Patched: requirements.txt (removed asyncio-compat)"
    }
}

# --- sw_finder.py: add 2019-2021 template paths ---
if (Test-Path $finderPy) {
    $finder = Get-Content $finderPy -Raw
    if ($finder -notmatch 'SOLIDWORKS 2019') {
        $finder = $finder -replace (
            'r"C:\\ProgramData\\SolidWorks\\SOLIDWORKS 2022\\templates",',
            @'
r"C:\ProgramData\SolidWorks\SOLIDWORKS 2022\templates",
        r"C:\ProgramData\SolidWorks\SOLIDWORKS 2021\templates",
        r"C:\ProgramData\SolidWorks\SOLIDWORKS 2020\templates",
        r"C:\ProgramData\SolidWorks\SOLIDWORKS 2019\templates",
'@
        )
        Set-Content -Path $finderPy -Value $finder -Encoding UTF8
        Write-Host "Patched: sw_finder.py (2019 template paths)"
    }
}

# --- base.py: versioned ProgIDs ---
if (Test-Path $basePy) {
    $base = Get-Content $basePy -Raw
    if ($base -notmatch 'Application\.27') {
        $old = @'
        methods = [
            # Method 1: GetObject (running instance)
            lambda: win32com.client.GetObject(Class="SldWorks.Application"),
            # Method 2: Dispatch (creates or gets existing)
            lambda: win32com.client.Dispatch("SldWorks.Application"),
            # Method 3: Dynamic Dispatch
            lambda: win32com.client.dynamic.Dispatch("SldWorks.Application"),
            # Method 4: GetActiveObject
            lambda: win32com.client.GetActiveObject("SldWorks.Application"),
        ]
'@
        $new = @'
        # Versioned ProgIDs help when multiple SW versions are registered (2019 = .27)
        prog_ids = [
            "SldWorks.Application",
            "SldWorks.Application.27",  # SOLIDWORKS 2019
            "SldWorks.Application.28",  # 2020
            "SldWorks.Application.29",  # 2021
        ]
        methods = []
        for prog_id in prog_ids:
            methods.extend([
                lambda pid=prog_id: win32com.client.GetObject(Class=pid),
                lambda pid=prog_id: win32com.client.Dispatch(pid),
                lambda pid=prog_id: win32com.client.dynamic.Dispatch(pid),
                lambda pid=prog_id: win32com.client.GetActiveObject(pid),
            ])
'@
        if ($base -match [regex]::Escape($old.Trim())) {
            $base = $base.Replace($old, $new)
            Set-Content -Path $basePy -Value $base -Encoding UTF8
            Write-Host "Patched: base.py (ProgID .27 for 2019)"
        } else {
            Write-Host "Skip base.py: pattern not found (may already be patched or upstream changed)"
        }
    }
}

Write-Host "patch-sw2019.ps1 done"
