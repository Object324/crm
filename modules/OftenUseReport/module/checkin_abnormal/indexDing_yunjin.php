<?php
//editor:gyq_155 reason:钉钉考勤同步  2019/10/30 17:45 ID1000624
require_once globalStatic::$root_directory.'modules/OftenUseReport/module/checkin_monthly/AttendanceDingTalk.php';

$modelObj = new AttendanceDingTalk();
$OftenUseReport = new ReportModel();
//报表名
$OftenUseReport->report_name = $_REQUEST['report_name'];
//`````````报表序时簿默认14条
$OftenUseReport->report_pagerecordcount = 14;
//`````````报表类型
$OftenUseReport->report_parent_type = 'checkin';
//`````````获取查询的月度时间范围，默认当月
$startmonth = $_REQUEST['startmonth'];
if(empty( $startmonth)){
    $month = date('Y-m');
    $month_start = strtotime($month);//指定月份月初时间戳
    $month_end = mktime(23, 59, 59, date('m', strtotime($month))+1, 00);//指定月份月末时间戳
    $month_start_millisecond = $month_start.'000';
    $month_end_millisecond = $month_end.'000';
}else{
    $month_start =  strtotime( $startmonth.' 00:00:00');
    $month_end = strtotime( $_REQUEST['endmonth'].' 23:59:59');
    $month_start_millisecond = $month_start.'000';
    $month_end_millisecond = $month_end.'000';
}
//```````````获取部门名称列表
$group_label_list  = $OftenUseReport->group_label_list();
//```````````获取用户查看范围
$select_userid = $OftenUseReport->SmOwnerSearchScope();

//```````获取请假信息
$sql = 'select smownerid,a.id,minusjobtype,starttime, endtime, last_name  from ld_minusjobbilldetail a INNER JOIN ld_minusjobbill b on a.id = b.minusjobbillid
INNER JOIN ld_users on b.smownerid = ld_users.id where b.smownerid in ('.$select_userid.') and endtime between ? and \'2099-12-31\' and b.approvestatus = \'已批准\'';
$result = $adb->pquery($sql, array(date('Y-m-d H:i:s',$month_start)));
$nums = $adb->num_rows($result);
$vacations = [];
for($i = 0;$i < $nums;$i++){
    $smownerid = $adb->query_result($result, $i, 'smownerid');
    $starttime =  $adb->query_result($result, $i, 'starttime');
    $endtime =  $adb->query_result($result, $i, 'endtime');
    $vacations[$smownerid][] = ['smownerid'=>$smownerid,'starttime'=>$starttime,'endtime'=>$endtime];
}
//获取外出信息
$sql = 'SELECT smownerid, cf_4736, cf_4737 from ld_customform07 INNER JOIN ld_customform07scf ON ld_customform07.customform07id = ld_customform07scf.customform07id
        WHERE smownerid in ('.$select_userid.') and  (cf_4736 BETWEEN ? AND ? or cf_4737 BETWEEN ? AND ?) and approvestatus = \'已批准\'';
$result = $adb->pquery($sql,array(date('Y-m-d H:i:s',$month_start) ,date('Y-m-d H:i:s',$month_end),date('Y-m-d H:i:s',$month_start) ,date('Y-m-d H:i:s',$month_end)));
$nums = $adb->num_rows($result);
$singin_list = array();
$check_total = [];
for($i = 0; $i < $nums;$i++){
    $smownerid = $adb->query_result($result, $i, 'smownerid');
    $cf_4736 =  $adb->query_result($result, $i, 'cf_4736');
    $cf_4737 =  $adb->query_result($result, $i, 'cf_4737');
    $check_total[$smownerid][$i] = ['smownerid'=>$smownerid,'start_day'=>$cf_4736, 'end_day'=>$cf_4737];
}

//````````考勤组名称
$dingtalkSimplegroups = json_decode( file_get_contents(globalStatic::$root_directory.'dataCache/weixin/dingtalk_simplegroups.txt'),true);
$simplegroupsName = array();
foreach ($dingtalkSimplegroups['result']['groups'] as $key=>$value){
    $simplegroupsName[$value['group_id']] = $value['group_name'];
}
//`````````打卡时间统计
$page_list_query = 'select concat(c.userid,DATE_FORMAT(c.userchecktime_date,\'%m-%d-%Y\')) userid_date_day,
                   DATE_FORMAT(c.userchecktime_date,\'%m-%d-%Y\') date_day,b.id, c.userid,c.userchecktime_date,
                   b.last_name,b.groupid
                     from ld_wx_checkin_dingtalk c left join ld_users b on c.userid=b.dingtalk_userid
                     where c.userchecktime between ? and ? and ifnull(b.dingtalk_userid,\'\')<>\'\' 
                     and b.deleted=0 and b.id in('.$select_userid.') 
                     group by userid_date_day
                     order by date_day asc ,b.id asc';

$multi_result = $OftenUseReport->page_list_result($page_list_query,array($month_start_millisecond,$month_end_millisecond));

$page_list_query = $multi_result['page_list_query'];

$sql = 'select d.id,a.userid,a.groupid,a.checktype,a.timeresult,a.userchecktime,a.userchecktime_date,a.sourceType,a.basechecktime,a.workdate_date,a.basechecktime_date,
        d.last_name,d.groupid user_groupid
        from ld_wx_checkin_dingtalk a inner join ('.$page_list_query.') d on a.userid=d.userid 
        and DATE_FORMAT(a.userchecktime_date,\'%m-%d-%Y\')=d.date_day
        order by a.workdate_date asc ,d.id asc';

$result = $adb->pquery($sql,array($month_start_millisecond,$month_end_millisecond));
$list_day = array();
$list = array();
$list_with_key_of_workdate_date = array();
$user_list = array();

for ($i=0;$i<$adb->num_rows($result);$i++){
    $userid = $adb->query_result($result,$i,'id');
    $wx_userid = $adb->query_result($result,$i,'userid');
    $groupname = $adb->query_result($result,$i,'groupid');
    $checktype = $adb->query_result($result,$i,'checktype');//OnDuty上班  OffDuty下班
    $exception_type = $adb->query_result($result,$i,'timeresult');//Normal正常 NotSigned缺卡
    $checkctime = $adb->query_result($result,$i,'userchecktime');//打卡时间或者应打卡时间  时间戳
    $checkin_time = substr($checkctime,0,-3);
    $basechecktime_date = $adb->query_result($result,$i,'basechecktime_date');//打卡时间或者应打卡时间 年月日 时分秒格式
    $last_name = $adb->query_result($result,$i,'last_name');//成员的名字
    $groupid = $adb->query_result($result,$i,'user_groupid');
    $sourcetype = $adb->query_result($result,$i,'sourcetype');//数据来源 USER用户数据  AUTO_CHECK自动检查  SYSTEM系统数据
    $workdate_date = $adb->query_result($result,$i,'workdate_date');//工作应打卡时间  比如早上9点和下午6点
    $checkin_day = date('Y-m-d',$checkin_time);
    if($sourcetype=='APPROVE'){
        $sourcetype = ' ('.getFixedLabel('DINGTALKREISSUE').')';
    }else{
        $sourcetype = '';
    }
    $tmp_arr = array(
        'checktype'=>$checktype,
        'userchecktime'=>$checkin_time,
        'basechecktime_date'=>$basechecktime_date,
        'exception_type'=>$exception_type,
        'sourcetype'=>$sourcetype,
        'userid'=>$userid,
        'workdate_date'=>$workdate_date,
        'checkin_day'=>$checkin_day
    );
    $list_day[$wx_userid.','.$workdate_date.','.$groupname][$checktype] = $tmp_arr;
    $list_with_key_of_workdate_date[date('Y-m-d',strtotime($workdate_date))][$checktype] = ['checkin_day'=>$checkin_day,];
    //生成成员信息列
    $groupid_list = explode(',',$groupid);
    foreach ($groupid_list as $key=>$value){
        $groupid_list[$key] = $group_label_list[$value];
    }
    $group_label = implode(',',$groupid_list);
    $user_list[$wx_userid] = array(
        'lastname'=>$last_name,
        'group'=>$group_label
    );
}

$i = 0;
foreach ($list_day as $key=>$value){
    $multi_key = explode(',',$key);

    if(!isset($user_list[$multi_key[0]]))
        continue;
    $list[$i]['time'] = date('Y-m-d',strtotime($multi_key[1]));
    $list[$i]['lastname'] = $user_list[$multi_key[0]]['lastname'];
    $list[$i]['group'] = $user_list[$multi_key[0]]['group'];
    $list[$i]['groupname'] = $simplegroupsName[$multi_key[2]];
    $condition = '';
    $work_hour = '';

    if(!isset($value['OnDuty'])||!isset($value['OffDuty'])){
        $condition = '<font color="red">上班或下班无数据记录</font>';
        $first_checkin = null;
        $latest_checkin = null;
        $work_hour = null;
    }else{
        $checkin_first = $value['OnDuty'];//上班
        $checkout_end = $value['OffDuty'];//下班
        $first_checkin = null;
        $latest_checkin = null;
        if ($checkin_first['exception_type'] == 'Normal' && $checkout_end['exception_type'] == 'Normal') {
            //上班下班都正常
            $condition = '正常';
            $first_checkin = $checkin_first['userchecktime'];
            $latest_checkin = $checkout_end['userchecktime'];
            $work_hour = $modelObj->countRestTime($first_checkin ,$latest_checkin);
        }else{
            $iid = $checkin_first['userid'];
            $flag1 = $checkin_first['exception_type'] == 'Normal'?true:false;
            $isVaca1 = $checkin_first['exception_type'] == 'Normal'?true:false;
            $flag2 = $checkout_end['exception_type'] == 'Normal'?true:false;
            $isVaca2 = $checkout_end['exception_type'] == 'Normal'?true:false;
            //上班没打卡
            if($checkin_first['exception_type'] != 'Normal'){

                //外出信息判断
                foreach ($check_total[$iid] as $data) {
                    $start_day_timestamp = strtotime($data['start_day']);
                    $end_day_timestamp = strtotime($data['end_day']);
                    //如果签到时间在外出申请时间开始和结束时间之前 判定正常
                    if($checkin_first['userchecktime']+60>=$start_day_timestamp&&$checkin_first['userchecktime']<=$end_day_timestamp){
                        $flag1 = true;
                        break;
                    }
                }
                //请假信息判断
                foreach($vacations[$iid] as $vacation){
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
                foreach ($check_total[$iid] as $data) {
                    $start_day_timestamp = strtotime($data['start_day']);
                    $end_day_timestamp = strtotime($data['end_day']);
                    //如果签到时间在外出申请时间开始和结束时间之前 判定正常
                    if($checkout_end['userchecktime']+60>=$start_day_timestamp&&$checkout_end['userchecktime']<=$end_day_timestamp){
                        $flag2 = true;
                        break;
                    }
                }

                //请假信息判断
                foreach($vacations[$iid] as $vacation){
                    $tmp_userchecktime = $checkout_end['userchecktime'];
                    if($tmp_userchecktime+60 >= strtotime($vacation['starttime'])&&$tmp_userchecktime <= strtotime($vacation['endtime'])){
                        $isVaca2 = true;
                        break;
                    }
                }
            }
            $first_checkin = $checkin_first['userchecktime'];
            $latest_checkin = $checkout_end['userchecktime'];
            $work_hour = $modelObj->countRestTime($first_checkin ,$latest_checkin);
            if($flag1 && $flag2){
                $condition = '正常(已批准外出申请)';
            }
            else if($isVaca1 && $isVaca2){
                $condition = '正常(已批准请假)';
            }
            else if(($flag1 && $isVaca2)||($isVaca1 && $flag2)){
                $condition = '正常(已批准外出和请假)';
            }else if($checkin_first['exception_type']=='Late'){
                $condition = '<font color="red">迟到</font>';
            }else if($checkout_end['exception_type']=='Early'){
                $condition = '<font color="red">早退</font>';
            }else{
                $condition = '<font color="red">缺卡</font>';
                if(!$flag1||!$isVaca1){
                    $first_checkin = null;
                    $work_hour = '--';
                }
                if(!$flag2||!$isVaca2){
                    $latest_checkin = null;
                    $work_hour = '--';
                }
            }
        }

    }
    $list[$i]['first_checkin'] = $first_checkin>0? date('Y-m-d H:i',$first_checkin).$checkin_first['sourcetype']:'--' ;
    $list[$i]['latest_checkin'] = $latest_checkin > 0 ? date('Y-m-d H:i', $latest_checkin) . $checkout_end['sourcetype'] : '--';
    $list[$i]['work_hour'] = $work_hour ? $work_hour : '--';
    $list[$i]['condition'] = $condition?$condition:'--';
    $i++;
}
//`````````报表内容
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
        $html_content .= '<td>' . $value . '</td>';
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
//editor:gyq_20190902 reason:0038000: （1.6）常用报表->请假明细表、考勤异常明细表：“自定义日期”标签没有上下居中  2019/9/2 16:18
$basicfilterHtml2 = '<label class="Name changeday" style="padding:0;padding-right: 5px;margin-bottom: 0px !important;line-height: 29px;">
                                                                    <span style="font-weight:normal;">'. getFixedLabel('DATESELECTION') .':&nbsp;</span> </label>';
$data_system = "width:180px;padding-left:3px;margin-right:10px;";
$basicfilterHtml2 .= "<input class='borderALL btn-radius-system' type='text' readonly=true value='$thequerytime' id='startmonth' name='startmonth' findcolumn= 'time' style='" . $data_system . "'/>";
//````````月度考勤表跳转考勤异常明细表，默认选中用户
$SmOwnerSearchScope = '';
if($_REQUEST['SmOwnerSearchScope'] > 0){
    $SmOwnerSearchScope = $_REQUEST['SmOwnerSearchScope'];
}

//报表底部
include globalStatic::$root_directory.'modules/OftenUseReport/module/index_report_bottom.php';
?>