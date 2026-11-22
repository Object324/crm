<?php

global $current_user, $currentModule;

//checkFileAccessForInclusion("modules/$currentModule/$currentModule.php");
//require_once("modules/$currentModule/$currentModule.php");
//
$focus = CRMEntity::getInstance($currentModule);


$mode = $_REQUEST['mode'];
$record=$_REQUEST['record'];
if($mode) $focus->mode = $mode;
if($record)$focus->id  = $record;
if($focus->id>0)
{
    $focus->retrieve_entity_info($focus->id,$currentModule);
    $focus->mode='edit';
    $before_columnfieldvalue=$focus->column_fields;
}
setObjectValuesFromRequest($focus);

$focus->save($currentModule);
$return_id = $focus->id;

$search = vtlib_purify($_REQUEST['search_url']);

$parenttab = getParentTab();
if($_REQUEST['return_module'] != '') {
	$return_module = vtlib_purify($_REQUEST['return_module']);
} else {
	$return_module = $currentModule;
}

if($_REQUEST['return_action'] != '') {
	$return_action = vtlib_purify($_REQUEST['return_action']);
} else {
	$return_action = "DetailView";
}

if($_REQUEST['return_id'] != '') {
	$return_id = vtlib_purify($_REQUEST['return_id']);
}

/**
 * �б�༭�󣬷����б�ʱ������query_session=1�Ĳ����������б�ҳ������session
 * @project ��ʱ����ѯ��ס��������
 * @author Tujt 2014-04-24
 */
if($return_module == $currentModule && $return_action != 'DetailView'){
	$return_action .= '&query_session=1';
}
//editor:gyq_161 reason:带分录模块弹出层   2019/12/4 11:09
$_REQUEST['diony']='diony';
$focus->column_fields['record_module']=$focus->module_name;
if($_REQUEST['refreshpage']=='no')
{
    //$arr['fieldhrefname']=$focus->list_link_field;
//    $arr['fieldvalue']=$focus->column_fields;
//    $arr['fieldvalue']['maintable_id']=$focus->id;
//    $arr['modulebillnotip']=$_SESSION[$currentModule.'_modulebillnotip'];
//    $_SESSION[$currentModule.'_modulebillnotip']='no';
//    ConvertTojsonString(1,$arr,"success");
    $focus->ReturnAfterSave($before_columnfieldvalue);
}

  header("Location: index.php?action=$return_action&module=$return_module&record=$return_id&parenttab=$parenttab&start=".vtlib_purify($_REQUEST['pagenumber']).$search);  

?>