/// MyApp.SrvStudent
Class MyApp.SrvStudent Extends %SOAP.WebService [ ProcedureBlock ]
{

/// WebService 的名称.
Parameter SERVICENAME = "SrvStudent";

/// TODO:将此更改为实际 SOAP namespace.
/// WebService 的 SOAP Namespace
Parameter NAMESPACE = "http://tempuri.org";

/// 引用类的 Namespace 将在 WSDL 中使用.
Parameter USECLASSNAMESPACES = 1;

/// TODO:添加自变量和实施.
/// Test
Method Test() As %String [ WebMethod ]
{
	Quit "Test"
}

/// function:获取用户信息
/// input:Name  学生姓名
/// output:用户信息
/// table:SS_User 
/// d ##class(MyApp.SrvStudent).%New().GetStudentInfo("李四")
Method GetStudentInfo(Name As %String) As %String [ WebMethod ]
{
    Set StRowId=0
	For{
        //s obj=##class(User.DHCStudentHYX).%New()
		Set StRowId=$ORDER(^DHCSTUDENTHYX(StRowId)) Quit:StRowId=""
		Set StNo=$PIECE($GET(^DHCSTUDENTHYX(StRowId)),"^",1)
		Set StName=$PIECE($GET(^DHCSTUDENTHYX(StRowId)),"^",2)
		Set StGender=$PIECE($GET(^DHCSTUDENTHYX(StRowId)),"^",3)	///取性别描述
		Set StBirthday=$PIECE($GET(^DHCSTUDENTHYX(StRowId)),"^",4) 
		Set:StBirthday'="" StBirthday=$ZDATE(StBirthday,3)
        if (StName=Name){
           	s StRowIdv=StRowId
            s StNov=StNo
            s StNamev=StName
            s StGenderv=StGender
            s StBirthdayv=StBirthday
        }
		}
		
		s str="学生信息如下：RowId为："_StRowIdv_"，学号："_StNov_"，姓名："_StNamev_"，性别："_StGenderv_"，生日："_StBirthdayv
		q str
}


/// function:获取用户信息
/// input:Name  学生姓名
/// output:用户信息
/// table:SS_User 
/// d ##class(MyApp.SrvStudent).%New().GetStudentInfo("李四")
Method GetStudentInfo(Name As %String) As %String [ WebMethod ]
{
    Set StRowId=0
	For{
        //s obj=##class(User.DHCStudentHYX).%New()
		Set StRowId=$ORDER(^DHCSTUDENTHYX(StRowId)) Quit:StRowId=""
		Set StNo=$PIECE($GET(^DHCSTUDENTHYX(StRowId)),"^",1)
		Set StName=$PIECE($GET(^DHCSTUDENTHYX(StRowId)),"^",2)
		Set StGender=$PIECE($GET(^DHCSTUDENTHYX(StRowId)),"^",3)	///取性别描述
		Set StBirthday=$PIECE($GET(^DHCSTUDENTHYX(StRowId)),"^",4) 
		Set:StBirthday'="" StBirthday=$ZDATE(StBirthday,3)
        if (StName=Name){
           	s StRowIdv=StRowId
            s StNov=StNo
            s StNamev=StName
            s StGenderv=StGender
            s StBirthdayv=StBirthday
        }
		}
		
		s str="学生信息如下：RowId为："_StRowIdv_"，学号："_StNov_"，姓名："_StNamev_"，性别："_StGenderv_"，生日："_StBirthdayv
		q str
}

}
