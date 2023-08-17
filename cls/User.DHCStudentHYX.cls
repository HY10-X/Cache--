/// creator:候宇轩 
/// createdate：2023年8月16日
/// input:RowId
/// output:StNo StName StGender StBirthday(%String,%String,%String(0,1,2),%Date)
/// otehr:重建索引_d ##class(User.DHCStudentHYX).%BuildIndices()
Class User.DHCStudentHYX Extends %Persistent [ SqlTableName = DHC_StudentHYX, StorageStrategy = NewStorage1 ]
{

/// 排序列名，rowid默认第一列,所以从第二列开始，SqlColumnNumber=
Property StNo As %String [ SqlColumnNumber = 2, SqlFieldName = St_No ];

/// 姓名St_Name
Property StName As %String [ SqlColumnNumber = 3, SqlFieldName = St_Name ];

/// 性别St_Sex_DR(Ct_Sex)，指向表，指向Ct_Sex
Property StGender As %String [ SqlColumnNumber = 4, SqlFieldName = St_Gender ];

/// 出生日期St_Dob  
Property StBirthday As %Date [ SqlColumnNumber = 5, SqlFieldName = St_Birthday ];

Storage NewStorage1
{
<SqlIdExpression>$I(^DHCSTUDENTHYX(0))</SqlIdExpression>
<SQLMap name="DataMaster">
<ConditionalWithHostVars></ConditionalWithHostVars>
<Data name="St_Birthday">
<Delimiter>"^"</Delimiter>
<Piece>4</Piece>
</Data>
<Data name="St_Gender">
<Delimiter>"^"</Delimiter>
<Piece>3</Piece>
</Data>
<Data name="St_Name">
<Delimiter>"^"</Delimiter>
<Piece>2</Piece>
</Data>
<Data name="St_No">
<Delimiter>"^"</Delimiter>
<Piece>1</Piece>
</Data>
<Global>^DHCSTUDENTHYX</Global>
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
<SQLMap name="GenderIndex">
<ConditionalWithHostVars></ConditionalWithHostVars>
<Global>^DHCSTUDENTHYX</Global>
<PopulationType>nonnull</PopulationType>
<RowIdSpec name="1">
<Expression>{L4}</Expression>
<Field>St_RowId</Field>
</RowIdSpec>
<Subscript name="1">
<Expression>0</Expression>
</Subscript>
<Subscript name="2">
<Expression>"Gender"</Expression>
</Subscript>
<Subscript name="3">
<Expression>{St_Gender}</Expression>
</Subscript>
<Subscript name="4">
<Expression>{St_RowId}</Expression>
</Subscript>
<Type>index</Type>
</SQLMap>
<SqlRowIdName>St_RowId</SqlRowIdName>
<StreamLocation>^User.DHCStudentHYXS</StreamLocation>
<Type>%CacheSQLStorage</Type>
}

/*业务层：BLStudent，定义增删改查方法*/

/// function:根据姓名、性别查询数据，为空时输出所有数据
/// creator:候宇轩 
/// createdate：2023年8月16日
/// input:StName,StGender
/// output:StNo StName StGender StBirthday(%String,%String,%String(0,1,2),%Date)
/// table:DHCSTUDENTHYX
/// otehr:d ##class(User.DHCStudentHYX).GetStudentByNameGender()
ClassMethod GetStudentByNameGender(StName as %String,StGender as %String) As %String
{   
    if (StName=""){
        if (StGender=""){   //输入都为空输出所有数据
            s RowId=0
            for{    
               s RowId=$o(^DHCSTUDENTHYX(RowId)) 
               q:RowId=""
               s DataStr=$g(^DHCSTUDENTHYX(RowId))
               s StNo=$p(DataStr,"^",1)
               s StName=$p(DataStr,"^",2)
               s StGender=$p(DataStr,"^",3)
               //日期转换，将指定格式字符转换为日期格式
               s StBirthday=""
               s StBirthday=$p(DataStr,"^",4)
               s:StBirthday'="" StBirthday=$zd(StBirthday,3)
               w RowId_"学号："_StNo_"姓名："_StName_"性别："_StGender_"日期："_StBirthday_""	
               w !
            }
        }
        else{   //姓名为空，性别不为空，根据性别有索引查找 入参stgender
            quit:($data(^DHCSTUDENTHYX(0,"Gender",StGender))=0) "数据不存在"    ///无索引无数据退出
            s RowId=0
            for{
                s RowId=$o(^DHCSTUDENTHYX(0,"Gender",StGender,RowId)) //获取第一个rowid
                q:RowId=""
                s DataStr=$g(^DHCSTUDENTHYX(RowId))
                s StNo=$p(DataStr,"^",1)
                s StName=$p(DataStr,"^",2)
                s StGender=$p(DataStr,"^",3)
                //日期转换，将指定格式字符转换为日期格式
                s StBirthday=""
                s StBirthday=$p(DataStr,"^",4)
                s:StBirthday'="" StBirthday=$zd(StBirthday,3)
                w RowId_"学号："_StNo_"姓名："_StName_"性别："_StGender_"日期："_StBirthday_""	
                w !  
                }
        }   
    }
    else{   
         if (StGender=""){  //姓名不为空，性别为空，根据姓名查找 input:StName
            //添加
             s RowId=0
             for{    
               s RowId=$o(^DHCSTUDENTHYX(RowId)) 
              
               q:RowId=""   //遍历到最后时跳出
               if ($d(^DHCSTUDENTHYX(RowId))=0){    //不存在数据跳出
                    w "数据不存在"
                    quit
               }
               s DataStr=$g(^DHCSTUDENTHYX(RowId))
               s StNo=$p(DataStr,"^",1)
               s StNameTemp=$p(DataStr,"^",2)
               s StGender=$p(DataStr,"^",3)
               //日期转换，将指定格式字符转换为日期格式
               s StBirthday=""
               s StBirthday=$p(DataStr,"^",4)
               s:StBirthday'="" StBirthday=$zd(StBirthday,3)
               
              if (StNameTemp=StName)||(StNameTemp=""){
                    w RowId_"学号："_StNo_"姓名："_StName_"性别："_StGender_"日期："_StBirthday_""	
                    w !
                }    
            }
         }
         else{  //姓名不为空，性别不为空，根据姓名查找 input:StName，StGender
             //添加
            s RowId=0
            for{    
                s RowId=$o(^DHCSTUDENTHYX(RowId)) 
                q:RowId=""   //遍历到最后时跳出
                if ($d(^DHCSTUDENTHYX(RowId))=0){    //不存在数据跳出
                    w "数据不存在"
                    quit
                }
               s DataStr=$g(^DHCSTUDENTHYX(RowId))
               s StNo=$p(DataStr,"^",1)
               s StNameTemp=$p(DataStr,"^",2)
               s StGenderTemp=$p(DataStr,"^",3)
               //日期转换，将指定格式字符转换为日期格式
               s StBirthday=""
               s StBirthday=$p(DataStr,"^",4)
               s:StBirthday'="" StBirthday=$zd(StBirthday,3)
               
              if (StNameTemp=StName)||(StNameTemp=""){
                if (StGenderTemp=StGender){
                    w RowId_"学号："_StNo_"姓名："_StName_"性别："_StGender_"日期："_StBirthday_""	
                    w !
                }
                else{
                    w "性别输入错误"
                }
                }    
            }
         }
    }
}

/// function:编写使用query
/// input:RowId,Code,Name
/// GetList:入参、GetListExecute：执行，GetListFetch：从执行取数据出参，GetListClose：关闭临时global
/// others:d ##class(%ResultSet).RunQuery("User.DHCStudentSFCA","GetList")
Query GetList() As %query(ROWSPEC = "")
{
}

ClassMethod GetListExecute(ByRef qHandle As %Binary) As %Status
{
	s repid=$i(^CacheTemp)
	s ind=1
	
	s qHandle=$lb(0,repid,0)
	quit $$$OK
OutputRow2
	s Data=$lb()
	s ^Cachetmp(repid,ind)=Data
	s ind=ind+1
	quit
}

ClassMethod GetListFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status
{
}

ClassMethod GetListClose(ByRef qHandle As %Binary) As %Status [ PlaceAfter = GetStudentDataExecute ]
{
	
	Set repid=$LIST(qHandle,2)
	kill ^CacheTemp(repid)
	Quit $$$OK
}

}
}
