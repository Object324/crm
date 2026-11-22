<?php
/*+********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 *******************************************************************************/
require_once('Smarty_setup.php');
require_once('modules/PriceBooks/PriceBooks.php');;

global $app_strings,$mod_strings,$current_language,$theme,$currentModule,$adb,$current_user;
 $product_field_obj=Field::getInstance('Products',$adb);
  $languagetranslate=new LanguageTranslate($current_user,'Products',14,$adb);
$arrFieldLabel=$product_field_obj->getFieldLables();
$current_module_strings = return_module_language($current_language, $currentModule);

$productid = $_REQUEST['return_id'];
$parenttab = getParentTab();
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";
require_once('modules/lingdang/layout_utils.php');
$productNameArr = getEntityName($currentModule, array($productid));
$productname = $productNameArr[$productid];

if(getFieldVisibilityPermission($currentModule,$current_user->id,'unit_price') != '0'){
	echo "<link rel='stylesheet' type='text/css' href='themes/$theme/style.css'>";	
	echo "<table border='0' cellpadding='5' cellspacing='0' width='100%' height='450px'><tr><td align='center'>";
	echo "<div style='border: 3px solid rgb(153, 153, 153); background-color: rgb(255, 255, 255); width: 55%; position: relative; z-index: 10000000;'>

		<table border='0' cellpadding='5' cellspacing='0' width='98%'>
		<tbody><tr>
		<td rowspan='2' width='11%'><img src=". lingdang_imageurl('denied.gif', $theme) ."' ></td>
		<td style='border-bottom: 1px solid rgb(204, 204, 204);' nowrap='nowrap' width='70%'><span class='genHeaderSmall'>".getFixedLabel('ACCESSDENIEDPRICEPROD')."</span></td>
		</tr>
		<tr>
		<td class='small' align='right' nowrap='nowrap'>			   	
		<a href='javascript:window.history.back();'>".getFixedLabel('RETURN')."</a><br>								   						     </td>
		</tr>
		</tbody></table> 
		</div>";
	echo "</td></tr></table>";
	exit();
}

$smarty=new lingdangCRM_Smarty; 

$smarty->assign("MOD", $mod_strings);
$smarty->assign("APP", $app_strings);
$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH",$image_path);

$focus = new PriceBooks();

//Retreive the list of PriceBooks
$list_query = getListQuery("PriceBooks");

$list_query .= ' and ld_pricebook.active<>0  ORDER BY ld_pricebook.pricebookid DESC ';

$list_result = $adb->query($list_query);
$num_rows = $adb->num_rows($list_result);

$record_string= "Total No of PriceBooks : ".$num_rows;

//Retreiving the array of already releated products
$sql1="select ld_crmentity.crmid, ld_pricebookproductrel.pricebookid,ld_products.unit_price 
			from ld_pricebookproductrel inner join ld_crmentity on ld_crmentity.crmid=ld_pricebookproductrel.productid 
			inner join ld_products on ld_products.productid=ld_pricebookproductrel.productid 		
			where ld_crmentity.deleted=0 and ld_pricebookproductrel.productid=?";
$res1 = $adb->pquery($sql1, array($productid));
$num_prod_rows = $adb->num_rows($res1);
$pbk_array = Array();
for($i=0; $i<$num_prod_rows; $i++)
{
	$pbkid=$adb->query_result($res1,$i,"pricebookid"); 
	$pbk_array[$pbkid] = $pbkid;
}

$pro_unit_price = getUnitPrice($productid, $currentModule); 
$prod_price_details = getPriceDetailsForProduct($productid, $pro_unit_price);

$prod_cur_price = array();
for($i=0; $i<count($prod_price_details); $i++)
{
	$prod_cur_info = $prod_price_details[$i];
	$prod_cur_price[$prod_cur_info['curid']] = $prod_cur_info['curvalue'];
}

$unit_price_array=array();
$field_name_array=array();

$other_text = '
	<table border="0" cellpadding="1" cellspacing="0" width="90%" align="center">
	<form name="addToPB" method="POST" id="addToPB">
	   <tr>
		<td align="center">&nbsp;
			<input name="product_id" type="hidden" value="'.$productid.'">
			<input name="idlist" type="hidden">
			<input name="viewname" type="hidden">';

	//we should not display the Add to PriceBook button if there is no pricebooks to associate
	if($num_rows != $num_prod_rows)
        	$other_text .='<input class="saveauto" type="button" value="'.getFixedLabel('ADDTO').' '.getTranstab('PriceBooks').'" onclick="return addtopricebook()"/>&nbsp;';

$other_text .='<input title="'.getFixedLabel('CANCEL').'" class="cancelauto" onclick="window.history.back()" type="button" name="button" value="'.getFixedLabel('CANCEL').'"></td>';
$other_text .='
	   </tr>
	</table>';

$smarty->assign("PRICEBOOKLISTHEADER", get_form_header(getFixedLabel('PRICEBOOKSLIST'), $other_text, false ));


//List View Table Header
$list_header = '';
$list_header .= '<tr>';
$list_header .='<td class="lvtCol commonCol" width="5%"><input type="checkbox" name="selectall" onClick=\'toggleSelect(this.checked,"selected_id");updateAllListPrice() \'></td>';
$list_header .= '<td class="lvtCol commonCol" width="35%">'.$arrFieldLabel['productname'].'</td>';
$list_header .= '<td class="lvtCol commonCol" width="20%">'.$arrFieldLabel['productcode'].'</td>';
$list_header .= '<td class="lvtCol commonCol" width="20%">'.$arrFieldLabel['unit_price'].'</td>';
$list_header .= '<td class="lvtCol commonCol" width="20%">'.getFixedLabel('WHOLESALEPRICE').'</td>';
$list_header .= '</tr>';

$smarty->assign("LISTHEADER", $list_header);

$list_body ='';
for($i=0; $i<$num_rows; $i++)
{	
	$entity_id = $adb->query_result($list_result,$i,"crmid");
	if(! array_key_exists($entity_id, $pbk_array))
	{
		$pk_currency_id = $adb->query_result($list_result,$i,"currency_id");
		$pk_currency_name = $adb->query_result($list_result,$i,"currency_name");
		$unit_price = $prod_cur_price[$pk_currency_id];
		$field_name = $entity_id."_listprice";
		$unit_price_array[]='"'.$unit_price.'"';
		$field_name_array[]="'".$field_name."'";
		
		$list_body .= '<tr class="lvtColData" onmouseover="this.className=\'lvtColDataHover\'" onmouseout="this.className=\'lvtColData\'" bgcolor="white">';
		$list_body .= '<td><INPUT type=checkbox NAME="selected_id" id="check_'.$entity_id.'" value= '.$entity_id.' onClick=\'toggleSelectAll(this.name,"selectall");updateListPriceForField("'.$field_name.'",this)\'></td>';
		$list_body .= '<td>'.$adb->query_result($list_result,$i,"bookname").'</td>';
		$list_body .= '<td>'.$pk_currency_name.'</td>';
		$list_body .= '<td>'.$unit_price.'</td>';

		$list_body .='<td>';
		if(isPermitted("PriceBooks","EditView","") == 'yes')
			$list_body .= '<input type="text" name="'.$field_name.'" style="visibility:hidden;" id="'.$field_name.'">';
		else
			$list_body .= '<input type="text" name="'.$field_name.'" style="visibility:hidden;" readonly id="'.$field_name.'">';	
		$list_body .= '</td></tr>';
	}

}

$smarty->assign("UNIT_PRICE_ARRAY",implode(",",$unit_price_array));
$smarty->assign("FIELD_NAME_ARRAY",implode(",",$field_name_array));

if($order_by !='')
	$url_string .="&order_by=".$order_by;
if($sorder !='')
	$url_string .="&sorder=".$sorder;

$smarty->assign("LISTENTITY", $list_body);
$smarty->assign("RETURN_MODULE", vtlib_purify($_REQUEST['return_module']));
$smarty->assign("RETURN_ACTION", vtlib_purify($_REQUEST['return_action']));
$smarty->assign("RETURN_ID", $productid);
$smarty->assign("CATEGORY", $parenttab);

$smarty->display("AddProductToPriceBooks.tpl");

?>