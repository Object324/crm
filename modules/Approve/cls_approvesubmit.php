<?php


class cls_approvesubmit{


    public $module;
    public $approveobj;
    public $saveskip_nextstepapproveby;
    public function __construct($approveobj)
    {
        $this->approveobj=$approveobj;
        $this->module = $approveobj->module;
    }
    public function submit($module,$crmid,$approveid,$diaplsytime)
    {
        
        
		global $adb,$current_user;
		static $approvesubmitarr;
        static $firstapprovestepid;
        global $selectapprovecrmid_len;//判断是否选择了多个单据进行提交
        crm_load_class_file('cls_ApproveStep','modules/Approve');
        $approveinfo=$this->approveobj->approveStatus($crmid);
      
		if(!empty($approvesubmitarr[$approveid])){
			$stepid = $approvesubmitarr[$approveid]['stepid'];
			$concurrentid=$approvesubmitarr[$approveid]['concurrentid'];
            $sequence=$approvesubmitarr[$approveid]['sequence'];
		}else{
		 
			$query = 'select id,sequence,concurrentid from ld_approvestep 
						where approveid=? order by sequence;';
			$result = $adb->pquery($query,array($approveid));
		
            $sequence=$adb->query_result($result,0,'sequence');
            $approvesubmitarr[$approveid]['sequence']=$sequence;
			$approvesubmitarr[$approveid]['stepid'] = $stepid = $adb->query_result($result,0,'id');
            $approvesubmitarr[$approveid]['concurrentid'] = $concurrentid = $adb->query_result($result,0,'concurrentid');
             
		}
    
	    $approvestepobj=new cls_ApproveStep($module,$approveid,0);
        
        $stepinfo=$approvestepobj->getstepid($stepid,$stepid,$sequence,$crmid,1,$concurrentid,$approveid);
     
        if($stepinfo['nextstepid']<=0)
        {
            //没有满足条件审批步骤
            return $stepinfo;
        }
       
       	$query = 'select id,sequence,approvetype,approvevalue,countersigner,concurrentid from ld_approvestep 
						where approveid=? and id= ?;';
		$result = $adb->pquery($query,array($approveid,$stepinfo['nextstepid']));
        
 	   $approvetype = $adb->query_result($result,0,'approvetype');
		$approvevalue = $adb->query_result($result,0,'approvevalue');   
        $nextstep_countersigner=$adb->query_result($result,0,'countersigner');
        $concurrentid=$adb->query_result($result,0,'concurrentid');//大于零标识是有并发步骤
        $emptyapproverdeal = $adb->query_result($result,0,'emptyapproverdeal');
        $countersigner='no';
         
      if($selectapprovecrmid_len<=1 && $stepid == $_REQUEST['nextstep_0'])
	       	$approvesubmitarr[$approveid]['approveby'] = $approveby=$_REQUEST['userid_0'];//是否允许修改审批人功能改进// $this->getApproveBy($approvetype,$approvevalue,$crmid);
        else{
            //多个单据提交
             
            if($_REQUEST['concurrentidStepCount']>1)//说明是并发步骤
            {
                $query = 'select id,sequence,approvetype,approvevalue,countersigner,concurrentid from ld_approvestep 
						where approveid=? and concurrentid= ? order by sequence  asc;';
                $result = $adb->pquery($query,array($approveid,$concurrentid));
                $rows=$adb->num_rows($result);
                for($i=0;$i<$rows;$i++)
                {
                    //$_REQUEST['nextstep_'.$i]
                    $approvetype=$adb->query_result($result,$i,'approvetype');
                    $approvevalue=$adb->query_result($result,$i,'approvevalue');
                    $_REQUEST['userid_'.$i]=$this->approveobj->getApproveBy($approvetype,$approvevalue,$crmid);
                }
            }
            else{
                $approvesubmitarr[$approveid]['approveby'] = $approveby=$this->approveobj->getApproveBy($approvetype,$approvevalue,$crmid);
            }
        }
        
                                    
		$approvelogid = $adb->getUniqueID('ld_approvelog');
		/*
		* approve_autograph 是否显示手写签名  approve_autograph_path 手写签名图片保存路径
		*edit:chj
		*date:2020-07-13
		*reason:审批意见增加手写签名
		*/
		$approve_autograph = 'no';
		if(!empty($_REQUEST['approve_autograph_path'])){
			$approve_autograph = 'yes';	
		}
//        ls 2021-08-11  【ID1001881】航港：加急（优先）审批
        $urgent = 'no';
        if($_REQUEST['urgent']=='on'||$_REQUEST['urgent']=='yes'){
            //edit:can 20211129 49003: （81mis.com/kfbcrm/index.php）自定义表单07，单据 ZDYBD07-20，审批流“自定义表单07审批流程”，一级审批后-反审批操作使用当前流程重新流转，会显示加急审批
            $urgent = 'yes';
        }
        $lastapprovelogid=0;
        
		$query = 'insert into ld_approvelog(id,crmid,description,approveid,stepid,approved_by,
  	     approveresult,createdtime,seqtime,nextstepid,nextstepapproveby,countersigner,nextstep_countersigner,approve_autograph,approve_autograph_path,stepseq,urgent)';
		$query .= 'value(?,?,?,?,?,?,?,now(),current_timestamp(6),?,?,?,?,?,?,0,?)';
        

        /*
         * editor:gyq_05
         * reason:新增提交审批时，向日志表写入审批步骤ID,审批人默认为-5(没有人审批过)
         * date  :2016 3 3
         * */
        
         if($stepinfo["nextstepid"]==$stepid)
          {
              if(empty($approveby) && $_REQUEST['concurrentidStepCount'] <= 1 && $this->approveobj->get_allow_emptyapprover($stepid,$approvetype)!='yes') //0045103:排除并发步骤
                {
                    //edit:can 2021-03-17045040: （https://61mis.com/kfbcrm [^]）客户问题（徐燕男），服务合同勾选（服务合同编号：SERCON196和SERCON196）单据使用审批流程“服务合同选人审批流程”批量提交时，审批结果提示错误（需要补丁）
                    return array('nextstepid'=>$stepid,"approveby"=>$approveby);
                    
                }
    		   $adb->pquery($query,array($approvelogid,$crmid,trim($_REQUEST['description']),$approveid,-1,$current_user->id,1,$stepid,$approveby,$countersigner,$nextstep_countersigner,$approve_autograph,$_REQUEST['approve_autograph_path'],$urgent));//存入审批历史表，确定下一步审批步骤和审批人
            }
		  else

             $adb->pquery($query,array($approvelogid,$crmid,trim($_REQUEST['description']),$approveid,-1,$current_user->id,1,$stepid,"-1",$countersigner,$nextstep_countersigner,$approve_autograph,$_REQUEST['approve_autograph_path'],$urgent));//存入审批历史表，确定下一步审批步骤和审批人
      $logconcurrentid=0;
      $lastapprovelogid=$approvelogid;
      $concurrentInsertStepInfo=array('logconcurrentid'=>0);
      $approvelog_arr=[];
     $approvelog_arr['crmid']=$crmid;
     $approvelog_arr['approveid']=$approveid;
     $this->approveobj->insertStepID_arr=[];
     $this->approveobj->insertStepID_arr[]="-1";//已经插入的审批步骤
     $new_description=$_REQUEST['description'];
    $_REQUEST['description']='';
      if($_REQUEST['concurrentidStepCount']>1)//说明是并发步骤
      {
            //提交审批，下一步是并发审批步骤
           $concurrentInsertStepInfo=$this->approveobj->insertConcurrentApproveLog($approvestepobj,$approvelog_arr);//插入并发步骤
           $logconcurrentid=$concurrentInsertStepInfo['logconcurrentid'];
      }
      $_REQUEST['new_concurrentidStepCount']=$_REQUEST['concurrentidStepCount'];
     
        
		$focus = CRMEntity::getInstance($module);
		$tabname = $focus->table_name;
		$tabindex = $focus->table_index;
	   $approvestepobj->saveskip_nextstepapproveby=$approveby;
     
       $skipstepConcurrentinfo= $approvestepobj->saveSkipApproveLog($crmid);//保存跳过的审批步骤
    
        //跳过进入的下一步判断是否为并发
        //$stepinfo['nextstepid']:防止反审批和审批结束
        if(sizeof($approvestepobj->skipstepinfo)>0&&$stepinfo['nextstepid']>0)
        {
            $lastskipstepinfo=$approvestepobj->skipstepinfo[sizeof($approvestepobj->skipstepinfo)-1];
          
            if(is_array($approvestepinfo_arr)&&array_key_exists($approveid,$approvestepinfo_arr))
            {
                
                
            }
            else
            {
                if(!is_array($approvestepinfo_arr))
                {
                    $approvestepinfo_arr=[];
                }
               $approvestepinfo_arr[$approveid]=$this->approveobj->getAllStepInfoByApproveid($approveid);
            }
            $tmpstartindex=0;
            $curstep_concurrentid=0;
            $con_sequence=0;
            foreach($approvestepinfo_arr[$approveid] as $tmpindex=>$tmpstepinfo)
            {
                    if($tmpstepinfo['stepid']==$_REQUEST['nextstep_0'])
                    {
                        $curstep_concurrentid=$tmpstepinfo['concurrentid'];
                        
                        break;
                    }
            }
           
            foreach($approvestepinfo_arr[$approveid] as $tmpindex=>$tmpstepinfo)
            {
                
                if($tmpstepinfo['stepid']==$lastskipstepinfo['nextstepid'])
                {
                         $tmpconcurrentid=$tmpstepinfo['concurrentid'];
                         $con_sequence=$tmpstepinfo['sequence'];//并发的sequence 
                         break;
                }
            }
           
             /**
              * 当前跳过并发步骤的所有步骤
              * **/
             if($tmpconcurrentid>0&&$this->approveobj->checkConcurrentStepAllSkip($tmpconcurrentid,$approveid,$approvestepobj)=='yes')
             {
                //edit:can 2020-12-18 043841: （61mis.com/kfbcrm）并发审批：财务管理-销售发票；单据编号INV30；审批流“销售发票并发跳过”；第一步审批不符合条件跳过，直接进入并发步骤中跳过时，无法进入并发最后一步
                    $con_sequence=floor($con_sequence)+1;//获取下一个sequence
                    foreach($approvestepinfo_arr[$approveid] as $tmpindex=>$tmpstepinfo)
                    {
                        if($con_sequence<=$tmpstepinfo['sequence'])
                        {
                            $tmpconcurrentid=$tmpstepinfo['concurrentid'];
                            if(empty($tmpconcurrentid))
                            {
                                //跳过进入的步骤不是并发
                                $approvelogid=$adb->getUniqueID('ld_approvelog');
                                /*id,crmid,description,approveid,stepid,approved_by,
                          	     approveresult,createdtime,seqtime,nextstepid,nextstepapproveby,countersigner,nextstep_countersigner,approve_autograph,approve_autograph_path,stepseq
                                 */
                                 $tmpapprovetype=$tmpstepinfo['approvetype'];
                                 $tmpapprovevalue=$tmpstepinfo['approvevalue'];
                                 
                                 $tmpnextstepapproveby=$this->approveobj->getApproveBy($tmpapprovetype,$tmpapprovevalue,$crmid);
                                 $approvestepobj->saveskip_nextstepapproveby=$tmpnextstepapproveby;
								 //chj 2021/11/5 提交审批时候，并发步骤没有满足条件时，没有自动跳到下一步！
                                 $adb->pquery($query,array($approvelogid,$crmid,'',$approveid,$stepinfo['nextstepid'],'-1',1,$tmpstepinfo['stepid'],$tmpnextstepapproveby
                                            ,'no',$tmpstepinfo['nextstep_countersigner'],'','','no'));//存入审批历史表，确定下一步审批步骤和审批人
                                 $logconcurrentid=0;
                                 $approvestepobj->skipstepinfo[sizeof($approvestepobj->skipstepinfo)-1]['nextstepid']=$tmpstepinfo['stepid'];
                                
                            }
                            else//跳过即将进入并发步骤
                                $skipstepConcurrentinfo=['logconcurrentid'=>0];
                            break;
                        }
                    }
             }
           // else
           // {
           
                foreach($approvestepinfo_arr[$approveid] as $tmpindex=>$tmpstepinfo)
                {
                  
                    if($tmpstepinfo['concurrentid']==$tmpconcurrentid)
                    {
                     
                       
                        if($tmpstepinfo['concurrentid']<=0)
                        {
                            break;
                        }
                        else
                        {
                            
                            //如果进入的是并发步骤
                            $tmpconcurrentid=$tmpstepinfo['concurrentid'];
                          
                            if($curstep_concurrentid==$tmpconcurrentid)
                            {
                                //和界面传值过来的是同一个并发步骤
                                break;
                            }
                           
                            if($skipstepConcurrentinfo['logconcurrentid']<=0)
                            {
                                //非并发步骤
                                $skipstepConcurrentinfo=[];
                                $skipstepConcurrentinfo['concurrentid']=$tmpconcurrentid;
                                $sql='select logconcurrentid,current_timestamp(6) as seqtime from ld_approvelog_concurrent ';
                                $tmpresult=$adb->pquery($sql,array());
                                $skipstepConcurrentinfo['logconcurrentid']=$adb->query_result($tmpresult,0,'logconcurrentid');
                                $skipstepConcurrentinfo['seqtime']=$adb->query_result($tmpresult,0,'seqtime');
                                $sql='update ld_approvelog_concurrent set logconcurrentid=logconcurrentid+1 ';
                                $adb->pquery($sql,array());
                            }
                          
                            $this->approveobj->insertSkipStepConcurrentApproveLog($approvestepobj,$skipstepConcurrentinfo,$approvelog_arr);
                             
                            $logconcurrentid=$skipstepConcurrentinfo['logconcurrentid'];
                            break;
                        }
                    }
                }
            //}
           
      }
      //判断并发步骤是否所有的步骤都自动跳过
      
      
      
        $approvestatus = constant('D_A_S_APPROVALOF');
        if($logconcurrentid>0)
        {
            //获取并发步骤的所有待审批人和审批步骤
           $sql='select GROUP_CONCAT(distinct nextstepapproveby),group_concat(distinct stepid)  from ld_approvelog 
           where approveid=? and logconcurrentid=? and isfinished="no" ';
           
           $tmpresult=$adb->pquery($sql,array($approvelog_arr['approveid'],$logconcurrentid));
           $tmpstr_arr=array_unique(explode(',',$adb->query_result($tmpresult,0,0)));
           $approveby=implode(',',$tmpstr_arr);
           
          // $tmpstr_arr=array_unique(explode(',',$adb->query_result($tmpresult,0,1)));
          // $currentapprovestepid=implode(',',$tmpstr_arr);
        }else{
            //duan 判断下一步审批人是否为空，如果为空则执行特殊处理方式
            $sql='select nextstepapproveby,id from ld_approvelog where crmid=? order by id desc limit 1';
            $result=$adb->pquery($sql,array($crmid));
            $id = $adb->query_result($result,0,'id');
            //duan 判断下一步审批人是否为空，如果为空则执行特殊处理方式,因为需要修改单据中的值，所以获取到执行的结果
            $empty_approver_result = $this->approveobj->emptyapprover_solution($id);
            if ($empty_approver_result['type']=='change'){//转交其他审批人
                $approveby = $empty_approver_result['nextstepapproveby'];
            }else{
                $approveby = $adb->query_result($result,0,'nextstepapproveby');
            }
            $approvelog['nextstepapproveby'] = $approveby;
            $currentapprover=$approvelog['nextstepapproveby'];
        }
        
        
        
        $_REQUEST['description']=$new_description;
        //工作流程反写
        crm_load_class_file("cls_savereverse",'include/SaveReverse');
         $pagemode='submit';
        $workflowreverseobj=cls_savereverse::getInstance($module);
        $workflowreverseobj->setPageMode($pagemode);
        
        $workflowreverseobj->getInfo();
         if($adb->num_rows($workflowreverseobj->workflowresut)>0)
         {
              global $reset_retrieve_entity_info;//修改日志需要重新获取数据
              $reset_retrieve_entity_info='yes';//批量提交
             $focus->retrieve_entity_info($crmid, $module);
             $beforefieldvalue_arr=$focus->column_fields;
         }
        //duan 2022-4-21 提交审批后清空上一步审批人避免影响反审批判断
        // @edit:liushuai @date:2020-07-13 @reason: 审批中心查询优化：发起人（提交人）、发起时间（提交时间）、审批步骤（当前审批步骤）， 放在单据表里面（单据详情页审批）
       	$query = 'update '.$tabname.' set approvestatus = ?,currentapprover=?,approvetime=?,approvesubmitter=?,approvesubmittedtime=?,currentapprovestepid=?,approveurgent=?,approveexpediting=?,approveby=? where '.$tabindex.'='.$crmid;//将单据修改为审批中
         
        $adb->pquery($query,array($approvestatus,$approveby,date("Y-m-d H:i:s"),$current_user->id,date("Y-m-d H:i:s"),'-1',$urgent,'no',''));
       
       if($adb->num_rows($workflowreverseobj->workflowresut)>0)
         {
        
            $workflowreverseobj->setRecord($crmid);
            
            $focus->column_fields['approvestatus']=$approvestatus;
            $focus->column_fields['approvesubmitter']=$current_user->id;
            $focus->column_fields['currentapprover']='';
            $focus->column_fields['approveby']=$approveby;
            $workflowreverseobj->setPageMode($pagemode);
            if (!isset($_REQUEST['batchsubmit']) && $workflowreverseobj->checkCallApiPop() == 'yes')
                $workflowreverseobj->setNotCallActionType(array('API','Link2ERP'));
            $workflowreverseobj->getStartComputer($beforefieldvalue_arr,$focus->column_fields,$pagemode);
            $stepinfo['workflow']['before_save_infos'] = $beforefieldvalue_arr;
            $stepinfo['workflow']['after_save_infos'] = $focus->column_fields;
             if (isset($_REQUEST['batchsubmit']) && $workflowreverseobj->checkCallApiPop() == 'yes'){
                 $stepinfo['workflow']['callapimsg_arr'] = $workflowreverseobj->getExecResultData();
             }

         }
      
        require_once(globalStatic::$root_directory.'modules/Approve/ApproveRemind.php');
        //@param 参数$approvelog是一个包含审批历史的数组，需传审批结果approveresult、下一步审批人nextstepapproveby
        $approvelog['approveresult'] = 1;
        $approvelog['nextstepapproveby'] = $approveby;
        $approvelog['stepid'] =$approvesubmitarr[$approveid]['stepid'];
        $approvelog['crmid'] =$crmid;
        $approvelog['approved_by'] = $current_user->id;
        $approvelog['approvelogid'] = $approvelogid;
        
         if(sizeof($approvestepobj->skipstepinfo)>0)
            $approvelog['stepid']=$approvestepobj->skipstepinfo[sizeof($approvestepobj->skipstepinfo)-1]['nextstepid'];
      
        $appremindObj = new ApproveRemind();
		$appremindObj->updateRemindStatus($crmid);
        //生成消息提醒

        $appremindObj->CreateMultiApproveReminds($module,$approvelog,'submit');
      
        //批量循环
        $_REQUEST['new_concurrentidStepCount']=0;
        $_REQUEST['concurrentidStepCount']=0;
        
        if ($urgent == 'yes' && !empty($lastapprovelogid) )//并发
        {
            $adb->pquery("update ld_approvelog set urgent=? where crmid=? and  id >=? and approveid=? "
                        ,array($urgent,$approvelog['crmid'],$lastapprovelogid,$approveid));//更新最新审批步骤的审批日志urgent的值（并发审批多条记录）
               
        }
        
        return $stepinfo;
    }
    
    function approveLog($record){
        global $adb;
		//left join ld_crmentity on ld_crmentity.crmid=ld_approvelog.crmid 
        $query="select ld_approvelog.id,ld_approvelog.approved_by, ld_approvelog.approveresult
        ,ld_approve.name as approvename,ld_approvestep.name as stepname,la.name as nextstepname
        ,ld_approvelog.stepid,ld_approvelog.nextstepid,ld_approvelog.approved_by,nextstepapproveby
        ,t1.last_name as approvebyname,t1.wx_userid,ld_approvelog.description,ld_approvelog.createdtime
        ,ld_approvelog.approve_autograph,ld_approvelog.approve_autograph_path 
        ,ld_approvelog.countersigner,ld_approvelog.nextstep_countersigner
        ,ld_approvelog.logconcurrentid,stepcol_rowspantable.stepcol_rowspan,isfinished,expediting
        from ld_approvelog
         left join ld_users as t1 on
        ld_approvelog.approved_by=t1.id  left JOIN
        ld_approvestep on ld_approvelog.stepid=ld_approvestep.id left JOIN
        ld_approvestep as la on ld_approvelog.nextstepid=la.id left join
        ld_approve on ld_approvelog.approveid=ld_approve.id left join
        ld_users on ld_users.id = ld_approvelog.approved_by 
        left join (select max(id) as maxapprovelogstepid,count(id) as stepcol_rowspan from ld_approvelog
                     where crmid=? and logconcurrentid>0   GROUP BY seqtime,stepseq,logconcurrentid ) 
                     as stepcol_rowspantable  on stepcol_rowspantable.maxapprovelogstepid=ld_approvelog.id
         where  ld_approvelog.crmid = ? order by ld_approvelog.seqtime desc, ld_approvestep.sequence desc ,ld_approvelog.id desc";
        //ld_approvelog.stepseq desc,会导致跳过有问题
        $result=$adb->pquery($query,array($record,$record));
        $num_rows=$adb->num_rows($result);
        $approve=array();
        $userobj=new Users();
        $nextlogconcurrentid=0;
        $nextstepid=0;
        $seqno=0;
        $arr_index=-1;
        for($i=0;$i<$num_rows;$i++){
            $approveresult=$adb->query_result($result,$i,'approveresult');
            $logconcurrentid=$adb->query_result($result,$i,'logconcurrentid');
            
            $approved_by=$adb->query_result($result,$i,'approved_by');//审批人ID
            $stepname=$adb->query_result($result,$i,'stepname');
            $stepid=$adb->query_result($result,$i,'stepid');//当前步骤
            $nextstepid=$adb->query_result($result,$i,'nextstepid');
            $approvename=$adb->query_result($result,$i,'approvename');//审批流程名称
            $approvebyname=$adb->query_result($result,$i,'approvebyname');//审批人名称
            $approve_wx_userid=$adb->query_result($result,$i,'wx_userid');
            $isfinished=$adb->query_result($result,$i,'isfinished');
            $userobj->wx_userid=$approve_wx_userid;
            $userobj->last_name=$approvebyname;
           
            if(!empty($approved_by))
                $approvebyname=getUserlastName($userobj);
            
            $nextstepapproveby=$adb->query_result($result,$i,'nextstepapproveby');//下一个步骤审批人id
            $approved_by=$adb->query_result($result,$i,'approved_by');//审批人id,当审批人id等于-1,则审批人名称为System;
            $nextstepname=$adb->query_result($result,$i,'nextstepname');
            $countersigner=$adb->query_result($result,$i,'countersigner');
            $nextstep_countersigner=$adb->query_result($result,$i,'nextstep_countersigner');
            
			/* approve_autograph 是否显示手写签名  approve_autograph_path 手写签名图片保存路径
			*edit:chj
			*date:2020-07-13
			*reason:审批意见增加手写签名功能，
			*/
			$approve_autograph=$adb->query_result($result,$i,'approve_autograph');
            $approve_autograph_path=$adb->query_result($result,$i,'approve_autograph_path');
            $expediting = $adb->query_result($result,$i,'expediting');
            if($approved_by==-1)
            {
                $approvebyname="System";
            }
            if(substr((string)$nextstepapproveby, 0, 1 )=='H'){
                $approveby = getUserIdRole($nextstepapproveby);
                $nextstepapproveby=implode(',',$approveby);
            }
            
            if($nextstepapproveby==-1)
            {
                $nextstepbyname="System";
            }
            else
           {
             $nextstepby=$nextstepapproveby;
             $nextstepbyname=$this->approveobj->getApproveByName($nextstepby);
           }
            
                if($stepid==-1){
                    $operate=getFixedLabel('SUBMITAPPROVAL');
                    $stepname=getFixedLabel('Leadersubmittedforapproval');
                }
                else{
                    $operate=getFixedLabel('APPROVAL');
                }
           
           $approveresultno = $approveresult;
		   $cur_nextstepbyname = $nextstepbyname;	
		   $cur_approveresult = $approveresult;	//审批方式未转换前的数值
            switch($approveresult){
                case 10://审批不满足条件，直接跳过
                  $approveresult="未满足条件，直接跳过";
                 	if($stepid==-1)//使用新的的流程重新流转
                    //35803: （1.6登录）单据查看明细界面：提交审批后，审批日志中的审批结果信息中的冒号使用的是半角。预期结果：应使用全角。（服务合同模块测试）
					   $approveresult.="(".getFixedLabel('UseProcess').":".$approvename.")";
                    break;
                case 0://强制返回提交审批
					if($stepid==-1){
						$operate=getFixedLabel('FORCEDRETURNSSUBMITAPPROVAL');
						$stepname=getFixedLabel('FORCEDRETURNSSUBMITAPPROVAL');
						$approveresult=getFixedLabel('FORCEDRETURNSSUBMITAPPROVAL');
					
					}
					break;
                case 1:
					if($stepid==-1)//使用新的的流程重新流转
					$approveresult=getFixedLabel('UseProcess')."：".$approvename;
					elseif($stepid==-2){
					   //回撤上一步
						$stepname=getFixedLabel('RETRACEMENT');
						//$approveresult=getFixedLabel('Retracementofthereapproval');
                        //0033844: 微信端：审批-已审批：点击【驳回】，审批中心的审批结果显示为“回撤，重新审批”。预期结果：应该是“回撤到上一步”
                        $approveresult=getFixedLabel('APPROVE_CANCEL_BACKUP')."：".$adb->query_result($result,$i,'nextstepname');
					}
					else//通过并继续下一步
					$approveresult=getFixedLabel('CONTINUEAPPROVALSTEP')."：".$adb->query_result($result,$i,'nextstepname');
				    if($logconcurrentid>0&&$approved_by>0)
                    {
                       
                        $approveresult=getFixedLabel('Agree');
                    }
                	break;
                case 2://审批成功，结束流程
					$approveresult=getFixedLabel('AISTEOTP');
					break;
                case 3://审批失败，结束流程
					$approveresult=getFixedLabel('AFTPE');
					break;
                case 4://不通过，返回负责人
					$approveresult=getFixedLabel('INPTRC');
					//#0013160: 所有模块的单据驳回时返回的负责人有误 tujt 2015-01-04
                    if($stepid==-2)
                    {
                        //提交审批增加“回撤”功能
                        $approveresult=getFixedLabel('APPROVERETRACERESULT');
                        //36291: （1.6登录）提交审批回撤后，审批日志中审批步骤应该显示为“回撤”（合同订单模块测试）
                        $stepname=getFixedLabel('RETRACEMENT');
                        $operate=getFixedLabel('RETRACEMENT');
                        
                    }
					//$nextstepbyname=$smwoner;
					$nextstepbyname = '';
					$cur_nextstepbyname = '';
					break;
				case '5'://不通过，返回到上一步
				    $approveresult=getFixedLabel('IFNOTPASSEDTHENRETURNTOTHEPREVIOUSSTEP')."：".$adb->query_result($result,$i,'nextstepname');
				   break;
                case '12':
                    $approveresult='';//并发审批（待审批)
                    break;
                case '13':
                    $operate = getFixedLabel('SAVE');
                    $stepname = getFixedLabel('SAVE').getFixedLabel('resubmit');
                    $approveresult = D_A_S_UNAPPROVED;
                    break;
                case '14'://下一步审批人为空，直接通过
                    $approveresult = getFixedLabel('AUTOMATICPASSRESULT');
                    if($stepid==-1)//使用新的的流程重新流转
					   $approveresult.="(".getFixedLabel('UseProcess').":".$approvename.")";
                    break;
                case '15'://下一步审批人为空，转交管理员
                    $approveresult = getFixedLabel('AUTPFORWARDTOADMINRESULT');
                    break;
                case '16'://下一步审批人为空，转交指定成员
                    $approveresult = getFixedLabel('AUTPFORWARDTOUSERRESULT');
                    break;
                case '17'://审批步骤设置变更，修改单据审批信息
                    $approveresult = getFixedLabel('APPROVESETTINGSCHANGED');
                    break;
                case '18'://审批人重复，自动通过
                    $approveresult = getFixedLabel('APPROVERREPEATAUTOPASS');
                    break;
            }
            if($countersigner=='yes'){
				$operate=getFixedLabel('Countersignature');	//会签审批
				if($approveresultno==4){
					$approveresult=getFixedLabel('NOTPASSRETURNCHARGE');	//不通过
				}
                else if($approveresultno==5){
                    
                }
                else if($approveresultno==17){
                    $approveresult=getFixedLabel('APPROVESETTINGSCHANGED');	//审批步骤设置变更，修改单据审批信息
                }
				else if($logconcurrentid<=0)
					$approveresult=getFixedLabel('Agree');	//通过
                if(($nextstep_countersigner=='yes'||$logconcurrentid>0) && $approveresultno!=5){
                    //如果下一步也是会签审批，则判断当前步骤和下一步审批步骤的ID是否相等
                    if($stepid!=$nextstepid){
                        
                         $approveresult=getFixedLabel('CountersignatureNextStep')."：".$nextstepname;//审批结果
                         $nextstepbyname= getFixedLabel('Countersignature')."：".$nextstepbyname;//审批人
                    }
                    else{
                       $nextstepbyname= getFixedLabel('Countersignature')."：".$nextstepbyname;//审批人
                    }
                    
                }
                else{
                        if(empty($nextstepid)&&$approveresultno==2){
                            $approveresult=getFixedLabel('CountersignatureApproveSuccess');
                        }
                }
            }
            else   if($nextstep_countersigner=='yes'){
                $nextstepbyname= getFixedLabel('Countersignature')."：".$nextstepbyname;//审批人
            }
			//加签审批
			if($cur_approveresult == 6){
				$operate=getFixedLabel('augmentsingerapprove');	//加签审批
				$approveresult=getFixedLabel('augmentsingercurapprovestep');	//加签当前审批步骤
				$nextstepbyname=getFixedLabel('augmentsingerapprove')."：".$cur_nextstepbyname;//审批结果
			}
            $stepcol_rowspan=1;//审批步骤跨行数
            $stepcol_rowspan=$adb->query_result($result,$i,'stepcol_rowspan');//步骤列跨行数
            if(empty($stepcol_rowspan)&&$logconcurrentid==0)
            {
                $stepcol_rowspan=1;
            }
            //审批日志
            if(empty($logconcurrentid))
            {
                $seqno++;
                $arr_index++;
            }
            else if($logconcurrentid>0)
            {
                if($nextlogconcurrentid!=$logconcurrentid)
                {
                   
                    $seqno++;
                    $arr_index++;
                    
                }
            }
            $approve[$arr_index]['nextlogconcurrentid']=$nextlogconcurrentid;//下一步审批并发表示
            $nextlogconcurrentid=$logconcurrentid;
            $approve[$arr_index]['seqno']=$seqno;//序号列
            $approve[$arr_index]['curlogconcurrentid']=$logconcurrentid;
            $approve[$arr_index]['operatecol_rowspan']=1;//操作列跨行数
            $approve[$arr_index]['operatename']=$operate;//第二列 操作列
           // $approve[$arr_index]['logcurrentstepinfo'][]='';
            $createdtime=$adb->query_result($result,$i,'createdtime');
            if($createdtime<='1600-01-01 00:00:00')
            {
                $createdtime='';
            }
           if($logconcurrentid>0&&$isfinished=='yes')
           {
            
                //edit:can 2020-12-18 43847: 并发审批日志：并发步骤的审批日志，通过的步骤的“下一审批步骤”和“下一步处理”需要显示为空白，以免引起歧义
                $nextstepname='';
               
                if($cur_approveresult==6)
                {
                    $approveresult=getFixedLabel('Passandaugmentsinger');
                  //  $nextstepbyname加签审批：加签人
                }
                else
                {
                     $nextstepbyname='';
                }
           }
       
           $approve[$arr_index]['stepinfo'][]=array(
                                'stepcol_rowspan'=>$stepcol_rowspan,
                                'STEPNAME'=>$stepname,
                                'OPERATOR'=>$approvebyname,//操作人
                                'APPROVERESULT'=>$approveresult,//审批结果
                                'stepid'=>$stepid,
                                'nextstepid'=>$nextstepid,
                                    /*gyq_X01 去豆 */
                                'NEXTSTEPBYNAME'=>rtrim($nextstepbyname,','),//下一步审批审批人的名称
                                //@edit:liushuai 20200715 @reason: 审批中心查询优化：单据详情界面“审批日志”，“下一步处理人”右边增加列“下一审批步骤”
                                'NEXTSTEPNAME'=>$nextstepname,//下一步审批步骤名称
                                'DESCRIPTION'=>str_replace("\n","<br/>",(string)$adb->query_result($result,$i,'description')),//BUG0074598  	审批意见填写可以换行，保存后在审批日志中换行没有了 
                                'CREATEDTIME'=>$createdtime,
                    			'APPROVEID'=>$adb->query_result($result,$i,'id'),
                                'BACKUP'=>($approveresultno==4||$stepid==-2)?'YES':'NO',
                    			'APPROVEAUTOGRAPH' => $approve_autograph,
                    			'APPROVEAUTOGRAPHPATH' => $approve_autograph_path,
                                'cur_approveresult' =>$cur_approveresult,
                                'expediting'=>$expediting,
								'countersigner'=>$countersigner,
                                'isfinished'=>$isfinished
                            );
            
            
            
        }
      // dump($approve);
        $arr=array();
        $maxseqno=sizeof($approve);
        foreach($approve as $tmpindex=>$tmpinfo)
        {
           
            $tmpinfo['operatecol_rowspan']=sizeof($tmpinfo['stepinfo']);
            $tmpinfo['seqno']=$maxseqno;
            //edit:can 2020-12-15 43754: （61mis.com/kfbcrm）并发审批：OA表单-常用审批单；单据编号PTSP1，提交审批步骤“并发 普通”后，审批日志显示序号没有倒序显示
            $maxseqno--;
            if($tmpinfo['operatecol_rowspan']>1)
            {
                $tmpinfo['operatename']=getFixedLabel('ConcurrentApproval');
            }
            if($tmpindex>0)
                $tmpinfo['nextlogconcurrentid']=$approve[$tmpindex-1]['curlogconcurrentid'];
            else
                $tmpinfo['nextlogconcurrentid']=0;
            
            if($tmpinfo['nextlogconcurrentid']>0)
            {
                //下一步是审批并发步骤
               
                $tmpinfo['stepinfo'][0]['NEXTSTEPNAME']=getFixedLabel('StartConcurrent');
                //edit:can 2020-12-14 43733: 并发审批：当前审批之后将进入并发审批，则当前审批日志的“下一步处理人”显示为空
                //$tmpinfo['stepinfo'][0]['NEXTSTEPBYNAME']='';
            }
             $arr[$tmpindex]=$tmpinfo;
        }
        
   
        //editor:gyq date:20170401 reason:空值统一为''，避免移动端出现null
        /*0027558: （微信端，公司账套)费用报销明细：审批历史，已批准的单据，审批人没有显示，显示成了空，实际上是应该显示审批人姓名。
        foreach($approve as $key=>$content){
            foreach($content as $td=>$val){
                if(empty($val)){
                    $approve[$key][$td] = '';
                }
            }
        }*/
       
        return $arr;
    }
    
    
    //按照新的审批日志样式显示日志信息，将同一步骤的操作合并，获取完整的审批流程信息，包括未到达的步骤
    public function getWholeApproveLog($record,$ApprovelogSetInfo){
        $approvelog = $this->approveLog($record);
        $tmp_approvelog = array();
        $WholeApproveLog = array();
        $end_approvelog = 'no';
        $arr_index = -1;
        $approveid = 0;
        $max_showstepcount = 3;//审批日志最大展示条数
        $showstepcount = 0;//已选中条数
        $cancel_result_arr = array(3,4,5); //反审批结果
        $pass_reuslt_arr = array(1,2,6,10,14,18); //审批通过结果
        $autopass_result_arr = array(10,14,18); //自动通过结果
        $pass_descrition_color = 'rgb(48,199,117)';
        $cancel_descrition_color = 'rgb(255,80,107)';
        $versioninfo = getVersionInfo();
        if($versioninfo['trade']=='zhongfu'){
            $pass_descrition_color = 'rgb(0,100,0)';
        }

        //根据个性化设置参数，筛选掉不需要显示的步骤信息
        
        foreach($approvelog as $tmp_key=>$tmp_approveinfo){
            $tmp_arr = array();
            foreach($tmp_approveinfo['stepinfo'] as $tmp_index => $tmp_approveloginfo){
                $tmp_stepid = $tmp_approveloginfo['stepid'];
                $cur_result = $tmp_approveloginfo['cur_approveresult'];
                if($tmp_index == 0 && $tmp_key==0){
                    //获取下一步审批步骤id
                    $nextstepid = $tmp_approveloginfo['nextstepid'];
                    $last_approveloginfo = $tmp_approveloginfo;
                }
                //控制隐藏自动跳过的步骤
                if($ApprovelogSetInfo['hideautopassstep'] != 'no'){
                    if(in_array($cur_result,$autopass_result_arr)){
                        continue;
                    }
                }
                $tmp_arr['stepinfo'][$tmp_index] = $tmp_approveloginfo;
                $tmp_arr['curlogconcurrentid'] = $tmp_approveinfo['curlogconcurrentid'];
                $tmp_approvelog[$tmp_key] = $tmp_arr;
                //控制只显示最近一次提交审批的记录
                if($tmp_stepid == -1 && $cur_result==1){
                    if($approveid == 0){
                        $approveid = $tmp_approveloginfo['APPROVEID'];
                    }
                    if($ApprovelogSetInfo['showcurrentapprove'] != 'no'){
                        $end_approvelog = 'yes';
                        break;
                    }
                }
            }
            //控制只显示最近一次提交审批的记录
            if($end_approvelog == 'yes'){
                break;
            }
        }
        $keys_arr = array_keys($tmp_approvelog);
        $count = sizeof($keys_arr);
        $curlogconcurrentid_arr = array();
        //逆序读取日志
       
        for($tmp_key = $count-1;$tmp_key>=0;$tmp_key--){
            $incurrentapprove = 'no';
            $tmp_approveinfo = $tmp_approvelog[$keys_arr[$tmp_key]];
            $curlogconcurrentid = $tmp_approveinfo['curlogconcurrentid'];
            
            foreach($tmp_approveinfo['stepinfo'] as $tmp_index => $tmp_approveloginfo){
                $tmp_stepid = $tmp_approveloginfo['stepid'];
                $cur_result = $tmp_approveloginfo['cur_approveresult'];
                $stepname = $tmp_approveloginfo['STEPNAME'];
                $isfinished = $tmp_approveloginfo['isfinished'];

                //设置审批操作图标样式
                if(in_array($cur_result,$cancel_result_arr)||($cur_result==1&&$tmp_stepid==-2)){
                    //反审批
                    $tmp_approveloginfo['icon_class'] = 'approvelog_cancel';
                    $tmp_approveloginfo['tip'] = getFixedLabel('APPROVE_ANTIAPPROVAL');
                    $tmp_approveloginfo['tip_color'] = 'rgb(255,80,107)';
                    $tmp_approveloginfo['descrition_color'] = $cancel_descrition_color;
                }else if($curlogconcurrentid >0 && (($cur_result==12 && $isfinished == 'no') || ($cur_result==6 && $isfinished == 'no'))){
                    //并发审批中
                    $tmp_approveloginfo['icon_class'] = 'approvelog_wait';
                    $tmp_approveloginfo['tip'] = getFixedLabel('Approvalof');
                    $tmp_approveloginfo['tip_color'] = 'rgb(255,127,0)';
                    $tmp_approveloginfo['OPERATOR'] = $tmp_approveloginfo['NEXTSTEPBYNAME'];
                    if($cur_result==6 && $isfinished == 'no'){
                        $tmp_approveloginfo['APPROVERESULT'] = '';
                    }
                    $incurrentapprove = 'yes';
                }
                else if($curlogconcurrentid >0 && ($cur_result==12 && $isfinished == 'yes')){
                    //并发审批反审批产生的多余日志需要处理
                    continue;
                }
                else if(in_array($cur_result,$pass_reuslt_arr) && ($tmp_stepid != -1 && $tmp_stepid != -2)){
                    //审批通过
                    $tmp_approveloginfo['icon_class'] = 'approvelog_pass';
                    $tmp_approveloginfo['tip'] = getFixedLabel('Approvals');
                    $tmp_approveloginfo['tip_color'] = 'rgb(48,199,117)';
                    $tmp_approveloginfo['descrition_color'] = $pass_descrition_color;
                }else if($tmp_stepid == -1 && $cur_result==1){
                    //提交审批
                    $tmp_approveloginfo['descrition_color'] = $pass_descrition_color;
                }else{
                    //其他操作
                    $tmp_approveloginfo['icon_class'] = 'approvelog_other';
                }
                 
                //同一步骤的操作进行合并
                if($cur_result==2)
                {
                    $arr_index += 1;
                    $tmp_approvestep = array();
                    $tmp_approvestep['stepid'] = $tmp_stepid;
                    $tmp_approvestep['stepname'] = $stepname;
                    $tmp_approvestep['approveloginfo'][] = $tmp_approveloginfo;
                    $WholeApproveLog[$arr_index] = $tmp_approvestep;
                }
                else if($pre_stepid > 0 && $pre_stepid == $tmp_stepid){
                   
                    if(in_array($tmp_stepid,$curlogconcurrentid_arr) &&$tmp_approveloginfo['countersigner']!='yes'){
                        $skip = 'yes'; 
                        foreach($WholeApproveLog[$arr_index]['approveloginfo'] as &$tmp_tmp_approveloginfo){
                            if($tmp_tmp_approveloginfo['stepid']==$tmp_stepid){
                                if($cur_result == $tmp_tmp_approveloginfo['cur_approveresult'] && $cur_result != 6){
                                    $tmp_tmp_approveloginfo['DESCRIPTION']=$tmp_approveloginfo['DESCRIPTION'];
                                    $skip = 'yes';
                                }else{
                                    $skip = 'no';
                                }
                                //break;
                            }
                        }
                        if($skip == 'yes'){
                            continue;
                        }

                        $tmp_arr = [];
                        $tmp_arr[] = $tmp_approveloginfo;
                        foreach($WholeApproveLog[$arr_index]['approveloginfo'] as $tmp_value){
                            $tmp_arr[] = $tmp_value;
                        }
                        $WholeApproveLog[$arr_index]['approveloginfo'] = $tmp_arr;
                    }else{
                        $WholeApproveLog[$arr_index]['approveloginfo'][] = $tmp_approveloginfo;
                    }
                }else if($curlogconcurrentid == $pre_curlogconcurrentid){
                    //并发步骤进行合并
                   
                    $curlogconcurrentid_arr[] = $tmp_stepid;
                    $tmp_arr = [];
                    $tmp_arr[] = $tmp_approveloginfo;
                    foreach($WholeApproveLog[$arr_index]['approveloginfo'] as $tmp_value){
                        $tmp_arr[] = $tmp_value;
                    }
                    $WholeApproveLog[$arr_index]['approveloginfo'] = $tmp_arr;
                }else{
                    $tmp_approvestep = array();
                    if($curlogconcurrentid>0){
                        $curlogconcurrentid_arr = array();
                        $curlogconcurrentid_arr[] = $tmp_stepid;
                        $tmp_stepinfo = $this->approveobj->getStepInfo($tmp_stepid);
                        $concurrentid = $tmp_stepinfo['concurrentid'];
                        $tmp_approvestep['concurrentid'] = $concurrentid;
                        $tmp_approvestep['stepid'] = $concurrentid * -1;
                        $tmp_approvestep['stepname'] = getFixedLabel('ConcurrentApproval');
                    }else{
                        if(in_array($tmp_stepid,$curlogconcurrentid_arr)){
                            $skip = 'yes'; 
                            foreach($WholeApproveLog[$arr_index]['approveloginfo'] as &$tmp_tmp_approveloginfo){
                                if($tmp_tmp_approveloginfo['stepid']==$tmp_stepid){
                                    if($cur_result == $tmp_tmp_approveloginfo['cur_approveresult']){
                                        $tmp_tmp_approveloginfo['DESCRIPTION']=$tmp_approveloginfo['DESCRIPTION'];
                                    }else{
                                        $skip = 'no';
                                    }
                                    break;
                                }
                            }
                            if($skip == 'yes'){
                                continue;
                            }
                        }
                        $curlogconcurrentid_arr = array();
                        $tmp_approvestep['stepid'] = $tmp_stepid;
                        $tmp_approvestep['stepname'] = $stepname;
                    }
                    $arr_index += 1;
                    $tmp_approvestep['approveloginfo'][] = $tmp_approveloginfo;
                    $WholeApproveLog[$arr_index] = $tmp_approvestep;
                }

                //设置步骤图标样式
                if($tmp_stepid == -1 && $cur_result==1){
                    $WholeApproveLog[$arr_index]['icon_class'] = 'approvelog_submit';
                }else if($incurrentapprove == 'yes'){
                    $WholeApproveLog[$arr_index]['icon_class'] = 'approvelog_wait';
                    $WholeApproveLog[$arr_index]['tip'] = getFixedLabel('Approvalof');
                    $WholeApproveLog[$arr_index]['tip_color'] = 'rgb(255,127,0)';
                }else{
                    $WholeApproveLog[$arr_index]['icon_class'] = $tmp_approveloginfo['icon_class'];
                    $WholeApproveLog[$arr_index]['tip'] = $tmp_approveloginfo['tip'];
                    $WholeApproveLog[$arr_index]['tip_color'] = $tmp_approveloginfo['tip_color'];
                }
                $pre_stepid = $tmp_stepid;
                if($curlogconcurrentid >0){
                    $pre_curlogconcurrentid = $curlogconcurrentid;
                }else{
                    $pre_curlogconcurrentid = -1;
                }
            }
            
        }
       
        $pre_approveloginfo = $tmp_approveloginfo;
        
        //控制显示步骤的数量
        for($tmp_index = $arr_index;$tmp_index>=0;$tmp_index--){
            if($showstepcount < $max_showstepcount-1){
                $WholeApproveLog[$tmp_index]['showtype'] = 'show';
                $WholeApproveLog[$tmp_index]['display'] = 'yes';
                $showstepcount += 1;
            }else{
                $WholeApproveLog[$tmp_index]['showtype'] = 'pre_hidden';
                $WholeApproveLog[$tmp_index]['display'] = 'no';
            }
            //获取最后一个显示的键值
            $last_showindex = $tmp_index;
        }
        global $adb;
        //只有审批中的单据才加入待审批的步骤
        $approve_focus = CRMEntity::getInstance($this->module);
        $query = 'select approvestatus from ' . $approve_focus->table_name . ' where ' . $approve_focus->table_index . ' = ' . $record . ' limit 1';
        $result = $adb->pquery($query,array());
        $num_rows = $adb->num_rows($result);
        if($num_rows>0){
            $approvestatus = $adb->query_result($result,0,'approvestatus');
        }
        //加入当前流程待审批的步骤
        if($nextstepid>0 && $approveid >0 && $approvestatus == constant('D_A_S_APPROVALOF')){
            $find_step = 'no';
            $tmp_stepinfo=$this->approveobj->getStepInfo($nextstepid);
            
            $allstepinfo = $this->approveobj->getAllStepInfoByApproveid($tmp_stepinfo['approveid']);
             
            foreach($allstepinfo as $tmp_index=>$tmp_stepinfo){
                $tmp_stepid = $tmp_stepinfo['stepid'];
                if($tmp_stepid == $nextstepid){
                    //找到当前步骤在审批流程中的位置
                    $find_step = 'yes';
                    $cur_concurrentid = $tmp_stepinfo['concurrentid'];
                }
                if($find_step == 'no')continue;
                
                $tmp_approveloginfo = array();
                $tmp_concurrentid = $tmp_stepinfo['concurrentid'];
                //并发步骤不需要增加当前步骤
                if($tmp_concurrentid >0 && $tmp_concurrentid == $cur_concurrentid){
                    continue;
                }
                $tmp_approvetype = $tmp_stepinfo['approvetype'];
                $tmp_approvevalue = $tmp_stepinfo['approvevalue'];
                $tmp_approveloginfo['stepid'] = $tmp_stepid;
                //当前步骤的审批人从前一步的审批日志获取
                if($tmp_stepid == $nextstepid){
                    $tmp_approveloginfo['OPERATOR'] = $last_approveloginfo['NEXTSTEPBYNAME'];
                }else{
                    $nextstepby = $this->approveobj->getApproveBy($tmp_approvetype,$tmp_approvevalue,$record);
                    $tmp_approveloginfo['OPERATOR'] = trim($this->approveobj->getApproveByName($nextstepby),',');
                }
                $tmp_approveloginfo['STEPNAME'] = $tmp_stepinfo['name'];
                //区分当前步骤和剩余审批步骤
                if($tmp_stepid == $nextstepid){
                    $tmp_approveloginfo['icon_class'] = 'approvelog_wait';
                    $tmp_approveloginfo['tip'] = getFixedLabel('Approvalof');
                    $tmp_approveloginfo['tip_color'] = 'rgb(255,127,0)';
                }else{
                    $tmp_approveloginfo['tip'] = getFixedLabel('APPROVER');
                    $tmp_approveloginfo['tip_color'] = '#272727';
                }
                //如果审批步骤id和前一个日志的id相同则合并
                if($pre_stepid > 0 && $pre_stepid == $tmp_stepid){
                    $WholeApproveLog[$arr_index]['approveloginfo'][] = $tmp_approveloginfo;
                    if($tmp_stepid == $nextstepid){
                        $WholeApproveLog[$arr_index]['icon_class'] = $pre_approveloginfo['icon_class'];
                    }
                }else if($tmp_concurrentid>0 && $tmp_concurrentid == $pre_tmp_concurrentid){
                    $WholeApproveLog[$arr_index]['approveloginfo'][] = $tmp_approveloginfo;
                }else{
                    $arr_index += 1;
                    $tmp_approvestep = array();
                    if($tmp_concurrentid >0){
                        $tmp_approvestep['concurrentid'] = $tmp_concurrentid;
                        $tmp_approvestep['stepid'] = $tmp_concurrentid * -1;
                        $tmp_approvestep['stepname'] = getFixedLabel('ConcurrentApproval');
                    }else{
                        $tmp_approvestep['stepid'] = $tmp_stepid;
                        $tmp_approvestep['stepname'] = $tmp_stepinfo['name'];
                    }
                    $tmp_approvestep['approveloginfo'][] = $tmp_approveloginfo;
                    //控制刚进入显示部分步骤
                    if($tmp_stepid == $nextstepid){
                        $tmp_approvestep['showtype'] = 'show';
                        $tmp_approvestep['display'] = 'yes';
                        $showstepcount += 1;
                    }else{
                        $tmp_approvestep['showtype'] = 'next_hidden';
                        $tmp_approvestep['display'] = 'no';
                    }
                    $WholeApproveLog[$arr_index] = $tmp_approvestep;
                }
                 
                if($tmp_stepid == $nextstepid){
                    $WholeApproveLog[$arr_index]['icon_class'] = 'approvelog_wait';
                    $WholeApproveLog[$arr_index]['tip'] = getFixedLabel('Approvalof');
                    $WholeApproveLog[$arr_index]['tip_color'] = 'rgb(255,127,0)';
                    $WholeApproveLog[$arr_index]['expediting'] = $pre_approveloginfo['expediting'];
                }else{
                    $WholeApproveLog[$arr_index]['icon_class'] = 'approvelog_none';
                }
                $pre_stepid = $tmp_stepid;
                $pre_tmp_concurrentid = $tmp_concurrentid;
            }    
        }
       
        //如果显示的步骤数量不足，则向上增加显示
        if($showstepcount < $max_showstepcount){
            $i = 0;
            do{
                $tmp_index = $arr_index-$i;
                if(isset($WholeApproveLog[$tmp_index])&& $WholeApproveLog[$tmp_index]['showtype']=='pre_hidden'){
                    $WholeApproveLog[$tmp_index]['showtype'] = 'show';
					$WholeApproveLog[$tmp_index]['display'] = 'yes';
                    $showstepcount += 1;
                }
                if($showstepcount>=$max_showstepcount||$tmp_index<=0){
                    break;
                }
                $i += 1;
            }while($showstepcount < $max_showstepcount);
        }
        return $WholeApproveLog;
    }
    
}

?>