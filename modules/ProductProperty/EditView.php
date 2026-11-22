<?php
/*+**********************************************************************************
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ************************************************************************************/
global $current_language, $currentModule, $theme;
global $adb;
//zkt 20231012 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();

crm_load_class_file('cls_ParentRelatedFields', 'include/RelatedFields');
crm_load_class_file('ProductPropertyDetailFieldsHtml', 'modules/ProductProperty');
$cls_tabledetail_focus = cls_ParentRelatedFields::getInstance($currentModule, '', 583);
$focus = CRMEntity::getInstance($currentModule);
$smarty = new lingdangCRM_Smarty();

//$category = getParentTab($currentModule);
$record = $_REQUEST['record'];
$setListVal = 0;
$befidval = array();
$selck = '';
$isduplicate = vtlib_purify($_REQUEST['isDuplicate']);
$searchurl = getBasic_Advance_SearchURL();
$smarty->assign("SEARCH", $searchurl);
$currencyid = 1;
$conversion_rate = 1;
$focus->mode = 'create';
$smarty->assign('MODULE_ACTIVATE', vtlib_isModuleActive('ProductProperty'));
$sourcemodules = getSourceModule($currentModule);
foreach ($sourcemodules as $sourceinfo) {
    $source_mod[] = $sourceinfo['entitytype'];
}
if ($record) {
    $focus->id = $record;
    $focus->mode = 'edit';
    if (isset ($_REQUEST['convertmode']) && $_REQUEST['convertmode'] == 'update_so_val') {
        foreach ($focus->column_fields as $fieldname => $val) {
            if (isset ($_REQUEST[$fieldname])) {
                $value = $_REQUEST[$fieldname];
                $focus->column_fields[$fieldname] = $value;
            }
        }
    } else {
        $focus->retrieve_entity_info($record, $currentModule);
        $fieldinfo = $focus->fieldobj->getFieldInfoobjBykey('columnname', $focus->getSmownerColumName());
        if ($focus->column_fields[$fieldinfo->getFieldName()] != $current_user->id) {

            crm_load_class_file('cls_CurUserDataScope', 'include/ListView');
            $datascopeobj = cls_CurUserDataScope::getInstance($currentModule, 'record');
            $datascopeobj->isMyViewData($_REQUEST['record']);
        }
    }
}
if (!empty($_REQUEST['fromid']) && !empty($_REQUEST['frommodule'])) {
    $entitytypeid = $_REQUEST['fromid'];

    if (!in_array($_REQUEST['frommodule'], $source_mod)) {
        $entitytypeid = 0;
    }
}


$version_info = getVersionInfo();
$smarty->assign('VERSIONTRADE',$version_info['trade']);
$smarty->assign('VERSION_ACCOUNT',$version_info['account']);

if (isset ($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true') {
    $smarty->assign("DUPLICATE_FROM", $focus->id);
    $focus->id = "";
    $focus->mode = '';

    //$focus->column_fields['assigned_user_id'] = $current_user->id;
}
if (empty($_REQUEST['record']) && $focus->mode != 'edit') {
    setObjectValuesFromRequest($focus);
}



if (!empty($_REQUEST['fromid']) && !empty($_REQUEST['frommodule']) && in_array($_REQUEST['frommodule'], $source_mod)) {
    $currency_info = getModuleCurrencyInfo($_REQUEST['fromid'], $_REQUEST['frommodule']);
    $focus->column_fields['currency_id'] = $currency_info['curid'];
    $entitytypeid = $_REQUEST['fromid'];
}
$disp_view = getView($focus->mode);


$isallow = $focus->Library('SystemCode')->getModentityfield('isallow', $currentModule);
$smarty->assign('ISALLOW', $isallow);

if ($focus->mode == 'edit') {
    $smarty->assign('CURRENCYID', $focus->column_fields['currency_id']);
    $smarty->assign('CONVERSIONRATE', $focus->column_fields['conversion_rate']);
} else {
    $smarty->assign('CURRENCYID', $currencyid);
    $smarty->assign('CONVERSIONRATE', $conversion_rate);
}

if ($focus->mode != 'edit') {
    $value = $focus->Library('SystemCode')->getModuleSeqNumRecord($_REQUEST['module']);
    if (!$value) $value = getFixedLabel('MSG_AUTO_GEN_ON_SAVE');
    $focus->column_fields['productproperty_no'] = $value;
}

if (isset($_REQUEST['parent_id']) && $_REQUEST['parent_id'] > 0) {
    $focus->getModuleLogic($currentModule)->setQuickCreateColumn($_REQUEST['parent_module'], $_REQUEST['parent_id']);
}
if (isset($_REQUEST['fromid']) && $_REQUEST['fromid'] > 0) {
    $focus->getModuleLogic($currentModule)->setQuickCreateColumnValues($currentModule, $_REQUEST['fromid']);
    if (!empty($_REQUEST['frommodule']) && ($_REQUEST['frommodule'] == 'ServiceContracts' || $_REQUEST['frommodule'] == 'SalesOrder')) {
        $frommodule_focus = CRMEntity::getInstance($_REQUEST['frommodule']);
        $frommodule_focus->retrieve_entity_info($_REQUEST['fromid'], $_REQUEST['frommodule']);
        if (!empty($frommodule_focus->column_fields['account_id'])) {
            $focus->column_fields['account_id'] = $frommodule_focus->column_fields['account_id'];
        }
    }
}

global $global_pick_list_values, $edit_column_fields_value;
$act_data = getBlocks($currentModule, $disp_view, $mode, $focus->column_fields);
$smarty->assign("COLUMN_FIELDS_VALUE", ldcrm_json_encode($edit_column_fields_value));

if (isset($act_data['RichText']) && !empty($act_data['RichText'])) {
    $richText = $act_data['RichText'];
    unset($act_data['RichText']);
    $smarty->assign('RICHTEXTBOX', implode(',', $richText));
    $smarty->assign('RICHTEXTCOUNT', sizeof($richText));
} else {
    $smarty->assign('RICHTEXTBOX', '');
    $smarty->assign('RICHTEXTCOUNT', '0');
}
$smarty->assign('BLOCKS', $act_data);
$ProductPropertyDetailFieldsHtml = new ProductPropertyDetailFieldsHtml($focus, $currentModule);


//$smarty->assign('BASBLOCKS', getBlocks($currentModule, $disp_view, $focus->mode, $focus->column_fields, 'BAS'));
$smarty->assign('OP_MODE', $disp_view);

$smarty->assign('MODULE', $currentModule);

// TODO: Update Single Module Instance name here.
$smarty->assign('SINGLE_MOD', 'SINGLE_' . $currentModule);
$smarty->assign('CATEGORY', $category);
$smarty->assign("THEME", $theme);
$smarty->assign('IMAGE_PATH', "themes/$theme/images/");
$smarty->assign('ID', $focus->id);
$smarty->assign('MODE', $focus->mode);
$smarty->assign('CREATEMODE', vtlib_purify($_REQUEST['createmode']));
$smarty->assign('ISADMIN', $current_user->is_admin);
//$smarty->assign('CHECK', Button_Check($currentModule));
$smarty->assign('DUPLICATE', $isduplicate);
//zkt 20220525 52158（https://81mis.com/kfbtest/index.php）自定义表单26-182，复制单据时，单据分录带不过来
if (isset ($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true') {
    $focus->id=$_REQUEST['record'];
}
//zkt 20221121 BUG0058996kfbcrm  佣金单分录---增加引用字段，引用跟进记录里的联系方式，并保存数据库---当保存佣金单后，修改器源单跟进记录的联系方式字段---列表界面和编辑界面引用字段出现不统一
if(!empty($_REQUEST['fromid']) && !empty($_REQUEST['frommodule'])&&$_REQUEST['relatedcreate']=='yes'){
	$ProductPropertyDetailFieldsHtml->tabDetailFieldData->row_mode = 'related_create';
}
$smarty->assign('TREXPENSE', $ProductPropertyDetailFieldsHtml->getTabDetailFieldsHtml($entitytypeid));
if ($focus->mode == 'edit' || $isduplicate) {
    $recordName = array_values(getEntityName($currentModule, $record));
    $recordName = $recordName[0];
    $smarty->assign('NAME', $recordName);
    //$smarty->assign('UPDATEINFO',updateInfo($record));
}

if (isset($_REQUEST['return_module'])) $smarty->assign("RETURN_MODULE", vtlib_purify($_REQUEST['return_module']));
if (isset($_REQUEST['return_action'])) $smarty->assign("RETURN_ACTION", vtlib_purify($_REQUEST['return_action']));
if (isset($_REQUEST['return_id'])) $smarty->assign("RETURN_ID", vtlib_purify($_REQUEST['return_id']));
if (isset($_REQUEST['return_viewname'])) $smarty->assign("RETURN_VIEWNAME", vtlib_purify($_REQUEST['return_viewname']));
if (isset($_REQUEST['SearchScope'])) $smarty->assign("SEARCHSCOPE", $_REQUEST['SearchScope']);
// Field Validation Information
$tabid = getTabid($currentModule);
$validationArray = $focus->fieldobj->split_validationdataArray();

$smarty->assign("VALIDATION_DATA_FIELDNAME", $validationArray['fieldname']);
$smarty->assign("VALIDATION_DATA_FIELDDATATYPE", $validationArray['datatype']);
$smarty->assign("VALIDATION_DATA_FIELDLABEL", $validationArray['fieldlabel']);
$fields = $focus->fieldobj->getFieldListArray();
$fields['module'] = $currentModule;
$smarty->assign('FIELDINFOJSON', json_encode($fields['fields']));
$smarty->assign("MODULELINKFIELD", $focus->list_link_field);
$smarty->assign("SMOWNERCOLUMNNAME", $focus->getSmownerColumName());
/* In case you have a date field
$smarty->assign("CALENDAR_LANG", $app_strings['LBL_JSCALENDAR_LANG']);
$smarty->assign("CALENDAR_DATEFORMAT", parse_calendardate($app_strings['NTC_DATE_FORMAT']));*/
global $global_pick_list_depencyfield;
crm_load_class_file("lingdang_DependencyPicklist", 'modules/PickList');
$picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasource($currentModule);

$smarty->assign("PICKIST_DEPENDENCY_DATASOURCE", ldcrm_json_encode($picklistDependencyDatasource));
$smarty->assign("PICKLISTDEPENCYFIELDS", ldcrm_json_encode($global_pick_list_depencyfield));
$smarty->assign('TABLECOSPLAN', 8);

if ((isset($_REQUEST['Create']) && ($_REQUEST['Create'] == 'true' || $_REQUEST['Create'] == 'yes')) || $_REQUEST['isDuplicate'] == 'true') {
    $smarty->assign('CREATE', 'true');
} else {
    $smarty->assign('CREATE', 'false');
}

if (isset($selectSourceModuleName))
    $smarty->assign('ISSOURCEMODULE', $selectSourceModuleName);
else
    $smarty->assign('ISSOURCEMODULE', 'SalesOrder');

$smarty->assign("ACCOUNTID", $focus->column_fields['account_id']);

$block_info = getBlockDisplayInfo('AccountContacts');

$smarty->assign('DISPLAY_POSITION', $block_info['display_position']);

if ($block_info['is_display'] == 0)
    $smarty->assign('BESTATUS', 'YES');
else
    $smarty->assign('BESTATUS', 'NO');
crm_load_class_file('TabDetailFields', 'include/TabDetailFields');
$TabDetailFields = new TabDetailFields($tabid);
$productFields['fields'] = $TabDetailFields->getTabDetailFormulaField();
$versiontrade = getVersionTradeInfo();
$productFields['trade'] = $versiontrade['trade'];
$smarty->assign('PRODUCTFIELDSINFOJSON', ldcrm_json_encode($productFields));
$smarty->assign('SELECTSOURCENAME', $selectSourceModuleName);
$relmodule = (isset($_REQUEST['module'])) ? $_REQUEST['module'] : $currentModule;
//$smarty->assign("IS_REL_LIST", isPresentRelatedLists($relmodule));
$smarty->assign("PICKLISTCONTENT", ldcrm_json_encode($global_pick_list_values));


$smarty->assign("VALIDATASAVE", ldcrm_json_encode(getValidataSave($currentModule)));

$smarty->assign("TABDETAILFIELDS", ldcrm_json_encode($ProductPropertyDetailFieldsHtml->tabDetailFieldData->TabDetailFields->getFieldListArray()));
setGLobalURLSmarty($smarty);//设置js,css等访问路径
$smarty->assign("ReferenceUitypes", cls_module_uitype::getAllUitypes());
$smarty->assign("UITYPEMODULES", cls_module_uitype::getUitypeModules());
//布局规则
crm_load_class_file('cls_fieldrule', 'include/fields/fieldrule');
$fieldruleobj = cls_fieldrule::getInstance($currentModule);
$smarty->assign('jsonFieldRuleFieldNames', ldcrm_json_encode($fieldruleobj->getAllFieldNameSetChangeEvent()));//获取所有的触发字段
//editor:gyq_161 reason:带分录模块弹出层   2019/12/4 11:47
//$smarty->display("DetailView/EditRelated.tpl");
$arr = $ProductPropertyDetailFieldsHtml->detailPopup($smarty, $fields, $productFields);

ConvertTojsonString(1, $arr, "success");

?>