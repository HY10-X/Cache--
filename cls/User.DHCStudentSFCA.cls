/// 功能：创建学生表2
/// 创建日期：2023年8月8日
/// 创建人：houyuxuan
/// 字段：St_RowId,St_Code,St_Name,St_Sex_DR(Ct_Sex),St_Dob(Date)
Class User.DHCStudentSFCA Extends %Persistent [ SqlTableName = DHC_StudentSFCA, StorageStrategy = NewStorage1 ]
{

/// 父表中定义子表关系
Relationship ChildCourse As DHCStudentCourseSFCA [ Cardinality = children, Inverse = DHCScParRef ];

/// 学号St_Code	重命名列名[SqlFieldName = St_Code ] 
/// 排序列名，rowid默认第一列,所以从第二列开始，SqlColumnNumber=
Property StCode As %String [ SqlColumnNumber = 2, SqlFieldName = St_Code ];

/// 姓名St_Name
Property StName As %String [ SqlColumnNumber = 3, SqlFieldName = St_Name ];

/// 性别St_Sex_DR(Ct_Sex)，指向表，指向Ct_Sex
Property StSexDR As User.CTSex [ SqlColumnNumber = 4, SqlFieldName = St_Sex_DR ];

/// 出生日期St_Dob  
Property StDob As %Date [ SqlColumnNumber = 5, SqlFieldName = St_Dob ];

/// 创建字段的唯一索引，去重，校验
Index CodeIdx On StCode [ Unique ];

Storage NewStorage1
{
<SqlIdExpression>$i(^DHCSTUDENTSFCA(0))</SqlIdExpression>
<SQLMap name="DataMaster">
<Data name="St_Code">
<Delimiter>"^"</Delimiter>
<Piece>1</Piece>
</Data>
<Data name="St_Dob">
<Delimiter>"^"</Delimiter>
<Piece>4</Piece>
</Data>
<Data name="St_Name">
<Delimiter>"^"</Delimiter>
<Piece>2</Piece>
</Data>
<Data name="St_Sex_DR">
<Delimiter>"^"</Delimiter>
<Piece>3</Piece>
</Data>
<Global>^DHCSTUDENTSFCA</Global>
<RowIdSpec name="1">
<Expression>{L1}</Expression>
<Field>St_RowId</Field>
</RowIdSpec>
<Subscript name="1">
<Expression>{St_RowId}</Expression>
<StartValue>1</StartValue>
</Subscript>
<Type>data</Type>
</SQLMap>
<SQLMap name="IdexCode">
<Global>^DHCSTUDENTSFCA</Global>
<PopulationType>nonnull</PopulationType>
<RowIdSpec name="1">
<Expression>{L4}</Expression>
<Field>St_RowId</Field>
</RowIdSpec>
<Subscript name="1">
<Expression>0</Expression>
</Subscript>
<Subscript name="2">
<Expression>"code"</Expression>
</Subscript>
<Subscript name="3">
<Expression>{St_Code}</Expression>
</Subscript>
<Subscript name="4">
<Expression>{St_RowId}</Expression>
</Subscript>
<Type>index</Type>
</SQLMap>
<SQLMap name="IndexName">
<Global>^DHCSTUDENTSFCA</Global>
<PopulationType>nonnull</PopulationType>
<RowIdSpec name="1">
<Expression>{L4}</Expression>
<Field>St_RowId</Field>
</RowIdSpec>
<Subscript name="1">
<Expression>0</Expression>
</Subscript>
<Subscript name="2">
<Expression>"Name"</Expression>
</Subscript>
<Subscript name="3">
<Expression>{St_Name}</Expression>
</Subscript>
<Subscript name="4">
<Expression>{St_RowId}</Expression>
</Subscript>
<Type>index</Type>
</SQLMap>
<SqlRowIdName>St_RowId</SqlRowIdName>
<StreamLocation>^User.DHCStudentSFCAS</StreamLocation>
<Type>%CacheSQLStorage</Type>
}

/// function:无索引遍历数据,当入参为空输出所有学生。
/// createdate：2023年8月9日
/// creator：houyuxuan
/// input:StRowId Code
/// output:
/// table:DHC_StudentSFCA
/// other:d ##class(User.DHCStudentSFCA).GetDataList("1","")
ClassMethod GetDataList(StRowId As %String, Code As %String) As %String
{
	If (StRowId'=""){
		
		If ($DATA(^DHCSTUDENTSFCA(StRowId))=0) {  ///$Data=0该节点不存在
			Write "不存在此学生"
			}
		Else{	
		Set DataStr=$GET(^DHCSTUDENTSFCA(StRowId)) ///获取当前节点的数据串
		Set StCode=$PIECE(DataStr,"^",1)	///获取字段第一个rowid，具体查看表结构data位置
		Set StName=$PIECE(DataStr,"^",2) ///姓名
		Set StSexDR=$PIECE(DataStr,"^",3)	///指向了ctsex，需要取指向表的描述
		Set StSexDRDesc=""
		Set:StSexDR'="" StSexDRDesc=$PIECE($GET(^CT("SEX",StSexDR)),"^",2)	///取得对应的性别描述^CT("SEX",1)="1^男^^61089^^^"
		Set StDob=""
		Set StDob=$PIECE(DataStr,"^",4)
		Set:StDob'="" StDob=$ZDATE(StDob,3)	///日期转换
		Write "学号："_StCode_"姓名："_StName_"性别："_StSexDR_"日期："_StDob	
		}	
	}
	Else{
			Set RowId=0
			For{
			Set RowId=$ORDER(^DHCSTUDENTSFCA(RowId))
			Quit:RowId=""
			Set DataStr=$GET(^DHCSTUDENTSFCA(RowId)) ///获取当前节点的数据串
			Set StCode=$PIECE(DataStr,"^",1)	///获取字段第一个rowid，具体查看表结构data位置
			Set StName=$PIECE(DataStr,"^",2) ///姓名
			Set StSexDR=$PIECE(DataStr,"^",3)	///指向了ctsex，需要取指向表的描述
			Set StSexDRDesc=""
			Set:StSexDR'="" StSexDRDesc=$PIECE($GET(^CT("SEX",StSexDR)),"^",2)	///取得对应的性别描述^CT("SEX",1)="1^男^^61089^^^"
			Set StDob=""
			Set StDob=$PIECE(DataStr,"^",4)
			Set:StDob'="" StDob=$ZDATE(StDob,3)	///日期转换
			If (StCode=Code)||(Code=""){
				Write RowId_"学号："_StCode_"姓名："_StName_"性别："_StSexDR_"日期："_StDob_""	
				Write !
				}
			}	
		}
}

/// function:有索引遍历数据,当入参为空输出所有学生。
/// createdate：2023年8月10日
/// creator：houyuxuan
/// input: Code
/// output:
/// table:DHC_StudentSFCA  
/// global: ^DHCSTUDENTSFCA
/// other:d ##class(User.DHCStudentSFCA).GetDataListByCode("789")
ClassMethod GetDataListByCode(Code As %String) As %String
{
	Quit:($GET(Code)="") "code为空"	///传入为空跳出
	Quit:($DATA(^DHCSTUDENTSFCA(0,"code",Code))=0) "数据不存在" ///无索引无数据退出
	Set RowId=0
	Set RowId=$ORDER(^DHCSTUDENTSFCA(0,"code",Code,RowId)) ///使用$o从节点取得rowid
	Quit:RowId=""
	Set DataStr=$GET(^DHCSTUDENTSFCA(RowId)) ///获取获取到的RowId的数据串
	Set StCode=$PIECE(DataStr,"^",1)	///获取字段第一个rowid，具体查看表结构data位置
	Set StName=$PIECE(DataStr,"^",2) ///姓名
	Set StSexDR=$PIECE(DataStr,"^",3)	///指向了ctsex，需要取指向表的描述
	Set StSexDRDesc=""
	Set:StSexDR'="" StSexDRDesc=$PIECE($GET(^CT("SEX",StSexDR)),"^",2)	///取得对应的性别描述^CT("SEX",1)="1^男^^61089^^^"
	Set StDob=""
	Set StDob=$PIECE(DataStr,"^",4)
	Set:StDob'="" StDob=$ZDATE(StDob,3)	///日期转换
	If (StCode=Code)||(Code=""){
		Write RowId_"学号："_StCode_"姓名："_StName_"性别："_StSexDR_"日期："_StDob_""	
		Write !		
				}
}

/// 题目：获取rowid为3的就诊（PA_Adm）的病人（PA_PatMas）的性别描述（CT_Sex）
/// global:^PAADM({PAADM_RowID})
/// table:PA_Adm
/// method:d ##CLASS(User.DHCStudentSFCA).GetPAADmSexDesc("3")
ClassMethod GetPAADmSexDesc(AdmRowId As %String) As %String
{
	Quit:AdmRowId="" "RowId not be NUll"
	Quit:$DATA(^PAADM(AdmRowId))=0
	Set PAADMPAPMIDR=$PIECE($GET(^PAADM(AdmRowId)),"^",1)
	Set:PAADMPAPMIDR'="" PAPMISexDR=$PIECE($GET(^PAPER(PAADMPAPMIDR,"ALL")),"^",7)
	Set:PAPMISexDR'="" CTSEXDesc=$PIECE($GET(^CT("SEX",PAPMISexDR)),"^",2)
	Write "rowid为3的"_AdmRowId_"就诊（PA_Adm）的病人（PA_PatMas）的性别描述为"_CTSEXDesc
}

/// function:编写使用query
/// input:RowId,Code,Name
/// others: d ##class(%ResultSet).RunQuery("User.DHCStudentSFCA","GetList","2")
Query GetList(Code As %String) As %Query(ROWSPEC = "StRowId:%String,StCode:%String,StName:%String,StSexDR:%String,StDob:%String")
{
}

ClassMethod GetListExecute(ByRef qHandle As %Binary, Code As %String) As %Status
{
	Set repid=$INCREMENT(^CacheTemp)
	Set ind=1
	///StRowId,StCode,StName,StSexDR,StDob
	Set StRowId=0
	For{
		Set StRowId=$ORDER(^DHCSTUDENTSFCA(StRowId)) Quit:StRowId=""
		Set StCode=$PIECE($GET(^DHCSTUDENTSFCA(StRowId)),"^",1)
		Set StName=$PIECE($GET(^DHCSTUDENTSFCA(StRowId)),"^",2)
		Set StSexDR=$PIECE($GET(^DHCSTUDENTSFCA(StRowId)),"^",3)	///取性别描述
		Set:StSexDR'="" StSexDR=$PIECE($GET(^CT("SEX",StSexDR)),"^",2)
		Set StDob=$PIECE($GET(^DHCSTUDENTSFCA(StRowId)),"^",4) 
		Set:StDob'="" StDob=$ZDATE(StDob,3)
			///[包含
			///输出至CacheTemp
		If (StCode[Code){
			Set data=$LISTBUILD(StRowId,StCode,StName,StSexDR,StDob)
			Set ^Cachetmp(repid,ind)=data
			Set ind=ind+1
		
		}
		
	}
	
	Set qHandle=$LISTBUILD(0,repid,0)
		
	Quit $$$OK
}

ClassMethod GetListFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status
{
	Set AtEnd=$LIST(qHandle,1)
	Set repid=$LIST(qHandle,2)
	Set ind=$LIST(qHandle,3)
	
	Set ind=$ORDER(^CacheTemp(repid,ind))
	If ind=""{
		Set AtEnd=1
		Set Row=""
		}
	Else{
		Set Row=^CacheTemp(repid,ind)
		}	
		
	Set qHandle=$LISTBUILD(AtEnd,repid,ind)

	Quit $$$OK
}

ClassMethod GetListClose(ByRef qHandle As %Binary) As %Status [ PlaceAfter = GetListExecute ]
{
	
	Set repid=$LIST(qHandle,2)
	Kill ^CacheTemp(repid)
	Quit $$$OK
}

/// function：使用sql操作，数据新增
/// table:DHC_StudentSFCA
/// others：d ##class(User.DHCStudentSFCA).InsertData("007","ccc","1","2001-02-21")
ClassMethod InsertData(StCode As %String, StName As %String, StSexDR As %String, StDob As %String) As %String
{
	///zhuanhuanriqi
	If StDob'="" Set StDob=$ZDATEH(StDob,3)
	&SQL(INSERT INTO DHC_StudentSFCA 
	VALUES(:StCode,:StName,:StSexDR,:StDob)
	)
	If SQLCODE=0{
		Set result="success"
		}
	Else{
		Set result="error"_%msg
		}
	Quit result
}

/// function：使用SQL操作部分新增，数据新增
/// table:MRC_ICDDx
/// var:MRCID_Code,MRCID_Desc,MRCID_ICD9CM_Code,MRCID_DateActiveFrom,MRCID_Valid
/// others：d ##class(User.DHCStudentSFCA).AddMRCTCD("ZY0571ATEST","ccc1","ccc1","BES060")
ClassMethod AddMRCICD(MRCIDCode, MRCIDDesc, MRCIDICD9CMCode, MRCIDDateActiveFrom, MRCIDValid) As %String
{
	///zhuanhuanriqi
	If MRCIDDateActiveFrom'="" Set MRCIDDateActiveFrom=$ZDATEH(MRCIDDateActiveFrom,3)
	&SQL(INSERT INTO MRC_ICDDx (MRCID_Code,MRCID_Desc,MRCID_ICD9CM_Code,MRCID_DateActiveFrom,MRCID_Valid)
	VALUES(:MRCIDCode,:MRCIDDesc,:MRCIDICD9CMCode,:MRCIDDateActiveFrom,:MRCIDValid)
	)
	If SQLCODE=0{
		Set result="success"
		}
	Else{
		Set result="error"_%msg
		}
	Quit result
}

/// function：plist新增
/// table:MRC_ICDDx
/// others:
ClassMethod AddMRCICDByPLIST(MRCIDCode, MRCIDDesc, MRCIDICD9CMCode, MRCIDDateActiveFrom, MRCIDValid) As %String
{
	If MRCIDDateActiveFrom'="" Set MRCIDDateActiveFrom=$ZDATEH(MRCIDDateActiveFrom,3)
	Kill PList
	Set PList(2)=MRCIDCode
	Set PList(3)=MRCIDDesc
	Set PList(6)=MRCIDICD9CMCode
	Set PList(8)=MRCIDDateActiveFrom
	Set PList(29)=MRCIDValid
	&SQL(
	INSERT INTO MRC_ICDDx
	VALUES :PLIST()
	
	)
}

/// function:数据更新
/// input：St_Name,St_SexDR,St_Dob
/// table: DHC_StudentSFCA
/// other:d ##class(User.DHCStudentSFCA).UpdateData("3","liming","1","2001-02-21")
ClassMethod UpdateData(StRowId, StName, StSexDR, StDob) As %String
{
	
	Set:StDob'="" StDob=$ZDATEH(StDob,3)
	&sql(
	UPDATE DHC_StudentSFCA
	SET St_Name=:StName,St_Sex_DR=:StSexDR,St_Dob=:StDob
	WHERE St_RowId=:StRowId
	)
	If (SQLCODE=0){
		Set result="sucsses"
		}
	Else{
		Set result="error"
		
		}
	Quit result
}

/// function:PLIST数据更新
/// input：St_Name,St_SexDR,St_Dob
/// table: DHC_StudentSFCA
/// other:d ##class(User.DHCStudentSFCA).UpdateDataByPList("3","liming","1","2001-02-21")
ClassMethod UpdateDataByPList(StRowId, StName, StSexDR, StDob) As %String
{
	Quit:StRowId="" "rowid is null"
	Kill PLIST
	Set:StDob'="" StDob=$ZDATEH(StDob,3)
	Set PLIST(3)=StName
	Set PLIST(4)=StSexDR
	Set PLIST(5)=StDob
	&sql(
	UPDATE DHC_StudentSFCA
	VALUES :PLIST()
	WHERE St_RowId=:StRowId
	
	
	)
}

/// function:数据删除
/// Table：DHC_StudentSFCA
/// Inputh:St_RowId  必须要加条件否则删除所有数据
/// output:0失败1成功
/// others：w ##class(User.DHCStudentSFCA).DeleteData("")
ClassMethod DeleteData(StRowId As %String) As %String
{
	Quit:StRowId="" "rowid is null"
	Quit:$DATA(^DHCSTUDENTSFCA(StRowId))=0 "data is null"
	&SQL(
	DELETE FROM DHC_StudentSFCA 
	WHERE St_RowId=:StRowId
	)
	If (SQLCODE=0) {
		Set Result=1
		}
	Else {
		Set Result=0_%msg
		}
	Quit Result
}

/// function:数据查询（一条）
/// Table：DHC_StudentSFCA
/// Inputh:St_RowId  必须要加条件否则删除所有数据
/// output:0失败1成功
/// others：w ##class(User.DHCStudentSFCA).GetList("3")
ClassMethod GetList(StRowId As %String) As %String
{
	Quit:StRowId="" "rowid is null"
	Quit:$DATA(^DHCSTUDENTSFCA(StRowId))=0 "data is null"
	&sql(
	SELECT St_Code,St_Name,St_Sex_DR,St_Dob
	INTO :StCode,:StName,:StSexDR,:StDob
	FROM DHC_StudentSFCA WHERE St_RowId=:StRowId
	)
	Set:StDob'="" StDob=$ZDATE(StDob,3)
	Set:StSexDR'="" StSexDR=$PIECE(^CT("SEX",StSexDR),"^",2)
	If (SQLCODE=0){
		Quit "学号:"_StCode_"姓名:"_StName_"性别"_StSexDR_"出生日期"_""
		}
	Else{
		
		Quit "error"
		
		}
}

/// function:plist数据查询（一条）,但是字段很多，使用for循环输出plist
/// Table：DHC_StudentSFCA
/// Inputh:St_RowId  必须要加条件否则删除所有数据
/// output:0失败1成功
/// others：w ##class(User.DHCStudentSFCA).GetListByPLIST("3") 
ClassMethod GetListByPLIST(StRowId As %String) As %String
{
	Quit:StRowId="" "StRowId is null"
	Quit:$DATA(^DHCSTUDENTSFCA(StRowId))=0 "data is null"
	&sql(
		SELECT * INTO :PLIST()
		FROM DHC_StudentSFCA
		WHERE St_RowID=:StRowId
	)
	Set cnt=$ORDER(PLIST(""),-1) //取PLIST最大标号
	For i=1:1:cnt{
		Write " "
		Write PLIST(i)
	}
}

/// function:使用面向对象的方法查询全部数据
/// d ##class(User.DHCStudentSFCA).GetAllList()
ClassMethod GetAllList() As %String
{
	Set sqlstr="SELECT * FROM DHC_StudentSFCA"
	Set result=##class(%ResultSet).%New()
	If (result){
			Do result.Prepare(sqlstr)
			Do result.Execute()
			While(result.Next()){
				Set StRowId=result.Data("St_RowId")
				Set StCode=result.Data("St_Code")
				Set StName=result.Data("St_Name")
				Set StSexDR=result.Data("St_Sex_DR")
				Set StDob=result.Data("St_Dob")
				Set:StDob'="" StDob=$ZDATE(StDob,3)
				Set:StSexDR'="" StSexDR=$PIECE(^CT("SEX",StSexDR),"^",2)
				Write "学号"_StCode_"姓名"_StName_"性别"_StSexDR_"出生日期"_StDob
				Write !
			}
	}
}

}
