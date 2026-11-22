<?php

$root_dir=dirname( dirname(dirname(__FILE__)));
$root_dir.=DIRECTORY_SEPARATOR;
$root_directory=$root_dir;
include($root_directory.'includefile.php');
//require_once($root_directory.'Register/RegOp.php');
//require_once ($root_directory.'data/CRMEntity.php');
//require_once ($root_directory.'include/utils/CommonFun.php');
global $adb;
$_REQUEST['diony'] = 'diony';
$record = intval(vtlib_purify($_REQUEST['record']));
//$topicid = intval(vtlib_purify($_REQUEST['topicid']));
//$optionid = intval(vtlib_purify($_REQUEST['optionid']));
//$option_value = vtlib_purify($_REQUEST['option_value']);
//$userid = intval(vtlib_purify($_REQUEST['uid']));

$action = vtlib_purify($_REQUEST['action']);
if ($action == 'upview') {
    //判断是否暂停回收。
    $query = 'SELECT * FROM ld_questionnaire where questionnaireid = ? AND deleted = 0 LIMIT 1';
    $check_result = $adb->pquery($query,array($record));
    if ($adb->num_rows($check_result) > 0) {
        if ($adb->query_result($check_result,0,"status") == '暂停') {
            ConvertTojsonString(-1,array(),'问卷已暂停回收，提交将不记录数据');
        }
    }else{
//        ConvertTojsonString(-2,array(),'问卷已废弃'); //可不要这个判断
        ConvertTojsonString(-1,array(),'问卷已暂停回收，提交将不记录数据');
    }


    $query = 'UPDATE ld_questionnaire SET views = IFNULL(views,0)+1 WHERE questionnaireid = ? AND deleted = 0 AND status = \'正在回收\' ';
    $adb->pquery($query,array($record));
    ConvertTojsonString(1,array(),'浏览次数已更新');
}elseif ($action == 'save'){
    /*record: 40200
    one_29: 29,106,好
    more_30: 30,108,音乐
    more_30: 30,109,舞蹈
    text_31: 吃饭吧
    action: save*/

    //判断是否暂停回收。
    $query = 'SELECT * FROM ld_questionnaire where questionnaireid = ? AND deleted = 0 AND status = \'正在回收\'LIMIT 1';
    $check_result = $adb->pquery($query,array($record));
    if ($adb->num_rows($check_result) > 0) {
        //dump($_REQUEST);
        foreach ($_REQUEST as $key=>$val){
            if($val != null || $val != ""){
                $keyarr = explode('_',$key);
                if ($keyarr[0]=='SelectBillId' || $keyarr[0]=='tel') {
                    $sql = 'select id,ld_questionnaire_topic.topic_name from ld_questionnaire_chart LEFT JOIN ld_questionnaire_topic on ld_questionnaire_chart.topicid = ld_questionnaire_topic.topicid where ld_questionnaire_chart.topicid = ? and ld_questionnaire_topic.fieldonly = 1 and ld_questionnaire_chart.option_value =? ';
                    $only_result = $adb->pquery($sql,array($keyarr[1],$val));
                    if($adb->num_rows($only_result) > 0){
                        $topicname = $adb->query_result($only_result,0,"topic_name");
                        ConvertTojsonString(-2,array(),'问题“'.$topicname.'”不允许重复选择相同单据');
                    }
                }
                if($keyarr[0]=='tel'){
                    $sql_telregexp = 'select topic_name,telregexp from ld_questionnaire_topic where topicid = ?';
                    $result_telregexp = $adb->pquery($sql_telregexp,array($keyarr[1]));
                    if($adb->num_rows($result_telregexp) > 0){
                        if($adb->query_result($result_telregexp,0,"telregexp") == 'yes'){
                            $regexp_phone = "/^1[345789]\d{9}$/";
                            if(preg_match($regexp_phone,$val)){

                            }else{
                                $topicname = $adb->query_result($result_telregexp,0,"topic_name");
                                ConvertTojsonString(-2,array(),'问题“'.$topicname.'”手机号码格式不正确，请输入正确的手机号码格式');
                            }
                        }
                    }
                }
            }
        }
        //更新回收量
        $query = 'UPDATE ld_questionnaire SET recoverys = IFNULL(recoverys,0)+1 where questionnaireid = ? AND deleted = 0 AND status = \'正在回收\'';
        $adb->pquery($query,array($record));

        $createdtime = date('Y-m-d H:i:s');
        $sql='select  current_timestamp(6) as seqtime ';
        $tmpresult=$adb->pquery($sql,array());
        
        $seqtime=$adb->query_result($tmpresult,0,'seqtime');

        $save_sql = 'INSERT INTO ld_questionnaire_chartsave(`questionnaireid`,`createdtime`,`seqtime`) VALUES (?,?,?);';
        $save_result=$adb->pquery($save_sql,array($record,$createdtime,$seqtime));
        $chartsaveid = $adb->getLastInsertID();
        
        $sql = 'INSERT INTO ld_questionnaire_chart(`topicid`,`optionid`,`option_value`,`createdtime`,seqtime,chartsaveid) VALUES (?,?,?,?,?,?);';
        $insertIds = array();
        foreach ($_REQUEST as $key=>$val){
            if($val != null || $val != ""){
                $keyarr = explode('_',$key);
                if (in_array($keyarr[0], array('one','more','text','Singleline','Multiline','SelectBillId','tel'))) {
                    if (in_array($keyarr[0], array('text','Singleline','Multiline','SelectBillId','tel'))) {
                        $topicid = $keyarr[1];
                        $optionid = 0;
                        $option_value = $val;
                        $adb->pquery($sql,array($topicid,$optionid,$option_value,$createdtime,$seqtime,$chartsaveid));
                        
                    }elseif($keyarr[0] == 'one'){
                        $valarr = explode(',',$val);
    
                        $topicid = $valarr[0];
                        $optionid = $valarr[1];
                        $option_value = $valarr[2];
                        $adb->pquery($sql,array($topicid,$optionid,$option_value,$createdtime,$seqtime,$chartsaveid));
                        //array_push($insertIds, $adb->getLastInsertID());
                    }else{
                        foreach ($val as $no => $more){
                            $valarr = explode(',',$more);
                            $topicid = $valarr[0];
                            $optionid = $valarr[1];
                            $option_value = $valarr[2];
                            $adb->pquery($sql,array($topicid,$optionid,$option_value,$createdtime,$seqtime,$chartsaveid));
                            //array_push($insertIds, $adb->getLastInsertID());
                        }
                    }
                    array_push($insertIds, $adb->getLastInsertID());
                }
            }
        }
        ConvertTojsonString(1,$insertIds,'提交数据处理完成');

    }else{
        ConvertTojsonString(-1,array(),'fail');
    }


}

