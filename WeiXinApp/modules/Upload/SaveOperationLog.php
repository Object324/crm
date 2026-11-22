<?php
/*
edit:duan
date:20220831
reason:保存移动端的下载和预览次数
*/
global $adb,$current_user;
$frommodule = $_REQUEST['frommodule'];
$attachmentsid = $_REQUEST['attachmentsid'];
$dbQuery = "SELECT * FROM ld_attachments WHERE attachmentsid = ?";
if($_REQUEST['isentry'] && $_REQUEST['isentry'] == 'entry'){
    $dbQuery = "SELECT * FROM ld_detailattachments WHERE id = ?";
}
$result = $adb->pquery($dbQuery, array($attachmentsid));
$arr = array();
if ($adb->num_rows($result) == 1) {
    $code = 1;
    $msg = 'success';
    $operating_type = $_REQUEST['operating_type'];
    $crmid = $_REQUEST['crmid'];
    $fileType = @$adb->query_result($result, 0, "type");
    $name = @$adb->query_result($result, 0, "name");
    $filepath = @$adb->query_result($result, 0, "path");
    $name = html_entity_decode($name, ENT_QUOTES, $default_charset);
    $newfile_name = html_entity_decode(@$adb->query_result($result, 0, "newfile_name"), ENT_QUOTES, $default_charset);
    //$saved_filename = $attachmentsid."_".$name;
    $saved_filename = $newfile_name;
    //editor:gyq_169 reason:腾讯云COS文件上传预览   2020/3/2 17:07
    $cloud_path = $adb->query_result($result, 0, "cloud_path");
    $storage_location = $adb->query_result($result, 0, "storage_location");
    //edit:xll 2023/06/30 XUQIU1000357 单据分录定制，增加“附件”字段类型（分录附件字段的预览下载次数在表ld_fileoperationlog中增加了lineitem_id字段，非分录默认为零）
    $lineitem_id = (empty($_REQUEST['lineitem_id']) || $_REQUEST['lineitem_id'] == '') ? 0 : $_REQUEST['lineitem_id'];
    $sql = 'insert into ld_fileoperationlog(tabid,crmid,lineitem_id,newfile_name,operator,operating_type,operating_time) values(?,?,?,?,?,?,?)';
    $adb->pquery($sql, array(getTabid($frommodule),$crmid,$lineitem_id,$newfile_name, $current_user->id,
        $operating_type, date("Y-m-d H:i:s")));
    
    $sql = "select operating_type,count(id) as count_id from ld_fileoperationlog where lineitem_id=? and newfile_name=? and crmid=? group by operating_type";
    $result = $adb->pquery($sql,array($lineitem_id,$newfile_name,$crmid,$operating_type));
    $num_rows = $adb->num_rows($result);
    if($num_rows>0){
        for($i=0;$i<$num_rows;$i++){
            $operating_type = $adb->query_result($result,0,'operating_type');
            $count_id = $adb->query_result($result,0,'count_id');
            $arr[$operating_type] = $count_id;
        }
    }
}else{
    $code = -1;
    $msg = 'failed';
}

ConvertTojsonString($code,$arr,$msg);
?>