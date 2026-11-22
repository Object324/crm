<?php

//反审批
class cls_getCancelApprove
{
    public $record;//单据id
    public $setype;//类型
    public $approveStatus;//审批流程状态  开启:1  删除/禁用:0
    public $approveid;//当前审批流程
    public $fld_module;//单据模块
    public $approve;//

    public function __construct($record,$approve,$fld_module){
        $this->record = $record;
        $this->approve = $approve;
        $this->fld_module = $fld_module;
    }
    
    //获取反审批流程信息
    public function getApproveInfo(){
        global $current_user;
        $username = $current_user->user_name;

    	$approveStatus = $this->getApproveStatus($this->record);
        $approveid = $this->approveid;
        
        $approvenew = $this->approve->submitApprove(getTabid($this->fld_module)); 
        if($username=='admin')
            $applyapprove['list'] = $approvenew;

        if($approveStatus==0){
            if($username=='admin'){
                $applyapprove['list1'][]=array('canceltype'=>'2','label'=>getFixedLabel('APPROVE_CANCEL_SELECTAPPROVE'),'approveid'=>$approveid);
            }else{
                ConvertTojsonString(-1,array(),getFixedLabel('APPROVEALSTATUS1ORDELETED'));
            }
    	}else{
    	    $applyapprove['list1'][]=array('canceltype'=>'0','label'=>getFixedLabel('APPROVE_CANCEL_BACKUP'),'approveid'=>$approveid);
    	    if($username=='admin'){
    	        $applyapprove['list1'][]=array('canceltype'=>'1','label'=>getFixedLabel('APPROVE_CANCEL_BACKAPPROVE'),'approveid'=>$approveid);
                $applyapprove['list1'][]=array('canceltype'=>'3','label'=>getFixedLabel('APPROVERETURNORIGINAL'),'approveid'=>$approveid);
    		    $applyapprove['list1'][]=array('canceltype'=>'2','label'=>getFixedLabel('APPROVE_CANCEL_SELECTAPPROVE'),'approveid'=>$approveid);
    	    }
    	}
        $approvelist2=array();
        $approvelist2['status'] = $approveStatus;
        $approvelist2['approveid'] = $approveid;
        $applyapprove['list2'] = $approvelist2;
        ConvertTojsonString(1,$applyapprove,'');
    }
    
    //判断单据审批流程是否有效
    protected function getApproveStatus($record){
        global $adb;
                
        $approveStatus = 1;//当前审批流程是否被删除
        $query = 'SELECT approveid FROM ld_approvelog  WHERE crmid = ? 
    				AND ld_approvelog.id > 0 ORDER BY ld_approvelog.createdtime DESC limit 1;';
    	$result = $adb->pquery($query,array($record));
    	$rows = $adb->num_rows($result);
    	
		$this->approveid = $approveid = $adb->query_result($result,0,'approveid');//当前审批流程
		//判断当前审批是否存在
		$approve_query = 'select status from ld_approve where id = ?';
		$approve_result = $adb->pquery($approve_query,array($approveid));
		if($adb->num_rows($approve_result)>0&&$adb->query_result($approve_result,0,0)==0){
		    $approveStatus = 1;
		}else{
		    $approveStatus = 0;
    	}
        return $approveStatus;
    }
    
    //选择反审批流程步骤
    public function setApproveCancel($setype){
        switch($setype){
            case '0':
                $this->cancelBackUp();
                break;
            case '1':
                $this->cancelBackApprove();
                break;
            case '2':
                $this->cancelSelectApprove();
                break;
            case '3':
                $this->returnOriginal();
                break;
        }
        $focus=CRMEntity::getInstance($this->fld_module);
        $focus->cancel_ApproveEnd($this->record);
    }
    
    //回撤到上一步
    protected function cancelBackUp(){
        global $adb,$current_user;
        $record = $this->record;
        $fld_module = $this->fld_module;
        $focus=CRMEntity::getInstance($fld_module);
        $smowneridcolumnname=$focus->getSmownerColumName();
        $maintablename=$focus->table_name;
        $maintable_index=$focus->table_index;
        if(isset($_REQUEST['description']) && !empty($_REQUEST['description'])){
            $antiapproval = $_REQUEST['description'];
        }
        //approved_by>0 代表该审批步骤才是有用户点击的审批步骤，-1代表系统自动流转的审批步骤
        $query = "SELECT approveid,stepid,nextstepid,nextstepapproveby,approveresult ,approved_by,$smowneridcolumnname as smowner
						FROM ld_approvelog inner join $maintablename on $maintablename.$maintable_index=ld_approvelog.crmid 
                        WHERE ld_approvelog.crmid = ? AND ld_approvelog.id > 0 and approveresult <> 18 and (ld_approvelog.approved_by>0 or (ld_approvelog.approved_by = -1 and ld_approvelog.approveresult = 1)) ORDER BY ld_approvelog.seqtime desc,ld_approvelog.stepseq DESC;";
		$result = $adb->pquery($query,array($record));
		$rows = $adb->num_rows($result);
		if($rows > 1){//回撤
			$approveid = $adb->query_result($result,0,'approveid');//当前审批流程
			$nextstepid = $adb->query_result($result,0,'nextstepid');//当前审批步骤
            $smownerid=$adb->query_result($result,0,'smowner');//当前审批单据的负责人
           	$approveresult = $adb->query_result($result,0,'approveresult');//当前审批状态
			if(empty($nextstepid)){
			
				if(3 == $approveresult){//审批失败
					$nextstepid = $adb->query_result($result,1,'nextstepid');//上一步下次审批步骤
				}else if(2 == $approveresult){//审批成功
					$nextstepid = $adb->query_result($result,1,'nextstepid');//上一步下次审批步骤
				}//已驳回状态下无法反审批，不会走到这里，没有其余可能性
				if(empty($nextstepid)) return false;//没取到审批步骤直接跳出
                $sql='select * from ld_approvestep  where id=?';
                $tmpresult=$adb->pquery($sql,array($nextstepid));
                if($adb->num_rows($tmpresult)<=0)
                {
                    $this->returnOriginal();//032998: 单据明细界面--单据审批成功后，把该审批流程的最后一步审批步骤删除或者删除审批流程，再反审批单据回撤到上一步，此时单据审批状态返回为原始状态为“已驳回”
                }
			}
			$nextstep = $adb->query_result($result,0,'stepid');//上一步审批步骤
			if(!$nextstep) return false;//最终未取到上一步审批步骤
			if(-1 == $nextstep){//刚提交审批，回撤到提交审批状态
				$approvelog = array();
				$approvelog['crmid'] = $record;//数据ID
				$approvelog['approveid'] = $approveid;//当前审批步骤ID
				$approvelog['stepid'] = $nextstepid;//获取当前审批步骤
				$approvelog['approved_by'] = $current_user->id;//当前审批人
				$approvelog['approveresult'] = 4;//驳回
				$approvelog['description'] = $antiapproval;//备注：反审批
				$this->approve->ApprovedcheckBankMonery($fld_module,$approvelog,$record);
				return false;
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
            
                $tmprowindex=$this->approve->getBackStepLogIndex($result);
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
					$this->approve->ApprovedcheckBankMonery($fld_module,$approvelog,$record);
					return false;
				}
				if(empty($nextstep)) return false;//未取到上一步审批流程，跳出
			}else{
				//获取反审批的审批步骤的上一步审批人，如果为空，会在保存方法中再获取一次，因此不用考虑
                //在此处不能根据审批步骤，重新获取审批人，因为可以指定审批人，指定的审批人可能和审批流程不一致
				$nextstepapproveby = $adb->query_result($result,1,'nextstepapproveby');
			}
			$stepid = -2;//-2表示回撤操作
			$approvelog = array();
			$approvelog['crmid'] = $record;//数据ID
			$approvelog['approveid'] = $approveid;//当前审批步骤ID
			$approvelog['stepid'] = $stepid;//回撤
			$approvelog['approved_by'] = $current_user->id;//当前审批人
			$approvelog['approveresult'] = 1;//当前审批类型（通过、驳回等）
			$approvelog['description'] = $antiapproval;//备注：反审批
			$approvelog['nextstepid'] = $nextstep;//回撤到上一步审批步骤

            if($nextstep>0)
            {
                //进入的是并发步骤
                global $approvestepinfo_arr;
                if(!is_array($approvestepinfo_arr))
                {
                    $approvestepinfo_arr=[];
                }
                $approve = new Approve();
                crm_load_class_file("ApproveCommon","modules/Approve");
                $approvecommonobj = ApproveCommon::getInstance($fld_module);
                $approveobj = $approvecommonobj->getApproveobjByApproveid($approveid);
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
                // dump($tmpconcurrentid);
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

            if($nextstepapproveby<0)//系统处理人 system
            {
                    $select = 'SELECT id,approvevalue,approvetype FROM ld_approvestep 
								WHERE id = ? AND id > 0 ;';
					$selectresult = $adb->pquery($select,array($nextstep));
                    $approvetype = $adb->query_result($selectresult,0,'approvetype');
					$approvevalue = $adb->query_result($selectresult,0,'approvevalue');
                    $nextstepapproveby = $this->approve->getApproveBy($approvetype,$approvevalue,$record);
            }
			if(!empty($nextstepapproveby))//不等于空则提交，否则在方法中取自动获取
				$approvelog['nextstepapproveby'] = $nextstepapproveby;//审批步骤对应审批人
			$this->approve->ApprovedcheckBankMonery($fld_module,$approvelog,$record);
		}elseif($rows > 0){//只有一条审批历史，说明是刚提交审批，回撤到负责人重新提交审批
			$approveid = $adb->query_result($result,0,'approveid');//当前审批流程
			$nextstepid = $adb->query_result($result,0,'nextstepid');//当前审批步骤
            $smownerid=$adb->query_result($result,0,'smowner');//当前审批单据的负责人
			if(empty($nextstepid)) return false;
			$approvelog = array();
			$approvelog['crmid'] = $record;//数据ID
			$approvelog['approveid'] = $approveid;//当前审批步骤ID
			$approvelog['stepid'] = $nextstepid;//获取当前审批步骤
			$approvelog['approved_by'] = $current_user->id;//当前审批人
			$approvelog['approveresult'] = 4;//驳回
			$approvelog['description'] = $antiapproval;//备注：反审批
			$this->approve->ApprovedcheckBankMonery($fld_module,$approvelog,$record);
		}
        $approved_by=$adb->query_result($result,0,'approved_by');
        $smownerid=$adb->query_result($result,0,'smowner');//当前审批单据的负责人
        //反审批提醒
        $this->createReminds($smownerid,$antiapproval);
    }
    
    //使用当前流程重新流转
    protected function cancelBackApprove(){
        global $adb,$current_user;
        $record = $this->record;
        $fld_module = $this->fld_module;
        $focus=CRMEntity::getInstance($fld_module);
        $smowneridcolumnname=$focus->getSmownerColumName();
         $maintablename=$focus->table_name;
        $maintable_index=$focus->table_index;
        if(isset($_REQUEST['description']) && !empty($_REQUEST['description'])){
            $antiapproval = $_REQUEST['description'];
        }
        $query = "SELECT approveid,stepid,nextstepid,approveresult,approved_by,$smowneridcolumnname as smowner
						FROM ld_approvelog inner join $maintablename on $maintablename.$maintable_index=ld_approvelog.crmid 
                         WHERE ld_approvelog.crmid = ? AND ld_approvelog.id > 0 and ld_approvelog.approved_by>0 ORDER BY ld_approvelog.createdtime DESC;";
		$result = $adb->pquery($query,array($record));
		$rows = $adb->num_rows($result);
		$approveid = $adb->query_result($result,0,'approveid');//当前审批流程
        $stepid = $adb->query_result($result,0,'stepid');//当前审批流程
        $approved_by=$adb->query_result($result,0,'approved_by');
        $smownerid=$adb->query_result($result,0,'smownerid');//当前审批单据的负责人
        
       
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
         //判断流程是否有满足条件的审批步骤
            crm_load_class_file('cls_ApproveStep','modules/Approve');
            $query = 'select id,sequence from ld_approvestep 
						where approveid=? order by sequence;';
			$result = $adb->pquery($query,array($approveid));
            $tmp_stepid = $adb->query_result($result,0,'id');
            $tmp_sequence=$adb->query_result($result,0,'sequence');
            $approvestepobj=new cls_ApproveStep($fld_module,$approveid,0);
            $stepinfo=$approvestepobj->getstepid($tmp_stepid,$tmp_stepid,$tmp_sequence,$record,1);
             if($stepinfo['nextstepid']<=0)
            {
                //当前流程不满足条件
                
                echo "###error###".getFixedLabel("CURRENTAPPROVALPROCESSSELECTAPPROVAL");
                exit();
            }
        $this->approve->ApprovedcheckBankMonery($fld_module,$approvelog,$record,'nosave');
		$this->approve->SaveApprovedLog($fld_module,$approvelog);

        $time = time();$time ++;//让提交审批的创建时间延后一秒，防止排序出现混乱

		$stepinfo=$this->approve->ApproveSubmit($fld_module,$record,$approveid,date('Y-m-d H:i:s',$time)); 
               
        //反审批提醒
        $this->createReminds($smownerid,$antiapproval);       
    }
    
    //使用新的流程重新流转
    protected function cancelSelectApprove(){
        global $adb,$current_user;
        $record = $this->record;
        $fld_module = $this->fld_module;
        $focus=CRMEntity::getInstance($fld_module);
        $smowneridcolumnname=$focus->getSmownerColumName();
         $maintablename=$focus->table_name;
        $maintable_index=$focus->table_index;
        if(isset($_REQUEST['description']) && !empty($_REQUEST['description'])){
            $antiapproval = $_REQUEST['description'];
        }
		$query = "SELECT approveid,nextstepid,approveresult ,approved_by,$smowneridcolumnname as smowner
						FROM ld_approvelog inner join $maintablename on $maintablename.$maintable_index=ld_approvelog.crmid 
                        WHERE ld_approvelog.crmid = ? AND ld_approvelog.id > 0 and ld_approvelog.approved_by>0 ORDER BY ld_approvelog.createdtime DESC;";
		$result = $adb->pquery($query,array($record));
		$rows = $adb->num_rows($result);
		$approveid = $adb->query_result($result,0,'approveid');//当前审批流程
		$nextstepid = $adb->query_result($result,0,'nextstepid');//当前审批步骤
        $approved_by=$adb->query_result($result,0,'approved_by');//上一步审批人
        $smownerid=$adb->query_result($result,0,'smowner');//当前审批单据的负责人
		if(empty($nextstepid)){
			$approveresult = $adb->query_result($result,0,'approveresult');//当前审批状态
			if(3 == $approveresult){//审批失败
				$nextstepid = $adb->query_result($result,1,'nextstepid');//上一步下次审批步骤
			}else if(2 == $approveresult){//审批成功
				$nextstepid = $adb->query_result($result,1,'nextstepid');//上一步下次审批步骤
			}//提交审批状态不会走到这里，没有其余可能性
			if(empty($nextstepid)) return false;//没取到审批步骤直接跳出
		}
        $approvelog = array();
		$approvelog['crmid'] = $record;//数据ID
		$approvelog['approveid'] = $approveid;//当前审批步骤ID
		$approvelog['stepid'] = $nextstepid;//获取当前审批步骤
		$approvelog['approved_by'] = $current_user->id;//当前审批人
		$approvelog['approveresult'] = 4;//驳回
		$approvelog['description'] = $antiapproval;//备注：反审批
	
		//获取选中的审批流程
        $selectapproveid = $_REQUEST['approveid'];//提交审批
        //判断新的流程是否有满足条件的审批步骤
        crm_load_class_file('cls_ApproveStep','modules/Approve');
        $query = 'select id,sequence from ld_approvestep 
						where approveid=? order by sequence;';
		$result = $adb->pquery($query,array($selectapproveid));
        $tmp_stepid = $adb->query_result($result,0,'id');
        $tmp_sequence=$adb->query_result($result,0,'sequence');
        $approvestepobj=new cls_ApproveStep($fld_module,$selectapproveid,0);
        $stepinfo=$approvestepobj->getstepid($tmp_stepid,$tmp_stepid,$tmp_sequence,$record,1);
        if($stepinfo['nextstepid']<=0)
        {
                
                echo "###error###".getFixedLabel("CHOICEAPPROVALPROCESSSELECTAPPROVAL");
                exit();
        }
            
		//$time = time();$time ++;//让提交审批的创建时间延后一秒，防止排序出现混乱
        $this->approve->ApprovedcheckBankMonery($fld_module,$approvelog,$record,'nosave');
		$this->approve->SaveApprovedLog($fld_module,$approvelog);
		$stepinfo=$this->approve->ApproveSubmit($fld_module,$record,$selectapproveid,date('Y-m-d H:i:s')); 

        //反审批提醒
        $this->createReminds($smownerid,$antiapproval);
    }
    
    //返回初始状态
    protected function returnOriginal(){
        global $adb,$current_user;
        $record = $this->record;
        $fld_module = $this->fld_module;
        $focus=CRMEntity::getInstance($fld_module);
        $smowneridcolumnname=$focus->getSmownerColumName();
         $maintablename=$focus->table_name;
        $maintable_index=$focus->table_index;
        if(isset($_REQUEST['description']) && !empty($_REQUEST['description'])){
            $antiapproval = $_REQUEST['description'];
        }
        $query = "SELECT approveid,stepid,nextstepid,approveresult,approved_by,$smowneridcolumnname as smowner
						FROM ld_approvelog inner join $maintablename on $maintablename.$maintable_index=ld_approvelog.crmid
                         WHERE ld_approvelog.crmid = ? AND ld_approvelog.id > 0 ORDER BY ld_approvelog.createdtime DESC;";
		$result = $adb->pquery($query,array($record));
		$rows = $adb->num_rows($result);
		$approveid = $adb->query_result($result,0,'approveid');//当前审批流程
		$stepid = $adb->query_result($result,0,'stepid');//当前审批流程
        $approved_by=$adb->query_result($result,0,'approved_by');
        $smownerid=$adb->query_result($result,0,'smowner');//
		//获取选中的审批流程
		$selectapproveid = $approveid;//提交审批

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

		$this->approve->SaveApprovedLog($fld_module,$approvelog);

		$time = time();$time ++;//让提交审批的创建时间延后一秒，防止排序出现混乱
		$this->approve->ApprovedcheckBankMonery($fld_module,$approvelog,$record,'nosave');
        $this->createReminds($smownerid,$antiapproval);
    }
    function createReminds($smownerid,$description)
    {
        global $current_user;
        $focusreminds = CRMEntity::getInstance('Reminds');
    	$date_time = date('Y-m-d H:i:s', time());
    	$focusreminds->column_fields['related_to'] = $this->record;
    	$focusreminds->column_fields['reltab'] = $this->fld_module;
    	$focusreminds->column_fields['is_del_send'] = 0;
    	$focusreminds->column_fields['is_del_rec'] = 0;
    	$focusreminds->column_fields['status_rmd'] = '未读';
    	$focusreminds->column_fields['date_time'] = $date_time;
        if(trim($description)!="")
        {
            $focusreminds->column_fields['content'] = "你提交的单据已经被".$current_user->last_name."反审批,原因：".$description;
        }
        else
        {
            $focusreminds->column_fields['content'] = "你提交的单据已经被".$current_user->last_name."反审批";
        }
        $focusreminds->column_fields['recieverid'] = $smownerid;
        $focusreminds->column_fields['remindstype'] = 'AntiApprove';
        $focusreminds->mode='create';
        $focusreminds->save('Reminds');
    }
}



?>