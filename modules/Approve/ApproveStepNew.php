<?php
/***************************************************
**edit:duan
**date:2022-08-22
reason:新的审批步骤信息
***************************************************/


//判断使用新的审批流程或旧的审批流程
$approveinfo_arr = $approve->getApproveInfo($approveid);
$approveobj = Approve::getInstance($fld_module,$isnewapprove);


//审批必填字段判断
/*
if(!empty($_REQUEST['getApproveStepField']) && $_REQUEST['getApproveStepField'] == 'yes'){
	$approvestepinfo=$approveobj->getStepInfo($stepid);//审批步骤信息
	$module_status = $approveobj->getModuleRecordStatus($approvestepinfo['module_field'],$record,$fld_module);
	$_REQUEST['diony']='diony';
	if($module_status == 'no'){
		ConvertTojsonString(-1,array('stepid'=>$stepid),getFixedLabel('youwanttofillintherequiredfields'));
	}
	ConvertTojsonString(1,array(),array());
}
*/
//判断即将审批的步骤是否为会签

$countersigner=$approveobj->getisCounterSigner($countersigner,$approveinfo['nextstepapproveby'],$approveinfo['nextstepid']);
$nextapproved_bys=explode(',',$approveinfo['nextstepapproveby']);
if(!in_array($current_user->id,$nextapproved_bys))
{
	$_REQUEST['diony']='diony';
	ConvertTojsonString(-1,array(),getFixedLabel('BILLHAVEAPPROVED'));
}

if($countersigner=='yes'){
    
    //获取会签的下一步审批人
    //会签审批
    $nextsetpbyuser='';
    foreach($nextapproved_bys as $tmpindex=>$tmp_approveuserid){
         if($tmp_approveuserid==$current_user->id)
         {
            continue;//删除当前审批人
         }
         $nextsetpby.=$tmp_approveuserid.',';
    }
    
    $nextsetpby = rtrim($nextsetpby,',');
   
    if(!empty($nextsetpby))
    {
        $sql='select * from ld_approvestep where id=?';
        $result=$adb->pquery($sql,array($stepid));
        //用于判断审批界面的标题
        $stepname=$adb->query_result($result,0,'name');
        $curcountersigner=$adb->query_result($result,0,'countersigner');
        $approveremarkrequire = $adb->query_result($result,0,'approveremarkrequire');//审批意见是否必填
    }else{
        $countersigner = 'no';
    }
    $lastapproveinfo = $approve->getlastapproveinfo($record,$fld_module);
	$augmentsinger = $lastapproveinfo['augmentsinger'];
    $nextstepid=$stepid;
}
$smarty->assign('CUR_NEXTSTEPBY',$nextsetpby);
$smarty->assign("approveresult",1);
$nextstep_concurrentid=0;
$islastconcurrentstep='no';   

$changestep = $_REQUEST['changestep'];
$return_arr = [];
$return_arr['nextsteps_arr'] = [];

if(!empty($logconcurrentid)){
    $islastconcurrentstep=$approveobj->getisLastStepConcurrent($record,$logconcurrentid,$approveid);
}

if($countersigner=='no'||$nextsetpby==''||($approveinfo['augmentsinger'] == 'no'&& $countersigner != 'yes')){//非会签审批
        //获取当前流程的所有审批步骤
        $All_Stepinfo_arr = $approveobj->getAllStepInfoByApproveid($approveid);
        
        $cur_stepinfo = $All_Stepinfo_arr[$stepid];
        $cur_stepid = $stepid;
        $stepname = $cur_stepinfo['name'];
        $ended = $cur_stepinfo['ended'];
        $step = $cur_stepinfo['step'];//是否允许指定审批步骤0：允许，1：否
        $approveremarkrequire = $cur_stepinfo['approveremarkrequire'];//审批意见是否必填
        $augmentsinger = $cur_stepinfo['augmentsinger'];//加签
		if($approveinfo['augmentsinger'] == 'no'){
			$countersigner = 'no';
			if($approveinfo['approvestatus'] == 6)
				$augmentsinger = '';	//同为或签的时候
		}
        $showcancelbill = $cur_stepinfo['approvalauthority']['showcancelbill'];// 是否显示“驳回，结束流程（单据作废）”选项
        //获取下一步审批人
        $islastapprovestep='no';
        //duan 20240926 审批必填字段界面根据字段动态判断审批步骤
        if($changestep == 'yes'){
            //允许指定审批步骤的时候不需要动态变化步骤
            if($step == 0){
                ConvertTojsonString(-2,$return_arr,"success");
            }
            $requestvalues=$_REQUEST['requestvalues'];
            $columnvalue_arr=json_decode($requestvalues,true);
            $approveobj->setApprovechangeCheck($columnvalue_arr);
        }
        //获取下一审批步骤
        $nextstepinfo = $approveobj->getnextstepinfo($flowstepid,$stepid,$approveid,$record);
        
        //没有下一步骤，表示审批成功
        if($nextstepinfo['nextstepid'] <0){
            $smarty->assign("approveresult",2);
            $nextstepid = $nextstepinfo['nextstepid'];
            $return_arr['approveresult'] = 2;
        }else{
            $next_flowstepid = $nextstepinfo['flowstepid'];
            $tmpnextstepid = $nextstepinfo['nextstepid'];
            $next_stepinfo = $All_Stepinfo_arr[$tmpnextstepid];
            
            $tmpnextstepid=$next_stepinfo['stepid'];
            $nextstepid=$tmpnextstepid;
            $approvevalue = $next_stepinfo['approvevalue'];//下一步审批人
            $approvetype =$next_stepinfo['approvetype'];//下一步审批人类型（指定用户，指定角色，部门等待)
            $cur_specifyapproverid=$next_stepinfo['specifyapproverid'];//是否允许指定当前步骤审批人(1:否，0：是)
            $nextstep_countersigner=$next_stepinfo['countersigner'];
            $emptyapproverdeal=$next_stepinfo['emptyapproverdeal'];
            //获取下一步审批人
            $nextsetpby = '';$nextsetpbyuser = '';
            $focus=CRMEntity::getInstance($fld_module);
            if($changestep == 'yes'){
                if($record>0){
                    $focus->id = $record;
                    $focus->retrieve_entity_info($record,$fld_module);
                }
                $modulefields=$focus->fieldobj->getModuleFields();
                foreach($modulefields as $fieldname=>$fieldinfo)
                {
                    $columnname = $fieldinfo->getColumnName();
                    if(isset($columnvalue_arr[$columnname])){
                        $focus->column_fields[$fieldname]=$columnvalue_arr[$columnname];
                    }
                    $nextsetpby= $approveobj->getApproveByInfo($approvetype,$approvevalue,$focus);
                }
            }else{
                $nextsetpby = $approveobj->getApproveBy($approvetype,$approvevalue,$record,$emptyapproverdeal);
            }

            //duan 判断当前步骤是否允许审批人为空
            $allow_emptyapprover = $approveobj->get_allow_emptyapprover($tmpnextstepid,$approvetype);
            $nextstep_countersigner=$approveobj->getisCounterSigner($nextstep_countersigner,$nextsetpby,$tmpnextstepid);
            $nextstepidtoname = array();
            if(!empty($nextsetpby)){
                $ids=explode(',',$nextsetpby);
                foreach($ids as $value){
                    $tmpusername = getUserFullName($value);
                    $nextstepidtoname[$value] = $tmpusername;
                }
                $nextsetpbyuser = implode(',',$nextstepidtoname);
            }
            //大于6表示为用户字段
            $user_fieldname_arr = [];
            if($approvetype >6){
                $fieldname = $focus->fieldobj->getFieldInfoBykeyValue('fieldid',$approvetype,'fieldname');
                $user_fieldname_arr[] = $fieldname;
            }
            $arr['user_fieldname_arr'] = $user_fieldname_arr;
            $nextSteps=array();
            
            if($step){
                $nextSteps[] = array('stepid'=>$next_stepinfo['stepid'],'stepname'=>$next_stepinfo['name']);
            }
            else{
                //允许指定审批步骤
                //获取所有当前单据可以选择的所有审批步骤
                $_REQUEST['testtag'] = 3;
                $choose_stepinfo = $approveobj->getAllStepInfoByApproveid($approveid);
                
                foreach($choose_stepinfo as $tmp_stepinfo){
                    if($tmp_stepinfo['steptype'] == 'approver' && $tmp_stepinfo['stepid'] != $cur_stepid){
                        $nextSteps[] = array('stepid'=>$tmp_stepinfo['stepid'],'stepname'=>$tmp_stepinfo['name']);
                    }
                }
                
            }
            //$nextsetpby.':'.$nextsetpbyuser.':'.$specifyapproverid.":".$countersigner.":".$nextstepidtoname
            if(!empty($nextsetpby) && !empty($nextsetpbyuser)){
                $return_arr['nextsetpby'] = $nextsetpby;
                $return_arr['nextsetpbyuser'] = $nextsetpbyuser;
                $return_arr['nextstepidtoname'] = $nextstepidtoname;
            }else{
                $return_arr['nextsetpby'] = '';
                $return_arr['nextsetpbyuser'] = '';
                $return_arr['nextstepidtoname'] = '';
            }
            $return_arr['specifyapproverid'] = $cur_specifyapproverid;
            $return_arr['countersigner'] = $countersigner;

            $return_arr['user_fieldname_arr'] = $user_fieldname_arr;
            $return_arr['approveresult'] = 1;
            $return_arr['nextsteps_arr'] = $nextSteps;
            
            $smarty->assign("nextstep_countersigner",$nextstep_countersigner);
        }
}else{
	$approveremarkrequire = $cur_stepinfo['approveremarkrequire'];//审批意见是否必填
	$lastapproveinfo = $approve->getlastapproveinfo($record,$fld_module);
	$augmentsinger = $lastapproveinfo['augmentsinger'];
}
 
$smarty->assign('RECORD',$record);
$smarty->assign('MODULE',$fld_module);
$smarty->assign('RETURNMODULE',$returnmodule);
$smarty->assign('APPROVEID',$approveid);
$smarty->assign('STEPID',$stepid);
$smarty->assign('STEPNAME',$stepname);
//用于判断审批界面的标题
$smarty->assign("curcountersigner",$curcountersigner);

//判断当前步骤是否是第一步审批
$prestep_approveby = $approveobj->getApprovePreStepApproveBy($record);

$nextcheck='';
$endcheck='';

if($nextstepid<=0){
    $ended=0;
    $endcheck='checked';
   
}//最后一步可以结束流程
else{
    $nextcheck='checked';
}

if($changestep == 'yes'){
    $return_arr['ended'] = $ended;
    ConvertTojsonString(1,$return_arr,"success");
}

$assigned_user_id = $current_user->id;
$users_combo = get_select_options_array(get_user_array(FALSE, "Active", $assigned_user_id), $ids);
//print_r($users_combo);
$smarty->assign("users_combo",$users_combo);

$smarty->assign('nextstepid',$nextstepid);

$smarty->assign('nextsetpbyuser',$nextsetpbyuser);//下一步审批人姓名
$smarty->assign('NEXTSETPBY',$nextsetpby);//下一步骤审批人id
$smarty->assign('ALLOWEMPTYAPPROVER',$allow_emptyapprover);//是否允许审批人为空
$smarty->assign('NEXTSETPIDTONAME',$nextstepidtoname);//下一步骤审批人id与name对应关系
$smarty->assign('PRESTEPAPPROVEBY',$prestep_approveby);//判断当前是否是第一步审批

$smarty->assign('APPROVEREMARKREQUIRE',$approveremarkrequire);//判断审批意见是否必填
$smarty->assign('NEXTSETPID',$nextstepid);
$smarty->assign('augmentsinger',$augmentsinger);
$smarty->assign('CurStepspecifyapproverid',$cur_specifyapproverid);
$smarty->assign('ENDED',$ended);
$smarty->assign('showcancelbill',$showcancelbill);// 是否显示“驳回，结束流程（单据作废）”选项
$smarty->assign('STEP',$step);
$smarty->assign('LASTSTEPID',$laststepid);

$smarty->assign('NEXTSTEPS',$nextSteps);

//$smarty->assign('NEXTSPECIFYAPPROVERIDS',implode(',',$nextspecifyapproverids));
$smarty->assign('NEXTCHECK',$nextcheck);
$smarty->assign('ENDCHECK',$endcheck);
$smarty->assign('LANGUAGETYPE',$languageType);
$VersionInfo = getVersionInfo();
$smarty->assign('version_account',$VersionInfo['account']);
$smarty->assign("ShowHaigeInfo",'no');
$hiden_backup = 'no';
if($VersionInfo['account'] == 'haige'&&$fld_module=='Quotes'){
    $sql='select quota,usedquota from ld_customform06 where user_name=?
	and deleted=0 ';
	$result=$adb->pquery($sql,array($current_user->user_name));
    $approvetotal=0;
	if($adb->num_rows($result)>0)
	{
		$quota=$adb->query_result($result,0,'quota');
		$usedquota=$adb->query_result($result,0,"usedquota");
		$smarty->assign("ShowHaigeInfo",'yes');
        $sql='select sum(total) from ld_quotes inner join (select distinct ld_quotes.quoteid from ld_quotes
        inner join ld_approvelog 
        on ld_approvelog.crmid=ld_quotes.quoteid and ld_quotes.deleted=0
        where ld_approvelog.approved_by=? and ld_quotes.approvestatus=?
        and ld_approvelog.stepid<>-1)
        as tmp on tmp.quoteid=ld_quotes.quoteid';
        $approveresult=$adb->pquery($sql,array($current_user->id,D_A_S_APPROVED));
        
        if($adb->num_rows($approveresult)>0){
            $approvetotal=$adb->query_result($approveresult,0,0);
        }
        $sql='select total from ld_quotes where quoteid=?';
        $result=$adb->pquery($sql,array($record));
        $total=$adb->query_result($result,0,0);
        
	}
    if(empty($quota))
    {
        $quota=0;
    }
    if(empty($usedquota))
    {
        $usedquota=0;
    }
	$smarty->assign("Quota",setNumberFormat($quota, 2));
    
	$smarty->assign("BalanceApproveMoney",setNumberFormat( $quota-$usedquota-$approvetotal , 2  ));
    $smarty->assign("Total",setNumberFormat($total , 2  ));

    //duan 20240605 海格特殊开发,这两个审批步骤不显示驳回初始状态按钮
    $special_stepname_arr = ['Mkt.D审批','PM审批'];
    if(in_array($stepname,$special_stepname_arr)){
        $hiden_backup = 'yes';
    }

}

$smarty->assign("HIDENBACKUP",$hiden_backup);
$counter_augmentsinger = 'no';
$_REQUEST['diony']='diony';

// duan 20240923 获取审批需要使用的条件判断字段
crm_load_class_file("cls_approvestep_change","modules/Approve");
$approveid_arr = [];
$approveid_arr[] = $approveid;
$approvestep_change_obj = new cls_approvestep_change($fld_module);
$approvestep_change_obj->set_pagemode('approve');
$arr['approve_fieldname_arr'] = $approvestep_change_obj->get_approve_fieldname($approveid_arr);


$arr['oktext']=getFixedLabel("CONFIRME");
$arr['canceltext']=getFixedLabel("CANCEL");
if($curcountersigner=='yes')
         $arr['title']=getFixedLabel("Countersignature").':'.$stepname;
    else
         $arr['title']=getFixedLabel("APPROVAL").':'.$stepname;
 

   $smarty->assign("logconcurrentid",$logconcurrentid);
   $smarty->assign("approvelogid",$approvelogid);
if($approveinfo['approvestatus']=='6'||$approveinfo['approvestatus']==6)
{
   //只要当前审批步骤加过签，则不能再加签
    $smarty->assign("augmentsinger",'');
}
//审批日志先注释
//$ApprovelogSetInfo = $approveobj->getApprovelogSet($record);
//$ApprovelogSetInfo['showcurrentapprove'] = 'yes';
//$WholeApproveLog = $approveobj->getWholeApproveLog($record,$ApprovelogSetInfo);
//if(!empty($WholeApproveLog)){
//	$smarty->assign('WholeApproveLog',$WholeApproveLog);
//    $smarty->assign('RECORD',$record);
//    $smarty->assign('MODULENAME',$fld_module);
//    $smarty->assign('APPROVELOGSETINFO',$ApprovelogSetInfo);
//    $smarty->assign("noapprovesetting",'yes');
//    $smarty->assign("iskehu001",isKehu001ServerPc());
//    $smarty->assign("pre_hidden_btn",'yes');
//    $smarty->assign("next_hidden_btn",'yes');
//    
//	global $global_regop;
//	if(!isset($global_regop))
//		$global_regop=RegOp::getInstance();
//	$smarty->assign('AUTOGRAPH',$global_regop->gethandleWriteSign_interface());
//}

if(($countersigner=='yes'&&$logconcurrentid<=0)||($logconcurrentid>0&&$islastconcurrentstep=='no'))
{
   
    $stepapproveinfp = $approve->getStepInfo($approveinfo['nextstepid']);
  
    //edit:can 2021-03-02 44814: （61mis.com/kfbcrm）审批加签；销售管理-销售机会；审批流程中二级审批设置了加签，但在二级审批时弹出层中没有增加审批人选项；三级审批反审或驳回后，二级审批会出现增加审批人
    //加签 是会签有问题
    
	if($stepapproveinfp['augmentsinger'] == 'yes' && $approveinfo['approvestatus'] != "6"){
		$counter_augmentsinger = 'yes';
	}
    
   if($approve->getIsaugmentsinger($approveinfo['approveresult'],$approveinfo['approvelogid'],$record,$approveinfo['nextstepid'],$approveinfo['stepid'])=='yes')
   {
        //代表已加签过
        $counter_augmentsinger = 'no';
   }

	$smarty->assign('counter_augmentsinger',$counter_augmentsinger);
  
    
    if(empty($logconcurrentid))
    {
        $str=$smarty->fetch("Approve/CounterSignerStep.tpl");
    }
    else
    {
       
    
          
            $str=$smarty->fetch("Approve/LogConcurrentStep.tpl");
    }
    
    
}
else
{
 
    $concurrentidStep_arr=[];


     if($approve->getIsaugmentsinger($approveinfo['approveresult'],$approveinfo['approvelogid'],$record,$approveinfo['nextstepid'],$approveinfo['stepid'])=='yes')
   {
        //代表已加签过
    
        $smarty->assign("augmentsinger",'');
   }
   
        
        if($ended==1){
    		 if($nextstepid<=0)
    		 {
    			 //最后一步
    			 $smarty->assign("ENDCHECK",'checked');
    			 $smarty->assign("ENDED",'0');
    		 }
    	 }
    
    $smarty->assign('nextstep_concurrentid',$nextstep_concurrentid);
    $smarty->assign('concurrentidStep_arr',$concurrentidStep_arr);
    $smarty->assign('isnewapprove','yes');
    $str=$smarty->fetch("Approve/ApproveStep.tpl");
}
$arr['content']=$str;
ConvertTojsonString(1,$arr,"success");
?>