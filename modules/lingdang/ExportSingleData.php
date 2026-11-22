<?php
/**
 * 列表不带明细的测试
 * 
 * 
 * */

 if($_REQUEST['exportformat']=='exportcsv')
{
    //导出csv格式
     include(globalStatic::$root_directory."modules/lingdang/ExportSingleCSV.php");
     exit();
}
 set_time_limit(0);
global  $adb;
global $current_user;
$languageType=getLanguageType($current_user);

global $currentModule, $theme;
global $list_max_entries_per_page_new;

require_once('include/ListView/ListViewSession.php');
include('PHPExcel/PHPExcel.php');
$pathname='storage/'.$current_user->id.'_'.$currentModule.'.xls';


$smarty=new lingdangCRM_Smarty();
$page_width= 559;
$smarty->assign("PAGEWIDTH",$page_width);
if($_SESSION[$currentModule][$current_user->id]['export']['startexportindex'])
    $startexportindex=$_SESSION[$currentModule][$current_user->id]['export']['startexportindex'];
else
{
    $startexportindex=0;
}
$eachexportcount=10000;//每次导出的记录数量为2500
if($startexportindex<=0)
{
    $startexportindex=0;
   
}

$_SESSION[$currentModule][$current_user->id]['export']['startexportindex']=$startexportindex+$eachexportcount;
if($_SESSION[$currentModule][$current_user->id]['export']['listcounts'])
{
    $listcounts=$_SESSION[$currentModule][$current_user->id]['export']['listcounts'];
}
setGLobalURLSmarty($smarty);//设置js,css等访问路径
$smarty->assign("STARTEXPORTINDEX",100);

$smarty->assign("MODULE",$currentModule);
$smarty->assign("EXPORTFORMAT",'exportexcel'); 
$smarty->display('ExportRecords.tpl');
//$cacheMethod = PHPExcel_CachedObjectStorageFactory::cache_to_phpTemp;
//$cacheSettings = array('memoryCacheSize'=>'10MB');
//PHPExcel_Settings::setCacheStorageMethod($cacheMethod, $cacheSettings);
        
if(array_key_exists('objphpexcel',$_SESSION[$currentModule][$current_user->id]['export']))
{
  
    $objPHPExcel =PHPExcel_IOFactory::load($pathname);
  
}
else
{
    $objPHPExcel = new PHPExcel();
    $_SESSION[$currentModule][$current_user->id]['export']['objphpexcel']=serialize($objPHPExcel);

}


$objPHPExcel->setActiveSheetIndex(0);
$activesheet=$objPHPExcel->getActiveSheet();
$modulelabel = getTranstab($currentModule);
$modulelabel = str_replace(' ','_',$modulelabel);
$modulelabel = str_replace('/','_',$modulelabel);
$modulelabel = str_replace('\\','_',$modulelabel);
$modulelabel = str_replace('?','_',$modulelabel);
$modulelabel = str_replace('[','(',$modulelabel);
$modulelabel = str_replace(']',')',$modulelabel);
$objPHPExcel->getActiveSheet()->setTitle($modulelabel);






$objWriter = PHPExcel_IOFactory::createWriter($objPHPExcel, 'Excel5');
unset($_REQUEST['search_field']);
unset($_REQUEST['search_text']);
unset($_REQUEST['SearchScope']);
unset($_REQUEST['searchtype']);
unset($_REQUEST['type']);
unset($_REQUEST['advft_criteria']);
unset($_REQUEST['advft_criteria_groups']);
unset($_REQUEST['SearchScope']);
unset($_REQUEST['searchtype']);
$warehouseid = 0;
$url_string = '';
$stockquery = '';

$focus = CRMEntity::getInstance($currentModule);
//$focus->initSortbyField($currentModule);

if(ListViewSession::hasViewChanged($currentModule,$viewid)) {
	$_SESSION[$currentModule."_Order_By"] = '';
}
$sorder = $focus->getSortOrder();
$order_by = $focus->getOrderBy();

$_SESSION[$currentModule."_Order_By"] = $order_by;
$_SESSION[$currentModule."_Sort_Order"]=$sorder;

// Custom View
$customView = new CustomView($currentModule);

$viewid = $customView->getViewId($currentModule);
if(isset($_SESSION['lvs'][$currentModule]['SearchScope'])&&$_SESSION['lvs'][$currentModule]['SearchScope']!=null)
{
}
else 
{
    $SearchScope="SmOwner_Search_All";
    $_SESSION['lvs'][$currentModule]['SearchScope']=$SearchScope;
}

$queryGenerator =  QueryGenerator::getInstance($currentModule, $current_user,$customView);
/**
 * query_session=1时，读取session中的搜索条件，否则将清空session
 * 查看页面返回列表、列表编辑之后保存 返回列表时，返回query_session=1的参数
 * @project 序时簿查询记住搜索条件
 * @author Tujt 2014-04-25
 */
if( isset($_SESSION['LiveViewSearch'][$currentModule])&&($_REQUEST['search_type']=='includesearch'||$_REQUEST['search_type']=='withoutsearch')){
	$input = $_SESSION['LiveViewSearch'][$currentModule]['input'];
	global $search_session;
	$search_session = 1;
	if($input['searchtype'] == 'BasicSearch'){
		if(!empty($input['search_text'])){
			$_REQUEST['search_field'] = $input['search_field'];
			$_REQUEST['search_text'] = $input['search_text'];
			$_REQUEST['SearchScope'] = $input['SearchScope'];
			$_REQUEST['searchtype'] = $input['searchtype'];
			$_REQUEST['type'] = $input['type'];
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
			$advfilterlist = getAdvancedSearchCriteriaList($advft_criteria, $advft_criteria_groups, $currentModule);
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
	$_REQUEST['searchtype'] = trim($_REQUEST['searchtype']);
	$queryGenerator->addUserSearchConditions($_REQUEST);

}
$page_list_query=$queryGenerator->getQuery("",1);
$list_query = $queryGenerator->getQuery("",2);


$tablename=$focus->table_name;
$table_index=$focus->table_index;
$where = $queryGenerator->getConditionalWhere();

$params = array();
$search_type = $_REQUEST['search_type'];
$where=' where '.$tablename.'.deleted = 0 ';
if($search_type == 'includesearch') {
    $where = $queryGenerator->getWhereClause();
}
if($_REQUEST['idstring']!=''&&$search_type == 'selecteddata'&&$_REQUEST['idstring']!='all'){
    $_REQUEST['idstring']=rtrim($_REQUEST['idstring'],',');
    $idstring = explode(";", $_REQUEST['idstring']);
    $querywhere = ' and '.$tablename.'.'.$table_index.' in ('.implode(",",array_filter($idstring)).')';
    //array_push($params, $idstring);
}

if((!is_array($idstring)|| count($idstring)<=0)&&$search_type == 'selecteddata'&&$_REQUEST['idstring']!='all')$querywhere=" and 1<>1 ";

if($module!='InventoryAccount')
	$chart_owner=$queryGenerator->getSmOwnerSearchSql();  
if($_SESSION[$currentModule][$current_user->id]['export']['page_list_query'])
    $page_list_query=$_SESSION[$currentModule][$current_user->id]['export']['page_list_query'];
else
{
    $page_list_query=$page_list_query.$chart_owner.$querywhere;
   $_SESSION[$currentModule][$current_user->id]['export']['page_list_query']=$page_list_query;
}
 if(empty($order_by)&&$module=='InventoryAccount')
 {
    //28921: 库存流水账：导出，点击【其他仓库】页签，导出，结果导出了库存流水账中所有的数据了
    		$stockquery  = $queryGenerator->isStockQuery($module);
            $page_list_query.=$stockquery;
        
            
 }
if(!array_key_exists('exportgetcount',$_SESSION[$currentModule][$current_user->id]['export']))
{
    
    $listcounts_result = $adb->pquery($page_list_query, $params);
    $listcounts = $adb->num_rows($listcounts_result);
   
     $_SESSION[$currentModule][$current_user->id]['export']['listcounts']=$listcounts;
     $_SESSION[$currentModule][$current_user->id]['export']['exportgetcount']="##SUCCESS##". $listcounts;
       
    
}

 list($page_list_query,$order_by,$sorder) = $queryGenerator->customview->getOrderWhere($page_list_query);

 if(empty($order_by)&&$module=='InventoryAccount')
 {
    //28921: 库存流水账：导出，点击【其他仓库】页签，导出，结果导出了库存流水账中所有的数据了
    
            $order_by=' ld_warehousecondtions.id desc';
 }
$queryMode = (isset($_REQUEST['query']) && $_REQUEST['query'] == 'true');
$start = ListViewSession::getRequestCurrentPage($currentModule, $list_query, $viewid, $queryMode);
// crm_load_function_file('VT_getSimpleNavigationValues','include/utils','ListViewUtils');
//echo $list_query. " OFFSET $limit_start_rec LIMIT $list_max_entries_per_page_new";
//$navigation_array = VT_getSimpleNavigationValues($start,$list_max_entries_per_page_new,$noofrows);;
$limit_start_rec = ($start-1) * $list_max_entries_per_page_new;


crm_load_class_file('cls_ExportListView','include/ListView/ExportListView');
$controller = new cls_ExportListView($adb, $current_user, $queryGenerator,'excel');

if(isset($skipAction)==false){
	$skipAction==false;
}
 //得到列头
 //print_r($list_result);
$listview_header = $controller->getListViewHeader($focus,$currentModule,$url_string,$sorder,$order_by,$skipAction);
$bool_opertionbutton=$controller->haveExistsOperationHeader(getTabid($currentModule));

if($bool_opertionbutton=='yes')
        array_pop($listview_header);
foreach($listview_header as $key=>$arr){
    $listview_header[$key]=strip_tags($arr);
}
//edit: xll 2023/08/03 BUG0070673 导出优化，系统导出的excel表格的表头应有底色，标题应加粗
$Header_FromArray = cls_ExportListView::getListHeaderFormArray();
foreach($listview_header as $key=>$arr){//wsh 标签颜色
    $fieldifo = $focus->fieldobj->getFieldByColumnName($controller->listViewFields_permitarr[$key]);
    if (!empty($fieldifo)){
        $Header_FromArray["font"]["color"]["rgb"] = $fieldifo->getExportLabelColor();
    }
    $activesheet->getStyle(PHPExcel_Cell::stringFromColumnIndex($key) . '1')->applyFromArray($Header_FromArray);
    $activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex($key).'1',trim($arr));
}



$listcounts=$_SESSION[$currentModule][$current_user->id]['export']['listcounts'];
$prev_totalrows=0;
$nums =100;
$step = ceil($eachexportcount/$nums);

$progress_step=$page_width/$listcounts;
if(array_key_exists('exportprev_totalrows',$_SESSION[$currentModule][$current_user->id]['export']))
{
        $prev_totalrows=$_SESSION[$currentModule][$current_user->id]['export']['exportprev_totalrows'];
}
 crm_load_class_file("cls_excelImage",'include');
 $excelimageobj=new cls_excelImage();
 if($startexportindex==0&&$startexportindex==$listcounts)
 {
   
    $objWriter->save($pathname); 
    unset($_SESSION[$currentModule][$current_user->id]['export']); 
    echo '<script>showExportResult();</script>';
 }
if($startexportindex<$listcounts)
{
    //230530 wym 图片字段添加超链接
    $sql="select crm_address from ld_organizationdetails";
    $result = $adb->pquery($sql, array());
    $organization_crm_address = $adb->query_result($result,0,'crm_address');
         for($s = 1; $s <= $step; ++$s) 
         {
                  $start = ($s - 1) * $nums+$startexportindex;
                 $queryLIMIT =  ' LIMIT '.$start.','.$nums;
                if($currentModule=='InventoryAccount')
                    {
                         $tmplist_query=$list_query." inner join ($page_list_query $queryLIMIT) as tmp
                         on tmp.id=$tablename.id order by $order_by";
                    }
                else
                $tmplist_query=$list_query." inner join ($page_list_query $queryLIMIT) as tmp
                         on tmp.$table_index=$tablename.$table_index ";
                list($tmplist_query,$order_by,$sorder) = $queryGenerator->customview->getOrderWhere($tmplist_query);
                $list_result = $adb->pquery($tmplist_query, $params);
                 $rows=$adb->num_rows($list_result);
                 if($rows<=0)
                    break;
                $listview_entries = $controller->getListViewEntries($focus,$currentModule,$list_result,array(),$skipAction,false,'nosubstr');
               $headerlistfields=$controller->listViewFields;
            
              
                 $a=2;
                foreach($listview_entries as $key=>$arr)
                {
                             
                        foreach($arr as $key2=>$arr2){
                               $fieldname=$headerlistfields[$key2];
                               $fieldinfo=$controller->getListViewFieldobj($key2,$fieldname);
                                 
                            
                            if($fieldinfo&&$fieldinfo->isImageField()=="yes")
                            {
                                
                                $excelimageobj->setCellImage($objPHPExcel,$arr2,$key+$a+$prev_totalrows,$key2,$activesheet,$organization_crm_address);
                                
                                
                            }
                            else  if($fieldinfo&&($fieldinfo->istotalFldMoneyField()))
                             {
                               
                                
                                $activesheet->setCellValueExplicit(PHPExcel_Cell::stringFromColumnIndex($key2).($key+$a+($prev_totalrows)), trim($arr2),PHPExcel_Cell_DataType::TYPE_NUMERIC);
            
                             }
                             else
                            $activesheet->setCellValueExplicit(PHPExcel_Cell::stringFromColumnIndex($key2).($key+$a+($prev_totalrows)), trim($arr2),PHPExcel_Cell_DataType::TYPE_STRING);
                        }
                        
                         //$key是从0开始的，所以要加1
                         $cur_progress_step=($key+1+$prev_totalrows)*$progress_step;
                         echo '<script> 
                                   document.getElementById("dvctimedescription").innerHTML="正在导出第'.($key+1+$prev_totalrows).'条数据"
                                   document.getElementById("dv").innerHTML="共'.$listcounts.'条数据";
                                   document.getElementById("dvExportprogress").style.width = "'.$cur_progress_step.'px"</script>';
                                   
                         ob_flush(); 
                         flush();  
                }
              $prev_totalrows+=$rows;
              unset($listview_entries);
        }
       
       
         $_SESSION[$currentModule][$current_user->id]['export']['total_list_query']="$list_query inner join ($page_list_query   ) as tmp on tmp.$focus->table_index=$focus->table_name.$focus->table_index $where  $orderby";
         $_SESSION[$currentModule][$current_user->id]['export']['list_query']="$list_query inner join ($page_list_query   ) as tmp on tmp.$focus->table_index=$focus->table_name.$focus->table_index $where  $orderby";
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
                foreach($listview_header as $key=>$arr)//设置数字列和金额列的宽度
                {
                             $fieldname=$headerlistfields[$key];
                            $fieldinfo=$controller->getListViewFieldobj($key,$fieldname);
                             if($fieldinfo&&($fieldinfo->istotalFldMoneyField()))
                                {
                                     $tmp= PHPExcel_Cell::stringFromColumnIndex($key);
                                     $objPHPExcel->getActiveSheet()->getColumnDimension($tmp)->setWidth(12);
                                }
                }
              
               $query=$_SESSION[$currentModule][$current_user->id]['export']['list_query'];
             $total_query=$_SESSION[$currentModule][$current_user->id]['export']['total_list_query'];
             crm_load_class_file('clsTotal_ExportList','include/ListView/ExportListView');
            $clstotalobj=new clsTotal_ExportList($controller);
        
            $totalfldhtml = $clstotalobj->getTotalFldCount($page_list_query,$list_result,$listcounts);
          
            if(!empty($totalfldhtml))
            {
                 
                 $_SESSION[$currentModule][$current_user->id]['export']['totalfldhtml']=$totalfldhtml;
                 $maxkey=$_SESSION[$currentModule][$current_user->id]['export']['exportprev_totalrows'];
               
                if(is_array($totalfldhtml)&&sizeof(array_keys($totalfldhtml))>0)
                    foreach($totalfldhtml as $key=>$arr){
                        $arr = str_replace('&yen;','¥',strip_tags($arr)); 
                        $activesheet->setCellValueExplicit(PHPExcel_Cell::stringFromColumnIndex($key).($maxkey+2), trim($arr),PHPExcel_Cell_DataType::TYPE_STRING);
                    }
                  
            }
        
                $objWriter->save($pathname); 
                unset($_SESSION[$currentModule][$current_user->id]['export']); 
              echo '<script>showExportResult();</script>';
         
        }
       
    
}
else
{
       $query=$_SESSION[$currentModule][$current_user->id]['export']['list_query'];

     //$list_result=$adb->pquery($query);
     $total_query=$_SESSION[$currentModule][$current_user->id]['export']['total_list_query'];
     crm_load_class_file('clsTotal_ExportList','include/ListView/ExportListView');
    $clstotalobj=new clsTotal_ExportList($controller);

    $totalfldhtml = $clstotalobj->getTotalFldCount($page_list_query,$list_result,$listcounts);
  
    if(!empty($totalfldhtml))
    {
         
         $_SESSION[$currentModule][$current_user->id]['export']['totalfldhtml']=$totalfldhtml;
         $maxkey=$_SESSION[$currentModule][$current_user->id]['export']['exportprev_totalrows'];
       
        if(is_array($totalfldhtml)&&sizeof(array_keys($totalfldhtml))>0)
            foreach($totalfldhtml as $key=>$arr){
                $arr = str_replace('&yen;','¥',strip_tags($arr)); 
                $activesheet->setCellValueExplicit(PHPExcel_Cell::stringFromColumnIndex($key).($maxkey+2), trim($arr),PHPExcel_Cell_DataType::TYPE_STRING);
            }
          
    }

        $objWriter->save($pathname);  

        unset($_SESSION[$currentModule][$current_user->id]['export']);
    $_REQUEST['frommodule']=$currentModule;
    include(globalStatic::$root_directory.'modules/uploads/downloadxls.php');
}



exit();
?>