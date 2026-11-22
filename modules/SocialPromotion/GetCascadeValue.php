<?php
/**
 * User: Dong
 * Project: crm
 * Date: 2020/7/14 15:04
 * Description: 获取联动信息
 */
require_once ('ExternalAccessRequire.php');
global  $adb;
$_REQUEST['diony'] = 'yes';
$mappingModule = strval(vtlib_purify($_REQUEST['mappingmodule']));  //对应模块
$targetfield = strval(vtlib_purify($_REQUEST['afterCascade']));
$sourcevalue = strval(vtlib_purify($_REQUEST['value']));
if($sourcevalue == ''){
    ConvertTojsonString(1,array('content'=>''),'success');
}
$mTabid = getTabid($mappingModule);
$sql = 'select targetvalues from ld_picklist_dependency where tabid = ? and targetfield=? and sourcevalue=?';
$result = $adb->pquery($sql,array($mTabid,$targetfield,$sourcevalue));
$num_rows = $adb->num_rows($result);

if($num_rows >0){
    $targetvalues =$adb->query_result($result,0,0);
    $targetvalues = json_decode($targetvalues);
}else{
    // @edit:dong @date:2020/07/15 @reason: 自己设置的联动，如果选项联动内容不存在 则调用下拉框的信息
    $focus = CRMEntity::getInstance($mappingModule);
    $fieldObj = $focus->fieldobj;
    $moduleFields = $fieldObj->getModuleFields();
    require_once ($root_dir.'modules/PickList/PickListUtils.php');
    $targetvalues = getAssignedPicklistValues($targetfield, 1, $adb, array(), $moduleFields[$targetfield]);
}
$returnHtml = '';
$returnHtml .= '<option value=""></option>';
foreach ($targetvalues as $value){
    $returnHtml .= '<option value="'.$value.'">'.$value.'</option>';
}
ConvertTojsonString(1,array('content'=>$returnHtml),'success');
