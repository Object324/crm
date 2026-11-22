<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global  $currentModule, $theme;
global $list_max_entries_per_page_new;
global $current_user,$adb;
$smarty = new lingdangCRM_Smarty();
crm_load_function_file('VT_getSimpleNavigationValues','include/utils','ListViewUtils');
crm_load_class_file('Map_ProductDetails','modules/Accounts/Map');
crm_load_class_file('cls_Tencent_Map', 'include/utils');
$cls_Tencent_Map = new cls_Tencent_Map();
$currentModule = $_REQUEST['frommodule'];
$focus = CRMEntity::getInstance($currentModule);
$focus->getModuleLogic($currentModule);//->getListViewButtons();
$moduleFields=$focus->fieldobj->getModuleFields();
// Custom View
$productdetail = new Map_ProductDetails($currentModule);
$customView = CustomView::getInstance($currentModule);
if($currentModule == 'Accounts'){
	$queryGenerator =QueryGenerator::getInstance($currentModule, $current_user,$customView,$productdetail);
}else{
	crm_load_class_file('Map_QueryGenerator', 'modules/Accounts/Map');
	$queryGenerator =new Map_QueryGenerator($currentModule, $current_user,$customView);
}
$viewid = $customView->getViewId($currentModule);
if ($viewid != "0") {
   $queryGenerator->initForCustomViewById($viewid);
} else {
	$queryGenerator->initForDefaultCustomView();
}
if(isset($_REQUEST['query_session']) && $_REQUEST['query_session'] == '1' 
		&& isset($_SESSION['LiveViewSearch'][$currentModule])){
	$input = $_SESSION['LiveViewSearch'][$currentModule]['input'];
	global $search_session;
	$search_session = 1;
    //edit:can 20210514 0045889: （https://61mis.com/kfbcrm [^]）客户问题（广东新业），客户地图，点击“广东->广州”，进入客户单据列表界面，再点击“地图视图”模式图标时，带过来的查询条件没有生效（需要补丁）
	if($input['searchtype'] == 'BasicSearch'){
		if($input['search_text']!=''){
			$_REQUEST['search_field'] = $input['search_field'];
			$_REQUEST['search_text'] = $input['search_text'];
			$_REQUEST['SearchScope'] = $input['SearchScope'];
			$_REQUEST['searchtype'] = $input['searchtype'];
			$_REQUEST['type'] = $input['type'];
		}else{
			$search_session = 0;
			unset($_SESSION['LiveViewSearch'][$currentModule]);
		}
		// @edit:dong @date:2020/08/24 @reason: 添加平铺查找
	}else if($input['searchtype'] == 'advance' || $input['searchtype'] == 'tiled'){
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
			$smarty->assign('CRITERIA_GROUPS',$advfilterlist);
		}else{
			$search_session = 0;
			unset($_SESSION['LiveViewSearch'][$currentModule]);
		}
	}
  
	if($search_session == 1){
		$smarty->assign('SEATCH_INPUT',$input);
		$smarty->assign('SEARCH_URL', $_SESSION['LiveViewSearch'][$currentModule]['url']);
		$_REQUEST['query'] = 'true';
	}
}else{
	unset($_SESSION['LiveViewSearch'][$currentModule]);
}
if($_REQUEST['query'] == 'true') {
	$_REQUEST['searchtype'] = trim($_REQUEST['searchtype']);
	$queryGenerator->addUserSearchConditions($_REQUEST);
}
$list_query = $queryGenerator->getQuery('',2);
$page_list_query=$queryGenerator->getQuery('',1);
$queryRow_Count=$queryGenerator->getQueryRow_Count();
if($_REQUEST['btn_type'] == 'map'){
	$page_list_query .= " and IFNULL(ld_account.bill_street, '') != '' ";
}
$list_query = str_replace("distinct","distinct CONCAT(IFNULL(ld_account.bill_state,''),IFNULL(ld_account.bill_city,''),IFNULL(ld_account.bill_area,''),IFNULL(ld_account.bill_street,'')) as local_address,ld_account.longtitude,ld_account.latitude,",$list_query);
$page_list_query.=" group by ld_account.accountid";
$queryRow_Count.=" and (ld_account.bill_street <> '' and ld_account.bill_street is not null) group by ld_account.accountid ";
crm_load_class_file('Map_ListController','modules/Accounts/Map');
$controller = new Map_ListController($adb, $current_user, $queryGenerator);
$count_result = $adb->query($queryRow_Count);
if(!empty($count_result))
	$noofrows = $adb->num_rows($count_result);
else 
	$noofrows = null;
list($page_list_query,$order_by,$sorder) = $queryGenerator->customview->getOrderWhere($page_list_query);
$queryMode = (isset($_REQUEST['query']) && $_REQUEST['query'] == 'true');
if(empty($_REQUEST['page']))
	$start = ListViewSession::getRequestCurrentPage($currentModule, $noofrows, $viewid, $queryMode);
else{
	$start = $_REQUEST['page'];
}
$navigation_array = VT_getSimpleNavigationValues($start,$list_max_entries_per_page_new,$noofrows);
$limit_start_rec = ($start-1) * $list_max_entries_per_page_new;
$list_query=$list_query." inner join ( $page_list_query limit $limit_start_rec,$list_max_entries_per_page_new ) as temp on temp.$focus->table_index=$focus->table_name.$focus->table_index";
$list_query=$list_query.$queryGenerator->getWhereClause();
list($list_query,$order_by,$sorder) = $queryGenerator->customview->getOrderWhere($list_query);
$list_result = $adb->pquery($list_query);
$listview_entries = $controller->getListViewEntries($focus,$currentModule,$list_result,$navigation_array,$skipAction);

crm_load_class_file("cls_map_field",'modules/Accounts/Map');
$cls_map_field = new cls_map_field($module);
$map_field_list = $cls_map_field->getAllMapFields();
if(!empty($listview_entries)){
	$first_map_lat = 0;
	$first_map_lng = 0;
	foreach($listview_entries as $record => $data){
		foreach($map_field_list as $map_type => $map_cols){
			foreach($map_cols as $columns){
				$col = explode(':',$columns);
				$fieldname = $col[2];
				$value = $data[$fieldname];
				$field = $moduleFields[$fieldname];
				if(empty($field))continue;
				if($fieldname == 'accountname'){
				    $value = preg_replace("/[\r\n]+/", '', $value);
				    $map_content[$record][$map_type][$fieldname] = $value;
				}
				else if($fieldname == 'assigned_user_id'){
					$value = preg_replace("/[\r\n]+/", ',', $value);
					$value = str_replace('"', "'", $value);
					$map_content[$record][$map_type][$fieldname] = $field->getFieldLabelKey() . ':'.$value;
				}else
					$map_content[$record][$map_type][$fieldname] = $field->getFieldLabelKey() . ':'.preg_replace("/[\r\n]+/", ',', $value);
				// $field->getFieldLabelKey()
			}
			//定位
			$local_address = $data['local_address'];
			if(!empty($local_address)){
                if(empty($data['longtitude'])){
                    $point = getCoordinateByTecentApi($local_address);
                    $map_content[$record][$map_type]['local_address'] = $local_address;
                    $map_content[$record][$map_type]['lng'] = $point['result']['location']['lng'];
                    $map_content[$record][$map_type]['lat'] = $point['result']['location']['lat'];
                    if(empty($first_map_lat)){
                        $first_map_lng = $point['result']['location']['lng'];
                        $first_map_lat = $point['result']['location']['lat'];
                    }
                }else{
                    $map_content[$record][$map_type]['local_address'] = $local_address;
                    $map_content[$record][$map_type]['lng'] = $data['longtitude'];
                    $map_content[$record][$map_type]['lat'] = $data['latitude'];
                    if(empty($first_map_lat)){
                        $first_map_lng = $point['result']['location']['lng'];
                        $first_map_lat = $point['result']['location']['lat'];
                    }
                }
			}
		}
	}
}
foreach($map_content as $record => $map){
	foreach($map as $map_type => $data){
		if($map_type == 'detail'){
			$map_detail[$record] = $data;
		}
	}
}
if(empty($first_map_lat))$first_map_lat = '31.24789';
if(empty($first_map_lng))$first_map_lng = '121.54894';
//东贸-客户地图点击下一页报错
$VersionInfo = getVersionInfo();
if($currentModule =='ServiceCharge'&&$VersionInfo['account'] == 'dongmao'){
    $smarty->assign('MODULE',$currentModule);
}else{
    $smarty->assign('MODULE','Accounts');
}
$smarty->assign('FIRST_MAP_LAT',$first_map_lat);
$smarty->assign('FIRST_MAP_LNG',$first_map_lng);
$smarty->assign('NEXT_PAGE',$navigation_array['next']);
$smarty->assign('PREV_PAGE',$navigation_array['prev']);
$smarty->assign("MAPDETAIL",ldcrm_json_encode($map_detail));
$smarty->assign('MAPCONTENT',$map_content);
$_REQUEST['diony']='yes';
//$smarty->display('MapLeftList.tpl');
$arr['map_content'] = ldcrm_json_encode($map_detail);
$arr['content']=$smarty->fetch("MapLeftList.tpl");
if($listview_entries){
	ConvertTojsonString(1,$arr,'success');	
}
else{
	ConvertTojsonString(-1,$arr,'error');
}
?>