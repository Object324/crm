<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
include ($root_directory.'modules/Expense/ExpenseDetailFieldsHtml.php');
global  $current_language, $currentModule, $theme;
global $adb;
//require_once('Smarty_setup.php');
$isduplicate=1;
$focus = CRMEntity::getInstance($currentModule);
$smarty = new lingdangCRM_Smarty();

 
$isSourceModule = 'SalesOrder';
$isduplicate = vtlib_purify($_REQUEST['isDuplicate']);
$record = $_REQUEST['record'];
//added to fix the issue4600
$searchurl = getBasic_Advance_SearchURL();
$smarty->assign("SEARCH", $searchurl);
$currencyid = 1;//默认币种为人民币
//4600 ends

if($record) {
	$focus->id = $record;
	$focus->mode = 'edit';
	$focus->retrieve_entity_info($record, $currentModule);
    $sourceModuleInfo = $focus->getSourceField('entitytype',$focus->id);
    $isSourceModule=$sourceModuleInfo['module'];
    $smarty->assign('SELECTSOURCENAME',$isSourceModule);
    $smarty->assign('LISTVAL',getEditListValName($focus->id,$isSourceModule,1));
    $smarty->assign('ENTITYTYPEID',$sourceModuleInfo['sourceid']);
    if($isduplicate)
    {
        //037436: 单据复制默认值问题：费用报销单、加班单、请假单，自定义表单10-20，日期、日期时间类型的字段复制的时候带出了原来的值
        $focus->mode='create';
        $focus->id=0;
    }
}else{
	$focus->mode = 'create';
}


if(empty($_REQUEST['record']) && $focus->mode != 'edit'){
    
	setObjectValuesFromRequest($focus);
}

$disp_view = getView($focus->mode);
$smarty->assign('SALESORDER_MODULE_ACTIVATE',vtlib_isModuleActive('SalesOrder'));
$smarty->assign('SERVICE_MODULE_ACTIVATE',vtlib_isModuleActive('ServiceContracts'));

if(isset($_REQUEST['return_module']))   
{
    $smarty->assign("RETURN_MODULE", vtlib_purify($_REQUEST['return_module']));
} 
else
{
    $smarty->assign("RETURN_MODULE", $currentModule);
}
if(isset($_REQUEST['return_action']))    $smarty->assign("RETURN_ACTION", vtlib_purify($_REQUEST['return_action']));
if(isset($_REQUEST['return_id']))        $smarty->assign("RETURN_ID", vtlib_purify($_REQUEST['return_id']));
if (isset($_REQUEST['return_viewname'])) $smarty->assign("RETURN_VIEWNAME", vtlib_purify($_REQUEST['return_viewname']));
if($_REQUEST['fromid']>0)
{
    if($_REQUEST['frommodule']=='SalesOrder')
    {
        $_REQUEST['salesorder_id']=$_REQUEST['fromid'];
    }
    else if($_REQUEST['frommodule']=='PurchaseOrder')
    {
        $_REQUEST['purchaseorder_id']=$_REQUEST['fromid'];
    }
    else if($_REQUEST['frommodule']=='Potentials')
    {
        $_REQUEST['potential_id']=$_REQUEST['fromid'];
    }
    else if($_REQUEST['frommodule']=='ServiceContracts')
    {
        $_REQUEST['servicecontractsid']=$_REQUEST['fromid'];
    }
}
if(isset($_REQUEST['salesorder_id'])&&$_REQUEST['salesorder_id']!='0')
{
     $currencyinfo = getModuleCurrencyInfo($_REQUEST['salesorder_id'],'SalesOrder');
     $currencyid = $currencyinfo['curid'];
     $sqlsalesorder="select accountid from ld_salesorder where salesorderid=?";
     $resultsalesorder=$adb->pquery($sqlsalesorder,array($_REQUEST['salesorder_id']));
     if($adb->num_rows($resultsalesorder)>0)
     {
        $focus->column_fields['account_id']=$adb->query_result($resultsalesorder,0,0);
     }
     $_REQUEST['selectsourcename']='SalesOrder';
     $_REQUEST['listval']=$_REQUEST['salesorder_id'];
}
if(isset($_REQUEST['servicecontractsid'])&&$_REQUEST['servicecontractsid']!='0')
{
     $currencyinfo = getModuleCurrencyInfo($_REQUEST['servicecontractsid'],'ServiceContracts');
     $currencyid = $currencyinfo['curid'];
     $sqlsalesorder="select accountid from ld_servicecontracts where servicecontractsid=?";
     $resultsalesorder=$adb->pquery($sqlsalesorder,array($_REQUEST['servicecontractsid']));
     if($adb->num_rows($resultsalesorder)>0)
     {
        $focus->column_fields['account_id']=$adb->query_result($resultsalesorder,0,0);
     }
     $_REQUEST['selectsourcename']='ServiceContracts';
     $_REQUEST['listval']=$_REQUEST['servicecontractsid'];
}
if(isset($_REQUEST['purchaseorder_id'])&&$_REQUEST['purchaseorder_id']!='0')
{
     $currencyinfo = getModuleCurrencyInfo($_REQUEST['purchaseorder_id'],'PurchaseOrder');
     $currencyid = $currencyinfo['curid'];
    
     $_REQUEST['selectsourcename']='PurchaseOrder';
     $_REQUEST['listval']=$_REQUEST['purchaseorder_id'];
}
/**
 * @by andy
 * @date 20140729
 * @reason 系统编号改进
 */ 
$isallow= $focus->Library('SystemCode')->getModentityfield('isallow',$currentModule);
$smarty->assign('ISALLOW',$isallow);

/**
 * 创建单据时，编号为自动生成后的编号
 * @project 创建单据时，自动生成编号
 * @author Tujt 2014-05-13
 */
if($focus->mode!='edit'){
	$value = $focus->Library('SystemCode')->getModuleSeqNumRecord($_REQUEST['module']);
	if(!$value) $value = getFixedLabel('MSG_AUTO_GEN_ON_SAVE');
	$focus->column_fields['expense_no'] = $value;
}

/* 关联创建单据统一处理方法 begin */
if(isset($_REQUEST['parent_id']) && $_REQUEST['parent_id'] > 0){
	$focus->getModuleLogic($currentModule)->setQuickCreateColumn($_REQUEST['parent_module'],$_REQUEST['parent_id']);
}
if(isset($_REQUEST['fromid']) && $_REQUEST['fromid'] > 0){
	$focus->getModuleLogic($currentModule)->setQuickCreateColumnValues($currentModule,$_REQUEST['fromid']);
}
/* 关联创建单据统一处理方法 end */
global $global_pick_list_values,$edit_column_fields_value;

$act_data=getBlocks($currentModule, $disp_view, $mode, $focus->column_fields);
$smarty->assign("COLUMN_FIELDS_VALUE",ldcrm_json_encode($edit_column_fields_value));
 /**
    * 更新操作
    * edit:can
    * date:20131223
    * reason:添加富文本框
    * */
if(isset($act_data['RichText']) && !empty($act_data['RichText'])){
	$richText=$act_data['RichText'];
	unset($act_data['RichText']);
	$smarty->assign('RICHTEXTBOX',implode(',',$richText));
	$smarty->assign('RICHTEXTCOUNT',sizeof($richText));
}else{
	$smarty->assign('RICHTEXTBOX','');
	$smarty->assign('RICHTEXTCOUNT','0');
}

//chj:获取币种ID
if($focus->mode == 'edit')
    $smarty->assign('CURRENCYID',$focus->column_fields['currency_id']);
else if($_REQUEST['isDuplicate']==true)
{
    $smarty->assign("isDuplicate",'yes');
    
    $bankaccountsetid=$focus->column_fields['bankaccountsetid'];
    if(!empty($bankaccountsetid))
   {
         $sql='select currency_id from ld_bankaccountset where bankaccountsetid=?';
        $tmpresult=$adb->pquery($sql,array($bankaccountsetid));
         $currencyid=$adb->query_result($tmpresult,0,'currency_id');
   }
   
    $smarty->assign('CURRENCYID',$currencyid);
    
}
else
    $smarty->assign('CURRENCYID',$currencyid);


$smarty->assign('ISSOURCEMODULE',$isSourceModule);
$smarty->assign("BLOCKS",$act_data);
$smarty->assign('OP_MODE',$disp_view);

$smarty->assign('MODULE', $currentModule);
$smarty->assign('ISADMIN',$current_user->is_admin);
// TODO: Update Single Module Instance name here.
$smarty->assign('SINGLE_MOD', $currentModule);
 
$smarty->assign("THEME", $theme);
$smarty->assign('IMAGE_PATH', "themes/$theme/images/");
//edit:can reason:16817: 费用报销-复制保存：提示：此记录已删除

if($isduplicate)
    $smarty->assign('MODE','create' );
else
    $smarty->assign('MODE', $focus->mode);
$smarty->assign('CREATEMODE', vtlib_purify($_REQUEST['createmode']));

//$smarty->assign('CHECK', Button_Check($currentModule));
$smarty->assign('DUPLICATE', $isduplicate);

if($focus->mode == 'edit' || $isduplicate) {
	
	$recordName = $focus->column_fields[$focus->list_link_field];
	$smarty->assign('NAME', $recordName);
	//$smarty->assign('UPDATEINFO',updateInfo($record));
}

if(isset($_REQUEST['SearchScope'])) $smarty->assign("SEARCHSCOPE",$_REQUEST['SearchScope']);
// Field Validation Information
$tabid = getTabid($currentModule);

$validationArray =$focus->fieldobj->split_validationdataArray($validationData);

$smarty->assign("VALIDATION_DATA_FIELDNAME",$validationArray['fieldname']);
$smarty->assign("VALIDATION_DATA_FIELDDATATYPE",$validationArray['datatype']);
$smarty->assign("VALIDATION_DATA_FIELDLABEL",$validationArray['fieldlabel']);


global $global_pick_list_depencyfield;
crm_load_class_file("lingdang_DependencyPicklist",'modules/PickList');
$picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasource($currentModule);
$smarty->assign("PICKIST_DEPENDENCY_DATASOURCE", ldcrm_json_encode($picklistDependencyDatasource));
$smarty->assign("PICKLISTDEPENCYFIELDS", ldcrm_json_encode($global_pick_list_depencyfield));

$now= $tmp_date=date("Y-m"); 
$days = date("t");  
$smarty->assign("NOWMONTHSTART",$now.'-01');
$smarty->assign("NOWMONTHEND",$now.'-'.$days);


$smarty->assign("TOTAL",$focus->column_fields['hdnGrandTotal']);
//$smarty->assign('FORMATTOTAL',number_format($focus->column_fields['hdnGrandTotal'],2));

//联合技术MER特殊控制:根据费用类别控制显示隐藏列
$versioninfo = getVersionInfo();
$smarty->assign('VERSION_ACCOUNT',$versioninfo['account']);
if($versioninfo['account'] == 'utrc'){
	$utrc_type = $focus->getExpenseDetailRowUtrcType($focus->id);
	$smarty->assign('UTRC_TYPE',$utrc_type);
}

crm_load_class_file('TabDetailFields','include/TabDetailFields');
$TabDetailFields = new TabDetailFields($tabid);
$productFields['fields']=$TabDetailFields->getTabDetailFormulaField();
$versiontrade=getVersionTradeInfo();
$productFields['trade']=$versiontrade['trade'];

$smarty->assign('PRODUCTFIELDSINFOJSON',ldcrm_json_encode($productFields));

//相关信息、关联创建源单
if(!empty($_REQUEST['salesorder_id']) && $_REQUEST['salesorder_id'] > 0){
	$entitytypeid = $_REQUEST['salesorder_id'];
}else if(!empty($_REQUEST['potential_id']) && $_REQUEST['potential_id'] > 0){
	$entitytypeid = $_REQUEST['potential_id'];
}else if(!empty($_REQUEST['servicecontractsid']) && $_REQUEST['servicecontractsid'] > 0){
	$entitytypeid = $_REQUEST['servicecontractsid'];
}
else if(!empty($_REQUEST['purchaseorder_id']) && $_REQUEST['purchaseorder_id'] > 0){
    //38178: 费用报销单->源单类型增加采购订单，采购订单->相关信息增加“费用报销”，采购订单关联创建费用报销单无法传入源单
	$entitytypeid = $_REQUEST['purchaseorder_id'];
}
else if($_REQUEST['relatedcreate']=='yes'){
    //zkt 20221011 BUG0054072费用报销单，可选源单类型增加“市场活动”和“常用审批单”，但是从“市场活动”或“常用审批单”关联创建费用报销单，没有带过来源单信息
    $sourcemodules=getSourceModule($currentModule);
    foreach($sourcemodules as $sourcemoduleinfo){
        if($sourcemoduleinfo['entitytype']==$_REQUEST['frommodule']){
            $entitytypeid=$_REQUEST['fromid'];
            break;
        }
    }
    
}

$focus->id=$_REQUEST['record'];//一定要这样，不然复制后明细没有了；

$ExpenseDetailFieldsHtml = new ExpenseDetailFieldsHtml($focus,$currentModule);
//zkt 20221121 BUG0058996kfbcrm  佣金单分录---增加引用字段，引用跟进记录里的联系方式，并保存数据库---当保存佣金单后，修改器源单跟进记录的联系方式字段---列表界面和编辑界面引用字段出现不统一
if(!empty($_REQUEST['fromid']) && !empty($_REQUEST['frommodule'])&&$_REQUEST['relatedcreate']=='yes'){
    $ExpenseDetailFieldsHtml->tabDetailFieldData->row_mode = 'related_create';
}
$smarty->assign('TREXPENSE',$ExpenseDetailFieldsHtml->getTabDetailFieldsHtml($entitytypeid));

if($isduplicate == 'true') {
	$focus->id = '';
	$focus->mode = '';
	//$focus->column_fields['assigned_user_id'] = $current_user->id;
}
$smarty->assign('ID', $focus->id);

//ls 240827  XUQIU20240815-01 对接发票云的API接口
crm_load_class_file('PiaozoneClass', 'modules/lingdang');
$piaozoneObj = PiaozoneClass::getInstance($currentModule);
$smarty->assign('InvioceData',"");//编辑单据时记录已存在的发票数据
$smarty->assign('InvoicetypeData',"");//发票类型的集合
$smarty->assign('PiaozoneAuth',$piaozoneObj->isauthorize?'yes':'no');
if ($piaozoneObj->isauthorize /*&& $isduplicate != 'true'*/) {  //授权到期即使有历史数据编辑页也不应该显示发票区块（但详情页需要显示）
    $smarty->assign('InvoiceTotal',$piaozoneObj->getInvoiceTotal($focus->id));//编辑单据时记录已存在的发票数据
    $inviocehtml = $piaozoneObj->invoiceDataToHtmlByid($focus->id);
    $smarty->assign('InvioceHtml',$inviocehtml);//发票分录明细
    if(!empty($inviocehtml)){
        $smarty->assign('InvioceData',ldcrm_json_encode($piaozoneObj->getInvioceData($focus->id)));//编辑单据时记录已存在的发票数据
        $smarty->assign('InvoicetypeData',ldcrm_json_encode($piaozoneObj->invoicetype_arr));//发票类型的集合
    }
}
/*
edit:can
date:20130530
reason:创建和编辑权限分开
*/
if( (isset($_REQUEST['Create'])&&($_REQUEST['Create']=='true' || $_REQUEST['Create']=='yes')) ||$_REQUEST['isDuplicate']=='true')
{
   
    $smarty->assign('CREATE','true');
}
else
{
    
     $smarty->assign('CREATE','false');
}
/**
 * 从源单模块创建过来，默认源单产品信息以及主题
 * @reason 0010375 服务合同添加销售发票、收款单、佣金单、费用报销相关信息
 * @author Tujt 2014-07-28
 */
if( $_REQUEST['fromid']>0 && isset($_REQUEST['selectsourcename']) && $_REQUEST['listval'] > 0){

	$selectsourcename = $_REQUEST['selectsourcename'];
	$listval = $_REQUEST['listval'];
	$entitysubject = getEntityName($selectsourcename,$listval);
	$smarty->assign('SELECTSOURCENAME',$selectsourcename);
	$smarty->assign('LISTVAL',$entitysubject[$listval]);
	$smarty->assign('ENTITYTYPEID',$listval);
    $isSourceModule = $_REQUEST['selectsourcename'];
    
    
    /**
     * zyh
     * bug 0015368 服务合同>明细：关联创建佣金单、费用报销，币种默认值不是服务合同的币种
     */
    $listval = $_REQUEST['listval'];
    if($selectsourcename=='ServiceContracts')
    {
        $res = $adb->pquery("select currency_id from ld_servicecontracts where servicecontractsid=$listval");
        $cy_id = $adb->query_result($res,0,'currency_id');
        $smarty->assign('CYID',$cy_id);
    }
}

$smarty->assign("ACCOUNTID",$focus->column_fields['account_id']);


$fields=$focus->fieldobj->getFieldListArray();
$fields['module']=$currentModule;

/**
 * 编辑、新增页面，增加更多信息左边栏
 * @author Tujt 2014-04-11
 */
$relmodule = (isset($_REQUEST['module']))?$_REQUEST['module']:$currentModule;
//$smarty->assign("IS_REL_LIST",isPresentRelatedLists($relmodule));
$fields=$focus->fieldobj->getFieldListArray();
$fields['module']=$currentModule;
$smarty->assign('FIELDINFOJSON',ldcrm_json_encode($fields['fields']));
$smarty->assign("MODULELINKFIELD",$focus->list_link_field);
$smarty->assign("SMOWNERCOLUMNNAME",$focus->getSmownerColumName());
$smarty->assign("PICKLISTCONTENT",ldcrm_json_encode($global_pick_list_values));



///保存判断
$smarty->assign("VALIDATASAVE",ldcrm_json_encode(getValidataSave($currentModule)));
//明细字段
//$smarty->assign("TABDETAILFIELDS",ldcrm_json_encode($ExpenseDetailFieldsHtml->tabDetailFieldData->TabDetailFields->getFieldListArray()));
$smarty->assign("ReferenceUitypes",cls_module_uitype::getAllUitypes());
$smarty->assign("UITYPEMODULES",cls_module_uitype::getUitypeModules());

 //布局规则
crm_load_class_file('cls_fieldrule','include/fields/fieldrule');
$fieldruleobj=cls_fieldrule::getInstance($currentModule);
$smarty->assign('jsonFieldRuleFieldNames',ldcrm_json_encode($fieldruleobj->getAllFieldNameSetChangeEvent()));//获取所有的触发字段
//editor:gyq_161 reason:带分录模块弹出层   2019/11/27 16:08
$arr = $ExpenseDetailFieldsHtml->detailPopup($smarty,$fields,$productFields);
ConvertTojsonString(1,$arr,"success");


?>