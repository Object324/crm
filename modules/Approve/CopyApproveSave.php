<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
$record=$_REQUEST['record'];
global $adb,$current_user;
$newapproveid=$adb->getUniqueID('ld_approve');
$sql='select * from ld_approve where id=?';
$result=$adb->pquery($sql,array($record));
$name=$adb->query_result($result,0,'name');
$tabid=$adb->query_result($result,0,'tabid');

if($adb->query_result($result,0,'isnewapprove')=='yes')
{
    require_once("modules/Approve/CopyNewApproveSave.php");
    
}
$i=1;
while($i<=200)
{
    $sql='select 1 from ld_approve where name=?';
    $result=$adb->pquery($sql,array($name.'_'.$i));
    if($adb->num_rows($result)<=0)
    {
        break;
    }
    $i++;
}
$name=$name.'_'.$i;
$sql="insert into ld_approve(id,tabid,name,description,status,smcreatorid,modifiedby,createdtime,modifiedtime,approveallocatetype,allowediting,allowantiapproval,finishedallowedit,showsubmitremark,submitremarkrequire,showurgent,allowagainsubmit,finishedfield_allocatetype,finishedfield_allocateid,editresetapprove) 
                select $newapproveid, tabid,'$name',description,0,".$current_user->id.','.$current_user->id.",now(),now(),approveallocatetype,allowediting,allowantiapproval,finishedallowedit,showsubmitremark,submitremarkrequire,showurgent,allowagainsubmit,finishedfield_allocatetype,finishedfield_allocateid,editresetapprove from ld_approve where id=?";
$adb->pquery($sql,array($record));





//分配
$sql=' insert into ld_approve2user(approveid,userid) select  '.$newapproveid.',userid from ld_approve2user where approveid=?';
$adb->pquery($sql,array($record));

//审批结束后可编辑字段
$sql='INSERT into ld_approve_finishededitfield(`columns`,userid,approveid) SELECT `columns`,userid,? from ld_approve_finishededitfield where approveid = ?';
$adb->pquery($sql,array($newapproveid,$record));

$sql='select * from ld_approvestep where approveid=?  order by sequence asc ';
$result=$adb->pquery($sql,array($record));
$rows=$adb->num_rows($result);


$prev_concurrentid=0;
$new_concurrentid=0;
for($i=0;$i<$adb->num_rows($result);$i++)
{
    $stepid=$adb->query_result($result,$i,'id');
    $name=$adb->query_result($result,$i,'name');
    $description=$adb->query_result($result,$i,'description');
    $ended=$adb->query_result($result,$i,'ended');
    $step=$adb->query_result($result,$i,'step');
    $sequence=$adb->query_result($result,$i,'sequence');
    $approvetype=$adb->query_result($result,$i,'approvetype');
    
    $approvevalue=$adb->query_result($result,$i,'approvevalue');
    $specifyapproverid=$adb->query_result($result,$i,'specifyapproverid');
    $alloweditbill=$adb->query_result($result,$i,'alloweditbill');
	$countersigner=$adb->query_result($result,$i,'countersigner');
	$augmentsinger=$adb->query_result($result,$i,'augmentsinger');
	$module_field=$adb->query_result($result,$i,'module_field');
    $concurrentid=$adb->query_result($result,$i,'concurrentid');
    $approveremarkrequire=$adb->query_result($result,$i,'approveremarkrequire');
    $emptyapproverdeal = $adb->query_result($result,$i,'emptyapproverdeal');
    $newstepid=$adb->getUniqueID('ld_approvestep');//新增步骤的id
    
    
    if(!empty($concurrentid)>0&&$prev_concurrentid!=$concurrentid)
    {
        //复制的是并发步骤
        $sql='select max(concurrentid) as concurrentid from ld_approvestep ';
        $tmpresult=$adb->pquery($sql,array());
        $new_concurrentid=$adb->query_result($tmpresult,0,0)+1;
        $prev_concurrentid=$concurrentid;
    }
    if(empty($concurrentid))
    {
        $new_concurrentid=0;
    }
    $sql='insert into ld_approvestep(id,approveid,name,description,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid,alloweditbill,countersigner,augmentsinger,module_field,concurrentid,approveremarkrequire,emptyapproverdeal)
    value( '.$newstepid.','.$newapproveid.",'".$name."','$description',$ended,$step,$sequence,now(),now(),$approvetype,'$approvevalue',$specifyapproverid,'$alloweditbill','$countersigner','$augmentsinger','$module_field',$new_concurrentid,'$approveremarkrequire','$emptyapproverdeal') ";
    $adb->pquery($sql,array());//新增步骤
   
   
    $sql="insert into ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent,reminduserid,remindcolumnname)
    select $newstepid,type,remindmethod,reminduser,remindcontent,reminduserid,remindcolumnname from ld_approvereminds where stepid=?";
    $adb->pquery($sql,array($stepid));//新增提醒
    
    $sql=" insert into ld_approvestepadvfilter(stepid,columnindex,columnname,comparator,value,groupid,column_condition) 
            select $newstepid,columnindex,columnname,comparator,value,groupid,column_condition from ld_approvestepadvfilter where stepid=?";
    $adb->pquery($sql,array($stepid));//新增高级查询
    $sql=" insert into ld_approvestepadvfilter_grouping(stepid,groupid,group_condition,condition_expression) 
            select $newstepid,groupid,group_condition,condition_expression from ld_approvestepadvfilter_grouping where stepid=?";
    $adb->pquery($sql,array($stepid));//新增高级查询
    
    //修改下拉框的值
     $sql=" insert into ld_approvestepdetails(stepid,pass,modulestatus,pickcolumnname) 
            select $newstepid,pass,modulestatus,pickcolumnname from ld_approvestepdetails where stepid=?";
    $adb->pquery($sql,array($stepid));//

    //审批必填字段
    $sql = "INSERT into ld_approvestep_mandatoryfield(stepid,approveresult,allfieldname,sequence) SELECT ?,approveresult,allfieldname,sequence from ld_approvestep_mandatoryfield where stepid = ?";
    $adb->pquery($sql,array($newstepid,$stepid));
}

$_REQUEST['diony']='yes';
ConvertTojsonString(1,array(),'success');

/*select * from ld_approve;

select * from ld_approve2user;
select * from ld_approvestep;
select * from ld_approvereminds;
select * from ld_approvestepadvfilter;

select * from ld_approvestepadvfilter_grouping;

select  * from ld_approvestepdetails
*/
?>