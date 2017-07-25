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
	
	Try
	
		Dim myRequest As String
		
		Dim myListOfObjects As New List(Of Object)
		
		For Counter As Integer = 0 To Request.Form.Count - 1
			If Counter = 0
				myRequest = Request.Form(Counter)
			Else
				myListOfObjects.Add(Request.Form(Counter))
			End If
		Next

		If myRequest <> "" Then
		
			Dim myMethod As MethodInfo = MethodBase.GetCurrentMethod().DeclaringType.GetMethod(myRequest)
		
			If myMethod IsNot Nothing Then
				Dim myParamsArray = myListOfObjects.ToArray
				ReturnValue = myMethod.Invoke(Nothing, myParamsArray)
			Else
				ReturnValue = "Unknown Request '" & myRequest & "'"
			End If
			
		Else
		
			ReturnValue = "Unknown Request"
			
		End If

	Catch ex As Exception

		ReturnValue = "Error" ' ex.Message
	
	End Try
	
	Response.ContentType = SpiderBite_Header_ContentType
	
	If Not String.IsNullOrEmpty(SpiderBite_Header_AccessControlAllowOrigin) Then
		Response.AppendHeader("Access-Control-Allow-Origin", SpiderBite_Header_AccessControlAllowOrigin)
	End If
	
	Response.Write(ReturnValue)
	
End Sub

</script>