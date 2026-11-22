<?php

/**
 * Created by PhpStorm.
 * User: gyq_19
 * Date: 2016/11/15 0015
 * Time: 下午 1:46
 */
crm_load_class_file('cls_PageValidataSave','data');
class cls_AllocateAccount
{
    protected $adb;
    protected $current_user;
    protected $currentModule;
    protected $module;
    protected $focus;
    public  $allocatetype;     //allocatetype---2:分配,3:领取
    protected $userid;
    protected $btach_num;   //批量处理数
    public $count;  //分配上限
    protected $days;
    protected $adminaccount;
    protected $opdate;
    protected $protectdate;
    protected $record;
    protected $idstring;
    protected $maxaccount;
    public $obtainerrormsg;//领取错误信息
    public $pool_id;
    public $public_account;
    public $public_account_pool;
    public $all_count;
    public $relatedinfoset_arr = [];// 分配相关信息的设置
    public function __construct()
    {
        require_once(globalStatic::$root_directory.'modules/Reminds/Reminds.php');
        global $current_user, $currentModule, $adb;
        $this->currentModule = $currentModule;
        $this->current_user = $current_user;
        $this->adb = $adb;
        $this->focus = CRMEntity::getInstance($currentModule);
        $this->allocatetype = $_REQUEST['allocatetype'];
        $this->userid = $_REQUEST['userid'];
        $this->module = $currentModule;
		//批量操作时记录数上限
        $deployarray = getSys_deploy(67);
        $this->btach_num = $deployarray['deploy_value'];
        if(isset($_REQUEST['pool_id']))
        {
            
        }
		else if(!empty($_SESSION['lvsAccount']["Accounts"]['pool_id'])){
			$_REQUEST['pool_id'] = $_SESSION['lvsAccount']["Accounts"]['pool_id'];
		}
		//chj 2021/3/15 44971: 桑博士（http://152.136.139.115:888/crm [^]）系统用户-公海领取客户明明没有达到上限，但是频频报错。例：用户张弦（详情见附件）
		if(empty($_REQUEST['pool_id']))$_REQUEST['pool_id'] = 1;
        $this->pool_id = $_REQUEST['pool_id'];	//公海池
		crm_load_class_file('cls_PublicAccounts', 'modules/Accounts');
		$cls_PublicAccounts = cls_PublicAccounts::getInstance($currentModule);
		$this->public_account = $cls_PublicAccounts->getPublicAccountConfig();
		$this->public_account_pool = $this->public_account['public_account_pool'][$this->pool_id];
        $this->adminaccount = $this->public_account_pool['administrators'];
        $this->maxaccount = $_REQUEST['maxaccount'];
        $this->opdate = date('Y-m-d H:i:s', time());
        $this->days = getAccount_set_ProtectedDays("",0);
		
         if(!is_numeric($days))
        {
              $this->protectdate ='';
        }
        else
            $this->protectdate = DateOperation::addDays(date("Y-m-d",$this->opdate),$this->days);
      
    }

    public function set_userid($userid){
        $this->userid = $userid;
        return $this;
    }
    //用于客户模块新增保存时
   /* public function setParams($allocatetype,$userid,$maxaccount){
        $this->allocatetype = $allocatetype;
        $this->userid = $userid;
        $this->current_user->id = $userid;
        $this->maxaccount = 1;
    }*/
    //初始化分配上限
    public function init_count()
    {
        $adb = $this->adb;
        if ($this->allocatetype == 2) {
            $user_role_id = $this->userid;
        } else{
			if(!empty($_REQUEST['userid'])&&is_numeric($_REQUEST['userid']))
				$user_role_id = $_REQUEST['userid'];
			else
				$user_role_id = $this->current_user->id;
        }
        require_once globalStatic::$root_directory.'include/utils/UserInfoUtil.php';
        $roleid = getUserRoleId($user_role_id);
		//公海已分配客户数量上限
		$public_account_limit_type = $this->public_account_pool['limit_type'];
        if ($public_account_limit_type == 'user') {
            $count = $this->public_account_pool['limit_count'];//按用户上限
        } else if($public_account_limit_type == 'role'){
            $sql = 'SELECT limit_count FROM ld_account_role_limitcount WHERE roleid=? and pool_id = ? limit 1;';

            $result = $adb->pquery($sql, array($roleid,$this->pool_id));
            $rows = $adb->num_rows($result);
            if ($rows > 0) {
                $count = $adb->query_result($result, 0, 'limit_count');
            } else {
                $count = 0;
            }
        }else{
            $count = 99999999;
        }
        if ($count == '') {
            $count = 0;
        }
        //所有公海已分配客户数量上限
        $all_count = 0;
        $all_public_limit_type = $this->public_account['public_limit_type'];
        if ($all_public_limit_type == 'user') {
            $all_count = $this->public_account['public_limit_count'];//按用户上限
        } else if($all_public_limit_type == 'role'){
            $sql = 'SELECT limit_count FROM ld_account_role_limitcount WHERE roleid=? and pool_id = ? limit 1;';

            $result = $adb->pquery($sql, array($roleid,-1));
            $rows = $adb->num_rows($result);
            if ($rows > 0) {
                $all_count = $adb->query_result($result, 0, 'limit_count');
            } else {
                $all_count = 0;
            }
        }else{
            $all_count = 99999999;
        }

        $this->count = $count;
        $this->all_count = $all_count;
        return $this;

    }
    //主入口，区分单条多条
    public function switch_entrance()
    {
   
        if (isset($_REQUEST['record'])) {
            $this->record = $_REQUEST['record'];
            $this->allocateForRecord();
        } elseif (isset($_REQUEST['idstring'])) {
            $this->idstring = $_REQUEST['idstring'];
            $this->allocateForIdstring();
        }else{
            $this->judgeCount();
        }
    }
    //判断是否超额
    public function judgeCount(){
        $adb = $this->adb;
        if ( $this->maxaccount == 1) {
            $sql = "select ld_account.accountname from ld_account
         where ld_account.smownerid=? and pool_id = ? and ld_account.deleted=0 and ld_account.publicaccount>1";
            $check_userid = '';
            if(!empty($_REQUEST['userid'])&&is_numeric($_REQUEST['userid'])){
                $check_userid = $_REQUEST['userid'];
            }else{
                $check_userid = $this->current_user->id;
            }
            $result = $adb->pquery($sql, array($check_userid,$this->pool_id));

            file_put_contents(globalStatic::$root_directory.'modules/Accounts/wangcancount.txt',$this->count);
        
            if ($this->count <= $adb->num_rows($result)) {
                $msg = "###error###";
                $this->exportReminds($msg,'R21');
            }

            $this->judgeAllCount($check_userid);
        }
    }
    //判断是否超过所有公海的总数
    public function judgeAllCount($userid){
        $adb = $this->adb;
        $sql = "select ld_account.accountname from ld_account
         where ld_account.smownerid=? and ld_account.deleted=0 and ld_account.publicaccount>1";
        $result = $adb->pquery($sql, array($userid));

        if ($this->all_count <= $adb->num_rows($result)) {
            if($this->allocatetype == 3){
                $confirm_str = getFixedLabel('ACCOUNTSLIMITCOLLECTIONFAILED');
            }else{
                $confirm_str = getFixedLabel('ACCOUNTSLIMITALLOCATIONFAILED');
            }
            ConvertTojsonString('validata',[],$confirm_str);
        }

    }
    //根据不同端重写输出不同返回格式
    protected function exportReminds($msg,$type){
        $tmparr = explode('###',$msg);
        if($tmparr>2&&$tmparr[1]=='error'){
            ConvertTojsonString(-1,array(),$msg);
        }
        else{
            ConvertTojsonString(1,$tmparr,'success');
        }
        exit;
    }
    /**
     * 领取判断,yes:可以领取，no:不允许领取
     * $smownerid:客户的负责人
     * */
    public function ObtainAccountsJudge($accountid,$smownerid)
    {
        global $current_user;
        global $adb;
     
        if($this->allocatetype==3)
        {
           //公海未分配客户不允许领取（只能由公海管理员分配）
           if($this->public_account_pool['allowget']=='no')
           {
			   //客户被自动回收后  天内不允许被当前销售负责人再次领取（为0或空表示不控制）
                //$objtainaccountcontroldays=$this->public_account_pool['objtainaccountcontroldays'];
               $sql='select opdate,programmeid,old_smownerid,operation from ld_logpublicaccount  where accountid=?
                         and (username=? or operation=? or operation=?)
                            order by opdate desc limit 1 ';
               $result=$adb->pquery($sql,array($accountid,'系统','LOGPUBLICALLOCATE','LOGPUBLICNORMAL'));
               $objtainaccountcontroldays = 0;
               if($adb->num_rows($result)>0)
               {
                   //edit:can 20210602 46122: https://61mis.com/WX/kh43044/ [^] 公海规则设置客户被自动回收2天后不允许销售人员再次领取，但是销售人员自己新建客户显示不允许领取
                   $opdate=$adb->query_result($result,0,'opdate');
                   $programmeid=$adb->query_result($result,0,'programmeid');
                   $old_smownerid=$adb->query_result($result,0,'old_smownerid');
                   $operation = $adb->query_result($result,0,'operation');
                   if($operation =='LOGPUBLICALLOCATE'){
                       $sql = "SELECT objtainaccountcontroldays from ld_module_recovery_programme where programmeid =? and active = 'yes';";
                       $tmp_result = $adb->pquery($sql,[$programmeid]);
                   }else{
                       $sql = "SELECT objtainaccountcontroldays from ld_account_normal where id =? and active = 'yes';";
                       $tmp_result = $adb->pquery($sql,[$programmeid]);
                   }
                   if($adb->num_rows($tmp_result)>0){
                       $objtainaccountcontroldays = $adb->query_result($tmp_result,0,'objtainaccountcontroldays');
                   }
               }

                if($objtainaccountcontroldays>0)
                {
                    if($current_user->id==$old_smownerid)
                    {
                        if(DateOperation::days_between_date(date("Y-m-d"),$opdate)<$objtainaccountcontroldays)
                        {
                            return 'no';
                        }
                    }
                }
           }
            
          //  $sql='select * from ld_logpublicaccount where accountid=? order by '
        }
        return 'yes';
    }
    public function allocateForRecord()
    {
         global $current_user;
        //21849: 公海分配与领取功能，两个用户同时进行， 结果：该客户既进行了公海分配，也进行了领取。
        //publicaccount 1:未分配,2:分配,3:领取
        $adb = $this->adb;
        $query = "select publicaccount,pool_id from ld_account where accountid = ?";
        $result = $adb->pquery($query, array($this->record));
        if ($adb->query_result($result, 0, 'publicaccount') == 3 || $adb->query_result($result, 0, 'publicaccount') == 2) //已领取
        {
            $msg = "###error###" . $adb->query_result($result, 0, 'publicaccount');
            $this->exportReminds($msg,'R1');
        }
        //zkt 20230817 BUG0071105  （V8.4.7.3）客户管理--客户--客户“集群车宝盐步店”在移动端领取后，客户模块中搜不到该客户了 
        if($this->allocatetype == 3 && $adb->query_result($result, 0, 'pool_id')<=0){
            $msg = "###error###".getFixedLabel('accounthasnotallocated');
            $this->exportReminds($msg,'R5');
        }
        
        if ($this->maxaccount == 1) {
            if($this->allocatetype == 3){
                //duan 20240411 领取时判断验证规则
                $PageValidataSaveobj=new cls_PageValidataSave('Accounts',0,0);
                $PageValidataSaveobj->setApplication('lingqu');
                $PageValidataSaveobj->batchoprate = 'yes';
                $errormsg = '';
                $PageValidataSaveobj->resetobj('Accounts',$this->record);//重置验证规则对象
                $PageValidataSaveobj->setAllowSave('no');
                $PageValidataSaveobj->setNewSmownerid($this->current_user->id);
                $PageValidataSaveobj->getValidDataInfoPhp();
                if(!empty($PageValidataSaveobj->errortip)){
                    $errormsg = $PageValidataSaveobj->errortip;
                    ConvertTojsonString('validata',[],$errormsg);
                }
            }else if($this->allocatetype == 2){
                //duan  20240429 XUQIU20240423-05 奥克兰：公海分配时判断验证规则
                $PageValidataSaveobj=new cls_PageValidataSave('Accounts',0,0);
                $PageValidataSaveobj->setApplication('allocated');
                $PageValidataSaveobj->batchoprate = 'yes';
                $errormsg = '';
                $PageValidataSaveobj->resetobj('Accounts',$this->record);//重置验证规则对象
                $PageValidataSaveobj->setAllowSave('no');
                $PageValidataSaveobj->setNewSmownerid($this->current_user->id);
                $PageValidataSaveobj->getValidDataInfoPhp();
                if(!empty($PageValidataSaveobj->errortip)){
                    $errormsg = $PageValidataSaveobj->errortip;
                    ConvertTojsonString('validata',[],$errormsg);
                }
            }
            $check_userid = $this->current_user->id;
            if ($this->userid) {
                $check_userid = $this->userid;
            }
            //判断公海池数量总上限
            $this->judgeAllCount($check_userid);

            $sql = "select ld_account.accountname from ld_account
         where ld_account.smownerid=? and pool_id = ? and ld_account.deleted=0 and ld_account.publicaccount>1";

            $result = $adb->pquery($sql, array($check_userid,$this->pool_id));

            if ($this->count <= $adb->num_rows($result)) {
                $msg = "###error###";
                $this->exportReminds($msg,'R2');
            }

            $sql = "select accountname,smownerid from ld_account where accountid=?";
            $result = $adb->pquery($sql, array($this->record));
            $accountname = $adb->query_result($result, 0, 0);
            $smownerid=$adb->query_result($result,0,'smownerid');
          
            if($this->ObtainAccountsJudge($this->record,$smownerid)=='no')
            {
                //客户被自动回收后     天内不允许被当前负责人再次领取（为0或空表示不控制）
               
                $this->exportReminds('###error###obtainaccountmsg###error###'.getFixedLabel('ObtainAccountError').'','obtainaccountmsg');
                
            }
            $msg = "###$accountname###";
            $this->exportReminds($msg,'RS');
        }
        if ($this->userid) {
            $query = "SELECT smownerid FROM ld_account WHERE accountid=" . $this->record;
            $result = $adb->pquery($query);
            $num_rows = $adb->num_rows($result);
            for ($i = 0; $i < $num_rows; $i++) {
                $old_smonwerids = $adb->query_result($result, $i, 'smownerid');
            }
            $this->focus->retrieve_entity_info($this->record, $this->module);
            //工作流程获取改变前字段值
            $beforefieldvalue_arr = $this->focus->column_fields;
         
            if ($old_smonwerids != $this->current_user->id) {
                $this->focus->getModuleStatic('ModTracker');//字段修改日志

                $this->focus->modstatic->saveFieldLogOne('Accounts', 'assigned_user_id', $this->record, $old_smonwerids, $this->current_user->id);
            }
            $this->days = getAccount_set_ProtectedDays("",$this->record);
            if(!is_numeric($this->days))
            {
                 $this->protectdate=null;
                
            }
            else
                 $this->protectdate = date("Y-m-d", strtotime("$this->opdate +$this->days day"));
            
            $sql = "update ld_account set publicaccount=?,allocatedate=?,distributiondate=? ,protectdate=?,protectstartdate=now(),modifiedtime=?,smownerid=? where accountid=?";
            $adb->pquery($sql, array($this->allocatetype, $this->opdate,$this->opdate, $this->protectdate,date('Y-m-d H:i:s'), $this->current_user->id, $this->record));
          
            $sql = 'select smownerid from ld_account where accountid=?';
            $assresult = $adb->pquery($sql, array($this->record));
            //$sql = "update ld_contactdetails set smownerid=? where deleted=0 and accountid in(select contactid from ld_contactdetails where accountid=?)";
           // $adb->pquery($sql, array($this->current_user->id, $this->record));
            if ($this->allocatetype == 3)//领取
            {
                $operation = "GETMYPUBLICACCOUNT";
                $this->idstring = $this->record . ';';
                $_REQUEST['assign_name'] = $adb->query_result($assresult, 0, 0);
            }
            $_REQUEST['caterorid']=$this->current_user->id;
            $sql = "insert into ld_logpublicaccount(username,Operation,Opdate,accountid,userid,pool_id)values(?,?,?,?,?,?)";
            $adb->pquery($sql, array($this->current_user->last_name, $operation, $this->opdate, $this->record,$current_user->id,$this->pool_id));
            //系统操作日志
            $logid = $adb->getLastInsertID();
            crm_load_class_file('cls_OperationLogs', 'modules/Settings/cls_OperationLogs');
            cls_OperationLogs::saveLogs('Accounts','Receuve',$this->record,'',$logid);

            //更新字段所属部门
            $this->UpdateUserGroup($this->focus,[$this->record=>$this->current_user->id],'smownerid');

            //duan 20240429 公海领取后执行工作流程
            $pagemode = 'Allocated';
            crm_load_class_file("cls_savereverse", 'include/SaveReverse');
            $workflowreverseobj = cls_savereverse::getInstance($this->module);
            $workflowreverseobj->setPageMode($pagemode);
            $workflowreverseobj->getInfo();

            if ($adb->num_rows($workflowreverseobj->workflowresut) > 0) {
                global $reset_retrieve_entity_info;
                $reset_retrieve_entity_info = 'yes';
                $this->focus->retrieve_entity_info($this->record, $this->module);
                //工作流程获取改变前字段值
                $afterfieldvalue_arr = $this->focus->column_fields;

                $workflowreverseobj->setRecord($this->record);
                $workflowreverseobj->getStartComputer($beforefieldvalue_arr,$afterfieldvalue_arr,$pagemode);
            }
            // 分配
            if ($this->allocatetype == 2){
                if ($this->module == 'Accounts' && (getSys_deploy(61)['deploy_value'] == 'all')) {
                    $this->relatedinfoset_arr = [
                        'sharerelatedinfo' => 'yes',
                        'shareoldsmowner' => '',
                        'relmodule_scope' => 'all',
                        'relmodule_selectedtabid_str' => '',
                        'reldata_scope' => 'all',
                    ];
                }
                if(!empty($this->relatedinfoset_arr)){
                    $this->relatedinfoset_arr['oldsmowner'] = $old_smonwerids;// 旧负责人
                    $this->focus->relatedinfoset_arr = $this->relatedinfoset_arr;// 分配相关信息的设置
                }
            }
            //35870: （1.6）客户公海未分配：当用户领取公海未分配单据后，关联的联系人的销售负责人没有自动变成领取人。（需要补丁）
            $this->focus->massChangeUser_after('Accounts',$this->record,'allocate');
        }
    }

    protected function allocateForIdstring()
    {
        global $current_user;
        $adb = $this->adb;
        /*if (isset($this->allocatetype) && ($this->allocatetype == 2 || $this->allocatetype == 3))//分配
        {
            $query = "select publicaccount from ld_account where accountid = ?";
            $publicresult = $adb->pquery($query, array($this->idstring));
            if ($adb->query_result($publicresult, 0, 'publicaccount') == 2 || $adb->query_result($publicresult, 0, 'publicaccount') == 3) //已分配
            {
                $msg = "###error###" . $adb->query_result($publicresult, 0, 'publicaccount');
                $this->exportReminds($msg,'R1');
            }
        }*/

        if ($this->maxaccount == 1) {
            $check_userid = $this->current_user->id;
            if ($this->userid) {
                $check_userid = $this->userid;
            }

            $this->judgeAllCount($check_userid);

            $sql = "select ld_account.accountname from ld_account
         where ld_account.smownerid=? and pool_id = ? and ld_account.deleted=0 and ld_account.publicaccount>1";

            $result = $adb->pquery($sql, array($check_userid,$this->pool_id));

            if ($this->count <= $adb->num_rows($result)) {
                $msg =  "###error###";
                $this->exportReminds($msg,'R2');
            } else {
                $excludedRecords = vtlib_purify($_REQUEST['excludedRecords']);
                $storearray = getSelectedRecords($_REQUEST, $this->currentModule, $this->idstring, $excludedRecords);
                $storearray = array_filter($storearray);
                $haveaccount = $adb->num_rows($result);
                $msg = "###$this->count###" . count($storearray) . "###$haveaccount" . "###" . implode(';', $storearray);
                $this->exportReminds($msg,'R4');
            }
        }
        $success = 0;
        $lose = 0;
        $startrow = $_REQUEST['startrow'];
        $endrow = $_REQUEST['endrow'];
         if($startrow == 0 || !isset($_REQUEST['startrow']))
        {
            $startrow = 0;
            unset($_SESSION[$current_user->id.'_Accounts_MassUnallocated']);
        }
      if($_SESSION[$current_user->id.'_Accounts_MassUnallocated']&&isset($_SESSION[$current_user->id.'_Accounts_MassUnallocated']['data']))
       {
            $storearray= $_SESSION[$current_user->id.'_Accounts_MassUnallocated']['data'];
           
            
       }
       else if ($this->idstring == 'all') {
              $_REQUEST['mass_batch_num_all'] = $this->btach_num;
            $storearray = getSelectedRecords($_REQUEST, $this->currentModule, $this->idstring, $excludedRecords);
             $_SESSION[$current_user->id.'_Accounts_MassUnallocated']['data']=$storearray;
        } else {
            $storearray = explode(";", trim($this->idstring, ';'));
            $storearray = array_filter($storearray);
            $_SESSION[$current_user->id.'_Accounts_MassUnallocated']['data']=$storearray;
        }
      
        $revenuecount = count($storearray);
   
        
        if(!isset($_REQUEST['endrow']) || $endrow > count($storearray))
        {
            $endrow = count($storearray);
        }
       
        $storearray = array_slice($storearray, $startrow, $endrow-$startrow);


        //duan 20240429 公海领取后执行工作流程
        global $reset_retrieve_entity_info;
        $pagemode = 'Allocated';
        crm_load_class_file("cls_savereverse", 'include/SaveReverse');
        $workflowreverseobj = cls_savereverse::getInstance($this->module);
        $workflowreverseobj->setPageMode($pagemode);
        $workflowreverseobj->getInfo();

        if ($this->allocatetype == 3)//领取
        {
            $_REQUEST['caterorid']=$current_user->id;

            //duan 20240411 华企：批量领取时判断验证规则
            $PageValidataSaveobj=new cls_PageValidataSave('Accounts',0,0);
            $PageValidataSaveobj->setApplication('lingqu');
            $PageValidataSaveobj->batchoprate = 'yes';
            $errormsg_arr = [];

            foreach ($storearray as $key => $id) {
                if ($key >= $this->btach_num) {
                    break;
                }
                $PageValidataSaveobj->resetobj('Accounts',$id);//重置验证规则对象
                $PageValidataSaveobj->setAllowSave('no');
                $PageValidataSaveobj->setNewSmownerid($this->current_user->id);
                $PageValidataSaveobj->getValidDataInfoPhp();
                if(!empty($PageValidataSaveobj->errortip)){
                    $errormsg = $PageValidataSaveobj->errortip;
                    $errormsg_arr[] = $errormsg;
                    $lose ++;
                    continue;
                }
                $this->focus->retrieve_entity_info($id, $this->module);
                //工作流程获取改变前字段值
                $beforefieldvalue_arr = $this->focus->column_fields;


                $ids[]=$id;
                /**
                 * 发送短信
                 * */
                $publicquery = "select publicaccount,smownerid from ld_account where accountid = ?";
                $publicresult = $adb->pquery($publicquery, array($id));
                $publicaccount = $adb->query_result($publicresult, 0, 'publicaccount');
                $smownerid=$adb->query_result($publicresult,0,'smownerid');
                
                if($this->ObtainAccountsJudge($id,$smownerid)=='no')
                {
                    $lose++;
                    continue;
                }
                else if ($publicaccount == 3) //已领取
                {
                    $lose++;
                } else {
                    $query = "SELECT smownerid FROM ld_account WHERE accountid=" . $id;
                    $result = $adb->pquery($query);
                    $num_rows = $adb->num_rows($result);
                    for ($i = 0; $i < $num_rows; $i++) {
                        $old_smonwerids = $adb->query_result($result, $i, 'smownerid');
                    }
                    if ($old_smonwerids != $this->current_user->id) {
                        $this->focus->getModuleStatic('ModTracker');//字段修改日志

                        $this->focus->modstatic->saveFieldLogOne('Accounts', 'assigned_user_id', $id, $old_smonwerids, $this->current_user->id);
                    }
                    $operation = "GETMYPUBLICACCOUNT";
                    $sql = "insert into ld_logpublicaccount(username,Operation,Opdate,accountid,userid,pool_id)values(?,?,?,?,?,?)";
                    $adb->pquery($sql, array($this->current_user->last_name, $operation, $this->opdate, $id,$current_user->id,$this->pool_id));
                    //系统操作日志
					$logid = $adb->getLastInsertID();
					crm_load_class_file('cls_OperationLogs', 'modules/Settings/cls_OperationLogs');
					cls_OperationLogs::saveLogs('Accounts','Receuve',$id,'',$logid);
                    $success++;
                }
                $sql = 'select smownerid from ld_account where accountid=?';
                $assresult = $adb->pquery($sql, array($id));
                $_REQUEST['assign_name'] .= $adb->query_result($assresult, 0, 0) . ',';
                $this->days = getAccount_set_ProtectedDays("",$id);
                if(!is_numeric($this->days))
                {
                     $this->protectdate=null;
                    
                }
                else
                     $this->protectdate = date("Y-m-d", strtotime("$this->opdate +$this->days day"));
          
                $sql = "update ld_account set publicaccount=?,allocatedate=?,distributiondate=? ,protectdate=?,protectstartdate=now(),modifiedtime=?,smownerid=? where accountid=?";
                $adb->pquery($sql, array($this->allocatetype, $this->opdate,$this->opdate, $this->protectdate,date('Y-m-d H:i:s'), $this->current_user->id, $id));
                //edit:can 2020-11-12 43232: （https://61mis.com/kfbtest [^] ）客户问题（邹钰明），勾选单据，点击公海未分配页签界面更多中的“领取”按钮，领取成功后，联系人销售负责人没有改变。预期结果：应该跟公海已分配客户销售负责人保持一致（需要补丁）
                $this->focus->massChangeUser_after('Accounts',$id,'allocate');
                //更新字段所属部门
                $this->UpdateUserGroup($this->focus,[$id=>$this->current_user->id],'smownerid');


                if ($adb->num_rows($workflowreverseobj->workflowresut) > 0) {

                    $reset_retrieve_entity_info = 'yes';
                    $this->focus->retrieve_entity_info($id, $this->module);
                    //工作流程获取改变前字段值
                    $afterfieldvalue_arr = $this->focus->column_fields;

                    $workflowreverseobj->setRecord($id);
                    $workflowreverseobj->getStartComputer($beforefieldvalue_arr,$afterfieldvalue_arr,$pagemode);
                }

            }

            if(is_array($errormsg_arr) && count($errormsg_arr)>0){
                $tmp_errormsg = implode('<br>',array_unique($errormsg_arr));
                $msg = "###$success###$lose###3";
                $tmp_arr = explode('###',$msg);
                ConvertTojsonString('validata',$tmp_arr,$tmp_errormsg);
            }else{
                $msg = "###$success###$lose###3";
                $this->exportReminds($msg,'R3');
            }
        } else//分配
        {
            //duan 20240429 XUQIU20240423-05 奥克兰：公海分配时判断验证规则

            $PageValidataSaveobj=new cls_PageValidataSave('Accounts',0,0);
            $PageValidataSaveobj->setApplication('allocated');
            $PageValidataSaveobj->batchoprate = 'yes';
            $errormsg_arr = [];

           
            crm_load_class_file('cls_allocate_account','modules/Accounts');
            if(isset($_REQUEST['responseType'])&& $_REQUEST['responseType']=='htmlfive'){
                $allocate_userid = $_REQUEST['allocate_userid'];
            }elseif(!empty($this->userid)){
                $allocate_userid = $this->userid;
            }else{
                $allocate_userid = $_REQUEST['userid'];
            }
            $_REQUEST['caterorid']=$allocate_userid;
            foreach ($storearray as $key => $id) {
                if ($key >= $this->btach_num) {
                    break;
                }
                $smownerid_query = "SELECT smownerid FROM ld_account WHERE accountid=" . $id;
                $smownerid_result = $adb->pquery($smownerid_query);
                $num_rows = $adb->num_rows($smownerid_result);
                for ($i = 0; $i < $num_rows; $i++) {
                    $old_smonwerids = $adb->query_result($smownerid_result, $i, 'smownerid');
                }
                $PageValidataSaveobj->resetobj('Accounts',$id);//重置验证规则对象
                $PageValidataSaveobj->setAllowSave('no');
                $PageValidataSaveobj->setNewSmownerid($allocate_userid);
                $PageValidataSaveobj->getValidDataInfoPhp();
                if(!empty($PageValidataSaveobj->errortip)){
                    $errormsg = $PageValidataSaveobj->errortip;
                    $errormsg_arr[] = $errormsg;
                    $lose++;
                    continue;
                }


                $ids[]=$id;

                if ($this->module == 'Accounts' && (getSys_deploy(61)['deploy_value'] == 'all')) {
                    $this->relatedinfoset_arr = [
                        'sharerelatedinfo' => 'yes',
                        'shareoldsmowner' => 'setshare',
                        'relmodule_scope' => 'all',
                        'relmodule_selectedtabid_str' => '',
                        'reldata_scope' => 'all',
                    ];
                }
                if(!empty($this->relatedinfoset_arr)){
                    $this->relatedinfoset_arr['oldsmowner'] = $old_smonwerids;// 旧负责人
                    $this->focus->relatedinfoset_arr = $this->relatedinfoset_arr;// 分配相关信息的设置
                }
                
                $clsobj=new cls_allocate_account($this->focus,'Accounts',$id,$allocate_userid,2);//gyqCom0307   	0027448: （6.6.4app访问1.6系统）客户> 列表：公海分配失效。
                 if($clsobj->save()=='error')
                 {
                    $lose++;
                 }
               
                else
                {
                    
                     $success++;
                }
            }
            // $msg = "###$success###$lose###2";

            if (!isset($_SESSION[$current_user->id . '_Accounts_MassUnallocated']['success'])) {
                $_SESSION[$current_user->id . '_Accounts_MassUnallocated']['success'] = 0;
            }
            $_SESSION[$current_user->id . '_Accounts_MassUnallocated']['success'] += $success;
            $_SESSION[$current_user->id . '_Accounts_MassUnallocated']['lose'] += $lose;
            $msg = "###".$_SESSION[$current_user->id . '_Accounts_MassUnallocated']['success']."###".$_SESSION[$current_user->id . '_Accounts_MassUnallocated']['lose']."###2###$revenuecount";
            if(is_array($errormsg_arr) && count($errormsg_arr)>0){
                $tmp_errormsg = implode('<br>',array_unique($errormsg_arr));
                $tmp_arr = explode('###',$msg);
                ConvertTojsonString('validata',$tmp_arr,$tmp_errormsg);
            }else{
                $this->exportReminds($msg,'R3');
            }
            
            
        }
        //35870: （1.6）客户公海未分配：当用户领取公海未分配单据后，关联的联系人的销售负责人没有自动变成领取人。（需要补丁）
        $this->focus->massChangeUser_after('Accounts',$ids,'allocate');
    }
    //PC端分配后跳转
    public function header()
    {
        $viewid = vtlib_purify($_REQUEST['viewid']);
        $SearchScope = $_REQUEST['SearchScope'];
        if (isset($_REQUEST['start']) && $_REQUEST['start'] != '') {
            $rstart = "&start=" . vtlib_purify($_REQUEST['start']);
        }
        $accounttype = $_REQUEST['pagepublicaccounttype'];

        if (isset($_REQUEST['assign_name'])) {
            $assOldOwnerID = $_REQUEST['assign_name'];
        }
        if (isset($_REQUEST['idstring'])) {
            $idstring = $_REQUEST['idstring'];
        }

        $massHref = "index.php?module=Accounts&action=ListView&parenttab=Parent Accounts$rstart&SearchScope=$SearchScope&pagepublicaccounttype=$accounttype&viewid=$viewid";

        $idstring = explode(';', $idstring);
        $idstring = implode(',', $idstring);
        $idstring = substr($idstring, 0, strlen($idstring) - 1);
        $_REQUEST['id'] = $idstring;
        $_REQUEST['sendSms'] = $assOldOwnerID;
          if($_REQUEST['type']!='createpage')
          { 
            
            //新增和编辑界面保存不需要
       
                include("modules/Accounts/Accountalertmsg.php");
      
              header("Location: index.php?module=Accounts&action=ListView&parenttab=Parent Accounts$rstart&id=$idstring&SearchScope=$SearchScope&pagepublicaccounttype=$accounttype&viewid=$viewid");
            
          }
       


    }
    //公海领取/分配后更新所属部门
    public function  UpdateUserGroup($focus,$record_info,$smcolumnname){
        global $adb;
        $group_focus = new Group();

        foreach ($record_info as $recordid =>$new_userid){
            $depInfo = $group_focus->getUserGroup($new_userid);//变更后的创建人
            ksort($depInfo);
            $depId = implode(',',array_keys($depInfo));//部门id
            foreach($focus->fieldobj->getModuleFields() as $tmp_fieldname => $tmp_fieldinfo)
            {
                if($tmp_fieldinfo->getUIType() == 1600)
                {
                    $tmp_effect_fieldid = $tmp_fieldinfo->getFieldId();
                    $result_related_field = $adb->pquery('select * from ld_related_field where effect_fieldid = ?', array($tmp_effect_fieldid));
                    if ($adb->num_rows($result_related_field) >= 1) {
                        $tmp_trigger_fieldid = $adb->query_result($result_related_field,0,'trigger_fieldid');
                        $sql_field = "select uitype,columnname from ld_field where fieldid = ? and ld_field.presence in (0,2)";
                        $result_field = $adb->pquery($sql_field, array($tmp_trigger_fieldid));
                        if ($adb->num_rows($result_field) >= 1 && $adb->query_result($result_field,0,'columnname') == $smcolumnname) {//触发字段为创建人
                            $sql = 'update ' . $tmp_fieldinfo->getTableName() . ' set ' . $tmp_fieldinfo->getColumnName() . ' = ? where ' . $focus->table_index . ' = ? ';
                            $adb->pquery($sql, array($depId, $recordid));
                        }
                    }
                }
            }
        }
    }

}