<?php
/**
 * 公海分配保存
 * */
class cls_allocate_account
{
    protected $module;
    protected $userid;
    protected $accountid;
    protected $focus;
    protected $allocatetype;
    public $id;
    /**
     * $focus:模块对象
     * $module:模块名称
     * $userid:分配的负责人id
     * $allocatetype:2：分配，3：领取
     * */
    public function __construct($focus,$module,$accountid,$userid,$allocatetype)
    {
        $this->id=$accountid;
        $this->module=$module;
        $this->focus=$focus;
        $this->userid=$userid;
        $this->allocatetype=$allocatetype;
    }
    public function getUserId()
    {
        return $this->userid;
    }
    public function getAccountId()
    {
        return $this->id;
    }
    public function getUserName()
    {
        if(isset($_REQUEST['username']))
        {
            return $_REQUEST['username'];
        }
        else
        {
            global $adb;
            $sql='select last_name,wx_userid from ld_users where id=?';
            $result=$adb->pquery($sql,array($this->getUserId()));
            if($adb->num_rows($result)>0)
            {
                $last_name=$adb->query_result($result,0,0);
                $wx_userid=$adb->query_result($result,0,1);
                $userobj=new Users();
                $userobj->last_name=$last_name;
                $userobj->wx_userid=$wx_userid;
                return getUserlastName($userobj);
            }
            else
            {
                return '';
                
            }
        }
    }
    public function save()
    {
        global $adb,$current_user;
        $focus=$this->focus;
        $opdate=date('Y-m-d H:i:s',time());
        $newdate = date('Y-m-d',time());
      
        
       
       
        
        $id=$this->getAccountId();
        $days=getAccount_set_ProtectedDays("",$id);
        if(is_numeric($days))
            $protectdate=date("Y-m-d",strtotime("$opdate +$days day"));
        else
            $protectdate='';
         
        $sql = 'select smownerid,accountname,pool_id from ld_account where accountid = ? LIMIT 1 ';
        $result=$adb->pquery($sql,array($id));
        $accountname=$adb->query_result($result,0,'accountname'); 
        $oldsmownerid=$adb->query_result($result,0,'smownerid');  
        $pool_id=$adb->query_result($result,0,'pool_id');

        $focus->retrieve_entity_info($id, $this->module);
        //工作流程获取改变前字段值
        $beforefieldvalue_arr = $focus->column_fields;

        $_REQUEST['assign_name'].=$oldsmownerid.',';
        $publicquery = "select publicaccount from ld_account where accountid = ?";
        $publicresult = $adb->pquery($publicquery,array($id));
        $publicaccount = $adb->query_result($publicresult,0,'publicaccount');
        if($publicaccount == 2) //已分配
        {
                return 'error';
        }
        else
        {
        
                $query = "SELECT smownerid FROM ld_account WHERE accountid=".$id;
                $result = $adb->pquery($query);
                $num_rows = $adb->num_rows($result);
                for($i = 0; $i<$num_rows; $i++){
                    $old_smonwerids= $adb->query_result($result,$i,'smownerid');
                }
                if($old_smonwerids!=$this->getUserId()){
                	$focus->getModuleStatic('ModTracker');//字段修改日志
                    
                	$focus->modstatic->saveFieldLogOne($this->module,'assigned_user_id',$id,$old_smonwerids,$this->getUserId());
                }
    			$sql = 'update ld_account set publicaccount=?,distributiondate=?,allocatedate=? ,protectdate=?,protectstartdate=now(),
    						smownerid=?,lastdistributedate=?,lastdistributer=?,modifiedtime=?
    					where accountid = ? ';
                                               
    			$adb->pquery($sql,array($this->allocatetype,$opdate,$opdate,$protectdate,$this->getUserId(),
    						$opdate,$current_user->id,date('Y-m-d H:i:s'),$id));


           //ls 2021-08-09 0047337: 公海分配没有更改客户的“负责人所属部门”(公海分配)
           require_once  globalStatic::$root_directory.'modules/Users/Group.class.php';
           $group_focus = new Group();
           $depInfo = $group_focus->getUserGroup($this->getUserId());//变更后的负责人
           ksort($depInfo);
           $depId = implode(',',array_keys($depInfo));//部门id
           foreach($focus->fieldobj->getModuleFields() as $tmp_fieldname => $tmp_fieldinfo)
           {
               if($tmp_fieldinfo->getUIType() == 1600)
               {
                   $tmp_effect_fieldid = $tmp_fieldinfo->getFieldId();
                   $result_related_field = $adb->pquery('select * from ld_related_field where effect_fieldid = ?', array($tmp_effect_fieldid));
                   if ($adb->num_rows($result_related_field) >= 1) {
                       //检查设置的触发字段类型（负责人、创建人、单选用户类型不处理）
                       $tmp_trigger_fieldid = $adb->query_result($result_related_field,0,'trigger_fieldid');
                       $sql_field = "select uitype,columnname from ld_field where fieldid = ? and ld_field.presence in (0,2)";
                       $result_field = $adb->pquery($sql_field, array($tmp_trigger_fieldid));
                       if ($adb->num_rows($result_field) >= 1 && $adb->query_result($result_field,0,'columnname') == $focus->getSmownerColumName()) {//触发字段为负责人
                           $sql = 'update ' . $tmp_fieldinfo->getTableName() . ' set ' . $tmp_fieldinfo->getColumnName() . ' = ? where ' . $focus->table_index . ' = ? ';
                           $adb->pquery($sql, array($depId, $id));
                       }

                   }

               }
           }
            /* duan BUG20240709-55 20240710 公海分配后不需要更新联系人的负责人
          	$sql = 'update ld_contactdetails inner join ld_account on ld_account.accountid=ld_contactdetails.accountid set 
    						ld_contactdetails.smownerid=?
    					where ld_contactdetails.accountid = ? ';
    			$adb->pquery($sql,array($this->getUserId(),$id));
    		*/

    			$sql='DELETE from ld_tabshare WHERE crmid=?';
                $adb->pquery($sql,array($id));//删除共享
                $operation='ALLOCATEPUBLICACCOUNTGIVEN$###$'.$this->getUserName();
                $sql='insert into ld_logpublicaccount(username,Operation,Opdate,accountid,userid,pool_id)values(?,?,?,?,?,?)';
                $adb->pquery($sql,array($current_user->last_name,$operation,$opdate,$id,$current_user->id,$pool_id));
                //系统操作日志
                $logid = $adb->getLastInsertID();
                crm_load_class_file('cls_OperationLogs', 'modules/Settings/cls_OperationLogs');
                cls_OperationLogs::saveLogs('Accounts','Distribute',$id,'',$logid);
                //分配生成提醒
                // duan 20240722 公海分配的时候，负责人不变化也要发提醒
                //if($oldsmownerid!=$this->getUserId())
                //{
                $focus_rel =CRMEntity::getInstance('Reminds');
                $focus_rel->column_fields['date_time'] = $opdate;
                $focus_rel->column_fields['related_to']=$id;
                $focus_rel->column_fields['reltab']="Accounts";
                $focus_rel->column_fields['recieverid']=$this->getUserId();
                $focus_rel->column_fields['status_rmd']='未读';
                $focus_rel->column_fields['content']='有新客户分配给您，敬请关注！';
                $focus_rel->mode="create";
                $focus_rel->save('Reminds');
                //}
                $_REQUEST['caterorid']=$this->getUserId();
                //26628: 客户-公海未分配页签：设置分配客户时分配相关信息，将单据分配给其他用户后，相关信息单据的负责人并没有变
                $this->focus->massChangeUser_after('Accounts',$this->id,'allocate');
                unset($_REQUEST['caterorid']);

           //ls 2021-08-09 0047337: 公海分配没有更改客户的“负责人所属部门”（公海分配客户的同时更改关联联系人的负责人所在部门id）
           $system_deploy=getSys_deploy(61);
           if($system_deploy['deploy_value']==0)//客户分配时，是否同时分配相关信息 1：否，0：是
           {
               $contact_focus = CRMEntity::getInstance('Contacts');
               foreach($contact_focus->fieldobj->getModuleFields() as $tmp_fieldname => $tmp_fieldinfo)
               {
                   if($tmp_fieldinfo->getUIType() == 1600)
                   {
                       $tmp_effect_fieldid = $tmp_fieldinfo->getFieldId();
                       $result_related_field = $adb->pquery('select * from ld_related_field where effect_fieldid = ?', array($tmp_effect_fieldid));
                       if ($adb->num_rows($result_related_field) >= 1) {
                           //检查设置的触发字段类型（负责人、创建人、单选用户类型不处理）
                           $tmp_trigger_fieldid = $adb->query_result($result_related_field,0,'trigger_fieldid');
                           $sql_field = "select uitype,columnname from ld_field where fieldid = ? and ld_field.presence in (0,2)";
                           $result_field = $adb->pquery($sql_field, array($tmp_trigger_fieldid));
                           if ($adb->num_rows($result_field) >= 1 && $adb->query_result($result_field,0,'columnname') == $contact_focus->getSmownerColumName()) {//触发字段为负责人
                               $sql = 'update ' . $tmp_fieldinfo->getTableName() . ' inner join ld_contactdetails on ld_contactdetails.contactid='.$tmp_fieldinfo->getTableName().'.contactid inner join ld_account on ld_account.accountid=ld_contactdetails.accountid set '. $tmp_fieldinfo->getTableName(). '.' . $tmp_fieldinfo->getColumnName() . ' = ? where ld_contactdetails.accountid = ? ';
                               $adb->pquery($sql, array($depId, $id));
                           }

                       }

                   }
               }
           }

           //duan 20240429 公海分配后执行工作流程
           $pagemode = 'Allocated';
           crm_load_class_file("cls_savereverse", 'include/SaveReverse');
           $workflowreverseobj = cls_savereverse::getInstance($this->module);
           $workflowreverseobj->setPageMode($pagemode);
           $workflowreverseobj->getInfo();

           if ($adb->num_rows($workflowreverseobj->workflowresut) > 0) {
               global $reset_retrieve_entity_info;
               $reset_retrieve_entity_info = 'yes';
               $focus->retrieve_entity_info($id, $this->module);
               //工作流程获取改变前字段值
               $afterfieldvalue_arr = $focus->column_fields;

               $workflowreverseobj->setRecord($id);
               $workflowreverseobj->getStartComputer($beforefieldvalue_arr,$afterfieldvalue_arr,$pagemode);
           }

           $_SESSION[$current_user->id.'_'.$this->module.'_massDeskHighAvgAllocatetaccount']['Account_Average'][$this->userid] += 1;//依次统计所选用户分配个数
           $_SESSION[$current_user->id.'_'.$this->module.'_massDeskHighAvgAllocatetaccount']['success'] += 1;//依次统计分配成功的个数
                 return 'success';
            
       }
    }
}



?>