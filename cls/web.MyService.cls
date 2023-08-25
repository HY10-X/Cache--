/// web.MyService
Class web.MyService Extends %SOAP.WebService [ ProcedureBlock ]
{

/// WebService 的名称.
Parameter SERVICENAME = "MyService";

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

// 

Method Hello() As %String [ WebMethod ]
{
	Quit "Hello"
}
///function:获取用户名称
/// input:Code  用户工号
/// output:SSUserName 用户姓名
/// table:SS_User 
/// w ##class(web.MyService).%New().GetSSUserName("0004")
Method GetSSUserName(Code as %String) as %String [WebMethod]{
    q:Code="" "Code is Null"
    s SSUserRowId=$o(^SSU("SSUSR",0,"SSUSR_Initials",Code,0))
    q:SSUserRowId="" ""    //循环完毕
    s SSUserName=$p($g(^SSU("SSUSR",SSUserRowId)),"^",2)
    q SSUserName

}

/// w ##class(web.MyService).%New().TestWebservice("上海")
ClassMethod TestWebservice(byProvinceName as %String) As %Status
{
    s obj=##class(WeatherWebService.WeatherWebServiceSoap).%New()
    if (obj){
        s result=obj.getSupportCity(byProvinceName)
        for i=1:1:result.Count(){
            s CityName=result.GetAt(i)
            w CityName,!
        }
    }
}

}
