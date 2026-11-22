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

require_once('include/utils/utils.php');

global $mod_strings;
global $app_strings;
global $theme,$default_charset;
$theme_path="themes/".$theme."/";
$delete_prof_id = vtlib_purify($_REQUEST['profileid']);
$delete_prof_name = getProfileName($delete_prof_id);

$output='';
$output ='<div id="DeleteLay" class="layerPopup ltextalign bgwhite">
<form name="newProfileForm" action="index.php" onsubmit="puyoungJS_DialogBox.block();">
<input type="hidden" name="module" value="Users">
<input type="hidden" name="action" value="DeleteProfile">
<input type="hidden" name="delete_prof_id" value="'.$delete_prof_id.'">	
<table border=0 cellspacing=0 cellpadding=5 width=100% class=layerHeadingULine>
<tr>
	<td class="layerPopupHeading" align="left">'.$mod_strings["LBL_DELETE_PROFILE"].'</td>
	<td align="right"><a class="icon-homeimg icon-close" href="javascript:;" title="'.$app_strings["LBL_CLOSE"].'" onClick="document.getElementById(\'DeleteLay\').style.display=\'none\'";></a></td>
</tr>
</table>
<table border=0 cellspacing=0 cellpadding=5 width=95% align=center> 
<tr>
	<td class="small">
	<table border=0 celspacing=0 cellpadding=5 width=100% align=center bgcolor=white>
	<tr>
		<td width="50%" class="cellLabel small"><b>'.$mod_strings["LBL_PROFILE_TO_BE_DELETED"].'</b></td>
		<td width="50%" class="cellText small"><b>'.htmlentities($delete_prof_name,ENT_QUOTES,$default_charset).'</b></td>
	</tr>
	<tr>
		<td align="left" class="cellLabel small" nowrap><b>'.$mod_strings["LBL_TRANSFER_ROLES_TO_PROFILE"].'</b></td>
		<td align="left" class="cellText small">';
		$output.='<select class="select" name="transfer_prof_id">';
		global $adb;	
		$sql = "select * from ld_profile";
		$result = $adb->pquery($sql, array());
		$temprow = $adb->fetch_array($result);
		do
		{
			$prof_name=htmlentities($temprow["profilename"],ENT_QUOTES,$default_charset);
			$prof_id=$temprow["profileid"];
			if($delete_prof_id != $prof_id)
			{	 
    				$output.='<option value="'.$prof_id.'">'.$prof_name.'</option>';
			}	
		}while($temprow = $adb->fetch_array($result));
		$output.='</select>';

		$output.='</td>
	</tr>
	</table>
	</td>
</tr>
</table>
<table border=0 cellspacing=0 cellpadding=5 width=100% class="layerPopupTransport">
<tr>
	<td align=center class="small">
	<input type="submit" name="Delete" value="'.$app_strings["LBL_SAVE_BUTTON_LABEL"].'">
	</td>
</tr>
</table>
</form></div>';

echo $output;
?>