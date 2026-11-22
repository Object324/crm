<?php
/**
 * 列表不带明细的测试
 *
 *
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
    include(globalStatic::$root_directory."modules/lingdang/Export/ExportSingleCSVNew.php");
    exit();
}



$languageType=getLanguageType($current_user);


//require_once('include/ListView/ListViewSession.php');
//crm_load_class_file("ListViewSession",'include/ListView');
include('PHPExcel/PHPExcel.php');
$pathname='storage/'.$current_user->id.'_'.$currentModule.'.xls';
$_SESSION[$currentModule][$current_user->id]['export']['startexportindex']=$startexportindex+$eachexportcount;
if($_SESSION[$currentModule][$current_user->id]['export']['listcounts'])
{
    $listcounts=$_SESSION[$currentModule][$current_user->id]['export']['listcounts'];


}

$startexportindex=$_REQUEST['startexportrow'];
$endexportrow=$_REQUEST['endexportrow'];

$eachexportcount=$endexportrow-$startexportindex;//每次导出的记录数量50


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
if( isset($_SESSION['LiveViewSearch'][$currentModule])&&($_REQUEST['search_type']=='includesearch'||$_REQUEST['search_type']=='withoutsearch'||$_REQUEST['search_type']=='selecteddata')){
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
//20240726 hzx XUQIU1001729 经销商用PRM成员管理设置
if($currentModule == 'Users' && $_REQUEST['user_type']){
    $user_type = 'crm';
    if(isset($_REQUEST['user_type'])){
        $user_type = $_REQUEST['user_type'];
    }
    $focus->setuser_type($user_type);
    $where = $focus->getusertypewheresql();
    if(!empty($where['where'])){
        $queryGenerator->AddSqlWhere(" and ".$where['where'],array(),array());
    }
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

if(( !is_array($idstring)||count($idstring)<=0)&&$search_type == 'selecteddata'&&$_REQUEST['idstring']!='all')$querywhere=" and 1<>1 ";

if($module!='InventoryAccount')
    $chart_owner=$queryGenerator->getSmOwnerSearchSql();
if($_SESSION[$currentModule][$current_user->id]['export']['page_list_query'])
    $page_list_query=$_SESSION[$currentModule][$current_user->id]['export']['page_list_query'];
else
{
    //edit:can 2020-09-25 中孚账套个人用户导出没有数据
    $page_list_query=$page_list_query.$querywhere;
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
    $fieldinfo = $focus->fieldobj->getFieldByColumnName($controller->listViewFields_permitarr[$key]);
    if (!empty($fieldifo)){
        $Header_FromArray["font"]["color"]["rgb"] = $fieldifo->getExportLabelColor();
    }
    $activesheet->getStyle(PHPExcel_Cell::stringFromColumnIndex($key) . '1')->applyFromArray($Header_FromArray);
    $activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex($key).'1',trim($arr));
    $objPHPExcel->getActiveSheet()->getColumnDimension(PHPExcel_Cell::stringFromColumnIndex($key))->setWidth(20);
}



$listcounts=$_SESSION[$currentModule][$current_user->id]['export']['listcounts'];
$prev_totalrows=0;
$nums =$eachexportcount/2;
$step = ceil($eachexportcount/$nums);

$progress_step=$page_width/$listcounts;
if(array_key_exists('exportprev_totalrows',$_SESSION[$currentModule][$current_user->id]['export']))
{
    $prev_totalrows=$_SESSION[$currentModule][$current_user->id]['export']['exportprev_totalrows'];
}

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
$detailcounts=$listcounts;
//230530 wym 图片字段添加超链接
$sql="select crm_address from ld_organizationdetails";
$result = $adb->pquery($sql, array());
$organization_crm_address = $adb->query_result($result,0,'crm_address');

require_once globalStatic::$root_directory.'Register/ld_Sm4.php';
global $sm4_key;
$sm4 = new ld_Sm4($sm4_key);
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
    $headerlistfields = $controller->listViewFields;
    
    $rows=$adb->num_rows($list_result);
    if($rows<=0)
        break;

    $_REQUEST['export']='yes';
    $listview_entries = $controller->getListViewEntries($focus,$currentModule,$list_result,array(),$skipAction,false,'nosubstr');

    // $_SESSION[$currentModule][$current_user->id]['export']['headerlistfields']=$headerlistfields;

    $a=2;
    foreach($listview_entries as $key=>$arr)
    {
        $key2 = 0;
        foreach($arr as $indexkey2=>$arr2){
            $fieldname=$headerlistfields[$indexkey2];
            $fieldinfo=$controller->getListViewFieldobj($indexkey2,$fieldname);

            if ($fieldinfo && (string)$arr2 !== '') {
                $arr2_decrypt = false;
                if ($fieldinfo->getBigType()=="text" && $fieldinfo->getIsEncrypt()=="yes") {
                    $arr2_decrypt = $sm4->Decrypt($arr2);
                } elseif ($fieldinfo->getBigType() == 'reference') {//关联选择单据
                    crm_load_class_file("cls_module_uitype", 'include/fields');
                    $uitypemodules = cls_module_uitype::getUitypeModules();
                    $referencemodule = $uitypemodules[$fieldinfo->getUIType()];
                    if(!empty($referencemodule)){
                        $entityarray = getEntitynameInfo(getTabid($referencemodule));

                        $referencemodule_focus = CRMEntity::getInstance($referencemodule);
                        $referencemodule_fieldinfo = $referencemodule_focus->fieldobj->getFieldInfoobjBykey("fieldname", $entityarray['fieldname']);
                        if ($referencemodule_fieldinfo&&$referencemodule_fieldinfo->getIsEncrypt()=="yes") {
                            $arr2_decrypt = $sm4->Decrypt($arr2);
                        }
                    }
                }
                $arr2 = $arr2_decrypt !== false?$arr2_decrypt:$arr2;
            }

            if($fieldinfo&&$fieldinfo->isImageField()=="yes")
            {
                if(!empty($arr2)){
                    $excelimageobj->setCellImage($objPHPExcel,$arr2,$key+$a+$prev_totalrows,$key2,$activesheet,$organization_crm_address);
                }


            }
            elseif($fieldinfo&&$fieldinfo->getUIType()==222)
            {
                //ls 2022-07-14 1000072 “手写签名”字段可放在单据列表，也支持导出图片（导出Excel格式，签名时间也导出）
                //注：导出功能在系统文件里有好几个地方都有这种逻辑，但其他的文件可能是废弃的，灿哥说先只改这个 ExportSingleDataNew.php 文件
                $excelimageobj->setCellImage($objPHPExcel,$arr2['imagepath'],$key+$a+$prev_totalrows,$key2,$activesheet,$organization_crm_address);
                $activesheet->setCellValueExplicit(PHPExcel_Cell::stringFromColumnIndex($key2).($key+$a+$prev_totalrows), trim($arr2['datetime']),PHPExcel_Cell_DataType::TYPE_STRING);

            }
            //edit: xll 2023/07/13 BUG0069040 单据列表界面，导出模板中应该不显示单据头和单据分录的“附件”字段
            // wym BUG0075571 单据列表界面，导出模板中可以导出图片字段
            else if($fieldinfo&&$fieldinfo -> getBigtype() == 'fileattachment'  && $fieldname != 'imagename' &&$fieldinfo->getUIType() != 69){
                continue;
            }
            else{
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
                else if ($fieldinfo && ($fieldinfo->isAmountorCurrencyField())) { //判断是否为 单据分录明细金额字段和单据头货币字段
                    $typedecimal = explode(',', $fieldinfo->typeofData);
                    $tmpdecimal = $typedecimal[1];
                    $tmpstr = number_format(0, (int)$tmpdecimal);
                    $activesheet->setCellValueExplicit(PHPExcel_Cell::stringFromColumnIndex($key2) . ($key + $a + ($prev_totalrows)), trim($arr2), PHPExcel_Cell_DataType::TYPE_NUMERIC);
                    $activesheet->getStyle(PHPExcel_Cell::stringFromColumnIndex($key2) . ($key + $a + $prev_totalrows))->getNumberFormat()->setFormatCode('#,##'.$tmpstr);
                }
                else if ($fieldinfo && $fieldinfo->isPriceField()) {  //单价类型
                    $arr2 = str_replace(',', '', strip_tags($arr2));
                    $typedecimal = explode(',', $fieldinfo->typeofData);
                    $tmpdecimal = $typedecimal[1];
                    $tmpstr = number_format(0, (int)$tmpdecimal);
                    $activesheet->setCellValueExplicit(PHPExcel_Cell::stringFromColumnIndex($key2) . ($key + $a + ($prev_totalrows)), trim($arr2), PHPExcel_Cell_DataType::TYPE_NUMERIC);
                    $activesheet->getStyle(PHPExcel_Cell::stringFromColumnIndex($key2) . ($key + $a + $prev_totalrows))->getNumberFormat()->setFormatCode('#,##'.$tmpstr);
                }
                else if ($fieldinfo && ($fieldinfo->istotalFldNumField())) {//数字类型
                    $arr2 = str_replace(',', '', strip_tags($arr2));
                    $typedecimal = explode(',', $fieldinfo->typeofData);
                    $tmpdecimal = $typedecimal[1];
                    $tmpstr = number_format(0, (int)$tmpdecimal);
                    $activesheet->setCellValueExplicit(PHPExcel_Cell::stringFromColumnIndex($key2) . ($key + $a + ($prev_totalrows)), trim($arr2), PHPExcel_Cell_DataType::TYPE_NUMERIC);
                    $activesheet->getStyle(PHPExcel_Cell::stringFromColumnIndex($key2) . ($key + $a + $prev_totalrows))->getNumberFormat()->setFormatCode($tmpstr);
                }
                else {
                    $activesheet->setCellValueExplicit(PHPExcel_Cell::stringFromColumnIndex($key2) . ($key + $a + ($prev_totalrows)), trim($arr2), PHPExcel_Cell_DataType::TYPE_STRING);
                }
            }
            $key2++;
        }



    }
    $prev_totalrows+=$rows;
    unset($listview_entries);
}


$_SESSION[$currentModule][$current_user->id]['export']['total_list_query']="$list_query inner join ($page_list_query   ) as tmp on tmp.$focus->table_index=$focus->table_name.$focus->table_index $where  $orderby";
$_SESSION[$currentModule][$current_user->id]['export']['list_query']="$list_query inner join ($page_list_query   ) as tmp on tmp.$focus->table_index=$focus->table_name.$focus->table_index $where  $orderby";
$_SESSION[$currentModule][$current_user->id]['export']['exportprev_totalrows']=$prev_totalrows;



$tmptmp=$startexportindex+$eachexportcount;
if($tmptmp<$listcounts)
{

}
else
{
    foreach($listview_header as $key=>$arr)
    {
        $fieldname = $headerlistfields[$key];

        $fieldinfo = $controller->getListViewFieldobj($key, $fieldname);
        $tmp = PHPExcel_Cell::stringFromColumnIndex($key);

        if ($fieldinfo && $fieldinfo->isImageField() == "yes") {
            $deploy_75 = getSys_deploy(75);
            $deployarray_75 = explode(',', $deploy_75['deploy_value']);
            //DPI             Scale      ColumnWidth             RowHeight
            //72dpi           75%       cw=(pix-5)/6              rh=pix*1
            $objPHPExcel->getActiveSheet()->getColumnDimension($tmp)->setWidth(ceil(($deployarray_75[0]-5)/6));
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
                $allCurrencies=["¥","￡","￥","€","AUD","ALL","HKD","TWD"];
                foreach ($allCurrencies as $currency) {
                    if (strpos($tmpvalue, $currency) !== false) {
                        $containcur = strpos($tmpvalue, $currency) ;
                        $tmpvalue = str_replace($currency, '', strip_tags($tmpvalue));
                        $activesheet->getStyle(PHPExcel_Cell::stringFromColumnIndex($key).($maxkey+2))->getNumberFormat()->setFormatCode('#,##0.00');
                    }
                }
            }

    }


    unset($_SESSION[$currentModule][$current_user->id]['export']);
}
$objWriter->save($pathname);

include(globalStatic::$root_directory.'modules/lingdang/Export/ExportProgressDescription.php');
$ret_arr['timedescription']=$time_description;
$ret_arr['content']=$progresshtml;
$ret_arr['startexportrow']=$startexportindex;
$ret_arr['endexportrow']=$endexportrow;
$ret_arr['listcount']=$listcounts;
$ret_arr['detailcount']=$listcounts;


// $ret_arr['writefilelabel']=getFixedLabel('WRITEEXCELFILE');
//$ret_arr['title']=getTranstab($currentModule).'>'. getFixedLabel('EXPORTDATATITLE');
global $languageType;
if($languageType == 'en') {
    $ret_arr['title'] = getFixedLabel("EXPORT") .' '. getTranstab($currentModule);
}
else{
    $ret_arr['title'] = getFixedLabel("EXPORT") . getTranstab($currentModule);
}
ConvertTojsonString(1,$ret_arr,'success');

exit();
?>