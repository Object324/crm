<?php
/**
* @edit:dong
* @data:2020/08/26
* @reason:小程序banner设置
* @description:
*/

global $mod_strings,$app_strings,$adb,$theme,$default_charset;

$theme_path="themes/".$theme."/";
$smarty=new lingdangCRM_Smarty;

if(isset($_REQUEST['record']) && $_REQUEST['record']!='' && $_REQUEST['type'] == 'edit')
{
    $id = vtlib_purify($_REQUEST['record']);
    $currency = '';
    // Get all the currencies
    $sql = "SELECT
	id,filename,path,url,createdtime
FROM
	ld_wxshoppingmall_banner
	WHERE id =?";
    $result = $adb->pquery($sql, array($id));
    if($result){
        $imgInfo= $adb->fetch_array($result);
        $smarty->assign("IMGINFO", $imgInfo);
    }
    $smarty->assign("ID",$id);
}

$_REQUEST['diony']='diony';
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
if($_REQUEST['type'] == 'create'){
    $arr['title'] = getFixedLabel('NEW').getFixedLabel('wxmall_banner_img');
}else{
    $arr['title'] = getFixedLabel('EDIT');
}

$smarty->assign('TYPE',$_REQUEST['type']);
$smarty->assign('site_URL',$site_URL);
$str=$smarty->fetch("Settings/wechat_minimall_banner_setting_edit.tpl");
$arr['content']=$str;
ConvertTojsonString(1,$arr,"success");
?>