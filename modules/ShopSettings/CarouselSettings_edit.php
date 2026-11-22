<?php

global $adb,$current_user,$currentModule;
require(globalStatic::$root_directory.'user_privileges/user_language_'.$current_user->id.'.php');
crm_load_class_file('cls_CarouselSettings',"modules/ShopSettings");
$carouselobj = new cls_CarouselSettings();
$smarty = new lingdangCRM_Smarty;
$smarty->assign('MODULE',$currentModule);
$smarty->assign('OperateMode','create');        //当前操作

$smarty->assign('URL_FILEPATH','themes/images/default_cartimg.png');//默认图片
if(isset($_REQUEST['mode'])&&$_REQUEST['mode']=='edit'){
    $smarty->assign('OperateMode','edit');
    $edit_carouselid = $_REQUEST['recordid'];
    $carouselinfo = $carouselobj->getCarouselinfoById($edit_carouselid);
    $carousellinkinfo = $carouselobj->getCarousellinkinfoById($edit_carouselid);
    $smarty->assign('RECORDID',$carouselinfo['carouselid']);
    $smarty->assign('LINKTYPE',$carouselinfo['linktype']);
    if($carouselinfo['linktype'] == 'Carousel_ProductCategoryList'){
        $smarty->assign('CATEGORYID',$carouselinfo['linkid']);
        //$smarty->assign(,$carousellinkinfo['linkname']);
    }
    elseif($carouselinfo['linktype'] == 'Carousel_Productdetails'){
        $smarty->assign('PRODUCTID',$carouselinfo['linkid']);
        $smarty->assign('fldvalue',$carousellinkinfo['linkname']);
    }
    $smarty->assign('LOADFILENAME',$carouselinfo['uploadfile_name']);
    $smarty->assign('FILENAME',$carouselinfo['newfile_name']);
    $smarty->assign('FILESIZE',$carouselinfo['file_size']);
    $url_filepath  = $carouselinfo['file_path'].$carouselinfo['newfile_name'];
    //图片丢失默认显示
    if(!file_exists($url_filepath)||!@getimagesize($url_filepath)){
        //$url_filepath = 'themes/images/default_cartimg.png';
    }
    $smarty->assign('URL_FILEPATH',$url_filepath);
    $smarty->assign('Status',$carouselinfo['status']);
    
}
$smarty->assign('LANGUAGETYPE',$languageType);
$linktype_list = array(
                    'Carousel_ProductCategoryList'=>getFixedLabel('Carousel_ProductCategoryList'),
                    'Carousel_Productdetails'=>getFixedLabel('Carousel_Productdetails')
                );
$smarty->assign('linktype',$linktype_list);       
$categorylist = getselectProductCategoryList();
$smarty->assign('categorylist',$categorylist);
//获取模块链接字段
$tabid = getTabid('Products');
$entityarray = getEntitynameInfo($tabid);
$tabname = $entityarray['tablename'];
$tabindex = $entityarray['entityidfield'];
$tabfieldname = $entityarray['fieldname'];
$version_info = getVersionInfo(); 
$smarty->assign('version_account',$version_info['account']);
$smarty->assign('productfieldname',$tabindex);
$_REQUEST['diony']='diony';
$arr['title'] = getFixedLabel('CreateCarousel');
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$str=$smarty->fetch("modules/ShopSettings/CarouselSettings_edit.tpl");
$arr['content']=$str;
ConvertTojsonString(1,$arr,"success");
exit();

function getselectProductCategoryList(){
    global $adb;
    $productcategory_arr = array();
    $query = "select * from ld_picklist_values 
            LEFT JOIN ld_picklist_set on ld_picklist_set.listid=ld_picklist_values.listid 
            where listname='productcategory';";
    $result = $adb->pquery($query,array());
    $rows = $adb->num_rows($result);
    for($i = 0;$i<$rows;$i++){
        $id = $adb->query_result($result,$i,'id');
        $listvalue = $adb->query_result($result,$i,'listvalue');
        $productcategory_arr[] = array('value'=>$id,'text'=>$listvalue);
    }
    return $productcategory_arr;
}
?>