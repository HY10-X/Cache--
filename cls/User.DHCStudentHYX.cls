/// creator:候宇轩 
/// createdate：2023年8月16日
/// input:RowId
/// output:No Name Gender Birthday(%String,%String,%String(0,1,2),%Date)
/// otehr:重建索引_d ##class(User.DHCStudentHYX).%BuildIndices()
/// 
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

}
