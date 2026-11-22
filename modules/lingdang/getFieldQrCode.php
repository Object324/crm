<?php
global $adb;
$module = $_REQUEST['module'];
$fieldid = $_REQUEST['fieldid'];
$uitype = $_REQUEST['uitype'];
$recordid = $_REQUEST['recordid'];
$corpurl = $_REQUEST['corpurl'];

if($uitype == '1503'){
    require_once(globalStatic::$root_directory.'modules/lingdang/getFormQrcode.php');
    exit();
}

$tabid = getTabid($module);
$focus=CRMEntity::getInstance($module);
$_REQUEST['diony']='diony';
if($uitype==1502){
    //1502 生成模块名+id
    $modulelabel = getTranstab($module);
    $content_arr = ['modulelabel'=>$modulelabel,'modulename'=>$module,'recordid'=>$recordid];
    $pdfhtml = json_encode($content_arr);
}else{
    //1501 1500 根据模板生成
    require_once(globalStatic::$root_directory.'include/TemplatePrint/TemplatePrint.php');
    $template=new TemplatePrint($module,$tabid,$fieldid,$recordid,$adb,0,'yes');
    //生成html
    $pdfhtml = $template->createPrintHtml();
}

//生成二维码
require_once(globalStatic::$root_directory.'marketplateform/phpqrcode/phpqrcode.php');
if($uitype==1501){
    //链接码
    $server = $_SERVER['HTTP_ORIGIN'].rtrim($_SERVER['PHP_SELF'],'index.php');
    $corpurl = empty($corpurl)?$server:$corpurl;
    $data = $corpurl."WeiXinApp/fieldqrcodelink.php?module=$module&fieldid=$fieldid&uitype=$uitype&recordid=$recordid";
}else{
    //内容码
    $data = strip_tags(htmlspecialchars_decode(trim($pdfhtml)));//内容
    $data = str_replace('&nbsp;',' ',$data);
}
$level = 'L';// 纠错级别：L、M、Q、H
$size = 10;//元素尺寸
$margin = 1;//边距
if(!is_dir(globalStatic::$root_directory.'storage/phpqrcode/')){
    mkdir(globalStatic::$root_directory.'storage/phpqrcode/',0777);
}
if(file_exists(globalStatic::$root_directory.'storage/phpqrcode/'.$recordid.$fieldid.$uitype.'.png')){
    unlink(globalStatic::$root_directory.'storage/phpqrcode/'.$recordid.$fieldid.$uitype.'.png');
}
$outfile = globalStatic::$root_directory.'storage/phpqrcode/'.$recordid.$fieldid.$uitype.'.png';
$saveandprint = true;// true直接输出屏幕  false 保存到文件中
$back_color = 0xFFFFFF;//白色底色
$fore_color = 0x000000;
$QRcode = new QRcode();
//生成png图片
$QRcode->png($data, $outfile, $level, $size, $margin, false, $back_color, $fore_color);
//获取字段名作为标题
$fieldinfo = $focus->fieldobj->getFieldInfoobjBykey('fieldid',$fieldid);

$fieldlabel = getFixedLabel('SOCIALPROMOTIONQRCODE');
if(!empty($fieldinfo)){
    $fieldlabel = $fieldinfo->getfieldLabel();
}
ConvertTojsonString(1, array('path'=>'storage/phpqrcode/'.$recordid.$fieldid.$uitype.'.png','title'=>$fieldlabel), '成功！');
