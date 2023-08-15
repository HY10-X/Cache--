/// 功能：创建学生选课表
/// 创建日期：2023年8月15日
/// 创建人：houyuxuan
/// 字段：StSc_RowId,DHCScCourseDR,DHCScScore
Class User.DHCStudentCourseSFCA Extends %Persistent [ SqlTableName = DHC_StudentCourseSFCA, StorageStrategy = NewStorage1 ]
{

/// 子表中定义父表	
Relationship DHCParef As DHCStudentSFCA [ Cardinality = parent, Inverse = ChildCourse ];
///创建childsub
Property DHCscChildSub As %Numeric[InitialExpression={$i(^DHCCOURSESFCA(+$s(initvalue:initvalue,1:%d(0))),"","")}];
/// 课程变量
Property DHCScCourseDR As DHCCourse [ SqlFieldName = DHC_ScCourse_DR ];

/// 成绩
Property DHCScScore As %Integer [ SqlFieldName = DHCScScore ];

Storage NewStorage1
{
<SqlRowIdName>StSc_RowId</SqlRowIdName>
<Type>%CacheSQLStorage</Type>
}

}
