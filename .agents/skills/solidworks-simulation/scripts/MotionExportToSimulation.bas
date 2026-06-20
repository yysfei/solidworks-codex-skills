Attribute VB_Name = "MotionExportToSimulation"
' SOLIDWORKS Motion → Simulation load export workflow template
' Skill: solidworks-simulation
'
' Hybrid template: Motion setup checklist + Simulation API hooks.
' Motion COM API varies by SW version; complete motion setup in GUI first,
' then automate Simulation import and FEA via API.

Option Explicit

' ===================== CONFIG =====================
Private Const ASSEMBLY_PATH As String = "C:\CAD\slider_asm.sldasm"
Private Const MOTION_STUDY_NAME As String = "MotionStudy1"
Private Const SIM_STATIC_STUDY As String = "Static_FromMotion"
Private Const DURATION_SEC As Double = 5#
Private Const STATIC_FRICTION As Double = 0.3
Private Const DYNAMIC_FRICTION As Double = 0.25
Private Const PART_FOR_FEA As String = "slider-1"   ' component name in tree
' ================================================

Public Sub RunMotionToFEAWorkflow()
    Dim swApp As SldWorks.SldWorks
    Dim errCode As Long

    Set swApp = Application.SldWorks
    If swApp.ActiveDoc Is Nothing Then
        swApp.OpenDoc6 ASSEMBLY_PATH, swDocumentTypes_e.swDocASSEMBLY, swOpenDocOptions_Silent, "", errCode, errCode
    End If

    Debug.Print "=== Motion + Friction + FEA Workflow ==="
    Debug.Print ""
    Debug.Print "STEP 1 — Motion study setup (GUI or Motion API)"
    Debug.Print "  [ ] Open Motion Study tab: " & MOTION_STUDY_NAME
    Debug.Print "  [ ] Enable Gravity"
    Debug.Print "  [ ] Add motors / springs / dampers per load case"
    Debug.Print "  [ ] Mates/Contacts: set friction"
    Debug.Print "      Static coeff  = " & STATIC_FRICTION
    Debug.Print "      Dynamic coeff = " & DYNAMIC_FRICTION
    Debug.Print "  [ ] Run motion analysis for " & DURATION_SEC & " s"
    Debug.Print ""
    Debug.Print "STEP 2 — Export motion loads to Simulation"
    Debug.Print "  GUI: Motion toolbar > Export to Simulation (or Simulation > Import Motion Loads)"
    Debug.Print "  Select components: " & PART_FOR_FEA
    Debug.Print ""
    Debug.Print "STEP 3 — Structural study (API below)"

    Call CreateStaticStudyFromMotionLoads swApp
End Sub

Private Sub CreateStaticStudyFromMotionLoads(swApp As SldWorks.SldWorks)
    Dim CWAddinCallBack As CosmosWorksLib.CWAddinCallBack
    Dim ActDoc As CosmosWorksLib.CWModelDoc
    Dim StudyMngr As CosmosWorksLib.CWStudyManager
    Dim Study As CosmosWorksLib.CWStudy
    Dim errCode As Long

    Set CWAddinCallBack = swApp.GetAddInObject("SldWorks.Simulation")
    If CWAddinCallBack Is Nothing Then Exit Sub

    Set ActDoc = CWAddinCallBack.ActiveDoc
    Set StudyMngr = ActDoc.StudyManager

    ' After motion loads imported, time-varying loads appear in Simulation tree
    Set Study = StudyMngr.CreateNewStudy3(SIM_STATIC_STUDY, swsStaticStudy, errCode)
    If Study Is Nothing Then Exit Sub

    ' Link imported motion load curves (GUI-verified once; record macro for load case IDs)
    Debug.Print "  [ ] Verify imported motion loads on " & PART_FOR_FEA
    Debug.Print "  [ ] Peak load case OR full transient dynamic study (Premium)"

    errCode = Study.CreateMesh(0, 0.003, 1.5)
    errCode = Study.RunAnalysis

    Debug.Print "STEP 4 — Post-process peak stress at critical time step"
    Debug.Print "  For full dynamic: use swsLinearDynamicStudy (Premium) with modal time history"
    Call WriteMotionFEAReport
End Sub

Private Sub WriteMotionFEAReport()
    Dim p As String
    p = Environ$("TEMP") & "\sw_motion_fea_report.txt"
    Open p For Output As #1
    Print #1, "assembly=" & ASSEMBLY_PATH
    Print #1, "motion_study=" & MOTION_STUDY_NAME
    Print #1, "friction_static=" & STATIC_FRICTION
    Print #1, "friction_dynamic=" & DYNAMIC_FRICTION
    Print #1, "fea_study=" & SIM_STATIC_STUDY
    Print #1, "peak_von_mises_mpa=TODO"
    Print #1, "peak_displacement_mm=TODO"
    Close #1
    Debug.Print "Report stub: " & p
End Sub

' --- Friction reference (Motion Mate PropertyManager) ---
' Coulomb model parameters:
'   Static Friction Coefficient  — force to start sliding
'   Dynamic Friction Coefficient — sliding resistance
'   Dynamic Friction Velocity — transition smoothness
' Set on mate Analysis tab or Contact PropertyManager for 3D Contact.
