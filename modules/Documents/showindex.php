<?php

/*********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 ** The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
*
 ********************************************************************************/


global $adb;

if($_REQUEST['type'] == 'savedocModuleTableSort') {
    $type = $_REQUEST['type'];
//保存审批流程排序 weiyannan 20231123 XUQIU1002038 后台设置列表界面可以做排序 XUQIU1002038 后台设置列表界面可以做排序（仿照单据分录定制那样，可以通过拖拽排序）
    if ($type == 'savedocModuleTableSort') {
        if (!empty($_REQUEST['tagids'])) {
            $tagids_arr = explode(',', $_REQUEST['tagids']);
            $sequence = 1;
            foreach ($tagids_arr as $id) {
                $adb->pquery('update ld_documenttemplates set sequence = ? where templateid = ?', array($sequence, $id));
                $sequence++;
            }
            ConvertTojsonString(1,array(),"success");
        }
    }
}

   $sql = "select * from ld_documenttemplates order by sequence, templateid DESC";
   $result = $adb->pquery($sql, array());
   $temprow = $adb->fetch_array($result);
   
$edit="Edit  ";
$del="Del  ";
$bar="  | ";
$cnt=1;


global $app_strings;
global $app_list_strings;
global $mod_strings;
global $theme,$default_charset;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";

$smarty = new lingdangCRM_Smarty;

$smarty->assign("APP", $app_strings);

//echo $module;
$smarty->assign("MODULE", $module);
$smarty->assign("DOCUMNETSMODULELABEL", getTranstab('Documents'));
$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH", $image_path);
$smarty->assign("PARENTTAB", "Settings");

$return_data=array();
if ($temprow != null)
{
do
{
  $templatearray=array();
  $templatearray['templatename'] = $temprow["templatename"];
  $templatearray['templateid'] = $temprow["templateid"];
  $templatearray['description'] = $temprow["description"];
  $templatearray['foldername'] = $temprow["foldername"];
  $return_data[]=$templatearray;
  $cnt++;
}while($temprow = $adb->fetch_array($result));
}


$smarty->assign("TEMPLATES",$return_data);
$_REQUEST['diony']='yes';
// require_once("modules/Settings/SetmenuControl.php");
$arr['content']= $smarty->fetch('showdocumenttemplates.tpl');
ConvertTojsonString(1,$arr,"success");
?>