/// 功能：创建学生选课表
/// 创建日期：2023年8月15日
/// 创建人：houyuxuan
/// 字段：StSc_RowId,DHCScCourseDR,DHCScScore
Class User.DHCStudentCourseSFCA Extends %Persistent [ SqlTableName = DHC_StudentCourseSFCA, StorageStrategy = NewStorage1 ]
{

/// 子表中定义父表	
Relationship DHCParRef As DHCStudentSFCA [ Cardinality = parent, Inverse = ChildCourse ];

/// 创建childsub
Property DHCScChildSub As %Numeric [ InitialExpression = {$i(^DHCCOURSESFCA(+$s(initvalue:initvalue,1:%d(0)),"Course","0"))}, Required, SqlColumnNumber = 2, SqlFieldName = DHC_ScChildSub ];

/// 课程变量
Property DHCScCourseDR As DHCCourseSFC [ SqlColumnNumber = 3, SqlFieldName = DHC_ScCourse_DR ];

/// 成绩
Property DHCScScore As %Integer [ SqlColumnNumber = 4, SqlFieldName = DHCScScore ];

/// 给childsub定义索引
Index IndexName On DHCScChildSub [ IdKey, PrimaryKey, Unique ];

Storage NewStorage1
{
<SQLMap name="DataMaster">
<Data name="DHCScScore">
<Delimiter>"^"</Delimiter>
<Piece>2</Piece>
</Data>
<Data name="DHC_ScCourse_DR">
<Delimiter>"^"</Delimiter>
<Piece>1</Piece>
</Data>
<Global>^DHCCOURSESFCA</Global>
<RowIdSpec name="1">
<Expression>{L1}</Expression>
<Field>DHC_StudentSFCA.St_RowId</Field>
</RowIdSpec>
<RowIdSpec name="2">
<Expression>{L3}</Expression>
<Field>DHC_ScChildSub</Field>
</RowIdSpec>
<Subscript name="1">
<Expression>{DHC_StudentSFCA.St_RowId}</Expression>
<StartValue>1</StartValue>
</Subscript>
<Subscript name="2">
<Expression>"Course"</Expression>
</Subscript>
<Subscript name="3">
<Expression>{DHC_ScChildSub}</Expression>
<StartValue>1</StartValue>
</Subscript>
<Type>data</Type>
</SQLMap>
<SqlRowIdName>StSc_RowId</SqlRowIdName>
<StreamLocation>^User.DHCStudentCourseSFCAS</StreamLocation>
<Type>%CacheSQLStorage</Type>
}

}
