<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();

//require_once('include/logging.php');
//require_once('include/database/PearDatabase.php');

$search=vtlib_purify($_REQUEST['search_url']);
/*
if(isset($_REQUEST['dup_check']) && $_REQUEST['dup_check'] != '')
{
	//started
	$value = $_REQUEST['accountname'];
	$query = "SELECT accountname FROM ld_account,ld_crmentity WHERE accountname =? and ld_account.accountid = ld_crmentity.crmid and ld_crmentity.deleted != 1";
	$params = array($value);
	$id = $_REQUEST['record'];
	if(isset($id) && $id !='') {
		$query .= " and ld_account.accountid != ?";
		array_push($params, $id);
	}
	$result = $adb->pquery($query, $params);
        if($adb->num_rows($result) > 0)
	{
		echo $mod_strings['LBL_ACCOUNT_EXIST'];
	}
	else
	{
		echo 'SUCCESS';
	}
	die;
}*/
//Ended

//
//
global $currentModule;
$focus =CRMEntity::getInstance($currentModule);
global $current_user,$adb,$currentModule;
$publicaccount=0;
if(isset($_REQUEST['record']))
{
	$focus->id = $_REQUEST['record'];
    $focus->mode='edit';
    $focus->retrieve_entity_info($focus->id,$currentModule);
    $before_columnfieldvalue=$focus->column_fields;
}
//快速创建客户 - 在模块列表界面 
//选择客户弹出层-快速创建和列表界面直接选择快速创建客户不一致
if(isset($_REQUEST['createview']) && $_REQUEST['createview'] == 'create_view'){
	$field=new Field($module,$adb);
	$qcreate_array =$field->QuickCreate();
	$qcreate_array=$qcreate_array['data'];
	$fieldobj=$focus->fieldobj;
	$fieldModules=$fieldobj->getModuleFields();
	foreach($qcreate_array as $key=>$value)
	{
		if($fieldModules[$key]->getTableName() == 'ld_contactdetails' || $fieldModules[$key]->getTableName() == 'ld_contactscf'){
			$_REQUEST['contactid'] = '';
		}
	}
}
// diony 2013-03-20
/*$sql_rmd="select smownerid from ld_crmentity where crmid='".$focus->id."'";
$resul = $adb->pquery($sql_rmd);
$assOLD=$adb->query_result($resul,0);       */



/*
foreach($focus->column_fields as $fieldname => $val)
{
	if(isset($_REQUEST[$fieldname]))
	{
		if(is_array($_REQUEST[$fieldname]))
			$value = $_REQUEST[$fieldname];
		else
			$value = trim($_REQUEST[$fieldname]);
		
		$focus->column_fields[$fieldname] = $value;
	}
}*/
setObjectValuesFromRequest($focus);
$focus->column_fields['assigned_user_id'] = $_REQUEST['assigned_user_id'];

if(isset($_REQUEST['record']))
{
    $servicequery = "select servicecasher,servicegroup,smownerid from ld_account where accountid = ?";
    $result = $adb->pquery($servicequery,array($_REQUEST['record']));
    $focus->column_fields['servicegroup'] = $adb->query_result($result,0,'servicegroup');
    if($currentModule == 'Accounts')
    {
        $focus->column_fields['servicecasher'] = $adb->query_result($result,0,'servicecasher');
		$focus->column_fields['assigned_user_id'] = $_REQUEST['assigned_user_id'];
    }
    else if($currentModule == 'ServiceCharge')
    {
        $focus->column_fields['servicecasher'] = $_REQUEST['servicecasher'];
		$focus->column_fields['assigned_user_id'] = $adb->query_result($result,0,'smownerid');
    }
}
//When changing the Account Address Information  it should also change the related contact address - dina
if($focus->mode == 'edit' && $_REQUEST['address_change'] == 'yes')
{
	$query = "update ld_contactaddress set mailingcity=?,mailingstreet=?,mailingcountry=?,mailingzip=?,mailingpobox=?,mailingstate=?,othercountry=?,othercity=?,otherstate=?,otherzip=?,otherstreet=?,otherpobox=?  where contactaddressid in (select contactid from ld_contactdetails where accountid=?)" ;
    $params = array($focus->column_fields['bill_city'], $focus->column_fields['bill_street'], $focus->column_fields['bill_country'], 
				$focus->column_fields['bill_code'], $focus->column_fields['bill_pobox'], $focus->column_fields['bill_state'], $focus->column_fields['ship_country'], 
				$focus->column_fields['ship_city'], $focus->column_fields['ship_state'], $focus->column_fields['ship_code'], $focus->column_fields['ship_street'], 
				$focus->column_fields['ship_pobox'], $focus->id);
	$adb->pquery($query, $params);
}
//ls 20221115  XUQIU1000422 “公海参数设置”界面增加“客户数量上限”区块（保存时判断，防止当前登录成员创建客户时，销售负责人不是当前用户）
crm_load_class_file('cls_PublicAccounts', 'modules/Accounts');
$cls_PublicAccounts = cls_PublicAccounts::getInstance($currentModule);
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
    $limit_count = $focus->getCommonAccountLimitCount($focus->column_fields['assigned_user_id']);//普通客户数量上限
    if($limit_count<9999999999)
    {
        $haved_count = $focus->getSmowerNumForCommonAccount($focus->column_fields['assigned_user_id']);//已有客户数量
        if ($limit_count <= $haved_count) {
            $errormsg = $public_account['status']=='yes'?sprintf(getFixedLabel('CreateSaveReacheMaximumError1'), getUserFullName($focus->column_fields['assigned_user_id'])):sprintf(getFixedLabel('CreateSaveReacheMaximumError'), getUserFullName($focus->column_fields['assigned_user_id']));
            ConvertTojsonString(-1,[],$errormsg);
        }
    }
}

$focus->save("Accounts");//调用公用的save方法保存

// @edit:dong @date:2021/04/07 @reason: 禹王特殊开发 保存后同步到nc

$versioninfo = getVersionInfo();
if($versioninfo['account'] =='yuwang'){
    require_once('include/yuwang.php');
    $yuwang = new  yuwang();
    $yuwang->accountToNc($focus);
}


if($_REQUEST['tablerelmodule']&&$_REQUEST['tablerelmodule']=='Campaigns')
{
    //弹出层界面保存方法
      $campaignid=$_REQUEST['tablerelid'];
       
		$campAccStatusResult = $adb->pquery("select campaignrelstatusid from ld_campaignaccountrel where campaignid=? AND accountid=?",array($_REQUEST['return_id'], $focus->id));
		$accountStatus = $adb->query_result($campAccStatusResult,0,'campaignrelstatusid');
		$sql = "delete from ld_campaignaccountrel where accountid = ?";
		$adb->pquery($sql, array($focus->id));
		if(isset($accountStatus) && $accountStatus!=''){
			$sql = "insert into ld_campaignaccountrel(campaignid,accountid,campaignrelstatusid) values (?,?,?)";
			$adb->pquery($sql, array($campaignid, $focus->id,$accountStatus));
		}
		else{
			$sql = "insert into ld_campaignaccountrel(campaignid,accountid,campaignrelstatusid) values (?,?,1)";
			$adb->pquery($sql, array($campaignid, $focus->id));		
		}
}
if((isset($_REQUEST['return_module']) && $_REQUEST['return_module'] == "Campaigns")||(isset($_REQUEST['parent_module']) && $_REQUEST['parent_module'] == "Campaigns"))
{
    //
	if((isset($_REQUEST['return_id']) && $_REQUEST['return_id'] != "")||(isset($_REQUEST['parent_id']) && $_REQUEST['parent_id'] != ""))
	{
	    $campaignid=isset($_REQUEST['return_id'])?$_REQUEST['return_id']:$_REQUEST['parent_id'];
       
		$campAccStatusResult = $adb->pquery("select campaignrelstatusid from ld_campaignaccountrel where campaignid=? AND accountid=?",array($_REQUEST['return_id'], $focus->id));
		$accountStatus = $adb->query_result($campAccStatusResult,0,'campaignrelstatusid');
		$sql = "delete from ld_campaignaccountrel where accountid = ?";
		$adb->pquery($sql, array($focus->id));
		if(isset($accountStatus) && $accountStatus!=''){
			$sql = "insert into ld_campaignaccountrel(campaignid,accountid,campaignrelstatusid) values (?,?,?)";
			$adb->pquery($sql, array($_REQUEST['return_id'], $focus->id,$accountStatus));
		}
		else{
			$sql = "insert into ld_campaignaccountrel(campaignid,accountid,campaignrelstatusid) values (?,?,1)";
			$adb->pquery($sql, array($_REQUEST['return_id'], $focus->id));		
		}
	}
  
}
/**
edit:diony
date:2014-12-29
reason:销售机会，相关信息增加客户
*/

if(isset($_REQUEST['return_module']) && $_REQUEST['return_module'] == "Potentials")
{
	if(isset($_REQUEST['return_id']) && $_REQUEST['return_id'] != "")
	{
		$potentialid = $_REQUEST['return_id'];
        $accountid = $focus->id;
        $checkSql = "select count(1) as count from ld_accountpotentialrel WHERE potentialid = $potentialid AND accountid = $accountid ";
        $checkResult = $adb->pquery($checkSql,array());
        if($adb->query_result($checkResult,0,"count") == 0)
        {
            $adb->pquery("insert into ld_accountpotentialrel values($accountid,$potentialid)", array());
        }
	}
    //21675: 市场活动明细：相关信息-客户，关联客户资料后，编辑单据，点击【保存】，进入的页面不正确
  //  $_REQUEST['return_module']='Accounts';
  //  $_REQUEST['return_id']=$focus->id;
}
/*
$publicaccountRecordid = $_REQUEST['copypublicaccountid'];//yyx 2015-4-21 获取公海参数值
if($publicaccountRecordid >=0){
    $query = ' update ld_account set publicaccount = ? where accountid = ?';
    $adb->pquery($query,array($publicaccountRecordid,$focus->id));
}//yyx 2015-4-21 更新复制后产生的新客户的公海参数值
*/

/**
edit:chj
date:2014-6-23
reason:教育 班级更多信息 创建客户
*/
if($_REQUEST['tablerelmodule']&&$_REQUEST['tablerelmodule']=='Project'&& getEduType('Edu') == true)
{
    $sql = "insert into ld_lessionplanorg(accountid,otherid,type) values (?,?,?)";
    $adb->pquery($sql,array($focus->id,$_REQUEST['tablerelid'],1));
}
$return_id = $focus->id;

// @edit:dong @date:2020/07/17 @reason: 表单推广 5.当销售线索升级后，更新关联关系
if($_REQUEST['upgradefrommodule']!=''&&$_REQUEST['upgradefromid']>0)
{
    $leadid = $_REQUEST['upgradefromid'];
    $accountid = $return_id;
    crm_load_class_file('SocialPromotionForm','modules/SocialPromotion');
    $form = new SocialPromotionForm('');
    $form->updateFromMappingmodule($leadid,$accountid);
}



//$parenttab = getParentTab();

if(isset($_REQUEST['return_module']) && $_REQUEST['return_module'] != "") $return_module = vtlib_purify($_REQUEST['return_module']);
else $return_module = "Accounts";
if(isset($_REQUEST['return_action']) && $_REQUEST['return_action'] != "") $return_action = vtlib_purify($_REQUEST['return_action']);
else $return_action = "DetailView";
if(isset($_REQUEST['return_id']) && $_REQUEST['return_id'] != "") $return_id = vtlib_purify($_REQUEST['return_id']);

/**
 * 列表编辑后，返回列表时，增加query_session=1的参数，启用列表页面搜索session
 * @project 序时簿查询记住搜索条件
 * @author Tujt 2014-04-24
 */
if($return_module == $currentModule && $return_action != 'DetailView'){
	$return_action .= '&query_session=1';
}
//$local_log->debug("Saved record with id of ".$return_id);

//code added for returning back to the current view after edit from list view
if($_REQUEST['return_viewname'] == '') $return_viewname='0';
if($_REQUEST['return_viewname'] != '')$return_viewname=vtlib_purify($_REQUEST['return_viewname']);
if($_REQUEST['SearchScope']!='')     $SearchScope=$_REQUEST['SearchScope'];

/* editor:gyq_11  reason:新增客户更新通话记录相关信息 date:20160603*/
/*
if(!empty($_REQUEST['jiuweiaccount'])){
	if($_REQUEST['callcenter_switch'] == 5) {
		$adb->pquery("UPDATE ld_jiuweiak_phonerecord SET indexid = ?,modulename='Accounts' WHERE id=?", array($focus->id, $_REQUEST['jiuweiaccount']));
	}elseif($_REQUEST['callcenter_switch'] == 6){
		$adb->pquery("UPDATE ld_sopho_phonerecord SET indexid = ?,modulename='Accounts' WHERE id=?", array($focus->id, $_REQUEST['jiuweiaccount']));
	}
}
*/
/*
edit:can
date:20130530
reason:创建和编辑权限分开
*/

/*
更新操作
edit:cdw
date:20131028
reason:客户负责人变更时弹出框提醒
*/
//传用户以前的负责人id
$assign_user_id = $focus->smoldOwnerID;


//传客户的id
$accountid = $_REQUEST['record'];
//服务收费 新增时，销售负责人默认为自己
if(empty($_REQUEST['record']))
{
    if($currentModule == 'ServiceCharge')
    {
        $return_module = 'ServiceCharge';
        $adb->pquery('update ld_account set smownerid = ? where accountid = ?',array($current_user->id,$return_id));
    }   
    
}
$_REQUEST['diony']='diony';
$focus->column_fields['record_module']=$focus->module_name;
$arr['fieldhrefname']=$focus->list_link_field;
if($_REQUEST['refreshpage']=='no')
 {
    if($currentModule == 'Accounts'&&empty($_REQUEST['record']))
    {
        $adb->pquery('update ld_account set servicecasher = ? where accountid = ? and servicecasher = 0',array($current_user->id,$focus->id));
    }
    //
    $focus->setRefreshListModules(array($currentModule));
    //42075: （61mis.com/kfbcrm）客户模块>选择单据编号为“ACC1051”进入编辑界面>“联系人手机”字段：修改手机字段中任意一个字符，保存后界面不会自动刷新，需要手动刷新。
    $focus->setRefreshDetailModules(array($currentModule));
    $focus->ReturnAfterSave($before_columnfieldvalue);
   /* $arr['fieldvalue']=$focus->column_fields;
    $arr['fieldvalue']['maintable_id']=$focus->id;
    $arr['fieldhrefname']=$focus->list_link_field;
    $arr['modulebillnotip']=$_SESSION[$currentModule.'_modulebillnotip'];
    $_SESSION[$currentModule.'_modulebillnotip']='no';
     crm_load_function_file('getDataInfoAfterSave','include/utils','DetailViewUtils');
    $arr['datainfo']=getDataInfoAfterSave($currentModule,'',$focus->column_fields,getTabid($currentModule));    
    ConvertTojsonString(1,$arr,"success");*/
    
        
 }
 else if( (isset($_REQUEST['Create'])&&($_REQUEST['Create']=='true' || $_REQUEST['Create']=='yes')) ||$_REQUEST['isDuplicate']=='true')
{
   
    if($currentModule == 'Accounts')
    {
        $adb->pquery('update ld_account set servicecasher = ? where accountid = ?',array($current_user->id,$focus->id));
    }
    header("Location: index.php?action=$return_action&module=$return_module&Create=true&record=$return_id&SearchScope=$SearchScope&viewname=$return_viewname&start=".vtlib_purify($_REQUEST['pagenumber']).$search);
}
else
{
 
    $_REQUEST['id']=$return_id;
    $_REQUEST['sendSms']=$assign_user_id;
    $massHref="index.php?action=$return_action&module=$return_module&parenttab=$parenttab&id=$return_id&record=$return_id&SearchScope=$SearchScope&viewname=$return_viewname&start=".vtlib_purify($_REQUEST['pagenumber']);
    include("modules/Accounts/Accountalertmsg.php");
	//0017025: 服务收费查看界面：编辑单据保存后，结果模块名称不正确
	if($currentModule == 'ServiceCharge'){
		$return_module = $currentModule;
	}
    header("Location: index.php?action=$return_action&module=$return_module&parenttab=$parenttab&id=$return_id&record=$return_id&SearchScope=$SearchScope&viewname=$return_viewname&start=".vtlib_purify($_REQUEST['pagenumber']));
}


?>