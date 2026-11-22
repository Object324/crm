<?php
//zkt 20231014 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
require_once(globalStatic::$root_directory.'include/utils/UserInfoUtil.php');
global $mod_strings;
global $app_strings;
global $app_list_strings;
global $current_user;
$_SESSION[globalStatic::$root_directory.'prevmenu_modulefile'.$current_user->id]='SettingLeftRight';
$_SESSION[globalStatic::$root_directory.'prevmenu_modilefile_childmenu'.$current_user->id]='OrgSharingDetailView';
$_SESSION[globalStatic::$root_directory.'prevmenu_module'.$current_user->id]='Settings';
global $theme;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";

$smarty = new lingdangCRM_Smarty;
//全局共享规则代码
$defSharingPermissionData = getDefaultSharingAction();//array(tabid,permission)
//echo  "<pre>";
//print_r($defSharingPermissionData);
$access_privileges = array();
$row=1;
foreach($defSharingPermissionData as $tab_id => $def_perr)
{
    $entity_name = getTabname($tab_id);
    //print_r($entity_name).'-';
        /**
         * by andy 
         * bug 10159
         */ 
        if($entity_name =='PublicAnnouncement' || $entity_name == 'Singin')
            continue;        
    	/*if($tab_id == 6)
        {
            36684: 系统设置-模块共享规则，客户和联系人模块共享规则，分开显示， 客户共享规则 ,联系人共享规则
        	$cont_name = getTabname(4);
            $entity_name = getTranstab($entity_name) . getFixedLabel('AND'). getTranstab($cont_name);
        }*/
        
        else if($tab_id == 45)
        {
            $entity_name = getTranstab('ModComments');
        }
        else
        {
             $entity_name = getTranstab($entity_name);
        }
        if(empty($entity_name))
        {
            continue;
        }
   
    	$entity_perr = getDefOrgShareActionName($def_perr);
       
    	$access_privileges[] = $entity_name;
    	$access_privileges[] = getFixedLabel($entity_perr);    
        $access_privileges[] = getFixedLabel('LBL_DESCRIPTION_'.$entity_perr);
        $access_privileges[] = $tab_id;
    	
    	$row++;
    //}
}
$access_privileges=array_chunk($access_privileges,4);
$smarty->assign("DEFAULT_SHARING", $access_privileges);

$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH",$image_path);
$smarty->assign("APP", $app_strings);
$smarty->assign("CMOD", $mod_strings);
//$smarty->assign("MOD", return_module_language($current_language,'Settings'));

// require_once('SetmenuControl.php');
$_REQUEST['diony']='yes';


//获取帮助手册入口链接，为空则不显示
//可能有多个帮助链接需要获取
$helpHtmlArr = array();
//审批流定制帮助
$labels = array('OrgSharingDetailView');
foreach($labels as $label){
    $helpHtmlArr[$label] = getHelpHtmlByLabel('Settings',1,'HelpUrl_'.$label);
}
$smarty->assign("HelpHtml", $helpHtmlArr);


$arr['content']= $smarty->fetch('OrgSharingDetailView.tpl');
ConvertTojsonString(1,$arr,"success");
?>