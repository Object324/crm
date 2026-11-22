<?php

/**
 * 公海客户 - 延期
 * User: chj
 * Date: 2018-03-01
 */

class cls_DelayAccount
{

    public function __construct($record,$module)
    {
		$this->record = $record;
		$this->module = $module;
		$this->db = PearDatabase::getInstance();
    }
	
	public function setDelayAccount($delayDays){
		global $current_user;
		$opdate=date("Y-m-d H:i:s");
		$operation="DELAYPUBLICACCOUNTDAYS$###$".$delayDays;
		$sql="select ld_account.smownerid,ld_account.accountname,ld_account.pool_id from ld_account inner join ld_crmentity on ld_crmentity.crmid=ld_account.accountid where crmid=?";
		$result=$this->db->pquery($sql,array($this->record));
		$accountname=$this->db->query_result($result,0,1); 
		$oldsmownerid=$this->db->query_result($result,0,0);
		$pool_id=$this->db->query_result($result,0,2);

		$sql="update ld_account set protectdate= date_add(protectdate, interval $delayDays day) where accountid=? and protectdate is not null";
		$this->db->pquery($sql,array($this->record));

		$sql="insert into ld_logpublicaccount(username,Operation,Opdate,accountid,userid,pool_id)values(?,?,?,?,?,?)";
		$this->db->pquery($sql,array($current_user->last_name,$operation,$opdate,$this->record,$current_user->id,$pool_id));
		//系统操作日志
		$logid = $this->db->getLastInsertID();
		crm_load_class_file('cls_OperationLogs', 'modules/Settings/cls_OperationLogs');
		cls_OperationLogs::saveLogs('Accounts','Delay',$this->record,'',$logid);

		$focus_rel =CRMEntity::getInstance('Reminds');                    
		$focus_rel->column_fields['date_time'] = date('Y-m-d H:i');	   
		$focus_rel->column_fields['related_to']=$this->record;
		$focus_rel->column_fields['reltab']="Accounts";
		$focus_rel->column_fields['recieverid']=$oldsmownerid;
		$focus_rel->column_fields['status_rmd']='未读';
		$focus_rel->column_fields['content']=getUserlastName($current_user).'把'.$accountname.'到期时间延长了'.$delayDays.'天';
		$focus_rel->mode="create";
		$focus_rel->save('Reminds');
	}

}