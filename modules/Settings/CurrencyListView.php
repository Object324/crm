<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $mod_strings,$adb,$theme,$app_strings,$default_charset;
global $current_user;
$_SESSION[globalStatic::$root_directory.'prevmenu_modulefile'.$current_user->id]='SettingLeftRight';
$_SESSION[globalStatic::$root_directory.'prevmenu_modilefile_childmenu'.$current_user->id]='CurrencyListView';
$_SESSION[globalStatic::$root_directory.'prevmenu_module'.$current_user->id]='Settings';
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";
$smarty=new lingdangCRM_Smarty;
   $parenttab = getParentTab();
   $sql = "select id,currency_name,currency_code,currency_symbol,conversion_rate, case when currency_status='Active' then 'ACTIVATE' else 'INACTIVATE' end as currency_status  ,defaultid,deleted from ld_currency_info where deleted=0";
   $result = $adb->pquery($sql, array());
   $temprow = $adb->fetch_array($result);
   $cnt=1;
   $currency = Array();
do
{
	$currency_element = Array();
	$currency_element['name'] = '<span title="'.getTranslatedCurrencyString($temprow["currency_name"]).'">'.getTranslatedCurrencyString($temprow["currency_name"]).'</span>';
	$currency_element['code'] = $temprow["currency_code"];
	$currency_element['symbol'] = $temprow["currency_symbol"];
	$currency_element['crate'] = $temprow["conversion_rate"];
	$currency_element['status'] = getFixedLabel(strtoupper($temprow["currency_status"]));
	if($temprow["defaultid"] != '-11')
	{
    //31631: 系统设置 > 货币设定 ：“人民币”操作列增加“编辑”“启用”功能，当人民币名称更改后，货币符号对应更改
		$currency_element['name'] = '<a title="'.getTranslatedCurrencyString($temprow["currency_name"]).'" href="javascript:void(0)" onclick="editCurreny('.$temprow["id"].',\'detail_view\')">'.getTranslatedCurrencyString($temprow["currency_name"]).'</a>';
		$currency_element['tool'] = '<a class="Anu3_a" href="javascript:void(0)" onclick="editCurreny('.$temprow["id"].',\'\')">'.getFixedLabel('EDIT').'</a>';
        
        if($temprow["currency_status"] == 'ACTIVATE')
		{
			$currency_element['active_button'] = '<input type="checkbox" onclick="InactivateCurrency(\''.$temprow['id'].'\',this.checked);" class="second_switch" checked="" />';
		}
		else
		{
			$currency_element['active_button'] = '<input type="checkbox" onclick="InactivateCurrency(\''.$temprow['id'].'\',this.checked);" class="second_switch" />';
		}
	}
	else{
        $currency_element['active_button'] = '<input type="checkbox" class="second_switch" checked="" disabled />';
		$currency_element['tool']= '<a class="Anu3_a" href="javascript:void(0)" onclick="editCurreny('.$temprow["id"].',\'\')">'.getFixedLabel('EDIT').'</a>';
	}
 	$currency[] = $currency_element; 
	$cnt++;
}while($temprow = $adb->fetch_array($result));
$smarty->assign("PARENTTAB",$parenttab);
$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH",$image_path);
$smarty->assign("MOD",$mod_strings);
$smarty->assign("CURRENCY_LIST",$currency);

global $current_user;
//中英文包
$languageType= getLanguageType($current_user);
$smarty->assign("LANUGAGETYPE",$languageType);

// require_once('SetmenuControl.php');
$_REQUEST['diony']='yes';
if($_REQUEST['ajax'] !=''){
	$arr['content']= $smarty->fetch('CurrencyListViewEntries.tpl');
	ConvertTojsonString(1,$arr,"success");
}
else {
    $arr['content']= $smarty->fetch('CurrencyListView.tpl');
    ConvertTojsonString(1,$arr,"success");
}
?>
