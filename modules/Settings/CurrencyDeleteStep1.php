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

require_once('include/utils/utils.php');

global $mod_strings;
global $app_strings;
global $theme;
$theme_path="themes/".$theme."/";

$delete_currency_id = $_REQUEST['id'];
$sql = "select * from ld_currency_info where id=?";
$result = $adb->pquery($sql, array($delete_currency_id));
$delete_currencyname = $adb->query_result($result,0,"currency_name");


$output='';
$output ='<div id="CurrencyDeleteLay" class="ltextalign width350">
<form name="newCurrencyForm" action="index.php" style="margin:0" onsubmit="puyoungJS_DialogBox.block();">
<input type="hidden" name="module" value="Settings">
<input type="hidden" name="action" value="CurrencyDelete">
<input type="hidden" name="delete_currency_id" value="'.$delete_currency_id.'">	

<div class="D_pop_tit">
    <strong class="D_ptita">'.getFixedLabel('DELETINGCURRENCY').'</strong>
    <a href="javascript:fninvshnew(\'currencydiv\');" class="D_ptitc">
    	<img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="'.getFixedLabel('CLOSE').'" title="'.getFixedLabel('CLOSE').'"/>
    </a>
</div>	
<table class="D_pop_bod" cellspacing="1" cellpadding="2" width="100%" border="0" align="center">
	<tr>
		<td width="50%" align="right">'.getFixedLabel('THEMONEYWILLBEDELETED').'</td>
		<td width="50%" >'.getTranslatedCurrencyString($delete_currencyname).'</td>
	</tr>
	<tr>
		<td align="right">'.getFixedLabel('USERSTOTRANSFERMONEY').'</td>
		<td >';
			   
	$output.='<select class="select small" name="transfer_currency_id" id="transfer_currency_id" style="border:1px solid #dadada;">';
			 
			 global $adb;	
			 $sql = "select * from ld_currency_info where currency_status = ? and deleted=0";
			 $result = $adb->pquery($sql, array('Active'));
			 $temprow = $adb->fetch_array($result);
			 do
			 {
				$currencyname=$temprow["currency_name"];
				$currencyid=$temprow["id"];
				if($delete_currency_id 	!= $currencyid)
				{	 
					$output.='<option value="'.$currencyid.'">'.getTranslatedCurrencyString($currencyname).'</option>';
				}	
			 }while($temprow = $adb->fetch_array($result));
	
	$output.='</td>
	</tr>
</table>
<div class="D_pbtn">
	<input type="button" class="D_pbtnok" onclick="transferCurrency('.$delete_currency_id.')" name="Delete" value="'.getFixedLabel('SAVE').'"><span>&nbsp;</span>   
</div>
</form></div>';

echo $output;
?>