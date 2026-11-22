<?php
/*
edit:duan
date:20220829
reason:新图形化流程审批步骤功能类
*/
crm_load_class_file("ApproveStepView","include/QueryGenerator/ApproveStepQuery");
crm_load_class_file("ApproveProductDetailView","include/QueryGenerator/ApproveStepQuery");
crm_load_class_file("ApproveProductDetailQuery","include/QueryGenerator/ApproveStepQuery");
crm_load_class_file("ApproveTabDetailQuery","include/QueryGenerator/ApproveStepQuery");
crm_load_class_file("ApproveQuery","include/QueryGenerator/ApproveStepQuery");
crm_load_class_file("ApproveTabView","include/QueryGenerator/ApproveStepQuery");
class cls_ApproveStepNew
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
    public $approvechange_check = 'no';
    public $column_value; //表头字段值
    public $fieldsearchobj; //条件搜索对象
    public $approveremove_arr = [];
    public $issubmit;
    public $saveskip_nextstepapproveby;
    public $last_approvelog;

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
        $this->approveremove_arr = array();
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
        
        if(get_file_address($this->approvemodule,"ProductDetails"))
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
    
      //判断是否触发了审批人为空自动跳过和审批去重
     public function getCheckStepCondidion($stepid,$record,$prestepid=0)
     {
         global $current_user,$adb;    
        if($this->check_autopass($stepid,$record)=='yes'){
            //判断当前步骤是触发了审批人为空时自动跳过
            $this->skiptypearr[$stepid] = 'emptyapprover';
            return 'no';
        }
        
        else if($this->ApproverDuplicateRemoval($stepid,$record,$prestepid)=='yes'){
            //判断当前步骤是触发了审批人去重自动跳过
           
            
            return 'no';
        }
        return 'yes';       
     }

    public function setApprovechangeCheck($record,$column_value)
    {
        $this->approvechange_check = 'yes';
        $this->column_value = $column_value;

        crm_load_class_file('cls_fieldsearchcondition','include/utils/');
        $cls_fieldsearchconditionobj = cls_fieldsearchcondition::getInstance($this->approvemodule);
        $cls_fieldsearchconditionobj->setRecord($record);
        $cls_fieldsearchconditionobj->setColumnValues($this->column_value);
        if($column_value['rowcnt'] > 0){
            $cls_fieldsearchconditionobj->setdetailrowcnt($column_value['rowcnt']);
        }else{
            $cls_fieldsearchconditionobj->getDetailRowcnt();
        }
        $this->fieldsearchobj = $cls_fieldsearchconditionobj;
    }

    public function transfertoadvft($advFilterList){
        $advft_criteria[] = '';
        $advft_criteria_groups[] = '';
        foreach ($advFilterList as $group_id => $tmp_info){
            foreach ($tmp_info['columns'] as $tmp_column){
                $tmp_column['groupid'] = $group_id;
                if(empty($tmp_column['columncondition'])){
                    $tmp_column['columncondition'] = $tmp_column['column_condition'];
                }
                $tmp_column['groupid'] = $group_id;
                $advft_criteria[] = $tmp_column;
            }
            $advft_criteria_groups[$group_id] = array('groupcondition'=>$tmp_info['condition']);
        }

        return array('advft_criteria'=>json_encode($advft_criteria),'advft_criteria_groups'=>json_encode($advft_criteria_groups));
    }

     //判断是否通过分支条件
     public function getCheckStepadvFilterList($stepid,$record)
     {
         global $current_user,$adb;    
        $queryobj=$this->getQueryobj($stepid);
        
        $queryobj->initForCustomViewById($stepid);
        
        if(is_array($queryobj->advFilterList)&&sizeof($queryobj->advFilterList)>0)
        {
            if($this->approvechange_check == 'yes'){

                $tmpinput = $this->transfertoadvft($queryobj->advFilterList);

                $tmpinput['searchtype'] = 'advance';

                $tmp_result = $this->fieldsearchobj->getresultbyAdvancecondition($tmpinput);

                if($tmp_result){
                    return 'yes';
                }else{
                    $this->skiptypearr[$stepid] = 'condition';
                    return 'no';
                }
            }else{
                if($record <= 0){
                    return 'yes';
                }

                //说明该步骤设置了查询条件
                $query=$queryobj->getQuery("",1);
                $query.=" and ".$queryobj->moduleobj->table_name.'.'.$queryobj->moduleobj->table_index.'='.$record;

                $result=$adb->pquery($query,array());
                if($adb->num_rows($result)>0){
                    return 'yes';
                }else{
                    $this->skiptypearr[$stepid] = 'condition';
                    return 'no';
                }
            }

        }else{
            return 'yes';
        }       
     }
     public function getstepid($curstepid,$nextstepid,$sequence,$tmprecord,$depth=1,$concurrentid=0,$approveid=0)
     {
                global $current_user,$adb;
                global $approvestepinfo_arr;//某个审批流程下所有审批步骤信息
              // $queryobj=$this->getQueryobj($nextstepid);
             //   $queryobj->initForCustomViewById($nextstepid);
             //审批去重 和条件判断
                if($this->getCheckStepCondidion($nextstepid,$tmprecord,$curstepid)=='no')
                {
                   
            
                    //说明该步骤设置了查询条件
                       //if($approveid>0&&!array_key_exists())
                      
                        $nextstepinfo = $this->getnextstepid($flowstepid,$nextstepid,$tmprecord,$approveid);
                         
                     
                        if($nextstepinfo['nextstepid']>0)
                        {
                            $stepid=$nextstepinfo['nextstepid'];
                            $this->skipstepinfo[]=array("curstepid"=>$nextstepid,"nextstepid"=>$stepid,'concurrentid'=>0,'logcurrentid'=>0,'stepseq'=>'','seqtime'=>'');
                           
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
                             
                             if($this->skiptypearr[$nextstepid]=='approveremove')
                            {
                                $this->insertStepInfo=array("curstepid"=>$nextstepid,"nextstepid"=>0,'concurrentid'=>0);
                            }
                            else
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
      //获取当前步骤的下一步 $brandstepid 审批设置中的结构id
     public function getnextstepid($flowstepid,$stepid,$tmprecord,$approveid=0)
    {
        global $current_user,$adb;
        global $approvestepinfo_arr;//某个审批流程下所有审批步骤信息
     
        $cur_approvestepinfo = $approvestepinfo_arr[$approveid];
        //根据flowstepid生成索引数组
        $flowstepid_approvestepinfo = array();
        
        foreach($cur_approvestepinfo as $tmpstepid => $tmp_stepinfo){
            if($stepid<=0 && $flowstepid == $tmp_stepinfo['flowstepid']){
                $stepid = $tmpstepid;
                
            }
            $tmp_flowstepid = $tmp_stepinfo['flowstepid'];
            $flowstepid_approvestepinfo[$tmp_flowstepid] = $tmp_stepinfo;
        }
        
        $cur_stepinfo = $cur_approvestepinfo[$stepid];
        
        $flowstepid = $cur_stepinfo['flowstepid'];
        $childid_str = $cur_stepinfo['childids'];
       
        if(empty($childid_str)){
       
            //子节点为空，表示最后一个结点，审批流程结束
            return array('nextstepid'=>-2);
        }
        
        //增加循环上限
        $index = 0;
        $find_nextstep = 'no';
        do{
            if(!empty($childid_str)){
                $child_arr = explode(',',$childid_str);
            }else{
                $child_arr = [];
            }

            if(sizeof($child_arr)>1 ){
                //子节点数量大于1,表示需要判断分支    
                foreach($child_arr as $tmp_key => $tmp_childid){
                    $tmp_stepinfo = $flowstepid_approvestepinfo[$tmp_childid];
                    
                    if($tmp_stepinfo['steptype'] == 'condition'){
                        //判断当前单据是否满足条件分支条件
                        if($tmp_key == 0){
                            //如果所有的分支条件都没有满足，以第一个分支为默认选项,如果以后设置默认选项可以直接沿用
                            $childid_str = $tmp_stepinfo['childids'];
                        }

                        if($this->getCheckStepadvFilterList($tmp_stepinfo['stepid'],$tmprecord)=='no'){
                            
                            continue;
                        }else{
                            
                            $childid_str = $tmp_stepinfo['childids'];
                            break;
                        }
                    }else if($tmp_stepinfo['steptype'] == 'approver'){
                        //如果是审批人节点直接返回，正常情况下多个分支的第一个不会是审批人节点，控制一下错误情况
                        $flowstepid = $tmp_stepinfo['flowstepid'];
                        $nextstepid = $tmp_stepinfo['stepid'];
                        $find_nextstep ='yes';
                        break;
                    }
                }
                if($find_nextstep == 'yes'){
                    break;
                }
            }else if(sizeof($child_arr)==1){
                //如果子节点只有一个
                $tmp_stepinfo = $flowstepid_approvestepinfo[$child_arr[0]];
                if($tmp_stepinfo['steptype'] == 'approver'){
                    //如果是审批人节点可以判断结束
                    $flowstepid = $tmp_stepinfo['flowstepid'];
                    $nextstepid = $tmp_stepinfo['stepid'];
                    $find_nextstep ='yes';
                    break;
                }else{
                    //非审批人节点继续获取子节点
                    $childid_str = $tmp_stepinfo['childids'];
                }
            }else{     //如果没有子节点，表示为最后一步，可以结束流程
                return array('nextstepid'=>-2);
            }
            $index++;
        //设置循环上限
        }while($index<=100);
        if(empty($flowstepid))$flowstepid = -2;
        if(empty($nextstepid))$nextstepid = -2;
     
        return array("curstepid"=>$curstepid,"nextstepid"=>$nextstepid,'flowstepid'=>$flowstepid);
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
            $cur_stepid = $stepinfo['curstepid'];
            if($this->skiptypearr[$cur_stepid] == 'approveremove'){
                //审批人去重时自动跳过
                $approveresult = 18;
                $countersigner = $stepinfo['countersigner'];
                //原始的审批人
                $orgin_approverremove_arr = $this->orgin_approveby_arr[$cur_stepid];
                $orgin_approverremove_arr_copy = $orgin_approverremove_arr; //用于记录去重后剩余的审批人
                //被审批去重去掉的审批人
                $approverremove_arr = $this->approveremove_arr[$cur_stepid];
                $len = sizeof($orgin_approverremove_arr);
                //非会签审批只会记录一个被去重的审批人，会签审批有可能记录多个
                for($j=0;$j<$len;$j++){
                    $approveby = $orgin_approverremove_arr[$j];
                    //如果审批人在去重名单中
                    if(sizeof($approverremove_arr)>0 &&in_array($approveby,$approverremove_arr)){
                        unset($orgin_approverremove_arr_copy[$j]);
                        //设置会签审批的剩余审批人时去掉当前审批人
                        if(sizeof($orgin_approverremove_arr_copy)>0 && $countersigner == 'yes'){
                            $tmp_nextapproveby = implode(',',$orgin_approverremove_arr_copy);
                            $nextstepid = $cur_stepid;
                        }else{
                            //如果是最后一个审批人，则设置下一步人和审批步骤
                            $tmp_nextapproveby = $nextstepapproveby;
                            $nextstepid = $stepinfo['nextstepid'];
                        }
                        $this->saveskip_nextstepapproveby=$tmp_nextapproveby;
                        $this->insertApproveLog($tmprecord,$approveresult,$this->approveid,$cur_stepid,$approveby,$approveresult,$nextstepid,$tmp_nextapproveby,$seqtime,$stepseq,$logconcurrentid);
                    }
                }
                continue;
            }else if($this->skiptypearr[$cur_stepid] == 'emptyapprover'){
                //审批人为空时触发‘自动跳过’
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
					approveresult,createdtime,nextstepid,nextstepapproveby,countersigner,nextstep_countersigner,seqtime,stepseq,logconcurrentid,isnewlog)';
		$query .= 'value(?,?,?,?,?,?,?,now(),?,?,?,?,?,?,?,"yes")';
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
            && isset($_REQUEST['userid_'.$tmp_sequence])&&!empty($_REQUEST['userid_'.$tmp_sequence])){
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
    //审批人去重功能，需要判断是否为会签
    //如果是会签，则需要在针对不同的审批人进行判断，不能直接跳过
    public function ApproverDuplicateRemoval($stepid,$record,$prestepid=0){
        //获取当前步骤的审批人去重设置
        global $approvestepinfo_arr,$adb,$current_user,$selectapprovecrmid_len;
        $approveid = $this->approveid;
        $stepinfo = $approvestepinfo_arr[$approveid][$stepid];
        
        $approverremovetype = $stepinfo['approverremovetype'];//审批人去重类型
        $countersigner = $stepinfo['countersigner'];//是否为会签
        //未设置审批人去重则不需要判断
        
        if(empty($approverremovetype) || $approverremovetype == 'no'){
            return 'no';
        }
        //根据审批人去重参数，从审批人日志中需要去重的审批人
        $allow_removeapprover_arr = array();
        $last_approvelog = $this->last_approvelog;

        //duan 20231107 如果当前操作步骤是反审批,则不判断审批人重复自动通过
        if($last_approvelog['approveresult'] == 5 || $last_approvelog['stepid'] == -2 ){
            return 'no';
        }

        //如果是提交审批，则以当前用户作为需要去重的审批人
        if($this->issubmit == 'yes'){
            $allow_removeapprover_arr[] = $current_user->id;
            //edit:can 20230329   63440	付款单审批流，审批流名称： 付款单自动审批 
            if($approverremovetype!='approversamesubmitter')
                 return 'no';
        }else{
            //获取最近一次提交审批的记录
            $sql = "SELECT approved_by,id from ld_approvelog where crmid = ? AND stepid = -1 AND approveresult = 1 ORDER BY seqtime desc limit 1;";
            $result = $adb->pquery($sql,array($record));
            
            if($adb->num_rows($result)>0){
                $submitter = $adb->query_result($result,0,'approved_by');//提交人
                $start_approvelogid = $adb->query_result($result,0,'id');//开始提交审批的日志id
            }else{
                return 'no';
            }
            
            //根据审批人去重类型，获取到所有可以去重的审批人
            switch($approverremovetype){
                case 'approversamesubmitter': //当审批人和提交人相同时去重
                    //获取最近一次提交审批的记录中的提交人
                    $allow_removeapprover_arr[] = $submitter;
                   
                break;
                case 'usefirst'; //当同一个审批人多次出现时-仅保留第一个
                 
                    //获取最近一次的提交记录后,所有已审批过的审批人
                    $query = "SELECT DISTINCT approved_by from ld_approvelog where crmid = ? AND approveresult in (1,6) AND id > ?;";
                    $result = $adb->pquery($query,array($record,$start_approvelogid));
                    $num_rows = $adb->num_rows($result);
                    for($i=0;$i<$num_rows;$i++){
                        $approve_by = $adb->query_result($result,$i,'approved_by');
                        $allow_removeapprover_arr[] = $approve_by;
                    }
                    
                    //如果当前的审批日志的结果是通过，则将当前用户作为审批人加入

                    if($last_approvelog['stepid']==$prestepid && in_array($last_approvelog['approveresult'],array(1,6))){
                        $allow_removeapprover_arr[] = $current_user->id;
                        $allow_removeapprover_arr = array_unique($allow_removeapprover_arr);
                    }
                break;
                case 'continueremove'; //当同一个审批人多次出现时-仅在连续出现时去重
                    //获取上一个审批步骤的审批人
                    //如果出现连续跳过步骤的情况，则直接使用上一个步骤的去重审批人
                    if(isset($this->orgin_approveby_arr[$prestepid])&&is_array($this->orgin_approveby_arr[$prestepid])){
                        $allow_removeapprover_arr = $this->orgin_approveby_arr[$prestepid];
                    }else{
                        $query = "SELECT approved_by,result,stepid from ld_approvelog where crmid = ? AND approveresult = 1 AND id > ? order by id desc;";
                        $result = $adb->pquery($query,array($record,$start_approvelogid));
                        $num_rows = $adb->num_rows($result);
                        //如果当前的审批日志的结果是通过，则将当前用户作为审批人加入
                        $last_approvelog = $this->last_approvelog;
                        if($last_approvelog['stepid']==$prestepid && in_array($last_approvelog['approveresult'],array(1,6))){
                            $last_stepid = $prestepid;
                            $allow_removeapprover_arr[] = $current_user->id;
                        }
                        for($i=0;$i<$num_rows;$i++){
                            $tmp_stepid = $adb->pquery($result,$i,'stepid');
                            if($last_stepid >0 && $tmp_stepid != $last_stepid){
                                break;
                            }
                            $approveresult = $adb->pquery($result,$i,'result');
                            $approve_by = $adb->query_result($result,$i,'approved_by');
                            //审批通过或加签时记录审批人
                            if($approveresult == 1 || $approveresult == 6){
                                $allow_removeapprover_arr[] = $approve_by;
                                $last_stepid = $tmp_stepid;
                            }
                        }
                    }
                break;
                default:
                break;
            }
        }
        
        
        $isnewapprove = 'no';
        $approveobj=Approve::getInstance($this->approvemodule,$isnewapprove);
        $tmp_sequence = 0;//预留并发步骤的位置
        //获取当前步骤的审批人
        if($selectapprovecrmid_len <=1 && isset($_REQUEST['nextstep_'.$tmp_sequence]) && $_REQUEST['nextstep_'.$tmp_sequence] == $stepid 
        &&isset($_REQUEST['userid_'.$tmp_sequence])&&!empty($_REQUEST['userid_'.$tmp_sequence])){
            $nextapproveby = $_REQUEST['userid_'.$tmp_sequence];
        }else{
            $approvetype = $stepinfo['approvetype'];
            $approvevalue = $stepinfo['approvevalue'];
            $emptyapproverdeal = $stepinfo['emptyapproverdeal'];
            if(!empty($last_approvelog['nextstepapproveby']) && $last_approvelog['nextstepid']==$stepid){
                $nextapproveby = $last_approvelog['nextstepapproveby'];
            }else{
                $nextapproveby = $approveobj->getApproveBy($approvetype,$approvevalue,$record,$emptyapproverdeal);
            }
        }
       
        //下一步审批人数组
        $nextapproveby_arr = explode(',',trim($nextapproveby,','));
        $this->orgin_approveby_arr[$stepid] = $nextapproveby_arr;
        
        //记录成功去重的审批人
        $approveremove_arr = array();
        $approver_autopass = 'no';
        //根据步骤是否设置会签和下一审批人数量来判断是否可以去重
        
        if(sizeof($nextapproveby_arr) == 0){
            //审批人为空时不需要判断去重（其实审批人为空上一步已经判断过了，做个错误处理）
            return $approver_autopass;
        }else if($countersigner != 'yes'||sizeof($nextapproveby_arr)==1){
            foreach($nextapproveby_arr as $tmp_userid){
                if(in_array($tmp_userid,$allow_removeapprover_arr)){
                    //非会签审批只需要判断一个审批人在去重范围内，就可以直接跳过
                    $this->skiptypearr[$stepid] = 'approveremove';
                    $approveremove_arr[] = $tmp_userid; 
                    $approver_autopass = 'yes';//判断是否触发自动跳过
                    break;
                }
            }
        }else{
            //如果设置了会签，且下一步审批人数量大于1
            $approver_autopass = 'yes';
            foreach($nextapproveby_arr as $tmp_userid){
                //会签审批里的每一个审批人都需要判断是否在去重范围内
                if(in_array($tmp_userid,$allow_removeapprover_arr)&&!in_array($tmp_userid,$approveremove_arr)){
                    //获取到需要去重的用户名单
                    $approveremove_arr[] = $tmp_userid;
                    $have_autopass_approver = 'yes'; 
                }else{
                    $approver_autopass = 'no';//存在一个审批人未去重则自动跳过失败
                }
            }
            //如果所有的审批人都在去重范围内，则判断成功跳过步骤
            if($approver_autopass == 'yes'){
                $this->skiptypearr[$stepid] = 'approveremove';
            }else if($have_autopass_approver == 'yes'){
                //如果会签审批中部分审批人触发了审批去重，则需要跳过部分审批人
                $this->skiptypearr[$stepid] = 'approveremove';
                $this->skipstepinfo[]=array("curstepid"=>$stepid,"nextstepid"=>$stepid,'concurrentid'=>0,'logcurrentid'=>0,'seqtime'=>'','countersigner'=>'yes');
                
            }
            
        }
         
        $this->approveremove_arr[$stepid] = $approveremove_arr;
        return $approver_autopass;
    }
}
?>