<?php

class cls_OperationLogs_Merge extends cls_OperationLogs
{
    public function __construct($selectmodule,$actiontype,$userids,$operationtime=''){
		parent::__construct($selectmodule,$actiontype,$userids,$operationtime);
	}
    //获取单行日志内容
    public function getRowData($result,$i=0){
    	global $adb;

        $listdata = parent::getRowData($result,$i);
        $merged_crmids = $adb->query_result($result, $i, "mergedcrmids");
        $merged_details = $this->getHyperlinkHtmls($listdata['module'],$merged_crmids);
        $operationdetails = $this->getDetailsLabel($listdata['operationdetails_labelbol'],$listdata['module'],$listdata['crmid'],$merged_details);
        $listdata['operationdetails'] = $operationdetails;

        return $listdata;
    }
    //获取操作详情
    public function getDetailsLabel($labelbol,$module,$crmid,$content=''){

        $labelstr = parent::getDetailsLabel($labelbol,$module,$crmid);
        $labelstr = str_replace('{Var1}',$content,$labelstr);

        return $labelstr;
    }
    //保存日志
    public function save($logid,$module,$actiontype,$crmid,$content=[]){
        global $adb,$current_user;

        $action = 'Merge';
        $operationdetails = 'MergeLogLabel';
        $mergedcrmids = $content['pass_rec'];

        $insert_sql = 'INSERT into ld_crmlog_delete(id,userid,`action`,actiontype,module,crmid,operationdetails,
                        operationtime,mergedcrmids) value(?,?,?,?,?,?,?,?,?)';
        $adb->pquery($insert_sql, array($logid,$current_user->id,$action,$actiontype,$module,$crmid,$operationdetails,date("Y-m-d H:i:s"),$mergedcrmids));
    }
}

?>