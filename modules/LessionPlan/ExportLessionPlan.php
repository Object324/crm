<?php
/**
 * 更新操作
 * edit:andrew
 * date:20140126
 * reason:导出模板文件
 * */
global $adb;

global $app_strings, $mod_strings, $currentModule, $theme;
global $list_max_entries_per_page_new;
global $current_user;
require_once('include/ListView/ListViewSession.php');
require_once("modules/$currentModule/$currentModule.php");
require_once("include/ProductDetails/ProductDetails.php");
require('user_privileges/user_privileges_'.$current_user->id.'.php');
unset($_REQUEST['search_field']);
unset($_REQUEST['search_text']);
unset($_REQUEST['SearchScope']);
unset($_REQUEST['searchtype']);
unset($_REQUEST['type']);
unset($_REQUEST['advft_criteria']);
unset($_REQUEST['advft_criteria_groups']);
unset($_REQUEST['SearchScope']);
unset($_REQUEST['searchtype']);
$page_count=500;
include('PHPExcel/PHPExcel.php');
$objPHPExcel = new PHPExcel();
$objPHPExcel->setActiveSheetIndex(0);
$activesheet=$objPHPExcel->getActiveSheet();
$modulelabel = getTranstab('LessionPlan');
$objPHPExcel->getActiveSheet()->setTitle($modulelabel);
$modulelabel = str_replace(' ','_',iconv('UTF-8','gbk',$modulelabel));

$objWriter = PHPExcel_IOFactory::createWriter($objPHPExcel, 'Excel5');

$category = getParentTab();
$warehouseid = 0;
$morelist = 0;
$url_string = '';


$focus = CRMEntity::getInstance($currentModule);
//$focus->initSortbyField($currentModule);
if(ListViewSession::hasViewChanged($currentModule,$viewid)) {
	$_SESSION[$currentModule."_Order_By"] = '';
}
$sorder = $focus->getSortOrder();
$order_by = $focus->getOrderBy();

$_SESSION[$currentModule."_Order_By"] = $order_by;
$_SESSION[$currentModule."_Sort_Order"]=$sorder;
$morelist = 1;

// Custom View
$customView = new CustomView($currentModule);

$viewid = $customView->getViewId($currentModule);

$queryGenerator = new QueryGenerator($currentModule, $current_user,$customView);


///得到对应视图的查询字段
if ($viewid != "0") {
   $queryGenerator->initForCustomViewById($viewid);
} else {
	$queryGenerator->initForDefaultCustomView();
}

// Enabling Module Search
$url_string = '';
if($_REQUEST['query'] == 'true') {
     $queryGenerator->addUserSearchConditions($_REQUEST);
	$ustring = getSearchURL($_REQUEST);
	$url_string .= "&query=true$ustring";
	
   
}
$search_type = $_REQUEST['search_type'];
$params = array();
if($_REQUEST['idstring']!=''&&$search_type == 'selecteddata'&&$_REQUEST['idstring']!='all'){
    $_REQUEST['idstring']=rtrim($_REQUEST['idstring'],',');
    $idstring = explode(";", $_REQUEST['idstring']);
    $querywhere = ' and ld_lessionplan.lessionplanid in ('.generateQuestionMarks($idstring).')';
    array_push($params, $idstring);
}
if((!is_array($idstring)|| count($idstring)<=0)&&$search_type == 'selecteddata')$querywhere=" and 1<>1 ";
$list_query = $queryGenerator->getQuery();

$where = $queryGenerator->getConditionalWhere();

if(empty($order_by)){
	$orderModArr = array('InventoryAccount'=>1,'InventoryQuery'=>1,'Checks'=>1);
	if(isset($orderModArr[$module])){
		$stockquery  = $queryGenerator->isStockQuery($module);
        $list_query .=$stockquery . $customsortorder;
	}
}
$list_query.=$querywhere;
list($list_query,$order_by,$sorder) = $queryGenerator->customview->getOrderWhere($list_query);

$queryMode = (isset($_REQUEST['query']) && $_REQUEST['query'] == 'true');

$listcounts_result = $adb->pquery($list_query, $params);
$listcounts = $adb->num_rows($listcounts_result);

if($_REQUEST['getcount']=='getcount'){
    echo "##SUCCESS##". $listcounts;exit();
}
$controller = new ListViewController($adb, $current_user, $queryGenerator);

if(isset($skipAction)==false){
	$skipAction==false;
}
//得到列头
$listview_header = $controller->getListViewHeader($focus,$currentModule,$url_string,$sorder,$order_by,$skipAction);
array_pop($listview_header);
foreach($listview_header as $key=>$arr){
    $listview_header[$key]=strip_tags($arr);
}
//edit: xll 2023/08/03 BUG0070673 导出优化，系统导出的excel表格的表头应有底色，标题应加粗
crm_load_class_file('cls_ExportListView','include/ListView/ExportListView');
$Header_FromArray = cls_ExportListView::getListHeaderFormArray();
foreach($listview_header as $key=>$arr){//wsh 标签颜色
    $fieldifo = $focus->fieldobj->getFieldByColumnName($controller->listViewFields_permitarr[$key]);
    if (!empty($fieldifo)){
        $Header_FromArray["font"]["color"]["rgb"] = $fieldifo->getExportLabelColor();
    }
    $activesheet->getStyle(PHPExcel_Cell::stringFromColumnIndex($key) . '1')->applyFromArray($Header_FromArray);
    $activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex($key).'1',trim($arr));
}

$objWriter->save('storage/LessionPlan.xls'); 


for($i=0;$i<ceil($listcounts/$page_count);$i++){
    $limit_start_rec=0+$page_count*$i;
	$queryLIMIT = ' LIMIT '.$limit_start_rec.','.$page_count;
    $list_result = $adb->pquery($list_query.$queryLIMIT, $params);

    $listview_entries = $controller->getListViewEntries($focus,$currentModule,$list_result,$navigation_array,$skipAction,false,'nosubstr');
    foreach($listview_entries as $key=>$arr){
        array_pop($listview_entries[$key]);
    }
    
    $a=2;
    foreach($listview_entries as $key=>$arr){
        $j=0;
        foreach($arr as $key2=>$arr2){
            if($arr2=='&&'){
                $listview_entrie[$a][$j] = '';
            }else{
               //$listview_entrie[$a][$j] = str_replace('&yen;','¥',strip_tags($arr2)); 
               $arr2 = str_replace('&yen;','¥',strip_tags($arr2)); 
              $arr2 = str_replace('&euro;','€',strip_tags($arr2));               
              $listview_entrie[$a][$j] = $arr2;       
            }
            
            $j++;
        }
        $a++;
    }
    
    foreach($listview_entrie as $key=>$arr){
                  //echo ($key+($i*$page_count))."<br>";
        foreach($arr as $key2=>$arr2){
           //$activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex($key2).($key+($i*$page_count)),trim($arr2)); 
        $activesheet->setCellValueExplicit(PHPExcel_Cell::stringFromColumnIndex($key2).($key+($i*$page_count)), trim($arr2),PHPExcel_Cell_DataType::TYPE_STRING);
        }
    }
    $objWriter->save('storage/LessionPlan.xls');  
    unset($listview_entrie);
}

 //下载文件
unset($app_strings);
unset($mod_strings);
unset($currentModule) ;
unset($theme) ;
unset ($list_max_entries_per_page_new);

 $file_name="LessionPlan.xls";
 $file_dir="storage/";

$modulelabel = mb_convert_encoding($modulelabel, 'UTF-8', 'gbk');
preg_match_all('/[\s\x{4e00}-\x{9fff}a-zA-Z0-9#\[\]\{\}\'\"=+\-\(\)*&%$@]+/iu', $modulelabel, $matches);
$modulelabels = join('', $matches[0]);
if(strstr(PHP_OS,'WIN')){
   $modulelabel =  mb_convert_encoding($modulelabels, "gbk", "UTF-8"); 
}else{
    $modulelabel = $modulelabels;
}
//unlink($file_dir . $modulelabel.".xls");
//rename($file_dir . $file_name,$file_dir . $modulelabel.".xls");
echo '##SUCCESS##'.$modulelabels;
exit();
?>