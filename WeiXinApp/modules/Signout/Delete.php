<?php
/**
 * 删除签到记录
 * 包括：签到表，签到附件表，签到附件文件
 */
//zkt 20231023 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $current_user,$adb;

$signid = $_REQUEST['record'];
if(empty($signid)) ConvertTojsonString('-1',getFixedLabel('DELETEFAILED'),'');
//duan 20221210 删除签到单据
$focus = CRMEntity::getInstance('Signout');
$focus->trash('Singin',$signid);
ConvertTojsonString('1',null,'');

$sql = 'delete from ld_singin where id=? and userid=?';
$adb->pquery($sql,array($signid,$current_user->id));
$sql = 'select path,filename from ld_attachmentsforsign where signid=?';
$result = $adb->pquery($sql,array($signid));
$num_rows = $adb->num_rows($result);
if($num_rows){
    for($i=0;$i<$num_rows;$i++){
        $path = $adb->query_result($result,$i,'path');
        $filename = $adb->query_result($result,$i,'filename');
        $filepath = globalStatic::$root_directory.$path.$filename;
        if(file_exists($filepath)) @unlink($filepath);
    }
}
$adb->pquery('delete from ld_attachmentsforsign where signid=?',array($signid));

ConvertTojsonString('1',null,'');
?>