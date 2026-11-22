<?php
//@edit:liushuai,2020-12-29,reason:【ID1001225】快速创建增加设置按钮，可设置快速创建显示的模块

global $mod_strings, $current_language, $default_charset;
global $current_user;
global $adb;


$quickcreate_onlyin = trim($_REQUEST['quickcreate_onlyin'])?:'none';
$_SESSION['__UnifiedQuickcreate_SelectedModules__'] = $quickcreate_onlyin;
$sql='update ld_users set quickcreatemodules=? where id=?';

$adb->pquery($sql,array($quickcreate_onlyin,$current_user->id));

$quickcreatemodules = getQuickCreateModules();
$quickcreatemodules_all = [];
foreach ($quickcreatemodules as $info){
    $quickcreatemodules_all[] = $info[1];  //快速创建默认全部模块
}
$quickcreate_sql = "select quickcreatemodules from ld_users where id=?";//为空显示全部模块（初始化），为none不显示任何模块(清空)
$quickcreate_result=$adb->pquery($quickcreate_sql,array($current_user->id));
if ($adb->num_rows($quickcreate_result) > 0) {
    $tmpquickcreatemodules = trim(trim($adb->query_result($quickcreate_result, 0, 0), ','));
    if ($tmpquickcreatemodules == '') {
        $tmpquickcreatemodules_arr = $quickcreatemodules_all;  //快速创建默认全部模块
    } else if ($tmpquickcreatemodules == 'none') {
        $tmpquickcreatemodules_arr = array();
    } else if ($tmpquickcreatemodules != '' && $tmpquickcreatemodules != 'none') {
        $tmpquickcreatemodules_arr = explode(',', $tmpquickcreatemodules);
    }
}
//zxm 2021-01208 查询模块图标
crm_load_class_file('MenuUtils','modules/Users');
$MenuUtilsObj = new MenuUtils();
$moduleIconArr = $MenuUtilsObj->getTabModuleIconArr();
/*
$select_tab_sql = "select `name`,default_icon,active_icon from ld_tab";
$select_tab_res = $adb->pquery($select_tab_sql);
$moduleIconArr = [];
$select_tab_nums = $adb->num_rows($select_tab_res);
for($i=0;$i<$select_tab_nums;$i++){
    $temp_name = $adb->query_result($select_tab_res,$i,'name');
    $temp_default_icon = $adb->query_result($select_tab_res,$i,'default_icon');
    $temp_active_icon = $adb->query_result($select_tab_res,$i,'active_icon');
    if(empty($temp_active_icon)||!file_exists(globalStatic::$root_directory.$temp_active_icon)){
        if(empty($temp_default_icon)||!file_exists(globalStatic::$root_directory.$temp_default_icon)){
            if(empty($temp_name)||!file_exists(globalStatic::$root_directory.'themes/icon2022/crm2/crm_'.$temp_name.'.png')){
                if(get_file_address($temp_name,'ProductDetails')||get_file_address($temp_name,$temp_name."DetailFieldsHtml")){
                    $moduleIconArr[$temp_name] = 'themes/icon2022/crm2/crm_CustomForm.png';
                }
                else{
                    $moduleIconArr[$temp_name] = 'themes/icon2022/crm2/crm_CustomForm1.png';
                }
            }else{
                $moduleIconArr[$temp_name] = 'themes/icon2022/crm2/crm_'.$temp_name.'.png';
            }
        }else{
            $moduleIconArr[$temp_name] = $temp_default_icon;
        }
    }else{
        $moduleIconArr[$temp_name] = $temp_active_icon;
    }
}
*/
$quickcreate = [];
foreach($quickcreatemodules as $info){
    $quickmodule = $info[1];
    if (!in_array($quickmodule, $tmpquickcreatemodules_arr)) {  //当前用户权限范围内 去掉未开启快速创建的模块
        continue;
    }
    if(get_file_address($quickmodule,'ProductDetails') && $quickmodule != 'ServiceCharge'){
        $edit = 1;	//带产品分录明细
    }else if(get_file_address($quickmodule,$quickmodule.'DetailFieldsHtml')){
        $edit = 3;	//带明细
    }
    else{
        $edit = 2;
    }
    if($quickmodule == 'Accounts'){
		crm_load_class_file('cls_PublicAccounts', 'modules/Accounts');
		$cls_PublicAccounts = new cls_PublicAccounts($currentModule);
		$public_account = $cls_PublicAccounts->getPublicAccountConfig();
		$create_commonaccount = $public_account['is_commonaccount_create'];	//是否允许创建普通客户
        
		if($create_commonaccount == 'no'&&$public_account['status'] == 'yes'){
			continue;
		}
	}
    //快速创建时，用来判断是否自定义表弟模块
    $havacustomform = 'no';
    if(strpos($quickmodule,'CustomForm') !==false){
        $havacustomform = 'yes';
    }
    //ModuleDetailCreate
    $quickcreate[] = array(
        'label' => 	$info[0],
        'module' => $info[1],
        'img' => $moduleIconArr[$quickmodule],//themes/icon2021/crm/crm_{$details.img}.png,
        'edit' => $edit,
        'havacustomform'=>$havacustomform,
    );
}
$moduleOrder = array_flip($tmpquickcreatemodules_arr);
usort($quickcreate, function($a, $b) use ($moduleOrder) {
    return $moduleOrder[$a['module']] <=> $moduleOrder[$b['module']];
});
$_REQUEST['diony']='yes';
$smarty = new lingdangCRM_Smarty;
$smarty->assign("QUICKMODULE",$quickcreate);
$str=$smarty->fetch("PopUnifiedQuickcreateModulesEntries.tpl");
$arr['content']=$str;
$arr['quickcreate_onlyin']=$quickcreate_onlyin;
ConvertTojsonString(1,$arr,'success');


?>