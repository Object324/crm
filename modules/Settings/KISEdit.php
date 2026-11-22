<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 
require_once('Smarty_setup.php');
global $mod_strings;
global $app_strings;
global $app_list_strings;
global $adb;
global $theme;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";
if(!isset($_REQUEST['return_action'])&&!isset($_REQUEST['openfile']))
{
    /*
    $sql="select * from ld_DataInterface";
    $result=$adb->pquery($sql,array());
    $softversion=$adb->query_result($result,0,'soft_version');
    $softfactory=$adb->query_result($result,0,'soft_factory');
    $demoname=$adb->query_result($result,0,'demo_name');
    $usingorder=$adb->query_result($result,0,'using_order');
    $usingcredence=$adb->query_result($result,0,'using_credence');
    $usinginventory=$adb->query_result($result,0,'using_inventory');
    $sa=$adb->query_result($result,0,'sa');
    $PassWord=$adb->query_result($result,0,'pwd');
    $hostname=$adb->query_result($result,0,'hostname');
    $databasename=$adb->query_result($result,0,'databasename');
    */
    $softversion=getDatainterface('soft_version');
    $softfactory=getDatainterface('soft_factory');
    $demoname=getDatainterface('demo_name');
    $usingorder=getDatainterface('using_order');
    $usingcredence=getDatainterface('using_credence');
    $usinginventory=getDatainterface('using_inventory');
    $using_order_read=getDatainterface('using_order_read');
    $using_quote_read=getDatainterface('using_quote_read');
    $using_ticket_read=getDatainterface('using_ticket_read');
    $setting_mode =getDatainterface('setting_mode');
    $sa=getDatainterface('sa');
    $PassWord=getDatainterface('pwd');
    $hostname=getDatainterface('hostname');
    $databasename=getDatainterface('databasename');
    $connect_mode=getDatainterface('connect_mode');
}
else 
{
    
}

if($_REQUEST['openfile'])
{
    $vbOpenFile=new COM("ComRegister.vbFile");
   // $hostname=$vbOpenFile->openFileDialog();
    $databasename=$hostname;
    $demoname=$hostname;
    $sa="morningstar";
    $pwd="ypbwkfyjhyhgzj";
    $softfactory="金蝶";
    $usingcredence=$_REQUEST['usingcredence'];
    $usingorder=$_REQUEST['usingorder'];
    $softversion=$_REQUEST['softversion'];
    
}
$smarty = new lingdangCRM_Smarty;

$smarty->assign("SOFTFACTORY",$softfactory);

//金蝶
$versionHtml="<select name='soft_version' id='soft_version' onchange='changesel(this)' class='btn-radius-system'>";
$versionHtml .="<option value='1'>K3系统</option>";
$versionHtml .="<option value='2'>KIS专业版</option>";
$versionHtml .="<option value='5'>KIS旗舰版</option>";
//$versionHtml .="<option value='3'>".$mod_strings['LBL_KIS_STANDARD']."</option>";
//$versionHtml .="<option value='4'>".$mod_strings['LBL_KIS_MINI']."</option>";
$versionHtml .="</select>";

//用友
$versionYy="<select name='soft_version_1' onchange='changesel(this)'>";
$versionYy .="<option value='101'>T+</option>";
$versionYy .="<option value='103'>T6</option>";
$versionYy .="<option value='102'>U8+</option>";
$versionYy .="</select>";
//鼎捷
$versionDj="<select name='soft_version_2' onchange='changesel(this)'>";
$versionDj .="<option value='201'>易助7.0</option>";
$versionDj .="</select>";

if($softversion < 100){
    $kischecked = 'selected';
}elseif($softversion>=100 && $softversion<200){
    $yychecked = 'selected';
}else{
    $djchecked = 'selected';
}
$softfactoryHtml="<select name='soft_factory' id= 'soft_factory' onchange='changesoft(this)' class='btn-radius-system'>";
$softfactoryHtml .="<option value='金蝶' ".$kischecked.">金蝶</option>";
$softfactoryHtml .="<option value='用友' ".$yychecked.">用友</option>";
$softfactoryHtml .="<option value='鼎捷' ".$djchecked.">鼎捷</option>";
$softfactoryHtml .="</select>";
$smarty->assign("SOFTFACTORYHTML",$softfactoryHtml);
$smarty->assign("VERSIONHTML",$versionHtml);
$smarty->assign("VERSIONYY",$versionYy);
$smarty->assign("VERSIONDJ",$versionDj);
$smarty->assign("SOFTVERSION",$softversion);
$smarty->assign("DEMONAME",$demoname);
$smarty->assign("USINGORDER",$usingorder);
$smarty->assign("USINGCREDENCE",$usingcredence);
$smarty->assign("USINGINVENTORY",$usinginventory);
$smarty->assign("USINGORDERREAD",$using_order_read);
$smarty->assign("USINGQUOTEREAD",$using_quote_read);
$smarty->assign("USINGTICKETREAD",$using_ticket_read);
$smarty->assign("SA",$sa);
$smarty->assign("PASSWORD",$PassWord);
$smarty->assign("DATABASENAME",$databasename);
$smarty->assign("HOSTNAME",$hostname);
//$smarty->assign("MOD", return_module_language($current_language,'Settings'));
$smarty->assign("APP", $app_strings);
$smarty->assign("CMOD", $mod_strings);
$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH",$image_path);
$smarty->assign("SETTING_MODE",$setting_mode);
$smarty->assign("CONNECTMODE",$connect_mode);

require_once('SetmenuControl.php');

$smarty->display("modules/DataInterface/KISEdit.tpl");


?>