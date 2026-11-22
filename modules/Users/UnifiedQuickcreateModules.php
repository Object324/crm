<?php
//@edit:liushuai,2020-12-29,reason:【ID1001225】快速创建增加设置按钮，可设置快速创建显示的模块

global $app_strings, $mod_strings, $current_language, $currentModule, $current_user, $theme, $adb;

$quickcreatemodules = getQuickCreateModules();//  $quickcreatemodules 为数组
$quickcreatemodules_all = [];
foreach ($quickcreatemodules as $key => $info){
	//chj 2021/3/2 公海池参数“公海成员客户序时簿“新建”功能下拉选项”中没有选择“普通成员”，公海成员快速创建弹出层和设置快速创建弹出层中应该不显示“客户”模块
	if($info[1] == 'Accounts'){
		crm_load_class_file('cls_PublicAccounts', 'modules/Accounts');
		$cls_PublicAccounts = new cls_PublicAccounts('Accounts');
		$public_account = $cls_PublicAccounts->getPublicAccountConfig();
		if($public_account['status'] == 'yes'){
			//chj 2021/7/22 47081: （https://81mis.com/kfbcrm [^]）快速创建中没有客户模块的新建按钮（没有关闭新建普通客户的参数）
			$create_commonaccount = $public_account['is_commonaccount_create'];	//是否允许创建普通客户
			if($create_commonaccount == 'no'){
				unset($quickcreatemodules[$key]);
				continue;
			}
		}
	}
    $quickcreatemodules_all[] = $info[1];  //快速创建默认全部模块
}
$selected_modules = array(); //在此之前，header.php已经有session了。
if(!empty($_SESSION['__UnifiedQuickcreate_SelectedModules__']) && is_array($_SESSION['__UnifiedQuickcreate_SelectedModules__'])) {
    $selected_modules = $_SESSION['__UnifiedQuickcreate_SelectedModules__'];
}
else {
    $quickcreate_sql = "select quickcreatemodules from ld_users where id=?";
    $quickcreate_result=$adb->pquery($quickcreate_sql,array($current_user->id));

    if ($adb->num_rows($quickcreate_result) > 0) {
        $tmpquickcreatemodules = trim(trim($adb->query_result($quickcreate_result, 0, 0), ','));
        if ($tmpquickcreatemodules == '') {
            $selected_modules = $quickcreatemodules_all;
        }else if ($tmpquickcreatemodules == 'none') {
            $selected_modules = array();
        } else if ($tmpquickcreatemodules != '' && $tmpquickcreatemodules != 'none') {
            $selected_modules = explode(',', $tmpquickcreatemodules);
        }
        $selected_modules=(string)$selected_modules;
        $_SESSION['__UnifiedQuickcreate_SelectedModules__'] = $selected_modules;  //数组
        $_REQUEST['quickcreate_onlyin'] = explode(',', $selected_modules);;
    }

}
for ($i = 0; $i < count($selected_modules); $i++) {
    $selected_modules[$i] = array(getTranstab($selected_modules[$i]), $selected_modules[$i]);
}

foreach ($quickcreatemodules as $key => $quickcreatemodule) {
    foreach ($selected_modules as $module) {
        if ($quickcreatemodule == $module) {
            unset($quickcreatemodules[$key]);
        }
    }
}
$smarty = new lingdangCRM_Smarty();
$smarty->assign('MOD', $mod_strings);
$smarty->assign('APP', $app_strings);
$smarty->assign('THEME', $theme);
$smarty->assign('IMAGE_PATH', "themes/$theme/images/");
$smarty->assign('ALLOWED_MODULES', $quickcreatemodules);
$smarty->assign('SELECT_MODULES', $selected_modules);

$str=$smarty->fetch('PopUnifiedQuickcreateModules.tpl');
$_REQUEST['diony']='diony';
$arr['title']=getFixedLabel('SELECTMODULE');
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$arr['allselect']=getFixedLabel('ALLSELECT');
$arr['selectcancel']=getFixedLabel('SELECTCANCEL');
$arr['content']=$str;


ConvertTojsonString(1,$arr,"success");

?>