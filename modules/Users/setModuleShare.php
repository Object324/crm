<?php
//zkt 20231024 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
header('Content-Type:text/html;charset=UTF-8');
//Eidtor:gyq_66 Reason:序时簿共享优化 Date:2018/5/7 0007 上午 10:33
//获取共享人信息
if(isset($_REQUEST['mode']) && 'tabshare' == $_REQUEST['mode']){
    crm_load_class_file('cls_share','include/Functions/Share');
    $objShare = new cls_share();
    echo $objShare->jsonEnco($objShare->getSelectedUser($_REQUEST['recordid']));
    exit;
}
//共享信息保存
if(isset($_REQUEST['recordall']) && isset($_REQUEST['frommodule'])){
    crm_load_class_file('cls_share','include/Functions/Share');
    $objShare = new cls_share();

    // 是否同步共享相关信息
    if(isset($_REQUEST['enablerelatedinfo']) && !empty($_REQUEST['enablerelatedinfo'])){
        $objShare->relatedinfoset_arr['sharerelatedinfo'] = $_REQUEST['enablerelatedinfo'];
        if(isset($_REQUEST['relmodule_scope']) && !empty($_REQUEST['relmodule_scope'])){
            $objShare->relatedinfoset_arr['relmodule_scope'] = $_REQUEST['relmodule_scope'];
            $objShare->relatedinfoset_arr['relmodule_selectedtabid_str'] = $_REQUEST['selectedtabid_str'];
        }
        $objShare->relatedinfoset_arr['type'] = 'seniorShare';
    }

    $recordArr = $objShare->check_permit($_REQUEST['frommodule'],$_REQUEST['recordall'],$_REQUEST['excluded_records'],$_REQUEST['useridall'],$_REQUEST['viewposition']);
    $content = $objShare->output_html();
    if($endrow >= sizeof($_SESSION[$current_user->id . '_'.$_REQUEST['frommodule'].'_share']['crmid']))
    {
        unset($_SESSION[$current_user->id.'_'.$_REQUEST['frommodule'].'_share']);
    }
    if($_REQUEST['change_share_mobile'] == 'yes'){
        global $adb;
        $focus = CRMEntity::getInstance($_REQUEST['frommodule']);
        $tablename = $focus->table_name;
        $table_index = $focus->table_index;
        $sql = "select modifiedtime from $tablename where $table_index =?";
        $result = $adb->pquery($sql,array($_REQUEST['recordall']));
        if($adb->num_rows($result)>0){
            $modifiedtime = $adb->query_result($result,0,'modifiedtime');
        }
        $arr = [];
        $arr['modifiedtime'] = $modifiedtime;

        crm_load_class_file("cls_savereverse", 'include/SaveReverse');
        $workflowreverseobj = cls_savereverse::getInstance($_REQUEST['frommodule']);
        $workflowreverseobj->setPageMode('Shared');
        $receive_msg = $workflowreverseobj->checkCallApiPop();
        $arr['workflow']['receive_msg'] = $receive_msg;
        if ($receive_msg == 'yes') {
            $arr['workflow']['record'] = $_REQUEST['recordall'];
            $arr['workflow']['module'] = $_REQUEST['frommodule'];
            $arr['workflow']['pagemode'] = $workflowreverseobj->getPageMode();
        }
        ConvertTojsonString(1, $arr,'success');
    }
    else{
        echo $objShare->jsonEnco($content);
        exit;
    }
}
exit;

?>