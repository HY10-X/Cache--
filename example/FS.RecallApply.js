// 全局变量
var FSRecallApply = FSRecallApply || {
	selectedMREpisodeID:"",
	selectedEpisodeID:"",
	BusinessSysCode:"EMR.DHC"
	};

//全局配置
FSRecallApply.Config = FSRecallApply.Config || {
	DATESPAN: 3,
	PAGESIZE: 30,
	PAGELIST: [20, 30, 50, 100, 200],
	LOADING_INFO: '数据装载中.....'
};

(function (win) {
	$(function() {
		setDefaultDate();
		
		$('#inputAdmType').combobox({
			valueField: 'id',
			textField: 'text',
			panelHeight: 'auto',
			editable: false,
			data: [{
				'id': 'A',
				'text': '全部'
			}, {
				'id': 'I',
				'text': '住院病案'
			}, {
				'id': 'O',
				'text': '门诊病案'
			}],
			onLoadSuccess: function() {
				var typeData = $('#inputAdmType').combobox('getData');
				$('#inputAdmType').combobox('select', typeData[0].id);
			}
		});
		
		$('#inputHosp').combobox({
			valueField: 'HospID',
			textField: 'HospDesc',
			url: $URL + '?ClassName=DHCEPRFS.BL.BLDeptList&QueryName=GetHospitalList&ResultSetType=array&AAddItem=1',
			method: 'post',
			onLoadSuccess: function() {
				var hospData = $('#inputHosp').combobox('getData');
				if (hospData.length > 0) {
					$('#inputHosp').combobox('select', hospData[0].HospID);
				}
			},
			onSelect: function(rec) {
				var url = $URL + '?ClassName=DHCEPRFS.BL.BLDeptList&QueryName=GetLocListByDepDR&ResultSetType=array&AHospID=' + rec.HospID + '&AAddItem=1';
				$('#inputAdmLoc').combobox('reload', url);
			}
		});
		
		$('#inputAdmLoc').combobox({
			valueField: 'LocID',
			textField: 'LocDesc',
			onLoadSuccess: function() {
				var locData = $('#inputAdmLoc').combobox('getData');
				if (locData.length > 0) {
					$('#inputAdmLoc').combobox('select', locData[0].LocID);
				}
			},
			filter: function(q,row) {
				var opts = $(this).combobox('options');
				return (row['LocDesc'].toLowerCase().indexOf(q.toLowerCase())==0)||(row['LocContactName'].toLowerCase().indexOf(q.toLowerCase())==0);
			}
		});
		
		/// 查询点击事件
		$('#btnSearch').on('click', function() {
			searchEpisode();
		});
		
		/// 查询已申请记录
		$('#btnApplied').on('click', function() {
			searchApplied();
		});
		
		/// 导出
		$('#btnExport').on('click', function() {
			//Export();
		});
		
		/// 病案号回车
		$('#inputMrNo').keyup(function(e){
			if(event.keyCode == 13) {
				searchEpisode();
			}
		});
		
		///召回申请
		$('#btnRecallApply').on('click', function() {
			var row = $('#RecallApplyTable').datagrid('getSelected');
			if (row) {
				FSRecallApply.selectedEpisodeID=row.EpisodeID;
				FSRecallApply.selectedMREpisodeID=row.MREpisodeID;
				showApplyDtl(row.EpisodeID);
			}
			else {
				$.messager.alert('提示','请选择一条数据后操作','info');
			}
		});
		
		///修改完成
		$('#btnFinish').on('click', function() {
			var row = $('#RecalledListTable').datagrid('getSelected');
			if (row) {
				$.m({
					ClassName: 'DHCEPRFS.BL.BLMRRecall',
					MethodName: 'RecallModifyFinish',
					AMRRecallID: row.MRRecallID
				},function(txtData) {
					console.log('result:'+txtData);
					$('#RecalledListTable').datagrid('reload');
				});
				$.messager.popover({
					msg: '操作成功！',
					type: 'success',
					timeout: 2000
				});
			}
			else {
				$.messager.alert('提示','请选择一条数据后操作','info');
			}
		});
		
		$HUI.datagrid('#RecallApplyTable',{
			title: '病案列表',
			iconCls:'icon-paper',
			headerCls: 'panel-header-gray',
			fit: true,
			toolbar: '#recallapplytoolbar',
			rownumbers: true,
			singleSelect: false,
			url: $URL,
			queryParams:{
				ClassName: 'DHCEPRFS.BL.BLMRRecall',
				QueryName: 'QueryEpisodeList',
				AStartDate: '',
				AEndDate :'', 
				AAdmType : '',
				AMedRecordNo : '',
				ALocID : ''
			},
			method: 'post',
			pagination: true,
			pageSize: FSRecallApply.Config.PAGESIZE,
			pageList: FSRecallApply.Config.PAGELIST,
			columns: [[
				//{ field: 'ck', checkbox: true },
				{ field: 'RecordID', title: 'RecordID', width: 80, hidden: true },
				{ field: 'SysCode', title: 'SysCode', width: 80, hidden: true },
				{ field: 'EpisodeID', title: '就诊号', width: 80, hidden: true },
				{ field: 'MREpisodeID', title: 'MREpisodeID', width: 80, hidden: true },
				{ field: 'ArchiveDate', title: '归档日期', width: 140},
				{ field: 'PrintStatus', title: '打印标识', width: 100},
				{ field: 'MedRecordNo', title: '病案号', width: 100 },
				{ field: 'RegNo', title: '登记号', width: 120 },
				{ field: 'Name', title: '姓名', width: 80 },
				{ field: 'AdmDate', title: '入院日期', width: 100 },
				{ field: 'DisDate', title: '出院日期', width: 100 },
				{ field: 'AdmLoc', title: '入院科室', width: 150 },
				{ field: 'DisLoc', title: '出院科室', width: 150 },
				{ field: 'DisWard', title: '病区', width: 150 }
			]]
		});
		
		//申请记录列表
		$HUI.datagrid('#RecalledListTable',{
			title: '召回申请列表',
			iconCls:'icon-paper',
			headerCls: 'panel-header-gray',
			fit: true,
			toolbar: '#recalllisttoolbar',
			rownumbers: true,
			singleSelect: false,
			url: $URL,
			queryParams:{
				ClassName: 'DHCEPRFS.BL.BLMRRecall',
				QueryName: 'QueryRecallByApplyUser'
			},
			method: 'post',
			pagination: true,
			pageSize: FSRecallApply.Config.PAGESIZE,
			pageList: FSRecallApply.Config.PAGELIST,
			columns: [[
				//{ field: 'ck', checkbox: true },
				{ field: 'MRRecallID', title: 'MRRecallID', width: 80, hidden: true },
				{ field: 'MREpisodeID', title: 'MREpisodeID', width: 80, hidden: true },
				{ field: 'ApplyDate', title: '申请日期', width: 100, hidden: false },
				{ field: 'RegNo', title: '病人ID', width: 80},
				{ field: 'MedRecordNo', title: '病案号', width: 80},
				{ field: 'Name', title: '姓名', width: 80 },
				{ field: 'AdmDate', title: '入院日期', width: 100 },
				{ field: 'DisDate', title: '出院日期', width: 100 },
				{ field: 'AdmLoc', title: '入院科室', width: 150 },
				{ field: 'DisLoc', title: '出院科室', width: 150 },
				{ field: 'ApproveStatus', title: '审批状态', width: 100, hidden: true },
				{ field: 'ApproveStatusDesc', title: '审批状态' ,width: 100,
				formatter: function(value,row,index){
					var approveStatus = row.ApproveStatus;
					if (parseInt(approveStatus) == 1) {
						return '已审批';
					}
					else {
						return '未审批';
					}
				}},
				{ field: 'ApproveDate', title: '审批日期', width: 100 },
				{ field: 'ApproveUserName', title: '审批人', width: 100 },
				{ field: 'AuthorizedDays', title: '授权时长(天)', width: 100 },
				{ field: 'FinishFlag', title: '修改完成标志', width: 100, hidden: true },
				{ field: 'FinishStatus', title: '修改完成状态' ,width: 100,
				formatter: function(value,row,index){
					var finishFlag = row.FinishFlag;
					if (parseInt(finishFlag) == 1) {
						return '已完成';
					}
					else {
						return '未完成';
					}
				}},
				{ field: 'FinishDate', title: '修改完成时间', width: 100 }
				
			]]
		});
		
		// 查询就诊
		function searchEpisode() {
			$('#panel1').panel('open');
			$('#panel2').panel('close');
			var queryParams = $('#RecallApplyTable').datagrid('options').queryParams;
			queryParams.AStartDate = $('#inputDateStart').datebox('getValue');
			queryParams.AEndDate = $('#inputDateEnd').datebox('getValue');
			queryParams.AAdmType = $('#inputAdmType').combobox('getValue');
			queryParams.ALocID = $('#inputAdmLoc').combobox('getValue');
			queryParams.AMedRecordNo = $('#inputMrNo').val();
			$('#RecallApplyTable').datagrid('options').queryParams = queryParams;
			$('#RecallApplyTable').datagrid('reload');
			$('#RecallApplyTable').datagrid('getPager').pagination('select',1);
			$('#RecallApplyTable').datagrid('resize');
		}
		
		//查询已申请记录
		function searchApplied(){
			//alert("searchApplied");
			
			$('#panel1').panel('close');
			$('#panel2').panel('open');
			//alert("searchApplied0");
			var queryParams = $('#RecalledListTable').datagrid('options').queryParams;
			/*queryParams.AStartDate = $('#inputDateStart').datebox('getValue');
			queryParams.AEndDate = $('#inputDateEnd').datebox('getValue');
			queryParams.AAdmType = $('#inputAdmType').combobox('getValue');
			queryParams.ALocID = $('#inputAdmLoc').combobox('getValue');
			queryParams.AFinishStatus = $('#inputFinishStatus').combobox('getValue');
			
			*/
			//alert("searchApplied1");
			$('#RecalledListTable').datagrid('options').queryParams = queryParams;
			$('#RecalledListTable').datagrid('reload');
			$('#RecalledListTable').datagrid('getPager').pagination('select',1);
			$('#RecalledListTable').datagrid('resize');
			//alert("searchApplied2");
		}
		
		$(".upload-image-box").imageUpload({
			fileInput: 'file1',
			width: 120,
			height: 120,
			maxNum: 100, //允许选择图片数量
			allowZoom: true, //允许放大
			maxSize: 10, //允许上传图片的最大尺寸，单位M
			appendMethod: 'after',
			allowType: ['jpg','png'],
			error: function(e) {
				alert(e.msg + '(' + e.code + ')');
			}
		});
		
		$("#btnUpload").click(function (argument) {
			var $files = $("input[name='file1[]']");
			if ($files.length==0) {
				$.messager.alert('提示','请上传附件','info');
				return;
			}
			var arrFile = [];
			for (var $i = 0; $i < $files.length; $i++) {
				var oneFile = {};
				var $file = $files[$i];
				var dataURL = $file.defaultValue;
				oneFile.OrderNum = $i;
				oneFile.AttachFile = dataURL;
				var strFile = JSON.stringify(oneFile);
				arrFile.push(strFile);
			}
			console.dir(arrFile);
		});
		
		/// 提交按钮
		$('#btnSubmit').on('click', function() {
			submit();
		});
		
		// 召回申请
		function submit(){
			//附件信息
			var $files = $("input[name='file1[]']");
			if ($files.length==0) {
				$.messager.alert('提示','请上传附件','info');
				return;
			}
			
			/*var strFile = '';
			var arrFile = [];
			for (var $i=0;$i<$files.length;$i++) {
				var oneFile = {};
				var $file = $files[$i];
				var dataURL = $file.defaultValue;
				oneFile.OrderNum = $i + 1;
				oneFile.AttachFile = dataURL;
				arrFile.push(oneFile);
			}
			strFile = JSON.stringify(arrFile);*/
			
            //组织json
            var strjson = "";
            strjson += "{";
            strjson += "\"MREpisodeID\":" + "\"" +FSRecallApply.selectedMREpisodeID+"\",";
            strjson += "\"EpisodeID\":" + "\"" +FSRecallApply.selectedEpisodeID+"\",";
            strjson += "\"ApplyRights\":" + "\"ApplyRights\",";
            strjson += "\"ReasonTypeCode\":" + "\"01\",";
           
            strjson += "\"ReasonDesc\":" + "\"" + $('#result').text() +"\",";
            strjson += "\"PreContent\":" + "\"" + $('#preContent').text() +"\",";
            strjson += "\"PostContent\":" + "\"" + $('#postContent').text() +"\",";
             
            strjson += "\"ApplyUserID\":" + "\"" + "533" +"\",";
            strjson += "\"ApplyUserName\":" + "\"" + "医生01" +"\",";
            strjson += "\"BusinessSysCode\":" + "\"" +FSRecallApply.BusinessSysCode+"\",";
            strjson += "\"Attach\":[";
            //strjson += "{\"OrderNum\": \"1\",\"AttachFile\": \"929fsdf798789ds7f98sd7fs98\"},"
            //strjson += "{\"OrderNum\": \"2\",\"AttachFile\": \"121212929fsdf798789ds7f98sd7fs98\"}"
            for (var $i=0;$i<$files.length;$i++) {
				var oneFile = {};
				var $file = $files[$i];
				var dataURL = $file.defaultValue;
				oneFile.OrderNum = $i + 1;
				oneFile.AttachFile = dataURL;
				strjson += JSON.stringify(oneFile);
			}
            strjson += "],";
            strjson += "\"Item\":[";
            
            var checkedNodes = $('#TreeEMRDir').tree('getChecked');
            for (var i = 0; i < checkedNodes.length; i++) {
	            var applyRight = '';
	            $('input[name="applyauth-'+checkedNodes[i].id+'"]').each(function(ind,ele){
			        if (ele.checked) {
						applyRight = $(ele).attr('value');
					}
				});
				
				if (checkedNodes[i].mrversubitemdetailid !=undefined)
				{
					 
					//alert(checkedNodes[i].mrversubitemdetailid);
	                strjson +=  "{\"OrderNum\":\"" + (i+1) +"\",\"MRVerSubItemID\": \""+ checkedNodes[i].id +"\",\"MRVerSubItemDetailID\": \""+checkedNodes[i].mrversubitemdetailid+"\",\"ApplyRight\": \"" + applyRight + "\"}"
	                if (i== checkedNodes.length -1)	//最后一个
	                {
		            	strjson += "]";    
		            }
		            else
		            {
			            strjson += ",";  
			        }
				}
            }
            strjson += "}";    
            //console.log(strjson);
            //alert(strjson);
            $.m({
				ClassName: 'DHCEPRFS.BL.BLMRRecall',
				MethodName: 'RecallApply',
				AJsonInfo: strjson
			},function(txtData) {
				console.log('result:'+txtData);
				alert("申请成功");
			});
			//测试方法
			/*$.m({
				ClassName: 'DHCEPRFS.BL.BLMRRecall',
				MethodName: 'ApplyTest',
				AApplyInfo: strjson
			},function(txtData) {
				console.log('result:'+txtData);
				alert("申请成功");
			});*/
            /*$.m({
				ClassName: 'DHCEPRFS.BL.BLMRRecall',
				MethodName: 'RecallApply',
				AJsonInfo: strjson
				},function(txtData) {
					alert("申请成功");
				}
			);*/
		}
		
		// 设置默认时间
		function setDefaultDate() {
			var currDate = new Date();
			$('#inputDateStart').datebox('setValue', myformatter1(currDate, FSRecallApply.Config.DATESPAN));
			$('#inputDateEnd').datebox('setValue', myformatter(currDate));
		}
		
		function myformatter(date) {
			var y = date.getFullYear();
			var m = date.getMonth() + 1;
			var d = date.getDate();
			return y + '-' + (m < 10 ? ('0' + m) : m) + '-' + (d < 10 ? ('0' + d) : d);
		}
		
		function myformatter1(date, span) {
			var d = date.getDate() - span;
			var tmp = new Date();
			tmp.setDate(d);
			var y = tmp.getFullYear();
			var m = tmp.getMonth() + 1;
			d = tmp.getDate();
			return y + '-' + (m < 10 ? ('0' + m) : m) + '-' + (d < 10 ? ('0' + d) : d);
		}
	});
}(window));

// 打开申请信息界面
function showApplyDtl(episodeID)
{
	InitEMRDirTree(episodeID);
	apendPatInfoItem(episodeID);
	var ApplyInfoDialog = $('#ApplyInfoDialog').dialog({
		title:'申请信息',
		iconCls:'icon-paper',
		width: 1000,
		height: 700,
		minimizable:false,
		maximizable:false,
		maximizable:false,
		collapsible:false,
		closed: false,
		cache: false,
		modal: true,
		buttons: '#dlgApplyBtn'
	});
	return;
}


 // 初始化病历目录
function InitEMRDirTree(episodeID) {
	//alert("InitEMRDirTree" + episodeID);
	var TreeEMRDir = $HUI.tree("#TreeEMRDir",{
		checkbox:true,
		formatter:function(node){
			//formatter  此时isLeaf方法还无法判断是不是叶子节点 可通过children
			if (node.children){
				return node.text;
			}else{
				return "<div >"
					+"<span data-id='"+node.id+"' class='icon-write-order' style='display:block;width:16px;height:16px;position:absolute;right:5px;top:5px;'></span>"
					+"<span style='height:20px;line-height:20px;'>"+node.text+"</span>&nbsp;"
					+"<span style='height:20px;line-height:20px;color:gray'>"+node.updatetime+"</span>"
					+"<span style='height:20px;line-height:20px;color:gray'>"+node.updateuserdesc+"</span>&nbsp;"
					//+"<span><input type='checkbox' label='修改' name='applyModify' value='newAut'><label>修改</label>"+"</span>"
					//+"<span><input type='checkbox' label='删除' name='applyDel' value='newAut'><label>删除</label>"+"</span>"
					+"<span><input type='checkbox' label='修改' name='applyauth-"+node.id+"' value='modify'><label>修改</label>"
					+"<input type='checkbox' label='删除 'name='applyauth-"+node.id+"' value='delete'><label>删除</label>"+"</span>"
					+"</div>";
				//同时给此树下的tree-node 加上position: relative;   以实现小图标靠右:
			}
			
		},
		lines:true,autoNodeHeight:true
	});
	$.cm({
		wantreturnval: 0,
		ClassName: 'DHCEPRFS.web.eprajax.AjaxMRRecall',
		MethodName: 'GetArchivedFilesJSON',
		AEpisodeID: episodeID,
		ABusinessSysCode:FSRecallApply.BusinessSysCode
	},function(data){
		$('#TreeEMRDir').tree('loadData',data);
	});
}

// 展示患者基本信息
function apendPatInfoItem(episodeID)
{
	//alert("apendPatInfoItem"+episodeID);
	$.m({
		ClassName: 'DHCEPRFS.BL.BLMREpisode',
		MethodName: 'GetPatientInfoByAdm',
		AEpisodeID: episodeID
	},function(txtData) {
		if ((txtData != '')&&(txtData != '-1')) {
			var arrPatInfo = txtData.split('^');
			var html = '<div style="text-align:left;">'
			switch(arrPatInfo[5]){
				case '男':
					html +='<img style=" background: url(../scripts/epr/Pics/pdficon/man_big.png) 0% 0% / cover no-repeat; position: absolute; top: 0px; width: 30px; height: 30px; border-radius: 30px;"/>'
					break;
				case '女':
					html +='<img style=" background: url(../scripts/epr/Pics/pdficon/woman_big.png) 0% 0% / cover no-repeat; position: absolute; top: 0px; width: 30px; height: 30px; border-radius: 30px;"/>'
				   break;
				default:
					html +='<img style=" background: url(../scripts/epr/Pics/pdficon/man_big.png) 0% 0% / cover no-repeat; position: absolute; top: 0px; width: 30px; height: 30px; border-radius: 30px;"/>'
			}
			html +='<span style="margin: 0 5px; margin-left: 38px">'
			html +=arrPatInfo[4]
			html +='</span><span>/</span>'
			html +='<span style="margin: 0 10px">'
			html +=arrPatInfo[5]
			html +='</span><span>/</span>'

			html +='<span style="margin: 0 10px">'
			html +="age"
			html +='</span><span>/</span>'

			html +='<span>病案号:</span><span style="color: #589dda; margin: 0 10px">'
			html +=arrPatInfo[0]
			html +='</span>'

			html +='<span>住院次数:</span><span style="color: #ebb806; margin: 0 10px">'
			html +="1"
			html +='</span>'

			html +='<span>入院日期:</span><span style="color: #ebb806; margin: 0 10px">'
			html +=arrPatInfo[6]
			html +='</span>'

			html +='<span>出院日期:</span><span style="color: #ebb806; margin: 0 10px">'
			html +=arrPatInfo[7]
			html +='</span>'

			html +='<span>出院科室:</span><span style="color: #ebb806; margin: 0 10px">'
			html +=arrPatInfo[9]
			html +='</span>'
			html +='<div>'
			$('#PatInfoItem').html(html)
		}
	});
}
