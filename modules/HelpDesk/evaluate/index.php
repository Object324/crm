<?php
//editor:gyq_127 reason:服务小程序增加评价  2019/6/24 17:30
crm_load_class_file('evaluate_model','modules/HelpDesk/evaluate');
$Model = new evaluate_model();
if(isset($_REQUEST['second_action'])){
    $se_action = $_REQUEST['second_action'];
    $Model->$se_action();
}