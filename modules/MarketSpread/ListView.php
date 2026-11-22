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
global $adb, $currentModule, $theme;
global $list_max_entries_per_page_new;
global $current_user;

//wym 230605 获取该模块列表最多条数
//wym 231221 XUQIU1002380 列表显示条数可按成员设置不同的条数
$list_max_entries_per_page_new=getUsersettingByLabel($currentModule,$current_user->id,'MaxEntriesPerPageByuser')??getUsersettingByLabel($currentModule,1,'MaxEntriesPerPage');
$list_max_entries_per_page_new=empty($list_max_entries_per_page_new)?'20':$list_max_entries_per_page_new;

if(isset($_REQUEST['SearchScope'])&&$_REQUEST['SearchScope']!='')
{
    //越权访问
    $ScopOfAuthority=ScopOfAuthority::getInstance($adb,$currentModule);
    $ScopOfAuthority->isCorrectSearchScope($_REQUEST['SearchScope']);
}
if(isset($_REQUEST['senioruserid']))
{
    //越权访问
    $ScopOfAuthority=ScopOfAuthority::getInstance($adb,$currentModule);
    $userids=explode(',',$_REQUEST['senioruserid']);
    for($i=0;$i<sizeof($userids);$i++)
    {
        $ScopOfAuthority->isCorrectSearchScope($userids[$i]);
    }
    
}
require(globalStatic::$root_directory.'user_privileges/user_privileges_'.$current_user->id.'.php');
//require_once($root_directory.'data/Inventory.php');
crm_load_function_file('VT_getSimpleNavigationValues','include/utils','ListViewUtils');
crm_load_class_file('Inventory','data');

$category = getParentTab();
$smarty = new lingdangCRM_Smarty();
$url_string = '';
$stockquery = '';

$focus = CRMEntity::getInstance($currentModule);
//$focus->initSortbyField($currentModule);

//$focus->initSortbyField($currentModule);
/* 列表按钮 begin */
$focus->getModuleLogic($currentModule)->getListViewButtons();
$smarty->assign('LISTBUTTON',$focus->logic->list_buttons);
//增加用户查询范围需求
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

$smarty->assign('MODULE', $currentModule);
$smarty->assign('SINGLE_MOD', getTranstab($currentModule));
$smarty->assign('CATEGORY', $category);
$smarty->assign('THEME', $theme);
$smarty->assign('IMAGE_PATH', "themes/$theme/images/");

//视图中：排序功能失效。
if(isset($_REQUEST["selectedColumnsString2"])){
    include("modules/lingdang/ViewOrderEditSave.php");
    
}
// Custom View
$customView = CustomView::getInstance($currentModule);

$viewid = $customView->getViewId($currentModule);

$smarty->assign("VIEWID", $viewid);

//视图hTML
$customview_html = $customView->getCustomViewAll($viewid,$module,$category);
//@edit zsk 2024/06/11 XUQIU20240516-01 查询分类功能优化
//获取查询分类分组列表
$groupList=$customView->getCustomViewGroupList($customview_html);
$smarty->assign("CUSTOMVIEWGROUPLIST",$groupList);
//前五个数据分类
//$customview_html_before = $customView->getCustomViewCombo2Before($viewid,$module,$category);
$edit_permit = $customView->isPermittedCustomView($viewid,'Create',$currentModule);
$delete_permit = $customView->isPermittedCustomView($viewid,'Delete',$currentModule);
$smarty->assign("CV_EDIT_PERMIT",$edit_permit);
$smarty->assign("CV_DELETE_PERMIT",$delete_permit); 

//by LD tifa 20130104 bug0003118
/*
edit:can
date:20130426
reason:记住上次查询范围
*/
if($_REQUEST['SearchScope'] !=null&&$_REQUEST['SearchScope'] !=''){
	$SearchScope=$_REQUEST['SearchScope'];
	$_SESSION['lvs'][$currentModule]['SearchScope']=$SearchScope;
	$smarty->assign('SelectedOwner2', $_REQUEST['SearchScope']); 
}else if(isset($_SESSION['lvs'][$currentModule]['SearchScope'])&&$_SESSION['lvs'][$currentModule]['SearchScope']!=null){
    $smarty->assign('SelectedOwner2',$_SESSION['lvs'][$currentModule]['SearchScope']);
}else {
    $SearchScope="SmOwner_Search_All";
    $_SESSION['lvs'][$currentModule]['SearchScope']=$SearchScope;
    $smarty->assign('SelectedOwner2',"SmOwner_Search_All");
}
//获取批量操作时记录数上限
$deployarray=getSys_deploy(67);
$smarty->assign('BATCHNUM',$deployarray['deploy_value']);
$viewname = $customView->getViewNameDetail($viewid);
$smarty->assign('ALL', $viewname);
if($viewname == 'All'){
    $viewname = getFixedLabel('ALL');
}
$smarty->assign("VIEWNAME", $viewname);

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
$queryGenerator = QueryGenerator::getInstance($currentModule, $current_user,$customView);
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
$url_string = '';
if($_REQUEST['query'] == 'true') {
   
	$_REQUEST['searchtype'] = trim($_REQUEST['searchtype']);
	$queryGenerator->addUserSearchConditions($_REQUEST);
	if($_REQUEST['searchtype'] == 'BasicSearch'){
		$_REQUEST['search_text'] = trim($_REQUEST['search_text']);
		$searcharr = explode(':',$_REQUEST['search_field']);
        //18399: 回款计划、付款计划、收款单、付款单、费用报销单、佣金单、提现单、存现单-序列表界面：基本查找，按照金额等于0查找，结果基本查找区块会自动收起
		if($_REQUEST['search_text']!='' || (empty($_REQUEST['search_text']) && 'D' == $searcharr[count($searcharr)-1])){
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
    //上一页和下一页点击使用使用
    //28257: 收付款单序时簿界面：基本查找后，点击翻页下一页，结果显示了所有的数据
	$ustring = getSearchURL($_REQUEST);
	$url_string .= "&query=true$ustring";
	$smarty->assign('SEARCH_URL', $url_string);
   
	if(!empty($input)){
		$_SESSION['LiveViewSearch'][$currentModule]['input'] = $input;
		$_SESSION['LiveViewSearch'][$currentModule]['url'] = $url_string;
		$smarty->assign('SEATCH_INPUT',$input);
	}
}
$list_query = $queryGenerator->getQuery('',2);

$page_list_query=$queryGenerator->getQuery('',1);   


$where = $queryGenerator->getConditionalWhere();


//echo $list_query;
if(PerformancePrefs::getBoolean('LISTVIEW_COMPUTE_PAGE_COUNT', false) === true) {
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
$navigation_array = VT_getSimpleNavigationValues($start,$list_max_entries_per_page_new,$noofrows);;
$limit_start_rec = ($start-1) * $list_max_entries_per_page_new;
$countsql = $page_list_query;

list($page_list_query,$order_by,$sorder) = $queryGenerator->customview->getOrderWhere($page_list_query);

$list_query=$list_query." inner join ( $page_list_query  limit $limit_start_rec,$list_max_entries_per_page_new ) as temp on temp.$focus->table_index=$focus->table_name.$focus->table_index";

$list_query.= $queryGenerator->getWhereClause();
list($list_query,$order_by,$sorder) = $queryGenerator->customview->getOrderWhere($list_query,'',$queryGenerator);

$list_result = $adb->pquery($list_query);

if($noofrows-$list_max_entries_per_page_new-$limit_start_rec>0)
    $recordListRangeMsg = getRecordRangeMessageForServieCharge($list_max_entries_per_page_new, $limit_start_rec,$noofrows);
else
    $recordListRangeMsg = getRecordRangeMessageForServieCharge($noofrows-$limit_start_rec, $limit_start_rec,$noofrows);


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
crm_load_class_file('TabDetailListViewController','include/ListView','TabDetailListViewController'); 
$controller = new TabDetailListViewController($adb, $current_user, $queryGenerator,$currentModule);

$skipAction=false;

//得到列头
$listview_header = $controller->getListViewHeader($focus,$currentModule,$url_string,$sorder,$order_by,$skipAction);

$listview_entries = $controller->getListViewEntries($focus,$currentModule,$list_result,$navigation_array,$skipAction);

/**
 * @project PROT26 序时簿增加合计项
 * @author Tujt 2014-06-05
 */
 crm_load_class_file('clsTotal_List','include/ListView');
 $clstotalobj=new clsTotal_List($controller);
$totalfldhtml = $clstotalobj->getTotalFldCount($page_list_query." LIMIT $limit_start_rec, $list_max_entries_per_page_new ",$list_result,$noofrows);
$smarty->assign('TOTALFLDHTML',$totalfldhtml);

//基本查找选项
$listview_header_search = $queryGenerator->TabDetails->getListViewHeaderSearch();

$smarty->assign('LISTHEADER', $listview_header);

$headerinfo=$queryGenerator->TabDetails->getListViewHeaderInfo();
$smarty->assign('HEADERNAME',$headerinfo['fieldname']);
$smarty->assign('HEADERMODULE',$headerinfo['module']);

//合并列
$smarty->assign('LISTHEADERCOUNT', count($listview_header)+1);
$smarty->assign('SEARCHLISTHEADER',$listview_header_search);

// Module Search//拼音查找
$alphabetical = AlphabeticalSearch($currentModule,'index',$focus->def_basicsearch_col,'true','basic','','','','',$viewid);
$fieldnames = $controller->getAdvancedSearchOptionString();
//$criteria = getcriteria_options();
$smarty->assign("ALPHABETICAL", $alphabetical);
$smarty->assign("FIELDNAMES", $fieldnames);
$smarty->assign("CRITERIA", $criteria);

//Added to select Multiple records in multiple pages
$smarty->assign("SELECTEDIDS", vtlib_purify($_REQUEST['selobjs']));
$smarty->assign("ALLSELECTEDIDS", vtlib_purify($_REQUEST['allselobjs']));

ListViewSession::setSessionQuery($currentModule,$page_list_query,$viewid);
$smarty->assign('IS_ADMIN', is_admin($current_user));

//中英文包
require("user_privileges/user_language_".$current_user->id.'.php');
if(empty($languageType)){
    $languageType = 'zh';
}
$smarty->assign("LANUGAGETYPE",$languageType);

//获取列表操作列按钮名称总汇，并返回宽度
$operationWidth = $focus->getModuleLogic($currentModule)->getListButtomName();
$operationWidth=0;
$smarty->assign('OPERATIONWIDTH',$operationWidth);

$widthinfo=getModuleWidth($focus,$controller->getModuleViewFieldsWidth(),$currentModule);
$smarty->assign('LISTHEADERWIDTH',$widthinfo);
$total_width=$controller->getListTotalWidth($widthinfo,$operationWidth);
$smarty->assign('TOTALWIDTH',$total_width);
$smarty->assign("CHKBOXWIDTH",$controller->listchkbox_width);
/**
 * 判断当前模块是否开启审批，开启的话就显示批量提交按钮
 * @project PROT144 审批功能改进
 * @author Tujt 2014-12-26
 */
$approve_focus = Approve::getInstance($currentModule);
$startapprovemodule = $approve_focus->startBlocksApprove();
$issubmit = 0;
if(isset($startapprovemodule[$currentModule])) $issubmit = 1;
$smarty->assign('APPROVEDISSUBMIT',$issubmit);
//$smarty->assign('LISTENTITY', $listview_entries);
$row_count=$queryGenerator->getMainColumnCount();

$row_header = count($listview_header)+1;//有checkbox列所以要加+1
$smarty->assign('PROHTML',Inventory::createModWithDetailhtml($listview_entries,$row_count,$row_header,"yes","",$controller->listchkbox_width));


//$smarty->assign('DEAILHTML',Inventory::createHTML($listview_entries,$currentModule,0,sizeof($listview_header)+1,$focus->logic->list_buttons));

if(isset($_REQUEST['ajax']) && $_REQUEST['ajax'] != ''){
    
    $smarty->display("ProductListViewEntries.tpl");
}else{
    $smarty->display('ListView.tpl');   
}

?>