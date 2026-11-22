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
 
$sql="insert into ld_approve(id,tabid,name,description,status,smcreatorid,modifiedby,createdtime,modifiedtime,approveallocatetype,allowediting,allowantiapproval,finishedallowedit,showsubmitremark,submitremarkrequire,showurgent
,allowagainsubmit,isnewapprove,dataadv,dataadvgroup,finishedfield_allocatetype,finishedfield_allocateid,editresetapprove) 
                select $newapproveid, tabid,'$name',description,0,".$current_user->id.','.$current_user->id.",now(),now(),approveallocatetype,allowediting,allowantiapproval,finishedallowedit,showsubmitremark,submitremarkrequire,showurgent
                    ,allowagainsubmit,isnewapprove,dataadv,dataadvgroup,finishedfield_allocatetype,finishedfield_allocateid,editresetapprove from ld_approve where id=?";
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


crm_load_class_file('cls_Send_MassSms','include/utils');
$cls_Send_MassSms = cls_Send_MassSms::getInstance();

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
    $steptype=$adb->query_result($result,$i,'steptype');
    $isnewstep='yes';
    $flowstepid=$adb->query_result($result,$i,'flowstepid');
    $childids=$adb->query_result($result,$i,'childids');
    $writesignrequired=$adb->query_result($result,$i,'writesignrequired');
    $writesignlogtype=$adb->query_result($result,$i,'writesignlogtype');
    $approverremovetype=$adb->query_result($result,$i,'approverremovetype');
    $branchflowstepid=$adb->query_result($result,$i,'branchflowstepid');
        
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
    $sql='insert into ld_approvestep(id,approveid,name,description,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid,alloweditbill,countersigner,augmentsinger,
            module_field,concurrentid,approveremarkrequire,emptyapproverdeal,steptype,isnewstep,flowstepid,childids,writesignrequired,writesignlogtype,approverremovetype,branchflowstepid)
    value( '.$newstepid.','.$newapproveid.",'".$name."','$description','$ended','$step',$sequence,now(),now(),'$approvetype','$approvevalue','$specifyapproverid','$alloweditbill','$countersigner','$augmentsinger'
    ,'$module_field',$new_concurrentid,'$approveremarkrequire','$emptyapproverdeal'
    ,'$steptype','$isnewstep','$flowstepid','$childids','$writesignrequired','$writesignlogtype','$approverremovetype','$branchflowstepid') ";
    $adb->pquery($sql,array());//新增步骤


    if ($cls_Send_MassSms->platform == 'aliyun') {
        $sql = "select ld_approvereminds.*,ld_smsrelated.relatedtable,ld_smsrelated.relatedmodulename,ld_smsrelated.template_id,ld_smsrelated.templateparamconf,ld_smsrelated.scene 
from ld_approvereminds left join ld_smsrelated ON ld_approvereminds.id = ld_smsrelated.relatedid AND relatedtable='ld_approvereminds'
where ld_approvereminds.stepid=?";echo 'aliyun:'.$stepid."<br>";
        $tmp_result = $adb->pquery($sql,array($stepid));
        $num_rows = $adb->num_rows($tmp_result);
        if ($num_rows >= 1) {
            for($j = 0; $j<$num_rows; $j++){
                //审批提醒相关字段
                $type = $adb->query_result($tmp_result, $j, 'type');
                $remindmethod = $adb->query_result($tmp_result, $j, 'remindmethod');
                $reminduser = $adb->query_result($tmp_result, $j, 'reminduser');
                $remindcontent = $adb->query_result($tmp_result, $j, 'remindcontent');
                $reminduserid = $adb->query_result($tmp_result, $j, 'reminduserid');
                $remindcolumnname = $adb->query_result($tmp_result, $j, 'remindcolumnname');
                $remindtitle = $adb->query_result($tmp_result, $j, 'remindtitle');

                $sql="insert into ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent,reminduserid,remindcolumnname,remindtitle) value(?,?,?,?,?,?,?,?)";
                $adb->pquery($sql,array($newstepid,$type,$remindmethod,$reminduser,$remindcontent,$reminduserid,$remindcolumnname,$remindtitle));
                $last_approveremindsid = $adb->getLastInsertID();

                //短信配置相关字段
                $templateid = $adb->query_result($tmp_result, $j, 'template_id');
                if ($remindmethod == 'sms' && !empty($templateid)) {
                    $relatedtable = $adb->query_result($tmp_result, $j, 'relatedtable');
                    $relatedmodulename = $adb->query_result($tmp_result, $j, 'relatedmodulename');
                    $templateparamconf = $adb->query_result($tmp_result, $j, 'templateparamconf');
                    $scene = $adb->query_result($tmp_result, $j, 'scene');
                    $cls_Send_MassSms->insertSmsRelated($relatedtable, $last_approveremindsid, $relatedmodulename, $templateid, $templateparamconf,$scene);
                }

            }
        }
    }else{
        $sql="insert into ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent,reminduserid,remindcolumnname,remindtitle)
       select $newstepid,type,remindmethod,reminduser,remindcontent,reminduserid,remindcolumnname,remindtitle from ld_approvereminds where stepid=?";
       $adb->pquery($sql,array($stepid));//新增提醒
    }

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