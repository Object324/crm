<?php
/********************************************************
**更新操作
**edit:kevin
**date:2013-11-13
**reason:子菜单
********************************************************/
require_once('Smarty_setup.php');
global $adb;
$smarty=new lingdangCRM_Smarty;
$query="select ld_tab.tabid,ld_tranlabel.fieldlabel as newtabname,languagetype from ld_tab inner  join ld_tranlabel on 
ld_tab.tabid=ld_tranlabel.relateid
 where (languagetype=? or languagetype=?) and  trantable=? and  ld_tab.presence=0 and ld_tab.tabid not in(1,7,27,28,29,30,33,35,44,51,52,61,16)
 and ld_tab.name not in ('Attachment','Cache','ReportLog','OftenUseReport') ";
$result=$adb->pquery($query." ORDER BY ld_tab.tabsequence,tabid,languagetype",array('zh','en','ld_tab'));
$num_rows=$adb->num_rows($result);
$alltabs=array();
for($i=0;$i<$num_rows;$i++){
    $tabid=$adb->query_result($result,$i,'tabid');
    $enlabel=$adb->query_result($result,$i,'newtabname');
    $i++;
    $zhlabel=$adb->query_result($result,$i,'newtabname');
    
    $alltabs[]=array('tabid'=>$tabid,
    'enlabel'=>$enlabel,
    'zhlabel'=>$zhlabel
    );
}
print_r($alltabs);
$smarty->assign('ALLTABS',$alltabs);
echo '###SUCCESS###';
$smarty->display('Menu/ChildMenu.tpl');
exit();
?>