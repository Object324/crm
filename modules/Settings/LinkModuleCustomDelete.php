<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
//链接模块定制-》删除
global $adb;
global $current_user;
if(!is_admin($current_user))
{
    exit();
}
$id=$_REQUEST['id'];
$sql='delete from ld_linkmodulecustom where id=?';
$adb->pquery($sql,array($id));
$sql='delete from ld_parenttabrel where tabid=? and tab_tablename=?';
$adb->pquery($sql,array($id,'ld_linkmodulecustom'));

$sql='delete from ld_appparenttabrel where tabid=? and tab_tablename=?';
$adb->pquery($sql,array($id,'ld_linkmodulecustom'));

//edit: xll 2024/03/05 BUG20240201-06 删除连接模块时未删除 ld_mobile_report_tab_rel 表中相关数据
$sql = "delete from ld_mobile_report_tab_rel where tabid = ? and tab_tablename = ?";
$adb->pquery($sql,array($id,'ld_linkmodulecustom'));

create_parenttab_data_file();
// @edit:dong @date:2020/10/29 @reason: bug0043060
//清除缓存
unsetCache('cache_getparenttabrelinfo');
$_REQUEST['diony']='yes';
ConvertTojsonString(1,array(),'success');
?>