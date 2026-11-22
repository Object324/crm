<?php
//editor:gyq_109 reason:日程管理模块  2019/4/29 16:55
crm_load_class_file('cls_ListViewWX', 'WeiXinApp/list');

class cls_Calendar_ListViewWX extends cls_ListViewWX
{
    //editor:gyq_20191118 reason:当前选中的日程  ID1000646
    protected $chooseDay = false;

    public function setFilterRequest()
    {
        //reason:tab_page  区分日程管理序时簿两个标签页:me 我的 \ list其他人的日程
        if ($_REQUEST['tab_page'] == 'me') {
            global $current_user;
            $_REQUEST['filter']['SearchScope'] = 'smowner_search_senior';
            $_REQUEST['filter']['senioruserid'] = $current_user->id;
            $this->chooseDay = $_REQUEST['filter']['lastmodified'];
            unset($_REQUEST['filter']['lastmodified']);
        }
        parent::setFilterRequest();
    }

    //editor:gyq_20191118 reason:日期搜索修改  ID1000646
    public function get_page_query($showtype, $isSingle)
    {
        $sql = parent::get_page_query($showtype, $isSingle);
        if ($this->chooseDay) {
            $readDay = date('Y-m-d', strtotime($this->chooseDay));
            $sql .= '
            and ((' . $this->focus->table_name . '.date_start like \'' . $readDay . '%\' or ' . $this->focus->table_name . '.due_date like \'' . $readDay . '%\') or (
            DATE_FORMAT(' . $this->focus->table_name . '.date_start,\'%Y-%m-%d\')  < \'' . $readDay . '\'
            and DATE_FORMAT(' . $this->focus->table_name . '.due_date,\'%Y-%m-%d\')  > \'' . $readDay . '\'))';
        }
        return $sql;
    }

    //me标签页，不需要复杂的序时簿格式化
    public function getListViewEntries($adb, $list_result, $approvestatus)
    {
        if ($_REQUEST['tab_page'] == 'me') {
            crm_load_class_file('cls_StaticCommonFun', 'WeiXinApp/WeiXin_common');
            $num_rows = $adb->num_rows($list_result);
            $detail_value = array();
            $baseTable = $this->focus->table_name;
            $moduleTableIndexList = $this->focus->tab_name_index;
            $baseTableIndex = $moduleTableIndexList[$baseTable];
            $real_i = 0;
            $calendar_arr=$adb->query_result_all($list_result);

            //解析循环日程
            if ($this->chooseDay) {
                $startdate = date("Y-m-d",strtotime($this->chooseDay));//2024-04-17
                $enddate = $startdate." 23:59:59";
                $loop_calendar_arr = $this->getLoopCalendarRemindSources($startdate,$enddate);
            }
            $loop_calendar_arr = array_merge($loop_calendar_arr,$calendar_arr);
            foreach ($loop_calendar_arr as $item) {
                $recordId = $item[$baseTableIndex];
                $ac_subject = isset($item['ac_subject'])?$item['ac_subject']:$item['subject'];
                $ac_start = isset($item['ac_start'])?$item['ac_start']:$item['date_start'];
                $ac_end = isset($item['ac_end'])?$item['ac_end']:$item['due_date'];
                $time_range = date('H:i', strtotime($ac_start)) . ' - ' . date('H:i', strtotime($ac_end));
                $detail_value[$recordId]['loop_calendar'] = $item['loop_calendar'];
                $detail_value[$recordId]['curid'] = $recordId;
                $detail_value[$recordId]['title'] = $ac_subject;
                $detail_value[$recordId]['module'] = 'Calendar';
                $detail_value[$recordId]['field'][0] = $time_range;
            }

            //额外增加的SQL $parent_colum .= ',ld_activity.subject ac_subject,ld_activity.date_start ac_start,ld_activity.due_date ac_end';
            /*for ($i = 0; $i < $num_rows; $i++) {
                $recordId = $adb->query_result($list_result, $i, $baseTableIndex);
                $ac_subject = $adb->query_result($list_result, $i, 'ac_subject');
                $ac_start = $adb->query_result($list_result, $i, "ac_start");
                $ac_end = $adb->query_result($list_result, $i, "ac_end");
                $time_range = date('H:i', strtotime($ac_start)) . ' - ' . date('H:i', strtotime($ac_end));
                $detail_value[$real_i]['curid'] = $recordId;
                $detail_value[$real_i]['title'] = $ac_subject;
                $detail_value[$real_i]['module'] = 'Calendar';
                $detail_value[$real_i]['field'][0] = $time_range;
                $real_i++;
            }*/
            $list1_complex = $detail_value;
            //ｚｘｍ　２０２１－０７０５　获取选择日期的 我的提醒数据
            $remindList = $this->getRemindsList();
            $list1_complex = array_merge($list1_complex,$remindList);
            $this->jsonArr['yan_shi'] = array(
                array('value' => 60 * 60, 'label' => '1小时之后'),
                array('value' => 3 * 60 * 60, 'label' => '3小时之后'),
                array('value' => 24 * 60 * 60, 'label' => '明天'),
                array('value' => 2 * 24 * 60 * 60, 'label' => '后天'),
                array('value' => 7 * 24 * 60 * 60, 'label' => '7天之后')
            );
            $this->jsonArr['written_days'] = $this->getEventSources();
        } else {
            crm_load_class_file('QueryGenerator_FunctionsMC', 'appCommon/include/QueryGenerator');
            $QFN = new QueryGenerator_FunctionsMC();
            $list1_complex = $QFN->getListViewEntries($this->focus, $this->module, $list_result, null);
        }

        return $list1_complex;
    }
    //editor:gyq_20191118 reason:已写日程的日历日期下方增加一个小红点，作为已写日程提示 ID1000646
    //获取日程管理范围数据,参考自modules\Calendar\getEventSources.php
    public function getEventSources()
    {
        global $adb;
        global $current_user;
        $choosemonth = date('Y-m', strtotime($_REQUEST['choosemonth']));
//36690: （1.6）日程管理：别人共享的日程在日历视图中看不到，列表中能看到。（需要补丁）
        $sql = 'select ld_users.usercolor,ld_users.last_name,ld_activity.`subject`,ld_activity.`eventstatus`,ld_activity.activityid,
      ld_activity.date_start,ld_activity.due_date,ld_account.accountname,ld_contactdetails.lastname,ld_contactdetails.mobile 
      from ld_activity LEFT JOIN ld_account on ld_activity.accountid=ld_account.accountid
      LEFT JOIN ld_contactdetails on ld_activity.contactid=ld_contactdetails.contactid
      left join ld_users on ld_users.id=ld_activity.smownerid  
      where ld_activity.deleted=0 and ld_activity.activitytype<>"Emails" and ld_activity.smownerid =? and  (ld_activity.date_start like ? or ld_activity.due_date like ? )  ';
        $sql .= " order by ld_activity.date_start asc";
        $result = $adb->pquery($sql, array($current_user->id, $choosemonth . '%', $choosemonth . '%'));

        $dayList = array();
        $oneDay = 24 * 60 * 60;
        $rows = $adb->num_rows($result);
        for ($i = 0; $i < $rows; $i++) {
            $date_start = $adb->query_result($result, $i, 'date_start');
            $due_date = $adb->query_result($result, $i, 'due_date');
            //0038612: （kfbcrm）移动端，日程管理，开始日期跨年后，已写日程的日期下方没有显示小灰点
            $startDay = strtotime(date('Y-m-d', strtotime($date_start)) . ' 00:00:00');
            $endDay = strtotime(date('Y-m-d', strtotime($due_date)) . ' 00:00:00');
            $betweenDays = ((int)$endDay - (int)$startDay) / $oneDay;
            for ($j = 0; $j <= $betweenDays; $j++) {
                $cellDayTime = strtotime($date_start) + $oneDay * $j;
                if (date('Y-m', $cellDayTime) == $choosemonth) {
                    $dayList[(int)date('d', $cellDayTime)] = 1;
                }
            }
        }

        $remindDays = $this->getRemindSources();
        $dayList = array_unique(array_merge(array_keys($dayList),$remindDays));
        $finalList = implode(',', $dayList);

        ////ls 20240412 XUQIU1002280  优化日程界面及其设置循环日程功能（解析循环日程(因为想和列表视图下日程做区分，故分开)）
        $startdate = date('Y-m-d', strtotime($choosemonth));
        $enddate = date('Y-m-t', strtotime($choosemonth));
        $enddate = date('Y-m-d', strtotime($enddate . " +1 day"));
        $loop_calendar_arr = $this->getLoopCalendarRemindDays($startdate,$enddate);
//        $calendar_arr = array_merge($calendar_arr,$loop_calendar_arr);//合并列表视图数据及解析出来的循环数据

        $loopdayList = [];
        foreach ($loop_calendar_arr as $item){
            $tmp_loopday = (int)date('d', strtotime($item['date_start']));
            if (in_array($tmp_loopday,$dayList)) continue;
            $loopdayList[] = $tmp_loopday;
        }
        $this->jsonArr['written_loopdays'] = implode(',', array_unique($loopdayList));

        return $finalList;
    }

    //ｚｘｍ　２０２１－０７０５　获取选择日期的 我的提醒数据
    public function getRemindsList(){
        global $adb;
        global $current_user;
        $remindTypeArr = $this->getRemindTypeArr();
        $remindList = [];

        if(!empty($remindTypeArr)){
            $remindTypeArr = implode('","',$remindTypeArr);
            $remindTypeArr = '"'.$remindTypeArr.'"';
            $day = $this->chooseDay;
            $day = date('Y-m-d',strtotime($day));
            $remindSql = "SELECT content,date_time,related_to,reltab FROM
        ld_reminds
    WHERE
        deleted = 0
    AND recieverid = $current_user->id
    AND is_del_rec = 0 and date_time like '$day%'
    AND remindstype in ($remindTypeArr) and status_rmd ='未读'
    AND remindsid > 0";
            $remindRes = $adb->pquery($remindSql);
            $remindNums = $adb->num_rows($remindRes);
            if($remindNums>0) {
                for ($j = 0; $j < $remindNums; $j++) {
                    $date_time = $adb->query_result($remindRes, $j, 'date_time');
                    $remindList[$j]['title'] = $adb->query_result($remindRes, $j, 'content');
                    $remindList[$j]['field'][0] = $date_time;
                    $remindList[$j]['curid'] = $adb->query_result($remindRes, $j, 'related_to');
                    $remindList[$j]['module'] = $adb->query_result($remindRes, $j, 'reltab');
                }
            }
        }
        return $remindList;
    }
    /**
     * zxm  2021-07-05 日历增加消息提醒设置　查询提醒
     *获取提醒列表  跟进记录提醒、服务合同、合同订单、收款计划、付款计划
     */
    public function getRemindSources(){
        global $adb;
        global $current_user;
        $remindTypeArr = $this->getRemindTypeArr();
        $choosemonth = date('Y-m', strtotime($_REQUEST['choosemonth']));
        $remindDays = [];
        if(!empty($remindTypeArr)) {
            $remindTypeArr = implode('","', $remindTypeArr);
            $remindTypeArr = '"' . $remindTypeArr . '"';
            $remindSql = "SELECT DATE_FORMAT(date_time,'%d') AS `date` FROM
        ld_reminds
    WHERE
        deleted = 0
    AND recieverid = $current_user->id
    AND is_del_rec = 0
    AND remindstype in ($remindTypeArr) and status_rmd ='未读' and date_time like '$choosemonth%'
    AND remindsid > 0";
            $remindRes = $adb->pquery($remindSql);
            $remindNums = $adb->num_rows($remindRes);
            if ($remindNums > 0) {
                for ($j = 0; $j < $remindNums; $j++) {
                    $date = $adb->query_result($remindRes, $j, 'date');
                    $remindDays[] = str_replace ("0", "", $date);
                }
            }
        }
        return $remindDays;
    }

    /**
     * @return array
     * 获取提醒类型数组
     */
    public function  getRemindTypeArr()
    {
        global $adb;
        global $current_user;
        //zxm 2021-07-01 日历增加消息提醒设置　查询提醒
        $remindArr = [
            'ContactRecordsRemind'=>['remindType'=>'ContactRecordsDate','deploy_type'=>10,'module'=>'ContactRecords'],//跟进记录提醒
            'SalesOrderRemind'=>['remindType'=>'SalesOrderDueDate','deploy_type'=>11,'module'=>'SalesOrder'],//交付日期提醒
            'ServiceContractsRemind'=>['remindType'=>'ServiceContractsDueDate','deploy_type'=>12,'module'=>'ServiceContracts'],//服务到期日提醒
            'PaymentPlanRemind'=>['remindType'=>'PaymentPlanPlanDate','deploy_type'=>13,'module'=>'PaymentPlan'],//计划收款日期提醒
            'SendPaymentRemind'=>['remindType'=>'SendPaymentPlanDate','deploy_type'=>14,'module'=>'SendPayment'],//计划付款日期提醒
        ];
        // 先查询是否有不需要显示的提醒
        $appsystemSql = "select deploy_type from ld_appsystem where userid=".$current_user->id." and deploy_type in (10,11,12,13,14) and is_open='no'";
        $appsystemRes = $adb->pquery($appsystemSql);
        $nums = $adb->num_rows($appsystemRes);
        $deployTypeArr = [];
        if($nums>0){
            for($i=0;$i<$nums;$i++){
                $deployTypeArr[] = $adb->query_result($appsystemRes,$i,'deploy_type');
            }
        }
        $remindTypeArr = [];
        foreach($remindArr as $k=>$v){
            if(!in_array($v['deploy_type'],$deployTypeArr)&&vtlib_isModuleActive($v['module'])){
                $remindTypeArr[] = $v['remindType'];
            }
        }
        return $remindTypeArr;
    }

    //点击某一天显示具体日程信息
    public function getLoopCalendarRemindSources($startdate,$enddate){
        global $adb,$current_user;
        require_once(globalStatic::$root_directory . 'include/Calendar/CalendarDisplayContent.php');
        $calendarBolSql=new CalendarDisplayContent('calendar','');

        $loop_sql = 'select ld_activity.`subject`,ld_activity.date_start,ld_activity.due_date,ld_activity.smownerid,ld_activity.activitytype,ld_activity.activityid,"yes" as loop_calendar
,ld_loopcalendar_reminds.loop_type,ld_loopcalendar_reminds.loop_month,ld_loopcalendar_reminds.loop_dayvalue,ld_loopcalendar_reminds.reminder_setting,ld_loopcalendar_reminds.expiredate
      from ld_activity  
      INNER JOIN ld_loopcalendar_reminds ON ld_loopcalendar_reminds.activityid = ld_activity.activityid
      where ld_activity.deleted=0 and ld_activity.activitytype<>"Emails" AND ld_activity.eventstatus <> "已执行" and ld_activity.smownerid =? 
        AND ifnull(ld_loopcalendar_reminds.loop_type, "norepeat") <> "norepeat"
AND ld_activity.date_start <= ?
AND (
	ifnull(ld_loopcalendar_reminds.expiredate, "") = ""
	OR ld_loopcalendar_reminds.expiredate >= ?
)  order by date_start asc ';
        $loop_result=$adb->pquery($loop_sql,array($current_user->id,$enddate,$startdate));
        $loop_calendar_arr=$calendarBolSql->getLoopPendingData($loop_result,$startdate,$enddate);


        return $loop_calendar_arr;
    }
    //哪些日期下面有小灰点
    public function getLoopCalendarRemindDays($startdate,$enddate){
        global $adb,$current_user;
        require_once(globalStatic::$root_directory . 'include/Calendar/CalendarDisplayContent.php');
        $calendarBolSql=new CalendarDisplayContent('calendar','');

        $loop_sql = 'select ld_users.usercolor,ld_users.last_name,ld_activity.`subject`,ld_activity.`eventstatus`,ld_activity.activityid,
      ld_activity.date_start,ld_activity.due_date,ld_account.accountname,ld_contactdetails.lastname,ld_contactdetails.mobile,"yes" as loop_calendar
,ld_loopcalendar_reminds.loop_type,ld_loopcalendar_reminds.loop_month,ld_loopcalendar_reminds.loop_dayvalue,ld_loopcalendar_reminds.reminder_setting,ld_loopcalendar_reminds.expiredate
      from ld_activity LEFT JOIN ld_account on ld_activity.accountid=ld_account.accountid
      LEFT JOIN ld_contactdetails on ld_activity.contactid=ld_contactdetails.contactid
      left join ld_users on ld_users.id=ld_activity.smownerid  
      INNER JOIN ld_loopcalendar_reminds ON ld_loopcalendar_reminds.activityid = ld_activity.activityid
      where ld_activity.deleted=0 and ld_activity.activitytype<>"Emails" AND ld_activity.eventstatus <> "已执行" and ld_activity.smownerid =? 
        AND ifnull(ld_loopcalendar_reminds.loop_type, "norepeat") <> "norepeat"
AND ld_activity.date_start <= ?
AND (
	ifnull(ld_loopcalendar_reminds.expiredate, "") = ""
	OR ld_loopcalendar_reminds.expiredate >= ?
)  order by date_start asc ';
        $loop_result=$adb->pquery($loop_sql,array($current_user->id,$enddate,$startdate));
        $loop_calendar_arr=$calendarBolSql->getLoopPendingData($loop_result,$startdate,$enddate);


        return $loop_calendar_arr;
    }
}
?>