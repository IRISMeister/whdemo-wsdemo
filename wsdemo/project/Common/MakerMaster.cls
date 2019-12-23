Class Common.MakerMaster Extends %Persistent
{

Property メーカ名 As %String;

Property メーカコード As %String;

Index pkey On メーカコード [ PrimaryKey, Unique ];

Index uniqueidx1 On メーカ名 [ Unique ];

ClassMethod GetNewMakerCode()
{
	Set code=$INCREMENT(^Common.MakerMaster)
	Return "MK"_$REPLACE($J(code,8)," ","0")
}

Storage Default
{
<Data name="MakerMasterDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>メーカ名</Value>
</Value>
<Value name="3">
<Value>メーカコード</Value>
</Value>
</Data>
<DataLocation>^Common.MakerMasterD</DataLocation>
<DefaultData>MakerMasterDefaultData</DefaultData>
<IdLocation>^Common.MakerMasterD</IdLocation>
<IndexLocation>^Common.MakerMasterI</IndexLocation>
<StreamLocation>^Common.MakerMasterS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
