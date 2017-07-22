CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  #PathSeparator = "\"
CompilerElse
  #PathSeparator = "/"
CompilerEndIf

Procedure.s GetExePath()
  Protected ExePath.s = GetPathPart(ProgramFilename())
  If LCase(ExePath) = LCase(GetTemporaryDirectory()) : ExePath = GetCurrentDirectory() : EndIf
  If Right(ExePath, 1) <> "/" : ExePath + "/" : EndIf
  ProcedureReturn ExePath
EndProcedure

Procedure StartsWith(String.s, StartString.s)
	If Left(String, Len(StartString)) = StartString
		ProcedureReturn #True
	Else
		ProcedureReturn #False
	EndIf
EndProcedure

Procedure EndsWith(String.s, EndString.s)
  If Right(String, Len(EndString)) = EndString
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
EndProcedure

#WHITESPACE$ = " " + #TAB$ + #CRLF$

Procedure.s LTrimChars (source$, charlist$ = #WHITESPACE$)
	; http://www.purebasic.fr/english/viewtopic.php?p=411500#p411500
	; removes from source$ all leading characters which are contained in charlist$
	Protected p, last=Len(source$)
	
	p = 1
	While p <= last And FindString(charlist$, Mid(source$,p,1)) <> 0
		p + 1
	Wend
	
	ProcedureReturn Mid(source$, p)
EndProcedure

Procedure.s RTrimChars (source$, charlist$ = #WHITESPACE$)
	; http://www.purebasic.fr/english/viewtopic.php?p=411500#p411500
	; removes from source$ all trailing characters which are contained in charlist$
	Protected p
	
	p = Len(source$)
	While p >= 1 And FindString(charlist$, Mid(source$,p,1)) <> 0
		p - 1
	Wend
	
	ProcedureReturn Left(source$, p)
	
EndProcedure

Macro TrimChars (_source_, _charlist_=#WHITESPACE$)
	; http://www.purebasic.fr/english/viewtopic.php?p=411500#p411500
	LTrimChars(RTrimChars(_source_, _charlist_), _charlist_)
EndMacro

Procedure Split(Array StringArray.s(1), StringToSplit.s, Separator.s = " ")
	; http://www.purebasic.fr/english/viewtopic.php?p=409005#p409005	
	Protected c = CountString(StringToSplit, Separator)
  Protected i, l = Len(Separator.s)
  Protected *p1.Character = @StringToSplit
  Protected *p2.Character = @Separator
  Protected *p = *p1
  ReDim StringArray(c)
  While i < c
    While *p1\c <> *p2\c
      *p1 + SizeOf(Character)
    Wend
    If CompareMemory(*p1, *p2, l)
      CompilerIf #PB_Compiler_Unicode
        StringArray(i) = PeekS(*p, (*p1 - *p) >> 1)
      CompilerElse
        StringArray(i) = PeekS(*p, *p1 - *p)
      CompilerEndIf
      *p1 + l
      *p = *p1
    EndIf
    i + 1
  Wend
  StringArray(c) = PeekS(*p)
  ProcedureReturn c
EndProcedure

Procedure.s Join(Array StringArray.s(1), Separator.s = "")
	; http://www.purebasic.fr/english/viewtopic.php?p=409005#p409005	
  Protected r.s, i, l, c = ArraySize(StringArray())
  While i <= c
    l + Len(StringArray(i))
    i + 1  
  Wend
  r = Space(l + Len(Separator) * c)
  i = 1
  l = @r
  CopyMemoryString(@StringArray(0), @l)
  While i <= c
    CopyMemoryString(@Separator)
    CopyMemoryString(@StringArray(i))
    i + 1  
  Wend
  ProcedureReturn r
EndProcedure

Procedure.s LoadTextFile(TextFilename.s)
  
  Protected FF
  Protected ReturnValue.s
  Protected StringFormat
  
  If FileSize(TextFilename) <= 0 : ProcedureReturn "" : EndIf
  FF = ReadFile(#PB_Any, TextFilename)
  If FF = 0 : ProcedureReturn "" : EndIf
  StringFormat = ReadStringFormat(FF)
  ReturnValue = ReadString(FF, #PB_File_IgnoreEOL | StringFormat)
  CloseFile(FF)
  
  ProcedureReturn ReturnValue
  
EndProcedure

Procedure SaveTextFile(TextFileContent.s, TextFileName.s, WriteStringFormat = #PB_Ascii)
  
  Protected FF
  FF = CreateFile(#PB_Any, TextFileName)
  If FF 
    WriteString(FF, TextFileContent, WriteStringFormat)
    CloseFile(FF)
  EndIf
  
EndProcedure