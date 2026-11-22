<?php
//-- todo -- 翻译没写
global $adb;
global $current_user;
$smarty = new lingdangCRM_Smarty();
$_REQUEST['diony'] = 'yes';
$mode = $_REQUEST['mode'];
$option = $_REQUEST['option'];
$smarty->assign('option',$option);
//提醒设置数组
$remindArr = [
    'ContactRecordsRemind'=>['name'=>getFixedLabel('ContactRecordsRemind'),'deploy_type'=>10,'is_open'=>'yes','module'=>'ContactRecords','description'=>''],//跟进记录提醒
    'SalesOrderRemind'=>['name'=>getFixedLabel('SalesOrderRemind'),'deploy_type'=>11,'is_open'=>'yes','module'=>'SalesOrder','description'=>''],//交付日期提醒
    'ServiceContractsRemind'=>['name'=>getFixedLabel('ServiceContractsRemind'),'deploy_type'=>12,'is_open'=>'yes','module'=>'ServiceContracts','description'=>''],//服务到期日提醒
    'PaymentPlanRemind'=>['name'=>getFixedLabel('PaymentPlanRemind'),'deploy_type'=>13,'is_open'=>'yes','module'=>'PaymentPlan','description'=>''],//计划收款日期提醒
    'SendPaymentRemind'=>['name'=>getFixedLabel('SendPaymentRemind'),'deploy_type'=>14,'is_open'=>'yes','module'=>'SendPayment','description'=>''],//计划付款日期提醒
];

//将模块关闭的值去掉
foreach($remindArr as $key=>$val){
    if(!vtlib_isModuleActive($val['module'])){
        unset($remindArr[$key]);
    }
}

if($mode=="save"){
    if ($option == 'notice'){
        //先删除数据
        $deleteSql = "delete from ld_appsystem where deploy_type in (10,11,12,13,14) and  userid=".$current_user->id;
        $adb->pquery($deleteSql);
        //保存数据
        $params = $_REQUEST;
        foreach($remindArr as $k=>$v){
            if($params[$k]=='no'){
                $insertValue = [
                    $current_user->id,
                    0,
                    $v['deploy_type'],
                    $v['description'],
                    'no',
                    $k,
                    0,
                    $v['module']
                ];
                //才需要存储数据
                $insertSql = "insert into ld_appsystem (userid,deploy_value,deploy_type,description,is_open,`name`,`sequence`,`module`) values (?,?,?,?,?,?,?,?)";
                $adb->pquery($insertSql,$insertValue);
            }
        }
    }
    elseif ($option == 'default'){
        $default_value_arr=array('CalendarDefaultDisplay'=>$_REQUEST['default_display'],
            'CalendarDefaultStartTime'=>$_REQUEST['default_start_time'],
            'CalendarDefaultStartSlot'=>$_REQUEST['default_time_slot']);
        foreach ($default_value_arr as $label => $content){
            setUsersettingByLabel('Calendar',1,$label,$content);
        }
    }
    elseif ($option == 'color'){
        $status=$_REQUEST['status'];
        setUsersettingByLabel('Calendar',1,'CalendarCustomColorStatus',$status);
    }
    elseif ($option == 'field'){// ljj 20240125 XUQIU1002448 日程管理->日历视图，可自定义显示字段（陈钦帅）
        $content=$_REQUEST['content'];
        setUsersettingByLabel('Calendar',1,'CustomDisplayContent',$content);
    }
    $arr = [];
}
elseif($mode == 'list'){
    if ($option == 'notice'){//消息通知
        $arr['title']=getFixedLabel('MessageNotificationSettings');
        //ld_appsystem从表中查询设置数据 查询为no的
        $appsystemSql = "select * from ld_appsystem where userid=? and deploy_type in (10,11,12,13,14) and is_open=?";
        $appsystemRes = $adb->pquery($appsystemSql,array($current_user->id,'no'));
        $nums = $adb->num_rows($appsystemRes);
        if($nums>0){
            for($i=0;$i<$nums;$i++){
                $is_open = $adb->query_result($appsystemRes,$i,'is_open');
                $name = $adb->query_result($appsystemRes,$i,'name');
                //开启的模块 才显示在设置里
                if(is_array($remindArr) && array_key_exists($name,$remindArr)){
                    $remindArr[$name]['is_open'] = $is_open;
                }
            }
        }
        $smarty->assign('remindSetArr',$remindArr);
    }
    elseif ($option == 'default'){
        $language=getLanguageType($current_user);
        //日历设置-基本信息-默认值设置
        $arr['title']=getFixedLabel('DefaultValueSettings');
        $defaultDisplay_arr=array('month'=>['label'=>getFixedLabel('nMonth'),'selected'=>''],
            'week'=>['label'=>getFixedLabel('Week'),'selected'=>''],
            'day'=>['label'=>getFixedLabel('Day'),'selected'=>'']);
        $defaultStartTime_arr=array('06:00:00'=>['label'=>'6点','selected'=>''],
            '07:00:00'=>['label'=>'7'.getFixedLabel('OCLOCK'),'selected'=>''],
            '08:00:00'=>['label'=>'8'.getFixedLabel('OCLOCK'),'selected'=>''],
            '09:00:00'=>['label'=>'9'.getFixedLabel('OCLOCK'),'selected'=>''],
            '10:00:00'=>['label'=>'10'.getFixedLabel('OCLOCK'),'selected'=>'']);
        $defaultTimeSlot_arr=array('00:01:00'=>['label'=>'1'.getFixedLabel('minutes'),'selected'=>''],
            '00:05:00'=>['label'=>'5'.getFixedLabel('minutes'),'selected'=>''],
            '00:10:00'=>['label'=>'10'.getFixedLabel('minutes'),'selected'=>''],
            '00:15:00'=>['label'=>'15'.getFixedLabel('minutes'),'selected'=>''],
            '00:20:00'=>['label'=>'20'.getFixedLabel('minutes'),'selected'=>''],
            '00:30:00'=>['label'=>'30'.getFixedLabel('minutes'),'selected'=>'']);
        $basic_info_arr=array('display'=>'CalendarDefaultDisplay','starttime'=>'CalendarDefaultStartTime','timetslot'=>'CalendarDefaultStartSlot');
        foreach ($basic_info_arr as $key =>$label){
            $content=getUsersettingByLabel('Calendar',1,$label);
            if ($key == 'display'){
                $content=(empty($content))?'month':$content;
                $defaultDisplay_arr[$content]['selected']='yes';
            }elseif ($key == 'starttime'){
                $content=(empty($content))?'06:00:00':$content;
                $defaultStartTime_arr[$content]['selected']='yes';
            }elseif ($key == 'timetslot'){
                $content=(empty($content))?'00:30:00':$content;
                $defaultTimeSlot_arr[$content]['selected']='yes';
            }
        }
        $smarty->assign("DEFAULTDISPLAYARR",$defaultDisplay_arr);
        $smarty->assign("DEFAULTSTARTTIMEARR",$defaultStartTime_arr);
        $smarty->assign("DEFAULTTIMESLOTARR",$defaultTimeSlot_arr);
    }
    elseif ($option == 'color'){
        $arr['title']=getFixedLabel('CustomColor');
        $customColorStatus=getUsersettingByLabel('Calendar',1,'CalendarCustomColorStatus');
        $smarty->assign("customColorStatus",$customColorStatus);
        $rulesInfoarr=getCustomColorRules();
        $smarty->assign("rulesInfoarr",$rulesInfoarr);
    }
    elseif ($option == 'field'){// ljj 20240125 XUQIU1002448 日程管理->日历视图，可自定义显示字段（陈钦帅）
        $arr['title']=getFixedLabel('CustomDisplayContent');
        $tablabel=getTranstab('Calendar');
        $smarty->assign("TABLABEL",$tablabel);
        $CustomDisplayContent=getUsersettingByLabel('Calendar',1,'CustomDisplayContent');
        if (empty($CustomDisplayContent)){
            $CustomDisplayContent = '[var.activity_subject_Calendar] [var.activity_account_id_Calendar]|[var.activity_contact_id_Calendar] [var.activity_assigned_user_id_Calendar]|[var.activity_eventstatus_Calendar]';
        }
        $arr['displaycontent']=$CustomDisplayContent;
        $smarty->assign("CONTENT",$CustomDisplayContent);
    }
    $arr['oktext']=getFixedLabel("SAVE");
    $arr['canceltext']=getFixedLabel("CANCEL");
    //D:\ldcrm\www\ldcrm\Smarty\templates\modules\Calendar\calendarRemindSet.tpl
    $arr['content'] = $smarty->fetch("modules/Calendar/calendarRemindSet.tpl");
}
ConvertTojsonString(1,$arr,'success');

function getCustomColorRules(){
    global $adb;
    $arr=[];
    $sql='select id,name,status,backgroundcolor,textcolor from ld_calendar_colorrule order by sequence';
    $result=$adb->pquery($sql,array());
    $num_row=$adb->num_rows($result);
    for ($i=0;$i<$num_row;$i++){
        $id=$adb->query_result($result,$i,'id');
        $name=$adb->query_result($result,$i,'name');
        $status=$adb->query_result($result,$i,'status');
        $backgroundcolor=$adb->query_result($result,$i,'backgroundcolor');
        $textcolor=$adb->query_result($result,$i,'textcolor');
        $arr[]=array('id'=>$id,'name'=>$name,'status'=>$status,'sequence'=>($i+1),'backgroundcolor'=>$backgroundcolor,'textcolor'=>$textcolor);
    }
    return $arr;
}


?>