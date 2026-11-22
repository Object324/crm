<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 

global $app_list_strings;
global $adb;
global $theme;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";

$smarty = new lingdangCRM_Smarty;
/*
$sql="select * from ld_DataInterface";
$result=$adb->pquery($sql,array());
$softversion=$adb->query_result($result,0,'soft_version');
*/
$softversion=getDatainterface('soft_version');
switch($softversion)
{
    case 1:
        $smarty->assign("SOFTVERSION",getFixedLabel('LBL_K3'));
        break;
    case 2:
        $smarty->assign("SOFTVERSION",getFixedLabel('LBL_KIS_MAJOR'));
        break;
    case 3:
        $smarty->assign("SOFTVERSION",getFixedLabel('LBL_KIS_STANDARD'));
        break;
    case 4:
         $smarty->assign("SOFTVERSION",getFixedLabel('LBL_KIS_MINI'));
		break;
	case 5:
         $smarty->assign("SOFTVERSION",getFixedLabel('LBL_KIS_ULTIMATE'));
		break;
    case 101:
         $smarty->assign("SOFTVERSION",'T+');
        break;
    case 102:
         $smarty->assign("SOFTVERSION",'U8+');
        break;
	 case 103:
         $smarty->assign("SOFTVERSION",'T6');
        break;
    case 201:
         $smarty->assign("SOFTVERSION",'易助7.0');
        break;
}
/*
$softfactory=$adb->query_result($result,0,'soft_factory');
$demoname=$adb->query_result($result,0,'demo_name');
$usingorder=$adb->query_result($result,0,'using_order');
$usingcredence=$adb->query_result($result,0,'using_credence');
$usinginventory=$adb->query_result($result,0,'using_inventory');
*/
$softfactory=getDatainterface('soft_factory');
//因为配置连接没有账套，所以在这显示datebasename
if(getDatainterface('setting_mode') == 2){
    $demoname=getDatainterface('databasename');
}else{
    $demoname=getDatainterface('demo_name');
}
$usingorder=getDatainterface('using_order');
$usingcredence=getDatainterface('using_credence');
$usinginventory=getDatainterface('using_inventory');
$using_order_read=getDatainterface('using_order_read');
$using_quote_read=getDatainterface('using_quote_read');
$using_ticket_read=getDatainterface('using_ticket_read');


$smarty->assign("SOFTFACTORY",$softfactory);

$smarty->assign("DEMONAME",$demoname);
if($usingorder==0)
{
    $smarty->assign("USINGORDER",getFixedLabel('NO'));
}
else 
{
   $smarty->assign("USINGORDER",getFixedLabel('YES')); 
}
if($usingcredence==0)
{
    $smarty->assign("USINGCREDENCE",getFixedLabel('NO'));
}
else 
{
    $smarty->assign("USINGCREDENCE",getFixedLabel('YES'));
}
if($usinginventory==0)
{
    $smarty->assign("USINGINVENTORY",getFixedLabel('NO'));
}
else 
{
    $smarty->assign("USINGINVENTORY",getFixedLabel('YES'));
}

if($using_order_read==0)
{
    $smarty->assign("USINGORDERREAD",getFixedLabel('NO'));
}
else 
{
    $smarty->assign("USINGORDERREAD",getFixedLabel('YES'));
}

if($using_quote_read==0)
{
    $smarty->assign("USINGQUOTEREAD",getFixedLabel('NO'));
}
else 
{
    $smarty->assign("USINGQUOTEREAD",getFixedLabel('YES'));
}

if($using_ticket_read==0)
{
    $smarty->assign("USINGTICKETREAD",getFixedLabel('NO'));
}
else 
{
    $smarty->assign("USINGTICKETREAD",getFixedLabel('YES'));
}

//$smarty->assign("MOD", return_module_language($current_language,'Settings'));
$smarty->assign("APP", $app_strings);
$smarty->assign("CMOD", $mod_strings);
$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH",$image_path);
$smarty->assign('OEM_CRM',$common_version['oem_crm']);
require_once('SetmenuControl.php');
$smarty->display("modules/DataInterface/KISSetting.tpl");

?>