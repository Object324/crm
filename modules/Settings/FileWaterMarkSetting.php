<?php
// ljj 20240423 XUQIU20240408-04 附件增加“上传Word文件添加水印”和“上传Excel文件添加水印”字段属性（王庆）
global $current_user,$adb;
$_REQUEST['diony'] = 'yes';
$smarty=new lingdangCRM_Smarty;
$option = $_REQUEST['option'];
crm_load_class_file('FileWaterMark', 'modules/Settings');
if ($option == 'show'){
    $type = $_REQUEST['type'];
    $smarty->assign('type',$type);
    $relatedmodule = $_REQUEST['relatedmodule'];
    $settingid = $_REQUEST['settingid'];
    if (!empty($settingid)){
        $fileWaterMarkobj = FileWaterMark::getInstance($relatedmodule);
        $info = $fileWaterMarkobj->getWaterMarkSettingbyId($_REQUEST['settingid']);
        $image_watermark = $info['image_watermark'];
        $text_watermark = $info['text_watermark'];
        $text_content = $info['content'];
        $arr['jsonData'] = $info['jsonData'];
        $smarty->assign('CONTENT',$text_content);
        $smarty->assign('image_watermark',$image_watermark);
        $smarty->assign('text_watermark',$text_watermark);
    }
    $tablebel = getTranstab($relatedmodule);
    $smarty->assign('TABLABEL',$tablebel);
    $arr['tabid'] = getTabid($relatedmodule);
    $languageType=getLanguageType($current_user);
    $arr['title'] = strtoupper($type).($languageType == 'en'?' ':'').getFixedLabel('WATERMARKSETTING');
    $arr['oktext'] = getFixedLabel("CONFIRMED");
    $arr['canceltext'] = getFixedLabel("CANCEL");
    $arr['content']=$smarty->fetch('Settings/FileWaterMarkSetting.tpl');
    ConvertTojsonString(1,$arr,'success');
}elseif ($option == 'download'){
    $settingid = $_REQUEST['settingid'];
    $sql = 'select image_name,image_path,image_newfilename from ld_attachments_watermark_setting where id=?';
    $result = $adb->pquery($sql,array($settingid));
    if ($adb->num_rows($result)>0){
        $filepath = $adb->query_result($result,0,'image_path');
        $newfile_name = $adb->query_result($result,0,'image_newfilename');
        $name = $adb->query_result($result,0,'image_name');
        $saved_filename = mb_convert_encoding($newfile_name, 'gbk', 'UTF-8');
    }else{
        echo 'error';
        die;
    }
    $isconvert='yes';
    if (file_exists($filepath . $saved_filename)) {
        $disk_file_size = filesize($filepath . $saved_filename);
    }
    else if (file_exists($filepath . $newfile_name)) {
        $isconvert='no';
        $disk_file_size = filesize($filepath . $newfile_name);
    }
    $diskfilesize = $disk_file_size + ($disk_file_size % 1024);
    $fileContent = fread(fopen($filepath . $newfile_name, "r"), $diskfilesize);
    header("Content-type: image/png");
    header("Pragma: public");
    header("Cache-Control: private");
    if (stripos($_SERVER['HTTP_USER_AGENT'], 'edge') !== false)//edge浏览器(win10自带)
        header("Content-Disposition: attachment; filename=" . urlencode($name));
    else {
        if (strtolower(PHP_OS) == 'freebsd' || strtolower(PHP_OS) == 'linux' || strtolower(PHP_OS) == 'unix' || strtolower(PHP_OS) == 'macos') {
            header("Content-Disposition: attachment; filename=" . $name);
        } else {
            if($isconvert=='yes')
                header("Content-Disposition: attachment; filename=" . mb_convert_encoding($name, 'gbk', 'UTF-8'));
            else
                header("Content-Disposition: attachment; filename=" . $name);
        }
    }
    //header("Content-Disposition: attachment; filename=\"".$name."\"");
    header("Content-Description: PHP Generated Data");
    header('Content-Encoding: none');
    header("Content-Transfer-Encoding: binary");
    ob_clean();
    flush();
    echo $fileContent;
}elseif ($option == 'save'){
    $fileType = $_REQUEST['type'];
    $relatedmodule = $_REQUEST['relatedmodule'];
    $fieldname = empty($_REQUEST['fieldname'])?'':$_REQUEST['fieldname'];
    $settingid = empty($_REQUEST['settingid'])?'':$_REQUEST['settingid'];
    $image_checked = $_REQUEST['image_checked'];
    $image_name= empty($_REQUEST['image_name'])?'':$_REQUEST['image_name'];
    $image_path= empty($_REQUEST['image_path'])?'':$_REQUEST['image_path'];
    $image_newfilename= empty($_REQUEST['image_newfilename'])?'':$_REQUEST['image_newfilename'];
    $text_checked = empty($_REQUEST['text_checked'])?'':$_REQUEST['text_checked'];
    $content = empty($_REQUEST['content'])?'':$_REQUEST['content'];
    $fileWaterMarkobj = FileWaterMark::getInstance($relatedmodule);
    $arr['settingid'] = $fileWaterMarkobj->saveWaterMarkSetting($settingid,$relatedmodule,$fieldname,$fileType,$image_checked,$text_checked,$content,$image_name,$image_path,$image_newfilename);
    ConvertTojsonString(1,$arr,'success');
}



?>