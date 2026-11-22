<?php
/***************************************************
**edit:kevin
**date:2013-09-11
reason:审批历史
***************************************************/
//zkt 20231122 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();

global $adb,$current_user,$languageType;

if(isset($_REQUEST['fld_module']) && $_REQUEST['fld_module']!=''){    
    $fld_module=$_REQUEST['fld_module'];
    $returnmodule = $_REQUEST['returnmodule'];
    $blockid=getTabid($fld_module);
}
if(isset($_REQUEST['record']) && $_REQUEST['record']!='')
$record=$_REQUEST['record'];
$smarty=new lingdangCRM_Smarty;


$approve = Approve::getInstance($fld_module);
$approveinfo=$approve->approveStatus($record);//获取单据的最后一条审批历史记录

if(empty($approveinfo)){
	$_REQUEST['diony']='diony';
	ConvertTojsonString(-1,array(),'approveStatus无返回值!' . $record);
}
$approveid=$approveinfo['approveid'];
$stepid=$approveinfo['nextstepid'];
$laststepid=$approveinfo['stepid'];	//上一步
$countersigner=$approveinfo['nextstep_countersigner'];//即将审批的步骤是否为会签审批（yes,no)
$logconcurrentid=$approveinfo['logconcurrentid'];//并发步骤ID
$approvelogid=$approveinfo['approvelogid'];//审批历史iD
//判断使用新的审批流程或旧的审批流程
$approveinfo_arr = $approve->getApproveInfo($approveid);
$isnewapprove = $approveinfo_arr['isnewapprove'];

//获取审批必填字段对应单html
crm_load_class_file('cls_ApproveMandatoryField','modules/Approve');
$mandatoryfieldobj = cls_ApproveMandatoryField::getInstance($fld_module);
$mandatoryfieldobj->CommonEditFieldobj->setEmptyFieldOnly('no');
$result_arr = $mandatoryfieldobj->CreateFieldHtml($record,$stepid,1);

$smarty->assign('tablehtml',$result_arr['html']);
$arr['mandatory_field_arr'] = $result_arr['field'];
$arr['approvedata'] = $mandatoryfieldobj->getReturnApproveData();
$arr['columnfields_value']=$mandatoryfieldobj->CommonEditFieldobj->focus->column_fields;
$arr['label_arr'] = [];

$arr['isadmin'] = is_admin($current_user)?'yes':'no';
if($isnewapprove == 'yes'){
    require(globalStatic::$root_directory.'modules/Approve/ApproveStepNew.php');
    exit();
}
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
}*/
//判断即将审批的步骤是否为会签,
$countersigner=$approveobj->getisCounterSigner($countersigner,$approveinfo['nextstepapproveby'],$approveinfo['nextstepid']);
$nextapproved_bys=explode(',',$approveinfo['nextstepapproveby']);
if(!in_array($current_user->id,$nextapproved_bys))
{
	$_REQUEST['diony']='diony';
	ConvertTojsonString(-1,array(),getFixedLabel('BILLHAVEAPPROVED'));
}
/*$nextapproved_bys=array_filter($nextapproved_bys);
if($countersigner=='yes'&&sizeof($nextapproved_bys)==1)
{
    //审批步骤是会签且当前步骤审批人只有一个,则不执行会签审批的业务
    $countersigner='no';
}
else
{
    
}*/
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
        $stepname=$adb->query_result($result,0,'name');$curcountersigner=$adb->query_result($result,0,'countersigner');
    
   }else{
        $countersigner = 'no';
   }
    
    $nextstepid=$stepid;
    
}
$smarty->assign('CUR_NEXTSTEPBY',$nextsetpby);
$smarty->assign("approveresult",1);
$nextstep_concurrentid=0;
 $islastconcurrentstep='no';   

if(!empty($logconcurrentid))
{
  
     $islastconcurrentstep=$approve->getisLastStepConcurrent($record,$logconcurrentid,$approveid);

 }

if($countersigner=='no'||$nextsetpby==''||($approveinfo['augmentsinger'] == 'no'&& $countersigner != 'yes')){//非会签审批

        $query="select ld_approve.name,ld_approvestep.id as maxstepid ,ld_approvestep.sequence as  maxsequence
        ,ld_approvestep.countersigner
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
        $step=$adb->query_result($result,0,'step');//是否允许指定审批步骤0：允许，1：否
        $approveremarkrequire = $adb->query_result($result,$i,'approveremarkrequire');//审批意见是否必填
        $augmentsinger=$adb->query_result($result,0,'augmentsinger');	//加签
		if($approveinfo['augmentsinger'] == 'no'){
			$countersigner = 'no';
			if($approveinfo['approvestatus'] == 6)
				$augmentsinger = '';	//同为或签的时候
		}
        //17318: 佣金单>明细：当审批步骤为多步，下一步骤的审批人显示错误，还是显示了当前的审批人。
        //18233: （建议）单据明细界面审批：审批弹出层中：下一步骤的审批人建议默认显示为当前步骤的下一步审批
        //获取下一步审批人
        
        $islastapprovestep='no';
     
        
        if($logconcurrentid>0&&$islastconcurrentstep=='no')
        {
            //如果是并发步骤，且当前步骤不是并发步骤的最后一步
             $query="select approvevalue,approvetype,specifyapproverid,countersigner,augmentsinger,id,concurrentid,approveremarkrequire,emptyapproverdeal
              from ld_approvestep where id=?  ";
             $result=$adb->pquery($query,array($stepid));
        }
        else
        {
            $query="select approvevalue,approvetype,specifyapproverid,countersigner,augmentsinger,id,concurrentid,approveremarkrequire,emptyapproverdeal from ld_approvestep where approveid=?  ";
            
            $sequence=floor($adb->query_result($result,0,'sequence'))+1;
           
            if($sequence<=$maxSequence)
            {
                $query.=" and sequence>=".$sequence. ' order by sequence asc  limit 1';
            }
            else
            {
                $islastapprovestep='yes';
               
            }
            if($islastapprovestep=='yes'){
                $smarty->assign("approveresult",2);//最后一步，代表审批成功
                $query.=" and id=".$maxstepid;
            }
            $result=$adb->pquery($query,array($approveid));
        }
       
      
        
        if($adb->num_rows($result)<=0)
        {
        	$_REQUEST['diony']='diony';
        	ConvertTojsonString(-1,array(),"没有找到合适的审批步骤！");
        }
        $tmpnextstepid=$adb->query_result($result,0,'id');
        $nextstepid=$tmpnextstepid;
        $approvevalue = $adb->query_result($result,0,'approvevalue');//下一步审批人
        $approvetype = $adb->query_result($result,0,'approvetype');//下一步审批人类型（指定用户，指定角色，部门等待)
        $cur_specifyapproverid=$adb->query_result($result,0,'specifyapproverid');//是否允许指定当前步骤审批人(1:否，0：是)
        $nextstep_countersigner=$adb->query_result($result,0,'countersigner');
        $nextstep_concurrentid=$adb->query_result($result,0,'concurrentid');
        //duan 判断当前步骤是否允许审批人为空
        $allow_emptyapprover = $approve->get_allow_emptyapprover($tmpnextstepid,$approvetype);
        /**
         * 当前步骤：允许指定下一步审批人的情况下，再去获取下一步审批人信息
         * @reason 0016110: 审批流程为多步时，当审批步骤中有指定角色时，这时，下一步审批人显示不对
         * @author Tujt 2015-07-10
         */
        $nextsetpby = '';$nextsetpbyuser = '';
        $nextsetpby = $approve->getApproveBy($approvetype,$approvevalue,$record);
        //duan 2022-3-31 单据审批时如果下一步审批人为空，则根据‘审批人为空时处理方式’参数替换审批人信息
        if(empty($nextsetpby) && $approve->get_allow_emptyapprover($tmpnextstepid,$approvetype) == 'yes'){ //如果该类型可以设置对应参数
            $emptyapproverdeal=$adb->query_result($result,0,'emptyapproverdeal');
            $nextsetpby = $approve->getTransferUsers($emptyapproverdeal);
        }
        $nextstep_countersigner=$approve->getisCounterSigner($nextstep_countersigner,$nextsetpby,$tmpnextstepid);
        $nextstepidtoname = array();
        if(!empty($nextsetpby)){
            $ids=explode(',',$nextsetpby);
        
            foreach($ids as $value){
                $tmpusername = getUserFullName($value);
                $nextsetpbyuser .=$tmpusername.",";
                $nextstepidtoname[$value] = $tmpusername;
            }
            /*
             * editor:gyq_05
             * reason:字符串末尾逗号为清除失败
             * date  : 2016 3 2
             * */
            $nextsetpbyuser = rtrim($nextsetpbyuser,',');
            //$nextsetpbyuser=substr($nextsetpbyuser,0,strlen($nextsetpbyuser)-1);//删除最后一个多余的逗号
        }
        
        $nextSteps=array();
      
        if($step){
            $query="select id,name,approvevalue ,specifyapproverid,concurrentid from ld_approvestep where approveid=? and sequence>=? and id<>? order by sequence limit 1";
            $result=$adb->pquery($query,array($approveid,$sequence,$stepid));
            $nextstep_concurrentid=$adb->query_result($result,0,'concurrentid');
            if($adb->num_rows($result)>0)
                $nextSteps[]=array('stepid'=>$adb->query_result($result,0,'id'),
                'stepname'=>$adb->query_result($result,0,'name')
                );
        }
        else{
            //允许指定审批步骤
            $nextstep_concurrentid=0;
            //过滤并发步骤
            $query="select id,name,approvevalue  ,specifyapproverid,concurrentid from ld_approvestep where approveid=? and concurrentid<=0 and id <> ? order by sequence";
            $result=$adb->pquery($query,array($approveid,$stepid));
            $num_rows=$adb->num_rows($result);
            for($i=0;$i<$num_rows;$i++)
            {
                $nextSteps[]=array('stepid'=>$adb->query_result($result,$i,'id'),
                'stepname'=>$adb->query_result($result,$i,'name')
                
                 );
              
            }
            
        }
        $smarty->assign("nextstep_countersigner",$nextstep_countersigner);
        
}else{
	$query="select * from ld_approvestep where approveid=? and id=?";
	$result=$adb->pquery($query,array($approveid,$stepid));
	$approveremarkrequire = $adb->query_result($result,0,'approveremarkrequire');//审批意见是否必填
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



/*
 * editor:gyq_05
 * reason:无论审批人是否可指定都显示审批人信息
 * date:2016 3 2
 * */
//if(0 == $nextspecifyapproverid){//获取下一步审批人
       

//}
//判断当前步骤是否是第一步审批
$prestep_approveby = $approve->getApprovePreStepApproveBy($record);

$nextcheck='';
$endcheck='';

if($stepid==$maxstepid){
    $ended=0;
    $endcheck='checked';
   
}//最后一步可以结束流程

else{
    $nextcheck='checked';
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
    
 }
$counter_augmentsinger = 'no';
$_REQUEST['diony']='diony';

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
//审批界面的审批日志显示，暂时注释掉
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

    if($nextstep_concurrentid>0)
    {
        //获取下一步的并发步骤列表
        //edit:can 2021-02-22 44671: （http://82.156.63.48:8445/crm/ [^] ）客户大平恒-申请审批-开票申请-ZDYBD09-2-审批日志-第9步中林佳杨不满足审批流程中设置的条件，却流转至了该成员
        $sql='select * from ld_approvestep where approveid=? and concurrentid=? order by sequence asc ';
        $result=$adb->pquery($sql,array($approveid, $nextstep_concurrentid));
        $rows=$adb->num_rows($result);
        $concurrentidStep_arr=[];
       $userObj=new Users();
        for($i=0;$i<$rows;$i++)
        {
            $tmp_stepid=$adb->query_result($result,$i,'id');
            $tmp_stepname=$adb->query_result($result,$i,'name');
            $specifyapproverid=$adb->query_result($result,$i,'specifyapproverid');//是否允许修改本步骤审批人（0：允许）
            $approvevalue=$adb->query_result($result,$i,'approvevalue');
            $approvetype=$adb->query_result($result,$i,'approvetype');
            $countersigner=$adb->query_result($result,$i,'countersigner');
            $augmentsinger=$adb->query_result($result,$i,'augmentsinger');
            
            
            $approveobj=new Approve();
            $allow_emptyapprover = $approveobj->get_allow_emptyapprover($tmp_stepid,$approvetype);
            $approvebyids= $approveobj->getApproveBy($approvetype,$approvevalue,$record);
            //duan 2022-3-31 单据审批时如果下一步审批人为空，则根据‘审批人为空时处理方式’参数替换审批人信息
            if(empty($approvebyids) && $approve->get_allow_emptyapprover($tmp_stepid,$approvetype) == 'yes'){ //如果该类型可以设置对应参数
            	$emptyapproverdeal=$adb->query_result($result,$i,'emptyapproverdeal');
            	$approvebyids = $approve->getTransferUsers($emptyapproverdeal);
            }
           $sqluser='select wx_userid,last_name,id from ld_users where id in('.$approvebyids.') ';
            $user_result=$adb->pquery($sqluser,array());
            $user_rows=$adb->num_rows($user_result);
            $userobj_arr=[];
            $stepuseridtonamearr = array();
            for($j=0;$j<$user_rows;$j++)
            {
                
                $userObj->last_name=$adb->query_result($user_result,$j,'last_name');
                $userObj->id=$adb->query_result($user_result,$j,'id');
                $userObj->wx_userid=$adb->query_result($user_result,$j,'wx_userid');
                $tmpusername = getUserlastName($userObj);
                $userobj_arr[]=$tmpusername;
                $stepuseridtonamearr[$userObj->id] = $tmpusername;
                
            }
            
            $concurrentidStep_arr[]=array('stepid'=>$tmp_stepid,'stepname'=>$tmp_stepname,
                                            'specifyapproverid'=>$specifyapproverid,'augmentsinger'=>$augmentsinger,
                                            'countersigner'=>$countersigner,'approvebyid'=>$approvebyids,
                                            'approvebyname'=>implode(",",$userobj_arr),'stepuseridtonamearr'=>$stepuseridtonamearr,
                                            'allow_emptyapprover'=>$allow_emptyapprover);
        }
          
    }
  
    /* if($approveinfo['augmentsinger']=='yes'&&($approveinfo['nextstep_countersigner']=='yes'||$approveinfo['countersigner']=='yes'))
     {
        
        $smarty->assign("augmentsinger",'');
     }*/

     if($approve->getIsaugmentsinger($approveinfo['approveresult'],$approveinfo['approvelogid'],$record,$approveinfo['nextstepid'],$approveinfo['stepid'])=='yes')
   {
        //代表已加签过
    
        $smarty->assign("augmentsinger",'');
   }
   
        if($islastapprovestep=='yes'&&$logconcurrentid>0)
        {
              if($nextstepid==$maxstepid)
              {
                //edit:can 2021-03-02 44789: （61mis.com/kfbcrm）并发审批；供应商联系记录，单据编号GYSLXJL17，并发审批中会签的最后一步，审批时异常，详情请看附图
                $smarty->assign("ENDED",0);
                $smarty->assign("LastStepForApprove",'yes');//审批流程的最后一步
              }  
        }
        
        if($ended==1){
            //edit:can 51057 （https://www.cubenergy.com.cn/crm）客户问题（库博能源），合同订单（合同编号：HT279）审批，审批日志中没有显示审批结果，审批状态更改为了未提交 
            //edit:duan 2022-5-10 审批流程中倒数第二步审批步骤，虽然没有设置可以结束审批流程，但是有审批流程的选项，将此处的sequence>改为>=
		 $sql='select  1 from ld_approvestep where approveid=? and sequence>=?';
		 $tmpresult=$adb->pquery($sql,array($approveid,$sequence));
		 if($adb->num_rows($tmpresult)<=0)
		 {
			 //最后一部
			 $smarty->assign("ENDCHECK",'checked');
			 $smarty->assign("ENDED",'0');
		 }
	 }
    
    $smarty->assign('nextstep_concurrentid',$nextstep_concurrentid);
    $smarty->assign('concurrentidStep_arr',$concurrentidStep_arr);
    
    $str=$smarty->fetch("Approve/ApproveStep.tpl");
}
$arr['content']=$str;
ConvertTojsonString(1,$arr,"success");
?>