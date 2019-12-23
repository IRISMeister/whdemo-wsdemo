Class Common.CustomerMaster Extends %Persistent
{

ClassMethod GetNewCustomerCode()
{
	Set code=$INCREMENT(^Common.CustomerMaster)
	Return "CS"_$REPLACE($J(code,8)," ","0")
}

ClassMethod GetCustomerCode(code)
{
	Return "CS"_$REPLACE($J(code,8)," ","0")
}

Storage Default
{
<Data name="CustomerMasterDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
</Data>
<DataLocation>^Common.CustomerMasterD</DataLocation>
<DefaultData>CustomerMasterDefaultData</DefaultData>
<IdLocation>^Common.CustomerMasterD</IdLocation>
<IndexLocation>^Common.CustomerMasterI</IndexLocation>
<StreamLocation>^Common.CustomerMasterS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
