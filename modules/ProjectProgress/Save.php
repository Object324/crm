<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $current_user, $currentModule;

//checkFileAccessForInclusion("modules/$currentModule/$currentModule.php");
//require_once("modules/$currentModule/$currentModule.php");

$focus = CRMEntity::getInstance($currentModule);
$mode = $_REQUEST['mode'];
$record=$_REQUEST['record'];
if($record>0){
    $focus->mode='edit';
    $focus->id=$record;
     $focus->retrieve_entity_info($focus->id,$currentModule);
    $before_columnfieldvalue=$focus->column_fields;
    
}
setObjectValuesFromRequest($focus);



if($mode) $focus->mode = $mode;
if($record)$focus->id  = $record;


$focus->save($currentModule);
$return_id = $focus->id;

$search = vtlib_purify($_REQUEST['search_url']);

//$parenttab = getParentTab();
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
 * 列表编辑后，返回列表时，增加query_session=1的参数，启用列表页面搜索session
 * @project 序时簿查询记住搜索条件
 * @author Tujt 2014-04-24
 */
if($return_module == $currentModule && $return_action != 'DetailView'){
	$return_action .= '&query_session=1';
}
if($_REQUEST['progress']){
    //16118: 客户>明细>相关信息：联系人、销售机会列表，点击【跟进】按钮，保存后，页面跳转到了联系人、销售机会列表。
  @ob_clean();
  @ob_flush();
  $jarr['code']='1';
  echo $str=json_encode($jarr);//将数组进行json编码
  exit();
  // header("Location: index.php?action=index&module=$return_module&action=$return_action&record=".$return_id);
}
$_REQUEST['diony']='diony';
if($_REQUEST['refreshpage']=='no')
 {
    //$arr['fieldhrefname']=$focus->list_link_field;
//     $arr['fieldvalue']=$focus->column_fields;
//    $arr['fieldvalue']['maintable_id']=$focus->id;
//     $arr['modulebillnotip']=$_SESSION[$currentModule.'_modulebillnotip'];
//    $_SESSION[$currentModule.'_modulebillnotip']='no';
//    ConvertTojsonString(1,$arr,"success");
$focus->ReturnAfterSave($before_columnfieldvalue);
        
 }
 else if($_REQUEST['progress']){
     
}
else
{
  header("Location: index.php?action=$return_action&module=$return_module&record=$return_id&parenttab=$parenttab&start=".vtlib_purify($_REQUEST['pagenumber']).$search);  
}
?>