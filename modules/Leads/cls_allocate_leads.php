<?php
/**
 * 公海分配保存
 * */
class cls_allocate_leads
{
    protected $module;
    protected $userid;
    protected $leadsid;
    protected $focus;
    protected $allocatetype;
    /**
     * $focus:模块对象
     * $module:模块名称
     * $userid:分配的负责人id
     * $allocatetype:2：分配，3：领取
     * */
    public function __construct($focus,$module,$leadsid,$userid,$allocatetype)
    {
        $this->id=$leadsid;
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
       $days=getLeads_set_ProtectedDays("",$id);
       if(is_numeric($days))
            $protectdate=date("Y-m-d",strtotime("$opdate +$days day"));
       else
        $protectdate='';
        
       $sql = 'select smownerid,accountname,pool_id from ld_leads where leadsid = ? LIMIT 1 ';
       $result=$adb->pquery($sql,array($id));
       $accountname=$adb->query_result($result,0,'accountname'); 
       $oldsmownerid=$adb->query_result($result,0,'smownerid');  
	   $pool_id=$adb->query_result($result,0,'pool_id'); 
    
       $_REQUEST['assign_name'].=$oldsmownerid.',';      
          
       $publicquery = "select publicaccount from ld_leads where leadsid = ?";
       $publicresult = $adb->pquery($publicquery,array($id));
       $publicaccount = $adb->query_result($publicresult,0,'publicaccount');
      
       if($publicaccount == 2) //已分配
       {
                return 'error';
       }
       else
       {
        
                $query = "SELECT smownerid FROM ld_leads WHERE leadsid=".$id;
                $result = $adb->pquery($query);
                $num_rows = $adb->num_rows($result);
                for($i = 0; $i<$num_rows; $i++){
                    $old_smonwerids= $adb->query_result($result,$i,'smownerid');
                }
              
                if($old_smonwerids!=$this->getUserId()){
                	$focus->getModuleStatic('ModTracker');//字段修改日志
                    
                	$focus->modstatic->saveFieldLogOne($this->module,'assigned_user_id',$id,$old_smonwerids,$this->getUserId());
                }
    			$sql = 'update ld_leads set publicaccount=?,allocatedate=? ,protectdate=?,protectstartdate=now(),
    						smownerid=?,lastdistributedate=?,lastdistributer=?
    					where leadsid = ? ';
                              
    			$adb->pquery($sql,array($this->allocatetype,$opdate,$protectdate,$this->getUserId(),
    						$opdate,$current_user->id,$id));
                         
                            
          
    		
    			$sql='DELETE from ld_tabshare WHERE crmid=?';
                $adb->pquery($sql,array($id));//删除共享
                $operation='ALLOCATEPUBLICACCOUNTGIVEN$###$'.$this->getUserName();
                $sql='insert into ld_logpublicleads(username,Operation,Opdate,leadsid,userid,pool_id)values(?,?,?,?,?,?)';
                $adb->pquery($sql,array($current_user->last_name,$operation,$opdate,$id,$current_user->id,$pool_id));
                //系统操作日志
                $logid = $adb->getLastInsertID();
                crm_load_class_file('cls_OperationLogs', 'modules/Settings/cls_OperationLogs');
                cls_OperationLogs::saveLogs('Leads','Distribute',$id,'',$logid);
                //分配生成提醒
                if($oldsmownerid!=$this->getUserId())
                {
                $focus_rel =CRMEntity::getInstance('Reminds');                    
                $focus_rel->column_fields['date_time'] = $opdate;	   
                $focus_rel->column_fields['related_to']=$id;
                $focus_rel->column_fields['reltab']="Leads";
                $focus_rel->column_fields['recieverid']=$this->getUserId();
                $focus_rel->column_fields['status_rmd']='未读';
                $focus_rel->column_fields['content']='有新客户分配给您，敬请关注！';
                $focus_rel->mode="create";
                $focus_rel->save('Reminds');
                }
                $_REQUEST['caterorid']=$this->getUserId();
                //26628: 客户-公海未分配页签：设置分配客户时分配相关信息，将单据分配给其他用户后，相关信息单据的负责人并没有变
                $this->focus->massChangeUser_after('Leads',$this->id,'allocate');
                unset($_REQUEST['caterorid']);
           $_SESSION[$current_user->id.'_'.$this->module.'_massDeskHighAvgAllocatetleads']['leads_Average'][$this->userid] += 1;//依次统计所选用户分配个数
           $_SESSION[$current_user->id.'_'.$this->module.'_massDeskHighAvgAllocatetleads']['success'] += 1;//依次统计分配成功的个数
                 return 'success';
            
       }
    }
}



?>