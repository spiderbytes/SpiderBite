EnableExplicit

If Not InitCGI() Or Not ReadCGI()
  End 
EndIf

Global PB_CGI_HeaderContentType.s        = ""
Global PB_CGI_HeaderLocation.s           = ""
Global PB_CGI_AccessControlAllowOrigin.s = ""

; ---

PB_CGI_AccessControlAllowOrigin = "*"
PB_CGI_HeaderContentType = "text/plain;charset=UTF-8"

; ------------------
; ### ServerCode ###
; ------------------

Define Request.s = LCase(CGIParameterValue("", 0))

Define ReturnValue.s

; ---------------------
; ### RequestSelect ###
; ---------------------


If PB_CGI_HeaderLocation <> ""
  WriteCGIHeader(#PB_CGI_HeaderLocation, PB_CGI_HeaderLocation)
EndIf

If PB_CGI_AccessControlAllowOrigin <> ""
  WriteCGIHeader("Access-Control-Allow-Origin", PB_CGI_AccessControlAllowOrigin)
EndIf

WriteCGIHeader(#PB_CGI_HeaderContentType, PB_CGI_HeaderContentType, #PB_CGI_LastHeader)

WriteCGIString(ReturnValue)