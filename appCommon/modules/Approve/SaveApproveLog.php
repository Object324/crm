<?php


//提交审批
$record=$_REQUEST['record'];
$approvelog = array();
$approvelog['crmid'] = $_REQUEST['record'];//数据ID
$approvelog['approveid'] = $_REQUEST['approveid'];//当前审批步骤ID

$approvelog['stepid'] = $_REQUEST['stepid'];//下拉框选择的步骤id
$approvelog['nextstepid'] = $_REQUEST['nextstep_0'];//下拉框选择的步骤id
$approvelog['approved_by'] = $current_user->id;//当前审批人
$approvelog['approveresult'] = $_REQUEST['approvestatus'];//当前审批类型（通过、驳回等）
$approvelog['description'] = $_REQUEST['description'];//备注
$approvelog['logconcurrentid']=$_REQUEST['logconcurrentid'];//审批历史并发步骤id
$approvelog['approvelogid']=$_REQUEST['approvelogid'];//审批历史并发步骤id

if(empty($approvelog['approveid'])){
    ConvertTojsonString(-1,array(),'参数错误:Approveid');
}
if(empty($approvelog['approveresult'])){
    ConvertTojsonString(-1,array(),'参数错误:Approveresult');
}
//editor:gyq_20191120 reason:增加$frommodule
$frommodule = $_REQUEST['fld_module'];
$approveinfo=$approve->getlastapproveinfo($record,$frommodule);
$issave='yes';
$approveid=$approvelog['approveid'];

if($_REQUEST['approvestatus']==1||$_REQUEST['approvestatus']==2)
{
    $islastconcurrentstep='no';
  
    if($_REQUEST['concurrentid']>0)
    {
        //表示进入了并发步骤
        
       $approvestepinfo_arr[$approvelog['approveid']]= $approve->getAllStepInfoByApproveid($approvelog['approveid']);
      
       $alltotalCount=sizeof($approvestepinfo_arr[$approvelog['approveid']]);
       $concurrentidStepCount=0;
       $i=-1;
       foreach($approvestepinfo_arr[$approvelog['approveid']] as $tmpstepinfo)
       {
            $tmpconcurrentid= $tmpstepinfo['concurrentid'];
            $i++;
            if($tmpconcurrentid!=$_REQUEST['concurrentid'])
                continue;
                
             $_REQUEST['nextstep_'.$concurrentidStepCount]=$approvestepinfo_arr[$approveid][$i]['stepid'];
                   
            $_REQUEST['countersigner_'.$concurrentidStepCount]=$approvestepinfo_arr[$approveid][$i]['countersigner'];//$adb->query_result($tmpresult,$i,'countersigner');
            $_REQUEST['nextstep_countersigner_'.$concurrentidStepCount]=$approvestepinfo_arr[$approveid][$i]['countersigner'];
            $_REQUEST["stepseq_$concurrentidStepCount"]=$concurrentidStepCount;
            $approvetype=$approvestepinfo_arr[$approveid][$i]['approvetype'];//$adb->query_result($tmpresult,$i,'approvetype');
            $approvevalue=$approvestepinfo_arr[$approveid][$i]['approvevalue'];//$adb->query_result($tmpresult,$i,'approvevalue');
            
            $_REQUEST["userid_$concurrentidStepCount"]=$approve->getApproveBy($approvetype,$approvevalue,$record);
            $_REQUEST["nextstep_augmentsinger_$concurrentidStepCount"]=$approvestepinfo_arr[$approveid][$i]['augmentsinger'];//$adb->query_result($tmpresult,$i,'augmentsinger');;
            $concurrentidStepCount++;
       }
       $_REQUEST['concurrentidStepCount']=$concurrentidStepCount;
    }
    else if($_REQUEST['logconcurrentid']>0)
    {
        $approvelog['logconcurrentid']=$_REQUEST['logconcurrentid'];
        $islastconcurrentstep=$approve->getisLastStepConcurrent($record,$_REQUEST['logconcurrentid'],$approvelog['approveid']);
        $logconcurrentid=$_REQUEST['logconcurrentid'];
    }
     
   $approveid=$approvelog['approveid'];
   $crmid=$record;
   
    $lastapproveinfo=$approve->getlastapproveinfo($record,$module);
    if($islastconcurrentstep=='yes')
    {
           global $approvestepinfo_arr;
            //是并发步骤的最后的步骤或者下一个步骤
            if(!array_key_exists($approveid,$approvestepinfo_arr))
            {

                $approvestepinfo_arr[$approveid]=$approve->getAllStepInfoByApproveid($approveid);
                
            }
            foreach($approvestepinfo_arr[$approveid] as $tmpstepInfo)
            {
                //edit:can 49477: （http://124.225.200.21:85/crm [^] ）（海南爱恩）付款单FKD20211227-690使用流程：付款单选人审批流程审批时，三级审批后直接走五级审批跳过了四级，且四级审批的审批人变成了五级审批人
                if($tmpstepInfo['stepid']==$approvelog['stepid'])
                {
                    $sequence=floor($tmpstepInfo['sequence'])+1;
                    break;
                }
            }
          
            foreach($approvestepinfo_arr[$approveid] as $tmpstepInfo)
            {
                if($sequence>=1&&$tmpstepInfo['sequence']>=$sequence)
                {
                    //获取下一步审批步骤信息
                    $concurrentid=$tmpstepInfo['concurrentid'];
                       
                         
                    
                    if($concurrentid>0&&$_REQUEST['concurrentid']<=0)
                    {
                        $concurrentidStepCount=0;//并发的审批步骤个数
                        //下一步也是并发步骤
                        foreach($approvestepinfo_arr[$approveid] as $tmpstepInfo)
                        {
                            if($tmpstepInfo['concurrentid']==$concurrentid)
                            {
                                $approvetype=$tmpstepInfo['approvetype'];
                                $approvevalue=$tmpstepInfo['approvevalue'];
                                $stepuserid=$approve->getApproveBy($approvetype,$approvevalue,$crmid);
                                $_REQUEST['userid_'.$concurrentidStepCount]=$stepuserid;
                                $_REQUEST['nextstep_countersigner_'.$concurrentidStepCount]=$tmpstepInfo['countersigner'];
                                $_REQUEST['nextstep_augmentsinger_'.$concurrentidStepCount]=$tmpstepInfo['augmentsinger'];
                                $_REQUEST['stepseq_'.$concurrentidStepCount]=$concurrentidStepCount;
                                $_REQUEST['nextstep_'.$concurrentidStepCount]=$tmpstepInfo['stepid'];
                                $concurrentidStepCount++;
                            }
                        }
                        $_REQUEST['concurrentidStepCount']=$concurrentidStepCount;
                       
                    }
                    else if($logconcurrentid>0){
                          
                            //已经判断是并发步骤最后一步了
                        //并发步骤的第一个步骤，最后审批，需要重新获取nextstepid;
                        if($tmpstepInfo['stepid']>0)//大于零，是判断是否为审批流程的最后一步
                        {
                         
                           
                            $approvelog['nextstepid']=$tmpstepInfo['stepid'];
                            $nextstep_countersigner=$tmpstepInfo['countersigner'];
                        }
                        
                        
                    }
                    break;
                }
            }

    }

    if($lastapproveinfo['approveresult']==2 || $lastapproveinfo['approveresult']==13)
    {
        //approveresult 13；单据从审批结束编辑后到未提交时，不应该有反审批操作(PC端和手机端同时操作会出现这种情况)
        //35744: （1.6）单据明细界面>审批：当多个页面同时审批时会导致生成多条审批历史。
        $issave='no';//已经审批
      
    }
    else if($lastapproveinfo['approveresult']==1)
    {
        $lastcreatedtime=$lastapproveinfo['createdtime'];
       $seconds= DateOperation::sencods_between_time(date("Y-m-d H:i:s"),$lastcreatedtime);
        
        //审批中
        //35744: （1.6）单据明细界面>审批：当多个页面同时审批时会导致生成多条审批历史。
        //abs($seconds)<=10&&
        if( $lastapproveinfo['stepid']==$_REQUEST['stepid']&&$approveinfo['approved_by']==$current_user->id)
        {
            $issave='no';
            
        }
    }
    
}

if($issave=='no')
{
    ConvertTojsonString('error_load',array(),getFixedLabel("Approvestephavechangetip"));
}


//通过进入下一步
if($approvestatus==1 && empty($approvelog['stepid'])){
    $nextstepid=$_REQUEST['stepid'];
    $query="select approvetype,approvevalue from ld_approvestep where approveid=? and id=?";
    $result=$adb->pquery($query,array($approvelog['approveid'],$nextstepid));
    $approvetype=$adb->query_result($result,0,'approvetype');
    $approvevalue=$adb->query_result($result,0,'approvevalue');
    //$approveby=$approve->getApproveBy($approvetype,$approvevalue).',';//下一步审批人
    //审批时间相同有问题
    if($approvelog['logconcurrentid']>0)
        $sql='select nextstepid from ld_approvelog where crmid='.$approvelog['crmid'].' and isfinished="no"  order by ld_approvelog.stepseq asc, ld_approvelog.createdtime DESC, id desc limit 1';
    else
        $sql='select nextstepid from ld_approvelog where crmid='.$approvelog['crmid'].'  order by  ld_approvelog.createdtime DESC, id desc limit 1';
    $nextapproveresult=$adb->pquery($sql,array());//获取当前步骤id
    if($adb->num_rows($nextapproveresult)>0)
    {
        $stepid=$adb->query_result($nextapproveresult,0,0);
        
    }
    $approvelog['stepid']=$stepid;
   
}
$stepid = $_REQUEST['stepid'];
if($approvestatus==2&&empty($stepid))//审核成功结束流程,apple没有传stepid
{
    $sql='select nextstepid from ld_approvelog where crmid='.$approvelog['crmid'].' order by seqtime desc, createdtime desc limit 1';
    $nextapproveresult=$adb->pquery($sql,array());
    if($adb->num_rows($nextapproveresult)>0)
    {
        $stepid=$adb->query_result($nextapproveresult,0,0);
        
    }
    $approvelog['stepid']=$stepid;
}

//修改操作，by andrew,修正费用报销审批状态不正确，添加break,20140102
if(!empty($_REQUEST['userid_0']) && !empty($approvelog['nextstepid'])){//指定下一步审批人
	$userids = $_REQUEST['userid_0'];//查询是否有审批委托
	$query = 'select distinct case when approvestatus=0 then approveby else id end as userid 
				from ld_users where id in ('.$userids.') order by userid;';
    $result = $adb->pquery($query,array());
    $num_rows=$adb->num_rows($result);
    for($i=0;$i<$num_rows;$i++){
        $approveby .= $adb->query_result($result,$i,'userid').",";
    }

    //echo $approveby;die;
	$approveby = trim($approveby,',');
    //if(empty($approveby)) ConvertTojsonString(-1,array(),'下一步审批人不能为空');
	$approvelog['nextstepapproveby'] = $approveby;
}

if(6 == $approvestatus){ //加签
    $query='select nextstepapproveby ,approveresult,logconcurrentid
        ,approved_by,ld_approvelog.countersigner,ld_approvelog.nextstep_countersigner from ld_approvelog where crmid=? and approved_by != -1 
        ORDER BY ld_approvelog.createdtime DESC,ld_approvelog.id desc limit 1 ';
    $result=$adb->pquery($query,array($_REQUEST['record']));
    if($adb->num_rows($result)>0){
        $countersigner = $adb->query_result($result,0,'countersigner');
        $old_approveby = $adb->query_result($result,0,'nextstepapproveby');
        $nextstep_countersigner = $adb->query_result($result,0,'nextstep_countersigner');
        $logconcurrentid = $adb->query_result($result,0,'logconcurrentid');

        $approvelog['nextstepid'] = $approvelog['stepid'];
        //会签中加签

        if($countersigner == 'yes' && !empty($old_approveby) && $logconcurrentid == 0){
            $new_approveby_arr = explode(',',$approvelog['nextstepapproveby']);
            $old_approveby_arr = explode(',',$old_approveby);
            $new_arr = [];
            foreach ($old_approveby_arr as $tmp_id){
                if($tmp_id == $current_user->id){
                    continue;
                }
                $new_arr[] = $tmp_id;
            }
            foreach ($new_approveby_arr as $tmp_id){
                $new_arr[] = $tmp_id;
            }
            $approvelog['nextstepapproveby'] = implode(',',array_unique($new_arr));
            $approvelog['augmentsinger'] = $nextstep_countersigner;
            $approvelog['countersigner'] = $approvelog['augmentsinger'];
        }
    }
}
//不通过，返回到上一步
if($approvestatus == 5){

   //edit:can 2021-01-12 44192: （企业微信移动端-kfbcrm）加签审批；待审批-销售机会，单据编号 POT70 ；流程“销售机会加签；加签人驳回至上一步后，当前步骤也操作驳回，但无法驳回成功
       $query='SELECT logconcurrentid, GROUP_CONCAT(stepid order by id) as stepid ,nextstepid,nextstepapproveby ,GROUP_CONCAT(approveresult order by id) as approveresult
            ,approved_by,ld_approvelog.countersigner,ld_approvelog.augmentsinger from ld_approvelog where crmid=? 
            and ld_approvelog.approved_by>0
            GROUP BY IF(logconcurrentid>0,logconcurrentid,id)
            ORDER BY ld_approvelog.createdtime DESC,ld_approvelog.id desc ';
            $result=$adb->pquery($query,array($_REQUEST['record']));
            
        	$num_rows=$adb->num_rows($result);
          //edit:can 2021-03-25 45147: （企业微信移动端-kfbcrm）跟进记录，已审批单据编号LXJL587，成员ASD，操作驳回（反审批）单据异常
	       	$tmprowindex=$approve->getBackStepLogIndex($result);
            if($adb->num_rows($result)>0)
            { 
                $nextstepid=$adb->query_result($result,$tmprowindex,'nextstepid');
                $nextstep = $adb->query_result($result,$tmprowindex,'stepid');//需要回撤或者返回的上一个审批步骤
                if($adb->query_result($result,$tmprowindex,'logconcurrentid')>0){
                    $nextstep = explode(',',$nextstep)[0];//并发步骤在group by后stepid会至少有两个，读第一个
                }
                
                if($nextstep==-1)
                {
                    $isreject=1;
                }
                $nextstepapproveby=$adb->query_result($result,$tmprowindex,'approved_by');
                $augmentsinger = $adb->query_result($result,$tmprowindex,'augmentsinger');
            }
            else
            {
                $isreject=1;
                $augmentsinger='no';
                $nextstep='-1';
            }
			
			$approvelog['nextstepid'] = $nextstep;

	        if($nextstep>0)
            {
                //进入的是并发步骤
                global $approvestepinfo_arr;
                if(!is_array($approvestepinfo_arr))
                {
                    $approvestepinfo_arr=[];
                }
                $approvestepinfo_arr[$approveid]= $approve->getAllStepInfoByApproveid($approveid);
                $tmprows=sizeof($approvestepinfo_arr[$approveid]);
                $concurrentidStepCount=0;
                for($i=0;$i<$tmprows;$i++)
                {
                    if($approvestepinfo_arr[$approveid][$i]['stepid']==$nextstep)
                    {
                        $tmpconcurrentid=$approvestepinfo_arr[$approveid][$i]['concurrentid'];
                        break;
                    }
                }

                for($i=0;$i<$tmprows;$i++)
                {
                   
                    if(empty($tmpconcurrentid))
                    {
                        break;
                    }
                        
                    
                    if($tmpconcurrentid>0&&$approvestepinfo_arr[$approveid][$i]['concurrentid']==$tmpconcurrentid)
                    {
                        $_REQUEST['nextstep_'.$concurrentidStepCount]=$approvestepinfo_arr[$approveid][$i]['stepid'];
                       
                        $_REQUEST['countersigner_'.$concurrentidStepCount]=$approvestepinfo_arr[$approveid][$i]['countersigner'];//$adb->query_result($tmpresult,$i,'countersigner');
                        $_REQUEST["stepseq_$concurrentidStepCount"]=$concurrentidStepCount;
                        $approvetype=$approvestepinfo_arr[$approveid][$i]['approvetype'];//$adb->query_result($tmpresult,$i,'approvetype');
                        $approvevalue=$approvestepinfo_arr[$approveid][$i]['approvevalue'];//$adb->query_result($tmpresult,$i,'approvevalue');
                        
                        $_REQUEST["userid_$concurrentidStepCount"]=$approve->getApproveBy($approvetype,$approvevalue,$record);
                        $_REQUEST["nextstep_augmentsinger_$concurrentidStepCount"]=$approvestepinfo_arr[$approveid][$i]['augmentsinger'];//$adb->query_result($tmpresult,$i,'augmentsinger');;
                        $concurrentidStepCount++;
                    }
                }
                
                $_REQUEST['concurrentidStepCount']=$concurrentidStepCount;
            }
      		
			$approvelog['approved_by'] =  $current_user->id;
			$approvelog['nextstepapproveby'] = $nextstepapproveby;
		
		$approvelog['stepid'] = $_REQUEST['stepid'];	//上一步审批步骤id
		$approvelog['approvedeal'] = 'backlaststep';
       
}

if($approvestatus==4)
{
    //edit:can 2021-03-04 44798: （kfbcrm，企业微信移动端）审批中心，单据驳回选择【不通过，返回负责人】后，单据查看详情界面，【驳回】按钮应该显示【重新提交】按钮（企业微信操作）
    $approvelog['nextstepid']='';
    $approvelog['nextstepapproveby']='';
}
if($approvestatus==2)
{
    //edit:can 2021-03-26 0045167: （企业微信小程序-kfbcrm）待办-跟进记录审批；单据编号LXJL598，审批流程“跟进记录提前结束”；二级审批时操作审批“审批成功，结束流程”，但审批日志仍显示下一审批步骤
    $approvelog['nextstepid']='';
    $approvelog['nextstepapproveby']='';
    $_REQUEST['concurrentidStepCount']=0;
}
if($approvestatus==3)
{
  
    //edit:can 20220627 https://61mis.com/WX/kh46733/）PC端审批中新显示3个待审批，但点进去没有数据，审批失败的单据不应该有nextstepid值
    $approvelog['nextstepid']='';
    $approvelog['nextstepapproveby']='';
    unset($_REQUEST['nextstepid']);
    
}

$stepinfo = $approve->SaveApprovedLog($_REQUEST['fld_module'],$approvelog);
$arr = [];
if (isset($stepinfo['workflow'])) {
    //检查是否有API调用
    crm_load_class_file("cls_savereverse",'include/SaveReverse');
    $workflowreverseobj = cls_savereverse::getInstance($_REQUEST['fld_module']);
    $receive_msg = $workflowreverseobj->checkCallApiPop();
    $arr['workflow']['receive_msg'] = $receive_msg;
    if ($receive_msg == 'yes') {
        $arr['workflow']['record'] = $record;
        $arr['workflow']['module'] = $_REQUEST['fld_module'];
        $arr['workflow']['pagemode'] = $workflowreverseobj->getPageMode();

        $arr['workflow']['before_save_infos'] = $stepinfo['workflow']['before_save_infos'];
        $arr['workflow']['after_save_infos'] = $stepinfo['workflow']['after_save_infos'];
    }
}

/*
$query=$approve->jsongetApproveQueryByReocrd($record);

$list_result=$adb->pquery($query);
$approvedata=array();
$num_rows=$adb->num_rows($list_result);
//获取该单据的审批信息
//$approve=new jsonApprove();
$approveinfo=$approve->approveStatus($record);
$approvestatus=$approveinfo['approvestatus'];
$sql="select smownerid from $tabname  where $moduleid=$record";

$smresult=$adb->pquery($sql);
$smownerid=$adb->query_result($smresult,0,0);
$blockbuttons=$approve->blocksButton($smownerid,$record);
$isapprove=$blockbuttons[2];
if($isapprove==1)
{
    $approveresult="1";
}
else
{
    $approveresult="2";
}
for($i=0;$i<$num_rows;$i++)
{
  $crmid=$adb->query_result($list_result,$i,'crmid');
   $num=$adb->query_result($list_result,$i,'num');
   
   if($adb->query_result($list_result,$i,'module')=='Expense'||$adb->query_result($list_result,$i,'module')=='SalesOrder')
   {
     $accountname=$adb->query_result($list_result,$i,'accountname');
     $stra=$num;
     if(!empty($accountname))
     {
        $stra.='('.$accountname.')';
        
     }
     $strb=$adb->query_result($list_result,$i,'createdtime');
     $strc=$adb->query_result($list_result,$i,'moneyfield');
     if(is_null($strc)||$strc==null)
     {
         $strc='';
     }
    
     $strd=$adb->query_result($list_result,$i,'smownername');
      $approvedata['list'][]=array(
       'curid'=>$crmid,
       'modulename'=>$adb->query_result($list_result,$i,'module'),
       'moduletitle'=>getTranstab($adb->query_result($list_result,$i,'module')),
       'A'=>$stra,
       'B'=>$strb,
       'C'=>$strc,
       'D'=>$strd,
       'E'=>$approveresult,
     
       );
   }
   else
   {
         $approvedata['list'][]=array(
       'curid'=>$crmid,
       'modulename'=>$adb->query_result($list_result,$i,'module'),
       'moduletitle'=>getTranstab($adb->query_result($list_result,$i,'module')),
       'A'=>$adb->query_result($list_result,$i,'accountname'),
       'B'=>$num,
       'C'=>$adb->query_result($list_result,$i,'createdtime'),
       'D'=>$adb->query_result($list_result,$i,'smownername'),
       'E'=>$approveresult,
     
       );
   }
}*/
ConvertTojsonString(1,$arr,'');

?>
