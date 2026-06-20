# Reference

## Architecture

```text
Cursor / Codex
    │  MCP (stdio)
    ▼
solidworks_mcp_server.py
    │  pywin32 COM
    ▼
SldWorks.Application[.27]
    ▼
SOLIDWORKS.exe (local)
```

## MCP tools (22)

| Category | Tools |
|----------|-------|
| Connection | `connect_solidworks`, `get_solidworks_info` |
| Documents | `create_new_part`, `create_new_assembly`, `open_document`, `close_document`, `save_document`, `list_open_documents` |
| Sketches | `create_sketch`, `close_sketch`, `draw_circle`, `draw_rectangle`, `draw_line`, `draw_arc`, `draw_polygon` |
| Features | `extrude_sketch`, `cut_extrude`, `fillet_edges`, `chamfer_edges`, `list_features` |
| Utilities | `set_units`, `execute_python` |

## SOLIDWORKS 2019 patches

Applied by `scripts/patch-sw2019.ps1`:

### 1. `solidworks_mcp/automation/base.py`

Add versioned ProgIDs before generic `SldWorks.Application`:

```python
prog_ids = [
    "SldWorks.Application",
    "SldWorks.Application.27",  # 2019
    ...
]
```

### 2. `solidworks_mcp/utils/sw_finder.py`

Add to `PROGRAMDATA_TEMPLATE_PATHS`:

```python
r"C:\ProgramData\SolidWorks\SOLIDWORKS 2019\templates",
```

### 3. `solidworks_mcp/config.json`

```json
{
  "exe_path": "D:\\Program Files\\SOLIDWORKS Corp\\SOLIDWORKS\\SLDWORKS.exe"
}
```

Use auto-detect via `get_solidworks_info()` or installer.

### 4. `requirements.txt`

Remove `asyncio-compat>=0.1.0` (not on PyPI).

## Config keys (`solidworks_mcp/config.json`)

| Key | Description |
|-----|-------------|
| `exe_path` | `SLDWORKS.exe` path or `"auto"` |
| `part_template` | `.prtdot` path or `"auto"` |
| `default_unit` | `mm`, `inch`, `cm`, `m`, `ft` |
| `startup_timeout` | Seconds to wait for SW launch |

## Upstream repo

https://github.com/alisamsam/Solidworks-MCP

## Companion skill

**solidworks-simulation** — Simulation API macros for static, motion export, fatigue.
