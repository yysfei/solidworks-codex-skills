# SolidWorks MCP — Codex install (Windows)

## One command

From project root `C:\Users\ThinkPad\Desktop\codex`:

```powershell
powershell -ExecutionPolicy Bypass -File ".agents\skills\solidworks-mcp\scripts\install.ps1"
```

## Manual steps

### 1. Prerequisites

- Windows 10/11, SOLIDWORKS 2019+ (2019 verified with patches)
- Python 3.10+, Git
- Codex CLI (`codex --version`)

### 2. Clone MCP server (if install.ps1 not run)

```powershell
cd $env:USERPROFILE\Projects
git clone https://github.com/alisamsam/Solidworks-MCP.git
cd Solidworks-MCP
python -m venv .venv
.\.venv\Scripts\pip.exe install mcp pywin32 python-dotenv
```

Do **not** `pip install -r requirements.txt` — `asyncio-compat` is invalid on PyPI.

### 3. Apply SW 2019 patch

```powershell
powershell -ExecutionPolicy Bypass -File "C:\Users\ThinkPad\Desktop\codex\.agents\skills\solidworks-mcp\scripts\patch-sw2019.ps1" -RepoRoot "$env:USERPROFILE\Projects\Solidworks-MCP"
```

### 4. Codex MCP config

Project file (auto-written by install.ps1):

`C:\Users\ThinkPad\Desktop\codex\.codex\config.toml`

Or add globally: `%USERPROFILE%\.codex\config.toml`

```toml
[mcp_servers.solidworks]
command = "C:\\Users\\YOUR_USER\\Projects\\Solidworks-MCP\\.venv\\Scripts\\python.exe"
args = ["C:\\Users\\YOUR_USER\\Projects\\Solidworks-MCP\\solidworks_mcp_server.py"]
startup_timeout_sec = 30
tool_timeout_sec = 120

[mcp_servers.solidworks.env]
SOLIDWORKS_VISIBLE = "1"
```

### 5. Trust project (first time)

```powershell
cd C:\Users\ThinkPad\Desktop\codex
codex
```

Approve trust when prompted so project `.codex/config.toml` is loaded.

### 6. CLI alternative

```powershell
codex mcp add solidworks --env SOLIDWORKS_VISIBLE=1 -- C:\Users\ThinkPad\Projects\Solidworks-MCP\.venv\Scripts\python.exe C:\Users\ThinkPad\Projects\Solidworks-MCP\solidworks_mcp_server.py
```

## Verify

```powershell
powershell -ExecutionPolicy Bypass -File ".agents\skills\solidworks-mcp\scripts\verify.ps1"
```

In Codex TUI: `/mcp` → `solidworks` should appear.
