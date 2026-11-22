<?php
/********************************************************
**更新操作
**edit:LMX
**date:20140304
**reason:添加菜单和权限
********************************************************/
global $adb,$default_charset;
require_once('Smarty_setup.php');
$smarty=new lingdangCRM_Smarty;
if(isset($_REQUEST['parentchinese']) && $_REQUEST['parentchinese']!='')
$parentchinese=$_REQUEST['parentchinese'];
if(isset($_REQUEST['selectedtabColumnsString'])&& $_REQUEST['selectedtabColumnsString']!='')
$tabids=$_REQUEST['selectedtabColumnsString'];
$tabids=mb_substr($tabids,0,strlen($tabids)-1,$default_charset);
$tabarr=explode(';',$tabids);
if(isset($_REQUEST['parentindex']) && $_REQUEST['parentindex'])
$parentindex=$_REQUEST['parentindex'];
if(isset($_REQUEST['parentenglish']) && $_REQUEST['parentenglish'])
$parentenglish=$_REQUEST['parentenglish'];
if(isset($_REQUEST['selectedprofieldidString'])&& $_REQUEST['selectedprofieldidString']!='')
$pofiledid=$_REQUEST['selectedprofieldidString'];
$profieldarr=mb_substr($pofiledid,0,strlen($pofiledid)-1,$default_charset);
if(isset($_REQUEST['visible']) && $_REQUEST['visible'])
$visible=$_REQUEST['visible'];
$customscope_type = $_REQUEST['customscope_type'];
if(empty($customscope_type))$customscope_type = 'all';
$customscope_ids = $_REQUEST['customscope_ids'];
/*
*更新操作
*edit:diony
*time:2013-12-03
*reson:0005828: 控制面板->菜单定制，建议“主模块”和“子模块”的菜单名称都不能重复。
*这里控制主模块不能重复

$query='select chinesename from ld_parentlanguagepackage where chinesename ='.$parentchinese;
$list_result = $adb->pquery($query);
$num_rows=$adb->num_rows($list_result);
if($num_rows){
    for($i=0;$i<$num_rows;$i++){
        $chinesename_result = $adb->query_result($list_result,$i,'chinesename');
        if($parentchinese==$chinesename_result)
        {
            $eeror = 1;
            header('location:index.php?module=Settings&action=EditMenu&parenttab=Settings&error='.$eeror);
            exit();
        }
    }
}*/
//$sql_sequence="select max(sequence)+1 as sequences,max(parenttabid)+ 1 as parenttabid from ld_parenttab";
$sql_sequence="select max(parenttabid)+ 1 as parenttabid from ld_parenttab";
$result_sequence=$adb->query($sql_sequence);
//$sequences=$adb->query_result($result_sequence,0,'sequences');
$parenttabid=$adb->query_result($result_sequence,0,'parenttabid');
$sql="insert into ld_parenttab(parenttabid,parenttab_label,sequence,visible,allocatetype,allocateid) 
values('$parenttabid','$parentenglish','$parentindex','$visible','$customscope_type','$customscope_ids')";
$adb->query($sql);

$adb->query("insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
values('en','ld_parenttab',$parenttabid,$parenttabid,'$parentenglish')");
$adb->query("insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
values('zh','ld_parenttab',$parenttabid,$parenttabid,'$parentchinese')");
$query='insert into ld_parenttabrel(parenttabid,tabid,sequence)value';
$value='';
for($i=0;$i<count($tabarr);$i++){
    $index=$i+1;
    $value .='('.$parenttabid.','.$tabarr[$i].','.$index.')'.',';
}
$adb->query($query.mb_substr($value,0,strlen($value)-1,$default_charset));
create_tab_data_file();
create_parenttab_data_file();
create_parent_language();
$cachekey = 'cache_getparenttabrelinfo';
unsetCache($cachekey);
header('location:index.php?module=Settings&action=MenuList&parenttab=Settings&blockidsetting='.$_REQUEST['blockidsetting'].'&fieldidsetting='.$_REQUEST['fieldidsetting']);
?>