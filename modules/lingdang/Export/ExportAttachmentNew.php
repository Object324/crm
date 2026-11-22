<?php
/**
 * 更新操作
 * edit:andrew
 * date:20140126
 * reason:导出模板文件
 * */
   set_time_limit(0);
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
 global  $adb;
global $current_user;

global $currentModule, $theme;
global $list_max_entries_per_page_new;

$_REQUEST['diony']='yes';
if($_REQUEST['getprogress']=='yes')
{
      crm_load_class_file("LoginHistory",'modules/Users');
    $historyobj=new LoginHistory();
    $historyobj->user_operation_history('Export',$currentModule);
     include(globalStatic::$root_directory.'modules/lingdang/Export/ExportProgressHtml.php');

}
 if($_REQUEST['exportformat']=='exportcsv')
{
    //导出csv格式
     include(globalStatic::$root_directory."modules/lingdang/Export/ExportAttachmentCSVNew.php");
     exit();
}

  
global $adb;
set_time_limit(0);
global $app_strings, $mod_strings, $currentModule, $theme;

global $current_user;

require_once("modules/$currentModule/$currentModule.php");
require('user_privileges/user_privileges_'.$current_user->id.'.php');
include('PHPExcel/PHPExcel.php');
$pathname='storage/'.$current_user->id.'_'.$currentModule.'.xls';

$startexportindex=$_REQUEST['startexportrow'];
$endexportrow=$_REQUEST['endexportrow'];

$eachexportcount=$endexportrow-$startexportindex;//每次导出的记录数量50

if($startexportindex<=0)
{
    $startexportindex=0;
   
}

if($_SESSION[$currentModule][$current_user->id]['export']['listcounts'])
{
    $listcounts=$_SESSION[$currentModule][$current_user->id]['export']['listcounts'];
    $detailcounts=$_SESSION[$currentModule][$current_user->id]['export']['detailcounts'];
}


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
        // zkt 2021/12/27 平铺搜索 优化（批量操作按钮）-批量导出
	}else if($input['searchtype'] == 'advance'||$input['searchtype'] == 'tiled'){
		if(!empty($input['advft_criteria']) && $input['advft_criteria'] != '[]'){
			$_REQUEST['advft_criteria'] = $input['advft_criteria'];
			$_REQUEST['advft_criteria_groups'] = $input['advft_criteria_groups'];
			$_REQUEST['SearchScope'] = $input['SearchScope'];
			$_REQUEST['searchtype'] = $input['searchtype'];
            //zkt 20220331 50734: （https://61mis.com/WX/kh46549 [^]）（客户问题：重庆公牛摩托）合同订单经标签查找后，导出就是空白
            $tmpurl = $_SESSION['LiveViewSearch'][$currentModule]['url'];
            if(strpos($tmpurl,'&tag_search=true')===false)
            {
                
            }
            else
            {
                $_REQUEST['tag_search'] = 'true';
            }
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

//zkt 20220909 XUQIU1000234 带分录和带产品分录的表单，导出弹出层中增加“导出样式”参数（胡斐） 
$groupby = '';
if($_REQUEST['export_style']=='onlycolheader'){
    //仅显示单据头字段（一行）
    $groupby = $queryGenerator->getGroupBy();
}

$list_query=$list_query." inner join ( $page_list_query    ) as temp on temp.$focus->table_index=$focus->table_name.$focus->table_index $where $groupby";

$list_count_sql= $page_list_query;
if(!array_key_exists('exportgetcount',$_SESSION[$currentModule][$current_user->id]['export']))
{
     $detail_result = $adb->pquery($list_query, $params);
    $detailcounts = $adb->num_rows($detail_result);       
    
    $listcounts_result = $adb->pquery($list_count_sql, $params);
    $listcounts = $adb->num_rows($listcounts_result);       
    $_SESSION[$currentModule][$current_user->id]['export']['listcounts']=$listcounts;
    $_SESSION[$currentModule][$current_user->id]['export']['detailcounts']=$detailcounts;
    
     $_SESSION[$currentModule][$current_user->id]['export']['exportgetcount']="##SUCCESS##". $listcounts.'details'.$detailcounts;
       
    
}
$listcounts=$_SESSION[$currentModule][$current_user->id]['export']['listcounts'];
$detailcounts=$_SESSION[$currentModule][$current_user->id]['export']['detailcounts'];

     
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
$nums=$eachexportcount/2;//每次获取的记录数量
$step=$eachexportcount/$nums;
if($startexportindex==0&&$startexportindex==$listcounts)
 {
   
    $objWriter->save($pathname); 
    unset($_SESSION[$currentModule][$current_user->id]['export']); 
     $ret_arr['startexportrow']=$startexportindex;
      $ret_arr['endexportrow']=$endexportrow;
      $ret_arr['listcount']=-1;
      $ret_arr['detailcount']=-1;
    //$ret_arr['title']=getTranstab($currentModule).'>>'. getFixedLabel('EXPORTDATATITLE');
     global $languageType;
     if($languageType == 'en') {
         $ret_arr['title'] = getFixedLabel("EXPORT") .' '. getTranstab($currentModule);
     }
     else{
         $ret_arr['title'] = getFixedLabel("EXPORT") . getTranstab($currentModule);
     }
    ConvertTojsonString(1,$ret_arr,'success');
 }
if(!empty($_SESSION[$currentModule][$current_user->id]['export']['detailcount']))
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
     
            $tmplist_query="$list_query inner join ($page_list_query   $queryLIMIT) as tmp on tmp.$focus->table_index=$focus->table_name.$focus->table_index $where $groupby ";
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
                        
                    
                    
               }                        
                
            
                 $prev_totalrows+= $rows;//明细
              
                unset($listview_entries);
      }

        $_SESSION[$currentModule][$current_user->id]['export']['total_list_query']="$list_query inner join ($page_list_query  $querywhere $orderby ) as tmp on tmp.$focus->table_index=$focus->table_name.$focus->table_index $where  $orderby";
        $_SESSION[$currentModule][$current_user->id]['export']['list_query']="$list_query inner join ($page_list_query  $querywhere $orderby ) as tmp on tmp.$focus->table_index=$focus->table_name.$focus->table_index $where  $orderby";
        $_SESSION[$currentModule][$current_user->id]['export']['exportprev_totalrows']=$prev_totalrows;

        $tmptmp=$startexportindex+$eachexportcount;
      if($tmptmp<$listcounts)
    {
        

    }
    else
    {
         
          unset($_SESSION[$currentModule][$current_user->id]['export']); 
          
    }
     $objWriter->save($pathname); 
      include(globalStatic::$root_directory.'modules/lingdang/Export/ExportProgressDescription.php');
    $ret_arr['timedescription']=$time_description;
    
    $ret_arr['content']=$progresshtml;
    $ret_arr['startexportrow']=$startexportindex;
    $ret_arr['endexportrow']=$endexportrow;
    $ret_arr['listcount']=$listcounts;
    //$ret_arr['writefilelabel']=getFixedLabel('WRITEEXCELFILE');
    $ret_arr['detailcount']=$detailcounts;
    //$ret_arr['title']=getTranstab($currentModule).'>'. getFixedLabel('EXPORTDATATITLE');
    global $languageType;
    if($languageType == 'en') {
        $ret_arr['title'] = getFixedLabel("EXPORT") .' '. getTranstab($currentModule);
    }
    else{
        $ret_arr['title'] = getFixedLabel("EXPORT") . getTranstab($currentModule);
    }
    ConvertTojsonString(1,$ret_arr,'success');
    
}


exit();
?>