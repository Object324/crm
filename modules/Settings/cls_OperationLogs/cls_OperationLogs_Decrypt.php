<?php
//Decrypt
class cls_OperationLogs_Decrypt extends cls_OperationLogs
{
    public function __construct($selectmodule,$actiontype,$userids,$operationtime=''){
		parent::__construct($selectmodule,$actiontype,$userids,$operationtime);
	}
	//保存日志
	public function save($logid,$module,$actiontype,$crmid,$content=[]){
		global $adb,$current_user;

		$action = 'Decrypt';
		$operationdetails = 'ModuleRecord';

        $insert_sql = 'INSERT into ld_crmlog_decrypt(id,userid,`action`,module,crmid,operationdetails,operationtime) value(?,?,?,?,?,?,?)';
        $adb->pquery($insert_sql, array($logid,$current_user->id,$action,$module,$crmid,$operationdetails,date("Y-m-d H:i:s")));
	}
}

?>