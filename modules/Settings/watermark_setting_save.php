<?php
global $adb;
/*
edit:杨彬阳
2022.12.10
*/
$watermark_display = $_REQUEST['watermark_display']; //获取前端返回的值
$custom_content  =  $_REQUEST['custom_content'];
if(isset($_REQUEST['presence']) && $_REQUEST['presence'] != '')
    $presence= $_REQUEST['presence'];
else 
    $presence= 'no';
 
$sql = "update ld_watermark_setting set presence=?,watermark_display=?,custom_content=? where id=1";
$params = array($presence, $watermark_display, $custom_content);
$adb->pquery($sql,$params);

// ljj 20240131 BUG20240130-68 kfbcrm-水印设置-修改水印显示内容后界面不会自动刷新
$arr=[];
if ($presence == 0){
    crm_load_class_file('MenuUtils','modules/Users');
    $MenuUtilsObj = new MenuUtils();
    $watermark_txt = $MenuUtilsObj->getwatermark_setting();
    $arr['watermark_txt']=$watermark_txt;
}else{
    $arr['watermark_txt']='';
}

$_REQUEST['diony']='yes';
ConvertTojsonString(1,$arr,"success");

?>