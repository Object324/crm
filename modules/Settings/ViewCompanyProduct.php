<?php
/**
 * zxm
 * 2020-0922
 * 灵当云 名片小程序 关于我们的查看
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

$organization_id = $adb->query_result($result,0,'organization_id');
$product_title = $adb->query_result($result,0,'product_title');
// 从表信息 多条简介 多图链接
$brief_sql = "select * from ld_organizationdetails_product where organizationdetails_id=".$organization_id." order by `order` asc";

$brief_result = $adb->pquery($brief_sql, array());
$num_rows = $adb->num_rows($brief_result);
$res_list = [];
if($num_rows > 0){
    for($i = 0; $i<$num_rows; $i++){
        $temp_id = $adb->query_result($result,$i,'id');
        $temp_title = $adb->query_result($result,$i,'title');
        $temp_image_link = $adb->query_result($result,$i,'image_link');
        $temp_order = $adb->query_result($result,$i,'order');
        $temp_brief = $adb->query_result($result,$i,'brief');
        $temp_brief = $temp_brief?explode("|",$temp_brief):[];
        $temp = [];
        $temp['id'] = $temp_id;
        $temp['title'] = $temp_title;
        $temp['image_link'] = $temp_image_link;
        $temp['order'] = $temp_order;
        $temp['brief'] = $temp_brief;
        $res_list[] = $temp;
    }
}

$smarty->assign("organization_id", $organization_id);
$smarty->assign("product_title", $product_title);
$smarty->assign("brief_arr", $res_list);
$smarty->assign("THEME", $theme);
$smarty->assign("APP", $app_strings);
$smarty->assign("CMOD", $mod_strings);
$_REQUEST['diony']='diony';
$arr['title'] = getFixedLabel('VIEW').getFixedLabel('PRODUCTINTRODUCTION');
$str=$smarty->fetch("Settings/ViewCompanyProduct.tpl");
$arr['content']=$str;
ConvertTojsonString(1,$arr,"success");

