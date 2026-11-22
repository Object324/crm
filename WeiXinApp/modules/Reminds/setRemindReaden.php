<?php
/**
 * 移动端——待办——消息中心——"全部标为已读"
 */
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb,$current_user,$currentModule;

$mobj = cls_Instance::get_moduleAction_Instance($currentModule,'ListView');
$select_sql = $mobj->get_page_query(null,null);


$update_sql1="UPDATE ld_reminds INNER JOIN( $select_sql ) as tmp on tmp.remindsid = ld_reminds.remindsid set status_rmd = '已读' ";
$update_sql2="UPDATE ld_reminds_accepted INNER JOIN( $select_sql ) as tmp on tmp.remindsid = ld_reminds_accepted.remindsid set status_rmd = '已读' ";
$adb->pquery($update_sql1,array());
$adb->pquery($update_sql2,array());

// 消息中心——未读消息条数
require_once(globalStatic::$root_directory.'modules/Reminds/static_reminds.php');
$remindscount = static_Reminds::getRemindsCount();
if($remindscount == 0)
    $remindscount = -1;

ConvertTojsonString(1, array('remindscount' => $remindscount), getFixedLabel('SetSuccessfully'));
?>