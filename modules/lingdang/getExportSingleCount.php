<?php
global $current_user;
$customView = new CustomView($currentModule);
//chj 2021/3/23 45099: （61mis.com/kfbcrm）OA表单-加班单；加班单列表处，点击全部合计时长为120；回到加班单的链接模块“加班单_已批准”后，点击全部合计也显示“120”，实际时长“38”；
if(!empty($_REQUEST['viewname'])){
	$viewid = vtlib_purify($_REQUEST['viewname']);
}else{
	$viewid = $customView->getViewId($currentModule);
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

$chart_owner=$queryGenerator->getSmOwnerSearchSql();  
$page_list_query=$page_list_query.$chart_owner;
$list_query=$page_list_query;
?>