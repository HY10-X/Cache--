Class DHCEPRFS.BL.BLMRRecall Extends %RegisteredObject [ ProcedureBlock ]
{

/// Desc: 	查询召回就诊列表
/// Input: 	AStartDate 出院开始日期
///         AEndDate 出院截止日期
/// 			AAdmType 就诊类型 I：住院，O：门诊
///         AMedRecordNo 病案号
/// 			ACTLocID 科室ID
/// Debug: d ##class(%ResultSet).RunQuery("DHCEPRFS.BL.BLMRRecall","QueryEpisodeList","2021-01-01","2021-12-31","A","","")
Query QueryEpisodeList(AStartDate As %String, AEndDate As %String, AAdmType As %String, AMedRecordNo As %String, ALocID As %String = "") As %Query(ROWSPEC = "SysCode:%String,EpisodeID:%String,MREpisodeID:%String,ArchiveDate:%String,MedRecordNo:%String,RegNo:%String,Name:%String,AdmDate:%String,DisDate:%String,AdmLoc:%String,DisLoc:%String,DisWard:%String")
{
}

ClassMethod QueryEpisodeListExecute(ByRef qHandle As %Binary, AStartDate As %String, AEndDate As %String, AAdmType As %String, AMedRecordNo As %String, ACTLocID As %String = "") As %Status
{
	set repid=$I(^CacheTemp)
	set ind = 1
	set qHandle = $lb(0,repid,0)
	s ^CacheTemp("QueryEpisodeListExecute",AStartDate_"|"_AEndDate_"|"_AAdmType_"|"_AMedRecordNo_"|"_ACTLocID)=""
	s:(ACTLocID = $c(0)) ACTLocID = ""
	s:(AStartDate '= "") startDate = ##class(DHCEPRFS.Util.StringHelper).FormatCacheDate(AStartDate)
	s:(AEndDate '= "") endDate =  ##class(DHCEPRFS.Util.StringHelper).FormatCacheDate(AEndDate)
	s:(AMedRecordNo = $c(0)) AMedRecordNo = ""
	
	if (AMedRecordNo '= "")
	{
		s AMedRecordNo = $zcvt(AMedRecordNo,"U")
		s MREpisodeID = ""
		f {
			s MREpisodeID = $o(^DHCEPRFS.INST.MREpisodeI("IdxMedRecordNo"," "_AMedRecordNo,MREpisodeID))
			q:(MREpisodeID = "")
			d GetEpisodeList
		}
	}
	elseif ((startDate '= "") && (endDate '= ""))
	{
		s date = startDate - 1
		f {
			s date = $o(^DHCEPRFS.INST.MREpisodeI("IdxDisDate",date))
			q:((date = "")||(date > endDate))
			s MRPatientID = ""
			f {
				s MRPatientID = $o(^DHCEPRFS.INST.MREpisodeI("IdxDisDate",date,MRPatientID))
				q:(MRPatientID = "")
				s MREpisodeID = ""
				f {
					s MREpisodeID = $o(^DHCEPRFS.INST.MREpisodeI("IdxDisDate",date,MRPatientID,MREpisodeID))
					q:(MREpisodeID = "")
					d GetEpisodeList
				}
			}
		}
	}
	
	q $$$OK
GetEpisodeList
	s objMREpisode = ##class(DHCEPRFS.INST.MREpisode).%OpenId(MREpisodeID)
	q:(objMREpisode = "")
	s objMRPatient =  ##class(DHCEPRFS.INST.MRPatient).%OpenId(objMREpisode.MRPatientID)
	q:(objMRPatient = "")
	
	s sysCode = objMREpisode.SysCode
	s episodeID = objMREpisode.EpisodeID
	s mrEpisodeID= MREpisodeID
	s archiveDate = ##class(DHCEPRFS.BL.BLMREpisodeStatus).GetArchiveDateByAdm(sysCode,episodeID)
	s medRecordNo = objMREpisode.MedRecordNo
	s regNo = objMRPatient.RegNo
	s name = objMRPatient.Name
	s admDate = $zd(objMREpisode.AdmDate,3)
	s disDate = $zd(objMREpisode.DisDate,3)
	s admLoc = objMREpisode.AdmLoc
	s disLoc = objMREpisode.DisLoc
	s disWard = objMREpisode.DisWard
	
	s ^CacheTemp(repid,ind) = $lb(sysCode,episodeID,mrEpisodeID,archiveDate,medRecordNo,regNo,name,admDate,disDate,admLoc,disLoc,disWard)
	s ind = ind + 1
	q
}

ClassMethod QueryEpisodeListFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status [ PlaceAfter = QueryEpisodeListExecute ]
{
	Set AtEnd = $LIST(qHandle,1)
	Set repid = $LIST(qHandle,2)
	Set ind = $LIST(qHandle,3)
	Set ind = $o(^CacheTemp(repid,ind))
	If ind = "" {				// if there are no more rows, finish fetching
		Set AtEnd = 1
		Set Row = ""
	}
	Else      {				// fetch row
		Set Row = ^CacheTemp(repid,ind)
	}
	// Save QHandle
	s qHandle = $lb(AtEnd,repid,ind)
	Quit $$$OK
}

ClassMethod QueryEpisodeListClose(ByRef qHandle As %Binary) As %Status [ PlaceAfter = QueryEpisodeListExecute ]
{
	Set repid = $LIST(qHandle,2)
	Kill ^CacheTemp(repid)
	Quit $$$OK
}

/// Desc:	查询某个业务系统已归档文件目录
/// Input：	AEpisodeID  		就诊号
/// 			ABusinessSysCode	业务系统代码
/// Output: 结果集 医嘱子表ID,医嘱开始日期,医嘱开始时间,医嘱项编码,医嘱项描述,医嘱状态
/// debug: do ##class(%ResultSet).RunQuery("DHCEPRFS.BL.BLMRRecall","QueryArchivedFiles","27534360","PACS.GE")
Query QueryArchivedFiles(AEpisodeID As %String, ABusinessSysCode As %String) As %SQLQuery
{
	SELECT E.Code As SubcategoryCode, E.Name AS SubcategoryName,D.ID AS MRItemID,D.Name AS MRItemName, 
	C.Remark2 AS DocumentTitle, C.UpdateDate||' '||C.UpdateTime AS UpdateTime,
	C.UpdateUserDesc,C.ID AS MRVerSubItemID,'1' AS IsPrint ,
	(SELECT max(id) FROM DHCEPRFS_INST.MRVerSubItemDetail F WHERE F.TheMRVerSubItem=C.ID ) AS MRVerSubItemDetailID
	 FROM dhceprfs_inst.mrversion A
	INNER JOIN DHCEPRFS_INST.MRVerItem B ON A.ID = B.MRVersionID
	INNER JOIN DHCEPRFS_INST.MRVerSubItem C ON B.ID=c.MRVerItemID 
	INNER JOIN DHCEPRFS_META.MRItem D ON B.MRItemID=D.ID
	INNER JOIN DHCEPRFS_META.MRSubCategory E ON D.MRSubCategoryID=E.ID
	WHERE A.MREpisodeID =(SELECT ID FROM DHCEPRFS_INST.MREpisode WHERE EpisodeID =:AEpisodeID)
	AND c.BusinessSysCode=:ABusinessSysCode
}

/// Desc:	已召回记录
/// Input：	AUserID  		用户编码 
/// 		ABusinessSysCode	业务系统代码
/// Output: 结果集 
/// debug: do ##class(%ResultSet).RunQuery("DHCEPRFS.BL.BLMRRecall","QueryRecallByApplyUser","533","PACS.GE")
Query QueryRecallByApplyUser() As %SQLQuery
{
	SELECT A.ID AS MRRecallID,To_Char(A.ApplyDate,'YYYY-MM-DD') as ApplyDate,A.ApplyTime,B.ID AS MREpisodeID, 
	B.MedRecordNo,C.RegNo,C.Name,To_Char(B.AdmDate,'YYYY-MM-DD') as AdmDate,To_Char(B.DisDate,'YYYY-MM-DD') as DisDate,
	B.AdmLoc,B.DisLoc, A.ApproveStatus,To_Char(A.ApproveDate,'YYYY-MM-DD') AS ApproveDate,A.ApproveTime,
	A.ApproveUserID,A.ApproveUserName,A.AuthorizedDays,
	A.FinishFlag,To_Char(A.FinishDate,'YYYY-MM-DD') AS FinishDate,A.FinishTime
	FROM DHCEPRFS_INST.MRRecall A
	INNER JOIN DHCEPRFS_INST.MREpisode B ON A.MREpisodeID=B.ID
	INNER JOIN DHCEPRFS_INST.MRPatient C ON B.MRPatientID=C.ID
	WHERE ApplyUserID = '533'
}

/// Desc:	增加召回申请记录
/// Input：	AJsonInfo json结构入参
/// Output: String 成功返回ID，否则返回空
/// Debug: w ##class(DHCEPRFS.BL.BLMRRecall).RecallApply()
ClassMethod RecallApply(AJsonInfo As %GlobalBinaryStream) As %String
{
	s ^CacheTemp("RecallApply") = AJsonInfo
	s nowDate= $p($h,",",1)
	s nowTime= $p($h,",",2)
	s jsonObj = ##class(DHCEPRFS.Util.JStream).FromJson(AJsonInfo)
	TSTART
	s $zt = "OnAddRecallApplyErrorHandler"
	
	//主表
	s objMRRecall = ##class(DHCEPRFS.INST.MRRecall).%New()
	s objMRRecall.MREpisodeID = jsonObj.GetAt("MREpisodeID").Read()
	s objMRRecall.EpisodeID = jsonObj.GetAt("EpisodeID").Read()
	s objMRRecall.ApplyRights = jsonObj.GetAt("ApplyRights").Read()
	s objMRRecall.ReasonTypeCode = jsonObj.GetAt("ReasonTypeCode").Read()
	s objMRRecall.ReasonDesc = jsonObj.GetAt("ReasonDesc").Read()
	s objMRRecall.PreContent = jsonObj.GetAt("PreContent").Read()
	s objMRRecall.PostContent = jsonObj.GetAt("PostContent").Read()
	s objMRRecall.ApplyUserID = jsonObj.GetAt("ApplyUserID").Read()
	s objMRRecall.ApplyUserName = jsonObj.GetAt("ApplyUserName").Read()
	s objMRRecall.BusinessSysCode = jsonObj.GetAt("BusinessSysCode").Read()
	s objMRRecall.ApplyDate = nowDate
	s objMRRecall.ApplyTime = nowTime
	s objMRRecall.ApproveStatus = "0"
	s sc=objMRRecall.%Save()
	if ($$$ISERR(sc))
	{
		TRollback
		q "-1"	
	}
	
	//附件表
	s AttachJson = jsonObj.GetAt("Attach")
	s key = ""
	s succeedFlag = "true"
	for {
		s data = AttachJson.GetNext(.key)
		q:(key = "")
		s objMRRecallAttach = ##class(DHCEPRFS.INST.MRRecallAttach).%New()
		s objMRRecallAttach.MRRecallID = objMRRecall.%Id()
		s objMRRecallAttach.OrderNum = data.GetAt("OrderNum").Read()
		
		d objMRRecallAttach.AttachFile.CopyFrom(data.GetAt("AttachFile"))
		/*s stream = ##class(%GlobalBinaryStream).%New()
		d stream.Write(data.GetAt("AttachFile"))
		s objMRRecallAttach.AttachFile = stream*/
		
		
		s sc = objMRRecallAttach.%Save()
		if ($$$ISERR(sc))
		{
			s succeedFlag = "false"
			q
		}
	}
	
	if (succeedFlag = "false")
	{
		TROLLBACK
		q "-2"
	}
	
	//明细表
	s ItemJson = jsonObj.GetAt("Item")
	s key = ""
	s succeedFlag = "true"
	for {
		s data = ItemJson.GetNext(.key)
		q:(key = "")
		s objMRRecallItem = ##class(DHCEPRFS.INST.MRRecallItem).%New()
		s objMRRecallItem.MRRecallID = objMRRecall.%Id()
		s objMRRecallItem.OrderNum = data.GetAt("OrderNum").Read()
		s objMRRecallItem.MRVerSubItemID = data.GetAt("MRVerSubItemID").Read()
		s objMRRecallItem.MRVerSubItemDetailID = data.GetAt("MRVerSubItemDetailID").Read()
		s objMRRecallItem.ApplyRight = data.GetAt("ApplyRight").Read()
		s sc = objMRRecallItem.%Save()
		if ($$$ISERR(sc))
		{
			s succeedFlag = "false"
			q
		}
	}
	
	if (succeedFlag = "false")
	{
		TROLLBACK
		q "-3"
	}
	
	TCOMMIT 
	q objMRRecall.%Id()
	
OnAddRecallApplyErrorHandler
	TROLLBACK
	q "-999:"_$ZERROR
}

/// Desc:	召回审批
/// Input：	AMRRecallID 召回主表ID
/// 			AApproveUserID 审批人ID
/// 			AApproveUserName 审批人姓名
/// 			AApproveStatus 审批状态
/// 			AApproveReason  审批未通过原因
/// 			AAuthorizedDays 授权天数
/// Output: String 成功：1，失败:0
/// Debug: w ##class(DHCEPRFS.BL.BLMRRecall).RecallApprove(4,"userid","username","1","测试",7)
ClassMethod RecallApprove(AMRRecallID As %String, AApproveUserID As %String, AApproveUserName As %String, AApproveStatus As %String, AApproveReason As %String, AAuthorizedDays As %Integer) As %String
{
	s nowDate= $p($h,",",1)
	s nowTime= $p($h,",",2)
	TSTART
	s $zt = "OnRecallApproveErrorHandler"
	
	//修改主表
	s objMRRecall = ##class(DHCEPRFS.INST.MRRecall).%OpenId(AMRRecallID)
	s objMRRecall.ApproveUserID = AApproveUserID
	s objMRRecall.ApproveUserName = AApproveUserName
	s objMRRecall.ApproveDate = nowDate
	s objMRRecall.ApproveTime = nowTime
	s objMRRecall.ApproveStatus = AApproveStatus
	s objMRRecall.ApproveReason = AApproveReason
	s objMRRecall.AuthorizedDays = AAuthorizedDays
	s objMRRecall.ExpiredDate = (nowDate + AAuthorizedDays)	//是否应根据节假日来计算？？
	
	s sc = objMRRecall.%Save()
	if ($$$ISERR(sc))
	{
		TROLLBACK
		q "0"
	}
	
	//修改MREpisodeStatus的召回状态为1
	
	//向业务系统推送授权审批通过信息，业务系统开放相应文书报告的修改权限
	
	
	
	TCOMMIT
	q "1"
OnRecallApproveErrorHandler
	TROLLBACK
	q "0"
}

/// Desc:	召回修改完成
/// Input：	AMRRecallID 召回主表ID
/// Output: String 成功：1，失败:0
/// Debug: w ##class(DHCEPRFS.BL.BLMRRecall).RecallModifyFinish(4)
ClassMethod RecallModifyFinish(AMRRecallID As %String) As %String
{
	
	s nowDate= $p($h,",",1)
	s nowTime= $p($h,",",2)
	
	s objMRRecall = ##class(DHCEPRFS.INST.MRRecall).%OpenId(AMRRecallID)
	
	
	s BusinessSysCode = objMRRecall.BusinessSysCode
	s EpisodeID = objMRRecall.EpisodeID
	//获取业务系统对应的归档类型
	&sql(SELECT TypeCode into :TypeCode FROM DHCEPRFS_META.CTItemType WHERE Company = :BusinessSysCode)
	
	TSTART
	s $zt = "OnRecallModifyFinishErrorHandler"
	
	//产生归档记录
	s retArchiveRecord = ##class(DHCEPRFS.BL.BLMRArchiveRecord).AddRecordByAdm(EpisodeID,"RecallArchive","99","@@T:"_TypeCode)
	if (retArchiveRecord = "0")
	{
		TROLLBACK
		q "0" 
	}
	
	//设置召回记录表修改完成标志
	s objMRRecall.FinishFlag = "1"
	s objMRRecall.FinishDate = nowDate
	s objMRRecall.FinishTime = nowTime
	s objMRRecall.MRArchiveRecordID = retArchiveRecord
	s sc = objMRRecall.%Save()
	if ($$$ISERR(sc))
	{ 	
		TROLLBACK
		q "0" 
	}
	
	TCOMMIT
	q "1"
OnRecallModifyFinishErrorHandler
	TROLLBACK
	q "0"
}

/// Desc:	查询病案召回申请记录(病案科审批)
/// Input：	
/// 		
/// Output: 结果集 
/// debug: do ##class(%ResultSet).RunQuery("DHCEPRFS.BL.BLMRRecall","QueryRecallByApplyUser","533","PACS.GE")
Query QueryRecallApply1() As %SQLQuery
{
	SELECT A.ID AS MRRecallID,To_Char(A.ApplyDate,'YYYY-MM-DD') as ApplyDate,A.ApplyTime,B.ID AS MREpisodeID, 
	B.MedRecordNo,C.RegNo,C.Name,To_Char(B.AdmDate,'YYYY-MM-DD') as AdmDate,To_Char(B.DisDate,'YYYY-MM-DD') as DisDate,
	B.AdmLoc,B.DisLoc, B.DisWard,A.ApplyUserID,A.ApplyUserName,a.BusinessSysCode, A.ApproveStatus,
	To_Char(A.ApproveDate,'YYYY-MM-DD') AS ApproveDate,A.ApproveTime,
	A.ApproveUserID,A.ApproveUserName,A.AuthorizedDays,
	A.FinishFlag,To_Char(A.FinishDate,'YYYY-MM-DD') AS FinishDate,A.FinishTime
	FROM DHCEPRFS_INST.MRRecall A
	INNER JOIN DHCEPRFS_INST.MREpisode B ON A.MREpisodeID=B.ID
	INNER JOIN DHCEPRFS_INST.MRPatient C ON B.MRPatientID=C.ID
}

/// Desc: 	查询病案召回申请记录(病案科审批)
/// Input: 	AStartDate 申请开始日期
///         AEndDate 申请截止日期
/// 		AAdmType 就诊类型 I：住院，O：门诊
/// 		AApproveStatus 审批状态 A:全部，0:未审批，1:已审批
///         AMedRecordNo 病案号
/// 		ACTLocID 科室ID
/// Debug: d ##class(%ResultSet).RunQuery("DHCEPRFS.BL.BLMRRecall","QueryRecallApply","2021-01-01","2023-12-31","A","A","","")
Query QueryRecallApply(AStartDate As %String, AEndDate As %String, AAdmType As %String, AApproveStatus As %String, AMedRecordNo As %String, ALocID As %String = "") As %Query(ROWSPEC = "MRRecallID:%String,ApplyDate:%String,ApplyTime:%String,MREpisodeID:%String,MedRecordNo:%String,RegNo:%String,Name:%String,AdmDate:%String,DisDate:%String,AdmLoc:%String,DisLoc:%String,DisWard:%String,ApplyUserID:%String,ApplyUserName:%String,BusinessSysCode:%String,ApproveStatus:%String,ApproveDate:%String,ApproveTime:%String,ApproveUserID:%String,ApproveUserName:%String,AuthorizedDays:%String,FinishFlag:%String,FinishDate:%String,FinishTime:%String")
{
}

ClassMethod QueryRecallApplyExecute(ByRef qHandle As %Binary, AStartDate As %String, AEndDate As %String, AAdmType As %String, AApproveStatus As %String, AMedRecordNo As %String, ACTLocID As %String = "") As %Status
{
	set repid=$I(^CacheTemp)
	set ind = 1
	set qHandle = $lb(0,repid,0)
	
	s:(ACTLocID = $c(0)) ACTLocID = ""
	s:(AStartDate '= "") startDate = ##class(DHCEPRFS.Util.StringHelper).FormatCacheDate(AStartDate)
	s:(AEndDate '= "") endDate =  ##class(DHCEPRFS.Util.StringHelper).FormatCacheDate(AEndDate)
	s:(AMedRecordNo = $c(0)) AMedRecordNo = ""
	
	if (AMedRecordNo '= "")
	{
		s AMedRecordNo = $zcvt(AMedRecordNo,"U")
		s MREpisodeID = ""
		f {
			s MREpisodeID = $o(^DHCEPRFS.INST.MREpisodeI("IdxMedRecordNo"," "_AMedRecordNo,MREpisodeID))
			q:(MREpisodeID = "")
			s MRRecallID = ""
			f {
				s MRRecallID = $o(^DHCEPRFS.INST.MRRecallI("IdxMREpisodeID"," "_MREpisodeID,MRRecallID))
				d GetRecallApplyList
			}
			
		}
	}
	elseif ((startDate '= "") && (endDate '= ""))
	{
		s date = startDate - 1
		f {
			s date = $o(^DHCEPRFS.INST.MRRecallI("IdxApplyDate",date))
			q:((date = "")||(date > endDate))
			s MRRecallID = ""
			f {
				s MRRecallID = $o(^DHCEPRFS.INST.MRRecallI("IdxApplyDate",date,MRRecallID))
				q:(MRRecallID = "")
				d GetRecallApplyList
			}
		}
	}
	
	q $$$OK
GetRecallApplyList
	s objMRRecall = ##class(DHCEPRFS.INST.MRRecall).%OpenId(MRRecallID)
	q:(objMRRecall = "")
	s objMREpisode =  ##class(DHCEPRFS.INST.MREpisode).%OpenId(objMRRecall.MREpisodeID)
	q:(objMREpisode = "")
	s objMRPatient =  ##class(DHCEPRFS.INST.MRPatient).%OpenId(objMREpisode.MRPatientID)
	q:(objMRPatient = "")
	
	s mrrecallid = MRRecallID
	s applyDate = $zd(objMRRecall.ApplyDate,3)
	s applyTime = $zt(objMRRecall.ApplyTime)
	s mrEpisodeID = objMRRecall.MREpisodeID
	s medRecordNo = objMREpisode.MedRecordNo
	s regNo = objMRPatient.RegNo
	s name = objMRPatient.Name
	s admDate = $zd(objMREpisode.AdmDate,3)
	s disDate = $zd(objMREpisode.DisDate,3)
	s admLoc = objMREpisode.AdmLoc
	s disLoc = objMREpisode.DisLoc
	s disWard = objMREpisode.DisWard
	s applyUserID = objMRRecall.ApplyUserID
	s applyUserName = objMRRecall.ApplyUserName
	s businessSysCode = objMRRecall.BusinessSysCode
	s approveStatus =objMRRecall.ApproveStatus
	if (objMRRecall.ApproveDate = "")
	{
		s approveDate = ""
		s approveTime = ""
	}
	else
	{
		s approveDate = $zd(objMRRecall.ApproveDate,3)
		s approveTime = $zt(objMRRecall.ApproveTime)
	}
	s approveUserID = objMRRecall.ApproveUserID
	s approveUserName = objMRRecall.ApproveUserName
	s authorizedDays = objMRRecall.AuthorizedDays
	s finishFlag = objMRRecall.FinishFlag
	if (objMRRecall.FinishDate = "")
	{
		s finishDate = ""
		s finishTime = ""
	}
	else
	{
		s finishDate = $zd(objMRRecall.FinishDate,3)
		s finishTime = $zt(objMRRecall.FinishTime)
	}
	
	s ^CacheTemp(repid,ind) = $lb(mrrecallid,applyDate,applyTime,mrEpisodeID,medRecordNo,regNo,name,
	admDate,disDate,admLoc,disLoc,disWard,applyUserID,applyUserName,businessSysCode,approveStatus,approveDate,
	approveTime,approveUserID,approveUserName,authorizedDays,finishFlag,finishDate,finishTime)
	s ind = ind + 1
	q
}

ClassMethod QueryRecallApplyFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status [ PlaceAfter = QueryRecallApplyExecute ]
{
	Set AtEnd = $LIST(qHandle,1)
	Set repid = $LIST(qHandle,2)
	Set ind = $LIST(qHandle,3)
	Set ind = $o(^CacheTemp(repid,ind))
	If ind = "" {				// if there are no more rows, finish fetching
		Set AtEnd = 1
		Set Row = ""
	}
	Else      {				// fetch row
		Set Row = ^CacheTemp(repid,ind)
	}
	// Save QHandle
	s qHandle = $lb(AtEnd,repid,ind)
	Quit $$$OK
}

ClassMethod QueryRecallApplyClose(ByRef qHandle As %Binary) As %Status [ PlaceAfter = QueryRecallApplyExecute ]
{
	Set repid = $LIST(qHandle,2)
	Kill ^CacheTemp(repid)
	Quit $$$OK
}

/// Desc:	获取召回记录详情json
/// Input：	AMRRecallID 召回主表ID
/// Output: String json
/// Debug: w ##class(DHCEPRFS.BL.BLMRRecall).GetRecallDetailJson(4)
ClassMethod GetRecallDetailJson1(AMRRecallID As %String) As %String
{
	s retjson = ""
	s objMRRecall = ##class(DHCEPRFS.INST.MRRecall).%OpenId(AMRRecallID)
	q:(objMRRecall = "") retjson
	
	s retjson= "{"
	s retjson = retjson_"""ReasonDesc"": """ _ objMRRecall.ReasonDesc_ ""","
	s retjson = retjson_"""PreContent"": """_ objMRRecall.PreContent _""","
	s retjson = retjson_"""PostContent"": """_ objMRRecall.PostContent _"""," 
	s retjson = retjson_"""Item"": {""rows"":["
	
	s allItemJson = ""
	//取变更文件
	Set rset = ##class(%ResultSet).%New("DHCEPRFS.BL.BLMRRecall:QueryRecallAlterFiles")
	Set sc = rset.Execute(objMRRecall.MREpisodeID,objMRRecall.BusinessSysCode,objMRRecall.MRArchiveRecordID)
	s rowCount = 0 
	While (rset.Next()) {
		s rowCount = rowCount +1
		s DocumentTitle = rset.GetDataByName("DocumentTitle")
		s UpdateTime = rset.GetDataByName("UpdateTime")
		s MRVerSubItemID = rset.GetDataByName("MRVerSubItemID")
		s DetailNum = rset.GetDataByName("DetailNum")
		s FileMasterID = rset.GetDataByName("FileMasterID")
		s AlterType = ""
		s PreFileMasterID = ""
		if (DetailNum=0)
		{
			s AlterType = "新增"
		}
		else
		{
			s AlterType = "修改"
			s MRVerSubItemDetailID = ##class(DHCEPRFS.BL.BLMRVerSubItemDetail).GetMRVerSubItemDetailID(MRVerSubItemID,DetailNum -1)
			if (MRVerSubItemDetailID '= "")
			{
				s objMRVerSubItemDetail = ##class(DHCEPRFS.INST.MRVerSubItemDetail).%OpenId(MRVerSubItemDetailID)
				s PreFileMasterID =objMRVerSubItemDetail.FileMasterID
			}
		}
		s oneItemJson = "{"
		s oneItemJson = oneItemJson _"""DocumentTitle"":"""_DocumentTitle_""","
		s oneItemJson = oneItemJson _"""UpdateTime"":"""_UpdateTime_""","
		s oneItemJson = oneItemJson _"""AlterType"":"""_AlterType_""","
		s oneItemJson = oneItemJson _"""FileMasterID"":"""_##class(web.Util.Encryption).SimpleEncrypt(FileMasterID)_""","
		s oneItemJson = oneItemJson _"""PreFileMasterID"":"""_##class(web.Util.Encryption).SimpleEncrypt(PreFileMasterID)_"""}"
		
		if (allItemJson ="")
		{
			s allItemJson = oneItemJson 
		}
		else
		{
			s allItemJson = allItemJson _ ","_oneItemJson 
		}
	}
	
	d rset.Close()
	
	s retjson = retjson _allItemJson_"],""total"":"""_rowCount_"""}"
	s retjson = retjson _"}"
	q retjson
}

/// Debug: w ##class(DHCEPRFS.BL.BLMRRecall).GetRecallDetailJson("10")
ClassMethod GetRecallDetailJson(AMRRecallID As %String) As %String
{
	s retjson = ""
	s objMRRecall = ##class(DHCEPRFS.INST.MRRecall).%OpenId(AMRRecallID)
	q:(objMRRecall = "") retjson
	
	s retjson= "{"
	s retjson = retjson_"""ReasonDesc"": """ _ objMRRecall.ReasonDesc_ ""","
	s retjson = retjson_"""PreContent"": """_ objMRRecall.PreContent _""","
	s retjson = retjson_"""PostContent"": """_ objMRRecall.PostContent _"""," 
	s retjson = retjson_"""Item"": {""rows"":["
	
	s allItemJson = ""
	s rowCount = 0 
	s xOrdNum = ""
	f {
		s xOrdNum = $o(^DHCEPRFS.INST.MRRecallItemI("IdxUnique"," "_AMRRecallID,xOrdNum))
		q:(xOrdNum = "")
		s xItemID = ""
		f {
			s xItemID = $o(^DHCEPRFS.INST.MRRecallItemI("IdxUnique"," "_AMRRecallID,xOrdNum,xItemID))
			q:(xItemID = "")
			s rowCount = rowCount +1
			
			s objItem = ##class(DHCEPRFS.INST.MRRecallItem).%OpenId(xItemID)
			s mrVerSubItemDetailID = objItem.MRVerSubItemDetailID
			s mrVerSubItemID = objItem.MRVerSubItemID
			s applyRight = objItem.ApplyRight
			
			s objSubItem = ##class(DHCEPRFS.INST.MRVerSubItem).%OpenId(mrVerSubItemID)
			s DocumentTitle = objSubItem.Remark2
			s UpdateTime = objSubItem.UpdateDate_" "_objSubItem.UpdateTime
			s AlterType = $s(applyRight="add":"新增",applyRight="modify":"修改",applyRight="delete":"删除",1:"")
			
			s objMRVerSubItemDetail =  ##class(DHCEPRFS.INST.MRVerSubItemDetail).%OpenId(mrVerSubItemDetailID)
			if (objMRVerSubItemDetail '="")
			{
				s PreFileMasterID = objMRVerSubItemDetail.FileMasterID
			}
			
			//取最新的FileMasterID,是否应该回写召回记录，或者通过MRArchiveRecordID来查。
			s newDetailNum = ##class(DHCEPRFS.BL.BLMRVerSubItemDetail).GetMaxDetailNum(mrVerSubItemID)
			s newMRVerSubItemDetailID = ##class(DHCEPRFS.BL.BLMRVerSubItemDetail).GetMRVerSubItemDetailID(mrVerSubItemID,newDetailNum)
			s objnewMRVerSubItemDetail =  ##class(DHCEPRFS.INST.MRVerSubItemDetail).%OpenId(newMRVerSubItemDetailID)
			if (objnewMRVerSubItemDetail '="")
			{
				s FileMasterID = objnewMRVerSubItemDetail.FileMasterID
			}
			
			s oneItemJson = "{"
			s oneItemJson = oneItemJson _"""DocumentTitle"":"""_DocumentTitle_""","
			s oneItemJson = oneItemJson _"""UpdateTime"":"""_UpdateTime_""","
			s oneItemJson = oneItemJson _"""AlterType"":"""_AlterType_""","
			s oneItemJson = oneItemJson _"""FileMasterID"":"""_##class(web.Util.Encryption).SimpleEncrypt(FileMasterID)_""","
			s oneItemJson = oneItemJson _"""PreFileMasterID"":"""_##class(web.Util.Encryption).SimpleEncrypt(PreFileMasterID)_"""}"
			
			if (allItemJson ="")
			{
				s allItemJson = oneItemJson 
			}
			else
			{
				s allItemJson = allItemJson _ ","_oneItemJson 
			}
		}
	}
	
	s retjson = retjson _allItemJson_"],""total"":"""_rowCount_"""}"
	s retjson = retjson _"}"
	q retjson
}

/// Desc:	查询某次召回变更的归档文件
/// Input：	AMREpisodeID 归档就诊ID
/// 		ABusinessSysCode 业务系统代码
/// 			AMRArchiveRecordID 归档记录ID
/// Output: 结果集 
/// debug: do ##class(%ResultSet).RunQuery("DHCEPRFS.BL.BLMRRecall","QueryRecallAlterFiles","359102","PACS.GE","710")
Query QueryRecallAlterFiles(AMREpisodeID As %String, ABusinessSysCode As %String, AMRArchiveRecordID As %String) As %SQLQuery
{
	SELECT E.Code As SubcategoryCode, E.Name AS SubcategoryName,D.ID AS MRItemID,D.Name AS MRItemName, 
	C.Remark2 AS DocumentTitle, C.UpdateDate||' '||C.UpdateTime AS UpdateTime,
	C.UpdateUserDesc,C.ID AS MRVerSubItemID,F.DetailNum,F.FileMasterID  FROM dhceprfs_inst.mrversion A
	INNER JOIN DHCEPRFS_INST.MRVerItem B ON A.ID = B.MRVersionID
	INNER JOIN DHCEPRFS_INST.MRVerSubItem C ON B.ID=c.MRVerItemID 
	INNER JOIN DHCEPRFS_META.MRItem D ON B.MRItemID=D.ID
	INNER JOIN DHCEPRFS_META.MRSubCategory E ON D.MRSubCategoryID=E.ID
	INNER JOIN DHCEPRFS_INST.MRVerSubItemDetail F ON C.ID=F.TheMRVerSubItem 
	WHERE A.MREpisodeID =:AMREpisodeID
	AND c.BusinessSysCode=:ABusinessSysCode AND F.MRArchiveRecordID=:AMRArchiveRecordID
}

/// Debug: w ##class(DHCEPRFS.BL.BLMRRecall).GetRecallAttach("9")
ClassMethod GetRecallAttach(AMRRecallID As %String) As %GlobalBinaryStream
{
	s retStream=##class(%GlobalBinaryStream).%New()
	s xOrdNum = ""
	s xOrdNum = $o(^DHCEPRFS.INST.MRRecallAttachI("IdxUnique"," "_AMRRecallID,xOrdNum))
	q:(xOrdNum = "") retStream
	s attachID = ""
	s attachID = $o(^DHCEPRFS.INST.MRRecallAttachI("IdxUnique"," "_AMRRecallID,xOrdNum,attachID))
	q:(attachID = "") retStream
	d retStream.Write("{""AttachFile"":""")
	s objAttach = ##class(DHCEPRFS.INST.MRRecallAttach).%OpenId(attachID)
	//d retStream.Write(objAttach.AttachFile)
	s fileStream=##class(%GlobalBinaryStream).%New()
	d fileStream.CopyFrom(objAttach.AttachFile)
	s byteList = fileStream.Read(12288)
	while(byteList'=""){
		d retStream.Write(byteList)
    	s byteList = ""         
        s byteList = fileStream.Read(12288)
	}
	d retStream.Write("""}")
	q retStream
}

}
