<?php
/*+********************************************************************************
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
global $theme,$currentModule,$adb,$current_user,$default_language;
crm_load_function_file('selWareAll','include/Stock','CommonStock');
$result=selWareAll();

$num_rows=$adb->num_rows($result);

if(!$num_rows){
    //echo "<table border='0' cellpadding='5' cellspacing='0' width='100%' height='450px'><tr><td align='center'>";
//	echo "<div style='border: 3px solid rgb(153, 153, 153); background-color: rgb(255, 255, 255); width: 55%; position: relative; z-index: 10000000;'>
//
//		<table border='0' cellpadding='5' cellspacing='0' width='98%'>
//		<tbody><tr>
//		<td rowspan='2' width='11%'><img src='". lingdang_imageurl('denied.gif', $theme) ."' ></td>
//		<td style='border-bottom: 1px solid rgb(204, 204, 204);' nowrap='nowrap' width='70%'><span clas
//		s='genHeaderSmall'>".getFixedLabel('INSUFFICIENTWAREHOUSE')."</span></td>
//		</tr>
//		<tr>
//		<td class='small' align='right' nowrap='nowrap'>
//		<a href='index.php?module=Home&action=index&parenttab=My Home Page'>".getFixedLabel('RETURN')."</a><br>
//		</td>
//		</tr>
//		</tbody></table>
//		</div>";
//	echo "</td></tr></table>";
    include(globalStatic::$root_directory."modules/lingdang/ExitWithoutPermission.php");
	exit;
}

//wym 230605 获取该模块列表最多条数
//wym 231221 XUQIU1002380 列表显示条数可按成员设置不同的条数
$list_max_entries_per_page_new=getUsersettingByLabel($currentModule,$current_user->id,'MaxEntriesPerPageByuser')??getUsersettingByLabel($currentModule,1,'MaxEntriesPerPage');
$list_max_entries_per_page_new=empty($list_max_entries_per_page_new)?'20':$list_max_entries_per_page_new;

function getInventoryQueryCount($result,$type,$customView,$fields)
{
    global $adb, $current_user,$currentModule;
	$InventoryArray = array();
	$queryGenerator = new QueryGenerator($currentModule, $current_user,$customView);
	$meta = $queryGenerator->getMeta($queryGenerator->getModule());
	//获取标签中英文
	$arrFieldLabel=$queryGenerator->getFieldLables();
	$moduleFields = $meta->getModuleFields();
	$accessibleFieldList = array_keys($moduleFields);
	$listViewFields = array_intersect($fields, $accessibleFieldList);
    $num_rows = $adb->num_rows($result);
	//获取出库单或入库单更新库存流水记录触发点 0：审核 1：保存
    $deployarray=getSys_deploy(48);
	for($i=0; $i<$num_rows; $i++)
    {
		foreach($listViewFields as $fld){++ $j;
			$fldobj = $moduleFields[$fld];
			$fldval = $adb->query_result($result,$i,$fld);
			if($fld == 'productqty'||$fld == 'qtyearly'||$fld == 'commissionrate'||$fld == 'warehouseid'||$fld == 'productid'||$fld == 'qtyinstock')
			{
				if($fld == 'warehouseid')	//待入库
				{
					$stock_num = 0;
					if($deployarray['deploy_value']!= 1 && $type == 2){
						$stock_num = getInventoryStockNum($adb->query_result($result, $i, "productid"),$adb->query_result($result, $i, "warehouseid"),1);
					}
					if($deployarray['deploy_value']!= 1 && $type == 1){
						if($i == 0)
							$stock_num = getInventoryStockNumAll(1);
					}
					$InventoryArray[$fld]+=$stock_num;

				}
				else if($fld == 'productid')	//待出库
				{
					$out_num = 0;
					if($deployarray['deploy_value'] != 1 && $type == 2){
						$out_num += getInventoryStockNum($adb->query_result($result, $i, "productid"),$adb->query_result($result, $i, "warehouseid"),2);
					}
					if($deployarray['deploy_value']!= 1 && $type == 1){
						if($i == 0)
							$stock_num = getInventoryStockNumAll(2);
					}
					$InventoryArray[$fld] += $out_num;
					//var_dump($InventoryArray[$fld]);

				}
				else if($fld == 'commissionrate')
				{
					$InventoryArray[$fld]+=$adb->query_result($result, $i, "unit_price")*$adb->query_result($result, $i, "productqty");
				}
				else if($fld == 'qtyinstock'){
					$InventoryArray[$fld] += $adb->query_result($result, $i, "productqty") + $stock_num - $out_num - $adb->query_result($result, $i, "qtyearly");
				}
				else
				{
				   
					$InventoryArray[$fld]+=$fldval;
				}
				
			}
			else
			{
			 
				$InventoryArray[$fld]='';
			}
		}

	}
	
	$k=1;$isstart = 1;
	$sysdeploy = getSys_deploy(49);
	if(isset($sysdeploy['deploy_value']))
		$lengthdecimaldigits = $sysdeploy['deploy_value'];
	else
		$lengthdecimaldigits  = 2;
	$ptyarray = array('productqty'=>1,'qtyinstock'=>1,'warehouseid'=>1,'productid'=>1);
	foreach($InventoryArray as $key=>$val){
		if($isstart == 1){
			
			if($key == 'unit_price'  && $isstart == 1)
			{
				if($type == 1)
					$tips = getFixedLabel('TOTALALL');
				else
					$tips = getFixedLabel('TOTALTHIS');
		
					$InventoryArray[$key] = '∑&nbsp;' . $tips .'　'. $val;
				//break;
				$isstart = 2;
			}
			$nextkey = $key;$k++;
			if(isset($ptyarray[$key])){
			 //26294: 即时库存查询：预警数量小数位数显示为8位数。
				$InventoryArray[$key] = setNumberFormat($val,$lengthdecimaldigits);
			}
		}else{
			if(isset($ptyarray[$key])){
				$InventoryArray[$key] = setNumberFormat($val,$lengthdecimaldigits);
			}else{
				$InventoryArray[$key] = setNumberFormat($val);
			}
		}
		
	}
    return $InventoryArray;
}
function getInventoryStockNum($productid,$wareid,$type)
{
    global $adb, $current_user;
	/*
	 * editor : gyq
	 * reason : 0020131: 即时库存查询>序时簿界面>“全部仓库”分类中的本页合计行待出库数量统计错误
	 * date   : 2016 1 7
	 * */
	if(empty($_REQUEST['wareid'])){
		if($type == 1)
			$sql = "select sum(quantity) as quantity from ld_stockdetail a,ld_stock b,ld_crmentity c where a.id = b.stock_id and a.productid = ?
                        and b.stock_id = c.crmid and b.presence = '".NOTINSTOCK."' and b.deleted = 0";
		else
			$sql = "select sum(quantity) as quantity from ld_outboundorderdetail a,ld_outboundorder b,ld_crmentity c where a.id = b.out_id
                    and b.out_id = c.crmid and a.productid = ?  and b.presence = '".NOTOUTBOUND."' and b.deleted = 0";
		$tuty=$adb->pquery($sql,array($productid));
	}else {
		if ($type == 1)
			$sql = "select sum(quantity) as quantity from ld_stockdetail a,ld_stock b,ld_crmentity c where a.id = b.stock_id and a.productid = ?
                        and b.stock_id = c.crmid and b.wareid = ? and b.presence = '" . NOTINSTOCK . "' and b.deleted = 0";
		else
			$sql = "select sum(quantity) as quantity from ld_outboundorderdetail a,ld_outboundorder b,ld_crmentity c where a.id = b.out_id
                    and b.out_id = c.crmid and a.productid = ? and b.wareid = ? and b.presence = '" . NOTOUTBOUND . "' and b.deleted = 0";
		$tuty = $adb->pquery($sql, array($productid, $wareid));

	}
    return $adb->query_result($tuty,0,'quantity');
}

function getInventoryStockNumAll($type)
{
    global $adb, $current_user;
	/*
	 * editor : gyq
	 * reason : 0020131: 即时库存查询>序时簿界面>“全部仓库”分类中的本页合计行待出库数量统计错误
	 * date   : 2016 1 7
	 * */
	 if($type == 1)
		$sql = "select sum(quantity) as quantity from ld_stockdetail a,ld_stock b,ld_crmentity c where a.id = b.stock_id  
		and b.stock_id = c.crmid and b.presence = '".NOTINSTOCK."' and b.deleted = 0";
	else
		$sql = "select sum(quantity) as quantity from ld_outboundorderdetail a,ld_outboundorder b,ld_crmentity c where a.id = b.out_id
                    and b.out_id = c.crmid and b.presence = '" . NOTOUTBOUND . "' and b.deleted = 0";
	$tuty = $adb->pquery($sql, array());
    return $adb->query_result($tuty,0,'quantity');
}

require('user_privileges/user_privileges_'.$current_user->id.'.php');

require_once($root_directory.'data/Inventory.php');

$category = getParentTab();
$smarty = new lingdangCRM_Smarty();
$warehouseid = 0;
$url_string = '';
$stockquery = '';

$focus = CRMEntity::getInstance($currentModule);
//$focus->initSortbyField($currentModule);
/* 列表按钮 begin */
$focus->getModuleLogic($currentModule)->getListViewButtons();
$smarty->assign('LISTBUTTON',$focus->logic->list_buttons);



/*
By LD Can;
Date:20121225;
reason:增加用户查询范围需求

*/
$MergeSmowner=getCurSmOwnerSearchScope($currentModule);
unset($MergeSmowner["UserCombo"][$current_user->id]);//去除当前用户

$fieldobj = Field::getInstance($currentModule,$adb);
$smarty->assign('FIELDOBJ',$fieldobj);

$smarty->assign('CUSTOM_MODULE', $focus->IsCustomModule);
$smarty->assign('Merge_SmOwner',$MergeSmowner);
//20240305 hzx XUQIU20240112-01 查询分类显示优化（仿腾讯云），一行显示4个，点击出现弹出层注：注意区分普通、悬浮、选中状态
if(count($MergeSmowner) > 0 && $currentModule != 'InventoryAccount' && $currentModule != 'InventoryQuery' && $currentModule != 'BankAccountSet' && $currentModule != 'Reminds'){
    $SmOwner_option_arr = [];
    $showviewrange = false;
    foreach($MergeSmowner as $User_Key => $User_value){
        foreach($User_value as $User_id => $User_name){
            foreach($User_name as $User_name_key => $User_name_value){
                $SmOwner_option_arr[] = array('label'=>$User_name_key,'value'=>$User_id);
                if($User_id == 'smowner_search_senior'){
                    $showviewrange = true;
                }
            }
        }
    }
    if($showviewrange == true){
        $smarty->assign('showviewrange',$showviewrange);
    }
}else{
    $SmOwner_option_arr = [];
    $SmOwner_option_arr[] = array('label'=>getFixedLabel('ALL'),'value'=>'SmOwner_Search_All','selected'=>true);
}
$smarty->assign('Merge_SmOwner_arr',json_encode($SmOwner_option_arr));
$smarty->assign('MAX_RECORDS', $list_max_entries_per_page_new);
$smarty->assign('MOD', $mod_strings);
$smarty->assign('APP', $app_strings);
$smarty->assign('MODULE', $currentModule);
$smarty->assign('SINGLE_MOD', getTranstab($currentModule));
$smarty->assign('CATEGORY', $category);

//$smarty->assign('CHECK', $tool_buttons);
$smarty->assign('THEME', $theme);
$smarty->assign('IMAGE_PATH', "themes/$theme/images/");

/*
edit:Can
date:20130605
reason:4067: 视图中：排序功能失效。
*/
if(isset($_REQUEST["selectedColumnsString2"]))
{
    include("modules/lingdang/ViewOrderEditSave.php");
    
}
// Custom View
$customView = CustomView::getInstance($currentModule);

	$viewid = $customView->getViewId($currentModule);
    /*
    edit:can
    date:20130703
    reason:4209引出的问题，无法记住上一次的选择，
    */
    if(isset($_REQUEST['viewname'])&& $_REQUEST['viewname'])
    {
        $viewid=$_REQUEST['viewname'];
        $_SESSION['lvs'][$module]["viewname"]=$viewid;
    }



$smarty->assign("VIEWID", $viewid);

//视图hTML
$customview_html = $customView->getCustomViewAll($viewid,$module,$category);
//@edit zsk 2024/06/11 XUQIU20240516-01 查询分类功能优化
//获取查询分类分组列表
$groupList=$customView->getCustomViewGroupList($customview_html);
$smarty->assign("CUSTOMVIEWGROUPLIST",$groupList);
//前五个数据分类
//$customview_html_before = $customView->getCustomViewCombo2Before($viewid,$module,$category);
//$viewinfo = $customView->getCustomViewByCvid($viewid);
//$statusdetails = $customView->isPermittedChangeStatus($viewinfo['status']);
 
// To check if a user is able to edit/delete a CustomView
$edit_permit = $customView->isPermittedCustomView($viewid,'Create',$currentModule);
$delete_permit = $customView->isPermittedCustomView($viewid,'Delete',$currentModule);

//$smarty->assign("CUSTOMVIEW_PERMISSION",$statusdetails);
$smarty->assign("CV_EDIT_PERMIT",$edit_permit);
$smarty->assign("CV_DELETE_PERMIT",$delete_permit); 


//by LD tifa 20130104 bug0003118
/*
edit:can
date:20130426
reason:记住上次查询范围

*/
if($_REQUEST['senioruserid']!="")
{
     $_SESSION['lvs'][$currentModule]['senioruserid']=$_REQUEST['senioruserid'];
}
if($_SESSION['lvs'][$currentModule]['senioruserid']!="")
{
    $smarty->assign("senioruserid",$_SESSION['lvs'][$currentModule]['senioruserid']);
}
if($_REQUEST['SearchScope'] !=null&&$_REQUEST['SearchScope'] !='')
{
     $SearchScope=$_REQUEST['SearchScope'];
     $_SESSION['lvs'][$currentModule]['SearchScope']=$SearchScope;
     
    $smarty->assign('SelectedOwner2', $_REQUEST['SearchScope']);
    
} 
else if(isset($_SESSION['lvs'][$currentModule]['SearchScope'])&&$_SESSION['lvs'][$currentModule]['SearchScope']!=null)
{
    $smarty->assign('SelectedOwner2',$_SESSION['lvs'][$currentModule]['SearchScope']);
   
}
else 
{
    $SearchScope="SmOwner_Search_All";
    $_SESSION['lvs'][$currentModule]['SearchScope']=$SearchScope;
    $smarty->assign('SelectedOwner2',"SmOwner_Search_All");
}
//获取批量操作时记录数上限
$deployarray=getSys_deploy(67);
$smarty->assign('BATCHNUM',$deployarray['deploy_value']);
$viewname = $customView->getViewNameDetail($viewid);
if($viewname == 'All'){
    $viewname = getFixedLabel('ALL');
}

$smarty->assign("VIEWNAME", $viewname);
$smarty->assign('ALL', $customView->getViewNameDetail($viewid));
if($viewid ==0) {
	//echo "<table border='0' cellpadding='5' cellspacing='0' width='100%' height='450px'><tr><td align='center'>";
//	echo "<div style='border: 3px solid rgb(153, 153, 153); background-color: rgb(255, 255, 255); width: 55%; position: relative; z-index: 10000000;'>
//
//		<table border='0' cellpadding='5' cellspacing='0' width='98%'>
//		<tbody><tr>
//		<td rowspan='2' width='11%'><img src='". lingdang_imageurl('denied.gif', $theme) ."' ></td>
//		<td style='border-bottom: 1px solid rgb(204, 204, 204);' nowrap='nowrap' width='70%'><span clas
//		s='genHeaderSmall'>".getFixedLabel('NOPERMITTEDEXECUTE')."</span></td>
//		</tr>
//		<tr>
//		<td class='small' align='right' nowrap='nowrap'>
//		<a href='javascript:window.history.back();'>".getFixedLabel('RETURN')."</a><br>
//		</td>
//		</tr>
//		</tbody></table>
//		</div>";
//	echo "</td></tr></table>";
    include(globalStatic::$root_directory."modules/lingdang/ExitWithoutPermission.php");
	exit;
}


$queryGenerator =QueryGenerator::getInstance  ($currentModule, $current_user,$customView);
/**
 * query_session=1时，读取session中的搜索条件，否则将清空session
 * 查看页面返回列表、列表编辑之后保存 返回列表时，返回query_session=1的参数
 * @project 序时簿查询记住搜索条件
 * @author Tujt 2014-04-25
 */
if(isset($_REQUEST['query_session']) && $_REQUEST['query_session'] == '1' 
		&& isset($_SESSION['LiveViewSearch'][$currentModule])){
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
		}else{
			$search_session = 0;
			unset($_SESSION['LiveViewSearch'][$currentModule]);
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
	/**
	 * query=true时 把搜索参数存入session中
	 * @project 序时簿查询记住搜索条件
	 * @author Tujt 2014-04-25
	 */
	if($_REQUEST['searchtype'] == 'BasicSearch'){
		$_REQUEST['search_text'] = trim($_REQUEST['search_text']);
		$searcharr = explode(':',$_REQUEST['search_field']);
		if(!empty($_REQUEST['search_text']) || (empty($_REQUEST['search_text']) && 'D' == $searcharr[count($searcharr)-1])){
			$input['search_field'] = trim($_REQUEST['search_field']);
			$input['search_text'] = trim($_REQUEST['search_text']);
			$input['SearchScope'] = trim($_REQUEST['SearchScope']);
			$input['searchtype'] = trim($_REQUEST['searchtype']);
			$input['type'] = trim($_REQUEST['type']??'');
		}else{
			unset($_SESSION['LiveViewSearch'][$currentModule]);
		}
	}else if($_REQUEST['searchtype'] == 'advance'){
		$_REQUEST['advft_criteria'] = trim($_REQUEST['advft_criteria']);
		if(!empty($_REQUEST['advft_criteria']) && $_REQUEST['advft_criteria'] != '[]'){
			$input['advft_criteria'] = $_REQUEST['advft_criteria'];
			$input['advft_criteria_groups'] = trim($_REQUEST['advft_criteria_groups']);
			$input['SearchScope'] = trim($_REQUEST['SearchScope']);
			$input['searchtype'] = trim($_REQUEST['searchtype']);
		}else{
			unset($_SESSION['LiveViewSearch'][$currentModule]);
		}
	}
	$ustring = getSearchURL($_REQUEST);
	$url_string .= "&query=true$ustring";
	$smarty->assign('SEARCH_URL', $url_string);
	if(!empty($input)){
		$_SESSION['LiveViewSearch'][$currentModule]['input'] = $input;
		$_SESSION['LiveViewSearch'][$currentModule]['url'] = $url_string;
		$smarty->assign('SEATCH_INPUT',$input);
	}
}
$page_list_query = $queryGenerator->getQuery('',1);
if(empty($_REQUEST['wareid'])){
	crm_load_function_file('getWareidAll','include/Stock','CommonStock');
	if(getWareidAll($current_user->id) != '')
	{
		$all_ware_id = getWareidAll($current_user->id);
	}    
	$ware_sql = ',ld_warehouse2products.productqty FROM (SELECT
				productid,
				warehouseid,sum(ld_warehouse2products.productqty) as productqty
			FROM
				ld_warehouse2products
			WHERE
				ld_warehouse2products.warehouseid IN ('.$all_ware_id.')
			GROUP BY
				productid ) AS ld_warehouse2products ';
	$page_list_query = str_replace("FROM ld_warehouse2products",$ware_sql,$page_list_query);
}else{
	$stockquery  = $queryGenerator->isStockQuery($module);
	$page_list_query .=$stockquery . $customsortorder;
}
$list_query = $queryGenerator->getQuery('',2);

if(isset($_REQUEST['wareid']) && $_REQUEST['wareid'] != '' && $_REQUEST['wareid'] > 0)
{
    $warehouseid = $_REQUEST['wareid'];
}

$where = $queryGenerator->getConditionalWhere();



if(empty($_REQUEST['wareid'])){
	//$page_list_query .= ' group by ld_warehouse2products.productid';
}
/**
 * 排序的逻辑集中到CRMEntity类中，方便处理
 * @author Tujt 2015-04-23
 */

//echo $list_query;
if(PerformancePrefs::getBoolean('LISTVIEW_COMPUTE_PAGE_COUNT', false) === true) {
	/**
	 * 新写 mkListCountQuery 方法，替代 mkCounntListQuery
	 * @author Tujt 2014-07-24
	 */
     //26929: （妙居账套）即时库存查询：显示的单据总数不对，一共只有5条单据，这里记录总数时显示的是7条
    $count_result = $adb->query($page_list_query);
    
    //by ld tifa 20120116 bug 0003154
    if(!empty($count_result))
		$noofrows = $adb->num_rows($count_result);
		//$noofrows=$adb->num_rows($count_result);
    else 
		$noofrows = null;
}else {
	$noofrows = null;
}

$fields = $queryGenerator->getFields();


$queryMode = (isset($_REQUEST['query']) && $_REQUEST['query'] == 'true');
$start = ListViewSession::getRequestCurrentPage($currentModule, $noofrows, $viewid, $queryMode);

  

//echo $list_query. "  $limit_start_rec LIMIT $list_max_entries_per_page_new";
 crm_load_function_file('VT_getSimpleNavigationValues','include/utils','ListViewUtils');

$navigation_array = VT_getSimpleNavigationValues($start,$list_max_entries_per_page_new,$noofrows);;
$limit_start_rec = ($start-1) * $list_max_entries_per_page_new;

$total_list_query=$list_query. " inner join ($page_list_query) 
        as tmp on tmp.warehouseid=ld_warehouse2products.warehouseid and tmp.productid=ld_warehouse2products.productid ";

$list_query.= " inner join ($page_list_query LIMIT $limit_start_rec, $list_max_entries_per_page_new ) 
        as tmp on tmp.warehouseid=ld_warehouse2products.warehouseid and tmp.productid=ld_warehouse2products.productid ";

if(empty($_REQUEST['wareid'])){
	$list_query .= ' group by ld_warehouse2products.productid';
    $total_list_query.=" group by ld_warehouse2products.productid";
}

  $smarty->assign("INVENTORYSUM",getInventoryQueryCount($adb->pquery($total_list_query, array()),1,$customView,$fields));//合计
	$list_result = $adb->pquery($list_query, array());

  

 
    $smarty->assign("INVENTORYCOUNT",getInventoryQueryCount($list_result,2,$customView,$fields));//小计


$recordListRangeMsg = getRecordRangeMessage($list_result, $limit_start_rec,$noofrows);

/**
 * edit:can
 * date:20131212
 * reason:5648: 序时簿全选功能异常：需要选两次，才能出现 全选小页签
 * */
$smarty->assign('recordListRange',$recordListRangeMsg);
$smarty->assign('NUMOFROWS',$noofrows);
$smarty->assign("CUSTOMVIEW_OPTION",$customview_html);
//$smarty->assign("CUSTOMVIEW_OPTION_BEFORE",$customview_html_before);

// Navigation
$navigationOutput = getTableHeaderSimpleNavigation2($navigation_array, $url_string, $currentModule, 'index', $viewid);
$smarty->assign("NAVIGATION", $navigationOutput);

//hzx 20231207 XUQIU1002273 PC端模块列表界面，分页样式优化
$smarty->assign("TABNAME", getParentTab());
$smarty->assign("STARTPAGE", ceil($start));
$smarty->assign("LISTVIEWRECORDCOUNT", ceil($noofrows));
$smarty->assign("LISTVIEWPAGECOUNT", ceil($noofrows/$list_max_entries_per_page_new));
$smarty->assign("LISTVIEWPERPAGENUM", json_encode(getlistmaxentries_per_page($list_max_entries_per_page_new)));

$controller = new ListViewController($adb, $current_user, $queryGenerator);



//得到列头
$listview_header = $controller->getListViewHeader($focus,$currentModule,$url_string,$sorder,$order_by,false);


$listview_entries = $controller->getListViewEntries($focus,$currentModule,$list_result,$navigation_array,false);

/**
 * @project PROT26 序时簿增加合计项
 * @author Tujt 2014-06-05
 */

//$totalfldhtml = $controller->getTotalFldCount($list_query,$list_result,$noofrows);
//$smarty->assign('TOTALFLDHTML',$totalfldhtml);

$listview_header_search = $controller->getBasicSearchFieldInfoList();

//菜单查询和立即查找的数据
$smarty->assign('LISTHEADER', $listview_header);
//$smarty->assign('LISTENTITY', $listview_entries);
//合并列
$smarty->assign('LISTHEADERCOUNT', count($listview_header)+1);

    require('user_privileges/user_language_'.$current_user->id.'.php');
    if($languageType =='en')
        $listview_header_search = $focus->header_search_en;
    else
        $listview_header_search = $focus->header_search;

$smarty->assign('SEARCHLISTHEADER',$listview_header_search);
$smarty->assign("HEADERNAME",$controller->headername);
// Module Search//拼音查找
$alphabetical = AlphabeticalSearch($currentModule,'index',$focus->def_basicsearch_col,'true','basic','','','','',$viewid);
$fieldnames = $controller->getAdvancedSearchOptionString();
//$criteria = getcriteria_options();
$smarty->assign("ALPHABETICAL", $alphabetical);
$smarty->assign("FIELDNAMES", $fieldnames);
$smarty->assign("CRITERIA", $criteria);
/**
 * edit:kevin
 * date:2013-07-31
 * reason:查找单据重复数据
 */ 

//Added to select Multiple records in multiple pages
$smarty->assign("SELECTEDIDS", vtlib_purify($_REQUEST['selobjs']));
$smarty->assign("ALLSELECTEDIDS", vtlib_purify($_REQUEST['allselobjs']));

ListViewSession::setSessionQuery($currentModule,$list_query,$viewid);

/*
edit:chj
date:2013-11-14
reson:入库单仓库检索
*/

    if($current_user->is_admin == on)
    {
        $query='select DISTINCT ld_warehouse.name,ld_warehouse.id from ld_warehouse2user left join ld_warehouse on ld_warehouse2user.warehouseid=ld_warehouse.id
	 where ld_warehouse.started = 0 and ld_warehouse.status = 0 order by ld_warehouse.id';  
	 $result=$adb->pquery($query,array());
    }
    else
    {
        $query="
			select id,name from (
				SELECT 
					ld_warehouse.id, 
					ld_warehouse.`name`
				FROM 
				ld_warehouse 
				INNER JOIN ld_warehouse2user ON ld_warehouse.id = ld_warehouse2user.warehouseid and ld_warehouse.allocatetype = 'all' 
				where `status` = 0 
				GROUP BY 
					ld_warehouse.id
				UNION ALL
				SELECT 
					ld_warehouse.id, 
					ld_warehouse.`name`
				FROM 
				ld_warehouse 
				INNER JOIN ld_warehouse2user ON ld_warehouse.id = ld_warehouse2user.warehouseid and ld_warehouse.allocatetype = 'user'
				INNER JOIN ld_users ON ld_warehouse2user.userid = ld_users.id 
				where ld_warehouse2user.userid = ? and ld_warehouse.`status` = 0 
				GROUP BY 
					ld_warehouse.id
				UNION ALL
				SELECT 
					ld_warehouse.id, 
					ld_warehouse.`name`
				FROM 
				ld_warehouse 
				INNER JOIN ld_warehouse2user ON ld_warehouse.id = ld_warehouse2user.warehouseid and ld_warehouse.allocatetype = 'group'
				INNER JOIN ld_groups ON ld_warehouse2user.userid = ld_groups.groupid 
				LEFT JOIN ld_users2group on ld_users2group.groupid = ld_groups.groupid
				where ld_users2group.userid = ? and ld_warehouse.`status` = 0 
				GROUP BY 
					ld_warehouse.id
				UNION ALL
				SELECT 
					 ld_warehouse.id, 
					ld_warehouse.`name`
				FROM 
				ld_warehouse 
				INNER JOIN ld_warehouse2user ON ld_warehouse.id = ld_warehouse2user.warehouseid and ld_warehouse.allocatetype = 'role'
				INNER JOIN ld_profile ON ld_warehouse2user.userid = ld_profile.profileid 
				LEFT JOIN ld_users on ld_users.profileid = ld_profile.profileid 
				where ld_users.id = ? and ld_warehouse.`status` = 0 
				GROUP BY 
					ld_warehouse.id
			) as temp ORDER BY id
		";
		 $result=$adb->pquery($query,array($current_user->id,$current_user->id,$current_user->id));
    }
   
    $num_rows=$adb->num_rows($result);
    $warehouses=array();
    for($i=0;$i<$num_rows;$i++){
        $warehouses[]=array(
        'id'=>$adb->query_result($result,$i,'id'),
        'name'=>$adb->query_result($result,$i,'name')
        );
    }
   
    if(count($warehouses)>5){
        $warehousesofeight=array();
        for($i=0;$i<5;$i++){
            $warehousesofeight[]=$warehouses[$i];
        }
        $warehouseslast=array();
        for($i=5;$i<count($warehouses);$i++){
            $warehouseslast[$warehouses[$i]['id']]=$warehouses[$i]['name'];
        }
        $smarty->assign('WAREHOUSES',$warehousesofeight);//仓库信息
        $smarty->assign('MOREWAREHOUSES',$warehouseslast);
        
    }
    else
    {
        $smarty->assign('WAREHOUSES',$warehouses);//仓库信息
    }
    $smarty->assign('WAREHOUSEID',$warehouseid);

$smarty->assign('IS_ADMIN', is_admin($current_user));
//add by tifa 20130221 for reminds
//$CASHBILLCREATE

//中英文包
require("user_privileges/user_language_".$current_user->id.'.php');
if(empty($languageType))
{
    $languageType = 'zh';
}
$smarty->assign("LANUGAGETYPE",$languageType);


$approve_focus = Approve::getInstance($currentModule);
$startapprovemodule = $approve_focus->startBlocksApprove();
$issubmit = 0;
if(isset($startapprovemodule[$currentModule])) $issubmit = 1;
$smarty->assign('APPROVEDISSUBMIT',$issubmit);
$smarty->assign('LIST_NOCHECKBOX','no');
$buttonWidth = $focus->getModuleLogic($currentModule)->getListButtomName();//按钮宽度
$widthinfo=getModuleWidth($focus,$controller->getModuleViewFieldsWidth(),$currentModule);
$smarty->assign('LISTHEADERWIDTH',$widthinfo);
$total_width=$controller->getListTotalWidth($widthinfo,$buttonWidth);
$smarty->assign('TOTALWIDTH',$total_width);

$smarty->assign('DEAILHTML',Inventory::createHTML($listview_entries,$currentModule,0,sizeof($listview_header)+1,$focus->logic->list_buttons,'','no'));
if(isset($_REQUEST['ajax']) && $_REQUEST['ajax'] != '')
{
    
    $smarty->display("ListViewEntries.tpl");
}
else
{
    $smarty->display('ListView.tpl');   
}
?>