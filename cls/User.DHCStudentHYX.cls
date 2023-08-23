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
ClassMethod GetStudentByNameGender(StName As %String, StGender As %String) As %String
{
   
    d ##class(%ResultSet).RunQuery("User.DHCStudentHYX","GetList",StName)   //调用query传出数据测试
    b
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

/// function:编写使用按照学号查询query
/// input:RowId,StNo,StName
/// GetList:入参、GetListExecute：执行，GetListFetch：从执行取数据出参，GetListClose：关闭临时global
/// others:d ##class(%ResultSet).RunQuery("User.DHCStudentHYX","GetList","1")
Query GetList(No As %String) As %Query(ROWSPEC = "StRowId:%String,StNo:%String,StName:%String,StGender:%String,StBirthday:%Date")
{
}

ClassMethod GetListExecute(ByRef qHandle As %Binary, No As %String) As %Status
{
	Set repid=$INCREMENT(^CacheTemp)
	Set ind=1
	Set StRowId=0
	For{
		Set StRowId=$ORDER(^DHCSTUDENTHYX(StRowId)) Quit:StRowId=""
		Set StNo=$PIECE($GET(^DHCSTUDENTHYX(StRowId)),"^",1)
		Set StName=$PIECE($GET(^DHCSTUDENTHYX(StRowId)),"^",2)
		Set StGender=$PIECE($GET(^DHCSTUDENTHYX(StRowId)),"^",3)	///取性别描述
		Set StBirthday=$PIECE($GET(^DHCSTUDENTHYX(StRowId)),"^",4) 
		Set:StBirthday'="" StBirthday=$ZDATE(StBirthday,3)
			///[包含
			///输出至CacheTemp
            
		If (StNo[No){
			Set data=$LISTBUILD(StRowId,StNo,StName,StGender,StBirthday)
			Set ^CacheTemp(repid,ind)=data
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

/// function:面向对象的方法实现新增操作
/// input:StNo,StName,StGender,StBirthday
/// others:d ##class(User.DHCStudentHYX).AddData("8888","张新增","1","2001-01-01")
/// w ##class(User.DHCStudentHYX).AddData("9","张新增2","1","2001-01-01")
ClassMethod AddData(StNo As %String, StName As %String, StGender As %String, StBirthday As %Date) As %String
{
   
    Quit:(StNo="")||(StName="") "学号或姓名为空"
    s RowIdIdenti=0
    s Count=0
    for{    //遍历判断学号是否重复
        s RowIdIdenti=$o(^DHCSTUDENTHYX(RowIdIdenti))   //取rowid值 
        q:RowIdIdenti="" //rowid为空跳出 
        s StNoTemp=$p(^DHCSTUDENTHYX(RowIdIdenti),"^",1)    //取学号值
       if (StNoTemp=StNo){
            s Count=Count+1     //统计重复的学号
        }
       // w StNoTemp,!
    }
    if (Count'=0){
        return "学号已存在"
    }
    //判断性别输入是否正确
    if (StGender'=0||StGender'=1||StGender'=2){
        return "性别输入错误"
    }
    Set:StBirthday'="" StBirthday=##class(websys.Conversions).DateHtmlToLogical(StBirthday) //标准转换日期接口 = $zdh(stdob,3)
 	Set oref=##class(User.DHCStudentHYX).%New()
    If (oref){    //判断对象是否创建，还可以写做 (oref)
        Set oref.StNo=StNo
        Set oref.StName=StName
        Set oref.StGender=StGender
        Set oref.StBirthday=StBirthday  //需要转换格式，转换为逻辑数字传输
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

/// function:更改学生信息
/// table：DHC_StudenHYX
/// input:StRowId,StNo,StName,StGender,StBirthday
/// output:
/// other:w ##class(User.DHCStudentHYX).UpdateData("5","8888","张xiugai","0","2001-02-21")
ClassMethod UpdateData(StRowId As %String, StNo As %String, StName As %String, StGender As %String, StBirthday As %Date) As %String
{
	q:(StRowId="") "RowId为空"
    Quit:(StNo="")||(StName="") "学号或姓名为空"_StRowId 
    //判断性别输入是否正确
    if (StGender'=0){
        if (StGender'=2){
            if (StGender'=1){
                 return "性别输入错误"
            }
        }
       
    }
	Set:StBirthday'="" StBirthday=$zdh(StBirthday,3)    //转换日期格式
	s obj=##class(User.DHCStudentHYX).%OpenId(StRowId) //open obejct 
	if (obj){
		s obj.StNo=StNo
        s obj.StName=StName
        s obj.StGender=StGender
		s obj.StBirthday=StBirthday
      
		TSTART		//引入事务
		s sc=obj.%Save()	//save obj
		if (sc=1){
			TCOMMIT
			s result=1
		}
		Else{
			TROLLBACK
			s result=0
		}
		d obj.%Close()
		q result
	}
}

/// function:删除数据
/// table：DHC_StudentHYX
/// input:StRowId（不为空）
/// output:
/// other:w ##class(User.DHCStudentHYX).DeleteData("6")
ClassMethod DeleteData(StRowId As %String) As %String
{
	Quit:StRowId="" "RowId为空"
	Set obj=##class(User.DHCStudentHYX).%OpenId(StRowId)
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
    return result
}

/// 按照范例重新编写增删改查
/// 
/// function:更改学生信息,新增学生信息
/// table：DHC_StudenHYX
/// input:StRowId,StNo,StName,StGender,StBirthday
/// output:
/// other:w ##class(User.DHCStudentHYX).UpdateData("5","8888","张xiugai","0","2001-02-21")
ClassMethod UpdateDataByex(StRowId As %String, StNo As %String, StName As %String, StGender As %String, StBirthday As %Date) As %String
{
    //前端限制性别选择
    /*
    if (StGender'=0){
        if (StGender'=2){
            if (StGender'=1){
                 return "性别输入错误"
            }
        }
    }
    */
    if (StRowId=""){
    s RowIdIdenti=0
    s Count=0
    for{    //遍历判断学号是否重复
        s RowIdIdenti=$o(^DHCSTUDENTHYX(RowIdIdenti))   //取rowid值 
        q:RowIdIdenti="" //rowid为空跳出 
        s StNoTemp=$p(^DHCSTUDENTHYX(RowIdIdenti),"^",1)    //取学号值
       if (StNoTemp=StNo){
            s Count=Count+1     //统计重复的学号
        }
       // w StNoTemp,!
    }
    if (Count'=0){
        return 0_"学号已存在"
    }
    //判断性别输入是否正确,前端验证

    Set:StBirthday'="" StBirthday=##class(websys.Conversions).DateHtmlToLogical(StBirthday) //标准转换日期接口 = $zdh(stdob,3)
 	Set oref=##class(User.DHCStudentHYX).%New()
    If (oref){    //判断对象是否创建，还可以写做 (oref)
        Set oref.StNo=StNo
        Set oref.StName=StName
        Set oref.StGender=StGender
        Set oref.StBirthday=StBirthday  //需要转换格式，转换为逻辑数字传输
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
    else{
        Set:StBirthday'="" StBirthday=$zdh(StBirthday,3)    //转换日期格式
        s obj=##class(User.DHCStudentHYX).%OpenId(StRowId) //open obejct 
        if (obj){
            s obj.StNo=StNo
            s obj.StName=StName
            s obj.StGender=StGender
            s obj.StBirthday=StBirthday
        
            TSTART		//引入事务
            s sc=obj.%Save()	//save obj
            if (sc=1){
                TCOMMIT
                s result=1
            }
            Else{
                TROLLBACK
                s result=0
            }
            d obj.%Close()
            q result
        }

    }
}

/// function:编写使用按照姓名查询query
/// input:StName
/// GetList:入参、GetListExecute：执行，GetListFetch：从执行取数据出参，GetListClose：关闭临时global
/// others:d ##class(%ResultSet).RunQuery("User.DHCStudentHYX","GetListByName","张三")
Query GetListByName(Name As %String) As %Query(ROWSPEC = "StRowId:%String,StNo:%String,StName:%String,StGender:%String,StBirthday:%Date")
{
}

ClassMethod GetListByNameExecute(ByRef qHandle As %Binary, Name As %String) As %Status
{
	Set repid=$INCREMENT(^CacheTemp)
	Set ind=1
	Set StRowId=0
	For{
		Set StRowId=$ORDER(^DHCSTUDENTHYX(StRowId)) Quit:StRowId=""
		Set StNo=$PIECE($GET(^DHCSTUDENTHYX(StRowId)),"^",1)
		Set StName=$PIECE($GET(^DHCSTUDENTHYX(StRowId)),"^",2)
		Set StGender=$PIECE($GET(^DHCSTUDENTHYX(StRowId)),"^",3)	///取性别描述
		Set StBirthday=$PIECE($GET(^DHCSTUDENTHYX(StRowId)),"^",4) 
		Set:StBirthday'="" StBirthday=$ZDATE(StBirthday,3)
			///[包含
			///输出至CacheTemp
            
		If (StName[Name){
			Set data=$LISTBUILD(StRowId,StNo,StName,StGender,StBirthday)
			Set ^CacheTemp(repid,ind)=data
			Set ind=ind+1
		
		}
		
	}
	
	Set qHandle=$LISTBUILD(0,repid,0)
		
	Quit $$$OK
}

ClassMethod GetListByNameFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status
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

ClassMethod GetListByNameClose(ByRef qHandle As %Binary) As %Status [ PlaceAfter = GetListExecute ]
{
	
	Set repid=$LIST(qHandle,2)
	Kill ^CacheTemp(repid)
	Quit $$$OK
}

/// 接受前端数据调用query
/// d ##class(User.DHCStudentHYX).GetFrontNameExucet("张三")
ClassMethod GetFrontNameExucet(FrontName As %String) As %String
{
    d ##class(%ResultSet).RunQuery("User.DHCStudentHYX","GetListByName",FrontName)
    Quit $$$OK
}


/// function:编写使用按照性别查询query,使用索引
/// input:StGender
/// GetList:入参、GetListExecute：执行，GetListFetch：从执行取数据出参，GetListClose：关闭临时global
/// others:d ##class(%ResultSet).RunQuery("User.DHCStudentHYX","GetListByGender","")
Query GetListByGender(Gender As %String) As %Query(ROWSPEC = "StRowId:%String,StNo:%String,StName:%String,StGender:%String,StBirthday:%Date")
{
}

ClassMethod GetListByGenderExecute(ByRef qHandle As %Binary, Gender As %String) As %Status
{
	Set repid=$INCREMENT(^CacheTemp)
	Set ind=1
	Set StRowId=0
        quit:($data(^DHCSTUDENTHYX(0,"Gender",Gender))=0) //性别不存在退出
            s RowId=0
            for{
                s RowId=$o(^DHCSTUDENTHYX(0,"Gender",Gender,RowId)) //获取第一个rowid
                q:RowId=""
                s StRowId=RowId
                Set StNo=$PIECE($GET(^DHCSTUDENTHYX(StRowId)),"^",1)
                Set StName=$PIECE($GET(^DHCSTUDENTHYX(StRowId)),"^",2)
                Set StGender=$PIECE($GET(^DHCSTUDENTHYX(StRowId)),"^",3)	///取性别描述
                Set StBirthday=$PIECE($GET(^DHCSTUDENTHYX(StRowId)),"^",4) 
                Set:StBirthday'="" StBirthday=$ZDATE(StBirthday,3)
                
                ///[包含
			    ///输出至CacheTemp
                If (StGender[Gender){
                
			    Set data=$LISTBUILD(StRowId,StNo,StName,StGender,StBirthday)
			    Set ^CacheTemp(repid,ind)=data
			    Set ind=ind+1
		
		}
                }
			
	
	
	Set qHandle=$LISTBUILD(0,repid,0)
		
	Quit $$$OK
}

ClassMethod GetListByGenderFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status
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

ClassMethod GetListByGenderClose(ByRef qHandle As %Binary) As %Status [ PlaceAfter = GetListExecute ]
{
	
	Set repid=$LIST(qHandle,2)
	Kill ^CacheTemp(repid)
	Quit $$$OK
}

}
