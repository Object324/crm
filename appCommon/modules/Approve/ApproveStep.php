<?php
sleep(2);

$approveinfo=$approve->approveStatus($record);
$approveid=$approveinfo['approveid'];
$stepid=$approveinfo['nextstepid'];
$laststepid=$approveinfo['stepid'];	//上一步

$query="select ld_approve.name,ld_approvestep.id as maxstepid ,sequence as  maxsequence
from ld_approve left join ld_approvestep on ld_approve.id=ld_approvestep.approveid 
where ld_approve.id=? 
order by ld_approvestep.sequence desc,ld_approvestep.id desc limit 1";
$result=$adb->pquery($query,array($approveid));
$approvename=$adb->query_result($result,0,'name');
$maxstepid=$adb->query_result($result,0,'maxstepid');
$maxSequence=$adb->query_result($result,0,'maxsequence');

$query="select * from ld_approvestep where approveid=? and id=?";
$result=$adb->pquery($query,array($approveid,$stepid));
$stepname=$adb->query_result($result,0,'name');
$ended=$adb->query_result($result,0,'ended');
$step=$adb->query_result($result,0,'step');
$sequence=$adb->query_result($result,0,'sequence');
$nextspecifyapproverid=$adb->query_result($result,0,'specifyapproverid');//是否允许指定审批人(1:否，0：是)

//获取下一步审批人
$query="select approvevalue,approvetype from ld_approvestep where approveid=?  ";
if($sequence<$maxSequence)
{
    $query.=" and sequence>".$sequence. ' order by sequence asc  limit 1';
}
else
{
    $query.=" and id=".$maxstepid;
}
$result=$adb->pquery($query,array($approveid));
$approvevalue = $adb->query_result($result,0,'approvevalue');//下一步审批人
$approvetype = $adb->query_result($result,0,'approvetype');//下一步审批人类型（指定用户，指定角色，部门等待)

/**
 * 当前步骤：允许指定下一步审批人的情况下，再去获取下一步审批人信息
 * @reason 0016110: 审批流程为多步时，当审批步骤中有指定角色时，这时，下一步审批人显示不对
 * @author Tujt 2015-07-10
 */
$nextsetpby = '';$nextsetpbyuser = '';
/*
if(0 == $nextspecifyapproverid){//获取下一步审批人
    $nextsetpby = $approve->getApproveBy($approvetype,$approvevalue);//下一步审批人用户ID
    if(!empty($nextsetpby)){
		$ids=explode(',',$nextsetpby);
       
        foreach($ids as $value){
            $nextsetpbyuser .=getUserFullName($value).",";
        }
		//获取下一步审批人的用户名称
        $nextsetpbyuser=substr($nextsetpbyuser,0,strlen($nextsetpbyuser)-1);//删除最后一个多余的逗号
	}
}
*/
$nextsetpby = $approve->getApproveBy($approvetype,$approvevalue,$record);
if(!empty($nextsetpby)){
    $ids=explode(',',$nextsetpby);
    foreach($ids as $value){
        $nextsetpbyuser .=getUserFullName($value).",";
    }
    /*
     * editor:gyq_05
     * reason:字符串末尾逗号为清除失败
     * date  : 2016 3 2
     * */
    $nextsetpbyuser = rtrim($nextsetpbyuser,',');
    //$nextsetpbyuser=substr($nextsetpbyuser,0,strlen($nextsetpbyuser)-1);//删除最后一个多余的逗号
}
$sqlnextset = "select id,approvevalue from ld_approvestep where approveid=$approveid and sequence >= 
(select sequence from ld_approvestep where approveid=$approveid and id =
(select nextstepid from ld_approvelog where approveid = $approveid and crmid = $record order by id desc limit 1 )) and id <>
(select nextstepid from ld_approvelog where approveid = $approveid and crmid = $record order by id desc limit 1 )  order by sequence asc limit 1 ";
$result = $adb->pquery($sqlnextset);
$nextsetpid = $adb->query_result($result,0,'id');

$nextSteps=array();
if($step){
    $query="select id,name,approvevalue from ld_approvestep where approveid=? and sequence>=? and id<>? order by sequence limit 1";
    $result=$adb->pquery($query,array($approveid,$sequence,$stepid));
    $nextSteps[]=array('stepid'=>$adb->query_result($result,0,'id'),
    'stepname'=>$adb->query_result($result,0,'name')
    );
}
else{
    $query="select * from ld_approvestep where approveid=? order by sequence";
    $result=$adb->pquery($query,array($approveid));
    $num_rows=$adb->num_rows($result);
    for($i=0;$i<$num_rows;$i++){
        $selected='no';
        if($nextsetpid==$adb->query_result($result,$i,'id'))
        {
            $selected='yes';
        }
        $nextSteps[]=array('stepid'=>$adb->query_result($result,$i,'id'),
        'stepname'=>$adb->query_result($result,$i,'name'),
        'selected'=>$selected
    );
    }    
}

$nextcheck='uncheck';
$endcheck='uncheck';

$arrapprove['list'][]=array('approvestatus'=>4,'label'=>getFixedLabel('NOTPASSRETURNCHARGE'),'checked'=>'uncheck');

//判断当前步骤是否是第一步审批
$prestep_approveby = $approve->getApprovePreStepApproveBy($record);
if($prestep_approveby>=1){
    $arrapprove['list'][]=array('approvestatus'=>5,'label'=>getFixedLabel('IFNOTPASSEDTHENRETURNTOTHEPREVIOUSSTEP'),'checked'=>'uncheck');
}
if($stepid==$maxstepid){
    $ended=0;
    $endcheck='checked';
   
}//最后一步可以结束流程

else{
    $step=0;
    $nextcheck='checked';
}

if($ended==0)
{
    $arrapprove['list'][]=array('approvestatus'=>2,'label'=>getFixedLabel('SUCCESSENDPROCESS'),'checked'=>$endcheck);
    $arrapprove['list'][]=array('approvestatus'=>3,'label'=>getFixedLabel('FAILENDPROCESS'),'checked'=>'uncheck');
}
if($step==0)
{
    $nextuserinfo = array('nextspecifyapproverid'=>$nextspecifyapproverid,'nextsetpby'=>$nextsetpby,'nextsetpbyuser'=>$nextsetpbyuser);
    $arrapprove['list'][]=array('approvestatus'=>1,'label'=>getFixedLabel('CONTINUEAPPROVALSTEP'),'checked'=>$nextcheck,'options'=>$nextSteps,'setnextuser'=>$nextuserinfo); 
}
$arrapprove['list1']=array('record'=>$record,'modulename'=>$fld_module,'approveid'=>$approveid,'stepid'=>$stepid,'stepname'=>$stepname,'laststepid'=>$laststepid);
ConvertTojsonString(1,$arrapprove,'');
