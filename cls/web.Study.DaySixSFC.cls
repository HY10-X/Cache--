/// function:面向对象操作
/// Creatordate：2023年8月14日
Class web.Study.DaySixSFC Extends %RegisteredObject
{

/// 新增操作
/// table：DHC_StudentSFCA
/// input:StCode(不能重复),StName,StSexDR,StDob
/// output:
/// other:w ##class(web.Study.DaySixSFC).AddData("10","aa","1","2020-11-11")
ClassMethod AddData(StCode As %String, StName As %String, StSexDR As %String, StDob As %String) As %String
{
    Quit:(StCode="")||(StName="") "学号或姓名为空"
    Quit:$DATA(^DHCSTUDENTSFCA(0,"code",StCode))'=0 "学号重复" //$d为0时通过，为0代表值为空，子节点也为空,代表code索引中没有这个学号
   
    Set:StDob'="" StDob=##class(websys.Conversions).DateHtmlToLogical(StDob) //标准转换日期接口 = $zdh(StDob,3)
 	Set oref=##class(User.DHCStudentSFCA).%New()
    If (oref){    //判断对象是否创建，还可以写做 (oref)
        Set oref.StCode=StCode
        Set oref.StName=StName
        Do oref.StSexDRSetObjectId(StSexDR) //指向型字段，需要用SetObjectId()赋值
        Set oref.StDob=StDob  //需要转换格式，转换为逻辑数字传输
        Set sc=oref.%Save()
        If ($$$ISOK(sc)){    //(sc=1)判断保存是否为空,保存是否成功
        
            Set StRowId=oref.%Id()
            Set result="add success"_StRowId
        }
        Else{
            Set result="add error"_$SYSTEM.OBJ.DISPLAYError(sc)   //显示错误信息 w $SYSTEM.Status.DISPLAYError
        }
    }
    Do oref.%Close()
    Quit result
}
/// 更新操作
/// table：DHC_StudentSFCA
/// input:StRowId,StName,StSexDR,StDob
/// output:
/// other:w ##class(web.Study.DaySixSFC).AddData("10","aa","1","2020-11-11")
ClassMethod UpdateData(StRowId As %String, StName As %String, StSexDR As %String, StDob As %String)as %String {
	Quit:(StRowId="") "rowid is null"
	Set:StDob'="" StDob=$ZDG(StDob,3)
	Set obj=##class(User.DHCStudentSFCA).%OpenId(StRowId) //open obejct 
	If (obj){
		Set obj.StName=StName
		Do obj.StSexDRSetobjectId(StSexDR)
		Set obj.StDob=StDob
		Tstart		//引入事务
		Set sc=obj.%Save()	//save obj
		If (sc=1){
			Tcommit
			Set result=1
		}
		Else{
			Trollback
			Set result=0
		}
		Do obj.%Close()
		Quit result
	}
}

///function:数据保存 新增与修改合并方法
///input:StRowId为空默认新增，不为空默认为更新数据
ClassMethod SaveData(StRowId As %String,StCode As %String, StName As %String, StSexDR As %String, StDob As %String){
	Quit:StCode="" "StCode is null"
	Quit:StName="" "StName is null"
	If (StRowId="") {	//新增
	Quit:$DATA(^DHCSTUDENTSFCA(0,"code",StCode))'=0 "学号重复" //$d为0时通过，为0代表值为空，子节点也为空,代表code索引中没有这个学号
		Set oref=##class(User.DHCStudentSFCA).%New()
	}

	Else{	//修改
		Set oref=##class(user.DHCStudentSFCA).%OpenId(StRowId)
	}

	If ($ISOBJECT(oref)){	//判断对象是否存在，然后给对象属性赋值
		Set oref.StCode=StCode
		Set oref.StName=StName
		Do oref.StSexDRSetObjectId(StSexDR)	//性别使用SetObjectId赋值
		Set sc=oref.%save()
		Tstart
	}

	 If ($$$ISOK(sc)){    //(sc=1)判断保存是否为空,保存是否成功
        Tcommit
        Set StRowId=oref.%Id()
        Set result="add success"_StRowId
        }

    Else{
		Trollback
         Set result="add error"_$SYSTEM.OBJ.DISPLAYError(sc)   //显示错误信息 w $SYSTEM.Status.DISPLAYError
        }

    Do oref.%Close()
	Quit result
	}

///function:查询数据，取出数据
/// table：DHC_StudentSFCA
/// input:StRowId（不为空）
/// output:
/// other:w ##class(web.Study.DaySixSFC).OpenData("10")
ClassMethod OpenData(StRowId AS %String) as %String{
	Quit:StRowId="" "StRowId is null"
	Set obj=##class(User.DHCStudentSFCA).%OpenId(StRowId)
	If (obj){
		Set StCode=obj.StCode		//等同于obj.StCodeGet()
		Set StName=obj.StName
		Set:obj.StSexDR'="" StSexDR=obj.StSexDR.CTSEXDesc //指向表取性别描述,先取出obj中的指向数，再赋值给指向表获取性别指向值
		//=obj.StSexDRGetObjectId	取性别指向表CT_SEX的的RowId 
		Set StDob=obj.StDob
		Set:StDob'="" StDob=$ZDATE(StDob,3) //transfer Date
		Set result="学号："_StCode_"姓名："_StName_"性别:"_StSexDR_"出生日期:"_StDob
	}
	Do obj.%Close()
	Quit result
}


///function:删除数据
/// table：DHC_StudentSFCA
/// input:StRowId（不为空）
/// output:
/// other:w ##class(web.Study.DaySixSFC).DeleteData("10")
ClassMethod DeleteData(StRowId AS %String) as %String{
	Quit:StRowId="" "rowid is null"
	Set obj=##class(User.DHCStudentSFCA).%OpenId(StRowId)
	If (obj){	//通过%OpenId判断数据是否存在
	Tstart
		Set sc=obj.%DeleteId(StRowId)	//通过%DeleteId删除数据
		If (sc=1){
			Set result="success"
			Tcommit
		}
		Else{
			Trollback
			Set result="error"_$SYSTEM.Status.DISPLAYError(sc)
		}
		Do obj.%Close()
	}
	Else{
		Set result="数据不存在"
	}
}

}
