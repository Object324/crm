<?php
/*+*******************************************************************************
 *{*修改编码格式:统一编码：UTF-8*} 
 *  The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 *
 *********************************************************************************/

/**
 * @author MAK
 */

global $mod_strings;
global $app_strings;
global $theme;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";

require_once('include/home.php');
require_once('Smarty_setup.php');
require_once('include/freetag/freetag.class.php');

$homeObj=new Homestuff;

Zend_Json::$useBuiltinEncoderDecoder = true;
$widgetInfoList = Zend_Json::decode($_REQUEST['widgetInfoList']);
//$widgetInfoList = Zend_Json::decode($_REQUEST['widgetInfoList']);
$widgetHTML = array();
$smarty=new lingdangCRM_Smarty;
$smarty->assign("MOD",$mod_strings);
$smarty->assign("APP",$app_strings);
$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH",$image_path);
/**
 * AUTHOR:BY LD KEVIN
 * 20130226
 */
foreach ($widgetInfoList as $widgetInfo) {
	$widgetType = $widgetInfo['widgetType'];
	$widgetId = $widgetInfo['widgetId'];
	/*if($widgetType=='Tag Cloud'){
		$freetag = new freetag();
		$smarty->assign("ALL_TAG",$freetag->get_tag_cloud_html("",$current_user->id));
		$html = $smarty->fetch("Home/TagCloud.tpl");
	}elseif($widgetType == 'Notebook'){
		$contents = $homeObj->getNoteBookContents($widgetId);
		$smarty->assign("NOTEBOOK_CONTENTS",$contents);
		$smarty->assign("NOTEBOOKID", $widgetId);
		$html = $smarty->fetch("Home/notebook.tpl");
	}elseif($widgetType == 'URL'){
		$url = $homeObj->getWidgetURL($widgetId);
		if(strpos($url, "://") === false){
			$url = "http://".trim($url);
		}
		$smarty->assign("URL",$url);
		$smarty->assign("WIDGETID", $widgetId);
		$html = $smarty->fetch("Home/HomeWidgetURL.tpl");
	}else{
		$homestuff_values=$homeObj->getHomePageStuff($widgetId,$widgetType);
		$html = '';
		if($widgetType == "DashBoard"){
			$homeObj->getDashDetails($widgetId,'type');
			$dashdet=$homeObj->dashdetails;
			$smarty->assign("DASHDETAILS",$dashdet);
		}
	}*/
    $homestuff_values=$homeObj->getHomePageStuff($widgetId,$widgetType);
	$html = '';
    $homedetails = $homeObj->getHomePageFrame();
	$type = 'default';
	foreach($homedetails as $infos){
		if($infos['Stuffid'] == $stuffid){
			$type = $infos['Stufftype'];
		}
	}
    if($type=='notebook'){
        $contents = $homeObj->getNoteBookContents($widgetId);
		$smarty->assign("NOTEBOOK_CONTENTS",$contents);
		$smarty->assign("NOTEBOOKID", $widgetId);
		$html = $smarty->fetch("Home/notebook.tpl");
    }
    elseif($type=='default'){
        $smarty->assign("HOME_STUFFTYPE",$type);
    	$smarty->assign("HOME_STUFFID",$widgetId);
    	$smarty->assign("HOME_STUFF",$homestuff_values);  
    	$smarty->assign("THEME", $theme);
    	$smarty->assign("IMAGE_PATH", $image_path);    
    	$html = $smarty->fetch("Home/HomeBlock.tpl");
    }
    elseif($type=='table'){
        $smarty->assign("HOME_STUFFTYPE",$type);
        $smarty->assign("HOME_STUFFID",$widgetId);         
         $smarty->assign("HOME_STUFF",$homestuff_values);
         $html = $smarty->fetch("Home/HomeTable.tpl");         
    }
    elseif($type=='chart'){
        $smarty->assign("HOME_STUFF",$homestuff_values);      
        //$html .=$smarty->fetch("Home/HomeChart.tpl");
       $html ="<div id='chartid'></div>".chart();
    }
	$widgetHTML[$widgetId] = $html;
}
echo Zend_JSON::encode($widgetHTML);
?>
<?php 
function chart(){
include("include/FusionCharts/class/FusionCharts.php");
$chartxml="<chart numberPrefix='$' isSliced='1' streamlinedData='0' isHollow='0'>
  <set label='Buchanan' value='20000'/>
  <set label='Callahan' value='49000'/>
  <set label='Davolio' value='63000'/>
  <set label='Dodsworth' value='41000'/>
  <set label='Fuller' value='74000'/>
  <set label='King' value='49000'/>
  <set label='Leverling' value='77000'/>
  <set label='Peacock' value='54000'/>
  <set label='Suyama' value='14000'/>
</chart>";
echo renderChartHTML("include/FusionCharts/FCF_Funnel.swf","",$chartxml, "chartid", 400, 210);
}
?>