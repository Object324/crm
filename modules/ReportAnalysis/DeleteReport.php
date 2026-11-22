<?php
//删除报表 由于报表来自五个表的表数据  需要判断
global $adb,$languageType,$smarty;
$_REQUEST['diony']='yes';
//判断是否有删除权限
if(isPermitted('ReportAnalysis','Delete')=='no'){
    $res = ['code'=>0,'msg'=>getFixedLabel('NoPermission')];
}else{
    $report_id = $_REQUEST['report_id'];
    $modulename = $_REQUEST['modulename'];
    switch ($modulename) {
        case 'OftenUseReport'://常用报表 ld_usereport usereportid
            $delete_sql = "update ld_usereport set deleted=1 where usereportid=?";
            $res = $adb->pquery($delete_sql, [$report_id]);
            //做成的链接模块如何处理？？？ -- todo--
            //新的需求是常用報表不允許刪除的，这里不需要处理
            break;
        case 'Customreport'://报表库 ld_customreport_info  report_id
            $query = 'select report_type,folder_id from ld_customreport_info where report_id = ? limit 1';
            $result = $adb->pquery($query,array($report_id));
            if($adb->num_rows($result) >= 1){
                $report_type = $adb->query_result($result,0,'report_type');
                $folder_id = $adb->query_result($result,0,'folder_id');

                $delete_sql = "update ld_customreport_info set deleted=1 where report_id=?";
                $res = $adb->pquery($delete_sql, [$report_id]);
                //zxm  2021-0830 删除链接模块
                $sql ='select * from ld_linkmodulecustom where  linkcvid =? and entitytype=? and linkmodule=?';
                if($report_type == 'finereport')
                {
                    $result = $adb->pquery($sql,array($report_id,'customfine','Customreport'));
                }
                else
                {
                    $result = $adb->pquery($sql,array($report_id,'custom','Customreport'));
                }
                $nums = $adb->num_rows($result);
                if($nums>0){
                    $linkmoduleId = $adb->query_result($result,0,'id');
                    //ld_parenttabrel
                    $sql ='delete from ld_linkmodulecustom where id = ?';
                    $adb->pquery($sql,array($linkmoduleId));
                    $sql2 ='delete from ld_parenttabrel where tabid =? and tab_tablename="ld_linkmodulecustom"';
                    $adb->pquery($sql2,array($linkmoduleId));
                    clearAllCaCheFiles();
                }
            }
            break;
        case 'Comprehensivereport'://综合报表 ld_comprehensivereport id
            $delete_sql = "update ld_comprehensivereport set deleted=1 where id=?";
            $res = $adb->pquery($delete_sql, [$report_id]);
            break;
        case 'CustomEcharts'://自定义统计图 ld_customreport report_id
            //查询报表是什么类型 是选字段的还是sql图表
            $delete_sql = "update ld_customreport set deleted=1 where report_id=?";
            $res = $adb->pquery($delete_sql,[$report_id]);
            //删除放在首页组件的数据
            $template_sql = "delete from ld_templatesstuff where stuffid=? and `source`=?";
            $res_template = $adb->pquery($template_sql,[$report_id,'customechart']);
            //index.php?module=ReportAnalysis&action=ReportAnalysisAjax&file=SelfDefinedReport&function_name=getChart&isAjax=no&report_id=209
            $url = 'index.php?module=ReportAnalysis&action=ReportAnalysisAjax&file=SelfDefinedReport&function_name=getChart&isAjax=no&report_id='.$report_id;
            //index.php?module=ReportAnalysis&action=ReportAnalysisAjax&file=SqlEchartsDetailView&function_name=getChart&isAjax=no&report_id=204&report_type=sqlchart
            $urlsql = 'index.php?module=ReportAnalysis&action=ReportAnalysisAjax&file=SqlEchartsDetailView&function_name=getChart&isAjax=no&report_id='.$report_id.'&report_type=sqlchart';
            //删除菜单设置
            $selectSql = "select * from ld_linkmodulecustom where url =? or url =?";
            $selectRes = $adb->pquery($selectSql,array($url,$urlsql));
            $selectNums = $adb->num_rows($selectRes);
            if($selectNums>0) {
                $linkmoduleId = $adb->query_result($selectRes, 0, 'id');
                //ld_parenttabrel
                $sql = 'delete from ld_linkmodulecustom where url =? or url =?';
                $adb->pquery($sql, array($url,$urlsql));
                $sql2 = 'delete from ld_parenttabrel where tabid =? and tab_tablename="ld_linkmodulecustom"';
                $adb->pquery($sql2, array($linkmoduleId));
                //移动端菜单
                $sqlMobile = "delete from ld_mobile_report_tab_rel where tabid =? and tab_tablename='ld_linkmodulecustom'";
                $adb->pquery($sqlMobile, array($linkmoduleId));
            }
            break;
        case 'CustomTables':
            $delete_sql = "update ld_customtable set deleted=1 where report_id=?";
            $res = $adb->pquery($delete_sql, [$report_id]);
            $url = 'index.php?module=CustomTables&action=CustomTablesAjax&file=DetailView&function_name=index&isAjax=no&report_id=' . $report_id;
            $urlnew = 'index.php?module=CustomTables&action=CustomTablesAjax&file=SqlTableDetailView&function_name=index&isAjax=no&report_id=' . $report_id;
            //删除菜单设置
            $selectSql = "select * from ld_linkmodulecustom where url =? or url =?";
            $selectRes = $adb->pquery($selectSql, array($url, $urlnew));
            $selectNums = $adb->num_rows($selectRes);
            if ($selectNums > 0) {
                $linkmoduleId = $adb->query_result($selectRes, 0, 'id');
                //ld_parenttabrel
                $sql = 'delete from ld_linkmodulecustom where url =? or url =?';
                $adb->pquery($sql, array($url, $urlnew));
                $sql2 = 'delete from ld_parenttabrel where tabid =? and tab_tablename="ld_linkmodulecustom"';
                $adb->pquery($sql2, array($linkmoduleId));
                //移动端菜单
                $sqlMobile = "delete from ld_mobile_report_tab_rel where tabid =? and tab_tablename='ld_linkmodulecustom'";
                $adb->pquery($sqlMobile, array($linkmoduleId));

            }
            break;
    }
    ConvertTojsonString(1, [], getFixedLabel('SuccessDeleted'));
}
