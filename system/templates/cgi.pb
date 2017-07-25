EnableExplicit

If Not InitCGI() Or Not ReadCGI()
  End 
EndIf

Global SpiderBite_Header_ContentType.s        = ""
Global SpiderBite_Header_Location.s           = ""
Global SpiderBite_Header_AccessControlAllowOrigin.s = ""

; ---

SpiderBite_Header_AccessControlAllowOrigin = "*"
SpiderBite_Header_ContentType = "text/plain;charset=UTF-8"

; ------------------
; ### ServerCode ###
; ------------------

Define Request.s = LCase(CGIParameterValue("", 0))

Define ReturnValue.s

; ---------------------
; ### RequestSelect ###
; ---------------------


If SpiderBite_Header_Location <> ""
  WriteCGIHeader(#PB_CGI_HeaderLocation, SpiderBite_Header_Location)
EndIf

If SpiderBite_Header_AccessControlAllowOrigin <> ""
  WriteCGIHeader("Access-Control-Allow-Origin", SpiderBite_Header_AccessControlAllowOrigin)
EndIf

WriteCGIHeader(#PB_CGI_HeaderContentType, SpiderBite_Header_ContentType, #PB_CGI_LastHeader)

WriteCGIString(ReturnValue)