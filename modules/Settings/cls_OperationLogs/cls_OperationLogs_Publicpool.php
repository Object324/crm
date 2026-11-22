<?php

class cls_OperationLogs_Publicpool extends cls_OperationLogs
{
    private $publicpool_actions = [
        'Transfer'=>"TOBETHE%CUSTOM%",//变更公海
        'Release'=>"TORELEASETHECUSTOMERTOTHEHIGNSEAS%",//释放
        'Distribute'=>"ALLOCATEPUBLICACCOUNTGIVEN%",//分配
        'Receuve'=>"GETMYPUBLICACCOUNT%",//领取
        'Delay'=>"DELAYPUBLICACCOUNTDAYS%",//延期
    ];
    private $actionlabelbol = [
        'Transfer' => 'Transfer',//变更公海
        'Distribute' => 'LBL_DISTRIBUT_HIGHSEAS',//公海分配
        'Receuve' => 'RECEIVE',//公海领取
        'Release' => 'RELEASE',//公海释放
        'Delay' => 'ACCOUNTDELAY',//公海延期
    ];
    public $log_table;//日志表
    public $pool_table;//公海池表
    public $idindex;
    protected $idname = 'log.id';
    public function __construct($selectmodule,$actiontype,$userids,$operationtime=''){
		parent::__construct($selectmodule,$actiontype,$userids,$operationtime);
        if($selectmodule == 'Accounts'){
            $this->log_table = 'ld_logpublicaccount';
            $this->pool_table = 'ld_account_public_pool';
            $this->idindex = 'accountid';

        }else if($selectmodule == 'Leads'){
            $this->log_table = 'ld_logpublicleads';
            $this->pool_table = 'ld_leads_public_pool';
            $this->idindex = 'leadsid';
        }
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
    //获取单行日志内容
    public function getRowData($result,$i=0){
    	global $adb,$languageType;

        $listdata['user'] = getUserFullName($adb->query_result($result, $i, "userid"));
        $listdata['operationtime'] = $adb->query_result($result, $i, "opdate");
        $listdata['action'] = $this->actionlabelbol[$this->actiontype];
        $module = $this->selectmodule;
        $listdata['module'] = $module;

        $crmid = $adb->query_result($result, $i, $this->idindex);
        $listdata['record'] = $this->getHyperlinkHtml($module,$crmid);

        $zh_name = $adb->query_result($result, $i, "zh_name");
        $zh_name = !empty($zh_name)?$zh_name.' , ':'';
        $en_name = $adb->query_result($result, $i, "en_name");
        $en_name = !empty($en_name)?$en_name.' , ':'';
        $operation = $adb->query_result($result, $i, "operation");
        if(stripos($operation,'$###$')!==false)
        {
            
            $strs=explode('$###$',$operation);
            
            $operation = sprintf(getFixedLabel($strs[0]),$strs[1]);

        }
        else if(stripos($operation,'$####$')!==false)//释放原因
        {
                $strs = explode('$####$', $operation);
            $operation = getFixedLabel($strs[0]);

            $operation .= '&nbsp;&nbsp;&nbsp;&nbsp;' . getFixedLabel('RELEASEACCOUNTTREASON') . ':' . $strs[1];
        }
        else {
            //chj 2021/1/14 44264: 公海操作日志：将客户转为公海客户，建议后面增加“公海池信息”
            if($operation == 'TOBETHEHIGHSEASCUSTOMTERS'){
                if($languageType == 'zh')
                    $operation = getFixedLabel($operation).','.getFixedLabel('Highseaspool') .': '.$zh_name;
                else
                    $operation = getFixedLabel($operation).','.getFixedLabel('Highseaspool') .': '.$en_name;
            }else{
                $operation = getFixedLabel($operation);
            }
        }
        if($languageType == 'zh')
            $operation = $zh_name.getFixedLabel($operation);
        else
            $operation = $en_name.getFixedLabel($operation);
        $listdata['operationdetails'] = $operation;
        return $listdata;
    }
    
    //获取查询sql
    public function getQuery(){

        $sql = 'SELECT log.id,log.username,operation,opdate,log.userid,zh_name,en_name,'.$this->idindex.' from '.$this->log_table.' as log
		        LEFT JOIN '.$this->pool_table.' as pool on pool.id = log.pool_id';

        return $sql;
    }
    //获取查询条件
    public function getWhere(){

        $time_query = getHomeDateScope($this->operationtime);
        $where = ' where log.operation like "'.$this->publicpool_actions[$this->actiontype].'"';
        if($this->userids != 'SmOwner_Search_All' && !empty($this->userids)){
            $where .= ' and log.userid in ('.$this->userids.') ';
        }
        if($time_query != ''){
            $where .= ' and log.opdate '.$time_query;
        }

        $where .= '  ORDER BY log.opdate desc';
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
    public function isNeedSave($actiontype){

        return false;
    }
    //保存日志
    public function save($logid,$module,$actiontype,$crmid,$content=[]){
        
    }
}

?>