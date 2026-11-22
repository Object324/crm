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
require_once 'include/utils/CommonUtils.php';
require_once 'modules/Tooltip/TooltipUtils.php';

global $current_user;

$modname = $_REQUEST['modname'];
$id = $_REQUEST['id'];
$fieldname = $_REQUEST['fieldname'];
$tabid = getTabid($modname);
$result = ToolTipExists($fieldname,$tabid);
//echo $modname;
if($result !== false){
//get tooltip information
	$viewid = 1;	//viewid is 1 by default
	$descObject = vtws_describe($modname,$current_user);
	$id = vtws_getWebserviceEntityId($modname, $id);
	$sql = "select * from " .$modname ." where id ='$id';";
    //echo $sql;
	$result = vtws_query($sql, $current_user);
   
	if(empty($result)){
	   // echo $fieldname;
		exit(0);
	}
	$result = vttooltip_processResult($result, $descObject);
    //print_r($result);
  //echo $modname
   // echo $viewid;
	$text = getToolTipText($viewid, $fieldname,$modname,$result);
   // print_r($text);
	$tip = getToolTip($text);
	//echo $modname.$fieldname;
    echo $tip;
}else {
	echo false;
}

?>