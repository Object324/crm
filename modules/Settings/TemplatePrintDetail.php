<?php
global $adb;
require_once('Smarty_setup.php');
$printId=$_REQUEST['printId'];
$sql='select * from ld_templateprint where templateprintid=?';
$result=$adb->pquery($sql,array($printId));
$templatename='';
$tabid=0;
$printfilename='';
$isDefault='';
if($adb->num_rows($result)>0)
{
    $templatename=$adb->query_result($result,0,'templateprintname');
    $tabid=$adb->query_result($result,0,'tabid');
    $printfilename=$adb->query_result($result,0,'printfilename');
    $isDefault=$adb->query_result($result,0,'isdefault');
    $replacespacevalue=$adb->query_result($result,0,'replacespacevalue');
}
else
{
    echo getFixedLabel('TEMPLATEHASVEENDELETED');
    exit();
}
$smarty->assign("TEMPLATENAME",$templatename);
$smarty->assign("PRINTTABID",$tabid);
$smarty->assign("ISDEFAULT",$isDefault);
$pos  =  strpos ($replacespacevalue , 'nbsp');
if($pos){
	$replacespacevalue = '';
}
$smarty->assign('REPLACESPACEVALUE',$replacespacevalue);
if(file_exists("templatePrintFile/".$printfilename))
{  
                
    if ( !is_readable("templatePrintFile/".$printfilename) )
    {
        die(getFixedLabel('FILE') .$printfilename. getFixedLabel('UNREADABLEPLEASECHECK'));
    }
    $extension = pathinfo($printfilename, PATHINFO_EXTENSION);// 文件格式
    if($extension == 'doc' || $extension == 'docx' || $extension == 'xls' || $extension == 'xlsx'){// 2024-5-15 xxy Word/Excel打印模板,编辑时显示已上传文件
        if($extension == 'doc' || $extension == 'docx'){
            $type = 'Word';
        }else if($extension == 'xls' || $extension == 'xlsx'){
            $type = 'Excel';
        }
        $smarty->assign("TYPE",$type);
        $attname = $adb->query_result($result,0,'originalfilename');// 用户上传的文件名,用于显示
        
        $storage_location = "local";
        $path = "templatePrintFile/";
        $cloud_path = "templatePrintFile/";
        $file_type = '';
        $newfile_name = $printfilename;

        $size = filesize($path.$newfile_name);
        if ($size < 1024)
            $size = $size . ' B';
        else if ($size > 1024 && $size < 1048576)
            $size = round($size / 1024, 2) . ' KB';
        else if ($size > 1048576)
            $size = round($size / 1024, 2) . ' MB';
        // 下载
        $cls_AESencryptionbykeyobj = cls_AESencryptionbykey::getInstance();
        $download_path = $cls_AESencryptionbykeyobj->getencryption($path.$newfile_name);
        $arr_smarty['downloadpath'] = $download_path;
        $arr_smarty['originalfilename'] = $attname;
        //edit: xll XUQIU1001183 下载优化：newfile_name、path、cloud_path加密
        $cls_MyCRMcrypt = new cls_MyCRMcrypt();
        $path = $cls_MyCRMcrypt->encode($path);
        $cloud_path = $cls_MyCRMcrypt->encode($cloud_path);
        $newfile_name = $cls_MyCRMcrypt->encode($newfile_name);
        $isEncrypt = 'yes';

        // edit: xll 2023/07/25 XUQIU1001352 PC端和移动端上传附件功能：新增、编辑界面上传附件后，增加预览功能（生成预览按钮并返回）
        $httppath = $cls_MyCRMcrypt->decode($cloud_path);
        $pre_path = $cls_MyCRMcrypt->decode($path) . $cls_MyCRMcrypt->decode($newfile_name);
        $file = array('id' => $id, 'storage_location' => $storage_location, 'httppath' => $httppath,
            'pre_path' => $pre_path, 'name' => $attname, 'type' => $file_type, 'isEncrypt' => $isEncrypt,
            'path' => $path, 'cloud_path' => $cloud_path, 'newfile_name' => $newfile_name);
        crm_load_class_file('AttachmentUtils','modules/Attachment');
        $AttachmentUtilsObj = new AttachmentUtils();
        $pre_button = $AttachmentUtilsObj->getPreviewButton($file);

        $file_info[] = array('file_name' => $attname, 'file_size' => $size, 'file_type' => $file_type
        , 'file_path' => $path, 'cloud_path' => $cloud_path, 'newfile_name' => $newfile_name, 'fileid' => $id, 'storage_location' => $storage_location, 'isEncrypt' => $isEncrypt
        , 'pre_button' => $pre_button);
        
        $arr_smarty['templatetype'] = $type;
        $arr_smarty['filejsondata'] = Zend_Json::encode($file_info);
    }else{
        $file_handle=fopen("templatePrintFile/".$printfilename,"r");
                
        $contents = fread($file_handle, filesize ("templatePrintFile/".$printfilename));
        fclose($file_handle);
        $smarty->assign("CKEDITORHTML",$contents);
    }
                
}
else
{
    $smarty->assign("CKEDITORHTML",getFixedLabel('TEMPLATEFILEISMISSING'));
}
$smarty->assign("PRINTID",$printId);
 $_REQUEST['diony']='diony';
$arr_smarty['title'] = getFixedLabel('VIEW');
$arr_smarty['oktext']=getFixedLabel("CONFIRMED");
$arr_smarty['canceltext']=getFixedLabel("CANCEL");
$str=$smarty->fetch("TemplatePrintDetail.tpl");
$arr_smarty['content']=$str;
ConvertTojsonString(1,$arr_smarty,"success");

?>