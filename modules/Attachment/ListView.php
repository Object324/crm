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
global $current_language, $currentModule, $theme;
global $list_max_entries_per_page_new;
global $current_user;

//wym 230605 获取该模块列表最多条数
//wym 231221 XUQIU1002380 列表显示条数可按成员设置不同的条数
$list_max_entries_per_page_new=getUsersettingByLabel($currentModule,$current_user->id,'MaxEntriesPerPageByuser')??getUsersettingByLabel($currentModule,1,'MaxEntriesPerPage');
$list_max_entries_per_page_new=empty($list_max_entries_per_page_new)?'20':$list_max_entries_per_page_new;

$_SESSION[globalStatic::$root_directory.'prevmenu_module'.$current_user->id]=$currentModule;
$_SESSION[globalStatic::$root_directory.'prevmenu_modulefile'.$current_user->id]='index';
require_once('data/Inventory.php');
$category = getParentTab();
$warehouseid = 0;
$url_string = '';
$stockquery = '';
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
$smarty = new lingdangCRM_Smarty();

//0050212: 【苏州灵当】V8.4.5.6（https://kh.xiaoshou360.com/suzhould [^]）工作台-企业云盘(原附件管理)-树状结构目录：设置完成后不生效，系产品通用bug，开发部CRM可还原（详情见说明）
//zkt 列表界面增加树结构显示
crm_load_class_file('cls_Module_Tree', 'include/utils');
$cls_module_tree = cls_Module_Tree::getInstance($currentModule);
if(isset($_REQUEST['ajax']) && $_REQUEST['ajax'] != '')
{
    
}
else
{
    if($cls_module_tree->moduleenable=='yes'){
        //加载初始listview树状结构
        $modulelisttree = $cls_module_tree->getModuleListTree();
        $smarty->assign('MODULElISTTREE',$modulelisttree);
        $module_list_treeselectrecord=0;
        //若$_SESSION中储存的selectrecord值,为级联下拉值id，设置selectrecord为0（或获取下级对应html）
        if(isset($modulelisttree)&&$modulelisttree['enable']=='yes'&&!isset($modulelisttree['list'][$_SESSION['module_list_tree'][$currentModule]['selectrecord']])){
            //$_SESSION['module_list_tree'][$currentModule] = array('selectrecord'=>0,'list'=>array());
            //获取下级对应html
            $sessionarr = $_SESSION['module_list_tree'][$currentModule];
            $Inithtmlexpand = $cls_module_tree->getInithtmlexpand($sessionarr['selectrecord'],$sessionarr['list']);
            $smarty->assign('Inithtmlexpand',$Inithtmlexpand);
        }
    }
    //获取设置选中的树结构id和list
    $module_list_treeselectrecord=0;
    if(isset($_SESSION['module_list_tree'][$currentModule])){
        $module_list_treeselectrecord= $_SESSION['module_list_tree'][$currentModule]['selectrecord'];
    }
    $smarty->assign('MODULE_TREE_PICKLIST_ID',$module_list_treeselectrecord);
}

$focus = CRMEntity::getInstance($currentModule);
//$focus->initSortbyField($currentModule);

/* 列表按钮 begin */
$focus->getModuleLogic($currentModule)->getListViewButtons();

if(isset($_REQUEST['ajaxtype']) && $_REQUEST['ajaxtype'] =='ld_linkmodulecustom'){
    $smarty->assign('LINKMODULECUSTOM', true);
}

$MergeSmowner=getCurSmOwnerSearchScope($currentModule);
unset($MergeSmowner["UserCombo"][$current_user->id]);//去除当前用户
// Identify this module as custom module.
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

$smarty->assign('CATEGORY', $category);
//$smarty->assign('CHECK', $tool_buttons);
$smarty->assign('THEME', $theme);
$smarty->assign('IMAGE_PATH', "themes/$theme/images/");


if(isset($_REQUEST["selectedColumnsString2"]))
{
    include("modules/lingdang/ViewOrderEditSave.php");
    
}
//获取批量操作时记录数上限
$deployarray=getSys_deploy(67);
$smarty->assign('BATCHNUM',$deployarray['deploy_value']);
// Custom View
$customView =CustomView::getInstance($currentModule);
$viewid = $customView->getViewId($currentModule);
$smarty->assign("VIEWID", $viewid);
//$smarty->assign('PAGEWIDTHPERCENT', getModulePageWithPercent($viewid));
//视图hTML
$customview_html = $customView->getCustomViewAll($viewid,$module,$category);
//@edit zsk 2024/06/11 XUQIU20240516-01 查询分类功能优化
//获取查询分类分组列表
$groupList=$customView->getCustomViewGroupList($customview_html);
$smarty->assign("CUSTOMVIEWGROUPLIST",$groupList);
//前五个数据分类
//$customview_html_before = $customView->getCustomViewCombo2Before($viewid,$module,$category);
$viewinfo = $customView->getViewDetailInfo($viewid);
Crm_load_class_file("CommonView","modules/CustomView");
$smarty->assign("DATETIMESTR",json_encode(CommonView::stdFilterDateTimeStr()));

//$statusdetails = $customView->isPermittedChangeStatus($viewinfo['status']);
 
	// To check if a user is able to edit/delete a CustomView
	//$edit_permit = $customView->isPermittedCustomView($viewid,'Create',$currentModule);
//	$delete_permit = $customView->isPermittedCustomView($viewid,'Delete',$currentModule);

	$smarty->assign("CUSTOMVIEW_PERMISSION",$statusdetails);
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
$viewname = $customView->getViewNameDetail($viewid);
$smarty->assign('ALL', $viewname);
if($viewname == 'All'){
    $viewname = getFixedLabel('ALL');
}
$smarty->assign("VIEWNAME", $viewname);

if($viewid ==0 ) {
	// echo "<table border='0' cellpadding='5' cellspacing='0' width='100%' height='450px'><tr><td align='center'>";
	// echo "<div style='border: 3px solid rgb(153, 153, 153); background-color: rgb(255, 255, 255); width: 55%; position: relative; z-index: 10000000;'>

	// 	<table border='0' cellpadding='5' cellspacing='0' width='98%'>
	// 	<tbody><tr>
	// 	<td rowspan='2' width='11%'><img src='". lingdang_imageurl('denied.gif', $theme) ."' ></td>
	// 	<td style='border-bottom: 1px solid rgb(204, 204, 204);' nowrap='nowrap' width='70%'><span clas
	// 	s='genHeaderSmall'>".getFixedLabel('NOPERMITTEDEXECUTE')."</span></td>
	// 	</tr>
	// 	<tr>
	// 	<td class='small' align='right' nowrap='nowrap'>
	// 	<a href='javascript:window.history.back();'>" . getFixedLabel('RETURN') . "</a><br>
	// 	</td>
	// 	</tr>
	// 	</tbody></table>
	// 	</div>";
	// echo "</td></tr></table>";
    include(globalStatic::$root_directory."modules/lingdang/ExitWithoutPermission.php");
	exit;
}


//$queryGenerator = new QueryGenerator($currentModule, $current_user);
$queryGenerator =QueryGenerator::getInstance($currentModule, $current_user,$customView);
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
         // zkt 2021/12/27 平铺搜索 优化（批量操作按钮）-批量导出
	}else if($input['searchtype'] == 'advance'|| $_REQUEST['searchtype'] == 'tiled'){
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
$smarty->assign("LISTPAGEURL", getlisturl_aftersave());
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
         // zkt 2021/12/27 平铺搜索 优化（批量操作按钮）-批量导出
	}else if($_REQUEST['searchtype'] == 'advance'|| $_REQUEST['searchtype'] == 'tiled'){
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
$list_query= $queryGenerator->getQuery('',2);

//zxm 2021-0506【单据序时簿列表界面，进度漏斗增加穿透功能】 https://www.tapd.cn/63637123/prong/stories/view/1163637123001001609
//因无法使用高级查询 拼接advance_stage条件
$advance_stage =  $_REQUEST['advance_stage'];
if(!empty($advance_stage)){
    $page_list_query_explode = explode('group by',$page_list_query);
    $page_list_query_explode[0] = $page_list_query_explode[0].' and '.$focus->table_name.'.advance_stage like "%'.$advance_stage.'%" ';
    $page_list_query = implode(' group by ',$page_list_query_explode);
}

$where = $queryGenerator->getConditionalWhere();
//$smarty->assign('BUTTONS', $list_buttons);

if(isset($where) && $where != '') {
	$_SESSION['export_where'] = $where;
} else {
	unset($_SESSION['export_where']);
}

/**
 * 排序的逻辑集中到CRMEntity类中，方便处理
 * @author Tujt 2015-04-23
 */



    $count_result = $adb->query( $page_list_query);
    //by ld tifa 20120116 bug 0003154
    if(!empty($count_result))
		$noofrows = $adb->num_rows($count_result);
		//$noofrows=$adb->num_rows($count_result);
    else 
		$noofrows = null;


list($page_list_query,$order_by,$sorder) = $queryGenerator->customview->getOrderWhere($page_list_query);
$queryMode = (isset($_REQUEST['query']) && $_REQUEST['query'] == 'true');
$start = ListViewSession::getRequestCurrentPage($currentModule, $noofrows, $viewid, $queryMode);
//echo $list_query. " OFFSET $limit_start_rec LIMIT $list_max_entries_per_page_new";
crm_load_function_file('VT_getSimpleNavigationValues','include/utils','ListViewUtils');
$navigation_array = VT_getSimpleNavigationValues($start,$list_max_entries_per_page_new,$noofrows);;
$limit_start_rec = ($start-1) * $list_max_entries_per_page_new;
 $list_query=$list_query." inner join (  $page_list_query   LIMIT $limit_start_rec, $list_max_entries_per_page_new ) as tmp 
         on tmp.attachmentsid=ld_attachmentsforbills.attachmentsid ";
$list_query=$list_query.$queryGenerator->getWhereClause();
list($list_query,$order_by,$sorder) = $queryGenerator->customview->getOrderWhere($list_query,'',$queryGenerator);    

$list_result = $adb->pquery($list_query, array());

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

//$controller = new ListViewController($adb, $current_user, $queryGenerator);
crm_load_function_file('AttachmentsListViewController','include/ListView','AttachmentsListViewController'); 
$controller = new AttachmentsListViewController($adb, $current_user, $queryGenerator,$currentModule);
if(isset($skipAction)==false){
	$skipAction==false;
}

$listview_header = $controller->getListViewHeader($focus,$currentModule,$url_string,$sorder,$order_by,$skipAction);

$listview_entries = $controller->getListViewEntries($focus,$currentModule,$list_result,$navigation_array,$skipAction);

/**
 * @project PROT26 序时簿增加合计项
 * @author Tujt 2014-06-05
 */
//$totalfldhtml = $controller->getTotalFldCount($list_query,$list_result,$noofrows);
//$smarty->assign('TOTALFLDHTML',$totalfldhtml);

//$listview_header_search = $controller->getBasicSearchFieldInfoList();
$listview_header_search=$queryGenerator->productDetails->getListViewHeaderSearch();

//Liver 2017-04-13 去掉查找条件中的相关对象
foreach($listview_header_search as $key =>$value){
    if(strstr($key,"related_to")){
        unset($listview_header_search[$key]);
    }
}

//菜单查询和立即查找的数据
$smarty->assign('LISTHEADER', $listview_header);
//合并列
$smarty->assign('LISTHEADERCOUNT', count($listview_header)+1);
$smarty->assign('LISTENTITY', $listview_entries);

$smarty->assign('SEARCHLISTHEADER',$listview_header_search);
$smarty->assign("HEADERNAME",$controller->headername);
// Module Search//拼音查找
$alphabetical = AlphabeticalSearch($currentModule,'index',$focus->def_basicsearch_col,'true','basic','','','','',$viewid);
$fieldnames = $controller->getAdvancedSearchOptionString();
//$criteria = getcriteria_options();
$smarty->assign("ALPHABETICAL", $alphabetical);
$smarty->assign("FIELDNAMES", $fieldnames);

//Added to select Multiple records in multiple pages
$smarty->assign("SELECTEDIDS", vtlib_purify($_REQUEST['selobjs']));
$smarty->assign("ALLSELECTEDIDS", vtlib_purify($_REQUEST['allselobjs']));

//zkt 20230216 BUG0061726附件管理，添加多个附件时，点击进入单据详情，点击下一页，点击无效 
ListViewSession::setSessionQuery($currentModule,$page_list_query,$viewid);

//单据推进管理 - 推进漏斗
/*crm_load_class_file('cls_module_advance','modules/Settings');
$cls_module_advance = new cls_module_advance($currentModule);
$smarty->assign('MODULEADVANCESTAGESTATUS',$cls_module_advance->is_Enable());*/
$smarty->assign('IS_ADMIN', is_admin($current_user));
 $smarty->assign("LISTBUTTONMOREFORD",'YES');
//中英文包
$languageType= getLanguageType($current_user);

$smarty->assign("LANUGAGETYPE",$languageType);
/**
 * 每列宽度的信息
 * edit:can 20200720
 * */
$smarty->assign("FieldWidthSetting",ldcrm_json_encode($controller->getModuleViewFieldsWidth()));
//获取列表操作列按钮名称总汇，并返回宽度
//设置列宽的列
$headerinfo=$queryGenerator->productDetails->getListViewHeaderInfo();
$smarty->assign('HEADERNAME',$headerinfo['fieldname']);
$smarty->assign('HEADERMODULE',$headerinfo['module']);
$operationWidth = $focus->getModuleLogic($currentModule)->getListButtomName();
$smarty->assign('OPERATIONWIDTH',$operationWidth);
$widthinfo=getModuleWidth($focus,$controller->getModuleViewFieldsWidth(),$currentModule);
$smarty->assign('LISTHEADERWIDTH',$widthinfo);
$total_width=$controller->getListTotalWidth($widthinfo,$operationWidth);
$smarty->assign('TOTALWIDTH',$total_width);
$smarty->assign("CHKBOXWIDTH",$controller->listchkbox_width);
//print_r($focus->logic->list_buttons);

//dump(Inventory::createHTML($listview_entries,$currentModule,1,sizeof($listview_header)+1,$focus->logic->list_buttons));
$row_count=$queryGenerator->getMainColumnCount();
$row_header = count($listview_header)+1;
setGLobalURLSmarty($smarty);//设置js,css等访问路径
$smarty->assign('PROHTML',Inventory::createModWithDetailhtml($listview_entries,$row_count,$row_header,"yes","",$controller));
  $fields=$focus->fieldobj->getFieldListArray();
$smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));
$smarty->assign('MODULEBILLNOTIP',$_SESSION[$currentModule.'_modulebillnotip']);
$_SESSION[$currentModule.'_modulebillnotip']='no';
// @edit:dong @date:2020/08/19 @reason: 查找 用于区分搜索类型
$smarty->assign('SEARCHTYPE',$_REQUEST['searchtype']);
//zkt 2021/12/27 用于区分是否为销售漏斗
if(isset($_REQUEST['fromtype'])&&$_REQUEST['fromtype']=='salesfunnel'){
    $smarty->assign('ISSALESFUNNEL','yes');
}
//zkt 2021/12/27 用于区分是否显示平铺搜索界面
if(isset($_REQUEST['tiledSearchdisplay'])&&$_REQUEST['tiledSearchdisplay']=='none'){
    $smarty->assign('SHOWtiledSearch','no');
}

//xll 20221214 获取最近一次的基本搜索框字段选项
$controller->getFieldStorage($smarty);

// ljj 2023-08-29 XUQIU1001610 树结构设置和成员管理，左侧分类名称增加计数功能
$cls_MyCRMcryptobj=new cls_MyCRMcrypt();
$smarty->assign("Encrypt_TreeWhere",$cls_MyCRMcryptobj->encode($queryGenerator->getSqlNoTreeWhere($page_list_query)));

//zxm 20230614 获取列表页面公共参数并assign到tpl
ListViewCommonAssign($currentModule,$smarty,$focus);


if(isset($_REQUEST['ajax']) && $_REQUEST['ajax'] != ''){
    $smarty->display("ProductListViewEntries.tpl");
    //$smarty->display("ProductListViewEntries.tpl");
}else{
    $smarty->display('ListView.tpl');   
}

?>