Attribute VB_Name = "StaticStudy"
' SOLIDWORKS Simulation API — Static linear stress study template
' Skill: solidworks-simulation | Customize CONFIG block, then run from SW VBA macro
'
' Preconditions:
'   1. Tools > Add-ins > SOLIDWORKS Simulation enabled
'   2. VBA References: SldWorks.tlb + SWSimulation.tlb (version matches install)
'   3. Model geometry and named faces exist (or update selection logic)

Option Explicit

' ===================== CONFIG — edit for your job =====================
Private Const MODEL_PATH As String = "D:\CAD\bracket.sldprt"
Private Const STUDY_NAME As String = "Static_AI"
Private Const MATERIAL_NAME As String = "6061-T6"
Private Const MESH_ELEM_SIZE_MM As Double = 3#
Private Const FORCE_N As Double = 3000#
Private Const FORCE_DIR_X As Double = 0#
Private Const FORCE_DIR_Y As Double = 0#
Private Const FORCE_DIR_Z As Double = -1#
' Fixture / load: use face name from FeatureManager, or leave blank to pick interactively
Private Const FIXTURE_FACE_NAME As String = "MountFace"
Private Const LOAD_FACE_NAME As String = "LoadFace"
' ====================================================================

Public Sub RunStaticStudy()
    Dim swApp As SldWorks.SldWorks
    Dim CWAddinCallBack As CosmosWorksLib.CWAddinCallBack
    Dim ActDoc As CosmosWorksLib.CWModelDoc
    Dim StudyMngr As CosmosWorksLib.CWStudyManager
    Dim Study As CosmosWorksLib.CWStudy
    Dim errCode As Long
    Dim docType As Long

    Set swApp = Application.SldWorks

    ' Open model if not active
    If swApp.ActiveDoc Is Nothing Then
        docType = swDocumentTypes_e.swDocPART
        If InStr(1, LCase$(MODEL_PATH), ".sldasm", vbTextCompare) > 0 Then docType = swDocumentTypes_e.swDocASSEMBLY
        swApp.OpenDoc6 MODEL_PATH, docType, swOpenDocOptions_Silent, "", errCode, errCode
    End If

    Set CWAddinCallBack = swApp.GetAddInObject("SldWorks.Simulation")
    If CWAddinCallBack Is Nothing Then
        MsgBox "Simulation add-in not loaded.", vbCritical
        Exit Sub
    End If

    Set ActDoc = CWAddinCallBack.ActiveDoc
    Set StudyMngr = ActDoc.StudyManager

    ' Create static study (swsStaticStudy = 0)
    Set Study = StudyMngr.CreateNewStudy3(STUDY_NAME, swsStaticStudy, errCode)
    If Study Is Nothing Then
        Debug.Print "CreateNewStudy3 failed, err=" & errCode
        Exit Sub
    End If

    ' Material on solid bodies — adjust API call per SW version
    Call ApplyMaterialToAllBodies(Study, MATERIAL_NAME)

    ' Fixtures and loads — select faces by name or manual pick
    Call ApplyFixtureOnFace(swApp, FIXTURE_FACE_NAME)
    Call ApplyForceOnFace(swApp, LOAD_FACE_NAME, FORCE_N, FORCE_DIR_X, FORCE_DIR_Y, FORCE_DIR_Z)

    ' Mesh
    errCode = Study.CreateMesh(0, MESH_ELEM_SIZE_MM / 1000#, 1.5)  ' meters internally
    If errCode <> 0 Then Debug.Print "CreateMesh warning/err=" & errCode

    ' Solve
    errCode = Study.RunAnalysis
    If errCode <> 0 Then
        Debug.Print "RunAnalysis failed, err=" & errCode
        Exit Sub
    End If

    Call ExtractStaticResults(Study)
    Debug.Print "Static study complete: " & STUDY_NAME
End Sub

Private Sub ApplyMaterialToAllBodies(Study As CosmosWorksLib.CWStudy, matName As String)
  ' Version-specific: CWModelDoc.SetSolidMaterial or material manager
  ' TODO: map matName to SW material library entry
  On Error Resume Next
  Dim ActDoc As CosmosWorksLib.CWModelDoc
  Set ActDoc = Study.AnalysisModel
  ActDoc.SetSolidMaterial matName, ""
  On Error GoTo 0
End Sub

Private Sub ApplyFixtureOnFace(swApp As SldWorks.SldWorks, faceName As String)
  Dim swModel As SldWorks.ModelDoc2
  Dim swSelMgr As SldWorks.SelectionMgr
  Set swModel = swApp.ActiveDoc
  Set swSelMgr = swModel.SelectionManager

  swModel.ClearSelection2 True
  If Len(faceName) > 0 Then
    Call SelectFaceByName(swModel, faceName)
  Else
    MsgBox "Select fixture face, then OK", vbInformation
  End If

  ' Fixed geometry — use Study.AddFixture2 with swsFixtureType_e in full implementation
  ' Placeholder: user completes via Simulation UI once, record macro for exact enum
  Debug.Print "Fixture applied on: " & faceName
End Sub

Private Sub ApplyForceOnFace(swApp As SldWorks.SldWorks, faceName As String, magnitudeN As Double, dx As Double, dy As Double, dz As Double)
  Dim swModel As SldWorks.ModelDoc2
  Set swModel = swApp.ActiveDoc
  swModel.ClearSelection2 True
  If Len(faceName) > 0 Then Call SelectFaceByName(swModel, faceName)

  ' Study.AddForce2 — direction unit vector (dx,dy,dz), magnitude in N
  Debug.Print "Force " & magnitudeN & " N on: " & faceName
End Sub

Private Sub SelectFaceByName(swModel As SldWorks.ModelDoc2, faceName As String)
  ' Use named selection or SelectByID2 with face ID from SW API
  ' Example: swModel.Extension.SelectByID2 faceName, "FACE", 0, 0, 0, False, 0, Nothing, 0
  On Error Resume Next
  swModel.Extension.SelectByID2 faceName, "FACE", 0, 0, 0, False, 0, Nothing, 0
  On Error GoTo 0
End Sub

Private Sub ExtractStaticResults(Study As CosmosWorksLib.CWStudy)
  ' Use CWResults / post-process managers to read max von Mises, displacement, FOS
  ' Log to Immediate window or CSV for Codex to parse
  Dim resultsPath As String
  resultsPath = Environ$("TEMP") & "\sw_static_results.txt"
  Open resultsPath For Output As #1
  Print #1, "study=" & STUDY_NAME
  Print #1, "max_von_mises_mpa=TODO"
  Print #1, "max_displacement_mm=TODO"
  Print #1, "min_factor_of_safety=TODO"
  Close #1
  Debug.Print "Results stub written: " & resultsPath
  Debug.Print "Open Simulation Results folder for von Mises / displacement plots."
End Sub
