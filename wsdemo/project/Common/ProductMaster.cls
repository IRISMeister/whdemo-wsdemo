Class Common.ProductMaster Extends %Persistent
{

Property 商品コード As %String;

Property 商品名 As %String(MAXLEN = 200);

Property メーカコード As %String;

Property ＪＡＮコード As %String;

Property 薬価基準収載医薬品コード As %String;

Property 個別医薬品コード As %String;

/// JICSF等が望ましい？
Property 分類 As %String;

Property 原価 As %Numeric(SCALE = 0);

Property 売価 As %Numeric(SCALE = 0);

Property 売れ筋係数 As %Numeric(SCALE = 3);

Property リードタイム As %Numeric(SCALE = 0);

Index pkey On 商品コード [ PrimaryKey, Unique ];

ClassMethod GetLastId()
{
	Return +$G(^Common.ProductMasterD)
}

ClassMethod Populate() As %Status
{
#define DECODE(%x) $ZSTRIP(%x,"<>P")

	D ##class(MakerMaster).%KillExtent()
	Kill ^Common.MakerMaster
	D ##class(ProductMaster).%KillExtent()
	
	#;他に無償公開されてるデータが無いので、ひとまずmedisコードを使用
	Set file="/home/irisowner/MEDIS20130628.TXT"

	Set fs=##class(%Stream.FileCharacter).%New()
	Set fs.Filename=file
	Set rec=fs.ReadLine()  //skip header line

	Set sql2="INSERT INTO Common.ProductMaster (商品コード,商品名,ＪＡＮコード,薬価基準収載医薬品コード,個別医薬品コード,メーカコード,分類,原価,売価,売れ筋係数,リードタイム) VALUES (?,?,?,?,?,?,?,?,?,?,?)"
	Set tStmt2=##class(%SQL.Statement).%New()
	Set tSC=tStmt2.%Prepare(sql2)
	Set cnt=0
	While ('fs.AtEnd) {
		Set rec=fs.ReadLine()
		Set cnt=cnt+1
		Set 基準番号=$$$DECODE($P(rec,",",1))
		Set 物流用番号=$$$DECODE($P(rec,",",5))  //何？
		Set ＪＡＮコード=$$$DECODE($P(rec,",",6))  //GS1コードが良いのだが
		Set 薬価基準収載医薬品コード=$$$DECODE($P(rec,",",7)) 
		Set 個別医薬品コード=$$$DECODE($P(rec,",",8)) 
		Set 販売名=$$$DECODE($P(rec,",",12))
		Set 規格単位=$$$DECODE($P(rec,",",14))
		Set 包装単位数=$$$DECODE($P(rec,",",16))
		Set 包装単位単位=$$$DECODE($P(rec,",",17))
		Set 包装総量数=$$$DECODE($P(rec,",",18))
		Set 包装総量単位=$$$DECODE($P(rec,",",19))
		Set vendor=$$$DECODE($P(rec,",",21))
		#;Set 売れ筋係数=$ZABS($ZSIN(cnt*0.1)) If 売れ筋係数<0.1 Set 売れ筋係数=0.1
		Set 売れ筋係数=($ZSIN(cnt*0.1)+1)/2 If 売れ筋係数<0.1 Set 売れ筋係数=0.1
		
		Set 売価=$R(1000)+100
		Set 原価=売価*(($R(50)+10)/100)

		Set リードタイム=(基準番号#3)+5
	
		&SQL(SELECT "メーカコード" into :MakerCode FROM Common.MakerMaster WHERE "メーカ名"=:vendor)
		If SQLCODE=100 {
			Set MakerCode=##class(Common.MakerMaster).GetNewMakerCode()
			&SQL(INSERT INTO Common.MakerMaster ("メーカコード","メーカ名") VALUES (:MakerCode,:vendor))
			If SQLCODE'=0 {
					b
			}
		}
		Set ProductName=販売名_" "_規格単位_" "_包装単位数_包装単位単位_"/"_包装総量数_包装総量単位
		set tResult = tStmt2.%Execute(基準番号,ProductName,ＪＡＮコード,薬価基準収載医薬品コード,個別医薬品コード,MakerCode,物流用番号,原価,売価,売れ筋係数,リードタイム)
		If tResult.%SQLCODE'=0 {
				b
		}
	}
	Return $$$OK
}

Storage Default
{
<Data name="ProductMasterDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>商品コード</Value>
</Value>
<Value name="3">
<Value>商品名</Value>
</Value>
<Value name="4">
<Value>メーカコード</Value>
</Value>
<Value name="5">
<Value>分類</Value>
</Value>
<Value name="6">
<Value>原価</Value>
</Value>
<Value name="7">
<Value>売価</Value>
</Value>
<Value name="8">
<Value>ＪＡＮコード</Value>
</Value>
<Value name="9">
<Value>薬価基準収載医薬品コード</Value>
</Value>
<Value name="10">
<Value>個別医薬品コード</Value>
</Value>
<Value name="11">
<Value>売れ筋係数</Value>
</Value>
<Value name="12">
<Value>リードタイム</Value>
</Value>
</Data>
<DataLocation>^Common.ProductMasterD</DataLocation>
<DefaultData>ProductMasterDefaultData</DefaultData>
<IdLocation>^Common.ProductMasterD</IdLocation>
<IndexLocation>^Common.ProductMasterI</IndexLocation>
<StreamLocation>^Common.ProductMasterS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
