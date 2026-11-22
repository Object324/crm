<?php

include('PHPExcel/PHPExcel.php');
$objPHPExcel = new PHPExcel();
$objPHPExcel->setActiveSheetIndex(0);
$activesheet=$objPHPExcel->getActiveSheet();

global $adb;
$Start_Date1=$_REQUEST['Start_Date1'];
$End_Date1=$_REQUEST['End_Date1'];
$moduleNames=$_REQUEST['type'];
$baobiao=array(); // 报表数据
crm_load_class_file('cls_Report_Sql','modules/Customreport');

switch($moduleNames){
    case 'IndirectProjectSummaryReport':
        $file_name = 'IndirectProjectSummaryReport';
        $query = cls_Report_Sql::getInDriectProjectSummaryReport();
        
        $result = $adb->pquery($query,array($Start_Date1,$End_Date1,$Start_Date1,$End_Date1));
        $num_rows = $adb->num_rows($result);

    $baobiao=array(); // 报表数据
    for($i = 0; $i<$num_rows; $i++){
        $baobiao[$i]['expensetype'] = $adb->query_result($result,$i,'expensetype');
        $baobiao[$i]['subjectcode'] = $adb->query_result($result,$i,'subjectcode');
        $baobiao[$i]['subjectsummary'] = $adb->query_result($result,$i,'subjectsummary');
        $baobiao[$i]['usercategory'] = $adb->query_result($result,$i,'usercategory');
        $baobiao[$i]['subjectcode2'] = $adb->query_result($result,$i,'subjectcode2');
        $baobiao[$i]['rmb_tota'] = $adb->query_result($result,$i,'rmb_tota');
    }
        
        $listview_header = array('Business Reason','对应科目代码','对应科目摘要','人员类别','科目二级明细','Total (in RMB)');

        break;
    case 'IndirectReportDetail':
        $file_name = 'IndirectReportDetail';
        $query = cls_Report_Sql::getInDirectReportDetail();  
           
    $result=$adb->pquery($query,array($Start_Date1,$End_Date1,$Start_Date1,$End_Date1));
    $num_rows=$adb->num_rows($result);

	for($i = 0; $i<$num_rows; $i++){
	   // $baobiao[$i]['expensedetailid'] = $adb->query_result($result,$i,'expensedetailid');
        $baobiao[$i]['last_name'] = $adb->query_result($result,$i,'last_name');
        $baobiao[$i]['Startdate'] = $adb->query_result($result,$i,'startdate');
        $baobiao[$i]['indirect'] = $adb->query_result($result,$i,'indirect');
        $baobiao[$i]['expensetype'] = $adb->query_result($result,$i,'expensetype');
        $baobiao[$i]['subjectcode'] = $adb->query_result($result,$i,'subjectcode');
        $baobiao[$i]['subjectsummary'] = $adb->query_result($result,$i,'subjectsummary');
        $baobiao[$i]['usercategory'] = $adb->query_result($result,$i,'usercategory');
        $baobiao[$i]['subjectcode2'] = $adb->query_result($result,$i,'subjectcode2');
        $baobiao[$i]['subjectsummary2'] = $adb->query_result($result,$i,'subjectsummary2');
        $baobiao[$i]['rmb_tota'] = $adb->query_result($result,$i,'rmb_tota');
    }	
            $listview_header = array('Name','Date','Indirect','Business Reason','对应科目代码','对应科目摘要','人员类别','二级科目','二级科目摘要','Total (in RMB)');
        break;
    case 'DriectProjectSummaryReport':
    $file_name='DriectProjectSummaryReport';
    
    $query = cls_Report_Sql::getDriectProjectSummaryReport();

    $result = $adb->pquery($query,array($Start_Date1,$End_Date1));
    $num_rows = $adb->num_rows($result);
    
    for($i = 0; $i<$num_rows; $i++){
        $baobiao[$i]['po_no'] = $adb->query_result($result,$i,'po_no');
        $baobiao[$i]['subjectcode'] = $adb->query_result($result,$i,'subjectcode');
        $baobiao[$i]['subjectsummary'] = $adb->query_result($result,$i,'subjectsummary');
        $baobiao[$i]['rmb_tota'] = $adb->query_result($result,$i,'rmb_tota');
    }
      
    $listview_header = array('PO#','统一科目代码5121.00',"证摘要统一显示 \"Direct\"",'凭Total (in RMB)'); 
      break;
    case 'DriectReportDetail':
        $file_name='DriectReportDetail';
        $query = cls_Report_Sql::getDirectReportDetail();
    
        $result = $adb->pquery($query,array($Start_Date1,$End_Date1));
        $num_rows = $adb->num_rows($result);
        for($i = 0; $i<$num_rows; $i++){
            
            $baobiao[$i]['last_name'] = $adb->query_result($result,$i,'last_name');
            $baobiao[$i]['Startdate'] = $adb->query_result($result,$i,'startdate');
            $baobiao[$i]['po_no'] = $adb->query_result($result,$i,'po_no');
            $baobiao[$i]['expensetype'] = $adb->query_result($result,$i,'expensetype');
            $baobiao[$i]['subjectcode'] = $adb->query_result($result,$i,'subjectcode');
            $baobiao[$i]['subjectsummary'] = $adb->query_result($result,$i,'subjectsummary');
            $baobiao[$i]['rmb_tota'] = $adb->query_result($result,$i,'rmb_tota');
        }
        $listview_header = array('Name','Date','PO#','usiness Reason','对应会计科目','对应科目摘要','Total (in RMB)');
    
}

//edit: xll 2023/08/03 BUG0070673 导出优化，系统导出的excel表格的表头应有底色，标题应加粗
crm_load_class_file('cls_ExportListView','include/ListView/ExportListView');
$Header_FromArray = cls_ExportListView::getListHeaderFormArray();
foreach($listview_header as $key=>$arr){
    $activesheet->getStyle(PHPExcel_Cell::stringFromColumnIndex($key) . '1')->applyFromArray($Header_FromArray);
    $activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex($key).'1',trim($arr));
}   
$j = 2;
foreach($baobiao as $key=>$arr){
    $i = 0;
    foreach($arr as $key2=>$arr2){
      // $activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex($key2).($key+($i*$page_count)),trim($arr2)); 
        $activesheet->setCellValueExplicit(PHPExcel_Cell::stringFromColumnIndex($i).$j, trim($arr2),PHPExcel_Cell_DataType::TYPE_STRING);
        $i++;
    }
    $j++;
}
$modulelabel = getTranstab('OftenUseReport');
$modulelabel = str_replace(' ','_',iconv('UTF-8','gbk',$modulelabel));
$reportname=$_REQUEST['action'];
$file_dir = 'storage/';

$objPHPExcel->getActiveSheet()->setTitle('OftenUseReport');
$objWriter = PHPExcel_IOFactory::createWriter($objPHPExcel, 'Excel5');
$objWriter->save($file_dir.$file_name.'.xls');
echo $file_name; //不能删除
exit();
?>