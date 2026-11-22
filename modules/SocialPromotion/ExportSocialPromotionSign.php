<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
$_REQUEST['diony']='yes';
global  $currentModule, $current_user, $theme, $adb;
global $list_max_entries_per_page_new_more;
include('PHPExcel/PHPExcel.php');
$userid=$current_user->id;
$focus = CRMEntity::getInstance($currentModule);
$record=$_REQUEST['record'];
$focus->retrieve_entity_info($record, $currentModule);
crm_load_class_file("SocialPromotionForm", 'modules/SocialPromotion');
$socialPromotionForm = new SocialPromotionForm($focus->column_fields);
if($_REQUEST['getprogress']=='yes') {//第一次导出
    crm_load_class_file("LoginHistory",'modules/Users');//添加操作日志
    $historyobj=new LoginHistory();
    $historyobj->user_operation_history('Export_customview',$currentModule);
    unset($_SESSION[$currentModule][$current_user->id]['export_related']);
    $_SESSION[$currentModule][$current_user->id]['export_related']['starttime']=date("Y-m-d H:i:s");

    $listcount_sql = 'select id from ld_socialpromotionformfixed where socialpromotionid ='.$record;
    $smownerid = $socialPromotionForm->getSmownerid($record);
    if($userid != $focus->column_fields['smcreatorid'] && $userid != $smownerid) {
        $listcount_sql .= 'and userid = ' . $userid;
    }
    $listcount_result = $adb->pquery($listcount_sql,array());
    $listcounts=$adb->num_rows($listcount_result);
    $_SESSION[$currentModule][$current_user->id]['export_related']['listcounts']=$listcounts;
    $_SESSION[$currentModule][$current_user->id]['export_related']['exportgetcount']="##SUCCESS##". $listcounts;
}else{//后续导出行数延用第一步保存的session值
    $listcounts = $_REQUEST['listcounts']??$_SESSION[$currentModule][$current_user->id]['export_related']['listcounts'];
}

if(isset($_REQUEST['startexportrow']) && $_REQUEST['startexportrow'] != '') {
    $startexportrow = vtlib_purify($_REQUEST['startexportrow']);
}else{
    $startexportrow=0;
}
if(isset($_REQUEST['eachexportcount']) && $_REQUEST['eachexportcount'] != '') {
    $eachexportcount = vtlib_purify($_REQUEST['eachexportcount']);
}else{
    $eachexportcount=$list_max_entries_per_page_new_more;
}
$_SESSION[$currentModule][$current_user->id]['export_related']['startexportrow']=$startexportrow;

//新建excel对象
$pathname='storage/'.$current_user->id.'_'.$currentModule.'_related.xls';
if(array_key_exists('objphpexcel',$_SESSION[$currentModule][$current_user->id]['export_related'])) {
    $objPHPExcel = PHPExcel_IOFactory::load($pathname);
} else {
    $objPHPExcel = new PHPExcel();
    $_SESSION[$currentModule][$current_user->id]['export_related']['objphpexcel']=serialize($objPHPExcel);
}
$objPHPExcel->setActiveSheetIndex(0);
$activesheet=$objPHPExcel->getActiveSheet();
$activesheet->setTitle(getTranstab($focus->column_fields['mappingmodule']));
$objWriter = PHPExcel_IOFactory::createWriter($objPHPExcel, 'Excel5');

//列表体
$exportData = $socialPromotionForm->get_SocialPromotionExport($currentModule, $record, $focus->column_fields['mappingmodule'], $focus->column_fields['smcreatorid'],$startexportrow,$eachexportcount);

//列表头
$listview_header = $exportData['header'];
foreach($listview_header as $key=>$arr){
    $listview_header[$key]=strip_tags($arr);
}

crm_load_class_file('cls_ExportListView','include/ListView/ExportListView');
$Header_FromArray = cls_ExportListView::getListHeaderFormArray();
foreach($listview_header as $key=>$arr){
    $activesheet->getStyle(PHPExcel_Cell::stringFromColumnIndex($key) . '1')->applyFromArray($Header_FromArray);
    $activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex($key).'1',trim($arr));
    $objPHPExcel->getActiveSheet()->getColumnDimension(PHPExcel_Cell::stringFromColumnIndex($key))->setWidth(20);
}

$prev_totalrows=0;
$nums =$eachexportcount/2;
$step = ($eachexportcount/$nums);
$exportData_chunk=array_chunk($exportData['entries'], $nums);
if($startexportrow<$listcounts ||$_REQUEST['getprogress']=='yes')
{
    if(array_key_exists('exportprev_totalrows',$_SESSION[$currentModule][$current_user->id]['export_related'])) {
        $prev_totalrows=$_SESSION[$currentModule][$current_user->id]['export_related']['exportprev_totalrows'];
    }
    for($s = 0; $s < $step; ++$s) {
        $listview_entries = $exportData_chunk[$s];
        //dump($listview_entries);
        $a=2;
        foreach($listview_entries as $key=>$arr){
            $key2 = 0;
            foreach($arr as $columnname=>$arr2){
                $activesheet->setCellValueExplicit(PHPExcel_Cell::stringFromColumnIndex($key2) . ($key + $a + ($prev_totalrows)), trim($arr2), PHPExcel_Cell_DataType::TYPE_STRING);
                $key2++;
            }
        }
        $prev_totalrows+= count($listview_entries);
        unset($listview_entries);
    }
    $_SESSION[$currentModule][$current_user->id]['export_related']['exportprev_totalrows']=$prev_totalrows;
    $objWriter->save($pathname);
    $ret_arr['endexportrow']=$exportData['endexportrow'];
    $ret_arr['listcount']=$listcounts;
    ConvertTojsonString(1,$ret_arr,'success');
}
else {
    //导出完毕,开始下载
    unset($_SESSION[$currentModule][$current_user->id]['export_related']);
    ConvertTojsonString(2,'','success');
}

?>