
(function (win) {
	$(function() {
	
		$HUI.datagrid('#ctsystemTable',{
			fit: true,
			border: false,
			toolbar: [{
				iconCls: 'icon-add',
				text: '新增',
				handler: function(){
					editCtSystem("add");
				}
			},{
				iconCls: 'icon-edit',
				text: '修改',
				handler: function(){
					editCtSystem("edit");
				}
			}],
			rownumbers: true,
			singleSelect: true,
			pagination: true,
			pageSize: 20,
			pageList: [10, 20, 50],
			url: $URL,
			queryParams:{
				ClassName: 'DHCEPRFS.BL.BLCTSystem',
				QueryName: 'GetCTSystem'
			},
			columns: [[
				//{ field: 'ck', checkbox: true },
				{ field: 'SysCode', title: '系统代码', width: 150},
				{ field: 'SysName', title: '系统名称', width: 150},
				{ field: 'StartDate', title: '启用日期', width: 150 },
				{ field: 'Notes', title: '备注', width: 180 },
				{ field: 'LastModifyDate', title: '更新日期', width: 150 },
				{ field: 'LastModifyTime', title: '更新时间', width: 150 }
			]]
		});
		// 字典类型新增、修改事件
		function editCtSystem(op){
			var selected = $("#ctsystemTable").datagrid('getSelected');
			if (( op == "edit")&&(!selected)) {
				$.messager.alert("提示","请选择一条记录...","info")
				return false;
			}
			$('#CtSystemDialog').css('display','block');
			var _title = "修改系统类型",_icon="icon-w-edit"
			if (op == "add") {
				_title = "添加系统类型",_icon="icon-w-add";
				$("#txtACTSystemID").val('');
				$("#txtSysCode").val('');
				$("#txtSysName").val('');
				$("#txtStartDate").datebox('setValue','');
				$("#txtNotes").val('');
			} else {
				$("#txtACTSystemID").val(selected.SysID);
				$("#txtSysCode").val(selected.SysCode);
				$("#txtSysName").val(selected.SysName);
				$("#txtStartDate").datebox('setValue',selected.StartDate);
				$("#txtNotes").val(selected.Notes);
			}

			var CtSystemDialog = $HUI.dialog('#CtSystemDialog', {
				title: _title,
				iconCls: _icon,
				modal: true,
				minimizable:false,
				maximizable:false,
				maximizable:false,
				collapsible:false,
				buttons:[{
					text:'保存',
						iconCls:'icon-w-save',
						handler:function(){
							saveCtSystem();
						}
				},{
				text:'关闭',
				iconCls:'icon-w-close',
				handler:function(){
						$('#CtSystemDialog').window("close");
					}	
				}]
			});
		}
		// 系统保存操作
		function saveCtSystem(){
			var CTSystemID = $("#txtACTSystemID").val();
			var SysCode = $("#txtSysCode").val();
			var SysName = $("#txtSysName").val();
			var StartDate = $("#txtStartDate").datebox('getValue');
			var Notes = $("#txtNotes").val();
			if (SysCode == '') {
				$.messager.alert("提示","请填写系统代码...","info")
				return false;
			}
			if (SysName == '') {
				$.messager.alert("提示","请填写系统名称...","info")
				return false;
			}
			if (StartDate == '') {
				$.messager.alert("提示","请填写启用日期...","info")
				return false;
			}
			var flg = $m({
				ClassName:"DHCEPRFS.BL.BLCTSystem",
				MethodName:"UpdateCTSystem",
				ACTSystemID:CTSystemID,
				ASysCode:SysCode,
				ASysName:SysName,
				AStartDate:StartDate,
				ANotes:Notes
			},false);
			
			if (parseInt(flg) == 0) {
				$.messager.alert("错误提示", "保存失败!", 'info');
				return;
			}else{
				$.messager.alert("提示", "保存成功!", 'info');
			}
			
			$('#CtSystemDialog').window("close");
			$("#ctsystemTable").datagrid("reload");

		}
	});
	
}(window));
