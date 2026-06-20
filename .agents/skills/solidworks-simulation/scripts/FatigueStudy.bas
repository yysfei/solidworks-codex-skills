Attribute VB_Name = "FatigueStudy"
' SOLIDWORKS Simulation API — Fatigue (high-cycle) study template
' Skill: solidworks-simulation
'
' Requires a completed reference study (static or dynamic) before running fatigue.

Option Explicit

' ===================== CONFIG =====================
Private Const MODEL_PATH As String = "C:\CAD\shaft.sldprt"
Private Const REFERENCE_STUDY As String = "Static-Peak"    ' must exist & be solved
Private Const FATIGUE_STUDY_NAME As String = "Fatigue_Life"
Private Const CYCLES As Double = 1000000#                  ' 1e6
Private Const STRESS_RATIO_R As Double = -1#               ' fully reversed
Private Const SN_MATERIAL As String = "AISI 4340"          ' S-N curve source
Private Const LOAD_CASE_INDEX As Long = 1                  ' from reference study
' ================================================

Public Sub RunFatigueStudy()
    Dim swApp As SldWorks.SldWorks
    Dim CWAddinCallBack As CosmosWorksLib.CWAddinCallBack
    Dim ActDoc As CosmosWorksLib.CWModelDoc
    Dim StudyMngr As CosmosWorksLib.CWStudyManager
    Dim FatigueStudy As CosmosWorksLib.CWStudy
    Dim errCode As Long

    Set swApp = Application.SldWorks
    If swApp.ActiveDoc Is Nothing Then
        swApp.OpenDoc6 MODEL_PATH, swDocumentTypes_e.swDocPART, swOpenDocOptions_Silent, "", errCode, errCode
    End If

    Set CWAddinCallBack = swApp.GetAddInObject("SldWorks.Simulation")
    Set ActDoc = CWAddinCallBack.ActiveDoc
    Set StudyMngr = ActDoc.StudyManager

    ' Verify reference study exists
    If Not StudyExists(StudyMngr, REFERENCE_STUDY) Then
        Debug.Print "ERROR: Run reference study '" & REFERENCE_STUDY & "' first."
        Exit Sub
    End If

    ' Create fatigue study (swsFatigueStudy = 5)
    Set FatigueStudy = StudyMngr.CreateNewStudy3(FATIGUE_STUDY_NAME, swsFatigueStudy, errCode)
    If FatigueStudy Is Nothing Then
        Debug.Print "CreateNewStudy3 fatigue failed, err=" & errCode
        Exit Sub
    End If

    Debug.Print "Configure fatigue event in Study Properties:"
    Debug.Print "  Event type: Constant Amplitude"
    Debug.Print "  Reference study: " & REFERENCE_STUDY
    Debug.Print "  Load case: " & LOAD_CASE_INDEX
    Debug.Print "  Cycles: " & Format$(CYCLES, "0")
    Debug.Print "  Stress ratio R: " & STRESS_RATIO_R
    Debug.Print "  S-N curve material: " & SN_MATERIAL
    Debug.Print "  Mean stress correction: Goodman (default) or Gerber"

    ' Fatigue event linking is version-specific (CWFatigueStudy / event manager)
    ' Record macro once in GUI: Simulation > Fatigue > Add Event > link reference study
    ' Then paste recorded calls into LinkFatigueEvent below

    Call LinkFatigueEvent(FatigueStudy)

    errCode = FatigueStudy.RunAnalysis
    If errCode <> 0 Then
        Debug.Print "Fatigue RunAnalysis failed, err=" & errCode
        Exit Sub
    End If

    Call ExtractFatigueResults
    Debug.Print "Fatigue study complete."
End Sub

Private Function StudyExists(StudyMngr As CosmosWorksLib.CWStudyManager, studyName As String) As Boolean
    On Error Resume Next
    Dim s As CosmosWorksLib.CWStudy
    Set s = StudyMngr.GetStudy(studyName)
    StudyExists = Not (s Is Nothing)
    On Error GoTo 0
End Function

Private Sub LinkFatigueEvent(FatigueStudy As CosmosWorksLib.CWStudy)
    ' TODO: Paste GUI-recorded fatigue event API calls here
    ' Links REFERENCE_STUDY load case to constant-amplitude event with CYCLES and R
    Debug.Print "LinkFatigueEvent: complete via recorded macro or CWFatigueStudy API"
End Sub

Private Sub ExtractFatigueResults()
    Dim p As String
    p = Environ$("TEMP") & "\sw_fatigue_results.txt"
    Open p For Output As #1
    Print #1, "fatigue_study=" & FATIGUE_STUDY_NAME
    Print #1, "reference_study=" & REFERENCE_STUDY
    Print #1, "cycles_required=" & CYCLES
    Print #1, "min_life_cycles=TODO"          ' from Life plot
    Print #1, "max_damage=TODO"               ' from Damage plot (0-1)
    Print #1, "min_fatigue_fos=TODO"          ' from Fatigue FOS plot
    Print #1, "critical_location=TODO"
    Close #1
    Debug.Print "Fatigue results stub: " & p
    Debug.Print "View: Results > Life / Damage / Factor of Safety (fatigue)"
End Sub
