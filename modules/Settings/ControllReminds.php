<?php
/****************************************************
**edit:andy
**date:2014-05-08
**reason:禁用,删除-提醒
****************************************************/
//require_once("modules/Approve/Approve.php");
global $adb;
if(isset($_REQUEST['record']) && $_REQUEST['record']!='')
    $record=$_REQUEST['record'];
if(isset($_REQUEST['blockid']) && $_REQUEST['blockid']!='')
    $blockid=$_REQUEST['blockid'];
if(isset($_REQUEST['type']) && $_REQUEST['type']!='')
    $type=$_REQUEST['type'];

$smarty=new lingdangCRM_Smarty;

if($type == 1)//启用状态改成禁用状态
{
	$sql="UPDATE ld_automaticreminds SET status = 2 where id=$record  and tabid=$blockid";
	$adb->query($sql);
	$_REQUEST['diony']='diony';
	ConvertTojsonString(1,array(),"success");
}
elseif($type==2)//禁用状态改成启用状态
{
	$sql="UPDATE ld_automaticreminds SET status = 1 where id=$record  and tabid=$blockid";
	$adb->query($sql);
	$_REQUEST['diony']='diony';
	ConvertTojsonString(1,array(),"success");
}
elseif($type==3)
{
    //删除规则，后续估计要判断使用情况
    $sql="DELETE from ld_automaticreminds where id=$record and tabid=$blockid";
    $adb->query($sql);
    //删除该规则相关表内容
    $sql="DELETE from ld_remindway where wayid=$record";
    $adb->query($sql);
    $sql="DELETE from ld_remindcvstdfilter where cvid=$record";
    $adb->query($sql);
    $sql="DELETE from ld_remindcvadvfilter where cvid=$record";
    $adb->query($sql);
    $sql="delete from ld_reminds where reminds_ruleid=$record  AND status_rmd !='已读'";//删除该规则下所有的未读提醒
    $adb->query($sql);
    $sql="DELETE from ld_tmpreminder where reminds_ruleid=$record";//删除临时表提醒
    $adb->query($sql);

    $sql="delete from ld_smsrelated where relatedtable=? and relatedid=?";//删除提醒关联表
    $adb->pquery($sql,array("ld_automaticreminds",$record));

    $_REQUEST['diony']='diony';
	ConvertTojsonString(1,array(),"success");
}
if($_REQUEST['ajax'] == 'true' && isset($_REQUEST['remindRuleName']) && isset($_REQUEST['mode']))
{
    $sql   ="SELECT 1 from ld_automaticreminds where tabid =? and name =?";
    $result= $adb->pquery($sql,array($_REQUEST['mode'],$_REQUEST['remindRuleName']));
    $nums  =$adb->num_rows($result);
    if($nums> 0){
        $_REQUEST['diony']='diony';
		ConvertTojsonString(-1,array(),"USED");
    }else{
        $_REQUEST['diony']='diony';
		ConvertTojsonString(1,array(),"success");
    }
    
}
if($_REQUEST['ajax'] == 'true' && isset($_REQUEST['formatcontent']) && $_REQUEST['formatcontent'] == '1')
{
    if(isset($_REQUEST['record']) && $_REQUEST['record'] != ''){
        
    
    }else{
		$_REQUEST['diony']='diony';
		ConvertTojsonString(1,array(),"success");
    }
}

?>