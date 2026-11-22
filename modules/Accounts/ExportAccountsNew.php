<?php
/*+**********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ************************************************************************************/
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
$_SESSION['accountlistview']='yes';
global  $currentModule, $theme;

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
    
    include(globalStatic::$root_directory."modules/Accounts/ExportAccountsCSVNew.php");
    $_SESSION['accountlistview']='no';
    exit();
}


global $list_max_entries_per_page_new;
global $current_user;
$languageType= getLanguageType($current_user);
require_once($root_directory.'modules/Accounts/Accounts.php');
require_once($root_directory.'data/Inventory.php');

set_time_limit(0);

include('PHPExcel/PHPExcel.php');
$pathname='storage/'.$current_user->id.'_Accounts.xls';


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
    
    $objPHPExcel =PHPExcel_IOFactory::load($pathname);
  
}
else
{
    $objPHPExcel = new PHPExcel();
    $_SESSION[$currentModule][$current_user->id]['export']['objphpexcel']=serialize($objPHPExcel);

}
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

$url_string = '';

//$focus = new $currentModule();
$focus = CRMEntity::getInstance($currentModule);
//$focus->initSortbyField($currentModule);//代码优化，初始化客户对象赋值
if(ListViewSession::hasViewChanged($currentModule,$viewid)) {
	$_SESSION[$currentModule."_Order_By"] = '';
}
$sorder = $focus->getSortOrder();
$order_by = $focus->getOrderBy();

$_SESSION[$currentModule."_Order_By"] = $order_by;
$_SESSION[$currentModule."_Sort_Order"]=$sorder;

$accounttype="ALLACCOUNT";
if(isset( $_SESSION['lvsAccount'][$currentModule]['pagepublicaccounttype']))
{
    $accounttype=$_SESSION['lvsAccount'][$currentModule]['pagepublicaccounttype'];
}

// Custom View
$customView = new CustomView($currentModule);

$viewid = $customView->getViewId($currentModule);

if(isset($_SESSION['lvs'][$currentModule]['SearchScope'])&&$_SESSION['lvs'][$currentModule]['SearchScope']!=null)
{}
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
 * @author Tujt 2014-04-24
 */
// editor:gyqX160816 reason:新增在search_type=selecteddata时，仍要利用查询信息
// Bug:0023863: 项目>项目进度>序列表界面：使用基本查找帅选数据后全选所有记录，导出>"导出选定结果"，结果导出了全部的数据
if(isset($_SESSION['LiveViewSearch'][$currentModule])&&($_REQUEST['search_type']=='includesearch'||
        $_REQUEST['search_type']=='withoutsearch' || $_REQUEST['search_type']=='selecteddata')){
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

$list_query = $queryGenerator->getQuery('',2);

$page_list_query=$queryGenerator->getQuery('',4);

crm_load_class_file('ExportProductDetailController','include/ListView');
$controller = new ExportProductDetailController($adb, $current_user, $queryGenerator,'excel');
/**
 * 更新操作
 * date:20131228
 * edit:can
 * reason:(批量修改/修改负责人/批量分配领取)页面刷新会重复发送短信
 * other:把该语句移动到（批量修改/修改负责人/批量分配领取）保存页面
*/

//$sql="select * from ld_Account_set";
//$accountset=$adb->pquery($sql,array());
//$status=1;
//$adminaccount="";
//$usersaccount="";
//$dataProfile=1;
//$getProfile=1;

//by andy 公海客户改进
//$wheathershow=1;
//$userid='';
//$status=getAccount_Set('status');
//$adminaccount=getAccount_Set("adminaccount");
//$usersaccount=getAccount_Set('usersaccount');
//$dataProfile=getAccount_Set('dataprofile');
//$getProfile=getAccount_Set('getprofile');
//$wheathershow=getAccount_Set('wheathershow');
//$userid=getAccount_Set('userid');
//$splitadmin=explode(",",$adminaccount);
//$splituser=explode(',',$usersaccount);
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



$where = $queryGenerator->getConditionalWhere();

//$focus->setaccountstatus($status);
//$focus->setadminaccount($adminaccount);
//$focus->setuseraccount($usersaccount);
/*crm_load_class_file('cls_PublicAccounts', 'modules/Accounts');
$cls_PublicAccounts = new cls_PublicAccounts($currentModule);
$public_account = $cls_PublicAccounts->getPublicAccount();
if($public_account['status']=='yes')//启用公海参数
{
   if($accounttype=='PUBLICALLOCATE')
    {
       $ChartWhere=" and ld_account.publicaccount>1 ";
    }
}*/
/*
if($status==0&&($current_user->is_admin=="on"||in_array($current_user->id,$splitadmin)||in_array($current_user->id,$splituser)))
{
     if($accounttype=='NOALLOCATE')
    {
        $ChartWhere=" and ld_account.publicaccount=1";
    }
}
if($status==0&&($wheathershow == 1 || $wheathershow == 2 || $wheathershow == 3)&&$accounttype=='ALLACCOUNT')
{
	if($wheathershow == 1)
        $ChartWhere .=' and ld_account.publicaccount = 0 ';
	else if($wheathershow == 2)
        $ChartWhere .=' and ( ld_account.publicaccount > 1  or ifnull(ld_account.publicaccount,0)=0)';
	else if($wheathershow == 3)
        $ChartWhere .=' and  ifnull(ld_account.publicaccount,0)<= 1 ';
}*/

$ChartFrom=$queryGenerator->getChartFrom();

//$page_list_query .=$ChartWhere;

$ChartOwner=$queryGenerator->getChartOwner();

$list_query .=$ChartOwner;


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
$start = ListViewSession::getRequestCurrentPage($currentModule, $list_query, $viewid, $queryMode);
 crm_load_function_file('VT_getSimpleNavigationValues','include/utils','ListViewUtils');
$navigation_array = VT_getSimpleNavigationValues($start,$list_max_entries_per_page_new,$noofrows);
//分类默认排序设置
//$queryGenerator->getReferenceOrderBy()获取首要联系人
$customsortorder = $queryGenerator->getSequence_fields() . $queryGenerator->getReferenceOrderBy();
$limit_start_rec = ($start-1) * $list_max_entries_per_page_new;
$countsql = $list_query;

//统计
$countsql .= 'inner join ( '.$page_list_query.' ) as temp on temp.accountid=ld_account.accountid ';
$countsql .= $queryGenerator->getWhereClause();
$params = array();
$search_type = $_REQUEST['search_type'];

$wheres = $queryGenerator->getWhereClause();

if($_REQUEST['idstring']!=''&&$search_type == 'selecteddata'){
    if($_REQUEST['idstring']!='all'){
    $_REQUEST['idstring']=rtrim($_REQUEST['idstring'],',');
    $idstring = explode(";", $_REQUEST['idstring']);
    $querywhere = ' and ld_account.accountid in ('.generateQuestionMarks($idstring).')';
    array_push($params, $idstring);
    }
}

if((!is_array($idstring)|| count($idstring)<=0)&&$search_type == 'selecteddata'&&$_REQUEST['idstring']!='all')$querywhere=" and 1<>1 ";

//zkt 20220909 XUQIU1000234 带分录和带产品分录的表单，导出弹出层中增加“导出样式”参数（胡斐） 
$groupby = '';
if($_REQUEST['export_style']=='onlycolheader'){
    //仅显示单据头字段（一行）
    $groupby = $queryGenerator->getGroupBy();
}
$list_query=$list_query." inner join ( $page_list_query ".$querywhere." ) as temp on temp.$focus->table_index=$focus->table_name.$focus->table_index";

$list_query=$list_query.$wheres.$groupby;
$list_count_sql= $page_list_query;
if(!array_key_exists('exportgetcount',$_SESSION[$currentModule][$current_user->id]['export']))
{
    //32405: 客户模块-导出数据，导出搜索的结果，数据已经导出完成了，导出数据的进度条还在页面显示并且没有进度条
     $detail_result = $adb->pquery($list_query, $params);
    $detailcounts = $adb->num_rows($detail_result);       

    $listcounts_result = $adb->pquery($page_list_query . $querywhere, $params);
    $listcounts = $adb->num_rows($listcounts_result);  
    $_SESSION[$currentModule][$current_user->id]['export']['listcounts']=$listcounts;
    $_SESSION[$currentModule][$current_user->id]['export']['detailcounts']=$detailcounts;
    
     $_SESSION[$currentModule][$current_user->id]['export']['exportgetcount']="##SUCCESS##". $listcounts.'details'.$detailcounts;
       
    
}
$listcounts=$_SESSION[$currentModule][$current_user->id]['export']['listcounts'];
if(isset($skipAction)==false){
	$skipAction==false;
}

list($list_query,$order_by,$sorder) = $queryGenerator->customview->getOrderWhere($list_query);

$list_query = $queryGenerator->getQuery('',2);//所有数据查询
$where=$queryGenerator->getWhereClause();
$prev_totalrows=0;

//ls 20220825 BUG0055559 客户（ACC75）导出图片时，Excel表格中显示图片链接
crm_load_class_file("cls_excelImage",'include');
$excelimageobj=new cls_excelImage();
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

if($startexportindex<$listcounts)
{
    if(array_key_exists('exportprev_totalrows',$_SESSION[$currentModule][$current_user->id]['export']))
    {
                    $prev_totalrows=$_SESSION[$currentModule][$current_user->id]['export']['exportprev_totalrows'];
    }
    //230530 wym 图片字段添加超链接
    $sql="select crm_address from ld_organizationdetails";
    $result = $adb->pquery($sql, array());
    $organization_crm_address = $adb->query_result($result,0,'crm_address');

    require_once globalStatic::$root_directory.'Register/ld_Sm4.php';
    global $sm4_key;
    $sm4 = new ld_Sm4($sm4_key);

    for($s = 1; $s <= $step; ++$s) {
    	$start = ($s - 1) * $nums+$startexportindex;
        $queryLIMIT =  ' LIMIT '.$start.','.$nums;
    
         $list_result = $adb->pquery("$list_query inner join ($page_list_query $querywhere group by ld_account.accountid order by $order_by $sorder,$focus->table_name.$focus->table_index $sorder $queryLIMIT) as tmp on tmp.$focus->table_index=$focus->table_name.$focus->table_index $where $groupby  order by $order_by $sorder", $params);
         $rows=$adb->num_rows($list_result);
         if($rows<=0)
            break;
            
         $listview_entries = $controller->getListViewEntries($focus,$currentModule,$list_result,$navigation_array,$skipAction,true,'export');
        $headerlistfields = $controller->listViewFields;

        $a=2;
        
        foreach($listview_entries as $key=>$arr){
            $key2 = 0;
            foreach($arr as $indexkey2=>$arr2){
                $fieldname=$headerlistfields[$indexkey2];
                $fieldinfo=$controller->getListViewFieldobj($indexkey2,$fieldname);

                if ($fieldinfo && (string)$arr2 !== '') {
                    $arr2_decrypt = false;
                    if ($fieldinfo->getTableName()=='ld_contactdetails'||$fieldinfo->getTableName()=='ld_contactscf') {
                        $referencemodule_focus = CRMEntity::getInstance("Contacts");
                        $referencemodule_fieldinfo = $referencemodule_focus->fieldobj->getFieldInfoobjBykey("fieldname", $fieldinfo->getFieldName());
                        if ($referencemodule_fieldinfo&&$referencemodule_fieldinfo->getIsEncrypt()=="yes") {
                            $arr2_decrypt = $sm4->Decrypt($arr2);
                        }

                    } elseif ($fieldinfo->getBigType()=="text" && $fieldinfo->getIsEncrypt()=="yes") {
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
        /*$_SESSION[$currentModule][$current_user->id]['export']['headerlistfields']=$headerlistfields;
        if(isset($_SESSION[$currentModule][$current_user->id]['export']['data']))
            $size=sizeof($_SESSION[$currentModule][$current_user->id]['export']['data']);
        else
            $size=0;
        $_SESSION[$currentModule][$current_user->id]['export']['data'][$size]=$listview_entries;*/
        
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
    else
    {
    
    $_SESSION['accountlistview']='no';
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
    
   
    unset($_SESSION[$currentModule][$current_user->id]['export']);
    $_REQUEST['frommodule']=$currentModule;
    include(globalStatic::$root_directory.'modules/uploads/downloadxls.php');
}



?>