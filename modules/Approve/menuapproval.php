<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2015-01-22
 */
global $adb,$current_user;
$setype = (isset($_REQUEST['setype']))?$_REQUEST['setype']:1;
switch($setype){
    case '1'://获取审批列表结果集
		$tabid = $_REQUEST['search_tabid'];
		$session_key = 'menuapprovallist'.$current_user->id;
		$sessionidxkey = 'menuapproval_index'.$current_user->id;
        if(!empty($_REQUEST['search_text'])){//搜索
			$search_field = $_REQUEST['search_field'];
			$search_text = Input('search_text');
			$query = getMenuApprovalQuery($tabid);//获取审批历史sql
			$search_array = array(
				'Approval_object'=>'T.subject like "%%%s%%"',//审批对象
				'AccountName'=>'accountname like "%%%s%%"',//客户名单
				'COMPANYNAME'=>'accountname like "%%%s%%"',//客户名单
				'DocumentNumber'=>'T.num like "%%%s%%"',//单据编号
				'Related_modules'=>'T.modulename like "%%%s%%"',//相关模块
				'Approval_Process'=>'ld_approve.name like "%%%s%%"',//审批流程
				'APPROVALSTEP'=>'ld_approvestep.name like "%%%s%%"',//审批步骤
                'ASSIGNEDTO'=>'T5.last_name like "%%%s%%"',//负责人
                'Sponsor'=>'sponsoruser.last_name like "%%%s%%"',//发起人
				'APPROVER'=>array('sql'=>'(find_in_set("%d",nextstepapproveby) or find_in_set("%s",nextstepapproveby))')//审批人
			);
			if(!is_array($search_array[$search_field])){//组装where条件
				$searchquery = sprintf($search_array[$search_field],$search_text);
			}else{//approveby审批人查询
				$userinfo = getUserCacheNameInfo();
				$searchuserid = 0;$searchsmowner = array();
				foreach($userinfo as $userid=>$user){//整体匹配以及模糊匹配
					if($search_text == $user['username'] || $search_text == $user['lastname']){
						$searchuserid = $userid;
					}else if(stripos($user['username'],$search_text) > -1 || stripos($user['lastname'],$search_text) > -1){
						$searchsmowner[] = $userid;//模糊匹配查询多个
					}
				}
				if(0 == $searchuserid && !empty($searchsmowner)){
					$searchquery = '(';
					foreach($searchsmowner as $searchsmownerid){
						$searchroleid = $current_user->profileid;
						$searchquery .= sprintf($search_array[$search_field]['sql'],$searchsmownerid,$searchroleid).' or';
					}
					$searchquery = trim($searchquery,' or');
					$searchquery .= ')';
					$searchuserid = $searchsmowner;
				}else if($searchuserid > 0){
					$searchroleid = $current_user->profileid;
					$searchquery = sprintf($search_array[$search_field]['sql'],$searchuserid,$searchroleid);
				}else{
					$searchquery = sprintf($search_array[$search_field]['sql'],0,0);
				}
			}
			if(!empty($searchquery)){
				$query .= ' and ('.$searchquery.') ';
			}
			$query .= ' order by ld_approvelog.createdtime ';

            $result = $adb->pquery($query,array($tabid,$current_user->id,$current_user->profileid));
			$rows = $adb->num_rows($result);
            
			$approveobj = array();
			if(isset($_SESSION[$session_key]) && !empty($_SESSION[$session_key])){//取出session中的数据
				$approveobj = $_SESSION[$session_key];
			}
			if($rows > 0){
				$session_idx = array();
				if(isset($_SESSION[$sessionidxkey]) && !empty($_SESSION[$sessionidxkey])){
					$session_idx = $_SESSION[$sessionidxkey];
				}
				$time = date('Y-m-d H:i:s',time());
                
				for($i=0;$i<$rows;++ $i){
				    $crmid = $adb->query_result($result,$i,'crmid');
					if(!empty($session_idx) && isset($session_idx[$crmid])){
						continue;
					}
					$session_idx[$crmid] = $time;
					$subject = $adb->query_result($result,$i,'subject');//审批对象
					$accountname = $adb->query_result($result,$i,'accountname');//客户名
					$num = $adb->query_result($result,$i,'num');//编号
					$approvename = $adb->query_result($result,$i,'approvename');
					$nextstepname = $adb->query_result($result,$i,'nextstepname');
					$nextstepapproveby=$adb->query_result($result,$i,'approved_by');
					$smownername = $adb->query_result($result,$i,'smownername');
					$createdtime = $adb->query_result($result,$i,'createdtime');
					if(substr($nextstepapproveby,0,1) == 'H'){//下一步为角色
						$nextstepapproveby = getUserIdRole($nextstepapproveby);
					}else{
						$nextstepapproveby = explode(',',$nextstepapproveby);
					}
					$nextstepby = '';
					foreach($nextstepapproveby as $nextby){
						$nextstepby .=getUserFullName($nextby).",";
					}
					$approveby=mb_substr($nextstepby,0,strlen($nextstepby)-1,$default_charset);
					$approveby = trim($approveby,',');
					
					$approveobj[$time][$crmid]['subject'] = $subject;
					$approveobj[$time][$crmid]['accountname'] = $accountname;
					$approveobj[$time][$crmid]['num'] = $num;
					$approveobj[$time][$crmid]['approvename'] = $approvename;
					$approveobj[$time][$crmid]['stepname'] = $nextstepname;
					$approveobj[$time][$crmid]['approveby'] = trim($nextstepby,',');
					$approveobj[$time][$crmid]['smawnername'] = $smownername;
					$approveobj[$time][$crmid]['createdtime'] = $createdtime;
					$approveobj[$time][$crmid]['tabid'] = $tabid;
					$approveobj[$time][$crmid]['tabname'] = getTranstab(getTabname($tabid));
				}
				$_SESSION[$session_key] = $approveobj;
				$_SESSION[$sessionidxkey] = $session_idx;
			}
           
			if(!empty($approveobj)){
				krsort($approveobj);//用时间逆序排序，确保新搜索的单据在最上面
				
				$json = new Zend_Json();
				$jsonentity = $json->encode($approveobj);
				echo $jsonentity;die;
			}else{
				echo '';die;
			}
		}elseif(isset($_SESSION[$session_key]) && !empty($_SESSION[$session_key])){
			$approveobj = $_SESSION[$session_key];
			krsort($approveobj);
			
			$json = new Zend_Json();
			$jsonentity = $json->encode($approveobj);
			echo $jsonentity;die;
		}else{//没有数据
			unset($_SESSION[$sessionidxkey]);//防止影响下一次搜索
		}
        break;
    case '2'://移除
        $selectid = trim($_REQUEST['selectid'],',');
		if(!empty($selectid)){
			$session_key = 'menuapprovallist'.$current_user->id;
			$sessionidxkey = 'menuapproval_index'.$current_user->id;
			$session_idx = $_SESSION[$sessionidxkey];
			$approveobj = $_SESSION[$session_key];
			$selectobj = explode(',',$selectid);
			foreach($selectobj as $crmid){//循环crmid
				if(isset($session_idx[$crmid]) && !empty($session_idx[$crmid])){
					$time = $session_idx[$crmid];//获取crmid对应的时间
					if(isset($approveobj[$time][$crmid]) && !empty($approveobj[$time][$crmid])){
						unset($approveobj[$time][$crmid]);//清除session
						unset($session_idx[$crmid]);
					}
				}
			}
			$_SESSION[$session_key] = $approveobj;
			$_SESSION[$sessionidxkey] = $session_idx;
		}
        break;
	case '3'://获取用户信息以及对应模块的审批流程
		$select_tabid = $_REQUEST['select_tabid'];
		$selectid = $_REQUEST['selectid'];
	
		$approve = new Approve();
		$approveobj = $approve->submitApprove($select_tabid);
		if(!empty($approveobj)){
			$users_combo = getAllUserArrayInfo();
			$entity = array();
			$entity['user'] = $users_combo;
			$entity['approve'] = $approveobj;
			
			$json = new Zend_Json();
			$jsonentity = $json->encode($entity);
			echo $jsonentity;die;
		}else{
			echo '###APPROVE###';
		}
	    break;
	case '4'://获取审批流程对应的审批步骤信息
	    $approveid = $_REQUEST['approveid'];
		$query = 'select id,name,approvevalue from ld_approvestep where approveid=? order by sequence;';
		$result = $adb->pquery($query,array($approveid));
		$rows = $adb->num_rows($result);
		$steparr = array();
		if($rows > 0){
			for($i=0;$i<$rows;++ $i){
			    $stepid = $adb->query_result($result,$i,'id');
				$steparr[$stepid]['stepname'] = $adb->query_result($result,$i,'name');
				$steparr[$stepid]['stepby'] = $adb->query_result($result,$i,'approvevalue');
			}
		}
		if(!empty($steparr)){
			
			$json = new Zend_Json();
			$jsonentity = $json->encode($steparr);
			echo $jsonentity;die;
		}else{
			echo '';die;
		}
	    break;
	case '5'://批量审批
	
		$approve = new Approve();
		$approveid = $_REQUEST['approveid'];
		$descri = $_REQUEST['descri'];
	    $menutype = $_REQUEST['menutype'];
		$selectid = trim($_REQUEST['selectid'],',');
		$selectarr = explode(',',$selectid);
		$select_tabid = $_REQUEST['select_tabid'];
		$fld_module = getTabname($select_tabid);
		$approvelog = array();
		//获取选中crmid对应的当前审批步骤
		$query = 'SELECT crmid,nextstepid FROM (
				SELECT crmid,nextstepid 
				FROM ld_approvelog WHERE crmid IN ('.$selectid.') ORDER BY createdtime DESC
			) AS applog GROUP BY applog.crmid;';
		$result = $adb->pquery($query,array());
		$rows = $adb->num_rows($result);
		$modulestep = array();
		if($rows > 0){
			for($i=0;$i<$rows;++ $i){
			    $crmid = $adb->query_result($result,$i,'crmid');
				$nextstepid = $adb->query_result($result,$i,'nextstepid');
				$modulestep[$crmid] = $nextstepid;//方便用id直接获取对应的审批步骤
			}
		}
		if($menutype > 0){//直接审批成功、审批失败
			if(1 == $menutype){//审批成功
				foreach($selectarr as $recordid){
					$approvelog['crmid'] = $recordid;//数据ID
					$approvelog['approveid'] = $approveid;//所选择审批流程ID
					$approvelog['stepid'] = $modulestep[$recordid];//当前审批步骤ID
					$approvelog['approved_by'] = $current_user->id;//当前审批人
					$approvelog['approveresult'] = 2;//审批成功，结束流程
					$approvelog['description'] = $descri;//备注
					$approve->SaveApprovedLog($fld_module,$approvelog);
				}
			}else{//审批失败
				foreach($selectarr as $recordid){
					$approvelog['crmid'] = $recordid;//数据ID
					$approvelog['approveid'] = $approveid;//所选择审批流程ID
					$approvelog['stepid'] = $modulestep[$recordid];//当前审批步骤ID
					$approvelog['approved_by'] = $current_user->id;//当前审批人
					$approvelog['approveresult'] = 3;//审批失败，结束流程
					$approvelog['description'] = $descri;//备注
					$approve->SaveApprovedLog($fld_module,$approvelog);
				}
			}
		}else{//指定审批步骤、审批人
			$stepid = $_REQUEST['stepid'];
			$userid = $_REQUEST['userid'];
			foreach($selectarr as $recordid){
				$approvelog['crmid'] = $recordid;//数据ID
				$approvelog['approveid'] = $approveid;//当前审批步骤ID
				$approvelog['stepid'] = $modulestep[$recordid];//当前审批流程ID
				$approvelog['approved_by'] = $current_user->id;//当前审批人
				$approvelog['approveresult'] = 1;//当前审批类型（审批中）
				$approvelog['description'] = $descri;//备注
				$approvelog['nextstepid'] = $stepid;//所制定审批步骤ID
				$approvelog['nextstepapproveby'] = $userid;//所指定审批人(单个用户)
				$approve->SaveApprovedLog($fld_module,$approvelog);
			}
		}
	    break;
}

/**
 * 根据传入的tabid值，组装审批query
 * @param Integer $tabid 模块对应的tabid
 * @return 回传审批query
 * @author Tujt 2015-01-22
 */
function getMenuApprovalQuery($tabid) {
    global $adb;
	  $module = getTabname($tabid);
    $approve=Approve::getInstance($module);
    $approvemodules=$approve->getApproveModuleInfo();
    
    foreach($approvemodules as $approvemodulename)
    {
        $approvesetype[]="'".$approvemodulename."'";
    }
    $approvesetype=implode(",",$approvesetype);
  
    $focus=CRMEntity::getInstance($module);
    $tablename=$focus->table_name;
    $tableindex=$focus->table_index;
    $account_field=$focus->fieldobj->getFieldInfoobjBykey('uitype',73);
    $vendor_field=$focus->fieldobj->getFieldInfoobjBykey('uitype',81);
    $module_no_field=$focus->fieldobj->getFieldInfoobjBykey('uitype',4);//模块编号字段
    $entitynames=getEntitynameByModulename($module);
    $fieldname=$entitynames['fieldname'];
    $fieldtablename=$entitynames['tablename'];
    //19922: 审批中心--已处理页签：【发起人】字段值取值没有取单据提交审批人，现在取的是上一步审批人
    $smownercolumnname=$focus->getSmownerColumName();
    $smowner_field=$focus->fieldobj->getFieldInfoobjBykey("columnname",$smownercolumnname);
    $smowertablename=$smowner_field->getTableName();
    if($module=='Accounts'||$module=='ServiceCharge')//
    {
        $sql='select '. $smowertablename.'.'.$smownercolumnname .' as smownerid ,' . $fieldname .' as subject,
                    ld_account.accountid as crmid,
                    ld_account.accountid,
                    accountname,
                    \'%s\' AS modulename,
                    account_no as num
                    from ld_account ';
    }
    else if($module=='Vendors')
    {
        $sql='select ' . $smowertablename.'.'.$smownercolumnname . ' as smownerid ,'. $fieldname .' as subject,
                    ld_vendor.vendorid as crmid,
                    ld_vendor.vendorid,
                    vendorname,
                    \'%s\' AS modulename,
                    vendor_no as num
                    from ld_vendor ';
    }
    else if($account_field&&$account_field->getColumnName()!='')//有客户的模块
    {
      
        $sql='SELECT ' . $smowertablename.'.'.$smownercolumnname .' as smownerid ,'.$fieldtablename.'.'.$fieldname.' AS SUBJECT,';
		$sql.=" $tablename.$tableindex AS crmid,";
        if($module_no_field)
		  $sql=$sql.$module_no_field->getColumnName().'	 AS num,';
        else
            $sql.=' \'\'	 AS num,';
		$sql.='\'%s\' AS modulename,
				ld_account.accountid,
				accountname
			FROM ';
		$sql.=" $tablename
			INNER JOIN ld_approvelog ON ld_approvelog.crmid = $tablename.$tableindex
			LEFT JOIN ld_account ON ld_account.accountid = $tablename. ".$account_field->getColumnName();
		
    }
    else if($vendor_field&&$vendor_field->getColumnName()!='')
    {
   	    $sql='SELECT ' . $smowertablename.'.'.$smownercolumnname . '  as smownerid ,'.$fieldtablename.'.'.$fieldname .' AS SUBJECT,';
		$sql.=" $tablename.$tableindex AS crmid,";
        if($module_no_field)
		  $sql.=$module_no_field->getcolumnName().'	 AS num,';
        else
            $sql.=' \'\' AS num,';
		$sql.='\'%s\' AS modulename,
				ld_vendor.vendorid as accountid,
				vendorname as accountname
			FROM ';
		$sql.=" $tablename
			INNER JOIN ld_approvelog ON ld_approvelog.crmid = $tablename.$tableindex
			LEFT JOIN ld_vendor ON ld_vendor.vendorid = $tablename.".$vendor_field->getColumnName();
    }
    else
    {
        $sql='SELECT ' . $smowertablename.'.'.$smownercolumnname . ' as smownerid ,'.$fieldtablename.'.'.$fieldname .' AS SUBJECT,';
		$sql.=" $tablename.$tableindex AS crmid,";
        if($module_no_field)
		  $sql.=$module_no_field->getcolumnName().'	 AS num,';
        else
            $sql.=' \'\' AS num,';
		$sql.='\'%s\' AS modulename,
				\'0\' as accountid,
				\'\' as accountname
			FROM ';
		$sql.=" $tablename
			INNER JOIN ld_approvelog ON ld_approvelog.crmid = $tablename.$tableindex ";
    }
    if($fieldtablename!=$tablename)
    {
        $sql.=' left join '.$fieldtablename.' on '.$fieldtablename.'.'.$focus->tab_name_index[$fieldtablename].'='.$tablename.'.'.$tableindex;
    }
    $sql.=" WHERE
				$tablename.deleted = 0
			AND $tablename.$tableindex > 0";
            
	$query = 'SELECT DISTINCT ld_approvelog.stepid,accountid,accountname,
            ld_approvelog.crmid,ld_approvelog.approveid, T.subject,T.num,T.modulename,
            ld_approve.name as approvename,ld_approvestep.name as nextstepname,nextstep.name as stepname,
            ld_approvelog.nextstepapproveby,ld_approvelog.nextstepid, ld_approvelog.approveresult,
            ld_approvelog.approved_by,T5.last_name as smownername,ld_approvelog.createdtime FROM ld_approvelog 
				left JOIN ld_approve
					ON ld_approve.`id` = ld_approvelog.`approveid` 
				left JOIN ld_approvestep 
					ON ld_approvestep.`id` = ld_approvelog.nextstepid
				left JOIN ld_approvestep AS nextstep 
					ON nextstep.`id` = ld_approvelog.`stepid` ';

	$approvesql = 'SELECT MAX(ld_approvelog.id) AS idd,ld_approvelog.crmid,setype,approveid FROM ld_approvelog 
                        INNER JOIN ld_crmentity ON ld_crmentity.crmid=ld_approvelog.crmid 
     WHERE ld_approvelog.id > 0 AND  setype in ( '.$approvesetype.' ) GROUP BY ld_approvelog.crmid ';
	$query .= 'INNER JOIN ('.$approvesql.') AS TT ON ld_approvelog.id=TT.idd ';
 
	$sql = sprintf($sql,getTranstab($module));
    
	$query .= ' INNER JOIN ('.$sql.') as T on T.crmid = ld_approvelog.crmid ';
    $query .= ' left join ld_users as T5 on T5.id=T.smownerid ';
    $query .= 'LEFT JOIN ld_users AS sponsoruser ON ld_approvelog.approved_by = sponsoruser.id ';
	$query .= 'WHERE ld_approve.`tabid` = ? AND approveresult = 1
			AND (
				FIND_IN_SET(?, ld_approvelog.nextstepapproveby)
				OR FIND_IN_SET(?, ld_approvelog.nextstepapproveby)
			) AND ld_approvelog.id > 0 ';
 
	return $query;
}
/**
 * 获取所有用户数据
 * @author Tujt 2015-01-23
 */
function getAllUserArrayInfo() {
    global $adb,$current_user;
	$assigned_user_id = $current_user->id;
	$users_combo = get_user_array(FALSE, "Active", $assigned_user_id);
	return $users_combo;
}
?>