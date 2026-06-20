# Verify SolidWorks MCP (Codex)

## Script

```powershell
cd C:\Users\ThinkPad\Desktop\codex
powershell -ExecutionPolicy Bypass -File ".agents\skills\solidworks-mcp\scripts\verify.ps1"
```

## Codex TUI

1. `cd C:\Users\ThinkPad\Desktop\codex`
2. `codex`
3. Type `/mcp` — confirm `solidworks` server is listed and active
4. Open SOLIDWORKS first

## Prompt tests

```text
$solidworks-mcp 连接 SolidWorks 并返回版本和已打开文档
```

```text
创建新零件，Front 平面画半径 25mm 圆，拉伸 10mm，列出特征
```

## Skills list

In Codex, type `/skills` or `$` — should show:

- `solidworks-mcp`
- `solidworks-simulation`
