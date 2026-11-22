<?php
/**
 *  获取审批步骤信息 
 *  reason:微信端审批界面调整，明细界面下方通过、驳回、转审
 *  date:2017-11-27
 *  editor:xxs
 **/
class cls_Approve_StepWX{
    public $record;
    public $module;
    public $approve;
    public $approveid;      //审批流程id
    public $stepid;         //审批步骤id
    public $laststepid;     //上一步审批步骤id
    public $maxstepid;      //最后一步审批步骤id
    public $maxSequence;    
    public $stepname;
    public $ended;
    public $step;           //是否允许指定审批步骤
    public $sequence;
    public $nextspecifyapproverid;    //是否允许指定审批人(1:否，0：是)
    public $approvevalue;   //下一步审批人    
    public $approvetype;    //下一步审批人类型（指定用户，指定角色，部门等待)
    public $nextstepid;     //下一步审批步骤id
    public $nextstep_concurrentid;//下一步并发ID
    public $empty_approve_by_delete=0;     //删除审批步骤或流程造成的审批数据异常   0正常，1异常
    public $approvelog_countersigner;
    public $approvelog_curstepby;
    public $approvelog_augmentsinger;//加签
    public $approvelog_concurrentid;//审批日志表
    public $approvelog_approveresult;
    public $islastconcurrentstep='no';//并发步骤最后一步，yes:是，no:否
    public $approvelogid;//审批日志表主键ID(并发需要用到)
    public $augmentsinger;//当前步骤是否加签
    public $concurrentid;//当前步骤并发ID
    public $isAugmentsigner;//是否加签过，yes:加签过
    public $approveremarkrequire;//判断审核意见是否必填
    public $approvalauthority;//审批权限区块中的参数
    public $approvecommonobj;
    public $list2;
    public $isnewlog;
    public $have_writesign;

    public function __construct($record,$module,$list2){
        $this->record = $record;
        if(empty($module)) $module=getSalesEntityType($record);
        $this->module = $module;
        $this->list2 = $list2;
        $this->approvelog_countersigner='no';
        
        crm_load_class_file("ApproveCommon","modules/Approve");
        $this->approvecommonobj = ApproveCommon::getInstance($module);
        
    }
    
    public function getApproveInfo(){
        global $global_regop;
        //获取审批信息前，判断是否启用审批
        $ApproveModuleInfo = $this->approvecommonobj->getApproveModuleInfo();
        $module = $this->module;
        if(!empty($module)&&!isset($ApproveModuleInfo[$module])){
            return array();
        }

        $approveinfo=$this->approvecommonobj->approveStatus($this->record);
        $approveid = $approveinfo['approveid'];
        $this->isnewlog = $approveinfo['isnewlog'];
        $this->approve = $approve = $this->approvecommonobj->getApproveobjByApproveid($approveid);
        
        $this->approvelog_countersigner=$approveinfo['nextstep_countersigner'];//nextstep_countersigner：审批日志本步骤是否会签
        $this->approvelog_curstepby=$approveinfo['nextstepapproveby'];//edit:can 20200715 获取当前步骤的审批人有哪些，用于当前步骤是会签的时候，同意按钮的下一步审批人
      
        $this->approveid = $approveid;
        $this->stepid = $approveinfo['nextstepid'];
        $this->laststepid = $approveinfo['stepid'];	//上一步
        $this->approvelog_concurrentid=$approveinfo['logconcurrentid'];//审批日志的中并发步骤ID
        $this->approvelogid=$approveinfo['approvelogid'];//审批日志ID
        $this->approvelog_augmentsinger=$approveinfo['augmentsinger'];//加签状态
        $this->approvelog_approveresult=$approveinfo['approveresult'];
        $this->isAugmentsigner=$approve->getIsaugmentsinger($approveinfo['approveresult'],$approveinfo['logconcurrentid'],$this->record,$approveinfo['nextstepid'],$approveinfo['stepid']);
        $this->islastconcurrentstep='no';   
        //edit:can 20210510 045822: （企业微信移动端-kfbcrm）工具区块-自定义17，单据编号“37”，审批流“并发审批成员”，并发一级审批，审批人操作通过审批，提示审批步骤为空
        $this->nextstepid=$approveinfo['nextstepid'];

        $this->have_writesign = 'no';
        if(!isset($global_regop)){
            $global_regop=RegOp::getInstance();
        }
        if($global_regop->gethandleWriteSign_interface() == 1){
            $this->have_writesign = 'yes';
        }

        if(!empty($this->approvelog_concurrentid))
        {
          
             $this->islastconcurrentstep=$approve->getisLastStepConcurrent($this->record,$this->approvelog_concurrentid,$this->approveid);
           
        }
        //根据审批流程区分是使用新的逻辑还是旧的逻辑
        if($this->isnewlog == 'yes'){
            $approvelist = $this->getApproveInfoNew();
        }else{
            $approvelist = $this->getApproveInfoOld();
        }
        return $approvelist;
    }
    
    //获取该审批流程最后一步骤信息
    public function getTopApproveStepInfo(){
        global $adb;
        $query="select ld_approve.name,ld_approvestep.id as maxstepid ,ld_approvestep.sequence as  maxsequence
        from ld_approve left join ld_approvestep on ld_approve.id=ld_approvestep.approveid 
        where ld_approve.id=? 
        order by ld_approvestep.sequence desc,ld_approvestep.id desc limit 1";
        $result=$adb->pquery($query,array($this->approveid));
        if($adb->num_rows($result) > 0){
            $this->maxstepid = $adb->query_result($result,0,'maxstepid');
            $this->maxSequence = $adb->query_result($result,0,'maxsequence');
        }else{
            //审批流程被删除
            
            $this->empty_approve_by_delete = 1;
        }
    }
    
    //获取当前审批步骤信息
    public function getCurrentApproveStepInfo(){
        global $adb;
        $query="select * from ld_approvestep where approveid=? and id=?";
    
        $result=$adb->pquery($query,array($this->approveid,$this->stepid));
        if($adb->num_rows($result) > 0){
            $this->stepname=$adb->query_result($result,0,'name');
            $this->ended=$adb->query_result($result,0,'ended');
            $this->step=$adb->query_result($result,0,'step');
            $this->sequence=$adb->query_result($result,0,'sequence');
            $this->nextspecifyapproverid=$adb->query_result($result,0,'specifyapproverid');
            $this->concurrentid=$adb->query_result($result,0,'concurrentid');//当前步骤的并发ID
            $this->augmentsinger=$adb->query_result($result,0,'augmentsinger');//当前步骤是否要加签（yes:加签会签，no:加签会签，空值代表不需要加签
            $this->approveremarkrequire = $adb->query_result($result,0,'approveremarkrequire');//审核意见是否必填
            $this->writesignrequired = $adb->query_result($result,0,'writesignrequired');//手写签名必填
            $this->writesignlogtype = $adb->query_result($result,0,'writesignlogtype');//手写签名类型
            $this->approvalauthority = ldcrm_json_decode(html_entity_decode($adb->query_result($result,0,'approvalauthority')));//审批权限区块中的参数
            $this->specifystep=$adb->query_result($result,0,'step');
            if($this->stepid == $this->maxstepid){
                $this->ended = 0;
            }
            if($this->have_writesign == 'no'){
                $this->writesignrequired = 'no';
                $this->writesignlogtype = '';
            }
        }elseif($this->stepid > 0){
                
            $this->empty_approve_by_delete = 1;
        }

    }
    
    //获取下一步审批步骤信息
    public function getNextApproveStepInfo(){
        global $adb;
        $query="select approvevalue,approvetype,concurrentid from ld_approvestep where approveid=?  ";
        if($this->sequence < $this->maxSequence){
            if(!empty($this->sequence)){
                
                if($this->islastconcurrentstep=='yes'&&$this->approvelog_concurrentid>0)
                {   
                    //并发步骤的最后一步

                    $query .= " and sequence>=".(intval($this->sequence)+1);
                }
                else
                    $query .= " and sequence>".$this->sequence;
            }
            $query .= ' order by sequence asc  limit 1';
        }else{
            if(empty($this->maxstepid))
            {
                $this->maxstepid=0;
            }
            $query .= " and id=".$this->maxstepid;
        }

        $result=$adb->pquery($query,array($this->approveid));

        if($adb->num_rows($result) > 0){
            $this->approvevalue = $adb->query_result($result,0,'approvevalue');
            $this->approvetype = $adb->query_result($result,0,'approvetype');
            $concurrentid= $adb->query_result($result,0,'concurrentid');
            //edit:can 20210510 45815: （企业微信移动端-kfbcrm）工具区块-自定义17，单据编号“ZDY17”，审批流“并发条件”，由于设置的条件，单据跳过了并发的一级并发审批，二级并发审批通过后，又进入了二级并发审批
            $this->nextstep_concurrentid=$concurrentid;
        }else if($this->islastconcurrentstep!='yes'&&$this->approvelog_concurrentid<=0){
            //下一步审批步骤被删除
          
            $this->empty_approve_by_delete = 1;
        }
    }
    /**
     * 
     * 转审
     * */
    public function getTurnContent(){
        global $adb,$current_user;
        
        if(($this->approvelog_countersigner=='yes'&&$this->approvelog_approveresult!=6)
           ||($this->approvelog_approveresult==6 && $this->augmentsinger=='yes')){
            //当前步骤是会签审批或者加签的会签
            $this->nextstepid = $this->stepid;
            $nextSteps[]=array(
                'stepid'=>$this->stepid,
                'stepname'=>$this->stepname,
                'specifyapproverid'=>1,
                
                'selected'=>'',
            );
           $nextstepby=$this->approvelog_curstepby;
            $nextapproved_bys=explode(",",$nextstepby);
            $nextsetpbyuser='';
            foreach($nextapproved_bys as $tmpindex=>$tmp_approveuserid){
                 if($tmp_approveuserid==$current_user->id)
                 {
                    continue;//删除当前审批人
                 }
                 $nextsetpbyuser.=$tmp_approveuserid.',';
            }
            $nextsetpby = rtrim($nextsetpbyuser,',');
            
            if($nextsetpby=='')
            {
                //如果当前步骤审批人是会签的最后一人，则需要从审批流程获取下一步审批人
            }
            else
                return $nextSteps;
        }
        $sqlnextset = "select id,approvevalue,specifyapproverid,concurrentid from ld_approvestep where approveid=$this->approveid and sequence >= 
        (select sequence from ld_approvestep where approveid=$this->approveid and id =
        (select nextstepid from ld_approvelog where approveid = $this->approveid and crmid = $this->record order by id desc limit 1 )) and id <>
        (select nextstepid from ld_approvelog where approveid = $this->approveid and crmid = $this->record order by id desc limit 1 )  order by sequence asc limit 1 ";
        $result = $adb->pquery($sqlnextset);
        $nextsetpid = $adb->query_result($result,0,'id');
        $concurrentid=$adb->query_result($result,0,'concurrentid');
       
        $nextSteps=array();
        if(!empty($this->approvelog_concurrentid))
        {
    			//chj 2021/3/1144935: （http://121.36.209.7:85/crm/ [^]，企业微信小程序）客户问题（梁文乐），待审批中付款单查看详情一直显示加载中     
    			//感觉这句话在这函数中没有用到。
                $islastconcurrentstep=$this->approve->getisLastStepConcurrent($this->record,$this->approvelog_concurrentid,$this->approveid);
                if($islastconcurrentstep=='no')
                    $this->nextstep_concurrentid=0;
       }
          
        if(!empty($this->approvelog_concurrentid)&&$islastconcurrentstep=='no')
        {
            //并发步骤
            //edit:can 20210510 045822: （企业微信移动端-kfbcrm）工具区块-自定义17，单据编号“37”，审批流“并发审批成员”，并发一级审批，审批人操作通过审批，提示审批步骤为空
        }
         
        else if($this->step){//是否允许指定下一步骤，0，是，1否
            //concurrentid<=0：删除有并发的步骤
           
            if($this->nextstep_concurrentid>0)
            {
                $query="select id,name,approvevalue,specifyapproverid,augmentsinger from ld_approvestep 
                where approveid=?   and sequence>=".(intval($this->sequence)+1)." and id<>?  order by sequence limit 1";
                $result=$adb->pquery($query,array($this->approveid,$this->stepid));
                
            }
            else
            {
                 $query="select id,name,approvevalue,specifyapproverid,augmentsinger from ld_approvestep 
                where approveid=? and sequence>=? and id<>?  order by sequence limit 1";
              
                $result=$adb->pquery($query,array($this->approveid,$this->sequence,$this->stepid));
            }
            $this->nextstepid = $adb->query_result($result,0,'id');
            $allow_emptyapprover = $this->approve->get_allow_emptyapprover($this->nextstepid);
            // dump($adb->query_result($result,0,'specifyapproverid'));
            //editor:gyq_20190718 reason:转审问题 0037542
            $nextSteps[]=array(
                'stepid'=>$this->nextstepid,
                'stepname'=>$adb->query_result($result,0,'name'),
                'specifyapproverid'=>$adb->query_result($result,0,'specifyapproverid'),
                'countersigner'=>'no',
                'augmentsinger'=>'no',
                'concurrentid'=>0,
                'selected'=>'',
                'allow_emptyapprover'=>$allow_emptyapprover //是否允许下一步审批人为空
            );
            
           
        }else{
           
            $query="select * from ld_approvestep where approveid=? and concurrentid<=0 and id <> ? order by sequence";
            $result=$adb->pquery($query,array($this->approveid,$this->stepid));
            $num_rows=$adb->num_rows($result);
            for($i=0;$i<$num_rows;$i++){
                $selected='no';
                $concurrentid=$adb->query_result($result,$i,'concurrentid');
                $augmentsinger=$adb->query_result($result,$i,'augmentsinger');
                
                if($nextsetpid==$adb->query_result($result,$i,'id'))
                {
                    $selected='yes';
                    $this->nextstepid = $nextsetpid;
                }
               $countersigner='no';
               if($adb->query_result($result,$i,'id')==$this->stepid)
               {
                    $countersigner=$this->approvelog_countersigner;
               }
               $stepid = $adb->query_result($result,$i,'id');
               $allow_emptyapprover = $this->approve->get_allow_emptyapprover($stepid);//是否允许下一步审批人为空c
                $nextSteps[]=array(
                                'stepid'=>$stepid,
                                'stepname'=>$adb->query_result($result,$i,'name'),
                                'specifyapproverid'=>$adb->query_result($result,$i,'specifyapproverid'),
                                'countersigner'=>$countersigner,
                                'augmentsinger'=>$$augmentsinger,//加签
                                'concurrentid'=>$concurrentid,//并发步骤的ID
                                'selected'=>$selected,
                                'allow_emptyapprover'=>$allow_emptyapprover 
                             );
            
            }
        }
        return $nextSteps;
    }
    
    //通过
    public function getPassInfo(){
        global $current_user;
        $pass = array();
        if(!in_array('approvepermit',$this->list2)) return $pass;
      
        $this->getTurnContent();
      
        if(($this->approvelog_countersigner=='yes'&&$this->approvelog_approveresult!=6)
           ||($this->approvelog_approveresult==6 && $this->augmentsinger=='yes')){
            $nextstep_countersigner_user=array();
            $nextstepby=$this->approvelog_curstepby;
            $nextapproved_bys=explode(",",$nextstepby);
            $nextsetpbyuser='';
            foreach($nextapproved_bys as $tmpindex=>$tmp_approveuserid){
                 if($tmp_approveuserid==$current_user->id)
                 {
                    continue;//删除当前审批人
                 }
                 $nextsetpbyuser.=$tmp_approveuserid.',';
            }
            $nextstepby = rtrim($nextsetpbyuser,',');
            //会签步骤的最后一个人审批，获取的下一步审批人为空
             $nextstep_countersigner_user=$nextstepby;
            
        }
        $logconcurrentid=$this->approvelog_concurrentid;//审批日志的并发表示
        $approvelog_augmentsinger=$this->approvelog_augmentsinger;//审批日志是否加签（yes:加签会签，no:加签或签)
        $approvelog_result=$this->approvelog_approveresult;
        $augmentsinger=$this->augmentsinger;//当前步骤是否加签
        $tmp_augmentsinger=$augmentsinger;
        $augmentsingerlabel='通过并增加本步骤审批人';
        $allow_emptyapprover=$this->approve->get_allow_emptyapprover($this->nextstepid);//当前步骤是否允许审批人为空
         if($this->islastconcurrentstep=='no'&&$logconcurrentid>0)
            {
                //edit:can 20210510 0045814: （企业微信移动端-kfbcrm）工具区块-自定义17，单据编号“ZDY16”，审批流“并发条件”，二级并发，操作审批第一个步骤后，直接进入了三级并发
                $this->nextstep_concurrentid=0;
            }
        if($this->isAugmentsigner=='yes')//已加签过
        {
            $tmp_augmentsinger='';
            $augmentsingerlabel='';
        }
    
        if(empty($nextstepby))
                $nextstepby = $this->approve->getApproveBy($this->approvetype,$this->approvevalue,$this->record);
       
        if($this->stepid!=$this->maxstepid||$nextstep_countersigner_user!=""){//判断是否为最后一步
        ////$nextstep_countersigner_user:表示当前登录用户是会签步骤的最后一人
            $pass[] = array('approvestatus'=>1,'label'=>getFixedLabel('CONTINUEAPPROVALSTEP'),
                    'nextstep'=>$this->nextstepid,'nextstepby'=>$nextstepby,'augmentsinger'=>$tmp_augmentsinger,'augmentsingerlabel'=>$augmentsingerlabel
                    ,'logconcurrentid'=>$logconcurrentid,'approvelogid'=>$this->approvelogid, 'concurrentid'=>$this->nextstep_concurrentid,'allow_emptyapprover'=>$allow_emptyapprover);
        }
      if($this->islastconcurrentstep=='no'&&$this->approvelog_concurrentid>0)
      {
        //并发
        $pass=[];
         $pass[] = array('approvestatus'=>1,'label'=>getFixedLabel('CONTINUEAPPROVALSTEP'),
                    'nextstep'=>$this->nextstepid,'nextstepby'=>$nextstepby,'augmentsinger'=>$tmp_augmentsinger,'augmentsingerlabel'=>$augmentsingerlabel
                    ,'logconcurrentid'=>$logconcurrentid,'approvelogid'=>$this->approvelogid, 'concurrentid'=>$this->nextstep_concurrentid,'allow_emptyapprover'=>$allow_emptyapprover);
        
      }
       else if($this->ended == 0&&$nextstep_countersigner_user==""){//$nextstep_countersigner_user:表示当前登录用户是会签步骤的最后一人
            
            $pass[] = array('approvestatus'=>2,'label'=>getFixedLabel('SUCCESSENDPROCESS')
            ,'augmentsinger'=>$tmp_augmentsinger,'augmentsingerlabel'=>$augmentsingerlabel,'nextstep'=>0
            ,'logconcurrentid'=>0,'concurrentid'=>0,'approvelogid'=>$this->approvelogid,'allow_emptyapprover'=>$allow_emptyapprover);
        }
        
       if($this->islastconcurrentstep=='yes'&&$this->approvelog_concurrentid>0)
        {
           $tmpseq=intval($this->sequence)+1;
         
           if($tmpseq>intval($this->maxSequence))
           {
                $pass=[];
                $pass[] = array('approvestatus'=>2,'label'=>getFixedLabel('SUCCESSENDPROCESS')
                ,'augmentsinger'=>$tmp_augmentsinger,'augmentsingerlabel'=>$augmentsingerlabel,'nextstep'=>0
                ,'logconcurrentid'=>$logconcurrentid,'concurrentid'=>0,'approvelogid'=>$this->approvelogid,'allow_emptyapprover'=>$allow_emptyapprover);
           }
        }
        return $pass;
    }
    
    //不通过
    public function getFailInfo(){
        global $current_user;
        $fail['approve'] = array();
        $fail['cancel'] = array();
        //xxy 2023-12-27 并发审批需要根据getConcurrentApproveStatus重新获取审批信息
        $approveinfo = $this->approvecommonobj->getConcurrentApproveStatus($this->record);
        $approveid = $approveinfo['approveid'];
        $this->isnewlog = $approveinfo['isnewlog'];
        $this->approve = $approve = $this->approvecommonobj->getApproveobjByApproveid($approveid);
        $this->approvelog_countersigner=$approveinfo['nextstep_countersigner'];//nextstep_countersigner：审批日志本步骤是否会签
        $this->approvelog_curstepby=$approveinfo['nextstepapproveby'];//edit:can 20200715 获取当前步骤的审批人有哪些，用于当前步骤是会签的时候，同意按钮的下一步审批人
        $this->approveid = $approveid;
        $this->stepid = $approveinfo['nextstepid'];
        $this->laststepid = $approveinfo['stepid'];	//上一步
        $this->approvelog_concurrentid=$approveinfo['logconcurrentid'];//审批日志的中并发步骤ID
        $this->approvelogid=$approveinfo['approvelogid'];//审批日志ID
        $this->approvelog_augmentsinger=$approveinfo['augmentsinger'];//加签状态
        $this->approvelog_approveresult=$approveinfo['approveresult'];
        $this->isAugmentsigner=$approve->getIsaugmentsinger($approveinfo['approveresult'],$approveinfo['logconcurrentid'],$this->record,$approveinfo['nextstepid'],$approveinfo['stepid']);
        $this->islastconcurrentstep='no';
        $this->empty_approve_by_delete = 0;
        $this->getTopApproveStepInfo();

        $approve=$this->approve;
       
        $focus= cls_Instance::get_module_Instance($this->module);
        $cancelbtn=$approve->getCancelApprovedBtn($this->module,$this->record,$focus->column_fields,'');
       // if(empty($cancelbtn))
         //   return $fail;
        $tablename=$focus->table_name;
        $tableindex=$focus->table_index;
        global $adb,$current_user;
        $sql="select   currentapprover from $tablename  where $tableindex=?  ";
        $result=$adb->pquery($sql,array($this->record));
        $currentapprover=$adb->query_result($result,0,'currentapprover');
        $currentapprover_arr=explode(",",(string)$currentapprover);
        crm_load_class_file('cls_ApproveInfo','modules/Approve');
        $ApproveInfoObj=new cls_ApproveInfo($approve);
        $havecancelprofile = $ApproveInfoObj->CheckCancelApproveProfile($this->module,$current_user);

        // dump($this->empty_approve_by_delete);

        if($this->empty_approve_by_delete > 0 ){
            if(is_array($currentapprover_arr)&&in_array($current_user->id,$currentapprover_arr))
                 $fail['approve'][] = array('approvestatus'=>4,'label'=>getFixedLabel('NOTPASSRETURNCHARGE'));

            if(!empty($cancelbtn))  {
                $fail['cancel'][]=array('canceltype'=>'0','label'=>getFixedLabel('IFNOTPASSEDTHENRETURNTOTHEPREVIOUSSTEP'),'approveid'=>$this->approveid);
                if(is_admin($current_user) || $havecancelprofile == 'yes'){
                    $fail['cancel'][]=array('canceltype'=>'3','label'=>getFixedLabel('NOTPASSRETURNCHARGE'),'approveid'=>$this->approveid);
                }
            }
            return $fail;
        }
        if(!in_array('approvepermit',$this->list2)&&!in_array('cancelapprove',$this->list2)) return $fail;
        

        $username = $current_user->user_name;
        
        //edit:can 20210510 045822: （企业微信移动端-kfbcrm）工具区块-自定义17，单据编号“37”，审批流“并发审批成员”，并发一级审批，审批人操作通过审批，提示审批步骤为空
        $this->nextstepid=$approveinfo['nextstepid'];
        if(!empty($this->approvelog_concurrentid))
        {
            
                $this->islastconcurrentstep=$approve->getisLastStepConcurrent($this->record,$this->approvelog_concurrentid,$this->approveid);
            
        }
        if(in_array('approvepermit',$this->list2)){
            //判断当前步骤是否是第一步审批
            $prestep_approveby = $this->approve->getApprovePreStepApproveBy($this->record);
            
            if($prestep_approveby>=1){
                //并发步骤目前不支持 “不通过，返回上一步""
                $fail['approve'][]=array('approvestatus'=>5,'label'=>getFixedLabel('IFNOTPASSEDTHENRETURNTOTHEPREVIOUSSTEP'),'laststepid'=>$this->laststepid);
            }
            $fail['approve'][] = array('approvestatus'=>4,'label'=>getFixedLabel('NOTPASSRETURNCHARGE'));
            if($this->ended == 0 && $this->approvalauthority['showcancelbill'] == 'yes'){
                $fail['approve'][] = array('approvestatus'=>3,'label'=>getFixedLabel('FAILENDPROCESS'));
            }
        }
        else if(!empty($cancelbtn))  {
            // if(empty($this->approvelog_concurrentid))//并发步骤目前不支持 “不通过，返回上一步""
                $fail['cancel'][]=array('canceltype'=>'0','label'=>getFixedLabel('IFNOTPASSEDTHENRETURNTOTHEPREVIOUSSTEP'),'approveid'=>$this->approveid);
            if(is_admin($current_user) || $havecancelprofile == 'yes'){
                $fail['cancel'][]=array('canceltype'=>'3','label'=>getFixedLabel('NOTPASSRETURNCHARGE'),'approveid'=>$this->approveid);
            }
        }
        
        /*
        if($username=='admin'&&in_array('cancelapprove',$this->list2)){
            $approvenew = $this->approve->submitApprove(getTabid($this->module)); 
            $fail[]=array('canceltype'=>'2','label'=>getFixedLabel('APPROVE_CANCEL_SELECTAPPROVE'),'list'=>$approvenew);
        }*/
        return $fail;
    }
    
    //转审
    public function getTrunInfo(){
        $turn = array();
        if($this->approvelog_countersigner=='yes')return array();
        if(!in_array('approvepermit',$this->list2)) return $turn;
        $list = $this->getTurnContent();
        
      //  dump($list);
        //editor:gyq_20190718 reason:转审问题 0037542
        //0037542: （落落计划）企业微信>灵当CRM>审批中心>选择合同编号为SO25的单据进行审批>选择转审：选择转审后该单据直接审批成功了，而不是转到另一个人这里审批。（需要补丁）
        $turn['approveversion']=1;
        if($this->specifystep==0)//允许指定下一步的审批步骤
           $turn['nextspecifyapproverid'] = "0";
        else
        {
            if($list[0]['specifyapproverid']==0){//指定当前步骤的审批人
                 $turn['nextspecifyapproverid'] = "0";
            }
            else{
                 $turn['nextspecifyapproverid'] = "1";
            }
           
        }
   
        if($list[0]['stepid']){
            $turn['list'] =$list;
        }else{
            $turn['list'] = array();
            $turn['nextspecifyapproverid'] = 1;
        }
        /** 
        * @edit:diony 
        * @date:2020-09-03 
        * @description:自动获取上一次签名图片
        */
        $turn['autographImg'] = $this->getAutographImg();
        if(empty($turn['list'])&&$turn['nextspecifyapproverid']==1) return array(); 
        return $turn;
    }

    //自动获取上一次签名图片
    public function getAutographImg(){
        global $adb,$current_user;
        $approve_autograph_path = '';
        $query="select approve_autograph_path,createdtime 
                from ld_approvelog 
                where approved_by = ? and approve_autograph_path != '' ORDER BY createdtime desc limit 1;";
        $result=$adb->pquery($query,array($current_user->id));
        if($adb->num_rows($result) > 0){
            $approve_autograph_path = $adb->query_result($result,0,'approve_autograph_path');
            if(!file_exists(globalStatic::$root_directory.$approve_autograph_path)){
                $approve_autograph_path = '';
            }
        }
        return $approve_autograph_path;
    }
    //旧审批流程适用方法
    public function getApproveInfoOld(){
        $approvelist['approveversion']=1;
        $approvelist['haveapprovefield']='yes';
        $approvelist['pass'] = array();
        $approvelist['turn'] = array();
        $approvelist['fail'] = array();
        //editor:gyq_20181228 0035887: 反审批功能改进：单据审批后，审批流程删除，无法反审批
        $this->getTopApproveStepInfo();
         
        //获取当前审批步骤信息
        $this->getCurrentApproveStepInfo();
        //获取下一步骤的审批人信息
        $this->getNextApproveStepInfo();
        
        if(in_array('approvepermit',$this->list2)){
            $approvelist['pass'] = $this->getPassInfo();
            $approvelist['turn'] = $this->getTrunInfo();
            $approvelist['list'] = array('record'=>$this->record,'modulename'=>$this->module,
                                    'approveid'=>$this->approveid,'stepid'=>$this->stepid);
            $approvelist['remarkrequire']=$this->approveremarkrequire;
            $approvelist['writesignrequired']=$this->writesignrequired;
            $approvelist['writesignlogtype']=$this->writesignlogtype;
        }
        
        if($this->empty_approve_by_delete > 0){
            $approvelist = array();
            $approvelist['pass'] = array();
            $approvelist['turn'] = array();
            $approvelist['list'] = array();
        }
       
      
        if($this->islastconcurrentstep!='yes'&&$this->approvelog_concurrentid>0)
        {
              //如果是并发步骤，且当前步骤不是并发步骤的最后一步
            $approvelist['turn'] = array();
        }
        $approvelist['fail'] = $this->getFailInfo();
        /** 
        * @edit:diony 
        * @date:2020-09-03 
        * @description:自动获取上一次签名图片
        */
        $approvelist['autographImg'] = $this->getAutographImg();
        $approvelist['haveapprovefield']='yes';
        return $approvelist;
    }
    //新审批流程适用方法
    public function getApproveInfoNew(){
        $approvelist['approveversion']=1;

        $approvelist['pass'] = array();
        $approvelist['turn'] = array();
        $approvelist['fail'] = array();
        //反审批功能改进：单据审批后，审批流程删除，无法反审批
        //$this->getTopApproveStepInfo();
        
        //获取当前审批步骤信息
        $this->getCurrentApproveStepInfo();
        
        //获取下一步骤的审批人信息
        $this->getNextApproveStepInfoNew();
        
        if(in_array('approvepermit',$this->list2)){
            $approvelist['pass'] = $this->getPassInfoNew();
            $approvelist['turn'] = $this->getTrunInfoNew();
            $approvelist['list'] = array('record'=>$this->record,'modulename'=>$this->module,
                                    'approveid'=>$this->approveid,'stepid'=>$this->stepid);
            $approvelist['remarkrequire']=$this->approveremarkrequire;
            $approvelist['writesignrequired']=$this->writesignrequired;
        }
        
        if($this->empty_approve_by_delete > 0){
            $approvelist = array();
            $approvelist['pass'] = array();
            $approvelist['turn'] = array();
            $approvelist['list'] = array();
        }
       
       
        if($this->islastconcurrentstep!='yes'&&$this->approvelog_concurrentid>0)
        {
              //如果是并发步骤，且当前步骤不是并发步骤的最后一步
            $approvelist['turn'] = array();
        }
        $approvelist['fail'] = $this->getFailInfo();
        /** 
        * @edit:diony 
        * @date:2020-09-03 
        * @description:自动获取上一次签名图片
        */
        //设置了手写签名必填，且每次重签时，不获取手写签名的图片
        if($this->writesignrequired == 'yes' && $this->writesignlogtype == 'rewrite'){
        }else{
            $approvelist['autographImg'] = $this->getAutographImg();
        }
        $approvelist['haveapprovefield']='yes';
        return $approvelist;
    } 
    
    //获取下一步审批步骤信息
    public function getNextApproveStepInfoNew(){
        global $adb,$approvestepinfo_arr;
        //获取下一步审批步骤id
        $nextstepinfo = $this->approve->getnextstepinfo(0,$this->nextstepid,$this->approveid,$this->record);
        
        if($nextstepinfo['nextstepid'] > 0){
            $this->nextstepid = $nextstepinfo['nextstepid'];
            $tmp_stepinfo = $approvestepinfo_arr[$this->approveid][$this->nextstepid];
            $this->approvevalue = $tmp_stepinfo['approvevalue'];
            $this->approvetype = $tmp_stepinfo['approvetype'];
            $this->emptyapproverdeal = $tmp_stepinfo['emptyapproverdeal'];
            $concurrentid= $tmp_stepinfo['concurrentid'];
            $this->nextstep_concurrentid=$concurrentid;
        }else if($this->islastconcurrentstep!='yes'&&$this->approvelog_concurrentid<=0){
            //下一步审批步骤被删除
            $this->ended = 0;
            $this->maxstepid = $this->stepid;
        }
    }
    
    //通过
    public function getPassInfoNew(){
        global $current_user;
        $pass = array();
        if(!in_array('approvepermit',$this->list2)) return $pass;
      
        //$this->getTurnContent();
        if(($this->approvelog_countersigner=='yes'&&$this->approvelog_approveresult!=6)
           ||($this->approvelog_approveresult==6 && $this->augmentsinger=='yes')){
            $nextstep_countersigner_user=array();
            $nextstepby=$this->approvelog_curstepby;
            $nextapproved_bys=explode(",",$nextstepby);
            $nextsetpbyuser='';
            foreach($nextapproved_bys as $tmpindex=>$tmp_approveuserid){
                 if($tmp_approveuserid==$current_user->id)
                 {
                    continue;//删除当前审批人
                 }
                 $nextsetpbyuser.=$tmp_approveuserid.',';
            }
            $nextstepby = rtrim($nextsetpbyuser,',');
            //会签步骤的最后一个人审批，获取的下一步审批人为空
             $nextstep_countersigner_user=$nextstepby;
            if(!empty($nextstepby)){
                $this->nextstepid = $this->stepid;
            }
        }
        $logconcurrentid=$this->approvelog_concurrentid;//审批日志的并发表示
        $approvelog_augmentsinger=$this->approvelog_augmentsinger;//审批日志是否加签（yes:加签会签，no:加签或签)
        $approvelog_result=$this->approvelog_approveresult;
        $augmentsinger=$this->augmentsinger;//当前步骤是否加签
        $tmp_augmentsinger=$augmentsinger;
        $augmentsingerlabel=getFixedLabel('Pleasesettheapprovers');
        $allow_emptyapprover=$this->approve->get_allow_emptyapprover($this->nextstepid);//当前步骤是否允许审批人为空
         if($this->islastconcurrentstep=='no'&&$logconcurrentid>0)
            {
                //edit:can 20210510 0045814: （企业微信移动端-kfbcrm）工具区块-自定义17，单据编号“ZDY16”，审批流“并发条件”，二级并发，操作审批第一个步骤后，直接进入了三级并发
                $this->nextstep_concurrentid=0;
            }
        if($this->isAugmentsigner=='yes')//已加签过
        {
            $tmp_augmentsinger='';
            $augmentsingerlabel='';
        }
    
        if(empty($nextstepby))
                $nextstepby = $this->approve->getApproveBy($this->approvetype,$this->approvevalue,$this->record,$this->emptyapproverdeal);
       
        if($this->stepid!=$this->maxstepid||$nextstep_countersigner_user!=""){//判断是否为最后一步
        ////$nextstep_countersigner_user:表示当前登录用户是会签步骤的最后一人
            $pass[] = array('approvestatus'=>1,'label'=>getFixedLabel('CONTINUEAPPROVALSTEP'),
                    'nextstep'=>$this->nextstepid,'nextstepby'=>$nextstepby,'augmentsinger'=>$tmp_augmentsinger,'augmentsingerlabel'=>$augmentsingerlabel
                    ,'logconcurrentid'=>$logconcurrentid,'approvelogid'=>$this->approvelogid, 'concurrentid'=>$this->nextstep_concurrentid,'allow_emptyapprover'=>$allow_emptyapprover);
        }
      if($this->islastconcurrentstep=='no'&&$this->approvelog_concurrentid>0)
      {
        //并发
        $pass=[];
         $pass[] = array('approvestatus'=>1,'label'=>getFixedLabel('CONTINUEAPPROVALSTEP'),
                    'nextstep'=>$this->nextstepid,'nextstepby'=>$nextstepby,'augmentsinger'=>$tmp_augmentsinger,'augmentsingerlabel'=>$augmentsingerlabel
                    ,'logconcurrentid'=>$logconcurrentid,'approvelogid'=>$this->approvelogid, 'concurrentid'=>$this->nextstep_concurrentid,'allow_emptyapprover'=>$allow_emptyapprover);
        
      }
       else if($this->ended == 0&&$nextstep_countersigner_user==""){//$nextstep_countersigner_user:表示当前登录用户是会签步骤的最后一人
            
            $pass[] = array('approvestatus'=>2,'label'=>getFixedLabel('SUCCESSENDPROCESS')
            ,'augmentsinger'=>$tmp_augmentsinger,'augmentsingerlabel'=>$augmentsingerlabel,'nextstep'=>0
            ,'logconcurrentid'=>0,'concurrentid'=>0,'approvelogid'=>$this->approvelogid,'allow_emptyapprover'=>$allow_emptyapprover);
        }
        
       if($this->islastconcurrentstep=='yes'&&$this->approvelog_concurrentid>0)
        {
           $tmpseq=intval($this->sequence)+1;
         
           if($tmpseq>intval($this->maxSequence))
           {
                $pass=[];
                $pass[] = array('approvestatus'=>2,'label'=>getFixedLabel('SUCCESSENDPROCESS')
                ,'augmentsinger'=>$tmp_augmentsinger,'augmentsingerlabel'=>$augmentsingerlabel,'nextstep'=>0
                ,'logconcurrentid'=>$logconcurrentid,'concurrentid'=>0,'approvelogid'=>$this->approvelogid,'allow_emptyapprover'=>$allow_emptyapprover);
           }
        }
        return $pass;
    }
    //转审
    public function getTrunInfoNew(){
        $turn = array();
        if($this->approvelog_countersigner=='yes')return array();
        if(!in_array('approvepermit',$this->list2)) return $turn;
        $list = $this->getTurnContentNew();
        
      //  dump($list);
        //editor:gyq_20190718 reason:转审问题 0037542
        //0037542: （落落计划）企业微信>灵当CRM>审批中心>选择合同编号为SO25的单据进行审批>选择转审：选择转审后该单据直接审批成功了，而不是转到另一个人这里审批。（需要补丁）
        $turn['approveversion']=1;
        if($this->specifystep==0)//允许指定下一步的审批步骤
           $turn['nextspecifyapproverid'] = "0";
        else
        {
            if($list[0]['specifyapproverid']==0){//指定当前步骤的审批人
                 $turn['nextspecifyapproverid'] = "0";
            }
            else{
                 $turn['nextspecifyapproverid'] = "1";
            }
           
        }
   
        if($list[0]['stepid']){
            $turn['list'] =$list;
        }else{
            $turn['list'] = array();
            $turn['nextspecifyapproverid'] = 1;
        }
        /** 
        * @edit:diony 
        * @date:2020-09-03 
        * @description:自动获取上一次签名图片
        */
        $turn['autographImg'] = $this->getAutographImg();
        if($turn['nextspecifyapproverid']==1) return array(); 
        return $turn;
    }
    //获取转审步骤信息
    public function getTurnContentNew(){
        global $adb,$current_user,$approvestepinfo_arr;
        
        if(($this->approvelog_countersigner=='yes'&&$this->approvelog_approveresult!=6)
           ||($this->approvelog_approveresult==6 && $this->augmentsinger=='yes')){
            //当前步骤是会签审批或者加签的会签
            $this->nextstepid = $this->stepid;
            $nextSteps[]=array(
                'stepid'=>$this->stepid,
                'stepname'=>$this->stepname,
                'specifyapproverid'=>1,
                
                'selected'=>'',
            );
           $nextstepby=$this->approvelog_curstepby;
           
            $nextapproved_bys=explode(",",$nextstepby);
            $nextsetpbyuser='';
            foreach($nextapproved_bys as $tmpindex=>$tmp_approveuserid){
                 if($tmp_approveuserid==$current_user->id)
                 {
                    continue;//删除当前审批人
                 }
                 $nextsetpbyuser.=$tmp_approveuserid.',';
            }
            $nextsetpby = rtrim($nextsetpbyuser,',');
            
            if($nextsetpby=='')
            {
                //如果当前步骤审批人是会签的最后一人，则需要从审批流程获取下一步审批人
            }
            else
                return $nextSteps;
        }
        $nextstepinfo = $this->approve->getnextstepinfo(0,$this->stepid,$this->approveid,$this->record);
        
        if($nextstepinfo['nextstepid']>0 ){
            $nextsetpid = $nextstepinfo['nextstepid'];
        }       
        $nextSteps=array();
        if(!empty($this->approvelog_concurrentid))
        {
    			//chj 2021/3/1144935: （http://121.36.209.7:85/crm/ [^]，企业微信小程序）客户问题（梁文乐），待审批中付款单查看详情一直显示加载中     
    			//感觉这句话在这函数中没有用到。
                $islastconcurrentstep=$this->approve->getisLastStepConcurrent($this->record,$this->approvelog_concurrentid,$this->approveid);
                if($islastconcurrentstep=='no')
                    $this->nextstep_concurrentid=0;
       }
          
        if(!empty($this->approvelog_concurrentid)&&$islastconcurrentstep=='no')
        {
            //并发步骤
            //edit:can 20210510 045822: （企业微信移动端-kfbcrm）工具区块-自定义17，单据编号“37”，审批流“并发审批成员”，并发一级审批，审批人操作通过审批，提示审批步骤为空
        }
         
        else if($this->step){//是否允许指定下一步骤，0，是，1否
            //concurrentid<=0：删除有并发的步骤
           
            //if($this->nextstep_concurrentid>0)
//            {
//                $query="select id,name,approvevalue,specifyapproverid,augmentsinger from ld_approvestep 
//                where approveid=?   and sequence>=".(intval($this->sequence)+1)." and id<>?  order by sequence limit 1";
//                $result=$adb->pquery($query,array($this->approveid,$this->stepid));
//                
//            }
//            else
//            {
//                 $query="select id,name,approvevalue,specifyapproverid,augmentsinger from ld_approvestep 
//                where approveid=? and sequence>=? and id<>?  order by sequence limit 1";
//              
//                $result=$adb->pquery($query,array($this->approveid,$this->sequence,$this->stepid));
//            }
            if($nextsetpid >0){
                $this->nextstepid = $nextsetpid;
                $tmp_stepinfo = $approvestepinfo_arr[$this->approveid][$this->nextstepid];
                $nextSteps[]=array(
                    'stepid'=>$this->nextstepid,
                    'stepname'=>$tmp_stepinfo['name'],
                    'specifyapproverid'=>$tmp_stepinfo['specifyapproverid'],
                    'countersigner'=>'no',
                    'augmentsinger'=>'no',
                    'concurrentid'=>0,
                    'selected'=>'',
                    'allow_emptyapprover'=>$tmp_stepinfo['allow_emptyapprover'] //是否允许下一步审批人为空
                );
                
            }
            
            
           
        }else{
            
            $all_stepinfo = $approvestepinfo_arr[$this->approveid];
            foreach($all_stepinfo as $tmp_stepinfo){
                if($tmp_stepinfo['steptype'] != 'approver'){
                    continue;
                }
                $selected='no';
                $concurrentid= $tmp_stepinfo['concurrentid'];
                $augmentsinger=$tmp_stepinfo['augmentsinger'];
                $stepid = $tmp_stepinfo['stepid'];
                
                if($nextsetpid==$stepid)
                {
                    $selected='yes';
                    $this->nextstepid = $nextsetpid;
                }
                $countersigner='no';
                if($stepid==$this->stepid)
                {
                    $countersigner=$this->approvelog_countersigner;
                    continue;
                }
                
                $allow_emptyapprover = $tmp_stepinfo['allow_emptyapprover'];//是否允许下一步审批人为空c
                $nextSteps[]=array(
                                'stepid'=>$stepid,
                                'stepname'=> $tmp_stepinfo['name'],
                                'specifyapproverid'=>$tmp_stepinfo['specifyapproverid'],
                                'countersigner'=>$countersigner,
                                'augmentsinger'=>$$augmentsinger,//加签
                                'concurrentid'=>$concurrentid,//并发步骤的ID
                                'selected'=>$selected,
                                'allow_emptyapprover'=>$allow_emptyapprover
                             );
                
                
            }
        }
        return $nextSteps;
    }
}
?>