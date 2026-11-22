<?php
//editor:gyq_135 reason:常用报表公共底部  2019/8/14 14:30 ID1000568
require_once globalStatic::$root_directory.'Smarty_setup.php';
$smarty=new lingdangCRM_Smarty();
setGLobalURLSmarty($smarty);//设置js,css等访问路径
$sql='select * from ld_version';
$result=$adb->pquery($sql,array());
$trade=$adb->query_result($result,0,'trade');
//生成左边报表列表
$left_report_list = $OftenUseReport->left_report_list($smarty,$trade);
$reportHeader = $left_report_list['header'];
$usereportid = $left_report_list['default'];
if($_REQUEST['refreshUseReport']>0){
    //刷新界面的ID
    //40083: （51mis.com/kfbtest）常用报表>选择“库存台账”报表：选择后刷新界面，刷新后自动跳转到了“签到统计表”，而不是停留在刷新前的报表界面中。
    $_REQUEST['UseReport']=$_REQUEST['refreshUseReport'];
}
if(isset($_REQUEST['UseReport'])) {
    $usereportid=$_REQUEST['UseReport'];
}
require_once(globalStatic::$root_directory.'modules/OftenUseReport/renderHtml.php');
$renderHtmlObj = new renderHtml();
//报表名称以及报表其他信息
$renderHtmlObj->setReportId($usereportid);
$reportInfo = $renderHtmlObj->getReportInfo();
//dump($reportInfo);
$reportname = $reportInfo['reportname'];
$smarty->assign("reportlabel",getFixedLabel($reportname));
//获取当前查询的报表类型
$sql='select reporttype,tabids,parent_id,basicfilter,advfilter,setcolumns,name ,pagewidthpercent 
      from ld_usereport where usereportid=?';
$result=$adb->pquery($sql,array($usereportid));
$nums_result = $adb->num_rows($result);
if($nums_result > 0){
    $reporttype=$adb->query_result($result,0,'reporttype');
    $reportabid=$adb->query_result($result,0,'tabids');
    $reportname = $reportnames = $OftenUseReport->report_name = $adb->query_result($result,0,'name');
    $parentid=$adb->query_result($result,0,'parent_id');
    $basicfilter=$adb->query_result($result,0,'basicfilter');
    $advfilter=$adb->query_result($result,0,'advfilter');
    if(empty($setcolumns) && $setcolumns !== 0)
        $setcolumns=$adb->query_result($result,0,'setcolumns');
    $pagewidthpercent=$adb->query_result($result,0,'pagewidthpercent');
}else{
    exit;
}

//列头查询设置

$reportcolumn_content = $OftenUseReport->reportcolumns($usereportid);
$AllReportHeaders = $reportcolumn_content['AllReportHeaders'];
//导出时Excel表格列头
if(empty($exportheader))
    $exportheader = $reportcolumn_content['exportheader'];
$showcolLists = $reportcolumn_content['showcolLists'];
$fieldnames = $reportcolumn_content['fieldnames'];
//报表列头显示字段

if(empty($reportFindHeader))
    $reportFindHeader = $reportcolumn_content['reportFindHeader'];
//月度考勤表
if($OftenUseReport->report_name=='checkin_monthly'){
    foreach ($jobtype as $key=>$value){
        $reportFindHeader .='<th>&nbsp;'.$value.'</th>';
        $exportheader[] = $value;
    }
}
//editor:gyq_122 reason:删除__construct复杂参数，抽成新方法init_params 2019/6/13 17:31
//editor:gyq_20190726 reason:init_params放到操作按钮代码上面导致序时簿没有操作按钮！！！！！！！！
$OftenUseReport->init_params($reporttype,$reportname,$usereportid,$adb,$showcolLists,$AllReportHeaders,$reportabid,$advfilter);
//打印
if($_REQUEST['ajax']&&$_REQUEST['ajax']=='true'&&$_REQUEST['Export']=='true')
{
    //editor:gyq_20191216 reason:0038913: 安装包、升级包>常用报表>考勤异常明细表、月度考勤统计表、请假明细表、：点击导出Excel报错。
    $OftenUseReport->report_export($exportheader,$REPORTFILTERHTML,'yes');
}
//```````分页HTML
if(!empty($OftenUseReport->page_html_arr)){
    
    $page_html_arr = $OftenUseReport->page_html_arr;
    $smarty->assign("parent_type", $OftenUseReport->report_parent_type);
    $smarty->assign("recordListRange", $page_html_arr['total']);
    $smarty->assign("NAVIGATION", $page_html_arr['redirect_num']);
}

//editor:gyq_135 reason:标识报表新结构  2019/8/8 21:57 ID1000568
$smarty->assign("INDEX_REPORT",'index_report');
//左侧报表列
$smarty->assign("USEREPORTS",$reportHeader);
//人员范围
$smarty->assign('Merge_SmOwner',$OftenUseReport->Merge_SmOwner());
//当前报表名称
$smarty->assign("USEREPORTSNAME",$reportnames);

//当前报表ID
$smarty->assign("USEREPORTID",$usereportid);
//模块ID
$smarty->assign('TABID',getTabid('OftenUseReport'));
//报表列头显示字段

$smarty->assign('REPORTFINDHEADER',$reportFindHeader);
//是否显示显示列设置按钮
$smarty->assign('SETCOLUMNS',$setcolumns);
//自定义日期用时间数组
$smarty->assign("DATETIMESTR",json_encode(CommonView::stdFilterDateTimeStr()));
//基本查找
$smarty->assign('BASICFILTER',$basicfilter);
//高级查找
$smarty->assign('ADVFILTER',$advfilter);
//报表div宽度
$smarty->assign('PAGEWIDTHPERCENT',$pagewidthpercent);
//筛选栏第一行
$smarty->assign("BASICFILTERHTML",$basicfilterHtml);
//筛选栏第二行，基本查询字段
$smarty->assign("BASICFILTERHTML2",$basicfilterHtml2);
//月度考勤表跳转考勤异常明细表，默认选中用户
$smarty->assign("SmOwnerSearchScope",$SmOwnerSearchScope);
//报表内容
$smarty->assign('REPORTFILTERHTML',$REPORTFILTERHTML);
//高级查找下拉框字段
$smarty->assign("FIELDNAMES", $fieldnames);
//没看懂
if(!isset($_REQUEST['searchtype']))
{
    $_REQUEST['searchtype']='BasicSearch';
    $_REQUEST['startmonth']=$startdatemonth.' 00:00:00';
    $_REQUEST['endmonth']=$enddatemonth.' 23:59:59';
    $_REQUEST['datefindcolumn']=$datefindcolumn;
    $smarty->assign('SEARCHTYPE','BasicSearch');
} else {
    $smarty->assign('SEARCHTYPE',$_REQUEST['searchtype']);
}
//tpl中js的路径前缀
$smarty->assign("JSURL","");
$smarty->assign("APP",$app_strings);
//获取人员范围
//$smarty->assign("ARRUSER",$OftenUseReport->users_combo());
$smarty->assign('CHECKLABEL',getSalesRankingType($salesranking_value));

$smarty->assign("isADMIN",is_admin($current_user));

$smarty->assign("THEME", $theme);
$smarty->assign("REPORTNAMES", getFixedLabel($reportnames));
$smarty->assign("MODULE", $currentModule);
$smarty->assign("IMAGE_PATH", $image_path);
$smarty->assign('WORKTYPE',$_REQUEST['worktype']);
//editor:gyq_155 reason:钉钉考勤同步  2019/10/31 9:55 ID1000624
$smarty->assign('INTERFACETYPE',$interfaceType);
//wym XUQIU1002296 请假明细表、考勤异常明细表：增加“打印、导出”操作按钮
if($reportnames=='checkin_monthly' || $reportnames=='dial_record' ||  $reportnames=='minusjob_billdetail'||  $reportnames=='checkin_abnormal'){//月度签到考勤统计表
    $smarty->assign("ExportExcelPermit",isPermitted($currentModule,"Export"));//增加打印和导出excel权限判断
    $smarty->assign("PrintPermit",isPermitted($currentModule,"Print"));
}

if(empty($reportnames)){//所有报表都没有显示的情况下
    echo getFixedLabel('NOREPORTEAVAIL');
    exit();
}

//界面输出
if($_REQUEST['ajax']&&$_REQUEST['ajax']=='true')
{
    
    if($_REQUEST['Print']!='true'){
        echo '###SUCCESS###';
        if($reportname=='USERTRACKREPORT'){
            ob_clean();
            echo json_encode($points);
        }else{
            if($_REQUEST['usereport_search'] == 'yes' && $reportnames == 'InventoryLedger'){
                $smarty->display("modules/OftenUseReport/UseReportEntries.tpl");
            }else{
                $smarty->display("modules/OftenUseReport/UseReportListContent.tpl");
            }
            
        }
    }else{
         
        
        $smarty->display("modules/OftenUseReport/UseReportPrint.tpl");
        
        //$smarty->display("modules/OftenUseReport/NewUseReportList.tpl");
       
    }
    
    exit();
}else if($_REQUEST['frommodule']=='ReportAnalysis'||$currentModule=='ReportAnalysis'){
    //报表分析模块来的请求
    $smarty->assign('frommodule','ReportAnalysis');//如果是报表分析来的请求 把中间的报表菜单隐藏

    $listtype = $_REQUEST['listtype'];
    $listtype = empty($listtype)?'list':$listtype;
    $smarty->assign('listtype',$listtype);//如果是报表分析来的请求 把中间的报表菜单隐藏
    if($listtype=='screen'){
        $content = $smarty->fetch("ReportAnalysis/NewUseReportList.tpl");
        ConvertTojsonString(1,['content'=>$content],'success');
    }else{
        $smarty->display("ReportAnalysis/NewUseReportList.tpl");
    }
}
else if(isset($_REQUEST['refreshUseReport']))
{
    
    $smarty->display("modules/OftenUseReport/NewUseReportList.tpl");

}

else{
    //editor:gyq_170 reason:0039507  2020/3/10 11:32
    //0039507: （51mis.com/kfbtest）报表>常用报表：“月度考勤统计表”，“请假明细表”，“考勤异常明细表”点击提示“undefined”
    //BUG0053305	已分派	严重	zxm 常用报表->月度考勤统计表，点击“异常天数”显示值，界面显示乱码
    if($_REQUEST['leftmenuclick']=='yes'){
        echo '###SUCCESS###';
    }

    
    $smarty->display("modules/OftenUseReport/LeftClickContent.tpl");
    exit();
    //$smarty->display("modules/OftenUseReport/UseReportList.tpl");
}