<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb;
set_time_limit(0);
global  $currentModule, $theme;
global $list_max_entries_per_page_new;
global $current_user;

require_once("modules/$currentModule/$currentModule.php");
require_once("include/ProductDetails/ProductDetails.php");
require('user_privileges/user_privileges_'.$current_user->id.'.php');
include('PHPExcel/PHPExcel.php');
$_REQUEST['diony']='yes';
if($_REQUEST['getprogress']=='yes')
{

    include(globalStatic::$root_directory.'modules/lingdang/Export/ExportProgressHtml.php');

}
if($_REQUEST['exportformat']=='exportcsv')
{
    //导出csv格式

    include(globalStatic::$root_directory."modules/ServiceCharge/ExportServiceChargeCSVNew.php");

    exit();
}
$pathname='storage/'.$current_user->id.'_'.$currentModule.'.xls';


$startexportindex=$_REQUEST['startexportrow'];
$endexportrow=$_REQUEST['endexportrow'];

$eachexportcount=$endexportrow-$startexportindex;//每次导出的记录数量50


$_SESSION[$currentModule][$current_user->id]['export']['startexportindex']=$startexportindex+$eachexportcount;
if($_SESSION[$currentModule][$current_user->id]['export']['listcounts'])
{
    $listcounts=$_SESSION[$currentModule][$current_user->id]['export']['listcounts'];
    $detailcounts=$_SESSION[$currentModule][$current_user->id]['export']['detailcounts'];
}



if(array_key_exists('objphpexcel',$_SESSION[$currentModule][$current_user->id]['export']))
{

    $objPHPExcel =PHPExcel_IOFactory::load('storage/'.$current_user->id.'_'.$currentModule.'.xls');

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

$_SESSION[$currentModule."_Order_By"] = $order_by;
$_SESSION[$currentModule."_Sort_Order"]=$sorder;
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
$list_query=$list_query." inner join ( $page_list_query   ) as temp on temp.$focus->table_index=$focus->table_name.$focus->table_index $where";
$list_query.=$queryGenerator->getGroupBy();
$list_count_sql= $list_query;

if(!array_key_exists('exportgetcount',$_SESSION[$currentModule][$current_user->id]['export']))
{



    $list_query_detail=str_ireplace(' distinct '," ",$page_list_query);

    $detail_result = $adb->pquery($list_query_detail, $params);
    $detailcounts = $adb->num_rows($detail_result);

    $listcounts_result = $adb->pquery($page_list_query . $querywhere, $params);
    $listcounts = $adb->num_rows($listcounts_result);
    $_SESSION[$currentModule][$current_user->id]['export']['listcounts']=$listcounts;
    $_SESSION[$currentModule][$current_user->id]['export']['detailcounts']=$detailcounts;
    $_SESSION[$currentModule][$current_user->id]['export']['exportgetcount']="##SUCCESS##". $listcounts.'details'.$detailcounts;


}
$listcounts=$_SESSION[$currentModule][$current_user->id]['export']['listcounts'];

crm_load_class_file('ExportProductDetailController','include/ListView');
$controller = new ExportProductDetailController($adb, $current_user, $queryGenerator,'excel');

if(isset($skipAction)==false){
    $skipAction==false;
}

//得到列头
$listview_header = $controller->getListViewHeader($focus,$currentModule,$url_string,$sorder,$order_by,$skipAction);


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
    $objPHPExcel->getActiveSheet()->getColumnDimension(PHPExcel_Cell::stringFromColumnIndex($key))->setWidth(20);
}


$list_query = $queryGenerator->getQuery('',2);//所有数据查询
$prev_totalrows=0;

if($startexportindex==0&&$startexportindex==$listcounts)
{

    $objWriter->save($pathname);
    unset($_SESSION[$currentModule][$current_user->id]['export']);
    $ret_arr['startexportrow']=$startexportindex;
    $ret_arr['endexportrow']=$endexportrow;
    $ret_arr['listcount']=-1;
    $ret_arr['detailcount']=-1;
    $ret_arr['title']=getTranstab($currentModule).'>>'. getFixedLabel('EXPORTDATATITLE');
    ConvertTojsonString(1,$ret_arr,'success');
}

$nums =$eachexportcount/2;
$step = ($eachexportcount/$nums);
if($startexportindex=='')
{
    $startexportindex=0;
}
if($startexportindex<$listcounts)
{

    if(array_key_exists('exportprev_totalrows',$_SESSION[$currentModule][$current_user->id]['export']))
    {
        $prev_totalrows=$_SESSION[$currentModule][$current_user->id]['export']['exportprev_totalrows'];
    }
    for($s = 1; $s <= $step; ++$s) {
        $start = ($s - 1) * $nums+$startexportindex;
        $queryLIMIT = ' LIMIT '.$start.','.$nums;
        $tmplist_query="$list_query inner join ($page_list_query   $queryLIMIT) as tmp on tmp.$focus->table_index=$focus->table_name.$focus->table_index $where  ";
        if($queryGenerator->getwith_serviceinfo() == 'yes'){
            $list_query .= ' and (ifnull(ld_servicecontracts.servicecontractsid,0)=0 or ld_servicecontracts.servicecontractsid = serviceinfo.servicecontractsid) ';
        }
        $tmplist_query.=$queryGenerator->getGroupBy();
        list($tmplist_query,$order_by,$sorder) = $queryGenerator->customview->getOrderWhere($tmplist_query);

        $list_result = $adb->pquery($tmplist_query, $params);

        $listview_entries = $controller->getListViewEntries($focus,$currentModule,$list_result,$navigation_array,$skipAction,true,'export');
        $a=2;
        foreach($listview_entries as $key=>$arr){
            foreach($arr as $key2=>$arr2){
                $headerlistfields=$controller->listViewFields;
                $fieldname=$headerlistfields[$key2];
                $fieldinfo=$controller->getListViewFieldobj($key2,$fieldname);
                if($fieldinfo&&$fieldinfo->isImageField()=="yes")
                {
                    $excelimageobj->setCellImage($objPHPExcel,$arr2,$key+$a+$prev_totalrows,$key2,$activesheet,$organization_crm_address);
                }
                else{
                    //XUQIU1001388zl 导出excel需要转换货币,数字,日期格式,先判断日期
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
                    else if ($fieldinfo && ($fieldinfo->isAmountorCurrencyField())) {  //判断是否为 单据分录明细金额字段和单据头货币字段
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
                    else{
                        $activesheet->setCellValueExplicit(PHPExcel_Cell::stringFromColumnIndex($key2).($key+$a+($prev_totalrows)), trim($arr2),PHPExcel_Cell_DataType::TYPE_STRING);
                    }
                }
            }
        }

        $prev_totalrows+= count($listview_entries);
        unset($listview_entries);
    }
    $_SESSION[$currentModule][$current_user->id]['export']['total_list_query']="$list_query inner join ($page_list_query  $querywhere $orderby ) as tmp on tmp.$focus->table_index=$focus->table_name.$focus->table_index $where  $orderby";
    $_SESSION[$currentModule][$current_user->id]['export']['list_query']="$list_query inner join ($page_list_query  $querywhere $orderby ) as tmp on tmp.$focus->table_index=$focus->table_name.$focus->table_index $where  $orderby";
    $_SESSION[$currentModule][$current_user->id]['export']['exportprev_totalrows']=$prev_totalrows;
    $objWriter->save($pathname);

    $tmptmp=$startexportindex+$eachexportcount;
    if($tmptmp<$listcounts)
    {
    }

    include(globalStatic::$root_directory.'modules/lingdang/Export/ExportProgressDescription.php');
    $ret_arr['timedescription']=$time_description;

    $ret_arr['content']=$progresshtml;
    $ret_arr['startexportrow']=$startexportindex;
    $ret_arr['endexportrow']=$endexportrow;
    $ret_arr['listcount']=$listcounts;
    //$ret_arr['writefilelabel']=getFixedLabel('WRITEEXCELFILE');
    $ret_arr['detailcount']=$detailcounts;
    $ret_arr['title']=getTranstab($currentModule).'>'. getFixedLabel('EXPORTDATATITLE');
    ConvertTojsonString(1,$ret_arr,'success');
}
else
{
    unset($_SESSION[$currentModule][$current_user->id]['export']);
    $_REQUEST['frommodule']=$currentModule;
    include(globalStatic::$root_directory.'modules/uploads/downloadxls.php');
}

exit();
?>