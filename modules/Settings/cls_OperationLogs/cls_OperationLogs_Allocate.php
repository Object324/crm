<?php

class cls_OperationLogs_Allocate extends cls_OperationLogs
{
    protected $idname = 'b.id';
    public function __construct($selectmodule,$actiontype,$userids,$operationtime=''){
		parent::__construct($selectmodule,$actiontype,$userids,$operationtime);
	}
    //获取单个操作行为日志列表内容
    public function getLogData($pagenum){
    	global $adb,$current_user;
        
        $sql .= $this->getQuery();
        $sql .= $this->getWhere();
        $sql .= $this->setPageInfo($pagenum);
        $result = $adb->query($sql);
        $num_rows = $adb->num_rows($result);

    	if($num_rows > 0) {
            for($i = 0; $i<$num_rows; $i++){
                $listdata[$i] = $this->getRowData($result,$i);
            }
    	}
        return $listdata;
    }
    public function isNeedSave($actiontype){

        if($actiontype == 'Allocate')//分配
            return false;
        return true;
    }
    //获取单行日志内容
    public function getRowData($result,$i=0){
    	global $adb;

        $listdata['user'] = getUserFullName($adb->query_result($result, $i, "whodid"));
        $listdata['operationtime'] = $adb->query_result($result, $i, "changedon");
        $listdata['action'] = 'ALLOCATE';
        $module = $adb->query_result($result, $i, "module");
        $listdata['module'] = $module;

        $crmid = $adb->query_result($result, $i, "crmid");
        $listdata['crmid'] = $crmid;
        $listdata['record'] = $this->getHyperlinkHtml($module,$crmid);

        $operationdetails_labelbol = 'AllocateLogLabel';
        $userid["pre"] = $adb->query_result($result, $i, "prevalue");
        $userid["post"] = $adb->query_result($result, $i, "postvalue");
        $operationdetails = $this->getDetailsLabel($operationdetails_labelbol,$module,$crmid,$userid);
        $listdata['operationdetails'] = $operationdetails;
        return $listdata;
    }
    
    //获取查询sql
    public function getQuery(){

        $sql = 'SELECT * FROM ld_modtracker_basic as b LEFT JOIN ld_modtracker_detail as d ON b.id = d.id';

        return $sql;
    }
    //获取查询条件
    public function getWhere(){

        $time_query = getHomeDateScope($this->operationtime);
        $where = ' where b.module = "'.$this->selectmodule.'"';
        if($this->userids != 'SmOwner_Search_All'){
            $where .= ' and b.whodid in ('.$this->userids.') ';
        }
        if($time_query != ''){
            $where .= ' and b.changedon '.$time_query.'';
        }
        $where .= ' and d.fieldname = "assigned_user_id"';
        $where .= '  ORDER BY b.changedon desc';
        return $where;
    }
    //获取操作详情
    public function getDetailsLabel($labelbol,$module,$crmid,$content=''){

        $remove_users = $this->getUsersFullName($content['pre']);
        $shareto_users = $this->getUsersFullName($content['post']);
        $labelstr = parent::getDetailsLabel($labelbol,$module,$crmid);
        $labelstr = str_replace('{Var2}',$remove_users,$labelstr);
        $labelstr = str_replace('{Var3}',$shareto_users,$labelstr);

        return $labelstr;
    }
    //保存日志
    public function save($logid,$module,$actiontype,$crmid,$content=[]){
        
    }
}

?>