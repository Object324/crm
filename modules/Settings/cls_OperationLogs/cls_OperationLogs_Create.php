<?php

class cls_OperationLogs_Create extends cls_OperationLogs
{
    public function __construct($selectmodule,$actiontype,$userids,$operationtime=''){
		parent::__construct($selectmodule,$actiontype,$userids,$operationtime);
	}
    //获取单行日志内容
    public function getRowData($result,$i=0){
    	global $adb;

        $listdata = parent::getRowData($result,$i);
        if($listdata['action'] == 'ASSOCIATIONTOCREATE'){//关联创建
            $frommodule['fromcrmid'] = $adb->query_result($result, $i, "fromcrmid");
            $frommodule['frommodule'] = $adb->query_result($result, $i, "frommodule");
            $operationdetails = $this->getDetailsLabel($listdata['operationdetails_labelbol'],$listdata['module'],$listdata['crmid'],$frommodule);
            $listdata['operationdetails'] = $operationdetails;
        }
        
        return $listdata;
    }
    //获取操作详情
    public function getDetailsLabel($labelbol,$module,$crmid,$content=''){
        $modulename = getTranstab($module);
        $record = $this->getHyperlinkHtml($module,$crmid);
        $fromcrmid = $this->getHyperlinkHtmls($content['frommodule'],$content['fromcrmid']);
        $frommodulename = getTranstab($content['frommodule']);

        $labelstr = getFixedLabel($labelbol);
        $labelstr = str_replace('{Module}',$modulename,$labelstr);
        $labelstr = str_replace('{Var}',$record,$labelstr);
        $labelstr = str_replace('{FromModule}',$frommodulename,$labelstr);
        $labelstr = str_replace('{Var1}',$fromcrmid,$labelstr);
        return $labelstr;
    }
    //保存日志
    public function save($logid,$module,$actiontype,$crmid,$content=[]){
        global $adb,$current_user;

        $action = '';
        $frommodule = NULL;
        $fromid = NULL;
        if(isset($content['isDuplicate']) && $content['isDuplicate'] == 'true'){
            $action = 'CopyCreate';
            $operationdetails = 'ModuleRecord';
        }else if(isset($content['frommodule']) && !empty($content['frommodule'])){
            $action = 'ASSOCIATIONTOCREATE';
            $frommodule = $content['frommodule'];
            $fromid = $content['fromid'];
            $operationdetails = 'AssociationCreateLabel';
        }else if(isset($content['relatedCreationInfo']) && !empty($content['relatedCreationInfo'])){// 移动端关联创建
            $action = 'ASSOCIATIONTOCREATE';
            $relatedCreationInfo = Zend_Json::decode($content['relatedCreationInfo']);
            $frommodule = $relatedCreationInfo['frommodule'];
            $fromid = $relatedCreationInfo['fromid'];
            $operationdetails = 'AssociationCreateLabel';
        }else{
            $action = 'CREATE';
            $operationdetails = 'ModuleRecord';
        }
        $insert_sql = 'INSERT into ld_crmlog_create(id,userid,`action`,module,crmid,operationdetails,
                        operationtime,frommodule,fromcrmid) value(?,?,?,?,?,?,?,?,?)';
        $adb->pquery($insert_sql, array($logid,$current_user->id,$action,$module,$crmid,$operationdetails,date("Y-m-d H:i:s"),$frommodule,$fromid));
    }
}

?>