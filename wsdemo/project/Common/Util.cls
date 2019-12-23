Include %occErrors

Class Common.Util Extends %RegisteredObject
{

ClassMethod GetSiteInfo() As %List
{
	//namespaces
	Return $LISTBUILD("WSHQ","WSDC","WSDC2","MAKER")
}

ClassMethod GenAllClient(host = "localhost", port = "52773", namespace = "wsdemo", user = "appuser", pass = "sys") As %Status
{
	Set r=##class(%SOAP.WSDL.Reader).%New()
	Set server="http://"_host_":"_port_"/csp/"_namespace

	;Set r.ClientPackage="WSHQ.WC"
	Set r.MakePersistent=1
	Set url=server_"/WSHQ.Task.CLS?WSDL=1&CacheUserName="_user_"&CachePassword="_pass
	Do r.Process(url)

	Set r.MakePersistent=1
	Set url=server_"/WSHQ.Service.DC.CLS?WSDL=1&CacheUserName="_user_"&CachePassword="_pass
	Do r.Process(url)

	;Set r.ClientPackage="MAKER.WC"
	Set r.MakePersistent=1
	Set url=server_"/MAKER.Task.CLS?WSDL=1&CacheUserName="_user_"&CachePassword="_pass
	Do r.Process(url)
	
	;Set r.ClientPackage="MAKER.WC"
	Set r.MakePersistent=1
	Set url=server_"/MAKER.Service.HQ.CLS?WSDL=1&CacheUserName="_user_"&CachePassword="_pass
	Do r.Process(url)

	;Set r.ClientPackage="WSDC.WC"
	Set r.MakePersistent=1
	Set url=server_"/WSDC.Task.CLS?WSDL=1&CacheUserName="_user_"&CachePassword="_pass
	Do r.Process(url)

	;Set r.ClientPackage="WSDC.WC"
	Set r.MakePersistent=1
	Set url=server_"/WSDC.Service.HQ.CLS?WSDL=1&CacheUserName="_user_"&CachePassword="_pass
	Do r.Process(url)
	
	;Set r.ClientPackage="WSDC.WC"
	Set r.MakePersistent=1
	Set url=server_"/WSDC.Service.Maker.CLS?WSDL=1&CacheUserName="_user_"&CachePassword="_pass
	Do r.Process(url)
	
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
	Set wsClient.Location="http://"_host_":"_port_"/csp/wshq/WSHQ.Task.cls"
	Set utoken=..GetUsernameToken()
	Do wsClient.SecurityOut.AddSecurityElement(utoken)
	Return wsClient
}

ClassMethod GetWSDCClient(host = "localhost", port = 52773) As %SOAP.WebClient
{
	Set wsClient=##class(WSDC.WSDCSoap).%New()
	Set wsClient.Location="http://"_host_":"_port_"/csp/wsdc/WSDC.Task.cls"
	Set utoken=..GetUsernameToken()
	Do wsClient.SecurityOut.AddSecurityElement(utoken)
	Return wsClient
}

ClassMethod GetMAKERClient(host = "localhost", port = 52773) As %SOAP.WebClient
{
	Set wsClient=##class(MAKER.MAKERSoap).%New()
	Set wsClient.Location="http://"_host_":"_port_"/csp/maker/MAKER.Task.cls"
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

ClassMethod ClearAll(host = "localhost", port = 52773) As %Status
{
	#;念のため
	Do ..StopAll()
	
	#; purge Ensemble/Activity Voulme and Duration
	Set tSC=##class(Ens.Activity.Utils).Purge(0,"s",.c)
	Set tSC=##class(Ens.Activity.Utils).Purge(0,"hh",.c)
	Set tSC=##class(Ens.Activity.Utils).Purge(0,"d",.c)
	
	#;ダミー日付を初期化
	Do ##class(Common.Util).SetToday("2001-01-01")
	
	W "HQ環境のクリーンアップ",!
	Set wsClient=##class(Common.Util).GetWSHQClient(host,port)
	Do wsClient.ClearAll()
	;Do ##class(WSHQ.Task).ClearAll()
		
	#;DC環境のクリーンアップ
	W "WSDC1環境のクリーンアップ",!
	Set wsClient=##class(Common.Util).GetWSDCClient(host,port)
	Do wsClient.ClearAll()

	W "WSDC2環境のクリーンアップ",!
	Set wsClient=##class(Common.Util).GetWSDCClient(host,port)
	Set wsClient.Location="http://"_host_":"_port_"/csp/wsdc2/WSDC.Task.cls"
	Do wsClient.ClearAll()

	#;Maker環境のクリーンアップ
	W "Maker環境のクリーンアップ",!
	Set wsClient=##class(Common.Util).GetMAKERClient(host,port)
	Do wsClient.ClearAll()

	Return $$$OK
}

ClassMethod StartAll()
{
	Set nsall=..GetSiteInfo()

	New $namespace
	For i=1:1:$LISTLENGTH(nsall)	 {
		Set ns=$LIST(nsall,i)
		Set $namespace=ns
		If $E(ns,1,4)="WSHQ" Do ##class(Ens.Director).StartProduction("WSHQ.Production.Production1")
		If $E(ns,1,4)="MAKE" Do ##class(Ens.Director).StartProduction("MAKER.Production.Production1")
		If $E(ns,1,4)="WSDC" Do ##class(Ens.Director).StartProduction("WSDC.Production.Production1")
	}
}

ClassMethod StopAll()
{
	Set nsall=..GetSiteInfo()

	New $namespace
	For i=1:1:$LISTLENGTH(nsall)	 {
		Set ns=$LIST(nsall,i)
		Set $namespace=ns
		Do ##class(Ens.Director).StopProduction(,1)
	}
}

ClassMethod AddEnsembleCredential() As %Status
{
	Set tSC=##class(Ens.Config.Credentials).SetCredential("default", "appuser", "sys")
	Set tSC=##class(Ens.Config.Credentials).SetCredential("ensemble-email", "user1", "xxx")
	
	Return $$$OK
}

ClassMethod RemoveAll() As %Status
{
	#;以下、使用しているライブラリはいずれも将来的にはrest/apiに変更する。
	#;自分自身を含むDB(WSDEMO)も削除するので、実行後は%SYSに残る。
	Set tSC=$$$OK
	Set nsall=..GetSiteInfo()_$LISTBUILD("WSDEMO")
	Set $namespace="%SYS"

	Try {
		For i=1:1:$LISTLENGTH(nsall)	 {
			Set ns=$LIST(nsall,i)
			w ns,!
			Set directory=$SYSTEM.Util.ManagerDirectory()_ns
			Set webApp="/csp/"_ns

			Set tSC = ##class(Config.Namespaces).Delete(ns)
			If $SYSTEM.Status.GetErrorCodes(tSC)'=$$$CPFNameDoesNotExist {
				If $$$ISERR(tSC) throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)
			}
			
			Set tSC = ##class(%Library.EnsembleMgr).DisableNamespace(ns)
			If $$$ISERR(tSC) throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)

			Set tSC = ##Class(Security.Applications).Delete(webApp)
			If $SYSTEM.Status.GetErrorCodes(tSC)'=$$$ApplicationDoesNotExist {
				If $$$ISERR(tSC) throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)
			}
			Set tSC = ##class(Config.Databases).Delete(ns)
			If $SYSTEM.Status.GetErrorCodes(tSC)'=$$$CPFNameDoesNotExist {
				If $$$ISERR(tSC) throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)
			}
			Set tSC = ##class(SYS.Database).DeleteDatabase(directory)
			If $SYSTEM.Status.GetErrorCodes(tSC)'=$$$DatabaseDoesNotExist {
				If $$$ISERR(tSC) throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)
			}
		}
	}
	Catch (e) {
		zw e
	}
	Quit tSC
}

}
