<?php 
require_once('include/utils/utils.php');
require_once('include/utils/UserInfoUtil.php');
require_once('Smarty_setup.php');

$delete_role_id = vtlib_purify($_REQUEST['roleid']);
$delete_role_name = getProfileName($delete_role_id);
global $app_strings;
global $app_list_strings;
global $mod_strings;
$smarty=new lingdangCRM_Smarty;
$smarty->assign("APP", $app_strings);
//$smarty->assign("MOD", return_module_language($current_language,'Settings'));
$smarty->assign("THEME", $theme);
$smarty->assign("CMOD", $mod_strings);
global $theme;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";
$smarty->assign("IMAGE_PATH",$image_path);

$smarty->assign("ROLEID", $delete_role_id);
$smarty->assign("ROLENAME", $delete_role_name);
$opt = '<a class="icon-homeimg icon-select" href="javascript:openPopup(\''.$delete_role_id.'\');"></a>';
$smarty->assign("ROLEPOPUPBUTTON", $opt);

require_once('SetmenuControl.php');
$smarty->display("RoleDragDrop.tpl");

?>