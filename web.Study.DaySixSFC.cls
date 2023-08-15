///function:面向对象操作
/// Creatordate：2023年8月14日
Class web.Study.DaySixSFC Extends %RegisteredObject
{
///新增操作
/// table：DHC_StudentSFCA
/// input:StCode(不能重复),StName,StSexDR,StDob
/// output:
/// other:w ##class(web.Study.DaySixSFC).AddData()
ClassMethod AddData(StCode as %String,StName as %String,StSexDR as %String,StDob as %String)as %String{
    q:(StCode="")||(StName="")
    q:+$d(^DHCSTUDENTSFCA(0,"code",StCode))>0
    Set oref=##class(User.DHCStudentSFCA).%New()
    Set:StDob'="" StDob=##class(websys.Conversions).DateHtmlToLogical(StDob) //标准转换日期接口 = $zdh(stdob,3)

    If ($ISOBJECT(oref)){    //判断对象是否创建，还可以写做 (oref)
        Set oref.StCode=StCode
        Set oref.StName=StName
        Do oref.StSexDRSetObjectId(StSexDR) //指向型字段，需要用SetObjectId()赋值
        Set oref.StDob=StDob  //需要转换格式，转换为逻辑数字传输
        Set sc=oref.%save()
        If ($$$ISOK(sc)){    //(sc=1)判断保存是否为空,保存是否成功
        
            Set StRowId=oref.%Id()
            Set result="add success"_StRowId
        }
        Else{
            s result="add error"_$SYSTEM.OBJ.DISPLAYError(sc)   //显示错误信息 w $SYSTEM.Status.DISPLAYError

        }

    }
    d oref.%Close()
    q
}



}
