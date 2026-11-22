<?php
//云网金服开发
global $currentModule;
//editor:gyq_155 reason:钉钉考勤同步  2019/10/30 16:56 ID1000624
$OftenUseReport = new ReportModel();
//报表名
$OftenUseReport->report_name = $_REQUEST['report_name'];
$request_year = $_REQUEST['year'];
$request_month = $_REQUEST['month'];
//`````````获取查询的月度时间范围，默认当月
if(empty( $request_month) ){
    $request_month = date('m',time());
}
if(empty($request_year)){
    $request_year = date('Y',time());
}
//`````````获取查询的月度时间范围，默认当月
$startmonth = $_REQUEST['startmonth'];
if(empty( $startmonth)){
    $month = date('Y-m');
    $month_start = strtotime($month);//指定月份月初时间戳
    //$month_start = strtotime('2023-05-01');
    $month_end = mktime(23, 59, 59, date('m', strtotime($month))+1, 00);//指定月份月末时间戳
    $month_start_millisecond = $month_start.'000';
    $month_end_millisecond = $month_end.'000';
}else{
    $month_start =  strtotime( $startmonth.' 00:00:00');
    $month_end = strtotime( $_REQUEST['endmonth'].' 23:59:59');
    $month_start_millisecond = $month_start.'000';
    $month_end_millisecond = $month_end.'000';
}
//`````````应打卡数量
$sql = 'select  userid,count(distinct DATE_FORMAT(basechecktime_date,\'%m-%d-%Y\')) total_days
        from ld_wx_checkin_dingtalk where workdate between ? and ?
        group by userid order by userid asc ';
$result = $adb->pquery($sql,array($month_start_millisecond,$month_end_millisecond));
for ($i=0;$i<$adb->num_rows($result);$i++){
    $total_user_num[$adb->query_result($result,$i,'userid')] = $adb->query_result($result,$i,'total_days');
}
//$total_num = $adb->num_rows($result);
//````````考勤组名称
$dingtalkSimplegroups = json_decode( file_get_contents(globalStatic::$root_directory.'dataCache/weixin/dingtalk_simplegroups.txt'),true);
$simplegroupsName = array();
foreach ($dingtalkSimplegroups['result']['groups'] as $key=>$value){
    $simplegroupsName[$value['group_id']] = $value['group_name'];
}
//`````````请假单中的请假类型
$sql = 'select a.listvalue from ld_picklist_values a left join ld_picklist_set b on a.listid=b.listid
        where b.listname=\'minusjobtype\' order by a.sequence asc';
$result = $adb->pquery($sql,array());
$nums = $adb->num_rows($result);
$jobtype = array();//请假类型集合
if($nums > 0){
    for ($i=0;$i<$nums;$i++){
        $jobtype[$i] = $adb->query_result($result,$i,'listvalue');
    }
}else{
    echo 'minusjobtype num zero';
    exit;
}

//```````````获取请假的日期
$sql = 'select smownerid,a.id,minusjobtype,starttime, endtime, last_name  from ld_minusjobbilldetail a INNER JOIN ld_minusjobbill b on a.id = b.minusjobbillid
INNER JOIN ld_users on b.smownerid = ld_users.id where endtime between ? and \'2099-12-31\' and b.approvestatus = \'已批准\'';
$result = $adb->pquery($sql, array(date('Y-m-d H:i:s',$month_start)));
$nums = $adb->num_rows($result);
$vacations = [];
for($i = 0;$i < $nums;$i++){
    $smownerid = $adb->query_result($result, $i, 'smownerid');
    $starttime =  $adb->query_result($result, $i, 'starttime');
    $endtime =  $adb->query_result($result, $i, 'endtime');
    $vacations[$smownerid][] = ['smownerid'=>$smownerid,'starttime'=>$starttime,'endtime'=>$endtime];
}
//```````````获取部门名称列表
$group_label_list  = $OftenUseReport->group_label_list();
//```````````获取用户查看范围
$select_userid = $OftenUseReport->SmOwnerSearchScope();
//````````````补卡次数统计
$reissue_list = '删除';
$out_sing = array();
//获取外出申请的具体人和时间
$sql = 'SELECT smownerid, cf_4736, cf_4737 from ld_customform07 INNER JOIN ld_customform07scf ON ld_customform07.customform07id = ld_customform07scf.customform07id
        WHERE (cf_4736 BETWEEN ? AND ? or cf_4737 BETWEEN ? AND ?) and approvestatus = \'已批准\'';
$result = $adb->pquery($sql,array(date('Y-m-d H:i:s',$month_start) ,date('Y-m-d H:i:s',$month_end),date('Y-m-d H:i:s',$month_start) ,date('Y-m-d H:i:s',$month_end)));
$nums = $adb->num_rows($result);
$check_total = [];
for($i = 0; $i < $nums;$i++){
    $smownerid = $adb->query_result($result, $i, 'smownerid');
    $cf_4736 =  $adb->query_result($result, $i, 'cf_4736');
    $cf_4737 =  $adb->query_result($result, $i, 'cf_4737');
    $check_total[$smownerid][] = ['start_day'=>$cf_4736, 'end_day'=>$cf_4737];
}
//```````````获取外出申请的次数
$sql = 'SELECT count(cf_4736) as out_sign, smownerid, cf_4736, cf_4737 from ld_customform07 INNER JOIN ld_customform07scf ON ld_customform07.customform07id = ld_customform07scf.customform07id
        WHERE (cf_4736 BETWEEN ? AND ? or cf_4737 BETWEEN ? AND ?) and approvestatus = \'已批准\' group by smownerid';
$result = $adb->pquery($sql,array(date('Y-m-d H:i:s',$month_start) ,date('Y-m-d H:i:s',$month_end),date('Y-m-d H:i:s',$month_start) ,date('Y-m-d H:i:s',$month_end)));
$nums = $adb->num_rows($result);
$singin_list = array();
if($nums > 0){
    for ($i=0;$i<$nums;$i++){
        $smownerid = $adb->query_result($result,$i,'smownerid');
        $cf_4736 = $adb->query_result($result, $i, 'cf_4736');
        $cf_4737 = $adb->query_result($result, $i, 'cf_4737');
        $tmp_arr = ['smownerid'=>$smownerid,'cf_4736'=>$cf_4736, 'cf_4737'=>$cf_4737];
        $out_sing[] = $tmp_arr;
        $singin_list[$smownerid] = $adb->query_result($result,$i,'out_sign');
    }
}
$sql_checkin = 'SELECT
ld_wx_checkin_dingtalk.userid,
ld_wx_checkin_dingtalk.groupid,
planid,
checktype,
timeresult,
userchecktime,
basechecktime,
basechecktime_date,
userchecktime_date,
workdate_date,
\'广东云网金服信息系统有限公司\' as groupname1,
date_format(
    workdate_date,
    \'%Y-%m-%d\'
) date_day
FROM
ld_wx_checkin_dingtalk,
ld_groups,
ld_users2group,
ld_users
WHERE
ld_users.dingtalk_userid = ld_wx_checkin_dingtalk.userid and
ld_wx_checkin_dingtalk.userchecktime between ? and ? and
ld_groups.groupid = ld_users2group.groupid
AND ld_users.dingtalk_userid = ld_wx_checkin_dingtalk.userid
AND ld_users.id = ld_users2group.userid
ORDER BY
basechecktime DESC';
$result_checkin = $adb->pquery($sql_checkin,array($month_start_millisecond,$month_end_millisecond));
$nums_checkin = $adb->num_rows($result_checkin);
$list_checkin = array();
if($nums_checkin > 0){
    for($j=0;$j<$nums_checkin;$j++){
        $userid = $adb->query_result($result_checkin,$j,'userid');
        $date_day = $adb->query_result($result_checkin,$j,'date_day');
        $groupid = $adb->query_result($result_checkin,$j,'groupid');
        $planid = $adb->query_result($result_checkin,$j,'planid');
        $checktype = $adb->query_result($result_checkin,$j,'checktype');
        $userctime = $adb->query_result($result_checkin, $j, 'userchecktime');
        $check_time = $adb->query_result($result_checkin, $j, 'basechecktime');
        $workdate_date = $adb->query_result($result_checkin, $j, 'workdate_date');
        //$check_time_date = $adb->query_result($result_checkin, $j, 'basechecktime_date');
        $check_time_date = date('Y-m-d H:i:s',substr($check_time,0,-3));
        //$groupname = $adb->query_result($result_checkin, $j, 'groupname1');
        $list_checkin[$userid][$date_day][] = array(
            'exception_type'=> $adb->query_result($result_checkin,$j,'timeresult'),
            'groupname'=>$simplegroupsName[$groupid],
            'userchecktime'=>substr($userctime,0,-3),
            'planid'=>$planid,'checktype'=>$checktype,
            'userctime'=>$userctime,
            'basechecktime'=>$check_time,
            'basetime_date'=>$check_time_date,
            'workdate_date'=>$workdate_date
        );
    }
}
//```````````获取使用微信的成员列表
$sql = 'select a.dingtalk_userid,a.id,a.groupid,a.last_name from ld_users a  
        where  a.deleted=0 and a.id in('.$select_userid.') and ifnull(a.dingtalk_userid,\'\')<>\'\' 
       group by a.id';
$result = $adb->pquery($sql,array());
$nums  = $adb->num_rows($result);
$list = array();
$line = 0;
$jobtype_num = array();//请假类型数量集合
for($i=0;$i<$nums;$i++){
    $wx_userid = $adb->query_result($result,$i,'dingtalk_userid');
    //CRM用户无打卡记录
    if(!isset($total_user_num[$wx_userid]))
        continue;
    $userid = $adb->query_result($result,$i,'id');
    $groupid = $adb->query_result($result,$i,'groupid');
    $groupid_list = explode(',',$groupid);
    $outer = array();
    foreach ($groupid_list as $key=>$value){
        $groupid_list[$key] = $group_label_list[$value];
    }
    $group_label = implode(',',$groupid_list);
    //统计正常打卡天数
    $normal_check = 0;
    $groupname = '';
    $normal_date = [];
    $wrong_date = [];
    foreach ($list_checkin[$wx_userid] as $date_day=> &$content){
        //上班打卡
        $checkin_first = null;
        //下班打卡
        $checkout_end = null;
        if(count($content) < 2) continue;
        foreach($content as $data){
            if($data['checktype'] == 'OnDuty') $checkin_first = $data;
            else $checkout_end = $data;
        }
        $groupname = $checkout_end['groupname'];
        //若一天中，上班打卡和下班打卡没有异常，则判定这天的打卡正常
        if($checkin_first['exception_type']=='Normal' && $checkout_end['exception_type']=='Normal'){
            $normal_check++;
            //$normal_date[] = [$checkin_first, $checkout_end];
        }
        else{
            $flag1 = $checkin_first['exception_type'] == 'Normal'?true:false;
            $isVaca1 = $checkin_first['exception_type'] == 'Normal'?true:false;
            $flag2 = $checkout_end['exception_type'] == 'Normal'?true:false;
            $isVaca2 = $checkout_end['exception_type'] == 'Normal'?true:false;
            //上班没打卡
            if($checkin_first['exception_type'] != 'Normal'){
                //外出信息判断
                foreach ($check_total[$userid] as $data) {
                    $start_day_timestamp = strtotime($data['start_day']);
                    $end_day_timestamp = strtotime($data['end_day']);
                    //如果签到时间在外出申请时间开始和结束时间之前 判定正常
                    if($checkin_first['userchecktime']+60>=$start_day_timestamp&&$checkin_first['userchecktime']<=$end_day_timestamp){
                        $flag1 = true;
                        break;
                    }
                }
                //请假信息判断
                foreach($vacations[$userid] as $vacation){
                    $tmp_userchecktime = $checkin_first['userchecktime'];
                    if($tmp_userchecktime+60 >= strtotime($vacation['starttime'])&&$tmp_userchecktime <= strtotime($vacation['endtime'])){
                        $isVaca1 = true;
                        break;
                    }
                }
            }
            if($checkout_end['exception_type'] != 'Normal'){
                //下班不正常
                //外出信息判断
                foreach ($check_total[$userid] as $data) {
                    $start_day_timestamp = strtotime($data['start_day']);
                    $end_day_timestamp = strtotime($data['end_day']);
                    //如果签到时间在外出申请时间开始和结束时间之前 判定正常
                    if($checkout_end['userchecktime']+60>=$start_day_timestamp&&$checkout_end['userchecktime']<=$end_day_timestamp){
                        $flag2 = true;
                        break;
                    }
                }

                //请假信息判断
                foreach($vacations[$userid] as $vacation){
                    $tmp_userchecktime = $checkout_end['userchecktime'];
                    if($tmp_userchecktime+60 >= strtotime($vacation['starttime'])&&$tmp_userchecktime <= strtotime($vacation['endtime'])){
                        $isVaca2 = true;
                        break;
                    }
                }
            }
            if($flag1 && $flag2){
                $normal_check++;
            }
            else if($isVaca1 && $isVaca2){
                $normal_check++;
            }
            else if(($flag1 && $isVaca2)||($isVaca1 && $flag2)){
                $normal_check++;
            }
        }

    }

    //if($userid == 441)dump($normal_date);
    //`````````赋值打卡信息
    $list[$line]['lastname'] = $adb->query_result($result,$i,'last_name');
    $list[$line]['group'] = $group_label;
    $list[$line]['groupname'] = $groupname;
    //打卡次数
    $total_num = $total_user_num[$wx_userid];
    
    $normal_num = $normal_check;
    
    $unnormal_num = $total_num - $normal_num;

    $list[$line]['total_days'] = $total_num;
    $list[$line]['normal_days'] = $normal_num;
    $list[$line]['abnormal_days'] = $unnormal_num;
    if(isset($singin_list[$userid]))
        $singin_days = $singin_list[$userid];
    else
        $singin_days = 0;
    $list[$line]['signin_days'] = $singin_days;
    $list[$line]['userid'] = $userid;
    //````````````统计请假时间
    $sql_three = 'select sum(a.costtime) costtime,a.minusjobtype from ld_minusjobbilldetail a left join ld_minusjobbill b on a.id=b.minusjobbillid
          where b.smownerid=? and a.starttime between ? and ? and approvestatus = \'已批准\' group by a.minusjobtype ';
    $result_three = $adb->pquery($sql_three,array($userid,date('Y-m-d H:i:s',$month_start) ,date('Y-m-d H:i:s',$month_end)));
    $nums_three = $adb->num_rows($result_three);
    $jobtype_user_num = array();
    for($k=0;$k < $nums_three;$k++){
        $minusjobtype = $adb->query_result($result_three,$k,'minusjobtype');
        $jobtype_user_num[$minusjobtype] = $adb->query_result($result_three,$k,'costtime');
    }
    //给没值的请假类型补0
    foreach ($jobtype as $key=>$value){
        if($jobtype_user_num[$value] > 0){
            $jobtype_num[$userid][$key] = $jobtype_user_num[$value] ;
        }else{
            $jobtype_num[$userid][$key] = 0;
        }
    }
    $line++;
}
//````````生成异常天数超链接，指向考勤异常统计表
$sql  = 'select usereportid from ld_usereport where name=\'checkin_abnormal\'';
$result = $adb->pquery($sql,array());
$checkin_abnormal_id = $adb->query_result($result,0,'usereportid');
$page_addurl='&refreshleftmenuclick=yes&report_name=checkin_abnormal&refreshUseReport='.$checkin_abnormal_id.
                '&startmonth='.date('Y-m-d',$month_start).'&endmonth='.date('Y-m-d',$month_end).'&SmOwnerSearchScope=';
$page_addurl=urlencode($page_addurl);
$checkin_abnormal_url = 'index.php?pageto_module='.$currentModule.'&pageto_action=index_report&page_addurl='.$page_addurl;
//````````生成请假单超链接，指向请假单明细报表
$sql  = 'select usereportid from ld_usereport where name=\'minusjob_billdetail\'';
$result = $adb->pquery($sql,array());
$minusjob_billdetail_id = $adb->query_result($result,0,'usereportid');
$page_addurl='&refreshleftmenuclick=yes&report_name=minusjob_billdetail&refreshUseReport='.$minusjob_billdetail_id.
    '&startmonth='.date('Y-m-d',$month_start).'&endmonth='.date('Y-m-d',$month_end).'&SmOwnerSearchScope=';
    
 $page_addurl=urlencode($page_addurl);
 
$minusjob_billdetail_url = 'index.php?pageto_module='.$currentModule.'&pageto_action=index_report&page_addurl='.$page_addurl;
//````````生成外勤签到超链接，指向签到统计表
$sql  = 'select usereportid from ld_usereport where name=\'SIGNINSTATISTICS\'';
$result = $adb->pquery($sql,array());
$singin_statistics_id = $adb->query_result($result,0,'usereportid');
$page_addurl='&refreshleftmenuclick=yes&refreshUseReport='.$singin_statistics_id.
    '&searchtype=BasicSearch&redirect_from=checkin_monthly&startmonth='.date('Y-m-d',$month_start).'&endmonth='.date('Y-m-d',$month_end).'&SmOwnerSearchScope=';
 $page_addurl=urlencode($page_addurl);

$singin_statistics_url  =  'index.php?pageto_module=CustomForm07&pageto_action=index&page_addurl=%26SearchScope%3D';

//``````````报表内容
$html_content = '';
foreach ($list as $i=>$content){
    $trclass = 'lvtColData';
    $tr_on = 'on';
    if($i % 2 != 0){
        $trclass = 'lvtColDataBj';
        $tr_on = 'On';
    }
    $html_content .='<tr id="report_'.$i.'" class="'.$trclass.'" onmouseover="listOnMouseOver(ld(this))" onmouseout="listOnMouseOut(ld(this),\''.$tr_on.'\')">';
    //打卡信息
    foreach ($content as $key=>$value){
        if ($key == 'userid') {
            continue;
        } elseif($key == 'abnormal_days'||$key == 'reissue_card') {
            $html_content .='<td ><a target=\'_blank\' href=\''.$checkin_abnormal_url.$content['userid'].'\'>'.
                $value.'</a></td>';
        } elseif($key == 'signin_days') {
            $html_content .='<td ><a target=\'_blank\' href=\''.$singin_statistics_url.$content['userid'].'\'>'.
                $value.'</a></td>';
        } else {
            $html_content .= '<td>' . $value . '</td>';
        }
    }
    //请假信息
    foreach ($jobtype_num[$content['userid']] as $key=>$value){
        $html_content .='<td ><a target=\'_blank\' href=\''.$minusjob_billdetail_url.$content['userid'].'\'>'.
                        $value.'</a></td>';
    }
    $html_content .='</tr>';
}
$REPORTFILTERHTML = $html_content;
//是否显示显示列设置按钮,不显示
$setcolumns = 0;
//筛选栏第一行
$basicfilterHtml = '';
//````````筛选栏第二行，自定义日期
$thequerytime = date('Y-m-d',$month_start) . ' ' . '-' . ' ' . date('Y-m-d',$month_end);
//editor:gyq_20190830 reason:0037972: （1.6）常用报表->月度考勤统计表：“自定义日期”和人员范围标签没有上下居中
$basicfilterHtml2 = '<label class="Name changeday" style="padding:0;padding-right: 5px;margin-bottom: 0px !important;line-height: 29px;">
                                                                    <span style="font-weight:normal;">'. getFixedLabel('DATESELECTION') .':&nbsp;</span> </label>';
$data_system = "width:180px;padding-left:3px;margin-right:10px;";
$basicfilterHtml2 .= "<input class='borderALL btn-radius-system' type='text' readonly=true value='$thequerytime' id='startmonth' name='startmonth' findcolumn= 'time' style='" . $data_system . "'/>";

//报表底部
include globalStatic::$root_directory.'modules/OftenUseReport/module/index_report_bottom.php';
?>