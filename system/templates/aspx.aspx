<%@ Page Language="VB"  %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Web.Script.Serialization" %>
<%@ Import Namespace="System.Reflection" %>

<script language="VB" runat="server">

	Public Shared SpiderBite_Header_ContentType As String = ""
	Public Shared SpiderBite_Header_Location As String = ""
	Public Shared SpiderBite_Header_AccessControlAllowOrigin As String = ""

' ### ServerCode ###

Sub Page_Load(o as Object, e as EventArgs)

	SpiderBite_Header_ContentType = "text/plain;charset=UTF-8"
	SpiderBite_Header_AccessControlAllowOrigin = "*"
	
	Dim ReturnValue As String = ""

	' ### RequestSelect ###
	
	Response.ContentType = SpiderBite_Header_ContentType
	
	If Not String.IsNullOrEmpty(SpiderBite_Header_AccessControlAllowOrigin) Then
		Response.AppendHeader("Access-Control-Allow-Origin", SpiderBite_Header_AccessControlAllowOrigin)
	End If
	
	Response.Write(ReturnValue)
	
End Sub

</script>