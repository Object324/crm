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
	$query = 'select 1 from ld_leads_public';
	$result = $adb->pquery($query,array());
	$num_rows = $adb->num_rows($result);
	if($num_rows >= 1){
		$query = "update ld_leads_public set status = ?,show_publicaccount_tab = ?,default_publicaccount_tab = ?,administrators = ?,show_commonaccount_tab = ?,show_account_rule=?,account_rule_pool_id=?,is_commonaccount_create=?,set_default_tab=?";
	}else{
		$query = "insert into ld_leads_public(status,show_publicaccount_tab,default_publicaccount_tab,administrators,show_commonaccount_tab,show_account_rule,account_rule_pool_id,is_commonaccount_create,set_default_tab) values (?,?,?,?,?,?,?,?,?)";
	}
	$adb->pquery($query,array($status,$show_publicaccount_tab,$default_publicaccount_tab,$select_administrators_id,$show_commonaccount_tab,$show_account_rule,$account_rule_pool_id,$is_commonaccount_create,$set_default_tab));
	
	//自动回收规则设置
	$query="select tabname,type from ld_leads_set_rule where type = 'normal' and pool_id = 1 order by type desc ";
	$result=$adb->pquery($query,array());
	$rows=$adb->num_rows($result);
	if($rows >= 1){
		for($i=0;$i<$rows;$i++){
			$tabname=$adb->query_result($result,$i,'tabname');
			$type='complete';
			$condition=$_REQUEST[$type.'opt'];
			$days=$_REQUEST[$tabname."_".$type."days"];
			$rule_status=$_REQUEST[$tabname."_".$type."chk"];
			if( $rule_status == 'on'){
				$rule_status='active';
			}else{
				$rule_status='inactive';
			}
			$iscycle=$_REQUEST['changerule_'.$type.'_'.$tabname];
			if($iscycle=='no')
			{
				$days=$_REQUEST[$tabname."_single_".$type."days"];
			}
			$query="update ld_leads_set_rule set status=?,days=?,`condition`=?,iscycle=?  where type=? and tabname=? and pool_id = 1";
			$adb->pquery($query,array($rule_status,$days,$condition,$iscycle,'normal',$tabname));
		}
	}
	
	//提醒高级条件设置保存
	$sql="delete from ld_leads_set_advfilter where pool_id = -1"; 
	$adb->pquery($sql,array());
	$sql="delete from ld_leads_set_advfilter_grouping where pool_id = -1"; 
	$adb->pquery($sql,array());
	if(!empty($advft_criteria) && $status == 'yes'){
		$advfilterlist = ldcrm_json_decode($advft_criteria);
		$advfiltergroup=ldcrm_json_decode($advft_criteria_groups);
		$index=1;
        for($i=0;$i<count($advfilterlist);$i++){
			$query="INSERT INTO ld_leads_set_advfilter (groupid,columnindex,columnname,comparator,value,column_condition,pool_id) VALUES(?,?,?,?,?,?,?)"; 
			$groupid= $advfilterlist[$i]['groupid'];
			if($advfilterlist[$i]['columnname']==''){
				continue;
			}
			$params=array(
				$advfilterlist[$i]['groupid'],
				$index++,
				$advfilterlist[$i]['columnname'],
				$advfilterlist[$i]['comparator'],
				$advfilterlist[$i]['value'],
				$advfilterlist[$i]['columncondition'],
				-1
			);
			$adb->pquery($query,$params);
        }

		foreach($advfiltergroup as $groupid=>$groupinfo){
			
			if(empty($groupinfo)) continue;
			//if(empty($groupinfo["conditionexpression"])) continue;
			$sql='insert into ld_leads_set_advfilter_grouping(groupid,group_condition,condition_expression,pool_id)value(?,?,?,?)';
			$adb->pquery($sql,array($groupid,$groupinfo['groupcondition'],$groupid-1,-1));
		}
	}
	//回收公海的时候有用
	$sql="update ld_sys_event set eventdate=? where type='publicleads'";
	$adb->pquery($sql,array('1600-01-01'));

	//公海回收条件sql
	crm_load_class_file("LeadsSetCustomView",'modules/Leads/LeadsSet');

	$AccountSetCustomView=new LeadsSetCustomView(-1);
	

	crm_load_class_file("LeadsSetQueryGenerator",'modules/Leads/LeadsSet');
	if(count($advft_criteria)>0 && $status == 'yes')
	{
		$queryGenerator =new LeadsSetQueryGenerator('Leads', $current_user,$AccountSetCustomView);
		$queryGenerator->initForDefaultCustomView();
		$query= $queryGenerator->getQuery();

		$queryGenerator->getWhereClause();
		$queryGenerator->getFromClause();
	}
	else
	{
		$query='';
	}
	$sql=' update ld_leads_public set recycleselect=?';
	$adb->pquery($sql,array($query));

	//公海相关的5个字段：领取日期allocatedate、保护截止日期protectdate、公海目标completed、所属公海、公海状态publicaccount。启用公海参数时，如果这几个字段没有开启，则自动开启；关闭公海参数时这几个字段自动隐藏。
	if($before_status != $status){
	   $tabid=getTabid("Leads");
       
		if($status == 'yes'){
			$query = "update ld_field set presence = 0 where tabid = $tabid and columnname in  ('allocatedate','protectdate','completed','publicaccount','pool_id')";
		}else{
			$query = "update ld_field set presence = 1 where tabid = $tabid and columnname in  ('allocatedate','protectdate','completed','publicaccount','pool_id')";
		}
		$adb->pquery($query,array());
		unsetCacheDirectory('field');
	}

}

$query = "update ld_leads_public set limit_type=?,limit_count=?";
$adb->pquery($query,array($limit_type,$limit_count));
//普通客户数量上限：按角色控制
if ($limit_type == 'role') {
    if(!empty($txtbox_roleid) && !empty($txtbox_role_count)){
        $query = 'delete from ld_leads_role_limitcount_common';
        $adb->pquery($query,array());
        foreach($txtbox_roleid as $key => $roleid){
            $query = 'insert into ld_leads_role_limitcount_common(roleid,limit_count) values (?,?)';
            $adb->pquery($query,array($roleid,$txtbox_role_count[$key]));
        }
    }
}

$_REQUEST['diony']='diony';
ConvertTojsonString(1,array(),"success");
?>