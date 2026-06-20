# SolidWorks + Codex 工作区

本目录是 **OpenAI Codex CLI** 专用配置，用于通过 MCP 控制本机 SOLIDWORKS，并通过 Skill 完成仿真分析工作流。

## 启动前准备

1. 已安装 **Codex CLI**（`codex --version`）
2. 已安装 **SOLIDWORKS 2019+** 并可用许可证
3. 已安装 **Python 3.10+** 和 **Git**

## 首次安装（一次性）

在 PowerShell 中：

```powershell
cd C:\Users\ThinkPad\Desktop\codex
powershell -ExecutionPolicy Bypass -File ".agents\skills\solidworks-mcp\scripts\install.ps1"
```

安装脚本会：

- 克隆 MCP 服务到 `%USERPROFILE%\Projects\Solidworks-MCP`
- 安装 Python 依赖并打 SW2019 补丁
- 写入本项目的 `.codex\config.toml`

## 每次使用

1. **先打开 SOLIDWORKS**（避免 COM 连接失败）
2. 进入本项目并启动 Codex：

```powershell
cd C:\Users\ThinkPad\Desktop\codex
codex
```

3. 首次运行若提示 **trust project**，选择信任（否则项目级 MCP 不生效）
4. 在 Codex 中输入 `/mcp` 确认 `solidworks` 已加载

## 可用 Skill

| 调用方式 | 用途 |
|----------|------|
| `$solidworks-mcp` | 安装/配置 MCP、CAD 自动化（草图、拉伸、打开保存） |
| `$solidworks-simulation` | 静力、运动导出、疲劳 FEA（VBA 宏模板） |

也可直接描述任务，Codex 会根据 `description` 自动匹配 Skill。

## 常用提示词

**连接检查：**

```text
$solidworks-mcp 连接 SolidWorks，返回版本和当前打开的文档
```

**简单建模：**

```text
新建零件，单位 mm，Front 平面画 30mm 圆，拉伸 15mm
```

**静力分析（走仿真 Skill）：**

```text
$solidworks-simulation 对 D:\CAD\bracket.sldprt 做静力分析，底面固定，顶面 3000N 向下，材料 6061-T6
```

## 目录说明

```text
codex/
├── AGENTS.md                 # Codex 项目级指令（自动加载）
├── README.md                 # 本说明（给人看）
├── .codex/config.toml        # MCP + features 配置
└── .agents/skills/
    ├── solidworks-mcp/         # MCP 安装与 CAD
    └── solidworks-simulation/  # FEA 宏模板
```

## 故障排查

见 `.agents/skills/solidworks-mcp/troubleshoot.md`

## 与 Cursor 版本的区别

| 项目 | Cursor | Codex（本目录） |
|------|--------|-----------------|
| Skill 路径 | `~/.cursor/skills/` | `.agents/skills/` |
| MCP 配置 | `~/.cursor/mcp.json` | `.codex/config.toml` |
| 调用 Skill | `@solidworks-mcp` | `$solidworks-mcp` |
