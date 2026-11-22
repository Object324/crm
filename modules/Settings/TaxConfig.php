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

global $adb;

global $current_user;
$_SESSION[globalStatic::$root_directory.'prevmenu_modulefile'.$current_user->id]='SettingLeftRight';
$_SESSION[globalStatic::$root_directory.'prevmenu_modilefile_childmenu'.$current_user->id]='TaxConfig';
$_SESSION[globalStatic::$root_directory.'prevmenu_module'.$current_user->id]='Settings';
$smarty = new lingdangCRM_Smarty;
global $theme;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";

crm_load_function_file('getAllTaxes','include/utils','InventoryUtils');
//To save the edited value

if($_REQUEST['savetax'] == 'yes'){
    $taxid = $_REQUEST['taxid'];
    $new_labels[$taxid] = $_REQUEST['tax'];
    $new_percentages[$taxid] = $_REQUEST['taxrate'];
    $new_taxname[$taxid] = $_REQUEST['taxname'];
    $cachekey = 'cache_rmbtaxinfo';
	unsetCache($cachekey);
	updateTaxPercentages($new_percentages,$new_taxname);
	echo updateTaxLabels($new_labels);
   
	$getlist = true;    
}
/*
if($_REQUEST['save_tax'] == 'true')
{
	for($i=0;$i<count($tax_details); $i++) {
		$new_labels[$tax_details[$i]['taxid']] = $_REQUEST[bin2hex($tax_details[$i]['taxlabel'])];
		$new_percentages[$tax_details[$i]['taxid']] = $_REQUEST[$tax_details[$i]['taxname']];
		$new_taxname[$tax_details[$i]['taxid']] = $tax_details[$i]['taxname'];
	}
	$cachekey = 'cache_rmbtaxinfo';
	unsetCache($cachekey);
	updateTaxPercentages($new_percentages,$new_taxname);
	echo updateTaxLabels($new_labels);
   
	$getlist = true;
}
elseif($_REQUEST['sh_save_tax'] == 'true')
{
 
	for($i=0;$i<count($sh_tax_details);$i++)
	{
		$new_labels[$sh_tax_details[$i]['taxid']] = $_REQUEST[bin2hex($sh_tax_details[$i]['taxlabel'])];
		$new_percentages[$sh_tax_details[$i]['taxid']] = $_REQUEST[$sh_tax_details[$i]['taxname']];
		$new_taxname[$sh_tax_details[$i]['taxid']] = $sh_tax_details[$i]['taxname'];
	}
	
	updateTaxPercentages($new_percentages,$new_taxname,'sh');
	echo updateTaxLabels($new_labels,'sh');
	$getlist = true;
}

//To edit
if($_REQUEST['edit_tax'] == 'true')
{
	$smarty->assign("EDIT_MODE", 'true');
    $smarty->assign("MODE","yes");
}
elseif($_REQUEST['sh_edit_tax'] == 'true')
{
	$smarty->assign("SH_EDIT_MODE", 'true');
}

//To add tax
if($_REQUEST['add_tax_type'] == 'true')
{
	//Add the given tax name and value as a new tax type
	echo addTaxType($_REQUEST['addTaxLabel'],$_REQUEST['addTaxValue']);
	$getlist = true;
}
elseif($_REQUEST['sh_add_tax_type'] == 'true')
{
	echo addTaxType($_REQUEST['sh_addTaxLabel'],$_REQUEST['sh_addTaxValue'],'sh');
	$getlist = true;
}
*/
if($_REQUEST['changestatus']=='yes'){
    changeDeleted($_REQUEST['taxname'],$_REQUEST['deleted']);
    $getlist = true;
}
$tax_details = getAllTaxes();
$sh_tax_details = getAllTaxes('all','sh');

/*
//To Disable ie., delete or enable
if(($_REQUEST['disable'] == 'true' || $_REQUEST['enable'] == 'true') && $_REQUEST['taxname'] != '')
{
	if($_REQUEST['disable'] == 'true')
		changeDeleted($_REQUEST['taxname'],1);
	else
		changeDeleted($_REQUEST['taxname'],0);
	$getlist = true;
}
elseif(($_REQUEST['sh_disable'] == 'true' || $_REQUEST['sh_enable'] == 'true') && $_REQUEST['sh_taxname'] != '')
{
	if($_REQUEST['sh_disable'] == 'true')
		changeDeleted($_REQUEST['sh_taxname'],1,'sh');
	else
		changeDeleted($_REQUEST['sh_taxname'],0,'sh');
	$getlist = true;
}
*/
//edit:can reason:12164: 控制面板>>税率设定:点击【编辑】，然后任意修改税率，结果保存后，税率没有变，但是刷新一下页面，税率就会变了
 global $static_alltaxes_array;
 $static_alltaxes_array='';
//$tax_details = getAllTaxes();
//print_r($tax_details);
//after done save or enable/disable or added new tax the list will be retrieved again from db
if($getlist)
{
	//$tax_details = getAllTaxes();
	//$sh_tax_details = getAllTaxes('all','sh');
}

$smarty->assign("TAX_COUNT", count($tax_details));
$smarty->assign("SH_TAX_COUNT", count($sh_tax_details));

if(count($tax_details) == 0)
	$smarty->assign("TAX_COUNT", 0);
if(count($sh_tax_details) == 0)
	$smarty->assign("SH_TAX_COUNT", 0);

$smarty->assign("TAX_VALUES", $tax_details);

$smarty->assign("SH_TAX_VALUES", $sh_tax_details);

//$smarty->assign("MOD", return_module_language($current_language,'Settings'));
$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH",$image_path);

$smarty->assign("LANUGAGETYPE",$languageType);
// require_once('SetmenuControl.php');
if($_REQUEST['edit_tax'] == 'yes'){
    $smarty->assign("EDIT_MODE", 'true');
    $smarty->assign("MODE",$_REQUEST['edit_tax']);
}
$_REQUEST['diony']='yes';
if($_REQUEST['ajax'] != 'true')	
{
    $arr['content']= $smarty->fetch('Settings/TaxConfig.tpl');
    ConvertTojsonString(1,$arr,"success");
}
else 
{
    $smarty->display('Settings/TaxConfigEntries.tpl');
}

/**	Function to update the list of Tax percentages for the passed tax types
 *	@param array $new_percentages - array of tax types and the values like [taxid]=new value ie., [1]=3.56, [2]=11.45
 *      @param string $sh - sh or empty, if sh passed then update will be done in shipping and handling related table
 *      @return void
 */
function updateTaxPercentages($new_percentages, $new_labels,$sh='')
{
	global $adb;
	foreach($new_percentages as $taxid => $new_val)
	{
		if($new_val != '')
		{
			if($sh != '' && $sh == 'sh'){
				$query = "update ld_shippingtaxinfo set percentage=? where taxid=?";
			}else{
				$producttoolfield_tax = 'update ld_producttoolfield set defaultvalue = ? where columnname = ?';
				$adb->pquery($producttoolfield_tax,array($new_val,$new_labels[$taxid]));
				$query = "update ld_inventorytaxinfo set percentage =? where taxid=?";
				unsetCacheDirectory('productfields');
			}
			$adb->pquery($query, array($new_val, $taxid));
		}
	}

	
}

/**	Function to update the list of Tax Labels for the taxes
 *	@param array $new_labels - array of tax types and the values like [taxid]=new label ie., [1]=aa, [2]=bb
 *      @param string $sh - sh or empty, if sh passed then update will be done in shipping and handling related table
 *      @return void
 */
function updateTaxLabels($new_labels, $sh='')
{
	global $adb,  $currentModule;
	$duplicateTaxLabels = 0;
	foreach($new_labels as $taxid => $new_val)
	{
		if($new_val != '')
		{
			//First we will check whether the tax is already available or not
			if($sh != '' && $sh == 'sh')
				$check_query = "select taxlabel from ld_shippingtaxinfo where taxlabel = ? and taxid != ?";
			else
				$check_query = "select taxlabel from ld_inventorytaxinfo where taxlabel = ? and taxid != ?";
			$check_res = $adb->pquery($check_query, array($new_val, $taxid));

			if($adb->num_rows($check_res) > 0) {
				$duplicateTaxLabels++;
				continue;
			}

			if($sh != '' && $sh == 'sh'){
				$query = "update ld_shippingtaxinfo set taxlabel= ? where taxid=?";
				$adb->pquery($query, array($new_val, $taxid));
			}else{
				$query = "update ld_inventorytaxinfo set taxlabel= ? where taxid=?";
				$adb->pquery($query, array($new_val, $taxid));
				$query ='update ld_tranlabel set fieldlabel = ? where languagetype=? and trantable=? and relateid=?';
				$adb->pquery($query, array($new_val, 'zh','ld_inventorytaxinfo',$taxid));
				$query = 'select producttoolfieldid from ld_producttoolfield where fieldid = ? and uitype = 17';
				$result = $adb->pquery($query,array($taxid));
				$num_rows = $adb->num_rows($result);
				for($i = 0; $i<$num_rows; $i++){
					$producttoolfieldid = $adb->query_result($result,$i,'producttoolfieldid');
					$adb->pquery('update ld_tranlabel set fieldlabel = ? where languagetype=? and trantable=? and relateid=?;',array($new_val,'zh','ld_producttoolfield',$producttoolfieldid));
					$adb->pquery('update ld_producttoolfield set fieldlabel = ? where producttoolfieldid = ?',array($new_val,$producttoolfieldid));
				}
			}
			
		}
	}
    //014960: 控制面板>税率设定,关于编辑税率的问题 说明	控制面板>税率设定,编辑税率保存,弹出了提示信息.(如图)
	/*if($duplicateTaxLabels > 0) {
		//getTranslatedString翻译方法已经不再使用，故把方法内容拷贝到此处，翻译提示信息 tujt 2014-11-06
		global $app_strings, $mod_strings, $current_language,$tab_string;
		$temp_mod_strings = ($currentModule != '' ) ? return_module_language($current_language, $currentModule) : $mod_strings;
		$str = 'LBL_ERR_SOME_TAX_LABELS_ALREADY_EXISTS';
		$temp_mod_strings[$str] = ($tab_string[$str]!='')?$tab_string[$str]:$temp_mod_strings[$str];
		$trans_str = ($temp_mod_strings[$str] != '') ? $temp_mod_strings[$str] : (($app_strings[$str] != '') ? $app_strings[$str] : $str);
		//return "<font color='red'>".$trans_str."</font>";
        return "<script>alert('".$trans_str."');</script>";
	}*/


}
/**	Function used to add the tax type which will do database alterations
 *	@param string $taxlabel - tax label name to be added
 *	@param string $taxvalue - tax value to be added
 *      @param string $sh - sh or empty , if sh passed then the tax will be added in shipping and handling related table
 *      @return void
 */
function addTaxType($taxlabel, $taxvalue, $sh='')
{
	global $adb;
	//First we will check whether the tax is already available or not
	if($sh != '' && $sh == 'sh')
		$check_query = "select taxlabel from ld_shippingtaxinfo where taxlabel=?";
	else
		$check_query = "select taxlabel from ld_inventorytaxinfo where taxlabel=?";
	$check_res = $adb->pquery($check_query, array($taxlabel));

    /*
	if($adb->num_rows($check_res) > 0)
		return "<font color='red'>".getTranslatedString('LBL_ERR_TAX_LABEL_ALREADY_EXISTS', $currentModule)."</font>";
    */
	//if the tax is not available then add this tax.
	//Add this tax as a column in related table	
	if($sh != '' && $sh == 'sh')
	{
		$taxid = $adb->getUniqueID("ld_shippingtaxinfo");
		$taxname = "shtax".$taxid;
		$query = "alter table ld_inventoryshippingrel add column $taxname decimal(7,3) default NULL";
	}
	else
	{
		$taxid = $adb->getUniqueID("ld_inventorytaxinfo");
		$taxname = "tax".$taxid;
		$query = "alter table ld_inventoryproductrel add column $taxname decimal(7,3) default NULL";
	}
	$res = $adb->pquery($query, array());

	//if the tax is added as a column then we should add this tax in the list of taxes
	if($res)
	{
		if($sh != '' && $sh == 'sh') 
			$query1 = "insert into ld_shippingtaxinfo values(?,?,?,?,?)";
		else
			$query1 = "insert into ld_inventorytaxinfo values(?,?,?,?,?)";

		$params1 = array($taxid, $taxname, $taxlabel, $taxvalue, 0);
		$res1 = $adb->pquery($query1, $params1);
	}


	if($res1)
		return '';
	else
		return "There may be some problem in adding the Tax type. Please try again";
}

/**	Function used to Enable or Disable the tax type 
 *	@param string $taxname - taxname to enable or disble
 *	@param int $deleted - 0 or 1 where 0 to enable and 1 to disable
 *	@param string $sh - sh or empty, if sh passed then the enable/disable will be done in shipping and handling tax table ie.,lingdang_shippingtaxinfo  else this enable/disable will be done in Product tax table ie., in lingdang_inventorytaxinfo
 *	@return void
 */
function changeDeleted($taxname, $deleted, $sh='')
{
	global  $adb;
	
	if($sh == 'sh'){
		$adb->pquery("update ld_shippingtaxinfo set deleted=? where taxname=?", array($deleted, $taxname));
	}else{
		$adb->pquery("update ld_inventorytaxinfo set deleted=? where taxname=?", array($deleted, $taxname));
		$producttoolfield_tax = 'update ld_producttoolfield set presence = ? where columnname = ?';
		$adb->pquery($producttoolfield_tax,array($deleted,$taxname));
		unsetCacheDirectory('productfields');
	}

}

?>