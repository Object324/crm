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

global $mod_strings;
global $app_strings;
global $theme;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";

if(isset($_REQUEST['return_module']) && $_REQUEST['return_module']=="PriceBooks")
{
	$pricebook_id = vtlib_purify($_REQUEST['pricebook_id']);
	$product_id = vtlib_purify($_REQUEST['record']);
	$listprice = vtlib_purify($_REQUEST['listprice']);
	$return_action = "CallRelatedList";
	$return_id = vtlib_purify($_REQUEST['pricebook_id']);
}
else
{
	$product_id = vtlib_purify($_REQUEST['record']);
	$pricebook_id = vtlib_purify($_REQUEST['pricebook_id']);
	$listprice = getListPrice($product_id,$pricebook_id);
	$return_action = "CallRelatedList";
	$return_id = vtlib_purify($_REQUEST['pricebook_id']);
}


$output='';
//$output ='<div id="roleLay" style="display:block;" class="D_pop_box LdPopWidth400px">
//
//
//<table class="D_pop_bod" border="0" cellpadding="1" cellspacing="1">
//    <tr>
//    	<td align="right">'.getFixedLabel('EDIT').' '.getFixedLabel('WHOLESALEPRICE').'</td>
//    	<td><input class="dataInput" type="text" id="list_price" name="list_price" value="'.$listprice.'" style="border:1px solid #eee;"/></td>
//    </tr>
//</table>
//<div class="D_pbtn">
//	<input type="button" class="D_pbtnok" value="'.getFixedLabel('SAVE').'" onclick="if(verify_data() == true) gotoUpdateListPrice('.$return_id.','.$pricebook_id.','.$product_id.'); else document.getElementById(\'roleLay\').style.display=\'inline\'; return false;"/><span>&nbsp;</span>
//    <input type="button" class="D_pbtncancel" value="'.getFixedLabel("CANCEL").'" onclick="fninvsh(\'editlistprice\');puyoungJS_DialogBox.unblock();"/>   
//</div>
//
//
//</div>';
$output='<table class="settingPopTable lasttdbordernon pad2010" border="0" cellpadding="0" cellspacing="0" width="100%">
    <tr>
    	<td align="right">'.getFixedLabel('EDIT').' '.getFixedLabel('WHOLESALEPRICE').'</td>
    	<td><input class="commonTextBoxPop" type="text" id="list_price" name="list_price" value="'.$listprice.'"/></td>
    </tr>
</table>';
$arr['title']=getFixedLabel('EDIT').' '.getFixedLabel('WHOLESALEPRICE');

$arr['content']=$output;
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$_REQUEST['diony']='yes';
ConvertTojsonString(1,$arr,'success');



?>