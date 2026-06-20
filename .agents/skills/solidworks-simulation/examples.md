# Example Prompts

## Static — single part

```
Model: D:\CAD\bracket.sldprt
Material: 6061-T6
Fixture: face "MountFace" fully fixed
Load: 2500 N, direction -Y, on face "LoadFace"
Mesh: 3 mm default, 1 mm on fillet edges
Criterion: max von Mises < 276/1.5 MPa
Use StaticStudy.bas template, fill CONFIG, run, report stress and displacement.
```

## Assembly static with contact

```
Assembly: D:\CAD\clamp_asm.sldasm
Contact: no penetration between jaw faces, bonded elsewhere
Material: components keep assigned materials
Fix base plate bottom; apply 500 N closing force on handle
Run static study; report max stress and min FOS.
```

## Motion + friction → structure

```
Assembly: D:\CAD\slider_asm.sldasm
Motion: 5 s, gravity on, prismatic mate friction mu_s=0.3 mu_d=0.25
Motor: 120 RPM on drive shaft
Export motion loads to Simulation for slider block
Run static FEA at peak load frame; report peak stress.
Follow MotionExportToSimulation.bas checklist.
```

## Fatigue life

```
Part: D:\CAD\shaft.sldprt
Reference study: "Static-Peak" (already solved)
Fatigue: 1e6 cycles, fully reversed (R=-1), AISI 4340 S-N curve
Alternating stress from static study load case 1
Report minimum life (cycles) and locations with damage > 0.5.
Use FatigueStudy.bas template.
```

## MCP natural language (after setup)

```
Connect to SolidWorks. Open D:\CAD\bracket.sldprt.
Set material to Structural Steel, fix the largest bottom face,
apply 3000 N force in -Z on the top boss face,
mesh and run static analysis.
Return max von Mises (MPa), max displacement (mm), and minimum factor of safety.
```

## Batch parametric

```
Vary force 1000–5000 N step 500 N on bracket.sldprt static study.
Use RunBatchStudies.bas; export CSV with Force, MaxStress, MaxDisp, MinFOS.
```
