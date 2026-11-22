<?php
/****************************************************
**edit:kevin
**date:2013-08-23
**reason:删除流程
****************************************************/
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb;
if(isset($_REQUEST['record']) && $_REQUEST['record']!='')
$record=$_REQUEST['record'];
if(isset($_REQUEST['blockid']) && $_REQUEST['blockid']!='')
$blockid=$_REQUEST['blockid'];
$approve=new Approve();
$_REQUEST['diony']='yes';
if(isset($_REQUEST['delete']) && $_REQUEST['delete']=='false'){    
    $approveresult=$approve->approveUsed($record,$blockid); 
    if($approveresult==1 || $approveresult==5){
		ConvertTojsonString(-1,array(),"USED");        
    }
    else{
       ConvertTojsonString(1,array(),"success");
    }
    
}
else{
	$approveresult=$approve->approveUsed($record,$blockid);      
	if($approveresult==1 || $approveresult==5){
		ConvertTojsonString(-1,array(),"USED"); 
	}

    //记录需要删除的审批步骤id
    $query="select GROUP_CONCAT(id) as stepids from ld_approvestep where approveid = ?";
    $result = $adb->pquery($query,array($record));
    $stepids = $adb->query_result($result, 0, 'stepids');


    $query="delete from ld_approve where id=$record";
    $adb->pquery($query);
    
    $query="delete from ld_approvestepadvfilter where stepid in(select id from ld_approvestep where approveid=$record)";

    $adb->pquery($query,array());
    
    $query="delete from ld_approvestepadvfilter_grouping where stepid in(select id from ld_approvestep where approveid=$record)";
    $adb->pquery($query,array());
    
    $query="delete from ld_approvestepdetails where stepid in(select id from ld_approvestep where approveid=$record)";
    $adb->pquery($query);

    if (!empty($stepids)) {
        $query='delete ld_smsrelated from ld_smsrelated inner join ld_approvereminds on ld_smsrelated.relatedid = ld_approvereminds.id and ld_smsrelated.relatedtable=? 
    where  ld_approvereminds.stepid in('.$stepids.')';
        $adb->pquery($query,array('ld_approvereminds'));
    }

    //删除审批提醒
    $query='delete from ld_approvereminds where  stepid in('.$stepids.')';
    $adb->pquery($query,array());

    $query="delete from ld_approvestep where approveid=$record";
    $adb->pquery($query);
    ConvertTojsonString(1,array(),"success");
}



?>