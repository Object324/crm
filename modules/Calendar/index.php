<?php
/*
global $theme;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";

//$cal_log = LoggerManager::getLogger('calendar');
global $mod_strings;
require_once(globalStatic::$root_directory.'modules/Calendar/RenderRelatedListUI.php');
include ('modules/Calendar/new_calendar.php');
*/
if($_REQUEST['ajaxtype']=='ld_linkmodulecustom')
{
    require_once (globalStatic::$root_directory.'modules/lingdang/ListView.php');
    exit();
}
global $current_user,$currentModule,$adb;
//XUQIU20240126-01 日程管理--可以按用户记住上一次进入的页签
$logtype = getUsersettingByLabel($currentModule,$current_user->id,'CALENDARLOGTYPE');
if(isset($_REQUEST['calendar_logtype'])&&$_REQUEST['calendar_logtype'] != ''){
    $calendar_logtype = $_REQUEST['calendar_logtype'];
}else if(!empty($logtype)){
    $calendar_logtype = $logtype;
}else{
    $calendar_logtype = 'CalendarView';
}
setUsersettingByLabel($currentModule,$current_user->id,'CALENDARLOGTYPE', $calendar_logtype);
if ($calendar_logtype == 'ListView'){//0是视图 1是列表
    require_once('modules/Calendar/ListView.php');
    die;
}
$smarty=new lingdangCRM_Smarty();

$customView = CustomView::getInstance($currentModule);
$queryGenerator = new QueryGenerator($currentModule, $current_user,$customView);
$controller = new ListViewController($adb, $current_user, $queryGenerator);
$fieldnames = $controller->getAdvancedSearchOptionString();
$smarty->assign("FIELDNAMES", $fieldnames);

//0040797: 主页列表左侧 panel 中的calendar>修改年 月 日 以及所有显示的日期时间为英文格式 zxm 2021-0107
$languageType= getLanguageType($current_user);
$smarty->assign("LANUGAGETYPE",$languageType);
$smarty->assign('MODULE', $currentModule);
//hzx 20231215 列表页面页签优化
$Navbarlist = [
    array(
        'value'=>0,
        'label'=>getFixedLabel('CALENDARVIEW')
    ),
    array(
        'value'=>1,
        'label'=>getFixedLabel('LISTVIEW')
    )
];
$smarty->assign('ListViewNavbarcur',0);
$smarty->assign('ListViewNavbarlist',json_encode($Navbarlist));
/*
 * editor:ljj
 * time:20231226
 * reason:XUQIU1002423
 * content:日历视图界面，“消息提醒显示设置”修改为“日历设置”，可自定义日周月默认值及默认时间（陈钦帅）
 * node:日历显示
 * */
// $calendarSettings_arr=[array('label'=>getFixedLabel('MessageNotificationSettings'),'value'=>'notice')];
$smarty->assign("is_admin",is_admin($current_user));
if (is_admin($current_user)){//只有管理员有 默认值设置
    $calendarSettings_arr=[array('label'=>getFixedLabel('DefaultValueSettings'),'value'=>'default'),
        array('label'=>getFixedLabel('MessageNotificationSettings'),'value'=>'notice'),
        array('label'=>getFixedLabel('CustomColor'),'value'=>'color'),
        array('label'=>getFixedLabel('CustomDisplayContent'),'value'=>'field')
    ];
}else{
    //BUG20240716-53 ls 240716 消息通知设置是按照成员来的，普通成员可以设置自己的通知类型
    $calendarSettings_arr=[array('label'=>getFixedLabel('MessageNotificationSettings'),'value'=>'notice')];
}
$smarty->assign("calendarSettings",json_encode($calendarSettings_arr));
//日历设置-默认值数据
$default_value_arr=array('display'=>'CalendarDefaultDisplay','starttime'=>'CalendarDefaultStartTime','timeslot'=>'CalendarDefaultStartSlot');
$display_arr=array('month'=>'dayGridMonth','week'=>'timeGridWeek','day'=>'timeGridDay');
foreach ($default_value_arr as $key =>$label){
    $content=getUsersettingByLabel('Calendar',1,$label);
    if ($key == 'display'){//默认显示
        $defaultDisplay=(empty($content))?'dayGridMonth':$content;
        if (empty($content)){
            $defaultDisplay='dayGridMonth';
        }else{
            $defaultDisplay=$display_arr[$content];
        }
        $smarty->assign("DEFAULTDISPLAY",$defaultDisplay);
    }elseif ($key == 'starttime'){//默认起始时间点
        $defaultStartTime=(empty($content))?'08:00:00':$content;
        $smarty->assign("DEFAULTSTARTTIME",$defaultStartTime);
    }elseif ($key == 'timeslot'){//默认时间槽
        $defaultTimeSlot=(empty($content))?'00:20:00':$content;
        $smarty->assign("DEFAULTTIMESLOT",$defaultTimeSlot);
    }
}
Crm_load_class_file("CommonView","modules/CustomView");
$smarty->assign("DATETIMESTR",json_encode(CommonView::stdFilterDateTimeStr()));
if($_REQUEST['ajax']=='yes')
{

    //edit:can 2020-11-30 43479: （本地php72，8.3.2版本）工具-日程管理-日历视图（需要补丁）；在日历视图点开日程详情，编辑保存后，横栏相关信息点击没反应，关闭单据详情，点击列表视图也没反应；另外，日程详情，小编辑保存没反应
    $smarty->display("modules/Calendar/CalendarContent.tpl");
}
else

$smarty->display("modules/Calendar/Calendar.tpl");

?>