<?php
/********************************************************
**edit:kevin
**date:2013-08-23
**reason:删除审批步骤
********************************************************/
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb;
if(isset($_REQUEST['stepid']) && $_REQUEST['stepid'] !='')
$stepid=$_REQUEST['stepid'];
if(isset($_REQUEST['record']) && $_REQUEST['record']!='')
$record=$_REQUEST['record'];
if(isset($_REQUEST['blockid']) && $_REQUEST['blockid']!='')
$blockid=$_REQUEST['blockid'];

$approve=new Approve();
$approveresult=$approve->approveUsed($record,$blockid);
if($approveresult==1 || $approveresult==5){
    //echo "###USED###";
    //exit();        
}


//获取删除步骤的sequence
$query="select sequence,concurrentid,approveid from ld_approvestep where id=$stepid";
$result=$adb->query($query);
$sequence=$adb->query_result($result,0,'sequence');
$concurrentid=$adb->query_result($result,0,'concurrentid');
$approveid=$adb->query_result($result,0,'approveid');

//duan 2023-03-03 使用中的审批流程不允许删除，否则会影响审批日志显示
$module=getTabname($blockid);
$focus = CRMEntity::getInstance($module);
$table_name = $focus->table_name;
$table_index = $focus->table_index;
if($concurrentid >0){
    $tmp_query = "SELECT 1 from ld_approvelog INNER JOIN $table_name on $table_name.$table_index = ld_approvelog.crmid
        where ld_approvelog.stepid = ? and $table_name.deleted =0 AND $table_name.approvestatus = '审批中' and  ld_approvelog.isfinished = 'no' ;";
}else{
    $tmp_query = "SELECT 1 from ld_approvelog 
        INNER JOIN (SELECT crmid,max(id) as max_id from ld_approvelog GROUP BY crmid )as tmp_data 
        on tmp_data.max_id = ld_approvelog.id
        INNER JOIN $table_name on $table_name.$table_index = tmp_data.crmid
        where ld_approvelog.nextstepid = ? and $table_name.deleted = 0 AND $table_name.approvestatus = '审批中' ;";
}
$tmp_result = $adb->pquery($tmp_query,array($stepid));
if($adb->num_rows($tmp_result)>0){
    echo "###USED###";
    exit();  
}

$query="delete from ld_approvestep where id=$stepid";
$adb->query($query);
$query="delete from ld_approvestepdetails where stepid=$stepid";
$adb->query($query);
$query="update ld_approvelog set description = '".getFixedLabel('thisstephasbeendeleted')."' where stepid=$stepid";
$adb->query($query);




if($concurrentid>0)
{
    //删除的是并发步骤且删除是第一个并发步骤
   $query=" select ld_approvestep.sequence,ld_approvestep.concurrentid,ld_approvestep.id from   ld_approvestep
     
    where  ld_approvestep.approveid=$approveid and ld_approvestep.concurrentid=$concurrentid order by  ld_approvestep.sequence asc,ld_approvestep.id asc   ";
   
   $result=$adb->query($query);//获取当前并发步骤最小的sequence
   if($adb->num_rows($result)>0)
   {
          $stepid=$adb->query_result($result,0,'id');
          $rows=$adb->num_rows($result);
          if($adb->num_rows($result)==1)
           {
           
             //并发步骤只剩余一条了，则要更新concurrentid=0
                //$query="delete from ld_approvestep_concurrent where stepid=$stepid";
              //  $adb->query($query);
                //最后一条要修改为非并发步骤标识
                $query="update ld_approvestep set concurrentid=0 where id=$stepid ";
                $adb->query($query);
                
           }
            
          
            for($i=0;$i<$rows;$i++)
            {
                //并发步骤重新排序
                $sequence=$adb->query_result($result,$i,'sequence');
                $stepid=$adb->query_result($result,$i,'id');
                
                $tmpsequence=$i*Approve_Concurrent_Stepseq+floor($sequence);
                 $updatesql='update ld_approvestep set sequence=? where id=?';
                $adb->pquery($updatesql,array($tmpsequence,$stepid));
            }    
                
           
   }
}
else{
    $query="update ld_approvestep set sequence=sequence-1 where approveid=$record and sequence>$sequence order by sequence ASC";

    $adb->query($query);
}
echo "###SUCCESS###";
exit();
?>