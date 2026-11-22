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
//```````````统计补卡信息
//editor:gyq_139 reason:月度考勤增加显示补卡  2019/8/27 17:14 
/*$sql = 'select concat(userid,DATE_FORMAT(checkin_time_date,\'%Y-%m-%d\')) userid_date_day,
          DATE_FORMAT(checkin_time_date,\'%Y-%m-%d\') date_day,count(1) card_num,userid
        from ld_wx_checkin_reissue where checkin_time between ? and ? group by userid_date_day';
$result = $adb->pquery($sql,array($month_start,$month_end));
$nums = $adb->num_rows($result);
$reissue_list = array();
if($nums > 0){
    for($i=0;$i<$nums;$i++){
        $reissue_list[$adb->query_result($result,$i,'userid_date_day')] = $adb->query_result($result,$i,'card_num');
    }
}*/
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
                     order by date_day desc ,b.id asc';
$multi_result = $OftenUseReport->page_list_result($page_list_query,array($month_start_millisecond,$month_end_millisecond));
$page_list_query = $multi_result['page_list_query'];

$sql = 'select a.userid,a.groupid,a.checktype,a.timeresult,a.userchecktime,a.userchecktime_date,a.sourceType,
        d.last_name,d.groupid user_groupid
        from ld_wx_checkin_dingtalk a inner join ('.$page_list_query.') d on a.userid=d.userid 
        and DATE_FORMAT(a.userchecktime_date,\'%m-%d-%Y\')=d.date_day
        order by a.userchecktime desc ,d.id asc';
$result = $adb->pquery($sql,array($month_start_millisecond,$month_end_millisecond));
$list_day = array();
$list = array();
$user_list = array();
for ($i=0;$i<$adb->num_rows($result);$i++){
    $wx_userid = $adb->query_result($result,$i,'userid');
    $groupname = $adb->query_result($result,$i,'groupid');
    $checkin_type = $adb->query_result($result,$i,'checktype');
    $exception_type = $adb->query_result($result,$i,'timeresult');
    $checkin_time = substr($adb->query_result($result,$i,'userchecktime'),0,-3) ;
    $last_name = $adb->query_result($result,$i,'last_name');
    $groupid = $adb->query_result($result,$i,'user_groupid');
    $sourcetype = $adb->query_result($result,$i,'sourcetype');
    $checkin_day = date('Y-m-d',$checkin_time);
    if($sourcetype=='APPROVE'){
        $sourcetype = ' ('.getFixedLabel('DINGTALKREISSUE').')';
    }else{
        $sourcetype = '';
    }
    $list_day[$wx_userid.','.$checkin_day.','.$groupname][] = array($checkin_time,$exception_type,$sourcetype);
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
    $list[$i]['time'] = $multi_key[1];
    $list[$i]['lastname'] = $user_list[$multi_key[0]]['lastname'];
    $list[$i]['group'] = $user_list[$multi_key[0]]['group'];
    $list[$i]['groupname'] = $simplegroupsName[$multi_key[2]] ;
    $condition = '';
    $work_hour = '';
    //editor:gyq_20190902 reason:修改打卡数量算法，补卡影响正常打卡数量  2019/9/2 15:51
    //最早打卡
    $checkin_first = end($value);
    //最晚打卡
    $checkout_end = reset($value);
    $frequency = count($value);
    //未打卡，时间置空
    if ($checkin_first[1] == 'NotSigned') {
        $checkin_first[0] = 0;
        $frequency--;
    }
    $first_checkin = $checkin_first[0];
    if(count($value)==1){
        if($frequency > 0){
            $frequency--;
        }
        $condition = null;
        $work_hour = null;
        $latest_checkin_final = '--';
    }else {
        if ($checkout_end[1] == 'NotSigned') {
            $checkout_end[0] = 0;
            if ($frequency > 0)
                $frequency--;
        }
        //若一天中，最早打卡和最晚打卡没有异常，则判定这天的打卡正常
        if ($checkin_first[1] == 'Normal' && $checkout_end[1] == 'Normal') {
            $condition = '正常';
        } elseif ($checkin_first[1] == 'NotSigned' && $checkout_end[1] == 'NotSigned') {
            $condition = '<font color="red">缺卡</font>';
        } else {
            $condition = '<font color="red">时间异常</font>';
        }
        $latest_checkin = $checkout_end[0];
        //工作时间按小时格式化
        if ($first_checkin != $latest_checkin && $first_checkin > 0 && $latest_checkin > 0) {
            $work_hour = $modelObj->countRestTime($first_checkin ,$latest_checkin);
        }
        $latest_checkin_final = $latest_checkin > 0 ? date('H:i', $latest_checkin) . $checkout_end[2] : '--';
    }
    //$list[$i]['frequency'] =  $frequency;
    $list[$i]['first_checkin'] = $first_checkin>0? date('H:i',$first_checkin).$checkin_first[2]:'--' ;
    $list[$i]['latest_checkin'] = $latest_checkin_final;
    $list[$i]['work_hour'] = $work_hour ? $work_hour : '--';
    /*if(isset($reissue_list[$multi_key[0].$multi_key[1]]) && $multi_key[2])
        $list[$i]['reissue_card'] =$reissue_list[$multi_key[0].$multi_key[1]];
    else
        $list[$i]['reissue_card'] = 0;*/
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