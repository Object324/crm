<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @project PROT144 审批功能改进
 * @author Tujt 2014-12-30
 */
global $adb,$current_user;

if(!class_exists('Approve'))
	require('./modules/Approve/Approve.php');
crm_load_class_file("ApproveCommon","modules/Approve");
$approve = new Approve();
$fld_module = $_REQUEST['fld_module'];//模块名
$focus=CRMEntity::getInstance($fld_module);
$record = $_REQUEST['record'];//数据ID
$setype = $_REQUEST['setype'];//类型，info:获取
$iscancel = $_REQUEST['iscancel'];
$approveStatus='';//当前审批流程是否被删除
global $selectapprovecrmid_len;
$selectapprovecrmid_len=1;
if('info' == $setype){//获取反审批页面信息
	$smarty = new lingdangCRM_Smarty;
	$tabid = getTabid($fld_module);
    $username = $current_user->user_name;
    if($current_user->is_admin=='on')
    {
        $smarty->assign("ISADMIN",'yes');
    }
    else
    {
        $smarty->assign("ISADMIN",'no');
    }
	if($tabid == 16)$tabid = 9;
	$approves = $approve->submitApprove($tabid);
    
    $autopass_result_arr = array(10,14,18);
    $focus->retrieve_entity_info($record,$fld_module);
    $now_approvestatus = $focus->column_fields['approvestatus'];

    if($now_approvestatus == D_A_S_APPROVED){
        //@edit:zkt @date:2024/12/20 @reason: XUQIU20240821-02   --- 系统参数，设置预收单核销后不允许反审批
        if($fld_module == 'CashBill'){
            $sys_493 = getSys_deploy(493);//系统参数，设置预收单核销后不允许反审批
            $Iscancelunapproved = $sys_493['deploy_value'];
            if($Iscancelunapproved == 'yes'&&isset($focus->column_fields['cashtype'])&&$focus->column_fields['cashtype']=='debuction'){
                // 预收单、已批准、有反审批按钮时进一步判断是否 存在不为零的已核销信息
                $DebuctionInfo_arr = $focus->getDebuctionInfoByDebuctionid($record);
                if(isset($DebuctionInfo_arr['not_0_count'])&&is_numeric($DebuctionInfo_arr['not_0_count'])&&(int)$DebuctionInfo_arr['not_0_count']>0){
                    ConvertTojsonString(-1,array(),getFixedLabel('ADVANCERECEIPTWRITTENOFFCANNOTUNAPPROVED'));
                }
            }
        }
    }
    $smarty->assign('NOWAPPROVESTATUS',$now_approvestatus);
	$smarty->assign('APPROVE',$approves); 
	$smarty->assign('RECORD',$record);
	$smarty->assign('BLOCK',$fld_module);
    $smarty->assign('USERNAME',$username);
    //duan 20221110 审批流程的最后一步并发步骤且自动跳过时，特殊处理
    $wheresql = 'and (approveresult not in ('.implode(',',$autopass_result_arr).') or  ifnull(logconcurrentid,0) =0)';
    
    //获取当前步骤的审批
    $sql='select approveid,logconcurrentid,nextstepid from ld_approvelog where crmid=? '.$wheresql.'  order by id desc limit 1';
    $result=$adb->pquery($sql,array($record));
    if($adb->num_rows($result)>0)
   {
     $approveid=$adb->query_result($result,0,'approveid');
     $nextstepid = $adb->query_result($result,0,'nextstepid');
     if($nextstepid != "")
     {
        $approveinfo = $approve->getStepInfo($nextstepid);
        $smarty->assign("APPROVEREMARKREQUIRE",$approveinfo['approveremarkrequire']);
     }
     $smarty->assign("curapproveid",$approveid);
     $smarty->assign("logconcurrentid",$adb->query_result($result,0,'logconcurrentid'));
   }
    
    
    $sql = 'select * from ld_approve where tabid = ? and status = ?';
    $result = $adb->pquery($sql,array($tabid,0));
    //反审批，判断当前模块是否有其他可用审批流程，不需要判断当前用户是否有审批流程权限
    if($adb->num_rows($result)<1)
    //if($approve=='')
    {
        //0018645: 销售发票>明细：反审批弹出层，使用新的流程重新流转时，当审批流程为空时，点击【保存】按钮，应该给出提示信息。
        $approveStatus='NOAPPROVE' ;
    }
    else
    {
        $query = 'SELECT approveid,stepid FROM ld_approvelog  WHERE crmid = ?
				AND ld_approvelog.id > 0 ORDER BY ld_approvelog.seqtime DESC limit 1;';
    	$result = $adb->pquery($query,array($record));
    	$rows = $adb->num_rows($result);
        
    	if(1 == $rows){
    		$approveid = $adb->query_result($result,0,'approveid');//当前审批流程
    		//$stepid = $adb->query_result($result,0,'stepid');//当前审批流程
    		//判断当前审批是否存在
    		$approve_query = 'select status,name from ld_approve where id = ?';
    		$approve_result = $adb->pquery($approve_query,array($approveid));
           
    		if($adb->num_rows($approve_result) < 1){//审批流程被删除
    		    if($username == 'admin'){//用户为管理员，提示使用新的审批流程
    		        $approveStatus = 'Delete';
    		    }else{
    		        $approveStatus = 'NONE_APPROVE';
    		    }
    		}
            else
            {
                 $curprocessname=$adb->query_result($approve_result,0,'name');
                 
                 if($adb->query_result($approve_result,0,0) ){//审批流程被禁用
                    $approveStatus = 'NONE_APPROVE';
                }
                $smarty->assign("curprocessname",$curprocessname);
            }
            
    		$smarty->assign('APPROVEID',$approveid);
    	}
        else
        {
            //无审批历史，收款单，出库单的历史数据都为已审核
            $approveStatus = 'NONE_APPROVE';
        }
    }
    //读取审批日志进行显示
    //$ApprovelogSetInfo = $approve->getApprovelogSet($record);
//    //审批界面的审批日志只显示最近一次审批的日志
//    $ApprovelogSetInfo['showcurrentapprove'] = 'yes';
//    $WholeApproveLog = $approve->getWholeApproveLog($record,$ApprovelogSetInfo);
//    if(!empty($WholeApproveLog)){
//		$smarty->assign('WholeApproveLog',$WholeApproveLog);
//        $smarty->assign('RECORD',$record);
//        $smarty->assign('MODULENAME',$fld_module);
//        $smarty->assign("noapprovesetting",'yes');
//        $smarty->assign("pre_hidden_btn",'yes');
//        $smarty->assign("next_hidden_btn",'yes');
//        
//		global $global_regop;
//		if(!isset($global_regop))
//			$global_regop=RegOp::getInstance();
//		$smarty->assign('AUTOGRAPH',$global_regop->gethandleWriteSign_interface());
//	}
	//反审批判断条件
	crm_load_class_file("cls_ApproveCancel","modules/Approve");
	$cls_ApproveCancel = new cls_ApproveCancel($fld_module,$approveid);
	if($cls_ApproveCancel->get($record) == 'no'){
		$approveStatus = 'error';
	}
	//反审批权限
    crm_load_class_file('cls_ApproveInfo','modules/Approve');
    $ApproveInfoObj=new cls_ApproveInfo($approve);
    $havecancelprofile = $ApproveInfoObj->CheckCancelApproveProfile($fld_module,$current_user);

    $smarty->assign('HAVECANCELPROFILE',$havecancelprofile);
	$smarty->assign('APPROVESTATUS',$approveStatus);
	$_REQUEST['diony']='diony';
	$arr['title']=getFixedLabel("APPROVE_ANTIAPPROVAL");
	$arr['oktext']=getFixedLabel("SAVE");
	$arr['canceltext']=getFixedLabel("CANCEL");
	$str=$smarty->fetch("Approve/cancelApprove.tpl");
	$arr['content']=$str;
	$arr['approveerror'] = $approveStatus;
	ConvertTojsonString(1,$arr,"success");
}
else if('cancel' == $setype){//执行反审批操作
	$canceltype = $_REQUEST['canceltype'];
	$antiapproval = $_REQUEST['description'];
    
    $approvecommonobj = ApproveCommon::getInstance($fld_module);
    
    $smowneridcolumnname=$focus->getSmownerColumName();
    $maintablename=$focus->table_name;
    $maintable_index=$focus->table_index;
    // dump($smowneridcolumnname);
    if($canceltype==0)
    {
        $query = "SELECT approveid,stepid,nextstepid,nextstepapproveby,approveresult,approved_by,$smowneridcolumnname as smowner
						FROM ld_approvelog inner join $maintablename on $maintablename.$maintable_index=ld_approvelog.crmid
                        
                         WHERE ld_approvelog.crmid = ? AND ld_approvelog.id > 0 and ld_approvelog.approved_by>0
                          ORDER BY ld_approvelog.createdtime DESC;";
        $result = $adb->pquery($query,array($record));
        $rows = $adb->num_rows($result);
        $approveid = $adb->query_result($result,0,'approveid');//当前审批流程
        $nextstepid = $adb->query_result($result,0,'nextstepid');//当前审批步骤
      
    	if(empty($nextstepid))
        {
		   $approveresult = $adb->query_result($result,0,'approveresult');//当前审批状态
	       if(3 == $approveresult){//审批失败
    						$nextstepid = $adb->query_result($result,1,'nextstepid');//上一步下次审批步骤
	           }else if(2 == $approveresult){//审批成功
    						$nextstepid = $adb->query_result($result,1,'nextstepid');//上一步下次审批步骤
				}//已驳回状态下无法反审批，不会走到这里，没有其余可能性
	       if(!empty($nextstepid)) 
            {
                $sql='select * from ld_approvestep  where id=?';
                $tmpresult=$adb->pquery($sql,array($nextstepid));
                 if($adb->num_rows($tmpresult)<=0)
                 {
                    $canceltype=3;//032998: 单据明细界面--单据审批成功后，把该审批流程的最后一步审批步骤删除或者删除审批流程，再反审批单据回撤到上一步，此时单据审批状态返回为原始状态为“已驳回”
                 }               
            }
    	}
    }
  
	switch($canceltype){
	    case '0'://回撤到上一步
			//chj 2021/9/17 or (ld_approvelog.approved_by = -1 and ld_approvelog.approveresult = 1)   中孚：直接跳过到下一步审批步骤时，审批后，然后反审批，无法获取到上一步的审批人
            $query="select ld_approvelog.id ,logconcurrentid, approveid,stepid,nextstepid,nextstepapproveby,approveresult,approved_by ,$smowneridcolumnname as smowner,countersigner,augmentsinger 
						FROM ld_approvelog inner join $maintablename on $maintablename.$maintable_index=ld_approvelog.crmid
            WHERE ld_approvelog.crmid = ?  and  ld_approvelog.id > 0 and approveresult <> 18  and (ld_approvelog.approved_by>0 or (ld_approvelog.approved_by = -1 and ld_approvelog.approveresult = 1)) ORDER BY ld_approvelog.seqtime desc,ld_approvelog.stepseq DESC";
			$result = $adb->pquery($query,array($record));
          
			$rows = $adb->num_rows($result);
            $smownerid=$adb->query_result($result,0,'smowner');//当前单据的审批人
            $bill_approvestatus=$adb->query_result($result,0,'approvestatus');//审批单据的审批状态
            
			if($rows > 1){//回撤
				$approveid = $adb->query_result($result,0,'approveid');//当前审批流程
				$nextstepid = $adb->query_result($result,0,'nextstepid');//当前审批步骤
                 
                $approveresult=$adb->query_result($result,0,'approveresult');//approveresult=5：不通过返回上一步
				$countersigner = $adb->query_result($result,0,'countersigner');
                $augmentsinger=$adb->query_result($result,0,'augmentsinger');
                //$logconcurrentid=$adb->query_result($result,0,'logconcurrentid');
           
                //duan 20220908 根据审批流程id判断是新审批流程还是旧审批流程
                $approveobj = $approvecommonobj->getApproveobjByApproveid($approveid);
                $resetapprove = 'no';
				if(empty($nextstepid)){
					if(3 == $approveresult){//审批失败
						$nextstepid = $adb->query_result($result,1,'nextstepid');//上一步下次审批步骤
					}else if(2 == $approveresult){//审批成功
						$nextstepid = $adb->query_result($result,1,'nextstepid');//上一步下次审批步骤
                        $pre_stepid = $adb->query_result($result,1,'stepid');
                        //duan 20230824 如果审批成功的前一步是提交审批，需要判断提交审批后是否会自动通过，比如提交人去重
                        if($pre_stepid == -1){
                            //判断再上一步审批步骤是否为提交审批
                            $approvestepobj = $approveobj->GetApproveStepobj($fld_module,$approveid,0);
                            $tmp_stepinfo = $approvestepobj->getstepid($pre_stepid,$nextstepid,0,$record,1,0,$approveid);
                            //如果重新提交后会自动通过，则驳回初始状态
                            if($tmp_stepinfo['nextstepid'] <=0){
                                $resetapprove = 'yes';
                            }
                        }
					}//已驳回状态下无法反审批，不会走到这里，没有其余可能性
					if(empty($nextstepid)) break;//没取到审批步骤直接跳出
				}
                
				$nextstep = $adb->query_result($result,0,'stepid');//上一步审批步骤
                if($resetapprove=='yes')$nextstep = -1;

				if(!$nextstep) break;//最终未取到上一步审批步骤
				if(-1 == $nextstep){//刚提交审批，回撤到提交审批状态
					$approvelog = array();
					$approvelog['crmid'] = $record;//数据ID
					$approvelog['approveid'] = $approveid;//当前审批步骤ID
					$approvelog['stepid'] = $nextstepid;//获取当前审批步骤
					$approvelog['approved_by'] = $current_user->id;//当前审批人
					$approvelog['approveresult'] = 4;//驳回
					$approvelog['description'] = $antiapproval;//备注：反审批
                    $stepinfo=$approveobj->SaveApprovedLog($fld_module,$approvelog);
					break;
				}
              
			
				if(-2 == $nextstep||$approveresult==5){//上一步就是回撤状态(-1是提交审批，不会走到这里，不做判断)
                    //approveresult=5：不通过返回上一步
                   //当回撤和不通过返回上一步，则nextstepid存的是上一个审批步骤
                    $nextstepid=$adb->query_result($result,0,'nextstepid');//上一步审批步骤
                  
                 
                        //edit:can 2021-01-14 43016: （8.2.7PHP7+Redis安装包）设置审批流程定制中的审批步骤加签审批后，反审批时选择“回撤到上一步”时，审批错误，审批结果一直显示回撤到上一步（客户服务单模块测试）
                    //跳过后，有多个审批后，反审批
                    $query='SELECT logconcurrentid, GROUP_CONCAT(stepid order by id) as stepid ,nextstepid,nextstepapproveby ,GROUP_CONCAT(approveresult order by id) as approveresult
                    ,approved_by,ld_approvelog.countersigner,ld_approvelog.augmentsinger,id from ld_approvelog where crmid=? 
                    and (ld_approvelog.approved_by>0 )
                    GROUP BY IF(logconcurrentid>0,logconcurrentid,id)
                    ORDER BY ld_approvelog.createdtime DESC,ld_approvelog.id desc ';
                    $result=$adb->pquery($query,array($_REQUEST['record']));
                    
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
                        
                    }
                    else
                    {
                        $isreject=1;
                    }
					if(1 == $isreject){//驳回到负责人处，不走回撤流程
						$approvelog = array();
						$approvelog['crmid'] = $record;//数据ID
						$approvelog['approveid'] = $approveid;//当前审批步骤ID
						$approvelog['stepid'] = $nextstepid;//获取当前审批步骤
						$approvelog['approved_by'] = $current_user->id;//当前审批人
						$approvelog['approveresult'] = 4;//驳回
						$approvelog['description'] = $antiapproval;//备注：反审批


                        $stepinfo= $approveobj->SaveApprovedLog($fld_module,$approvelog);
						break;
					}
					if(empty($nextstep)) break;//未取到上一步审批流程，跳出
				}else{
					//获取反审批的审批步骤的上一步审批人，如果为空，会在保存方法中再获取一次，因此不用考虑
                   
					$nextstepapproveby = $adb->query_result($result,1,'nextstepapproveby');
                    
				}
              
				$stepid = -2;//-2表示回撤操
                $approvelog = array();
				$approvelog['crmid'] = $record;//数据ID
				$approvelog['approveid'] = $approveid;//当前审批步骤ID
				$approvelog['stepid'] = $stepid;//回撤
				$approvelog['approved_by'] = $current_user->id;//当前审批人
				$approvelog['approveresult'] = 1;//当前审批类型（通过、驳回等）
				$approvelog['description'] = $antiapproval;//备注：反审批
				$approvelog['nextstepid'] = $nextstep;//回撤到上一步审批步骤
				$approvelog['augmentsinger'] = $augmentsinger;
                
                if($nextstep>0)
                {
                    //进入的是并发步骤
                    global $approvestepinfo_arr;
                    if(!is_array($approvestepinfo_arr))
                    {
                        $approvestepinfo_arr=[];
                    }
                    $approvestepinfo_arr[$approveid]= $approveobj->getAllStepInfoByApproveid($approveid);

                    $tmprows=sizeof($approvestepinfo_arr[$approveid]);
                
                    $concurrentidStepCount=0;
                    for($i=0;$i<$tmprows;$i++)
                    {
                        if($approvestepinfo_arr[$approveid][$i]['stepid'] == $nextstep)
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
                
                        
                /*editor:gyq_05 reason: 反审批生成提醒 date:2016 3 22*/
				$approvelog['approvedeal'] = 'backstep';
                if($nextstepapproveby<0)//系统处理人 system
                {
                    $select = 'SELECT id,approvevalue,approvetype FROM ld_approvestep 
								WHERE id = ? AND id > 0 ;';
					$selectresult = $adb->pquery($select,array($nextstep));
                    $approvetype = $adb->query_result($selectresult,0,'approvetype');
					$approvevalue = $adb->query_result($selectresult,0,'approvevalue');
                    $nextstepapproveby = $approveobj->getApproveBy($approvetype,$approvevalue,$record);
                }
               
				if(!empty($nextstepapproveby))//不等于空则提交，否则在方法中取自动获取
					$approvelog['nextstepapproveby'] = $nextstepapproveby;//审批步骤对应审批人
               
                $stepinfo=$approveobj->SaveApprovedLog($fld_module,$approvelog);

				//$approve->ApprovedcheckBankMonery($fld_module,$approvelog,$record);
			}elseif($rows > 0){//只有一条审批历史，说明是刚提交审批，回撤到负责人重新提交审批
				$approveid = $adb->query_result($result,0,'approveid');//当前审批流程
				$nextstepid = $adb->query_result($result,0,'nextstepid');//当前审批步骤
				if(empty($nextstepid)) break;
				$approvelog = array();
				$approvelog['crmid'] = $record;//数据ID
				$approvelog['approveid'] = $approveid;//当前审批步骤ID
				$approvelog['stepid'] = $nextstepid;//获取当前审批步骤
				$approvelog['approved_by'] = $current_user->id;//当前审批人
				$approvelog['approveresult'] = 4;//驳回
				$approvelog['description'] = $antiapproval;//备注：反审批
				//$approve->ApprovedcheckBankMonery($fld_module,$approvelog,$record);
                $approveobj = $approvecommonobj->getApproveobjByApproveid($approveid);
                $stepinfo=$approveobj->SaveApprovedLog($fld_module,$approvelog);
			}
	        break;
	    case '1'://使用当前流程重新流转，相当于已驳回
			$query = "SELECT approveid,stepid,approveresult,approved_by,$smowneridcolumnname as smowner,$maintablename.approvestatus
						FROM ld_approvelog inner join $maintablename on $maintablename.$maintable_index=ld_approvelog.crmid
                        
                         WHERE ld_approvelog.crmid = ? AND ld_approvelog.id > 0 ORDER BY ld_approvelog.createdtime DESC;";
			$result = $adb->pquery($query,array($record));
            
			$rows = $adb->num_rows($result);
			$approveid = $adb->query_result($result,0,'approveid');//当前审批流程
            
            $stepid = $adb->query_result($result,0,'stepid');//当前审批流程
            $approved_by=$adb->query_result($result,0,'approved_by');//当前审批审批步骤审批人
            $smownerid=$adb->query_result($result,0,'smowner');//当前审批单据的负责人
            $sql="select id,sequence from ld_approvestep where approveid=? order by sequence asc limit 1";
            $result=$adb->pquery($sql,array($approveid));
            $nextstepid=$adb->query_result($result,0,'id');
            $sequence=$adb->query_result($result,0,'sequence');
            
            //duan 20220908 根据审批流程id判断是新审批流程还是旧审批流程
            $approveobj = $approvecommonobj->getApproveobjByApproveid($approveid);

			$approvelog = array();
            /* editor:gyq_05  reason:若步骤ID为-1，则根据审批流程查出第一步ID */
            if($stepid == -1){

                $query = "select id from ld_approvestep where approveid=? ORDER BY sequence limit 1";
                $result = $adb->pquery($query,array($approveid));
                $stepid = $adb->query_result($result,0,'id');
            }

			$approvelog['crmid'] = $record;//数据ID
			$approvelog['approveid'] = $approveid;//当前审批步骤ID
			$approvelog['stepid'] = $stepid;//获取当前审批步骤
			$approvelog['approved_by'] = $current_user->id;//当前审批人
			$approvelog['approveresult'] = 4;//驳回
			$approvelog['description'] = $antiapproval;//备注：反审批
            $approvelog['usecurprocess']='yes';
            
           
                       
                      
             //判断流程是否有满足条件的审批步骤
            crm_load_class_file('cls_ApproveStep','modules/Approve');
            $query = 'select id,sequence,concurrentid from ld_approvestep 
						where approveid=? order by sequence;';
			$result = $adb->pquery($query,array($approveid));
            $tmp_stepid = $adb->query_result($result,0,'id');
            $tmp_sequence=$adb->query_result($result,0,'sequence');
            $concurrentid=$adb->query_result($result,0,'concurrentid');
            
            
            $approvestepobj=$approveobj->GetApproveStepobj($fld_module,$approveid,0);
            $stepinfo=$approvestepobj->getstepid($tmp_stepid,$tmp_stepid,$tmp_sequence,$record,1,$concurrentid,$approveid);
             if($stepinfo['nextstepid']<=0)
            {
                //当前流程不满足条件
                $_REQUEST['diony']='diony';
				ConvertTojsonString(-1,array(),getFixedLabel("CURRENTAPPROVALPROCESSSELECTAPPROVAL"));
            }
			$approveobj->SaveApprovedLog($fld_module,$approvelog);
            $concurrentidStepCount_cancel=$_REQUEST['concurrentidStepCount_cancel'];//反审批步骤数量
            for($i=0;$i<$concurrentidStepCount_cancel;$i++)
            {
                $_REQUEST['nextstep_'.$i]=$_REQUEST['nextstep_cancel_'.$i];
                $_REQUEST['stepseq_'.$i]=$_REQUEST['stepseq_cancel_'.$i];
                $_REQUEST['userid_'.$i]=$_REQUEST['userid_cancel_'.$i];
                $_REQUEST['nextstep_countersigner_'.$i]=$_REQUEST['nextstep_countersigner_cancel_'.$i];
                $_REQUEST['nextstep_augmentsinger_'.$i]=$_REQUEST['nextstep_augmentsinger_cancel_'.$i];
                
            }
            $_REQUEST['concurrentidStepCount']=$concurrentidStepCount_cancel;
           
            $time=time();$time++;
			$stepinfo=$approveobj->ApproveSubmit($fld_module,$record,$approveid,date('Y-m-d H:i:s',$time));
            $_REQUEST['concurrentidStepCount']=0;
           //$approve->ApprovedcheckBankMonery($fld_module,$approvelog,$record,'nosave');
            
	        break;
		case '2'://使用新的流程重新流转，驳回后，提交到新的审批流程
            //新的流程重新流转
			//首先将当前审批流程驳回
			$query = "SELECT approveid,nextstepid,approveresult ,approved_by,$smowneridcolumnname as smowner,$maintablename.approvestatus
						FROM ld_approvelog inner join $maintablename on $maintablename.$maintable_index=ld_approvelog.crmid
						 WHERE ld_approvelog.crmid = ? AND ld_approvelog.id > 0 and ld_approvelog.approved_by>0 ORDER BY ld_approvelog.createdtime DESC;";
			$result = $adb->pquery($query,array($record));
            
           
			$rows = $adb->num_rows($result);
            if($rows>0)
			{
                //edit:can 2021-01-11 42250: （https://61mis.com/kfbtest [^]）收款单->导入：导入已批准的单据成功后，（GR172）反审批时使用新的审批流程流转，审批人应该按照审批流程定制中的参数设置显示
                $approveid = $adb->query_result($result,0,'approveid');//当前审批流程
    			$nextstepid = $adb->query_result($result,0,'nextstepid');//当前审批步骤
                $approved_by=$adb->query_result($result,0,'approved_by');//当前审批审批步骤审批人
                $smownerid=$adb->query_result($result,0,'smowner');//当前审批单据的负责人
    			if(empty($nextstepid)){
    				$approveresult = $adb->query_result($result,0,'approveresult');//当前审批状态
    				if(3 == $approveresult){//审批失败
    					$nextstepid = $adb->query_result($result,1,'nextstepid');//上一步下次审批步骤
    				}else if(2 == $approveresult){//审批成功
    					$nextstepid = $adb->query_result($result,1,'nextstepid');//上一步下次审批步骤
    				}//提交审批状态不会走到这里，没有其余可能性
                   
    				//if(empty($nextstepid)) break;//没取到审批步骤直接跳出
    			}
                //上一轮提交审批的审批流程
                $pre_approveobj = $approvecommonobj->getApproveobjByApproveid($approveid);
            }
            
			//获取选中的审批流程
	        $selectapproveid = $_REQUEST['approveid'];//提交审批
			//反审批弹出层，使用新的流程重新流转   当新的审批流程的下一步处理人为空时
			if(!empty($selectapproveid)){
				
                //duan 20220908 根据审批流程id判断是新审批流程还是旧审批流程
                $approveinfo = $approvecommonobj->getApproveInfo($selectapproveid);
                $approveobj = $approvecommonobj->getApproveobjByApproveid($selectapproveid);
                if($approveinfo['isnewapprove'] == 'yes'){
                    global $approvestepinfo_arr;
                    $nextstepinfo = $approveobj->getnextstepinfo(-1,-1,$selectapproveid,$record);
                    if($nextstepinfo['nextstepid']<=0)
                    {
                        $_REQUEST['diony']='diony';
        				ConvertTojsonString(-1,array(),getFixedLabel("CHOICEAPPROVALPROCESSSELECTAPPROVAL"));
                    }else{
                        $tmp_stepinfo = $approvestepinfo_arr[$selectapproveid][$nextstepinfo['nextstepid']];
                        $approvetype = $tmp_stepinfo['approvetype'];
                        $approvevalue = $tmp_stepinfo['approvevalue'];
                    }
                }else{
                    $query = 'select approvetype,approvevalue from ld_approvestep where approveid = ? ORDER BY sequence asc limit 1';
                    $result = $adb->pquery($query,array($selectapproveid));
    				$num_rows = $adb->num_rows($result);
    				if($num_rows >= 1){
    					$approvetype = $adb->query_result($result,0,0);
    					$approvevalue = $adb->query_result($result,0,1);
    				}
                }
                if($approvetype == '' || ($approvetype == 0 && empty($approvevalue))){
					$_REQUEST['diony']='diony';
					ConvertTojsonString(-1,array(),"NEXTSTEPNOUSER");
				}
                $approveby=$approveobj->getApproveBy($approvetype,$approvevalue,$record);
			    if(!empty($approveby))
                {
                    $query = "select 1 from ld_users where id in (".$approveby.")";
			     	$result = $adb->pquery($query,array());
                    if($adb->num_rows($result) <= 0){
    					$_REQUEST['diony']='diony';
						ConvertTojsonString(-1,array(),"NEXTSTEPNOUSER");
    				}
                }
                else
                {
                    //duan 2022-4-2 判断当前步骤是否允许审批人为空
                    if($approveobj->get_allow_emptyapprover(0,$approvetype)=='no'){
                        $_REQUEST['diony']='diony';
					   ConvertTojsonString(-1,array(),"NEXTSTEPNOUSER");
                    }
                }
				
				
			}
	        $approvelog = array();
			$approvelog['crmid'] = $record;//数据ID
			$approvelog['approveid'] = $approveid;//当前审批步骤ID
			$approvelog['stepid'] = $nextstepid;//获取当前审批步骤
			$approvelog['approved_by'] = $current_user->id;//当前审批人
			$approvelog['approveresult'] = 4;//驳回
			$approvelog['description'] = $antiapproval;//备注：反审批
            $approvelog['usenewprocess']='yes';
            if($rows>0)//edit:can 2021-01-11 42250: （https://61mis.com/kfbtest [^]）收款单->导入：导入已批准的单据成功后，（GR172）反审批时使用新的审批流程流转，审批人应该按照审批流程定制中的参数设置显示
             $pre_approveobj->SaveApprovedLog($fld_module,$approvelog);
            //判断新的流程是否有满足条件的审批步骤
            crm_load_class_file('cls_ApproveStep','modules/Approve');
            $query = 'select id,sequence,concurrentid from ld_approvestep 
						where approveid=? order by sequence;';
			$result = $adb->pquery($query,array($selectapproveid));
            $tmp_stepid = $adb->query_result($result,0,'id');
            $tmp_sequence=$adb->query_result($result,0,'sequence');
            $concurrentid=$adb->query_result($result,0,'concurrentid');
            
            $approvestepobj=$approveobj->GetApproveStepobj($fld_module,$selectapproveid,0);
            $stepinfo=$approvestepobj->getstepid($tmp_stepid,$tmp_stepid,$tmp_sequence,$record,1,$concurrentid,$approveid);
            if($stepinfo['nextstepid']<=0)
            {
                $_REQUEST['diony']='diony';
				ConvertTojsonString(-1,array(),getFixedLabel("CHOICEAPPROVALPROCESSSELECTAPPROVAL"));
            }
           
           //dump($_REQUEST);
           
		//	$time = time();$time ++;//让提交审批的创建时间延后一秒，防止排序出现混乱
            //获取
           // $nextStepInfo = $approve->getApproveStepInfo($selectapproveid,$record);
            $concurrentidStepCount_cancel=$_REQUEST['concurrentidStepCount_cancel'];//反审批步骤数量
            for($i=0;$i<$concurrentidStepCount_cancel;$i++)
            {
                $_REQUEST['nextstep_'.$i]=$_REQUEST['nextstep_cancel_'.$i];
                $_REQUEST['stepseq_'.$i]=$_REQUEST['stepseq_cancel_'.$i];
                $_REQUEST['userid_'.$i]=$_REQUEST['userid_cancel_'.$i];
                $_REQUEST['nextstep_countersigner_'.$i]=$_REQUEST['nextstep_countersigner_cancel_'.$i];
                $_REQUEST['nextstep_augmentsinger_'.$i]=$_REQUEST['nextstep_augmentsinger_cancel_'.$i];
                
            }
            $_REQUEST['concurrentidStepCount']=$concurrentidStepCount_cancel;
			$stepinfo=$approveobj->ApproveSubmit($fld_module,$record,$selectapproveid,date('Y-m-d H:i:s'));
            $_REQUEST['concurrentidStepCount']=0;
           //  $approve->ApprovedcheckBankMonery($fld_module,$approvelog,$record,'nosave');
            
            
	        break;
        case 3:
        
    
            /*editor:gyq_05 reason:新增反审批返回初始状态，相对于审批的驳回功能 date:20160513*/
			$query = "SELECT approveid,stepid,nextstepid,approveresult,approved_by,$smowneridcolumnname as smowner
						FROM ld_approvelog inner join $maintablename on $maintablename.$maintable_index=ld_approvelog.crmid
                         WHERE ld_approvelog.crmid = ? AND ld_approvelog.id > 0 and ld_approvelog.approved_by>0 ORDER BY ld_approvelog.createdtime DESC,ld_approvelog.id desc;";
			$result = $adb->pquery($query,array($record));
            //dump($query);
			$rows = $adb->num_rows($result);
			$approveid = $adb->query_result($result,0,'approveid');//当前审批流程
            $approved_by=$adb->query_result($result,0,'approved_by');//当前审批审批步骤审批人
			$stepid = $adb->query_result($result,0,'stepid');//当前审批流程
            $smownerid=$adb->query_result($result,0,'smowner');//当前单据的负责人
			//获取选中的审批流程
			$selectapproveid = $approveid;//提交审批
            
            //duan 20220908 根据审批流程id判断是新审批流程还是旧审批流程
            $approveobj = $approvecommonobj->getApproveobjByApproveid($selectapproveid);
            
			$approvelog = array();
			/* editor:gyq_05  reason:若步骤ID为-1，则根据审批流程查出第一步ID */
			if($stepid == -1){

				$query = "select id from ld_approvestep where approveid=? ORDER BY sequence limit 1";
				$result = $adb->pquery($query,array($approveid));
				$stepid = $adb->query_result($result,0,'id');
			}

			$approvelog['crmid'] = $record;//数据ID
			$approvelog['approveid'] = $approveid;//当前审批步骤ID
			$approvelog['stepid'] = $stepid;//获取当前审批步骤
			$approvelog['approved_by'] = $current_user->id;//当前审批人
			$approvelog['approveresult'] = 4;//驳回
			$approvelog['description'] = $antiapproval;//备注：反审批
             
           // $approve->ApprovedcheckBankMonery($fld_module,$approvelog,$record,'nosave');
            $stepinfo = $approveobj->SaveApprovedLog($fld_module,$approvelog);

			$time = time();$time ++;//让提交审批的创建时间延后一秒，防止排序出现混乱
			
			//public function ApproveSubmit($module,$crmid,$approveid,$diaplsytime='')
			break;
	}
    
    $focus=CRMEntity::getInstance($fld_module);
    //$focus->cancel_ApproveEnd($record);
    crm_load_class_file("Reminds",'modules/Reminds');
    $focusreminds = new Reminds();
	$date_time = date('Y-m-d H:i:s', time());
	$focusreminds->column_fields['related_to'] = $record;
	$focusreminds->column_fields['reltab'] = $fld_module;
	$focusreminds->column_fields['is_del_send'] = 0;
	$focusreminds->column_fields['is_del_rec'] = 0;
	$focusreminds->column_fields['status_rmd'] = '未读';
	$focusreminds->column_fields['date_time'] = $date_time;
    if(trim($antiapproval)!="")
    {
        
        $focusreminds->column_fields['content'] = "你提交的单据已经被".getUserlastName($current_user)."反审批,原因：".$antiapproval;
    }
    else
    {
        $focusreminds->column_fields['content'] = "你提交的单据已经被".getUserlastName($current_user)."反审批,原因：无";
    }
    $focusreminds->column_fields['recieverid'] = $smownerid;
    $focusreminds->column_fields['remindstype'] = 'AntiApprove';
   
    $focusreminds->mode='create';
    $focusreminds->save('Reminds');
}
$_REQUEST['diony']='diony';
$arr['refreshdetailmodules']=array($fld_module);
//liushuai  20230803 XUQIU1001688 工作流程定制->调用 API 功能优化(提交审批弹窗，反审批按钮可能涉及反审批和重新提交，故只显示提交的弹窗信息)
if (isset($stepinfo['workflow'])) {
    //检查是否有API调用
    crm_load_class_file("cls_savereverse", 'include/SaveReverse');
    $workflowreverseobj = cls_savereverse::getInstance($fld_module);
    $receive_msg = $workflowreverseobj->checkCallApiPop();
    $arr['workflow']['receive_msg'] = $receive_msg;
    if ($receive_msg == 'yes') {
        $arr['workflow']['record'] = $record;
        $arr['workflow']['module'] = $fld_module;
        $arr['workflow']['pagemode'] = $workflowreverseobj->getPageMode();

        $arr['workflow']['before_save_infos'] = $stepinfo['workflow']['before_save_infos'];
        $arr['workflow']['after_save_infos'] = $stepinfo['workflow']['after_save_infos'];
    }
}
ConvertTojsonString(1,$arr,"success");

/**
 * 考虑到多次回撤情况，用递归方式获取审批步骤
 * @param Object $result 审批历史结果集
 * @param Integer $row 下标
 * @return 获取反审批的上一步审批步骤
 * @author Tujt 2014-12-31
 */
function getApproveTakeAstep($result,$nextstepid,$row) {
	global $adb;
	$stepid = $adb->query_result($result,$row,'stepid');
    if(-2 == $stepid || $stepid == $nextstepid){
		$row ++;
		$steparr = getApproveTakeAstep($result,$nextstepid,$row);
		$stepid = $steparr['stepid'];
	}
	if(!$stepid) $stepid = 0;
	return array('stepid'=>$stepid,'row'=>$row);
}
?>