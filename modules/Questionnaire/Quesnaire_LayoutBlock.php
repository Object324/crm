<?php
global $adb, $currentModule;
$_REQUEST['diony']='diony';
$subMode = $_REQUEST['sub_mode'];

if($subMode == 'addBlock'){
    saveBlock();
}elseif($subMode == 'deleteBlock'){
    deleteBlock();
}elseif ($subMode =='changeBlockOrder'){
    changeBlockOrder();
}elseif ($subMode =='moveBlockOrder'){
    moveBlockOrder();
}elseif($subMode == 'getlayoutblock'){
    getLayoutBlock();
}elseif ($subMode == 'addTopic'){
    addTopic();
}elseif($subMode == 'deleteTopic'){
    deleteTopic();
}elseif($subMode == 'changeTopicOrder'){
    changeTopicOrder();
}elseif($subMode == 'getChartsaveDetail'){
    getChartsaveDetail();
}
//保存区块
function saveBlock(){
    global $currentModule;
    $blockinfo['questionnaireid'] = $_REQUEST['record'];
    $blockinfo['blockid'] = $_REQUEST['blockid'];
    $blockinfo['blockname'] = $_REQUEST['blockname'];
    $blockinfo['afterblockid'] = $_REQUEST['afterblockid'];
    $blockinfo['automatic_number'] = $_REQUEST['automatic_number'];
    if($blockinfo['automatic_number'] == 'yes'){
        $blockinfo['automatic_number_style'] = $_REQUEST['automatic_number_style'];
        $blockinfo['automatic_number_postfix'] = $_REQUEST['automatic_number_postfix'];
    }else{
        $blockinfo['automatic_number_style'] = '';
        $blockinfo['automatic_number_postfix'] = '';
    }
    $focus = CRMEntity::getInstance($currentModule);
    $focus->saveBlock($blockinfo);
    ConvertTojsonString(1,'',"success");
}
//删除区块
function deleteBlock(){
    global $adb,$currentModule;
    $blockid  = $_REQUEST['blockid'];
    if($blockid > 0){
        $have_chart = 'yes';
        $sql_select = 'select topicid from ld_questionnaire_topic where blockid = ? and deleted = 0';
        $result_select = $adb->pquery($sql_select,array($blockid));
        if($adb->num_rows($result_select)>0){
            $topicid_array = '';
            for($i = 0;$i<$adb->num_rows($result_select);$i++){
                if($i == 0){
                    $topicid_array .= $adb->query_result($result_select,$i,'topicid');
                }else{
                    $topicid_array .= ','.$adb->query_result($result_select,$i,'topicid');
                }
            }
            $sql_chart = 'select 1 from ld_questionnaire_chart where topicid in ('.$topicid_array.');';
            $result_chart = $adb->pquery($sql_chart,array());
            if($adb->num_rows($result_chart) > 0){
                $have_chart = 'yes';
            }else{
                $have_chart = 'no';
            }
        }else{
            $have_chart = 'no';
        }
        if($have_chart == 'yes'){
            ConvertTojsonString(2,'',"success");
        }else{
            $focus = CRMEntity::getInstance($currentModule);
            $focus->delect_block($blockid);
            ConvertTojsonString(1,'',"success");
        }
    }
}
//修改区块顺序
function changeBlockOrder(){
    global $currentModule;
    $blockid = $_REQUEST['blockid'];
    $changeid = $_REQUEST['changeid'];
    $focus = CRMEntity::getInstance($currentModule);
    $focus->Change_Block_Order($blockid,$changeid);
    ConvertTojsonString(1,'',"success");
}
//移动修改区块顺序
function moveBlockOrder(){
    global $currentModule;
    $focus = CRMEntity::getInstance($currentModule);
    $focus->id = $_REQUEST['record'];
    $sequence_array = explode(',',$_REQUEST['sequence']);
    $focus->moveBlockOrder($focus->id,$sequence_array);
    ConvertTojsonString(1,'',"success");
}
//获取区块、题目信息
function getLayoutBlock(){
    global $adb, $currentModule;
    $focus = CRMEntity::getInstance($currentModule);
    $layoutblockarray = $focus->getLayoutBlock($_REQUEST['record']);

    $sql_status = 'select `status` from ld_questionnaire where questionnaireid = ?;';
    $result_status = $adb->pquery($sql_status,array($_REQUEST['record']));
    if($adb->num_rows($result_status)>0){
        $tmp_status = $adb->query_result($result_status,0,'status');
    }
    $smarty=new lingdangCRM_Smarty;
    $_REQUEST['diony']='diony';
    $smarty->assign('LAYOUTBLOCKARRAY',$layoutblockarray);
    $smarty->assign('ID',$_REQUEST['record']);
    $smarty->assign('STATUS',$tmp_status);
    $str=$smarty->fetch("modules/Questionnaire/QuestionnaireBlockContent.tpl");

    $arr['layoutblockarray'] = $layoutblockarray;
    $arr['content']=$str;
    ConvertTojsonString(1,$arr,"success");
}
//保存题目
function addTopic(){
    global $adb, $currentModule;
    $focus = CRMEntity::getInstance($currentModule);
    $focus->id = $_REQUEST['record'];
    $topic_array = ldcrm_json_decode($_REQUEST['topic_json']);
    $new_topic_array = $focus->saveTopic($_REQUEST['blockid'],$topic_array);
    $arr['topic_array'] = ldcrm_json_encode($new_topic_array);
    $arr['topicid'] = $new_topic_array['topic_id'];
    ConvertTojsonString(1,$arr,"success");
}
//删除题目
function deleteTopic(){
    global $adb,$currentModule;
    $topicid = $_REQUEST['topicid'];
    $focus = CRMEntity::getInstance($currentModule);
    $focus->delect_topic($topicid);
    ConvertTojsonString(1,'',"success");
}
//修改题目顺序
function changeTopicOrder(){
    global $currentModule;
    $topicid = $_REQUEST['topicid'];
    $changeid = $_REQUEST['changeid'];
    $focus = CRMEntity::getInstance($currentModule);
    $focus->Change_Topic_Order($topicid,$changeid);
    ConvertTojsonString(1,'',"success");
}
//获取问卷填写详情
function getChartsaveDetail(){
    global $adb,$currentModule;
    $chartsaveid = $_REQUEST['chartsaveid'];
    $questionnaireid = $_REQUEST['questionnaireid'];
    $focus = CRMEntity::getInstance($currentModule);
    $smarty = new lingdangCRM_Smarty;
    $bloackarray = $focus->getLayoutBlock($questionnaireid);

    $chart_array = [];
    if($chartsaveid > 0){
        $chart_array = $focus->getChartsaveDetail($chartsaveid,$bloackarray);
    }

    //获取题目
    $data = [];
    $query = "SELECT questionnaireid,questionnaire_no,`name`,description,recovery_endremarks FROM ld_questionnaire WHERE questionnaireid = ? and deleted = 0";
    $params = array($questionnaireid);
    $result = $adb->pquery($query, $params);
    if($adb->num_rows($result) >= 1)
    {
        $questionnaire_no = $adb->query_result($result,0,"questionnaire_no");
        $name = $adb->query_result($result,0,"name");
        $description = $adb->query_result($result,0,"description");
        $recovery_endremarks = $adb->query_result($result,0,"recovery_endremarks");

        $data['record'] = $questionnaireid;
        $data['questionnaire_no'] = $questionnaire_no;
        $data['name'] = $name;
        $data['description'] = $description;
        $data['recovery_endremarks'] = $recovery_endremarks;
    }
    if(empty($chart_array)){
        $data['blockinfo'] = $bloackarray;
    }else{
        $data['blockinfo'] = $chart_array;
    }


    $smarty->assign('record',$questionnaireid);
    $smarty->assign('questionnaire_no',$questionnaire_no);
    $smarty->assign('name',$name);
    $smarty->assign('description',$description);
    $smarty->assign('recovery_endremarks',$recovery_endremarks);

    $smarty->assign('data',$data);
    $smarty->assign('datajson',ldcrm_json_encode($data));
    $smarty->caching = false;
    $str = $smarty->fetch('modules/Questionnaire/Chartsave_DetaiView.tpl');

    $_REQUEST['diony']='diony';
    $arr['title'] = getFixedLabel('QuestionnaireChartsave');
    $arr['canceltext']=getFixedLabel("CANCEL");
    $arr['content']=$str;
    ConvertTojsonString(1,$arr,"success");
}
?>