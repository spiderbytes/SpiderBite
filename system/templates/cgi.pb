EnableExplicit

If Not InitCGI() Or Not ReadCGI()
  End 
EndIf

Global PB_CGI_HeaderContentType.s = ""
Global PB_CGI_HeaderLocation.s = ""

PB_CGI_HeaderContentType.s = "text/plain;charset=UTF-8"
PB_CGI_HeaderContentType.s = "text/plain"

; ------------------
; ### ServerCode ###
; ------------------

Define Request.s = LCase(CGIParameterValue("", 0))

Define ReturnValue.s

; ---------------------
; ### RequestSelect ###
; ---------------------

WriteCGIHeader(#PB_CGI_HeaderContentType, PB_CGI_HeaderContentType)

If PB_CGI_HeaderLocation <> ""
  WriteCGIHeader(#PB_CGI_HeaderLocation, PB_CGI_HeaderLocation)
EndIf

WriteCGIHeader("Access-Control-Allow-Origin", "*", #PB_CGI_LastHeader)

WriteCGIString(ReturnValue)

; IDE Options = PureBasic 5.60 (Windows - x64)
; ExecutableFormat = Console
; CursorPosition = 33
; EnableOnError
; Executable = D:\xampp\cgi-bin\cgi54.exe
; EnableUnicode