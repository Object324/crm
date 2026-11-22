<?php
//zkt 20231122 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
 global $adb;
$approveid=$_REQUEST['approveid'];
if(!is_numeric($approveid))
{
    exit();
}
if($approveid == -1 || $approveid == 0){//xxy 2023-12-14 增加参数：无默认审批流时显示为空 ,approveid=-1为满足条件时的空审批流程，也返回一个空的审批步骤数组
    $_REQUEST['diony'] = 'yes';
    $tmp = array();
    $nextStepInfo_arr[] = array('nextstepname'=>'','stepid'=>'','newstepapprover'=>'','specifyapproverid'=>-1,'stepuserids'=>'','countersigner'=>'','augmentsinger'=>'','concurrentid'=>'','stepuseridtonamearr'=>'','allow_emptyapprover'=>'');
    $tmp['steplist'] = $nextStepInfo_arr;
    $tmp['isnewapprove'] = '';
    $tmp['labels'] = array('stepname' => getFixedLabel('NEXTAPPROVESTEP'), 'Countersigner' => getFixedLabel('Countersigner'), 'APPROVER' => getFixedLabel('APPROVER'));
    ConvertTojsonString(1, $tmp, 'success');
}
if(isset($_REQUEST['requestvalue_arr'])){
    $requestvalue_arr = $_REQUEST['requestvalue_arr'];
}else{
    $requestvalues=$_REQUEST['requestvalues'];
    $requestvalue_arr=ldcrm_json_decode($requestvalues);
}



$columnvalue_arr = $requestvalue_arr;
if(isset($_REQUEST['detaildata_arr'])){
    $detaildata_arr = $_REQUEST['detaildata_arr'];
    $columnvalue_arr = array_merge($columnvalue_arr,$detaildata_arr);
}


$frommodule=$_REQUEST['frommodule'];
$isnewapprove=$_REQUEST['isnewapprove'];
$focus=CRMEntity::getInstance($frommodule);
$modulefields=$focus->fieldobj->getModuleFields();
if(isset($_REQUEST['record'])&&!empty($_REQUEST['record'])){
    $focus->id = $_REQUEST['record'];
}
foreach($modulefields as $fieldname=>$fieldinfo)
{
    $focus->column_fields[$fieldname]=$requestvalue_arr[$fieldinfo->getColumnName()];
}

$sql='select isnewapprove from ld_approve where id=?';
$result=$adb->pquery($sql,array($approveid));
$isnewapprove = $adb->query_result($result,0,'isnewapprove');

$approveobj=Approve::getInstance($frommodule,$isnewapprove);

if($isnewapprove == 'yes'){
    $approveobj->setApprovechangeCheck($columnvalue_arr);
    $stepinfo = $approveobj->getnextstepinfo(-1,-1,$approveid,$focus->id);
    $sql = "SELECT name,approvevalue,approvetype,specifyapproverid
        ,countersigner,augmentsinger,ld_approvestep.id
        ,ld_approvestep.concurrentid,ld_approvestep.id as stepid,emptyapproverdeal
    FROM ld_approvestep WHERE id=? order by sequence asc  limit 1 ";
    $result = $adb->pquery($sql,array($stepinfo['nextstepid']));
}else{
    $sql = "SELECT name,approvevalue,approvetype,specifyapproverid
        ,countersigner,augmentsinger,ld_approvestep.id
        ,ld_approvestep.concurrentid,ld_approvestep.id as stepid,emptyapproverdeal
    FROM ld_approvestep WHERE approveid=$approveid order by sequence asc  limit 1 ";
    $result = $adb->pquery($sql);
}

$rows=$adb->num_rows($result);
if ($rows > 0) {
    
    $concurrentid=$adb->query_result($result,0,'concurrentid');
    
    if($concurrentid>0)
    {
        $sql = "SELECT name,approvevalue,approvetype,specifyapproverid
            ,countersigner,augmentsinger,ld_approvestep.id,emptyapproverdeal
            ,ld_approvestep.concurrentid
       FROM ld_approvestep WHERE approveid=$approveid and concurrentid=$concurrentid order by sequence  ";
        $result = $adb->pquery($sql);
    }
     $rows=$adb->num_rows($result);
     
    for($i=0;$i<$rows;$i++)
    {
        $nextStepName = $adb->query_result($result,$i, 'name');
        $nextStepValue = $adb->query_result($result, $i, 'approvevalue');
        $nextStepType = $adb->query_result($result, $i, 'approvetype');
        $specifyapproverid=$adb->query_result($result, $i, 'specifyapproverid');
        $countersigner=$adb->query_result($result,$i,'countersigner');//是否会签审批,yes:是
		$augmentsinger=$adb->query_result($result,$i,'augmentsinger');//是否加签
        $stepid=$adb->query_result($result,$i,'id');

		//在批量：如果选择了多个单据的情况下，默认取第一个
        $nextStepApproverIds=[];
        $nextStepApprover='';
        $stepuserids='';
        $stepuseridtonamearr = array();
        $nextStepApproverIds = $approveobj->getApproveByInfo($nextStepType,$nextStepValue,$focus);
        
        $approveby_arr[] =  array($nextStepType,$nextStepValue);
        //duan 2022-4-22 单据审批时如果下一步审批人为空，则根据‘审批人为空时处理方式’参数替换审批人信息
        $allow_emptyapprover = $approveobj->get_allow_emptyapprover($stepid,$nextStepType);
        if(empty($nextStepApproverIds) && $allow_emptyapprover == 'yes'){ //如果该类型可以设置对应参数
        	$emptyapproverdeal=$adb->query_result($result,$i,'emptyapproverdeal');
        	$nextStepApproverIds = $approveobj->getTransferUsers($emptyapproverdeal);
        }
		if(!empty($nextStepApproverIds)){
			$sql = "SELECT group_concat(last_name order by id asc) guser,group_concat(id order by id asc) as stepuserids 
           , group_concat(ifnull(wx_userid,'') order by id asc) as wx_userids
            FROM ld_users WHERE `status` = 'Active' and id IN ($nextStepApproverIds)";
			$tmp_result=$adb->pquery($sql);
            
            $nextStepApprover = $adb->query_result($tmp_result, 0, 'guser');
            $wx_userids=$adb->query_result($tmp_result, 0, 'wx_userids');
            if(!empty($wx_userids))
            {
                $wx_userid_array=explode(",",$wx_userids);
                $last_name_array=explode(',',$nextStepApprover);
                $tmp_last_name_array=$last_name_array;
                if(is_array($wx_userid_array)&&$wx_userid_array[0]!=''){
                    
                    foreach($wx_userid_array as $tmpindex=>$tmp_wx_userid)
                    {
                        $userobj=new Users();
                         $userobj->wx_userid=$tmp_wx_userid;
                         $userobj->last_name=$last_name_array[$tmpindex];
                         $tmp_last_name_array[$tmpindex]=getUserlastName($userobj);
                    }
                }
                $nextStepApprover=implode(",",$tmp_last_name_array);
            }
            
            $stepuserids= $adb->query_result($tmp_result, 0, 'stepuserids');
            
            if(!empty($stepuserids)){
                $stepuserid_arr = explode(",",$stepuserids);
                $last_namearr=explode(',',$nextStepApprover);
                if(is_array($stepuserid_arr)&&$stepuserid_arr[0]!=''){
                    
                    foreach($stepuserid_arr as $tmpindex=>$tmp_userid)
                    {
                        $tmp_username = $last_namearr[$tmpindex];
                        $stepuseridtonamearr[$tmp_userid] = $tmp_username;
                    }
                }
            }
		}
         //本步骤是否为会签需要满足两个条件1：审批步骤设为会签，2：审批人是2个或者2个以上
        $countersigner=$approveobj->getisCounterSigner($countersigner,$nextStepApproverIds,$stepid);
         $nextStepInfo_arr[]=array('nextstepname'=>$nextStepName,'stepid'=>$stepid,'newstepapprover'=>$nextStepApprover,
        'specifyapproverid'=>$specifyapproverid,'stepuserids'=>$stepuserids
        ,'countersigner'=>$countersigner,'augmentsinger'=>$augmentsinger,
        'concurrentid'=>$concurrentid,'stepuseridtonamearr'=>$stepuseridtonamearr,'allow_emptyapprover'=>$allow_emptyapprover);
    }
}
$_REQUEST['diony'] = 'yes';
$tmp = array();
$tmp['steplist'] = $nextStepInfo_arr;
$tmp['isnewapprove'] = $isnewapprove;
$tmp['labels'] = array('stepname' => getFixedLabel('NEXTAPPROVESTEP'), 'Countersigner' => getFixedLabel('Countersigner'), 'APPROVER' => getFixedLabel('APPROVER'));
//echo json_encode($nextStepInfo);
ConvertTojsonString(1, $tmp, 'success');

?>