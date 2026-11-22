<?php
//ls 2021-12-27 【1002356】公费电话直拨支持数据统计报表（蔡云桥-山水）
$OftenUseReport = new ReportModel();
//报表名
$OftenUseReport->report_name = $_REQUEST['report_name'];
//`````````报表类型

$OftenUseReport->report_parent_type = 'checkin';

//`````````获取查询的月度时间范围，默认当月
$start_time = $_REQUEST['startmonth'];
if(empty($start_time)){
    $month = date('Y-m');
    $start_time = strtotime($month);//指定月份月初时间戳
    $end_time = mktime(23, 59, 59, date('m', strtotime($month))+1, 00);//指定月份月末时间戳
}else{
    $start_time =  strtotime( $start_time.' 00:00:00');
    $end_time = strtotime( $_REQUEST['endmonth'].' 23:59:59');
}

//```````````获取部门名称列表
$group_label_list  = $OftenUseReport->group_label_list();
//```````````获取用户查看范围
$select_userid = $OftenUseReport->SmOwnerSearchScope();


//列表数据
$sql = "SELECT t3.wx_userid,t3.id AS user_id,t3.groupid,t3.last_name,t1.*,t2.callee_wx_userid,t2.callee_phone,t2.callee_duration FROM ld_dial_record t1 
LEFT JOIN ld_dial_record_details t2 ON t2.dialid=t1.id 
LEFT JOIN ld_users t3 ON t3.wx_userid = t1.caller_wx_userid
WHERE t3.id in(".$select_userid.") AND t1.call_time BETWEEN ? AND ? ORDER BY t1.id DESC ";
$result = $adb->pquery($sql,array(date('Y-m-d H:i:s',$start_time),date('Y-m-d H:i:s',$end_time)));
//echo $sql;dump(array(date('Y-m-d H:i:s',$start_time),date('Y-m-d H:i:s',$end_time)));
$nums = $adb->num_rows($result);
$list = array();
$line = 0;

for($i=0;$i<$nums;$i++){
    $id = $adb->query_result($result,$i,'id');

    $wx_userid = $adb->query_result($result,$i,'wx_userid');
    $userobj = new Users();
    $userobj->wx_userid = $wx_userid;
    $userobj->last_name = $adb->query_result($result, $i, 'last_name');
    $last_name = getUserlastName($userobj);
    if(!array_key_exists($id,$list))
    {
        $list[$id]=[];
    }
    $rowindex=sizeof($list[$id]);

    $list[$id][$rowindex]['idx'] = $id;
    $list[$id][$rowindex]['lastname'] = empty($last_name)?$wx_userid:$last_name;

    $groupid = $adb->query_result($result,$i,'groupid');
    $groupid_list = explode(',',$groupid);
    foreach ($groupid_list as $key=>$value){
        $groupobj=new Users();
        $groupobj->groupid=$value;
        $groupobj->groupname=$group_label_list[$value];
        $groupid_list[$key] = getWx_GroupName($groupobj);

    }
    $group_label = implode(',',$groupid_list);
    $list[$id][$rowindex]['groupname'] = $group_label;

    $list[$id][$rowindex]['call_type'] = $adb->query_result($result,$i,'call_type');
    $list[$id][$rowindex]['call_time'] = $adb->query_result($result,$i,'call_time');
    $list[$id][$rowindex]['total_duration'] = $adb->query_result($result,$i,'total_duration');
    $list[$id][$rowindex]['caller_duration'] = $adb->query_result($result,$i,'caller_duration');

    $callee_name = '';
    $callee_wx_userid = $adb->query_result($result,$i,'callee_wx_userid');
    if (!empty($callee_wx_userid)) {//被叫用户为公司内部成员
        $tmp_result = $adb->pquery("select last_name from ld_users where wx_userid = ? ",array($callee_wx_userid));
        if ($adb->num_rows($tmp_result) > 0) {
            $userobj = new Users();
            $userobj->wx_userid = $callee_wx_userid;
            $userobj->last_name =  $adb->query_result($tmp_result,0,'last_name');
            $callee_name = getUserlastName($userobj);
        }
    }

    $list[$id][$rowindex]['callee_wx_userid'] = empty($callee_name)?$callee_wx_userid:$callee_name;
    $list[$id][$rowindex]['callee_phone'] = $adb->query_result($result,$i,'callee_phone');
    $list[$id][$rowindex]['callee_duration'] = $adb->query_result($result,$i,'callee_duration');

}
//dump($list);


//``````````报表内容
$tmp_exist_idx = [];
$html_content = '';
$line = 0;
foreach ($list as $i=>$content){
    $trclass = 'lvtColData';
    $tr_on = 'on';
    if($i % 2 != 0){
        $trclass = 'lvtColDataBj';
        $tr_on = 'On';
    }

    $rowspan = count($content);
    foreach ($content as $key=>$value){
        $html_content .='<tr id="report_'.$line.'" idx='.$value['idx'].' class="'.$trclass.'" onmouseover="listOnMouseOver(ld(this))" onmouseout="listOnMouseOut(ld(this),\''.$tr_on.'\')">';
        if (!in_array($value['idx'],$tmp_exist_idx)) {
            $html_content .= '<td rowspan='.$rowspan.'>' . $value['lastname'] . '</td>';
            $html_content .= '<td rowspan='.$rowspan.'>' . $value['groupname'] . '</td>';
            $html_content .= '<td rowspan='.$rowspan.'>' . $value['call_type'] . '</td>';
            $html_content .= '<td rowspan='.$rowspan.'>' . $value['call_time'] . '</td>';
            $html_content .= '<td rowspan='.$rowspan.'>' . $value['total_duration'] . '</td>';
            $html_content .= '<td rowspan='.$rowspan.'>' . $value['caller_duration'] . '</td>';
        }
        $html_content .= '<td>' . $value['callee_wx_userid'] . '</td>';
        $html_content .= '<td>' . $value['callee_phone'] . '</td>';
        $html_content .= '<td>' . $value['callee_duration'] . '</td>';
        $html_content .= '</tr>';

        array_push($tmp_exist_idx,$value['idx']);
        $line++;
    }

}
$REPORTFILTERHTML = $html_content;
//是否显示显示列设置按钮,不显示
$setcolumns = 0;
//筛选栏第一行
$basicfilterHtml = '';
//````````筛选栏第二行，自定义日期
$thequerytime = date('Y-m-d',$start_time) . ' ' . '-' . ' ' . date('Y-m-d',$end_time);
//editor:gyq_20190830 reason:0037972: （1.6）常用报表->月度考勤统计表：“自定义日期”和人员范围标签没有上下居中
$basicfilterHtml2 = '<label class="Name changeday" style="padding:0;padding-right: 5px;margin-bottom: 0px !important;line-height: 29px;">
                                                                    <span style="font-weight:normal;">'. getFixedLabel('DATESELECTION') .':&nbsp;</span> </label>';
$data_system = "width:180px;padding-left:3px;margin-right:10px;";
$basicfilterHtml2 .= "<input class='borderALL btn-radius-system' type='text' readonly=true value='$thequerytime' id='startmonth' name='startmonth' findcolumn= 'time' style='" . $data_system . "'/>";

//报表底部
include globalStatic::$root_directory.'modules/OftenUseReport/module/index_report_bottom.php';
?>