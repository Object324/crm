<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb;
$frommodule=$_REQUEST['frommodule'];
$isduplicate=$_REQUEST['duplicate'];//新建界面设置

$tabid=getTabid($frommodule);
$sql='update ld_tab set isduplicate=? where name=?';
$adb->pquery($sql,array($isduplicate,$frommodule));

$rightfields = explode(";",$_REQUEST['AssmablyColumnsString']);
$leftfields = explode(";",$_REQUEST['selectedAssmablyColumnsString']);

$rightfieldnames=array();
$str_rightfieldname='';
foreach($rightfields as $fieldinfo)
{
    $infos=explode(':',$fieldinfo);
    $fieldname=$infos[0];
    $rightfieldnames[]=$fieldname;
    $str_rightfieldname.="'".$fieldname."',";
    
}
$str_rightfieldname=trim($str_rightfieldname,',');

$leftfieldnames=array();
$str_leftfieldname='';

foreach($leftfields as $index=>$fieldinfo)
{
    $infos=explode(':',$fieldinfo);
    $fieldname=$infos[0];
    $leftfieldnames[]=$fieldname;
    $str_leftfieldname.="'".$fieldname."',";
    $sql='update ld_field set quickcreatesequence=? where tabid=? and fieldname=?';
    
    $adb->pquery($sql,array($index+1,$tabid,$fieldname));
    
}
$str_leftfieldname=trim($str_leftfieldname,',');
if(!empty($str_rightfieldname))
{
    $sql='update ld_field set quickcreate=1 where tabid=? and fieldname in( '.$str_rightfieldname.')';
    $adb->pquery($sql,array($tabid));
}
if(!empty($str_leftfieldname))
{
    $sql='update ld_field set quickcreate=0 where tabid=? and fieldname in( '.$str_leftfieldname.')';
    $adb->pquery($sql,array($tabid));
}
unsetCache('cache_gettabduplicate');
unsetCacheDirectory('fields');
$_REQUEST['diony']='yes';
ConvertTojsonString(1,array(),'success');

?>