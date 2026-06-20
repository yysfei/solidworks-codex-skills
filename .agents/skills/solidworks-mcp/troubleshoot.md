# Troubleshooting

## MCP server won't start in Cursor

1. Run manually:

```powershell
& "$env:USERPROFILE\Projects\Solidworks-MCP\.venv\Scripts\python.exe" `
  "$env:USERPROFILE\Projects\Solidworks-MCP\solidworks_mcp_server.py"
```

2. Fix missing modules:

```powershell
& "$env:USERPROFILE\Projects\Solidworks-MCP\.venv\Scripts\pip.exe" install mcp pywin32 python-dotenv
```

3. Confirm paths in `%USERPROFILE%\.cursor\mcp.json` use double backslashes.

## `asyncio-compat` pip error

Upstream `requirements.txt` lists a non-existent package. Install without it:

```powershell
pip install mcp pywin32 python-dotenv
```

Re-run `install.ps1` from this skill.

## COM / connection errors

| Error | Fix |
|-------|-----|
| SolidWorks not found | Set `exe_path` in `solidworks_mcp/config.json` |
| Cannot connect | Launch SOLIDWORKS manually first; dismiss license dialogs |
| Wrong version connected | Patch adds `SldWorks.Application.27` for 2019 — re-run `patch-sw2019.ps1` |
| Access denied | Run Cursor as same Windows user that owns SW license |

## SOLIDWORKS 2019 specific

- Repo README says 2023–2025; **2019 works** after skill patches
- ProgID: `SldWorks.Application.27`
- Extrude API may need VBA fallback for complex features — use `execute_python` or record macro

## Feature tree only shows `Favorites`

Symptoms seen on SOLIDWORKS 2019 / pywin32 late-bound COM:

- `list_features` returns only `Favorites`
- `get_document_info` fails with `'int' object is not callable`
- `list_open_documents` fails with `Member not found`
- `ModelDoc2.FirstFeature()` is not exposed or reports `Member not found`
- `FeatureManager.GetFeatureTreeRootItem2()` returns only the root display node

Use `execute_python` with `scripts/list_feature_tree_execute_python.py`. The fallback confirms `ActiveDoc`, prints the path, calls `GetFeatureCount`, then enumerates features with `FeatureByPositionReverse(index)`. This recovered 213 feature names from a SW2019 part where the built-in MCP feature list only returned `Favorites`.

## Simulation / FEA

This MCP has **22 CAD tools**, not full Simulation MCP. For static/fatigue/motion FEA:

→ Use **@solidworks-simulation** skill and `scripts/*.bas` templates.

## Multiple SW versions installed

Set explicit ProgID in `solidworks_mcp/automation/base.py` connection list — put your version first.

| Year | ProgID suffix |
|------|----------------|
| 2019 | `.27` |
| 2020 | `.28` |
| 2021 | `.29` |
| 2022 | `.30` |
| 2023 | `.31` |
| 2024 | `.32` |
| 2025 | `.33` |

## Security

Keep MCP on localhost. Do not expose COM bridge to WAN.
