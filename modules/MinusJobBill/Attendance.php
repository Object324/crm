<?php

//考勤统计
crm_load_class_file('cls_OAAttendance','include/OA');
$obj=new cls_OAAttendance($_REQUEST['module'],$_REQUEST['id'],$_REQUEST['queryapprove']);
//echo $obj->ShowAttendance();
//exit();

//0041733: （https://61mis.com/kfbcrm/ [^]）加班单、请假单单据查看详情界面，点击更多中的“考勤统计”，界面变暗（弹出层样式已改好）
//新版弹窗
$data = $obj->ShowAttendance();
if(isset($_REQUEST['ajax']) && $_REQUEST['ajax'] == 'true'){
    echo $data;
    exit();
}


$smarty=new lingdangCRM_Smarty;
$_REQUEST['diony']='diony';

$data =  json_decode($data);
$smarty->assign('oatotalovertimetd',$data->oatotalovertime);
$smarty->assign('oatotaldaysofftd',$data->oatotaldaysoff);
$smarty->assign('oaremainingovertimetd',$data->oaremainingovertime);
$smarty->assign('oatotalannualleavetd',$data->oatotalannualleave);
$smarty->assign('oausedannualleavetd',$data->oausedannualleave);
$smarty->assign('oaremainingannualleavetd',$data->oaremainingannualleave);

$arr['title'] = getFixedLabel("VIEWADDJOBBILLHISTORY");
$str=$smarty->fetch("Attendance.tpl");
$arr['content'] = $str;
ConvertTojsonString(1,$arr,"success");
?>

