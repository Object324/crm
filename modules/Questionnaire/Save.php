<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb, $currentModule;
$focus = CRMEntity::getInstance($currentModule);
$focus->mode = 'create';
if ($_REQUEST['record'] > 0) {
    $focus->id = $_REQUEST['record'];
    $focus->retrieve_entity_info($focus->id, $currentModule);
    $before_columnfieldvalue = $focus->column_fields;
    $focus->mode = 'edit';

}
//dump($focus->column_fields);
$search = vtlib_purify($_REQUEST['search_url']);

setObjectValuesFromRequest($focus);
$focus->save($currentModule);
$return_id = $focus->id;

//默认创建调查问卷的虚拟模块
if($return_id > 0){
    //复制问卷
    if(isset($_REQUEST['copyid']) && $_REQUEST['copyid'] > 0){
        $copyid = $_REQUEST['copyid'];
        $createdtime = date('Y-m-d H:i:s');
        $sel_block = 'select blockid from ld_questionnaire_block where questionnaireid = ?;';
        $result_block = $adb->pquery($sel_block,array($copyid));
        if($adb->num_rows($result_block) > 0){
            for($i = 0;$i < $adb->num_rows($result_block);$i++){
                $blockid = $adb->query_result($result_block,$i,'blockid');
                $sql_block = 'insert into ld_questionnaire_block(questionnaireid,blockname,autonumber,numberstyle,numbersuffix,blocktype,sequence,deleted,createdtime,modifiedtime)
                    select "'.$return_id.'",blockname,autonumber,numberstyle,numbersuffix,blocktype,sequence,deleted,"'.$createdtime.'","'.$createdtime.'" from ld_questionnaire_block where questionnaireid = ? and blockid = ?;';
                $adb->pquery($sql_block,array($copyid,$blockid));
                $new_blockid = $adb->getLastInsertID();

                $sel_topic = 'select topicid,topic_type from ld_questionnaire_topic where questionnaireid = ? and blockid = ?;';
                $result_topic = $adb->pquery($sel_topic,array($copyid,$blockid));
                $other_topid_arr = [];
                if($adb->num_rows($result_topic) > 0){
                    for($j = 0;$j < $adb->num_rows($result_topic);$j++){
                        $topic_type = $adb->query_result($result_topic,$j,'topic_type');
                        $topic_id = $adb->query_result($result_topic,$j,'topicid');
                        if($topic_type == 'one' || $topic_type == 'more'){
                            $sql_topic1 = 'insert into ld_questionnaire_topic(questionnaireid,topic_type,topic_name,required,sequence,deleted,description,topic_json,created_at,updated_at,topic_json_old,referencemodule,advance_demand,advance_demand_groups,maxrowsshow,fieldonly,approve_demand,telregexp,blockid)
                                select "'.$return_id.'",topic_type,topic_name,required,sequence,deleted,description,topic_json,"'.$createdtime.'","'.$createdtime.'",topic_json_old,referencemodule,advance_demand,advance_demand_groups,maxrowsshow,fieldonly,approve_demand,telregexp,"'.$new_blockid.'" from ld_questionnaire_topic where questionnaireid = ? and blockid = ? and topicid = ?; ';
                            $adb->pquery($sql_topic1,array($copyid,$blockid,$topic_id));
                            $new_topic_id = $adb->getLastInsertID();

                            $sql_option = 'insert into ld_questionnaire_topic_option(topicid,topicoption,sequence,deleted,created_at,updated_at)
                                select "'.$new_topic_id.'",topicoption,sequence,deleted,"'.$createdtime.'","'.$createdtime.'" from ld_questionnaire_topic_option where topicid = ?;';
                            $adb->pquery($sql_option,array($topic_id));
                        }
                        else{
                            $other_topid_arr[] = $topic_id;
                        }
                    }
                }
                if(count($other_topid_arr)){
                    $sql_topic2 = 'insert into ld_questionnaire_topic(questionnaireid,topic_type,topic_name,required,sequence,deleted,description,topic_json,created_at,updated_at,topic_json_old,referencemodule,advance_demand,advance_demand_groups,maxrowsshow,fieldonly,approve_demand,telregexp,blockid)
                        select "'.$return_id.'",topic_type,topic_name,required,sequence,deleted,description,topic_json,"'.$createdtime.'","'.$createdtime.'",topic_json_old,referencemodule,advance_demand,advance_demand_groups,maxrowsshow,fieldonly,approve_demand,telregexp,"'.$new_blockid.'" from ld_questionnaire_topic where questionnaireid = ? and blockid = ? and topicid in ('.implode(',', $other_topid_arr).'); ';
                    $adb->pquery($sql_topic2,array($copyid,$blockid));
                }

            }
        }

    }
    else{
        $sql = "select 1 from ld_questionnaire_block where questionnaireid = ? and blocktype = 'virtual';";
        $result = $adb->pquery($sql,array($return_id));

        if($adb->num_rows($result) > 0){

        }else{
            $createdtime = date('Y-m-d H:i:s');
            $sql_insert = "INSERT INTO ld_questionnaire_block(`questionnaireid`,`blockname`,`autonumber`,`numberstyle`,`numbersuffix`,`blocktype`,`sequence`,`createdtime`,`modifiedtime`) VALUES (".$return_id.",'virtual','no','','','virtual',0,'".$createdtime."','".$createdtime."');";
            $adb->pquery($sql_insert,array());
        }
    }
}

//$focus->retrieve_entity_info($focus->id, $currentModule);
//$questionnaire_no =$focus->column_fields['questionnaire_no'];
//$_REQUEST['questionnaire_no'] =$questionnaire_no;
//删除题目
//if (isset($topic_array_new)&& $focus->mode = 'edit'){
//    //$topic_json_arr = ldcrm_json_decode($_REQUEST['topic_json_arr']);
//    $focus->delect_topic($_REQUEST['record'],$topic_array_new);
//}
//
////保存题目 topic_json_arr
//if (isset($_REQUEST['topic_json_arr']) && $_REQUEST['topic_json_arr'] != '' && $focus->mode == 'create') {
//    $topic_json_arr = ldcrm_json_decode($_REQUEST['topic_json_arr']);
//    $focus->SaveTopic($topic_json_arr);
//}
//
////编辑题目
//if (isset($_REQUEST['topic_json_arr']) && $_REQUEST['topic_json_arr'] != '' && $focus->mode == 'edit') {
//    $topic_json_arr = ldcrm_json_decode($_REQUEST['topic_json_arr']);
//    $topic_array_new = $focus->EditTopic($topic_json_arr);
//}


if (isset($_REQUEST['return_module']) && $_REQUEST['return_module'] != "") $return_module = vtlib_purify($_REQUEST['return_module']);
else $return_module = $currentModule;
if (isset($_REQUEST['return_action']) && $_REQUEST['return_action'] != "") $return_action = vtlib_purify($_REQUEST['return_action']);
else $return_action = "DetailView";
if (isset($_REQUEST['return_id']) && $_REQUEST['return_id'] != "") $return_id = vtlib_purify($_REQUEST['return_id']);


/**
 * 列表编辑后，返回列表时，增加query_session=1的参数，启用列表页面搜索session
 * @project 序时簿查询记住搜索条件
 * @author Tujt 2014-04-25
 */
if ($return_module == $currentModule && $return_action != 'DetailView') {
    $return_action .= '&query_session=1';
}
$_REQUEST['diony'] = 'diony';
$focus->column_fields['record_module'] = $focus->module_name;
if ($_REQUEST['refreshpage'] == 'no') {

    $focus->ReturnAfterSave($before_columnfieldvalue);

} else if ((isset($_REQUEST['Create']) && ($_REQUEST['Create'] == 'true' || $_REQUEST['Create'] == 'yes')) || $_REQUEST['isDuplicate'] == 'true') {
    header("Location: index.php?action=$return_action&module=$return_module&SearchScope=$SearchScope&record=$return_id&Create=true&activity_mode=$activitymode&viewname=$return_viewname&start=" . vtlib_purify($_REQUEST['pagenumber']));
} else {
    header("Location: index.php?action=$return_action&module=$return_module&SearchScope=$SearchScope&record=$return_id&activity_mode=$activitymode&viewname=$return_viewname&start=" . vtlib_purify($_REQUEST['pagenumber']));
}

?>