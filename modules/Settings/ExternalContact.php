<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @project 工作协同模板
 * @author Tujt 2015-05-05
 */
global $adb,$current_user;
global $current_user;
$_SESSION[globalStatic::$root_directory.'prevmenu_modulefile'.$current_user->id]='SettingLeftRight';
$_SESSION[globalStatic::$root_directory.'prevmenu_modilefile_childmenu'.$current_user->id]='ExternalContact';
$_SESSION[globalStatic::$root_directory.'prevmenu_module'.$current_user->id]='Settings';
require(globalStatic::$root_directory.'user_privileges/user_language_'.$current_user->id.'.php');
$smarty = new lingdangCRM_Smarty;

$sql = "select switch,usertype,userid from ld_wx_config where name=?";
$result = $adb->pquery($sql,array('external_contact'));
if($adb->num_rows($result)){
    $switch = $adb->query_result($result,0,'switch');
    $userid = $adb->query_result($result,0,'userid');
    $usertype = $adb->query_result($result,0,'usertype');
    
    if($usertype=='user'){
        $showusers = implode('、',array_map('getUserFullName',explode(',',$userid)));
    }elseif($usertype=='group'){
        $showusers = implode('、',array_map('getGroupFullName',explode(',',$userid)));
    }elseif($usertype=='role'){
        $showusers = getProfileName($userid);
    }else{
        $showusers = getFixedLabel('ALLTHEUSERS');
    }
    
    $smarty->assign('SWITCH',$switch);
    $smarty->assign('USERSCOPE',$showusers);
}
$smarty->assign('LANGUAGETYPE',$languageType);
$smarty->assign('IMPORTEXCONTACT',getFixedLabel('IMPORT').getTranstab('Contacts'));
$smarty->assign('SECONDACTION',$_REQUEST['second_action']);
if(vtlib_isModuleActive('Contacts'))
    $CONTACTACTIVE  = 'active';
else
    $CONTACTACTIVE  = 'noactive';
$smarty->assign('CONTACTACTIVE',$CONTACTACTIVE);
// require_once('SetmenuControl.php');
//editor:gyq_94 reason:企业微信外部联系人批量导入  2019/1/2 12:59
if(isset($_REQUEST['second_action'])){
    if(!isset($_REQUEST['progress'])){
        unset($_SESSION['exteral_contact']);//第一次加载时清除缓存
        unset($_SESSION['WechatSession_syncName']);//会话存档清除缓存
        $_REQUEST['diony']='yes';
        ConvertTojsonString(2,array(),"success");
    }
    
    require_once globalStatic::$root_directory.'WeiXinApp/lib/EventToApiModel.php';
    $model_obj = new EventToApiModel();
    
    if($_REQUEST['second_action']=='import_contact'){
        $result = $model_obj->get_external_contact_list();
        if($result == -1){
			$_REQUEST['diony']='yes';
			ConvertTojsonString(-1,array(),"success");
		}else{
            $total_temp =getFixedLabel('NEW').'%s'.getFixedLabel('ARTICLE').'%s,'.getFixedLabel('RELATIONAL').getFixedLabel('NEW').'%s'.getFixedLabel('ARTICLE').'%s,'.getFixedLabel('UPDATE').'%s'.getFixedLabel('ARTICLE').'%s';
            $total_html = sprintf($total_temp,
            $model_obj->progress_num['newcontact'],getTranstab('Contacts'),$model_obj->progress_num['newaccount'],getTranstab('Accounts'),$model_obj->progress_num['updatecontact'],getTranstab('Contacts'));
            $new_temp = getFixedLabel('THISTIME').getFixedLabel('TOTALOF').getFixedLabel('IMPORT').'%s'.getFixedLabel('ARTICLE').getFixedLabel('data').','.getFixedLabel('IMPORTABORT').'%s'.getFixedLabel('ARTICLE').getFixedLabel('data');
            $pregress_skip = $model_obj->progress_total-$model_obj->progress_i;
            $new_html = sprintf($new_temp,$model_obj->progress_i,$pregress_skip);
            $arr['total_html'] = $total_html;
            $arr['new_html'] = $new_html;
            
            $_REQUEST['diony']='yes';
            unset($_SESSION['exteral_contact']);
            ConvertTojsonString(2,$arr,"success");
        }
		
    }
}

//获取帮助手册入口链接，为空则不显示
//可能有多个帮助链接需要获取
$helpHtmlArr = array();
//企业微信客户联系设置帮助
$labels = array('ExternalContact');
foreach($labels as $label){
    $helpHtmlArr[$label] = getHelpHtmlByLabel('Settings',1,'HelpUrl_'.$label);
}
$smarty->assign("HelpHtml", $helpHtmlArr);

$_REQUEST['diony']='yes';
$arr['content']= $smarty->fetch('Settings/ExternalContact.tpl');
ConvertTojsonString(1,$arr,"success");

//获取权限名称
function getProfileName($profielid){
	global $adb;
	$query = "select GROUP_CONCAT(profilename SEPARATOR '、') from ld_profile where profileid in (".$profielid.")";
	$result = $adb->pquery($query,array());
	if($adb->num_rows($result) >= 1){
		return $adb->query_result($result,0,0);
	}
	return '';
}
?>