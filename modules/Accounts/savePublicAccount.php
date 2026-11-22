<?php
/**
* edit: chj
* reason: 公海参数设置 - 保存
* date: 2020/11/27
**/

global $adb,$theme;
global $current_user,$list_max_entries_per_page_new;
$smarty=new lingdangCRM_Smarty();
$limit_type = $_REQUEST['limit_type'];	//普通客户数量上限 类型
$limit_count = $_REQUEST['limit_count'];	// 普通客户数量上限：按成员控制，每成员
$txtbox_role_count = $_REQUEST['txtbox_role_count'];	//普通客户数量上限：按角色控制
$txtbox_roleid = $_REQUEST['txtbox_roleid'];

$status = $_REQUEST['status'];	//启用公海
$before_status = $_REQUEST['before_status'];	//编辑修改前的公海状态
$show_publicaccount_tab = $_REQUEST['show_publicaccount_tab'];	//显示 “全部（含所有公海）”页签 
$default_publicaccount_tab = $_REQUEST['default_publicaccount_tab'];	//默认 “全部（含所有公海）”页签 
$show_commonaccount_tab = $_REQUEST['show_commonaccount_tab'];	//显示 “全部（普通客户）”页签
$is_commonaccount_create = $_REQUEST['is_commonaccount_create'];	//允许创建普通客户
$set_default_tab = $_REQUEST['set_default_tab'];	//设置默认页签
$select_administrators_id = $_REQUEST['select_administrators_id'];	//公海超级管理员
$account_rule_pool_id = $_REQUEST['select_pool_id'];	//启用普通客户自动回收规则，自动回收到公海池
$show_account_rule = $_REQUEST['account_rule'];	//启用普通客户自动回收规则
$advft_criteria = $_REQUEST['advft_criteria'];	//自动回收规则数据分类设置
$advft_criteria_groups = $_REQUEST['advft_criteria_groups'];
if($status == 'on'){
	$status = 'yes';
}else{
	$status = 'no';
	$select_administrators_id = '';
	$show_commonaccount_tab = 'no';
}
if($show_publicaccount_tab == 'on'){
	$show_publicaccount_tab = 'yes';
}else{
	$show_publicaccount_tab = 'no';
}
if($default_publicaccount_tab == 'on'){
	$default_publicaccount_tab = 'yes';
}else{
	$default_publicaccount_tab = 'no';
}
if($show_commonaccount_tab == 'on'){
	$show_commonaccount_tab = 'yes';
}else{
	$show_commonaccount_tab = 'no';
}
if($is_commonaccount_create == 'on'){
	$is_commonaccount_create = 'yes';
}else{
	$is_commonaccount_create = 'no';
}
if($show_account_rule == 'on'){
	$show_account_rule = 'yes';
}else{
	$show_account_rule = 'no';
}
if(!empty($status)){
	if(empty($account_rule_pool_id)){
		$account_rule_pool_id = 0;
	}
	$query = 'select 1 from ld_account_public';
	$result = $adb->pquery($query,array());
	$num_rows = $adb->num_rows($result);
	if($num_rows >= 1){
		$query = "update ld_account_public set status = ?,show_publicaccount_tab = ?,default_publicaccount_tab = ?,administrators = ?,show_commonaccount_tab = ?,show_account_rule=?,account_rule_pool_id=?,is_commonaccount_create=?,set_default_tab=?";
	}else{
		$query = "insert into ld_account_public(status,show_publicaccount_tab,default_publicaccount_tab,administrators,show_commonaccount_tab,show_account_rule,account_rule_pool_id,is_commonaccount_create,set_default_tab) values (?,?,?,?,?,?,?,?,?)";
	}
	$adb->pquery($query,array($status,$show_publicaccount_tab,$default_publicaccount_tab,$select_administrators_id,$show_commonaccount_tab,$show_account_rule,$account_rule_pool_id,$is_commonaccount_create,$set_default_tab));
	if($show_account_rule == 'yes'){
		$normal_json = json_decode($_REQUEST['normal_json']);
		$adb->pquery("truncate ld_account_normal",array());
		$adb->pquery("truncate ld_account_set_rule_normal",array());
		foreach($normal_json as $json){
			$row_arr = json_decode($json);
			//$row_arr[0] $row_arr[1] 回收条件   $row_arr[2] 回收规则  $row_arr[3] 回收公海池  $row_arr[4] 规则描述
			$recycleselect = '';
			//公海回收条件sql
			if(!empty($row_arr[0]) && !empty($row_arr[1])){
				crm_load_class_file("AccountNormalSetCustomView",'modules/Accounts/AccountSet');
				crm_load_class_file("AccountNormalSetProductDetails",'modules/Accounts/AccountSet');
				$AccountSetCustomView=new AccountNormalSetCustomView('Accounts',$row_arr[0],$row_arr[1]);
				$AccountSetProductDetails=new AccountNormalSetProductDetails('Accounts',$row_arr[0],$row_arr[1]);
				crm_load_class_file("AccountsQueryGenerator",'include/QueryGenerator');
				crm_load_class_file("AccountsSetQueryGenerator",'modules/Accounts/AccountSet');
				if(count(ldcrm_json_decode($row_arr[0]))>0 && $status == 'yes')
				{
					$queryGenerator =new AccountsSetQueryGenerator('Accounts', $current_user,$AccountSetCustomView,$AccountSetProductDetails);
					$queryGenerator->initForDefaultCustomView();
					$recycleselect= $queryGenerator->getQuery();
					$queryGenerator->getWhereClause();
					$queryGenerator->getFromClause();
				}
			}
			
			$insert = "insert into ld_account_normal(description,recycleselect,pool_id,advfilter,advfilter_grouping) values (?,?,?,?,?)";
			$adb->pquery($insert,array($row_arr[4],$recycleselect,$row_arr[3],$row_arr[0],$row_arr[1]));
			$normal_id = $adb->getLastInsertID();
			$rule_array = ldcrm_json_decode($row_arr[2]);
			foreach($rule_array as $rule_str){
				$arr = explode('_',$rule_str);
				//$arr[0] checkbox  $arr[1] 回收规则（单次/循环） $arr[2] 天数  $arr[3] 回收规则条件  $arr[4] 模块
				$otherwhere = '';
				$sequence = 1;
				switch($arr[4]){
					case 'ContactRecords':
					   $labelbol = 'ALLOCATEORGETSTARTNOCREATECONTACTRECORDSCREATE/Days';
					   $singlelabelbol = 'ALLOCATEORCREATETIMESTART/NOTCREATECONTACTRECORDS';
					   break;
					case 'Potentials':
					   $labelbol = 'ALLOCATEORGETSTARTNOCREATEPOTENTIALSCREATE/Days';
					   $singlelabelbol = 'ALLOCATEORCREATETIMESTART/NOTCREATEPOTENTIALS';
					   break;
					case 'SalesOrder':
					   $labelbol = 'ALLOCATEORGETSTARTNOCREATESALESORDERCREATE/Days';
					   $singlelabelbol = 'ALLOCATEORCREATETIMESTART/NOTCREATESALESORDER';
					   $otherwhere = ' and ifnull(ld_salesorder.sostatus,"")<>"已作废" ';
					   break;
					case 'ServiceContracts':
					   $labelbol = 'ALLOCATEORGETSTARTNOCREATESERVICECONTRACTSCREATE/Days';
					   $singlelabelbol = 'ALLOCATEORCREATETIMESTART/NOTCREATESERVICECONTRACTS';
					   $otherwhere = ' and ifnull(ld_servicecontracts.contract_status,"")<>"已作废" ';
					   break;
					case 'CashBill':
					   $labelbol = 'ALLOCATEORGETSTARTNOCREATECASHBILLCREATE/Days';
					   $singlelabelbol = 'ALLOCATEORCREATETIMESTART/NOTCREATECASHBILL';
					   break;
					case 'Singin':
					   $labelbol = 'ALLOCATEORGETSTARTNOCREATESINGINCREATE/Days';
					   $singlelabelbol = 'ALLOCATEORCREATETIMESTART/NOTCREATESINGIN';
					   break;
					case 'OutboundOrder':
					   $labelbol = 'ALLOCATEORGETSTARTNOCREATEOUTBOUNDORDERCREATE/Days';
					   $singlelabelbol = 'ALLOCATEORCREATETIMESTART/NOTCREATEOutboundOrder';
					   break;
				}
				$columnname = 'createdtime';
				$insert = "insert into ld_account_set_rule_normal(normal_id,tabname,`condition`,labelbol,sequence,days,`status`,columnname,otherwhere,iscycle,singlelabelbol) values (?,?,?,?,?,?,?,?,?,?,?)";
				$adb->pquery($insert,array($normal_id,$arr[4],$arr[3],$labelbol,$sequence,$arr[2],$arr[0],$columnname,$otherwhere,$arr[1],$singlelabelbol));
				$sequence++;
			}
		}
	}

	//公海相关的5个字段：领取日期allocatedate、保护截止日期protectdate、公海目标completed、所属公海、公海状态publicaccount。启用公海参数时，如果这几个字段没有开启，则自动开启；关闭公海参数时这几个字段自动隐藏。
	if($before_status != $status){
		if($status == 'yes'){
			$query = "update ld_field set presence = 0 where tabid = 6 and columnname in  ('allocatedate','protectdate','completed','publicaccount','pool_id')";
		}else{
			$query = "update ld_field set presence = 1 where tabid = 6 and columnname in  ('allocatedate','protectdate','completed','publicaccount','pool_id')";
		}
		$adb->pquery($query,array());
		unsetCacheDirectory('field');
	}

}

$query = "update ld_account_public set limit_type=?,limit_count=?";
$adb->pquery($query,array($limit_type,$limit_count));
//普通客户数量上限：按角色控制
if ($limit_type == 'role') {
    if(!empty($txtbox_roleid) && !empty($txtbox_role_count)){
        $query = 'delete from ld_account_role_limitcount_common';
        $adb->pquery($query,array());
        foreach($txtbox_roleid as $key => $roleid){
            $query = 'insert into ld_account_role_limitcount_common(roleid,limit_count) values (?,?)';
            $adb->pquery($query,array($roleid,$txtbox_role_count[$key]));
        }
    }
}

$_REQUEST['diony']='diony';
ConvertTojsonString(1,array(),"success");
?>