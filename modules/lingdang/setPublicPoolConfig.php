<?php
/**
* edit: chj
* reason: 公海参数设置
* date: 2020/11/27
**/

global $adb,$theme;
global $current_user,$list_max_entries_per_page_new,$currentModule;
$smarty=new lingdangCRM_Smarty();
$before_status = 'no';
$module = $currentModule;

if($currentModule == 'Accounts'){
    crm_load_class_file('cls_PublicAccounts', 'modules/Accounts');
    $cls_PublicAccounts = new cls_PublicAccounts($currentModule);

    $program_table = 'ld_account_normal';
    $publicpool_table = 'ld_account_public_pool';
}else{
    crm_load_class_file('cls_PublicLeads', 'modules/Leads');
    $cls_PublicAccounts = new cls_PublicLeads($currentModule);

    $program_table = 'ld_leads_normal';
    $publicpool_table = 'ld_leads_public_pool';
}


$data = $cls_PublicAccounts->getPublicAccount();
if(!empty($data['status'])){
	$before_status = $data['status'];
	$data['before_status'] = $before_status;
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
//$smarty->assign('COMMONACCOUNBT_ROLE_LIMITCOUNT',$commonaccount_role_limitaccount);

crm_load_class_file('cls_AdvftOperate','include');
$AdvftOperateobj = cls_AdvftOperate::getInstance($module);
//回收方案
$common_recovey_rule = array();
$query = "select * from ".$program_table." order by sequence";
$result = $adb->pquery($query,array());
$num_rows = $adb->num_rows($result);
if($num_rows >= 1){
	for($i = 0; $i < $num_rows; $i++){
		$id = $adb->query_result($result,$i,'id');
		$advfilter = $adb->query_result($result,$i,'advfilter')??'';
        $advfilter_grouping = $adb->query_result($result,$i,'advfilter_grouping')??'';
        $advf_label = $AdvftOperateobj->TransAdvftTostring(json_decode(html_entity_decode($advfilter),true),json_decode(html_entity_decode($advfilter_grouping),true));
        //$advf_label = str_replace('<br>','',$advf_label);
        $transfer_users = $adb->query_result($result,$i,'transfer_users');
        $transfer_users_label = getUserFullName($transfer_users);
        $pool_id = $adb->query_result($result,$i,'pool_id');

		$common_recovey_rule[] = array(
            'programme_name' => $adb->query_result($result,$i,'programme_name'),
			'programmeid' => $adb->query_result($result,$i,'id'),
            'active' => $adb->query_result($result,$i,'active'),
			'pool_id' => $pool_id,
			'advfilter' => $advfilter,
			'advfilter_grouping' => $advfilter_grouping,
            'advf_label' => $advf_label,
			'description' => $adb->query_result($result,$i,'description'),
			'rule_arr' => getAccountNormalRule($module,$id),
            'beforereminddays' => $adb->query_result($result,$i,'beforereminddays'),
            'transfer_users' => $transfer_users,
            'transfer_users_label' => $transfer_users_label,
            'objtainaccountcontroldays' => $adb->query_result($result,$i,'objtainaccountcontroldays')
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

$arr['common_recovey_rule']=$common_recovey_rule;

$arr['account_pool'] = $account_pool;
$arr['default_pool'] = $cls_PublicAccounts->getDefaultPublicPool('pool_id');

//公海客户保有量
$arr['public_limit_info'] = array('public_limit_type'=>$data['public_limit_type'],'public_limit_count'=>$data['public_limit_count']);
//普通客户保有量
$arr['limit_info'] = array('limit_type'=>$data['limit_type'],'limit_count'=>$data['limit_count']);

//基础信息
unset($data['public_limit_type']);
unset($data['public_limit_count']);
unset($data['limit_type']);
unset($data['limit_count']);
$arr['base_poolinfo'] = $data;

$smarty->assign('DATA',$data);
$_REQUEST['diony']='diony';
//获取帮助手册入口链接，为空则不显示
//可能有多个帮助链接需要获取
$helpHtmlArr = array();
//线索公海参数设置帮助
$labels = array('PublicPoolParam');
foreach($labels as $label){
    $helpHtmlArr[$label] = getHelpHtmlByLabel($module,1,'HelpUrl_'.$label);
}
//$arr['helpHtml'] = $helpHtmlArr;
if (!empty($helpHtmlArr['PublicPoolParam'])){
    $arr['helpHtml'] = '<div class="ld-btn-icontext-items lfloat">'.$helpHtmlArr['PublicPoolParam'].'</div>';
}


$labelbol_arr = ['PUBLICCUSTOMERSET','DISPLAYSEACUSTOMER','ACTIVATEPUBLICCUST','Allownewordinarycustomers','Highseassuperadministratorsettings','Pleasesettheadministratorsjspop1',
    'Pleasesettheadministratorsjspop1','Createandmaintainmultiplehighseaspool','CUSTOMERLISTTABSET','SEACUSTOMERLISTTABSET','ZHPARENTMENUNMAE','ENPARENTMENUNMAE','TABDESCRIPTION',
    'WHETHERTOENABLE','DEFAULTTAB','OPERATING','HIGHSEASPOOLMANAGEMENT','Name(ZH)','Name(EN)','Set_Default','MAXIMUMREGULARCUSTOMERS','NOLIMITS','ACCORDINGTOTHEUSEREACH',
    'Accordingtotherolcontrol','recoveryconditions','recyclingrules','createecyclingscheme','SCHEMEDESCRIPTION','REGULARCUSTOMERSRECYCLINGSCHEME','PROFILES',
    'Themaximumnumberofcustomers','UPPERLIMITOFALLOCATED','Themaximumnumberofhighseascustomers','Enablecommoncustomerautomaticreclaimrules','createpublicaccountpool',
    'addrulecomments','CYCLENOCREATEDDAYS','SINGLENOCREATEDDAYS','ATLEASTONETAB','publiclimitcountinfolabel','limitcountinfolabel'];
$fieldlabel_arr = [];
foreach ($labelbol_arr as $tmp_label){
    $fieldlabel_arr[$tmp_label] = getFixedLabel($tmp_label);
}
if($module == 'Leads'){
    $transfer_label = [
        'DISPLAYSEACUSTOMER'=>'DISPLAYSEALEADS',
        'SEACUSTOMERLISTTABSET'=>'SEALEADLISTTABSET',
        'CUSTOMERLISTTABSET'=>'LEADLISTTABSET',
        'Allownewordinarycustomers'=>'AllowNewCommonLead',
        'REGULARCUSTOMERSRECYCLINGSCHEME'=>'REGULARLEADSRECYCLINGSCHEME',
        'Createandmaintainmultiplehighseaspool'=>'CreateAndMaintainMultipleHighSeasPoolOfLeads',
        'Enablecommoncustomerautomaticreclaimrules'=>'EnableCommonLeadsAutomaticReclaimRules',
        'MAXIMUMREGULARCUSTOMERS'=>'MAXIMUMREGULARLEADS',
        'Themaximumnumberofcustomers'=>'Themaximumnumberofleads',
        'publiclimitcountinfolabel'=>'publiclimitcountinfolabellead',
        'limitcountinfolabel'=>'limitcountinfolabellead',
        'Themaximumnumberofhighseascustomers'=>'THEMAXIMUMNUMBEROFHIGHSEASLEADS'];
    foreach ($transfer_label as $old_labelbol => $new_labelbol){
        $fieldlabel_arr[$old_labelbol] = getFixedLabel($new_labelbol);
    }
}


$arr['fieldlabel_arr'] = $fieldlabel_arr;
//公海基本设置按钮
$public_set_arr = [];
$public_set_arr[] = ['key'=>'status','labelbol'=>'ACTIVATEPUBLICCUST','tag'=>'no'];
$public_set_arr[] = ['key'=>'showpublicmodule','labelbol'=>'DISPLAYSEACUSTOMER','tag'=>'changestatus'];
$public_set_arr[] = ['key'=>'is_commonaccount_create','labelbol'=>'Allownewordinarycustomers','tag'=>'changestatus'];
$arr['public_set_arr'] = $public_set_arr;
$arr['admin_user'] = $users;
//模块列表页签信息
crm_load_class_file('cls_module_list_tab','modules/lingdang');
$list_tab_obj = new cls_module_list_tab($module);
$all_list_tab = $list_tab_obj->getAllListTab();
$arr['list_tab'] = $all_list_tab;
//公海池信息

$arr['public_pool'] = $cls_PublicAccounts->getAllActivePool();

$arr['language_type'] = getLanguageType($current_user);
$arr['commonaccount_role_limitaccount'] = $commonaccount_role_limitaccount;
$arr['all_publicpool_role_limitcount'] = $cls_PublicAccounts->getAccountRoleLimitCount(-1);

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
function getAccountNormalRule($module,$id) {
	global $adb;
    $all_rule = [];
    if($module == 'Accounts'){
        $query = "SELECT a.id,a.`status`,a.iscycle,a.days,a.`condition`,a.tabname FROM
        ld_account_set_rule_normal a INNER JOIN ld_tab ON ld_tab.NAME = a.tabname
        WHERE a.normal_id = ? AND ld_tab.presence IN (0, 2) ORDER BY a.sequence;";
    }else{
        $query = "SELECT a.programmeid ,a.`status`,a.iscycle,a.days,a.`condition`,a.tabname FROM
        ld_leads_set_rule a INNER JOIN ld_tab ON ld_tab.NAME = a.tabname
        WHERE a.programmeid = ? AND a.type = 'normal' and ld_tab.presence IN (0, 2) ORDER BY a.sequence;";
    }
	$result = $adb->pquery($query,array($id));
	$num_rows = $adb->num_rows($result);
	if($num_rows >= 1){
	    $tmp_id = 1;
        $all_rule = $adb->query_result_all($result);
        foreach ($all_rule as &$tmp_info){
            $tmp_info['id'] = $tmp_id;
            $tmp_info['tablabel'] = getTranstab($tmp_info['tabname']);
            $tmp_id ++;
        }
	}
	return $all_rule;
}

function getAccountNormalRuleLabel($id){
    global $adb;
    $sql = "SELECT tabname,days,iscycle from ld_account_set_rule_normal where normal_id = ? and `status` = 'active' ORDER BY sequence asc";
    $result = $adb->pquery($sql,array($id));
    $label_arr = [];
    $num_rows = $adb->num_rows($result);
    if($num_rows >= 1){
        $circle_label = getFixedLabel('CIRCLERULELABEL');
        $single_label = getFixedLabel('SINGLERULELABEL');
        for($i = 0; $i < $num_rows; $i++){
            $show_label = '';
            $module = $adb->query_result($result,$i,'tabname');
            $module_label = getTranstab($module);
            $days = $adb->query_result($result,$i,'days');
            $iscycle = $adb->query_result($result,$i,'iscycle');
            if($iscycle == 'yes'){
                $show_label = $circle_label;
            }else{
                $show_label = $single_label;
            }
            $show_label = str_replace('{var}',$days,$show_label);
            $show_label = str_replace('{module}',$module_label,$show_label);
            $label_arr[] = $show_label;
        }
    }
    return implode('<br>',$label_arr);
}

?>