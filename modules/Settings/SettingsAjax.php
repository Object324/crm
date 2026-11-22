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
$smarty=new lingdangCRM_Smarty;
global $current_user;
//中英文包
require("user_privileges/user_language_".$current_user->id.'.php');
if(empty($languageType))
{
    $languageType = 'zh';
}
$smarty->assign("LANUGAGETYPE",$languageType);

if(isset($_REQUEST['file']) && ($_REQUEST['file'] !='')) {
    /*
    date:2013-11-04
    edit:chj
    reson:个人设置  查看操作日志  BUG 0003359 修复
    */
   
    $pagenum = $_REQUEST['pagenum'];
    
  //  checkFileAccessForInclusion('modules/Settings/'.$_REQUEST['file'].'.php');
    $moduleFilepath = 'modules/Settings/'.$_REQUEST['file'].'.php';
    if(file_exists($moduleFilepath) == false) {
        require_once('include/Ajax/CommonAjax.php');
    }
    else
	    require_once('modules/Settings/'.$_REQUEST['file'].'.php');
}
if(isset($_REQUEST['orgajax']) && ($_REQUEST['orgajax'] !='')) {
	require_once('modules/Settings/CreateSharingRule.php');
} elseif(isset($_REQUEST['announce_save']) && ($_REQUEST['announce_save'] != '')) {
	$date_var = date('Y-m-d H:i:s');
	$announcement = vtlib_purify(from_html($_REQUEST['announcement']));
	//Change ##$## to & (reverse process has done in Smarty/templates/Settings/Announcements.tpl)
	$announcement = str_replace("##$##","&",$announcement);

    $title = vtlib_purify($_REQUEST['title_announcement']);
    $sql="select * from ld_announcement where creatorid=?";
    $is_announce=$adb->pquery($sql, array($current_user->id));
    if($adb->num_rows($is_announce) > 0) {
        $query="update ld_announcement set announcement=?,time=?,title=? where creatorid=?";
		$params = array($announcement, $adb->formatDate($date_var, true), 'announcement', $current_user->id);
	} else {
        $query="insert into ld_announcement values (?,?,?,?)";
		$params = array($current_user->id,$announcement,'announcement',$adb->formatDate($date_var, true));
	}
    $result=$adb->pquery($query, $params);
    $filename='user_privileges/announcement.php';
    $handle = fopen($filename, 'w+');
   	$newbuf = '';
    $newbuf .="<?php\n\n";
	$newbuf .="\n";
	$newbuf .= "\$announcement='" .$announcement . "';\n";
	$newbuf .= "\n";
	$newbuf .= "?>";
	fputs($handle, $newbuf);
	fclose($handle);
    echo $announcement;
}
?>