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
include("modules/Users/Group.class.php");
$group_focus = new Group();
global $adb;
$record=$_REQUEST['record'];
$groupid=$record;
//获取选择部门的parentid
$sqlquery=$adb->pquery('select parentid,groupseq from ld_groups where groupid='.$groupid);
$parentid=$adb->query_result($sqlquery,0,'parentid');
$direction=$_REQUEST['direction'];
//得到parentid相同的部门，按顺序显示
$query = 'select groupid,groupname,description,parentgroup,groupseq from ld_groups where parentid='.$parentid.' order by groupseq';
$result = $adb->pquery($query);
$groupseqbefore=$adb->query_result($sqlquery,0,'groupseq');
$resultorder=(int)($groupseqbefore)-1;
//获取即将交换部门的groupid和groupseq
if($direction=='moveup'){
    $trangroupid=$adb->query_result($result,$resultorder-1,'groupid');
    $groupseqafter=$adb->query_result($result,$resultorder-1,'groupseq');
}
else if($direction='movedown'){
    $trangroupid=$adb->query_result($result,$resultorder+1,'groupid');
    $groupseqafter=$adb->query_result($result,$resultorder+1,'groupseq');
}
//实现交换groupseq
$adb->pquery('update ld_groups set groupseq=? where groupid=?',array($groupseqafter,$groupid));
$adb->pquery('update ld_groups set groupseq=? where groupid=?',array($groupseqbefore,$trangroupid));

$_REQUEST['diony']='yes';
ConvertTojsonString(1,array(),'success');
?>