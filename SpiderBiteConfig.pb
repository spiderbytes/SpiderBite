EnableExplicit

Structure sSpiderBiteCfg
  
  PbCompiler.s
  
  AspxTemplate.s
  AspxServerFilename.s
  AspxServerAddress.s
  
  AspTemplate.s
  AspServerFilename.s
  AspServerAddress.s
  
  PbCgiTemplate.s
  PbCgiServerFilename.s
  PbCgiServerAddress.s
  
  NodeJsServerFilename.s
  NodeJsServerAddress.s
  NodeJsTemplate.s
  
  PhpTemplate.s
  PhpServerFilename.s
  PhpServerAddress.s
  
  PythonTemplate.s
  PythonServerFilename.s
  PythonServerAddress.s
  
EndStructure

Global NewMap SpiderBiteCfg.sSpiderBiteCfg()

Global GlobalQuit

Global DialogXML
Global Dialog

#AppName = "SpiderBiteConfig"

Enumeration
  #Action_Add = 1
  #Action_Edit
  #Action_Delete
EndEnumeration

Global Action

Runtime Enumeration
  
  #winConfig
  
  #winConfig_txtProfileName
  
  #winConfig_txtPbCompiler
  #winConfig_cmdPbCompiler
  
  #winConfig_txtPbCgiTemplate
  #winConfig_cmdPbCgiTemplate
  #winConfig_txtPbCgiServerFilename
  #winConfig_cmdPbCgiServerFilename
  #winConfig_txtPbCgiServerAddress
  
  #winConfig_txtPhpTemplate
  #winConfig_cmdPhpTemplate
  #winConfig_txtPhpServerFilename
  #winConfig_cmdPhpServerFilename
  #winConfig_txtPhpServerAddress
  
  #winConfig_txtAspTemplate
  #winConfig_cmdAspTemplate
  #winConfig_txtAspServerFilename
  #winConfig_cmdAspServerFilename
  #winConfig_txtAspServerAddress
  
  #winConfig_txtAspxTemplate
  #winConfig_cmdAspxTemplate
  #winConfig_txtAspxServerFilename
  #winConfig_cmdAspxServerFilename
  #winConfig_txtAspxServerAddress
  
  #winConfig_txtNodeJsFilename
  #winConfig_cmdNodeJsFilename
  #winConfig_txtNodeJsServerAddress
  
  #winConfig_txtPythonFilename
  #winConfig_cmdPythonFilename
  #winConfig_txtPythonServerAddress
  
  #winConfig_cmdOK
  #winConfig_cmdCancel
  
  #winMain
  
  #winMain_lstProfiles
  #winMain_cmdAdd
  #winMain_cmdEdit
  #winMain_cmdDelete
  
EndEnumeration

Procedure LoadConfig()
  
  Protected Filename.s = GetPathPart(ProgramFilename()) + "SpiderBite.cfg"
  
  If LoadJSON(0, FileName)
    
    ExtractJSONMap(JSONValue(0), SpiderBiteCfg())
    
  EndIf
  
EndProcedure

Procedure SaveConfig()
  
  Protected Filename.s = GetPathPart(ProgramFilename()) + "SpiderBite.cfg"
  
  If CreateJSON(0)
    
    InsertJSONMap(JSONValue(0), SpiderBiteCfg())
    
    SaveJSON(0, FileName, #PB_JSON_PrettyPrint)
    
  EndIf
  
EndProcedure

Runtime Procedure winConfig_ChoosePathEvent()
  
  Protected Filename.s
  Protected SelectedFilename.s
  
  Select EventGadget()
      
    Case #winConfig_cmdPbCompiler
      Filename = GetGadgetText(#winConfig_txtPbCompiler)
      
    Case #winConfig_cmdPbCgiTemplate
      Filename = GetGadgetText(#winConfig_txtPbCgiTemplate)
    Case #winConfig_cmdPbCgiServerFilename
      Filename = GetGadgetText(#winConfig_txtPbCgiServerFilename)
      
    Case #winConfig_cmdPhpTemplate
      Filename = GetGadgetText(#winConfig_txtPhpTemplate)
    Case #winConfig_cmdPhpServerFilename
      Filename = GetGadgetText(#winConfig_txtPhpServerFilename)
      
    Case #winConfig_cmdAspTemplate
      Filename = GetGadgetText(#winConfig_txtAspTemplate)
    Case #winConfig_cmdAspServerFilename
      Filename = GetGadgetText(#winConfig_txtAspServerFilename)
      
    Case #winConfig_cmdAspxTemplate
      Filename = GetGadgetText(#winConfig_txtAspxTemplate)
    Case #winConfig_cmdAspxServerFilename
      Filename = GetGadgetText(#winConfig_txtAspxServerFilename)
      
  EndSelect
  
  SelectedFilename = OpenFileRequester("Please choose a file", Filename, "All files (*.*)|*.*", 0)
  
  If SelectedFilename
    Select EventGadget()
      Case #winConfig_cmdPbCompiler
        SetGadgetText(#winConfig_txtPbCompiler, SelectedFilename)
      Case #winConfig_cmdPbCgiTemplate
        SetGadgetText(#winConfig_txtPbCgiTemplate, SelectedFilename)
      Case #winConfig_cmdPbCgiServerFilename
        SetGadgetText(#winConfig_txtPbCgiServerFilename, SelectedFilename)
      Case #winConfig_cmdPhpTemplate
        SetGadgetText(#winConfig_txtPhpTemplate, SelectedFilename)
      Case #winConfig_cmdPhpServerFilename
        SetGadgetText(#winConfig_txtPhpServerFilename, SelectedFilename)
      Case #winConfig_cmdAspTemplate
        SetGadgetText(#winConfig_txtAspTemplate, SelectedFilename)
      Case #winConfig_cmdAspServerFilename
        SetGadgetText(#winConfig_txtAspServerFilename, SelectedFilename)
      Case #winConfig_cmdAspxTemplate
        SetGadgetText(#winConfig_txtAspxTemplate, SelectedFilename)
      Case #winConfig_cmdAspxServerFilename
        SetGadgetText(#winConfig_txtAspxServerFilename, SelectedFilename)
    EndSelect
  EndIf
  
EndProcedure

Procedure CheckButtons()
  
  Protected Flag = #False
  
  If GetGadgetState(#winMain_lstProfiles) = -1
    Flag = #True
  EndIf
  
  DisableGadget(#winMain_cmdEdit, Flag)
  DisableGadget(#winMain_cmdDelete, Flag)
  
EndProcedure

Procedure ReFillProfileList(ProfileName.s = "")
  
  NewList DummyList.s()
  
  ForEach SpiderBiteCfg()
    AddElement(DummyList())
    DummyList() = MapKey(SpiderBiteCfg())
  Next
  
  SortList(DummyList(), #PB_Sort_Ascending)
  
  ClearGadgetItems(#winMain_lstProfiles)
  
  ForEach DummyList()
    AddGadgetItem(#winMain_lstProfiles, -1, DummyList())
  Next

  If ProfileName <> ""
    SetGadgetText(#winMain_lstProfiles, ProfileName)
  EndIf
  
  If GetGadgetState(#winMain_lstProfiles) = -1
    SetGadgetState(#winMain_lstProfiles, 0)
  EndIf
  
  CheckButtons()
  
EndProcedure

Runtime Procedure winConfig_cmdOK_Event()
  
  Protected ProfileName.s = Trim(GetGadgetText(#winConfig_txtProfileName))
  Protected ProfileNameExists
  
  If ProfileName = ""
    
    MessageRequester(#AppName, "ProfileName must not be empty.")
    SetActiveGadget(#winConfig_txtProfileName)
    
    ProcedureReturn
    
  EndIf
  
  Select Action
      
    Case #Action_Add
      
      ; Check, if ProfileName exists...
      
      ForEach SpiderBiteCfg()
        If LCase(ProfileName) = LCase(MapKey(SpiderBiteCfg()))
          ProfileNameExists = #True
          Break
        EndIf
      Next
      
      If ProfileNameExists
        MessageRequester(#AppName, "ProfileName already exists." + #LF$ + "Please choose another one.")
        SetActiveGadget(#winConfig_txtProfileName)
        ProcedureReturn
      EndIf
      
    Case #Action_Edit
      
      If LCase(ProfileName) <> LCase(GetGadgetText(#winMain_lstProfiles))
        
        ; rename profilename
        
        ; Check, if ProfileName exists elsewhere...
        
        ForEach SpiderBiteCfg()
          If LCase(ProfileName) = LCase(MapKey(SpiderBiteCfg()))
            ProfileNameExists = #True
            Break
          EndIf
        Next
        
        If ProfileNameExists
          MessageRequester(#AppName, "ProfileName already exists." + #LF$ + "Please choose another one.")
          SetActiveGadget(#winConfig_txtProfileName)
          ProcedureReturn
        EndIf
        
      EndIf
      
      DeleteMapElement(SpiderBiteCfg(), GetGadgetText(#winMain_lstProfiles))
      
  EndSelect
  
  SpiderBiteCfg(ProfileName)\PbCompiler          = GetGadgetText(#winConfig_txtPbCompiler)
  SpiderBiteCfg(ProfileName)\PbCgiTemplate       = GetGadgetText(#winConfig_txtPbCgiTemplate)
  SpiderBiteCfg(ProfileName)\PbCgiServerFilename = GetGadgetText(#winConfig_txtPbCgiServerFilename)
  SpiderBiteCfg(ProfileName)\PbCgiServerAddress  = GetGadgetText(#winConfig_txtPbCgiServerAddress)
  SpiderBiteCfg(ProfileName)\PhpTemplate         = GetGadgetText(#winConfig_txtPhpTemplate)
  SpiderBiteCfg(ProfileName)\PhpServerFilename   = GetGadgetText(#winConfig_txtPhpServerFilename)
  SpiderBiteCfg(ProfileName)\PhpServerAddress    = GetGadgetText(#winConfig_txtPhpServerAddress)
  SpiderBiteCfg(ProfileName)\AspTemplate         = GetGadgetText(#winConfig_txtAspTemplate)
  SpiderBiteCfg(ProfileName)\AspServerFilename   = GetGadgetText(#winConfig_txtAspServerFilename)
  SpiderBiteCfg(ProfileName)\AspServerAddress    = GetGadgetText(#winConfig_txtAspServerAddress)
  SpiderBiteCfg(ProfileName)\AspxTemplate        = GetGadgetText(#winConfig_txtAspxTemplate)
  SpiderBiteCfg(ProfileName)\AspxServerFilename  = GetGadgetText(#winConfig_txtAspxServerFilename)
  SpiderBiteCfg(ProfileName)\AspxServerAddress   = GetGadgetText(#winConfig_txtAspxServerAddress)  
  
  SaveConfig()
  
  CloseWindow(#winConfig)
  
  ReFillProfileList(ProfileName)

EndProcedure

Runtime Procedure winConfig_cmdCancel_Event()
  CloseWindow(#winConfig)
EndProcedure

Procedure winConfig_Close()
  CloseWindow(#winConfig)
EndProcedure

Runtime Procedure winMain_cmdAdd_Event()
  Action = #Action_Add
  OpenXMLDialog(Dialog, DialogXML, "winConfig")
  SetWindowTitle(#winConfig, "Add profile")
  BindEvent(#PB_Event_CloseWindow, @winConfig_Close(), #winConfig)
  SetActiveGadget(#winConfig_txtProfileName)
EndProcedure

Runtime Procedure winMain_cmdEdit_Event()
  
  Action = #Action_Edit
  
  OpenXMLDialog(Dialog, DialogXML, "winConfig")
  
  SetWindowTitle(#winConfig, "Edit profile")

  BindEvent(#PB_Event_CloseWindow, @winConfig_Close(), #winConfig)
  
  Protected SelectedProfile.s = GetGadgetText(#winMain_lstProfiles)
  
  SetGadgetText(#winConfig_txtProfileName, SelectedProfile)
  
  SetGadgetText(#winConfig_txtPbCompiler, SpiderBiteCfg(SelectedProfile)\PbCompiler)
  
  SetGadgetText(#winConfig_txtPbCgiTemplate, SpiderBiteCfg(SelectedProfile)\PbCgiTemplate)
  SetGadgetText(#winConfig_txtPbCgiServerFilename, SpiderBiteCfg(SelectedProfile)\PbCgiServerFilename)
  SetGadgetText(#winConfig_txtPbCgiServerAddress, SpiderBiteCfg(SelectedProfile)\PbCgiServerAddress)
  
  SetGadgetText(#winConfig_txtPhpTemplate, SpiderBiteCfg(SelectedProfile)\PhpTemplate)
  SetGadgetText(#winConfig_txtPhpServerFilename, SpiderBiteCfg(SelectedProfile)\PhpServerFilename)
  SetGadgetText(#winConfig_txtPhpServerAddress, SpiderBiteCfg(SelectedProfile)\PhpServerAddress)
  
  SetGadgetText(#winConfig_txtAspTemplate, SpiderBiteCfg(SelectedProfile)\AspTemplate)
  SetGadgetText(#winConfig_txtAspServerFilename, SpiderBiteCfg(SelectedProfile)\AspServerFilename)
  SetGadgetText(#winConfig_txtAspServerAddress, SpiderBiteCfg(SelectedProfile)\AspServerAddress)
  
  SetGadgetText(#winConfig_txtAspxTemplate, SpiderBiteCfg(SelectedProfile)\AspxTemplate)
  SetGadgetText(#winConfig_txtAspxServerFilename, SpiderBiteCfg(SelectedProfile)\AspxServerFilename)
  SetGadgetText(#winConfig_txtAspxServerAddress, SpiderBiteCfg(SelectedProfile)\AspxServerAddress)  
  
EndProcedure

Runtime Procedure winMain_cmdDelete_Event()
  
  If MessageRequester(#AppName, "Sure?", #PB_MessageRequester_YesNo)=#PB_MessageRequester_No
    ProcedureReturn
  EndIf
  
  Action = #Action_Delete
  
  Protected SelectedProfile.s = GetGadgetText(#winMain_lstProfiles)
  
  DeleteMapElement(SpiderBiteCfg(), SelectedProfile)
  
  SaveConfig()
  
  ReFillProfileList()
  
EndProcedure

Procedure winMain_Close()
  
  GlobalQuit = #True
  
EndProcedure

Procedure winMain_Open()
  
  OpenXMLDialog(Dialog, DialogXML, "winMain")
  
  BindEvent(#PB_Event_CloseWindow, @winMain_Close(), #winMain)
  
  ReFillProfileList()
  
EndProcedure

Runtime Procedure winMain_lstProfiles_Event()
  
  CheckButtons()
  
  If EventType() = #PB_EventType_LeftDoubleClick
    
    If GetGadgetState(#winMain_lstProfiles) > -1
      
      winMain_cmdEdit_Event()
      
    EndIf
    
  EndIf
  
EndProcedure

Procedure Main()
  
  Protected Event
  
  DialogXML = ParseXML(#PB_Any, PeekS(?SpiderBiteConfigDialogs, -1, #PB_UTF8))
  
  If DialogXML
    
    If XMLStatus(DialogXML) = #PB_XML_Success
      
      Dialog = CreateDialog(#PB_Any) 
      
      winMain_Open()
      
      Repeat
        Event = WaitWindowEvent()
        If GlobalQuit
          Break
        EndIf
      ForEver
      
    Else
      Debug "XML error: " + XMLError(DialogXML) + " (Line: " + XMLErrorLine(DialogXML) + ")"
    EndIf
    
  EndIf
  
EndProcedure

LoadConfig()
 
Main()

DataSection
  SpiderBiteConfigDialogs:
  IncludeBinary "includes/SpiderBiteConfigDialogs.xml"
  Data.b 0
EndDataSection