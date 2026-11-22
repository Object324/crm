<?php
//editor:gyq_128 reason:允许用户替换微信绑定  2019/7/8 15:42 ID1000504
crm_load_class_file('login_model','WeiXinApp/modules/Users/login');
$Model = new login_model();
$se_action = $_REQUEST['second_action'];
switch ($_REQUEST['second_action']){
    case 'check_and_bind':
        $Model->check_and_bind();
        break;
    case 'replace_bind':
        $Model->replace_bind();
        break;
	case 'yunzhijia_bind':
        $Model->yunzhijia_bind();
        break;
    default:
        ConvertTojsonString(-1,null,'error:second_action missing！');
        break;
}