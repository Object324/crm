<?php
/*+********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ********************************************************************************/

include_once('vtlib/lingdang/Utils.php');
global $current_user,$adb,$languageType;
global $theme;
$smarty = new lingdangCRM_Smarty;
//头部显示内容
$headerarr = ['functionsetting','callrecordlogs'];//功能设置，通信日志查询
$selectpage = $headerarr[0];
if(isset($_REQUEST['selectpage'])&&in_array($_REQUEST['selectpage'],$headerarr)){
    $selectpage = $_REQUEST['selectpage'];
}
if(isset($_REQUEST['mode'])){
    $mode = $_REQUEST['mode'];
}

$ret_arr = [];
// 功能设置
if($selectpage == 'functionsetting')
{
    crm_load_class_file('cls_CallRecord', 'modules/Settings');
    $cls_callrecord = new cls_CallRecord();

    
    if($mode == 'enablecallrecord'){// 启用/关闭通话录音
        $callrecordstatus = $_REQUEST['callrecordstatus'];
        $update_sql = "UPDATE ld_callrecordfields set `status` = ?";
        if($callrecordstatus == 'no'){
            $adb->pquery($update_sql,array('no'));
        }else{
            $update_sql .= " where columnnames <> '' and columnnames is not null";
            $adb->pquery($update_sql,array('yes'));
        }
        ConvertTojsonString(1,$arr,'success');

    }else if($mode == 'editfields'){

        $enabledphonefields = $cls_callrecord->getEnabledPhoneFields();
        $phonefields = $cls_callrecord->getPhoneFields();

        $arr['title'] = getFixedLabel('CallRecordSetting');
        $arr['oktext'] = getFixedLabel("SAVE");
        $arr['canceltext'] = getFixedLabel("CANCEL");
        $arr['tabletitle'] = getFixedLabel("PHONECALLINFIELDS");
        $arr['enabledphonefields'] = $enabledphonefields;
        $arr['phonefields'] = $phonefields;
        $arr['availabletimelabel'] = getFixedLabel("MONTHSAPP");
        
        // dump($phonefields);
        $_REQUEST['diony']='yes';
        ConvertTojsonString(1,$arr,"success");

    }else if($mode == 'savefields'){

        $enabledmodule = Zend_Json::decode($_REQUEST['enabledmodule']);
        $enabledphonefields = Zend_Json::decode($_REQUEST['enabledphonefields']);

        $cls_callrecord->setModuleAndFieldStatus($enabledmodule,$enabledphonefields);
        
        $_REQUEST['diony']='yes';
        ConvertTojsonString(1,$arr,"success");
    }

    $callrecordstatus = $cls_callrecord->getCallRecordStatus();
    $phonefieldlabel = $cls_callrecord->getEnabledPhoneFields('label');

    $smarty->assign('callrecordstatus',$callrecordstatus);
    $smarty->assign('phonefieldlabel',$phonefieldlabel);

}
//通话日志查询
else if($selectpage == 'callrecordlogs')
{
    if($mode == 'setMaxEntriesPerPage'){//设置最大条数
        setUsersettingByLabel('CallRecordSettingLogs',$current_user->id,'MaxEntriesPerPageByuser',$_REQUEST['pagecount']);
    
        $_REQUEST['diony']='yes';
        ConvertTojsonString(1,$arr,"success");
    
    }

    crm_load_class_file('cls_OperationLogs', 'modules/Settings/cls_OperationLogs');
    $selectmodule = $_REQUEST['selectmodule'];
    $selectcalltype = $_REQUEST['selectcalltype'];
    $startdate = $_REQUEST['startdate'];
    $enddate = $_REQUEST['enddate'];
    $basicsearchoption = $_REQUEST['basicsearchoption'];
    $basicsearchvalue = $_REQUEST['basicsearchvalue'];
    $cls_operationlogs = cls_OperationLogs::getInstance($selectmodule,'CallRecord',$userids,$operationtime,'CallRecord');
    $list_max_entries_per_page_new=getUsersettingByLabel('CallRecordSettingLogs',$current_user->id,'MaxEntriesPerPageByuser')??getUsersettingByLabel('CallRecordSettingLogs',1,'MaxEntriesPerPage');
    $list_max_entries_per_page_new=empty($list_max_entries_per_page_new)?'20':$list_max_entries_per_page_new;
    $cls_operationlogs->max_entries = $list_max_entries_per_page_new;
    //获取表头
    $table_header = $cls_operationlogs->getTableHeader();
    $headerwidth = $cls_operationlogs->getHeaderWidth();
    $smarty->assign('TableHeader',$table_header);
    $smarty->assign('HeaderWidth',$headerwidth);
    $smarty->assign('DataLength', -1);
    $smarty->assign("LogType", 'CallRecord');

    if(isset($_REQUEST['pagenum']) && $_REQUEST['pagenum'] != '')
        $pagenum = $_REQUEST['pagenum'];
    else
        $pagenum = 1;
    $cls_operationlogs->selectcalltype = $selectcalltype;
    $cls_operationlogs->startdate = $startdate;
    $cls_operationlogs->enddate = $enddate;
    $cls_operationlogs->basicsearchoption = $basicsearchoption;
    $cls_operationlogs->basicsearchvalue = $basicsearchvalue;
    if($mode == 'searchLogs'){//搜索

        $listdata = $cls_operationlogs->getLogData($pagenum);
        $smarty->assign('ListData', $listdata);
        $smarty->assign('DataLength', is_array($listdata)?count($listdata):0);
    
        //分页
        $noofrows = $cls_operationlogs->getTotalRows();
        $smarty->assign('MAX_RECORDS', $list_max_entries_per_page_new);
    
        $queryMode = (isset($_REQUEST['query']) && $_REQUEST['query'] == 'true');
        $start = ListViewSession::getRequestCurrentPage($currentModule, $noofrows, $viewid, $queryMode);
    
        $smarty->assign("TABNAME", getParentTab());
        $smarty->assign("STARTPAGE", ceil($start));
        $smarty->assign("LISTVIEWRECORDCOUNT", ceil($noofrows));
        $smarty->assign("LISTVIEWPAGECOUNT", ceil($noofrows/$list_max_entries_per_page_new));
        crm_load_function_file('getlistmaxentries_per_page','include/utils','ListViewUtils');
        $smarty->assign("LISTVIEWPERPAGENUM", json_encode(getlistmaxentries_per_page($list_max_entries_per_page_new)));
    
        $smarty->assign("FunctionObj", 'CallRecordSetting');

        $arr['content']= $smarty->fetch('Settings/OperationLogsList.tpl');
        ConvertTojsonString(1,$arr,"success");
    
    }else if($mode == 'changeLogspage'){//换页
    
        $listdata = $cls_operationlogs->getLogData($pagenum);
        $smarty->assign('ListData', $listdata);
        $smarty->assign('DataLength', count($listdata));
        $arr['content']= $smarty->fetch('Settings/OperationLogsListTable.tpl');
        ConvertTojsonString(1,$arr,"success");

    }
    
    //获取可选模块，通话类型，基本查找选项
    $selectModule = $cls_operationlogs->getselectModules();
    $calltypes = $cls_operationlogs->getCallType();
    $basicsearch_options = $cls_operationlogs->getBasicSearchOptions();
    $smarty->assign('SELECTMODULE',$selectModule);
    $smarty->assign('calltypes',$calltypes);
    $smarty->assign('basicsearch_options',$basicsearch_options);

    //分页
    $noofrows = $cls_operationlogs->getTotalRows();

    $smarty->assign('MAX_RECORDS', $list_max_entries_per_page_new);

    $queryMode = (isset($_REQUEST['query']) && $_REQUEST['query'] == 'true');
    $start = ListViewSession::getRequestCurrentPage($currentModule, $noofrows, $viewid, $queryMode);

    $smarty->assign("TABNAME", getParentTab());
    $smarty->assign("STARTPAGE", ceil($start));
    $smarty->assign("LISTVIEWRECORDCOUNT", ceil($noofrows));
    $smarty->assign("LISTVIEWPAGECOUNT", ceil($noofrows/$list_max_entries_per_page_new));
    crm_load_function_file('getlistmaxentries_per_page','include/utils','ListViewUtils');
    $smarty->assign("LISTVIEWPERPAGENUM", json_encode(getlistmaxentries_per_page($list_max_entries_per_page_new)));

    //获取查询的时间范围
    $startdate = date('Y-m') . '-01';
    $enddate = date('Y-m-t',time());
    $smarty->assign('startdate',$startdate);
    $smarty->assign('enddate',$enddate);
}

$ret_arr['selectpage'] = $selectpage;
$ret_arr['headerarr'] = $headerarr;

$smarty->assign('selectpage',$selectpage);
$smarty->assign('headerarrjson',json_encode($headerarr));
if($_REQUEST['ajax'] == 'true')
{
    $ret_arr['content']=$smarty->fetch('Settings/CallRecordSettingContent.tpl');
}
else
{
    $ret_arr['content']=$smarty->fetch('Settings/CallRecordSetting.tpl');
}
ConvertTojsonString(1,$ret_arr,'success');
?>