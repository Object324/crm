<?php

//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();

global $adb,$current_user;
$date = $_REQUEST['date'];
$date = str_replace("年","-",$date);
$date = str_replace("月","-",$date);
$start_date = $date . '01';
$ymd = explode('-',$date);
$month = $ymd[1];
$data['content'] = array();

/*$searchscopeobj=new ScopOfAuthority($adb,$module);
$searchscopeobj->getSmOwnerSearchSql();
if(empty())*/

$end_date = date('Y-m-d', strtotime("$start_date +1 month -1 day"));
//edit:can 20200824 42489: （https://61mis.com/kfbtest [^]）客户问题（长沙友捷），工作汇报，右侧【日程管理】目前可以看到所有人的单据。预期结果：应该只能看到自己负责的单据（需要补丁）
//edit:zhouxiaomei 2020-0910,日程管理某天的日程展示的bug问题，例如一个日程跨越三天只展示在开始日期，某天有多条数据只展示了一条等问题的修改
$cond_end = $end_date.' 23:59:59';//edit:zhouxiaomei 2020-0917 条件修改，日历最后一天的日程不显示了
$cond_start = $start_date.' 00:00:00';
$time_cod = " between '$cond_start' and '$cond_end' ";
//BUG20241021-42 ls 241024 不启用日程管理的“结束时间”字段,或者后启用"结束时间",可视为当天结束,正常日程结束时间必须大于开始时间
$query = "select `subject`,activityid,DATE_FORMAT(date_start,'%y/%m/%d') as date,DATE_FORMAT(CASE WHEN due_date>date_start THEN due_date ELSE date_start END,'%y/%m/%d') as date_finish,DATE_FORMAT(date_start,'%H:%i') as start_date,CASE WHEN due_date>date_start THEN DATE_FORMAT(due_date, '%H:%i') ELSE '23:59' END as end_date from ld_activity 
where smownerid = $current_user->id and (date_start $time_cod or due_date $time_cod) and deleted = 0 and `subject` != '' and activitytype <> 'emails' order by createdtime desc;
";
$result = $adb->pquery($query,array());
$num_rows = $adb->num_rows($result);
if($num_rows > 0){
	for($i = 0; $i < $num_rows; $i++){
		$activityid = $adb->query_result($result,$i,'activityid');
		$date_start_ymd = $adb->query_result($result,$i,'date');
        $date_start = explode('/',$date_start_ymd);
        $date_finish_ymd = $adb->query_result($result,$i,'date_finish');
        $date_finish = explode('/',$date_finish_ymd);
        if($date_start_ymd == $date_finish_ymd){
            $data['content'][(int)$date_start[2]][] = array(
                'activityid' => $activityid,
                'subject' => $adb->query_result($result,$i,'subject'),
                'start_date' => $adb->query_result($result,$i,'start_date'),
                'end_date' => $adb->query_result($result,$i,'end_date'),
            );
        }else{
            //edit:zhouxiaomei 2020-0910,日程管理某天的日程展示的bug问题，例如一个日程跨越三天只展示在开始日期，某天有多条数据只展示了一条等问题的修改
            if((int)$month != (int)$date_start[1]){
                $date_start[2] = 1;
            }

            if((int)$month != (int)$date_finish[1]){
                $date_finish[2] = explode('-',$end_date)[2];
            }
            //dump([$date_start[2],$date_finish[2]]);
            for($j=$date_start[2];$j<=$date_finish[2];$j++){
                $data['content'][(int)$j][] = array(
                    'activityid' => $activityid,
                    'subject' => $adb->query_result($result,$i,'subject'),
                    'start_date' => $date_start_ymd.' '. $adb->query_result($result,$i,'start_date'),
                    'end_date' => $date_finish_ymd.' '.$adb->query_result($result,$i,'end_date'),
                );
            }
        }

	}
}
$_REQUEST['diony']='diony';
ConvertTojsonString(1,$data,"success");
?>