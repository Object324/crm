<?php

class cls_OperationLogs_Edit extends cls_OperationLogs
{
    public $action;
    public function __construct($selectmodule,$actiontype,$userids,$operationtime=''){
		parent::__construct($selectmodule,$actiontype,$userids,$operationtime);
	}

    //保存日志
    public function save($logid,$module,$actiontype,$crmid,$content=[]){
        global $adb,$current_user;

        $action = '';
        if(isset($content['massedit_recordids']) && $content['ajaxaction'] == 'MassEditSave'){
            $action = 'MASSEDIT';
        }else if($content['logaction'] == 'listedit'){
            $action = 'ListEdit';
        }else if($content['logaction'] == 'detailviewedit'){
            $action = 'DetailViewEdit';
        }else{
            $action = 'EDIT';
        }
        $operationdetails = 'ModuleRecord';
        $insert_sql = 'INSERT into ld_crmlog_edit(id,userid,`action`,module,crmid,operationdetails,operationtime) value(?,?,?,?,?,?,?)';
        $adb->pquery($insert_sql, array($logid,$current_user->id,$action,$module,$crmid,$operationdetails,date("Y-m-d H:i:s")));
        return $logid;
    }
    //wsh 2024-07-03 XUQIU20240607-08 单据查看详情界面，相关信息操作日志，“编辑”操作详情增加“修改日志详情”操作按钮
    public function getHyperlinkHtml($module,$crmid){
        $relationId = $this->getViewHistoryRelationId($module);
        $logid = $this->logid;
        $title = getFixedLabel("ModifyingLogDetailstr");
        if($this->logs_from == 'mobile'){
            return '';
        }
        if ($this->getEditDetailLogs()){
            $hyperlink_html = '<a module = "'.$module.'" whodid = "'.$this->getUserids().'" changedon = "'.$this->getOperationtime().'" record="'.$crmid.'" relationId="'.$relationId.'" logId="'.$logid.'" href="javascript:;" onclick="get_edit_detail_logs(ld(this))">'.$title.'</a>';
        }else{
            $hyperlink_html = '<a module = "'.$module.'" whodid = "'.$this->getUserids().'" changedon = "'.$this->getOperationtime().'" record="'.$crmid.'" relationId="'.$relationId.'" logId="'.$logid.'" href="javascript:;" onclick="get_edit_detail_log(ld(this))">'.$title.'</a>';
        }
        return $hyperlink_html;
    }

    public function getViewHistoryRelationId($module)
    {
        global $adb,$current_user;
        $tabid = getTabid($module);
        if($tabid == 16)$tabid = 9;
        $sql = "select relation_id from ld_relatedlists where label = 'ViewHistory' and tabid = " . $tabid;
        $result = $adb->query($sql);
        return $result->fields['relation_id'];
    }
}

?>