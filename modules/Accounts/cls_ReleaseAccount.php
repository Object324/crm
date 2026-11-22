<?php

/**
 * 公海客户 - 释放
 * User: chj
 * Date: 2018-03-01
 */

class cls_ReleaseAccount
{
	private $assigned;
	private $focus;
    public $record;
    public $module;
    public $db;
    public $public_account;

    public function __construct($record,$module)
    {
		$this->record = $record;
		$this->module = $module;
        $this->db = PearDatabase::getInstance();
		$this->focus=CRMEntity::getInstance($module);
		$smcolumnname=$this->focus->getSmownerColumName();
		$field_obj=$this->focus->fieldobj->getFieldInfoobjBykey('columnname',$smcolumnname);
		$this->assigned=$field_obj->getFieldName();	//负责人
		crm_load_class_file('cls_PublicAccounts', 'modules/Accounts');
		$cls_PublicAccounts = new cls_PublicAccounts($currentModule);
		$this->public_account = $cls_PublicAccounts->getPublicAccountConfig();
    }
	
	//$releaseAccountReasons : 释放原因
    public function setReleaseAccount($releaseAccountReasons = ''){
		global $current_user,$adb;
		$operation = 'TORELEASETHECUSTOMERTOTHEHIGNSEAS$####$'.$releaseAccountReasons;	//17814: 公海客户被释放后，结果操作记录中操作显示为空
		$opdate=date("Y-m-d H:i:s");
		if(!empty($this->record)){
			$records = array_filter(explode(';',$this->record));
			$query = "select pool_id,accountid from ld_account where deleted = 0 and accountid in (".implode(',',$records).")";
			$result = $adb->pquery($query,array());
			$num_rows = $adb->num_rows($result);
			if($num_rows >= 1){
				for($i = 0; $i < $num_rows; $i++){
					$accountid = $adb->query_result($result,$i,'accountid');
					$pool_id = $adb->query_result($result,$i,'pool_id');
					$account_pool[$accountid] = $pool_id;
				}
			}
			foreach($records as $id){
				if(!empty($account_pool[$id])){
					$pool_id = $account_pool[$id];
					$public_account_pool = $this->public_account['public_account_pool'][$pool_id];
					if($public_account_pool['userid_after_release'] > 0){   //公海已分配客户释放后，更改客户负责人为（为空表示不更改）
						$userid=$public_account_pool['userid_after_release'];
						$this->focus->retrieve_entity_info($id,$this->module);
						$old_assign_userid=$this->focus->column_fields[$this->assigned];
						$sql="update ld_account set protectdate=null,allocatedate=null,protectstartdate=null,publicaccount=1,completed=null,smownerid=".$userid.",modifiedtime=? where accountid=? ";
						$this->db->pquery($sql,array(date('Y-m-d H:i:s'),$id));
						//39344: (51mis.com/kfbcrm)客户模块>公海未分配界面：普通用户公海未分配领取“客户”，释放后是否需要同步更改相关联模块“联系人”，“销售负责人”字段
						$query = "update ld_contactdetails set smownerid = ".$userid." where accountid = ? and deleted = 0";
						$this->db->pquery($query,array($id));
						if($old_assign_userid != $userid){
							$this->focus->getModuleStatic('ModTracker');//字段修改日志/变更销售负责人
							$this->focus->modstatic->saveFieldLogOne($this->module,$this->assigned,$id,$old_assign_userid,$userid);
					   }  
					} 
					else{
						$sql='update ld_account set protectdate=null,protectstartdate=now(),allocatedate=null,publicaccount=1,completed=null,modifiedtime=? where accountid=?';
						$this->db->pquery($sql,array(date('Y-m-d H:i:s'),$id));
					}   
					
					$sql="insert into ld_logpublicaccount(username,operation,opdate,accountid,userid,pool_id) values(?,?,?,?,?,?)";
					$this->db->pquery($sql,array($current_user->last_name,$operation,$opdate,$id,$current_user->id,$pool_id));
					//系统操作日志
					$logid = $this->db->getLastInsertID();
					crm_load_class_file('cls_OperationLogs', 'modules/Settings/cls_OperationLogs');
					cls_OperationLogs::saveLogs('Accounts','Release',$this->record,'',$logid);
				}
			}
		}
	}

}