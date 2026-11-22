<?php
global $adb;
$_REQUEST['diony']='yes';
$smarty = new lingdangCRM_Smarty;
crm_load_class_file('cls_CarouselSettings',"modules/ShopSettings");
$carouselobj = new cls_CarouselSettings();
$allcarousels=$carouselobj->getAllCarouselinfos();
foreach($allcarousels as $key=>$carouselinfo)
{
    $carouselid=$carouselinfo['carouselid'];
    $linktype= $carouselinfo['linktype'];
    $linkid= $carouselinfo['linkid'];
    $status= $carouselinfo['status'];
    $carouselseq= $carouselinfo['carouselseq'];
    $uploadfile_name= $carouselinfo['uploadfile_name'];
    $file_type= $carouselinfo['file_type'];
    $file_path= $carouselinfo['file_path'];
    $newfile_name= $carouselinfo['newfile_name'];
    $url_filepath  = $file_path.$newfile_name;
    //图片丢失默认显示
    if(!file_exists($url_filepath)||!@getimagesize($url_filepath)){
        //$url_filepath = 'themes/images/default_cartimg.png';
    }
    $list[]=array('carouselseq'=>$carouselseq,'carouselid'=>$carouselid,'linktype'=>$linktype
                    ,'status'=>$status,'uploadfile_name'=>$uploadfile_name,'url_filepath'=>$url_filepath);
}
$smarty->assign("List",$list);
if($_REQUEST['ajax']=='yes')
{
    //右侧专题下产品列表（table）页
    $arr["content"] = $smarty->fetch("modules/ShopSettings/CarouselSettingsListContent.tpl");
    ConvertTojsonString(1,$arr,'success');
}else{
    $arr["content"] = $smarty->fetch("modules/ShopSettings/CarouselSettings.tpl");
    ConvertTojsonString(1,$arr,'success');

}


?>