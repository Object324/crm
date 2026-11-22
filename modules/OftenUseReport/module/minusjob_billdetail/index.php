<?php
//editor:gyq_135 reason:请假明细表  2019/8/6 16:32 ID1000568
crm_load_class_file('TabDetailFields','include/TabDetailFields');
$OftenUseReport = new ReportModel();
//报表名
$OftenUseReport->report_name = $_REQUEST['report_name'];
//`````````报表序时簿默认20条
$OftenUseReport->report_pagerecordcount = 14;
//`````````报表类型
$OftenUseReport->report_parent_type = 'checkin';
//`````````请假单模块
$crm_module = 'MinusJobBill';
//请假单报表，固定显示字段
$static_main_field = array('minusjobbill_no','approvestatus');
$static_detail_field = array('minusjobtype','starttime','endtime','costtime','description');
//`````````获取查询的月度时间范围，默认当月
$startmonth = $_REQUEST['startmonth'];
if(empty( $startmonth)){
    $month = date('Y-m');
    $month_start = strtotime($month) ;//指定月份月初时间戳
    $month_end = mktime(23, 59, 59, date('m', strtotime($month))+1, 00);//指定月份月末时间戳
}else{
    $month_start =  strtotime( $startmonth.' 00:00:00');
    $month_end = strtotime( $_REQUEST['endmonth'].' 23:59:59');
}
//格式化的时间区间
$month_start_date = date('Y-m-d H:i:s',$month_start) ;
$month_end_date = date('Y-m-d H:i:s',$month_end) ;
//```````````获取部门名称列表
$group_label_list = $OftenUseReport->group_label_list();
//```````````获取用户查看范围
$select_userid = $OftenUseReport->SmOwnerSearchScope();
//`````````请假单统计
$page_list_query = 'select b.smownerid,c.wx_userid,c.last_name,ld_group.groupid,b.minusjobbill_no,b.approvestatus, a.minusjobtype,
                      a.starttime,a.endtime,a.costtime,a.description from ld_minusjobbilldetail a
                      left join ld_minusjobbill b on a.id=b.minusjobbillid
                      left join ld_users c on b.smownerid=c.id 
					  LEFT JOIN (
							select GROUP_CONCAT(ld_groups.groupname order by ld_groups.groupid) as groupname,
													GROUP_CONCAT(ld_groups.groupid order by ld_groups.groupid ) as groupid,
													ld_users2group.userid from ld_users2group
							LEFT JOIN ld_groups on ld_groups.groupid = ld_users2group.groupid
							GROUP BY ld_users2group.userid
						) as ld_group on ld_group.userid = b.smownerid 
                      where c.deleted=0 and c.id in('.$select_userid.') and
                    a.starttime between ? and ? 
                      order by a.id desc,a.starttime asc';
if($_REQUEST['Print']=='true'){
    //wym XUQIU1002296 打印不用分页
}else{
    $multi_result = $OftenUseReport->page_list_result($page_list_query,array($month_start_date,$month_end_date));
    $page_list_query = $multi_result['page_list_query'];
}
$result = $adb->pquery($page_list_query,array($month_start_date,$month_end_date));

$list_day = array();
$list = array();
for ($i=0;$i<$adb->num_rows($result);$i++){
    $list[$i]['last_name'] = $adb->query_result($result,$i,'last_name');
    $userObj=new Users();
    $userObj->wx_userid= $adb->query_result($result,$i,'wx_userid');
    $userObj->last_name= $adb->query_result($result,$i,'last_name');
    $list[$i]['last_name']=getUserlastName($userObj);
    $groupid = $adb->query_result($result,$i,'groupid');
    $groupid_list = explode(',',$groupid);
    foreach ($groupid_list as $key=>$value){
        $groupobj=new Users();
        $groupobj->groupid=$value;
        $groupobj->groupname=$group_label_list[$value];
        $groupid_list[$key] = getWx_GroupName($groupobj);
    }
    $group_label = implode(',',$groupid_list);
    $list[$i]['groupid'] = $group_label;
    $list[$i]['minusjobbill_no'] = $adb->query_result($result,$i,'minusjobbill_no');
    $list[$i]['approvestatus'] = $adb->query_result($result,$i,'approvestatus');
    $list[$i]['minusjobtype'] = $adb->query_result($result,$i,'minusjobtype');
    $list[$i]['starttime'] = $adb->query_result($result,$i,'starttime');
    $list[$i]['endtime'] = $adb->query_result($result,$i,'endtime');
    $list[$i]['costtime'] = $adb->query_result($result,$i,'costtime');
    $list[$i]['description'] = $adb->query_result($result,$i,'description');
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
//``````````请假单报表显示列头字段
$exportheader = array(getFixedLabel('Name'),getFixedLabel('Sector'));
$reportFindHeader = '';
$focus = CRMEntity::getInstance($crm_module);
$main_fields = $focus->fieldobj->getFieldLables();
foreach ($static_main_field as $key=>$value){
    $exportheader[] = $main_fields[$value];
}
$detailfieldobj=TabDetailFields::getInstance($crm_module);
$detail_fields = $detailfieldobj->getTabDetailFields();
$detail_fields_label = array();
foreach ($detail_fields as $key=>$value){
    $detail_fields_label[$key] = $value->fieldLableKey;
}
foreach ($static_detail_field as $key=>$value){
    $exportheader[] = $detail_fields_label[$value];
}
foreach ($exportheader as $value){
    $reportFindHeader.='<th>&nbsp;'.$value.'</th>';
}
//报表底部
include globalStatic::$root_directory.'modules/OftenUseReport/module/index_report_bottom.php';
?>