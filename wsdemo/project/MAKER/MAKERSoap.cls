Class MAKER.MAKERSoap Extends %SOAP.WebClient [ ProcedureBlock ]
{

/// This is the URL used to access the web service.
Parameter LOCATION = "http://maker:52773/csp/maker/MAKER.Task.cls";

/// This is the namespace used by the Service
Parameter NAMESPACE = "http://tempuri.org";

/// This is the name of the Service
Parameter SERVICENAME = "MAKER";

/// This is the SOAP version supported by the service.
Parameter SOAPVERSION = 1.1;

Method ClearAll() As %xsd.base64Binary [ Final, ProcedureBlock = 1, SoapBindingStyle = document, SoapBodyUse = literal, WebMethod ]
{
 Quit ..WebMethod("ClearAll").Invoke($this,"http://tempuri.org/MAKER.Task.ClearAll")
}

Method StartProduction() As %xsd.base64Binary [ Final, ProcedureBlock = 1, SoapBindingStyle = document, SoapBodyUse = literal, WebMethod ]
{
 Quit ..WebMethod("StartProduction").Invoke($this,"http://tempuri.org/MAKER.Task.StartProduction")
}

Method StopProduction() As %xsd.base64Binary [ Final, ProcedureBlock = 1, SoapBindingStyle = document, SoapBodyUse = literal, WebMethod ]
{
 Quit ..WebMethod("StopProduction").Invoke($this,"http://tempuri.org/MAKER.Task.StopProduction")
}

Method Test() As %String [ Final, ProcedureBlock = 1, SoapBindingStyle = document, SoapBodyUse = literal, WebMethod ]
{
 Quit ..WebMethod("Test").Invoke($this,"http://tempuri.org/MAKER.Task.Test")
}

}
