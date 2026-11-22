<?php
/**************************************************************************
**edit:kevin
**date:2013-08-15
**reason:
**************************************************************************/
/*
approveresult:

1:审批中
4：不通过返回负责人
3：审批失败
2：审批成功
5:不通过，返回上一步*/
/*

stepid -2是反审批
stepid -1提交审批
*/

define('D_A_S_UNAPPROVED','未提交');//未提交

define('D_A_S_APPROVALOF','审批中');//审批中

define('D_A_S_APPROVED','已批准');//已批准
define('D_A_S_REJECTED','已拒绝');//已拒绝
define('D_A_S_DISMISSED','已驳回');//已驳回
define('D_A_S_CHECKED','已审核');
define('WHERE_SYSTEM_APPROVE',D_A_S_APPROVED);
define("APPROVE_APPROVED",2);//已批准
define("Approve_Concurrent_Stepseq",0.00001);//并发步骤步长
class Approve{
    private static $_instance;//单例返回类实例
	private $approveInfo = array();

    public $isNeedApprovalClient = 'yes';// 是否获取审批委托人
    public $approvechange_check = 'no';
    public $column_value; //表头字段值
    public $ApproveStepobj;
    public $insertStepID_arr = [];
    public $moduleName;
    public $module_name ;
    public $recordApprovestatus;//记录单据审批状态信息
    public $last_approvelog;
    public static function getInstance($module,$isnewapprove='no') {
        /**
         * 单例返回当前类的实例
         * @author Tujt 2014-07-24
         */
        if($isnewapprove == 'yes'){
            //创建新的审批流程的对象
            crm_load_class_file("ApproveNew","modules/Approve");
            return ApproveNew::getInstance($module);
        }else{
            if(!(self::$_instance[$module] instanceof self)){//是否为当前类的实例
                self::$_instance[$module] = new self($module);
            }
            return self::$_instance[$module];
        }
        
    }
    public $module;
    public  function __construct($module='')
    {
        $this->module=$module;
    }
    /**
     * 防止被克隆
     * @author Tujt 2015-05-28
     */
    private function __clone(){}
    //判断审批流程是否在使用中
    public function approveUsed($approveid,$blockid){
        crm_load_class_file('cls_ApproveInfo','modules/Approve');
        $ApproveInfoObj=new cls_ApproveInfo($this);
        return $ApproveInfoObj->approveUsed($approveid,$blockid);
    }
    /**
     * 
     * 获取单据的最近审批信息，主要用于审批同步的判断
     * $record:单据id
     * $module:单据所在模块name
    */
    public function getlastapproveinfo($record,$module)
    {
        crm_load_class_file('cls_ApproveInfo','modules/Approve');
        $ApproveInfoObj=new cls_ApproveInfo($this);
        return $ApproveInfoObj->getlastapproveinfo($record,$module);
    }
    /**
     * edit:kevin
     * date:2013-09-09
     * reason:获取单据审批状态及下一个步骤审批人
     */
    public function approveStatus($record){
        crm_load_class_file('cls_ApproveInfo','modules/Approve');
        $ApproveInfoObj=new cls_ApproveInfo($this);
        return $ApproveInfoObj->approveStatus($record);
    }
    /**
     * edit:kevin
     * date:2013-09-09
     * reason:当前用户是否有编辑,提交,审批
     */ 
    public function blocksButton($smownerid,$record,$module=""){
        crm_load_class_file('cls_ApproveInfo','modules/Approve');
        $ApproveInfoObj=new cls_ApproveInfo($this);
        return $ApproveInfoObj->blocksButton($smownerid,$record,$module);
    }
    public function getAllApprovesByUserid($tabid,$userid){
        crm_load_class_file('cls_ApproveInfo','modules/Approve');
        $ApproveInfoObj=new cls_ApproveInfo($this);
        return $ApproveInfoObj->getAllApprovesByUserid($tabid,$userid);
    }
    /**
     * edit:cyb
     * date:2015-12-14
     * reason:获取审批单据可以用的审批流程
     * parameter：approveallocatetype --0表示所有用户，1表示按部门分配，2表示按用户分配。
     */
    public function submitApprove($tabid){
        global $current_user,$weixin_user;
        return $this->getAllApprovesByUserid($tabid,$current_user->id);
    }
    public function getApproveByInfo($approvetype,$approvevalue,$focus){
        crm_load_class_file('cls_ApproveInfo','modules/Approve');
        $ApproveInfoObj=new cls_ApproveInfo($this);
        return $ApproveInfoObj->getApproveByInfo($approvetype,$approvevalue,$focus);
    }
    /**
     * edit:kevin
     * date:2013-09-10
     * reason:获取审核人ids
     */
    public function getApproveBy($approvetype,$approvevalue,$crmid,$emptyapproverdeal=''){
        crm_load_class_file('cls_ApproveInfo','modules/Approve');
        $ApproveInfoObj=new cls_ApproveInfo($this);
        return $ApproveInfoObj->getApproveBy($approvetype,$approvevalue,$crmid,$emptyapproverdeal);
    }

    function  getApproveuserinfoByid($approvetype,$approvevalue,$approve_userid,$emptyapproverdeal=''){
        crm_load_class_file('cls_ApproveInfo','modules/Approve');
        $ApproveInfoObj=new cls_ApproveInfo($this);
        return $ApproveInfoObj->getApproveuserinfoByid($approvetype,$approvevalue,$approve_userid,$emptyapproverdeal);
    }
    /**
     * edit:kevin
     * date:2013-09-24
     * 回撤
     */ 
    function antiApprove($record,$approveid,$stepid){
        global $adb,$current_user;
        $query="select t.id from (select max(id) as id from ld_approvelog where crmid=? and approveid=?) as t INNER join
            (select id from ld_approvelog where crmid=? and approveid=? and stepid=? and approved_by=?) as t1 on t.id=t1.id";
        $result=$adb->pquery($query,array($record,$approveid,$record,$approveid,$stepid,$current_user->id));
        $num_rows=$adb->num_rows($result);
        return $num_rows;
    }
    function getApproveByName($approveby){
        global $default_charset;
        if(empty($approveby))return '';
        $ids=explode(',',$approveby);
        $approvebyname = '';
        foreach($ids as $id){
            $approvebyname .=getUserFullName($id).",";
        }
        $approvebyname=mb_substr($approvebyname,0,strlen($approvebyname)-1,$default_charset);
        return $approvebyname;        
    }
    /**
     * edit:kevin
     * date:2013-09-16
     * reason:审批历史//审批日志
     */ 
    function approveLog($record){
        crm_load_class_file('cls_approvesubmit','modules/Approve');
        $approvesubmitobj=new cls_approvesubmit($this);
        return $approvesubmitobj->approveLog($record);
    }
    /**
     * edit:kevin
     * date:2013-09-23
     * reason:单据编辑
     */ 
    public function EditBlocks($smownerid,$record){
        crm_load_class_file('cls_ApproveAction','modules/Approve');
        $ApproveActionObj=new cls_ApproveAction($this);
        return $ApproveActionObj->EditBlocks($smownerid,$record);
    }
    /**
     * edit:kevin
     * date:2013-09-23
     * reason:单据删除
     */ 
    function deleteBlocks($smownerid,$record){
        $blockbuttons=$this->blocksButton($smownerid,$record);
        $isdelete=$blockbuttons[3];
        $approvestatus=$blockbuttons[4];
        $alertstr="###SUCCESS###";
        if($isdelete!=0){
            switch($approvestatus){
                case 1:
                $alertstr="###APPROVE###".getFixedLabel('THISDOCUMENTISUNDEREXAMINATIONAND');
                break;
                case 2:
                $alertstr="###APPROVE###".getFixedLabel('THISRECORDHASBEENAPPROVEDNOTALL');
                break;
            }
        }
        return $alertstr;
    }
    /**
     * edit:can
     * date:20140221
     * reason:获得审批数量
     * */
    function getApproveCount($tabtype='')
    {
        crm_load_class_file('cls_Approve_countListView','modules/Approve');
        $obj = new cls_Approve_countListView($tabtype);
        $approveinfo = $obj->getapprovelist();
        $total = 0;
        foreach($approveinfo as $val){
            $total += $val['num'];
        }
        return $total;
    }
	/**
	 * 获取有审批的模块
	 * @author Tujt 2015-04-10
	 */
	public static function getApproveModuleInfo() {
        crm_load_class_file('cls_ApproveCache','modules/Approve');
        return cls_ApproveCache::getApproveModuleInfo();
	}
    /**
     * 是否为并发步骤的最后一步
     * yes:是
     * */
   public function getisLastStepConcurrent($record,$logconcurrentid,$approveid)
   {
        global $adb;
        $sql='select id from ld_approvelog where crmid=? and logconcurrentid=? and isfinished="no" limit 2';

        $tmp_result=$adb->pquery($sql,array($record,$logconcurrentid));

        if($adb->num_rows($tmp_result)<=1)
        {
            return 'yes';
        }
        return 'no';

   }
    
    /**
     * 判断审批的步骤是否为会签审批，会签：yes
     * 审批的步骤为会签需要满足两个条件，审批步骤设置为会签，审批步骤的审批人为多个
     * $approveuser:审批人id
     * $stepid:审批步骤id
     * $countersigner:步骤是否为会签
     * */
   public function getisCounterSigner($countersigner,$approveuser,$stepid){
       return $countersigner;
        if($countersigner=='no'){
            return 'no';
        }
        if(trim($approveuser,',')==''||empty($stepid)){
            return 'no';
        }
        $arr=array_filter(explode(',',$approveuser));
        if(sizeof($arr)>1&&$stepid>0){
            return 'yes';
        }
        return $stepid;
   }
	/*
     * editor:gyq_05
     * reason:获取审批步骤详情
     * */
    public function getStepInfo($stepid){
        crm_load_class_file('cls_ApproveInfo','modules/Approve');
        $ApproveInfoObj=new cls_ApproveInfo($this);
        return $ApproveInfoObj->getStepInfo($stepid);
	}
    /*
     * editor:gyq_05
     * reason:获取提交审批步骤详情
     * */
    public function getApproveStepInfo($approveid,$record,$userid=0){

        global $adb,$current_user;
        
        $sql = "SELECT name,approvevalue,approvetype,specifyapproverid
            ,countersigner,augmentsinger,ld_approvestep.id
            ,ld_approvestep.concurrentid,ld_approvestep.emptyapproverdeal
         FROM ld_approvestep WHERE approveid=$approveid order by sequence limit 1 ";
       
        $result = $adb->pquery($sql);
        $nextStepInfo_arr=[];
        $rows=$adb->num_rows($result);
        if ($rows > 0) {
            
            $concurrentid=$adb->query_result($result,0,'concurrentid');
            if($concurrentid>0)
            {
                $sql = "SELECT name,approvevalue,approvetype,specifyapproverid
                    ,countersigner,augmentsinger,ld_approvestep.id
                    ,ld_approvestep.concurrentid,ld_approvestep.emptyapproverdeal
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
    			$records = explode(',',(string)$record);
    			//在批量：如果选择了多个单据的情况下，默认取第一个
                $nextStepApproverIds=[];
                $nextStepApprover='';
                $stepuserids='';
                $stepuseridtonamearr = array();
                if($userid>0){
                    if($nextStepType == 5)$userid =$current_user->id;
                    $nextStepApproverIds = $this->getApproveuserinfoByid($nextStepType,$nextStepValue,$userid);
                }
                else
                    $nextStepApproverIds = $this->getApproveBy($nextStepType,$nextStepValue,$records[0]);
                    
                //duan 2022-3-31 提交审批时如果下一步审批人为空，则根据‘审批人为空时处理方式’参数替换审批人信息
                $emptyapproverdeal=$adb->query_result($result,$i,'emptyapproverdeal');
                if(empty($nextStepApproverIds) && $this->get_allow_emptyapprover($stepid,$nextStepType) == 'yes'){ //如果该类型可以设置对应参数

                    $nextStepApproverIds = $this->getTransferUsers($emptyapproverdeal);
                }
    			if(!empty($nextStepApproverIds)){
    				$sql = "SELECT group_concat(last_name order by id asc ) guser,group_concat(id order by id asc) as stepuserids 
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
                //duan 2022-3-25 判断允许下一步审批人为空时是否允许提交审批
                $allow_emptyapprover = $this->get_allow_emptyapprover($stepid,$nextStepType);
                 //本步骤是否为会签需要满足两个条件1：审批步骤设为会签，2：审批人是2个或者2个以上
                $countersigner=$this->getisCounterSigner($countersigner,$nextStepApproverIds,$stepid);
                //edit:can 20220707 //edit:can 20220707 http://123.135.130.44:85/chengtao/
                 $nextStepInfo_arr[]=array('nextstepname'=>$nextStepName,'stepid'=>$stepid,'newstepapprover'=>$nextStepApprover,
                'specifyapproverid'=>$specifyapproverid,'stepuserids'=>$stepuserids
                ,'countersigner'=>$countersigner,'augmentsinger'=>$augmentsinger,
                'concurrentid'=>$concurrentid,'stepuseridtonamearr'=>$stepuseridtonamearr,
                'allow_emptyapprover'=>$allow_emptyapprover,'emptyapproverdeal'=>$emptyapproverdeal,'nextsteptype'=>$nextStepType,'nextstepvalue'=>$nextStepValue);
            }
        }
        return $nextStepInfo_arr;
    }



	/**
	 * 获取有客户字段的模块
	 * @author Tujt 2015-04-15
	 */
	public static function getAccountModule() {
        crm_load_class_file('cls_ApproveCache','modules/Approve');
        return cls_ApproveCache::getAccountModule();
	}
    /**
     * edit:kevin
     * date:2013-09-24
     * reason:我的审批中心
     */
    public function getApproveLogQuery($approveresult,$searchquery=''){
        crm_load_class_file('cls_ApproveInfo','modules/Approve');
        $ApproveInfoObj=new cls_ApproveInfo($this);
        return $ApproveInfoObj->getApproveLogQuery($approveresult,$searchquery);
    }
    /**
     * edit:kevin
     * date:2013-09-24
     * reason:单据是否启用审批
     */ 
    function startBlocksApprove(){
        crm_load_class_file('cls_ApproveCache','modules/Approve');
        return cls_ApproveCache::startBlocksApprove();
    }
    
    function getAllApproveBy($record){
        global $adb,$default_charset;
        $query="select approvetype,approvevalue from ld_approvestep right join         
        (select distinct approveid from ld_approvelog where crmid=$record) as t1 on ld_approvestep.approveid=t1.approveid";
        $result=$adb->query($query);
        $num_rows=$adb->num_rows($result);
        $userids = '';
        for($i=0;$i<$num_rows;$i++){
            $approvetype=$adb->query_result($result,$i,'approvetype');
            $approvevalue=$adb->query_result($result,$i,'approvevalue');
            $userids .=$this->getApproveBy($approvetype,$approvevalue,$record).",";
        }
       
        $userids=mb_substr($userids,0,strlen($userids)-1,$default_charset);
        
        return $userids;
    }

	/**
	 * 传入单据ID、审批流程ID，将该单据提交到审批流程ID对应的流程中
	 * @param String $module 模块名
	 * @param Integer $crmid 单据ID
	 * @param Integer $approvevalue 审批流程ID
	 * @returns 存入审批历史表中以提交审批
	 * @project PROT144 审批功能改进
	 * @author Tujt 2014-12-25
	 */
	public function ApproveSubmit($module,$crmid,$approveid,$diaplsytime='') {
         crm_load_class_file('cls_approvesubmit','modules/Approve');
         $approvesubmitobj=new cls_approvesubmit($this);
         return $approvesubmitobj->submit($module,$crmid,$approveid,$diaplsytime );
	}


    public function SaveApprovedLog($module,$approvelog){
        crm_load_class_file('cls_ApproveAction','modules/Approve');
        $ApproveActionObj=new cls_ApproveAction($this);
        return $ApproveActionObj->SaveApprovedLog($module,$approvelog);
    }
    /**
     * 获取审批流程下的所有审批步骤信息，按照sequence asc
     * edit:can 2020-12-10
     * */
    public function getAllStepInfoByApproveid($approveid)
    {
        global $approvestepinfo_arr;
        global $adb;
        if(is_array($approvestepinfo_arr)&&array_key_exists($approveid,$approvestepinfo_arr))
        {
            return $approvestepinfo_arr[$approveid];

        }
         $sql='select * from ld_approvestep where approveid=? order by sequence asc  ';
        $tmpresult=$adb->pquery($sql,array($approveid));
        $tmprows=$adb->num_rows($tmpresult);
        for($tmpi=0;$tmpi<$tmprows;$tmpi++)
        {
            $tmpapprovalauthority = $adb->query_result($tmpresult,$tmpi,'approvalauthority');
            if(!empty($tmpapprovalauthority)){
                $tmpapprovalauthority = ldcrm_json_decode(html_entity_decode($tmpapprovalauthority));
            }
            $approvestepinfo_arr[$approveid][]=array(
                'sequence'=>$adb->query_result($tmpresult,$tmpi,'sequence')
                ,'stepid'=>$adb->query_result($tmpresult,$tmpi,'id')
                ,'concurrentid'=>$adb->query_result($tmpresult,$tmpi,'concurrentid')
                ,'approvetype'=>$adb->query_result($tmpresult,$tmpi,'approvetype')
                ,'approvevalue'=>$adb->query_result($tmpresult,$tmpi,'approvevalue')
                ,'countersigner'=>$adb->query_result($tmpresult,$tmpi,'countersigner')
                ,'augmentsinger'=>$adb->query_result($tmpresult,$tmpi,'augmentsinger')
                ,'name'=>$adb->query_result($tmpresult,$tmpi,'name')
                ,'emptyapproverdeal'=>$adb->query_result($tmpresult,$tmpi,'emptyapproverdeal')
                ,'approvalauthority'=>$tmpapprovalauthority
            );
        }
        return $approvestepinfo_arr[$approveid];
    }
    /**
     * 判断当前并发步骤是否都为跳过,yes:全部跳过
     * */
    public function checkConcurrentStepAllSkip($concurrentid,$approveid,$approvestepobj)
    {
        //edit:can 2020-12-18 43841: （61mis.com/kfbcrm）并发审批：财务管理-销售发票；单据编号INV30；审批流“销售发票并发跳过”；第一步审批不符合条件跳过，直接进入并发步骤中跳过时，无法进入并发最后一步
      global $approvestepinfo_arr;
      if(!is_array($approvestepinfo_arr))
        {
            $approvestepinfo_arr=[];
            
        }
        if(!array_key_exists($approveid,$approvestepinfo_arr))
                $approvestepinfo_arr[$approveid]=$this->getAllStepInfoByApproveid($approveid);
        $concurrentstepcount=0;
        $curconcurrentstepid_arr=[];
       
        foreach($approvestepinfo_arr[$approveid] as $tmpindex=>$tmpskitstepinfo)
        {
            if($tmpskitstepinfo['concurrentid']>0&&$tmpskitstepinfo['concurrentid']==$concurrentid)
            {
                //当前并发步骤的数量
                $concurrentstepcount++;
                //当前并发步骤的步骤ID
                $curconcurrentstepid_arr[]=$tmpskitstepinfo['stepid'];
                
            }
        }
       
        $curstep_skipcount=0;
        $havecomputerskipstepid_arr=[];
        foreach($approvestepobj->skipstepinfo as $tmpindex=>$tmpskitstepinfo)
        {
            //有两个或两个以上并发步骤 最后一个并发步骤第一步满足，其他都不满足
            if(in_array($tmpskitstepinfo['nextstepid'],$curconcurrentstepid_arr)
                &&$tmpskitstepinfo['nextstepid']!=$approvestepobj->insertStepInfo['nextstepid'])
            {
                if(!in_array($tmpskitstepinfo['nextstepid'],$havecomputerskipstepid_arr))
                {
                     $havecomputerskipstepid_arr[]=$tmpskitstepinfo['nextstepid'];
                
                    $curstep_skipcount++;
                }
            }
        }
     
        if($curstep_skipcount>=$concurrentstepcount)
        {
            //edit:can 2020-12-23 43927: (61mis.com/kfbcrm)并发审批：财务管理-销售发票；单据编号INV45，审批流“销售发票并发跳过”，提交审批后，审批流自动跳过，在并发审批的最后一个步骤时应该审批人审批但自动通过了，而且并发日志没有正确显示
            //并发步骤跳过的数量大于等于当前步骤并发数量
            return 'yes';
            
          
        }
        return 'no';
        
    }
    /**
     * 跳过的步骤最新步骤是并发
     * */
	public function insertSkipStepConcurrentApproveLog($approvestepobj,$skipstepConcurrentinfo,$approvelog_arr)
    {
          global $adb,$approvestepinfo_arr;
         //提交/提交审批跳过，插入了新的并发审批步骤
            $concurrentidStepCount=0;
            $seqtime=$skipstepConcurrentinfo['seqtime'];
            $concurrentid=$skipstepConcurrentinfo['concurrentid'];
            $logconcurrentid=$skipstepConcurrentinfo['logconcurrentid'];
            
            $approveid=$approvelog_arr['approveid'];
            if(!is_array($approvestepinfo_arr))
            {
                $approvestepinfo_arr=[];
                
            }
            if(!array_key_exists($approveid,$approvestepinfo_arr))
                $approvestepinfo_arr[$approveid]=$this->getAllStepInfoByApproveid($approveid);
            
            //$sql='select * from ld_approvestep where approveid=? and concurrentid=? order by sequence asc ';
           // $tmpresult=$adb->pquery($sql,array($approveid,$concurrentid));
            $rows=sizeof($approvestepinfo_arr[$approveid]);
            //$_REQUEST['concurrentidStepCount']=0;
            $startsteqseq=-1;
            for($k=0;$k<$rows;$k++)
            {
                if($approvestepinfo_arr[$approveid][$k]['concurrentid']!=$concurrentid)
                {
                    continue;
                }
                $tmpstepid=$approvestepinfo_arr[$approveid][$k]['stepid'];
               $startsteqseq++;//stepseq是从0开始
                $iscontinue='yes';
               foreach($approvestepobj->skipstepinfo as $tmpindex=>$tmpskitstepinfo)
                {
                    //已经插入到审批日志的并发审批步骤，不需要再插入
                    if($tmpskitstepinfo['curstepid']==$tmpstepid)
                    {
                        $approvestepobj->skipstepinfo[$tmpindex]['logconcurrentid']=$logconcurrentid;
                        
                      
                        $iscontinue='no';
                        break;
                    }
                }
               
                $countersigner=$approvestepinfo_arr[$approveid][$k]['countersigner'];//$adb->query_result($tmpresult,$k,'countersigner');
                $augmentsinger=$approvestepinfo_arr[$approveid][$k]['augmentsinger'];//$adb->query_result($tmpresult,$k,'augmentsinger');
                $approvevalue=$approvestepinfo_arr[$approveid][$k]['approvevalue'];//$adb->query_result($tmpresult,$k,'approvevalue');
                $approvetype=$approvestepinfo_arr[$approveid][$k]['approvetype'];//$adb->query_result($tmpresult,$k,'approvetype');
                
                 if($iscontinue=='no')
                {
                    //edit:can 2020-12-23 43927: (61mis.com/kfbcrm)并发审批：财务管理-销售发票；单据编号INV45，审批流“销售发票并发跳过”，提交审批后，审批流自动跳过，在并发审批的最后一个步骤时应该审批人审批但自动通过了，而且并发日志没有正确显示
                   $stepuserids=0;//跳过的步骤不要再获取userid
                }
                else
                 $stepuserids=$this->getApproveBy($approvetype,$approvevalue,$approvelog_arr['crmid']);//获取用户信息
                $_REQUEST['nextstep_'.$concurrentidStepCount]=$tmpstepid;
                $_REQUEST['stepseq_'.$concurrentidStepCount]=$startsteqseq;
                $_REQUEST['nextstep_countersigner_'.$concurrentidStepCount]=$countersigner;
                $_REQUEST['nextstep_augmentsinger_'.$concurrentidStepCount]=$augmentsinger;
                $_REQUEST['userid_'.$concurrentidStepCount]=$stepuserids;
               
                
                $concurrentidStepCount++;
                   
            }
            
            $tmpconcurrentidStepCount=$_REQUEST['concurrentidStepCount'];
            $_REQUEST['new_concurrentidStepCount']=$_REQUEST['concurrentidStepCount'];
            $_REQUEST['concurrentidStepCount']=$concurrentidStepCount;
            
            $this->insertConcurrentApproveLog($approvestepobj,$approvelog_arr,$seqtime,$logconcurrentid);
            $_REQUEST['concurrentidStepCount']=$tmpconcurrentidStepCount;
            
    }
    /**
     * 插入前端传过来过的并发步骤
     * */
    public function insertConcurrentApproveLog(&$approvestepobj,$approvelog_arr,$seqtime='',$logconcurrentid=0){
        global $adb,$current_user;
        $crmid=$approvelog_arr['crmid'];
        $approveid=$approvelog_arr['approveid'];
        $this->insertStepID_arr = [];
        if(!empty($logconcurrentid))
        {

        }
        else
        {
            $sql='select logconcurrentid from ld_approvelog_concurrent';
            $result=$adb->pquery($sql,array());
            $logconcurrentid=$adb->query_result($result,0,'logconcurrentid');
            $sql='update ld_approvelog_concurrent set logconcurrentid=logconcurrentid+1  ';
            $adb->pquery($sql,array());
        }
        $query = 'insert into ld_approvelog(id,crmid,approveid,stepid,approved_by
        ,approveresult,createdtime,seqtime,nextstepid,nextstepapproveby,countersigner
         ,nextstep_countersigner,augmentsinger,approve_autograph,approve_autograph_path
         ,isfinished,stepseq,logconcurrentid,description)';
        $query .= ' value(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)';
        $timesql='select current_timestamp(6) as seqtime ';
        $timeresult=$adb->pquery($timesql,array());
        if(empty($seqtime))
            $seqtime=$adb->query_result($timeresult,0,'seqtime');
        $concurrentidStepCount=$_REQUEST['concurrentidStepCount'];

        if($concurrentidStepCount<=1)
        {
            return ;
        }

        $isskipallconcurrentstep='no';//高级查询是否跳过所有的并发步骤
        $skipconcrrentstepcount=0;//跳过的并发步骤
        for($i=0;$i<$concurrentidStepCount;$i++)
        {
            $tmpstepid=$_REQUEST["nextstep_$i"];
            $countersigner=$_REQUEST["nextstep_countersigner_$i"];//$adb->query_result($result,$i,'countersigner');
            if($approvelog_arr['stepid'] == -2 || $approvelog_arr['approveresult'] == 5){
                $countersigner = $_REQUEST["countersigner_$i"];
            }
            $augmentsinger=$_REQUEST["nextstep_augmentsinger_$i"];//$adb->query_result($result,$i,'augmentsinger');
            $stepseq=$_REQUEST["stepseq_$i"];
            $description=$_REQUEST['description'];//
            $isskipstep='no';
            foreach($approvestepobj->skipstepinfo as $tmpindex=>$tmpskitstepinfo)
            {
                //找到当前并发步骤的跳过的步骤(有待优化)
                if($tmpskitstepinfo['curstepid']==$tmpstepid)
                {
                    $approvestepobj->skipstepinfo[$tmpindex]['logconcurrentid']=$logconcurrentid;
                    $approvestepobj->skipstepinfo[$tmpindex]['stepseq']=$stepseq;
                    $approvestepobj->skipstepinfo[$tmpindex]['seqtime']=$seqtime;
                    $skipconcrrentstepcount++;
                    $isskipstep='yes';

                    break;
                }
            }
            //echo $isskipstep."<br>";

            if($isskipstep=='yes')
                    continue;

            if(is_array($this->insertStepID_arr)&&in_array($tmpstepid,$this->insertStepID_arr))
            {
                continue;//已经插入过审批步骤不要再插入
            }

            if($approvelog_arr['approveresult'] != 5){
                $this->insertStepID_arr[]=$tmpstepid;
                $this->insertStepID_arr=array_unique($this->insertStepID_arr);
            }

            $approvelogid=$adb->getUniqueID('ld_approvelog');
            $nextsetpby =$_REQUEST["userid_$i"];//获取下一步审批人
            $approve_result = 12;
            //如果下一步审批人为空则进行特殊控制
            if(empty($nextsetpby)){
                $emptyapprover_result = $this->concurrent_emptyapprover_solution($tmpstepid);
                if($emptyapprover_result['type']=='change'){
                    $approve_result = $emptyapprover_result['approveresult'];
                    $nextsetpby = $emptyapprover_result['nextstepapproveby'];
                }
            }

            if($countersigner=='yes')
            {
                //如果是会签，要循环插入数据
               // dump($nextsetpby);
                $tmp_arr=explode(",",trim($nextsetpby,','));
                foreach($tmp_arr as $tmpnextstepby)
                {
                    $param=array($approvelogid,$crmid, $approveid,$tmpstepid,0,$approve_result,'',$seqtime,$tmpstepid,$tmpnextstepby
                        ,$countersigner,'no',$augmentsinger,$approve_autograph,'','no',$stepseq,$logconcurrentid,$description);
                    $adb->pquery($query,$param);
                    $approvelogid=$adb->getUniqueID('ld_approvelog');
                }
            }
            else  //$nextstep_countersigner:一定是：No,
            {
                $param=array($approvelogid,$crmid, $approveid,$tmpstepid,0,$approve_result,'',$seqtime,$tmpstepid,$nextsetpby
                        ,$countersigner,'no',$augmentsinger,$approve_autograph,'','no',$stepseq,$logconcurrentid,$description);
                 $adb->pquery($query,$param);
            }

        }
        if($skipconcrrentstepcount>=$concurrentidStepCount)
        {
            //表示该并发步骤没有满足条件的步骤
            $logconcurrentid=0;
        }
        return array('logconcurrentid'=>$logconcurrentid);
    }
	/**
	 * @author:andy
	 * @data:20141029
	 * @reason:获取模块审批状态字段comumnname
	 * @version:v5.8
	 */
	/* zxm 20221128 该代码未用到 function getApproveFieldColumnname($module) {
		global $adb;
		$sql='SELECT columnname from ld_approvepickfield LEFT JOIN ld_field
			on ld_field.fieldid=ld_approvepickfield.fieldid where ld_field.tabid=?
			and ld_approvepickfield.tabid=?';
		$tabid=getTabid($module);
		$result=$adb->pquery($sql,array($tabid,$tabid));
		if($adb->num_rows($result) > 0)
			return $adb->query_result($result,0,'columnname');
		return '';
	}*/
    /**
     * 获取审批流程是否允许编辑、以及是否允许反审批单据单据
     * @author Liver 2017-02-07
     */
    public function getApproveAllowediting($record){
        crm_load_class_file('cls_ApproveInfo','modules/Approve');
        $ApproveInfoObj=new cls_ApproveInfo($this);
        return $ApproveInfoObj->getApproveAllowediting($record);
    }
	/**
	 * 获取单据反审批权限按钮权限
	 * @param String $module 模块名
	 * @param Integer $record 数据ID
	 * @param Object $fields 当前数据对象结果集($focus->column_fields)
	 * @param Object $approved 审批按钮权限判断($approve->blocksButton结果)
	 * @return 获取反审批权限
	 * @author Tujt 2015-01-05
	 */
	public function getCancelApprovedBtn($module,$record,$fields,$approved) {
        crm_load_class_file('cls_ApproveInfo','modules/Approve');
        $ApproveInfoObj=new cls_ApproveInfo($this);
        return $ApproveInfoObj->getCancelApprovedBtn($module,$record,$fields,$approved);
	}
    public function ApprovedcheckBankMonery($module,$approvelog,$record,$type='') {
        crm_load_class_file('cls_ApproveAction','modules/Approve');
        $ApproveActionObj=new cls_ApproveAction($this);
        $ApproveActionObj->ApprovedcheckBankMonery($module,$approvelog,$record,$type);
    }
    //判断当前步骤是否是第一步审批。判断是否显示：不通过，返回负责人 选项
    public function getApprovePreStepApproveBy($record){
        crm_load_class_file('cls_ApproveInfo','modules/Approve');
        $ApproveInfoObj=new cls_ApproveInfo($this);
        return $ApproveInfoObj->getApprovePreStepApproveBy($record);
    }
	/**
	 * 通过ID自动审批单据
	 * @param Integer $record ID值
	 * @param Integer $approvedtype 审批通过或返回负责人
	 * @param String $description 备注
	 * @author Tujt 2015-05-11
	 */
    public function SaveRecordApproveLog($record,$approvedtype,$description = '',$approvelog_result=''){
        crm_load_class_file('cls_ApproveAction','modules/Approve');
        $ApproveActionObj=new cls_ApproveAction($this);
        return $ApproveActionObj->SaveRecordApproveLog($record,$approvedtype,$description,$approvelog_result);
    }
    /**
     * 获取审批状态对应的图片
     */
    public function getApproveStatus($status){
        crm_load_class_file('cls_ApproveCache','modules/Approve');
        return cls_ApproveCache::getApproveStatus($status);
    }
    
	//判断当前是否处于审批中，并且当前用户是否是当前步骤的审批人
	public function getCurApproveForModulefield($record){
        crm_load_class_file('cls_ApproveInfo','modules/Approve');
        $ApproveInfoObj=new cls_ApproveInfo($this);
        return $ApproveInfoObj->getCurApproveForModulefield($record);
	}

	//判断设置的审批人必填字段是否已填写
	public function getModuleRecordStatus($module_field,$record,$module,$environment){
        crm_load_class_file('cls_ApproveInfo','modules/Approve');
        $ApproveInfoObj=new cls_ApproveInfo($this);
        return $ApproveInfoObj->getModuleRecordStatus($module_field,$record,$module,$environment);
	}
    /**
     * 判断当前步骤是否加签yes:已加签
     * $approvelogid:审批日志表主键值（可以为空)
     * $nextstepid:当前审批步骤ID(审批日志的表最后一条记录的nextstepID字段的值)
     * */
    public function getIsaugmentsinger($approveresult,$approvelogid,$crmid,$nextstepid,$stepid)
    {
        crm_load_class_file('cls_ApproveInfo','modules/Approve');
        $ApproveInfoObj=new cls_ApproveInfo($this);
        return $ApproveInfoObj->getIsaugmentsinger($approveresult,$approvelogid,$crmid,$nextstepid,$stepid);
    }
    /**
     * 审批不同返回上一步的获取，反审批 回撤到上一步
     * */
    public function getBackStepLogIndex($result)
    {
        crm_load_class_file('cls_ApproveInfo','modules/Approve');
        $ApproveInfoObj=new cls_ApproveInfo($this);
        return $ApproveInfoObj->getBackStepLogIndex($result);
    }
    
    function showSubmitPopup($module,&$rSmarty){
        global $weixin_user;
        global $current_user;
        $tabid=getTabid($module);


        $focus = CRMEntity::getInstance($module);
        //$approveinfo = $this->submitApprove($tabid);
        crm_load_class_file("cls_approvestep_change","modules/Approve");
        $approvestep_change_obj = new cls_approvestep_change($module);
        $approvestep_change_obj->set_focus($focus);
        $approvestep_change_obj->set_approveobj($this);
        $approveinfo = $approvestep_change_obj->getApplicableApproveInfo();

        if(empty($approveinfo))
        {
            return ;
        }

        $rSmarty->assign('APPROVEFIRSTSTEP', $nextStepInfo);
        $rSmarty->assign('APPROVE', $approveinfo);
        $rSmarty->assign('RECORD', $record);
        $rSmarty->assign('ApproveModule', $module);
        $rSmarty->assign('APPROVETYPE', $_REQUEST['approvetype']);
        $rSmarty->assign('SELECTLEN', $_REQUEST['selectlen']);
        
        return $approveinfo;
    }
    //判断模块是否启用快速提交
    function Blocksquicksubmit($module){
        crm_load_class_file('cls_ApproveCache','modules/Approve');
        return cls_ApproveCache::Blocksquicksubmit($module);
    }
    //判断模块 已批准/拒绝的单据允许再次提交审批
    public function recordAgainSubmit($module){
        crm_load_class_file('cls_ApproveCache','modules/Approve');
        return cls_ApproveCache::recordAgainSubmit($module);
    }

    //ls 2021-11-26 【1002260】审批流程定制，审批结束重复提交审批时功能优化（保存时提示并更改审批状态）
    public function SaveResetApprovestatus($module){
        crm_load_class_file('cls_ApproveInfo','modules/Approve');
        $ApproveInfoObj=new cls_ApproveInfo($this);
        return $ApproveInfoObj->SaveResetApprovestatus($module);
    }

    //获取所有可以开启审批的模块信息
    public static function getAllModuleInfo() {
        crm_load_class_file('cls_ApproveCache','modules/Approve');
        return cls_ApproveCache::getAllModuleInfo();
	}
    
    /**
	 * 获取单据催审按钮权限
	 * @param String $module 模块名
	 * @param Integer $record 数据ID
     * @param String $crmapprovestatus 单据审批状态
	 * @return 催审按钮权限
	 * @author Tujt 2021-11-19
	 */
    function getExpeditingBtn($module,$record,$crmapprovestatus)
    {
        
        global $adb,$current_user;
        $approvestatus = $this->getApproveStatus($crmapprovestatus);//获取审批状态：审批中：1
        //非审批中单据不显示催审
        if($approvestatus != 1){
            return 0;
        }
        //获取approveid
        //0049090: （81mis.com/kfbcrm/index.php）自定义表单07，ZDYBD07-36，是并发审批步骤；并发审批中，加签审批后，催审按钮不显示了
        //resion: approveStatus函数未获取到approveid并发审批，下一步审批人没有用户自己时,催审按钮不能出现
        $query = 'SELECT approveid FROM ld_approvelog WHERE ld_approvelog.crmid = ? ORDER BY createdtime DESC LIMIT 1';
        $result = $adb->pquery($query,array($record));
        $rows = $adb->num_rows($result);
        if($rows>=0){
            $approveid = $adb->query_result($result,0,'approveid');
        }
        if($approveid<=0){
            return 0 ;
        }
        $tabid = getTabid($module);
        $userapprovearr = $this->getAllApprovesByUserid($tabid,$current_user->id);
        //获取单据审批流程对应“是否启用催审功能”设置的值
        $enableexpediting = 'no';
        foreach($userapprovearr as $index=>$settingapproveinfo){
            $settingenableexpediting = $settingapproveinfo['enableexpediting'];
            $settingapproveid = $settingapproveinfo['approveid'];
            if($settingapproveid == $approveid && $settingenableexpediting == 'yes')
            {
                $enableexpediting = 'yes';
                break;
            }
        }
        if($enableexpediting != 'yes'){
            return 0 ;
        }
        $focus=CRMEntity::getInstance($module);
        $tablename=$focus->table_name;
        $table_index=$focus->table_index;
        
        //获取提交审批人
        $sql = "select approvesubmitter from $tablename where $table_index = ? and deleted=0";
        $result = $adb->pquery($sql,array($record));
        $rows = $adb->num_rows($result);
        $approvelogid = 0;
        if($rows>0){
            $approvesubmitter = $adb->query_result($result,0,'approvesubmitter');
        }
        else{
            return 0;
        }
        //单据审批状态为审批中，催审参数启用，用户角色为单据提交审批人时显示催审按钮
        if($enableexpediting == 'yes' && $approvesubmitter == $current_user->id && $approvestatus == 1){
            return 1;
        }
        return 0;
    }
    
    //获取单据的审批日志中最大id
    function getLatestApprovelogidByCrmid($crmid)
    {
        global $adb;
        $sql = "select max(id) as approvelogid from ld_approvelog where crmid = ?";
        $result = $adb->pquery($sql,array($crmid));
        $rows = $adb->num_rows($result);
        $approvelogid = 0;
        if($rows>0){
            $approvelogid = $adb->query_result($result,0,'approvelogid');
        }
        return $approvelogid;
    }
    //下一步审批人为空时的解决方案
    function emptyapprover_solution($approvelogid){
        global $adb;
        //获取上一条审批日志信息
        $tmp_sql = 'select crmid,approveid,nextstepid,nextstepapproveby from ld_approvelog where id = ?';
        $tmp_result = $adb->pquery($tmp_sql,array($approvelogid));
        if($adb->num_rows($tmp_result)<=0){
            return array();
        }
        //审批人不为空时，不需要执行
        $approveby = $adb->query_result($tmp_result,0,'nextstepapproveby');
        if(!empty($approveby)){
            return array();
        }
        $nextstepid = $adb->query_result($tmp_result,0,'nextstepid');
        //下一步审批步骤为空时不执行操作，审批结束、撤回等情况
        if($nextstepid <= 0){
            return array();
        }
        //获取下一步审批信息
        $nextstepinfo = $this->getStepInfo($nextstepid);
        $approvetype = $nextstepinfo['approvetype'];
        $approvevalue = $nextstepinfo['approvevalue'];
        $emptyapproverdeal = $nextstepinfo['emptyapproverdeal'];
        //获取需要保存的日志信息
        $new_approvelogid = $adb->getUniqueID('ld_approvelog');
        $approve_result = 0;
        $approve_by = -1;
        $nextstepapproveby = 1;
        $query = 'insert into ld_approvelog(id,crmid,description,approveid,stepid,approved_by,approveresult,createdtime,
                    seqtime,nextstepid,nextstepapproveby,countersigner,nextstep_countersigner,approve_autograph,approve_autograph_path,stepseq,urgent)';
        $query .= 'SELECT ?,crmid,description,approveid,nextstepid,?,?,now(),current_timestamp(6),nextstepid,?,
					countersigner,nextstep_countersigner,approve_autograph,approve_autograph_path,stepseq,urgent from ld_approvelog
                    where ld_approvelog.id = ?;';
        //'审批人为空'参数未设置时，默认设置为转交管理员。
        if(empty($emptyapproverdeal)){
            $emptyapproverdeal = 'transfertomanager';
        }
        //可预设审批人为空参数的审批人类型
        if($this->get_allow_emptyapprover($stepid,$approvetype)=='yes'){
            if($emptyapproverdeal == 'autopass'){//审批人为空，自动通过,放到自动跳过里处理
            }else if($emptyapproverdeal == 'transfertomanager'){//审批人为空，自动转交管理员
                $approve_result =15;
                //获取所有管理员id
                $nextstepapproveby = $this->getTransferUsers($emptyapproverdeal);
                //增加转交记录
                $adb->pquery($query,array($new_approvelogid,$approve_by,$approve_result,$nextstepapproveby,$approvelogid));
            }else{//审批人为空，自动转交制定用户
                $approve_result =16;
                //获取选中的成员id
                $nextstepapproveby = $this->getTransferUsers($emptyapproverdeal);
                //增加转交记录
                $adb->pquery($query,array($new_approvelogid,$approve_by,$approve_result,$nextstepapproveby,$approvelogid));
            }
        }else{
            //无预设审批人为空参数，默认转交超级管理员
            $approve_result =15;
            $nextstepapproveby = 1;
            $adb->pquery($query,array($new_approvelogid,$approve_by,$approve_result,$nextstepapproveby,$approvelogid));
        }
        //返回下一步实际审批人
        return array('type'=>'change','nextstepapproveby'=>$nextstepapproveby);
        
    }
    //duan 判断当前步骤是否允许下一步审批人为空时进行审批
    public function get_allow_emptyapprover($stepid,$approvetype=''){
        if(empty($approvetype)){
            $stepinfo = $this->getStepInfo($stepid);
            $approvetype = $stepinfo['approvetype'];
        }
        //目前指定成员和单据负责、创建人不能设置‘审批人为空处理方式’参数
        if(in_array($approvetype,array(1,2,3,4))||$approvetype>6){
            return 'yes';
        }else{
            return 'no';
        }
    }
    
    //duan 并发步骤的审批人为空时，对日志保存值进行处理
    //根据传入的审批步骤id,返回转交的审批人或审批结果
    public function concurrent_emptyapprover_solution($stepid){
        global $adb;
        $stepinfo = $this->getStepInfo($stepid);
        $approvevalue = $stepinfo['approvevalue'];
        $approvetype = $stepinfo['approvetype'];
        //判断当前步骤是否允许下一步审批人为空时进行审批
        $emptyapproverdeal = $stepinfo['emptyapproverdeal'];
        if($this->get_allow_emptyapprover($stepid,$approvetype)=='yes'){
            if($emptyapproverdeal == 'autopass'){//审批人为空，自动通过
                $approve_result =14;
                $type = 'pass';
            }else if($emptyapproverdeal == 'transfertomanager'){//审批人为空，自动转交管理员
                $approve_result =15;
                $type = 'change';
                //获取所有管理员id
                $nextstepapproveby = $this->getTransferUsers($emptyapproverdeal);
            }else{//审批人为空，自动转交制定用户
                $approve_result =16;
                $type = 'change';
                //获取选中的成员id
                $nextstepapproveby = $this->getTransferUsers($emptyapproverdeal);
            }
        }else{
            //缺少相关参数时，默认指向超级管理员（正常情况不会执行到这，为了避免异常）
            $type = 'change';
            $nextstepapproveby = 1;
            $approve_result = 15;
        }
        return array('type'=>$type,'nextstepapproveby'=>$nextstepapproveby,'approveresult'=>$approve_result);
    }
    
    //当审批人为空需要转交时，获取转交的用户id
    public function getTransferUsers($emptyapproverdeal){
        crm_load_class_file('cls_ApproveInfo','modules/Approve');
        $ApproveInfoObj=new cls_ApproveInfo($this);
        return $ApproveInfoObj->getTransferUsers($emptyapproverdeal);
    }
    //按照新的审批日志样式显示日志信息，将同一步骤的操作合并，获取完整的审批流程信息，包括未到达的步骤
    public function getWholeApproveLog($record,$ApprovelogSetInfo){
        crm_load_class_file('cls_approvesubmit','modules/Approve');
        $approvesubmitobj=new cls_approvesubmit($this);
        return $approvesubmitobj->getWholeApproveLog($record,$ApprovelogSetInfo);
    }
    
    //获取审批日志设置信息
    public function getApprovelogSet(){
        crm_load_class_file('cls_ApproveCache','modules/Approve');
        return cls_ApproveCache::getApprovelogSet($this->module);
    }
    
    //获取审批流程信息
    public function getApproveInfo($approveid){
        crm_load_class_file('cls_ApproveInfo','modules/Approve');
        $ApproveInfoObj=new cls_ApproveInfo($this);
        return $ApproveInfoObj->getApproveInfo($approveid);
    }
    //获取审批流程的所有审批步骤
    public function getAllStepinfoByRecord($approveid,$record){
        return $this->getAllStepInfoByApproveid($approveid);
    }
    //获取提交审批时显示的审批日志，显示所有审批步骤和审批人
    public function getSubmitApprovelog($approveid,$record){
        //加入当前流程待审批的步骤
        global $current_user;
        if($record>0 && $approveid >0){
            $max_showstepcount = 2;//审批日志最大展示条数
            $showstepcount = 0;//已选中条数
            $arr_index = -1;
            $allstepinfo = $this->getAllStepInfoByApproveid($approveid);
            $tmp_approveloginfo = array();
            if(sizeof($allstepinfo)>0){
                //增加提交审批操作
                $arr_index += 1;
                $tmp_approvestep['stepname'] = getFixedLabel('Start');
                $tmp_approvestep['icon_class'] = 'approvelog_submit';
                $tmp_approvestep['showtype'] = 'show';
                $tmp_approvestep['display'] = 'yes';
                $tmp_approveloginfo['tip'] = getFixedLabel('Unapproved');
                $tmp_approvestep['approveloginfo'][] = $tmp_approveloginfo;
                $WholeApproveLog[$arr_index] = $tmp_approvestep;
                $showstepcount += 1;
            }
            
            foreach($allstepinfo as $tmp_index=>$tmp_stepinfo){
                $tmp_stepid = $tmp_stepinfo['stepid'];
                
                $tmp_approveloginfo = array();
                $tmp_concurrentid = $tmp_stepinfo['concurrentid'];
                $tmp_approvetype = $tmp_stepinfo['approvetype'];
                $tmp_approvevalue = $tmp_stepinfo['approvevalue'];
                $emptyapproverdeal = $tmp_stepinfo['emptyapproverdeal'];
                $tmp_approveloginfo['stepid'] = $tmp_stepid;
                //获取当前步骤的审批人
                $nextstepby = $this->getApproveBy($tmp_approvetype,$tmp_approvevalue,$record,$emptyapproverdeal);
                $tmp_approveloginfo['OPERATOR'] = trim($this->getApproveByName($nextstepby),',');
                
                $tmp_approveloginfo['STEPNAME'] = $tmp_stepinfo['name'];
                $tmp_approveloginfo['tip'] = getFixedLabel('APPROVER');
                $tmp_approveloginfo['tip_color'] = '#272727';
                //如果审批步骤id和前一个步骤的id相同则合并
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
                    if($showstepcount < $max_showstepcount){
                        $tmp_approvestep['showtype'] = 'show';
                        $tmp_approvestep['display'] = 'yes';
                        $showstepcount += 1;
                    }else{
                        $tmp_approvestep['showtype'] = 'next_hidden';
                        $tmp_approvestep['display'] = 'no';
                    }
                    $WholeApproveLog[$arr_index] = $tmp_approvestep;
                }
                $WholeApproveLog[$arr_index]['icon_class'] = 'approvelog_none';
                
                $pre_stepid = $tmp_stepid;
                $pre_tmp_concurrentid = $tmp_concurrentid;
            }    
        }
        return  $WholeApproveLog;
    }
    //获取审批步骤对象
    public function GetApproveStepobj($module,$approveid,$approveresult){
        crm_load_class_file('cls_ApproveStep','modules/Approve');
       /* if(!empty($this->ApproveStepobj)){
            $this->ApproveStepobj->approveid=$approveid;
            $this->ApproveStepobj->approveresult=$approveresult;
            $this->ApproveStepobj->approvemodule=$module;
        }else{*/
        //edit:can 20230209 61302 赵沁 批量提交 费用报销单使用该流程“ 低值易耗品费用报销流程（一）”提交时，单据审批步骤比较奇怪，直接略过了上级部门主管“张明辉”进入到了总经理审批，而且审批日志显示中间步骤经过了几次重复的流程
            $this->ApproveStepobj = new cls_ApproveStep($module,$approveid,$approveresult);
        //}
        return $this->ApproveStepobj;
    }
    
    //判断模块 判断是否显示停用的审批流程
    public function ShowDisabledApprove($module){
        crm_load_class_file('cls_ApproveCache','modules/Approve');
        return cls_ApproveCache::ShowDisabledApprove($module);
    }

    //判断是否显示回撤按钮
    public function get_retrace_permit($record,$module){
        global $adb,$current_user;
        $focus=CRMEntity::getInstance($module);
        $maintablename=$focus->table_name;
        $maintable_index=$focus->table_index;
        $smowneridcolumnname=$focus->getSmownerColumName();
        $sql="select approveid,stepid,nextstepid,nextstepapproveby,approveresult,approved_by
        FROM ld_approvelog inner join $maintablename on $maintablename.$maintable_index=ld_approvelog.crmid
        WHERE ld_approvelog.crmid = ?  and  ld_approvelog.id > 0 and (ld_approvelog.approved_by>0 && approveresult <> 18) ORDER BY ld_approvelog.id desc,ld_approvelog.createdtime DESC limit 1";
        $result=$adb->pquery($sql,array($record));
        $rows=$adb->num_rows($result);
        $approveinfo=array("stepid"=>0);
        $permit = 'no';
        if($rows>0)
        {
            $stepid = $adb->query_result($result,0,'stepid');
            $approve_by = $adb->query_result($result,0,'approved_by');
            if($stepid == -1 && $approve_by == $current_user->id){
                $permit = 'yes';
            }
        }
        return $permit;
    }
    //xxy 2023-12-14 判断是否有默认审批流程，没有默认流程时增加一个空流程
    public function NoDefaultAddEmptyApproval($approve_arr){
        global $weixin_user;
        // $approve_arr = $this->getAllApprovesByUserid($tabid,$userid);
        $noapprovalshowempty = getUsersettingByLabel($this->module,1,'NoApprovalShowEmpty');//无默认审批流时显示为空 参数
        $have_default = '';
        $default_approve = [];
        foreach($approve_arr as $index => $approve){
            if($approve['isdefaultapprove'] == 'yes'){
                $have_default = 'yes';
                $default_approve = $approve;
                break;
            }
        }
        if($noapprovalshowempty != 'yes' && $have_default != 'yes'){
            if (!empty($approve_arr)) {//当没有适用的审批流时,需要判断
                $approve_arr[0]['selected'] = 'selected';
            }
        }
        if($have_default != 'yes' && $noapprovalshowempty == 'yes' && count($approve_arr) > 1 ){
            if($noapprovalshowempty == 'yes' && !$weixin_user->environment_weixin){
                $empty_approval = array(
                    'approveid'=>-1,
                    'approvename'=>'',
                    'selected'=>'',
                    'submitremark'=>array('display'=>'','require'=>'',),
                    'showurgent'=>'',
                    'enableexpediting'=>'',
                    'finishedallowedit'=>'',
                    'allowagainsubmit'=>'',
                    'isnewapprove'=>'',
                    'isdefaultapprove'=>'',
                );
                array_unshift($approve_arr,$empty_approval);
                return $approve_arr;
            }

            return $approve_arr;
        }else{
            return $approve_arr;
        }
    }
    // 设置是否需要获取审批委托人
    public function setNeedApprovalClient($param){
        $this->isNeedApprovalClient = $param;
    }
    //控制使用界面上的值进行动态判断
    public function setApprovechangeCheck($column_value)
    {
        $this->approvechange_check = 'yes';
        $this->column_value = $column_value;
    }
}
?>