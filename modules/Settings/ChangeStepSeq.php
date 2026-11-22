<?php
/**************************************************
**edit:kevin
**date:2013-08-23
**reason:移动审批步骤
**************************************************/
// require_once("modules/Approve/Approve.php");
global $adb;
if(isset($_REQUEST['record']) && $_REQUEST['record']!='')
$record=$_REQUEST['record'];
if(isset($_REQUEST['stepid']) && $_REQUEST['stepid']!='')
$stepid=$_REQUEST['stepid'];
if(isset($_REQUEST['operation']) && $_REQUEST['operation']!='')
$operation=$_REQUEST['operation'];
if(isset($_REQUEST['blockid']) && $_REQUEST['blockid']!='')
$blockid=$_REQUEST['blockid'];
$approve=new Approve();
$approveresult=$approve->approveUsed($record,$blockid);
if($approveresult==1 || $approveresult==5){
    echo "###USED###";
    exit();        
}

if($operation=='up'){
    $query="select sequence,concurrentid,id from ld_approvestep where id=$stepid and approveid=$record";   
    $result=$adb->query($query);
    $sequence=floor($adb->query_result($result,0,'sequence'));  
    $concurrentid=$adb->query_result($result,0,'concurrentid');
    $stepid=$adb->query_result($result,0,'id');
    if($sequence>1){
        if($concurrentid>0)
        {
            $query="select sequence,id,concurrentid from ld_approvestep where sequence<? and approveid=? and concurrentid<>$concurrentid  order by sequence desc,id asc limit 1";
            $result=$adb->pquery($query,array($sequence,$record)); 
        }
        else
        {
            $query="select sequence,id,concurrentid from ld_approvestep where sequence<? and approveid=?   order by sequence desc,id asc limit 1";
            $result=$adb->pquery($query,array($sequence,$record)); 
        }      
        $prev_stepid=$adb->query_result($result,0,'id');  
        $prev_sequence=floor($adb->query_result($result,0,'sequence'));  
        $prev_concurrentid=$adb->query_result($result,0,'concurrentid');  
        
        $query="update ld_approvestep set sequence=$prev_sequence where id=$stepid and approveid=$record";
        $adb->pquery($query,array());
       
        $query="update ld_approvestep set sequence=$sequence where id=$prev_stepid and approveid=$record";
        $adb->pquery($query,array());
        
        if($concurrentid>0)
        {
            $sql='select * from ld_approvestep where approveid=?  and concurrentid=? and id<>? order by sequence asc  ';
            $result=$adb->pquery($sql,array($record,$concurrentid,$stepid));
            $rows=$adb->num_rows($result);
            
            //并发步骤重新排序
            for($i=0;$i<$rows;$i++)
            {
                $stepid=$adb->query_result($result,$i,'id');
                $tmpsequence=($i+1)*Approve_Concurrent_Stepseq+$prev_sequence;
                $updatesql='update ld_approvestep set sequence=? where id=?';
                $adb->pquery($updatesql,array($tmpsequence,$stepid));
                
            }
        }
       
        if($prev_concurrentid>0)
        {
            //并发步骤重新排序
            $sql='select * from ld_approvestep where approveid=?  and concurrentid=? and id<>? order by sequence asc  ';
            $result=$adb->pquery($sql,array($record,$prev_concurrentid,$prev_stepid));
            $rows=$adb->num_rows($result);
            
            
            for($i=0;$i<$rows;$i++)
            {
                $stepid=$adb->query_result($result,$i,'id');
                $tmpsequence=($i+1)*Approve_Concurrent_Stepseq+$sequence;
                $updatesql='update ld_approvestep set sequence=? where id=?';
                $adb->pquery($updatesql,array($tmpsequence,$stepid));
                
            }
        }
    }
    else{
        echo "###ALREADY_FIRST###";
        exit();
    }
    echo "###SUCCESS###";
    exit();
}
else{
    $query="select sequence,concurrentid,id from ld_approvestep where id=$stepid and approveid=$record";   
    $result=$adb->query($query);
    $sequence=floor($adb->query_result($result,0,'sequence'));
    $concurrentid=$adb->query_result($result,0,'concurrentid');
    $stepid=$adb->query_result($result,0,'id');
    $query="select max(sequence) as maxsequence from ld_approvestep where approveid=$record";
    $result=$adb->query($query);
    $maxSequence=$adb->query_result($result,0,'maxsequence');
    if(floor($sequence)<floor($maxSequence)){
        if($concurrentid>0)
        {
            $query="select id,concurrentid,sequence from ld_approvestep where sequence>? and approveid=? 
            and concurrentid<>$concurrentid  order by sequence asc limit 1";
            $result=$adb->pquery($query,array($sequence,$record));     
        }
        else
        {
            $query="select id,concurrentid,sequence from ld_approvestep where sequence>? and approveid=? order by sequence asc limit 1";
            $result=$adb->pquery($query,array($sequence,$record));       
        }
        $nextstepid=$adb->query_result($result,0,'id');
        $nextconcurrentid=$adb->query_result($result,0,'concurrentid');
        $nextsequence=floor($adb->query_result($result,0,'sequence'));
        if($nextconcurrentid>0)
        {
             $query="select id,concurrentid,sequence from ld_approvestep where sequence=? and approveid=? 
            and concurrentid=? order by sequence asc limit 1";//获取下一条sequence最小的步骤
            $result=$adb->pquery($query,array($nextsequence,$record,$nextconcurrentid));  
            $nextstepid=$adb->query_result($result,0,'id');
        }
        $query="update ld_approvestep set sequence=? where id=$stepid and approveid=$record";
       
        $adb->pquery($query,array($nextsequence));
        
        $query="update ld_approvestep set sequence=? where id=$nextstepid and approveid=$record";
        $adb->pquery($query,array($sequence));
        if($concurrentid>0)
        {
            $sql='select * from ld_approvestep where approveid=?  and concurrentid=? and id<>? order by sequence asc  ';
           
            $result=$adb->pquery($sql,array($record,$concurrentid,$stepid));
            $rows=$adb->num_rows($result);
            
            //并发步骤重新排序
            for($i=0;$i<$rows;$i++)
            {
                $stepid=$adb->query_result($result,$i,'id');
                $tmpsequence=($i+1)*Approve_Concurrent_Stepseq+$nextsequence;
                $updatesql='update ld_approvestep set sequence=? where id=?';
                $adb->pquery($updatesql,array($tmpsequence,$stepid));
              
            }
        }
      
        if($nextconcurrentid>0)
        {
            $sql='select * from ld_approvestep where approveid=?  and concurrentid=? and id<>? order by sequence asc  ';
            $result=$adb->pquery($sql,array($record,$nextconcurrentid,$nextstepid));
            $rows=$adb->num_rows($result);
            
            //并发步骤重新排序
            for($i=0;$i<$rows;$i++)
            {
                $stepid=$adb->query_result($result,$i,'id');
                $tmpsequence=($i+1)*Approve_Concurrent_Stepseq+$sequence;
                $updatesql='update ld_approvestep set sequence=? where id=?';
                $adb->pquery($updatesql,array($tmpsequence,$stepid));
                
            }
        }
    }
    else{
        echo "###ALREADY_LAST###";
        exit();
    }
    echo "###SUCCESS###";
    exit();
}
?>