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

require_once('include/home.php');
require_once('modules/Rss/Rss.php');
$oHomestuff=new Homestuff();
if(!empty($_REQUEST['stufftype'])){
	$oHomestuff->stufftype=$_REQUEST['stufftype'];
} 

if(!empty($_REQUEST['stufftitle'])){
	if(strlen($_REQUEST['stufftitle'])>100){
		$temp_str = substr($_REQUEST['stufftitle'],0,97)."...";
		$oHomestuff->stufftitle= $temp_str;
	}else{
		$oHomestuff->stufftitle=$_REQUEST['stufftitle'];
	}
	// Remove HTML/PHP tags from the input
	if(isset($oHomestuff->stufftitle)) {
		$oHomestuff->stufftitle = strip_tags($oHomestuff->stufftitle);
	}
}

if(!empty($_REQUEST['selmodule'])){
	$oHomestuff->selmodule=$_REQUEST['selmodule'];
}

if(!empty($_REQUEST['maxentries'])){
	$oHomestuff->maxentries=$_REQUEST['maxentries'];
}

if(!empty($_REQUEST['selFiltername'])){
	$oHomestuff->selFiltername=$_REQUEST['selFiltername'];
}

if(!empty($_REQUEST['fldname'])){
	$oHomestuff->fieldvalue=$_REQUEST['fldname'];
}
	
if(!empty($_REQUEST['txtRss'])){
	$ooRss=new lingdangRSS();
	if($ooRss->setRSSUrl($_REQUEST['txtRss'])){
		$oHomestuff->txtRss=$_REQUEST['txtRss'];
	}else{
		return false;
	}
}

if(!empty($_REQUEST['txtURL'])){
	$oHomestuff->txtURL = $_REQUEST['txtURL'];
}
if(isset($_REQUEST['seldashbd']) && $_REQUEST['seldashbd']!=""){
	$oHomestuff->seldashbd=$_REQUEST['seldashbd'];
}

if(isset($_REQUEST['seldashtype']) && $_REQUEST['seldashtype']!=""){
	$oHomestuff->seldashtype=$_REQUEST['seldashtype'];
}
	
if(isset($_REQUEST['seldeftype']) && $_REQUEST['seldeftype']!=""){
	$seldeftype=$_REQUEST['seldeftype'];
	$defarr=explode(",",$seldeftype);
	$oHomestuff->defaultvalue=$defarr[0];
	$deftitlehash=$defarr[1];
	$oHomestuff->defaulttitle=str_replace("#"," ",$deftitlehash);
}

if(isset($_REQUEST['selreport']) && $_REQUEST['selreport']!=""){
    $oHomestuff->selreport = $_REQUEST['selreport'];
}

if(isset($_REQUEST['selreportcharttype']) && $_REQUEST['selreportcharttype']!=""){
    $oHomestuff->selreportcharttype = $_REQUEST['selreportcharttype'];
}

$loaddetail=$oHomestuff->addStuff();
echo $loaddetail;	
?>