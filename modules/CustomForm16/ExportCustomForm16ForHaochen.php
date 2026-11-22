<?php
/**
 * 更新操作
 * edit:chj
 * date:2022/6/15
 * reason:浩辰特殊开发   合同拆分导出
 * */
global $adb;
set_time_limit(0);
global  $currentModule, $theme,$current_user;
$smarty=new lingdangCRM_Smarty;
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
$smarty->assign('search_type','includesearch'); 
if(!empty($_REQUEST['idstring']) && $_REQUEST['idstring']!='all'){
    $_REQUEST['idstring']=rtrim($_REQUEST['idstring'],',');
    $idstring = explode(";", $_REQUEST['idstring']);
    $querywhere = ' and '.$focus->table_name.'.'.$focus->table_index.' in ('.implode(",",array_filter($idstring)).')';
	$smarty->assign('search_type','selecteddata'); 
}

$chart_owner=$queryGenerator->getSmOwnerSearchSql();

$page_list_query=$page_list_query.$FoSearchSQL.$querywhere.$querysearch;

$result = $adb->pquery($page_list_query,array());
if($adb->num_rows($result) >= 1){
	for($i = 0; $i < $adb->num_rows($result); $i++){
		$listids[] = $adb->query_result($result,$i,$focus->table_index);
	}
}else{
	$_REQUEST['diony']='diony';
	ConvertTojsonString(-1,array(),"success");
}
//总条目数
$count = sizeOf($listids);
if($count > 2000){
	$smarty->assign('exportformat','exportcsv');
}else{
	$smarty->assign('exportformat','exportexcel');
}
$query = "select min(cf_4645),max(cf_4645),sum(IFNULL(cf_4646,0)),sum(IFNULL(cf_4647,0)) from  ld_customform16scf where customform16id in (".implode(',',$listids).")";
$result = $adb->pquery($query,array());
if($adb->num_rows($result) >= 1){
	$start_date = $adb->query_result($result,0,0);
	$end_date = $adb->query_result($result,0,1);
	$before_amount = $adb->query_result($result,0,2);
	$after_amount = $adb->query_result($result,0,3);
}
$smarty->assign('count',$count);
$smarty->assign('start_date',$start_date);
$smarty->assign('end_date',$end_date);
$smarty->assign('before_amount',$before_amount);
$smarty->assign('after_amount',$after_amount);
$_REQUEST['diony']='diony';
$arr['title'] = '导出拆分报表Excel';
$arr['oktext']=getFixedLabel("CONFIRMED").getFixedLabel("EXPORT");
$arr['canceltext']=getFixedLabel("CANCEL");
$str=$smarty->fetch("ExportForHaochen.tpl");
$arr['content']=$str;
ConvertTojsonString(1,$arr,"success");
exit();
?>