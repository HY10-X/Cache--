Class DHCEPRRBAC.web.eprajax.ApplyPermission Extends %CSP.Page [ ClassType = "", ProcedureBlock ]
{

ClassMethod OnPage() As %Status
{
	s action = $g(%request.Data("Action",1),"")
	s pageSize = $g(%request.Data("rows",1),"")
	s pageNum = $g(%request.Data("page",1),"")
	s startRow = (pageNum -1)*pageSize + 1
	s endRow = startRow + pageSize -1
	
	s episodeID = $Get(%request.Data("EpisodeID",1),"")
	s patientID = $Get(%request.Data("PatientID",1),"")
	s regNo = $Get(%request.Data("RegNo",1),"")
	s medRecordID = $Get(%request.Data("MedRecordID",1),"")
	s patientName = $Get(%request.Data("PatientName",1),"")
	s patientLocID = $Get(%request.Data("PatientLocID",1),"")
	s patientWardID = $Get(%request.Data("PatientWardID",1),"")
	
	s param = patientID_"^"_patientName_"^"_patientLocID_"^"_patientWardID_"^"_episodeID_"^"_regNo_"^"_medRecordID
	
	s userID = $g(%request.Data("UserID",1),"")
	s userLocID = $g(%request.Data("UserLocID",1),"")
	s userSSGroupID = $g(%request.Data("UserSSGroupID",1),"")
	
	s applyStatus = $g(%request.Data("ApplyStatus",1),"")
	s applyStartDate = $g(%request.Data("ApplyStartDate",1),"")
	s applyEndDate = $g(%request.Data("ApplyEndDate",1),"")
	s aStartDate = $g(%request.Data("AStartDate",1),"")
	s aEndDate = $g(%request.Data("AEndDate",1),"")
	
	s eprAction = $g(%request.Data("EPRAction",1),"")
	s episodeString = $g(%request.Data("EpisodeString",1),"")
	s reason = $g(%request.Data("Reason",1),"")
	s spanTime = $g(%request.Data("SpanTime",1),"")
	
	s authorizationID = $g(%request.Data("AuthorizationID",1),"")
	s roleID = $g(%request.Data("RoleID",1),"")
	s opID = $g(%request.Data("OpID",1),"")
	s authorizationIDList = $g(%request.Data("AuthorizationIDList",1),"")
	s spanTimeList = $g(%request.Data("SpanTimeList",1),"")
	
	if (action = "applylist")
	{
		d ..GetApplyListJSON(userID,applyStatus,applyStartDate,applyEndDate,startRow,endRow)
	}
	elseif (action = "applydefaultlist")
	{
		d ..GetApplyDefaultListJSON(userID,applyStatus,applyStartDate,applyEndDate,startRow,endRow)
	}
	elseif (action = "authorizationlist")
	{
		d ..GetAuthoriztionListJSON(aStartDate,aEndDate,startRow,endRow)
	}
	elseif (action = "applylistdetail")
	{
		d ..GetApplyListDetailJSON(authorizationID)
	}
	elseif (action = "episodelist")
	{
		d ..GetEPREpisodeListJSON(param, userID, userLocID, userSSGroupID, startRow, endRow)
	}
	elseif (action = "apply")
	{
		w ..Apply(eprAction,episodeString,userID,userLocID,userSSGroupID,reason,spanTime)
	}
	elseif (action = "defaultrole")
	{
		w ..DefaultRole(eprAction,episodeString,userID,userLocID,userSSGroupID)
	}
	elseif (action = "outpatientview")
	{
		w ..OutPatientView(eprAction,episodeString, userID, userLocID, userSSGroupID)
	}
	elseif (action = "getlist")
	{
		d ..GetListJSON(applyStatus,applyStartDate,applyEndDate,startRow,endRow)
	}
	elseif (action = "adduserrole")
	{
		w ..AddUserRole(userID,roleID,opID,authorizationIDList,spanTimeList)
	}
	elseif (action = "reject")
	{
		w ..Reject(userID,authorizationIDList,reason)
	}
	elseif (action = "cancel")
	{
		w ..Cancel(userID,authorizationIDList,reason)
	}
	elseif (action = "reapply")
	{
		w ..ReApply(authorizationID,reason,spanTime)
	}
	
	Quit $$$OK
}

/// Debug: w ##class(DHCEPRRBAC.web.eprajax.ApplyPermission).AddUserRole("153","1","1","1","12")
ClassMethod AddUserRole(AUserID As %String, ARoleID As %String, AOpID As %String, AAuthorizationIDList As %String, ASpanTimeList As %String)
{
	s ret = ##class(DHCEPRRBAC.BL.BLFSAuthorization).AddUserRole(AUserID,ARoleID,AOpID,AAuthorizationIDList,ASpanTimeList)
	q ret
}

/// Debug: w ##class(DHCEPRRBAC.web.eprajax.ApplyPermission).Cancel("153","9","test")
ClassMethod Cancel(AUserID As %String, AAuthorizationIDList As %String, AReason As %String) As %String
{
	s ret = ##class(DHCEPRRBAC.BL.BLFSAuthorization).Cancel(AUserID,AAuthorizationIDList,AReason)
	q ret
}

/// Debug: w ##class(DHCEPRRBAC.web.eprajax.ApplyPermission).Reject("153","9","test")
ClassMethod Reject(AUserID As %String, AAuthorizationIDList As %String, AReason As %String) As %String
{
	s ret = ##class(DHCEPRRBAC.BL.BLFSAuthorization).Reject(AUserID,AAuthorizationIDList,AReason)
	q ret
}

/// Debug: w ##class(DHCEPRRBAC.web.eprajax.ApplyPermission).Apply("FS","1273915^5236876","159","9","134","科研病历","24")
ClassMethod Apply(AEPRAction As %String, AEpisodeString As %String, AUserID As %String, AUserLocID As %String, AUserSSGroupID As %String, AReason As %String, ASpanTime As %String) As %String
{
	s ret = ##class(DHCEPRRBAC.BL.BLFSAuthorization).Apply(AEPRAction,AEpisodeString,AUserID,AUserLocID,AUserSSGroupID,AReason,ASpanTime)
	q ret
}

/// Debug: w ##class(DHCEPRRBAC.web.eprajax.ApplyPermission).DefaultRole("FS","1273915^5236876","159","9","134")
ClassMethod DefaultRole(AEPRAction As %String, AEpisodeString As %String, AUserID As %String, AUserLocID As %String, AUserSSGroupID As %String) As %String
{
	s ret = ##class(DHCEPRRBAC.BL.BLFSAuthorization).DefaultRole(AEPRAction,AEpisodeString,AUserID,AUserLocID,AUserSSGroupID)
	q ret
}

/// Debug: w ##class(DHCEPRRBAC.web.eprajax.ApplyPermission).OutPatientView("FS","8921328","2776","1673","1")
ClassMethod OutPatientView(AEPRAction As %String, AEpisodeString As %String, AUserID As %String, AUserLocID As %String, AUserSSGroupID As %String) As %String
{
	s ret = ##class(DHCEPRRBAC.BL.BLFSAuthorization).OutPatientView(AEPRAction,AEpisodeString,AUserID,AUserLocID,AUserSSGroupID)
	q ret
}

/// Debug: w ##class(DHCEPRRBAC.web.eprajax.ApplyPermission).ReApply("29","test","12")
ClassMethod ReApply(AAuthorizationID As %String, AReason As %String, ASpanTime As %String) As %String
{
	s ret = ##class(DHCEPRRBAC.BL.BLFSAuthorization).ReApply(AAuthorizationID,AReason,ASpanTime)
	q ret
}

/// Debug: d ##class(DHCEPRRBAC.web.eprajax.ApplyPermission).GetAuthoriztionListJSON("2015-7-2","2015-7-2",1,20)
ClassMethod GetAuthoriztionListJSON(AStartDate As %String, AEndDate As %String, AIdxStart As %Integer, AIdxLast As %Integer)
{
	s result = ##Class(%ResultSet).%New("DHCEPRRBAC.BL.BLFSAuthorization:GetAuthorizationList")
	s sc = result.Execute(AStartDate, AEndDate)
	
	s count = 0
	s first = 1
	w "{""rows"":["
	
	While (result.Next())
	{
		s count = count + 1
		if (count >= AIdxStart) && (count <= AIdxLast)
		{
			if ((count > 1)&&(first '= 1)) w ","
			w "{"
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""AuthorizationID"":"""_$g(result.Data("AuthorizationID"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""RequestUserID"":"""_$g(result.Data("RequestUserID"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""RequestUserName"":"""_$g(result.Data("RequestUserName"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""RequestDeptID"":"""_$g(result.Data("RequestDeptID"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""RequestDept"":"""_$g(result.Data("RequestDept"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""RequestSSGroupID"":"""_$g(result.Data("RequestSSGroupID"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""RequestSSGroup"":"""_$g(result.Data("RequestSSGroup"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""RequestDate"":"""_$g(result.Data("RequestDate"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""RequestTime"":"""_$g(result.Data("RequestTime"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""RequestReason"":"""_$g(result.Data("RequestReason"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""RequestTimeSpan"":"""_$g(result.Data("RequestTimeSpan"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""AppointUserID"":"""_$g(result.Data("AppointUserID"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""AppointUserName"":"""_$g(result.Data("AppointUserName"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""AppointDate"":"""_$g(result.Data("AppointDate"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""AppointTime"":"""_$g(result.Data("AppointTime"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""AppointEndDate"":"""_$g(result.Data("AppointEndDate"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""AppointEndTime"":"""_$g(result.Data("AppointEndTime"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""RoleID"":"""_$g(result.Data("RoleID"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""RoleCode"":"""_$g(result.Data("RoleCode"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""RoleDesc"":"""_$g(result.Data("RoleDesc"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""OperationID"":"""_$g(result.Data("OperationID"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""OperationCode"":"""_$g(result.Data("OperationCode"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""OperationDesc"":"""_$g(result.Data("OperationDesc"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""EPRAction"":"""_$g(result.Data("EPRAction"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""EPRActionDesc"":"""_$g(result.Data("EPRActionDesc"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""AppointType"":"""_$g(result.Data("AppointType"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""AppointStatus"":"""_$g(result.Data("AppointStatus"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""AppointStatusDesc"":"""_$g(result.Data("AppointStatusDesc"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""AppointComment"":"""_$g(result.Data("AppointComment"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""HasAdvancedSecurity"":"""_$g(result.Data("HasAdvancedSecurity"))_"""")
			w "}"
			s first = 0
		}
	}
	w "],""total"":"_count_"}"
}

/// Debug: d ##class(DHCEPRRBAC.web.eprajax.ApplyPermission).GetListJSON("N","","",1,20)
ClassMethod GetListJSON(AStatus As %String, AStartDate As %String, AEndDate As %String, AIdxStart As %Integer, AIdxLast As %Integer) As %String
{
	s result = ##Class(%ResultSet).%New("DHCEPRRBAC.BL.BLFSAuthorization:GetApplyListByStatus")
	s sc = result.Execute(AStatus, AStartDate, AEndDate)
	
	s count = 0
	s first = 1
	w "{""rows"":["
	
	While (result.Next())
	{
		s count = count + 1
		if (count >= AIdxStart) && (count <= AIdxLast)
		{
			if ((count > 1)&&(first '= 1)) w ","
			w "{"
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""AuthorizationID"":"""_$g(result.Data("AuthorizationID"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""RequestUserID"":"""_$g(result.Data("RequestUserID"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""RequestUserName"":"""_$g(result.Data("RequestUserName"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""RequestDeptID"":"""_$g(result.Data("RequestDeptID"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""RequestDept"":"""_$g(result.Data("RequestDept"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""RequestSSGroupID"":"""_$g(result.Data("RequestSSGroupID"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""RequestSSGroup"":"""_$g(result.Data("RequestSSGroup"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""RequestDate"":"""_$g(result.Data("RequestDate"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""RequestTime"":"""_$g(result.Data("RequestTime"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""RequestReason"":"""_$g(result.Data("RequestReason"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""RequestTimeSpan"":"""_$g(result.Data("RequestTimeSpan"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""AppointUserID"":"""_$g(result.Data("AppointUserID"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""AppointUserName"":"""_$g(result.Data("AppointUserName"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""AppointDate"":"""_$g(result.Data("AppointDate"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""AppointTime"":"""_$g(result.Data("AppointTime"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""AppointEndDate"":"""_$g(result.Data("AppointEndDate"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""AppointEndTime"":"""_$g(result.Data("AppointEndTime"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""RoleID"":"""_$g(result.Data("RoleID"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""RoleCode"":"""_$g(result.Data("RoleCode"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""RoleDesc"":"""_$g(result.Data("RoleDesc"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""OperationID"":"""_$g(result.Data("OperationID"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""OperationCode"":"""_$g(result.Data("OperationCode"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""OperationDesc"":"""_$g(result.Data("OperationDesc"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""EPRAction"":"""_$g(result.Data("EPRAction"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""EPRActionDesc"":"""_$g(result.Data("EPRActionDesc"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""AppointType"":"""_$g(result.Data("AppointType"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""AppointStatus"":"""_$g(result.Data("AppointStatus"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""AppointStatusDesc"":"""_$g(result.Data("AppointStatusDesc"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""AppointComment"":"""_$g(result.Data("AppointComment"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""HasAdvancedSecurity"":"""_$g(result.Data("HasAdvancedSecurity"))_"""")
			w "}"
			s first = 0
		}
	}
	w "],""total"":"_count_"}"
}

/// Debug: d ##Class(DHCEPRRBAC.web.eprajax.ApplyPermission).GetApplyDefaultListJSON("2776","D","2015-1-1","2015-7-30",1,20)
ClassMethod GetApplyDefaultListJSON(AUserID As %String, AApplyStatus As %String, AApplyStartDate As %String, AApplyEndDate As %String, AIdxStart As %Integer, AIdxLast As %Integer)
{
	s result = ##Class(%ResultSet).%New("DHCEPRRBAC.BL.BLFSAuthorization:GetApplyDefaultByUserID")
	s sc = result.Execute(AUserID,AApplyStatus,AApplyStartDate,AApplyEndDate)
	
	s count = 0
	s first = 1
	w "{""rows"":["
	
	While (result.Next())
	{
		s count = count + 1
		if (count >= AIdxStart) && (count <= AIdxLast)
		{
			if ((count > 1)&&(first '= 1)) w ","
			w "{"
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""AuthorizationID"":"""_$g(result.Data("AuthorizationID"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""AuthorizationDetailID"":"""_$g(result.Data("AuthorizationDetailID"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""PAStatusType"":"""_$g(result.Data("PAStatusType"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""PAAdmType"":"""_$g(result.Data("PAAdmType"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""PAPMIName"":"""_$g(result.Data("PAPMIName"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""PAPMINO"":"""_$g(result.Data("PAPMINO"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""PAPMIDOB"":"""_$g(result.Data("PAPMIDOB"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""PAPMIAge"":"""_$g(result.Data("PAPMIAge"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""PAPMISex"":"""_$g(result.Data("PAPMISex"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""PAAdmDate"":"""_$g(result.Data("PAAdmDate"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""PAAdmTime"":"""_$g(result.Data("PAAdmTime"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""PAAdmWard"":"""_$g(result.Data("PAAdmWard"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""PAAdmLoc"":"""_$g(result.Data("PAAdmLoc"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""PADischgeDate"":"""_$g(result.Data("PADischgeDate"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""PADischgeTime"":"""_$g(result.Data("PADischgeTime"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""PAAdmDoc"":"""_$g(result.Data("PAAdmDoc"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""PayMode"":"""_$g(result.Data("PayMode"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""EpisodeID"":"""_$g(result.Data("EpisodeID"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""PatientID"":"""_$g(result.Data("PatientID"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""MedRecordNo"":"""_$g(result.Data("MedRecordNo"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""RegNo"":"""_$g(result.Data("RegNo"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""LinkedParam"":"""_$g(result.Data("LinkedParam"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""IsAdvancedSecurity"":"""_$g(result.Data("IsAdvancedSecurity"))_"""")
			w "}"
			s first = 0
		}
	}
	w "],""total"":"_count_"}"
}

/// Debug: d ##Class(DHCEPRRBAC.web.eprajax.ApplyPermission).GetApplyListJSON("2776","F","2015-5-1","2015-5-30",1,20)
ClassMethod GetApplyListJSON(AUserID As %String, AApplyStatus As %String, AApplyStartDate As %String, AApplyEndDate As %String, AIdxStart As %Integer, AIdxLast As %Integer)
{
	s result = ##Class(%ResultSet).%New("DHCEPRRBAC.BL.BLFSAuthorization:GetApplyListByUserID")
	s sc = result.Execute(AUserID,AApplyStatus,AApplyStartDate,AApplyEndDate)
	
	s count = 0
	s first = 1
	w "{""rows"":["
	
	While (result.Next())
	{
		s count = count + 1
		if (count >= AIdxStart) && (count <= AIdxLast)
		{
			if ((count > 1)&&(first '= 1)) w ","
			w "{"
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""AuthorizationID"":"""_$g(result.Data("AuthorizationID"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""RequestUserID"":"""_$g(result.Data("RequestUserID"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""RequestUserName"":"""_$g(result.Data("RequestUserName"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""RequestDeptID"":"""_$g(result.Data("RequestDeptID"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""RequestDept"":"""_$g(result.Data("RequestDept"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""RequestSSGroupID"":"""_$g(result.Data("RequestSSGroupID"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""RequestSSGroup"":"""_$g(result.Data("RequestSSGroup"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""RequestDate"":"""_$g(result.Data("RequestDate"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""RequestTime"":"""_$g(result.Data("RequestTime"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""AppointUserID"":"""_$g(result.Data("AppointUserID"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""AppointUserName"":"""_$g(result.Data("AppointUserName"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""AppointDate"":"""_$g(result.Data("AppointDate"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""AppointTime"":"""_$g(result.Data("AppointTime"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""AppointEndDate"":"""_$g(result.Data("AppointEndDate"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""AppointEndTime"":"""_$g(result.Data("AppointEndTime"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""RoleID"":"""_$g(result.Data("RoleID"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""RoleCode"":"""_$g(result.Data("RoleCode"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""RoleDesc"":"""_$g(result.Data("RoleDesc"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""OperationID"":"""_$g(result.Data("OperationID"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""OperationCode"":"""_$g(result.Data("OperationCode"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""OperationDesc"":"""_$g(result.Data("OperationDesc"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""EPRAction"":"""_$g(result.Data("EPRAction"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""EPRActionDesc"":"""_$g(result.Data("EPRActionDesc"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""AppointType"":"""_$g(result.Data("AppointType"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""AppointStatus"":"""_$g(result.Data("AppointStatus"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""AppointStatusDesc"":"""_$g(result.Data("AppointStatusDesc"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""AppointComment"":"""_$g(result.Data("AppointComment"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""MedRecordNoS"":"""_$g(result.Data("MedRecordNoS"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""HasAdvancedSecurity"":"""_$g(result.Data("HasAdvancedSecurity"))_"""")
			w "}"
			s first = 0
		}
	}
	w "],""total"":"_count_"}"
}

/// Debug: d ##Class(DHCEPRRBAC.web.eprajax.ApplyPermission).GetApplyListDetailJSON("1")
ClassMethod GetApplyListDetailJSON(AAuthorizationID As %String)
{
	s result = ##Class(%ResultSet).%New("DHCEPRRBAC.BL.BLFSAuthorization:GetApplyListDetail")
	s sc = result.Execute(AAuthorizationID)
	
	s count = 0
	s first = 1
	w "{""rows"":["
	
	While (result.Next())
	{
		s count = count + 1
		if ((count > 1)&&(first '= 1)) w ","
		w "{"
		w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""AuthorizationID"":"""_AAuthorizationID_""",")
		w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""AuthorizationDetailID"":"""_$g(result.Data("AuthorizationDetailID"))_""",")
		w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""PAStatusType"":"""_$g(result.Data("PAStatusType"))_""",")
		w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""PAAdmType"":"""_$g(result.Data("PAAdmType"))_""",")
		w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""PAPMIName"":"""_$g(result.Data("PAPMIName"))_""",")
		w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""PAPMIDOB"":"""_$g(result.Data("PAPMIDOB"))_""",")
		w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""PAPMIAge"":"""_$g(result.Data("PAPMIAge"))_""",")
		w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""PAPMISex"":"""_$g(result.Data("PAPMISex"))_""",")
		w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""PAAdmDate"":"""_$g(result.Data("PAAdmDate"))_""",")
		w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""PAAdmTime"":"""_$g(result.Data("PAAdmTime"))_""",")
		w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""PAAdmWard"":"""_$g(result.Data("PAAdmWard"))_""",")
		w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""PAAdmLoc"":"""_$g(result.Data("PAAdmLoc"))_""",")
		w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""PADischgeDate"":"""_$g(result.Data("PADischgeDate"))_""",")
		w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""PADischgeTime"":"""_$g(result.Data("PADischgeTime"))_""",")
		w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""PAAdmDoc"":"""_$g(result.Data("PAAdmDoc"))_""",")
		w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""PayMode"":"""_$g(result.Data("PayMode"))_""",")
		w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""EpisodeID"":"""_$g(result.Data("EpisodeID"))_""",")
		w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""PatientID"":"""_$g(result.Data("PatientID"))_""",")
		w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""MedRecordNo"":"""_$g(result.Data("MedRecordNo"))_""",")
		w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""RegNo"":"""_$g(result.Data("RegNo"))_""",")
		w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""LinkedParam"":"""_$g(result.Data("LinkedParam"))_""",")
		w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""IsAdvancedSecurity"":"""_$g(result.Data("IsAdvancedSecurity"))_"""")
		w "}"
		s first = 0
	}
	w "],""total"":"_count_"}"
}

/// Debug: d ##Class(DHCEPRRBAC.web.eprajax.ApplyPermission).GetEPREpisodeListJSON("^^^^^218^","159","9","134","1","20")
ClassMethod GetEPREpisodeListJSON(AParam As %String, AUserID As %String, AUserLocID As %String, AUserSSGroupID As %String, AIdxStart As %Integer, AIdxLast As %Integer)
{
	s result = ##Class(%ResultSet).%New("DHCEPRRBAC.BL.BLFSAuthorization:GetPatientList")
	s sc = result.Execute(AParam,AUserID,AUserLocID,AUserSSGroupID)
	
	s count = 0
	s first = 1
	w "{""rows"":["
	
	While (result.Next())
	{
		s count = count + 1
		if (count >= AIdxStart) && (count <= AIdxLast)
		{
			if ((count > 1)&&(first '= 1)) w ","
			w "{"
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""PAStatusType"":"""_$g(result.Data("PAStatusType"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""PAAdmType"":"""_$g(result.Data("PAAdmType"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""PAPMIName"":"""_$g(result.Data("PAPMIName"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""PAPMINO"":"""_$g(result.Data("PAPMINO"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""PAPMIDOB"":"""_$g(result.Data("PAPMIDOB"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""PAPMIAge"":"""_$g(result.Data("PAPMIAge"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""PAPMISex"":"""_$g(result.Data("PAPMISex"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""PAAdmDateTime"":"""_$g(result.Data("PAAdmDateTime"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""PAAdmWard"":"""_$g(result.Data("PAAdmWard"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""PAAdmRoom"":"""_$g(result.Data("PAAdmRoom"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""PAAdmBed"":"""_$g(result.Data("PAAdmBed"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""PAAdmLoc"":"""_$g(result.Data("PAAdmLoc"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""PADischgeDateTime"":"""_$g(result.Data("PADischgeDateTime"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""PAAdmDoc"":"""_$g(result.Data("PAAdmDoc"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""PayMode"":"""_$g(result.Data("PayMode"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""EpisodeID"":"""_$g(result.Data("EpisodeID"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""PatientID"":"""_$g(result.Data("PatientID"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""CheckNoNeedApply"":"""_$g(result.Data("CheckNoNeedApply"))_""",")
			w ##class(DHCEPRRBAC.Util.Utilization).TrimEnter("""IsAdvancedSecurity"":"""_$g(result.Data("IsAdvancedSecurity"))_"""")
			w "}"
			s first = 0
		}
	}
	w "],""total"":"_count_"}"
}

}
