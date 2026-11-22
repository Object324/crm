<?php

class cls_OperationLogs_Share extends cls_OperationLogs
{
    public function __construct($selectmodule,$actiontype,$userids,$operationtime=''){
		parent::__construct($selectmodule,$actiontype,$userids,$operationtime);
	}
    //获取单行日志内容
    public function getRowData($result,$i=0){
    	global $adb;

        $listdata = parent::getRowData($result,$i);
        $userids_content["remove"] = $adb->query_result($result, $i, "remove_userids");
        $userids_content["shareto"] = $adb->query_result($result, $i, "shareto_userids");
        
        $operationdetails = $this->getDetailsLabel($listdata['operationdetails_labelbol'],$listdata['module'],$listdata['crmid'],$userids_content);
        $listdata['operationdetails'] = $operationdetails;
        return $listdata;
    }
    //获取操作详情
    public function getDetailsLabel($labelbol,$module,$crmid,$content=''){

        $remove_users = $this->getUsersFullName($content['remove']);
        $shareto_users = $this->getUsersFullName($content['shareto']);
        $labelstr = parent::getDetailsLabel($labelbol,$module,$crmid);
        $labelstr = str_replace('{Var2}',$remove_users,$labelstr);
        $labelstr = str_replace('{Var3}',$shareto_users,$labelstr);

        return $labelstr;
    }
    //保存日志
    public function save($logid,$module,$actiontype,$crmid,$content=[]){
        global $adb,$current_user;

        $shareto_userids = $content['shareto_userids'];
        $remove_userids = $content['remove_userids'];
        $action = 'SHARE';
        if(empty($shareto_userids) && !empty($remove_userids)){
            $operationdetails = 'ShareLogLabel2';
        }else if(empty($remove_userids) && !empty($shareto_userids)){
            $operationdetails = 'ShareLogLabel3';
        }else{
            $operationdetails = 'ShareLogLabel';
        }
        $insert_sql = 'INSERT into ld_crmlog_share(id,userid,`action`,module,crmid,operationdetails,
                        operationtime,shareto_userids,remove_userids) value(?,?,?,?,?,?,?,?,?)';
        $adb->pquery($insert_sql, array($logid,$current_user->id,$action,$module,$crmid,$operationdetails,date("Y-m-d H:i:s"),$shareto_userids,$remove_userids));
    }
}

?>