Class DHCEPRFS.BL.BLCTSystem Extends %RegisteredObject [ ProcedureBlock ]
{

/// Desc: 新增、修改系统
/// Debug: w ##class(DHCEPRFS.BL.BLCTSystem).UpdateCTSystem("","HIS6.9","东华HIS","2023-01-01","test")
ClassMethod UpdateCTSystem(ACTSystemID As %String, ASysCode As %String, ASysName As %String, AStartDate As %String, ANotes As %String) As %String
{
	s:(ACTSystemID = $c(0)) ACTSystemID = ""
	if (ACTSystemID = "")
	{
		s objSys = ##class(DHCEPRFS.META.CTSystem).%New()
	}
	else
	{
		s objSys = ##class(DHCEPRFS.META.CTSystem).%OpenId(ACTSystemID)
		q:('$IsObject(objSys)) "-1"
	}
	s objSys.SysCode = ASysCode
	s objSys.SysName = ASysName
	s:(AStartDate '= "") objSys.StartDate = $zdh(AStartDate,3)
	s objSys.Notes = ANotes
	s objSys.LastModifyDate = $p($h,",",1)
	s objSys.LastModifyTime = $p($h,",",2)
	s sc = objSys.%Save()
	if ($$$ISERR(sc))
	{
		q "0"
	}
	else
	{
		q "1"
	}
}

/// Creator：     grl
/// CreatDate：   2023-03-04
/// Description:  获取系统列表
/// Input：      
/// Debug: d ##class(%ResultSet).RunQuery("DHCEPRFS.BL.BLCTSystem","GetCTSystem")
Query GetCTSystem() As %Query(ROWSPEC = "SysID:%String,SysCode:%String,SysName:%String,StartDate:%String,Notes:%String,LastModifyDate:%String,LastModifyTime:%String")
{
}

ClassMethod GetCTSystemExecute(ByRef qHandle As %Binary) As %Status
{
	Set repid=$I(^CacheTemp)
	Set qHandle=$lb(0,repid,0)
	Set ind=1
	
	s rowID = ""
	f {
		s rowID = $o(^DHCEPRFS.META.CTSystemD(rowID))
		q:(rowID = "")
		s objSys = ##class(DHCEPRFS.META.CTSystem).%OpenId(rowID)
		s sysCode = objSys.SysCode
		s sysName = objSys.SysName
		s startDate = objSys.StartDate
		s:(startDate '= "") startDate = $zd(startDate,3)
		s notes = objSys.Notes
		s lastModifyDate = objSys.LastModifyDate
		s:(lastModifyDate '= "") lastModifyDate = $zd(lastModifyDate,3)
		s lastModifyTime = objSys.LastModifyTime
		s:(lastModifyTime '= "") lastModifyTime = $zt(lastModifyTime,1)
		d objSys.%Close()
		s ^CacheTemp(repid,ind) = $lb(rowID,sysCode,sysName,startDate,notes,lastModifyDate,lastModifyTime)
		s ind = ind + 1
	}
	
	Quit $$$OK
}

ClassMethod GetCTSystemClose(ByRef qHandle As %Binary) As %Status [ PlaceAfter = GetCTSystemExecute ]
{
	Set repid=$LIST(qHandle,2)
	Kill ^CacheTemp(repid)
	Quit $$$OK
}

ClassMethod GetCTSystemFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status [ PlaceAfter = GetCTSystemExecute ]
{
	Set AtEnd=$LIST(qHandle,1)
	Set repid=$LIST(qHandle,2)
	Set ind=$LIST(qHandle,3)
	Set ind=$o(^CacheTemp(repid,ind))
	If ind="" {				// if there are no more rows, finish fetching
		Set AtEnd=1
		Set Row=""
		kill ^CacheTemp(repid)
	}
	Else      {				// fetch row
		Set Row=^CacheTemp(repid,ind)
	}
	// Save QHandle
	s qHandle=$lb(AtEnd,repid,ind)
	Quit $$$OK
}

}
