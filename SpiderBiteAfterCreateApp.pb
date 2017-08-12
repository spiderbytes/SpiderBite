EnableExplicit

Global SourceFile.s

#AppName = "SpiderBiteAfterCreateApp"
#AppVersion = "2017-08-12"

Procedure Main()
  
  ; After Create App
  
  SourceFile.s = ProgramParameter() ; %COMPILEFILE!
  
  If SourceFile = "" ; no commandline-parameter
    MessageRequester(#AppName, "SourceFile = ''.")
    End
  EndIf
  
  If FileSize(SourceFile) = -1 ; File not found
    MessageRequester(#AppName, "File '" + SourceFile + "' not found.")
    End
  EndIf
  
  If FileSize(SourceFile + ".original") > 0
  
    DeleteFile(SourceFile)
    
    RenameFile(SourceFile + ".original", SourceFile)
    
    DeleteFile(SourceFile + ".original")
    
  EndIf
  
EndProcedure

Main()