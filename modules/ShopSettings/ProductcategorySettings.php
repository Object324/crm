<?php
global $adb;
$_REQUEST['diony']='yes';
$smarty = new lingdangCRM_Smarty;
crm_load_class_file('cls_ProductcategorySettings',"modules/ShopSettings");
$productcateobj = new cls_ProductcategorsySettings;
$productcatelist=$productcateobj->getAllProductcategory();
$smarty->assign("productcatelist",$productcatelist);
$focus = CRMEntity::getInstance('Products');
$fieldinfo=$focus->fieldobj->getFieldInfoobjBykey("columnname",'productcategory');
if($fieldinfo){
    $product_fieldlabel=$fieldinfo->getFieldLabel();
}else{
    $product_fieldlabel=getFixedLabel('ProductCategory');
}
$smarty->assign("product_fieldlabel",$product_fieldlabel);

if($_REQUEST['ajax']=='yes')
{
    $arr["content"] = $smarty->fetch("modules/ShopSettings/ProductcategoryContent.tpl");
}else{
    $arr["content"] = $smarty->fetch("modules/ShopSettings/ProductcategorySettings.tpl");
}
ConvertTojsonString(1,$arr,'success');

?>