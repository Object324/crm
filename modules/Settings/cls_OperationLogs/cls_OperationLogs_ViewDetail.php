<?php
//回收站还原
class cls_OperationLogs_ViewDetail extends cls_OperationLogs
{
    public function __construct($selectmodule,$actiontype,$userids,$operationtime=''){
		parent::__construct($selectmodule,$actiontype,$userids,$operationtime);
	}
	//保存日志
	public function save($logid,$module,$actiontype,$crmid,$content=[]){
		global $adb,$current_user;
		$action = 'VIEWDETAILSINFO';
		$operationdetails = 'ModuleRecord';
		$insert_sql = 'INSERT into ld_crmlog_viewdetail(id,userid,`action`,actiontype,module,crmid,operationdetails,
						operationtime) value(?,?,?,?,?,?,?,?)';
		$adb->pquery($insert_sql, array($logid,$current_user->id,$action,$actiontype,$module,$crmid,$operationdetails,date("Y-m-d H:i:s")));
	}
}

?>