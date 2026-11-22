<?php
//删除文件夹 需要判断该文件夹下是否有报表文件  没有的情况下才允许删除
global $adb,$languageType,$smarty;
require_once globalStatic::$root_directory.'modules/ReportAnalysis/ReportAnalysisActions.php';
$_REQUEST['diony']='yes';
$ReportAnalysisActionsObj = new ReportAnalysisActions();
//判断是否有删除权限
if(isPermitted('ReportAnalysis','Delete')=='no'){
    $result = ['code'=>0,'msg'=>getFixedLabel('NoPermission')];
}else{
    $report_id = $_REQUEST['report_id'];
    //删除文件夹 判断其下是否有报表或者文件夹
    $childlist = $ReportAnalysisActionsObj->getReportListByParentId($report_id,'all');

    if(!empty($childlist)){
        $result = ["code"=>0,"msg"=>getFixedLabel('NoDelete')];
    }else{
        $delete_sql = "update ld_report_analysis_folder set deleted=1 where analysisfolder_id=?";
        $res = $adb->pquery($delete_sql,[$report_id]);
        $result = ["code"=>1,"msg"=>getFixedLabel('SuccessDeleted')];
    }

    //ls 2022-02-18 0050029: （https://81mis.com/kfbtest/index.php [^]）自定义报表“ 客户服务 ”已经删除了，但之前设置过得链接模块还在，可以打开
    $url = 'index.php?module=CustomTables&action=CustomTablesAjax&file=DetailView&function_name=index&isAjax=no&report_id='.$report_id;
    //删除菜单设置
    $selectSql = "select * from ld_linkmodulecustom where url =?";
    $selectRes = $adb->pquery($selectSql,array($url));
    $selectNums = $adb->num_rows($selectRes);
    if($selectNums>0){
        $linkmoduleId = $adb->query_result($selectRes,0,'id');
        //ld_parenttabrel
        $sql ='delete from ld_linkmodulecustom where url =?';
        $adb->pquery($sql,array($url));
        $sql2 ='delete from ld_parenttabrel where tabid =? and tab_tablename="ld_linkmodulecustom"';
        $adb->pquery($sql2,array($linkmoduleId));
        //移动端菜单
        $sqlMobile = "delete from ld_mobile_report_tab_rel where tabid =? and tab_tablename='ld_linkmodulecustom'";
        $adb->pquery($sqlMobile,array($linkmoduleId));
    }
}
ConvertTojsonString($result['code'],['res'=>$result['msg']], 'success');
