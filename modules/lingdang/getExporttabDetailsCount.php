<?php

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
		//	unset($_SESSION['LiveViewSearch'][$currentModule]);
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
		//	unset($_SESSION['LiveViewSearch'][$currentModule]);
		}
	}
	if($search_session == 1){
		$_REQUEST['query'] = 'true';
	}
}
$customView = new CustomView($currentModule);
//chj 2021/3/23 45099: （61mis.com/kfbcrm）OA表单-加班单；加班单列表处，点击全部合计时长为120；回到加班单的链接模块“加班单_已批准”后，点击全部合计也显示“120”，实际时长“38”；
if(!empty($_REQUEST['viewname'])){
	$viewid = vtlib_purify($_REQUEST['viewname']);
}else{
	$viewid = $customView->getViewId($currentModule);
}
$queryGenerator = QueryGenerator::getInstance($currentModule, $current_user);
///得到对应视图的查询字段
if ($viewid != "0") {
   $queryGenerator->initForCustomViewById($viewid);
} else {
	$queryGenerator->initForDefaultCustomView();
}

if($_REQUEST['query'] == 'true') {
     $queryGenerator->addUserSearchConditions($_REQUEST);

}
$list_query = $queryGenerator->getQuery('',3);//所有数据查询
$page_list_query=$queryGenerator->getQuery('',1);//分页查询语句
$where= $queryGenerator->getWhereClause();
 

$list_query=$list_query." inner join ( $page_list_query   ) as temp on temp.$focus->table_index=$focus->table_name.$focus->table_index $where";


?>