EnableExplicit

Global SourceFile.s

#AppName = "SpiderBite"

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

Global NewMap SpiderBiteCfg.sSpiderBiteCfg()

Global ProfileName.s

XIncludeFile "includes/inc.lexer.pbi"
XIncludeFile "includes/functions.pbi"

Structure Token
  Token.s
  Type.i
  Line.i
EndStructure

Global NewList Token.Token()

Procedure.s AddCompilerError(FileContent.s, Message.s)
  FileContent = "CompilerError " + Chr(34) + Message + Chr(34) + #CRLF$ + FileContent
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

Procedure GetConstants(FileContent.s)
  
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
		          ProfileName = RemoveString(ConstantValue, Chr(34))
		      EndSelect
		      
		    EndIf
		EndSelect
	Next
	
EndProcedure

Procedure.s GetRequestSelect4PbCgi(ServerCode.s)
    
  Protected Lexer.iPBSC = New_PBSC() 	
  
  Protected RequestSelect.s
  
  ServerCode = ReplaceString(ServerCode, #CRLF$, #LF$)
  
  Lexer\SetFileString(ServerCode)
  
  ClearList(Token())
  
  ; Token einlesen
  While Lexer\IsNextToken() 
    AddElement(Token())
    Token()\Token = Lexer\GetNextToken() 
    Token()\Type  = Lexer\GetCurrentType() 
    Token()\Line = Lexer\GetCurrentLineNb()
  Wend
  
  PBSC_CloseFile(Lexer)
  
  Protected *Old_Element
  Protected isExport
  
  Protected ProcName.s
  
  Protected isString
  
  Protected ParamCounter
  
  ForEach Token()
  	
  	Select Token()\Type
  			
  		Case #PBSC_Identifier
  			
  			If LCase(Token()\Token) = "procedure"
  				
  				ParamCounter = 1 ; ParamCounter starts at 1!
  				
  				isString = #False
  				
  				NextElement(Token())
  				
  				If Token()\Token = "."
  					
  					NextElement(Token())
  					
  					If LCase(Token()\Token) = "s"
  						isString = #True
  					EndIf
  					
  					NextElement(Token())
  					
  				EndIf
  				
  				ProcName = Token()\Token
  				
  				RequestSelect + #TAB$ + "Case " + Chr(34) + LCase(ProcName) + Chr(34) + #CRLF$
  				
  				If isString
  					RequestSelect + #TAB$ + #TAB$ + "ReturnValue = " + ProcName + "("
  				Else
  					RequestSelect + #TAB$ + #TAB$ + "ReturnValue = Str(" + ProcName + "("
  				EndIf
  				
  				NextElement(Token()) ; Klammer auf
  				NextElement(Token()) ; Klammer zu?
  				
  				While Token()\Token <> ")"
  					
  					RequestSelect + " CGIParameterValue(" + Chr(34) + Chr(34) + ", " + ParamCounter + "), "
  					
  					ParamCounter + 1
  					
  					; RequestSelect + " GetValue(" + Chr(34) + Token()\Token + Chr(34) + "), "
  					
  					If CheckNextToken(Token(), ".")
  						NextElement(Token())
  						NextElement(Token())
  					EndIf
  					
  					If CheckNextToken(Token(), ",")
  						NextElement(Token())
  					EndIf
  					
  					NextElement(Token())
  					
  				Wend
  				
  				If EndsWith(Trim(RequestSelect), ",")
  					RequestSelect = Left(Trim(RequestSelect), Len(Trim(RequestSelect)) - 1)
  				EndIf
  				
  				If isString
  					RequestSelect + ")" + #CRLF$
  				Else
  					RequestSelect + "))" + #CRLF$
  				EndIf
  				
  			EndIf
  			
  	EndSelect
  Next
  
  If RequestSelect <> ""
    
    RequestSelect = " Select Request " + #CRLF$ +
                    RequestSelect + #CRLF$ +
                    " Default " + #CRLF$ +
                    "   ReturnValue = " + Chr(34) + "unknown request: '" + Chr(34) + " + Request + " + Chr(34) + "'" + Chr(34) + #CRLF$ +
                    " EndSelect"  
    
  EndIf
  
  ; Debug RequestSelect
  
  ProcedureReturn RequestSelect
  
EndProcedure
Procedure.s GetRequestSelect4Asp(ServerCode.s)
  
	Protected Lexer.iPBSC = New_PBSC() 	
	
	Protected RequestSelect.s
	
	ServerCode = ReplaceString(ServerCode, #CRLF$, #LF$)
	
	Lexer\SetFileString(ServerCode)
	
	ClearList(Token())
	
	; Token einlesen
	While Lexer\IsNextToken() 
		AddElement(Token())
		Token()\Token = Lexer\GetNextToken() 
		Token()\Type  = Lexer\GetCurrentType() 
		Token()\Line = Lexer\GetCurrentLineNb()
	Wend
	
	PBSC_CloseFile(Lexer)
	
	Protected *Old_Element
	Protected isExport
	
	Protected ProcName.s
	
	Protected ParamCounter
	
	ForEach Token()
		Select Token()\Type
			Case #PBSC_Identifier
			  Select LCase(Token()\Token)
			      
					Case "procedure"
					  
					  ParamCounter = 2 ; paramcounter start at 2!!!
					  
						NextElement(Token())
						
						If Token()\Token = "."
							
							NextElement(Token())
							NextElement(Token())
							
						EndIf
						
						ProcName = Token()\Token
						
						RequestSelect + #TAB$ + "Case " + Chr(34) + LCase(ProcName) + Chr(34) + #CRLF$
						
						RequestSelect + #TAB$ + #TAB$ + "Response.Write " + ProcName + " ( "
						
						NextElement(Token()) ; Klammer auf
						NextElement(Token()) ; Klammer zu?
						
						While Token()\Token <> ")"
							
							RequestSelect + " Request.Form(" + ParamCounter + "), "
							
							ParamCounter + 1
							
							If CheckNextToken(Token(), ".")
								NextElement(Token())
								NextElement(Token())
							EndIf
							
							If CheckNextToken(Token(), ",")
								NextElement(Token())
							EndIf
							
							NextElement(Token())
							
						Wend
						
						If EndsWith(Trim(RequestSelect), ",")
							RequestSelect = Left(Trim(RequestSelect), Len(Trim(RequestSelect)) - 1)
						EndIf
						
						RequestSelect + " ) " + #CRLF$
						
				EndSelect
		EndSelect
	Next
	
	If RequestSelect <> ""
		
	  RequestSelect = "Dim myRequest" + #CRLF$ + 
	                  "myRequest = LCase(Request.Form(1))" + #CRLF$ +
		                "" + #CRLF$ +
		                "Select Case myRequest" + #CRLF$ +
		                RequestSelect + #CRLF$ +
		                "Case Else" + #CRLF$ +
		                " Response.Write " + Chr(34) + "unknown request: '" + Chr(34) + " & myRequest & " + Chr(34) + "'" + Chr(34) + #CRLF$ +
		                "End Select"  
		
	EndIf
	
	;Debug RequestSelect
	
	ProcedureReturn RequestSelect
	
EndProcedure
Procedure.s GetRequestSelect4Aspx(ServerCode.s)
	
	Protected Lexer.iPBSC = New_PBSC() 	
	
	Protected RequestSelect.s
	
	ServerCode = ReplaceString(ServerCode, #CRLF$, #LF$)
	
	Lexer\SetFileString(ServerCode)
	
	ClearList(Token())
	
	; Token einlesen
	While Lexer\IsNextToken() 
		AddElement(Token())
		Token()\Token = Lexer\GetNextToken() 
		Token()\Type  = Lexer\GetCurrentType() 
		Token()\Line = Lexer\GetCurrentLineNb()
	Wend
	
	PBSC_CloseFile(Lexer)
	
	Protected *Old_Element
	Protected isExport
	
	Protected ProcName.s
	
	Protected ParamCounter

	ForEach Token()
		Select Token()\Type
			Case #PBSC_Identifier
				Select LCase(Token()\Token)
					Case "procedure"
					  
					  ParamCounter = 1 ; ASPX Startindex = 1!!!
					  
						NextElement(Token())
						
						If Token()\Token = "."
							
							NextElement(Token())
							NextElement(Token())
							
						EndIf
						
						ProcName = Token()\Token
						
						RequestSelect + #TAB$ + "Case " + Chr(34) + LCase(ProcName) + Chr(34) + #CRLF$
						
						RequestSelect + #TAB$ + #TAB$ + "Response.Write(" + ProcName + "("
						
						NextElement(Token()) ; Klammer auf
						NextElement(Token()) ; Klammer zu?
						
						While Token()\Token <> ")"
							
							RequestSelect + "Request.Form(" + ParamCounter + "), "
							
							ParamCounter + 1
							
							If CheckNextToken(Token(), ".")
								NextElement(Token())
								NextElement(Token())
							EndIf
							
							If CheckNextToken(Token(), ",")
								NextElement(Token())
							EndIf
							
							NextElement(Token())
							
						Wend
						
						If EndsWith(Trim(RequestSelect), ",")
							RequestSelect = Left(Trim(RequestSelect), Len(Trim(RequestSelect)) - 1)
						EndIf
						
						RequestSelect + "))" + #CRLF$
						
				EndSelect
		EndSelect
	Next
	
	If RequestSelect <> ""
		
	  RequestSelect = "Dim myRequest As String" + #CRLF$ +
	                  "myRequest = LCase(Request.Form(0))" + #CRLF$ +
		                "" + #CRLF$ +
		                "Select Case myRequest" + #CRLF$ +
		                RequestSelect + #CRLF$ +
		                "Case Else" + #CRLF$ +
		                " Response.Write(" + Chr(34) + "unknown request: '" + Chr(34) + " & myRequest & " + Chr(34) + "'" + Chr(34) + ")" + #CRLF$ +
		                "End Select"  
		
	EndIf
	
	;Debug RequestSelect
	
	ProcedureReturn RequestSelect
	
EndProcedure

Procedure.s ConvertToPbCgi(Code.s)
  ProcedureReturn Code
EndProcedure
Procedure.s ConvertToASPX(Code.s)
		
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
					Case "procedure"
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
					Case "procedure"
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
					Case "procedure"
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
	
	CodeBlock = Mid(CodeBlock, FindString(CodeBlock, "Enable" + ServerCodeType) + Len("Enable" + ServerCodeType))
	
	CodeBlock = Left(CodeBlock, FindString(CodeBlock, "Disable" + ServerCodeType) - 1)
	
	ProcedureReturn CodeBlock
	
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
      ServerAddress    = SpiderBiteCfg(ProfileName)\AspServerAddress
      ServerFilename   = SpiderBiteCfg(ProfileName)\AspServerFilename
      TemplateFilename = SpiderBiteCfg(ProfileName)\AspTemplate
      
    Case #ServerCodeType_Aspx
      ServerAddress    = SpiderBiteCfg(ProfileName)\AspxServerAddress
      ServerFilename   = SpiderBiteCfg(ProfileName)\AspxServerFilename
      TemplateFilename = SpiderBiteCfg(ProfileName)\AspxTemplate
      
    Case #ServerCodeType_PbCgi
      
      If FileSize(SpiderBiteCfg(ProfileName)\PbCompiler) = -1
        FileContent = AddCompilerError(FileContent, "PbCompiler not set")
        ProcedureReturn FileContent
      EndIf
      
      ServerAddress    = SpiderBiteCfg(ProfileName)\PbCgiServerAddress
      ServerFilename   = SpiderBiteCfg(ProfileName)\PbCgiServerFilename
      TemplateFilename = SpiderBiteCfg(ProfileName)\PbCgiTemplate
      
    Case #ServerCodeType_Php
      ServerAddress    = SpiderBiteCfg(ProfileName)\PhpServerAddress
      ServerFilename   = SpiderBiteCfg(ProfileName)\PhpServerFilename
      TemplateFilename = SpiderBiteCfg(ProfileName)\PhpTemplate
      
    Case #ServerCodeType_NodeJs
      FileContent = AddCompilerWarning(FileContent, "NodeJs is not supported (yet)")
      
    Case #ServerCodeType_Python
      FileContent = AddCompilerWarning(FileContent, "Python is not supported (yet)")
      
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
  
  Protected regex_SC
  Protected regex_P
  
  regex_SC = CreateRegularExpression(#PB_Any, "^[\t]*[\ ]*Enable" + ServerCodeType + "([\s\S]*?)\(([\s\S]*?)^[\s]*Disable" + ServerCodeType + "", #PB_RegularExpression_MultiLine | #PB_RegularExpression_NoCase)	
  
  ExamineRegularExpression(regex_SC, FileContent)
  
  While NextRegularExpressionMatch(regex_SC)
  	
  	CodeBlock = RegularExpressionMatchString(regex_SC)
  	
  	regex_P = CreateRegularExpression(#PB_Any, "^[\t]*[\ ]*Procedure([\s\S]*?)\(([\s\S]*?)^[\s]*EndProcedure", #PB_RegularExpression_MultiLine | #PB_RegularExpression_NoCase)	
  	
  	ExamineRegularExpression(regex_P, CodeBlock)
  	
  	While NextRegularExpressionMatch(regex_P)
  		
  		ClientProcedures + StringField(RegularExpressionMatchString(regex_P), 1, #LF$) + #LF$
  		
  		Protected dataType.s
  		Protected processData.s
  		
  		dataType = "text"
  		processData = "true"
  		
  		Protected CallbackProcedure.s
  		
  		CallbackProcedure = StringField(ClientProcedures, 1, "(")
  		CallbackProcedure = Trim(StringField(CallbackProcedure, CountString(CallbackProcedure, " ") + 1, " "))
  		CallbackProcedure + "Callback"
  		CallbackProcedure = "f_" + LCase(CallbackProcedure)
  		
  		ClientProcedures + " ! var returnValue; " + #LF$ +
  		                   " ! [].unshift.call(arguments, arguments.callee.name.substring(2)); " + #LF$ +
  		                   " ! var async; " + #LF$ +
  		                   " ! var successFunction; " + #LF$ +
  		                   " ! var errorFunction; " + #LF$ +
  		                   " ! if (typeof " + CallbackProcedure + " == 'function') { " + #LF$ +
  		                   " !   async = true; " + #LF$ +
  		                   " ! 	successFunction = function(result) { " + CallbackProcedure + "(true, result); }; " + #LF$ +
  		                   " ! 	errorFunction = function(a,b,c) { " + CallbackProcedure + "(false, b + '/' + c); }; " + #LF$ +
  		                   " ! } else { " + #LF$ +
  		                   " !   async = false; " + #LF$ +
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
  
  ; ----------------------------------------------------------------------
  
  Protected RequestSelect.s
  Protected TemplateCode.s
  
  Select ServerCodeType
      
    Case #ServerCodeType_Asp
      RequestSelect = GetRequestSelect4ASP(ServerCode)
      ServerCode = ConvertToASP(ServerCode)
      TemplateCode = LoadTextFile(TemplateFilename)
      TemplateCode = ReplaceString(TemplateCode, "' ### ServerCode ###", ServerCode)
      TemplateCode = ReplaceString(TemplateCode, "' ### RequestSelect ###", RequestSelect)
      SaveTextFile(TemplateCode, ServerFilename)
      
    Case #ServerCodeType_Aspx
      RequestSelect = GetRequestSelect4ASPX(ServerCode)
      ServerCode = ConvertToASPX(ServerCode)
      TemplateCode = LoadTextFile(TemplateFilename)
      TemplateCode = ReplaceString(TemplateCode, "' ### ServerCode ###", ServerCode)
      TemplateCode = ReplaceString(TemplateCode, "' ### RequestSelect ###", RequestSelect)
      SaveTextFile(TemplateCode, ServerFilename)
      
    Case #ServerCodeType_PbCgi
      
      Protected CgiTempFilename.s
      
      ServerCode = ConvertToPbCgi(ServerCode)
      
      RequestSelect = GetRequestSelect4PbCgi(ServerCode)
      
      TemplateCode = LoadTextFile(TemplateFilename)
      
      TemplateCode = ReplaceString(TemplateCode, "; ### ServerCode ###", ServerCode)
      
      TemplateCode = ReplaceString(TemplateCode, "; ### RequestSelect ###", RequestSelect)
      
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
      
      Protected Compiler = RunProgram(Chr(34) + SpiderBiteCfg(ProfileName)\PbCompiler    + Chr(34) + " " + 
                                      Chr(34) + CgiTempFilename            + Chr(34) + " /CONSOLE /EXE " +
                                      Chr(34) + ServerFilename + Chr(34),
                                      "",
                                      "",
                                      #PB_Program_Open | #PB_Program_Read | #PB_Program_Hide)
      
      Protected ExitCode = 1
      
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
          
          FileContent = AddCompilerError(FileContent, "Something went wrong :-(" + RemoveString(ProgramOutput, #CRLF$))
          
        EndIf
        
      Else
        
        FileContent = AddCompilerError(FileContent, "Couldn't start Pbcompiler.")
        
      EndIf			  
      
      ; DeleteFile(CgiTempFilename)
      
    Case #ServerCodeType_Php
      ServerCode = ConvertToPHP(ServerCode)
      TemplateCode = LoadTextFile(TemplateFilename)
      TemplateCode = ReplaceString(TemplateCode, "// ### ServerCode ###", ServerCode)
      SaveTextFile(TemplateCode, ServerFilename)
      
    Case #ServerCodeType_Python
      ; not yet
      
    Case #ServerCodeType_NodeJs
      ; not yet
      
  EndSelect
  
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

Procedure Main()
  
  ; Before Compile/Run
  
  ; %PATH : Path of the current source. Empty if the source wasn't saved yet.
  ; %FILE : Filename and Path of the current source. Empty if it wasn't saved yet.
  ; %TEMPFILE : A temporary copy of the source file. You may modify or delete this at will.
  ; %COMPILEFILE : The temporary file that is sent to the compiler. You can modify it to change the actual compiled source.
  ; %EXECUTABLE : Before and after Compilation the name of the created executable
  ; %CURSOR : The current cursor position given as 'LINExCOLUMN' (ie '15x10')
  ; %SELECTION : The current selection given as 'LINESTARTxCOLUMNSTARTxLINEENDxCOLUMNEND' (ie '15x1x16x5')
  ; %WORD : The word that is under the current cursor position.
  ; %HOME : The SpiderBasic directory.
  ; %PROJECT : The directory where the project file resides if there is an open project.
  
  SourceFile.s = ProgramParameter() ; %COMPILEFILE!
  
  ; SourceFile = "C:\Users\tuebben\AppData\Local\Temp\PB_EditorOutput2.pb"
  
  If SourceFile = "" ; no commandline-parameter
    MessageRequester(#AppName, "SourceFile = ''.")
    End
  EndIf
  
  If FileSize(SourceFile) = -1 ; File not found
    MessageRequester(#AppName, "File '" + SourceFile + "' not found.")
    End
  EndIf
  
  Protected FileContent.s
  
  FileContent = LoadTextFile(SourceFile)
  
  GetConstants(FileContent)
  
  If ProfileName <> ""
  	
  	If LoadConfig()
  		
  		If FindMapElement(SpiderBiteCfg(), ProfileName)
  			
  			FileContent = ProcessServerCode(FileContent, #ServerCodeType_PbCgi)
  			FileContent = ProcessServerCode(FileContent, #ServerCodeType_Php)
  			FileContent = ProcessServerCode(FileContent, #ServerCodeType_Aspx)
  			FileContent = ProcessServerCode(FileContent, #ServerCodeType_Asp)
  			; FileContent = ProcessServerCode(FileContent, #ServerCodeType_Python)
				; FileContent = ProcessServerCode(FileContent, #ServerCodeType_NodeJs)
  			
  		Else
  			
  			FileContent = AddCompilerError(FileContent, "Profile '" + ProfileName + "' not found!")
  			
  		EndIf
  		
  	Else
  		
  		FileContent = AddCompilerError(FileContent, "Couldn't load '" + GetPathPart(ProgramFilename()) + "SpiderBite.cfg!")
  		
  	EndIf
  	
  EndIf
  
  Debug FileContent
  
  SaveTextFile(FileContent, SourceFile)
  
EndProcedure

Main()