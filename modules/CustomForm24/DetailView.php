<?php
/*********************************************************************************
 *{*娣囶喗鏁肩紓鏍垳閺嶇厧绱?缂佺喍绔寸紓鏍垳閿涙瓗TF-8*} 
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
//zkt 20231014 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();

global $app_list_strings,$theme;
global  $currentModule, $singlepane_view;
crm_load_class_file('CustomForm24DetailFieldsHtml','modules/CustomForm24');
$focus = CRMEntity::getInstance($currentModule);
$smarty = new lingdangCRM_Smarty;
if(isset($_REQUEST['record']) && isset($_REQUEST['record'])) {
    $focus->retrieve_entity_info($_REQUEST['record'],"CustomForm24");
     $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey('columnname',$focus->getSmownerColumName());
     if($focus->column_fields[$fieldinfo->getFieldName()]!=$current_user->id)
     {
           //闂冨弶顒涢弫鐗堝祦鐡掑﹥娼堢拋鍧楁６
            crm_load_class_file('cls_CurUserDataScope','include/ListView');
            $datascopeobj=cls_CurUserDataScope::getInstance($currentModule,'record');
            $datascopeobj->isMyViewData($_REQUEST['record']);
     }
    $focus->id = $_REQUEST['record'];
   $focus->name=$focus->column_fields[$focus->list_link_field];

}
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";

$smarty->assign("MOD", $mod_strings);
$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH", $image_path);
$smarty->assign("PRINT_URL", "phprint.php?jt=".session_id().$GLOBALS['request_string']);
 
if (isset($focus->name)) $smarty->assign("NAME", $focus->name);
else $smarty->assign("NAME", "");
global $detail_column_fields_value;

$smarty->assign("MODULELINKFIELD",$focus->list_link_field);
$smarty->assign("SMOWNERCOLUMNNAME",$focus->getSmownerColumName());
global $global_pick_list_values;
$blocks= getBlocks($currentModule,"detail_view",'',$focus->column_fields);
$smarty->assign("COLUMN_FIELDS_VALUE",ldcrm_json_encode($detail_column_fields_value));
$smarty->assign("DETAILVIEWTITLE",getDetailViewTitleHtml($focus));
$smarty->assign("BLOCKS", $blocks);
//放在getblock函数后面，否则会影响布局规则
//$fields=$focus->fieldobj->getFieldListArray();
//$smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));
$smarty->assign("CUSTOMFIELD", $cust_fld);
$smarty->assign("ID", $_REQUEST['record']);
$smarty->assign("SINGLE_MOD",'CustomForm24');
//$category = getParentTab();
//$smarty->assign("CATEGORY",$category);

$tabid = getTabid("CustomForm24");

$data = $focus->fieldobj->split_validationdataArray();
$smarty->assign("TEMPLATEPRINTS",$focus->getPrintTemplate($tabid)); //閹垫挸宓冨銉ュ徔

$smarty->assign("VALIDATION_DATA_FIELDNAME",$data['fieldname']);
$smarty->assign("VALIDATION_DATA_FIELDDATATYPE",$data['datatype']);
$smarty->assign("VALIDATION_DATA_FIELDLABEL",$data['fieldlabel']);
$focus->mode = 'Details';
if(isset($_REQUEST['record']) && isset($_REQUEST['record'])) {
    $focus->retrieve_entity_info($_REQUEST['record'],"CustomForm24");
    $focus->id = $_REQUEST['record'];
  
}
/* 鐠囷附鍎忔い鍨瘻闁?begin */
$focus->getModuleLogic($currentModule)->getDetailViewButton();
$smarty->assign('DETAILBUTTON',$focus->logic->detail_buttons);
$smarty->assign('APPROVESTATUS',$focus->logic->getApproveImage());//鐎光剝澹掗悩鑸碘偓浣告禈閻?
$smarty->assign('APPROVEMOD','1');//鐎光剝澹掑Ο鈥虫健閿涘本妲搁崥锕€濮炴潪钘夘吀閹电懓宸婚崣?
$smarty->assign("MODULE",$currentModule);
//$smarty->assign("EDIT_PERMISSION",isPermitted($currentModule,'EditView',$_REQUEST['record']));

//if(PerformancePrefs::getBoolean('DETAILVIEW_RECORD_NAVIGATION', true) && isset($_SESSION[$currentModule.'_listquery'])){
	//$recordNavigationInfo = ListViewSession::getListViewNavigation($focus->id);
//	VT_detailViewNavigation($smarty,$recordNavigationInfo,$focus->id);
//}
//閺囨潙顦挎穱鈩冧紖
$is_rel_list=isPresentRelatedLists($currentModule);
$is_rel_list=Detail_Edit_View::setForeachRelatedLists($is_rel_list);
$smarty->assign("IS_REL_LIST",$is_rel_list);
//$smarty->assign("USE_ASTERISK", get_use_asterisk($current_user->id));
$smarty->assign("EVENT_PERMISSION",'true');
$smarty->assign("SinglePane_View", $singlepane_view);
$smarty->assign('DETAILVIEW_AJAX_EDIT', PerformancePrefs::getBoolean('DETAILVIEW_AJAX_EDIT', true));

$CustomForm24DetailFieldsHtml = new CustomForm24DetailFieldsHtml($focus,$currentModule);
//echo $CustomForm24DetailFieldsHtml->getTabDetailFieldsHtml();echo '<br><br>';
$smarty->assign('TREXPENSE',$CustomForm24DetailFieldsHtml->getTabDetailFieldsHtml());

//閹垫挸宓?
//$smarty->assign("TEMPLATEPRINTS",$focus->getPrintTemplate($tabid));

/* 閸忓疇浠堥崚娑樼紦 begin */
//$smarty->assign('QUICKACTIONLINK',$focus->logic->getActionUserd());
//$smarty->assign('ACTION_SHOW_NO',$focus->logic->getIsShowAction());
/* 閸忓疇浠堥崚娑樼紦 end */
 
$smarty->assign("ACCOUNTID",$focus->column_fields['account_id']);
//閼惧嘲褰囩€广垺鍩涢崪宀冧粓缁姹夐崠鍝勬健娣団剝浼?
$block_info = getBlockDisplayInfo('AccountContacts');
//閺勫墽銇氭担宥囩枂
$smarty->assign('DISPLAY_POSITION',$block_info['display_position']);
 //閺勵垰鎯侀弰鍓с仛
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
///娣囨繂鐡ㄩ崚銈嗘焽
//$smarty->assign("VALIDATASAVE",ldcrm_json_encode(getValidataSave($currentModule)));
$smarty->assign("HAVEMODCOMMENTS",'no');//自定义表单不需要评论
setGLobalURLSmarty($smarty);//设置js,css等访问路径
//单据编号重复提示
$smarty->assign('MODULEBILLNOTIP',$_SESSION[$currentModule.'_modulebillnotip']);
$_SESSION[$currentModule.'_modulebillnotip']='no';

//相关信息日期高级查询
//Crm_load_class_file("CommonView","modules/CustomView");
//$smarty->assign("DATETIMESTR",json_encode(CommonView::stdFilterDateTimeStr()));
$smarty->assign("ReferenceUitypes",cls_module_uitype::getAllUitypes());
$smarty->assign("UITYPEMODULES",cls_module_uitype::getUitypeModules());
DetailViewWidthTabDetail($currentModule,$focus,$smarty);

?>