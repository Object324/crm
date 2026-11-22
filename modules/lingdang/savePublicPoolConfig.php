<?php
/**
* edit: chj
* reason: 公海参数设置 - 保存
* date: 2020/11/27
**/

//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();

global $adb,$theme;
global $current_user,$list_max_entries_per_page_new,$currentModule;
$smarty=new lingdangCRM_Smarty();
$base_poolinfo = $_REQUEST['base_poolinfo'];
$public_limit_info = $_REQUEST['public_limit_info'];
$limit_info = $_REQUEST['limit_info'];

$public_limit_type = $public_limit_info['public_limit_type'];	//公海客户数量上限 类型
$public_limit_count = $public_limit_info['public_limit_count'];	// 公海客户数量上限：按成员控制，每成员
$limit_type = $limit_info['limit_type'];	//普通客户数量上限 类型
$limit_count = $limit_info['limit_count'];	// 普通客户数量上限：按成员控制，每成员


$status = $base_poolinfo['status'];	//启用公海
$before_status = $base_poolinfo['before_status'];	//编辑修改前的公海状态
$show_publicaccount_tab = $base_poolinfo['show_publicaccount_tab'];	//显示 “全部（含所有公海）”页签
$default_publicaccount_tab = $base_poolinfo['default_publicaccount_tab'];	//默认 “全部（含所有公海）”页签
$show_commonaccount_tab = $base_poolinfo['show_commonaccount_tab'];	//显示 “全部（普通客户）”页签
$is_commonaccount_create = $base_poolinfo['is_commonaccount_create'];	//允许创建普通客户
$set_default_tab = $base_poolinfo['set_default_tab'];	//设置默认页签
$select_administrators_id = $base_poolinfo['administrators'];	//公海超级管理员
$show_account_rule = $base_poolinfo['show_account_rule'];	//启用普通客户自动回收规则
$showpublicmodule = $base_poolinfo['showpublicmodule'];
//更新公海设置基本信息
$module = $currentModule;
$tabid = getTabid($module);
if($module == 'Accounts'){
    $public_table = 'ld_account_public';
    $normal_table = 'ld_account_normal';
    $normal_rule_table = 'ld_account_set_rule_normal';
    $role_limit_table = 'ld_account_role_limitcount';
    $role_limit_common_table = 'ld_account_role_limitcount_common';
    $public_pool_table = 'ld_account_public_pool';
}else{
    $public_table = 'ld_leads_public';
    $normal_table = 'ld_leads_normal';
    $normal_rule_table = 'ld_leads_set_rule';
    $role_limit_table = 'ld_leads_role_limitcount';
    $role_limit_common_table = 'ld_leads_role_limitcount_common';
    $public_pool_table = 'ld_leads_public_pool';
}

if(!empty($status)){
	if(empty($account_rule_pool_id)){
		$account_rule_pool_id = 0;
	}
	$query = 'select 1 from '.$public_table;
	$result = $adb->pquery($query,array());
	$num_rows = $adb->num_rows($result);
	if($num_rows >= 1){
		$query = "update ".$public_table." set status = ?,show_publicaccount_tab = ?,default_publicaccount_tab = ?,administrators = ?,show_commonaccount_tab = ?,show_account_rule=?,account_rule_pool_id=?,is_commonaccount_create=?,set_default_tab=?,showpublicmodule=?";
	}else{
		$query = "insert into ".$public_table."(status,show_publicaccount_tab,default_publicaccount_tab,administrators,show_commonaccount_tab,show_account_rule,account_rule_pool_id,is_commonaccount_create,set_default_tab,showpublicmodule) values (?,?,?,?,?,?,?,?,?,?)";
	}
	$adb->pquery($query,array($status,$show_publicaccount_tab,$default_publicaccount_tab,$select_administrators_id,$show_commonaccount_tab,$show_account_rule,$account_rule_pool_id,$is_commonaccount_create,$set_default_tab,$showpublicmodule));
	if($show_account_rule == 'yes'){
		$common_recovey_rule = $_REQUEST['common_recovey_rule'];
		$update_sql = 'UPDATE '.$normal_table.' set active = ?,sequence = ? where id=?';
		$saveid_arr = [];
		foreach ($common_recovey_rule as $key => $tmp_info){
            $saveid_arr[] = $tmp_info['programmeid'];
		    $adb->pquery($update_sql,[$tmp_info['active'],($key+1),$tmp_info['programmeid']]);
        }
        if(is_array($saveid_arr) && count($saveid_arr)>0){
            $saveid_str = implode(',',$saveid_arr);
        }else{
            $saveid_str = -1;
        }
        if($module == 'Accounts'){
            $delete_sql = 'delete from ld_account_set_rule_normal where normal_id not in ('.$saveid_str.')';
        }else{
            $delete_sql = 'delete from ld_leads_set_rule where programmeid not in ('.$saveid_str.') and type = \'normal\' ';
        }

        $adb->query($delete_sql);
        $delete_sql = 'delete from '.$normal_table.' where id not in ('.$saveid_str.')';
        $adb->query($delete_sql);
	}

	//公海相关的5个字段：领取日期allocatedate、保护截止日期protectdate、公海目标completed、所属公海、公海状态publicaccount。启用公海参数时，如果这几个字段没有开启，则自动开启；关闭公海参数时这几个字段自动隐藏。
	if($before_status != $status){
		if($status == 'yes'){
			$query = "update ld_field set presence = 0 where tabid = ? and columnname in  ('allocatedate','protectdate','protectstartdate','completed','publicaccount','pool_id')";
		}else{
			$query = "update ld_field set presence = 1 where tabid = ? and columnname in  ('allocatedate','protectdate','protectstartdate','completed','publicaccount','pool_id')";
		}
		$adb->pquery($query,array($tabid));
		unsetCacheDirectory('field');
	}

}

$query = "update ".$public_table." set limit_type=?,limit_count=?,public_limit_type=?,public_limit_count=?";
$adb->pquery($query,array($limit_type,$limit_count,$public_limit_type,$public_limit_count));
//普通客户数量上限：按角色控制
if ($limit_type == 'role') {
    $role_limit_count_info = $_REQUEST['role_limit_count_info'];
    $query = 'delete from '.$role_limit_common_table;
    $adb->pquery($query,array());
    if(is_array($role_limit_count_info)){
        foreach($role_limit_count_info as $key => $tmp_info){
            $query = 'insert into '.$role_limit_common_table.'(roleid,limit_count) values (?,?)';
            $adb->pquery($query,array($tmp_info['profileid'],$tmp_info['limit_count']));
        }
    }
}
if ($public_limit_type == 'role') {
    $tmp_pool_id = -1;
    $role_public_limit_count_info = $_REQUEST['role_public_limit_count_info'];
    $query = 'delete from '.$role_limit_table.' where pool_id = ?';
    $adb->pquery($query,array($tmp_pool_id));
    if(is_array($role_public_limit_count_info)){
        foreach($role_public_limit_count_info as $key => $tmp_info){
            $query = 'insert into '.$role_limit_table.'(pool_id,roleid,limit_count) values (?,?,?)';
            $adb->pquery($query,array($tmp_pool_id,$tmp_info['profileid'],$tmp_info['limit_count']));
        }
    }
}

//更新列表页签信息
$list_tab_info = $_REQUEST['list_tab_info'];
$update_sql = 'UPDATE ld_module_list_tab set zhlabel = ?,enlabel = ?,description = ?,active = ?,isdefault = ?,sequence = ? where id=?';
foreach ($list_tab_info as $key => $tmp_info){
    $adb->pquery($update_sql,[$tmp_info['zhlabel'],$tmp_info['enlabel'],$tmp_info['description'],$tmp_info['active'],$tmp_info['isdefault'],($key+1),$tmp_info['id']]);
}
//更新公海池信息
$public_pool_info = $_REQUEST['public_pool_info'];
$update_sql = 'UPDATE '.$public_pool_table.' set active = ?,default_pool = ?,sequence = ? where id=?';
foreach ($public_pool_info as $key => $tmp_info){
    $adb->pquery($update_sql,[$tmp_info['active'],$tmp_info['default_pool'],($key+1),$tmp_info['id']]);
}
if($module == 'Accounts'){
    unsetCache('public_account_pool');
}else{
    unsetCache('public_leads_pool');
}


$_REQUEST['diony']='diony';
ConvertTojsonString(1,array(),"success");
?>