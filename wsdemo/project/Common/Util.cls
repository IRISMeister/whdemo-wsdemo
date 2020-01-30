Include %occErrors

Class Common.Util Extends %RegisteredObject
{

ClassMethod GetSiteInfo() As %List
{
	//namespaces
	Return $LISTBUILD("WSHQ","WSDC","WSDC2","MAKER")
}

/// generate WebService clients
ClassMethod GenTaskClient(user = "appuser", pass = "sys") As %Status
{
	Set r=##class(%SOAP.WSDL.Reader).%New()

	;Set r.ClientPackage="WSHQ.WC"
	Set server="http://wshq:52773/csp/wshq"
	Set r.MakePersistent=1
	Set url=server_"/WSHQ.Task.CLS?WSDL=1&IRISUserName="_user_"&IRISPassword="_pass
	Do r.Process(url)

	;Set r.ClientPackage="MAKER.WC"
	Set server="http://maker:52773/csp/maker"
	Set r.MakePersistent=1
	Set url=server_"/MAKER.Task.CLS?WSDL=1&IRISUserName="_user_"&IRISPassword="_pass
	Do r.Process(url)

	;Set r.ClientPackage="WSDC.WC"
	Set server="http://wsdc1:52773/csp/wsdc"
	Set r.MakePersistent=1
	Set url=server_"/WSDC.Task.CLS?WSDL=1&IRISUserName="_user_"&IRISPassword="_pass
	Do r.Process(url)

	Return $$$OK
}

/// generate WebService clients
ClassMethod GenWSClient(user = "appuser", pass = "sys") As %Status
{
	Set r=##class(%SOAP.WSDL.Reader).%New()
		
	#; Other services are re-written to REST/JSON based apis. Following is left on puropose.
	#; You have to manually move generated classes (WSDC.Maker.WSDC.MakerSoap,WSDC.Maker.DeliveryNote,WSDC.Maker.DeliveryNoteContainer) to 
	#; wsdc/project/WSDC/Maker/WSDC folder of whdemo-wsdc project.
	Set server="http://wsdc1:52773/csp/wsdc"
	;Set r.ClientPackage="WSDC.WC"
	Set r.MakePersistent=1
	Set url=server_"/WSDC.Service.Maker.CLS?WSDL=1&CacheUserName="_user_"&CachePassword="_pass
	Do r.Process(url)
	
	Do ..GenTaskClient(user, pass)
	Return $$$OK
}

ClassMethod GetTodayOrg()
{
	Return +$H
}

ClassMethod GetToday()
{
	Return $G(^Common.BaseDate,$ZDATEH("2001-01-01",3,,,,,,,"err"))
}

ClassMethod GetTodayLastUpdate()
{
	Return $G(^Common.BaseDate("last"))
}

ClassMethod SetToday(today = "")
{
	Set h=$ZDATEH(today,3,,,,,,,"err")
	If h'="err" {
		Set ^Common.BaseDate=h
	}
	Else {
		Set ^Common.BaseDate=+$H
	}
	Set ^Common.BaseDate("last")=$H
}

ClassMethod IncrementToday()
{
	If $INCREMENT(^Common.BaseDate)
	Set ^Common.BaseDate("last")=$H
	Return ^Common.BaseDate
}

ClassMethod GetWSHQClient(host = "localhost", port = 52773) As %SOAP.WebClient
{
	Set wsClient=##class(WSHQ.WSHQSoap).%New()
	;Set wsClient.Location="http://"_host_":"_port_"/csp/wshq/WSHQ.Task.cls"
	Set utoken=..GetUsernameToken()
	Do wsClient.SecurityOut.AddSecurityElement(utoken)
	Return wsClient
}

ClassMethod GetWSDCClient(host = "localhost", port = 52773) As %SOAP.WebClient
{
	Set wsClient=##class(WSDC.WSDCSoap).%New()
	;Set wsClient.Location="http://"_host_":"_port_"/csp/wsdc/WSDC.Task.cls"
	Set utoken=..GetUsernameToken()
	Do wsClient.SecurityOut.AddSecurityElement(utoken)
	Return wsClient
}

ClassMethod GetMAKERClient(host = "localhost", port = 52773) As %SOAP.WebClient
{
	Set wsClient=##class(MAKER.MAKERSoap).%New()
	;Set wsClient.Location="http://"_host_":"_port_"/csp/maker/MAKER.Task.cls"
	Set utoken=..GetUsernameToken()
	Do wsClient.SecurityOut.AddSecurityElement(utoken)
	Return wsClient
}

ClassMethod GetUsernameToken() As %SOAP.Security.UsernameToken
{
	Set user="appuser"
	Set pwd="sys"
	Set utoken=##class(%SOAP.Security.UsernameToken).Create(user,pwd)
	Return utoken
}

ClassMethod ClearAll() As %Status
{
	#; There is no production in WSDEMO server at the moment.	
	#; purge Ensemble/Activity Voulme and Duration
	/*
	Set tSC=##class(Ens.Activity.Utils).Purge(0,"s",.c)
	Set tSC=##class(Ens.Activity.Utils).Purge(0,"hh",.c)
	Set tSC=##class(Ens.Activity.Utils).Purge(0,"d",.c)
	*/
	
	#;ダミー日付を初期化
	Do ##class(Common.Util).SetToday("2001-01-01")
	
	W "HQ環境のクリーンアップ",!
	Set wsClient=##class(Common.Util).GetWSHQClient()
	Set tSC=wsClient.StopProduction()
	Set tSC=wsClient.ClearAll()
		
	W "WSDC1環境のクリーンアップ",!
	Set wsClient=##class(Common.Util).GetWSDCClient()
	Set tSC=wsClient.StopProduction()
	Set tSC=wsClient.ClearAll()

	W "WSDC2環境のクリーンアップ",!
	Set wsClient=##class(Common.Util).GetWSDCClient()
	Set wsClient.Location="http://wsdc2:52773/csp/wsdc/WSDC.Task.cls"
	Set tSC=wsClient.StopProduction()
	Set tSC=wsClient.ClearAll()

	W "Maker環境のクリーンアップ",!
	Set wsClient=##class(Common.Util).GetMAKERClient()
	Set tSC=wsClient.StopProduction()
	Set tSC=wsClient.ClearAll()

	Return $$$OK
}

ClassMethod StartAll() As %Status
{
	W "HQ環境の開始",!
	Set wsClient=##class(Common.Util).GetWSHQClient()
	Set tSC=wsClient.StartProduction()
		
	W "WSDC1環境の開始",!
	Set wsClient=##class(Common.Util).GetWSDCClient()
	Set tSC=wsClient.StartProduction()

	W "WSDC2環境の開始",!
	Set wsClient=##class(Common.Util).GetWSDCClient()
	Set wsClient.Location="http://wsdc2:52773/csp/wsdc/WSDC.Task.cls"
	Set tSC=wsClient.StartProduction()

	W "Maker環境の開始",!
	Set wsClient=##class(Common.Util).GetMAKERClient()
	Set tSC=wsClient.StartProduction()

	Return $$$OK
}

ClassMethod StopAll() As %Status
{
	W "HQ環境の停止",!
	Set wsClient=##class(Common.Util).GetWSHQClient()
	Do wsClient.StopProduction()
		
	W "WSDC1環境の停止",!
	Set wsClient=##class(Common.Util).GetWSDCClient()
	Do wsClient.StopProduction()

	W "WSDC2環境の停止",!
	Set wsClient=##class(Common.Util).GetWSDCClient()
	Set wsClient.Location="http://wsdc2:52773/csp/wsdc/WSDC.Task.cls"
	Do wsClient.StopProduction()

	W "Maker環境の停止",!
	Set wsClient=##class(Common.Util).GetMAKERClient()
	Do wsClient.StopProduction()

	Return $$$OK
}

ClassMethod AddEnsembleCredential() As %Status
{
	Set tSC=##class(Ens.Config.Credentials).SetCredential("default", "appuser", "sys")
	Set tSC=##class(Ens.Config.Credentials).SetCredential("ensemble-email", "user1", "xxx")
	
	Return $$$OK
}

}
