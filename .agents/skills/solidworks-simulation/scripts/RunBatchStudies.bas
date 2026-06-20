Attribute VB_Name = "RunBatchStudies"
' SOLIDWORKS Simulation API — batch run multiple studies or parametric load sweep
' Skill: solidworks-simulation
' Based on: Run Studies in Batch Mode (SW Simulation API help)

Option Explicit

' ===================== CONFIG =====================
Private Const MODEL_PATH As String = "C:\CAD\bracket.sldprt"
' Studies must already exist in the model (create via StaticStudy.bas or GUI)
Private StudyNames As Variant
Private Const OUTPUT_CSV As String = "C:\CAD\batch_results.csv"
' ================================================

Public Sub RunBatch()
    StudyNames = Array("Static_1kN", "Static_2kN", "Static_3kN")

    Dim swApp As SldWorks.SldWorks
    Dim CWAddinCallBack As CosmosWorksLib.CWAddinCallBack
    Dim ActDoc As CosmosWorksLib.CWModelDoc
    Dim StudyMngr As CosmosWorksLib.CWStudyManager
    Dim RunStudyOptions As CosmosWorksLib.CWRunSpecStudiesRunMeshOptions
    Dim RunStudyResults As CosmosWorksLib.CWRunStudiesResults
    Dim errCode As Long
    Dim studyName As String
    Dim result As Long
    Dim i As Long

    Set swApp = Application.SldWorks
    If swApp.ActiveDoc Is Nothing Then
        swApp.OpenDoc6 MODEL_PATH, swDocumentTypes_e.swDocPART, swOpenDocOptions_Silent, "", errCode, errCode
    End If

    Set CWAddinCallBack = swApp.GetAddInObject("SldWorks.Simulation")
    Set ActDoc = CWAddinCallBack.ActiveDoc
    Set StudyMngr = ActDoc.StudyManager
    Set RunStudyOptions = StudyMngr.RunSpecifiedStudyOptions

    For i = LBound(StudyNames) To UBound(StudyNames)
        errCode = RunStudyOptions.AddStudyOption(CStr(StudyNames(i)), swsRunStudiesRunMeshOptions_MeshAndRun)
        Debug.Print "Queued: " & StudyNames(i) & " err=" & errCode
    Next i

    Set RunStudyResults = StudyMngr.RunSpecifiedStudyByName(errCode)
    If RunStudyResults Is Nothing Then
        Debug.Print "Batch run failed, err=" & errCode
        Exit Sub
    End If

    Open OUTPUT_CSV For Output As #1
    Print #1, "study,result_code,max_stress_mpa,max_disp_mm,min_fos"

    errCode = RunStudyResults.GetFirstItem(studyName, result)
    Do While errCode = 0
        Debug.Print "Completed: " & studyName & " result_code=" & result
        Print #1, studyName & "," & result & ",TODO,TODO,TODO"
        errCode = RunStudyResults.GetNextItem(studyName, result)
    Loop
    Close #1

    Debug.Print "Batch CSV: " & OUTPUT_CSV
End Sub

' Parametric sweep helper: duplicate study with scaled force via API, then call RunBatch

Public Sub ParametricForceSweep()
    Dim forces As Variant
    Dim i As Long
    forces = Array(1000#, 1500#, 2000#, 2500#, 3000#)
    For i = LBound(forces) To UBound(forces)
        Debug.Print "TODO: Create study Static_" & forces(i) & "N with force=" & forces(i)
        ' Clone study + update AddForce2 magnitude per variant
    Next i
    Call RunBatch
End Sub
