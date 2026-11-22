<?php

/**
 * Created by PhpStorm.
 * User: gyq_19
 * Date: 2016/11/15 0015
 * Time: 下午 1:46
 */

class cls_AllocateLeads
{
    protected $adb;
    protected $current_user;
    protected $currentModule;
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
		//批量操作时记录数上限
        $deployarray = getSys_deploy(67);
        $this->btach_num = $deployarray['deploy_value'];
		if(!empty($_SESSION['lvsAccount'][$this->currentModule]['pool_id'])){
			$_REQUEST['pool_id'] = $_SESSION['lvsAccount'][$this->currentModule]['pool_id'];
		}
		//chj 2021/3/15 44971: 桑博士（http://152.136.139.115:888/crm [^]）系统用户-公海领取客户明明没有达到上限，但是频频报错。例：用户张弦（详情见附件）
		if(empty($_REQUEST['pool_id']))$_REQUEST['pool_id'] = 1;
        $this->pool_id = $_REQUEST['pool_id'];	//公海池
		crm_load_class_file('cls_PublicLeads', 'modules/'.$this->currentModule);
		$cls_PublicLeads = new cls_PublicLeads($currentModule);
		$this->public_account = $cls_PublicLeads->getPublicAccountConfig();
		$this->public_account_pool = $this->public_account['public_account_pool'][$this->pool_id];
        $this->adminaccount = $this->public_account_pool['administrators'];
        $this->maxaccount = $_REQUEST['maxaccount'];
        $this->opdate = date('Y-m-d H:i:s', time());
        $this->days = getLeads_set_ProtectedDays("",0);
		
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
		//公海已分配客户线索上限
		$public_account_limit_type = $this->public_account_pool['limit_type'];
        if ($public_account_limit_type == 'user') {
            $count = $this->public_account_pool['limit_count'];//按用户上限
        } else if($public_account_limit_type == 'role'){
            $sql = 'SELECT limit_count FROM ld_leads_role_limitcount WHERE roleid=? and pool_id = ? limit 1;';

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
        //所有公海已分配线索数量上限
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
            if(!empty($_REQUEST['userid'])&&is_numeric($_REQUEST['userid'])){
                $check_userid = $_REQUEST['userid'];
            }else{
                $check_userid = $this->current_user->id;
            }

            $sql = "select ld_leads.accountname from ld_leads
         where ld_leads.smownerid=? and pool_id = ? and ld_leads.deleted=0 and ld_leads.publicaccount>1";

            $result = $adb->pquery($sql, array($check_userid,$this->pool_id));

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
        $sql = "select ld_leads.accountname from ld_leads
         where ld_leads.smownerid=? and ld_leads.deleted=0 and ld_leads.publicaccount>1";
        $result = $adb->pquery($sql, array($userid));

        if ($this->all_count <= $adb->num_rows($result)) {
            if($this->allocatetype == 3){
                $confirm_str = getFixedLabel('LEADSLIMITCOLLECTIONFAILED');
            }else{
                $confirm_str = getFixedLabel('LEADSLIMITALLOCATIONFAILED');
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
    public function ObtainLeadsJudge($leadsid,$smownerid)
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
               $sql='select opdate,programmeid,old_smownerid,operation from ld_logpublicleads  where leadsid=?
                         and (username=? or operation=? or operation=?)
                            order by opdate desc limit 1 ';
               $result=$adb->pquery($sql,array($leadsid,'系统','LOGPUBLICALLOCATE','LOGPUBLICNORMAL'));
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
                       $sql = "SELECT objtainaccountcontroldays from ld_leads_normal where id =? and active = 'yes';";
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
            
          //  $sql='select * from ld_logpublicaccount where leadsid=? order by '
        }
        return 'yes';
    }
    public function allocateForRecord()
    {
         global $current_user;
        //21849: 公海分配与领取功能，两个用户同时进行， 结果：该客户既进行了公海分配，也进行了领取。
        //publicaccount 1:未分配,2:分配,3:领取
        $adb = $this->adb;
        $query = "select publicaccount from ld_leads where leadsid = ?";
        $result = $adb->pquery($query, array($this->record));
        if ($adb->query_result($result, 0, 'publicaccount') == 3 || $adb->query_result($result, 0, 'publicaccount') == 2) //已领取
        {
            $msg = "###error###" . $adb->query_result($result, 0, 'publicaccount');
            $this->exportReminds($msg,'R1');
        }
        
        if ($this->maxaccount == 1) {
            $check_userid = $this->current_user->id;
            if ($this->userid) {
                $check_userid = $this->userid;
            }
            //判断公海池数量总上限
            $this->judgeAllCount($check_userid);

            $sql = "select ld_leads.accountname from ld_leads
         where ld_leads.smownerid=? and pool_id = ? and ld_leads.deleted=0 and ld_leads.publicaccount>1";

            $result = $adb->pquery($sql, array($check_userid,$this->pool_id));

            if ($this->count <= $adb->num_rows($result)) {
                $msg = "###error###";
                $this->exportReminds($msg,'R2');
            }

            $sql = "select accountname,smownerid from ld_leads where leadsid=?";
            $result = $adb->pquery($sql, array($this->record));
            $accountname = $adb->query_result($result, 0, 0);
            $smownerid=$adb->query_result($result,0,'smownerid');
          
            if($this->ObtainLeadsJudge($this->record,$smownerid)=='no')
            {
                //客户被自动回收后     天内不允许被当前负责人再次领取（为0或空表示不控制）
               
                $this->exportReminds('###error###obtainaccountmsg###error###'.getFixedLabel('ObtainAccountError').'','obtainaccountmsg');
                
            }
            $msg = "###$accountname###";
            $this->exportReminds($msg,'RS');
        }
        if ($this->userid) {
            $query = "SELECT smownerid FROM ld_leads WHERE leadsid=" . $this->record;
            $result = $adb->pquery($query);
            $num_rows = $adb->num_rows($result);
            for ($i = 0; $i < $num_rows; $i++) {
                $old_smonwerids = $adb->query_result($result, $i, 'smownerid');
            }
             
         
            if ($old_smonwerids != $this->current_user->id) {
                $this->focus->getModuleStatic('ModTracker');//字段修改日志

                $this->focus->modstatic->saveFieldLogOne('Leads', 'assigned_user_id', $this->record, $old_smonwerids, $this->current_user->id);
            }
            $this->days = getLeads_set_ProtectedDays("",$this->record);
            if(!is_numeric($this->days))
            {
                 $this->protectdate=null;
                
            }
            else
                 $this->protectdate = date("Y-m-d", strtotime("$this->opdate +$this->days day"));
            
            $sql = "update ld_leads set publicaccount=?,allocatedate=? ,protectdate=?,protectstartdate=now(),smownerid=? where leadsid=?";
            $adb->pquery($sql, array($this->allocatetype, $this->opdate, $this->protectdate, $this->current_user->id, $this->record));
          
            $sql = 'select smownerid from ld_leads where leadsid=?';
            $assresult = $adb->pquery($sql, array($this->record));
            //$sql = "update ld_contactdetails set smownerid=? where deleted=0 and leadsid in(select contactid from ld_contactdetails where leadsid=?)";
           // $adb->pquery($sql, array($this->current_user->id, $this->record));
            if ($this->allocatetype == 3)//领取
            {
                $operation = "GETMYPUBLICACCOUNT";
                $this->idstring = $this->record . ';';
                $_REQUEST['assign_name'] = $adb->query_result($assresult, 0, 0);
            }
            $_REQUEST['caterorid']=$this->current_user->id;
            $sql = "insert into ld_logpublicleads(username,Operation,Opdate,leadsid,userid,pool_id)values(?,?,?,?,?,?)";
            $adb->pquery($sql, array($this->current_user->last_name, $operation, $this->opdate, $this->record,$current_user->id,$this->pool_id));
            //系统操作日志
            $logid = $adb->getLastInsertID();
            crm_load_class_file('cls_OperationLogs', 'modules/Settings/cls_OperationLogs');
            cls_OperationLogs::saveLogs('Leads','Receuve',$this->record,'',$logid);
              //35870: （1.6）客户公海未分配：当用户领取公海未分配单据后，关联的联系人的销售负责人没有自动变成领取人。（需要补丁）
              $this->focus->massChangeUser_after('Leads',$this->record,'allocate');
        }
    }

    protected function allocateForIdstring()
    {
        global $current_user;
        $adb = $this->adb;
    

        if ($this->maxaccount == 1) {
            $check_userid = $this->current_user->id;
            if($this->userid){
                $check_userid = $this->userid;
            }
            $this->judgeAllCount($check_userid);

            $sql = "select ld_leads.accountname from ld_leads
         where ld_leads.smownerid=? and pool_id = ? and ld_leads.deleted=0 and ld_leads.publicaccount>1";

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
            unset($_SESSION[$current_user->id.'_Leads_MassUnallocated']);
        }
       if($_SESSION[$current_user->id.'_Leads_MassUnallocated']&&isset($_SESSION[$current_user->id.'_Leads_MassUnallocated']['data']))
       {
            $storearray= $_SESSION[$current_user->id.'_Leads_MassUnallocated']['data'];
            $revenuecount = count($_SESSION[$current_user->id.'_Leads_MassUnallocated']['data']);
           
           
       }
        else   if ($this->idstring == 'all') {
             
            $_REQUEST['mass_batch_num_all'] = $this->btach_num;
            $storearray = getSelectedRecords($_REQUEST, $this->currentModule, $this->idstring, $excludedRecords);
           // $_SESSION[$current_user->id.'_Leads_MassUnallocated']['']
           $_SESSION[$current_user->id.'_Leads_MassUnallocated']['data']=$storearray;
             $revenuecount = count($storearray);
             
        } else {
            $storearray = explode(";", trim($this->idstring, ';'));
            $storearray = array_filter($storearray);
            $_SESSION[$current_user->id.'_Leads_MassUnallocated']['data']=$storearray;
              $revenuecount = count($storearray);
        }
        
      
       
        if(!isset($_REQUEST['endrow']) || $endrow > count($storearray))
        {
            $endrow = count($storearray);
        }
        
        $storearray = array_slice($storearray, $startrow, $endrow-$startrow);

        if ($this->allocatetype == 3)//领取
        {
            $_REQUEST['caterorid']=$current_user->id;
           
            foreach ($storearray as $key => $id) {
                if ($key >= $this->btach_num) {
                    break;
                }
                $ids[]=$id;
                /**
                 * 发送短信
                 * */
                $publicquery = "select publicaccount,smownerid from ld_leads where leadsid = ?";
                $publicresult = $adb->pquery($publicquery, array($id));
                $publicaccount = $adb->query_result($publicresult, 0, 'publicaccount');
                $smownerid=$adb->query_result($publicresult,0,'smownerid');
                
                if($this->ObtainLeadsJudge($id,$smownerid)=='no')
                {
                    $lose++;
                    continue;
                }
                else if ($publicaccount == 3) //已领取
                {
                    $lose++;
                } else {
                    $query = "SELECT smownerid FROM ld_leads WHERE leadsid=" . $id;
                    $result = $adb->pquery($query);
                    $num_rows = $adb->num_rows($result);
                    for ($i = 0; $i < $num_rows; $i++) {
                        $old_smonwerids = $adb->query_result($result, $i, 'smownerid');
                    }
                    if ($old_smonwerids != $this->current_user->id) {
                        $this->focus->getModuleStatic('ModTracker');//字段修改日志

                        $this->focus->modstatic->saveFieldLogOne('Leads', 'assigned_user_id', $id, $old_smonwerids, $this->current_user->id);
                    }
                    $operation = "GETMYPUBLICACCOUNT";
                    $sql = "insert into ld_logpublicleads(username,Operation,Opdate,leadsid,userid,pool_id)values(?,?,?,?,?,?)";
                    $adb->pquery($sql, array($this->current_user->last_name, $operation, $this->opdate, $id,$current_user->id,$this->pool_id));
                    //系统操作日志
                    $logid = $adb->getLastInsertID();
                    crm_load_class_file('cls_OperationLogs', 'modules/Settings/cls_OperationLogs');
                    cls_OperationLogs::saveLogs('Leads','Receuve',$id,'',$logid);
                    $success++;
                }
                $sql = 'select smownerid from ld_leads where leadsid=?';
                $assresult = $adb->pquery($sql, array($id));
                $_REQUEST['assign_name'] .= $adb->query_result($assresult, 0, 0) . ',';
                //edit:can 20210601 46173: （81mis.com/kfbcrm）销售管理-销售线索，默认公海，管理员操作在公海未分配页签领取单据，领取后却没有显示保护日期
                $this->days = getLeads_set_ProtectedDays("",$this->$id);
                if(!is_numeric($this->days))
                {
                     $this->protectdate=null;
                    
                }
                else
                     $this->protectdate = date("Y-m-d", strtotime("$this->opdate +$this->days day"));
          
                $sql = "update ld_leads set publicaccount=?,allocatedate=? ,protectdate=?,protectstartdate=now(),smownerid=? where leadsid=?";
                $adb->pquery($sql, array($this->allocatetype, $this->opdate, $this->protectdate, $this->current_user->id, $id));
                //edit:can 2020-11-12 43232: （https://61mis.com/kfbtest [^] ）客户问题（邹钰明），勾选单据，点击公海未分配页签界面更多中的“领取”按钮，领取成功后，联系人销售负责人没有改变。预期结果：应该跟公海已分配客户销售负责人保持一致（需要补丁）
                $this->focus->massChangeUser_after('Leads',$id,'allocate');
            }
            $msg = "###$success###$lose###3";
            $this->exportReminds($msg,'R3');
        } else//分配
        {
            crm_load_class_file('cls_allocate_leads','modules/Leads');
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
                $ids[]=$id;
               $clsobj=new cls_allocate_leads($this->focus,'Leads',$id,$allocate_userid,2);//gyqCom0307   	0027448: （6.6.4app访问1.6系统）客户> 列表：公海分配失效。
                 if($clsobj->save()=='error')
                 {
                    $lose++;
                 }
               
                else
                {
                    
                     $success++;
                }  
            }
//            $msg = "###$success###$lose###2";

            if (!isset($_SESSION[$current_user->id . '_Leads_MassUnallocated']['success'])) {
                $_SESSION[$current_user->id . '_Leads_MassUnallocated']['success'] = 0;
            }
            $_SESSION[$current_user->id . '_Leads_MassUnallocated']['success'] += $success;
            $_SESSION[$current_user->id . '_Leads_MassUnallocated']['lose'] += $lose;
            $msg = "###".$_SESSION[$current_user->id . '_Leads_MassUnallocated']['success']."###".$_SESSION[$current_user->id . '_Leads_MassUnallocated']['lose']."###2###$revenuecount";
           
            $this->exportReminds($msg,'R3');
        }
         //35870: （1.6）客户公海未分配：当用户领取公海未分配单据后，关联的联系人的销售负责人没有自动变成领取人。（需要补丁）
              $this->focus->massChangeUser_after($this->currentModule,$ids,'allocate');
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

        $massHref = "index.php?module=Leads&action=ListView&parenttab=Parent Leads$rstart&SearchScope=$SearchScope&pagepublicaccounttype=$accounttype&viewid=$viewid";

        $idstring = explode(';', $idstring);
        $idstring = implode(',', $idstring);
        $idstring = substr($idstring, 0, strlen($idstring) - 1);
        $_REQUEST['id'] = $idstring;
        $_REQUEST['sendSms'] = $assOldOwnerID;
          if($_REQUEST['type']!='createpage')
          { 
            
            //新增和编辑界面保存不需要
       
                include("modules/Leads/Accountalertmsg.php");
      
              header("Location: index.php?module=Leads&action=ListView&parenttab=Parent Leads$rstart&id=$idstring&SearchScope=$SearchScope&pagepublicaccounttype=$accounttype&viewid=$viewid");
            
          }
       


    }

}