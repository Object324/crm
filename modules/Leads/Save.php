<?php

//require_once('modules/Leads/Leads.php');
//
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb,$currentModule;
$publicaccount=0;
$LINGDANG_BULK_SAVE_MODE = false;
$focus =CRMEntity::getInstance("Leads");
$focus->mode=$_REQUEST['mode'];
$search=$_REQUEST['search_url'];
if(isset($_REQUEST['record']) && $_REQUEST['record'] >0){
	$focus->id = $_REQUEST['record'];
    $focus->mode='edit';
    $focus->retrieve_entity_info($focus->id,'Leads');
    $before_columnfieldvalue=$focus->column_fields;
}
else
{
    $pool_id=$_REQUEST['pool_id'];
    if(!isset($_REQUEST['pool_id'])||empty($pool_id))
    {
        $_REQUEST['publicaccount']=0;
    }
}
setObjectValuesFromRequest($focus);

if($_REQUEST['assigned_type'] == 'U') {
	$focus->column_fields['assigned_user_id'] = $_REQUEST['assigned_user_id'];
} elseif($_REQUEST['assigntype'] == 'T') {
	$focus->column_fields['assigned_user_id'] = $_REQUEST['assigned_group_id'];
}
//ls 20221115  XUQIU1000422 “公海参数设置”界面增加“客户数量上限”区块（保存时判断，防止当前登录成员创建时，销售负责人不是当前用户）
crm_load_class_file('cls_PublicLeads', 'modules/Leads');
$cls_PublicAccounts = new cls_PublicLeads($currentModule);
$public_account = $cls_PublicAccounts->getPublicAccount();
if($_REQUEST['publicaccount'])
{
    $publicaccount=$_REQUEST['publicaccount'];
}
if($public_account['status'] != 'yes')
{
    $publicaccount=0;
}
if ($focus->mode != 'edit' && $publicaccount == 0) {
    $limit_count = $focus->getCommonAccountLimitCount($focus->column_fields['assigned_user_id']);
    if($limit_count<9999999999)
    {
        $haved_count = $focus->getSmowerNumForCommonAccount($focus->column_fields['assigned_user_id']);
        if ($limit_count <= $haved_count) {
            $errormsg = $public_account['status']=='yes'?sprintf(getFixedLabel('CreateSaveReacheMaximumLeadsError1'), getUserFullName($focus->column_fields['assigned_user_id'])):sprintf(getFixedLabel('CreateSaveReacheMaximumLeadsError'), getUserFullName($focus->column_fields['assigned_user_id']));
            ConvertTojsonString(-1,[],$errormsg);
        }
    }
}

$focus->save("Leads");
$versionInfo = getVersionInfo();
//2021-0201 zxm 陌远特殊开发 销售线索新建保存发送邮件
if($versionInfo['account'] == "moyuan"){
    include globalStatic::$root_directory.'modules/Home/CustomMade/MoyuanUtils.php';
    $moyuanObj = new MoyuanUtils();
    $moyuanObj->emailLeadsForSave($focus->mode,$focus->id);
}
$return_id = $focus->id;
if(isset($_REQUEST['return_module']) && $_REQUEST['return_module'] != "") $return_module = vtlib_purify($_REQUEST['return_module']);
else $return_module = "Leads";
if(isset($_REQUEST['return_action']) && $_REQUEST['return_action'] != "") $return_action = vtlib_purify($_REQUEST['return_action']);
else $return_action = "DetailView";
if(isset($_REQUEST['return_id']) && $_REQUEST['return_id'] != "") $return_id = vtlib_purify($_REQUEST['return_id']);
if($_REQUEST['frommodule']&&$_REQUEST['frommodule']=='Campaigns')
{
    //弹出层界面保存方法
    $campaignid=$_REQUEST['fromid'];
    $tabid = getTabid($currentModule);
    $rel_tabid = getTabid($_REQUEST['frommodule']);
    $rel_sql = 'SELECT * from ld_relatedlists where tabid = ? and related_tabid = ?';
    $rel_result = $adb->pquery($rel_sql,array($rel_tabid, $tabid));
    $rel_tablename = $adb->query_result($rel_result,0,'related_coltable');
    $rel_tablename = explode('.',$rel_tablename)[0];
    $rel_tablename = 'ld_'.$rel_tablename;
    $sql = "insert into ".$rel_tablename."(crmid,relcrmid,module,relmodule) values (?,?,?,?)";
    $adb->pquery($sql, array($campaignid,$focus->id,$_REQUEST['frommodule'],$currentModule));
}

//code added for returning back to the current view after edit from list view
if($_REQUEST['return_viewname'] == '') $return_viewname='0';
if($_REQUEST['return_viewname'] != '')$return_viewname=vtlib_purify($_REQUEST['return_viewname']);

/**
 * 列表编辑后，返回列表时，增加query_session=1的参数，启用列表页面搜索session
 * @project 序时簿查询记住搜索条件
 * @author Tujt 2014-04-24
 */
if($return_module == $currentModule && $return_action != 'DetailView'){
	$return_action .= '&query_session=1';
}

/*
edit:can
date:20130530
reason:创建和编辑权限分开
*/
$_REQUEST['diony']='diony';
$focus->column_fields['record_module']=$focus->module_name;
if($_REQUEST['refreshpage']=='no')
 {
    $focus->ReturnAfterSave($before_columnfieldvalue);
    /*
        $arr['fieldhrefname']=$focus->list_link_field;
     $arr['fieldvalue']=$focus->column_fields;
    $arr['fieldvalue']['maintable_id']=$focus->id;
    $arr['modulebillnotip']=$_SESSION[$currentModule.'_modulebillnotip'];
    $_SESSION[$currentModule.'_modulebillnotip']='no';
    ConvertTojsonString(1,$arr,"success");*/
        
 }else{
	header("Location: index.php?action=$return_action&module=$return_module&record=$return_id&SearchScope=$SearchScope&viewname=$return_viewname&start=".vtlib_purify($_REQUEST['pagenumber']).$search);	
 }
exit();
?>