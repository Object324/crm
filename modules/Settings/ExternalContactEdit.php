<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @project 工作协同模板
 * @author Tujt 2015-05-05
 */
global $adb,$current_user;
require('user_privileges/user_language_'.$current_user->id.'.php');
if(isset($_REQUEST['ajax'])&&$_REQUEST['ajax']=='save'){
    $switch = empty($_REQUEST['switch'])?'close':$_REQUEST['switch'];
    $userid = $_REQUEST['customscope_ids'];
    $usertype = $_REQUEST['customscope_type'];
    $sql = "update ld_wx_config set switch=?,usertype=?,userid=? where name=?";
    $adb->pquery($sql,array($switch,$usertype,$userid,'external_contact'));
	$_REQUEST['diony']='diony';
	ConvertTojsonString(1,array(),"success");
}
$smarty = new lingdangCRM_Smarty;

$sql = "select switch,usertype,userid from ld_wx_config where name=?";
$result = $adb->pquery($sql,array('external_contact'));
if($adb->num_rows($result)){
    $switch = $adb->query_result($result,0,'switch');
    $userid = $adb->query_result($result,0,'userid');
    $usertype = $adb->query_result($result,0,'usertype');
    
    
    $smarty->assign('USERSACCOUNT_TYPE',$usertype);
    $smarty->assign('SWITCH',$switch);
    $smarty->assign('USERSACCOUNT',$userid);
}


$smarty->assign('LANGUAGETYPE',$languageType);
$_REQUEST['diony']='diony';
$arr['title'] = getFixedLabel('ExternalContactSetting');
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$str=$smarty->fetch("Settings/ExternalContactEdit.tpl");
$arr['content']=$str;
ConvertTojsonString(1,$arr,"success");
exit();

?>