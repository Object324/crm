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
/**
 *@edit:andy 
 *@date:20140924
 *@reason:详情页相关信息新建单据
 *@version:
 */
global $theme,$currentModule,$current_user,$default_charset;

$smarty = new lingdangCRM_Smarty;

if($_REQUEST['module'] == 'Calendar'){
    $_REQUEST['module']='Events';
}

$module=vtlib_purify($_REQUEST['module']);
$focus = CRMEntity::getInstance($module);
$fieldobj=$focus->fieldobj;
$disp_view = getView($focus->mode);
$mode = 'create';

$tabid = getTabid($module);
$validationArray =$fieldobj->split_validationdataArray();
$smarty->assign("VALIDATION_DATA_FIELDNAME",$validationArray['fieldname']);
$smarty->assign("VALIDATION_DATA_FIELDDATATYPE",$validationArray['datatype']);
$smarty->assign("VALIDATION_DATA_FIELDLABEL",$validationArray['fieldlabel']);

$picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasource($module);
$smarty->assign("PICKIST_DEPENDENCY_DATASOURCE", ldcrm_json_encode($picklistDependencyDatasource));

$smarty->assign('BLOCKS',getBlocks($module,$disp_view,$mode,$focus->column_fields));

$smarty->assign('MODULE',$module);
$smarty->assign('THEME', $theme);
echo "###SUCCESS###";
$smarty->display('CreateNewBill.tpl');

?>