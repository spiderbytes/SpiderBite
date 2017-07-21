; http://www.purebasic.fr/german/viewtopic.php?p=338156#p338156

;- Design by Contract Macros
#CONTRACTS = #False


Macro require
EndMacro

Macro body
EndMacro

Macro ensure
EndMacro

Macro returns
	ProcedureReturn
EndMacro

Macro DQ
	"
EndMacro

Macro assert(cond, label="")
	CompilerIf #CONTRACTS
		If Not(cond)
			CompilerIf #PB_Compiler_Debugger
				Debug label+": Line "+Str(#PB_Compiler_Line)+": Contract violated: "+#DQUOTE$+DQ#cond#DQ+#DQUOTE$+" is false"
				CallDebugger
			CompilerElse
				MessageRequester("Contract violated", label+": Line "+Str(#PB_Compiler_Line)+": Contract violated "+DQ#cond#DQ+" is false")
			CompilerEndIf
		EndIf
	CompilerEndIf
EndMacro

Macro implies(a, b)
	((Not (a)) Or (b))
EndMacro

EnableExplicit 



Enumeration 0 
	#PBSC_Other  ; Operators, other symbols 
	#PBSC_Identifier ; all variables, structures, pseudotypes, functions, pointer, constants... 
	#PBSC_Number		 ; 'numb', 466, $ FFFF, %10001, 1.0e-4, etc. 
	#PBSC_String		 ; "this is a String!" 
	#PBSC_Comment		 ; the whole rest of the line starting with a ';' 
	#PBSC_NewLine		 ; a new line begins, Token = #LF$
	#PBSC_TypeEnumerationEnd
EndEnumeration 

Interface iPBSC 
	SetFile.l(FileName.s) 
	SetFileString(FileAsString.s) 
	SetFileLine(Line.l) 
	IsNextToken.l() 
	GetNextToken.s() 
	GetCurrentLineNb.l() 
	GetCurrentType.l() 
	CloseFile() 
EndInterface 

Structure cPBSC 
	*VTable 
	
	File.s 
	FileLine.l 
	FileMaxLine.l 
	
	Line.s 
	Started.l 
	
	CurrentType.l 
	
	LastToken.s 
	LastTokenType.l 
	PreLastToken.s 
	PreLastTokenType.l 
	PrePreLastToken.s 
	PrePreLastTokenType.l 
EndStructure 


Procedure _PBSC_SetLastToken(*this.cPBSC, s.s)
	require
	assert(*this <> 0 And Len(s) <> 0)
	body
	;Static PreLastToken.s = #LF$ 
	If *this\PreLastToken = "" : *this\PreLastToken = #LF$ : EndIf 
	*this\PrePreLastToken = *this\PreLastToken 
	*this\PreLastToken = *this\LastToken 
	*this\LastToken = s
	ensure
	assert(*this\LastToken = s)
	returns
EndProcedure 

Procedure _PBSC_SetTokenType(*this.cPBSC, Type.l)
	require
	assert(Type >= -1 And Type < #PBSC_TypeEnumerationEnd)
	assert(*this <> 0)
	body
	If Type = -1 
		*this\PrePreLastTokenType = #PBSC_Other 
		*this\PreLastTokenType = #PBSC_Other 
		*this\LastTokenType = #PBSC_Other 
		*this\CurrentType = #PBSC_Other 
	Else 
		*this\PrePreLastTokenType = *this\PreLastTokenType 
		*this\PreLastTokenType = *this\CurrentType 
		*this\LastTokenType = Type 
		*this\CurrentType = Type 
	EndIf
	ensure
	
	returns
EndProcedure 

Procedure.l PBSC_SetFile(*this.cPBSC, FileName.s) 
	require
	assert(*this <> 0)
	assert(Len(FileName) <> 0 And FileSize(FileName) <> -1 And FileSize(FileName) <> -2)
	body
	Protected FileID.l, Format.l, Result.l = #False
	
	FileID = ReadFile(#PB_Any, FileName) 
	If IsFile(FileID) 
		*this\FileLine = 1 
		_PBSC_SetLastToken(*this, #LF$) 
		_PBSC_SetTokenType(*this, -1) 
		*this\Line = "" 
		*this\Started = #True 
		
		Format = ReadStringFormat(FileID) 
		Select Format 
			Case #PB_Ascii, #PB_UTF8, #PB_Unicode 
				
				*this\FileMaxLine = 0 
				While Not Eof(FileID) 
					*this\FileMaxLine + 1 
					*this\File + ReadString(FileID, Format) + #LF$ 
				Wend 
				
				CloseFile(FileID)
				Result = #True 
				
			Default 
				CloseFile(FileID) 
				Result = #False 
		EndSelect
	EndIf
	ensure
	assert(Result = #False Or Result = #True)
	returns Result
EndProcedure 

Procedure PBSC_SetFileString(*this.cPBSC, FileAsString.s) ; lines separated with #LF$!
	require
	assert(*this <> 0)
	assert(Len(FileAsString) <> 0)
	body
	*this\File     = FileAsString 
	*this\FileLine = 1 
	_PBSC_SetLastToken(*this, #LF$) 
	_PBSC_SetTokenType(*this, -1) 
	*this\Line     = "" 
	*this\Started  = #True 
	*this\FileMaxLine = CountString(*this\File, #LF$) + 1
	ensure
	assert(*this\FileMaxLine >= *this\FileLine)
	returns
EndProcedure 

Procedure PBSC_SetFileLine(*this.cPBSC, Line.l)
	require
	assert(*this <> 0)
	assert(Line <= *this\FileMaxLine + 1) ; +1 because a loop could use this feature
																				; to iterate through all the lines
																				; but more than +1 should be a bug
	body
	*this\FileLine = Line 
	*this\Line     = "" 
	*this\Started  = #True 
	_PBSC_SetLastToken(*this, #LF$) 
	_PBSC_SetTokenType(*this, -1) 
	ensure
	
	returns
EndProcedure 

Procedure.l PBSC_IsNextToken(*this.cPBSC)
	require
	assert(*this <> 0)
	assert(*this\File, "no file loaded") 
	body 
	Protected Result.l
	If *this\File And (*this\FileLine <= *this\FileMaxLine Or Len(*this\Line) <> 0) 
		Result = #True 
	Else 
		Result = #False 
	EndIf
	ensure
	assert(Result = #True Or Result = #False)
	returns Result
EndProcedure 

Procedure.s _PBSC_ReadLine(*this.cPBSC) 
	require
	assert(*this <> 0)
	assert(*this\File, "no file loaded")
	body
	Protected Result.s
	
	If *this\File 
		*this\FileLine + 1 
		Result = StringField(*this\File, *this\FileLine - 1, #LF$) 
	Else
		Result = ""
	EndIf
	ensure
	returns Result
EndProcedure 

Procedure.s _PBSC_Trim(*this.cPBSC, s.s) 
	require
	assert(*this <> 0)
	body
	Protected *p.CHARACTER, *n.CHARACTER, Result.s
	
	*p = @s 
	While (*p\c = ' ' Or *p\c = 9) And *p\c 
		*p + SizeOf(CHARACTER) 
	Wend 
	; *p zeigt auf Start des Textes 
	
	; suche Ende 
	*n = *p 
	While *n\c <> 0 
		*n + SizeOf(CHARACTER) 
	Wend 
	
	*n - SizeOf(CHARACTER) 
	While (*n\c = ' ' Or *n\c = 9) And *n > *p 
		*n - SizeOf(CHARACTER) 
	Wend 
	
	Result = PeekS(*p, (*n + SizeOf(CHARACTER) - *p)/SizeOf(CHARACTER)) 
	ensure
	assert(PeekC(@Result) <> ' ' And PeekC(@Result) <> 9, "l-trimming failed")
	assert(PeekC(@Result + Len(Result) - 1) <> ' ' And PeekC(@Result + Len(Result) - 1) <> 9, "r-trimming failed")
	returns Result
EndProcedure 

Procedure.l _PBSC_GetIdentifier(*this.cPBSC, s.s)
	require
	assert(*this <> 0)
	assert(Len(s) <> 0)
	body
	Protected z.l, Len.l, ToLen.l = 0, Const.l = 0, PseudoType.l = 0, Temp.s 
	Protected LastToken.s, notptr.l 
	
	If *this\LastToken = "." And (PeekC(@s) = 'p' Or PeekC(@s) = 'P') And PeekC(@s+SizeOf(CHARACTER)) = '-' 
		PseudoType = 1 
		ToLen = 2 
	EndIf 
	
	If PseudoType = 0 
		If PeekC(@s) = '#' 
			If *this\LastTokenType = #PBSC_Identifier Or *this\LastTokenType = #PBSC_Other 
				Temp = LCase(*this\LastToken) 
				Select Temp 
					Case "to", "procedurereturn", "select", "case", "if", "elseif", "compilerselect" 
						Const = 1 : ToLen = 1 
					Case "compilercase", "compilerif", "compilerelseif", "break", "while", "until", "with"
						Const = 1 : ToLen = 1 
					Case "debug", "end", "and", "or", "xor", "not", "#", "includefile", "xincludefile", "includepath", "includebinary"
						Const = 1 : ToLen = 1 
					Case ",","/","+","-","%","!","~","|","&","<<",">>","<",">","<=",">=","=","<>","(","[","{",":" 
						Const = 1 : ToLen = 1 
					Case "*" 
						If *this\LastTokenType = #PBSC_Identifier 
							ProcedureReturn 0 
						Else 
							Const = 1 : ToLen = 1 
						EndIf 
					Default 
						ProcedureReturn 0 
				EndSelect 
			ElseIf *this\LastTokenType = #PBSC_NewLine 
				Const = 1 : ToLen = 1 
			Else 
				ProcedureReturn 0 
			EndIf 
			
		ElseIf PeekC(@s) = '*' 
			notptr = #True 
			If *this\LastTokenType = #PBSC_Identifier Or *this\LastTokenType = #PBSC_Other 
				Temp = LCase(*this\LastToken) 
				Select Temp 
					Case "to", "procedurereturn", "select", "case", "if", "elseif", "compilerselect" 
						notptr = #False 
					Case "while", "until", "protected", "define", "global", "shared", "static", "with"
						notptr = #False 
					Case "debug", "end", "and", "or", "xor", "not", "#" 
						notptr = #False 
					Case "dim", "newlist", "newmap"
						notptr = #False
					Case ",","/","+","-","%","!","~","|","&","<<",">>","<",">","<=",">=","=","<>","@","(","[","{",":" 
						notptr = #False 
					Case "*" 
						If *this\LastTokenType = #PBSC_Identifier 
							notptr = #True 
						Else 
							notptr = #False 
						EndIf 
					Default 
						notptr = #True 
				EndSelect 
			ElseIf *this\LastTokenType = #PBSC_NewLine 
				notptr = #False 
			EndIf 
			If notptr And *this\PrePreLastTokenType = #PBSC_Identifier 
				Temp = LCase(LastToken) 
				Select Temp 
					Case "protected", "define", "global", "shared", "static" 
						notptr = #False 
				EndSelect 
			EndIf 
			
			If notptr = #False 
				Const = 1 : ToLen = 1 
			EndIf 
			
			If Const <> 1 
				ProcedureReturn 0 
			EndIf 
		EndIf 
		
		If Const 
			z = 1 
			While (PeekC(@s+z*SizeOf(CHARACTER)) = ' ' Or PeekC(@s+z*SizeOf(CHARACTER)) = 9) 
				Const + 1 
				z + 1 
				ToLen + 1 
			Wend 
		EndIf 
		
		Select PeekC(@s + Const*SizeOf(CHARACTER)) 
			Case '_', 'a' To 'z', 'A' To 'Z' 
				ToLen + 1 
			Default 
				ProcedureReturn 0 
		EndSelect 
	EndIf 
	
	Len = Len(s) 
	For z = 2+Const+PseudoType To Len 
		Select Asc(Mid(s, z, 1)) 
			Case '_', 'a' To 'z', 'A' To 'Z', '0' To '9', '$' 
				ToLen + 1 
			Default 
				_PBSC_SetTokenType(*this, #PBSC_Identifier) 
				ProcedureReturn ToLen 
		EndSelect 
	Next 
	
	_PBSC_SetTokenType(*this, #PBSC_Identifier) 
	ProcedureReturn ToLen
	;   ensure
	;   returns
EndProcedure 

Procedure.l _PBSC_GetString(*this.cPBSC, s.s)
	require
	assert(*this <> 0)
	assert(Len(s) <> 0)
	body
	Protected z.l, Len.l, ToLen.l = 0, SearchString.l, startPos.l, countBackslashes.i 
	
	; only for escaped strings like ~"..."
	countBackslashes = -1
	
	If PeekC(@s) = '"' 
		SearchString = #True 
		ToLen = 1 
		startPos = 2
	ElseIf Len(s) > 1 And PeekS(@s,2) = Chr(126) + Chr(34) ; opener of escaped string: ~"
		SearchString = #True 
		countBackslashes = 0
		ToLen = 2 
		startPos = 3
	ElseIf PeekC(@s) = Asc("'") 
		SearchString = #False 
		ToLen = 1 
		startPos = 2
	Else 
		ProcedureReturn 0 
	EndIf 
	
	Len = Len(s) 
	For z = startPos To Len 
		If SearchString 
			Select Asc(Mid(s, z, 1)) 
				Case '"' 
					If (countBackslashes = -1) Or (countBackslashes % 2 = 0)  ; only even nb of backslashes allowed before escaped string closing
						_PBSC_SetTokenType(*this, #PBSC_String) 
						ProcedureReturn ToLen + 1 
					Else
						If countBackslashes <> -1
							countBackslashes = 0    ; reset repeated backslashes
						EndIf
						ToLen + 1
					EndIf
				Case '\'
					If countBackslashes <> -1
						countBackslashes + 1    ; count repeated backslashes
					EndIf
					ToLen + 1
				Default 
					If countBackslashes <> -1
						countBackslashes = 0    ; reset repeated backslashes
					EndIf
					ToLen + 1 
			EndSelect 
		Else 
			Select Asc(Mid(s, z, 1)) 
				Case Asc("'") 
					_PBSC_SetTokenType(*this, #PBSC_Number) 
					ProcedureReturn ToLen + 1 
				Default 
					ToLen + 1 
			EndSelect 
		EndIf 
	Next 
	
	_PBSC_SetTokenType(*this, #PBSC_String) 
	ProcedureReturn ToLen 
	;   ensure
	;   returns
EndProcedure 

Procedure.l _PBSC_GetNumber(*this.cPBSC, s.s)
	require
	assert(*this)
	assert(Len(s) <> 0)
	body 
	Protected z.l, Len.l, ToLen.l = 0, Digit.l = #False, Hex.l = #False, Spec.l = 0 
	Protected lastChar.c 
	
	If PeekC(@s) = '$' 
		Hex = #True 
		ToLen = 1 
		Spec = 1 
	ElseIf PeekC(@s) = '%' 
		If *this\LastTokenType = #PBSC_Identifier Or *this\LastTokenType = #PBSC_Number 
			ProcedureReturn 0 
		ElseIf *this\LastToken = ")" Or *this\LastToken = "]" 
			ProcedureReturn 0 
		EndIf 
		ToLen = 1 
		Spec = 1 
	EndIf 
	
	Len = Len(s) 
	For z = (1+Spec) To Len 
		If Hex 
			Select Asc(Mid(s, z, 1)) 
				Case '0' To '9', 'a' To 'f', 'A' To 'F' 
					ToLen + 1 
					Digit = #True 
				Case ' ', 9
					If _PBSC_Trim(*this, Left(s, z-1)) = "$"
						ToLen + 1 
					Else
						_PBSC_SetTokenType(*this, #PBSC_Number) 
						ProcedureReturn ToLen 
					EndIf
				Default 
					If Digit 
						_PBSC_SetTokenType(*this, #PBSC_Number) 
						ProcedureReturn ToLen 
					Else 
						ProcedureReturn 0 
					EndIf 
			EndSelect 
		Else 
			Select Asc(Mid(s, z, 1)) 
				Case '0' To '9', '.', 'e', 'E' 
					If Digit = #False And (Asc(Mid(s, z, 1)) = '.' Or Asc(LCase(Mid(s, z, 1))) = 'e') 
						ProcedureReturn 0 
					EndIf 
					If LCase(Mid(s, z, 1)) = "e" 
						Select Asc(Mid(s, z-1, 1)) 
							Case '0' To '9', '.' 
							Default 
								_PBSC_SetTokenType(*this, #PBSC_Number) 
								ProcedureReturn ToLen 
						EndSelect 
					EndIf 
					lastChar = Asc(Mid(s, z, 1)) 
					ToLen + 1 
					Digit = #True 
				Case '+', '-' 
					If Digit 
						If lastChar = 'e' Or lastChar = 'E' 
							ToLen + 1 
						Else 
							_PBSC_SetTokenType(*this, #PBSC_Number) 
							ProcedureReturn ToLen 
						EndIf 
					Else 
						ProcedureReturn 0 
					EndIf 
				Case ' ', 9
					If _PBSC_Trim(*this, Left(s, z-1)) = "%"
						ToLen + 1 
					Else
						_PBSC_SetTokenType(*this, #PBSC_Number) 
						ProcedureReturn ToLen 
					EndIf
				Default 
					If Digit 
						_PBSC_SetTokenType(*this, #PBSC_Number) 
						ProcedureReturn ToLen 
					Else 
						ProcedureReturn 0 
					EndIf 
			EndSelect 
		EndIf 
	Next 
	
	_PBSC_SetTokenType(*this, #PBSC_Number) 
	ProcedureReturn ToLen 
	;ensure
	;returns
EndProcedure 

Procedure.l _PBSC_GetDOperator(*this.cPBSC, s.s)
	require
	assert(*this <> 0)
	assert(Len(s) <> 0)
	body
	Protected Result.l = -1
	
	Select PeekC(@s) 
		Case '<', '>' 
			Select PeekC(@s+SizeOf(CHARACTER)) 
				Case '>', '<', '=' 
					_PBSC_SetTokenType(*this, #PBSC_Other) 
					Result = 2 
			EndSelect 
	EndSelect 
	
	If Result <> 2
		Result = 0 
	EndIf
	ensure
	assert(Result = 2 Or Result = 0)
	returns Result
EndProcedure 

Procedure.l _PBSC_FindToken(*this.cPBSC, s.s) 
	require
	assert(*this <> 0)
	assert(Len(s) <> 0)
	body
	; ok: Kommentare als Ganzes 
	; ok: Strings als Ganzes (auch mit ' umklammerte) 
	; ok: Bezeichner als Ganzes (auch #KONST, String$, *Ptr) 
	; ok: Pseudotypen als Ganzes 
	; ok: Zahlen: 2001, $5461, %454 
	; ok: Doppeloperatoren 
	Static RetVal.l = 0 
	
	If PeekC(@s) = ';' 
		_PBSC_SetLastToken(*this, s) 
		_PBSC_SetTokenType(*this, #PBSC_Comment) 
		RetVal = Len(s) 
	Else
		RetVal = _PBSC_GetIdentifier(*this, s) 
		If RetVal 
			_PBSC_SetLastToken(*this, Left(s, RetVal)) 
		Else
			RetVal = _PBSC_GetString(*this, s) 
			If RetVal 
				_PBSC_SetLastToken(*this, Left(s, RetVal)) 
			Else
				RetVal = _PBSC_GetNumber(*this, s) 
				If RetVal 
					_PBSC_SetLastToken(*this, Left(s, RetVal)) 
				Else
					RetVal = _PBSC_GetDOperator(*this, s) 
					If RetVal 
						_PBSC_SetLastToken(*this, Left(s, RetVal)) 
					Else
						_PBSC_SetLastToken(*this, Mid(s, 1, 1)) 
						_PBSC_SetTokenType(*this, #PBSC_Other) 
						RetVal = 1
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
	ensure
	assert(RetVal > 0)
	returns RetVal
EndProcedure 

Procedure.s PBSC_GetNextToken(*this.cPBSC) 
	require
	assert(*this <> 0)
	assert(*this\FileLine <= *this\FileMaxLine + 1, "searching outside of file")
	body
	Protected s0.s, Token.s, Len.l, Result.s 
	
	; Line is trimmed or empty (if set by string and not by file)!
	If *this\File And (*this\FileLine <= *this\FileMaxLine Or Len(*this\Line) <> 0) 
		
		If *this\Line = "" 
			_PBSC_SetTokenType(*this, #PBSC_NewLine) 
			_PBSC_SetLastToken(*this, #LF$) 
			
			s0 = _PBSC_ReadLine(*this) 
			*this\Line = _PBSC_Trim(*this, s0) 
			
			If ( Not *this\Started) Or (*this\Started And *this\Line = "") 
				Result = #LF$ 
			Else 
				*this\Started = #False 
			EndIf 
		EndIf 
		
		If Result <> #LF$
			Len = _PBSC_FindToken(*this.cPBSC, *this\Line) 
			Token = Left(*this\Line, Len) 
			
			*this\Line = _PBSC_Trim(*this, Mid(*this\Line, FindString(*this\Line, Token, 1)+Len(Token), Len(*this\Line)-Len(Token))) 
			
			Result = _PBSC_Trim(*this, Token)
		EndIf
	Else 
		Result = "" 
	EndIf
	ensure
	returns Result
EndProcedure 

Procedure.l PBSC_GetCurrentLineNb(*this.cPBSC)
	require
	assert(*this <> 0)
	assert(*this\FileMaxLine > 0, "no string loaded")
	body
	Protected Result.l
	
	If *this\Started = #False And *this\LastToken = #LF$ 
		Result = *this\FileLine - 2 
	Else 
		Result = *this\FileLine - 1 
	EndIf
	ensure
	assert(Result > 0 And Result <= *this\FileMaxLine)
	returns Result
EndProcedure 

Procedure.l PBSC_GetCurrentType(*this.cPBSC)
	require
	assert(*this <> 0)
	body 
	Protected Result.l
	Result = *this\CurrentType 
	ensure
	assert(Result >= 0 And Result < #PBSC_TypeEnumerationEnd)
	returns Result
EndProcedure 

Procedure PBSC_CloseFile(*this.cPBSC)
	require
	assert(*this <> 0)
	assert(Len(*this\File) <> 0)
	body
	*this\File = "" 
EndProcedure 

DataSection 
	cPBSC_VT: 
	Data.i @PBSC_SetFile(), @PBSC_SetFileString(), @PBSC_SetFileLine(), @PBSC_IsNextToken(), @PBSC_GetNextToken() 
	Data.i @PBSC_GetCurrentLineNb(), @PBSC_GetCurrentType(), @PBSC_CloseFile() 
EndDataSection 

Procedure.i New_PBSC()
	require
	body
	Protected *obj.cPBSC 
	
	*obj = AllocateMemory(SizeOf(cPBSC)) 
	If *obj    
		*obj\VTable = ?cPBSC_VT 
	EndIf
	ensure
	assert(*obj <> 0, "couldn't create object")
	returns *obj
EndProcedure

Procedure Delete_PBSC(*obj.cPBSC)
	If *obj
		With *obj
			\File.s = ""
			\Line.s = ""
			\LastToken.s = ""
			\PreLastToken.s = ""
			\PrePreLastToken.s = ""
		EndWith
		
		FreeMemory(*obj)
	EndIf
EndProcedure
; IDE Options = PureBasic 5.50 (Windows - x86)
; CursorPosition = 1
; Folding = ------
; EnableXP
; EnableCompileCount = 5
; EnableBuildCount = 0
; EnableExeConstant
; EnableUnicode