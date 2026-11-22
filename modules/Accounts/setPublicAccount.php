<?php
/**
* edit: chj
* reason: 公海参数设置
* date: 2020/11/27
**/

global $adb,$theme;
global $current_user,$list_max_entries_per_page_new;
$smarty=new lingdangCRM_Smarty();
$before_status = 'no';
crm_load_class_file('cls_PublicAccounts', 'modules/Accounts');
$cls_PublicAccounts = new cls_PublicAccounts($_REQUEST['frommodule']);
$data = $cls_PublicAccounts->getPublicAccount();
if(!empty($data['status'])){
	$before_status = $data['status'];
}
$users = [];
if(!empty($data['administrators'])){
	$query = 'select id,last_name,wx_userid from ld_users where id in (' . $data['administrators'] . ')';
	$result = $adb->pquery($query, array());
	$num_rows = $adb->num_rows($result);
	if($num_rows >= 1){
		for($i = 0; $i < $num_rows; $i++){
			$userid = $adb->query_result($result,$i,'id');
			$last_name = $adb->query_result($result,$i,'last_name');
			$wx_userid = $adb->query_result($result,$i,'wx_userid');
			$userobj=new Users();
			$userobj->wx_userid=$wx_userid;
			$userobj->last_name=$last_name;
			$users[$userid] = getUserlastName($userobj);;
		}
	}
}else{
	//新建公海超级管理员默认值
	$users[1] = getUserFullName(1);
	$data['administrators'] = 1;
}
$public_account = $cls_PublicAccounts->getPublicAccountConfig();
$account_pool = [];
if(!empty($public_account['public_account_pool'])){
	$tmp_i = 0;
	foreach($public_account['public_account_pool'] as $pool_id => $pool_info){
		$account_pool[$tmp_i] = array(
			'pool_id' => $pool_id,
			'pool_name' => $pool_info['pool_name'],
		);
		$tmp_i ++;
	}
}

//ls 20221115  XUQIU1000422 “公海参数设置”界面增加“客户数量上限”区块(按角色控制 数量上限)
//普通客户数量上限 - 按角色控制
$commonaccount_role_limitaccount = $cls_PublicAccounts->getCommonAccountRoleLimitCount();
$smarty->assign('COMMONACCOUNBT_ROLE_LIMITCOUNT',$commonaccount_role_limitaccount);

//回收方案
$arrcondition = array();
$query = "select id,description,pool_id,advfilter,advfilter_grouping from ld_account_normal";
$result = $adb->pquery($query,array());
$num_rows = $adb->num_rows($result);
if($num_rows >= 1){
	for($i = 0; $i < $num_rows; $i++){
		$id = $adb->query_result($result,$i,'id');
		$arrcondition[] = array(
			'normal_id' => $adb->query_result($result,$i,'id'),
			'pool_id' => $adb->query_result($result,$i,'pool_id'),
			'advfilter' => $adb->query_result($result,$i,'advfilter'),
			'advfilter_grouping' => $adb->query_result($result,$i,'advfilter_grouping'),
			'description' => $adb->query_result($result,$i,'description'),
			'rule_json' => getAccountNormalRule($id)
		);
	}
}


$smarty->assign("ARRRECOVERYMODULES",json_encode($arr_recovery_modules));//参与回收的模块
$smarty->assign("COMPLETECONDITION",$completecondition);
$smarty->assign("ARRCOMPLETECONDITION",$arr_complete_condition);

$smarty->assign('ALL_POOL',$account_pool);
//ls 2021-09-06 【ID1001938】销售线索和客户模块，多公海“全部”页签增加默认值显示
$smarty->assign('ALL_ACCOUNT_TYPE',array(
    'ALLACCOUNT' =>getFixedLabel('theallincludeunassignedpool'),	//全部（含所有公海）
    'DEFAULTALLACCOUNT' =>getFixedLabel('thedefaultallincludeunassigned'),	//全部（含指定公海）
    'COMMONACCOUNT' => getFixedLabel('allexcludinghignseas'),	//全部（不含公海）
    'PUBLICALLOCATE' => getFixedLabel('LBL_PUBLICALLOCATE'),	//全部（含公海已分配）
    'NOALLOCATE' => getFixedLabel('LBL_NOALLOCATE')	//全部（含公海未分配）
));
$smarty->assign('USERS',$users);
$smarty->assign('BEFORE_STATUS',$before_status);

$arr['condition']=$arrcondition;

$arr['account_pool'] = $account_pool;
$arr['default_pool'] = $cls_PublicAccounts->getDefaultPublicPool('pool_id');

$smarty->assign('DATA',$data);
$_REQUEST['diony']='diony';
//获取帮助手册入口链接，为空则不显示
//可能有多个帮助链接需要获取
$helpHtmlArr = array();
//线索公海参数设置帮助
$labels = array('PublicPoolParam');
foreach($labels as $label){
    $helpHtmlArr[$label] = getHelpHtmlByLabel('Accounts',1,'HelpUrl_'.$label);
}
//$arr['helpHtml'] = $helpHtmlArr;
if (!empty($helpHtmlArr['PublicPoolParam'])){
    $arr['helpHtml'] = '<div class="ld-btn-icontext-items lfloat">'.$helpHtmlArr['PublicPoolParam'].'</div>';
}

$content=$smarty->fetch("Accounts/AccountPublic.tpl");
$arr['show_account_rule'] = $data['show_account_rule'];
$arr['title']=getFixedLabel("LBL_ACCOUNT_SET");
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$arr['content']=$content;
ConvertTojsonString(1,$arr,"success");


/**
 * 获取回收规则
 * @param
 * @return
 * @author Chj
 */
function getAccountNormalRule($id) {
	global $adb;
	$data = [];
	$query = "select CONCAT(`status`,'_',iscycle,'_',days,'_',`condition`,'_',tabname) as a from ld_account_set_rule_normal
    inner join ld_tab on ld_tab.name=ld_account_set_rule_normal.tabname where normal_id = ?  and ld_tab.presence in(0,2) ORDER BY ld_account_set_rule_normal.sequence";
	$result = $adb->pquery($query,array($id));
	$num_rows = $adb->num_rows($result);
	if($num_rows >= 1){
		for($i = 0; $i < $num_rows; $i++){
			$data[] = $adb->query_result($result,$i,'a');
		}
	}
	return json_encode($data);
}
?>