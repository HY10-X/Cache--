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
   
    Set:StDob'="" StDob=##class(websys.Conversions).DateHtmlToLogical(StDob) //标准转换日期接口 = $zdh(stdob,3)
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

}
