Class WSDC.WSDCSoap Extends %SOAP.WebClient [ ProcedureBlock ]
{

/// This is the URL used to access the web service.
Parameter LOCATION = "http://wsdc1:52773/csp/wsdc/WSDC.Task.cls";

/// This is the namespace used by the Service
Parameter NAMESPACE = "http://tempuri.org";

/// This is the name of the Service
Parameter SERVICENAME = "WSDC";

/// This is the SOAP version supported by the service.
Parameter SOAPVERSION = 1.1;

Method ClearAll() As %xsd.base64Binary [ Final, ProcedureBlock = 1, SoapBindingStyle = document, SoapBodyUse = literal, WebMethod ]
{
 Quit ..WebMethod("ClearAll").Invoke($this,"http://tempuri.org/WSDC.Task.ClearAll")
}

Method StartProduction() As %xsd.base64Binary [ Final, ProcedureBlock = 1, SoapBindingStyle = document, SoapBodyUse = literal, WebMethod ]
{
 Quit ..WebMethod("StartProduction").Invoke($this,"http://tempuri.org/WSDC.Task.StartProduction")
}

Method StopProduction() As %xsd.base64Binary [ Final, ProcedureBlock = 1, SoapBindingStyle = document, SoapBodyUse = literal, WebMethod ]
{
 Quit ..WebMethod("StopProduction").Invoke($this,"http://tempuri.org/WSDC.Task.StopProduction")
}

Method Test() As %String [ Final, ProcedureBlock = 1, SoapBindingStyle = document, SoapBodyUse = literal, WebMethod ]
{
 Quit ..WebMethod("Test").Invoke($this,"http://tempuri.org/WSDC.Task.Test")
}

}
