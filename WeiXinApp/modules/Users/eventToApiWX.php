<?php
//editor:gyq_71 reason:外部联系人2.0 2018/6/20 11:27
error_reporting(E_ALL ^ E_NOTICE ^ E_WARNING);
header('Content-Type:text/html;charset=UTF-8');
include_once(globalStatic::$root_directory . 'WeiXinApp/lib/EventToApiModel.php');
$o_event_api = new EventToApiModel();
switch ($_REQUEST['method']) {
        //通讯录选人,按部门选择，返回部门内的成员ID
    case 'get_department_detail';
        $o_event_api->get_department_detail($_REQUEST['departid']);
        break;
        //外部联系人选择界面，提供前端config四个参数
    case 'select_external_contact';
        $o_event_api->select_external_contact();
        break;
        //获取外部联系人详情
    case 'get_external_contact';
        $o_event_api->get_external_contact($_REQUEST['userids']);
        break;
}






