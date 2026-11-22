<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $mod_strings,$app_strings,$adb,$theme,$default_charset;

$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";
$smarty=new lingdangCRM_Smarty;

if(isset($_REQUEST['record']) && $_REQUEST['record']!='')
{
	$tempid = vtlib_purify($_REQUEST['record']);
    $currency = '';
	
	// Get all the currencies
    $sql = "select id,currency_name,currency_code,currency_symbol,conversion_rate,case when currency_status = 'Active' then 'ACTIVATE' when currency_status = 'Inactive' then 'INACTIVATE' else currency_status end as currency_status,defaultid,deleted from ld_currency_info where deleted=0";
    $result = $adb->pquery($sql, array());
    // Check if the current currency status has to be disabled for the 
	$sql1 = "select * from ld_users where currency_id=?";
	$result1 = $adb->pquery($sql1, array($tempid));
	$noofrows = $adb->num_rows($result1);
	if($noofrows != 0)
	{
		$disable_currency = "disabled";
	} else {
		$disable_currency = "";
	}

	$other_currencies_list = array();
	while($currencyResult = $adb->fetch_array($result)) {
		if ($currencyResult['id'] == $tempid) {
			$smarty->assign("STATUS_DISABLE",$disable_currency);
			$smarty->assign("CURRENCY_NAME",$currencyResult['currency_name']);
			$smarty->assign("CURRENCY_CODE",$currencyResult['currency_code']);
			$smarty->assign("CURRENCY_SYMBOL",decode_html($currencyResult['currency_symbol']));
			$smarty->assign("CONVERSION_RATE",$currencyResult['conversion_rate']);
			$smarty->assign("CURRENCY_STATUS",getFixedLabel($currencyResult['currency_status']));
			$currency = $currencyResult['currency_name'];
			//if($currencyResult['currency_status'] == 'Active')
            if($currencyResult['currency_status'] == 'ACTIVATE')
				$smarty->assign("ACTSELECT","selected");	
			else
				$smarty->assign("INACTSELECT","selected");
		} elseif($currencyResult['currency_status'] == 'ACTIVATE') {
			$cur_id = $currencyResult['id'];
			$other_currencies_list[$cur_id] = $currencyResult['currency_name'];
		}
	}
	$smarty->assign("OTHER_CURRENCIES", $other_currencies_list);
	$smarty->assign("ID",$tempid);
    $smarty->assign("MODE",'EDIT');//wym BUG20240514-13 后台设置->其他设置->货币设定，1、新增货币后，编辑界面“货币名称”应该不允许修改 2、“是否启用”样式修改
}

$currencies_query = $adb->pquery("SELECT currency_name from ld_currency_info WHERE deleted=0",array());
for($index = 0;$index<$adb->num_rows($currencies_query);$index++){
	$currencies_listed[] = decode_html($adb->query_result($currencies_query,$index,'currency_name'));  
}

$currencies_query = $adb->pquery("SELECT currency_name,currency_code,currency_symbol from ld_currencies order by convert(description using gbk) ",array());
for($index = 0;$index<$adb->num_rows($currencies_query);$index++){
	$currencyname = decode_html($adb->query_result($currencies_query,$index,'currency_name'));  
	$currencycode = decode_html($adb->query_result($currencies_query,$index,'currency_code'));  
	$currencysymbol = decode_html($adb->query_result($currencies_query,$index,'currency_symbol'));  
	$currencies[$currencyname] = array($currencycode,$currencysymbol);
}

$currencies_not_listed = array();
foreach($currencies as $key=>$value){
	if(!in_array($key,$currencies_listed) || $key==$currency)
		$currencies_not_listed[$key] = $value;
}


$smarty->assign("CURRENCIES_ARRAY", Zend_Json::encode($currencies_not_listed));

$smarty->assign("MOD", $mod_strings);
$smarty->assign("APP", $app_strings);
$smarty->assign("THEME", $theme);
$smarty->assign("CURRENCIES", $currencies_not_listed);
$smarty->assign("PARENTTAB",getParentTab());
$smarty->assign("MASTER_CURRENCY",$currency_name);
$smarty->assign("IMAGE_PATH",$image_path);
$smarty->assign('detailview',$_REQUEST['detailview']);

$_REQUEST['diony']='diony';
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
if($_REQUEST['detailview'] == 'detail_view' && $_REQUEST['detailview'] != ''){
	$arr['title'] = getFixedLabel('VIEWDETAIL');
	$arr['canceltext'] = '';
}else if($_REQUEST['detailview'] == 'create' && $_REQUEST['detailview'] != ''){
	$arr['title'] = getFixedLabel('LBL_CURRENCY_SETTINGS');
}else{
	$arr['title'] = getFixedLabel('EDIT');
}
$arr['currencies']=Zend_Json::encode($currencies_not_listed);
if($_REQUEST['detailview'] == 'detail_view' && $_REQUEST['detailview'] != '')
	$str=$smarty->fetch("CurrencyDetailView.tpl");
else
	$str=$smarty->fetch("CurrencyEditView.tpl");
$arr['content']=$str;
ConvertTojsonString(1,$arr,"success");
exit();

?>