var FSApplyPermission = new Object();

FSApplyPermission.selectDocLocID = "";
FSApplyPermission.selectSSGroupID = "";

FSApplyPermission.selectPatientLocID = "";
FSApplyPermission.selectPatientWardID = "";

FSApplyPermission.ExpandAppointID = "";

FSApplyPermission.ExpandIndex = "-1";
FSApplyPermission.SubGridSelect = "-1";

FSApplyPermission.dateStart = "";
FSApplyPermission.dateEnd = "";
FSApplyPermission.typeCode = "";

FSApplyPermission.HDateStart = "";
FSApplyPermission.HDateEnd = "";

FSApplyPermission.DialogType = "add";
FSApplyPermission.selectEpisodeID = "";
FSApplyPermission.selectFavoritesCategoryID = "";
FSApplyPermission.addFavoriteType = "";
FSApplyPermission.favoritesIDS = "";
FSApplyPermission.favoritesEpisodeIDS = "";
FSApplyPermission.requestEpisodeIDS = "";
FSApplyPermission.spanTime = "";

//表明申请的为病案归档的权限
FSApplyPermission.EPRACTION = "FS";
FSApplyPermission.DATESPAN = 7;
FSApplyPermission.DATASERVICEURL = dataServiceURL;
FSApplyPermission.WINCOUNT = 0;

(function($) {
    $(function() {
        //$('#applyListPanel').panel('maximize');
        //$('#applyDefaultListPanel').panel('close');
        $('#applyListPanel').panel('close');
        $('#applyDefaultListPanel').panel('open');
        $('#applyDefaultListPanel').panel('maximize');
		//设置系统标识
		var sysDesc = systemName + '&nbsp;&nbsp;&nbsp;&nbsp;' + systemVersion;
		$('#systemDesc').html(sysDesc);
		//按钮文字描述---------------------------------------------------------------------------------------------------------------------------
		if (hospitalFlag == "BJFC")
		{
			$('#addNewApplyBtn').html('扫描病历浏览申请<font color="red">(需审批)</font>');
			$('#addDefaultRoleBtn').html('科研病历浏览(无需审批)');
		}

		//新增申请弹窗---------------------------------------------------------------------------------------------------------------------------
		var winInline = $('#addApplyWin').window({
			modal:true,
			inline:true,
			closed:true,
			iconCls:'icon-add',
			title: '新增浏览申请',
			onBeforeClose: function(){
				//检查是否在待申请表格中有数据
				if ($('#addListTable').datagrid('getRows').length > 0){
					if (confirm('窗口正在关闭，在待申请表格中还有数据，确定关闭界面?。\n 是否继续关闭窗口？')) {
						//关闭并忽略onBeforeClose事件
						$('#addApplyWin').window('close',true);
					}
					else{
						return false;
					}
				}
			}
		});
		
		//点击弹窗
        $('#addApplyBtn').on('click', function() {
        	//患者查询列表
	        var patientDG = $('#patientListTable').datagrid({
	            //url: '../DHCEPRRBAC.web.eprajax.ApplyPermission.cls',
	            queryParams: {
					Action: 'episodelist',
					UserID: appointUserID,
					UserLocID: appointUserLoc,
					UserSSGroupID: appointUserSSGroupID,
	                PatientName: '',
	                PatientLocID: '',
	                PatientWardID: '',
	                EpisodeID: '',
	                PatientID: '',
	                RegNo: '',
	                MedRecordID:''
	            },
	            method: 'post',
	            loadMsg: '数据装载中......',
	            //singleSelect: true,
	            showHeader: true,
	            //fitColumns: true,
				rownumbers:true,
	            columns: [[
					{ field: 'ck', checkbox: true},
	                { field: 'PAStatusType', title: '状态', width: 80, sortable: true },
	                { field: 'PAAdmType', title: '就诊类型', width: 80, sortable: true },
	                { field: 'PAPMIName', title: '病人姓名', width: 80, sortable: true },
	                { field: 'PAPMINO', title: '登记号', width: 80, sortable: true },
	                { field: 'PAPMIDOB', title: '出生日期', width: 100, sortable: true },
	                { field: 'PAPMIAge', title: '年龄', width: 80, sortable: true },
	                { field: 'PAPMISex', title: '性别', width: 80, sortable: true },
	                { field: 'PAAdmDateTime', title: '入院时间', width: 150, sortable: true },
	                { field: 'PAAdmWard', title: '病区', width: 80, sortable: true },
	                { field: 'PAAdmRoom', title: '病房', width: 80, sortable: true },
	                { field: 'PAAdmBed', title: '病床', width: 80, sortable: true },
	                { field: 'PAAdmLoc', title: '科室', width: 80, sortable: true },
	                { field: 'PADischgeDateTime', title: '出院时间', width: 150, sortable: true },
	                { field: 'PAAdmDoc', title: '医生', width: 80, sortable: true },
	                { field: 'PayMode', title: '付费类型', width: 80, sortable: true },
	                { field: 'EpisodeID', title: '就诊号', width: 80, sortable: true },
	                { field: 'PatientID', title: '病人号', width: 80, sortable: true },
					{ field: 'CodeStatus', title: 'CodeStatus', width: 80, sortable: true, hidden:true },
					{ field: 'CodeStatusDesc', title: '是否编目', width: 80, sortable: true },
					{ field: 'CheckNoNeedApply', title: '是否可无需申请', width: 80, sortable: true },
					{ field: 'IsAdvancedSecurity', title: 'IsAdvancedSecurity', width: 80, sortable: true, hidden:true }
	            ]],
                rowStyler:function(index,row){
                    if (row.CodeStatus == "0")
                    {
                        return 'background-color:#ddd;color:black;';
                    }
                    if (row.IsAdvancedSecurity == "Y")
                    {
                        return 'background-color:pink;color:blue;font-weight:bold;';
                    }
					
					if (row.CheckNoNeedApply == "1")
					{
						return 'background-color:lightgreen;color:black;font-weight:bold;';
					}
                },
	            pagination: true,
	            pageSize: 20,
	            pageList: [10, 20, 50],
	            pagePosition: 'bottom',
	            toolbar: '#patientListTableTBar',
	            title: '患者查询'
	        });
			/*
			//选择患者就诊科室
	        $('#inputPatientLoc').combogrid({
	            //url: '',
	            queryParams: {
	                DicCode: 'S71',
	                Filter: ''
	            },
	            panelWidth: 300,
	            idField: 'ID',
	            textField: 'DicDesc',
	            method: 'get',
	            showHeader: false,
	            //fitColumns: true,
	            columns: [[
	                { field: 'ID', title: 'ID', width: 80, hidden: true },
	                { field: 'DicAlias', title: 'DicAlias', width: 80, hidden: true },
	                { field: 'DicCode', title: 'DicCode', width: 80, hidden: true },
	                { field: 'DicDesc', title: 'DicDesc', width: 250 }
	            ]],
	            pagination: true,
	            pageSize: 10,
	            pageList: [5, 10, 20],
	            keyHandler: {
	                query: function(q) {
	                    //动态搜索
	                    var url = '../DHCEPRRBAC.web.eprajax.DicList.cls';
	                    $('#inputPatientLoc').combogrid('grid').datagrid('options').url = url;
	                    var queryParams = $('#inputPatientLoc').combogrid('grid').datagrid('options').queryParams;
	                    queryParams.Filter = q;
	                    $('#inputPatientLoc').combogrid('grid').datagrid('options').queryParams = queryParams;
	                    $('#inputPatientLoc').combogrid('grid').datagrid('reload');
	                    $('#inputPatientLoc').combogrid("setValue", q);
	                }
	            },
	            onSelect: function() {
	                FSApplyPermission.selectPatientLocID = "";
	                var rows = $('#inputPatientLoc').combogrid('grid').datagrid('getSelections');
	                var row = rows[0];
	                FSApplyPermission.selectPatientLocID = row["DicCode"];
	                searchPatient();
	            },
	            onShowPanel:function(){
	                 var url = '../DHCEPRRBAC.web.eprajax.DicList.cls';
	                 $('#inputPatientLoc').combogrid('grid').datagrid('options').url = url;
	                 var queryParams = $('#inputPatientLoc').combogrid('grid').datagrid('options').queryParams;
	                 $('#inputPatientLoc').combogrid('grid').datagrid('options').queryParams = queryParams;
	                 $('#inputPatientLoc').combogrid('grid').datagrid('reload');         		
	            }
	        });
	
	        //选择患者就诊病区
	        $('#inputPatientWard').combogrid({
	            //url: '',
	            queryParams: {
	                DicCode: 'S72',
	                Filter: ''
	            },
	            panelWidth: 300,
	            idField: 'ID',
	            textField: 'DicDesc',
	            method: 'get',
	            showHeader: false,
	            //fitColumns: true,
	            columns: [[
	                { field: 'ID', title: 'ID', width: 80, hidden: true },
	                { field: 'DicAlias', title: 'DicAlias', width: 80, hidden: true },
	                { field: 'DicCode', title: 'DicCode', width: 80, hidden: true },
	                { field: 'DicDesc', title: 'DicDesc', width: 250 }
	            ]],
	            pagination: true,
	            pageSize: 10,
	            pageList: [5, 10, 20],
	            keyHandler: {
	                query: function(q) {
	                    //动态搜索
	                    var url = '../DHCEPRRBAC.web.eprajax.DicList.cls';
	                    $('#inputPatientLoc').combogrid('grid').datagrid('options').url = url;
	                    var queryParams = $('#inputPatientLoc').combogrid('grid').datagrid('options').queryParams;
	                    queryParams.Filter = q;
	                    $('#inputPatientLoc').combogrid('grid').datagrid('options').queryParams = queryParams;
	                    $('#inputPatientLoc').combogrid('grid').datagrid('reload');
	                    $('#inputPatientLoc').combogrid("setValue", q);
	                }
	            },
	            onSelect: function() {
	                FSApplyPermission.selectPatientWardID = "";
	                var rows = $('#inputPatientWard').combogrid('grid').datagrid('getSelections');
	                var row = rows[0];
	                FSApplyPermission.selectPatientWardID = row["DicCode"];
	                searchPatient();
	            },
	            onShowPanel:function(){
	                 var url = '../DHCEPRRBAC.web.eprajax.DicList.cls';
	                 $('#inputPatientLoc').combogrid('grid').datagrid('options').url = url;
	                 var queryParams = $('#inputPatientLoc').combogrid('grid').datagrid('options').queryParams;
	                 $('#inputPatientLoc').combogrid('grid').datagrid('options').queryParams = queryParams;
	                 $('#inputPatientLoc').combogrid('grid').datagrid('reload');         		
	            }
	        });
			*/
			//查询患者
	        $('#patientSearchBtn').on('click', function() {
	            //debugger;
	            searchPatient();
	        });
	
	        //清空患者查询条件
	        $('#patientResetBtn').on('click', function() {
	            $('#inputPatientName').val('');
	            $('#inputPatientEpisodeID').val('');
	            $('#inputPatientRegNo').val('');
	            $('#inputPatientID').val('');
	            $('#inputMedRecordID').val('');
	            $('#inputPatientLoc').combogrid("setValue", '');
	            $('#inputPatientWard').combogrid("setValue", '');
	            FSApplyPermission.selectPatientLocID = "";
	            FSApplyPermission.selectPatientWardID = "";
	        });
	
	        //输入框enter事件
	        $('#inputPatientName').on('keypress', function(event) {
	            if (event.keyCode == "13") {
	                searchPatient();
	            }
	        });
	
	        $('#inputPatientEpisodeID').on('keypress', function(event) {
	            if (event.keyCode == "13") {
	                searchPatient();
	            }
	        });
	
	        $('#inputPatientID').on('keypress', function(event) {
	            if (event.keyCode == "13") {
	                searchPatient();
	            }
	        });
	
	        $('#inputPatientRegNo').on('keypress', function(event) {
	            if (event.keyCode == "13") {
	                searchPatient();
	            }
	        });
	        
	        $('#inputMedRecordID').on('keypress', function(event) {
	            if (event.keyCode == "13") {
	                searchPatient();
	            }
	        });
	
			//查询就诊
	        function searchPatient() {
	        	var url = '../DHCEPRRBAC.web.eprajax.ApplyPermission.cls';
	         	$('#patientListTable').datagrid('options').url = url;
	            var queryParams = $('#patientListTable').datagrid('options').queryParams;
	            queryParams.PatientLocID = FSApplyPermission.selectPatientLocID;
	            queryParams.PatientWardID = FSApplyPermission.selectPatientWardID;
	            queryParams.PatientName = $('#inputPatientName').val();
	            queryParams.EpisodeID = $('#inputPatientEpisodeID').val();
	            queryParams.PatientID = $('#inputPatientID').val();
	            queryParams.RegNo = $('#inputPatientRegNo').val();
	            queryParams.MedRecordID = $('#inputMedRecordID').val();
	            $('#patientListTable').datagrid('options').queryParams = queryParams;
	            $('#patientListTable').datagrid('reload');
	        }
        	
			$('#addApplyWin').window('open');
        });
		
		//待申请列表
		$('#addListTable').datagrid({
			showHeader: true,
            //fitColumns: true,
			rownumbers:true,
            columns: [[
				{ field: 'ck', checkbox: true},
                { field: 'PAStatusType', title: '状态', width: 80, sortable: true },
                { field: 'PAAdmType', title: '就诊类型', width: 80, sortable: true },
                { field: 'PAPMIName', title: '病人姓名', width: 80, sortable: true },
                { field: 'PAPMINO', title: '登记号', width: 80, sortable: true },
                { field: 'PAPMIDOB', title: '出生日期', width: 100, sortable: true },
                { field: 'PAPMIAge', title: '年龄', width: 80, sortable: true },
                { field: 'PAPMISex', title: '性别', width: 80, sortable: true },
                { field: 'PAAdmDateTime', title: '入院时间', width: 150, sortable: true },
                { field: 'PAAdmWard', title: '病区', width: 80, sortable: true },
                { field: 'PAAdmRoom', title: '病房', width: 80, sortable: true },
                { field: 'PAAdmBed', title: '病床', width: 80, sortable: true },
                { field: 'PAAdmLoc', title: '科室', width: 80, sortable: true },
                { field: 'PADischgeDateTime', title: '出院时间', width: 150, sortable: true },
                { field: 'PAAdmDoc', title: '医生', width: 80, sortable: true },
                { field: 'PayMode', title: '付费类型', width: 80, sortable: true },
                { field: 'EpisodeID', title: '就诊号', width: 80, sortable: true },
                { field: 'PatientID', title: '病人号', width: 80, sortable: true },
				{ field: 'CodeStatus', title: 'CodeStatus', width: 80, sortable: true, hidden:true },
				{ field: 'CodeStatusDesc', title: '是否编目', width: 80, sortable: true },
				{ field: 'CheckNoNeedApply', title: '是否可无需申请', width: 80, sortable: true },
                { field: 'IsAdvancedSecurity', title: 'IsAdvancedSecurity', width: 80, sortable: true, hidden:true }
            ]],
            toolbar: '#addListTableTBar',
            rowStyler:function(index,row){
				if (row.CodeStatus == "0")
				{
					return 'background-color:#ddd;color:black;';
				}
                if (row.IsAdvancedSecurity == "Y")
                {
                    return 'background-color:pink;color:blue;font-weight:bold;';
                }
				
				if (row.CheckNoNeedApply == "1")
				{
					return 'background-color:lightgreen;color:black;font-weight:bold;';
				}
            }
		});
		
		//将就诊添加到待申请列表
		$('#addListBtn').on('click', function() {
			var rows = $('#patientListTable').datagrid('getSelections');
			for (var i=0;i<rows.length;i++)
			{
				//检查是否已存在
				var addTRows = $('#addListTable').datagrid('getRows');
				var flag = false;
				for (var j=0;j<addTRows.length;j++)
				{
					if (addTRows[j].EpisodeID == rows[i].EpisodeID)
					{
						flag = true;
						break;
					}
				}
				if (!flag){
					$('#addListTable').datagrid('appendRow', rows[i]);
				}
			}
		});
		
		//将就诊从待申请列表中删除
		$('#removeListBtn').on('click', function() {
			var rows = $('#addListTable').datagrid('getSelections');
			for (var i=0;i<rows.length;i++)
			{
				var index = $('#addListTable').datagrid('getRowIndex',rows[i]);
				$('#addListTable').datagrid('deleteRow', index);
			}
		});
		
		//将待申请列表清空
		$('#resetListBtn').on('click', function() {
			$('#addListTable').datagrid('loadData',{total:0,rows:[]});
		});
		
		//申请权限
		$('#addNewApplyBtn').on('click', function() {
			FSApplyPermission.requestEpisodeIDS = "";
			var episodeString = "";
			var rows = $('#addListTable').datagrid('getSelections');
			
			if (rows.length == 0)
			{
				$.messager.alert('错误', '请先选择一条就诊记录再点击申请权限！', 'error');
			}
			else
			{
				for (var i=0;i<rows.length;i++)
				{
					var row = rows[i];
					var episodeID = row["EpisodeID"];
					var codeStatus = row["CodeStatus"]
					
					if (codeStatus == "0")
					{
						break;
					}

					if (episodeString == "")
					{
						episodeString = episodeID;
					}
					else
					{
						episodeString = episodeString + "^" + episodeID;
					}
				}

				if (codeStatus == "0")
				{
					$.messager.alert('错误', '含有未编目病历，请取消选中未编目病历！', 'error');
				}
				else{
					//确认申请权限
					FSApplyPermission.requestEpisodeIDS = episodeString;
					$('#requestReasonDialog').dialog('open');
				}
			}
			
        });
	
	//申请时间和原因弹窗
	$('#requestReasonDialog').dialog({    
		title: '申请时间和原因',    
		closed: true,    
		cache: false,     
		modal: true,
		buttons:[{
			text:'申请',
			handler:function(){
				var reason = $('#inputRequestReason').val();
					
				if (reason == ""){
					$.messager.alert('提示', '请填写申请原因', 'info');
				}
				else {
					var ret = ""
					var obj = $.ajax({
						url: "../DHCEPRRBAC.web.eprajax.ApplyPermission.cls?Action=apply&EPRAction=" + FSApplyPermission.EPRACTION + "&EpisodeString=" + FSApplyPermission.requestEpisodeIDS + "&UserID=" + appointUserID + "&UserLocID=" + appointUserLoc + "&UserSSGroupID=" + appointUserSSGroupID + "&Reason=" + encodeURI(reason) + "&SpanTime=" + FSApplyPermission.spanTime,
						type: 'post',
						async: false
					});
					var ret = obj.responseText;
					if ((ret != "") && (ret != null) && (ret != "-1")) {
						$.messager.alert('完成', '申请成功！', 'info',function(){
							refreshGrid();
							$('#addListTable').datagrid('loadData',{total:0,rows:[]});
							$('#addApplyWin').window('close');
							$('#requestReasonDialog').dialog('close');
						});
					}
					else {
						$.messager.alert('错误', '申请失败，请再次尝试！', 'error');
					}
					FSApplyPermission.requestEpisodeIDS = "";
				}
			}
		},{
			text:'取消',
			handler:function(){
				$('#requestReasonDialog').dialog('close');
			}
		}]		
	});  

	//授权时间
        $('#inputRequestSpan').combogrid({
            idField: 'id',
            textField: 'text',
            data: [{
                id: '1',
                text: '12小时',
		        code: '12'
            }, {
                id: '2',
                text: '24小时',
                code: '24'
            }, {
                id: '3',
                text: '48小时',
                code: '48'
	        }, {
                id: '4',
                text: '72小时',
                code: '72'
	        }, {
                id: '5',
                text: '4天',
                code: '96'
	        }, {
                id: '6',
                text: '5天',
                code: '120'
	        }, {
                id: '7',
                text: '8天',
                code: '192'
	        }, {
                id: '8',
                text: '10天',
                code: '240'
	        }, {
                id: '9',
                text: '15天',
                code: '360'
	        }],
            panelWidth: 300,
            showHeader: false,
	        singleSelect: true,
            columns: [[
                { field: 'id', title: 'id', width: 80, hidden: true },
                { field: 'code', title: 'code', width: 80, hidden: true },
                { field: 'text', title: '授权时间', width: 250 }
            ]],
	        onSelect: function() {
                var rows = $('#inputRequestSpan').combogrid('grid').datagrid('getSelections');
                var row = rows[0];
                FSApplyPermission.spanTime = row["code"];	
            },
	        onLoadSuccess: function() {
                $('#inputRequestSpan').combogrid('grid').datagrid('selectRow', 0);
            }
        });
        
       	//给予默认角色
		$('#addDefaultRoleBtn').on('click', function() {
        //debugger;
            var isAdvancedSecurity = "N";
			var checkNoNeedApply = "1";
			var episodeString = "";
			var rows = $('#addListTable').datagrid('getSelections');
			
			if (rows.length == 0)
			{
				$.messager.alert('错误', '请先选择一条就诊记录再点击以默认浏览权限浏览就诊按钮！', 'error');
			}
			else
			{
				for (var i=0;i<rows.length;i++)
				{
					var row = rows[i];
					var episodeID = row["EpisodeID"];
                    var isAdvancedSecurity = row["IsAdvancedSecurity"];
					var checkNoNeedApply = row["CheckNoNeedApply"];
					var codeStatus = row["CodeStatus"]
					
					if (codeStatus == "0")
					{
						break;
					}
                    if (isAdvancedSecurity == "Y")
                    {
                        break;
                    }
					
					if (checkNoNeedApply == "0")
					{
						break;
					}

					if (episodeString == "")
					{
						episodeString = episodeID;
					}
					else
					{
						episodeString = episodeString + "^" + episodeID;
					}
				}

                if (codeStatus == "0")
                {
                    $.messager.alert('错误', '含有未编目病历，请取消选中未编目病历！', 'error');
                }
                else if (isAdvancedSecurity == "Y")
                {
                    $.messager.alert('错误', '含有敏感病历，请取消选中敏感病历，或者点击《需审批》的申请，在审批后查看！', 'error');
                }
				else if (checkNoNeedApply == "0")
				{
					$.messager.alert('错误', '含有非本科病历，请取消选中非本科病历，或者点击《需审批》的申请，在审批后查看！', 'error');
					
				}
                else
                {
				    //确认申请权限
				    var ret = ""
				    var obj = $.ajax({
					    url: "../DHCEPRRBAC.web.eprajax.ApplyPermission.cls?Action=defaultrole&EPRAction=" + FSApplyPermission.EPRACTION + "&EpisodeString=" + episodeString + "&UserID=" + appointUserID + "&UserLocID=" + appointUserLoc + "&UserSSGroupID=" + appointUserSSGroupID,
					    type: 'post',
					    async: false
				    });
				    var ret = obj.responseText;
				    if ((ret != "") && (ret != null) && (ret != "-1")) {
					    $.messager.alert('完成', '添加成功！', 'info',function(){
						    refreshGrid();
						    $('#addListTable').datagrid('loadData',{total:0,rows:[]});
						    $('#addApplyWin').window('close');
					    });
				    }
				    else {
					    $.messager.alert('错误', '添加失败，请再次尝试！', 'error');
				    }
                }
			}
			
        });
		
	//申请权限列表---------------------------------------------------------------------------------------------------------------------------
          var applyDefaultDG = $('#applyDefaultListTable').datagrid({
            //url: '',
            queryParams: {
                Action: 'applydefaultlist',
		        UserID: appointUserID,
		        ApplyStatus: 'D',
		        ApplyStartDate: '',
		        ApplyEndDate: ''
            },
            method: 'post',
            loadMsg: '数据装载中......',
            singleSelect: true,
            showHeader: true,
            //fitColumns: false,
	        rownumbers:true,
			columns:[[
			    { field: 'AuthorizationID', title:'AuthorizationID', width:80, sortable: false, hidden:true },
				{ field: 'AuthorizationDetailID', title:'AuthorizationDetailID', width:80, sortable: false, hidden:true },
				{ field: 'PAStatusType', title: '状态', width: 80, sortable: true },
				{ field: 'PAAdmType', title: '就诊类型', width: 80, sortable: true },
				{ field: 'PAPMIName', title: '病人姓名', width: 80, sortable: true },
				{ field: 'PAPMIDOB', title: '出生日期', width: 100, sortable: true },
				{ field: 'PAPMIAge', title: '年龄', width: 80, sortable: true },
				{ field: 'PAPMISex', title: '性别', width: 80, sortable: true },
				{ field: 'PAAdmDateTime', title: '入院时间', width: 150, sortable: true },
				{ field: 'PAAdmWard', title: '病区', width: 80, sortable: true },
				{ field: 'PAAdmRoom', title: '病房', width: 80, sortable: true },
				{ field: 'PAAdmBed', title: '病床', width: 80, sortable: true },
				{ field: 'PAAdmLoc', title: '科室', width: 80, sortable: true },
				{ field: 'PADischgeDateTime', title: '出院时间', width: 150, sortable: true },
				{ field: 'PAAdmDoc', title: '医生', width: 80, sortable: true },
				{ field: 'PayMode', title: '付费类型', width: 80, sortable: true },
				{ field: 'EpisodeID', title:'就诊号', width:80, sortable: false },
				{ field: 'PatientID', title:'病人号', width:80, sortable: false },
				{ field: 'MedRecordNo', title:'病案号', width:80, sortable: false },
				{ field: 'RegNo', title:'登记号', width:80, sortable: false },
				{ field: 'Link', title:'关联', width:100, sortable: false, formatter: linkURLFormatter },
                { field: 'IsAdvancedSecurity', title: 'IsAdvancedSecurity', width: 80, sortable: true, hidden:true }
	        ]],
            rowStyler:function(index,row){
                if (row.IsAdvancedSecurity == "1")
                {
                    return 'background-color:pink;color:blue;font-weight:bold;';
                }
            },
            onDblClickRow:viewRecord,
            pagination: true,
            pageSize: 20,
            pageList: [10, 20, 50],
            pagePosition: 'bottom'
        });		

        var applyDG = $('#applyListTable').datagrid({
            //url: '../DHCEPRRBAC.web.eprajax.ApplyPermission.cls'
            queryParams: {
                Action: 'applylist',
		        UserID: appointUserID,
		        ApplyStatus: 'N',
		        ApplyStartDate: '',
		        ApplyEndDate: ''
            },
            method: 'post',
            loadMsg: '数据装载中......',
            singleSelect: true,
            showHeader: true,
            //fitColumns: false,
	        rownumbers:true,
            columns: [[
		        { field: 'AuthorizationID', title: 'AuthorizationID', width: 80, sortable: true, hidden:true },
                { field: 'RequestUserID', title: 'RequestUserID', width: 80, sortable: true, hidden:true },
                { field: 'RequestUserName', title: '申请人', width: 80, sortable: true },
                { field: 'RequestDeptID', title: 'RequestDeptID', width: 80, sortable: true, hidden:true },			
                { field: 'RequestDept', title: '申请人科室', width: 80, sortable: true, hidden:true },
		        { field: 'RequestSSGroupID', title: '申请人安全组', width: 80, sortable: true, hidden:true },		
                { field: 'RequestDateTime', title: '申请日期时间', width: 150, sortable: true },
                { field: 'AppointUserID', title: 'AppointUserID', width: 80, sortable: true, hidden:true },
                { field: 'AppointUserName', title: '批准人', width: 80, sortable: true },
                { field: 'AppointDateTime', title: '批准日期时间', width: 150, sortable: true },
		        { field: 'AppointEndDateTime', title: '批准到期日期时间', width: 150, sortable: true },
                { field: 'RoleID', title: 'RoleID', width: 80, sortable: true, hidden:true  },
		        { field: 'RoleCode', title: '分配角色代码', width: 80, sortable: true },
                { field: 'RoleDesc', title: '分配角色', width: 80, sortable: true },
		        { field: 'OperationID', title: 'OperationID', width: 80, sortable: true, hidden:true },
		        { field: 'OperationCode', title: '操作类型代码', width: 80, sortable: true, hidden:true},
                { field: 'OperationDesc', title: '操作类型描述', width: 80, sortable: true },
                { field: 'EPRAction', title: '分配权限类型代码', width: 80, sortable: true, hidden:true },
		        { field: 'EPRActionDesc', title: '分配权限类型', width: 80, sortable: true },
                { field: 'AppointType', title: 'AppointType', width: 80, sortable: true, hidden:true },
                { field: 'AppointStatus', title: '授权状态代码', width: 80, sortable: true, hidden:true },
		        { field: 'AppointStatusDesc', title: '授权状态', width: 80, sortable: true, formatter: formatStatusDesc },
		        { field: 'AppointComment', title: '被拒绝或取消原因', width: 80, sortable: true },
		        { field: 'MedRecordNoS', title: '申请的病案', width: 150, sortable: true },
                { field: 'HasAdvancedSecurity', title: 'HasAdvancedSecurity', width: 80, sortable: true, hidden:true }
	        ]],
            rowStyler:function(index,row){
                if (row.HasAdvancedSecurity == "Y")
                {
                    return 'background-color:pink;color:blue;font-weight:bold;';
                }
            },
            pagination: true,
            pageSize: 20,
            pageList: [10, 20, 50],
            pagePosition: 'bottom',
            //toolbar: '#applyListTableTBar',
	        view: detailview,
	        detailFormatter:function(index,row){
                return '<div style="padding:2px"><table class="ddv" id="ddv-' + index + '"></table></div>';
            },
			onClickRow:function(rowIndex, rowData){
				//展开选中
				FSApplyPermission.ExpandIndex = rowIndex;
				$('#applyListTable').datagrid('expandRow',rowIndex);
			},
			onExpandRow: function(index,row){	
				//展开即选中
				$('#applyListTable').datagrid('selectRow', index);
				FSApplyPermission.ExpandIndex = index;
				
				FSApplyPermission.ExpandAppointID = row.AuthorizationID;

				$('#ddv-' + index).datagrid({
					url:'../DHCEPRRBAC.web.eprajax.ApplyPermission.cls',
					queryParams: {
						Action: 'applylistdetail',
						AuthorizationID: FSApplyPermission.ExpandAppointID
					},
					method: 'post',
					loadMsg: '数据装载中......',
					//fitColumns:true,
					singleSelect:true,
					rownumbers:true,
					height:'auto',
					columns:[[
						{ field: 'AuthorizationID', title:'AuthorizationID', width:80, sortable: false, hidden:true },
						{ field: 'AuthorizationDetailID', title:'AuthorizationDetailID', width:80, sortable: false, hidden:true },
						{ field: 'PAStatusType', title: '状态', width: 80, sortable: true },
						{ field: 'PAAdmType', title: '就诊类型', width: 80, sortable: true },
						{ field: 'PAPMIName', title: '病人姓名', width: 80, sortable: true },
						{ field: 'PAPMIDOB', title: '出生日期', width: 100, sortable: true },
						{ field: 'PAPMIAge', title: '年龄', width: 80, sortable: true },
						{ field: 'PAPMISex', title: '性别', width: 80, sortable: true },
						{ field: 'PAAdmDateTime', title: '入院时间', width: 150, sortable: true },
						{ field: 'PAAdmWard', title: '病区', width: 80, sortable: true },
						{ field: 'PAAdmRoom', title: '病房', width: 80, sortable: true },
						{ field: 'PAAdmBed', title: '病床', width: 80, sortable: true },
						{ field: 'PAAdmLoc', title: '科室', width: 80, sortable: true },
						{ field: 'PADischgeDateTime', title: '出院时间', width: 150, sortable: true },
						{ field: 'PAAdmDoc', title: '医生', width: 80, sortable: true },
						{ field: 'PayMode', title: '付费类型', width: 80, sortable: true },
						{ field: 'EpisodeID', title:'就诊号', width:80, sortable: false },
						{ field: 'PatientID', title:'病人号', width:80, sortable: false },
						{ field: 'MedRecordNo', title:'病案号', width:80, sortable: false },
						{ field: 'RegNo', title:'登记号', width:80, sortable: false },
						{ field: 'Link', title:'关联', width:100, sortable: false, formatter: linkURLFormatter },
                        { field: 'IsAdvancedSecurity', title: 'IsAdvancedSecurity', width: 80, sortable: true, hidden:true }
	                ]],
                    rowStyler:function(index,row){
                        if (row.IsAdvancedSecurity == "1")
                        {
                            return 'background-color:pink;color:blue;font-weight:bold;';
                        }
                    },
					onResize:function(){
						$('#applyListTable').datagrid('fixDetailRowHeight',index);
					},
					onLoadSuccess:function(){
						setTimeout(function(){
							$('#applyListTable').datagrid('fixDetailRowHeight',index);
						},0);
					},
					onClickRow:function(rowIndex, rowData){
						//获取父表此行的index
						var parentIdex = "";
						for (var i=0;i<$('#applyListTable').datagrid('getRows').length;i++){
							var row = $('#applyListTable').datagrid('getRows')[i];
							if (row.AuthorizationID == rowData.AuthorizationID){
								parentIdex = $('#applyListTable').datagrid('getRowIndex',row);
								break;
							}
						}

						FSApplyPermission.ExpandIndex = parentIdex;
						//$('#applyListTable').datagrid('selectRow',parentIdex);
						
						FSApplyPermission.SubGridSelect = rowIndex;
						//清空其他子表的选中
						for (var j=0;j<$('#applyListTable').datagrid('getRows').length;j++){
							if (j != parentIdex){
								try{
									if ($('#ddv-' + j).length > 0){ 
										var ddvrows = $('#ddv-' + j).datagrid('getSelections');
										if (ddvrows.length > 0){
											$('#ddv-' + j).datagrid('unselectAll');
										}
									}
								}
								catch(e){
									//可能ddv-i还未渲染，即还未展开则进入此处，也不需要清空
									continue;
								}
							}
						}
					},
					onDblClickRow:viewRecord
				});
				$('#applyListTable').datagrid('fixDetailRowHeight',index);
			}
        });		
		
		//列表类型
        $('#inputType').combogrid({
            idField: 'id',
            textField: 'text',
            data: [{
                id: '0',
                text: '以默认角色浏览',
				code: 'D'
            }, {
                id: '1',
                text: '未批准',
				code: 'N'
            }, {
                id: '2',
                text: '已批准',
                code: 'F'
            }, {
                id: '3',
                text: '已拒绝',
                code: 'R'
			}, {
                id: '4',
                text: '已过期',
                code: 'I'
			}],
            panelWidth: 300,
            showHeader: false,
			singleSelect: true,
            columns: [[
                { field: 'id', title: 'id', width: 80, hidden: true },
                { field: 'code', title: 'code', width: 80, hidden: true },
                { field: 'text', title: '列表类型', width: 250 }
            ]],
			onSelect: function() {
                var row = $('#inputType').combogrid('grid').datagrid('getSelected');
                FSApplyPermission.typeCode = row["code"];

				//按钮显示隐藏
				if (row.code == "F"){
					$('#viewBtn').show();
					$('#reAppointBtn').hide();
				}
				else if ((row.code == "R") || (row.code == "I")){
					$('#viewBtn').hide();
					$('#reAppointBtn').show();
				}
				else if (row.code == "D"){
					$('#viewBtn').show();
					$('#reAppointBtn').hide();
				}
				else {
					$('#viewBtn').hide();
					$('#reAppointBtn').hide();
				}
				
				//隐藏列，显示列
				if (FSApplyPermission.typeCode == "N"){
					//未授权，隐藏授权人等信息
					$('#applyListTable').datagrid('hideColumn','AppointUserName');
					$('#applyListTable').datagrid('hideColumn','AppointDateTime');
					$('#applyListTable').datagrid('hideColumn','AppointEndDateTime');
					$('#applyListTable').datagrid('hideColumn','RoleCode');
					$('#applyListTable').datagrid('hideColumn','RoleDesc');
					$('#applyListTable').datagrid('hideColumn','OperationDesc');
					$('#applyListTable').datagrid('hideColumn','AppointComment');
				}
				else if(FSApplyPermission.typeCode == "F"){
					$('#applyListTable').datagrid('showColumn','AppointUserName');
					$('#applyListTable').datagrid('showColumn','AppointDateTime');
					$('#applyListTable').datagrid('showColumn','AppointEndDateTime');
					$('#applyListTable').datagrid('showColumn','RoleCode');
					$('#applyListTable').datagrid('showColumn','RoleDesc');
					$('#applyListTable').datagrid('showColumn','OperationDesc');	
					$('#applyListTable').datagrid('hideColumn','AppointComment');			
				}
				else if(FSApplyPermission.typeCode == "D"){
					$('#applyListTable').datagrid('hideColumn','AppointUserName');
					$('#applyListTable').datagrid('hideColumn','AppointDateTime');
					$('#applyListTable').datagrid('hideColumn','AppointEndDateTime');
					$('#applyListTable').datagrid('showColumn','RoleCode');
					$('#applyListTable').datagrid('showColumn','RoleDesc');
					$('#applyListTable').datagrid('showColumn','OperationDesc');	
					$('#applyListTable').datagrid('hideColumn','AppointComment');			
				}
				else {
					$('#applyListTable').datagrid('showColumn','AppointUserName');
					$('#applyListTable').datagrid('showColumn','AppointDateTime');
					$('#applyListTable').datagrid('showColumn','AppointEndDateTime');
					$('#applyListTable').datagrid('showColumn','RoleCode');
					$('#applyListTable').datagrid('showColumn','RoleDesc');
					$('#applyListTable').datagrid('showColumn','OperationDesc');	
					$('#applyListTable').datagrid('showColumn','AppointComment');					
				}
				
				refreshGrid();	
            },
			onLoadSuccess: function() {
                $('#inputType').combogrid('grid').datagrid('selectRow', 0);
            }
        });

	//时间过滤 - 起始日期
	$('#inputDateStart').datebox({
	    onSelect: function() {
		    FSApplyPermission.dateStart = $('#inputDateStart').datebox('getValue');
        },
		onChange: function() {
			//避免不选择日期而采用输入的方式
			FSApplyPermission.dateStart = $('#inputDateStart').datebox('getValue');
		}
	}); 

	//时间过滤 - 截止日期
	$('#inputDateEnd').datebox({   
	    onSelect: function() {
		    FSApplyPermission.dateEnd = $('#inputDateEnd').datebox('getValue');
        },
		onChange: function() {
			//避免不选择日期而采用输入的方式
			FSApplyPermission.dateEnd = $('#inputDateEnd').datebox('getValue');
		}		
	});
		
	var currDate = new Date(); 
 　 $("#inputDateStart").datebox("setValue",myformatter1(currDate,FSApplyPermission.DATESPAN));  
 　 $("#inputDateEnd").datebox("setValue",myformatter(currDate));  
	FSApplyPermission.dateStart = $("#inputDateStart").datebox("getValue");
	FSApplyPermission.dateEnd = $("#inputDateEnd").datebox("getValue");

	//刷新申请列表
	function refreshGrid(){
		//第一次加载时日期框没有值
		if (FSApplyPermission.dateStart == "")
		{
			var currDate = new Date(); 
			FSApplyPermission.dateStart = myformatter1(currDate,FSApplyPermission.DATESPAN);
			FSApplyPermission.dateEnd = myformatter(currDate);
		}
		
        if (FSApplyPermission.typeCode == "D") {
            $('#applyListPanel').panel('close');
            $('#applyDefaultListPanel').panel('open');
            $('#applyDefaultListPanel').panel('maximize');

   	        var url = '../DHCEPRRBAC.web.eprajax.ApplyPermission.cls';
	        $('#applyDefaultListTable').datagrid('options').url = url;
	        var queryParams = $('#applyDefaultListTable').datagrid('options').queryParams;
            queryParams.Action = 'applydefaultlist';
            queryParams.UserID = appointUserID;
	        queryParams.ApplyStatus = FSApplyPermission.typeCode;
	        queryParams.ApplyStartDate = FSApplyPermission.dateStart;
	        queryParams.ApplyEndDate = FSApplyPermission.dateEnd;
	
            $('#applyDefaultListTable').datagrid('options').queryParams = queryParams;
            $('#applyDefaultListTable').datagrid('reload');     
        }
        else {
            $('#applyDefaultListPanel').panel('close');
            $('#applyListPanel').panel('open');
            $('#applyListPanel').panel('maximize');

	        var url = '../DHCEPRRBAC.web.eprajax.ApplyPermission.cls';
	        $('#applyListTable').datagrid('options').url = url;
	        var queryParams = $('#applyListTable').datagrid('options').queryParams;
            queryParams.Action = 'applylist';
            queryParams.UserID = appointUserID;
	        queryParams.ApplyStatus = FSApplyPermission.typeCode;
	        queryParams.ApplyStartDate = FSApplyPermission.dateStart;
	        queryParams.ApplyEndDate = FSApplyPermission.dateEnd;
	
            $('#applyListTable').datagrid('options').queryParams = queryParams;
            $('#applyListTable').datagrid('reload');	
        }		
	} 	

	//查询
    $('#searchBtn').on('click', function() {
        refreshGrid();
    });

    //清空查询条件
    $('#resetBtn').on('click', function() {
        $('#inputType').combogrid('grid').datagrid('selectRow', 0);
	    var currDate = new Date(); 
	    $("#inputDateStart").datebox("setValue",myformatter1(currDate,FSApplyPermission.DATESPAN));  
	    $("#inputDateEnd").datebox("setValue",myformatter(currDate));  
	    FSApplyPermission.dateStart = $("#inputDateStart").datebox("getValue");
		FSApplyPermission.dateEnd = $("#inputDateEnd").datebox("getValue");
    });		
		
    //浏览按钮
    $('#viewBtn').on('click', function() {
        if (FSApplyPermission.typeCode == "D") {
            var rows = $('#applyDefaultListTable').datagrid('getSelections');
            if (rows.length != 1){
                $.messager.alert('错误', '请先选中一条就诊', 'error');
            }
            else {
                var row = rows[0];
	            viewRecord(0,row);
            }
        }
        else {
            if (FSApplyPermission.ExpandIndex == "-1"){
                $.messager.alert('错误', '请先展开一条授权', 'error');
            }
            else{
                if (FSApplyPermission.SubGridSelect == "-1"){
                    $.messager.alert('错误', '请先选中一条就诊', 'error');
                }
                else {
                    var row = $('#ddv-' + FSApplyPermission.ExpandIndex).datagrid('getRows')[FSApplyPermission.SubGridSelect];
			        viewRecord(FSApplyPermission.SubGridSelect,row);
		        }
	        }
        }
    });	
	
	function linkURLFormatter(value, row, index)
	{
		var episodeID = row.EpisodeID;
		var obj = $.ajax({
			url: "../DHCEPRRBAC.web.eprajax.Personalization.cls?Action=linkparam&EpisodeID=" + episodeID,
			type: 'post',
			async: false
		});
		var linkedEpisodeIDS = obj.responseText;
		if (linkedEpisodeIDS == "")
		{
			return "";
		}
		var arr = new Array();
		arr = linkedEpisodeIDS.split('^');
		var rowIndex = 0;
		if (FSApplyPermission.typeCode != "D") {
			rowIndex = FSApplyPermission.SubGridSelect;
		}
		var AuthorizationID = row.AuthorizationDetailID;
		var AuthorizationGroupID = row.AuthorizationID;
		
		var urls = "";
		for (var i=0;i<arr.length;i++) 
		{
			var linkedEpisode = arr[i];
			if (FSApplyPermission.typeCode == "F")
			{
				var obj = $.ajax({
					url: "../DHCEPRRBAC.web.eprajax.View.cls?Action=getviewparam&EpisodeID=" + linkedEpisode + "&AuthorizationID=" + FSApplyPermission.ExpandAppointID , 
					type: 'post',
					async: false
				});
				
				var ret = obj.responseText;

		    	var strs = new Array();
		      	strs = ret.split("|");
		    	var eprAction = strs[1];
	     		var operationCode = strs[2];
	    		var items = strs[3];
	    	    if (eprAction == "FS"){
				    if (operationCode == "VIEW"){
						var obj = $.ajax({
							type: 'POST',
							url: "../DHCEPRRBAC.web.eprajax.FS.cls", 
							data: {"Action":"getveritem","EpisodeID":linkedEpisode,"Items": items},
							async: false
						});
						
					    var retFS = obj.responseText;
					    if ((retFS != "") && (retFS != null) && (retFS != "-1"))  {
					        var strsFS = new Array();
						    strsFS = retFS.split("!");
						    var mrEpisodeID = strsFS[0];
						    var verItems = strsFS[1];
							
							if ((verItems == "") || (verItems == null))
							{
								return "";
								//$.messager.alert('错误', '此次就诊在此权限下没有任何可浏览项目', 'error');
							}
							
						    var url = "dhc.epr.fs.viewrecord.csp?MREpisodeID="+mrEpisodeID+"&MRVerItemsIDs="+verItems+"&DataServiceUrl="+FSApplyPermission.DATASERVICEURL;
						    urls = urls + '<a style="color:blue" target="_blank" href="'+url+'">关联'+(i+1)+'</a>';
							//写入浏览记录
							var obj = $.ajax({
								url: "../DHCEPRRBAC.web.eprajax.Log.cls?Action=addlog&EpisodeID=" + linkedEpisode + "&UserID=" + appointUserID + "&LogType=VIEW" + "&AuthorizationID=" + AuthorizationID + "&AuthorizationGroupID=" + AuthorizationGroupID, 
								type: 'post',
								async: false
							});	
						}
						else{
							return "";
							//$.messager.alert('错误', '此次就诊还没进入归档库', 'error');
						}
					}
				}
			}
			else if (FSApplyPermission.typeCode == "D"){
				var obj = $.ajax({
					url: "../DHCEPRRBAC.web.eprajax.View.cls?Action=getdefaultviewparam&EpisodeID=" + linkedEpisode + "&SSGroupID=" + appointUserSSGroupID, 
					type: 'post',
					async: false
				});
				var ret = obj.responseText;
				if (ret == "-4") {
					return "";
					//$.messager.alert('错误', '欲浏览的病历被加入敏感病历列表中，结束浏览，继续浏览需要申请并审批', 'error');
				}
				else
				{
					var strs = new Array();
					strs = ret.split("|");
					var operationCode = strs[1];
					var items = strs[2];
					if (operationCode == "VIEW"){
						var obj = $.ajax({
							type: 'POST',
							url: "../DHCEPRRBAC.web.eprajax.FS.cls", 
							data: {"Action":"getveritem","EpisodeID":linkedEpisode,"Items": items},
							async: false
						}); 
					
						var retFS = obj.responseText;
						if ((retFS != "") && (retFS != null) && (retFS != "-1"))  {
							var strsFS = new Array();
							strsFS = retFS.split("!");
							var mrEpisodeID = strsFS[0];
							var verItems = strsFS[1];
							var url = "dhc.epr.fs.viewrecord.csp?MREpisodeID="+mrEpisodeID+"&MRVerItemsIDs="+verItems+"&DataServiceUrl="+FSApplyPermission.DATASERVICEURL;
							urls = urls + '<a style="color:blue" target="_blank" href="'+url+'">关联'+(i+1)+'</a>';
							//写入浏览记录
							var obj = $.ajax({
								url: "../DHCEPRRBAC.web.eprajax.Log.cls?Action=addlog&EpisodeID=" + linkedEpisode + "&UserID=" + appointUserID + "&LogType=VIEW" + "&AuthorizationID=default" + "&AuthorizationGroupID=default", 
								type: 'post',
								async: false
							});	
						}
						else{
							return "";
							//$.messager.alert('错误', '此次就诊还没进入归档库', 'error');
						}
					}
				}
			}
		}
		return urls;
	}
		
    function viewRecord(rowIndex, rowData){
        var episodeID = rowData.EpisodeID;
	    if (FSApplyPermission.typeCode == "F")
		{
		    var AuthorizationID = rowData.AuthorizationDetailID;
		    var AuthorizationGroupID = rowData.AuthorizationID;
		    var obj = $.ajax({
			    url: "../DHCEPRRBAC.web.eprajax.View.cls?Action=getviewparam&EpisodeID=" + episodeID + "&AuthorizationID=" + FSApplyPermission.ExpandAppointID , 
			    type: 'post',
			    async: false
		    });
			
		    var ret = obj.responseText;

		    if (ret == "-3") {
		    	$.messager.alert('错误', '获取浏览参数失败', 'error');
		    }
		    else if (ret == "-2") {
		    	$.messager.alert('错误', '所选的项目未被审批或者已被拒绝', 'error');
		    }
		    else if (ret == "-1") {
		    	$.messager.alert('错误', '所选的项目已过期，请刷新列表，并重新申请', 'error');
		    }
		    else if ((ret != "") && (ret != null)) {	
		    	var strs = new Array();
		      	strs = ret.split("|");
		    	var eprAction = strs[1];
	     		var operationCode = strs[2];
	    		var items = strs[3];
	    	    if (eprAction == "FS"){
				    if (operationCode == "VIEW"){
						var obj = $.ajax({
							type: 'POST',
							url: "../DHCEPRRBAC.web.eprajax.FS.cls", 
							data: {"Action":"getveritem","EpisodeID":episodeID,"Items": items},
							async: false
						});
						
					    var retFS = obj.responseText;
					    if ((retFS != "") && (retFS != null) && (retFS != "-1"))  {
					        var strsFS = new Array();
						    strsFS = retFS.split("!");
						    var mrEpisodeID = strsFS[0];
						    var verItems = strsFS[1];
							
							if ((verItems == "") || (verItems == null))
							{
								$.messager.alert('错误', '此次就诊在此权限下没有任何可浏览项目', 'error');
							}
							
						    var url = "dhc.epr.fs.viewrecord.csp?MREpisodeID="+mrEpisodeID+"&MRVerItemsIDs="+verItems+"&DataServiceUrl="+FSApplyPermission.DATASERVICEURL;
						    FSApplyPermission.WINCOUNT = FSApplyPermission.WINCOUNT + 1;
							window.open (url,FSApplyPermission.WINCOUNT,'height=800,width=1280,top=0,left=0,toolbar=no,menubar=no,scrollbars=no, resizable=yes,location=no, status=no');
							//写入浏览记录
							var obj = $.ajax({
								url: "../DHCEPRRBAC.web.eprajax.Log.cls?Action=addlog&EpisodeID=" + episodeID + "&UserID=" + appointUserID + "&LogType=VIEW" + "&AuthorizationID=" + AuthorizationID + "&AuthorizationGroupID=" + AuthorizationGroupID, 
								type: 'post',
								async: false
							});	
						}
						else{
							$.messager.alert('错误', '此次就诊还没进入归档库', 'error');
						}
					}
				}
			}
		}
		else if (FSApplyPermission.typeCode == "D"){
			var obj = $.ajax({
				url: "../DHCEPRRBAC.web.eprajax.View.cls?Action=getdefaultviewparam&EpisodeID=" + episodeID + "&SSGroupID=" + appointUserSSGroupID, 
				type: 'post',
				async: false
			});
			var ret = obj.responseText;
            if (ret == "-4") {
				$.messager.alert('错误', '欲浏览的病历被加入敏感病历列表中，结束浏览，继续浏览需要申请并审批', 'error');
			}
            else
            {
	            debugger;
				var strs = new Array();
				strs = ret.split("|");
				var operationCode = strs[1];
				var items = strs[2];
				if (operationCode == "VIEW"){
					var obj = $.ajax({
						type: 'POST',
						url: "../DHCEPRRBAC.web.eprajax.FS.cls", 
						data: {"Action":"getveritem","EpisodeID":episodeID,"Items": items},
						async: false
					}); 
					
					var retFS = obj.responseText;
					if ((retFS != "") && (retFS != null) && (retFS != "-1"))  {
						var strsFS = new Array();
						strsFS = retFS.split("!");
					    var mrEpisodeID = strsFS[0];
					    var verItems = strsFS[1];
					    var url = "dhc.epr.fs.viewrecord.csp?MREpisodeID="+mrEpisodeID+"&MRVerItemsIDs="+verItems+"&DataServiceUrl="+FSApplyPermission.DATASERVICEURL;
					    FSApplyPermission.WINCOUNT = FSApplyPermission.WINCOUNT + 1;
					    window.open (url,FSApplyPermission.WINCOUNT,'height=800,width=1280,top=0,left=0,toolbar=no,menubar=no,scrollbars=no, resizable=yes,location=no, status=no');
					    //写入浏览记录
					    var obj = $.ajax({
						    url: "../DHCEPRRBAC.web.eprajax.Log.cls?Action=addlog&EpisodeID=" + episodeID + "&UserID=" + appointUserID + "&LogType=VIEW" + "&AuthorizationID=default" + "&AuthorizationGroupID=default", 
						    type: 'post',
					        async: false
				        });	
			        }
			        else{
				        $.messager.alert('错误', '此次就诊还没进入归档库', 'error');
			        }
                }
		    }
	    }
	    else{
	        return;
	    }
    }
		
		//浏览历史记录-------------------------------------------------------------------------------
		//浏览记录按钮
		function refleshHistoryDG(){
			var url = '../DHCEPRRBAC.web.eprajax.Log.cls';
 			$('#historyListTable').datagrid('options').url = url;
 			var queryParams = $('#historyListTable').datagrid('options').queryParams;
            queryParams.Action = 'historylist';
            queryParams.UserID = appointUserID;
			queryParams.LogType = 'VIEW';
			queryParams.StartDate = FSApplyPermission.HDateStart;
			queryParams.EndDate = FSApplyPermission.HDateEnd;

            $('#historyListTable').datagrid('options').queryParams = queryParams;
            $('#historyListTable').datagrid('reload');		
		}
		
        $('#viewHistoryBtn').on('click', function() {
        	//浏览记录列表
	        var historyDG = $('#historyListTable').datagrid({
	            //url: '',
	            queryParams: {
					Action: 'historylist',
	                UserID: appointUserID,
	                LogType: 'VIEW',
	                StartDate: FSApplyPermission.HDateStart,
	                EndDate: FSApplyPermission.HDateEnd
	            },
	            method: 'post',
	            loadMsg: '数据装载中......',
	            singleSelect: true,
	            showHeader: true,
	            //fitColumns: true,
				rownumbers:true,
	            columns: [[
                    { field: 'UserID', title: 'UserID', width: 80, sortable: true, hidden: true },
                    { field: 'UserName', title: '操作者', width: 80, sortable: true, hidden: true },
		        	{ field: 'AppointStatus', title: '授权情况', width: 80, sortable: true, hidden: true },
			        { field: 'AppointStatusDesc', title: '授权情况', width: 80, sortable: true, formatter: formatStatusDesc },
			        { field: 'AuthorizationID', title: '状态', width: 80, sortable: true, hidden: true },
			        { field: 'AuthorizationGroupID', title: '状态', width: 80, sortable: true, hidden: true },
			        { field: 'OperationDateTime', title: '操作日期时间', width: 150, sortable: true },
	                { field: 'PAStatusType', title: '状态', width: 80, sortable: true },
	                { field: 'PAAdmType', title: '就诊类型', width: 80, sortable: true },
	                { field: 'PAPMIName', title: '病人姓名', width: 80, sortable: true },
	                { field: 'RegNo', title: '登记号', width: 80, sortable: true },
	                { field: 'PAPMIDOB', title: '出生日期', width: 100, sortable: true },
	                { field: 'PAPMIAge', title: '年龄', width: 80, sortable: true },
	                { field: 'PAPMISex', title: '性别', width: 80, sortable: true },
	                { field: 'PAAdmDateTime', title: '入院时间', width: 150, sortable: true },
	                { field: 'PAAdmWard', title: '病区', width: 80, sortable: true },
	                { field: 'PAAdmRoom', title: '病房', width: 80, sortable: true },
	                { field: 'PAAdmBed', title: '病床', width: 80, sortable: true },
	                { field: 'PAAdmLoc', title: '科室', width: 80, sortable: true },
	                { field: 'PADischgeDateTime', title: '出院时间', width: 150, sortable: true },
	                { field: 'PAAdmDoc', title: '医生', width: 80, sortable: true },
	                { field: 'PayMode', title: '付费类型', width: 80, sortable: true },
	                { field: 'EpisodeID', title: '就诊号', width: 80, sortable: true },
	                { field: 'PatientID', title: '病人号', width: 80, sortable: true }
	            ]],
	            pagination: true,
	            pageSize: 20,
	            pageList: [10, 20, 50],
	            pagePosition: 'bottom',
	            toolbar: '#historyListTableTBar',
	            title: '浏览记录列表',
				onDblClickRow:function(rowIndex, rowData){	
					var episodeID = rowData.EpisodeID;
					var AuthorizationID = rowData.AuthorizationID;
					var AuthorizationGroupID = rowData.AuthorizationGroupID;
					if (AuthorizationGroupID == "default"){
						var obj = $.ajax({
							url: "../DHCEPRRBAC.web.eprajax.View.cls?Action=getdefaultviewparam&EpisodeID=" + episodeID + "&SSGroupID=" + appointUserSSGroupID, 
							type: 'post',
							async: false
						});
						var ret = obj.responseText;
						var strs = new Array();
						strs = ret.split("|");
						var operationCode = strs[1];
						var items = strs[2];
						if (operationCode == "VIEW"){
							var obj = $.ajax({
								type: 'POST',
								url: "../DHCEPRRBAC.web.eprajax.FS.cls", 
								data: {"Action":"getveritem","EpisodeID":episodeID,"Items": items},
								async: false
							});
							
							var retFS = obj.responseText;
							if ((retFS != "") && (retFS != null) && (retFS != "-1"))  {
								var strsFS = new Array();
								strsFS = retFS.split("!");
								var mrEpisodeID = strsFS[0];
								var verItems = strsFS[1];
								var url = "dhc.epr.fs.viewrecord.csp?MREpisodeID="+mrEpisodeID+"&MRVerItemsIDs="+verItems+"&DataServiceUrl="+FSApplyPermission.DATASERVICEURL;
								FSApplyPermission.WINCOUNT = FSApplyPermission.WINCOUNT + 1;
								window.open (url,FSApplyPermission.WINCOUNT,'height=800,width=1280,top=0,left=0,toolbar=no,menubar=no,scrollbars=no, resizable=yes,location=no, status=no');
								//写入浏览记录
								var obj = $.ajax({
									url: "../DHCEPRRBAC.web.eprajax.Log.cls?Action=addlog&EpisodeID=" + episodeID + "&UserID=" + appointUserID + "&LogType=VIEW" + "&AuthorizationID=default" + "&AuthorizationGroupID=default", 
									type: 'post',
									async: false
								});	
							}
							else{
								$.messager.alert('错误', '此次就诊还没进入归档库', 'error');
							}
						}
						
					}
					else{
						var obj = $.ajax({
							url: "../DHCEPRRBAC.web.eprajax.View.cls?Action=getviewparam&EpisodeID=" + episodeID + "&AuthorizationID=" + AuthorizationGroupID, 
							type: 'post',
							async: false
						});
						var ret = obj.responseText;
						if (ret == "-3") {
							$.messager.alert('错误', '获取浏览参数失败', 'error');
						}
						else if (ret == "-2") {
							$.messager.alert('错误', '所选的项目未被审批或者已被拒绝', 'error');
						}
						else if (ret == "-1") {
							$.messager.alert('错误', '所选的项目已过期，请重新申请', 'error');
						}
						else if ((ret != "") && (ret != null)) {	
							var strs = new Array();
							strs = ret.split("|");
							var eprAction = strs[1];
							var operationCode = strs[2];
							var items = strs[3];
							if (eprAction == "FS"){
								if (operationCode == "VIEW"){
									var obj = $.ajax({
										type: 'POST',
										url: "../DHCEPRRBAC.web.eprajax.FS.cls", 
										data: {"Action":"getveritem","EpisodeID":episodeID,"Items": items},
										async: false
									});
								
									var retFS = obj.responseText;
									if ((retFS != "") && (retFS != null) && (retFS != "-1"))  {
										var strsFS = new Array();
										strsFS = retFS.split("!");
										var mrEpisodeID = strsFS[0];
										var verItems = strsFS[1];
										var url = "dhc.epr.fs.viewrecord.csp?MREpisodeID="+mrEpisodeID+"&MRVerItemsIDs="+verItems+"&DataServiceUrl="+FSApplyPermission.DATASERVICEURL;
										FSApplyPermission.WINCOUNT = FSApplyPermission.WINCOUNT + 1;
										window.open (url,FSApplyPermission.WINCOUNT,'height=800,width=1280,top=0,left=0,toolbar=no,menubar=no,scrollbars=no, resizable=yes,location=no, status=no');
										//写入浏览记录
										var obj = $.ajax({
											url: "../DHCEPRRBAC.web.eprajax.Log.cls?Action=addlog&EpisodeID=" + episodeID + "&UserID=" + appointUserID + "&LogType=VIEW" + "&AuthorizationID=" + AuthorizationID + "&AuthorizationGroupID=" + AuthorizationGroupID, 
											type: 'post',
											async: false
										});	
									}
									else{
										$.messager.alert('错误', '此次就诊还没进入归档库', 'error');
									}
								}
							}
						}
					}
				}
	        });
			
			//浏览记录列表时间过滤 - 起始日期
			$('#historyDateStart').datebox({    
				onSelect: function() {
					FSApplyPermission.HDateStart = $('#historyDateStart').datebox('getValue');
	            }			
			}); 
	
			//浏览记录列表时间过滤 - 截止日期
			$('#historyDateEnd').datebox({    
				onSelect: function() {
					FSApplyPermission.HDateEnd = $('#historyDateEnd').datebox('getValue');
	            }			
			});
        	
			var currDate = new Date();     
 　 			$("#historyDateStart").datebox("setValue",myformatter(currDate));  
 　 			$("#historyDateEnd").datebox("setValue",myformatter(currDate));  
			FSApplyPermission.HDateStart = $('#historyDateStart').datebox('getValue');
			FSApplyPermission.HDateEnd = $('#historyDateEnd').datebox('getValue');
 
	        $('#refreshBtn').on('click', function() {
				refleshHistoryDG();	
	        });	
 			
 			refleshHistoryDG();	
			$('#viewHistoryWin').window('open');	
        });	 
		
		//浏览记录弹窗
		var winHistory = $('#viewHistoryWin').window({
			modal:true,
			inline:true,
			closed:true,
			iconCls:'icon-search',
			title: '浏览记录'
		});
		
		//收藏-------------------------------------------------------------------------------------
		$('#addFavoriteBtn').on('click', function() { 
            if (FSApplyPermission.typeCode == "D") {
                var rows = $('#applyDefaultListTable').datagrid('getSelections');
			    if (rows.length != 1){
			        $.messager.alert('错误', '请先选中一条就诊', 'error');
				}
                else {
    		        var row = rows[0];
				    FSApplyPermission.selectEpisodeID = row.EpisodeID;
				    refleshCategory("categoryListSelectTable");
				    FSApplyPermission.addFavoriteType= "add";
				    $('#addFavoriteDialog').dialog('open');            
                }
            }
            else {
			    if (FSApplyPermission.ExpandIndex == "-1"){
				    $.messager.alert('错误', '请先展开一条授权', 'error');
			    }
			    else{
				    if (FSApplyPermission.SubGridSelect == "-1"){
					    $.messager.alert('错误', '请先选中一条就诊', 'error');
				    }
				    else {
					    var row = $('#ddv-' + FSApplyPermission.ExpandIndex).datagrid('getRows')[FSApplyPermission.SubGridSelect];
					    FSApplyPermission.selectEpisodeID = row.EpisodeID;
					    refleshCategory("categoryListSelectTable");
					    FSApplyPermission.addFavoriteType= "add";
					    $('#addFavoriteDialog').dialog('open');
				    }
                }
			}		
        });	
		
		var winFavorites = $('#viewFavoritesWin').window({
			modal:true,
			inline:true,
			closed:true,
			iconCls:'icon-search',
			title: '收藏'
		});
		
		$('#viewFavoritesBtn').on('click', function() { 
			refleshCategory("categoryListTable");
			if ($('#categoryListTable').datagrid('getRows').length > 0){
				$('#categoryListTable').datagrid('selectRow',0);
			}
			$('#viewFavoritesWin').window('open');	
        });	
		
		$('#categoryAddBtn').on('click', function() { 
			refleshCategory("categoryListTable");	
			refleshCategory("categoryListSelectTable");	
			FSApplyPermission.DialogType = "add";
			$('#addCategoryDialog').dialog('open');
        });	
		
		$('#categorySelectAddBtn').on('click', function() { 
			refleshCategory("categoryListTable");	
				
			FSApplyPermission.DialogType = "add";
			$('#addCategoryDialog').dialog('open');
        });	
		
		$('#categoryDeleteBtn').on('click', function() { 
			deleteCategory("categoryListTable");
        });	
			
		$('#categorySelectDeleteBtn').on('click', function() { 
			deleteCategory("categoryListSelectTable");
        });	
		
		function deleteCategory(id){
			var rows = $('#' + id).datagrid('getSelections');
			if (rows.length <= 0){
				$.messager.alert('错误', '请先选择一个分类！', 'error');
			}
			else {
				$.messager.confirm('确认删除', '确定要删除分类，删除分类会将其下的所有项目一并删除，请确认要删除分类？', function(r) {
					if (r) {
						var categoryID = rows[0].FavoritesCategoryID;
						var obj = $.ajax({
							url: "../DHCEPRRBAC.web.eprajax.FavoritesCategory.cls?Action=delete"+ "&FavoritesCategoryID=" + categoryID, 
							type: 'post',
							async: false
						});

						var ret = obj.responseText;
						if (ret == "-1") {
							$.messager.alert('错误', text + '删除分类失败，请重新尝试！', 'error');
						}
						else if ((ret != "") && (ret != null) && (parseInt(ret) > 0)) {
							$.messager.alert('提示', '删除分类成功！', 'info');
							refleshCategory("categoryListTable");	
							refleshCategory("categoryListSelectTable");	
							$('#categoryListTable').datagrid('selectRow',0);
						}
					}
				});
			}
		}
		
		function refleshCategory(id){
			var url = '../DHCEPRRBAC.web.eprajax.FavoritesCategory.cls';
			$('#' + id).datagrid('options').url = url;
			var queryParams = $('#' + id).datagrid('options').queryParams;
			queryParams.Action = 'getlist';
			queryParams.UserID = appointUserID;

			$('#' + id).datagrid('options').queryParams = queryParams;
			$('#' + id).datagrid('reload');			
		}
		
		$('#addCategoryDialog').dialog({    
			title: '添加修改分类',    
			closed: true,    
			cache: false,     
			modal: true,
			buttons:[{
				text:'保存',
				handler:function(){
					var categoryDesc = $('#inputCategoryDesc').val();
					if (categoryDesc == ""){
						$.messager.alert('提示', text + '请填写分类名', 'info');
					}
					else {
						var obj = $.ajax({
							url: "../DHCEPRRBAC.web.eprajax.FavoritesCategory.cls?Action=" + FSApplyPermission.DialogType + "&Desc=" + encodeURI(categoryDesc) + "&UserID=" + appointUserID, 
							type: 'post',
							async: false
						});

						var ret = obj.responseText;
						if (ret == "-1") {
							$.messager.alert('错误', '添加修改分类失败，请重新尝试！', 'error');
						}
						else if ((ret != "") && (ret != null) && (parseInt(ret) > 0)) {
							$('#addCategoryDialog').dialog('close');
							$.messager.alert('提示', '添加修改分类成功！', 'info');
							refleshCategory("categoryListTable");	
							refleshCategory("categoryListSelectTable");								
						}
					}
				}
			},{
				text:'关闭',
				handler:function(){
					$('#addCategoryDialog').dialog('close');
				}
			}]		
		});    	
		
		$('#addFavoriteDialog').dialog({    
			title: '收藏',    
			closed: true,    
			cache: false,     
			modal: true,
			buttons:[{
				text:'保存',
				handler:function(){
					var rows = $('#categoryListSelectTable').datagrid('getSelections'); 
					if (rows.length <= 0){
						$.messager.alert('错误', '请先选择一个分类！', 'error');
					}
					else {
						var categoryID = rows[0].FavoritesCategoryID;
						var url = "";
						if (FSApplyPermission.addFavoriteType == "add"){
							url = "../DHCEPRRBAC.web.eprajax.Favorites.cls?Action=" + FSApplyPermission.addFavoriteType + "&FavoritesCategoryID=" + categoryID + "&EpisodeID=" + FSApplyPermission.selectEpisodeID + "&UserID=" + appointUserID;
						}
						else {
							url = "../DHCEPRRBAC.web.eprajax.Favorites.cls?Action=" + FSApplyPermission.addFavoriteType + "&FavoritesCategoryID=" + categoryID + "&FavoritesIDS=" + FSApplyPermission.favoritesIDS + "&EpisodeIDS=" + FSApplyPermission.favoritesEpisodeIDS + "&UserID=" + appointUserID;
						}
						var obj = $.ajax({
							url: url,
							type: 'post',
							async: false
						});
						
						var ret = obj.responseText;
						if (ret == "-1") {
							$.messager.alert('错误', '收藏失败，请重新尝试！', 'error');
						}
						else if (ret == "-2"){
							if (FSApplyPermission.addFavoriteType == "add"){
								$.messager.alert('提示', '此次就诊已经在此收藏分类中存在，因此不重复加入', 'info');
							}
							else {
								$.messager.alert('提示', '部分就诊已经在欲移动到的收藏分类中存在，因此不重复加入', 'info');
							}
						}
						else if ((ret != "") && (ret != null) && (parseInt(ret) > 0)) {
							$.messager.alert('提示', '收藏成功！', 'info');
							$('#addFavoriteDialog').dialog('close');
							if (FSApplyPermission.addFavoriteType == "move"){
								var url = '../DHCEPRRBAC.web.eprajax.Favorites.cls';
								$('#favoritesListTable').datagrid('options').url = url;
								var queryParams = $('#favoritesListTable').datagrid('options').queryParams;
								queryParams.Action = 'getlist';
								queryParams.UserID = appointUserID;
								queryParams.FavoritesCategoryID = FSApplyPermission.selectFavoritesCategoryID;

								$('#favoritesListTable').datagrid('options').queryParams = queryParams;
								$('#favoritesListTable').datagrid('reload');							
							}
						}
					}
				}
			},{
				text:'关闭',
				handler:function(){
					$('#addFavoriteDialog').dialog('close');
				}
			}]		
		});  
		
		$('#favoritesDeleteBtn').on('click', function() { 
			var rows = $('#favoritesListTable').datagrid('getSelections');
			if (rows.length <= 0){
				$.messager.alert('错误', '请先选择收藏的项！', 'error');
			}
			else {
				$.messager.confirm('确认删除', '确定要删除选中？', function(r) {
					if (r) {
						var ids = "";
						for (var i=0;i<rows.length;i++){
							var id = rows[i].FavoritesID
							if (ids == ""){
								ids = id;
							}
							else{
								ids = ids + "^" + id;
							}
						}
						var obj = $.ajax({
							url: "../DHCEPRRBAC.web.eprajax.Favorites.cls?Action=delete"+ "&FavoritesIDS=" + ids, 
							type: 'post',
							async: false
						});

						var ret = obj.responseText;
						if (ret == "-1") {
							$.messager.alert('错误', text + '删除失败，请重新尝试！', 'error');
						}
						else if ((ret != "") && (ret != null) && (parseInt(ret) > 0)) {
							$.messager.alert('提示', '删除成功！', 'info');
							var url = '../DHCEPRRBAC.web.eprajax.Favorites.cls';
							$('#favoritesListTable').datagrid('options').url = url;
							var queryParams = $('#favoritesListTable').datagrid('options').queryParams;
							queryParams.Action = 'getlist';
							queryParams.UserID = appointUserID;
							queryParams.FavoritesCategoryID = FSApplyPermission.selectFavoritesCategoryID;

							$('#favoritesListTable').datagrid('options').queryParams = queryParams;
							$('#favoritesListTable').datagrid('reload');
						}
					}
				});
			}
        });	
	
		$('#favoritesMoveBtn').on('click', function() { 
			var rows = $('#favoritesListTable').datagrid('getSelections');
			if (rows.length <= 0){
				$.messager.alert('错误', '请先选择收藏的项！', 'error');
			}
			else {
				var ids = "";
				var episodes = "";
				for (var i=0;i<rows.length;i++){
					var id = rows[i].FavoritesID;
					var episode = rows[i].EpisodeID;
					if (ids == ""){
						ids = id;
						episodes = episode;
					}
					else{
						ids = ids + "^" + id;
						episodes = episodes + "^" + episode;
					}
				}
				FSApplyPermission.favoritesIDS = ids;
				FSApplyPermission.favoritesEpisodeIDS = episodes;
				FSApplyPermission.addFavoriteType = "move";
				refleshCategory("categoryListSelectTable");	
				$('#addFavoriteDialog').dialog('open');					
			}
        });	
		
		var favorites = $('#favoritesListTable').datagrid({
            //url: '',
            queryParams: {
				Action: 'getlist',
                UserID: appointUserID,
				FavoritesCategoryID: ''
            },
            method: 'post',
            loadMsg: '数据装载中......',
            singleSelect: false,
            showHeader: true,
            //fitColumns: true,
			rownumbers:false,
            columns: [[
				{ field: 'ck', checkbox: true },
				{ field: 'FavoritesID', title:'FavoritesID', width:80, sortable: false, hidden:true },
				{ field: 'PAStatusType', title: '状态', width: 80, sortable: true },
				{ field: 'PAAdmType', title: '就诊类型', width: 80, sortable: true },
				{ field: 'PAPMIName', title: '病人姓名', width: 80, sortable: true },
				{ field: 'PAPMIDOB', title: '出生日期', width: 100, sortable: true },
				{ field: 'PAPMIAge', title: '年龄', width: 80, sortable: true },
				{ field: 'PAPMISex', title: '性别', width: 80, sortable: true },
				{ field: 'PAAdmDateTime', title: '入院时间', width: 150, sortable: true },
				{ field: 'PAAdmWard', title: '病区', width: 80, sortable: true },
				{ field: 'PAAdmRoom', title: '病房', width: 80, sortable: true },
				{ field: 'PAAdmBed', title: '病床', width: 80, sortable: true },
				{ field: 'PAAdmLoc', title: '科室', width: 80, sortable: true },
				{ field: 'PADischgeDateTime', title: '出院时间', width: 150, sortable: true },
				{ field: 'PAAdmDoc', title: '医生', width: 80, sortable: true },
				{ field: 'PayMode', title: '付费类型', width: 80, sortable: true },
				{ field: 'EpisodeID', title:'就诊号', width:80, sortable: false },
				{ field: 'PatientID', title:'病人号', width:80, sortable: false },
				{ field: 'MedRecordNo', title:'病案号', width:80, sortable: false },
				{ field: 'RegNo', title:'登记号', width:80, sortable: false }
            ]],
			pagination: true,
            pageSize: 20,
            pageList: [10, 20, 50],
            pagePosition: 'bottom',
            toolbar: '#favoritesListTableTBar',
			onDblClickRow:function(rowIndex, rowData){
				var episodeID = rowData.EpisodeID;
				//检查是否过期
				var obj = $.ajax({
					url: "../DHCEPRRBAC.web.eprajax.View.cls?Action=check&EpisodeID=" + episodeID + "&UserID=" + appointUserID, 
					type: 'post',
					async: false
				});
				var retCheck = obj.responseText;
				if (retCheck == ""){
					var obj = $.ajax({
						url: "../DHCEPRRBAC.web.eprajax.View.cls?Action=getdefaultviewparam&EpisodeID=" + episodeID + "&SSGroupID=" + appointUserSSGroupID, 
						type: 'post',
						async: false
					});
					var ret = obj.responseText;
					var strs = new Array();
					strs = ret.split("|");
					var operationCode = strs[1];
					var items = strs[2];
					if (operationCode == "VIEW"){
						var obj = $.ajax({
							type: 'POST',
							url: "../DHCEPRRBAC.web.eprajax.FS.cls", 
							data: {"Action":"getveritem","EpisodeID":episodeID,"Items": items},
							async: false
						});
						
						var retFS = obj.responseText;
						if ((retFS != "") && (retFS != null) && (retFS != "-1"))  {
							var strsFS = new Array();
							strsFS = retFS.split("!");
							var mrEpisodeID = strsFS[0];
							var verItems = strsFS[1];
							var url = "dhc.epr.fs.viewrecord.csp?MREpisodeID="+mrEpisodeID+"&MRVerItemsIDs="+verItems+"&DataServiceUrl="+FSApplyPermission.DATASERVICEURL;
							FSApplyPermission.WINCOUNT = FSApplyPermission.WINCOUNT + 1;
							window.open (url,FSApplyPermission.WINCOUNT,'height=800,width=1280,top=0,left=0,toolbar=no,menubar=no,scrollbars=no, resizable=yes,location=no, status=no');
							//写入浏览记录
							var obj = $.ajax({
								url: "../DHCEPRRBAC.web.eprajax.Log.cls?Action=addlog&EpisodeID=" + episodeID + "&UserID=" + appointUserID + "&LogType=VIEW" + "&AuthorizationID=default" + "&AuthorizationGroupID=default", 
								type: 'post',
								async: false
							});	
						}
						else{
							$.messager.alert('错误', '此次就诊还没进入归档库', 'error');
						}
					}
					
				}
				else{
					var retCheckStrs = new Array();
					retCheckStrs = retCheck.split("||");
					var AuthorizationGroupID = retCheckStrs[0];
					var AuthorizationID = retCheckStrs;
					var obj = $.ajax({
						url: "../DHCEPRRBAC.web.eprajax.View.cls?Action=getviewparam&EpisodeID=" + episodeID + "&AuthorizationID=" + AuthorizationGroupID, 
						type: 'post',
						async: false
					});
					var ret = obj.responseText;
					if (ret == "-3") {
						$.messager.alert('错误', '获取浏览参数失败', 'error');
					}
					else if (ret == "-2") {
						$.messager.alert('错误', '所选的项目未被审批或者已被拒绝', 'error');
					}
					else if (ret == "-1") {
						$.messager.alert('错误', '所选的项目已过期，请重新申请', 'error');
					}
					else if ((ret != "") && (ret != null)) {	
						var strs = new Array();
						strs = ret.split("|");
						var eprAction = strs[1];
						var operationCode = strs[2];
						var items = strs[3];
			
						if (eprAction == "FS"){

							if (operationCode == "VIEW"){
								var obj = $.ajax({
									type: 'POST',
									url: "../DHCEPRRBAC.web.eprajax.FS.cls", 
									data: {"Action":"getveritem","EpisodeID":episodeID,"Items": items},
									async: false
								});
							
								var retFS = obj.responseText;
								if ((retFS != "") && (retFS != null) && (retFS != "-1"))  {
									var strsFS = new Array();
									strsFS = retFS.split("!");
									var mrEpisodeID = strsFS[0];
									var verItems = strsFS[1];
									var url = "dhc.epr.fs.viewrecord.csp?MREpisodeID="+mrEpisodeID+"&MRVerItemsIDs="+verItems+"&DataServiceUrl="+FSApplyPermission.DATASERVICEURL;
									FSApplyPermission.WINCOUNT = FSApplyPermission.WINCOUNT + 1;
									window.open (url,FSApplyPermission.WINCOUNT,'height=800,width=1280,top=0,left=0,toolbar=no,menubar=no,scrollbars=no, resizable=yes,location=no, status=no');
									//写入浏览记录
									var obj = $.ajax({
										url: "../DHCEPRRBAC.web.eprajax.Log.cls?Action=addlog&EpisodeID=" + episodeID + "&UserID=" + appointUserID + "&LogType=VIEW" + "&AuthorizationID=" + AuthorizationID + "&AuthorizationGroupID=" + AuthorizationGroupID, 
										type: 'post',
										async: false
									});	
								}
								else{
									$.messager.alert('错误', '此次就诊还没进入归档库', 'error');
								}
							}
						}
					}
				}
			}
		});
		
		//分类列表
        var category = $('#categoryListTable').datagrid({
            //url: '../DHCEPRRBAC.web.eprajax.FavoritesCategory.cls',
            queryParams: {
				Action: 'getlist',
                UserID: appointUserID
            },
            method: 'post',
            loadMsg: '数据装载中......',
            singleSelect: true,
            showHeader: true,
            //fitColumns: false,
			rownumbers:false,
            columns: [[
			    { field: 'FavoritesCategoryID', title: '收藏分类ID', width: 80, sortable: true, hidden: true },
				{ field: 'CategoryDesc', title: '分类', width: 150, sortable: true }
            ]],
            toolbar: '#categoryListTableTBar',
			onSelect:function(rowIndex, rowData){
				var url = '../DHCEPRRBAC.web.eprajax.Favorites.cls';
				$('#favoritesListTable').datagrid('options').url = url;
				var queryParams = $('#favoritesListTable').datagrid('options').queryParams;
				queryParams.Action = 'getlist';
				queryParams.UserID = appointUserID;
				queryParams.FavoritesCategoryID = rowData.FavoritesCategoryID;
				FSApplyPermission.selectFavoritesCategoryID = rowData.FavoritesCategoryID;

				$('#favoritesListTable').datagrid('options').queryParams = queryParams;
				$('#favoritesListTable').datagrid('reload');	
			}
        });
		
		//分类列表
        var categorySelect = $('#categoryListSelectTable').datagrid({
            //url: '',
            queryParams: {
				Action: 'getlist',
                UserID: appointUserID
            },
            method: 'post',
            loadMsg: '数据装载中......',
            singleSelect: true,
            showHeader: true,
            //fitColumns: false,
			rownumbers:false,
            columns: [[
			    { field: 'FavoritesCategoryID', title: '收藏分类ID', width: 80, sortable: true, hidden: true },
				{ field: 'CategoryDesc', title: '分类', width: 150, sortable: true }
            ]],
            toolbar: '#categoryListTableSelectTBar',
			onSelect:function(rowIndex, rowData){
				var url = '../DHCEPRRBAC.web.eprajax.Favorites.cls';
				$('#favoritesListTable').datagrid('options').url = url;
				var queryParams = $('#favoritesListTable').datagrid('options').queryParams;
				queryParams.Action = 'getlist';
				queryParams.UserID = appointUserID;
				queryParams.FavoritesCategoryID = rowData.FavoritesCategoryID;
				FSApplyPermission.selectFavoritesCategoryID = rowData.FavoritesCategoryID;

				$('#favoritesListTable').datagrid('options').queryParams = queryParams;
				$('#favoritesListTable').datagrid('reload');	
			}
        });
		
		//formatter--------------------------------------------------------------------------------
		function formatStatusDesc(value,row,index){
			var status = row.AppointStatus;
			if (status == "N"){
				return '<font color="#AAAAFF">' + value + '</font>';
			}
			else if (status == "F"){
				return '<font color="#00A600">' + value + '</font>';
			}
			else if (status == "R"){
				return '<font color="#FF9797">' + value + '</font>';
			}
			else if (status == "D"){
				return '<font color="#7B7B7B">' + value + '</font>';
			}
			else if (status == "I"){
				return '<font color="#7B7B7B">' + value + '</font>';
			}
		}
		
		function myformatter(date){  
			var y = date.getFullYear();  
			var m = date.getMonth()+1;  
			var d = date.getDate();  
			return y+'-'+(m<10?('0'+m):m)+'-'+(d<10?('0'+d):d);  
		} 
		
		function myformatter1(date, span){  
			var d = date.getDate() - span;  
			var tmp = new Date();
			tmp.setDate(d);
			var y = tmp.getFullYear();  
			var m = tmp.getMonth()+1;  
			d = tmp.getDate();  
			return y+'-'+(m<10?('0'+m):m)+'-'+(d<10?('0'+d):d);  
		} 
		
    });
})(jQuery);
