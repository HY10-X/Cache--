/// 功能：创建学生选课表
/// 创建日期：2023年8月15日
/// 创建人：houyuxuan
/// 字段：StSc_RowId,DHCScCourseDR,DHCScScore
Class User.DHCStudentCourseSFCA Extends %Persistent [ SqlTableName = DHC_StudentCourseSFCA, StorageStrategy = NewStorage1 ]
{

/// 子表中定义父表	
Relationship DHCScParRef As DHCStudentSFCA [ Cardinality = parent, Inverse = ChildCourse, SqlFieldName = DHC_ScParRef ];

/// 创建childsub
Property DHCScChildSub As %Numeric(SCALE = 0) [ InitialExpression = {$INCREMENT(^DHCCOURSESFCA(+$SELECT($DATA(initvalue):initvalue,1:%d(0)),"Course","0"))}, Required, SqlColumnNumber = 2, SqlFieldName = DHC_ScChildSub ];

/// 课程变量
Property DHCScCourseDR As DHCCourseSFC [ SqlColumnNumber = 3, SqlFieldName = DHC_ScCourse_DR ];

/// 成绩
Property DHCScScore As %Integer [ SqlColumnNumber = 4, SqlFieldName = DHC_ScScore ];

/// 给childsub定义索引
Index IndexName On DHCScChildSub [ IdKey, PrimaryKey, Unique ];

Storage NewStorage1
{
<SQLMap name="DataMaster">
<ConditionalWithHostVars></ConditionalWithHostVars>
<Data name="DHC_ScCourse_DR">
<Delimiter>"^"</Delimiter>
<Piece>1</Piece>
</Data>
<Data name="DHC_ScScore">
<Delimiter>"^"</Delimiter>
<Piece>2</Piece>
</Data>
<Global>^DHCSTUDENTSFCA</Global>
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
<SQLMap name="IndexCourseDR">
<ConditionalWithHostVars></ConditionalWithHostVars>
<Global>^DHCCOURSESFCA</Global>
<PopulationType>nonnull</PopulationType>
<RowIdSpec name="1">
<Expression>{L4}</Expression>
<Field>DHC_StudentSFCA.St_RowId</Field>
</RowIdSpec>
<RowIdSpec name="2">
<Expression>{L5}</Expression>
<Field>DHC_ScChildSub</Field>
</RowIdSpec>
<Subscript name="1">
<Expression>0</Expression>
</Subscript>
<Subscript name="2">
<Expression>"CourseDR"</Expression>
</Subscript>
<Subscript name="3">
<Expression>{DHC_ScCourse_DR}</Expression>
</Subscript>
<Subscript name="4">
<Expression>{DHC_StudentSFCA.St_RowId}</Expression>
</Subscript>
<Subscript name="5">
<Expression>{DHC_ScChildSub}</Expression>
</Subscript>
<Type>index</Type>
</SQLMap>
<SqlRowIdName>StSc_RowId</SqlRowIdName>
<StreamLocation>^User.DHCStudentCourseSFCAS</StreamLocation>
<Type>%CacheSQLStorage</Type>
}

}
