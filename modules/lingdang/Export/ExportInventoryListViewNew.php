<?php
/**
 * 更新操作
 * edit:andrew
 * date:20140126
 * reason:导出模板文件
 * */
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

    include(globalStatic::$root_directory."modules/lingdang/Export/ExportInventoryCSVNew.php");
    exit();
}
crm_load_class_file("ListViewSession",'include/ListView');
require_once(globalStatic::$root_directory."modules/$currentModule/$currentModule.php");
crm_load_class_file('ProductDetails',"include/ProductDetails");
require(globalStatic::$root_directory.'user_privileges/user_privileges_'.$current_user->id.'.php');
include(globalStatic::$root_directory.'PHPExcel/PHPExcel.php');
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
$objWriter = PHPExcel_IOFactory::createWriter($objPHPExcel, 'Excel5');
$objPHPExcel->setActiveSheetIndex(0);
//dump($objPHPExcel);
$activesheet=$objPHPExcel->getActiveSheet();
$moduleName = $currentModule;
//wym BUG0072635 81kfbtest--销售订单，导出后第一个页签名字不显示销售订单，应显示模块名
if(array_key_exists('objphpexcel',$_SESSION[$currentModule][$current_user->id]['export']))
{

    $modulelabel = getTranstab($moduleName);
    $modulelabel = str_replace(' ','_',$modulelabel);
    $modulelabel = str_replace('/','_',$modulelabel);
    $modulelabel = str_replace('\\','_',$modulelabel);
    $modulelabel = str_replace('?','_',$modulelabel);
    $modulelabel = str_replace('[','(',$modulelabel);
    $modulelabel = str_replace(']',')',$modulelabel);
    $objPHPExcel->getActiveSheet()->setTitle($modulelabel);

}




$category = getParentTab();
$warehouseid = 0;
$morelist = 0;
$url_string = '';


$focus = CRMEntity::getInstance($currentModule);

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
    //$ustring = getSearchURL($_REQUEST);
    //$url_string .= "&query=true$ustring";


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

$chart_owner=$queryGenerator->getSmOwnerSearchSql();

if($_SESSION[$currentModule][$current_user->id]['export']['page_list_query'])
    $page_list_query=$_SESSION[$currentModule][$current_user->id]['export']['page_list_query'];
else
{
    //$chart_owner:edit:can 2020-09-10 ,开启用户界面汇报人，非管理员导出的文件没有数据
    $page_list_query=$page_list_query.$FoSearchSQL.$querywhere.$querysearch;
    $_SESSION[$currentModule][$current_user->id]['export']['page_list_query']=$page_list_query;
}

$queryMode = (isset($_REQUEST['query']) && $_REQUEST['query'] == 'true');
$customsortorder = $customView->getCustomViewOrderBy($viewid);
$where= $queryGenerator->getWhereClause();
//zkt 20220909 XUQIU1000234 带分录和带产品分录的表单，导出弹出层中增加“导出样式”参数（胡斐）
$groupby = '';
if($_REQUEST['export_style']=='onlycolheader'){
    //仅显示单据头字段（一行）
    $groupby = $queryGenerator->getGroupBy();
}
$orderby = " ORDER BY $customsortorder $focus->table_name.$focus->table_index desc";
$list_query=$list_query." inner join ( $page_list_query   ) as temp on temp.$focus->table_index=$focus->table_name.$focus->table_index $where $groupby";

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

crm_load_class_file('ExportProductDetailController','include/ListView');
$controller = new ExportProductDetailController($adb, $current_user, $queryGenerator,'excel');
if(isset($skipAction)==false){
    $skipAction==false;
}
list($page_list_query,$order_by,$sorder) = $queryGenerator->customview->getOrderWhere($page_list_query);

//得到列头
$listview_header = $controller->getListViewHeader($focus,$currentModule,$url_string,$sorder,$order_by,$skipAction);
foreach($listview_header as $key=>$arr){
    if($arr=='税种'||$arr=='Tax Type'){
        $checkkey=$key;
    }
    if(isset($checkkey)){
        $listview_header[$key]=$listview_header[$key+1];
    }
}

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
$nums=$eachexportcount/2;//每次获取的记录数量
$step=$eachexportcount/$nums;
if(!empty($_SESSION[$currentModule][$current_user->id]['export']['detailcount']))

    $progress_step=$page_width/$_SESSION[$currentModule][$current_user->id]['export']['detailcount'];
else
    $progress_step=0;;

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
if($startexportindex<$listcounts)
{   //230530 wym 图片字段添加超链接
    $sql="select crm_address from ld_organizationdetails";
    $result = $adb->pquery($sql, array());
    $organization_crm_address = $adb->query_result($result,0,'crm_address');

    require_once globalStatic::$root_directory.'Register/ld_Sm4.php';
    global $sm4_key;
    $sm4 = new ld_Sm4($sm4_key);

    for($s=1;$s<=$step;$s++)
    {
        $start=($s-1)*$nums+$startexportindex;
        $queryLIMIT = ' LIMIT '.$start.','.$nums;

        $tmplist_query="$list_query inner join ($page_list_query   $queryLIMIT) as tmp on tmp.$focus->table_index=$focus->table_name.$focus->table_index $where $groupby ";

        list($tmplist_query,$order_by,$sorder) = $queryGenerator->customview->getOrderWhere($tmplist_query,"",$queryGenerator);


        $list_result = $adb->pquery($tmplist_query, $params);
        $rows=$adb->num_rows($list_result);
        if($rows<=0)
        {
            break;
        }
        $nextrows=$start+$rows;
        //  unset($_SESSION[$currentModule][$current_user->id]['export']);
        $_REQUEST['export']='yes';
        $listview_entries = $controller->getListViewEntries($focus,$currentModule,$list_result,$navigation_array,$skipAction,true,'export');
        $headerlistfields = $controller->listViewFields;


        $a=2;
        //居中显示
        $objPHPExcel->getDefaultStyle()->getAlignment()->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_CENTER);
        $objPHPExcel->getDefaultStyle()->getAlignment()->setVertical(PHPExcel_Style_Alignment::VERTICAL_CENTER);
        foreach($listview_entries as $key=>$arr)
        {
            $key2 =0;
            foreach($arr as $indexkey2=>$arr2){
                $fieldname=$headerlistfields[$indexkey2];
                $fieldinfo=$controller->getListViewFieldobj($indexkey2,$fieldname);

                if ($fieldinfo && (string)$arr2 != '') {
                    $arr2_decrypt = false;
                    if ($fieldinfo->getBigType()=="text" && $fieldinfo->getIsEncrypt()=="yes") {
                        $arr2_decrypt = $sm4->Decrypt($arr2);
                    } elseif ($fieldinfo->getBigType() == 'reference') {
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
                if($fieldinfo->isImageField()=="yes")
                {
                    $excelimageobj->setCellImage($objPHPExcel,$arr2,$key+$a+$prev_totalrows,$key2,$activesheet,$organization_crm_address);
                }
                //edit: xll 2023/07/13 BUG0069040 单据列表界面，导出模板中应该不显示单据头和单据分录的“附件”字段
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
                    else if ($fieldinfo && $fieldinfo->isPriceField()) {  //单价类型
                        $arr2 = str_replace(',', '', strip_tags($arr2));
                        $typedecimal = explode(',', $fieldinfo->typeofData);
                        $tmpdecimal = $typedecimal[1];
                        //XUQIU1001388zl单据头字段单独判断,控制导出excel的小数位数
                        if ((empty($tmpdecimal)&&$tmpdecimal !== 0)&&($fieldinfo instanceof ProductFields || $fieldinfo instanceof TabDetailToolFields)){
                            $unitprice = getSys_deploy(93);
                            $tmpdecimal = $unitprice['deploy_value'];
                        }
                        $tmpstr = number_format(0, (int)$tmpdecimal);
                        $activesheet->setCellValueExplicit(PHPExcel_Cell::stringFromColumnIndex($key2) . ($key + $a + ($prev_totalrows)), trim($arr2), PHPExcel_Cell_DataType::TYPE_NUMERIC);
                        $activesheet->getStyle(PHPExcel_Cell::stringFromColumnIndex($key2) . ($key + $a + $prev_totalrows))->getNumberFormat()->setFormatCode('#,##'.$tmpstr);
                        if ($controller->getExportStyle() == 'firstcolheader' && $arr2=='') {
                            //导出 每一个单据主表字段只显示一行，分录完全显示 时，单元格不设置类型
                            $activesheet->setCellValueExplicit(PHPExcel_Cell::stringFromColumnIndex($key2) . ($key + $a + $prev_totalrows), trim($arr2));
                        }
                    }
                    else if ($fieldinfo && ($fieldinfo->istotalFldNumField())) {//数字类型
                        $arr2 = str_replace(',', '', strip_tags($arr2));
                        $typedecimal = explode(',', $fieldinfo->typeofData);
                        $tmpdecimal = $typedecimal[1];
                        //XUQIU1001388zl单据头字段单独判断,控制导出excel的小数位数
                        if ((empty($tmpdecimal)&&$tmpdecimal !== 0)&&($fieldinfo instanceof ProductFields || $fieldinfo instanceof TabDetailToolFields)){
                            $number = getSys_deploy(49);
                            $tmpdecimal = $number['deploy_value'];
                        }
                        $tmpstr = number_format(0, (int)$tmpdecimal);
                        $activesheet->setCellValueExplicit(PHPExcel_Cell::stringFromColumnIndex($key2) . ($key + $a + ($prev_totalrows)), trim($arr2), PHPExcel_Cell_DataType::TYPE_NUMERIC);
                        $activesheet->getStyle(PHPExcel_Cell::stringFromColumnIndex($key2) . ($key + $a + $prev_totalrows))->getNumberFormat()->setFormatCode($tmpstr);
                        //@edit:zkt @date:2024/12/10 @reason: BUG20241113-71 年度销售滚动预测模块（自定义表单16），数据分类导出用（含产品明细），导出带明细的excel单据头仅显示首行，导出后表头的金额字段都是0显示了多行
                        if ($controller->getExportStyle() == 'firstcolheader' && $arr2=='') {
                            //导出 每一个单据主表字段只显示一行，分录完全显示 时，单元格不设置类型
                            $activesheet->setCellValueExplicit(PHPExcel_Cell::stringFromColumnIndex($key2) . ($key + $a + $prev_totalrows), trim($arr2));
                        }
                    }
                    else {
                        $activesheet->setCellValueExplicit(PHPExcel_Cell::stringFromColumnIndex($key2) . ($key + $a + ($prev_totalrows)), trim($arr2), PHPExcel_Cell_DataType::TYPE_STRING);
                    }

                }
                $key2++;
            }


        }

        $prev_totalrows+= $rows;//明细

        unset($listview_entries);
    }


    /* */

    $_SESSION[$currentModule][$current_user->id]['export']['total_list_query']="$list_query inner join ($page_list_query    ) as tmp on tmp.$focus->table_index=$focus->table_name.$focus->table_index $where  $orderby";
    $_SESSION[$currentModule][$current_user->id]['export']['list_query']="$list_query inner join ($page_list_query    ) as tmp on tmp.$focus->table_index=$focus->table_name.$focus->table_index $where  $orderby";
    $_SESSION[$currentModule][$current_user->id]['export']['exportprev_totalrows']=$prev_totalrows;



    $tmptmp=$startexportindex+$eachexportcount;


    if($tmptmp<$listcounts)
    {
        $objWriter->save($pathname);

    }
    else
    {
        $headerlistfields=$controller->listViewFields;
        $query=$_SESSION[$currentModule][$current_user->id]['export']['list_query'];

        // $list_result=$adb->pquery($query);
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
                    //$arr=strip_tags($arr)
                    //$arr = str_replace('&yen;','¥',strip_tags($arr));
                    $arr = str_replace('¥','',strip_tags($arr));
                    // $arr= mb_convert_encoding($arr,"UTF-8","auto");

                    $activesheet->setCellValueExplicit(PHPExcel_Cell::stringFromColumnIndex($key).($maxkey+2), trim($arr),PHPExcel_Cell_DataType::TYPE_STRING);
                    //$activesheet->getStyle(PHPExcel_Cell::stringFromColumnIndex($key).($maxkey+2))->getNumberFormat()->setFormatCode("¥ #,##0");
                }

        }

        $objWriter->save($pathname);
        unset($_SESSION[$currentModule][$current_user->id]['export']);


    }
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

    $objWriter->save($pathname);

    unset($_SESSION[$currentModule][$current_user->id]['export']);
    $_REQUEST['frommodule']=$currentModule;
    include(globalStatic::$root_directory.'modules/uploads/downloadxls.php');
    //header("Location:http://localhost/ldcrm/index.php?module=uploads&action=downloadxls&frommodule="+$currentModule);

}

exit();
?>