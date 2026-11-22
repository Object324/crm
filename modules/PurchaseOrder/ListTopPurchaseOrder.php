<?php
/*********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the SugarCRM Public License Version 1.1.2
 * ("License"); You may not use this file except in compliance with the
 * License. You may obtain a copy of the License at http://www.sugarcrm.com/SPL
 * Software distributed under the License is distributed on an  "AS IS"  basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
 * the specific language governing rights and limitations under the License.
 * The Original Code is:  SugarCRM Open Source
 * The Initial Developer of the Original Code is SugarCRM, Inc.
 * Portions created by SugarCRM are Copyright (C) SugarCRM, Inc.;
 * All Rights Reserved.
 * Contributor(s): ______________________________________.
 ********************************************************************************/


/**	function used to get the top 12 purchase orders from Listview query 最新采购订单
 *	@return array $values - array with the title, header and entries like  Array('Title'=>$title,'Header'=>$listview_header,'Entries'=>$listview_entries) where as listview_header and listview_entries are arrays of header and entity values which are returned from function getListViewHeader and getListViewEntries
 */
//function getTopPurchaseOrder($calCnt,$scopeType,$senioruserid)
//{
//
//    crm_load_class_file('PurchaseOrder','modules/PurchaseOrder');
//	global $current_language,$current_user,$list_max_entries_per_page_new,$theme,$adb,$mod_strings,$default_charset;
//	//$log = LoggerManager::getLogger('po_list');
//
//	$url_string = '';
//	$sorder = '';
//	crm_load_function_file('getApproveQuery','modules/Home','HomeUtils');
//    if(!empty($_REQUEST['approve_value'])){
//		$purchaseorder_approvestatus = getApproveQuery('ld_purchaseorder');
//	}
//	$currentModule = 'PurchaseOrder';
//	$viewId = getCvIdOfAll($currentModule);
//	$queryGenerator = new QueryGenerator($currentModule, $current_user);
//	$queryGenerator->initForCustomViewById($viewId);
//	$meta = $queryGenerator->getMeta($currentModule);
//	$accessibleFieldNameList = array_keys($meta->getModuleFields());
//	$customViewFields = $queryGenerator->getCustomViewFields();
//	$fields = $queryGenerator->getFields();
//	$newFields = array_diff($fields, $customViewFields);
//	$widgetFieldsList = array('subject','vendor_id','contact_id','total');
//	$widgetFieldsList = array_intersect($accessibleFieldNameList, $widgetFieldsList);
//	$widgetSelectedFields = array_chunk(array_intersect($customViewFields, $widgetFieldsList), 2);
//	//select the first chunk of two fields
//	$widgetSelectedFields = $widgetSelectedFields[0];
//	if(count($widgetSelectedFields) < 2) {
//		$widgetSelectedFields = array_chunk(array_merge($widgetSelectedFields, $accessibleFieldNameList), 2);
//		//select the first chunk of two fields
//		$widgetSelectedFields = $widgetSelectedFields[0];
//	}
//	$newFields = array_merge($newFields, $widgetSelectedFields);
//	$queryGenerator->setFields($newFields);
//	//$_REQUEST = getTopPurchaseOrderSearch($_REQUEST);
//	$queryGenerator->addUserSearchConditions($_REQUEST);
//	//$search_qry = ''.getSearchURL($_REQUEST);
//
//
//
//	$query = $queryGenerator->getQuery();
//	//<<<<<<<<customview>>>>>>>>>
//    $query .=" and (ld_purchaseorder.postatus <>'Cancelled' or ld_purchaseorder.postatus<>'".$mod_strings['Cancelled']."') and ld_purchaseorder.smownerid in($senioruserid) $purchaseorder_approvestatus";
//    $query .=" order by ld_crmentity.createdtime desc";
//	$query .= " LIMIT 12";
//	if($calCnt == 'calculateCnt') {
//		$list_result_rows = $adb->query(mkCountQuery($query));
//		return $adb->query_result($list_result_rows, 0, 'count');
//	}
//
//	$list_result = $adb->query($query);
//
//	//Retreiving the no of rows
//	$noofrows = $adb->num_rows($list_result);
//
//	//Retreiving the start value from request
//	if(isset($_REQUEST['start']) && $_REQUEST['start'] != '') {
//		$start = vtlib_purify($_REQUEST['start']);
//	} else {
//		$start = 1;
//	}
//	require_once($root_dir.'/include/utils/ListViewUtils.php');
//	//Retreive the Navigation array
//	$navigation_array = getNavigationValues($start, $noofrows, $list_max_entries_per_page_new);
//
//
//	$focus = new PurchaseOrder();
//
//	//Retreive the List View Table Header
//	$title=array('myTopPurchaseOrders.gif',$current_module_strings['LBL_MY_TOP_PO'],'home_mytoppo');
//	$controller = new ListViewController($adb, $current_user, $queryGenerator);
//	$controller->setHeaderSorting(false);
//	$header = $controller->getListViewHeader($focus,$currentModule,$url_string,$sorder,
//			$order_by, true);
//
//	$entries = $controller->getListViewEntries($focus,$currentModule,$list_result,
//	$navigation_array, true);
//
//	$values=Array('ModuleName'=>'PurchaseOrder','Title'=>$title,'Header'=>$header,'Entries'=>$entries,'search_qry'=>$search_qry);
//	if ( ($noofrows == 0 ) || ($noofrows>0) )
//		return $values;
//}

?>