<?php
/**************************************************************************
**edit:duan
**date:2022-08-04
**reason:
**************************************************************************/
//新版审批流程基础类define('D_A_S_UNAPPROVED','未提交');//未提交

define('D_A_S_APPROVALOF','审批中');//审批中

define('D_A_S_APPROVED','已批准');//已批准
define('D_A_S_REJECTED','已拒绝');//已拒绝
define('D_A_S_DISMISSED','已驳回');//已驳回
define('D_A_S_CHECKED','已审核');
define('WHERE_SYSTEM_APPROVE',D_A_S_APPROVED);
define("APPROVE_APPROVED",2);//已批准
define("Approve_Concurrent_Stepseq",0.00001);//并发步骤步长
class ApproveNew{
    private static $_instance;//单例返回类实例
	private $approveInfo = array();


    public $recordApprovestatus;//记录单据审批状态信息
    public $approvemodule_field_notempty_arr;//审批必填
    public $isNeedApprovalClient = 'yes';// 是否获取审批委托人
    public $module;
    public $approvechange_check = 'no';
    public $column_value; //表头字段值
    public $ApproveStepobj;
    public $insertStepID_arr = [];
    public $last_approvelog;
    public static function getInstance($module) {
        //单例返回当前类的实例
        if(!(self::$_instance[$module] instanceof self)){//是否为当前类的实例
            self::$_instance[$module] = new self($module);
        }
        return self::$_instance[$module];
    }
    private function __clone(){}
    
    public  function __construct($module='')
    {
        
        $this->module=$module;
    }
    function approveUsed($approveid,$blockid){
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
        global $adb,$current_user,$weixin_user;
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
        global $adb;
		//left join ld_crmentity on ld_crmentity.crmid=ld_approvelog.crmid 
        $query="select ld_approvelog.id,ld_approvelog.approved_by, ld_approvelog.approveresult
        ,ld_approve.name as approvename,ld_approvestep.name as stepname,la.name as nextstepname
        ,ld_approvelog.stepid,ld_approvelog.nextstepid,ld_approvelog.approved_by,nextstepapproveby
        ,t1.last_name as approvebyname,t1.wx_userid,ld_approvelog.description,ld_approvelog.createdtime
        ,ld_approvelog.approve_autograph,ld_approvelog.approve_autograph_path 
        ,ld_approvelog.countersigner,ld_approvelog.nextstep_countersigner
        ,ld_approvelog.logconcurrentid,stepcol_rowspantable.stepcol_rowspan,isfinished
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
         where  ld_approvelog.crmid = ? order by ld_approvelog.seqtime desc,ld_approvelog.stepseq asc, ld_approvelog.id desc  ";
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
            
            $nextstepapproveby=$adb->query_result($result,$i,'nextstepapproveby')??'';//下一个步骤审批人id
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
            if($approved_by==-1)
            {
                $approvebyname="System";
            }
            if(substr($nextstepapproveby, 0, 1 )=='H'){
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
             $nextstepbyname=$this->getApproveByName($nextstepby);
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
            if($stepid != -1){
                if($countersigner=='yes'){
    				$operate=getFixedLabel('Countersignature');	//会签审批
    				if($approveresultno==4){
    					$approveresult=getFixedLabel('NOTPASSRETURNCHARGE');	//不通过
    				}else if($approveresultno == 5){
                    }
    				else if($logconcurrentid<=0)
    					$approveresult=getFixedLabel('Agree');	//通过
                    if($nextstep_countersigner=='yes'||$logconcurrentid>0){
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
                                'DESCRIPTION'=>str_replace("\n","<br/>",$adb->query_result($result,$i,'description')??''),//BUG0074598  	审批意见填写可以换行，保存后在审批日志中换行没有了 
                                'CREATEDTIME'=>$createdtime,
                    			'APPROVEID'=>$adb->query_result($result,$i,'id'),
                                'BACKUP'=>($approveresultno==4||$stepid==-2)?'YES':'NO',
                    			'APPROVEAUTOGRAPH' => $approve_autograph,
                    			'APPROVEAUTOGRAPHPATH' => $approve_autograph_path,
                                'cur_approveresult' =>$cur_approveresult
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
                $tmpinfo['stepinfo'][0]['NEXTSTEPBYNAME']='';
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
        global $adb,$current_user;
      
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
	//根据stepid获取对应的信息
    public function getStepInfo($stepid){
        crm_load_class_file('cls_ApproveInfo','modules/Approve');
        $ApproveInfoObj=new cls_ApproveInfo($this);
        return $ApproveInfoObj->getStepInfo($stepid);
    }
    /*
     * editor:gyq_05
     * reason:获取提交审批步骤详情
     * */

    function getApproveStepInfo($approveid,$record,$userid=0){
        global $adb;
        
        //获取流程的第一个审批步骤
        $stepinfo = $this->getnextstepinfo(-1,-1,$approveid,$record);
        
        $nextstepid = $stepinfo['nextstepid'];
        
        $sql = "SELECT name,approvevalue,approvetype,specifyapproverid
            ,countersigner,augmentsinger,ld_approvestep.id
            ,ld_approvestep.concurrentid,ld_approvestep.emptyapproverdeal
         FROM ld_approvestep WHERE id=? order by sequence limit 1 ";
       
        $result = $adb->pquery($sql,array($nextstepid));
        
       
        $nextStepInfo_arr=[];
        $rows=$adb->num_rows($result);
        if ($rows > 0) {
             
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

                //新增编辑界面根据界面上的字段判断审批人
                if($this->approvechange_check == 'yes'){
                    $focus=CRMEntity::getInstance($this->module);
                    if($record>0){
                        $focus->id = $record;
                        $focus->retrieve_entity_info($record,$this->module);
                    }

                    $modulefields=$focus->fieldobj->getModuleFields();
                    foreach($modulefields as $fieldname=>$fieldinfo)
                    {
                        $columnname = $fieldinfo->getColumnName();
                        if(isset($this->column_value[$columnname])){
                            $focus->column_fields[$fieldname]=$this->column_value[$columnname];
                        }

                    }
                    $nextStepApproverIds= $this->getApproveByInfo($nextStepType,$nextStepValue,$focus);
                }else{
                    if($userid>0){
                        $nextStepApproverIds = $this->getApproveuserinfoByid($nextStepType,$nextStepValue,$userid);
                    }
                    else
                        $nextStepApproverIds = $this->getApproveBy($nextStepType,$nextStepValue,$records[0]);
                }

                    
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
        return $ApproveInfoObj->getApproveLogQuery($approveresult,$searchquery='');
    }
    /**
     * edit:kevin
     * date:2013-09-24
     * reason:单据是否启用审批
     */
    public function startBlocksApprove(){
        crm_load_class_file('cls_ApproveCache','modules/Approve');
        return cls_ApproveCache::startBlocksApprove();
    }

    public function getAllApproveBy($record){
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
         
		global $adb,$current_user;
		static $approvesubmitarr;
        static $firstapprovestepid;
        global $selectapprovecrmid_len;//判断是否选择了多个单据进行提交
        
        //获取流程的第一个审批步骤
        $this->getAllStepInfoByApproveid($approveid);
        //获取审批步骤对象
        $approvestepobj=$this->GetApproveStepobj($module,$approveid,0);
        $approvestepobj->issubmit = 'yes';
        $stepid = -1;//-1表示从提交审批开始
         
        $nextstepinfo = $approvestepobj->getnextstepid(-1,-1,$crmid,$approveid);
       
        if($nextstepinfo['nextstepid']<=0){
            //没有满足条件审批步骤
            return $nextstepinfo;
        }
       
        $stepinfo=$approvestepobj->getstepid($stepid,$nextstepinfo['nextstepid'],$sequence,$crmid,1,$concurrentid,$approveid);
          $approvelog['approveresult'] = 1;
        
        if($stepinfo['nextstepid']<=0)
        {
            //没有满足条件审批步骤
            if($approvestepobj->skiptypearr[$stepinfo['curstepid']]=='approveremove')
            {
                $approvelog['approveresult']=2;
            }
            else
                return $stepinfo;
        }
       
        $stepid = $stepinfo['nextstepid'];
        $stepinfo_arr = $this->getStepInfo($stepinfo['nextstepid']);
        $approveinfo=$this->approveStatus($crmid);
 	    $approvetype = $stepinfo_arr['approvetype'];
		$approvevalue = $stepinfo_arr['approvevalue'];   
        $nextstep_countersigner= $stepinfo_arr['countersigner'];
        $concurrentid= $stepinfo_arr['concurrentid'];//大于零标识是有并发步骤
        $emptyapproverdeal = $stepinfo_arr['emptyapproverdeal'];
        $countersigner=$stepinfo_arr['countersigner'];
         
        if($selectapprovecrmid_len<=1 && $stepid == $_REQUEST['nextstep_0']){
            $tmp_approveby = $_REQUEST['userid_0'];
			if(empty($tmp_approveby)){
				$tmp_approveby = $this->getApproveBy($approvetype,$approvevalue,$crmid);
			}
	       	$approvesubmitarr[$approveid]['approveby'] = $approveby=$tmp_approveby;
	       	//是否允许修改审批人功能改进// $this->getApproveBy($approvetype,$approvevalue,$crmid);
        }
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
                    $_REQUEST['userid_'.$i]=$this->getApproveBy($approvetype,$approvevalue,$crmid);
                }
            }
            else{
                $approvesubmitarr[$approveid]['approveby'] = $approveby=$this->getApproveBy($approvetype,$approvevalue,$crmid);
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
  	     approveresult,createdtime,seqtime,nextstepid,nextstepapproveby,countersigner,nextstep_countersigner,approve_autograph,approve_autograph_path,stepseq,urgent,isnewlog)';
		$query .= 'value(?,?,?,?,?,?,?,now(),current_timestamp(6),?,?,?,?,?,?,0,?,?)';
        

        /*
         * editor:gyq_05
         * reason:新增提交审批时，向日志表写入审批步骤ID,审批人默认为-5(没有人审批过)
         * date  :2016 3 3
         * */
        if($approvelog['approveresult']!=2&&empty($approveby) && $_REQUEST['concurrentidStepCount'] <= 1 && $this->get_allow_emptyapprover($stepid,$approvetype)!='yes') //0045103:排除并发步骤
        {
               //edit:can 20230329   63440	付款单审批流，审批流名称： 付款单自动审批 
            //edit:can 2021-03-17045040: （https://61mis.com/kfbcrm [^]）客户问题（徐燕男），服务合同勾选（服务合同编号：SERCON196和SERCON196）单据使用审批流程“服务合同选人审批流程”批量提交时，审批结果提示错误（需要补丁）
            return array('nextstepid'=>$stepid,"approveby"=>$approveby);    
        }
	   $adb->pquery($query,array($approvelogid,$crmid,trim($_REQUEST['description']),$approveid,-1,$current_user->id,1,$nextstepinfo['nextstepid'],$approveby,$countersigner,$nextstep_countersigner,$approve_autograph,$_REQUEST['approve_autograph_path'],$urgent,'yes'));//存入审批历史表，确定下一步审批步骤和审批人
      $logconcurrentid=0;
      $lastapprovelogid=$approvelogid;
      $concurrentInsertStepInfo=array('logconcurrentid'=>0);
      $approvelog_arr=[];
     $approvelog_arr['crmid']=$crmid;
     $approvelog_arr['approveid']=$approveid;
     $this->insertStepID_arr=[];
     $this->insertStepID_arr[]="-1";//已经插入的审批步骤
     $new_description=$_REQUEST['description'];
    $_REQUEST['description']='';
      if($_REQUEST['concurrentidStepCount']>1)//说明是并发步骤
      {
            //提交审批，下一步是并发审批步骤
           $concurrentInsertStepInfo=$this->insertConcurrentApproveLog($approvestepobj,$approvelog_arr);//插入并发步骤
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
               $approvestepinfo_arr[$approveid]=$this->getAllStepInfoByApproveid($approveid);
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
             if($tmpconcurrentid>0&&$this->checkConcurrentStepAllSkip($tmpconcurrentid,$approveid,$approvestepobj)=='yes')
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
                                 
                                 $tmpnextstepapproveby=$this->getApproveBy($tmpapprovetype,$tmpapprovevalue,$crmid);
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
                          
                            $this->insertSkipStepConcurrentApproveLog($approvestepobj,$skipstepConcurrentinfo,$approvelog_arr);
                             
                            $logconcurrentid=$skipstepConcurrentinfo['logconcurrentid'];
                            break;
                        }
                    }
                }
      }
      //判断并发步骤是否所有的步骤都自动跳过
      $approvestatus = constant('D_A_S_APPROVALOF');
        $pre_approveby = '';
      if($approvelog['approveresult']==2)
      {
         //edit:can 20230329   63440	付款单审批流，审批流名称： 付款单自动审批 
        //审批结束 审批人和提交人相同时去重
         $approvelogid=$adb->getUniqueID('ld_approvelog');
        
       	$query = 'insert into ld_approvelog(id,crmid,description,approveid,stepid,approved_by,
      	     approveresult,createdtime,seqtime,nextstepid,nextstepapproveby,isnewlog)';
   		$query .= 'value(?,?,?,?,?,?,?,now(),current_timestamp(6),?,?,?)';
        $approvestatus = constant('D_A_S_APPROVED');
        $pre_approveby = $current_user->id;
    	  $adb->pquery($query,array($approvelogid,$crmid,'',$approveid,$stepinfo['curstepid'],$current_user->id,2,'','','yes'));
          
       
      }
      
        
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
            
            $sql='select nextstepapproveby,id from ld_approvelog where crmid=? order by id desc limit 1';
            $tmpresult=$adb->pquery($sql,array($crmid));
            $id = $adb->query_result($tmpresult,0,'id'); 
            //duan 判断下一步审批人是否为空，如果为空则执行特殊处理方式
            //因为需要修改单据中的值，所以获取到执行的结果
            $empty_approver_result =  $this->emptyapprover_solution($id);
            if ($empty_approver_result['type']=='change'){//转交审批人
                $approveby = $empty_approver_result['nextstepapproveby'];
            }else{
                $approveby=$approvestepobj->saveskip_nextstepapproveby;
                $approveby=$adb->query_result($tmpresult,0,'nextstepapproveby');
                
            }
        }
        
         //工作流程反写
        crm_load_class_file("cls_savereverse",'include/SaveReverse');
         $pagemode='submit';
        $workflowreverseobj=cls_savereverse::getInstance($module);
        $workflowreverseobj->setPageMode($pagemode);
        
        $workflowreverseobj->getInfo();
         if($adb->num_rows($workflowreverseobj->workflowresut)>0)
         {
             $focus->retrieve_entity_info($crmid, $module);
             $beforefieldvalue_arr=$focus->column_fields;
         }
        
        $_REQUEST['description']=$new_description;
        //duan 2022-4-21 提交审批后清空上一步审批人避免影响反审批判断
        // @edit:liushuai @date:2020-07-13 @reason: 审批中心查询优化：发起人（提交人）、发起时间（提交时间）、审批步骤（当前审批步骤）， 放在单据表里面（单据详情页审批）
       	$query = 'update '.$tabname.' set approvestatus = ?,currentapprover=?,approvetime=?,approvesubmitter=?,approvesubmittedtime=?,currentapprovestepid=?,approveurgent=?,approveexpediting=?,approveby=? where '.$tabindex.'='.$crmid;//将单据修改为审批中
         
        $adb->pquery($query,array($approvestatus,$approveby,date("Y-m-d H:i:s"),$current_user->id,date("Y-m-d H:i:s"),'-1',$urgent,'no',$pre_approveby));
        /*editor:gyq_05 explain:生成消息提醒 */
         //dump(array(constant('D_A_S_APPROVALOF'),$approveby,date("Y-m-d H:i:s"),$current_user->id,date("Y-m-d H:i:s"),'-1'));


        //BUG20240821-75 duan 自动通过的步骤也要触发审批通过后赋值
        if(sizeof($approvestepobj->skipstepinfo)>0){
            $query="select modulestatus,pickcolumnname from ld_approvestep left join
                ld_approvestepdetails on ld_approvestep.id=ld_approvestepdetails.stepid
                where approveid=? and stepid=? and pass=? ";
            foreach ($approvestepobj->skipstepinfo as $tmp_info){
                $cur_stepid = $tmp_info['curstepid'];
                if($approvestepobj->skiptypearr[$cur_stepid] == 'approveremove' || $approvestepobj->skiptypearr[$cur_stepid] == 'emptyapprover'){
                    $result = $adb->pquery($query,array($approvelog_arr['approveid'],$cur_stepid,0));
                    $num_rows = $adb->num_rows($result);
                    for($i=0;$i<$num_rows;$i++){
                        $tmp_arr = array();
                        $modulestatus = $adb->query_result($result,$i,'modulestatus');
                        $pickcolumnname=$adb->query_result($result,$i,'pickcolumnname');
                        $picktablename=$focus->fieldobj->getFieldInfoBykeyValue("columnname",$pickcolumnname,"tablename");
                        $tmp_arr['modulestatus'] = $modulestatus;
                        $tmp_arr['pickcolumnname'] = $pickcolumnname;
                        $approvestepdetails_arr[$picktablename][] = $tmp_arr;
                    }
                }
            }
            if(is_array($approvestepdetails_arr)&&sizeof($approvestepdetails_arr)>0)
            {
                foreach($approvestepdetails_arr as $tmp_picktablename => $pickcolumn_arr){
                    //获取所有选中的字段
                    $tmp_fieldsql = '';
                    foreach($pickcolumn_arr as  $column_info){
                        $pickcolumnname = $column_info['pickcolumnname'];
                        $modulestatus = $column_info['modulestatus'];
                        $tmp_fieldsql .= $pickcolumnname." = '".$modulestatus."',";
                    }
                    $tmp_fieldsql = trim($tmp_fieldsql,',');
                    $query=" update ".$tmp_picktablename ." set $tmp_fieldsql where ".$focus->tab_name_index[$tmp_picktablename].'=?';
                    $adb->pquery($query,array($crmid));
                }
            }
        }


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
         //20230616 duan 图形化审批流程第一步自动审批结束后,触发审批成功事件
        if($approvelog['approveresult']==2){
            $focus->successApprove($crmid);
            $focus->id = $crmid;
            $focus->retrieve_entity_info($crmid, $module);
            $focus->save_workflow($module,$focus,'Approved');
            $focus->column_fields['account_id']=0;

            //duan 20240620 自动审批结束后，触发审批通过工作流程
            $pagemode='Approved';
            $workflowreverseobj->setPageMode($pagemode);
            $workflowreverseobj->getInfo();
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

        }


        require_once(globalStatic::$root_directory.'modules/Approve/ApproveRemind.php');
        //@param 参数$approvelog是一个包含审批历史的数组，需传审批结果approveresult、下一步审批人nextstepapproveby
      //  $approvelog['approveresult'] = 1;
        $approvelog['nextstepapproveby'] = $approveby;
        $approvelog['stepid'] =$stepid;
        $approvelog['crmid'] =$crmid;
        $approvelog['approved_by'] = $current_user->id;
        $approvelog['approvelogid'] = $approvelogid;

         if(sizeof($approvestepobj->skipstepinfo)>0)
            $approvelog['nextstepid']=$approvestepobj->skipstepinfo[sizeof($approvestepobj->skipstepinfo)-1]['nextstepid'];
      
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
         
        if($approvelog['approveresult']==2)
        {
            //edit:can 63440 
            $stepinfo['nextstepid']=9999999999;
        }
        return $stepinfo;
	}

	/**
	 * 添加审批历史，执行审批步骤高级条件等
	 * @param String $module 模块名
	 * @param Array $approvelog 审批历史保存信息
	 * Array(
	 *	   crmid,//数据ID
	 *     approveid,//审批流程
	 *     stepid,//审批步骤
	 *     approved_by,当前审批人
	 *     approveresult,当前审批类型（通过、驳回、已审批等）
	 *     description,//审批备注
	 *     nextstepid,//下一步审批步骤
	 *     nextstepapproveby,//下一步审批人
	 * )
	 * @return 执行审批操作
	 * @project PROT144 审批功能改进
	 * @author Tujt 2014-12-26
	 */
	public function SaveApprovedLog($module,$approvelog) {
	    global $adb,$current_user;
        global $approvestepinfo_arr;//审批流程下所有审批步骤信息（批量审批）
		//异常处理(通过并进行下一步：审批步骤或者下一步审批人为空)
        $stepinfo['curstepid']=$approvelog['stepid'];//要初始化
        $stepinfo['nextstepid']=$approvelog['nextstepid'];//要初始化
    
        //已拒绝，和审批失败都不需要获取满足审批条件的审批流程
        $stepobj=$this->GetApproveStepobj($module,$approvelog['approveid'],$_REQUEST['approvestatus']);
        $stepobj->last_approvelog = $approvelog;
        $crmid=$approvelog['crmid'];
        $approveid=$approvelog['approveid'];
        $concurrentid=0;
        $islaststepconcurrent='yes';
        $stepid = $approvelog['stepid'];
        $cur_stepinfo = $this->getStepInfo($stepid);
        $approveinfo=$this->approveStatus($crmid);

        if($cur_stepinfo['countersigner'] == 'yes'&&$approvelog['approveresult']==1&&$approvelog['nextstepid']==$stepid){
            $nextapproved_bys=explode(',',$approveinfo['nextstepapproveby']);
            $nextsetpbyuser='';

            foreach($nextapproved_bys as $tmpindex=>$tmp_approveuserid){
                if($tmp_approveuserid==$current_user->id)
                {
                    continue;//删除当前审批人
                }
                $nextsetpbyuser.=$tmp_approveuserid.',';
            }
            $nextsetpbyuser = rtrim($nextsetpbyuser,',');
            if(!empty($nextsetpbyuser)){
                $approvelog['nextstepapproveby'] = $nextsetpbyuser;
            }else{
                $getnewstep = 'yes';
            }
        }
        if($getnewstep == 'yes'){
            $nextstepinfo = $this->getnextstepinfo($flowstepid,$stepid,$approveid,$crmid);

            //没有下一步骤，表示审批成功
            if($nextstepinfo['nextstepid'] <0){
                $approvelog['approveresult'] = 2;
                $approvelog['nextstepid'] = '';
                $approvelog['nextstepapproveby'] = '';
            }else{
                $tmp_nextstepid = $nextstepinfo['nextstepid'];
                $approvelog['nextstepid'] = $tmp_nextstepid;
                $tmp_nextstepinfo = $this->getStepInfo($tmp_nextstepid);
                $approvelog['nextstepapproveby'] = $this->getApproveBy($tmp_nextstepinfo['approvetype'],$tmp_nextstepinfo['approvevalue'],$crmid,$tmp_nextstepinfo['emptyapproverdeal']);
            }
        }

     
      if($approvelog['logconcurrentid']>0)
        {
            //是否为并发步骤最后一步
            $islaststepconcurrent=$this->getisLastStepConcurrent($approvelog['crmid'],$approvelog['logconcurrentid'],$approvelog['approveid']);
        }
        
        $iscanceloperation='no';//是否为反审批操作包括（不通过，返回负责人）
         
		if(1 == $approvelog['approveresult']||$approvelog['approveresult']==6||$approvelog['approveresult']==17||($approvelog['approveresult']==5&&($_REQUEST['action']=='SaveApproveLog'||$_REQUEST['file']=='SaveApproveLog')))
        {
            //通过并进行下一步
			//下一步审批步骤为空
           if($islaststepconcurrent=='no')
            {
                //并发步骤非最后一步
                $approvelog['nextstepid']=$approvelog['stepid'];
            }
        
			if(empty($approvelog['nextstepid'])){
			     
                 
                 /// $this->approveStatus($approvelog['crmid']);//获取审批日志的最后一步
				
               $query = 'select id,sequence,concurrentid from ld_approvestep where approveid = ? and id > (
						select nextstepid from ld_approvelog where crmid = ? ORDER BY id desc limit 1
						) ORDER BY sequence limit 1;';
				$result = $adb->pquery($query,array($approvelog['approveid'],$approvelog['crmid']));
                
				$num_rows = $adb->num_rows($result);
				if($num_rows > 0){
					$approvelog['nextstepid'] = $adb->query_result($result,0,0);
                    $sequence=$adb->query_result($result,0,0);
                    $concurrentid=$adb->query_result($result,0,'concurrentid');
				}
                
			}
            else
            {
                $query="select  sequence,concurrentid from ld_approvestep where id=?";
                
                $result = $adb->pquery($query,array($approvelog['nextstepid']));
                $sequence=$adb->query_result($result,0,0);
                $concurrentid=$adb->query_result($result,0,'concurrentid');
            }
        
         
             if($approvelog['stepid']==-2&&$_REQUEST['file']=='getCancelApprove')
             {
               //反审批 回撤到上一步，不需要处理，在module/Approve/getCancelApprove.php已经获取最新
               $iscanceloperation='yes';
               if($concurrentid>0)
               {
                    $sequence=floor($sequence);
                    $approvestepinfo_arr[$approveid]=$this->getAllStepInfoByApproveid($approveid);
                    foreach($approvestepinfo_arr[$approveid] as $tmpstepinfo )
                    {
                        if($tmpstepinfo['sequence']==$sequence)
                        {
                            $approvelog['nextstepid']=$tmpstepinfo['stepid'];
                            break;
                        }
                    }
               }
               
               
               $stepinfo=$stepobj->getstepid($approvelog['stepid'],$approvelog['nextstepid'],$sequence,$approvelog['crmid'],1,$concurrentid,$approvelog['approveid']);
               
             }
             else if($approvelog['approveresult']==5&&($_REQUEST['action']=='SaveApproveLog'||$_REQUEST['file']=='SaveApproveLog'))
            {
                //手机端审批：不通过，返回上一步
                $iscanceloperation='yes';
                //edit:can 2021-01-12 44190: （企业微信移动端-kfbcrm）待审批-销售机会，单据编号 pot97；审批流“销售机会第二步会签”；二级审批审批时操作驳回上一步，审批日志中显示“通过”

               //$approvelog['stepid']=-2;
                //$approvelog['approveresult']=1;
               
              if($concurrentid>0)
               {
                    $sequence=floor($sequence);
                    $approvestepinfo_arr[$approveid]=$this->getAllStepInfoByApproveid($approveid);
                    foreach($approvestepinfo_arr[$approveid] as $tmpstepinfo )
                    {
                        if($tmpstepinfo['sequence']==$sequence)
                        {
                            $approvelog['nextstepid']=$tmpstepinfo['stepid'];
                            break;
                        }
                    }
               }
                $stepinfo=$stepobj->getstepid($approvelog['stepid'],$approvelog['nextstepid'],$sequence,$approvelog['crmid'],1,$concurrentid,$approvelog['approveid']);
                
            }
             else
             {
              
                //加签不需要再做跳过判断
                if($islaststepconcurrent=='yes'&&$approvelog['approveresult']!='6')//高级查询并发步骤跳过
                {
                    //$stepobj->test = 1;
                    $stepinfo=$stepobj->getstepid($approvelog['stepid'],$approvelog['nextstepid'],$sequence,$approvelog['crmid'],1,$concurrentid,$approvelog['approveid']);
                  //  $stepobj->test = 2;
                }
                     
               else//如果是并发步骤且不是并发步骤的最后一步，则不需要判断高级查询条件
                     $stepinfo= array("curstepid"=>$approvelog['nextstepid'],"nextstepid"=>$approvelog['nextstepid'],'concurrentid'=>$concurrentid);;
         
                 if($approvelog['approveresult']!=4&&$stepinfo['nextstepid']<=0)
                 { //如果不是返回上一步，且没有找到满足的审批流程则，则认为审批成功

                    $approvelog['approveresult']=2;
                    $approvelog['nextstepapproveby']="";
                    //异常情况保存参数记录
                    $approvelog['description'] = $approvelog['description'];
                   
                 }
                 else if(empty($approvelog['nextstepapproveby'])&&$stepinfo['nextstepid']==$approvelog['nextstepid'])//批量审批中下一步审批人为空
                 {
                  
                       $approvestepinfo_arr[$approveid]=$this->getAllStepInfoByApproveid($approveid);
                       foreach($approvestepinfo_arr[$approveid] as $tmpstepinfo)
                       {
                            if($tmpstepinfo['stepid']==$approvelog['nextstepid'])
                            {
                                $approvetype = $tmpstepinfo['approvetype'];
            		           $approvevalue = $tmpstepinfo['approvevalue'];    
                      		    $approvelog['nextstepapproveby'] = $this->getApproveBy($approvetype,$approvevalue,$crmid);
                                break;
                            }
                       }
                      
                        
                 }
                 
             }
        
             
		}
        else{
            $iscanceloperation='yes';
        }
        /* duan 20231030 上面已经判断过当前审批的步骤是否属于正在审批的步骤，这一段代码没用了，先注释
        //当前审批步骤的审批历史
        $sql='select approveid,stepid,urgent,augmentsinger,approveresult,countersigner,nextstep_countersigner from ld_approvelog 
        where crmid =? and approved_by>0 and isfinished="yes" order by id desc limit 1';
        $result=$adb->pquery($sql,array($approvelog['crmid']));
        if($adb->num_rows($result)>0&&$approvelog['approveresult']!=4)
        {
            $urgent = $adb->query_result($result,0,'urgent');//新增审批日志前暂存上一次是否加急审批urgent的值
            //解决并发，判断approveid,stepid都相同
            $tmpapprovied=$adb->query_result($result,0,'approveid');
            $prevapproveid=$tmpapprovied;//
            $tmpstepid=$adb->query_result($result,0,'stepid');
            $augmentsinger=$adb->query_result($result,0,'augmentsinger');
            $approveresult = $adb->query_result($result,0,'approveresult');
            $countersigner = $adb->query_result($result,0,'countersigner');
            $nextstep_countersigner = $adb->query_result($result,0,'nextstep_countersigner');
            if($tmpapprovied==$approvelog['approveid']&&$tmpstepid==$approvelog['stepid']&&!in_array($approveresult,array(5,6,15,16,17,18))
                &&$countersigner!='yes'&&$nextstep_countersigner!='yes')
            {
                return ;
            }
        }
        */

        //在操作审批通过时，判断审批的步骤是否属于正在审批的步骤
        if(in_array($approvelog['approveresult'],[1,2]) && $approvelog['stepid']>0){
            $approveinfo=$this->approveStatus($crmid);//获取单据的最后一条审批历史记录
            if($approvelog['stepid']!=$approveinfo['nextstepid']){
                return '';
            }
        }

        if(!isset($approvelog['countersigner'])||$approvelog['countersigner']==''){
            $approvelog['countersigner']='no';
            //审批中心批量审批
            $sql='select countersigner from ld_approvestep where id=?';
            $tmpresult=$adb->pquery($sql,array($approvelog['stepid']));
            $approvelog['countersigner']=$adb->query_result($tmpresult,0,'countersigner');//当前步骤是否会签
        }
       
        
        $approvelog['nextstep_countersigner']='no';
       if($stepinfo['nextstepid']!=$approvelog['nextstepid'])//如果下一步审批步骤不满足条件，则下一步审批人为system
                    $approvelog['nextstepapproveby']="-1";
      
        // $nextstepapprove_user_arr=array_filter(explode(",",$approvelog['nextstepapproveby']));
        if($approvelog['nextstepid']>0){//审批成功$approvelog['nextstepid']为空
            //如果下一步审批人大于1，则要判断下一步审批是否为会签
            $sql='select countersigner,augmentsinger from ld_approvestep where id=?';
            $tmpresult=$adb->pquery($sql,array($approvelog['nextstepid']));
            $tmpcountersigner=$adb->query_result($tmpresult,0,'countersigner');
            $approvelog['nextstep_countersigner']=$adb->query_result($tmpresult,0,'countersigner');//当前步骤是否会签
			$approvelog['augmentsinger']=$adb->query_result($tmpresult,0,'augmentsinger');//当前步骤是否加签
            
			if($approvelog['approveresult'] == 6){
				if($approvelog['augmentsinger'] == 'yes' || $approvelog['augmentsinger'] == 'no'){
					$approvelog['nextstep_countersigner']= 'yes';
					if($approvelog['augmentsinger'] == 'yes')
						$approvelog['countersigner'] = 'yes';
				}else{

					$approvelog['nextstep_countersigner']=$this->getisCounterSigner($approvelog['nextstep_countersigner'],$approvelog['nextstepapproveby'],$approvelog['nextstepid']);
				}
			}else{
			
				if($approvelog['augmentsinger'] == 'yes' && 1 == $approvelog['approveresult'] && $approvelog['stepid'] > 0){
					$sql='select id,approveresult,stepid from ld_approvelog where crmid='.$crmid.' order by id desc limit 1';
                    $tmpresult=$adb->pquery($sql,array());
                    $last_approveresult=$adb->query_result($tmpresult,0,'approveresult');
                    $last_stepid=$adb->query_result($tmpresult,0,'stepid');
					$last_approvelogid=$adb->query_result($tmpresult,0,'id');
                    //$last_stepid!=$approvelog['stepid']||$approvelog['stepid']!=$approvelog['nextstepid']:判断是否为加签的最后一步
                    if($last_approveresult!=6||$last_stepid!=$approvelog['stepid']||$approvelog['stepid']!=$approvelog['nextstepid'])
                    {
                        //edit:can 44769: （61mis.com/kfbcrm）费用报销单审批；单据编号EXP49，审批步骤是会签，5个成员进行会签审批，到第3人时会签结束了
                        $approvelog['nextstep_countersigner']=$approvelog['augmentsinger'];
                        if($tmpcountersigner=='yes'||$approvelog['augmentsinger']=='yes')
                        {
                           // 或签时并且加签（会签） 时，执行到下一步时，变成会签审批了
							$isaugmentsinger = $this->getIsaugmentsinger($last_approveresult,$last_approvelogid,$crmid,$approvelog['nextstepid'],$approvelog['stepid']);
							if($tmpcountersigner == 'no' && $approvelog['augmentsinger'] == 'yes' && $isaugmentsinger == 'no'){
								$approvelog['nextstep_countersigner']= 'no';
							}else
								$approvelog['nextstep_countersigner']=$this->getisCounterSigner($approvelog['nextstep_countersigner'],$approvelog['nextstepapproveby'],$approvelog['nextstepid']); //改步骤是会签且加签也是会签
                        }
                        else
                           $approvelog['nextstep_countersigner']= 'no';
                    }
                    else
                        $approvelog['nextstep_countersigner']= 'yes';
				}else{
					$approvelog['nextstep_countersigner']=$this->getisCounterSigner($approvelog['nextstep_countersigner'],$approvelog['nextstepapproveby'],$approvelog['nextstepid']);
                }
			}
        }
        
		$fieldsql = '';$valuesql = '';
        //35083: （需要补丁）1.出库单明细界面：当审批流程只有一步的情况下反审批不会回撤到上一步。（但是审批的盖章从已批准变为了审批中）
        $insertcolumns=array('crmid','approveid','stepid','approved_by'
            ,'approveresult','description','nextstepid','nextstepapproveby','countersigner','nextstep_countersigner','augmentsinger','isnewlog');
     
        if($_REQUEST['countersigner']=='yes'&&$approvelog['nextstep_countersigner']=='no'&&$islaststepconcurrent='yes'
            &&($approvelog['approveresult']==1&&$approvelog['stepid']>0))
        {
            //$_REQUEST['countersigner']=='yes'&&$approvelog['nextstep_countersigner']=='no':表示会签的最后一个成员
            //$islaststepconcurrent：yes:表示并发步骤的最后一步或者表示当前步骤不是并发步骤
            if($stepinfo['nextstepid']==$approvelog['nextstepid']&&$concurrentid>0)
            {
                //没有跳过审批步骤
                if(!array_key_exists($approvelog['approveid'],$approvestepinfo_arr))
                {
                
                   $approvestepinfo_arr[$approveid]=$this->getAllStepInfoByApproveid($approvelog['approveid']);
                   
                }
                $concurrentidStepCount=0;
                foreach($approvestepinfo_arr[$approvelog['approveid']] as $tmpstepseq=> $tmpallstepinfo)
                {
                    if($tmpallstepinfo['concurrentid']==$concurrentid)
                    {
                        $approvetype=$tmpallstepinfo['approvetype'];
                        $approvevalue=$tmpallstepinfo['approvevalue'];
                        $_REQUEST['userid_'.$concurrentidStepCount]=$this->getApproveBy($approvetype,$approvevalue,$approvelog['crmid']);
                        $_REQUEST['nextstep_'.$concurrentidStepCount]=$tmpallstepinfo['stepid'];
                        $_REQUEST['nextstep_countersigner_'.$concurrentidStepCount]=$tmpallstepinfo['countersigner'];
                        $_REQUEST['nextstep_augmentsinger_'.$concurrentidStepCount]=$tmpallstepinfo['augmentsinger'];
                        $_REQUEST['stepseq_'.$concurrentidStepCount]=$concurrentidStepCount;
                        $concurrentidStepCount++;
                        $_REQUEST['concurrentidStepCount']=$concurrentidStepCount;
                    }
                    else  if($concurrentidStepCount>0)
                    {
                        break;
                    }
                    
                }
            }
            
            
        } 
        $approvelog['isnewlog'] = 'yes';
		foreach($insertcolumns as $col){
			$fieldsql .= $col.',';
			$values[] = $approvelog[$col];
		}
		$fieldsql = trim($fieldsql,',');
		$time = time();
        $nowtime = date('Y-m-d H:i:s',$time);
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
       
        
       //反审批
      
       if($iscanceloperation=='yes')
        {
            $sql='update ld_approvelog set createdtime=now(),isfinished="yes",approveresult=? , approved_by=?,approve_autograph=?,approve_autograph_path=? 
            where crmid=? and isfinished="no" ';
            
           
            $adb->pquery($sql,array($approvelog['approveresult'],$current_user->id,$approve_autograph,$_REQUEST['approve_autograph_path'],$approvelog['crmid']));
                      
        } 
      
        $logconcurrentid=$approvelog['logconcurrentid'];
        $currentapprover= $approvelog['nextstepapproveby'];
        
        if($approvelog['logconcurrentid']>0)
        {
            
           
            //是否为并发步骤最后一步
            //$islaststepconcurrent=$this->getisLastStepConcurrent($approvelog['crmid'],$approvelog['logconcurrentid'],$approvelog['approveid']);
            
              // dump(array($approvelog['approveresult'],$current_user->id,$approve_autograph,$_REQUEST['approve_autograph_path'],$_REQUEST['approvelogid']));
            if(($approvelog['approveresult']=='1'&&$_REQUEST['stepid']>0)||$approvelog['approveresult'] == 6||$approvelog['approveresult']==2||$approvelog['approveresult']==17)
            {
                $tmpapproveresult=$approvelog['approveresult'];
                if($tmpapproveresult==2)
                {
                    $tmpapproveresult=1;
                }
                
                if($approvelog['approveresult'] == 6)//加签
                {
                    $sql='update ld_approvelog set createdtime=now(),isfinished="yes",approveresult=? 
                     ,description=?,approved_by=?,nextstepapproveby=?,approve_autograph=?,approve_autograph_path=? where id=? ';
                
                
                      $adb->pquery($sql,array($tmpapproveresult,$approvelog['description'],
                      $current_user->id,$approvelog['nextstepapproveby'], $approve_autograph,$_REQUEST['approve_autograph_path'],$_REQUEST['approvelogid']));
                }else if($approvelog['approveresult'] == 17){//审批步骤设置变化，审批人变更
                    //如果是会签审批
                    if($approvelog['nextstep_countersigner'] == 'yes'){ 
                        //更新原有会签审批记录为已完成
                        $sql = "update ld_approvelog set isfinished=?,approveresult=?,approved_by=? where stepid = ? and logconcurrentid = ? and crmid = ?";
                        $adb->pquery($sql,array('yes',$tmpapproveresult,-1,$approvelog['stepid'], $approvelog['logconcurrentid'],$approvelog['crmid']));
                        //按照新的审批人添加会签审批日志
                        $query = 'insert into ld_approvelog(id,crmid,approveid,stepid,approved_by
                         	,approveresult,createdtime,seqtime,nextstepid,nextstepapproveby,countersigner
                             ,nextstep_countersigner,augmentsinger,approve_autograph,approve_autograph_path
                             ,isfinished,stepseq,logconcurrentid,description,isnewlog)';
                		$query .= ' value(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)';
                        $timesql='select current_timestamp(6) as seqtime ';
                        $timeresult=$adb->pquery($timesql,array());
                        if(empty($seqtime))
                            $seqtime=$adb->query_result($timeresult,0,'seqtime');
                            
                        $nextstepapproveby_arr = explode(',',$approvelog['nextstepapproveby']);
                        foreach($nextstepapproveby_arr as $userid){
                            $approvelogid=$adb->getUniqueID('ld_approvelog'); 
                            $param=array($approvelogid,$approvelog['crmid'], $approvelog['approveid'],$approvelog['stepid'],0,12,date('now'),$seqtime,$approvelog['stepid'],$userid
                                ,$approvelog['nextstep_countersigner'],'no','','no','','no',$stepseq,$approvelog['logconcurrentid'],'','yes');
                            $adb->pquery($query,$param);
                        }
                        
                        
                    }else{
                        //如果修改前为会签，修改后为非会签
                        if($approvelog['countersigner'] == 'yes'){
                            //更新原有会签审批记录为已完成
                            $sql = "update ld_approvelog set isfinished=?,approveresult=?,approved_by=? where stepid = ? and logconcurrentid = ? and crmid = ?";
                            $adb->pquery($sql,array('yes',$tmpapproveresult,-1,$approvelog['stepid'], $approvelog['logconcurrentid'],$approvelog['crmid']));
                            
                            //按照新的审批人添加非会签审批日志
                            $query = 'insert into ld_approvelog(id,crmid,approveid,stepid,approved_by
                             	,approveresult,createdtime,seqtime,nextstepid,nextstepapproveby,countersigner
                                 ,nextstep_countersigner,augmentsinger,approve_autograph,approve_autograph_path
                                 ,isfinished,stepseq,logconcurrentid,description,isnewlog)';
                    		$query .= ' value(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)';
                            $timesql='select current_timestamp(6) as seqtime ';
                            $timeresult=$adb->pquery($timesql,array());
                            if(empty($seqtime))
                                $seqtime=$adb->query_result($timeresult,0,'seqtime');
                            
                            $approvelogid=$adb->getUniqueID('ld_approvelog'); 
                            $param=array($approvelogid,$approvelog['crmid'], $approvelog['approveid'],$approvelog['stepid'],0,12,date('now'),$seqtime,$approvelog['stepid'],$approvelog['nextstepapproveby']
                                ,$approvelog['nextstep_countersigner'],'no','','no','','no',$stepseq,$approvelog['logconcurrentid'],'','yes');
                            $adb->pquery($query,$param);
                            
                        }else{
                            $sql='update ld_approvelog set createdtime=now(),isfinished="no",approveresult=? 
                             ,description=?,approved_by=?,nextstepapproveby=?,approve_autograph=?,approve_autograph_path=? where id=? ';
                              $adb->pquery($sql,array($tmpapproveresult,$approvelog['description'],
                              -1,$approvelog['nextstepapproveby'], $approve_autograph,$_REQUEST['approve_autograph_path'],$approvelog['approvelogid']));
                    
                        }
                        
                    }
                }
                else
                {
                     $sql='update ld_approvelog set createdtime=now(),isfinished="yes",approveresult=? 
                     ,description=?,approved_by=?,approve_autograph=?,approve_autograph_path=? where id=? ';
                
                
                      $adb->pquery($sql,array($tmpapproveresult,$approvelog['description'],
                      $current_user->id,$approve_autograph,$_REQUEST['approve_autograph_path'],$_REQUEST['approvelogid']));
                }
               
            
                $logconcurrentid=$approvelog['logconcurrentid'];
                if($approvelog['approveresult'] == 6)//加签
                {
                    //加签
                    $nextstep_concurrentid=0;
                    $approvelogid=$adb->getUniqueID('ld_approvelog');
                    
                    $sql='select stepseq,seqtime from ld_approvelog where id=? and logconcurrentid=? ';
                    $tmpresult=$adb->pquery($sql,array($approvelog['approvelogid'],$approvelog['logconcurrentid']));
                    $stepseq=$adb->query_result($tmpresult,0,'stepseq');
                    $seqtime=$adb->query_result($tmpresult,0,'seqtime');
                    $tmpvalues=$values;
                    $fieldsql_arr=explode(",",$fieldsql);
                    $tmpsearchindex=array_search('approved_by',$fieldsql_arr);
                    $sql='select * from ld_approvestep where id=?';
                    $tmpresult=$adb->pquery($sql,array($_REQUEST['stepid']));
                    $tmpaugmentsinger=$adb->query_result($tmpresult,0,'augmentsinger');
                   
                 
                    $tmpvalues[$tmpsearchindex]=0;//加签的当前审批人为空
                    if($tmpaugmentsinger=='yes')
                    {
                         $tmpsearchindex=array_search('countersigner',$fieldsql_arr);
                         $tmpvalues[$tmpsearchindex]='yes';
                            
                        $tmpsearchindex=array_search('nextstepapproveby',$fieldsql_arr);
                        $tmpdesciptionsearchindex=array_search('description',$fieldsql_arr);
                        $tmpvalues[$tmpdesciptionsearchindex]='';
                        
                         $nextstepapproveby_arr=explode(',',$tmpvalues[$tmpsearchindex]);
                      
                        foreach($nextstepapproveby_arr as $tmpnextuserid)
                        {
                            $trimuserid=trim($tmpnextuserid,',');
                            if(empty($trimuserid))
                            {
                                continue;
                            }
                            
                            $tmpvalues[$tmpsearchindex]=$tmpnextuserid;
                           
                            $query = 'insert into ld_approvelog(id,createdtime,'.$fieldsql.',approve_autograph,approve_autograph_path,stepseq,seqtime,isfinished,logconcurrentid) 
            					values('.$approvelogid.',now(),'.generateQuestionMarks($tmpvalues).',\''.$approve_autograph.'\',\''.$_REQUEST['approve_autograph_path'].'\',\''.$stepseq.'\',\''.$seqtime.'\',\'no\','.$approvelog['logconcurrentid'].');';
            		 
                            $adb->pquery($query,array($tmpvalues));
                            $approvelogid=$adb->getUniqueID('ld_approvelog');
                        }
                    }
                    else{
                            $query = 'insert into ld_approvelog(id,createdtime,'.$fieldsql.',approve_autograph,approve_autograph_path,stepseq,seqtime,isfinished,logconcurrentid) 
            					values('.$approvelogid.',now(),'.generateQuestionMarks($tmpvalues).',\''.$approve_autograph.'\',\''.$_REQUEST['approve_autograph_path'].'\',\''.$stepseq.'\',\''.$seqtime.'\',\'no\','.$approvelog['logconcurrentid'].');';
            		 
                             $adb->pquery($query,array($tmpvalues));
                    }
                }
                else{
                  
                    //判断是否为并发审批的最后一步
                    if($islaststepconcurrent=='yes'&&$_REQUEST['concurrentidStepCount']<=0)
                    {
                        //当前审批步骤，是并发步骤的最后一个审批步骤
                        //下一步不是并发步骤
                        //dump($approvelog);
                        $sql=' select * from ld_approvestep where approveid=? and id=?';
                        
                        $tmpresult=$adb->pquery($sql,array($approvelog['approveid'],$approvelog['nextstepid']));
                        $nextstep_concurrentid=0;
                        $nextstep_countersigner='no';
                        if($adb->num_rows($tmpresult))
                        {
                            $nextstep_concurrentid=$adb->query_result($tmpresult,0,'concurrentid');
                       
                            $nextstep_countersigner=$adb->query_result($tmpresult,0,'countersigner');
                        }
                        $approvelog['nextstep_countersigner']=$nextstep_countersigner;
                        $tmpapprovelogid=$adb->getUniqueID('ld_approvelog');
                        $stepseq=0;
                        $query = 'insert into ld_approvelog(id,createdtime,seqtime,stepseq,'.$fieldsql.',approve_autograph,approve_autograph_path) 
    					values('.$tmpapprovelogid.',now(),current_timestamp(6),0,'.generateQuestionMarks($values).',\''.$approve_autograph.'\',\''.$_REQUEST['approve_autograph_path'].'\');';
    		           $adb->pquery($query,array($values));
                       $logconcurrentid=0;
                        
                    }
                }
                
            }
            else{
                
                     
                   $query = 'insert into ld_approvelog(id,createdtime,seqtime,stepseq,'.$fieldsql.',approve_autograph,approve_autograph_path) 
        					values('.$approvelogid.',now(),current_timestamp(6),0,'.generateQuestionMarks($values).',\''.$approve_autograph.'\',\''.$_REQUEST['approve_autograph_path'].'\');';
        		 $adb->pquery($query,array($values));
            }
        }
        else
		{
		// dump($stepobj->skipstepinfo);
		  
    		  $query = 'insert into ld_approvelog(id,createdtime,seqtime,stepseq,'.$fieldsql.',approve_autograph,approve_autograph_path) 
    					values('.$approvelogid.',now(),current_timestamp(6),0,'.generateQuestionMarks($values).',\''.$approve_autograph.'\',\''.$_REQUEST['approve_autograph_path'].'\');';
    		 $adb->pquery($query,array($values));
             
            
		}
        
        //修改催审状态
        $focus = CRMEntity::getInstance($module);
        $tabname = $focus->table_name;
        $table_index = $focus->table_index;
        //满足任一条件修改单据催审状态（即ld_appprovelog表增加一条日志）:①非并发审批;②并发审批：加签;③并发审批：非加签且为并发审批的最后一步;
        if($approvelog['logconcurrentid']<=0||((($approvelog['approveresult']=='1'&&$_REQUEST['stepid']>0)||$approvelog['approveresult']==2)&&$islaststepconcurrent=='yes'&&$_REQUEST['concurrentidStepCount']<=0)||$approvelog['approveresult']==6)
        {
            $adb->pquery("update $tabname set approveexpediting='no' where $table_index = ?",array($crmid));
        }
        
      $this->insertStepID_arr=[];
      $this->insertStepID_arr[]=$approvelog['stepid'];//已经插入的审批步骤
      $concurrentInsertStepInfo=array('logconcurrentid'=>0);
    
      $_REQUEST['new_concurrentidStepCount']=$_REQUEST['concurrentidStepCount'];
     $new_description=$_REQUEST['description'];
    $_REQUEST['description']='';
    
    //edit:can 2021-01-14 44276: （61mis.com/kfbcrm）并发审批；OA表单-常用审批单；单据编号PTSP117 ， 二级审批时，不通过，返回上一步，结果进入了三级的并发审批
      if($_REQUEST['concurrentidStepCount']>1&&($approvelog['approveresult']==1||
                ($approvelog['approveresult']==5&&($_REQUEST['action']=='SaveApproveLog'||$_REQUEST['file']=='SaveApproveLog'))
            )
         )
      {
            //界面传值下一步是并发审批步骤
       
           $concurrentInsertStepInfo= $this->insertConcurrentApproveLog($stepobj,$approvelog);//插入并发步骤
          
           $logconcurrentid=$concurrentInsertStepInfo['logconcurrentid'];
           
           $with_concurrent = 'yes';
      }

      //跳过的审批步骤的审批历史
       $skipstepConcurrentinfo= $stepobj->saveSkipApproveLog($crmid);
      //edit:can 2020-12-17 43827: （61mis.com/kfbcrm）并发审批：OA表单-常用审批单；单据编号PTSP56，并发审批中，增加步骤审批人，审批人的审批意见在日志显示
    
     if(sizeof($stepobj->skipstepinfo)>0&&$stepinfo['nextstepid']>0)
     {
            //跳过进入的下一步判断是否为并发
            //$stepinfo['nextstepid']:防止反审批和审批结束
            $lastskipstepinfo=$stepobj->skipstepinfo[sizeof($stepobj->skipstepinfo)-1];
           
            if(is_array($approvestepinfo_arr)&&array_key_exists($approvelog['approveid'],$approvestepinfo_arr))
            {
                
            }
            else
            {
                if(!is_array($approvestepinfo_arr))
                {
                    $approvestepinfo_arr=[];
                }
               $approvestepinfo_arr[$approvelog['approveid']]=$this->getAllStepInfoByApproveid($approvelog['approveid']);
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
            foreach($approvestepinfo_arr[$approvelog['approveid']] as $tmpindex=>$tmpstepinfo)
            {
                
                if($tmpstepinfo['stepid']==$lastskipstepinfo['nextstepid'])
                {
                    //满足条件的步骤在并发步骤的中间，所以只能提前获取并发步骤ID判断
                        $tmpconcurrentid=$tmpstepinfo['concurrentid'];
                        $con_sequence=$tmpstepinfo['sequence'];
                         break;
                }
            }
          
           // dump($this->checkConcurrentStepAllSkip($tmpconcurrentid,$approvelog['approveid'],$stepobj));
            /**
              * 当前跳过并发步骤的所有步骤
              * **/
             if($tmpconcurrentid>0&&$this->checkConcurrentStepAllSkip($tmpconcurrentid,$approvelog['approveid'],$stepobj)=='yes')
             {
                //edit:can 2020-12-18 043841: （61mis.com/kfbcrm）并发审批：财务管理-销售发票；单据编号INV30；审批流“销售发票并发跳过”；第一步审批不符合条件跳过，直接进入并发步骤中跳过时，无法进入并发最后一步
                    $con_sequence=floor($con_sequence)+1;//获取下一个sequence
					
                    foreach($approvestepinfo_arr[$approvelog['approveid']] as $tmpindex=>$tmpstepinfo)
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
                                 
                                 $tmpnextstepapproveby=$this->getApproveBy($tmpapprovetype,$tmpapprovevalue,$approvelog['crmid']);
                                 $approvestepobj->saveskip_nextstepapproveby=$tmpnextstepapproveby;
                                 $currentapprover=$tmpnextstepapproveby;
                                 $tmpvalues=$values;
                                 $fieldsql_arr=explode(",",$fieldsql);
                                 
                                 $tmpsearchindex=array_search('stepid',$fieldsql_arr);
								 //通过下一步并发步骤，当所有并发步骤都不满足条件时，当时步骤则显示并发里的第一步
                                 //$tmpvalues[$tmpsearchindex]=$stepinfo['nextstepid'];
                                 $tmpvalues[$tmpsearchindex]=$approvelog['nextstepid'];
								 $tmpsearchindex=array_search('approved_by',$fieldsql_arr);
                                 $tmpvalues[$tmpsearchindex]='-1';
                                  $tmpsearchindex=array_search('nextstepapproveby',$fieldsql_arr);
                                 $tmpvalues[$tmpsearchindex]=$currentapprover;
                                 $tmpsearchindex=array_search('nextstepid',$fieldsql_arr);
                                 $tmpvalues[$tmpsearchindex]=$tmpstepinfo['stepid'];
                                 $tmpsearchindex=array_search('countersigner',$fieldsql_arr);
                                 $tmpvalues[$tmpsearchindex]='no';
                                 $tmpsearchindex=array_search('nextstep_countersigner',$fieldsql_arr);
                                 $tmpvalues[$tmpsearchindex]=$tmpstepinfo['countersigner'];
								 //下一步跳过并发后，满足条件的审批步骤，记录了当前审批步骤的审批意见
                                 $tmpsearchindex=array_search('description',$fieldsql_arr);
                                 $tmpvalues[$tmpsearchindex]='';
                                 $query = 'insert into ld_approvelog(id,createdtime,seqtime,stepseq,'.$fieldsql.') 
    				                	values('.$approvelogid.',now(),current_timestamp(6),0,'.generateQuestionMarks($tmpvalues).');';
                                 $adb->pquery($query,$tmpvalues);
                                 $logconcurrentid=0;
                                 $stepobj->skipstepinfo[sizeof($stepobj->skipstepinfo)-1]['nextstepid']=$tmpstepinfo['stepid'];
                                
                            }
                            else//跳过即将进入并发步骤
                                $skipstepConcurrentinfo=['logconcurrentid'=>0];
                            break;
                        }
                    }
             }
             
            foreach($approvestepinfo_arr[$approvelog['approveid']] as $tmpindex=>$tmpstepinfo)
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
                        //$tmpconcurrentid=$tmpstepinfo['concurrentid'];
                         //echo $crmid.'ass'.$curstep_concurrentid."<br>";
                        if($tmpconcurrentid==$curstep_concurrentid)
                        {
                            //和界面传值过来的是同一个并发步骤
                            break;
                        }
                       
                        if($skipstepConcurrentinfo['logconcurrentid']<=0)
                        {
                            
                            $skipstepConcurrentinfo=[];
                            $skipstepConcurrentinfo['concurrentid']=$tmpconcurrentid;
                            $sql='select logconcurrentid,current_timestamp(6) as seqtime from ld_approvelog_concurrent ';
                            $tmpresult=$adb->pquery($sql,array());
                            $skipstepConcurrentinfo['logconcurrentid']=$adb->query_result($tmpresult,0,'logconcurrentid');
                            $skipstepConcurrentinfo['seqtime']=$adb->query_result($tmpresult,0,'seqtime');
                            $sql='update ld_approvelog_concurrent set logconcurrentid=logconcurrentid+1 ';
                            $adb->pquery($sql,array());
                        }
                        else{
                            //有并发步骤
                           // $skipstepConcurrentinfo['concurrentid']=$tmpconcurrentid;
                              
                        }
                       
                        $this->insertSkipStepConcurrentApproveLog($stepobj,$skipstepConcurrentinfo,$approvelog);
                        
                        $logconcurrentid=$skipstepConcurrentinfo['logconcurrentid'];
                        break;
                    }
                }
            }
     }
     //批量审批会用到        
     $_REQUEST['description']=$new_description;
     
            
     
      if($logconcurrentid>0)
      {
            //获取并发步骤的所有待审批人和审批步骤
           $sql='select GROUP_CONCAT(distinct nextstepapproveby),group_concat(distinct stepid)  from ld_approvelog 
           where approveid=? and logconcurrentid=? and isfinished="no" ';
           $tmpresult=$adb->pquery($sql,array($approvelog['approveid'],$logconcurrentid));
           $tmpstr_arr=array_unique(explode(',',$adb->query_result($tmpresult,0,0)));
        
           $currentapprover=implode(',',$tmpstr_arr);
         //  $tmpstr_arr=array_unique(explode(',',$adb->query_result($tmpresult,0,1)));
           //$currentapprovestepid=implode(',',$tmpstr_arr);
      }
      else 
      {
        $sql='select nextstepapproveby,id from ld_approvelog where crmid=? order by id desc limit 1';
        $result=$adb->pquery($sql,array($approvelog['crmid']));
        $id = $adb->query_result($result,0,'id');
        //duan 判断下一步审批人是否为空，如果为空则执行特殊处理方式,因为需要修改单据中的值，所以获取到执行的结果
        $empty_approver_result = $this->emptyapprover_solution($id);
        if ($empty_approver_result['type']=='change'){//转交其他审批人
            $approveby = $empty_approver_result['nextstepapproveby'];
        }else{
            $approveby = $adb->query_result($result,0,'nextstepapproveby');
        }
        $approvelog['nextstepapproveby'] = $approveby;
        $currentapprover=$approvelog['nextstepapproveby'];
      }
        
        /*
         * editor:gyq_05
         * reason:生成消息提醒
         * */
        
        
        global $global_approvereminds;
        require_once(globalStatic::$root_directory."modules/Approve/CommonApproveVar.php");
        //@param 参数$approvelog是一个包含审批历史的数组，需传审批步骤IDstepid、审批结果approveresult、下一步审批人nextstepapproveby
        if(sizeof($stepobj->skipstepinfo)>0)
            $approvelog['nextstepid']=$stepobj->skipstepinfo[sizeof($stepobj->skipstepinfo)-1]['nextstepid'];
      
  
       
		//获取审批步骤高级条件字段
		$focus = CRMEntity::getInstance($module);
		$tabname = $focus->table_name;
		$tabindex = $focus->table_index;
	//	$status = $this->getApproveFieldColumnname($module);
		//获取审批步骤高级条件设定值
		$query="select modulestatus,pickcolumnname from ld_approvestep left join
		ld_approvestepdetails on ld_approvestep.id=ld_approvestepdetails.stepid
		where approveid=? and stepid=? and pass=? ";
        if($_REQUEST['file']=='getCancelApprove' && ($approvelog['stepid']==-2|| $approvelog['approveresult'] == 4)){
            //duan 路总要求反审批时不触发不通过的字段赋值
        }else{
            //ls 2022-05-18 0051805：审批步骤高级功能里，设置通过时的动态赋值，结果审批“不通过，返回上一”步时也执行了通过时的赋值
            if(3 == $approvelog['approveresult'] || 4 == $approvelog['approveresult'] || 5 == $approvelog['approveresult'])

            {
                //edit:can 2022 53445 合同订单审批流程，高级功能动态赋值：通过 订单状态＝项目经理已确认；不通过 项目经理已驳回。在该步骤审批时，选择不通过
                if($approvelog['stepid']=='-2')
                {
                    $sql='select nextstepid from ld_approvelog where crmid=? order by id desc limit 1 ';
                    $tmpresult=$adb->pquery($sql,array($approvelog['crmid']));
                    $result = $adb->pquery($query,array($approvelog['approveid'],$adb->query_result($tmpresult,0,'nextstepid'),1));

                }
                else
                    $result = $adb->pquery($query,array($approvelog['approveid'],$approvelog['stepid'],1));
            }
            else
                $result = $adb->pquery($query,array($approvelog['approveid'],$approvelog['stepid'],0));
        }
        $num_rows = $adb->num_rows($result);
        $approvestepdetails_arr = array();
        if($adb->num_rows($result)>0)
        {
            for($i=0;$i<$num_rows;$i++){
                $tmp_arr = array();
                $modulestatus = $adb->query_result($result,$i,'modulestatus');
                $pickcolumnname=$adb->query_result($result,$i,'pickcolumnname');
                $picktablename=$focus->fieldobj->getFieldInfoBykeyValue("columnname",$pickcolumnname,"tablename");
                $pickfieldname=$focus->fieldobj->getFieldInfoBykeyValue("columnname",$pickcolumnname,"fieldname");
                $tmp_arr['modulestatus'] = $modulestatus;
                $tmp_arr['pickcolumnname'] = $pickcolumnname;
                $tmp_arr['pickfieldname'] = $pickfieldname;
                $approvestepdetails_arr[$picktablename][] = $tmp_arr;
            }
        }
        //BUG20240821-75 duan 自动通过的步骤也要触发审批通过后赋值
        if(sizeof($stepobj->skipstepinfo)>0){
            foreach ($stepobj->skipstepinfo as $tmp_info){
                $cur_stepid = $tmp_info['curstepid'];
                if($stepobj->skiptypearr[$cur_stepid] == 'approveremove' || $stepobj->skiptypearr[$cur_stepid] == 'emptyapprover'){
                    $result = $adb->pquery($query,array($approvelog['approveid'],$tmp_info['curstepid'],0));
                    $num_rows = $adb->num_rows($result);
                    for($i=0;$i<$num_rows;$i++){
                        $tmp_arr = array();
                        $modulestatus = $adb->query_result($result,$i,'modulestatus');
                        $pickcolumnname=$adb->query_result($result,$i,'pickcolumnname');
                        $picktablename=$focus->fieldobj->getFieldInfoBykeyValue("columnname",$pickcolumnname,"tablename");
                        $pickfieldname=$focus->fieldobj->getFieldInfoBykeyValue("columnname",$pickcolumnname,"fieldname");
                        $tmp_arr['modulestatus'] = $modulestatus;
                        $tmp_arr['pickcolumnname'] = $pickcolumnname;
                        $tmp_arr['pickfieldname'] = $pickfieldname;
                        $approvestepdetails_arr[$picktablename][] = $tmp_arr;
                    }
                }
            }
        }
	
		//提醒
		//require_once('./modules/Approve/Remind.php');
        /*
         * editor:gyq_05
         * reason:取消调用旧*提醒方法
         * date  : 2016 3 4
         * */
		//$this->ApproveRemindInfo($module,$approvelog);
		//执行审批步骤高级条件
		$approvestatusarr = array(
			'1'=>constant('D_A_S_APPROVALOF'),//'审批中',
			'2'=>constant('D_A_S_APPROVED'),//'已批准',
			'3'=>constant('D_A_S_REJECTED'),//'已拒绝',
			'4'=>constant('D_A_S_DISMISSED'),//'已驳回'
			'5'=>constant('D_A_S_APPROVALOF'),//'审批中',
			'6'=>constant('D_A_S_APPROVALOF'),//'审批中',
            '12'=>constant('D_A_S_APPROVALOF'),//'并发审批中',
            '14'=>constant('D_A_S_APPROVALOF'),//'审批中'
            '17'=>constant('D_A_S_APPROVALOF'),//'审批中'
            '18'=>constant('D_A_S_APPROVALOF'),//'审批中'
		);
		$approvestatus = $approvestatusarr[$approvelog['approveresult']];
        $pagemode='';
         if($approvestatus==$approvestatusarr['2'])
        {
            $pagemode='Approved';//已批准
        }
        else if($approvestatus==$approvestatusarr['4'])
        {
            $pagemode='Dismissed';//已驳回
        }
        else if($approvestatus==$approvestatusarr['3'])
        {
            $pagemode='Rejected';//已拒绝
        }
        if(!empty($pagemode))
        {
             crm_load_class_file("cls_savereverse",'include/SaveReverse');
             
            $workflowreverseobj=cls_savereverse::getInstance($module);
            $workflowreverseobj->setPageMode($pagemode);
            $workflowreverseobj->isRead = 'no';
            $workflowreverseobj->getInfo();
             if($adb->num_rows($workflowreverseobj->workflowresut)>0)
             {
                  global $reset_retrieve_entity_info;//修改日志需要重新获取数据
                  $reset_retrieve_entity_info='yes';//批量提交
                 $focus->retrieve_entity_info($approvelog['crmid'], $module);
                 $beforefieldvalue_arr=$focus->column_fields;
             }
        }
        $sql='select approvestatus from '.$tabname. ' where '.$tabindex.' = '.$approvelog['crmid'];
        //修改前的审批状态
        $before_approveresult=$adb->pquery($sql,array());
        global $before_approveinfo;
        $before_approveinfo['approvestatus']=$adb->query_result($before_approveresult,0,'approvestatus');
        // @edit:liushuai @date:2020-07-13 @reason: 审批中心查询优化：发起人（提交人）、发起时间（提交时间）、审批步骤（当前审批步骤）， 放在单据表里面。(批量审批时当前审批步骤：currentapprovestepid)
        if($tabname == 'ld_potential'){
            $query1 = 'SELECT sales_stage,potentialid FROM ld_potential WHERE potentialid = "'.$approvelog['crmid'].'" LIMIT 1;';
            $result = $adb->pquery($query1);       
            $lastsales_stage = $adb->query_result($result,0,'sales_stage'); 
            $query = 'update '.$tabname.' set approvestatus="'.$approvestatus.'",approveby="'.$current_user->id.'",approvetime="'.date("Y-m-d H:i:s").'",currentapprovestepid="'.$approvelog['stepid'].'" , lastsales_stage="'.$lastsales_stage.'",currentapprover="'.$currentapprover.'" where '.$tabindex.' = '.$approvelog['crmid'];
        }else{
            $query = 'update '.$tabname.' set approvestatus="'.$approvestatus.'",approveby="'.$current_user->id.'",approvetime="'.date("Y-m-d H:i:s").'",currentapprovestepid="'.$approvelog['stepid'].'",currentapprover="'.$currentapprover.'" where '.$tabindex.' = '.$approvelog['crmid'];
        }	
          
       	$adb->pquery($query,array());
       if($adb->database->_errorMsg!='')
        {
             $errormsg=$adb->database->_errorMsg;
             unset($adb);
             $adb = new PearDatabase();;//::getInstance();
             $adb->connect();
       	    $adb->pquery($query,array());
           // $sql='insert into ld_adblog(errormsg,crmid,createdtime,`sql`)value(?,?,?,?)';
            //$adb->pquery($sql,array($errormsg,$approvelog['crmid'],date("Y-m-d H:i:s"),$query));
            
        }
        //审批后修改下拉框赋值
        if(is_array($approvestepdetails_arr)&&sizeof($approvestepdetails_arr)>0)
        {
            $focus->retrieve_entity_info($approvelog['crmid'], $module);
            $focus->getModuleStatic('ModTracker');//字段修改日志
            foreach($approvestepdetails_arr as $tmp_picktablename => $pickcolumn_arr){
                //获取所有选中的字段
                $tmp_fieldsql = '';
                //pickfieldname
                foreach($pickcolumn_arr as  $column_info){
                    $pickcolumnname = $column_info['pickcolumnname'];
                    $modulestatus = $column_info['modulestatus'];
                    $pickfieldname = $column_info['pickfieldname'];
                    $tmp_fieldsql .= $pickcolumnname." = '".$modulestatus."',";
                    //edit:duan date:2024/10/22 reason:字段值发生变化时增加修改日志
                    //dump([$focus->column_fields,$pickfieldname]);
                    if($modulestatus != $focus->column_fields[$pickfieldname]){
                        $focus->modstatic->saveFieldLogOne($module,$pickfieldname,$approvelog['crmid'],$focus->column_fields[$pickfieldname], $modulestatus);
                    }
                }
                $tmp_fieldsql = trim($tmp_fieldsql,',');
                if (!empty($tmp_picktablename) && !empty($tmp_fieldsql)) {
                    $query=" update ".$tmp_picktablename ." set $tmp_fieldsql where ".$focus->tab_name_index[$tmp_picktablename].'=?';
                    $adb->pquery($query,array($approvelog['crmid']));
                }
            }
        }
	
		global $modulestatus_now;
		$modulestatus_now = $modulestatus;
		//回调函数
		$focus = CRMEntity::getInstance($module);

		if(3 == $approvelog['approveresult']){//已拒绝，审批失败
            $focus->failedApproved($approvelog['crmid']);
        }

		elseif(4 == $approvelog['approveresult']||$_REQUEST['setype']=='cancel'){
		          //已驳回,不通过返回负责人,回撤到上一步，使用新的流程重新流转等等
                  //$_REQUEST['setype']=='cancel'一定要添加，因为反审批有$approvelog['approveresult']=1
            $focus->rejectApproved($approvelog['crmid']);
        }

		elseif(2 == $approvelog['approveresult']){//已批准
            $focus->id = $approvelog['crmid'];
			$focus->successApprove($approvelog['crmid']);
			$focus->retrieve_entity_info($approvelog['crmid'], $module);
			$focus->save_workflow($module,$focus,'Approved');
            //edit:can 49411: 【融君】V8.4.5.4（无外网）服务合同审批通过后，客户的最晚服务到期日没有更新，但是驳回后重新审批又成功更新了，例：SXRJ0292、SXRJ0400（详情见说明）
            //批量审批两个或两个以上服务合同 ，这些服务合同的客户如果不一样,其中有的客户是无法更新最晚服务到期日
            $focus->column_fields['account_id']=0;
        }

		//elseif(1== $approvelog['approveresult'] && 'Project' == $module)
		elseif(1== $approvelog['approveresult']||$approvelog['approveresult']==6 ){

            if('Project' == $module){
                $focus->approveding($approvelog['crmid']);
            }
        }
        if(!empty($pagemode)&&$adb->num_rows($workflowreverseobj->workflowresut)>0)
         {
        
            $workflowreverseobj->setRecord($approvelog['crmid']);
            
            $focus->column_fields['approvestatus']=$approvestatus;
            
            $focus->column_fields['currentapprover']=$currentapprover;
            $focus->column_fields['approveby']=$current_user->id;
            $workflowreverseobj->setPageMode($pagemode);
             if (!isset($_REQUEST['batckapproved']) && $workflowreverseobj->checkCallApiPop() == 'yes')
                 $workflowreverseobj->setNotCallActionType(array('API','Link2ERP'));
            $workflowreverseobj->getStartComputer($beforefieldvalue_arr,$focus->column_fields,$pagemode);
            $stepinfo['workflow']['before_save_infos'] = $beforefieldvalue_arr;
            $stepinfo['workflow']['after_save_infos'] = $focus->column_fields;
             if (isset($_REQUEST['batckapproved']) && $workflowreverseobj->checkCallApiPop() == 'yes'){
                 $stepinfo['workflow']['callapimsg_arr'] = $workflowreverseobj->getExecResultData();
             }
         }
        require_once(globalStatic::$root_directory.'modules/Approve/ApproveRemind.php');
        $appremindObj = new ApproveRemind();
        $approvelog['nextstepapproveby']=$currentapprover;//edit:can 20210625 45144: （81mis.com/kfbcrm）客户管理-跟进记录；单据编号LXJL2，审批流“初级并发审批”，流程中审批人默认是单据负责人，提交审批时将审批人改为了"夏至"，通过一级并发后，二级并发的待审批提醒发给了单据负责人
       // dump($approvelog);
        $approvelog['approvelogid'] = $approvelogid;
        $appremindObj->CreateMultiApproveReminds($module,$approvelog);
        if($_REQUEST['new_concurrentidStepCount']>1)
        {
            /*for($i=0;$i<$_REQUEST['new_concurrentidStepCount'];$i++)
            {
                $approvelog_arr=$approvelog;
                 $appremindObj = new ApproveRemind();
                 $approvelog_arr['stepid']=$_REQUEST['nextstep_'.$i];
                 $approvelog_arr['nextstepid']=$_REQUEST['nextstep_'.$i];
                 $approvelog_arr['nextstepapproveby']=$_REQUEST['userid_'.$i];
                $appremindObj->CreateMultiApproveReminds($module,$approvelog_arr);
            }*/
        }
        //批量循环
        $_REQUEST['new_concurrentidStepCount']=0;
        $_REQUEST['concurrentidStepCount']=0;

        //ls 2021-08-11  【ID1001881】航港：加急（优先）审批
        if ($urgent == 'yes' && !empty($prevapproveid) && !empty($approvelogid))
            $adb->pquery("update ld_approvelog set urgent=? where crmid=? and  id >=? and approveid=? "
                        ,array($urgent,$approvelog['crmid'],$prevapproveid,$approvelog['approveid']));//更新最新审批步骤的审批日志urgent的值（并发审批多条记录）
	   //清空跳过步骤的记录，批量审批时使用
       $stepobj->skipstepinfo = array();

        return $stepinfo;
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
        $sql='select * from ld_approvestep where approveid=? order by sequence asc';
        $tmpresult=$adb->pquery($sql,array($approveid));
        $tmprows=$adb->num_rows($tmpresult);
        //所有需要读取的字段值
        $column_arr = array('sequence','concurrentid','approvetype','approvevalue','specifyapproverid','approveremarkrequire','ended',
            'module_field','step','emptyapproverdeal','countersigner','augmentsinger','name','steptype','childids','flowstepid',
            'branchflowstepid','approverremovetype','writesignrequired','writesignlogtype','approvalauthority');
        for($tmpi=0;$tmpi<$tmprows;$tmpi++)
        {
            $tmp_stepinfo_arr = array();
            foreach($column_arr as $tmp_column){
                $tmp_stepinfo_arr[$tmp_column] =$adb->query_result($tmpresult,$tmpi,$tmp_column);
            }
            $stepid = $adb->query_result($tmpresult,$tmpi,'id');
            $tmp_stepinfo_arr['stepid'] = $stepid;
            $tmp_stepinfo_arr['approvalauthority'] = ldcrm_json_decode(html_entity_decode($tmp_stepinfo_arr['approvalauthority']??''));
            $approvestepinfo_arr[$approveid][$stepid] = $tmp_stepinfo_arr;
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
                 ,isfinished,stepseq,logconcurrentid,description,isnewlog)';
        		$query .= ' value(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)';
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
                    if($approvelog_arr['stepid']== -2 || $approvelog_arr['approveresult']== 5){
                        $countersigner=$_REQUEST["countersigner_$i"];
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
                    $this->insertStepID_arr[]=$tmpstepid;
                    $this->insertStepID_arr=array_unique($this->insertStepID_arr);
                    
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
                                ,$countersigner,'no',$augmentsinger,$approve_autograph,'','no',$stepseq,$logconcurrentid,$description,'yes');
                            $adb->pquery($query,$param);
                            $approvelogid=$adb->getUniqueID('ld_approvelog');
                        }
                    }
                   else  //$nextstep_countersigner:一定是：No,
                    {
                        $param=array($approvelogid,$crmid, $approveid,$tmpstepid,0,$approve_result,'',$seqtime,$tmpstepid,$nextsetpby
                                ,$countersigner,'no',$augmentsinger,$approve_autograph,'','no',$stepseq,$logconcurrentid,$description,'yes');
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
	/**
	 * 【费用报销单】、【提现单】、【存现单】反审批后账户反写
	 * @param String $module 模块名
	 * @param Array $approvelog 审批历史保存信息
	 * @param String $record 单据ID
     * @param String $type 判断是否调用SaveApprovedLog修改审批状态
	 * Array(
	 *	   crmid,//数据ID
	 *     approveid,//审批流程
	 *     stepid,//审批步骤
	 *     approved_by,当前审批人
	 *     approveresult,当前审批类型（通过、驳回、已审批等）
	 *     description,//审批备注
	 *     nextstepid,//下一步审批步骤
	 *     nextstepapproveby,//下一步审批人
	 * )
     * 
	 * @project 反审批后，银行账户的金额没有反算。
	 * @author andrew 2015-5-12
	 */
    public function ApprovedcheckBankMonery($module,$approvelog,$record,$type='') {
        crm_load_class_file('cls_ApproveAction','modules/Approve');
        $ApproveActionObj=new cls_ApproveAction($this);
        $ApproveActionObj->ApprovedcheckBankMonery($module,$approvelog,$record,$type);
    }
  //判断当前步骤是否是第一步审批。判断是否显示：不通过，返回负责人 选项
  function getApprovePreStepApproveBy($record){
	  global $adb;
	  $query = 'select nextstepid,approveid from ld_approvelog where crmid = ?  and approved_by>0 ORDER BY createdtime desc,id desc limit 1';
	  $result = $adb->pquery($query,array($record));
	  $num_rows = $adb->num_rows($result);
	  $last = 0;
	  if($num_rows){
		 $nextstepid = $adb->query_result($result,0,'nextstepid');
		 $approveid = $adb->query_result($result,0,'approveid');
         $all_stepinfo_arr = $this->getAllStepInfoByApproveid($approveid);
         $count = 0;
         $next_stepinfo = $all_stepinfo_arr[$nextstepid];
         $find_childid = $next_stepinfo['flowstepid'];//需要寻找的id
         
         do{
            $find_parent = 'no';
            $count ++;
            foreach($all_stepinfo_arr as $tmp_stepinfo){
                $tmp_flowstepid = $tmp_stepinfo['flowstepid'];
                
                $tmp_childstr = $tmp_stepinfo['childids'];
                $tmp_child_arr = explode(',',$tmp_childstr);
                
                if(in_array($find_childid,$tmp_child_arr)){
                    //找到上一级节点
                    if($tmp_stepinfo['steptype']=='approver'){
                        $last++;
                    }
                    $find_childid = $tmp_flowstepid;
                    $find_parent = 'yes';
                    //找到-1时，结束查找
                    if($tmp_flowstepid < 0) $find_parent = 'no';
                    
                    break;
                }
            }
            if($find_parent == 'no'){
                break;
            }
         }while($count<=100);
	  }
	  return $last;
  }
	/**
	 * 通过ID自动审批单据
	 * @param Integer $record ID值
	 * @param Integer $approvedtype 审批通过或返回负责人
	 * @param String $description 备注
	 * @author Tujt 2015-05-11
	 */
	public function SaveRecordApproveLog($record,$approvedtype,$description = '',$approvelog_result=null) {
	    global $adb,$current_user,$approvestepinfo_arr;
        //$approvestepinfo_arr:某个审批流程下所有的审批步骤信息
		//1、通过ID获取对应的模块名
		$query = 'select crmid,setype from ld_crmentity where crmid in ('.$record.'); ';
		$result = $adb->pquery($query,array());
		$rows = $adb->num_rows($result);
        $successcount=0;

		$fldmodarr = array();$fld_module = '';$mes = '';
		if($rows > 0){
			for($i=0;$i<$rows;++ $i){
				$crmid = $adb->query_result($result,$i,'crmid');
				$setype = $adb->query_result($result,$i,'setype');
				$fldmodarr[$crmid] = $setype;
				//优化批量审批代码，将单据对应超链接字段名移出来
                $entityarray = getEntitynameInfo(getTabid($setype));
                $tabname = $entityarray['tablename'];
                $tabindex = $entityarray['entityidfield'];
                $tabfieldname = $entityarray['fieldname'];
                $query = 'select '.$tabindex.','.$tabfieldname.' as subject from '.$tabname.' where '.$tabindex.'='.$crmid;
                $res = $adb->pquery($query);
                $num_rows = $adb->num_rows($res);
                for($j = 0; $j<$num_rows; $j++){
                    $subject[$crmid]['subject'] = $adb->query_result($res,$j,'subject');
                }
			}
		}
        
        $result = $approvelog_result;
		$rows = $adb->num_rows($result);
		$approvelog = array();
        $err_mes = getFixedLabel('documenterrorinfo');
        $suc_mes = getFixedLabel('DOCUMENTSUCCESS');
		if(1 != $approvedtype){//3、已驳回，返回负责人

			if($rows > 0){
                //duan 20230112 批量反审批 时增加验证规则判断
                crm_load_class_file('cls_PageValidataSave','data');
                $PageValidataSaveobj=new cls_PageValidataSave($setype,0,0);
                $PageValidataSaveobj->setApplication('cancel');
                $PageValidataSaveobj->batchoprate = 'yes';//批量操作
             
				for($i=0;$i<$rows;++ $i){
					$crmid = $adb->query_result($result,$i,'crmid');
                    
//                    $logconcurrentid=$adb->query_result($result,$i,'logconcurrentid');//表示是否为并发步骤
					if(!isset($fldmodarr[$crmid])) continue;
					$fld_module = $fldmodarr[$crmid];
					/*$fld_focus = CRMEntity::getInstance($fld_module);
					$entityarray = getEntitynameInfo(getTabid($fld_module));
					$tabname = $entityarray['tablename'];
					$tabindex = $entityarray['entityidfield'];
					$tabfieldname = $entityarray['fieldname'];
					$query = 'select '.$tabindex.','.$tabfieldname.' as subject from '.$tabname.' where '.$tabindex.' in ('.$crmid.')';
					$res = $adb->pquery($query);
					$num_rows = $adb->num_rows($res);
					for($j = 0; $j<$num_rows; $j++){
						$subject[$crmid]['subject'] = $adb->query_result($res,$j,'subject');
					}*/
					$approveresult = $adb->query_result($result,$i,'approveresult');//审批类型
					//43703: （http://51mis.com/ys/lwljzgc/ [^]）客户问题（蔡云桥），演示账套（建筑工程行业演示账套），审批中心->待审批页签，点击材料采购单【开始处理】，待审批单据列表显示没有数据
					if(in_array($approveresult,array(2,3,4))){	//已驳回、已批准、已拒绝等状态不可以批量审批
						$mes .= sprintf($err_mes,'<a href="javascript:" referencemodule="'.$fld_module.'" referencerecord="'.$crmid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)">'.$subject[$crmid]['subject'].'</a>',getFixedLabel('APPROVAL'),getFixedLabel('dismissalapprovalrejecton')).'<br>';
						continue;
					}
					$nextstepid = $adb->query_result($result,$i,'nextstepid');//下一步审批步骤
					if(!$nextstepid){	//下一步审批步骤为空，则跳过
						$mes .= sprintf($err_mes,'<a referencemodule="'.$fld_module.'" referencerecord="'.$crmid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" >'.$subject[$crmid]['subject'].'</a>',getFixedLabel('APPROVAL'),getFixedLabel('thenextstepofapproveisempty')).'<br>';
						continue;
					}
                    //批量反审批时增加验证规则判断，先判断阻断操作的验证规则
                    $PageValidataSaveobj->resetobj($fld_module,$crmid);//重置验证规则对象
                    $PageValidataSaveobj->setAllowSave('no');
                    $PageValidataSaveobj->getValidDataInfoPhp();
                    if(!empty($PageValidataSaveobj->errortip)){
                        $mes .= sprintf($err_mes,'<a referencemodule="'.$fld_module.'" referencerecord="'.$crmid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" >'.$subject[$crmid]['subject'].'</a>',getFixedLabel('APPROVAL'),$PageValidataSaveobj->errortip).'<br>';
                        continue;
                    }
                    
					$approvelog['crmid'] = $crmid;//数据ID
					$approvelog['approveid'] = $adb->query_result($result,$i,'approveid');//审批步骤ID
					$approvelog['stepid'] = $nextstepid;//审批流程ID取上一部审批的下次审批流程值
					$approvelog['approved_by'] = $current_user->id;//审批人
					$approvelog['approveresult'] = 4;//已驳回
					$approvelog['description'] = $description;//备注
                    $nextstepapproveby=$adb->query_result($result,$i,'nextstepapproveby');
                    $currentapprover=$adb->query_result($result,$i,'currentapprover');
                    $nextuserids=explode(",",$currentapprover);
                    if(!in_array($current_user->id,$nextuserids))//如果当前步骤不在下一步审批人中，则跳过
                    {
						$mes .= sprintf($err_mes,'<a referencemodule="'.$fld_module.'" referencerecord="'.$crmid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" >'.$subject[$crmid]['subject'].'</a>',getFixedLabel('APPROVAL'),getFixedLabel('thecurrentuserisnotinthenextapprover')).'<br>';
                        continue;
                    }

                    //判断允许保存的验证规则
                    $PageValidataSaveobj->setAllowSave('yes');
                    $PageValidataSaveobj->resetinfo = 'yes';
                    $PageValidataSaveobj->getValidDataInfoPhp();
                    if(!empty($PageValidataSaveobj->errortip)){
                        $validata_errortip = getFixedLabel('TIPS').':'.$PageValidataSaveobj->errortip;
                    }else{
                        $validata_errortip = '';
                    }
                    
					$mes .= sprintf($suc_mes,'<a referencemodule="'.$fld_module.'" referencerecord="'.$crmid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" >'.$subject[$crmid]['subject'].'</a>',getFixedLabel('APPROVAL')).$validata_errortip.'<br>';
					$successcount++;

                    $flowinfo = $this->SaveApprovedLog($fld_module,$approvelog);

                    $callapimsg_arr = $flowinfo['workflow']['callapimsg_arr'];//工作流的调用API提示
                    if (is_array($callapimsg_arr) && count($callapimsg_arr)>0) {
                        $mes .= implode('<br>',$callapimsg_arr)."<br/>";
                    }
				}
			}
		}else{//4、通过，并进行下一步，如果已经是最后一步，则为已审批状态
			if($rows > 0){
                //duan 20230301 批量审批时增加验证规则判断
                crm_load_class_file('cls_PageValidataSave','data');
                $PageValidataSaveobj=new cls_PageValidataSave($setype,0,0);
                $PageValidataSaveobj->setApplication('finish');
                $PageValidataSaveobj->batchoprate = 'yes';//批量操作
                //duan 20230718批量通过修改审批必填字段判断
                crm_load_class_file('cls_ApproveMandatoryField','modules/Approve');
                $mandatoryfieldobj = cls_ApproveMandatoryField::getInstance($setype);

                $approvestepinfo_arr = array();
                $nextapproveinfo = array();
                $concurrentstep_arr = array();
                global $selectapprovecrmid_len;//edit:can 20220714 项目信息表（Potentials模块）-项目编号：22-190466-0002A-3524 ，目前该项目使用的是【项目立项】审批流
                $selectapprovecrmid_len=$rows;
                
				for($i=0;$i<$rows;++ $i){
					$crmid = $adb->query_result($result,$i,'crmid');
                    $logconcurrentid=$adb->query_result($result,$i,'logconcurrentid');//表示是否为并发步骤
                    $approveid=$adb->query_result($result,$i,'approveid');
                    $nextstepapproveby=$adb->query_result($result,$i,'nextstepapproveby');
                    $nextstep_countersigner=$adb->query_result($result,$i,'nextstep_countersigner');
                    $currentapprover=$adb->query_result($result,$i,'currentapprover');
//					$all_crmid[] = $crmid;
					if(!isset($fldmodarr[$crmid])) continue;
                   
					$fld_module = $fldmodarr[$crmid];
                    
					$approveresult = $adb->query_result($result,$i,'approveresult');//审批类型
                    //edit:can 2020-12-28 043978: (61mis.com/kfbcrm)审批中心-合同订单；成员Q 单据编号SO65，SO172，批量审批通过时，提示审批状态已改变，审批失败
					if(!in_array($approveresult,array(1,5,6,10,14,15,16,17,18))&&empty($logconcurrentid))
                    {
   	                     /*$fld_focus = CRMEntity::getInstance($fld_module);
                         $tmptablename=$fld_focus->table_name;
                         $tmptable_index=$fld_focus->table_index;
                         $linkfield= $fld_focus->list_link_field;
                          $sql="select $linkfield from $tmptablename where $tmptable_index=?";
                          $tmpresult=$adb->pquery($sql,array($crmid));
                          $tmpsubject=$adb->query_result($tmpresult,0,$linkfield);*/
                          $err_mes="审批状态已改变";
                          $mes .= '单据[<a referencemodule="'.$fld_module.'" referencerecord="'.$crmid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)"" >'.$subject[$crmid]['subject'].'</a>]'.$err_mes."<br>";
                          continue;//已驳回、已批准、已拒绝等状态不可以批量审批
                    }
                    $nextstepid = $adb->query_result($result,$i,'nextstepid');//获取审批日志下一步审批步骤，实际为下一个审批日志的当前步骤
                    $curstepid=$nextstepid;
                   
                    //获取审批步骤信息
                    if(!array_key_exists($approveid,$approvestepinfo_arr))
                    {
                        $approvestepinfo_arr[$approveid]=$this->getAllStepInfoByApproveid($approveid);
                    }

					if(!$nextstepid)
                    {
                        $err_mes="当前审批步骤为空！";

                       	$mes .= '单据[<a referencemodule="'.$fld_module.'" referencerecord="'.$crmid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)"" >'.$subject[$crmid]['subject'].'</a>]'.$err_mes."<br>";

                        continue;//下一步审批步骤为空，则跳过
                    }

                    $nextuserids=explode(",",$currentapprover);
                    if(!in_array($current_user->id,$nextuserids))//如果当前步骤不在下一步审批人中，则跳过
                    {
                        $err_mes="登录用户不在下一步审批人中!";

                       	$mes .= '单据[<a referencemodule="'.$fld_module.'" referencerecord="'.$crmid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)"" >'.$subject[$crmid]['subject'].'</a>]'.$err_mes;
                        continue;
                    }
                    //批量审批时增加验证规则判断，先判断阻断操作的验证规则
                    $PageValidataSaveobj->resetobj($fld_module,$crmid);//重置验证规则对象
                    $PageValidataSaveobj->setAllowSave('no');
                    $PageValidataSaveobj->getValidDataInfoPhp();
                    if(!empty($PageValidataSaveobj->errortip)){
                        $err_mes = getFixedLabel('documenterrorinfo');
                        $mes .= sprintf($err_mes,'<a referencemodule="'.$fld_module.'" referencerecord="'.$crmid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" >'.$subject[$crmid]['subject'].'</a>',getFixedLabel('APPROVAL'),$PageValidataSaveobj->errortip).'<br>';
                        continue;
                    }
                    
					$approveid = $adb->query_result($result,$i,'approveid');
                    $approvelog[$crmid]['islastconcurrentstep']=$islastconcurrentstep;
					//将审批日志保存信息按crmid放入数组中
					$approvelog[$crmid]['crmid'] = $crmid;//数据ID
					$approvelog[$crmid]['approveid'] = $approveid;//当前审批步骤ID
					$approvelog[$crmid]['stepid'] = $curstepid;//当前审批流程ID
                   
                    $approvelog[$crmid]['countersigner']=$nextstep_countersigner;
                    $approvelog[$crmid]['cur_stepapproveby']=$nextstepapproveby;
                    $approvelog[$crmid]['logconcurrentid']=$logconcurrentid;
					$approvelog[$crmid]['approved_by'] = $current_user->id;//当前审批人
					$approvelog[$crmid]['approveresult'] = 1;//通过（也可能是已审批，不在此处判断）
					$approvelog[$crmid]['description'] = $description;//备注
                    $approvelog[$crmid]['approvelogid']=0;
                    
					//将当前提交的审批流程ID统一放到数组中
					$nextapproveinfo['approveid'][$approveid] = $approveid;
					//保存每一个crmid对应的审批流程approveid、审批步骤stepid
					$nextapproveinfo['stepid'][$crmid]['approveid'] = $approveid;
					$nextapproveinfo['stepid'][$crmid]['stepid'] = $nextstepid;
                    
                    
				}
                
				if(!empty($nextapproveinfo['stepid'])){
					//设置出库单或入库单更新库存流水记录的触发点  1保存  0审核
					$deployarray_48=getSys_deploy(48);
					$deploy_value_48 = $deployarray_48['deploy_value'];
					//设置是否允许负库存出库	// 1是 0否
					$deployarray=getSys_deploy(141);
					$deploy_value_101 = $deployarray['deploy_value'];
					$fld_focus = CRMEntity::getInstance($fld_module);
					/*$entityarray = getEntitynameInfo(getTabid($fld_module));
					$tabname = $entityarray['tablename'];
					$tabindex = $entityarray['entityidfield'];
					$tabfieldname = $entityarray['fieldname'];
					$query = 'select '.$tabindex.','.$tabfieldname.' as subject from '.$tabname.' where '.$tabindex.' in ('.implode(',',$all_crmid).')';
					$result = $adb->pquery($query);
					$num_rows = $adb->num_rows($result);
					for($i = 0; $i<$num_rows; $i++){
						$crmid = $adb->query_result($result,$i,$tabindex);
						$subject[$crmid]['subject'] = $adb->query_result($result,$i,'subject');
					}*/
                 
					//6、循环每一个crmid对应的审批流程和步骤
                    
					foreach($nextapproveinfo['stepid'] as $crmid=>$approveinfo)
                    {
                        $approveid=$approveinfo['approveid'];
                        $cur_stepid=$approvelog[$crmid]['stepid']; //当前步骤
                        $cur_stepapproveby=$approvelog[$crmid]['cur_stepapproveby'];//当前步骤的审批人
                        $nextstepapproveby=$cur_stepapproveby;//当前步骤的审批人
                        $nextstep_countersigner=$approvelog[$crmid]['countersigner'];//当前步骤是否为会签
                        $countersigner=$approvelog[$crmid]['countersigner'];
                    
					   //43668: （https://61mis.com/kfbcrm [^]）客户问题（邬丹华），设置审批流程定制步骤为“会签审批”（使用合同订单审批流程：123_1）时，批量审批错误，仅其中一人审批就审批通过了（需要补丁）
					   if($nextstep_countersigner=='yes'){//判断当前步骤是否为会签
						  //  $tmp_nextstep_user_arr=array(0,1);
							$tmp_nextstep_user_arr=array_filter(explode(',',$nextstepapproveby));
							if(sizeof($tmp_nextstep_user_arr)<=1){
								//会签步骤的审批人只有当前登录用户了
								$approveseq ++;//查找下一个审批流程对应的审批步骤
							}
						}else{
						    $tmp_nextstep_user_arr=[];
							$approveseq ++;//查找下一个审批流程对应的审批步骤
						}
                       
						//存在下一步审批步骤，取出审批步骤ID和审批人信息
                        if(!isset($fldmodarr[$crmid])) continue;
                        $nextstepinfo = $this->getnextstepinfo(0,$cur_stepid,$approveid,$crmid);
                        
                        if(!is_array($tmp_nextstep_user_arr)||sizeof($tmp_nextstep_user_arr)<=1){
                            if($nextstepinfo['nextstepid']>0){
                                $stepid = $nextstepinfo['nextstepid'];
                            	$stepinfo = $approvestepinfo_arr[$approveid][$stepid];
                                $approvetype = $stepinfo['approvetype'];
                                $approvevalue = $stepinfo['approvevalue'];
                                $emptyapproverdeal = $stepinfo['emptyapproverdeal'];
                                
                                $approvelog[$crmid]['nextstepid'] = $stepid;
                            	$approvelog[$crmid]['nextstepapproveby'] = $this->getApproveBy($approvetype,$approvevalue,$crmid,$emptyapproverdeal);
                            }else{//没有下一步审批步骤，说明当前这一步审批步骤直接结束流程
    							$approvelog[$crmid]['approveresult'] = 2;//标注为已审批
    						}
                        }else{
                           //会签步骤有多个人，则继续使用该会签步骤
                            $approvelog[$crmid]['nextstepid'] = $cur_stepid;
                            $tmp_nextstep_user='';//
                            foreach($tmp_nextstep_user_arr as $tmpuserid){
                                    if($tmpuserid==$current_user->id){
                                        continue;
                                    }
                                    $tmp_nextstep_user.=','.$tmpuserid;
                            }
                            $approvelog[$crmid]['nextstepapproveby'] = trim($tmp_nextstep_user,',');
                        }
                       
						$fld_module = $fldmodarr[$crmid];
                        $cur_stepid = $approvelog[$crmid]['stepid'];
                        $_REQUEST['stepid']=$cur_stepid;
                        $_REQUEST['approvelogid']=$approvelog[$crmid]['approvelogid'];
                        $_REQUEST['logconcurrentid']=$approvelog[$crmid]['logconcurrentid'];
                        $concurrentidStepCount=0;

                        $_REQUEST['nextstep_0']=$approvelog[$crmid]['nextstepid'];
                        
                        $approvestepinfo = $approvestepinfo_arr[$approveid][$cur_stepid];//审批步骤信息
                    	if($approvestepinfo['approveremarkrequire'] =="yes" && trim($approvelog[$crmid]['description'])=='')//判断当前步骤审批意见必填时，审批意见是否为空
                        {
                            $mes .= sprintf($err_mes,'<a referencemodule="'.$fld_module.'" referencerecord="'.$crmid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)"" >'.$subject[$crmid]['subject'].'</a>',getFixedLabel('APPROVAL'), getFixedLabel('APPROVEREMARKREQUIRE')).'<br>';
								
                            //$mes .=sprintf($err_mes,'<a referencemodule="'.$fld_module.'" referencerecord="'.$crmid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" >'.$subject[$crmid]['subject'].'</a>',getFixedLabel('APPROVEREMARKREQUIRE')).'<br>';
                            continue;
                        }
                    	//获取审批通过对应的审批必填字段
                        $choose_fieldname_arr = $mandatoryfieldobj->getMandatoryFieldByApprovesult($cur_stepid,1);
                        $module_status = $this->getModuleRecordStatus(implode(',',$choose_fieldname_arr),$crmid,$fld_module,'pc');
                        if($module_status=='no')
                        {
                            //edit:can 2021-01-05 43803: （61mis.com/kfbcrm）审批必填：OA表单-常用审批单；单据编号PTSP43，在审批中心操作批量审批单据，没有提示必填字段
                            $mes .= '<a referencemodule="'.$fld_module.'" referencerecord="'.$crmid.'"  onclick="OpenTabDetailView(ld(this),event)" >'.$subject[$crmid]['subject'].'</a>['.getFixedLabel('approvesetrequiredfield').']<br>';

                            continue;
                        }

                        if ($approvelog[$crmid]['approveresult'] == 2) {
                            //ls 20221201 XUQIU1000685  增加审批功能（盘点单、调拨单审批中心批量审批成功时，前置条件判断）
                            if ($fld_module == 'Checks') {
                                crm_load_class_file('CommonStock','include/Stock');
                                $infos = getChecksProductInfo($crmid,1,selCheckInfo($crmid,2));
                                if (sizeof($infos)>0) {
                                    $error_mes_warehouse = implode('',$infos['list']);
                                    $error_mes_warehouse = rtrim($error_mes_warehouse,'<br>');
                                    $mes .= sprintf($err_mes,'<a href="javascript:" referencemodule="'.$fld_module.'" referencerecord="'.$crmid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)">'.$subject[$crmid]['subject'].'</a>',getFixedLabel('APPROVAL'),$error_mes_warehouse).'<br>';
                                    continue;
                                }
                            } elseif ($fld_module == 'WareHouseTransfer') {
                                crm_load_class_file('CommonStock','include/Stock');
                                $fld_focus->retrieve_entity_info($crmid, $fld_module);
                                $outwarehouse = $fld_focus->column_fields['outwarehouse'];//调出仓库ID
                                $inwarehouse = $fld_focus->column_fields['inwarehouse'];//调入仓库ID
                                if($inwarehouse == $outwarehouse) {
                                    //调入和调出仓库不能一致
                                    $mes .= sprintf($err_mes,'<a href="javascript:" referencemodule="'.$fld_module.'" referencerecord="'.$crmid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)">'.$subject[$crmid]['subject'].'</a>',getFixedLabel('APPROVAL'),getFixedLabel('INANDOUTNOTSAME')).'<br>';
                                    continue;
                                }
                                elseif(is_admin($current_user) === false && getUserWarehouseStatus($inwarehouse) == false && getUserWarehouseStatus($outwarehouse) ==false)
                                {    //对仓库没有权限
                                    $mes .= sprintf($err_mes,'<a href="javascript:" referencemodule="'.$fld_module.'" referencerecord="'.$crmid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)">'.$subject[$crmid]['subject'].'</a>',getFixedLabel('APPROVAL'),getFixedLabel('YOUDONOTHAVEPERMISSIONTOTHISDOCUMENT')).'<br>';
                                    continue;
                                }else{
                                    if($deploy_value_48==0) {
                                        //产品A出库数量大于当前批次号产品数量
                                        $tmps= getMinZero_Batchtext_whenApprove('WareHouseTransfer',$crmid);
                                        if(is_array($tmps)&&sizeof($tmps)>0)
                                        {
                                            $error_mes_warehouse = '';
                                            foreach($tmps as $index=>$content) {
                                                $productname=$content['productname'];
                                                $error_mes_warehouse.=str_replace('{productname}','"'.$productname.'"',getFixedLabel('QUANTITYMORTHANCURRENTROWBATCH'))."<br>";
                                            }
                                            $mes .= sprintf($err_mes,'<a href="javascript:" referencemodule="'.$fld_module.'" referencerecord="'.$crmid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)">'.$subject[$crmid]['subject'].'</a>',getFixedLabel('APPROVAL'),'<br>'.$error_mes_warehouse).'<br>';
                                            continue;
                                        }
                                    }
                                }
                            }
                        }
                        //判断允许保存的验证规则
                        $PageValidataSaveobj->setAllowSave('yes');
                        $PageValidataSaveobj->resetobj($fld_module,$crmid);
                        $PageValidataSaveobj->getValidDataInfoPhp();
                        if(!empty($PageValidataSaveobj->errortip)){
                            $validata_errortip = getFixedLabel('TIPS').':'.$PageValidataSaveobj->errortip;
                        }else{
                            $validata_errortip = '';
                        }
                        
						if($fld_module == 'OutboundOrder' && $deploy_value_48 != 1 && $deploy_value_101 != 1){
							if($approvelog[$crmid]['approveresult'] == 2){
								$res = $fld_focus->getInventoryProductForWareQty($crmid);
								if($res == 'yes'){

									$mes .= sprintf($err_mes,'<a referencemodule="'.$fld_module.'" referencerecord="'.$crmid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)"" >'.$subject[$crmid]['subject'].'</a>',getFixedLabel('APPROVAL'),getFixedLabel('PRODUCTSQUANTITYEXCESS') . ',' . getFixedLabel('USERSAVEFAIL')).$validata_errortip.'<br>';
								}
                                else{
									$mes .= sprintf($suc_mes,'<a referencemodule="'.$fld_module.'" referencerecord="'.$crmid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" >'.$subject[$crmid]['subject'].'</a>',getFixedLabel('APPROVAL')).$validata_errortip.'<br>';
									$successcount++;
                                    $flowinfo = $this->SaveApprovedLog($fld_module,$approvelog[$crmid]);
								}
							}else{
								$mes .= sprintf($suc_mes,'<a referencemodule="'.$fld_module.'" referencerecord="'.$crmid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" >'.$subject[$crmid]['subject'].'</a>',getFixedLabel('APPROVAL')).$validata_errortip.'<br>';
								$successcount++;
                                $flowinfo = $this->SaveApprovedLog($fld_module,$approvelog[$crmid]);
							}
						}else{
							$mes .= sprintf($suc_mes,'<a referencemodule="'.$fld_module.'" referencerecord="'.$crmid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" >'.$subject[$crmid]['subject'].'</a>',getFixedLabel('APPROVAL')).$validata_errortip.'<br>';
							$successcount++;

                            $flowinfo = $this->SaveApprovedLog($fld_module,$approvelog[$crmid]);
						}

                        $callapimsg_arr = $flowinfo['workflow']['callapimsg_arr'];//工作流的调用API提示
                        if (is_array($callapimsg_arr) && count($callapimsg_arr)>0) {
                            $mes .= implode('<br>',$callapimsg_arr)."<br/>";
                        }
					}
				}
			}
		}
       
        if (!isset($_SESSION[$current_user->id . '_Approve_batchapproved']['correct'])) {
            $_SESSION[$current_user->id . '_Approve_batchapproved']['correct'] = 0;
        }
        $_SESSION[$current_user->id . '_Approve_batchapproved']['correct'] += $successcount;
        $_SESSION[$current_user->id . '_Approve_batchapproved']['edit_err'] .= $mes;

		return $mes;
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
        //duan 20230920 此反审批逻辑可能改的有问题,不好兼容并发的操作,先在新版本流程中使用
        global $adb;

        $num_rows=$adb->num_rows($result);

        if($num_rows > 0){
            $backstep_count=0;//回撤的次数
            $tmprowindex=0;

            //duan 20230920 如果反审批选中的审批日志，还是反审批的日志，就继续循环
            $tmp_index = 0;
            do{
                $stepid=$adb->query_result($result,$tmp_index,'stepid');
                $approveresult=$adb->query_result($result,$tmp_index,'approveresult');
                if($stepid=='-1')
                {
                    $tmprowindex=$tmp_index;
                    break;
                }
                if($stepid==-2||$approveresult==5)
                {
                    $tmprowindex+=2;
                }
                $tmp_index ++;
                if($tmprowindex>=$num_rows)
                {
                    break;
                }
            }while($tmp_index <= $tmprowindex);
        }

        if($tmprowindex>=$num_rows)
        {
            $tmprowindex=$num_rows-1;
        }
        return $tmprowindex;
    }
    
    function showSubmitPopup($module,&$rSmarty){
        global $weixin_user;
        global $current_user;
        $tabid=getTabid($module);

        //检查模块是否开启审批
        $approvemod = self::getApproveModuleInfo();
        if ($module == 'Events') {
            $approve_module = 'Calendar';
        }else
            $approve_module = $module;
        if (!isset($approvemod[$approve_module]) )
            return ;
        if(!$this->Blocksquicksubmit($module)){//如果不启用快速提交则返回空数组
            return array();
        }
        $approveinfo = $this->submitApprove($tabid);
        
        if(empty($approveinfo))
        {
            return ;
        }
        $focus = CRMEntity::getInstance($module);
        if ($focus->mode == 'edit') {
            $status = $this->getApproveStatus($focus->column_fields['approvestatus']);
            // ls 2021-11-17 【1002212】审批流程定制增加允许重复提交审批（徐昱轩）
            //已批准/已拒绝的单据允许再次提交审批，且有审批流程“审批结束编辑单据保存，自动提交审批时默认审批流程”为是，则编辑界面显示“保存并提交”按钮
            if (($status == 2 || $status == 3) && $this->recordAgainSubmit($module)) {
                foreach ($approveinfo as &$tmpapprove) {
                    if($tmpapprove['finishedallowedit']=='yes' && $tmpapprove['allowagainsubmit']=='yes') {
                        $tmpapprove['selected'] = 'selected';
                        break;
                    }
                }
            }
        }


        /*$defaultapprove=$approveinfo[0];
        foreach($approveinfo as $tmpapprove)
        {
             if($tmpapprove['selected']=='selected')
             {
                $defaultapprove=$tmpapprove;
                break;
             }
        }*/
        
        /*$nextStepInfo_arr = $this->getApproveStepInfo($defaultapprove['approveid'], 0,$current_user->id);

        $nextStepInfo = $nextStepInfo_arr;
        if (!empty($selectid) && sizeof($selectarr) > 1) {

            foreach ($nextStepInfo as $tmpindex => $tmpinfo) {
                $nextStepInfo[$tmpindex]['specifyapproverid'] = 1;
            }
        }*/

        // dump($nextStepInfo);
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
                    seqtime,nextstepid,nextstepapproveby,countersigner,nextstep_countersigner,approve_autograph,approve_autograph_path,stepseq,urgent,isnewlog)';
        $query .= 'SELECT ?,crmid,description,approveid,nextstepid,?,?,now(),current_timestamp(6),nextstepid,?,
					countersigner,nextstep_countersigner,approve_autograph,approve_autograph_path,stepseq,urgent,isnewlog from ld_approvelog
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
        //审批意见颜色修改
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
                
                //设置审批操作图标样式
                if(in_array($cur_result,$cancel_result_arr)||($cur_result==1&&$tmp_stepid==-2)){
                    //反审批
                    $tmp_approveloginfo['icon_class'] = 'approvelog_cancel';
                    $tmp_approveloginfo['tip'] = getFixedLabel('APPROVE_ANTIAPPROVAL');
                    $tmp_approveloginfo['tip_color'] = 'rgb(255,80,107)';
                    $tmp_approveloginfo['descrition_color'] = $cancel_descrition_color;
                }else if(in_array($cur_result,$pass_reuslt_arr) && ($tmp_stepid != -1 && $tmp_stepid != -2)){
                    //审批通过
                    $tmp_approveloginfo['icon_class'] = 'approvelog_pass';
                    if(in_array($cur_result,$autopass_result_arr)){
                        $tmp_approveloginfo['tip'] = getFixedLabel('AUTOMATICPASS');
                    }else{
                        $tmp_approveloginfo['tip'] = getFixedLabel('Approvals');
                    }
                    $tmp_approveloginfo['tip_color'] = 'rgb(48,199,117)';
                    $tmp_approveloginfo['descrition_color'] = $pass_descrition_color;
                }else if($curlogconcurrentid >0 && $cur_result==12){
                    //并发审批中
                    $tmp_approveloginfo['icon_class'] = 'approvelog_wait';
                    $tmp_approveloginfo['tip'] = getFixedLabel('Approvalof');
                    $tmp_approveloginfo['tip_color'] = 'rgb(255,127,0)';
                    $tmp_approveloginfo['OPERATOR'] = $tmp_approveloginfo['NEXTSTEPBYNAME'];
                    $incurrentapprove = 'yes';
                }
                else if($curlogconcurrentid >0 && ($cur_result==12 && $isfinished == 'yes')){
                    //并发审批反审批产生的多余日志需要处理
                    continue;
                }
                else if($tmp_stepid == -1 && $cur_result==1){
                    //提交审批
                    $tmp_approveloginfo['descrition_color'] = $pass_descrition_color;
                }else{
                    //其他操作
                    $tmp_approveloginfo['icon_class'] = 'approvelog_other';
                }
                
                //同一步骤的操作进行合并
                if($pre_stepid > 0 && $pre_stepid == $tmp_stepid){
                    if(in_array($tmp_stepid,$curlogconcurrentid_arr)){
                        continue;
                    }
                    $WholeApproveLog[$arr_index]['approveloginfo'][] = $tmp_approveloginfo;
                }else if($curlogconcurrentid == $pre_curlogconcurrentid){
                    //并发步骤进行合并
                    $curlogconcurrentid_arr[] = $tmp_stepid;
                    $WholeApproveLog[$arr_index]['approveloginfo'][] = $tmp_approveloginfo;
                }else{
                    $tmp_approvestep = array();
                    if($curlogconcurrentid>0){
                        $curlogconcurrentid_arr = array();
                        $curlogconcurrentid_arr[] = $tmp_stepid;
                        $tmp_stepinfo = $this->getStepInfo($tmp_stepid);
                        $concurrentid = $tmp_stepinfo['concurrentid'];
                        $tmp_approvestep['concurrentid'] = $concurrentid;
                        $tmp_approvestep['stepid'] = $concurrentid * -1;
                        $tmp_approvestep['stepname'] = getFixedLabel('ConcurrentApproval');
                    }else{
                        if(in_array($tmp_stepid,$curlogconcurrentid_arr)){
                            continue;
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
            $tmp_stepinfo=$this->getStepInfo($nextstepid);
            $approveid = $tmp_stepinfo['approveid'];
            $allstepinfo = $this->getAllStepInfoByApproveid($approveid);
            $tmp_nextstepid = $nextstepid;
            
            $count = 0;
            do{
                $count ++;
                $tmp_stepinfo = $allstepinfo[$tmp_nextstepid];
                
                $tmp_stepid = $tmp_stepinfo['stepid'];
                if($tmp_stepid == $nextstepid){
                    //找到当前步骤在审批流程中的位置
                    $find_step = 'yes';
                    $cur_concurrentid = $tmp_stepinfo['concurrentid'];
                }
                $tmp_approveloginfo = array();
                $tmp_concurrentid = $tmp_stepinfo['concurrentid'];
                
                $tmp_approvetype = $tmp_stepinfo['approvetype'];
                $tmp_approvevalue = $tmp_stepinfo['approvevalue'];
                $emptyapproverdeal = $tmp_stepinfo['emptyapproverdeal'];
                $tmp_approveloginfo['stepid'] = $tmp_stepid;
                //当前步骤的审批人从前一步的审批日志获取
                if($tmp_stepid == $nextstepid){
                    $tmp_approveloginfo['OPERATOR'] = $last_approveloginfo['NEXTSTEPBYNAME'];
                }else{
                    $nextstepby = $this->getApproveBy($tmp_approvetype,$tmp_approvevalue,$record,$emptyapproverdeal);
                    $tmp_approveloginfo['OPERATOR'] = trim($this->getApproveByName($nextstepby),',');
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
                
                $nextstepinfo = $this->getnextstepinfo(0,$tmp_stepid,$approveid,$record);
                $tmp_nextstepid = $nextstepinfo['nextstepid'];
            }while($tmp_nextstepid>0 && $count <= 100);
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
    
    //获取审批日志设置信息
    //获取审批日志设置信息
    public function getApprovelogSet(){
        crm_load_class_file('cls_ApproveCache','modules/Approve');
        return cls_ApproveCache::getApprovelogSet($this->module);
    }
    //获取新流程的审批步骤信息
    public function getnextstepinfo($flowstepid,$stepid,$approveid,$crmid){
        $this->getAllStepInfoByApproveid($approveid);
        $approvestepobj=$this->getApproveStepobj($this->module,$approveid,0);
        //根据条件判断新流程的审批步骤信息
        if($this->approvechange_check == 'yes'){
            $approvestepobj->setApprovechangeCheck($crmid,$this->column_value);
        }
        $stepinfo=$approvestepobj->getnextstepid($flowstepid,$stepid,$crmid,$approveid);
        
        return $stepinfo;
    }
    //获取审批流程高级查询条件
    public function getApproveInfo($approveid){
        global $adb;
        if(!empty($this->module)){
            $module = $this->module;
        }else{
            $sql = "select tabid from ld_approve where id = ?";
            $result = $adb->pquery($sql,array($approveid));
            if($adb->num_rows($result)>0){
                $tabid = $adb->query_result($result,0,'tabid');
                $module = getTabname($tabid);
                $this->module = $module;
            }else{
                return array();
            }
        }
        //将当前模块所有审批流程的筛选条件存下来，避免重复读取
        if(is_array($this->approvecondition_arr)&&isset($this->approvecondition_arr[$approveid])){
            return $this->approvecondition_arr[$approveid];
        }else{
            //获取当前模块所有审批流程的信息
            $sql = "select id,dataadv,dataadvgroup,isnewapprove from ld_approve where tabid = ?";
            $result = $adb->pquery($sql,array(getTabid($module)));
            $num_rows = $adb->num_rows($result);
            for($i=0;$i<$num_rows;$i++){
                $tmp_approveid = $adb->query_result($result,$i,'id');
                $dataadv = html_entity_decode($adb->query_result($result,$i,'dataadv'));//高级查询条件组
                $dataadvgroup = html_entity_decode($adb->query_result($result,$i,'dataadvgroup'));//高级查询组间关系
                $isnewapprove = $adb->query_result($result,$i,'isnewapprove');//判断是否为新审批流程
                $tmp_approveinfo = array('advft_criteria'=>$dataadv,
                                         'advft_criteria_groups'=>$dataadvgroup,
                                         'isnewapprove'=>$isnewapprove);
                $this->approvecondition_arr[$tmp_approveid]=$tmp_approveinfo;
            }
            return $this->approvecondition_arr[$approveid];
        }
    }
    //获取新审批流程中，所有的可选步骤
    //新的审批流程需要判断筛选条件，所以要根据单据id来判断
    //$cur_stepid 区分审批时获取审批步骤和提交时获取审批步骤，审批时需要排除自身
    public function getAllStepinfoByRecord($approveid,$record,$cur_stepid=0){
        $Stepinfo_arr = $this->getAllStepInfoByApproveid($approveid);
        $start_flowstepid = -1;//-1表示开始节点
        //根据flowstepid生成索引数组
        $cur_approvestepinfo = $Stepinfo_arr;
        $flowstepid_approvestepinfo = array();
        foreach($cur_approvestepinfo as $tmpstepid => $tmp_stepinfo){
            $tmp_flowstepid = $tmp_stepinfo['flowstepid'];
            $flowstepid_approvestepinfo[$tmp_flowstepid] = $tmp_stepinfo;
        }
        
        $tmp_stepid = $flowstepid_approvestepinfo[$start_flowstepid]['stepid'];
        
        $circulate_limit = 100;//循环上限100,避免死循环
        $count = 0;
        $tmp_sequence = 1;
        $all_stepinfo = array();
        do{
            $count++;
            if($count >=$circulate_limit){//循环上限100,避免死循环
                break;
            }
            
            $tmp_nextstepinfo = $this->getnextstepinfo($tmp_flowstepid,$tmp_stepid,$approveid,$record);
            
            if($tmp_nextstepinfo['nextstepid']>0){
                $tmp_flowstepid = $tmp_nextstepinfo['flowstepid'];
                $tmp_stepid = $tmp_nextstepinfo['nextstepid'];
                //获取审批步骤时排除掉当前步骤
                if(!empty($cur_stepid) && $cur_stepid == $tmp_stepid){
                }else{
                    $tmp_stepinfo = $flowstepid_approvestepinfo[$tmp_flowstepid];
                    $tmp_stepinfo['sequence'] = $tmp_sequence;
                    $all_stepinfo[] = $tmp_stepinfo;
                    $tmp_sequence += 1;
                }
            }else{
                break;
            }
        }while(true);
        $this->AllApproveStepinfoByrecord_arr[$approveid][$record] = $all_stepinfo;
        return $all_stepinfo;
    }
    //获取提交审批时显示的审批日志，显示所有审批步骤和审批人
    public function getSubmitApprovelog($approveid,$record){
        //加入当前流程待审批的步骤
        global $current_user;
        if($record>0 && $approveid >0){
            $max_showstepcount = 2;//审批日志最大展示条数
            $showstepcount = 0;//已选中条数
            $arr_index = -1;
            $allstepinfo = $this->getAllStepinfoByRecord($approveid,$record,0);
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
    //获取新的审批步骤对象
    public function GetApproveStepobj($module,$approveid,$approveresult){
        crm_load_class_file('cls_ApproveStepNew','modules/Approve');
        /*if(!empty($this->ApproveStepobj)){
            $this->ApproveStepobj->approveid=$approveid;
            $this->ApproveStepobj->approveresult=$approveresult;
            $this->ApproveStepobj->approvemodule=$module;
        }else{*/
         //edit:can 20230209 61302 赵沁 批量提交 费用报销单使用该流程“ 低值易耗品费用报销流程（一）”提交时，单据审批步骤比较奇怪，直接略过了上级部门主管“张明辉”进入到
            $this->ApproveStepobj = new cls_ApproveStepNew($module,$approveid,$approveresult);
        //}
        $this->getAllStepInfoByApproveid($approveid);
        return $this->ApproveStepobj;
    }
    //xxy 2023-12-14 判断是否有默认审批流程，没有默认流程时增加一个空流程
    public function NoDefaultAddEmptyApproval($approve_arr){
        global $weixin_user;
        // $approve_arr = $this->getAllApprovesByUserid($tabid,$userid);
        // dump($this->module);
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
            if (!empty($approve_arr)) {
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