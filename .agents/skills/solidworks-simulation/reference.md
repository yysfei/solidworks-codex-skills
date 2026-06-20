# SolidWorks Simulation API Reference

Condensed notes for agent customization. Official docs: [Simulation API Getting Started](https://help.solidworks.com/2025/english/api/swsimulationapi/GettingStarted-swsimulationapi.html)

## Core object chain (VBA)

```vb
Dim swApp As SldWorks.SldWorks
Dim CWAddinCallBack As CosmosWorksLib.CWAddinCallBack
Dim ActDoc As CosmosWorksLib.CWModelDoc
Dim StudyMngr As CosmosWorksLib.CWStudyManager
Dim Study As CosmosWorksLib.CWStudy

Set swApp = Application.SldWorks
Set CWAddinCallBack = swApp.GetAddInObject("SldWorks.Simulation")
Set ActDoc = CWAddinCallBack.ActiveDoc          ' or OpenDoc for batch
Set StudyMngr = ActDoc.StudyManager
Set Study = StudyMngr.CreateNewStudy3(STUDY_NAME, studyType, ...)
```

## Study types (`swsStudyType_e`)

| Enum | Value | Use |
|------|-------|-----|
| `swsStaticStudy` | 0 | Linear static stress |
| `swsFrequencyStudy` | 1 | Modal / natural frequency |
| `swsBucklingStudy` | 2 | Buckling |
| `swsThermalStudy` | 3 | Steady / transient thermal |
| `swsFatigueStudy` | 5 | High-cycle fatigue |
| `swsNonlinearStudy` | 6 | Nonlinear static |
| `swsLinearDynamicStudy` | 7 | Modal time history, harmonic, etc. |
| `swsNonlinearDynamicStudy` | 14 | Nonlinear transient |

## Typical static workflow API calls

1. `StudyMngr.CreateNewStudy3` — create static study
2. `Study.Material` / `SetSolidMaterial` — assign material
3. `Study.AddFixture2` — fixed, roller, symmetry
4. `Study.AddForce2` / `AddPressure` — loads
5. `Study.CreateMesh` / mesh controls — discretize
6. `Study.RunAnalysis` — solve
7. `Study.GetResults` / plot managers — post-process

## Assembly contacts

Before mesh on assemblies:

- **Component Contact** — global bonded / no penetration / shrink fit
- **Contact Set** — local face pairs
- Friction in **Simulation** contact: set friction coefficient in contact property manager via API `CWContactSet`

For **motion friction** (Coulomb), use Motion study mates/contacts — see MotionExport template.

## Motion → Simulation export

GUI path (document in macro comments):

1. Motion study tab → define motors, gravity, 3D Contact
2. Set static/dynamic friction on mates or contact
3. Run motion analysis
4. **Simulation tab → Import Motion Loads** (or Export to Simulation from Motion toolbar)
5. Creates time-varying loads on selected components
6. Run static or dynamic FEA referencing those loads

Motion API uses `SwMotionStudy` / `IMotionStudy` — version-dependent; template uses hybrid (motion setup checklist + Simulation API for FEA).

## Fatigue study

1. Run reference static or dynamic study first
2. `CreateNewStudy3(..., swsFatigueStudy, ...)`
3. Define fatigue events linking to reference study load cases
4. Set S-N curve from material database or custom
5. `RunAnalysis` — fast; does not re-run reference mesh solve
6. Results: damage, life (cycles), fatigue FOS

## Batch mode

`StudyMngr.RunSpecifiedStudyByName` + `CWRunStudiesResults` — see `RunBatchStudies.bas`.

## Error handling

- `errCode` non-zero → check Immediate window
- Common: insufficient restraints, invalid selections, missing material, license tier mismatch
- Use `Err.Number` / `Err.Description` in VBA for COM errors

## MCP tools (when configured)

Typical tool names from community servers:

| Tool | Purpose |
|------|---------|
| `sw_apply_material` | Material assignment |
| `sw_apply_fixture` | Constraints |
| `sw_apply_force` | Point/distributed load |
| `sw_run_static_study` | Solve static |
| `sw_get_simulation_results` | Stress, displacement, FOS |
| `execute_python` | Custom COM/API in SW context |

Verify exact tool list with `ping` or server README after install.
