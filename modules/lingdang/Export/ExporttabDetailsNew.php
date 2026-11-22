<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb;
set_time_limit(0);
global  $currentModule, $theme;

global $current_user;

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
    
    include(globalStatic::$root_directory."modules/lingdang/Export/ExporttabDetailsCSVNew.php");
    exit();
}

global  $currentModule, $theme;
global $list_max_entries_per_page_new;
global $current_user;
require_once("modules/$currentModule/$currentModule.php");
require('user_privileges/user_privileges_'.$current_user->id.'.php');
crm_load_class_file("ListViewSession",'include/ListView');
unset($_REQUEST['search_field']);
unset($_REQUEST['search_text']);
unset($_REQUEST['SearchScope']);
unset($_REQUEST['searchtype']);
unset($_REQUEST['type']);
unset($_REQUEST['advft_criteria']);
unset($_REQUEST['advft_criteria_groups']);
unset($_REQUEST['SearchScope']);
unset($_REQUEST['searchtype']);
$page_count=10;
include('PHPExcel/PHPExcel.php');

$pathname='storage/'.$current_user->id.'_'.$currentModule.'.xls';

$startexportindex=$_REQUEST['startexportrow'];
$endexportrow=$_REQUEST['endexportrow'];

$eachexportcount=$endexportrow-$startexportindex;//每次导出的记录数量50

if($startexportindex<=0)
{
    $startexportindex=0;
   
}

$_SESSION[$currentModule][$current_user->id]['export']['startexportindex']=$startexportindex+$eachexportcount;
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
$category = getParentTab();
$warehouseid = 0;
$url_string = '';
$stockquery = '';

$focus = CRMEntity::getInstance($currentModule);
if(ListViewSession::hasViewChanged($currentModule,$viewid)) {
	$_SESSION[$currentModule."_Order_By"] = '';
}

/**
*edit:diony
*time:2014-05-21
*reson:转换成大写
*/
$sorder = strtoupper($focus->getSortOrder());
if(isset($_REQUEST['order_by'])&&$_REQUEST['order_by']!='')
{
    $order_by=$_REQUEST['order_by'];
}
else
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

$queryGenerator = QueryGenerator::getInstance($currentModule, $current_user,$customView);
/**
 * query_session=1时，读取session中的搜索条件，否则将清空session
 * 查看页面返回列表、列表编辑之后保存 返回列表时，返回query_session=1的参数
 * @project 序时簿查询记住搜索条件
 * @author Tujt 2014-04-25
 */
//BUG20240112-07 ls 20240112 收款单导出数据bug，筛选条件控制本月，数据条数显示138条，导出显示为所有1795条(全选导出过滤条件也改为基于查询条件)
if(isset($_SESSION['LiveViewSearch'][$currentModule])&&($_REQUEST['search_type']=='includesearch'||$_REQUEST['search_type']=='withoutsearch'||$_REQUEST['search_type']=='selecteddata')){
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
$page_list_query = $queryGenerator->getQuery("",1);
$list_query = $queryGenerator->getQuery("",2);

$where = $queryGenerator->getConditionalWhere();

$params = array();
$search_type = $_REQUEST['search_type'];

$where=' where  '.$focus->table_name.'.deleted=0';
if($search_type == 'includesearch') {
    $where = $queryGenerator->getWhereClause();
}
if($_REQUEST['idstring']!=''&&$search_type == 'selecteddata'&&$_REQUEST['idstring']!='all'){
    $_REQUEST['idstring']=rtrim($_REQUEST['idstring'],',');
    $idstring = explode(";", $_REQUEST['idstring']);
    $querywhere = ' and '.$focus->table_name.'.'.$focus->table_index.' in ('.implode(",",array_filter($idstring)).')';
  

}

if((!is_array($idstring)|| count($idstring)<=0)&&$search_type == 'selecteddata'&&$_REQUEST['idstring']!='all')
    $querywhere=" and 1<>1 ";
$chart_owner=$queryGenerator->getSmOwnerSearchSql();  
if($_SESSION[$currentModule][$current_user->id]['export']['page_list_query'])
    $page_list_query=$_SESSION[$currentModule][$current_user->id]['export']['page_list_query'];
else
{
    $page_list_query=$page_list_query.$FoSearchSQL.$querywhere.$querysearch;
    $_SESSION[$currentModule][$current_user->id]['export']['page_list_query']=$page_list_query;
}
    

$queryMode = (isset($_REQUEST['query']) && $_REQUEST['query'] == 'true');
$start = ListViewSession::getRequestCurrentPage($currentModule, $list_query, $viewid, $queryMode);

//echo $list_query. " OFFSET $limit_start_rec LIMIT $list_max_entries_per_page_new";
crm_load_function_file('VT_getSimpleNavigationValues','include/utils','ListViewUtils');
$navigation_array = VT_getSimpleNavigationValues($start,$list_max_entries_per_page_new,$noofrows);;
$limit_start_rec = ($start-1) * $list_max_entries_per_page_new;
//zkt 20220909 XUQIU1000234 带分录和带产品分录的表单，导出弹出层中增加“导出样式”参数（胡斐） 
$groupby = '';
if($_REQUEST['export_style']=='onlycolheader'){
    //仅显示单据头字段（一行）
    $groupby = $queryGenerator->getGroupBy();
}
$list_query=$list_query." inner join ( $page_list_query  ) as temp on temp.$focus->table_index=$focus->table_name.$focus->table_index $where ";
if(!array_key_exists('exportgetcount',$_SESSION[$currentModule][$current_user->id]['export']))
{
     $list_query_detail=str_ireplace(' distinct '," ",$page_list_query);
      $detail_result = $adb->pquery($list_query_detail, $params);
     $detailcounts = $adb->num_rows($detail_result);      
     $listcounts_result = $adb->pquery($page_list_query, $params);
     $listcounts = $adb->num_rows($listcounts_result);
    $_SESSION[$currentModule][$current_user->id]['export']['detailcounts']=$detailcounts;
    $_SESSION[$currentModule][$current_user->id]['export']['listcounts']=$listcounts;
    $_SESSION[$currentModule][$current_user->id]['export']['exportgetcount']="##SUCCESS##". $listcounts.'details'.$detailcounts;

}
$listcounts=$_SESSION[$currentModule][$current_user->id]['export']['listcounts'];
$detailcounts=$_SESSION[$currentModule][$current_user->id]['export']['detailcounts'];

list($page_list_query,$order_by,$sorder) = $queryGenerator->customview->getOrderWhere($page_list_query);


crm_load_class_file('ExportTabDetailController','include/ListView');
$controller = new ExportTabDetailController($adb, $current_user, $queryGenerator,$currentModule,'excel');

if(isset($skipAction)==false){
	$skipAction==false;
}

//得到列头
$listview_header = $controller->getListViewHeader($focus,$currentModule,$url_string,$sorder,$order_by,$skipAction);

foreach($listview_header as $key=>$arr){
    $listview_header[$key]=strip_tags($arr);
}
foreach($listview_header as $key=>$arr){
    $activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex($key).'1',trim($arr));
    $objPHPExcel->getActiveSheet()->getColumnDimension(PHPExcel_Cell::stringFromColumnIndex($key))->setWidth(20);
}

$objWriter->save($pathname); 
$where=$queryGenerator->getWhereClause();
$list_query = $queryGenerator->getQuery('',2);//所有数据查询
$prev_totalrows=0;

$progress_step=$page_width/$detailcounts;

$nums =$eachexportcount/2;
$step = $eachexportcount/$nums;

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
  crm_load_class_file("cls_excelImage",'include');
 $excelimageobj=new cls_excelImage();
if($startexportindex<$listcounts)
{
    //230530 wym 图片字段添加超链接
    $sql="select crm_address from ld_organizationdetails";
    $result = $adb->pquery($sql, array());
    $organization_crm_address = $adb->query_result($result,0,'crm_address');
    if(array_key_exists('exportprev_totalrows',$_SESSION[$currentModule][$current_user->id]['export']))
    {
        $prev_totalrows=$_SESSION[$currentModule][$current_user->id]['export']['exportprev_totalrows'];
    }
    for($s=1;$s<=$step;$s++)
    {
        $start=($s-1)*$nums+$startexportindex;
        $queryLIMIT = ' LIMIT '.$start.','.$nums;
         $tmplist_query="$list_query inner join ($page_list_query  $queryLIMIT) as tmp on tmp.$focus->table_index=$focus->table_name.$focus->table_index $where $groupby";
        list($tmplist_query,$order_by,$sorder) = $queryGenerator->customview->getOrderWhere($tmplist_query);
        //zkt 20240904 BUG20240903-55 CustomForm25导出的时候，单据分录明细的顺序会乱，有没有办法能修改。
        if(trim($sorder)!=''&&(array_key_exists($focus->Detail_table, $queryGenerator->DetailTableColumn) || array_key_exists($focus->Detail_table_scf, $queryGenerator->DetailTableColumn)))
            $tmplist_query.=" ,   ".$focus->Detail_table.'.'.$focus->Detail_table_id.' asc ';
         $list_result = $adb->pquery($tmplist_query, $params);
         $rows=$adb->num_rows($list_result);
         if($rows<=0)
         {
            break;
         }
          //$listcounts:导出数据的总行数
        $listview_entries = $controller->getListViewEntries($focus,$currentModule,$list_result,$navigation_array,$skipAction,false,'nosubstr');
        $headerlistfields = $controller->listViewFields;
         

      
        $a=2;
         foreach($listview_entries as $key=>$arr)
         {
            //zkt 20230808 BUG0070643  模块售后维护保养，导出错位 
            $key2 = 0;
            foreach($arr as $indexkey2=>$arr2){
                 $fieldname=$headerlistfields[$indexkey2];
                $fieldinfo=$controller->getListViewFieldobj($indexkey2,$fieldname);
            
                if($fieldinfo->isImageField()=="yes")
                {
                                
                    $excelimageobj->setCellImage($objPHPExcel,$arr2,$key+$a+$prev_totalrows,$key2,$activesheet,$organization_crm_address);
                                
                                
                }
                ////edit: xll 2023/07/13 BUG0069040 单据列表界面，导出模板中应该不显示单据头和单据分录的“附件”字段
                // wym BUG0075571 单据列表界面，导出模板中可以导出图片字段
                else if($fieldinfo -> getBigtype() == 'fileattachment'  && $fieldname != 'imagename' &&$fieldinfo->getUIType() != 69){
                    continue;
                }
                else {
                    if ($fieldinfo && $fieldinfo->getFieldDataType() == 'date') {
                        $activesheet->setCellValueExplicit(PHPExcel_Cell::stringFromColumnIndex($key2) . ($key + $a + ($prev_totalrows)), trim($arr2), PHPExcel_Cell_DataType::TYPE_STRING);
                        $activesheet->getStyle(PHPExcel_Cell::stringFromColumnIndex($key2) . ($key + $a + $prev_totalrows))->getNumberFormat()->setFormatCode('yyyy-mm-dd');
                    }
                    else if ($fieldinfo && $fieldinfo->getFieldDataType() == 'datetime') {
                        $activesheet->setCellValueExplicit(PHPExcel_Cell::stringFromColumnIndex($key2) . ($key + $a + ($prev_totalrows)), trim($arr2), PHPExcel_Cell_DataType::TYPE_STRING);
                        $activesheet->getStyle(PHPExcel_Cell::stringFromColumnIndex($key2) . ($key + $a + $prev_totalrows))->getNumberFormat()->setFormatCode('yyyy-mm-dd hh:mm:ss');
                    }
                    else if ($fieldinfo && $fieldinfo->getFieldDataType() == 'time') {
                        $activesheet->setCellValueExplicit(PHPExcel_Cell::stringFromColumnIndex($key2) . ($key + $a + ($prev_totalrows)), trim($arr2), PHPExcel_Cell_DataType::TYPE_STRING);
                        $activesheet->getStyle(PHPExcel_Cell::stringFromColumnIndex($key2) . ($key + $a + $prev_totalrows))->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_DATE_TIME3);
                    }
                    else if ($fieldinfo && ($fieldinfo->isAmountorCurrencyField())) {//判断是否为 单据分录明细金额字段和单据头货币字段
                        $typedecimal = explode(',', $fieldinfo->typeofData);
                        $tmpdecimal = $typedecimal[1];
                        $tmpstr = number_format(0, (int)$tmpdecimal);
                        $activesheet->setCellValueExplicit(PHPExcel_Cell::stringFromColumnIndex($key2) . ($key + $a + ($prev_totalrows)), trim($arr2), PHPExcel_Cell_DataType::TYPE_NUMERIC);
                        $activesheet->getStyle(PHPExcel_Cell::stringFromColumnIndex($key2) . ($key + $a + $prev_totalrows))->getNumberFormat()->setFormatCode('#,##'.$tmpstr);

                        if ($fieldinfo && ($fieldinfo->istotalFldMoneyField()) && $controller->getExportStyle() == 'firstcolheader' && empty($arr2)) {
                            //导出 每一个单据主表字段只显示一行，分录完全显示 时，单元格不设置类型
                            $activesheet->setCellValueExplicit(PHPExcel_Cell::stringFromColumnIndex($key2) . ($key + $a + $prev_totalrows), trim($arr2));
                        }
                    }
                    else if ($fieldinfo && $fieldinfo->isPriceField()) {  //单价类型
                        $arr2 = str_replace(',', '', strip_tags($arr2));
                        $typedecimal = explode(',', $fieldinfo->typeofData);
                        $tmpdecimal = $typedecimal[1];
                        //XUQIU1001388zl单据头字段单独判断,控制导出excel的小数位数
                        if ($fieldinfo instanceof ProductFields || $fieldinfo instanceof TabDetailToolFields){
                            $unitprice = getSys_deploy(93);
                            $tmpdecimal = $unitprice['deploy_value'];
                        }
                        $tmpstr = number_format(0, (int)$tmpdecimal);
                        $activesheet->setCellValueExplicit(PHPExcel_Cell::stringFromColumnIndex($key2) . ($key + $a + ($prev_totalrows)), trim($arr2), PHPExcel_Cell_DataType::TYPE_NUMERIC);
                        $activesheet->getStyle(PHPExcel_Cell::stringFromColumnIndex($key2) . ($key + $a + $prev_totalrows))->getNumberFormat()->setFormatCode('#,##'.$tmpstr);
                    }
                    else if ($fieldinfo && ($fieldinfo->istotalFldNumField())) {//数字类型
                        $arr2 = str_replace(',', '', strip_tags($arr2));
                        $typedecimal = explode(',', $fieldinfo->typeofData);
                        $tmpdecimal = $typedecimal[1];
                        //XUQIU1001388zl单据头字段单独判断,控制导出excel的小数位数
                        if ($fieldinfo instanceof ProductFields || $fieldinfo instanceof TabDetailToolFields){
                            $number = getSys_deploy(49);
                            $tmpdecimal = $number['deploy_value'];
                        }
                        $tmpstr = number_format(0, (int)$tmpdecimal);
                        $activesheet->setCellValueExplicit(PHPExcel_Cell::stringFromColumnIndex($key2) . ($key + $a + ($prev_totalrows)), trim($arr2), PHPExcel_Cell_DataType::TYPE_NUMERIC);
                        $activesheet->getStyle(PHPExcel_Cell::stringFromColumnIndex($key2) . ($key + $a + $prev_totalrows))->getNumberFormat()->setFormatCode($tmpstr);
                    }
                    else {
                        $activesheet->setCellValueExplicit(PHPExcel_Cell::stringFromColumnIndex($key2) . ($key + $a + ($prev_totalrows)), trim($arr2), PHPExcel_Cell_DataType::TYPE_STRING);
                    }
                    
                }
                $key2 ++;
            }
            
           
        }
         $prev_totalrows+=$rows; 
        unset($listview_entries);
    }

      $_SESSION[$currentModule][$current_user->id]['export']['total_list_query']="$list_query inner join ($page_list_query    ) as tmp on tmp.$focus->table_index=$focus->table_name.$focus->table_index $where  $orderby";
      $_SESSION[$currentModule][$current_user->id]['export']['list_query']="$list_query inner join ($page_list_query    ) as tmp on tmp.$focus->table_index=$focus->table_name.$focus->table_index $where  $orderby";
      $_SESSION[$currentModule][$current_user->id]['export']['exportprev_totalrows']=$prev_totalrows;
            

     $tmptmp=$startexportindex+$eachexportcount;
    if($tmptmp<$listcounts)
    {
      
    }
    else
    {
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
         
        unset($_SESSION[$currentModule][$current_user->id]['export']);
        $_REQUEST['frommodule']=$currentModule;
        
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


?>