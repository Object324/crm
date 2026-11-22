<?php
/**
 * 更新操作
 * edit:andrew
 * date:20140126
 * reason:导出模板文件
 * */
 
  if($_REQUEST['exportformat']=='exportcsv')
{
    //导出csv格式
     include(globalStatic::$root_directory."modules/lingdang/ExportAttachmentCSV.php");
     exit();
}
global $adb;
set_time_limit(0);
global $app_strings, $mod_strings, $currentModule, $theme;
global $list_max_entries_per_page_new;
global $current_user;
require_once('include/ListView/ListViewSession.php');
require_once("modules/$currentModule/$currentModule.php");
require('user_privileges/user_privileges_'.$current_user->id.'.php');
include('PHPExcel/PHPExcel.php');
$pathname='storage/'.$current_user->id.'_'.$currentModule.'.xls';
$smarty=new lingdangCRM_Smarty();
if($_SESSION[$currentModule][$current_user->id]['export']['startexportindex'])
    $startexportindex=$_SESSION[$currentModule][$current_user->id]['export']['startexportindex'];
else
{
    $startexportindex=0;
}
$eachexportcount=10000;//每次导出的记录数量为10000
if($startexportindex<=0)
{
    $startexportindex=0;
   
}

$_SESSION[$currentModule][$current_user->id]['export']['startexportindex']=$startexportindex+$eachexportcount;
if($_SESSION[$currentModule][$current_user->id]['export']['listcounts'])
{
    $listcounts=$_SESSION[$currentModule][$current_user->id]['export']['listcounts'];
}

$smarty->assign("STARTEXPORTINDEX",100);
$smarty->assign("MODULE",$currentModule);
$page_width= 559;
$smarty->assign("PAGEWIDTH",$page_width);
$smarty->display('ExportRecords.tpl');
if(array_key_exists('objphpexcel',$_SESSION[$currentModule][$current_user->id]['export']))
{
    
    $objPHPExcel =PHPExcel_IOFactory::load($pathname);
  
}
else
{
    $objPHPExcel = new PHPExcel();
    $_SESSION[$currentModule][$current_user->id]['export']['objphpexcel']=serialize($objPHPExcel);

}
 $objWriter = PHPExcel_IOFactory::createWriter($objPHPExcel, 'Excel5');
$objPHPExcel->setActiveSheetIndex(0);
$activesheet=$objPHPExcel->getActiveSheet();

$moduleName = $currentModule;
$modulelabel = getTranstab($moduleName);
$modulelabel = str_replace(' ','_',$modulelabel);
$modulelabel = str_replace('/','_',$modulelabel);
$modulelabel = str_replace('\\','_',$modulelabel);
$modulelabel = str_replace('?','_',$modulelabel);
$modulelabel = str_replace('[','(',$modulelabel);
$modulelabel = str_replace(']',')',$modulelabel);
$objPHPExcel->getActiveSheet()->setTitle($modulelabel);



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


$morelist = 1;

// Custom View
$customView = new CustomView($currentModule);

$viewid = $customView->getViewId($currentModule);

$queryGenerator = QueryGenerator::getInstance($currentModule, $current_user);

if(isset($_SESSION['LiveViewSearch'][$currentModule])){
	$input = $_SESSION['LiveViewSearch'][$currentModule]['input'];
	global $search_session;
	$search_session = 1;
	if($input['searchtype'] == 'BasicSearch'){
		if(!empty($input['search_text'])){
			$_REQUEST['search_field'] = $input['search_field'];
			$_REQUEST['search_text'] = $input['search_text'];
			$_REQUEST['SearchScope'] = $input['SearchScope'];
			$_REQUEST['searchtype'] = $input['searchtype'];
		}else{
			$search_session = 0;
			unset($_SESSION['LiveViewSearch'][$currentModule]);
		}
	}else if($input['searchtype'] == 'advance'){
		if(!empty($input['advft_criteria']) && $input['advft_criteria'] != '[]'){
			$_REQUEST['advft_criteria'] = $input['advft_criteria'];
			$_REQUEST['advft_criteria_groups'] = $input['advft_criteria_groups'];
			$_REQUEST['SearchScope'] = $input['SearchScope'];
			$_REQUEST['searchtype'] = $input['searchtype'];
			//初始化搜索条件
			$json = new Zend_Json();
			$advft_criteria = $json->decode($input['advft_criteria']);
			$advft_criteria_groups = $json->decode($input['advft_criteria_groups']);
			$advfilterlist = getAdvancedSearchCriteriaList($advft_criteria, $advft_criteria_groups, $currentModule,$queryGenerator);
		}else{
			$search_session = 0;
			unset($_SESSION['LiveViewSearch'][$currentModule]);
		}
	}
	if($search_session == 1){
		$_REQUEST['query'] = 'true';
	}
}
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
$list_query = $queryGenerator->getQuery('',2);//所有数据查询
$page_list_query=$queryGenerator->getQuery('',1);//分页查询语句

$where = $queryGenerator->getConditionalWhere();

// Sorting
$params = array();
$search_type = $_REQUEST['search_type'];

$where=' where  '.$focus->table_name.'.deleted=0';
if($search_type == 'includesearch') {
 $where = $queryGenerator->getWhereClause();
 //echo $where;die;
}
if($search_type == 'selecteddata'&&$_REQUEST['idstring']!='all'){
    $_REQUEST['idstring']=rtrim($_REQUEST['idstring'],',');
    $idstring = explode(";", $_REQUEST['idstring']);
 
    $querywhere = ' and '.$focus->table_name.'.'.$focus->table_index.' in ('.implode(",",array_filter($idstring)).')';

    //array_push($params, $idstring);
}
if(((!is_array($idstring)|| count($idstring)<=0)&&$search_type == 'selecteddata')&&$_REQUEST['idstring']!='all')$querywhere=" and 1<>1 ";
$queryMode = (isset($_REQUEST['query']) && $_REQUEST['query'] == 'true');
$customsortorder = $customView->getCustomViewOrderBy($viewid);
$where= $queryGenerator->getWhereClause();
$chart_owner=$queryGenerator->getSmOwnerSearchSql();  
if($_SESSION[$currentModule][$current_user->id]['export']['page_list_query'])
    $page_list_query=$_SESSION[$currentModule][$current_user->id]['export']['page_list_query'];
else
{
    $page_list_query=$page_list_query.$chart_owner.$FoSearchSQL.$querywhere.$querysearch;
  $_SESSION[$currentModule][$current_user->id]['export']['page_list_query']=$page_list_query;
}


$list_query=$list_query." inner join ( $page_list_query    ) as temp on temp.$focus->table_index=$focus->table_name.$focus->table_index $where";

$list_count_sql= $page_list_query;
if(!array_key_exists('exportgetcount',$_SESSION[$currentModule][$current_user->id]['export']))
{
     $detail_result = $adb->pquery($list_query, $params);
    $detailcounts = $adb->num_rows($detail_result);       
    
    $listcounts_result = $adb->pquery($list_count_sql, $params);
    $listcounts = $adb->num_rows($listcounts_result);       
    $_SESSION[$currentModule][$current_user->id]['export']['listcounts']=$listcounts;
    $_SESSION[$currentModule][$current_user->id]['export']['detailcount']=$detailcounts;
    
     $_SESSION[$currentModule][$current_user->id]['export']['exportgetcount']="##SUCCESS##". $listcounts.'details'.$detailcounts;
       
    
}
$listcounts=$_SESSION[$currentModule][$current_user->id]['export']['listcounts'];

     
crm_load_class_file('ExportAttachmentDetailController','include/ListView');
$controller = new ExportAttachmentDetailController($adb, $current_user, $queryGenerator,"excel");

if(isset($skipAction)==false){
	$skipAction==false;
}
 list($page_list_query,$order_by,$sorder) = $queryGenerator->customview->getOrderWhere($page_list_query);

 //得到列头
$listview_header = $controller->getListViewHeader($focus,$currentModule,$url_string,$sorder,$order_by,$skipAction);

foreach($listview_header as $key=>$arr){
    if(isset($checkkey)){
        $listview_header[$key]=$listview_header[$key+1];
    } 
}
//array_pop($listview_header);
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


$list_query = $queryGenerator->getQuery('',2);//所有数据查询
$prev_totalrows=0;
$nums=100;//每次获取的记录数量
$step=$eachexportcount/$nums;

$progress_step=if(!empty($_SESSION[$currentModule][$current_user->id]['export']['detailcount']))
    $progress_step=$page_width/$_SESSION[$currentModule][$current_user->id]['export']['detailcount'];
else
    $progress_step=0;;
if(array_key_exists('exportprev_totalrows',$_SESSION[$currentModule][$current_user->id]['export']))
{
        $prev_totalrows=$_SESSION[$currentModule][$current_user->id]['export']['exportprev_totalrows'];
} 
  
if($startexportindex<$listcounts)
{
    
     for($s = 1; $s <= $step; ++$s) 
     {
                  $start = ($s - 1) * $nums+$startexportindex;
                 $queryLIMIT =  ' LIMIT '.$start.','.$nums;
     
            $tmplist_query="$list_query inner join ($page_list_query   $queryLIMIT) as tmp on tmp.$focus->table_index=$focus->table_name.$focus->table_index $where  ";
            list($tmplist_query,$order_by,$sorder) = $queryGenerator->customview->getOrderWhere($tmplist_query);
            $list_result = $adb->pquery($tmplist_query, $params);
            $rows=$adb->num_rows($list_result);
            if($rows<=0)
            {
                break;
            }
            $listview_entries = $controller->getListViewEntries($focus,$currentModule,$list_result,$navigation_array,$skipAction,true,'export');
            $a=2;
           
            foreach($listview_entries as $key=>$arr){
                    
                        foreach($arr as $key2=>$arr2){
                               
                              $arr2 = str_replace('&yen;','¥',strip_tags($arr2)); 
                              $arr2 = str_replace('&euro;','€',strip_tags($arr2));               
                                               
                            $activesheet->setCellValueExplicit(PHPExcel_Cell::stringFromColumnIndex($key2).($key+$a+($prev_totalrows)), trim($arr2),PHPExcel_Cell_DataType::TYPE_STRING);
                        }
                        
                    
                     //$key是从0开始的所以要加1
                     $cur_progress_step=($key+1+$prev_totalrows)*$progress_step;
                     if($cur_progress_step>$page_width)
                     {
                        $cur_progress_step=$page_width;
                     }
                     
                     //$key是从0开始的，所以要加1
                     echo '<script> 
                                       document.getElementById("dvctimedescription").innerHTML="正在导出第'.($key+$prev_totalrows+1).'条数据"
                                       document.getElementById("dv").innerHTML="共'.$listcounts.'条数据，明细'.($_SESSION[$currentModule][$current_user->id]['export']['detailcount']).'";
                                       document.getElementById("dvExportprogress").style.width = "'.$cur_progress_step.'px"</script>';
                               
                     ob_flush(); 
                     flush();
               }                        
                
            
                 $prev_totalrows+= $rows;//明细
              
                unset($listview_entries);
      }

        $_SESSION[$currentModule][$current_user->id]['export']['total_list_query']="$list_query inner join ($page_list_query  $querywhere $orderby ) as tmp on tmp.$focus->table_index=$focus->table_name.$focus->table_index $where  $orderby";
        $_SESSION[$currentModule][$current_user->id]['export']['list_query']="$list_query inner join ($page_list_query  $querywhere $orderby ) as tmp on tmp.$focus->table_index=$focus->table_name.$focus->table_index $where  $orderby";
        $_SESSION[$currentModule][$current_user->id]['export']['exportprev_totalrows']=$prev_totalrows;
      ob_flush();
      ob_clean();
        $tmptmp=$startexportindex+$eachexportcount;
      if($tmptmp<$listcounts)
    {
        $objWriter->save($pathname);  
         echo '<script type="text/javascript">';
         echo "document.forms['Export_Records'].submit();";
        echo '</script>';

    }
    else
    {
          $objWriter->save($pathname); 
          unset($_SESSION[$currentModule][$current_user->id]['export']); 
          echo '<script>showExportResult();</script>';
    }
    
}


exit();
?>