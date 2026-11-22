<?php

crm_load_class_file("ApproveStepView","include/QueryGenerator/ApproveStepQuery");
crm_load_class_file("ApproveProductDetailView","include/QueryGenerator/ApproveStepQuery");
crm_load_class_file("ApproveProductDetailQuery","include/QueryGenerator/ApproveStepQuery");
crm_load_class_file("ApproveTabDetailQuery","include/QueryGenerator/ApproveStepQuery");
crm_load_class_file("ApproveQuery","include/QueryGenerator/ApproveStepQuery");
crm_load_class_file("ApproveTabView","include/QueryGenerator/ApproveStepQuery");
crm_load_class_file("ApproveAccountQuery","include/QueryGenerator/ApproveStepQuery");
class cls_ApproveStep
{
     public $approveid;
     public $stepid;
     public $record;
     public $approvemodule;
     public $stepidQueryobjs=array();
     public $approvestatusarr =array();
     public $approveresult=array();
     public $skipstepinfo=array();
     public $insertStepInfo=array();//最后满足条件的步骤信息
     public $skiptypearr = array();//跳过的步骤类型,'condition'未满足条件，'emptyapprover'审批人为空时触发自动跳过
     //$approveresult:审批的按钮：0：提交，
     public function __construct($approvemodule,$approveid,$approveresult)
     {
        $this->approveid=$approveid;
        $this->approveresult=$approveresult;
        $this->approvemodule=$approvemodule;
        $this->approvestatusarr= array(
			'1'=>constant('D_A_S_APPROVALOF'),//'审批中',
			'2'=>constant('D_A_S_APPROVED'),//'已批准',
			'3'=>constant('D_A_S_REJECTED'),//'已拒绝',
			'4'=>constant('D_A_S_DISMISSED'),//'已驳回'
			'5'=>constant('D_A_S_APPROVALOF'),//'审批中',
            '6'=>constant('D_A_S_APPROVALOF'),//'审批中',(加签)
            '12'=>constant('D_A_S_APPROVALOF'),//'审批中',//并发步骤（没有审批）
		);
     }
     
     public function getQueryobj($stepid)
     {
        global $current_user;
        static $stepidQueryobjs;
         if(array_key_exists($stepid,$this->stepidQueryobjs))
         {
            return $stepidQueryobjs[$stepid];
         }
         
         $customviewobj=new ApproveStepView($this->approvemodule);
        //duan 20230309 客户和供应商模块也有分录，否则判断审批流程条件时会报错
         if($this->approvemodule == 'Accounts' ){
             $productviewobj=new ApproveProductDetailView($this->approvemodule,"");
             $queryobj=new ApproveAccountQuery($this->approvemodule,$current_user,$customviewobj,$productviewobj);
         }
         else if(get_file_address($this->approvemodule,"ProductDetails") ||  $this->approvemodule == 'Vendors' )
         {
            
            $productviewobj=new ApproveProductDetailView($this->approvemodule,"");
            
            $queryobj=new ApproveProductDetailQuery($this->approvemodule,$current_user,$customviewobj,$productviewobj);
            
        }
        else if(get_file_address($this->approvemodule,$this->approvemodule.'DetailFieldsHtml'))
        {
            $productviewobj=new ApproveTabView($this->approvemodule,"");
            $queryobj=new ApproveTabDetailQuery($this->approvemodule,$current_user,$customviewobj,$productviewobj);
        }
        else 
        {
            $queryobj=new ApproveQuery($this->approvemodule,$current_user,$customviewobj);
        }
        $stepidQueryobjs[$stepid]=$queryobj;
        
        return $queryobj;
     }
     /**
      * 返回上一步
      * 
      * 
     public  function getbackPrevApprove($tmprecord,$startstepid)
     {
        global $adb;
      $query = 'SELECT approveid,stepid,nextstepid,nextstepapproveby,approveresult 
						FROM ld_approvelog WHERE crmid = ? AND id > 0 ORDER BY createdtime DESC;';
     }*/
     
     /**
      * 通过的审批
      * 提交审批，审核成功，通过继续下一步
      * */
     public function passApprove( $operationtype,$records,$approveinfo,$curstepid,$nextstepid)
     {
        global $current_user;
        $focus=CRMEntity::getInstance($this->approvemodule);
       
        $approveobj=new Approve($this->approvemodule);
        if($operationtype=="submitapprove")
        {
            $approveresult=1;
            $query = 'select id,sequence from ld_approvestep 
						where approveid=? order by sequence limit 1;';
             if($adb->num_rows($result)<=0)
             {
                return false;
             }
            $result=$adb->pquery($query,array($this->approveid));
            $sequence=$adb->query_result($result,0,'sequence');
            $nextstepid=$adb->query_result($result,0,'id');
            $curstepid=-1;
            $approvestatus=$this->approvestatusarr[1];
        }
        else if($nextstepid>0)
        {
            $approveresult=$_REQUEST['approvestatus'];
            
            $query = 'select id,sequence from ld_approvestep 
						where id=? ';
            $result=$adb->pquery($query,array($nextstepid));
            $sequence=$adb->query_result($result,0,'sequence');
            $approvestatus=$this->approvestatusarr[1];
        }
        $initnextstepid=$nextstepid;
        require_once(globalStatic::$root_directory.'modules/Approve/ApproveRemind.php');
        foreach($records as $tmprecord)
        {
            if($operationtype=="submitapprove")
            {
                //提交审批
              $approveinfo=$approveobj->approveStatus($tmprecord);
               if($approveinfo['approvestatus']==1)
               {
                    $errors[]=getFixedLabel('MODULE_HAVED_APPROVED');
                    continue;
               }
               
            }
            //获取满足查询条件的下一个审批步骤
            $stepidinfo=$this->getstepid($curstepid,$nextstepid,$sequence,$tmprecord,1,0,$this->approveid);
            if($stepidinfo['nextstepid']>0)
            {
                //如果找到满足审批的条件
                $query = "select approvetype,approvevalue from ld_approvestep where approveid=? and id=?";
    			$result = $adb->pquery($query,array($this->approveid,$stepidinfo['nextstepid']));
    			$approvetype = $adb->query_result($result,0,'approvetype');
    			$approvevalue = $adb->query_result($result,0,'approvevalue');
                $approvelog['stepid']=$curstepid;
                $approvelog['nextstep']=$stepidinfo['nextstepid'];
                $approvelog['approveresult']=$_REQUEST['approvestatus'];
                $approvelog['description'] = $_REQUEST['description'];//备注
                $approvelog['crmid']=$tmprecord;
    			$approvelog['nextstepapproveby'] = $this->getApproveBy($approvetype,$approvevalue,$tmprecord);//下一步审批人
               //插入审批日志
                $approvelogid = $this->insertApproveLog($tmprecord,"",$this->approveid,$stepidinfo["curstepid"],$current_user->id,$approveresult,$stepidinfo['nextstepid'],$approvelog['nextstepapproveby']);
                $approvelog['approvelogid'] = $approvelogid;

                //审批日志提醒
                $appremindObj = new ApproveRemind();
                $appremindObj->CreateMultiApproveReminds($this->approvemodule,$approvelog);
                //修改模块单据审批状态字段的值
                $tabname=$focus->table_name;
                $tabindex=$focus->table_index;
                $query = 'update '.$tabname.' set approvestatus="'.$approvestatus.'",approveby='.$current_user->id.',approvetime="'.date("Y-m-d H:i:s").'",currentapprover="'.$approvelog['nextstepapproveby'].'" where '.$tabindex.' = '.$approvelog['crmid'];
            }
        }
        
     }
     
     
     /**
      * 获取审批步骤列表
      * 
      * */
     public function getApproveStepList()
     {
        global $adb;
         $query="select * from ld_approvestep where approveid=? order by sequence";
        $result=$adb->pquery($query,array($this->approveid));
        $num_rows=$adb->num_rows($result);
        $step=array();
		require_once( 'modules/Users/Group.class.php');
		$group_focus = new Group();
        if($num_rows){
            include_once('modules/Users/Profile.class.php');
            $profile = new Profile();
            $concurrentstepid_arr=[];
            $rowseq=1;
            for($i=0;$i<$num_rows;$i++){
                $approve_type=$adb->query_result($result,$i,'approvetype');
                $approve_value=$adb->query_result($result,$i,'approvevalue');
                switch($approve_type){
                    case 0:
                    $userids=explode(',',$approve_value);
                    $approve_value="";
                    foreach($userids as $key=>$userid){ 
                        if($key==count($userids)-1)
                        $approve_value .=getUserFullName($userid);
                        else
                        $approve_value .=getUserFullName($userid).",";
                    }
                    break;
                    case 1:
                        $profileids=explode(',',trim($approve_value,','));
                        $approve_value='';
                        foreach($profileids as $profileid)
                        {
                            $profileinfo = $profile->getProfileinfo($profileid);
                            $approve_value.=$profileinfo['profilename'].',';
                        }
                        $approve_value=trim($approve_value,',');
                    break;
                    case 4:
                        $approvearray = explode('::', $approve_value);
                        $groupList = $group_focus->getGroupInfoByid($approvearray[0]);
                        $approve_value = getFixedLabel('Sector').':'.$groupList['groupname'];
                        $approve_value .= '<br>'.getFixedLabel('POSITIONLEVEL').':'.$approvearray[1];
                    break;
                    case 5:
                         $approve_value = getFixedLabel('DATACREATOR');
                    break;
                    case 6:
                        $approve_value = getFixedLabel('DATASSIGNEDTO');
                    break;
                }
                $concurrentid=$adb->query_result($result,$i,'concurrentid');
                if($concurrentid>0&&array_key_exists($concurrentid,$concurrentstepid_arr))
                {
                    $concurrentstepid_arr[$concurrentid][]=array('id'=>$adb->query_result($result,$i,'id'),
                    'sequence'=>$adb->query_result($result,$i,'sequence'),
                    'name'=>$adb->query_result($result,$i,'name'),
                    'approvetype'=>$approve_type,
                    'approvevalue'=>$approve_value,
                    'ended'=>$adb->query_result($result,$i,'ended'),
                    'step'=>$adb->query_result($result,$i,'step'),
                    'alloweditbill'=>$adb->query_result($result,$i,'alloweditbill'),
                    'specifyapproverid'=>$adb->query_result($result,$i,'specifyapproverid'),
                    'countersigner'=>$adb->query_result($result,$i,'countersigner'),
                    'augmentsinger'=>$adb->query_result($result,$i,'augmentsinger'),//加签
                    'concurrentid'=>$concurrentid
                    );
                }
                else
                {
                    $step[]=array('id'=>$adb->query_result($result,$i,'id'),
                    'rowseq'=>$rowseq,
                    'sequence'=>$adb->query_result($result,$i,'sequence'),
                    'name'=>$adb->query_result($result,$i,'name'),
                    'approvetype'=>$approve_type,
                    'approvevalue'=>$approve_value,
                    'ended'=>$adb->query_result($result,$i,'ended'),
                    'step'=>$adb->query_result($result,$i,'step'),
                    'alloweditbill'=>$adb->query_result($result,$i,'alloweditbill'),
                    'specifyapproverid'=>$adb->query_result($result,$i,'specifyapproverid'),
                    'countersigner'=>$adb->query_result($result,$i,'countersigner'),
                    'augmentsinger'=>$adb->query_result($result,$i,'augmentsinger'),//加签
                    'concurrentstepinfo'=>array(),
                    'concurrentid'=>$concurrentid,
                    );
                    $concurrentstepid_arr[$concurrentid]=array();
                    $rowseq++;
                }
                
            }
        }
        $step_arr=[];
        foreach($step as $stepinfo)
        {
            $stepinfo['rowspan']=1;
            if($stepinfo['concurrentid']>0)
            {
                $stepinfo['concurrentstepinfo']=$concurrentstepid_arr[$stepinfo['concurrentid']];
                $stepinfo['rowspan']=sizeof($concurrentstepid_arr[$stepinfo['concurrentid']])+1;
            }
           $step_arr[]=$stepinfo;

        }
        //dump($step_arr);
        return $step_arr;
     }
     /**
      * 获取指定步骤是否满足条件，yes:满足
      * 目前主要用于并发步骤日志保存判断
      * */
     public function getCheckStepCondidion($stepid,$record)
     {
         global $current_user,$adb;    
        $queryobj=$this->getQueryobj($stepid);
        $queryobj->initForCustomViewById($stepid);
        if(is_array($queryobj->advFilterList)&&sizeof($queryobj->advFilterList)>0)
        {
            //说明该步骤设置了查询条件
             $query=$queryobj->getQuery("",1);
             $query.=" and ".$queryobj->moduleobj->table_name.'.'.$queryobj->moduleobj->table_index.'='.$record;
            $result=$adb->pquery($query,array());
             if($adb->num_rows($result)>0){
                if(($this->check_autopass($stepid,$record)=='yes')){//判断当前步骤是触发了审批人为空时自动跳过
                    $this->skiptypearr[$stepid] = 'emptyapprover';
                    return 'no';
                }else{
                    return 'yes';
                }
             }else{
                $this->skiptypearr[$stepid] = 'condition';
                return 'no';
             }
        }else if($this->check_autopass($stepid,$record)=='yes'){//判断当前步骤是触发了审批人为空时自动跳过
            $this->skiptypearr[$stepid] = 'emptyapprover';
            return 'no';
        }else{
            return 'yes';
        }
        return 'no';       
     }
     /**
      * 获取提交审批，审批继续下一步
      * 
      * */
     public function getstepid($curstepid,$nextstepid,$sequence,$tmprecord,$depth=1,$concurrentid=0,$approveid=0)
     {
                global $current_user,$adb;
                global $approvestepinfo_arr;//某个审批流程下所有审批步骤信息
               
              // $queryobj=$this->getQueryobj($nextstepid);
             //   $queryobj->initForCustomViewById($nextstepid);
                if($this->getCheckStepCondidion($nextstepid,$tmprecord)=='no')
                {
                    //说明该步骤设置了查询条件
                       //if($approveid>0&&!array_key_exists())
                      
                         $query = 'select id,sequence,concurrentid from ld_approvestep 
						where approveid=? and sequence>?  order by sequence asc  limit 1;';
                      
                        
                        $result=$adb->pquery($query,array($this->approveid,$sequence));
      
                      
                        if($adb->num_rows($result)>0)
                        {
                            $prevsequence=$sequence;
                            $stepid=$adb->query_result($result,0,'id');
                            $sequence=$adb->query_result($result,0,'sequence');
                            $tmpconcurrentid=$adb->query_result($result,0,'concurrentid');
                         
                            if($concurrentid>0)//并发步骤的最后一步
                            {
                                $sql='select * from ld_approvestep where approveid=? and concurrentid=? and sequence<=?';
                               
                                $tmpresult=$adb->pquery($sql,array($approveid,$concurrentid,$prevsequence));
                                $startstepseq=$adb->num_rows($tmpresult)-1;
                                $this->skipstepinfo[]=array("curstepid"=>$nextstepid,"nextstepid"=>$nextstepid,'concurrentid'=>$concurrentid,'logcurrentid'=>0,'stepseq'=>$startstepseq,'seqtime'=>'');
                                
                            }
                            else
                                   $this->skipstepinfo[]=array("curstepid"=>$nextstepid,"nextstepid"=>$stepid,'concurrentid'=>$concurrentid,'logcurrentid'=>0,'stepseq'=>'','seqtime'=>'');
                           
                            return $this->getstepid($nextstepid,$stepid,$sequence,$tmprecord,2,$tmpconcurrentid,$approveid);
                        }
                        else
                        {
                            $this->skipstepinfo[]=array("curstepid"=>$nextstepid,"nextstepid"=>-1,'concurrentid'=>$concurrentid,'logcurrentid'=>0,'seqtime'=>'');
                            //$this->insertApproveLog($tmprecord,"未满足审批条件，直接跳过",$this->approveid,$curstepid,-1,10,"","-1");
                            //当前单据不满足审批流程所有审批步骤,审批成功结束审批流程
                              
                            if($concurrentid>0)
                            {
                                 $sql='select * from ld_approvestep where approveid=? and concurrentid=? and sequence<=?';
                                $tmpresult=$adb->pquery($sql,array($approveid,$concurrentid,$sequence));
                                $startstepseq=$adb->num_rows($tmpresult);
                                
                                //说明满足条件的步骤是并发步骤
                                $sql='select * from ld_approvestep where approveid=? and concurrentid=? and sequence>?';
                                $tmpresult=$adb->pquery($sql,array($approveid,$concurrentid,$sequence));
                                $rows=$adb->num_rows($tmpresult);
                                for($i=0;$i<$rows;$i++)
                                {
                                    $tmpstepid=$adb->query_result($tmpresult,$i,'id');
                                    if($this->getCheckStepCondidion($nextstepid,$tmprecord)=='no')
                                    {
                                         $this->skipstepinfo[]=array("curstepid"=>$tmpstepid,"nextstepid"=>$tmpstepid,'concurrentid'=>$concurrentid,'logcurrentid'=>0,'stepseq'=>$startstepseq+$i,'seqtime'=>'');
                                         
                                    }
                                    
                                }
                                
                            }
                            $this->insertStepInfo=array("curstepid"=>$nextstepid,"nextstepid"=>-1,'concurrentid'=>0);
                            return $this->insertStepInfo;
                        }
                        
                     
                }
                else
                {
                   
                    //该审批步骤没有设置查询条件
                    if($concurrentid>0)
                    {
                        $sql='select * from ld_approvestep where approveid=? and concurrentid=? and sequence<=?';
                        $tmpresult=$adb->pquery($sql,array($approveid,$concurrentid,$sequence));
                        $startstepseq=$adb->num_rows($tmpresult);
                        //说明满足条件的步骤是并发步骤
                        $sql='select * from ld_approvestep where approveid=? and concurrentid=? and sequence>?';
                        $tmpresult=$adb->pquery($sql,array($approveid,$concurrentid,$sequence));
                        $rows=$adb->num_rows($tmpresult);
                        
                        for($i=0;$i<$rows;$i++)
                        {
                            $tmpstepid=$adb->query_result($tmpresult,$i,'id');
                            //$stepseq=$adb->query_result($tmpresult,$i,'stepseq');
                            //$sequence=$adb->query_result($tmpresult,$i,'sequence');
                            
                           
                            if($this->getCheckStepCondidion($tmpstepid,$tmprecord)=='no')
                            {
                                 $this->skipstepinfo[]=array("curstepid"=>$tmpstepid,"nextstepid"=>$tmpstepid,'concurrentid'=>$concurrentid,'logcurrentid'=>0,'stepseq'=>$startstepseq+$i,'seqtime'=>'');
                                 
                            }
                            
                        }
                    }
                    $this->insertStepInfo=array("curstepid"=>$curstepid,"nextstepid"=>$nextstepid,'concurrentid'=>$concurrentid);
                    return $this->insertStepInfo;
                }
                
              
               
                
            
     }
    
     public function getstepmodulestatus($stepid)
     {
        static $stepmodulestatus;
        
        //获取审批步骤高级条件设定值
		$query="select modulestatus from ld_approvestep left join
		ld_approvestepdetails on ld_approvestep.id=ld_approvestepdetails.stepid
		where approveid=? and stepid=? and pass=? and modulestatus!=''";
        //3:审核失败，4：不通过，不返回负责人，5：不通过返回上一步
		if(3 == $_REQUEST['approvestatus'] || 4 == $_REQUEST['approvestatus']||5 == $_REQUEST['approvestatus'])
			$result = $adb->pquery($query,array($this->approveid,$stepid,1));
		else
			$result = $adb->pquery($query,array($this->approveid,$stepid,0));
        if($adb->num_rows($result)>0)
		      $modulestatus = $adb->query_result($result,0,'modulestatus');
        $stepmodulestatus[$stepid]=$modulestatus;
        return $modulestatus;
     }
     public function saveSkipApproveLog($tmprecord)
     {
        global $adb;
        $approveobj=new Approve();
        //41562: （61mis.com/kfbcrm）库存管理>出库单>选择编号为“CK105”进入详情界面：提交审批后，“审批人”和“当前审批人”字段还是显示为空
     //  $this->saveskip_nextstepapproveby='';
         $count=sizeof($this->skipstepinfo);
        
         $i=0;
         $concurrentstep_logcurrentid_arr=[];//并发步骤对应审批日志的并发值
        foreach($this->skipstepinfo as $stepinfo)
        {
            $nextstepapproveby="-1";
            $concurrentid=$stepinfo['concurrentid'];
            if($stepinfo['nextstepid']<=0)
            {
                $stepinfo['nextstepid']=0;
                $nextstepapproveby="0";
                
            }
            else if($i==$count-1)
            {
                $query = 'select id,sequence,approvetype,approvevalue,concurrentid,emptyapproverdeal from ld_approvestep 
						where approveid=? and id= ?;';
                $result=$adb->pquery($query,array($this->approveid,$stepinfo['nextstepid']));
                 $approvetype = $adb->query_result($result,0,'approvetype');
	           	$approvevalue = $adb->query_result($result,0,'approvevalue');
                $nextstepapproveby=$approveobj->getApproveBy($approvetype,$approvevalue,$tmprecord);
                //duan 2022-3-31 单据审批时如果下一步审批人为空，则根据‘审批人为空时处理方式’参数替换审批人信息
                if(empty($nextstepapproveby) && $approveobj->get_allow_emptyapprover($tmpnextstepid,$approvetype) == 'yes'){ //如果该类型可以设置对应参数
                	$emptyapproverdeal=$adb->query_result($result,0,'emptyapproverdeal');
                	$nextstepapproveby = $approveobj->getTransferUsers($emptyapproverdeal);
                }
                $lastconcurrentid=$adb->query_result($result,0,'concurrentid');
                if($lastconcurrentid>0)
                {
                     $nextstepapproveby='-1';//如果是并发步骤的跳过所有的下一步审批人都为system
                }
            }
            $i++;
            $logconcurrentid=$stepinfo['logconcurrentid'];
            $stepseq=$stepinfo['stepseq'];
            if(empty($stepseq))
            {
                $stepseq='';
            }
            $seqtime=$stepinfo['seqtime'];
            $concurrentid=$stepinfo['concurrentid'];
            if($logconcurrentid<=0&&$concurrentid>0)
            {
                $nextstepapproveby='-1';//如果是并发步骤的跳过所有的下一步审批人都为system
               
                //是并发步骤跳过
                if(!array_key_exists($concurrentid,$concurrentstep_logcurrentid_arr))
                {
                    $sql='select logconcurrentid,current_timestamp(6) as seqtime from ld_approvelog_concurrent ';
                    $tmpresult=$adb->pquery($sql,array());
                    $seqtime=$adb->query_result($tmpresult,0,'seqtime');
                    $logconcurrentid=$adb->query_result($tmpresult,0,'logconcurrentid');
                    
                    $concurrentstep_logcurrentid_arr[$concurrentid][]=array('logconcurrentid'=>$logconcurrentid,'seqtime'=>$seqtime);
                    $updatesql='update ld_approvelog_concurrent set logconcurrentid=logconcurrentid+1';
                    $adb->pquery($updatesql,array());
                     
                    
                }
                else{
                    $logconcurrentid=$concurrentstep_logcurrentid_arr[$concurrentid][0]['logconcurrentid'];
                    $stepseq=$stepinfo['stepseq'];
                    $seqtime=$concurrentstep_logcurrentid_arr[$concurrentid][0]['seqtime'];
                }
            }
            else if($concurrentid==0)
            {
                $stepseq=0;
                 $timesql='select current_timestamp(6) as seqtime ';
                $timeresult=$adb->pquery($timesql,array());
                 $seqtime=$adb->query_result($timeresult,0,'seqtime');
            }
            if(empty($logconcurrentid))
            {
                $logconcurrentid=0;
            }
           
            $this->saveskip_nextstepapproveby=$nextstepapproveby;
            //审批人为空时触发‘自动跳过’
            if($this->skiptypearr[$stepinfo['curstepid']] == 'emptyapprover'){
                $description = getFixedLabel('AUTOMATICPASSRESULT');
                $approveresult = 14;
            }else{
                $description = "未满足审批条件，直接跳过";
                $approveresult = 10;
            }
            $this->insertApproveLog($tmprecord,$approveresult,$this->approveid,$stepinfo['curstepid'],-1,$approveresult,$stepinfo['nextstepid'],$nextstepapproveby,$seqtime,$stepseq,$logconcurrentid);
          
        }
          //返回最后一步的审批日志是否为并发
            return array('logconcurrentid'=>$logconcurrentid,'seqtime'=>$seqtime,'stepseq'=>$stepseq,'concurrentid'=>$concurrentid);
     }
     public function insertApproveLog($crmid,$description,$approveid,$stepid,$approveby,$approveresult,$nextstepid,$nextstepapproveby,$seqtime,$stepseq,$logconcurrentid)
     {
       
        global $adb,$current_user;
        $approvelogid = $adb->getUniqueID('ld_approvelog');
        	$query = 'insert into ld_approvelog(id,crmid,description,approveid,stepid,approved_by,
					approveresult,createdtime,nextstepid,nextstepapproveby,countersigner,nextstep_countersigner,seqtime,stepseq,logconcurrentid)';
		$query .= 'value(?,?,?,?,?,?,?,now(),?,?,?,?,?,?,?)';
        $countersigner='no';
        $nextstep_countersigner='no';
        if($logconcurrentid>0)
        {
            $nextstepid=$stepid;
        }
        $nextstep_user_arr=array_filter(explode(",",$nextstepapproveby));
        if($nextstepid>0){
            //edit:can 20200714 判断下一步是否为会签审批
            $sql='select countersigner from ld_approvestep where id=?';
            $result=$adb->pquery($sql,array($nextstepid));
            $nextstep_countersigner=$adb->query_result($result,0,'countersigner');
            //$nextstep_countersigner=
        }
        /*
		if(empty($diaplsytime))
			$createdtime = date('Y-m-d H:i:s',time());
		else
			$createdtime = $diaplsytime;
        */
      
        
         //echo json_encode(array($approvelogid,$crmid,'',$approveid,$stepid,$approveby,$approveresult,$nextstepid,$nextstepapproveby,$countersigner,$nextstep_countersigner,$seqtime,$stepseq,$logconcurrentid));
       
        $adb->pquery($query,array($approvelogid,$crmid,'',$approveid,$stepid,$approveby,$approveresult,$nextstepid,$nextstepapproveby,$countersigner,$nextstep_countersigner,$seqtime,$stepseq,$logconcurrentid));

        return $approvelogid;
        
     }
     //判断当前步骤是否触发审批人为空自动跳过
     public function check_autopass($stepid,$record){
        global $current_user,$adb;
        global $selectapprovecrmid_len;//判断是否选择了多个单据进行提交/批量审批
        $approveobj=new Approve($this->approvemodule);
        $query="select approvevalue,approvetype,approveid,concurrentid,emptyapproverdeal from ld_approvestep where id=? limit 1";
        $result = $adb->pquery($query,array($stepid));
        if($adb->num_rows($result)>0){
            $approvevalue = $adb->query_result($result,0,'approvevalue');
            $approvetype = $adb->query_result($result,0,'approvetype');
            $approveid = $adb->query_result($result,0,'approveid');
            $concurrentid = $adb->query_result($result,0,'concurrentid');
            $emptyapproverdeal =$adb->query_result($result,0,'emptyapproverdeal');
        }else{
            return 'no';
        }
        if($emptyapproverdeal != 'autopass'){
            return 'no';
        }
        $tmp_sequence = 0;
        //判断并发步骤
        if($concurrentid >0){
            $sql = "select id from ld_approvestep where approveid=? and concurrentid =? ORDER BY sequence asc;";
            $result = $adb->pquery($sql,array($approveid,$concurrentid));
            $num_rows = $adb->num_rows($result);
            if($num_rows>0){
                for($i=0;$i<$num_rows;$i++){
                    $id = $adb->query_result($result,$i,'id');
                    if($stepid == $id){
                        $tmp_sequence = $i;
                        break;
                    }
                }
            }
        }
        
        //如果单个单据审批或提交审批时时，另外指定审批人，则不触发自动跳过
        
        if($selectapprovecrmid_len <=1 && isset($_REQUEST['nextstep_'.$tmp_sequence]) && $_REQUEST['nextstep_'.$tmp_sequence] == $stepid 
            && isset($_REQUEST['userid_'.$tmp_sequence])&&(!empty($_REQUEST['userid_'.$tmp_sequence]) && $_REQUEST['userid_'.$tmp_sequence]!=-1)){
            return 'no';
        }
        
        //判断当前审批人类型是否可以设置‘审批人为空处理方式’参数
        if($approveobj->get_allow_emptyapprover($stepid,$approvetype)=='yes'){
            $approveby = $approveobj->getApproveBy($approvetype,$approvevalue,$record);
            //如果下一步审批人为空，且设置为自动跳过
            if(empty($approveby)&&$emptyapproverdeal == 'autopass'){
                
                return 'yes';
            }
        }
        return 'no';
     }
}

?>