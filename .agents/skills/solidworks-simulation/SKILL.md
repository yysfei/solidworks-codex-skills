---
name: solidworks-simulation
description: >-
  Drive SOLIDWORKS Simulation for static FEA, assembly motion-to-FEA export,
  friction, fatigue, and life analysis via Simulation API VBA macros on
  Windows. Use with Codex when analyzing SolidWorks parts, static stress,
  assembly dynamics, motion export, friction, fatigue, S-N curve, or
  $solidworks-simulation.
---

# SolidWorks Simulation — Codex

Automate SOLIDWORKS structural simulation. Use with **$solidworks-mcp** for CAD; this skill for FEA.

## License map

| Analysis | Minimum tier |
|----------|--------------|
| Static linear | Simulation Standard |
| Motion + friction | Premium or Sim Pro |
| Fatigue / life | Simulation Standard |
| Linear dynamics | Simulation Premium |

## Workflow

```
Goal?
├─ Static stress          → scripts/StaticStudy.bas
├─ Motion + friction → FEA → scripts/MotionExportToSimulation.bas
├─ Fatigue / life         → scripts/FatigueStudy.bas
├─ Batch / parametric     → scripts/RunBatchStudies.bas
└─ CAD prep               → $solidworks-mcp
```

## Agent checklist

```
- [ ] Model path (.sldprt / .sldasm)
- [ ] Simulation add-in enabled
- [ ] Material, fixtures, loads, contacts documented
- [ ] Edit CONFIG block in matching .bas template
- [ ] Run macro in SOLIDWORKS VBA (Tools → Macro → Run)
- [ ] Report max stress, displacement, FOS / life
```

## Templates

| File | Purpose |
|------|---------|
| `scripts/StaticStudy.bas` | Linear static FEA |
| `scripts/MotionExportToSimulation.bas` | Motion friction → export loads → FEA |
| `scripts/FatigueStudy.bas` | High-cycle fatigue |
| `scripts/RunBatchStudies.bas` | Batch studies |

Edit the `CONFIG` block at top of each file, paste into SOLIDWORKS VBA, run.

## Invoke in Codex

```text
$solidworks-simulation 对 bracket.sldprt 做静力分析，载荷 3000N，材料 6061-T6
```

## Output format

```markdown
## Simulation summary — [model]

| Metric | Value | Limit | Pass? |
|--------|-------|-------|-------|
| Max von Mises (MPa) | … | … | … |
| Max displacement (mm) | … | … | … |
| Min FOS | … | ≥1.5 | … |
| Fatigue life (cycles) | … | … | … |
```

## References

- [reference.md](reference.md) — Simulation API
- [examples.md](examples.md) — prompt templates
