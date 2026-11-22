<?php
global $adb,$current_user,$currentModule;

$record = $_REQUEST['workflow']['record'];
$module = $_REQUEST['workflow']['module'];
$pagemode = $_REQUEST['workflow']['pagemode'];
$pagemode_extra = $_REQUEST['workflow']['pagemode_extra'];


crm_load_class_file("cls_savereverse",'include/SaveReverse');

$workflowreverseobj=cls_savereverse::getInstance($module);
$workflowreverseobj->setRecord($record);
$beforefieldvalue_arr = $_REQUEST['workflow']['before_save_infos'];
$afterfieldvalue_arr = $_REQUEST['workflow']['after_save_infos'];
$workflowreverseobj->setNotCallActionType(array("UpdateFields","ExcuteSql","AutoShare"));
if(!empty($pagemode_extra)){
    //edit:duan date:2024/10/15 reason:如果通过推进进入编辑保存，则需要额外触发推进的工作流程
    $pagemode_arr = explode(',',$pagemode_extra);
    $result_arr = [];

    foreach ($pagemode_arr as $tmp_pagemode){
        $workflowreverseobj->setPageMode($tmp_pagemode);
        $workflowreverseobj->getStartComputer($beforefieldvalue_arr,$afterfieldvalue_arr,$tmp_pagemode);
        $result_arr = array_merge($result_arr,$workflowreverseobj->getExecResultData());
    }
    $callapimsg_arr = $result_arr;
}else{
    $workflowreverseobj->getStartComputer($beforefieldvalue_arr,$afterfieldvalue_arr,$pagemode);
    $callapimsg_arr = $workflowreverseobj->getExecResultData();
}

if (is_array($callapimsg_arr) && count($callapimsg_arr)>0) {
    $content = implode('<br>',$callapimsg_arr);
}else{
    $content = getFixedLabel('NOCONTENT');
}




$arr['content'] = '<div id="pop_remind_content" class="pop_remind_content"><div class="pop_prc_content">'.$content.'</div></div>';
$arr['mobcontent'] = $content;
ConvertTojsonString(1,$arr,"success");
     

?>