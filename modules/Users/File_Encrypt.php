<?php

require_once globalStatic::$root_directory.'Register/cls_MyCRMcrypt.php';
$cls_MyCRMcrypt = new cls_MyCRMcrypt();
$newfile_name = $_REQUEST['newfile_name'];
$path = $_REQUEST['path'];
$cloud_path = $_REQUEST['cloud_path'];

$newfile_name = $cls_MyCRMcrypt ->encode($newfile_name);
$path = $cls_MyCRMcrypt ->encode($path);
$cloud_path = $cls_MyCRMcrypt ->encode($cloud_path);

// edit: xll 2023/07/25 XUQIU1001352 PC端和移动端上传附件功能：新增、编辑界面上传附件后，增加预览功能（cos上传附件生成预览按钮）
$file = array('id'=>$_REQUEST['id'],'storage_location'=>'cos','httppath'=>$_REQUEST['cloud_path']
,'pre_path'=>'','name'=>$_REQUEST['name'],'type'=>$_REQUEST['type']
,'size'=>$_REQUEST['size'],'isEncrypt'=>'yes','path'=>$cloud_path,'cloud_path' => $cloud_path
,'newfile_name'=>$newfile_name);
crm_load_class_file('AttachmentUtils','modules/Attachment');
$pre_button = AttachmentUtils::getPreviewButton($file);

$response = array(
                'newfile_name' => $newfile_name,
                'path' => $path,
                'cloud_path' => $cloud_path,
                'isEncrypt' => 'yes',
                'pre_button' => $pre_button
            );

$_REQUEST['diony']='yes';
ConvertTojsonString(1,$response,'success');

?>