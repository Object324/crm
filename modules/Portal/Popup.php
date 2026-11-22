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

require_once('modules/Portal/Portal.php');
global $app_strings,$app_list_strings,$mod_strings,$adb,$theme;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";
if(isset($_REQUEST['record']) && $_REQUEST['record'] !='')
{
	$portalid = $_REQUEST['record'];
	$query="select * from ld_portal where portalid =?";
	$result=$adb->pquery($query, array($portalid));
	$portalname = $adb->query_result($result,0,'portalname');
        $portalurl = $adb->query_result($result,0,'portalurl');	
	/* to remove http:// from portal url*/
	$portalurl = preg_replace("/http:\/\//i","",$portalurl);	
}
$portal_inputs='';
$portal_inputs.='<div style="display:block;position:relative;" id="orgLay" class="layerPopup">
		<form onSubmit="OnUrlChange(); SaveSite(\''.$portalid.'\');return false;" >
		<table border="0" cellpadding="3" cellspacing="0" width="100%" class="layerHeadingULine">
		<tr>
			<td class="layerPopupHeading" align="left" width="60%">' .$mod_strings['LBL_ADD'] .' '.$mod_strings['LBL_BOOKMARK'].'</td>
			<td align="right" width="40%"><a class="icon-homeimg icon-close" href="javascript:fninvsh(\'orgLay\');"></a></td>
		</tr>
		</table>
<table border="0" cellspacing="0" cellpadding="5" width="95%" align="center"> 
	<tr>
	<td class="small" >
		<table border="0" celspacing="0" cellpadding="5" width="100%" align="center" bgcolor="white">
		
		<tr>

			<td align="right" width="40%" ><b>'.$mod_strings['LBL_BOOKMARK'].' ' .$mod_strings['LBL_URL'] .' </b></td>
			<td align="left" width="60%">http://<input name="portalurl" id="portalurl" class="txtBox" value="'.$portalurl.'" type="text" onkeyup="OnUrlChange();"></td>
		</tr>
		<tr>
			<td align="right" width="40%"> <b>'.$mod_strings['LBL_BOOKMARK'].' ' .$mod_strings['LBL_NAME'] .' </b></td>
			<td align="left" width="60%"><input name="portalname" id="portalname" value="'.$portalname.'" class="txtBox" type="text"></td>
		</tr>
		</table>
	</td>
	</tr>
</table>
<table border="0" cellspacing="0" cellpadding="5" width="100%" class="layerPopupTransport">
	<tr>
	<td align="center">
			<input name="save" value=" &nbsp;'.$app_strings['LBL_SAVE_BUTTON_LABEL'].'&nbsp; " class="save"  type="submit">&nbsp;&nbsp;
			<input name="cancel" value=" '.$app_strings['LBL_CANCEL_BUTTON_LABEL'].' " class="cancel" onclick="fninvsh(\'orgLay\');" type="button">
	</td>
	</tr>
</table>
</form>
</div>';
	
echo $portal_inputs;


?>