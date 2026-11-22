<?php
/**
 * zxm
 * 2020-0922
 * 灵当云 名片小程序 关于我们的编辑 与查看
 */
global $mod_strings;
global $app_strings;
global $app_list_strings;

$smarty = new lingdangCRM_Smarty;
global $adb;
global $theme;
$theme_path="themes/".$theme."/";
$sql="select * from ld_organizationdetails";
$result = $adb->pquery($sql, array());
// 判断是编辑还是新增
$id = $_REQUEST['id'];
if($id > 0){
    //编辑
    $product_sql = "select * from ld_organizationdetails_product  where id=".$id;
    $product_result = $adb->pquery($product_sql,[]);
    $product = $adb->query_result_rowdata($product_result);
    $product['brief'] = explode("|",$product['brief']);
    $smarty->assign("product",$product);
}
$organization_id = $adb->query_result($result,0,'organization_id');
//XUQIU20240805-03 电子名片界面优化 wsh
$sql = 'select max(id) from ld_organizationdetails_product where organizationdetails_id = ?';
$key = $adb->pquery($sql, array($organization_id));
$smarty->assign("KEY",$key);
$smarty->assign("organization_id",$organization_id);
$smarty->assign("THEME", $theme);
$smarty->assign("APP", $app_strings);
$smarty->assign("CMOD", $mod_strings);
$_REQUEST['diony']='diony';
$arr['title'] = getFixedLabel('Setup').getFixedLabel('PRODUCTINTRODUCTION');
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$str=$smarty->fetch("Settings/EditCompanyProduct.tpl");
$arr['content']=$str;
ConvertTojsonString(1,$arr,"success");

