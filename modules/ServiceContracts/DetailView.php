<?php
/*+**********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ************************************************************************************/
//zkt 20231014 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global  $currentModule, $current_user, $theme,$adb;

$focus = CRMEntity::getInstance($currentModule);
$fieldobj=Field::getInstance($currentModule,$adb);
//$tool_buttons = Button_Check($currentModule);
$smarty = new lingdangCRM_Smarty();

$record = $_REQUEST['record'];
$isduplicate = vtlib_purify($_REQUEST['isDuplicate']);
$tabid = getTabid($currentModule);
/*
 * edit:yangliu
 * date:2014-07-28
 * reason:明细界面更多按钮权限判断
 */
//$list_buttons_moreD=$focus->getListButtons_moreforD($app_strings,$mod_strings); 

if($record != '') {
	$focus->id = $record;
	$focus->retrieve_entity_info($record, $currentModule);
    $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey('columnname',$focus->getSmownerColumName());
	if(!empty($fieldinfo)){
		 if($focus->column_fields[$fieldinfo->getFieldName()]!=$current_user->id)
		 {
		  
				crm_load_class_file('cls_CurUserDataScope','include/ListView');
				$datascopeobj=cls_CurUserDataScope::getInstance($currentModule,'record');
				$datascopeobj->isMyViewData($_REQUEST['record']);
		 }
	}
}
$smarty->assign("ACCOUNTID",$focus->column_fields['account_id']);
$smarty->assign("CONTACTID",$focus->column_fields['contact_id']);
$smarty->assign("SALESORDERID",$focus->column_fields['salesorder_id']);
if($isduplicate == 'true') $focus->id = '';

/* 详情页按钮 begin */
$focus->getModuleLogic($currentModule)->getDetailViewButton();
$smarty->assign('DETAILBUTTON',$focus->logic->detail_buttons);
$smarty->assign('APPROVESTATUS',$focus->logic->getApproveImage());//审批状态图片
/* 详情页按钮 end */

// Identify this module as custom module.
$smarty->assign('CUSTOM_MODULE', true);
$smarty->assign('APPROVEMOD','1');//审批模块，是否加载审批历史
$smarty->assign('APP', $app_strings);
$smarty->assign('MOD', $mod_strings);

$smarty->assign('MODULE', $currentModule);
// TODO: Update Single Module Instance name here.
$smarty->assign('SINGLE_MOD', 'SINGLE_'.$currentModule); 
$smarty->assign('IMAGE_PATH', "themes/$theme/images/");
$smarty->assign('THEME', $theme);
$smarty->assign('ID', $focus->id);
$smarty->assign('MODE', $focus->mode);

$recordName = $focus->column_fields[$focus->list_link_field];
$smarty->assign('NAME', $recordName);
//$smarty->assign('UPDATEINFO',updateInfo($focus->id));

// Module Sequence Numbering
$mod_seq_field = $fieldobj->FieldInfoListByKeyValue('uitype',4);
if ($mod_seq_field != null) {
	$mod_seq_id = $focus->column_fields[$mod_seq_field['fieldname']];
} else {
	$mod_seq_id = $focus->id;
}
$smarty->assign('MOD_SEQ_ID', $mod_seq_id);
// END
global $detail_column_fields_value;

$smarty->assign("MODULELINKFIELD",$focus->list_link_field);
$smarty->assign("SMOWNERCOLUMNNAME",$focus->getSmownerColumName());
global $global_pick_list_values;
$blocks= getBlocks($currentModule,"detail_view",'',$focus->column_fields);

$smarty->assign("COLUMN_FIELDS_VALUE",ldcrm_json_encode($detail_column_fields_value));
$smarty->assign("BLOCKS", $blocks);
$smarty->assign("DETAILVIEWTITLE",getDetailViewTitleHtml($focus));
//放在getblock函数后面，否则会影响布局规则
//$fields=$focus->fieldobj->getFieldListArray();
//$smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));

$validationArray = $focus->fieldobj->split_validationdataArray();
$smarty->assign('VALIDATION_DATA_FIELDNAME',$validationArray['fieldname']);
$smarty->assign('VALIDATION_DATA_FIELDDATATYPE',$validationArray['datatype']);
$smarty->assign('VALIDATION_DATA_FIELDLABEL',$validationArray['fieldlabel']);

//$smarty->assign('CHECK', $tool_buttons);

//if(PerformancePrefs::getBoolean('DETAILVIEW_RECORD_NAVIGATION', true) && isset($_SESSION[$currentModule.'_listquery'])){
//	$recordNavigationInfo = ListViewSession::getListViewNavigation($focus->id);
//	VT_detailViewNavigation($smarty,$recordNavigationInfo,$focus->id);
//}
$is_rel_list=isPresentRelatedLists($currentModule);
$is_rel_list=Detail_Edit_View::setForeachRelatedLists($is_rel_list);

$smarty->assign('IS_REL_LIST', $is_rel_list);
$smarty->assign('SinglePane_View', $singlepane_view);

$smarty->assign('DETAILVIEW_AJAX_EDIT', PerformancePrefs::getBoolean('DETAILVIEW_AJAX_EDIT', true));
//if(isPermitted("ServiceContracts","Copy","") == 'yes'){
    //$smarty->assign("EDIT_DUPLICATE","permitted");
    //$list_buttons_moreD['copy'] = getFixedLabel('COPY');
//}
//$smarty->assign("TEMPLATEPRINTS",$focus->getPrintTemplate($tabid));
// if(isPermitted("Attachment","Create",'') == 'yes' && vtlib_isModuleActive('Attachment'))
///	$smarty->assign("CREATEATTACHMENT","permitted");
    
//打印
//$smarty->assign("TEMPLATEPRINTS",$focus->getPrintTemplate($tabid));

/* 关联创建 begin */
//$smarty->assign('QUICKACTIONLINK',$focus->logic->getActionUserd());
//$smarty->assign('ACTION_SHOW_NO',$focus->logic->getIsShowAction());

$ProductDetailsHtml = crm_load_class_obj('cls_productDetailsHtml',"modules/$currentModule/ProductDetails",array($currentModule));
$smarty->assign('ASSOCIATED_PRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($focus,'details'));//产品明细html

if(isset($_REQUEST['record']) && isset($_REQUEST['record'])) {
    $focus->retrieve_entity_info($_REQUEST['record'],"ServiceContracts");
    $focus->id = $_REQUEST['record'];
    $focus->name=$focus->column_fields[$focus->list_link_field];
}


/**
andrew
date 20141124
reason 创建回款计划时，回款计划总额与未计划金额的判断对比提示

$deployarray=getSys_deploy(59);
$deployvalue = $deployarray['deploy_value'];
$sqlServiceContracts='SELECT
                    	ld_account.accountname,
                    	contract_no,
                    	total,
                    	subtotal,
                    	ld_account.accountid
                    FROM
                    	ld_servicecontracts
                    INNER JOIN ld_account ON ld_servicecontracts.accountid = ld_account.accountid
                    WHERE
                    	ld_servicecontracts.servicecontractsid = '.$_REQUEST['record'];

$ServiceContractsresult=$adb->pquery($sqlServiceContracts,array());
$total=$adb->query_result($ServiceContractsresult,0,"total");
$sql="SELECT
        	ifnull(amount, 0),
        	entitytypeid,
        	periodtime
        FROM
        	ld_paymentplan
        WHERE
        	deleted = 0 AND entitytype='ServiceContracts' 
        AND entitytypeid =".$_REQUEST['record'].' 
        group by periodtime order by periodtime asc';

$paymentresult=$adb->pquery($sql,array());
if($adb->num_rows($paymentresult)>0)//如果有回款计划
{
    for($i=0;$i<$adb->num_rows($paymentresult);$i++)
    {
        $paymentamount+=$adb->query_result($paymentresult,$i,0);//获取服务合同的合计计划金额
    }
    $nopaymentamount=$total-$paymentamount;    
}
if($deployvalue == 1 || $adb->num_rows($paymentresult)<=0)
{
    $smarty->assign('DeployType', 0);
}
else
{
    if($nopaymentamount == 0)
    {
        $smarty->assign('DeployType', 1);
    }
    else if($nopaymentamount < 0)
    {
        $smarty->assign('DeployType', 2);
    }
    else
    {
        $smarty->assign('DeployType', 0);
    }   
}
*/
$deployarray=getSys_deploy(58);
$deployvalue = $deployarray['deploy_value'];
$smarty->assign('DEPLOYVALUE',$deployvalue);
if(isPermitted("PaymentPlan","EditView",'') == 'yes'&&vtlib_isModuleActive('PaymentPlan'))
{
    $smarty->assign("PAYMENTPLANEDIT","permitted");
    $smarty->assign("PAYMENTPLANCREATE","permitted");
    
}
if(isset($_REQUEST['salestype']) &&$_REQUEST['salestype']=='yes' &&!isset($_REQUEST['autocreate']) )
{
    $smarty->assign('CREATE','yes');
}
/**
 * 因为回款计划模块没有创建权限，所以这儿判断编辑权限
 * @reason 0014893: 服务合同>明细,关于新增回款计划的问题
 * @author Tujt 2015-05-12
 */
//if(isPermitted('Project','Create','')=="yes"&&vtlib_isModuleActive('Project'))
//{
//    $smarty->assign("ProjectEditView","permitted");
//}
//$fields=$focus->fieldobj->getFieldListArray();
//$fields['module']=$currentModule;
//$smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));
$smarty->assign('KISERROR',$_SESSION['kiserror']);
//获取客户和联系人区块信息
$block_info = getBlockDisplayInfo('AccountContacts');
//显示位置
$smarty->assign('DISPLAY_POSITION',$block_info['display_position']);
 //是否显示
if($block_info['is_display'] == 0)
    $smarty->assign('BESTATUS','YES');
else
    $smarty->assign('BESTATUS','NO');
global $global_pick_list_depencyfield;
crm_load_class_file('lingdang_DependencyPicklist','modules/PickList');
$picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasource($currentModule);
//$smarty->assign("PICKIST_DEPENDENCY_DATASOURCE", ldcrm_json_encode($picklistDependencyDatasource));
//$smarty->assign("PICKLISTDEPENCYFIELDS", ldcrm_json_encode($global_pick_list_depencyfield));
include(globalStatic::$root_directory.'include/DetailViewBlockStatus.php');
$smarty->assign("PICKLISTCONTENT",ldcrm_json_encode($global_pick_list_values));

///保存判断
//$smarty->assign("VALIDATASAVE",ldcrm_json_encode(getValidataSave($currentModule)));
setGLobalURLSmarty($smarty);//设置js,css等访问路径
//单据编号重复提示
$smarty->assign('MODULEBILLNOTIP',$_SESSION[$currentModule.'_modulebillnotip']);
$_SESSION[$currentModule.'_modulebillnotip']='no';
DetailViewReturnWithProductDetail($currentModule,$focus,$ProductDetailsHtml,$smarty);

//相关信息日期高级查询
/*
Crm_load_class_file("CommonView","modules/CustomView");
$smarty->assign("DATETIMESTR",json_encode(CommonView::stdFilterDateTimeStr()));
$smarty->assign("ReferenceUitypes",cls_module_uitype::getAllUitypes());
$smarty->assign("UITYPEMODULES",cls_module_uitype::getUitypeModules());
//布局规则
crm_load_class_file('cls_fieldrule','include/fields/fieldrule');
$fieldruleobj=cls_fieldrule::getInstance($currentModule);
$smarty->assign('jsonFieldRuleFieldNames',ldcrm_json_encode($fieldruleobj->getAllFieldNameSetChangeEvent()));//获取所有的触发字段

$smarty->display("DetailView/InventoryDetailRelated.tpl");

$_SESSION['kiserror']='';
unset($mod_strings);
unset($app_strings);*/
?>