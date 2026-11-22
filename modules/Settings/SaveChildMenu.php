<?php
/*****************************************************
**更新成操作
**edit:kevin
**date:2013-11-14
**reason:保存子菜单
*****************************************************/
global $adb,$current_user;
require('user_privileges/user_language_'.$current_user->id.'.php');
$query="select ld_tab.tabid,ld_tranlabel.fieldlabel as newtabname,languagetype from ld_tab inner  join ld_tranlabel on 
ld_tab.tabid=ld_tranlabel.relateid
 where (languagetype=? or languagetype=?) and  trantable=? and  ld_tab.presence=0 and ld_tab.tabid not in(1,7,27,28,29,30,33,35,44,51,52,61,16)
 and ld_tab.name not in ('Attachment','Cache','ReportLog','OftenUseReport') ";
$result=$adb->pquery($query." ORDER BY ld_tab.tabsequence,tabid,languagetype",array('zh','en','ld_tab'));
$num_rows=$adb->num_rows($result);


for($i=0;$i<$num_rows;$i++){
    $tabid=$adb->query_result($result,$i,'tabid');
    
    if(isset($_REQUEST['entab'.$tabid]) && $_REQUEST['entab'.$tabid]!=''){
        $enlabel=$_REQUEST['entab'.$tabid];
         $zhlabel=$_REQUEST['zhtab'.$tabid];
        $adb->pquery("update ld_tranlabel set fieldlabel = '$enlabel' where  languagetype = 'en' and tabid = $tabid and trantable = 'ld_tab' ");
        $adb->pquery("update ld_tranlabel set fieldlabel = '$zhlabel' where  languagetype = 'zh' and tabid = $tabid and trantable = 'ld_tab' ");
    }
    
    
}

create_tab_language();
$cachekey = 'cache_getparenttabrelinfo';
unsetCache($cachekey);
header('location:index.php?module=Settings&action=MenuList&parenttab=Settings');
?>