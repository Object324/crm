<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $app_strings, $app_list_strings, $mod_strings;
global $adb, $current_user, $currentModule;
$smarty = new lingdangCRM_Smarty;
//require_once(globalStatic::$root_directory . 'modules/Settings/SetmenuControl.php');

$smarty->assign('current_language', getLanguageType($current_user));

$smarty->assign("MODULE_NAME",$currentModule);
$smarty->assign("MODULE",$currentModule);
$smarty->assign("menufile",$_REQUEST['menufile']);
//获取 产品类别 字段名
$focus = CRMEntity::getInstance('Products');
$fieldinfo=$focus->fieldobj->getFieldInfoobjBykey("columnname",'productcategory');
if($fieldinfo){
    $product_fieldlabel=$fieldinfo->getFieldLabel();
}else{
    $product_fieldlabel=getFixedLabel('ProductCategory');
}
$smarty->assign("product_fieldlabel",$product_fieldlabel);
setGLobalURLSmarty($smarty);//js,css加载的url
//$smarty->display("modules/ShopSettings/SettingLeftRight.tpl");

$_REQUEST['diony']='yes';
$arr['content']=$smarty->fetch("modules/ShopSettings/SettingLeftRight.tpl");
ConvertTojsonString(1,$arr,'success');

?>