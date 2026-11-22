<?php
$_REQUEST['diony']='yes';
global $adb,$current_user,$currentModule,$root_directory;
crm_load_class_file('cls_ProductcategorySettings',"modules/ShopSettings");
$productcateobj = new cls_ProductcategorsySettings;

if(isset($_REQUEST['mode'])&&$_REQUEST['mode']=='drag'){
    if(isset($_REQUEST['sequence_arr'])&&!empty($_REQUEST['sequence_arr'])){
        $sequence_arr = explode(',',$_REQUEST['sequence_arr']);
        foreach ($sequence_arr as $index => $entityid){
            $sequence=$index+1;
            $adb->pquery("update ld_shop_othersettings set sequence = ? where entityid = ? and type='productcategory'",array($sequence,$entityid));
        }
        ConvertTojsonString(1,array(),'success');
        exit();
    }
}
else if(isset($_REQUEST['mode'])&&$_REQUEST['mode']=='activate'){
    if(isset($_REQUEST['recordid'])&&!empty($_REQUEST['recordid'])){
        $productid = $_REQUEST['recordid'];
        $productcateinfo = $productcateobj->getProductcateById($productid);
        $display = $productcateinfo['display'];
        if($display=='show'){
            ConvertTojsonString(1,array(),'success');
            exit();
        }
        $adb->pquery("update ld_shop_othersettings set display = ? where entityid = ? and type='productcategory'",array('show',$productid));
        ConvertTojsonString(1,array(),'success');
        exit();
    }
}
else if(isset($_REQUEST['mode'])&&$_REQUEST['mode']=='inactivate'){
    if(isset($_REQUEST['recordid'])&&!empty($_REQUEST['recordid'])){
        $productid = $_REQUEST['recordid'];
        $productcateinfo = $productcateobj->getProductcateById($productid);
        $display = $productcateinfo['display'];
        if($display=='hide'){
            ConvertTojsonString(1,array(),'success');
            exit();
        }
        $adb->pquery("update ld_shop_othersettings set display = ? where entityid = ? and type='productcategory'",array('hide',$productid));
        ConvertTojsonString(1,array(),'success');
        exit();
    }
}

exit();
?>