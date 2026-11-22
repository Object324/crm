<?php
global $adb,$default_charset;
$smarty=new lingdangCRM_Smarty;
$parenttabid=$_REQUEST['parenttabid'];

//zxm 2021-1206 上传菜单图标
$update_fields = [];
$update_values = [];
$error_msg = '';
if(isset($_FILES['inactive_icon'])){
    $inactive_icon = iconUpload('inactive_icon',$parenttabid);
    $update_fields[] = 'inactive_icon=?';
    $update_values[] = $inactive_icon['filepath'];
    if(!empty($inactive_icon['errorInfo'])){
        $error_msg = '未选中图标上传失败：'.$inactive_icon['errorInfo'];
        ConvertTojsonString(-1,array(),$error_msg);
    }
}
if(isset($_FILES['active_icon'])){
    $active_icon = iconUpload('active_icon',$parenttabid);
    $update_fields[] = 'active_icon=?';
    $update_values[] = $active_icon['filepath'];
    if(!empty($active_icon['errorInfo'])){
        $error_msg = '选中图标上传失败：'.$active_icon['errorInfo'];
        ConvertTojsonString(-1,array(),$error_msg);
    }
}
if(!empty($update_fields)){
    $update_values[] = $parenttabid;
    $update_fields = implode(',',$update_fields);
}
$query="update ld_parenttab set $update_fields where parenttabid=?";
$adb->pquery($query,$update_values);
$query='delete from ld_parenttabrel where parenttabid=?';
$adb->pquery($query,array($parenttabid));
$arr["msg"] = $error_msg;
ConvertTojsonString(1,$arr,"success");




//icon单文件上传
function  iconUpload($fieldname,$parenttabid){
    $uploaddir = globalStatic::$root_directory ."storage/menuIcon/";
    if(!is_dir($uploaddir)){
        mkdir($uploaddir, 0777);
    }

    $allowedExts = array("gif", "jpeg", "jpg", "png");
    $temp = explode(".", $_FILES[$fieldname]["name"]);
    $extension = end($temp);        // 获取文件后缀名
    $errorInfo = '';//错误信息
    $filename_destination = $fieldname.'_'.$parenttabid.".".$extension;
    if ((($_FILES[$fieldname]["type"] == "image/gif")
            || ($_FILES[$fieldname]["type"] == "image/jpeg")
            || ($_FILES[$fieldname]["type"] == "image/jpg")
            || ($_FILES[$fieldname]["type"] == "image/pjpeg")
            || ($_FILES[$fieldname]["type"] == "image/x-png")
            || ($_FILES[$fieldname]["type"] == "image/png"))
        && ($_FILES[$fieldname]["size"] <= 1024*1024)    // 小于 1mb
        && in_array($extension, $allowedExts))
    {
        if ($_FILES[$fieldname]["error"] > 0)
        {
            $errorInfo = $_FILES[$fieldname]["error"];
        }
        else
        {
            //echo "上传文件名: " . $_FILES["file"]["name"] . "<br>";
            //echo "文件类型: " . $_FILES["file"]["type"] . "<br>";
            //echo "文件大小: " . ($_FILES["file"]["size"] / 1024) . " kB<br>";
            //echo "文件临时存储的位置: " . $_FILES[$fieldname]["tmp_name"];
            //移动前判断文件存不存在 存在先删除
            if(file_exists($uploaddir.$filename_destination)){
                unlink($uploaddir.$filename_destination);
            }
            move_uploaded_file($_FILES[$fieldname]["tmp_name"],$uploaddir.$filename_destination);
        }
    }else if ($_FILES[$fieldname]["size"] > 1024*1024){
        $errorInfo = getFixedLabel('menuIconUploadTips');
    }else{
        $errorInfo = '文件格式不合法！';
    }
    if($errorInfo==''){
        return ['code'=>1,'filepath'=>"storage/menuIcon/".$filename_destination];
    }else{
        return ['code'=>-1,'errorInfo'=>$errorInfo];
    }
}