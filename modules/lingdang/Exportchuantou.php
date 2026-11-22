<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global  $currentModule, $current_user, $theme, $adb;
include('PHPExcel/PHPExcel.php');
if($_REQUEST['getprogress']=='yes') {//第一次导出
    crm_load_class_file("LoginHistory",'modules/Users');//添加操作日志
    $historyobj=new LoginHistory();
    $historyobj->user_operation_history('Export_customview',$currentModule);
    $_REQUEST['startexportrow']=0;//第一次导出时开始行默认为0
    $_REQUEST['endexportrow']=10;//第一次导出时结束行默认为10
    unset($_SESSION[$currentModule][$current_user->id]['export_chuantou']);
    $_SESSION[$currentModule][$current_user->id]['export_chuantou']['starttime']=date("Y-m-d H:i:s");
}
$startexportindex=$_REQUEST['startexportrow'];
$endexportrow=$_REQUEST['endexportrow'];
$eachexportcount=$endexportrow-$startexportindex;
$_SESSION[$currentModule][$current_user->id]['export_chuantou']['startexportindex']=$startexportindex+$eachexportcount;
if($_SESSION[$currentModule][$current_user->id]['export_chuantou']['listcounts']) {//后续导出行数延用第一步保存的session值
    $listcounts=$_SESSION[$currentModule][$current_user->id]['export_chuantou']['listcounts'];
    $detailcounts=$_SESSION[$currentModule][$current_user->id]['export_chuantou']['detailcounts'];
}

//新建excel对象
$pathname='storage/'.$current_user->id.'_'.$currentModule.'_chuantou.xls';
if(array_key_exists('objphpexcel',$_SESSION[$currentModule][$current_user->id]['export_chuantou'])) {
    $objPHPExcel = PHPExcel_IOFactory::load($pathname);
} else {
    $objPHPExcel = new PHPExcel();
    $_SESSION[$currentModule][$current_user->id]['export_chuantou']['objphpexcel']=serialize($objPHPExcel);
}
$objPHPExcel->setActiveSheetIndex(0);
$activesheet=$objPHPExcel->getActiveSheet();
$activesheet->setTitle(strip_tags($_REQUEST['title']));//title 里面有html 需要去掉
$objWriter = PHPExcel_IOFactory::createWriter($objPHPExcel, 'Excel5');



//列表体
$focus = CRMEntity::getInstance($currentModule);

/*$customView = new CustomView($currentModule);
$viewid = $customView->getViewId($currentModule);
$queryGenerator = QueryGenerator::getInstance($currentModule, $current_user,$customView);
///得到对应视图的查询字段
if ($viewid != "0") {
    $queryGenerator->initForCustomViewById($viewid);
} else {
    $queryGenerator->initForDefaultCustomView();
}*/
//zxm @date:2024/11/15 @reason: 组件穿透的导出  querygenerator应该从报表类中得
$boardid = $_REQUEST['boardid'];
require_once(globalStatic::$root_directory."modules/Home/DataRangeHomeboard.php");
$DataRangeHomeboardObj = DataRangeHomeboard::getInstance($boardid);
$queryGenerator = $DataRangeHomeboardObj->get_query_obj($currentModule);
$viewid = $queryGenerator->customview->cvid;
//zxm @date:2024/11/15 @reason: 导出  客户也有明细的
if(get_file_address($currentModule,"ProductDetails")||$currentModule=='Accounts'||$currentModule=='ServiceCharge'||$currentModule=='Vendors'){
    //有明細
    crm_load_class_file('ExportProductDetailController','include/ListView');
    $controller = new ExportProductDetailController($adb, $current_user, $queryGenerator,'excel');
}elseif(get_file_address($currentModule,$currentModule.'DetailFieldsHtml')){
    crm_load_class_file('ExportTabDetailController','include/ListView');
    $controller = new ExportTabDetailController($adb, $current_user, $queryGenerator,$currentModule,'excel');
}else{
    //无明細
    crm_load_class_file('cls_ExportListView','include/ListView/ExportListView');
    $controller = new cls_ExportListView($adb, $current_user, $queryGenerator,'excel');
}

//对sql进行解密
crm_load_class_file('cls_MyCRMcrypt',"Register");
$cls_MyCRMcryptobj=new cls_MyCRMcrypt();
$list_query = $cls_MyCRMcryptobj->decode($_REQUEST['list_query1']);
$list_query_where = $cls_MyCRMcryptobj->decode($_REQUEST['list_query2']);
$page_list_query = $cls_MyCRMcryptobj->decode($_REQUEST['page_list_query']);
$order_by = $cls_MyCRMcryptobj->decode($_REQUEST['order_by']);
$sorder = $cls_MyCRMcryptobj->decode($_REQUEST['sorder']);

//列表头
//wym BUG0072738 本来表头在加载穿透界面时传值给导出文件，但现在有bug提出表头不能有附件和图片 所以重新获取
//$listview_header = $_REQUEST['listheader'];
//wym 240122 BUG20240112-16 数据简报-点击新建客户数，进入单据界面，点击导出，导出的文件中，缺少首要联系人字段，并且还增加了“操作”列
$controller->havelistcheckbox = 'no';//不要多选列
$controller->haveExistsOperation = 'no';//不要操作列
$controller->haveoperation = false;//不要操作列 最后一列不要合并
$listview_header = $controller->getListViewHeader($focus,$currentModule,'',$sorder,$order_by,$skipAction);

foreach($listview_header as $key=>$arr){
    $listview_header[$key]=strip_tags($arr);
}
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

if(PerformancePrefs::getBoolean('LISTVIEW_COMPUTE_PAGE_COUNT', false) === true) {
    $count_result = $adb->query($page_list_query);
    if(!empty($count_result))
        $noofrows=$adb->num_rows($count_result);
    else
        $noofrows = null;
}else {
    $noofrows = null;
}
$queryMode = (isset($_REQUEST['query']) && $_REQUEST['query'] == 'true');
$start = ListViewSession::getRequestCurrentPage($currentModule, $list_query , $viewid, $queryMode);
crm_load_function_file('VT_getSimpleNavigationValues','include/utils','ListViewUtils');
$navigation_array = VT_getSimpleNavigationValues($start, $_REQUEST['exportnum_onestep'],$noofrows);
if(!array_key_exists('exportgetcount',$_SESSION[$currentModule][$current_user->id]['export_chuantou'])) {//第一次导出
    $detail_result = $adb->pquery($list_query);
    $detailcounts = $adb->num_rows($detail_result);
    $listcounts_result = $adb->pquery($page_list_query);
    $listcounts = $adb->num_rows($listcounts_result);
    $_SESSION[$currentModule][$current_user->id]['export_chuantou']['listcounts']=$listcounts;
    $_SESSION[$currentModule][$current_user->id]['export_chuantou']['detailcounts']=$detailcounts;
    $_SESSION[$currentModule][$current_user->id]['export_chuantou']['exportgetcount']="##SUCCESS##". $listcounts.'details'.$detailcounts;
}else {
    $listcounts = $_REQUEST['listcounts']??$_SESSION[$currentModule][$current_user->id]['export_chuantou']['listcounts'];
    $detailcounts = $_REQUEST['detailcounts']??$_SESSION[$currentModule][$current_user->id]['export_chuantou']['detailcounts'];
}

$prev_totalrows=0;
$nums =$eachexportcount/2;
$step = ($eachexportcount/$nums);
if($startexportindex<=$listcounts)
{
    if(array_key_exists('exportprev_totalrows',$_SESSION[$currentModule][$current_user->id]['export_chuantou'])) {
        $prev_totalrows=$_SESSION[$currentModule][$current_user->id]['export_chuantou']['exportprev_totalrows'];
    }

    //230530 wym 图片字段添加超链接
    $sql="select crm_address from ld_organizationdetails";
    $result = $adb->pquery($sql, array());
    $organization_crm_address = $adb->query_result($result,0,'crm_address');
    for($s = 1; $s <= $step; ++$s) {

        $start = ($s - 1) * $nums+$startexportindex;
        $queryLIMIT =  ' LIMIT '.$start.','.$nums;
        $tmplist_query=$list_query." inner join ( $page_list_query $queryLIMIT ) as temp on temp.$focus->table_index=$focus->table_name.$focus->table_index".$list_query_where;

        list($tmplist_query,$order_by,$sorder) = $queryGenerator->customview->getOrderWhere($tmplist_query);

        $list_result = $adb->pquery($tmplist_query);

        $rows=$adb->num_rows($list_result);
        if($rows<=0)
            break;
        $listview_entries = $controller->getListViewEntries($focus,$currentModule,$list_result,$navigation_array,$skipAction,true,'export');

        //没明细的应该用下一行获取listview_entries,但目前没遇到问题,所以先跟 有明细的用一样的参数,如果有bug可以让没明细的模块试着用下一行
        //$listview_entries = $controller->getListViewEntries($focus,$currentModule,$list_result,array(),$skipAction,false,'nosubstr');

        $headerlistfields=$controller->listViewFields;
        $a=2;

        foreach($listview_entries as $key=>$arr){
            $key2 = 0;
            foreach($arr as $indexkey2=>$arr2){
                $fieldname=$headerlistfields[$indexkey2];
                $fieldinfo=$controller->getListViewFieldobj($indexkey2,$fieldname);
                if($fieldinfo&&$fieldinfo->isImageField()=="yes")
                {
                    crm_load_class_file("cls_excelImage",'include');
                    $excelimageobj=new cls_excelImage();
                    $excelimageobj->setCellImage($objPHPExcel,$arr2,$key+$a+$prev_totalrows,$key2,$activesheet,$organization_crm_address);
                }
                else if($fieldinfo -> getBigtype() == 'fileattachment'  && $fieldname != 'imagename'){
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
                    else if($fieldinfo && ($fieldinfo->isAmountorCurrencyField())) {  //判断是否为 单据分录明细金额字段和单据头货币字段
                        $typedecimal = explode(',', $fieldinfo->typeofData);
                        $tmpdecimal = $typedecimal[1];
                        $tmpstr = number_format(0, (int)$tmpdecimal);
                        $activesheet->setCellValueExplicit(PHPExcel_Cell::stringFromColumnIndex($key2) . ($key + $a + ($prev_totalrows)), trim($arr2), PHPExcel_Cell_DataType::TYPE_NUMERIC);
                        $activesheet->getStyle(PHPExcel_Cell::stringFromColumnIndex($key2) . ($key + $a + $prev_totalrows))->getNumberFormat()->setFormatCode('#,##'.$tmpstr);
                        //zkt 20220915 BUG0056484客户问题（凡图工业），合同订单列表全部数据分类，导出所有数据，导出样式选择“导出明细：单据头仅显示首行”导出数据后，Excel表格中合计值求和错误
                        if ($fieldinfo && ($fieldinfo->istotalFldMoneyField()) && $controller->getExportStyle() == 'firstcolheader' && empty($arr2)) {
                            //导出 每一个单据主表字段只显示一行，分录完全显示 时，单元格不设置类型
                            $activesheet->setCellValueExplicit(PHPExcel_Cell::stringFromColumnIndex($key2) . ($key + $a + $prev_totalrows), trim($arr2));
                        }
                    }
                    //XUQIU1001388 zl
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
                    else if ($fieldinfo && ($fieldinfo->isAmountorCurrencyField())) {  //判断是否为 单据分录明细金额字段和单据头货币字段
                        $typedecimal = explode(',', $fieldinfo->typeofData);
                        $tmpdecimal = $typedecimal[1];
                        $tmpstr = number_format(0, (int)$tmpdecimal);
                        $activesheet->setCellValueExplicit(PHPExcel_Cell::stringFromColumnIndex($key2) . ($key + $a + ($prev_totalrows)), trim($arr2), PHPExcel_Cell_DataType::TYPE_NUMERIC);
                        $activesheet->getStyle(PHPExcel_Cell::stringFromColumnIndex($key2) . ($key + $a + $prev_totalrows))->getNumberFormat()->setFormatCode('#,##'.$tmpstr);

                    }
                    else {
                        $activesheet->setCellValueExplicit(PHPExcel_Cell::stringFromColumnIndex($key2) . ($key + $a + ($prev_totalrows)), trim($arr2), PHPExcel_Cell_DataType::TYPE_STRING);
                    }

                }
                $key2++;
            }

        }

        $prev_totalrows+= count($listview_entries);
        unset($listview_entries);
    }

    $_SESSION[$currentModule][$current_user->id]['export_chuantou']['exportprev_totalrows']=$prev_totalrows;
    $objWriter->save($pathname);
    $ret_arr['startexportrow']=$startexportindex;
    $ret_arr['endexportrow']=$endexportrow;
    $ret_arr['listcount']=$listcounts;
    $ret_arr['detailcount']=$detailcounts;

    include(globalStatic::$root_directory.'modules/lingdang/Export/ExportProgressHtml.php');
    $ret_arr['content']=$progresshtml;
    $ret_arr['title']=getTranstab($currentModule).'>'. getFixedLabel('EXPORTDATATITLE');
    $_REQUEST['diony']='yes';
    ConvertTojsonString(1,$ret_arr,'success');
}
else {
     $_REQUEST['diony']='yes';
    unset($_SESSION[$currentModule][$current_user->id]['export_chuantou']);
    ConvertTojsonString(2,'','success');
}

?>