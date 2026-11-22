<?php
/*********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*} 
 * The contents of this file are subject to the SugarCRM Public License Version 1.1.2
 * ("License"); You may not use this file except in compliance with the 
 * License. You may obtain a copy of the License at http://www.sugarcrm.com/SPL
 * Software distributed under the License is distributed on an  "AS IS"  basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
 * the specific language governing rights and limitations under the License.
 * The Original Code is:  SugarCRM Open Source
 * The Initial Developer of the Original Code is SugarCRM, Inc.
 * Portions created by SugarCRM are Copyright (C) SugarCRM, Inc.;
 * All Rights Reserved.
 * Contributor(s): ______________________________________.
 ********************************************************************************/
/*********************************************************************************
 * $Header: /advent/projects/wesat/lingdang_crm/sugarcrm/modules/CashBill/DetailView.php,v 1.37 2005/04/18 10:37:49 samk Exp $
 * Description:  TODO To be written.
 * Portions created by SugarCRM are Copyright (C) SugarCRM, Inc.
 * All Rights Reserved.
 * Contributor(s): ______________________________________..
 ********************************************************************************/
//zkt 20231014 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global  $currentModule, $singlepane_view;
$focus = CRMEntity::getInstance($currentModule);

//$list_buttons_moreD=$focus->getListButtons_moreforD($app_strings,$mod_strings);
if(isset($_REQUEST['record']) && isset($_REQUEST['record'])) {
    $focus->retrieve_entity_info($_REQUEST['record'],"CashBack");
    $focus->id = $_REQUEST['record'];
	 /**
	  * sendcashbillno 修改为 cashback_no
	  * @author Tujt 
	  */
    $focus->name=$focus->column_fields[$focus->list_link_field];
}

if(isset($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true') {
	$focus->id = "";
} 
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";

$smarty = new lingdangCRM_Smarty;

$smarty->assign("ACCOUNTID",$focus->column_fields['account_id']);
$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH", $image_path);
$smarty->assign("PRINT_URL", "phprint.php?jt=".session_id().$GLOBALS['request_string']);

/* 详情页按钮 begin */
$focus->getModuleLogic($currentModule)->getDetailViewButton();
$smarty->assign('DETAILBUTTON',$focus->logic->detail_buttons);
/* 详情页按钮 end */

if (isset($focus->name)) $smarty->assign("NAME", $focus->name);
else $smarty->assign("NAME", "");
global $detail_column_fields_value;

$smarty->assign("MODULELINKFIELD",$focus->list_link_field);
$smarty->assign("SMOWNERCOLUMNNAME",$focus->getSmownerColumName());
global $global_pick_list_values;
$blocks= getBlocks($currentModule,"detail_view",'',$focus->column_fields);
//$smarty->assign("COLUMN_FIELDS_VALUE",json_encode($detail_column_fields_value));
$smarty->assign("DETAILVIEWTITLE",getDetailViewTitleHtml($focus));
$smarty->assign("BLOCKS", $blocks);
//$fields=$focus->fieldobj->getFieldListArray();
//$smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));
$smarty->assign("CUSTOMFIELD", $cust_fld);
$smarty->assign("ID", $_REQUEST['record']);
$smarty->assign("SINGLE_MOD",'CashBill');
$category = getParentTab();
$smarty->assign("CATEGORY",$category);
$ProductDetailsHtml = crm_load_class_obj('cls_productDetailsHtml',"modules/$currentModule/ProductDetails",array($currentModule));
$smarty->assign('ASSOCIATED_PRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($focus,'details'));//产品明细html

$tabid = getTabid("CashBack");
$data =$focus->fieldobj->split_validationdataArray();

$smarty->assign("VALIDATION_DATA_FIELDNAME",$data['fieldname']);
$smarty->assign("VALIDATION_DATA_FIELDDATATYPE",$data['datatype']);
$smarty->assign("VALIDATION_DATA_FIELDLABEL",$data['fieldlabel']);

$smarty->assign("MODULE",$currentModule);
//$smarty->assign("EDIT_PERMISSION",isPermitted($currentModule,'EditView',$_REQUEST['record']));

//if(PerformancePrefs::getBoolean('DETAILVIEW_RECORD_NAVIGATION', true) && isset($_SESSION[$currentModule.'_listquery'])){
	//$recordNavigationInfo = ListViewSession::getListViewNavigation($focus->id);
	//VT_detailViewNavigation($smarty,$recordNavigationInfo,$focus->id);
//}
//更多信息
$is_rel_list=isPresentRelatedLists($currentModule);
$is_rel_list=Detail_Edit_View::setForeachRelatedLists($is_rel_list);

$smarty->assign("IS_REL_LIST",$is_rel_list);
//$smarty->assign("USE_ASTERISK", get_use_asterisk($current_user->id));
//
//$smarty->assign("SinglePane_View", $singlepane_view);
//
$smarty->assign('DETAILVIEW_AJAX_EDIT', PerformancePrefs::getBoolean('DETAILVIEW_AJAX_EDIT', true));

$sqlpayment="select nosendpayment,ld_sendpayment.sendpayment_no,ifnull(actualamount,0) as actualamount,ld_sendpayment.amount,ld_sendpayment.plandate,cpstatus,
                                ld_sendpayment.sendpaymentid ,ld_sendpayment.cpperiodtime,ld_sendpayment.purchaseorder_id ,ifnull(ld_sendcashbill2payment.amount,0) as curAmount,
                                ld_sendcashbill2payment.sendcashbillstatus,ld_sendcashbill.total,ld_sendcashbill.subtotal from ld_sendcashbill 
                                                    inner join ld_crmentity on ld_crmentity.crmid=ld_sendcashbill.sendcashbillid
                                                      left join ld_sendcashbill2payment on ld_sendcashbill2payment.sendcashbillid=ld_sendcashbill.sendcashbillid and ld_sendcashbill2payment.sendcashbillStatus=0 
                                                      left join ld_sendpayment on ld_sendpayment.sendpaymentid=ld_sendcashbill2payment.sendpaymentid
                                                      where ld_sendcashbill.deleted=0  and  ld_sendcashbill.sendcashbillid=".$focus->id." order by ld_sendpayment.sendpayment_no desc ";
$result=$adb->pquery($sqlpayment,array());

for($i=0;$i<$adb->num_rows($result);$i++)
{
               
    $j=$i+1;
    $trPayment.="<tr id='row".$j."'>";
    //$trPayment .='<td><input   checked onclick="checkedamount_click(this)" name="chkPayment'.$j.'" id="chkPayment'.$j.'" type="checkbox" value="0" /></td>';
    $trPayment .='<td> <a referencemodule="SendPayment" referencerecord="'.$adb->query_result($result,$i,"sendpaymentid").'"  onclick="DetailViewReferenceLinkClick(ld(this),event)">'.$adb->query_result($result,$i,"sendpayment_no").'</a>
                                    </td>';//编号
    $trPayment .='<td> '.$adb->query_result($result,$i,"cpstatus").'</td>';//状态
    $trPayment .='<td> '.$adb->query_result($result,$i,"cpperiodtime").'</td>';//期次
    $trPayment .='<td> '.$adb->query_result($result,$i,"plandate").'</td>';//计划日期
    $trPayment .='<td> '.number_format($adb->query_result($result,$i,"amount"),2).'</td>';
    $totalnopaymentamount=$adb->query_result($result,$i,"nosendpayment");
    $totalhavepaymentamount=$adb->query_result($result,$i,"subtotal");
    $havecashbill=$adb->query_result($result,$i,"actualamount")-$adb->query_result($result,$i,"curamount");
    $trPayment .='<td>'.number_format($havecashbill,2).'</td>';//已收金额
    $trPayment .='<td>'.number_format($adb->query_result($result,$i,"curamount"),2).'</td>';//本次收款
    $trPayment.="</tr>";
}
$smarty->assign("PAYMENTLIST",$trPayment);
$total=$totalhavepaymentamount+$totalnopaymentamount;
$smarty->assign("TOTALPAYMENTAMOUNT",number_format($total,2));
$smarty->assign("TOTALHAVEEPAYMENTAMOUNT",number_format($totalhavepaymentamount,2));
$smarty->assign("TOTALNOPAYMENTAMOUNT",number_format($totalnopaymentamount,2));
/**
 * edit:can
 * date:20140107
 * reason:控制面板页面设置可以修改字段标签
 * */
$sql='select fieldlabel from ld_field where tabid in(select tabid from ld_tab where name=\'sendpayment\') and (columnname=? or columnname=? or columnname=? or columnname=? or columnname=? or columnname=?) order by columnname asc';
$result=$adb->pquery($sql,array('sendpayment_no','cpstatus','cpperiodtime','plandate','amount','actualamount'));
$thHtml='';
$fieldlabel=$adb->query_result($result,5,0);//付款计划编号
$thHtml.='<th>'.getTranslatedString($fieldlabel,'SendPayment').'</th>';
$fieldlabel=$adb->query_result($result,3,0);//状态
$thHtml.='<th>'.getTranslatedString($fieldlabel,'SendPayment').'</th>';
$fieldlabel=$adb->query_result($result,2,0);//期次
$thHtml.='<th>'.getTranslatedString($fieldlabel,'SendPayment').'</th>';
$fieldlabel=$adb->query_result($result,4,0);//计划回款日期
$thHtml.='<th>'.getTranslatedString($fieldlabel,'SendPayment').'</th>';
$fieldlabel=$adb->query_result($result,1,0);//金额
$thHtml.='<th>'.getTranslatedString($fieldlabel,'SendPayment').'</th>';
$fieldlabel=$adb->query_result($result,0,0);//已付金额
$thHtml.='<th>'.getTranslatedString($fieldlabel,'SendPayment').'</th>';
//$fieldlabel=$adb->query_result($result,$i,)
$smarty->assign('THHTML',$thHtml);
$smarty->assign("TEMPLATEPRINTS",$focus->getPrintTemplate($tabid));
//$smarty->display("Inventory/InventoryDetailView.tpl");
$fields=$focus->fieldobj->getFieldListArray();
$fields['module']=$currentModule;
$smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));
/* 关联创建 begin */
//$smarty->assign('QUICKACTIONLINK',$focus->logic->getActionUserd());
//$smarty->assign('ACTION_SHOW_NO',$focus->logic->getIsShowAction());
/* 关联创建 end */

//andy
//$tabid=getTabid($currentModule);
//$actions_arr_userd=GetAction_userd($tabid);
//$smarty->assign('actions_arr_userd',$actions_arr_userd);
////print_r($actions_arr_userd);
//if(count($actions_arr_userd) == 0)
    //$smarty->assign('action_show_no','yes');
/*
 * edit:yangliu
 * date:2014-07-30
 * reason:明细界面更多按钮权限判断
 * 判断数组是否为空
 */
//print_r($list_buttons_moreD);
//if(count($list_buttons_moreD)){
    //$smarty->assign('LISTBUTTONMOREFORD','YES');
//}
//else{
    //$smarty->assign('LISTBUTTONMOREFORD','NO');
//}
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

setGLobalURLSmarty($smarty);//设置js,css等访问路径

//单据编号重复提示
$smarty->assign('MODULEBILLNOTIP',$_SESSION[$currentModule.'_modulebillnotip']);
$_SESSION[$currentModule.'_modulebillnotip']='no';

$smarty->assign("ReferenceUitypes",cls_module_uitype::getAllUitypes());
$smarty->assign("UITYPEMODULES",cls_module_uitype::getUitypeModules());

DetailViewReturnWithProductDetail($currentModule,$focus,$ProductDetailsHtml,$smarty);

/*布局规则
crm_load_class_file('cls_fieldrule','include/fields/fieldrule');
$fieldruleobj=cls_fieldrule::getInstance($currentModule);
$smarty->assign('jsonFieldRuleFieldNames',ldcrm_json_encode($fieldruleobj->getAllFieldNameSetChangeEvent()));//获取所有的触发字段

$smarty->display("DetailView/InventoryDetailRelated.tpl");*/

?>