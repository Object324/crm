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
//zkt 20231012 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb;
global $current_user;
$cvid = vtlib_purify($_REQUEST["record"]);
$module = vtlib_purify($_REQUEST["dmodule"]);
$moduleid=getTabid($module);
$smodule = vtlib_purify($_REQUEST["smodule"]);
$group=vtlib_purify($_REQUEST['groupEmail']);//邮件分组
$parenttab = getParentTab();

if(isset($cvid) && $cvid != '')
{
	$deletesql = "delete from ld_customview where cvid =?";
	$deleteresult = $adb->pquery($deletesql, array($cvid));

    $deletesql="delete from ld_user_module_preferences where tabid=? and userid=?";
    $deleteresult = $adb->pquery($deletesql, array($moduleid,$current_user->id));
      
	$_SESSION['lvs'][$module]["viewname"] = '';
    $deletesql="delete from ld_tabwithproductview where cvid=? ";
   	$deleteresult = $adb->pquery($deletesql, array($cvid));

    $listsort = 'delete from ld_cvcolumnlistsort where cvid = ?';
    $adb->pquery($listsort, array($cvid));

    $delete_adv = 'delete from ld_cvadvfilter where cvid = ?';
    $adb->pquery($delete_adv, array($cvid));

    $delete_advg = 'delete from ld_cvadvfilter_grouping where cvid = ?';
    $adb->pquery($delete_advg, array($cvid));

    $sqlwidth='delete from ld_list_headerwidth where module=? and type=? and relateid=? ';
    $adb->pquery($listsort, array($smodule,'customview',$cvid));
    $sql =' delete from ld_parenttabrel where tabid in
        ( select id from  ld_linkmodulecustom where linkcvid=? and entitytype="category" and linkmodule=? ) and tab_tablename="ld_linkmodulecustom" ';
      $adb->pquery($sql, array($cvid,$smodule));    
    
    
    $sql =' delete from ld_appparenttabrel where tabid in
        ( select id from  ld_linkmodulecustom where linkcvid=? and entitytype="category" and linkmodule=? ) 
        and tab_tablename="ld_linkmodulecustom" ';
      $adb->pquery($sql, array($cvid,$smodule));    
    
     $sql='delete from  ld_linkmodulecustom where linkcvid=? and entitytype="category" and linkmodule=?  ';
    $adb->pquery($sql, array($cvid,$smodule));    
    
}
if(isset($smodule) && $smodule != '')
{
	$smodule_url = "&smodule=".$smodule;
}
$SearchScope="";
if(isset($_REQUEST['SearchScope']))
{
    $SearchScope=$_REQUEST['SearchScope'];
}
unsetCacheDirectory('customview');
  
if($_REQUEST['refreshpage']=='no')
{
  $_REQUEST['diony']='diony';
  ConvertTojsonString(1,array(),'success');
     
}
if(isset($_REQUEST['groupEmail'])&&$_REQUEST['groupEmail']!='')
{
    /*if($group=='Emails')
    header("Location: index.php?module=$group&action=GroupEmail&return_module=Accounts&SearchScope=".$SearchScope);//群发邮件
    else
    header("Location: index.php?module=$group&action=SendView&return_module=Accounts&SearchScope=".$SearchScope);//群发短信*/
    $_REQUEST['diony']='diony';
    if($group=='Emails'){
        $customView = CustomView::getInstance($group);//Emails
        $viewid = $customView->getViewId($group);
        $module=$group;

        $customview_html = $customView->getCustomViewCombo2($viewid,$module,$category);
        $smarty=new lingdangCRM_Smarty();
        $smarty->assign('CUSTOMVIEW_HTML',$customview_html);

        $content=$smarty->fetch("SelectEmailFenzuName.tpl");
        $arr['datafenzucontent'] = $content;//邮件群发 分组头部

        ConvertTojsonString(1,$arr,'success');
    }
    else{
        header("Location: index.php?module=$group&action=SendView&return_module=Accounts&SearchScope=".$SearchScope);//群发短信
    }
}
else
{

    header("Location: index.php?action=ListView&module=$module".$smodule_url."&SearchScope=".$SearchScope);
}

exit();
?>