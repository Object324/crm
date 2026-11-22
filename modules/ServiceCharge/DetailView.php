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

//zkt 20231014 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();

global $theme;
global  $currentModule,$navigationInfo;
global $current_user;
require('user_privileges/user_language_'.$current_user->id.'.php');
$smarty = new lingdangCRM_Smarty;
$focus = CRMEntity::getInstance($currentModule);
if(isset($_REQUEST['record'])) {
    $focus->retrieve_entity_info($_REQUEST['record'],"ServiceCharge");
    $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey('columnname',$focus->getSmownerColumName());
	if(!empty($fieldinfo)){
		if($focus->column_fields[$fieldinfo->getFieldName()]!=$current_user->id){
				crm_load_class_file('cls_CurUserDataScope','include/ListView');
				$datascopeobj=cls_CurUserDataScope::getInstance($currentModule,'record');
				$datascopeobj->isMyViewData($_REQUEST['record']);
		}
	}
    $focus->id = $_REQUEST['record'];	
    $focus->name=$focus->column_fields[$focus->list_link_field];
}
if(isset($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true') {
	$focus->id = "";
}
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";
$smarty->assign('ACCOUNTS_ACTIVATE',vtlib_isModuleActive('Accounts'));


/* 详情页按钮 begin */
$focus->getModuleLogic($currentModule)->getDetailViewButton();
$smarty->assign('DETAILBUTTON',$focus->logic->detail_buttons);
$smarty->assign('APPROVESTATUS',$focus->logic->getApproveImage());//审批状态图片
$smarty->assign('APPROVEMOD','1');//审批模块，是否加载审批历史
/* 详情页按钮 end */

$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH", $image_path);
$smarty->assign("PRINT_URL", "phprint.php?jt=".session_id().$GLOBALS['request_string']);

if (isset($focus->name)) $smarty->assign("NAME", $focus->name);
else $smarty->assign("NAME", "");

crm_load_class_file('Detail_Edit_View','include/utils');
$smarty->assign('CONTACTID',Detail_Edit_View::getAccountPrimaryContactInfo($focus));

global $detail_column_fields_value;

$smarty->assign("MODULELINKFIELD",$focus->list_link_field);
$smarty->assign("SMOWNERCOLUMNNAME",$focus->getSmownerColumName());
global $global_pick_list_values;
$blocks= getBlocks($currentModule,"detail_view",'',$focus->column_fields);
//$smarty->assign("COLUMN_FIELDS_VALUE",ldcrm_json_encode($detail_column_fields_value));
$smarty->assign("BLOCKS", $blocks);
$smarty->assign("DETAILVIEWTITLE",getDetailViewTitleHtml($focus));
//放在getblock函数后面，否则会影响布局规则
//$fields=$focus->fieldobj->getFieldListArray();
//$smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));

$smarty->assign("CUSTOMFIELD", $cust_fld);
$smarty->assign("ID", $_REQUEST['record']);
$smarty->assign("SINGLE_MOD",'Accounts');
//$category = getParentTab();
//$smarty->assign("CATEGORY",$category);

$tabid = getTabid("ServiceCharge");

$data =$focus->fieldobj->split_validationdataArray();

$smarty->assign("VALIDATION_DATA_FIELDNAME",$data['fieldname']);
$smarty->assign("VALIDATION_DATA_FIELDDATATYPE",$data['datatype']);
$smarty->assign("VALIDATION_DATA_FIELDLABEL",$data['fieldlabel']);
      

$smarty->assign("MODULE",'ServiceCharge');


/*上一条和下一条数据信息*/
if(PerformancePrefs::getBoolean('DETAILVIEW_RECORD_NAVIGATION', true) && isset($_SESSION[$currentModule.'_listquery'])){

	//$recordNavigationInfo = ListViewSession::getListViewNavigation($focus->id);

//	VT_detailViewNavigation($smarty,$recordNavigationInfo,$focus->id);
}
//更多信息
$is_rel_list=isPresentRelatedLists($currentModule);
$is_rel_list=Detail_Edit_View::setForeachRelatedLists($is_rel_list);
$smarty->assign("IS_REL_LIST",$is_rel_list);
//$smarty->assign("USE_ASTERISK", get_use_asterisk($current_user->id));

$smarty->assign("EVENT_PERMISSION",'true');

$smarty->assign("ASSIGNUSERID",$focus->column_fields["assigned_user_id"]);

$smarty->assign('DETAILVIEW_AJAX_EDIT', PerformancePrefs::getBoolean('DETAILVIEW_AJAX_EDIT', true));

$smarty->assign('ACCOUNTID',$focus->id);

//$smarty->assign("TEMPLATEPRINTS",$focus->getPrintTemplate($tabid));

/**
 * 基础版，销售通，因为只有合同订单模块，所以没必要显示往来对账
 * @author Tujt 2014-06-12
 */
$reg = RegOp::getInstance();
$testFile = $reg->isExistFile();
if($testFile == 0){//不存在
    require_once("VersionType.php");
    global $VersionNo;
    $RegisterVersionNo = $VersionNo;
}else{
    $RegisterVersionNo = $reg->GetVersionNo();
}

$modbalancestr = '';
if($RegisterVersionNo != '2'&&$RegisterVersionNo!='7'){//基础版，销售通，不显示往来对账
	/**
	 * @project PROT21 龙威机械：往来对账
	 * @author Tujt 2014-06-06
	 */
	$modbalance = array('SalesOrder','CashBill','SalesBack','CashBack');
	if($current_user->is_admin == 'on'){
		foreach($modbalance as $mod){
			if(vtlib_isModuleActive($mod))
				$modbalancestr .= $mod.',';
		}
	}else{
		foreach($modbalance as $mod){
			if(isPermitted($mod,'index','')=='yes' && vtlib_isModuleActive($mod))
				$modbalancestr .= $mod.',';
		}
	}
	$modbalancestr = trim($modbalancestr,',');
}
$smarty->assign('MODBALANCESTR',$modbalancestr);
if(vtlib_isModuleActive('Contacts'))
	$smarty->assign('CONTACTSSTATUS','yes');
else
	$smarty->assign('CONTACTSSTATUS','no');
/* 关联创建 begin */
//$smarty->assign('QUICKACTIONLINK',$focus->logic->getActionUserd());
//$smarty->assign('ACTION_SHOW_NO',$focus->logic->getIsShowAction());
/* 关联创建 end */

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


//相关信息日期高级查询
//Crm_load_class_file("CommonView","modules/CustomView");
//$smarty->assign("DATETIMESTR",json_encode(CommonView::stdFilterDateTimeStr()));
$smarty->assign("ReferenceUitypes",cls_module_uitype::getAllUitypes());
$smarty->assign("UITYPEMODULES",cls_module_uitype::getUitypeModules());
/*布局规则
crm_load_class_file('cls_fieldrule','include/fields/fieldrule');
$fieldruleobj=cls_fieldrule::getInstance($currentModule);
$smarty->assign('jsonFieldRuleFieldNames',ldcrm_json_encode($fieldruleobj->getAllFieldNameSetChangeEvent()));//获取所有的触发字段

$smarty->display("DetailView/DetailRelated.tpl"); */
DetailViewReturn($currentModule,$focus,$smarty);
?>