<?php
/*********************************************************************************
 *{*淇敼缂栫爜鏍煎紡:缁熶竴缂栫爜锛歎TF-8*} 
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
crm_load_class_file('CustomForm21DetailFieldsHtml','modules/CustomForm21');
$focus = CRMEntity::getInstance($currentModule);
$smarty = new lingdangCRM_Smarty;
if(isset($_REQUEST['record']) && isset($_REQUEST['record'])) {
    $focus->retrieve_entity_info($_REQUEST['record'],"CustomForm21");
     $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey('columnname',$focus->getSmownerColumName());
     if($focus->column_fields[$fieldinfo->getFieldName()]!=$current_user->id)
     {
           //闃叉鏁版嵁瓒婃潈璁块棶
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
$smarty->assign("SINGLE_MOD",'CustomForm21');
//$category = getParentTab();
//$smarty->assign("CATEGORY",$category);

$tabid = getTabid("CustomForm21");

$data = $focus->fieldobj->split_validationdataArray();
$smarty->assign("TEMPLATEPRINTS",$focus->getPrintTemplate($tabid)); //鎵撳嵃宸ュ叿

$smarty->assign("VALIDATION_DATA_FIELDNAME",$data['fieldname']);
$smarty->assign("VALIDATION_DATA_FIELDDATATYPE",$data['datatype']);
$smarty->assign("VALIDATION_DATA_FIELDLABEL",$data['fieldlabel']);
$focus->mode = 'Details';
if(isset($_REQUEST['record']) && isset($_REQUEST['record'])) {
    $focus->retrieve_entity_info($_REQUEST['record'],"CustomForm21");
    $focus->id = $_REQUEST['record'];
  
}
/* 璇︽儏椤垫寜閽?begin */
$focus->getModuleLogic($currentModule)->getDetailViewButton();
$smarty->assign('DETAILBUTTON',$focus->logic->detail_buttons);
$smarty->assign('APPROVESTATUS',$focus->logic->getApproveImage());//瀹℃壒鐘舵€佸浘鐗?
$smarty->assign('APPROVEMOD','1');//瀹℃壒妯″潡锛屾槸鍚﹀姞杞藉鎵瑰巻鍙?
$smarty->assign("MODULE",$currentModule);
//$smarty->assign("EDIT_PERMISSION",isPermitted($currentModule,'EditView',$_REQUEST['record']));

//if(PerformancePrefs::getBoolean('DETAILVIEW_RECORD_NAVIGATION', true) && isset($_SESSION[$currentModule.'_listquery'])){
//	$recordNavigationInfo = ListViewSession::getListViewNavigation($focus->id);
//	VT_detailViewNavigation($smarty,$recordNavigationInfo,$focus->id);
//}
//鏇村淇℃伅
$is_rel_list=isPresentRelatedLists($currentModule);
$is_rel_list=Detail_Edit_View::setForeachRelatedLists($is_rel_list);
$smarty->assign("IS_REL_LIST",$is_rel_list);
//$smarty->assign("USE_ASTERISK", get_use_asterisk($current_user->id));
$smarty->assign("EVENT_PERMISSION",'true');
$smarty->assign("SinglePane_View", $singlepane_view);
$smarty->assign('DETAILVIEW_AJAX_EDIT', PerformancePrefs::getBoolean('DETAILVIEW_AJAX_EDIT', true));

$CustomForm21DetailFieldsHtml = new CustomForm21DetailFieldsHtml($focus,$currentModule);
//echo $CustomForm21DetailFieldsHtml->getTabDetailFieldsHtml();echo '<br><br>';
$smarty->assign('TREXPENSE',$CustomForm21DetailFieldsHtml->getTabDetailFieldsHtml());

//鎵撳嵃
//$smarty->assign("TEMPLATEPRINTS",$focus->getPrintTemplate($tabid));

/* 鍏宠仈鍒涘缓 begin */
//$smarty->assign('QUICKACTIONLINK',$focus->logic->getActionUserd());
//$smarty->assign('ACTION_SHOW_NO',$focus->logic->getIsShowAction());
/* 鍏宠仈鍒涘缓 end */
 
$smarty->assign("ACCOUNTID",$focus->column_fields['account_id']);
//鑾峰彇瀹㈡埛鍜岃仈绯讳汉鍖哄潡淇℃伅
$block_info = getBlockDisplayInfo('AccountContacts');
//鏄剧ず浣嶇疆
$smarty->assign('DISPLAY_POSITION',$block_info['display_position']);
 //鏄惁鏄剧ず
if($block_info['is_display'] == 0)
    $smarty->assign('BESTATUS','YES');
else
    $smarty->assign('BESTATUS','NO');
global $global_pick_list_depencyfield;
crm_load_class_file('lingdang_DependencyPicklist','modules/PickList');
//$picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasource($currentModule);
//$smarty->assign("PICKIST_DEPENDENCY_DATASOURCE", ldcrm_json_encode($picklistDependencyDatasource));
$smarty->assign("PICKLISTDEPENCYFIELDS", ldcrm_json_encode($global_pick_list_depencyfield));    
include(globalStatic::$root_directory.'include/DetailViewBlockStatus.php');
$smarty->assign("PICKLISTCONTENT",ldcrm_json_encode($global_pick_list_values));
///淇濆瓨鍒ゆ柇
$smarty->assign("VALIDATASAVE",ldcrm_json_encode(getValidataSave($currentModule)));
$smarty->assign("HAVEMODCOMMENTS",'no');//自定义表单不需要评论
setGLobalURLSmarty($smarty);//设置js,css等访问路径
//单据编号重复提示
$smarty->assign('MODULEBILLNOTIP',$_SESSION[$currentModule.'_modulebillnotip']);
$_SESSION[$currentModule.'_modulebillnotip']='no';

//相关信息日期高级查询
//Crm_load_class_file("CommonView","modules/CustomView");
//$smarty->assign("DATETIMESTR",json_encode(CommonView::stdFilterDateTimeStr()));
//
$smarty->assign("ReferenceUitypes",cls_module_uitype::getAllUitypes());
$smarty->assign("UITYPEMODULES",cls_module_uitype::getUitypeModules());
DetailViewWidthTabDetail($currentModule,$focus,$smarty);
//布局规则
//crm_load_class_file('cls_fieldrule','include/fields/fieldrule');
//$fieldruleobj=cls_fieldrule::getInstance($currentModule);
//$smarty->assign('jsonFieldRuleFieldNames',ldcrm_json_encode($fieldruleobj->getAllFieldNameSetChangeEvent()));//获取所有的触发字段
//
//$smarty->display("DetailView/DetailRelated.tpl");
?>