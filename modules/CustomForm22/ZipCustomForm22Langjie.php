<?php
global $adb,$currentModule, $theme,$current_user;
$tempPath = 'storage/downCacheFile/';
$logFile ='storage/downCacheFile/logfile.txt';
// list_view 发送批量发送邮件传的值
if($_REQUEST['idstring'] && $_REQUEST['idstring']!= '' && $_REQUEST['setype'] =='ExportCustomsOrderEmail'){
    $ids = $_REQUEST['idstring'] ;
    $attachments = getAttachments($ids);

    //下载附件
    if(!empty($attachments)){
        foreach ($attachments as $id =>$attachment){
//        linux保存文件名要求文件名编码为utf-8 否则乱码
//        此处保存文件大文件可能会报错
            foreach ($attachment as $key=>$value){
                if($attachment['storage_location'] =='cos'){
                    $attachmentName =changEncode($value['name']);
                    downloadFile($value['path'],$tempPath.$attachmentName);
                }
            }

        }
    }
}

$zip = new ZipArchive();
$zipName  = time().'.zip';
//删除旧的重名文件
@unlink($tempPath.$zipName);
$zip->open($tempPath.$zipName, ZipArchive::CREATE);  //打开压缩包
$files = json_decode(urldecode(urldecode($_REQUEST['files'])),TRUE);
$newNameArr = array();
if(is_array($files) && !empty($files)){
    foreach ($files as $file){
        $newNameArr[]=$file['declareDate'].'-'.$file['declareType'].'-'.$file['accountName'].'-'.$file['port_no'];
        $file['filename'] =  changEncode($file['filename']);
        zipFileLog($logFile,$tempPath.$file['filename']);
        $zip->addFile($tempPath.$file['filename'],$file['filename']);
    }
}

if(!empty($attachments)){
    $tableCode = getOrderNo($ids);
    // @edit:dong @date:2020/07/22 @reason:  重命名压缩包内的附件名称 带上订单code
    foreach ($attachments as $id=>$idAttachments) {
        foreach ($idAttachments as $attachment){
            $attachment['name'] = changEncode($attachment['name']);
            //临时解决 附件表中 name和newfilename不对应问题
            $attachment['path'] = changEncode($attachment['path']);
            if(!file_exists($attachment['path'])){
                $attachment['path'] = $attachment['path2'].'CustomForm22_'.$attachment['name'];
            }
            zipFileLog($logFile, $attachment['path']);
            // @edit:dong @date:2020/09/07 @reason: 朗捷 没有storage_location =cos的附件 暂时注释掉
//            if($attachment['storage_location'] =='cos'){
//                $zip->addFile($tempPath.$attachment['name'],$tableCode[$id].'_'.$attachment['name']);  //向压缩包中添加文件
//            }else{
                $zip->addFile($attachment['path'],$tableCode[$id].'_'.$attachment['name']);

//            }
        }
    }
}
$zip->close(); //关闭压缩包
$newNameStr = implode('_',array_unique($newNameArr));
$newZipName =mb_substr($newNameStr,0,210,'UTF-8').'__'.time();

rename($tempPath.$zipName,$tempPath.changEncode($newZipName).'.zip');
zipFileLog($logFile,$tempPath.changEncode($newZipName).'.zip');
//
////删除原文件
foreach ($attachments as $fileName=>$file){
    foreach ($file as $key=>$value){
        if($value['storage_location'] =='cos'){
            @unlink($tempPath.$value['name']);
        }
    }

}
foreach ($files as $file){
    @unlink($tempPath.changEncode($file['filename']));
}


$_REQUEST['diony']='yes';
$arr['zipName'] =$newZipName.'.zip';
$arr['returntitle'] =$newNameStr;
ConvertTojsonString(1,$arr,'success');


function getAttachments($ids){
    global  $adb;
    $sql = 'SELECT ld_seattachmentsrel.crmid,ld_attachments.cloud_path,ld_attachments.name,ld_attachments.storage_location,ld_attachments.path,ld_attachments.newfile_name FROM ld_seattachmentsrel  LEFT JOIN ld_attachments on ld_seattachmentsrel.attachmentsid = ld_attachments.attachmentsid where ld_seattachmentsrel.attachmentcolumnname ="filename" and  ld_seattachmentsrel.crmid in  ';
    $ids = '('.trim(str_replace(';',',',$ids),',').')';

    $result = $adb->pquery($sql.$ids);
    $row_nums = $adb->num_rows($result);
    echo $row_nums;
    $attachments = array();
    if($row_nums>0){
        $i =0;
        while($row = $adb->fetch_array($result)){
            // @edit:dong @date:2020/09/07 @reason: 朗捷 附件不会有storage_location =cos的附件 暂时注释掉
//            if($row['storage_location'] =='cos'){
//                $attachments[$row['crmid']][$i]['name'] = $row['name'];
//                $attachments[$row['crmid']][$i]['path'] = $row['cloud_path'];
//                $attachments[$row['crmid']][$i]['storage_location'] = $row['storage_location'];
//                $i++;
//            }else{
                $attachments[$row['crmid']][$i]['name']  = $row['name'];
                $attachments[$row['crmid']][$i]['path']  = $row['path'].$row['newfile_name'];
                $attachments[$row['crmid']][$i]['path2']  = $row['path'];
                $attachments[$row['crmid']][$i]['storage_location'] = $row['storage_location'];
                $i++;
//            }

        }
    }
    return $attachments;

}

//通过id获取订单编号
function getOrderNo($ids){
    global  $adb,$currentModule;
    $focus =CRMEntity::getInstance($currentModule);
    $tablename = $focus->table_name;
    $table_index = $focus->table_index;
    $table_code = $focus->table_code;
    $sql = 'SELECT '.$table_index.','.$table_code.'  FROM '. $tablename .' where '.$table_index.' in ';
    $ids = '('.trim(str_replace(';',',',$ids),',').')';
    $result = $adb->pquery($sql.$ids);
    $row_nums = $adb->num_rows($result);
    $returnArr =array();
    if($row_nums>0){
        for($i=0;$i<$row_nums;$i++){
            $id = $adb->query_result($result,$i,$table_index);
            $returnArr[$id] = $adb->query_result($result,$i,$table_code);
        }
    }
    return $returnArr;
}
/**
 * Name: 下载cos的附件
 * User: Dong
 * Date: 2020/6/22 14:53
 * @param $fileUrl
 * @param $filename
 * @return mixed
 */
function downloadFile($fileUrl,$filename) {
    set_time_limit(0);
    $hostfile = fopen($fileUrl, 'r');
    $fh = fopen($filename, 'w');
    while (!feof($hostfile)) {
        $output = fread($hostfile, 2048);
        fwrite($fh, $output);
    }
    fclose($hostfile);
    fclose($fh);
}

//改变编码
function changEncode($str){
//    $arr=array("ASCII","UTF-8","GB2312","GBK",'BIG-5');
//    $encode=mb_detect_encoding($string, $arr);
//    strtolower(PHP_OS)=='freebsd'||strtolower(PHP_OS)=='linux'||strtolower(PHP_OS)=='unix'
    if(strtolower(substr(PHP_OS,0,3))=='win'){
        $str= mb_convert_encoding($str,'gbk','auto');
    }
    return $str;
}
//记录压缩时 被压缩文件是否存在
function zipFileLog($logFile,$filename){
    global  $current_user;
    $status = changEncode(file_exists($filename)? '存在':'不存在');
    file_put_contents($logFile,'id:'.$current_user->id .'-'.date('Y-m-d H:i:s').'-'.$filename.'-'.$status."\r\n",FILE_APPEND);
}