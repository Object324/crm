<?php
//zkt 20231012 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
/*+**********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ************************************************************************************/
global  $current_language, $currentModule, $theme,$current_user;
global $adb;
$smarty = new lingdangCRM_Smarty();
require_once('modules/Calendar/CalendarCommon.php');
if($currentModule == 'Calendar'){
    $currentModule='Events';
}
if (isset($_REQUEST['contactscallid']) && $_REQUEST['contactscallid'] != '') {
    $contactsid = $_REQUEST['contactscallid'];
    $smarty->assign("CALLTYPE", 'true');
    $result = $adb->pquery("select T1.accountid,accountname,T1.contactid,lastname from ld_contactdetails as T1 
    left join ld_account as T2 on T1.accountid = T2.accountid
    where T1.contactid = ?", array($contactsid));
    
   // if($adb->num_rows($result)>0)
	$accountid = $adb->query_result($result, 0, 'accountid');
    $accountname = $adb->query_result($result, 0, 'accountname');
    $lastname = $adb->query_result($result, 0, 'lastname');
    $smarty->assign("ACCOUNTID", $accountid);
    $_REQUEST['account_id']=$accountid;
    $smarty->assign("ACCOUNTNAME", $accountname);
    $smarty->assign("CONTACTID", $contactsid);
    $smarty->assign("LASTNAME", $lastname);
}
$sourcemodules=getSourceModule($currentModule);
$isfromsourcemodule='no';
/*
合同订单,服务合同  新增出库单
*/


$focus = CRMEntity::getInstance($currentModule);
$fieldObj=Field::getInstance($currentModule,$adb);

//$category = getParentTab($currentModule);
$record = $_REQUEST['record'];

$isduplicate = vtlib_purify($_REQUEST['isDuplicate']);

//added to fix the issue4600
$searchurl = getBasic_Advance_SearchURL();
$smarty->assign("SEARCH", $searchurl);
//4600 ends

if($record) {
	$focus->id = $record;
	$focus->mode = 'edit';
	$focus->retrieve_entity_info($record, $currentModule);
    $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey('columnname',$focus->getSmownerColumName());
    if($fieldinfo&&$focus->column_fields[$fieldinfo->getFieldName()]!=$current_user->id)
    {
            crm_load_class_file('cls_CurUserDataScope','include/ListView');
            $datascopeobj=cls_CurUserDataScope::getInstance($currentModule,'record');
            $datascopeobj->isMyViewData($_REQUEST['record']);
    }
    //审批流程begin
    //判断单据的审批状态，如果是已审批或者审批中，小编辑功能失效
    //require_once('modules/Approve/Approve.php');
	$approve = Approve::getInstance($currentModule);
    //$approve=new Approve();
    if(isset($_REQUEST['ajax']) && $_REQUEST['ajax']==true){
        echo $approve->EditBlocks($focus->column_fields['assigned_user_id'],$focus->id);
        exit();
    }
    //审批流程end
}else{
    $focus->mode = 'create';
    
}
if($isduplicate == 'true') {
	$focus->id = '';
	$focus->mode = '';
	/**
	 * 复制时，负责人设置为自己
	 * @author Tujt 2015-07-20
	  //单据复制，默认值设置,https://www.tapd.cn/my_worktable?source_user=2004112531&workspace_id=20699121&workitem_type=story&workitem_id=1120699121001000517#&filter_close=true
	if('ServiceContracts' == $module){
		$focus->column_fields['ServiceContractsassigned_user_id'] = $current_user->id;
	}else{
		$focus->column_fields['assigned_user_id'] = $current_user->id;
	}*/
}
//chj:获取币种ID
if(isset($focus->column_fields['currency_id']))
{
    if($focus->mode == 'edit')
        $currencyid = $focus->column_fields['currency_id'];
    else
        $currencyid = 1;
}
if(empty($_REQUEST['record']) && $module == 'Project' && isset($_REQUEST['servicecontractsid']) && $_REQUEST['servicecontractsid'] > 0){
    $_REQUEST['salesorder_id'] = $_REQUEST['servicecontractsid'];
}
if(empty($_REQUEST['record']) && $focus->mode != 'edit'){
	setObjectValuesFromRequest($focus);
}

if((isset($_REQUEST['fromid']) && $_REQUEST['fromid'] >0) )
{

		$salesorder_id = $_REQUEST['fromid'];
   
    
   foreach($sourcemodules as $tmp=>$sourcemoduleinfo)
    {
        if($_REQUEST['frommodule']==$sourcemoduleinfo['entitytype'])
        {
            $isfromsourcemodule='yes';
            break;
        }
    }
    if($isfromsourcemodule=='yes')
	{
	   
         $fieldinfo=$focus->getSourceFieldInfo();
         if($fieldinfo&&$fieldinfo->getFieldName()!='')//报价单管理创建服务合同
            $focus->column_fields[$fieldinfo->getFieldName()]=$_REQUEST['fromid'];//关联创建原单
    }
}
if($currentModule=='Reminds'){
    
    $focus->column_fields['assigned_user_id'] = $current_user->id;
    if(!empty($_REQUEST['contact_id'])){
    	$focus->column_fields['related_to'] = $_REQUEST['contact_id'];
    }elseif(!empty($_REQUEST['account_id'])){
    	$focus->column_fields['related_to'] = $_REQUEST['account_id'];
    }elseif(!empty($_REQUEST['potential_id'])){
    	$focus->column_fields['related_to'] = $_REQUEST['potential_id'];
    }
}
if($currentModule=='Events'){
    if(!empty($_REQUEST['start_date'])){
        $date_start=$_REQUEST['start_date'];
        $datestrart=new DateTimeField($date_start);
        $focus->column_fields['date_start'] =$datestrart->getDBInsertDateValue().' '.$datestrart->getDBInsertTimeValue();
        if (!empty($_REQUEST['end_date'])){
            $date_end=$_REQUEST['end_date'];
            $dateend=new DateTimeField($date_end);
            $focus->column_fields['due_date'] =$dateend->getDBInsertDateValue().' '.$dateend->getDBInsertTimeValue();
        }else{
            $focus->column_fields['due_date']=DateOperation::addHours($date_start,1);
        }

    }
    
    /*if(!empty($_REQUEST['end_date']) && !empty($_REQUEST['time_end'])){
        $due_date=$_REQUEST['end_date'].' '.$_REQUEST['time_end'];
        $duedate=new DateTimeField($due_date);
        $focus->column_fields['due_date'] =$duedate->getDBInsertDateValue().' '.$duedate->getDBInsertTimeValue();
    }*/
}
$disp_view = getView($focus->mode);

if($currentModule=="PaymentPlan" && $isduplicate==true)
  {

    $focus->column_fields['paymentstatus']='未收';
    
  }
if($currentModule=="SendPayment" && $isduplicate==true)
{
	$focus->column_fields['cpstatus']='未付';
}
if($currentModule=="SendPayment" &&$_REQUEST['purchaseorder_id']){
    crm_load_function_file('getInventoryCurrencyInfo','include/utils','InventoryUtils');
	$inventory_cur_info = getInventoryCurrencyInfo('PurchaseOrder',$_REQUEST['purchaseorder_id']);
	$currencyid = $inventory_cur_info['currency_id'];
	$sql='select subject,vendorid from ld_purchaseorder where purchaseorderid='.$_REQUEST['purchaseorder_id'];
	$SendPaymentresult=$adb->pquery($sql,array());
	//$focus->column_fields['purchaseorder_name']=$adb->query_result($SendPaymentresult,0,'subject');
	$focus->column_fields['vendor_id']=$adb->query_result($SendPaymentresult,0,'vendorid');
	$focus->column_fields['purchaseorder_id']=$_REQUEST['purchaseorder_id'];
}

if(isset($_REQUEST['return_module']))   
{
    $smarty->assign("RETURN_MODULE", vtlib_purify($_REQUEST['return_module']));
    if(isset($_REQUEST['return_id'])&& $_REQUEST['return_module']=='SalesOrder'&&$currentModule=="PaymentPlan")
    {
   
      $sql='select  ld_account.accountid,ld_account.accountname,subject from ld_salesorder left join ld_account on 
                        ld_account.accountid=ld_salesorder.accountid  where salesorderid='.$_REQUEST['return_id'];
      $salesresult=$adb->pquery($sql,array());
      
      $focus->column_fields['salesorder_name']=$adb->query_result($salesresult,0,'subject');
      $focus->column_fields['salesorder_id']=$_REQUEST['return_id'];
       $focus->column_fields['account_id']=$adb->query_result($salesresult,0,'accountid');
       $focus->column_fields['account_name']=$adb->query_result($salesresult,0,'accountname');
    }
    if($currentModule=="PaymentPlan"&&!isset($_REQUEST['return_id']))
    {   
        if(isset($_REQUEST['salesorder_id'])){
			$currencyinfo = getModuleCurrencyInfo($_REQUEST['salesorder_id'],'SalesOrder');
            $focus->column_fields['entitytypeid'] = $_REQUEST['salesorder_id'];  
        }
        if(isset($_REQUEST['servicecontracts_id'])){
			$currencyinfo = getModuleCurrencyInfo($_REQUEST['servicecontracts_id'],'ServiceContracts');
            $focus->column_fields['entitytypeid'] = $_REQUEST['servicecontracts_id'];
        }
		$smarty->assign('CURRENCYID',$currencyinfo['curid']);
    }
    if(isset($_REQUEST['salesorder_id'])){
        $currencyinfo = getModuleCurrencyInfo($_REQUEST['salesorder_id'],'SalesOrder');
        $currencyid = $currencyinfo['curid'];   
    }
	if(isset($_REQUEST['records'])&& $_REQUEST['return_module']=='ProjectTask'&&$currentModule=="ProjectProgress")
    {
		$focus->column_fields['projecttaskid'] =$_REQUEST['records'];
		$query = 'select projectid from ld_projecttask where projecttaskid = ?';
		$result = $adb->pquery($query,array($_REQUEST['records']));
		if($adb->num_rows($result) >= 1){
			$projectid = $adb->query_result($result,0,0);
			$focus->column_fields['projectid'] =$projectid;
		}
		
	}
}

if(isset($_REQUEST['return_action']))    $smarty->assign("RETURN_ACTION", vtlib_purify($_REQUEST['return_action']));
if(isset($_REQUEST['return_id']))        $smarty->assign("RETURN_ID", vtlib_purify($_REQUEST['return_id']));
if (isset($_REQUEST['return_viewname'])) $smarty->assign("RETURN_VIEWNAME", vtlib_purify($_REQUEST['return_viewname']));

/**
* edit:chj
* date:2014-6-23
* reason:教育行业 学员更多信息新增班级 课程 教师
*/
if(($currentModule == 'Project' || $currentModule == 'ServiceContracts' || $currentModule == 'ProjectMilestone') 
&& isset($_REQUEST['account_id']) && $_REQUEST['account_id'] > 0 && getEduType('Edu') == true)
{
    $smarty->assign('ACCOUNTID',$_REQUEST['account_id']);
}
//服务合同选择合同订单带出明细 - 显示合同订单名称
if(!empty($_REQUEST['convertmode']) && $_REQUEST['convertmode'] == 'update_so_val' && $currentModule == 'ServiceContracts'){
    if(!empty($_REQUEST['salesorder_id'])){
        $focus->column_fields['salesorder_id'] = $_REQUEST['salesorder_id'];   
    }
}
if($_REQUEST['frommodule']&&$_REQUEST['frommodule']=='HelpDesk')
{
    $focus->column_fields['troubleticketid']=$_REQUEST['fromid'];
	if($currentModule == 'ServiceReturn'){
		//$helpdesk_focus = CRMEntity::getInstance('HelpDesk');
		//$helpdesk_focus->retrieve_entity_info($_REQUEST['fromid'], 'HelpDesk');
		//$focus->column_fields['assigned_user_id'] = $helpdesk_focus->column_fields['assigned_user_id'];
	}
}
if(!empty($_REQUEST['fromid'])&&$_REQUEST['frommodule']=='PurchaseOrder' && $_REQUEST['relatedcreate'] == 'yes')
{
     //采购订单关联创建服务合同，需要判断
    if(method_exists($focus,"getPurchaseOrder"))
	{
	  
	   $purchaseorder = $focus->getPurchaseOrder($_REQUEST['fromid']);
    	$smarty->assign('LISTVAL',$purchaseorder['purchaseorder_no']);
    	$smarty->assign('ENTITYTYPEID',$_REQUEST['fromid']);
    	$focus->column_fields['purchaseorder_id']=$_REQUEST['fromid'];
    	$focus->column_fields['amount']=$purchaseorder['total'];
    }
	
}

if($currentModule == 'ServiceContracts' && !empty($_REQUEST['quote_id'])){
	$_REQUEST['fromid'] = $_REQUEST['quote_id'];
}
/**
 * @by andy
 * @date 20140729
 * @reason 系统编号改进
 */  
$isallow= $focus->Library('SystemCode')->getModentityfield('isallow',$currentModule);
$smarty->assign('ISALLOW',$isallow);


$mod_seq_field=$fieldObj->FieldInfoListByKeyValue('uitype',4);

if($focus->mode != 'edit' && isset($mod_seq_field['fieldname'])) {
	$value = $focus->Library('SystemCode')->getModuleSeqNumRecord($_REQUEST['module']);
	if(!$value) $value = getFixedLabel('MSG_AUTO_GEN_ON_SAVE');
	$focus->column_fields[$mod_seq_field['fieldname']]=$value;
}
//服务合同 - 选择合同订单
if(!empty($_REQUEST['salesorder_id']) && $currentModule == 'ServiceContracts'){
	$_REQUEST['fromid'] = $_REQUEST['salesorder_id'];
}
/* 关联创建单据统一处理方法 begin */
if(isset($_REQUEST['parent_id']) && $_REQUEST['parent_id'] > 0){
	$focus->getModuleLogic($currentModule)->setQuickCreateColumn($_REQUEST['parent_module'],$_REQUEST['parent_id']);
}

if(isset($_REQUEST['fromid']) && $_REQUEST['fromid'] > 0){
	//订单下推调试/维修单,将订单中的合同流水号带入到调试/维修单的"合同流水号"字段中.
	if(!empty($_REQUEST['fromid']) && $_REQUEST['frommodule'] == 'SalesOrder' && $currentModule == 'HelpDesk'  && get_versiontrade() == 'yangduan'){
		$query = 'select cf_2191 from ld_salesorder
		LEFT JOIN ld_salesordercf on ld_salesordercf.salesorderid = ld_salesorder.salesorderid 
		where ld_salesorder.salesorderid = ?';
		$result = $adb->pquery($query,array($_REQUEST['fromid']));
		$cf_2191 = $adb->query_result($result,0,0);
		$focus->column_fields['cf_2377'] = $cf_2191;
	}

	$focus->getModuleLogic($currentModule)->setQuickCreateColumnValues($currentModule,$_REQUEST['fromid']);
}

//新增 - 中能
$VersionInfo = getVersionInfo();
if($VersionInfo['account'] == 'zhongneng' && $focus->mode == 'create' && empty($_REQUEST['isDuplicate']) && array_key_exists('wareid',$focus->column_fields)){
	$user_focus = CRMEntity::getInstance('Users');
	$user_focus->retrieve_entity_info($current_user->id, 'Users');
	$wareid = $user_focus->column_fields['wareid'];
	$focus->column_fields['wareid'] = $wareid;
}

$smarty->assign('VERSION_ACCOUNT',$VersionInfo['account']);
/* 关联创建单据统一处理方法 end */
//$focus->setRelatedCreateInfo();
global $global_pick_list_values;

$act_data=getBlocks($currentModule, $disp_view, $focus->mode, $focus->column_fields);
/*echo '<pre>';
print_r($act_data);
echo '</pre>';
exit();*/
/**
 * 更新操作
 * edit:can
 * date:20131223
 * reason:添加富文本框
 **/
if(isset($act_data['RichText']) && !empty($act_data['RichText'])){
	$richText=$act_data['RichText'];
	unset($act_data['RichText']);
	$smarty->assign('RICHTEXTBOX',implode(',',$richText));
	$smarty->assign('RICHTEXTCOUNT',sizeof($richText));
}else{
	$smarty->assign('RICHTEXTBOX','');
	$smarty->assign('RICHTEXTCOUNT','0');
}
if($focus->mode != 'edit')
{
    if(isset($_REQUEST['account_id']) && $_REQUEST['account_id'] > 0)
    {
        $smarty->assign("ACCOUNTID", $_REQUEST['account_id']);   
    }
    if(isset($_REQUEST['contact_id']) && $_REQUEST['contact_id'] > 0)
    {
        $smarty->assign("CONTACTID", $_REQUEST['contact_id']);   
    }
}
$smarty->assign('BLOCKS', $act_data);

$smarty->assign('OP_MODE',$disp_view);

$smarty->assign('MODULE', $currentModule);

// TODO: Update Single Module Instance name here.
$smarty->assign('SINGLE_MOD', 'SINGLE_'.$currentModule);
$smarty->assign('CATEGORY', $category);
$smarty->assign("THEME", $theme);
$smarty->assign('IMAGE_PATH', "themes/$theme/images/");
$smarty->assign('ID', $focus->id);
$smarty->assign('MODE', $focus->mode);
$smarty->assign('CREATEMODE', vtlib_purify($_REQUEST['createmode']));
$smarty->assign('ISADMIN',$current_user->is_admin);
//$smarty->assign('CHECK', Button_Check($currentModule));
$smarty->assign('DUPLICATE', $isduplicate);

if($focus->mode == 'edit' || $isduplicate) {
	$recordName = $focus->column_fields[$focus->list_link_field];
	$smarty->assign('NAME', $recordName);
//	$smarty->assign('UPDATEINFO',updateInfo($record));
}

if(isset($_REQUEST['SearchScope'])) $smarty->assign("SEARCHSCOPE",$_REQUEST['SearchScope']);
// Field Validation Information
$tabid = getTabid($currentModule);
$validationArray = $fieldObj->split_validationdataArray();
//项目选择原单
if($focus->mode == 'edit' && $currentModule == 'Project'){
	$sourceModuleInfo = $focus->getSourceField('entitytype',$focus->id);
    $isSourceModule=$sourceModuleInfo['module'];
	$smarty->assign('SELECTSOURCENAME',$isSourceModule);
	$smarty->assign('LISTVAL',getEditListValName($focus->id,$isSourceModule,1));
	$smarty->assign('ENTITYTYPEID',$sourceModuleInfo['sourceid']);
	$smarty->assign('ISSOURCEMODULE',$isSourceModule);
}else if(((isset($_REQUEST['servicecontractsid']) && $_REQUEST['servicecontractsid']>0)||(isset($_REQUEST['salesorder_id']) && $_REQUEST['salesorder_id']>0)) && $currentModule == 'Project'){
	if(isset($_REQUEST['servicecontractsid'])){
		$isSourceModule = 'ServiceContracts';
		$entitytypeid = $_REQUEST['servicecontractsid'];
	}else{
		$isSourceModule = 'SalesOrder';
		$entitytypeid = $_REQUEST['salesorder_id'];
	}
	$smarty->assign('SELECTSOURCENAME',$isSourceModule);
	$smarty->assign('LISTVAL',getModuleHref($isSourceModule,$entitytypeid));
	$smarty->assign('ENTITYTYPEID',$entitytypeid); 
	$smarty->assign('ISSOURCEMODULE',$isSourceModule);
}
if(($currentModule == 'PaymentPlan' || $currentModule == 'SendPayment') && $focus->mode == 'edit'){
	$sourceModuleInfo = $focus->getSourceField($focus->id);
	$isSourceModule=$sourceModuleInfo['module'];
	$smarty->assign('SELECTSOURCENAME',$isSourceModule);
	$smarty->assign('LISTVAL',getEditListValName($focus->id,$isSourceModule,1));
	$smarty->assign('ENTITYTYPEID',$sourceModuleInfo['sourceid']);
	$smarty->assign('ISSOURCEMODULE',$isSourceModule);
}
$smarty->assign('SOURCEMODULE',getSourceModule($currentModule));
$smarty->assign("VALIDATION_DATA_FIELDNAME",$validationArray['fieldname']);
$smarty->assign("VALIDATION_DATA_FIELDDATATYPE",$validationArray['datatype']);
$smarty->assign("VALIDATION_DATA_FIELDLABEL",$validationArray['fieldlabel']);

/*---仓库信息---*/
if(isset($focus->column_fields['wareid'])){
	require_once ('include/Stock/CommonStock.php');
	$wareresult = selWareAll($current_user->id);
	for($i = 0; $i<$adb->num_rows($wareresult); $i++)
	{
		$wareArray[$adb->query_result($wareresult, $i, "id")] = $adb->query_result($wareresult, $i, "name");
	}
	$smarty->assign("WAREALL", $wareArray);
}
/*
$smarty->assign("CALENDAR_LANG", $app_strings['LBL_JSCALENDAR_LANG']);
$smarty->assign("CALENDAR_DATEFORMAT", parse_calendardate($app_strings['NTC_DATE_FORMAT']));*/
if(array_key_exists('account_id',$focus->column_fields)&& $module != 'Calendar')
{
	//获取客户和联系人区块信息
	$block_info = getBlockDisplayInfo('AccountContacts');
	//显示位置
	$smarty->assign('DISPLAY_POSITION',$block_info['display_position']);
	 //是否显示
	if($block_info['is_display'] == 0)
		$smarty->assign('BESTATUS','YES');
	else
		$smarty->assign('BESTATUS','NO');
}
global $global_pick_list_depencyfield;
crm_load_class_file("lingdang_DependencyPicklist",'modules/PickList');
$picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasource($currentModule);
$smarty->assign("PICKIST_DEPENDENCY_DATASOURCE", ldcrm_json_encode($picklistDependencyDatasource));
$smarty->assign("PICKLISTDEPENCYFIELDS", ldcrm_json_encode($global_pick_list_depencyfield));
$smarty->assign('CURRENCYID',$currencyid);

if (isset($_REQUEST['record']) && $_REQUEST['record'] != '') {
    $smarty->assign("ACCOUNTID", $focus->column_fields['account_id']);
    $smarty->assign("CONTACTID", $focus->column_fields['contact_id']);
    $smarty->assign("SALESORDERID", $focus->column_fields['salesorder_id']);
    $smarty->assign("VENDOR_ID", $focus->column_fields['vendor_id']);
}
$fields=$focus->fieldobj->getFieldListArray();
$fields['module']=$currentModule;
$smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));
$smarty->assign("MODULELINKFIELD",$focus->list_link_field);
$smarty->assign("SMOWNERCOLUMNNAME",$focus->getSmownerColumName());

//wym BUG0074511 当关联创建模块包含附件或图片类型的引用字段时，focus对象上有fieldjsondata（此时foucs->id无值）
$fieldjsondata = empty($focus->fieldjsondata)?array():$focus->fieldjsondata;
/*if($focus->id>0&&$focus->fieldobj->getFieldInfoBykeyValue("uitype",1109,'fieldname')!='')
            $fieldjsondata[$focus->fieldobj->getFieldInfoBykeyValue("uitype",1109,'fieldname')]=json_decode( getAttachmentsTableInfo($focus->id,$currentModule));
        if($focus->id>0&&$focus->fieldobj->getFieldInfoBykeyValue("uitype",69,'fieldname')!='')
            $fieldjsondata[$focus->fieldobj->getFieldInfoBykeyValue("uitype",69,'fieldname')]= json_decode(getImageFileInfo($focus->id,$currentModule));*/
if(($focus->id>0||$_REQUEST['record']>0)&&$focus->fieldobj->getFieldInfoBykeyValue('bigtype','fileattachment','fieldname')!='')
{
    if($focus->id>0){
        $tmp_record = $focus->id;
    }else if($_REQUEST['record']>0){ //edit:duan date:2021-9-30 复制的时候带出附件信息
        $tmp_record = $_REQUEST['record'];
    }
    $fieldjsondata=getAllFile_imageInfo($tmp_record,$currentModule);
}
/*
edit:can
date:20130530
reason:创建和编辑权限分开
*/
if( ($_REQUEST['relatedcreate']=='yes')|| $_REQUEST['isDuplicate']=='true'||(isset($_REQUEST['Create'])&&($_REQUEST['Create']=='true' || $_REQUEST['Create']=='yes')))
{
  
    $smarty->assign('CREATE','true');
}
else
{
  
     $smarty->assign('CREATE','false');
}
if($focus->id<=0||$isduplicate==true)
    $qcreate_array=$focus->fieldobj->QuickCreate();
else
{
   
  //  $qcreate_array
}
$smarty->assign("QUICKCREATE", $qcreate_array['form']);
$quickcreatestr=$smarty->fetch("DetailView/PopupEditQuickCreate.tpl");
$data = $focus->fieldobj->split_validationdataArray();
unset($mod_strings);
unset($app_strings);
?>