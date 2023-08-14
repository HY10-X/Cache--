///function:面向对象操作
/// Creatordate：2023年8月14日
Class web.Study.DaySixSFC Extends %RegisteredObject
{
///新增操作
/// table：DHC_StudentSFCA
/// input:StCode,StName,StSexDR,StDob
/// output:
/// other:w ##class(web.Study.DaySixSFC).AddData()
ClassMethod AddData(StCode as %String,StName as %String,StSexDR as %String,StDob as %String)as %String{
    s oref=##class(User.DHCStudentSFCA).%New()

}



}
