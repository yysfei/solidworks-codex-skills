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

## Listing a feature tree

Preferred path:

1. `connect_solidworks`
2. `open_document` with the full `.SLDPRT` / `.SLDASM` path
3. `list_features`

If the built-in tool returns only `Favorites`, or `get_document_info` / `list_open_documents` fails with COM wrapper errors such as `'int' object is not callable` or `Member not found`, use `execute_python` with:

```text
scripts/list_feature_tree_execute_python.py
```

This fallback uses `ModelDoc2.GetFeatureCount` plus `FeatureByPositionReverse(index)`. It reads the same model even when `FirstFeature` is unavailable through SW2019 late-bound pywin32 COM. The order is reverse position order, commonly from the end/bottom of the feature tree back toward root items.

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
