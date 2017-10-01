EnableExplicit

Global SourceFile.s

#AppName = "SpiderBite"
#AppVersion = "2017-10-01"

#ServerCodeType_NodeJs = "NodeJs"
#ServerCodeType_Php    = "Php"
#ServerCodeType_PbCgi  = "PbCgi"
#ServerCodeType_Python = "Python"
#ServerCodeType_Asp    = "Asp"
#ServerCodeType_Aspx   = "Aspx"

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

Global SpiderBite_Profile.s
Global SpiderBite_ByPass

Global NewMap SpiderBiteCfg.sSpiderBiteCfg()

XIncludeFile "includes/inc.lexer.pbi"
XIncludeFile "includes/functions.pbi"

Structure Token
  Token.s
  Type.i
  Line.i
EndStructure

Global NewList Token.Token()
 
Procedure.s AddCompilerError(FileContent.s, Message.s)
  FileContent = "CompilerError " + Chr(34) + "SpiderBite: " + Message + Chr(34) + #CRLF$ + FileContent
  ProcedureReturn FileContent
EndProcedure

Procedure.s AddCompilerWarning(FileContent.s, Message.s)
  FileContent = "CompilerWarning " + Chr(34) + Message + Chr(34) + #CRLF$ + FileContent
  ProcedureReturn FileContent
EndProcedure

Procedure CheckNextToken(List TT.Token(), Match.s)
  Protected ReturnValue
  If NextElement(TT())
    ReturnValue = Bool(TT()\Token = Match)
    PreviousElement(TT())
  EndIf
  ProcedureReturn ReturnValue
EndProcedure

Procedure GetSpiderByteConstants(FileContent.s)
  
	Protected Lexer.iPBSC = New_PBSC() 	
	
	Protected RequestSelect.s
	
	FileContent = ReplaceString(FileContent, #CRLF$, #LF$)
	
	Lexer\SetFileString(FileContent)
	
	NewList TT.Token()
	
	; Token einlesen
	While Lexer\IsNextToken() 
		AddElement(TT())
		TT()\Token = Lexer\GetNextToken() 
		TT()\Type  = Lexer\GetCurrentType() 
		TT()\Line  = Lexer\GetCurrentLineNb()
	Wend
	
	PBSC_CloseFile(Lexer)
	
	Protected ConstantName.s
	Protected ConstantValue.s
	
	ForEach TT()
		Select TT()\Type
		  Case #PBSC_Identifier
		    If Left(TT()\Token, 1) = "#"
		      
		      ConstantName = TT()\Token
		      NextElement(TT())
		      NextElement(TT())
		      ConstantValue = TT()\Token
		      
		      Select LCase(ConstantName)
		          
		        Case "#spiderbite_profile"
		          SpiderBite_Profile = RemoveString(ConstantValue, Chr(34))
		          
		        Case "#spiderbite_bypass"
		          
		          Select LCase(ConstantValue)
		            Case "1", "#true"
		              SpiderBite_ByPass = #True
		            Default
		              SpiderBite_ByPass = #False
		          EndSelect
		          
		      EndSelect
		      
		    EndIf
		EndSelect
	Next
	
EndProcedure

Procedure.s GetRequestSelect4PbCgi(ServerCode.s)
  
  Protected regex_Procedure
  
  Protected CurrentProcedure.s
  Protected ProcedureLine.s
  
  Protected ProcIsString
  Protected ParamIsString
  
  Protected ProcName.s
  Protected RequestSelect.s
  Protected ParamCounter
  
  regex_Procedure = CreateRegularExpression(#PB_Any, "^[\t]*[\ ]*ProcedureDLL([\s\S]*?)\(([\s\S]*?)^[\s]*EndProcedure", #PB_RegularExpression_MultiLine | #PB_RegularExpression_NoCase)	
  
  If ExamineRegularExpression(regex_Procedure, ServerCode)
    
    While NextRegularExpressionMatch(regex_Procedure)
      
      CurrentProcedure = RegularExpressionMatchString(regex_Procedure)
      
      ProcName = Trim(RemoveString(CurrentProcedure, "ProcedureDLL", #PB_String_NoCase))
      
      ProcIsString = #False
      
      If Left(ProcName, 2) = ".s"
        ProcIsString = #True
        ProcName = Trim(Mid(ProcName, 3))
      EndIf
      
      ProcName = Trim(StringField(ProcName, 1, "("))
      
      RequestSelect + #TAB$ + "Case " + Chr(34) + LCase(ProcName) + Chr(34) + #CRLF$
      
      If ProcIsString
        RequestSelect + #TAB$ + #TAB$ + "ReturnValue = " + ProcName + "("
      Else
        RequestSelect + #TAB$ + #TAB$ + "ReturnValue = Str(" + ProcName + "("
      EndIf
      
      ProcedureLine = StringField(CurrentProcedure, 1, #LF$)
      
      Protected Parameters.s = ParseParameter(ProcedureLine)
      
      Protected Parameter.s
      
      For ParamCounter = 0 To CountString(Parameters, Chr(1))
        
        Parameter = Trim(StringField(Parameters, ParamCounter + 1, Chr(1)))
        
        If Parameter <> ""
          
          If LCase(Left(Parameter, Len("list"))) = "list" Or 
             LCase(Left(Parameter, Len("map"))) = "map" Or
             Left(Parameter, 1) = "*"
            
            ProcedureReturn "CompilerError:\n" + ProcName + "\nLists, Maps And Pointers are not allowed (yet)"
            
          EndIf
          
          ParamIsString = #False
          
          Protected P1.s = Trim(StringField(Parameter, 1, "="))
          
          If Right(P1, 1) = "$"
            ParamIsString = #True
          EndIf
          
          Protected P2.s = Trim(StringField(P1, 2, "."))
          
          If LCase(P2) = "s"
            ParamIsString = #True
          EndIf
          
          If ParamIsString
            RequestSelect + " CGIParameterValue(" + Chr(34) + Chr(34) + ", " + Str(ParamCounter + 1) + "), "
          Else
            RequestSelect + " Val(CGIParameterValue(" + Chr(34) + Chr(34) + ", " + Str(ParamCounter + 1) + ")), "
          EndIf
          
        EndIf
        
      Next
      
      If EndsWith(Trim(RequestSelect), ",")
        RequestSelect = Left(Trim(RequestSelect), Len(Trim(RequestSelect)) - 1)
      EndIf
      
      If ProcIsString
        RequestSelect + ")" + #CRLF$
      Else
        RequestSelect + "))" + #CRLF$
      EndIf
      
    Wend
    
    FreeRegularExpression(regex_Procedure)
    
  EndIf
  
  If RequestSelect <> ""
    
    RequestSelect = "Select Request" + #CRLF$ +
                    RequestSelect + 
                    #TAB$ + "Default" + #CRLF$ +
                    #TAB$ + #TAB$ + "ReturnValue = " + Chr(34) + "unknown request: '" + Chr(34) + " + Request + " + Chr(34) + "'" + Chr(34) + #CRLF$ +
                    "EndSelect"  
    
  EndIf
  
  Debug RequestSelect
  
  ProcedureReturn RequestSelect
  
EndProcedure
Procedure.s GetRequestSelect4Asp(ServerCode.s)
  
  Protected regex_Procedure
  
  Protected CurrentProcedure.s
  Protected ProcedureLine.s
  
  Protected ProcName.s
  Protected RequestSelect.s
  Protected ParamCounter
  
  regex_Procedure = CreateRegularExpression(#PB_Any, "^[\t]*[\ ]*ProcedureDLL([\s\S]*?)\(([\s\S]*?)^[\s]*EndProcedure", #PB_RegularExpression_MultiLine | #PB_RegularExpression_NoCase)	
  
  If ExamineRegularExpression(regex_Procedure, ServerCode)
    
    While NextRegularExpressionMatch(regex_Procedure)
      
      CurrentProcedure = RegularExpressionMatchString(regex_Procedure)
      
      ProcName = Trim(RemoveString(CurrentProcedure, "ProcedureDLL", #PB_String_NoCase))
      
      If Left(ProcName, 2) = ".s"
        ProcName = Trim(Mid(ProcName, 3))
      EndIf
      
      ProcName = Trim(StringField(ProcName, 1, "("))
      
      RequestSelect + #TAB$ + #TAB$ + "Case " + Chr(34) + LCase(ProcName) + Chr(34) + #CRLF$
      
      RequestSelect + #TAB$ + #TAB$ + #TAB$ + "Response.Write " + ProcName + "("
      
      ProcedureLine = StringField(CurrentProcedure, 1, #LF$)
      
      Protected Parameters.s = ParseParameter(ProcedureLine)
      
      Protected Parameter.s
      
      For ParamCounter = 0 To CountString(Parameters, Chr(1))
        
        Parameter = Trim(StringField(Parameters, ParamCounter + 1, Chr(1)))
        
        If Parameter <> ""
          
          If LCase(Left(Parameter, Len("list"))) = "list" Or 
             LCase(Left(Parameter, Len("map"))) = "map" Or
             Left(Parameter, 1) = "*"
            
            ProcedureReturn "CompilerError:\n" + ProcName + "\nLists, Maps And Pointers are not allowed (yet)"
            
          EndIf
          
          RequestSelect + "Request.Form(" + Str(ParamCounter + 2) + "), "
          
        EndIf
        
      Next
      
      If EndsWith(Trim(RequestSelect), ",")
        RequestSelect = Left(Trim(RequestSelect), Len(Trim(RequestSelect)) - 1)
      EndIf
      
      RequestSelect + ")" + #CRLF$
      
    Wend
    
    FreeRegularExpression(regex_Procedure)
    
  EndIf
  
  If RequestSelect <> ""
    
    RequestSelect = "If Request.ServerVariables(" + Chr(34) + "REQUEST_METHOD" + Chr(34) + ")= " + Chr(34) + "POST" + Chr(34) + " Then" + #CRLF$ + 
		                "" + #CRLF$ +
                    #TAB$ + "Dim myRequest" + #CRLF$ + 
	                  #TAB$ + "myRequest = LCase(Request.Form(1))" + #CRLF$ +
		                "" + #CRLF$ +
		                #TAB$ + "Select Case myRequest" + #CRLF$ +
                    RequestSelect + 
                    #TAB$ + #TAB$ + "Case Else" + #CRLF$ +
                    #TAB$ + #TAB$ + #TAB$ + "Response.Write " + Chr(34) + "unknown request: '" + Chr(34) + " & myRequest & " + Chr(34) + "'" + Chr(34) + #CRLF$ +
                    #TAB$ + "End Select" + #CRLF$ +
		                "" + #CRLF$ +
                    "End If"
    
  EndIf
  
	Debug RequestSelect
	
	ProcedureReturn RequestSelect
	
EndProcedure
Procedure.s GetRequestSelect4PHP(ServerCode.s)
  
  Protected regex_Procedure
  
  Protected CurrentProcedure.s
  Protected ProcedureLine.s
  
  Protected ProcName.s
  Protected RequestSelect.s
  Protected ParamCounter
  
  regex_Procedure = CreateRegularExpression(#PB_Any, "^[\t]*[\ ]*ProcedureDLL([\s\S]*?)\(([\s\S]*?)^[\s]*EndProcedure", #PB_RegularExpression_MultiLine | #PB_RegularExpression_NoCase)	
  
  If ExamineRegularExpression(regex_Procedure, ServerCode)
    
    While NextRegularExpressionMatch(regex_Procedure)
      
      CurrentProcedure = RegularExpressionMatchString(regex_Procedure)
      
      ProcName = Trim(RemoveString(CurrentProcedure, "ProcedureDLL", #PB_String_NoCase))
      
      If Left(ProcName, 2) = ".s"
        ProcName = Trim(Mid(ProcName, 3))
      EndIf
      
      ProcName = Trim(StringField(ProcName, 1, "("))
      
      RequestSelect + #TAB$ + "case " + Chr(34) + LCase(ProcName) + Chr(34) + ":" + #CRLF$
      
      RequestSelect + #TAB$ + #TAB$ + "$ReturnValue = " + ProcName + "("
      
      ProcedureLine = StringField(CurrentProcedure, 1, #LF$)
      
      Protected Parameters.s = ParseParameter(ProcedureLine)
      
      Protected Parameter.s
      
      For ParamCounter = 0 To CountString(Parameters, Chr(1))
        
        Parameter = Trim(StringField(Parameters, ParamCounter + 1, Chr(1)))
        
        If Parameter <> ""
          
          If LCase(Left(Parameter, Len("list"))) = "list" Or 
             LCase(Left(Parameter, Len("map"))) = "map" Or
             Left(Parameter, 1) = "*"
            
            ProcedureReturn "CompilerError:\n" + ProcName + "\nLists, Maps And Pointers are not allowed (yet)"
            
          EndIf
          
          RequestSelect + " $_POST(" + Str(ParamCounter + 1) + "), "
          
        EndIf
        
      Next
      
      If EndsWith(Trim(RequestSelect), ",")
        RequestSelect = Left(Trim(RequestSelect), Len(Trim(RequestSelect)) - 1)
      EndIf
      
      RequestSelect + ");" + #CRLF$
      RequestSelect + #TAB$ + #TAB$ + "break;" + #CRLF$
      
    Wend
    
    FreeRegularExpression(regex_Procedure)
    
  EndIf
  
  If RequestSelect <> ""
    
    RequestSelect = "switch ($request) {" + #CRLF$ +
                    RequestSelect + 
                    #TAB$ + "default:" + #CRLF$ +
                    #TAB$ + #TAB$ + "$ReturnValue = " + Chr(34) + "unknown request: '" + Chr(34) + " . $request . " + Chr(34) + "'" + Chr(34) + ";" + #CRLF$ +
                    #TAB$ + #TAB$ + "break;" + #CRLF$ +
                    "}"
    
  EndIf
  
  ; Debug RequestSelect
  
  ProcedureReturn RequestSelect
  
EndProcedure
Procedure.s GetRequestSelect4Aspx(ServerCode.s)
  
  Protected regex_Procedure
  
  Protected CurrentProcedure.s
  Protected ProcedureLine.s
  
  Protected ProcName.s
  Protected RequestSelect.s
  Protected ParamCounter
  
  regex_Procedure = CreateRegularExpression(#PB_Any, "^[\t]*[\ ]*ProcedureDLL([\s\S]*?)\(([\s\S]*?)^[\s]*EndProcedure", #PB_RegularExpression_MultiLine | #PB_RegularExpression_NoCase)	
  
  If ExamineRegularExpression(regex_Procedure, ServerCode)
    
    While NextRegularExpressionMatch(regex_Procedure)
      
      CurrentProcedure = RegularExpressionMatchString(regex_Procedure)
      
      ProcName = Trim(RemoveString(CurrentProcedure, "ProcedureDLL", #PB_String_NoCase))
      
      If Left(ProcName, 2) = ".s"
        ProcName = Trim(Mid(ProcName, 3))
      EndIf
      
      ProcName = Trim(StringField(ProcName, 1, "("))
      
      RequestSelect + #TAB$ + "Case " + Chr(34) + LCase(ProcName) + Chr(34) + #CRLF$
      
      RequestSelect + #TAB$ + #TAB$ + "ReturnValue = " + ProcName + "("
      
      ProcedureLine = StringField(CurrentProcedure, 1, #LF$)
      
      Protected Parameters.s = ParseParameter(ProcedureLine)
      
      Protected Parameter.s
      
      For ParamCounter = 0 To CountString(Parameters, Chr(1))
        
        Parameter = Trim(StringField(Parameters, ParamCounter + 1, Chr(1)))
        
        If Parameter <> ""
          
          If LCase(Left(Parameter, Len("list"))) = "list" Or 
             LCase(Left(Parameter, Len("map"))) = "map" Or
             Left(Parameter, 1) = "*"
            
            ProcedureReturn "CompilerError:\n" + ProcName + "\nLists, Maps And Pointers are not allowed (yet)"
            
          EndIf
          
          RequestSelect + "Request.Form(" + Str(ParamCounter + 1) + "), "
          
        EndIf
        
      Next
      
      If EndsWith(Trim(RequestSelect), ",")
        RequestSelect = Left(Trim(RequestSelect), Len(Trim(RequestSelect)) - 1)
      EndIf
      
      RequestSelect + ")" + #CRLF$
      
    Wend
    
    FreeRegularExpression(regex_Procedure)
    
  EndIf
  
  If RequestSelect <> ""
    
	  RequestSelect = "Dim myRequest = LCase(Request.Form(0))" + #CRLF$ +
                    "Select Case myRequest" + #CRLF$ +
                    RequestSelect + 
                    #TAB$ + "Case Else" + #CRLF$ +
                    #TAB$ + #TAB$ + "ReturnValue = " + Chr(34) + "unknown request: '" + Chr(34) + " & myRequest & " + Chr(34) + "'" + Chr(34) + #CRLF$ +
                    "End Select"
    
  EndIf
  
  ; Debug RequestSelect
  
  ProcedureReturn RequestSelect
	
EndProcedure


Procedure.s ConvertToPbCgi(Code.s)
  ProcedureReturn Code
EndProcedure
Procedure.s ConvertToAspx(Code.s)
		
	Code = #LF$ + Code
	
	Protected Lexer.iPBSC = New_PBSC() 	
	
	Protected RequestSelect.s
	
	Code = ReplaceString(Code, #CRLF$, #LF$)
	
	Lexer\SetFileString(Code)
	
	NewList TT.Token()
	
	; Token einlesen
	While Lexer\IsNextToken() 
		AddElement(TT())
		TT()\Token = Lexer\GetNextToken() 
		TT()\Type  = Lexer\GetCurrentType() 
		TT()\Line = Lexer\GetCurrentLineNb()
	Wend
	
	PBSC_CloseFile(Lexer)
	
	Protected inProcedure
	
	ForEach TT()
		Select TT()\Type
			Case #PBSC_Identifier
				Select LCase(TT()\Token)
				  Case "proceduredll"
				    
						TT()\Token = "Public Shared Function"
						
						inProcedure = #True
						
						If CheckNextToken(TT(), ".")
						  NextElement(TT()) : TT()\Token = ""
						  NextElement(TT()) : TT()\Token = ""
						EndIf
						
						NextElement(TT())
						
						; TT()\Token = LCase(TT()\Token)
						
					Case "endprocedure"
						TT()\Token = "End Function"
				EndSelect
			Case #PBSC_NewLine, #PBSC_Comment
				inProcedure = #False
			Default
				If inProcedure
					If TT()\Token = "."
						TT()\Token = ""
						NextElement(TT())
						TT()\Token = ""
					EndIf
				EndIf
				If TT()\Token = "!"
					TT()\Token = ""
				EndIf
		EndSelect
	Next
	
	Code = ""
	
	ForEach TT()
		If CheckNextToken(TT(), ".")
			Code + TT()\Token
		ElseIf TT()\Token = "."
			Code + TT()\Token
		Else
			Code + TT()\Token + " "
		EndIf
	Next
	
	ProcedureReturn Code
	
EndProcedure
Procedure.s ConvertToPHP(Code.s)
		
	Code = #LF$ + Code
	
	Protected Lexer.iPBSC = New_PBSC() 	
	
	Protected RequestSelect.s
	
	Code = ReplaceString(Code, #CRLF$, #LF$)
	
	Lexer\SetFileString(Code)
	
	NewList TT.Token()
	
	; Token einlesen
	While Lexer\IsNextToken() 
		AddElement(TT())
		TT()\Token = Lexer\GetNextToken() 
		TT()\Type  = Lexer\GetCurrentType() 
		TT()\Line = Lexer\GetCurrentLineNb()
	Wend
	
	PBSC_CloseFile(Lexer)
	
	Protected inProcedure
	
	ForEach TT()
		Select TT()\Type
				
			Case #PBSC_Identifier
				
				Select LCase(TT()\Token)
					Case "proceduredll"
						TT()\Token = "function"
						inProcedure = #True
					Case "endprocedure"
						TT()\Token = "}"
				EndSelect
				
			Case #PBSC_NewLine
				
				If inProcedure
					TT()\Token = "{" + TT()\Token
				EndIf
				
				inProcedure = #False
				
				If CheckNextToken(TT(), "!")
					NextElement(TT())
					TT()\Token = ""
				EndIf
				
			Case #PBSC_Comment
				
				If inProcedure
					TT()\Token = "{ //" + Mid(TT()\Token, 2)
				EndIf
				
				inProcedure = #False
				
			Default
				If inProcedure
					Select TT()\Token
						Case "."
							TT()\Token = ""
							NextElement(TT())
							TT()\Token = ""
						Case "("
							NextElement(TT())
							If TT()\Token <> ")"
								TT()\Token = "$" + TT()\Token
							EndIf
						Case ","
							NextElement(TT())
							TT()\Token = "$" + TT()\Token
					EndSelect
				EndIf
		EndSelect
	Next
	

	
	Code = ""
	
	ForEach TT()
		If CheckNextToken(TT(), ".")
			Code + TT()\Token
		ElseIf CheckNextToken(TT(), ":")
			Code + TT()\Token
		ElseIf CheckNextToken(TT(), "/")
			Code + TT()\Token
		ElseIf TT()\Token = "."
			Code + TT()\Token
		ElseIf TT()\Token = "/"
			Code + TT()\Token
		ElseIf TT()\Token = "!"
			Code + TT()\Token
		ElseIf TT()\Token = ":"
			Code + TT()\Token
		ElseIf TT()\Token = "$"
			Code + TT()\Token
		ElseIf TT()\Token = "-" And CheckNextToken(TT(), ">")
			Code + TT()\Token
		ElseIf TT()\Token = "=" And CheckNextToken(TT(), ">")
			Code + TT()\Token
		ElseIf TT()\Token = "=" And CheckNextToken(TT(), "=")
			Code + TT()\Token
		ElseIf TT()\Token = "&" And CheckNextToken(TT(), "&")
			Code + TT()\Token
		Else
			If TT()\Type = #PBSC_Number
				Code + TT()\Token
			Else
				Code + TT()\Token + " "
			EndIf
		EndIf
	Next
	
	ProcedureReturn Code
	
EndProcedure
Procedure.s ConvertToASP(Code.s)
	
	Code = #LF$ + Code
	
	Protected Lexer.iPBSC = New_PBSC() 	
	
	Protected RequestSelect.s
	
	Code = ReplaceString(Code, #CRLF$, #LF$)
	
	Lexer\SetFileString(Code)
	
	NewList TT.Token()
	
	; Token einlesen
	While Lexer\IsNextToken() 
		AddElement(TT())
		TT()\Token = Lexer\GetNextToken() 
		TT()\Type  = Lexer\GetCurrentType() 
		TT()\Line = Lexer\GetCurrentLineNb()
	Wend
	
	PBSC_CloseFile(Lexer)
	
	Protected inProcedure
	
	ForEach TT()
		Select TT()\Type
			Case #PBSC_Identifier
				Select LCase(TT()\Token)
					Case "proceduredll"
						TT()\Token = "Function"
						inProcedure = #True
					Case "endprocedure"
						TT()\Token = "End Function"
				EndSelect
			Case #PBSC_NewLine, #PBSC_Comment
				inProcedure = #False
			Default
				If inProcedure
					If TT()\Token = "."
						TT()\Token = ""
						NextElement(TT())
						TT()\Token = ""
					EndIf
				EndIf
				If TT()\Token = "!"
					TT()\Token = ""
				EndIf
		EndSelect
	Next
	

	
	Code = ""
	
	ForEach TT()
		If CheckNextToken(TT(), ".")
			Code + TT()\Token
		ElseIf TT()\Token = "."
			Code + TT()\Token
		Else
			Code + TT()\Token + " "
		EndIf
	Next
	
	ProcedureReturn Code
	
EndProcedure
Procedure.s ConvertToNodeJs(Code.s)
	
	Code = #LF$ + Code
	
	NewList ProcedureName.s()
	
	Dim TempArray.s(0)
	Split(TempArray(), Code, #LF$)
	Protected Counter
	For Counter = 0 To ArraySize(TempArray())
		TempArray(Counter) = TrimChars(TempArray(Counter))
		If StartsWith(LCase(TempArray(Counter)), "proceduredll")
			
			AddElement(ProcedureName())
			ProcedureName() = ReplaceString(TempArray(Counter), "ProcedureDLL.s ", "", #PB_String_NoCase)
			ProcedureName() = Left(ProcedureName(), FindString(ProcedureName(), "(") - 1)
			
			TempArray(Counter) = ""
			
		EndIf
		If StartsWith(LCase(TempArray(Counter)), "endprocedure")
			TempArray(Counter) = ""
		EndIf
		If StartsWith(TempArray(Counter), "!")
			TempArray(Counter) = Mid(TempArray(Counter), 2)
		EndIf
	Next
	
	Code = " var PB2NodeJsFunctions = { }; "
	Code + Join(TempArray(), #LF$)
	ForEach ProcedureName()
		Code + "PB2NodeJsFunctions." + ProcedureName() + " = " + ProcedureName() + ";" + #LF$
	Next
	
	; Debug "ServerCode:>>>" + #LF$ + Code + #LF$ + "<<<"
	
	ProcedureReturn Code
	
EndProcedure
Procedure.s ConvertToPython(Code.s)
	
	Code = #LF$ + Code
	
	Protected Lexer.iPBSC = New_PBSC() 	
	
	Protected RequestSelect.s
	
	Code = ReplaceString(Code, #CRLF$, #LF$)
	
	; Whitespaces are important!
	Code = ReplaceString(Code, " ", Chr(1))
	Code = ReplaceString(Code, #TAB$, Chr(2))
	
	Lexer\SetFileString(Code)
	
	NewList TT.Token()
	
	; Token einlesen
	While Lexer\IsNextToken() 
		AddElement(TT())
		TT()\Token = Lexer\GetNextToken() 
		TT()\Type  = Lexer\GetCurrentType() 
		TT()\Line = Lexer\GetCurrentLineNb()
	Wend
	
	PBSC_CloseFile(Lexer)
	
	Protected inProcedure
	NewList vars.s()
	Protected ProcName.s
	ForEach TT()
		Select TT()\Type
				
			Case #PBSC_Identifier
				
				Select LCase(TT()\Token)
						
					Case "proceduredll", "procedurecdll"
						
						TT()\Token = "def "
						
						Define LI = ListIndex(TT())
						
						Repeat
							NextElement(TT())
							If TT()\Token = "("
								Break
							EndIf
						ForEver
						Repeat
							PreviousElement(TT())
							If TT()\Token <> Chr(1) And TT()\Token <> Chr(2)
								Break
							EndIf
						ForEver
						
						ProcName = TT()\Token
						
						SelectElement(TT(), LI)
						
						TT()\Token = "@app.route('/" + ProcName + "', methods=['POST'])" + #LF$ + TT()\Token
						
						inProcedure = #True
						
					Case "endprocedure"
						TT()\Token = ""
						ClearList(vars())
				EndSelect
				
			Case #PBSC_NewLine
				
				If inProcedure
					
					TT()\Token = ":" + TT()\Token
					
					ForEach vars()
						TT()\Token + " " + vars() + " = request.form.get('" + Str(ListIndex(vars())) + "')" + #LF$
					Next
					
					ClearList(vars())
					
				EndIf
				
				inProcedure = #False
				
			Case #PBSC_Comment
				
				If inProcedure
					
					TT()\Token = ": #" + Mid(TT()\Token, 2)
					
					ForEach vars()
						TT()\Token + " " + vars() + " = request.form.get('" + Str(ListIndex(vars())) + "')" + #LF$
					Next
					
					ClearList(vars())
					
				EndIf
				
				inProcedure = #False
				
			Default
				If inProcedure
					Select TT()\Token
						Case "."
							TT()\Token = ""
							NextElement(TT())
							TT()\Token = ""
						Case "("
							NextElement(TT())
							If TT()\Token <> ")"
								AddElement(vars())
								vars() = TT()\Token
								TT()\Token = ""
							EndIf
						Case ","
							TT()\Token = ""
							NextElement(TT())
							AddElement(vars())
							vars() = TT()\Token
							TT()\Token = ""
					EndSelect
				EndIf
				If TT()\Token = "!"
					TT()\Token = ""
				EndIf
		EndSelect
	Next
	

	
	Code = ""
	
	ForEach TT()
		Code + TT()\Token
	Next
	
	Code = ReplaceString(Code, Chr(1), " ")
	Code = ReplaceString(Code, Chr(2), #TAB$)
	
	Debug "ServerCode:>>>" + #LF$ + Code + #LF$ + "<<<"
	
	ProcedureReturn Code
	
EndProcedure

Procedure.s RemoveCodeIdentifier(CodeBlock.s, ServerCodeType.s)
	
	CodeBlock = Mid(CodeBlock, FindString(CodeBlock, "Enable" + ServerCodeType, 1, #PB_String_NoCase) + Len("Enable" + ServerCodeType))
	
	CodeBlock = Left(CodeBlock, FindString(CodeBlock, "Disable" + ServerCodeType, 1, #PB_String_NoCase) - 1)
	
	ProcedureReturn CodeBlock
	
EndProcedure

Procedure.s GetParentPath(Path.s)
  
  Protected ParentPath.s
  Protected Counter
  Protected PathSeparator.s
  
  If FindString(Path, "\")
    PathSeparator = "\"
  ElseIf FindString(Path, "/")
    PathSeparator = "/"
  Else
    ProcedureReturn ParentPath
  EndIf
  
  For Counter = 1 To CountString(Path, PathSeparator) - 1
    ParentPath + StringField(Path, Counter, PathSeparator) + PathSeparator
  Next
  
  ProcedureReturn ParentPath
  
EndProcedure

Procedure.s ProcessServerCode(FileContent.s, ServerCodeType.s)
	
	;{
	
  If FindString(FileContent, "Enable" + ServerCodeType, 1, #PB_String_NoCase) = 0
    ProcedureReturn FileContent
  EndIf
  
  Protected ServerFilename.s 
  Protected ServerAddress.s 
  Protected TemplateFilename.s
  
  Select ServerCodeType
      
    Case #ServerCodeType_Asp
      ServerAddress    = SpiderBiteCfg(SpiderBite_Profile)\AspServerAddress
      ServerFilename   = SpiderBiteCfg(SpiderBite_Profile)\AspServerFilename
      
      If SpiderBiteCfg(SpiderBite_Profile)\AspTemplate = ""
        SpiderBiteCfg(SpiderBite_Profile)\AspTemplate = GetExePath() + "system/templates/asp.asp"
      EndIf
      
      TemplateFilename = SpiderBiteCfg(SpiderBite_Profile)\AspTemplate
      
    Case #ServerCodeType_Aspx
      ServerAddress    = SpiderBiteCfg(SpiderBite_Profile)\AspxServerAddress
      ServerFilename   = SpiderBiteCfg(SpiderBite_Profile)\AspxServerFilename
      
      If SpiderBiteCfg(SpiderBite_Profile)\AspxTemplate = ""
        SpiderBiteCfg(SpiderBite_Profile)\AspxTemplate = GetExePath() + "system/templates/aspx.aspx"
      EndIf
      
      TemplateFilename = SpiderBiteCfg(SpiderBite_Profile)\AspxTemplate
      
    Case #ServerCodeType_PbCgi
      
      If FileSize(SpiderBiteCfg(SpiderBite_Profile)\PbCompiler) = -1
        FileContent = AddCompilerError(FileContent, "PbCompiler not set")
        ProcedureReturn FileContent
      EndIf
      
      ServerAddress    = SpiderBiteCfg(SpiderBite_Profile)\PbCgiServerAddress
      ServerFilename   = SpiderBiteCfg(SpiderBite_Profile)\PbCgiServerFilename
      
      If SpiderBiteCfg(SpiderBite_Profile)\PbCgiTemplate = ""
        SpiderBiteCfg(SpiderBite_Profile)\PbCgiTemplate = GetExePath() + "system/templates/cgi.pb"
      EndIf
      
      TemplateFilename = SpiderBiteCfg(SpiderBite_Profile)\PbCgiTemplate
      
    Case #ServerCodeType_Php
      ServerAddress    = SpiderBiteCfg(SpiderBite_Profile)\PhpServerAddress
      ServerFilename   = SpiderBiteCfg(SpiderBite_Profile)\PhpServerFilename
      
      If SpiderBiteCfg(SpiderBite_Profile)\PhpTemplate = ""
        SpiderBiteCfg(SpiderBite_Profile)\PhpTemplate = GetExePath() + "system/templates/php.php"
      EndIf
      
      TemplateFilename = SpiderBiteCfg(SpiderBite_Profile)\PhpTemplate
      
    Case #ServerCodeType_NodeJs
      FileContent = AddCompilerWarning(FileContent, "NodeJs is not supported (yet)")
      
    Case #ServerCodeType_Python
      
      ServerAddress    = SpiderBiteCfg(SpiderBite_Profile)\PythonServerAddress
      ServerFilename   = SpiderBiteCfg(SpiderBite_Profile)\PythonServerFilename
      
      If SpiderBiteCfg(SpiderBite_Profile)\PythonTemplate = ""
        SpiderBiteCfg(SpiderBite_Profile)\PythonTemplate = GetExePath() + "system/templates/python.py"
      EndIf
      
      TemplateFilename = SpiderBiteCfg(SpiderBite_Profile)\PythonTemplate
      
  EndSelect
  
  If ServerAddress = ""
    FileContent = AddCompilerError(FileContent, "ServerAddress for " + ServerCodeType + " is empty!")
    ProcedureReturn FileContent
  EndIf
  
  If ServerFilename = ""
    FileContent = AddCompilerError(FileContent, "ServerFilename for " + ServerCodeType + " is empty!")
    ProcedureReturn FileContent
  EndIf
  
  If FileSize(GetPathPart(ServerFilename)) <> -2
    FileContent = AddCompilerError(FileContent, "Folder '" + GetPathPart(ServerFilename) + "' doesn't exist")
    ProcedureReturn FileContent
  EndIf  	
  
  If TemplateFilename = ""
    FileContent = AddCompilerError(FileContent, "TemplateFilename for " + ServerCodeType + " is empty!")
    ProcedureReturn FileContent
  EndIf
  
  ;}
  
  Protected CodeBlock.s
  Protected ClientProcedures.s = ""
  Protected ServerCode.s
  Protected CurrentProcedure.s
  
  Protected regex_SC
  Protected regex_P
  
  regex_SC = CreateRegularExpression(#PB_Any, "^[\t]*[\ ]*Enable" + ServerCodeType + "([\s\S]*?)\(([\s\S]*?)^[\s]*Disable" + ServerCodeType + "", #PB_RegularExpression_MultiLine | #PB_RegularExpression_NoCase)	
  
  ExamineRegularExpression(regex_SC, FileContent)
  
  While NextRegularExpressionMatch(regex_SC)
  	
  	CodeBlock = RegularExpressionMatchString(regex_SC)
  	
  	regex_P = CreateRegularExpression(#PB_Any, "^[\t]*[\ ]*ProcedureDLL([\s\S]*?)\(([\s\S]*?)^[\s]*EndProcedure", #PB_RegularExpression_MultiLine | #PB_RegularExpression_NoCase)	
  	
  	ExamineRegularExpression(regex_P, CodeBlock)
  	
  	While NextRegularExpressionMatch(regex_P)
  	  
  	  CurrentProcedure = RegularExpressionMatchString(regex_P)
  	  
  		If LCase(Left(Trim(CurrentProcedure), Len("ProcedureDLL"))) = "proceduredll"
  		  CurrentProcedure = ReplaceString(CurrentProcedure, "ProcedureDLL", "Procedure", #PB_String_NoCase)
  		EndIf
  		
  		ClientProcedures + StringField(CurrentProcedure, 1, #LF$) + #LF$
  	  
  	  Protected dataType.s
  		Protected processData.s
  		
  		dataType = "text"
  		processData = "true"
  		
  		Protected CallbackProcedure.s
  		
  		CurrentProcedure  = StringField(CurrentProcedure, 1, "(")
  		
  		CurrentProcedure  = Trim(StringField(CurrentProcedure, CountString(CurrentProcedure, " ") + 1, " "))
  		
  		CallbackProcedure = "f_" + LCase(CurrentProcedure) + "callback"
  		
  		ClientProcedures + " ! var returnValue; " + #LF$ +
  		                   " ! [].unshift.call(arguments, '" + CurrentProcedure + "'); " + #LF$ +
  		                   " ! var async; " + #LF$ +
  		                   " ! var successFunction; " + #LF$ +
  		                   " ! var errorFunction; " + #LF$ +
  		                   " ! if (typeof " + CallbackProcedure + " == 'function') { " + #LF$ +
  		                   " !  async = true; " + #LF$ +
  		                   " ! 	successFunction = function(result) { " + CallbackProcedure + "(true, result); }; " + #LF$ +
  		                   " ! 	errorFunction = function(a,b,c) { " + CallbackProcedure + "(false, b + '/' + c); }; " + #LF$ +
  		                   " ! } else { " + #LF$ +
  		                   " !  async = false; " + #LF$ +
  		                   " ! 	successFunction = function(result) { returnValue = result; };" + #LF$ +
  		                   " ! 	errorFunction = function(a,b,c) { returnValue = 'error: ' + b + '/' + c; };" + #LF$ +
  		                   " ! }" + #LF$ +
  		                   " ! $.ajax({ " + #LF$ +
  		                   " ! 	url: '" + ServerAddress + "', " + #LF$ +
  		                   " ! 	type: 'POST', " + #LF$ +
  		                   " ! 	data: arguments, " + #LF$ +
  		                   " ! 	dataType: '" + dataType + "', " + #LF$ +
  		                   " ! 	processData: " + processData + ", " + #LF$ +
  		                   " ! 	async: async, " + #LF$ +
  		                   " ! 	cache: false, " + #LF$ +
  		                   " ! 	success: successFunction, " + #LF$ +
  		                   " ! 	error: errorFunction " + #LF$ +
  		                   " ! }); " + #LF$ +
  		                   " ! return returnValue; " + #LF$ +
  		                   "EndProcedure" + #LF$
  		
  	Wend
  	
  	FreeRegularExpression(regex_P)
  	
  	FileContent = ReplaceString(FileContent, CodeBlock, ClientProcedures)
  	
  	ServerCode + RemoveCodeIdentifier(CodeBlock, ServerCodeType) + #LF$
  	
  Wend
  
  FreeRegularExpression(regex_SC)
  
  ;{
  
  If ServerCode <> ""
    
    If SpiderBite_ByPass = #False
      
      Protected RequestSelect.s
      Protected TemplateCode.s
      
      Select ServerCodeType
          
        Case #ServerCodeType_Asp
          
          RequestSelect = GetRequestSelect4ASP(ServerCode)
          
          If Left(RequestSelect, Len("CompilerError")) = "CompilerError"
            
            FileContent = AddCompilerError(FileContent, Mid(RequestSelect, Len("CompilerError") + 3))
            
          Else
            
            ServerCode    = ConvertToASP(ServerCode)
            TemplateCode  = LoadTextFile(TemplateFilename)
            TemplateCode  = ReplaceString(TemplateCode, "' ### ServerCode ###", ServerCode)
            TemplateCode  = ReplaceString(TemplateCode, "' ### RequestSelect ###", RequestSelect)
            SaveTextFile(TemplateCode, ServerFilename)
            
          EndIf
          
        Case #ServerCodeType_Aspx
          
          RequestSelect = GetRequestSelect4Aspx(ServerCode)
          
          If Left(RequestSelect, Len("CompilerError")) = "CompilerError"
            
            FileContent = AddCompilerError(FileContent, Mid(RequestSelect, Len("CompilerError") + 3))
            
          Else
          
            ServerCode    = ConvertToAspx(ServerCode)
            TemplateCode  = LoadTextFile(TemplateFilename)
            TemplateCode  = ReplaceString(TemplateCode, "' ### ServerCode ###", ServerCode)
            TemplateCode  = ReplaceString(TemplateCode, "' ### RequestSelect ###", RequestSelect)
            SaveTextFile(TemplateCode, ServerFilename)
            
          EndIf
            
        Case #ServerCodeType_PbCgi
          
          RequestSelect = GetRequestSelect4PbCgi(ServerCode)
          
          If Left(RequestSelect, Len("CompilerError")) = "CompilerError"
            
            FileContent = AddCompilerError(FileContent, Mid(RequestSelect, Len("CompilerError") + 3))
            
          Else
            
            ServerCode    = ConvertToPbCgi(ServerCode)
            TemplateCode  = LoadTextFile(TemplateFilename)
            TemplateCode  = ReplaceString(TemplateCode, "; ### ServerCode ###", ServerCode)
            TemplateCode  = ReplaceString(TemplateCode, "; ### RequestSelect ###", RequestSelect)
            
            Protected CgiTempFilename.s
            
            CgiTempFilename = GetPathPart(SourceFile) + "tempcgi.pb"
            
            SaveTextFile(TemplateCode, CgiTempFilename)
            
            Protected FileDeleteCounter = 0
            
            Repeat
              
              If FileSize(ServerFilename) = -1
                Break
              EndIf
              
              DeleteFile(ServerFilename)
              
              FileDeleteCounter + 1
              
              If FileDeleteCounter > 9
                Break
              EndIf
              
              Delay(500)
              
            ForEver
            
            Protected PbCompiler.s = SpiderBiteCfg(SpiderBite_Profile)\PbCompiler
            
            CompilerIf #PB_Compiler_OS = #PB_OS_Windows
              PbCompiler      = Chr(34) + PbCompiler + Chr(34)
              CgiTempFilename = Chr(34) + CgiTempFilename + Chr(34)
              ServerFilename  = Chr(34) + ServerFilename + Chr(34)
              #Params = " /CONSOLE /EXE "
            CompilerElse
              #Params = " -e "
            CompilerEndIf
            
            SetEnvironmentVariable("PUREBASIC_HOME", GetParentPath(GetPathPart(SpiderBiteCfg(SpiderBite_Profile)\PbCompiler)))
            
            Protected Compiler = RunProgram(PbCompiler,
                                            CgiTempFilename + #Params + ServerFilename,
                                            "",
                                            #PB_Program_Open | #PB_Program_Read | #PB_Program_Hide)
            
            Protected ExitCode
            
            If Compiler
              
              Protected ProgramOutput.s
              
              While ProgramRunning(Compiler)
                If AvailableProgramOutput(Compiler)
                  ProgramOutput + ReadProgramString(Compiler) + #CRLF$
                EndIf
              Wend
              
              ExitCode = ProgramExitCode(Compiler)
              
              CloseProgram(Compiler) ; Close the connection to the program
              
              If ExitCode <> 0
                
                FileContent = AddCompilerError(FileContent, "Something went wrong :-(" + ReplaceString(ProgramOutput, #CRLF$, " / "))
                
              EndIf
              
            Else
              
              FileContent = AddCompilerError(FileContent, "Couldn't start Pbcompiler.")
              
            EndIf			  
            
            ; DeleteFile(CgiTempFilename)
            
          EndIf
          
        Case #ServerCodeType_Php
          
          RequestSelect = GetRequestSelect4PHP(ServerCode)
          
          If Left(RequestSelect, Len("CompilerError")) = "CompilerError"
            
            FileContent = AddCompilerError(FileContent, Mid(RequestSelect, Len("CompilerError") + 3))
            
          Else
          
            ServerCode   = ConvertToPHP(ServerCode)
            TemplateCode = LoadTextFile(TemplateFilename)
            TemplateCode = ReplaceString(TemplateCode, "// ### ServerCode ###",    ServerCode)
            TemplateCode = ReplaceString(TemplateCode, "// ### RequestSelect ###", RequestSelect)
            SaveTextFile(TemplateCode, ServerFilename)
            
          EndIf
            
        Case #ServerCodeType_Python
          
          ServerCode = ConvertToPython(ServerCode)
          TemplateCode = LoadTextFile(TemplateFilename)
          TemplateCode = ReplaceString(TemplateCode, "# ### ServerCode ###", ServerCode)
          SaveTextFile(TemplateCode, ServerFilename)
          
        Case #ServerCodeType_NodeJs
          ; not yet
          
      EndSelect
      
    EndIf
    
  EndIf
  
  ;}-
  
  ProcedureReturn FileContent
  
EndProcedure

Procedure LoadConfig()
  
  Protected Filename.s = GetExePath() + "SpiderBite.cfg"
  
  If LoadJSON(0, FileName)
    
    ExtractJSONMap(JSONValue(0), SpiderBiteCfg())
    
    ProcedureReturn #True
    
  EndIf
  
EndProcedure

Procedure PreProcess(SourceFile.s)
	
; 	AddLog("")
; 	AddLog("Preprocessing. Starting PureBasic...")
  
  Protected SbCompiler.s = GetEnvironmentVariable("PB_TOOL_Compiler")
  
	Protected Parameter.s = Chr(34) + SourceFile + Chr(34) + " /PREPROCESS " + Chr(34) + SourceFile + ".pp" + Chr(34)
	
	MessageRequester("!", SbCompiler + #CRLF$ + Parameter)
	
	Protected Compiler = RunProgram(Chr(34) + SbCompiler + Chr(34),
	                                Parameter, 
	                                "",
	                                #PB_Program_Open | #PB_Program_Read | #PB_Program_Hide)
	
	
	
	Protected ExitCode = 1
	
	If Compiler
		
		While ProgramRunning(Compiler)
			;If AvailableProgramOutput(Compiler)
				; AddLog(ReadProgramString(Compiler))
			;EndIf
		Wend
		
		ExitCode = ProgramExitCode(Compiler)
		
		CloseProgram(Compiler) ; Close the connection to the program
		
	Else
		
; 		AddLog("")
; 		AddLog("Something went wrong :-(", 1)
; 		AddLog("")
		
	EndIf
	
	If ExitCode = 0
		
		; PbFileContent = LoadTextfile(SourceFile + ".pp")
		
		ProcedureReturn #True
		
	Else
		
		; PbFileContent = ""
		
		ProcedureReturn #False
		
	EndIf  
	
EndProcedure

Procedure Main()
  
  Protected FileContent.s

  ; Before Compile/Run
  
  SourceFile.s = ProgramParameter() ; %COMPILEFILE!
  
  ; SourceFile = "C:\Users\Administrator\AppData\Local\Temp\8\PB_EditorOutput.pb.original"
  
  ; SourceFile = "/tmp/PB_EditorOutput2.pb"
  
  If SourceFile = "" ; no commandline-parameter
    MessageRequester(#AppName, "SourceFile = ''.")
    End
  EndIf
  
  If FileSize(SourceFile) = -1 ; File not found
    MessageRequester(#AppName, "File '" + SourceFile + "' not found.")
    End
  EndIf
  
  ; for SpiderBitePostCompile:
  DeleteFile(SourceFile + ".original")
  CopyFile(SourceFile, SourceFile + ".original")
  
  ; PreProcess(SourceFile)
  
  FileContent = LoadTextFile(SourceFile)
  
  GetSpiderByteConstants(FileContent)
  
  If SpiderBite_Profile <> ""
    
    If LoadConfig()
      
      If FindMapElement(SpiderBiteCfg(), SpiderBite_Profile)
        
        FileContent = ProcessServerCode(FileContent, #ServerCodeType_PbCgi)
        FileContent = ProcessServerCode(FileContent, #ServerCodeType_Php)
        FileContent = ProcessServerCode(FileContent, #ServerCodeType_Aspx)
        FileContent = ProcessServerCode(FileContent, #ServerCodeType_Asp)
        ; FileContent = ProcessServerCode(FileContent, #ServerCodeType_Python)
        ; FileContent = ProcessServerCode(FileContent, #ServerCodeType_NodeJs)
        
      Else
        
        FileContent = AddCompilerError(FileContent, "Profile '" + SpiderBite_Profile + "' not found!")
        
      EndIf
      
    Else
      
      FileContent = AddCompilerError(FileContent, "Couldn't load '" + GetPathPart(ProgramFilename()) + "SpiderBite.cfg!")
      
    EndIf
    
    ; Debug FileContent
    
    SaveTextFile(FileContent, SourceFile)
    
  EndIf
  
EndProcedure

Main()