# SolidWorks × Codex 静态分析插件

> **首次推送**：Codex + SolidWorks MCP + 静力/疲劳仿真 Skills（Windows，SOLIDWORKS 2019+）

**GitHub（公开仓库）：** https://github.com/yysfei/solidworks-codex-skills

```powershell
git clone https://github.com/yysfei/solidworks-codex-skills.git
cd solidworks-codex-skills
powershell -ExecutionPolicy Bypass -File ".agents\skills\solidworks-mcp\scripts\install.ps1"
```

本目录 `C:\Users\ThinkPad\Desktop\codex` 是面向 **OpenAI Codex CLI** 的独立工作区，包含：

- **MCP 配置** — 让 Codex 调用本机 SOLIDWORKS（COM）
- **两个 Skill** — CAD 自动化 + 结构仿真工作流

---

## 一、环境要求

| 组件 | 要求 |
|------|------|
| 操作系统 | Windows 10/11 |
| Codex CLI | 已安装，命令行可执行 `codex` |
| SOLIDWORKS | 2019+（本机已验证 2019 / 27.4.0） |
| Python | 3.10+ |
| Git | 用于克隆 MCP 仓库 |

检查：

```powershell
codex --version
python --version
git --version
```

---

## 二、首次安装（只需一次）

### 步骤 1：进入项目目录

```powershell
cd C:\Users\ThinkPad\Desktop\codex
```

### 步骤 2：运行安装脚本

```powershell
powershell -ExecutionPolicy Bypass -File ".agents\skills\solidworks-mcp\scripts\install.ps1"
```

脚本会自动完成：

1. 克隆 [Solidworks-MCP](https://github.com/alisamsam/Solidworks-MCP) → `%USERPROFILE%\Projects\Solidworks-MCP`
2. 创建 Python 虚拟环境并安装 `mcp`、`pywin32`
3. 应用 **SOLIDWORKS 2019** 兼容补丁
4. 检测 `SLDWORKS.exe` 路径
5. 生成本项目 `.codex\config.toml`
6. 运行健康检查

### 步骤 3：验证安装

```powershell
powershell -ExecutionPolicy Bypass -File ".agents\skills\solidworks-mcp\scripts\verify.ps1"
```

期望输出全部为 `[OK]`（COM 连接需 SOLIDWORKS 已打开）。

---

## 三、日常使用流程

### 1. 启动 SOLIDWORKS

**必须先打开 SOLIDWORKS**，再启动 Codex，否则 MCP 无法连接 COM。

### 2. 启动 Codex（在本项目目录）

```powershell
cd C:\Users\ThinkPad\Desktop\codex
codex
```

### 3. 信任项目（首次）

若 Codex 询问是否信任此项目，选择 **信任**。只有受信任项目才会加载 `.codex/config.toml` 中的 MCP 配置。

### 4. 检查 MCP 是否加载

在 Codex 交互界面（TUI）输入：

```text
/mcp
```

应看到 **`solidworks`** 服务器。若无，退出 Codex 后重新运行 `install.ps1`，并确认 `.codex\config.toml` 存在。

### 5. 检查 Skill 是否可用

```text
/skills
```

或输入 `$` 查看技能列表，应包含：

- `solidworks-mcp`
- `solidworks-simulation`

---

## 四、Skill 调用方式

Codex 有两种触发 Skill 的方式：

### 显式调用（推荐）

在提示词前加 `$技能名`：

```text
$solidworks-mcp 连接 SolidWorks 并返回版本信息
```

```text
$solidworks-simulation 帮我填写 StaticStudy.bas 的 CONFIG 并说明如何运行宏
```

### 隐式调用

直接描述任务，Codex 根据 Skill 的 `description` 自动选择，例如：

```text
在 SolidWorks 里新建零件，画一个 50mm 的圆并拉伸 20mm
```

---

## 五、典型使用场景

### 场景 A：检查 MCP 连接

```text
$solidworks-mcp 使用 solidworks MCP 连接 SolidWorks，返回版本号和已打开的文件列表
```

### 场景 B：CAD 建模

```text
新建零件，单位毫米，在 Front 平面绘制圆心 (0,0) 半径 30mm 的圆，向两侧拉伸 15mm，然后列出所有特征
```

### 场景 C：打开已有模型

```text
打开 D:\CAD\bracket.sldprt 并列出特征树
```

### 场景 D：静力有限元分析

MCP **不包含**完整 Simulation 工具链，请用仿真 Skill + VBA 宏：

```text
$solidworks-simulation
模型：D:\CAD\bracket.sldprt
材料：6061-T6
约束：底面 MountFace 完全固定
载荷：LoadFace 上 3000N，方向 -Z
请根据 scripts/StaticStudy.bas 填写 CONFIG 并说明在 SOLIDWORKS VBA 中如何运行
```

### 场景 E：装配体运动 + 摩擦 + 结构分析

```text
$solidworks-simulation
装配体 slider_asm.sldasm，Motion 仿真 5 秒，摩擦系数静 0.3 动 0.25，
导出载荷后做结构分析，按 MotionExportToSimulation.bas 流程给出步骤
```

### 场景 F：疲劳寿命

```text
$solidworks-simulation
轴零件已完成静力算例 Static-Peak，需要 10^6 次全反转疲劳分析，
使用 FatigueStudy.bas 模板说明 CONFIG 参数
```

---

## 六、目录结构

```text
C:\Users\ThinkPad\Desktop\codex\
│
├── README.md                          ← 本手册
├── AGENTS.md                          ← Codex 自动加载的项目指令
│
├── .codex\
│   └── config.toml                    ← MCP 服务器配置（install.ps1 生成）
│
└── .agents\skills\
    ├── solidworks-mcp\                ← MCP 安装 / CAD 自动化
    │   ├── SKILL.md
    │   ├── agents\openai.yaml
    │   ├── install-windows.md
    │   ├── verify.md
    │   ├── troubleshoot.md
    │   ├── reference.md
    │   └── scripts\
    │       ├── install.ps1            ← 一键安装
    │       ├── verify.ps1             ← 健康检查
    │       └── patch-sw2019.ps1       ← SW2019 补丁
    │
    └── solidworks-simulation\         ← FEA 仿真宏模板
        ├── SKILL.md
        ├── reference.md
        ├── examples.md
        └── scripts\
            ├── StaticStudy.bas
            ├── MotionExportToSimulation.bas
            ├── FatigueStudy.bas
            └── RunBatchStudies.bas
```

---

## 七、配置文件说明

### 项目级：`.codex/config.toml`

由 `install.ps1` 写入，核心内容：

```toml
[features]
skills = true

[mcp_servers.solidworks]
command = "...\\Projects\\Solidworks-MCP\\.venv\\Scripts\\python.exe"
args = ["...\\Projects\\Solidworks-MCP\\solidworks_mcp_server.py"]
startup_timeout_sec = 30
tool_timeout_sec = 120
default_tools_approval_mode = "auto"

[mcp_servers.solidworks.env]
SOLIDWORKS_VISIBLE = "1"
```

### 全局级（可选）

也可合并到 `%USERPROFILE%\.codex\config.toml`，则任意目录启动 Codex 都能用 SolidWorks MCP。本项目推荐**项目级配置**，便于迁移整个 `codex` 文件夹。

### 用 CLI 添加 MCP（替代手写 toml）

```powershell
codex mcp add solidworks --env SOLIDWORKS_VISIBLE=1 -- ^
  C:\Users\ThinkPad\Projects\Solidworks-MCP\.venv\Scripts\python.exe ^
  C:\Users\ThinkPad\Projects\Solidworks-MCP\solidworks_mcp_server.py
```

管理命令：

```powershell
codex mcp list
codex mcp remove solidworks
codex mcp --help
```

---

## 八、Codex 常用命令

| 命令 | 作用 |
|------|------|
| `codex` | 在本目录启动交互会话 |
| `codex -C C:\Users\ThinkPad\Desktop\codex "你的任务"` | 指定工作目录单次执行 |
| `codex --full-auto "任务"` | 自动批准工具（慎用） |
| `/mcp` | TUI 内查看 MCP 服务器 |
| `/skills` | TUI 内查看 Skill 列表 |
| `$solidworks-mcp` | 显式调用 Skill |

### 审批与安全

默认 Codex 对工具调用有审批策略。SolidWorks MCP 会操作真实 CAD 软件，建议：

- 首次使用保持默认审批，确认每一步
- 熟悉后可对 `solidworks` MCP 设置 `default_tools_approval_mode = "auto"`（已在项目 config 中配置）

---

## 九、迁移到新账户 / 新电脑

1. 复制整个文件夹：

   ```text
   C:\Users\ThinkPad\Desktop\codex\
   ```

2. 在新机器安装：Codex、Python、Git、SOLIDWORKS

3. 运行：

   ```powershell
   cd <新路径>\codex
   powershell -ExecutionPolicy Bypass -File ".agents\skills\solidworks-mcp\scripts\install.ps1"
   ```

4. `cd` 到项目目录，启动 `codex`，信任项目

无需复制 Cursor 的 `.cursor\skills` 或 `mcp.json`。

---

## 十、故障排查

| 现象 | 处理 |
|------|------|
| `/mcp` 无 solidworks | 重新运行 `install.ps1`；确认项目已信任 |
| COM 连接失败 | 先手动打开 SOLIDWORKS；关闭许可证弹窗 |
| pip 报 asyncio-compat | 只用 `install.ps1`，不要 `pip install -r requirements.txt` |
| Skill 未出现 | 确认在 `codex` 目录启动；输入 `/skills` 刷新 |
| 拉伸等复杂特征失败 | SW2019 API 差异，用 `execute_python` 或录宏 |
| 要做 FEA 仿真 | 用 `$solidworks-simulation`，不是 MCP |

详细说明：`.agents\skills\solidworks-mcp\troubleshoot.md`

---

## 十一、与 Cursor 版本对照

| 项目 | Cursor | Codex（本目录） |
|------|--------|-----------------|
| Skill 位置 | `%USERPROFILE%\.cursor\skills\` | `Desktop\codex\.agents\skills\` |
| MCP 配置 | `%USERPROFILE%\.cursor\mcp.json` | `Desktop\codex\.codex\config.toml` |
| 调用 Skill | `@solidworks-mcp` | `$solidworks-mcp` |
| 项目指令 | `.cursor/rules` | `AGENTS.md` |

---

## 十二、快速参考卡片

```powershell
# 安装
cd C:\Users\ThinkPad\Desktop\codex
powershell -ExecutionPolicy Bypass -File ".agents\skills\solidworks-mcp\scripts\install.ps1"

# 验证
powershell -ExecutionPolicy Bypass -File ".agents\skills\solidworks-mcp\scripts\verify.ps1"

# 使用
# 1. 打开 SOLIDWORKS
# 2. cd C:\Users\ThinkPad\Desktop\codex
# 3. codex
# 4. $solidworks-mcp 连接 SolidWorks
```
