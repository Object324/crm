<?php
global $currentModule;
//editor:gyq_135 reason:月度考勤表  2019/8/6 16:32 ID1000568
$OftenUseReport = new ReportModel();
//报表名
$OftenUseReport->report_name = $_REQUEST['report_name'];
//`````````报表类型
//editor:gyq_20191216 reason:0038913: 安装包、升级包>常用报表>考勤异常明细表、月度考勤统计表、请假明细表、：点击导出Excel报错。
$OftenUseReport->report_parent_type = 'checkin';
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
    $month_end = mktime(23, 59, 59, date('m', strtotime($month))+1, 00);//指定月份月末时间戳
}else{
    $month_start =  strtotime( $startmonth.' 00:00:00');
    $month_end = strtotime( $_REQUEST['endmonth'].' 23:59:59');
}
$today_checkin_time = date('Y-m-d');
//`````````应打卡数量
$sql = "select  userid,count(distinct DATE_FORMAT(checkin_time_date,'%m-%d-%Y')) total_days
          from ld_wx_checkin where checkin_time between ? and ? and DATE_FORMAT(checkin_time_date,'%Y-%m-%d')<>$today_checkin_time group by userid order by userid asc ";
$result = $adb->pquery($sql,array($month_start,$month_end));

for ($i=0;$i<$adb->num_rows($result);$i++){
    $total_user_num[$adb->query_result($result,$i,'userid')] = $adb->query_result($result,$i,'total_days');
}
$total_num = $adb->num_rows($result);
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
//```````````获取部门名称列表
$group_label_list  = $OftenUseReport->group_label_list();
//```````````获取用户查看范围
$select_userid = $OftenUseReport->SmOwnerSearchScope();
//````````````补卡次数统计
//editor:gyq_139 reason:月度考勤增加显示补卡  2019/8/27 17:15
//editor:gyq_20190830 reason:不统计当天补卡次数 0037988
//0037988: （http://kehu001.com/weixin/kh35564/ [^]）常用报表->月度考勤统计表：报表数据【补卡】次数与企业微信不一致
$sql = "select userid,count(1) card_num from ld_wx_checkin_reissue where sp_status=2 
        and checkin_time between ? and ? and DATE_FORMAT(checkin_time_date,'%Y-%m-%d')<>$today_checkin_time group by userid order by sp_num asc ";
$result = $adb->pquery($sql,array($month_start,$month_end));
$nums = $adb->num_rows($result);
$reissue_list = array();
if($nums > 0){
    for($i=0;$i<$nums;$i++){
        $reissue_list[$adb->query_result($result,$i,'userid')] = $adb->query_result($result,$i,'card_num');
    }
}
//```````````获取外勤签到的次数
$sql = 'select count(1) singin_num,userid from ld_singin
      where createdtime between ? and ? group by userid';
$result = $adb->pquery($sql,array(date('Y-m-d H:i:s',$month_start) ,date('Y-m-d H:i:s',$month_end)));
$nums = $adb->num_rows($result);
$singin_list = array();
if($nums > 0){
    for ($i=0;$i<$nums;$i++){
        $singin_list[$adb->query_result($result,$i,'userid')] = $adb->query_result($result,$i,'singin_num');
    }
}
//editor:gyq_20190902 reason:修改打卡数量算法，补卡影响正常打卡数量  2019/9/2 15:51
//``````````统计打卡
$sql_checkin = "select userid,groupname,checkin_type,exception_type,checkin_time,checkin_time_date,
                  date_format(checkin_time_date,'%Y-%m-%d') date_day
                from ld_wx_checkin  where  checkin_time between ? and ? 
                and DATE_FORMAT(checkin_time_date,'%Y-%m-%d')<>$today_checkin_time
                                           order by checkin_time desc";
$result_checkin = $adb->pquery($sql_checkin,array($month_start,$month_end));
$nums_checkin = $adb->num_rows($result_checkin);
$list_checkin = array();
if($nums_checkin > 0){
    for($j=0;$j<$nums_checkin;$j++){
        $userid = $adb->query_result($result_checkin,$j,'userid');
        $date_day = $adb->query_result($result_checkin,$j,'date_day');
        $groupname = $adb->query_result($result_checkin,$j,'groupname');
        $list_checkin[$userid][$date_day][] = array(
            'exception_type'=> $adb->query_result($result_checkin,$j,'exception_type'),
            'groupname'=>$groupname
        );
    }
}
//```````````获取使用微信的成员列表
$sql = 'select a.wx_userid,b.convertuserid,a.id,a.groupid,a.last_name from ld_users a  left join ld_wechatconvertuserid b on a.wx_userid=b.wechatuserid
        where  a.deleted=0 and a.id in('.$select_userid.') and ifnull(a.wx_userid,\'\')<>\'\' 
       group by a.id';
	 
$result = $adb->pquery($sql,array());
$nums  = $adb->num_rows($result);
$list = array();
$line = 0;
$jobtype_num = array();//请假类型数量集合

for($i=0;$i<$nums;$i++){
    $wx_userid = $adb->query_result($result,$i,'wx_userid');
    $convertuserid = $adb->query_result($result,$i,'convertuserid');
    //CRM用户无打卡记录
	
    if(!isset($total_user_num[$wx_userid])&&!empty($convertuserid)){
		$wx_userid = $convertuserid;
	}
	if(!isset($total_user_num[$wx_userid]))
        continue;
    $userid = $adb->query_result($result,$i,'id');
    $groupid = $adb->query_result($result,$i,'groupid');
    $groupid_list = explode(',',$groupid);
    foreach ($groupid_list as $key=>$value){
       // $groupid_list[$key] = $group_label_list[$value];
        $groupobj=new Users();
        $groupobj->groupid=$value;
        $groupobj->groupname=$group_label_list[$value];
        $groupid_list[$key] = getWx_GroupName($groupobj);
        
    }
    $group_label = implode(',',$groupid_list);
    //统计正常打卡天数
    $normal_check = array();
    $groupname = '';
    foreach ($list_checkin[$wx_userid] as $date_day=> $content){
        //最早打卡
        $checkin_first = end($content);
        //最晚打卡
        $checkout_end = reset($content);
        $groupname = $checkout_end['groupname'];
        //若一天中，最早打卡和最晚打卡没有异常，则判定这天的打卡正常
        if($checkin_first['exception_type']=='' && $checkout_end['exception_type']==''){
            $normal_check[] = 1;
        }
    }
    //`````````赋值打卡信息
    $userobj=new Users();
    $userobj->wx_userid=$wx_userid;
    $userobj->last_name=$adb->query_result($result,$i,'last_name');
    $list[$line]['lastname'] = getUserlastName($userobj);
    
    $list[$line]['group'] = $group_label;
    $list[$line]['groupname'] = $groupname;
    //打卡次数
    $total_num = $total_user_num[$wx_userid];
    $normal_num = count($normal_check);
    $unnormal_num = $total_num - $normal_num;
    $list[$line]['total_days'] = $total_num;
    $list[$line]['normal_days'] = $normal_num;
    $list[$line]['abnormal_days'] = $unnormal_num;
    if(isset( $reissue_list[$wx_userid]))
        $list[$line]['reissue_card'] = $reissue_list[$wx_userid];
    else
        $list[$line]['reissue_card'] = 0;
    if(isset($singin_list[$userid]))
        $singin_days = $singin_list[$userid];
    else
        $singin_days = 0;
    $list[$line]['signin_days'] = $singin_days;
    $list[$line]['userid'] = $userid;
    //````````````统计请假时间
    $sql_three = 'select sum(a.costtime) costtime,a.minusjobtype from ld_minusjobbilldetail a left join ld_minusjobbill b on a.id=b.minusjobbillid
          where b.smownerid=? and a.starttime between ? and ? group by a.minusjobtype ';
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
$page_addurl='&report_name=checkin_abnormal&UseReport='.$checkin_abnormal_id.
                '&startmonth='.date('Y-m-d',$month_start).'&endmonth='.date('Y-m-d',$month_end).'&SmOwnerSearchScope=';
                
$page_addurl=urlencode($page_addurl);

$checkin_abnormal_url = 'index.php?pageto_module='.$currentModule.'&pageto_action=index_report&page_addurl='.$page_addurl;
//````````生成请假单超链接，指向请假单明细报表
$sql  = 'select usereportid from ld_usereport where name=\'minusjob_billdetail\'';
$result = $adb->pquery($sql,array());
$minusjob_billdetail_id = $adb->query_result($result,0,'usereportid');
$page_addurl='&report_name=minusjob_billdetail&UseReport='.$minusjob_billdetail_id.
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

$singin_statistics_url = 'index.php?pageto_module='.$currentModule.'&pageto_action=newindex&page_addurl='.$page_addurl;

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