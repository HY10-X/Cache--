/// creator:候宇轩 
/// createdate：2023年8月16日
/// input:RowId
/// output:No Name Gender Birthday(%String,%String,%String(0,1,2),%Date)
/// otehr:
Class User.DHCStudentHYX Extends %Persistent [ SqlTableName = DHC_StudentHYX]
{

/// 排序列名，rowid默认第一列,所以从第二列开始，SqlColumnNumber=
Property StNo As %String [ SqlColumnNumber = 2, SqlFieldName = No ];

/// 姓名St_Name
Property StName As %String [ SqlColumnNumber = 3, SqlFieldName = Name ];

/// 性别St_Sex_DR(Ct_Sex)，指向表，指向Ct_Sex
Property StGender As %String [ SqlColumnNumber = 4, SqlFieldName = Gender ];

/// 出生日期St_Dob  
Property StBirthday As %Date [ SqlColumnNumber = 5, SqlFieldName = Birthday ];

}
