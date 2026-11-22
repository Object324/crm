<?php

class cls_OperationLogs_Delete extends cls_OperationLogs
{
    public function __construct($selectmodule,$actiontype,$userids,$operationtime=''){
		parent::__construct($selectmodule,$actiontype,$userids,$operationtime);
	}
    //获取单行日志内容

    // //获取操作详情
    // public function getDetailsLabel($labelbol,$module,$crmid,$content=''){
    //     $labelstr = parent::getDetailsLabel($labelbol,$module,$crmid);
    //     $labelstr = str_replace('{Var1}',$content,$labelstr);
    //     return $labelstr;
    // }
    //保存日志
    public function save($logid,$module,$actiontype,$crmids,$content=[]){
        global $adb,$current_user;

        $action = 'DELETE';
        $operationdetails = 'ModuleRecord';
        if(isset($content['deletetype']) && $content['deletetype'] == 'rassdelete'){
            $action = 'COMPLETELYDELETED';//回收站 删除
        }

        $insert_sql = 'INSERT into ld_crmlog_delete(id,userid,`action`,actiontype,module,crmid,operationdetails,
                        operationtime) value(?,?,?,?,?,?,?,?)';
        $crmids = !is_array($crmids)?[$crmids]:$crmids;
        $logid = !is_array($logid)?[$logid]:$crmids;

        foreach($crmids as $index => $crmid){
            $adb->pquery($insert_sql, array($logid[$index],$current_user->id,$action,$actiontype,$module,$crmid,$operationdetails,date("Y-m-d H:i:s")));
        }
    }
}

?>