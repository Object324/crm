<?php
/*+********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ********************************************************************************/

global $app_strings;
global $app_list_strings;
global $mod_strings;
global $adb;
$trackpostion_id = vtlib_purify($_REQUEST['trackpostion_id']);
$operatetype = vtlib_purify($_REQUEST['operatetype']);
$smarty=new lingdangCRM_Smarty;
$smarty->assign("APP", $app_strings);
//$smarty->assign("MOD", return_module_language($current_language,'Settings'));

$smarty->assign("CMOD", $mod_strings);
global $theme;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";
$smarty->assign("IMAGE_PATH",$image_path);
$query ='
        select 
            ld_trackpostion.trackpostion_id,
            ld_trackpostion.trackpostion,
            ld_trackpostion.starttime,
            ld_trackpostion.stoptime,
          ld_trackpostion.cycle,
          ld_trackpostion.frequency
        from ld_trackpostion 
   
        where ld_trackpostion.trackpostion_id=?';
$result = $adb->pquery($query,array($trackpostion_id));
$num_rows = $adb->num_rows($result);
$frequency=5;
for($i = 0; $i<$num_rows; $i++){
    $trackpostion_id = $adb->query_result($result,$i,'trackpostion_id');
	$trackpostion = $adb->query_result($result,$i,'trackpostion');
	$starttime = $adb->query_result($result,$i,'starttime');
    $stoptime = $adb->query_result($result,$i,'stoptime');
    $workcalender_id = $adb->query_result($result,$i,'workcalender_id');
    $cycle=$adb->query_result($result,$i,'cycle');
    $frequency=$adb->query_result($result,$i,'frequency');


    //$workcalender_name = $adb->query_result($result,$i,'workcalender_name');
}
$workcalenderquery='SELECT workcalender_id,workcalender_name from ld_workcalender';
$workcalender_result = $adb->pquery($workcalenderquery);
$workcalender_num_rows = $adb->num_rows($workcalender_result);
for($j = 0; $j<$workcalender_num_rows; $j++){
    
    $workcalender_names[$j]['workcalender_id']=$adb->query_result($workcalender_result,$j,'workcalender_id');
    $workcalender_names[$j]['workcalender_name']=$adb->query_result($workcalender_result,$j,'workcalender_name');
}
$smarty->assign("cycle",$cycle);
$smarty->assign("frequency",$frequency);

$smarty->assign('WORKCALENDERNAMES',$workcalender_names);
$smarty->assign('TRACKPOSTIONID',$trackpostion_id);
$smarty->assign('STARTTIME',$starttime);
$smarty->assign('STOPTIME',$stoptime);
$smarty->assign('TRACKPOSTIONNAME',$trackpostion);
$smarty->assign('WORKCALENDERID',$workcalender_id);
//$smarty->assign('WORKCALENDERNAME',$workcalender_name);
$smarty->assign('OPERATETYPE',$operatetype);
$smarty->assign('BLOCKIDSETTING',$_REQUEST['blockidsetting']);
$smarty->assign('FIELDIDSETTING',$_REQUEST['fieldidsetting']);
//echo '&#&#&#';
//$smarty->display("EditTracks.tpl");
$_REQUEST['diony']='yes';


$arr=array();
$arr['content']=$smarty->fetch("EditTracks.tpl");
if($_REQUEST['trackpostion_id']>0)
    $arr['title']=getFixedLabel("EDIT").getFixedLabel("TRACKGROUP");
else
    $arr['title']=getFixedLabel("CREATE").getFixedLabel("TRACKGROUP");
$arr['urlparam_arr']=[];
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
ConvertTojsonString(1,$arr,'success');
?>