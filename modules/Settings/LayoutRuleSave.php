<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
$_REQUEST['diony']='yes';

global $adb,$current_user;
//布局规则保存
$rulename=$_REQUEST['rulename'];//布局名称

$triggercolumnname=$_REQUEST['triggercolumnname'];//触发字段
$frommodule=$_REQUEST['frommodule'];
$ruleid=$_REQUEST['ruleid'];//规则id
$tabid=getTabid($frommodule);

if(trim($rulename)=='')
{
    ConvertTojsonString(-1,array(),getFixedLabel('RULENAME').getFixedLabel('CANOTEMPTYGTH'));
}
$sql='select id from ld_fieldrule where tabid=? and rulename=?';
if($ruleid>0)
{
    $sql.=' and id<>'.$ruleid;
}
$result=$adb->pquery($sql,array($tabid,$rulename));
if($adb->num_rows($result)>0)
{
     ConvertTojsonString(-1,array(),getFixedLabel('RULENAME').getFixedLabel('CANOTREPEATED'));
}
if($ruleid>0)
{
    $sql='update ld_fieldrule set rulename=?,columnname=? where id=?';
    $adb->pquery($sql,array($rulename,$triggercolumnname,$ruleid));
    $sql='delete from ld_fieldruleadvancesearch
            where basicsearchid in(select id from ld_fieldrulebasicsearch where ruleid=? )';
    $adb->pquery($sql,array($ruleid));
    $sql='delete from ld_fieldrule_operate
            where basicsearchid in(select id from ld_fieldrulebasicsearch where ruleid=? )';
    $adb->pquery($sql,array($ruleid));
    $sql='delete from ld_fieldrulebasicsearch  where ruleid=?';
     $adb->pquery($sql,array($ruleid));
    
}
else
{
    $sql=' insert into ld_fieldrule(tabid,rulename,columnname,createdtime,smcreator,enablestatus)value(?,?,?,?,?,?)';
    $adb->pquery($sql,array($tabid,$rulename,$triggercolumnname,date("Y-m-d H:i:s"),$current_user->id,'yes'));
    $ruleid=$adb->getLastInsertID();
    
    
}
$arr_basicsearch=json_decode($_REQUEST['basicsearch'],true);
$advancesearch=$_REQUEST['advancesearch'];
$arr_advsearch=json_decode($advancesearch,true);
$arr_triggeroperate=json_decode($_REQUEST['triggeroperate'],true);

//$arr_basicsearch和$arr_advsearch是1对多的关系
//$arr_basicsearch和$arr_triggeroperate是1对多的关系
foreach($arr_basicsearch as $index=>$basicsearchinfo)
{
    $tmp_arr_advancesearch=$arr_advsearch[$index];
    $tmp_arr_triggeroperate=$arr_triggeroperate[$index];
    $sql='insert into ld_fieldrulebasicsearch(ruleid,comparator,value)value(?,?,?)';
    $adb->pquery($sql,array($ruleid,$basicsearchinfo['comparator'],$basicsearchinfo['value']));
    $basicsearchid=$adb->getLastInsertID();
    foreach($tmp_arr_advancesearch as $advancesearcinfo)
    {
        if(is_array($advancesearcinfo)&&$advancesearcinfo['columnname']!='')
        {
            $sql='insert into ld_fieldruleadvancesearch(basicsearchid,columnname,comparator,value,columncondition)value(?,?,?,?,?)';
            $adb->pquery($sql,array($basicsearchid,$advancesearcinfo['columnname'],$advancesearcinfo['comparator'],$advancesearcinfo['value'],$advancesearcinfo['columncondition']));
            
        }
    }
    foreach($tmp_arr_triggeroperate as $triggeroperateinfo)
    {
        if(is_array($triggeroperateinfo)&&$triggeroperateinfo['columnname']!='')
        {
            $sql='insert into ld_fieldrule_operate(type,columnname,basicsearchid)value(?,?,?)';
            $adb->pquery($sql,array($triggeroperateinfo['type'],$triggeroperateinfo['columnname'],$basicsearchid));
        }
    }
}
unsetCacheDirectory("fields");

ConvertTojsonString(1,array(),'success');


?>