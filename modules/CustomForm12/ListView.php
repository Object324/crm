<?php
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

require('user_privileges/user_privileges_'.$current_user->id.'.php');
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
crm_load_function_file('VT_getSimpleNavigationValues','include/utils','ListViewUtils');
crm_load_class_file('Inventory','data');
//$category = getParentTab();
$category = '';
$warehouseid = 0;
$morelist = 0;
$url_string = '';
$smarty = new lingdangCRM_Smarty();

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
$smarty->assign('LISTBUTTON',$focus->logic->list_buttons);
/* 列表按钮 end */
if(isset($_REQUEST['ajaxtype']) && $_REQUEST['ajaxtype'] =='ld_linkmodulecustom'){
    $smarty->assign('LINKMODULECUSTOM', true);
}
/*
By LD Can;
Date:20121225;
reason:增加用户查询范围需�?

*/
$MergeSmowner=getCurSmOwnerSearchScope($currentModule);
unset($MergeSmowner["UserCombo"][$current_user->id]);//去除当前用户

//$newCustomView = new ProductDetails($module);
$morelist = 1;

// Identify this module as custom module.
$smarty->assign('MORE_LIST',$morelist);
//print_r($newCustomView->getRowCount());

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

$smarty->assign('CHECK', $tool_buttons);
$smarty->assign('THEME', $theme);
$smarty->assign('IMAGE_PATH', "themes/$theme/images/");

/*
edit:Can
date:20130605
reason:4067: 视图中：排序功能失效�?
*/
if(isset($_REQUEST["selectedColumnsString2"]))
{
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
//前五个数据分�?
//$customview_html_before = $customView->getCustomViewCombo2Before($viewid,$module,$category);

// To check if a user is able to edit/delete a CustomView
//$edit_permit = $customView->isPermittedCustomView($viewid,'Create',$currentModule);
//$delete_permit = $customView->isPermittedCustomView($viewid,'Delete',$currentModule);
Crm_load_class_file("CommonView","modules/CustomView");
$smarty->assign("DATETIMESTR",json_encode(CommonView::stdFilterDateTimeStr()));
//$smarty->assign("CUSTOMVIEW_PERMISSION",$statusdetails);
//$smarty->assign("CV_EDIT_PERMIT",$edit_permit);
///$smarty->assign("CV_DELETE_PERMIT",$delete_permit); 
//}
// END
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
/**
 * query_session=1时，读取session中的搜索条件，否则将清空session
 * 查看页面返回列表、列表编辑之后保�?返回列表时，返回query_session=1的参�?
 * @project 序时簿查询记住搜索条�?
 * @author Tujt 2014-04-24
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
	}else if($input['searchtype'] == 'advance'|| $input['searchtype'] == 'tiled'){
		if(!empty($input['advft_criteria']) && $input['advft_criteria'] != '[]'){
			$_REQUEST['advft_criteria'] = $input['advft_criteria'];
			$_REQUEST['advft_criteria_groups'] = $input['advft_criteria_groups'];
			$_REQUEST['SearchScope'] = $input['SearchScope'];
			$_REQUEST['searchtype'] = $input['searchtype'];
			//初始化搜索条�?
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

///得到对应视图的查询字�?
if ($viewid != "0") {
   $queryGenerator->initForCustomViewById($viewid);
} else {
	$queryGenerator->initForDefaultCustomView();
}
//eidtor:gyq_20200311 reason:新增保存，refreshlistbyPopupobj函数刷新列表时，需要使用 url:"index.php?"+popupobj.url,而popupobj.url的值来源于LISTPAGEURL
//0039306: （51mis.com/kfbcrm）自定义表单>自定义表单11>新建单据界面：录入数据后，点击“保存”按钮会自动跳转至“首页”界面
$smarty->assign("LISTPAGEURL", getlisturl_aftersave());
// Enabling Module Search
$url_string = '';
if($_REQUEST['query'] == 'true') {
	$_REQUEST['searchtype'] = trim($_REQUEST['searchtype']);
	$queryGenerator->addUserSearchConditions($_REQUEST);
	/**
	 * query=true�?把搜索参数存入session�?
	 * @project 序时簿查询记住搜索条�?
	 * @author Tujt 2014-04-24
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


$page_list_query=$queryGenerator->getQuery('',4);//分页查询语句


//14569: 合同订单>明细：显示空白。edit:can
ListViewSession::setSessionQuery($currentModule,$page_list_query,$viewid);
//echo $page_list_query;
$list_query = $queryGenerator->getQuery('',2);//所有数据查�?
//zxm 2021-0506【单据序时簿列表界面，进度漏斗增加穿透功能】 https://www.tapd.cn/63637123/prong/stories/view/1163637123001001609
//因无法使用高级查询 拼接advance_stage条件
$advance_stage =  $_REQUEST['advance_stage'];
if(!empty($advance_stage)){
    $page_list_query_explode = explode('group by',$page_list_query);
    $page_list_query_explode[0] = $page_list_query_explode[0].' and '.$focus->table_name.'.advance_stage like "%'.$advance_stage.'%" ';
    $page_list_query = implode(' group by ',$page_list_query_explode);
}

//echo $queryGenerator->getMainColumnCount();

$ChartFrom=str_replace(' ','//B/',$queryGenerator->getChartFrom());
$ChartFrom=str_replace("'","//,/",$ChartFrom);
$ChartFrom=str_replace("%'","//,,/",$ChartFrom);

$ChartWhere=str_replace(' ','//B/',$queryGenerator->getChartWhere());
$ChartWhere=str_replace("'","//,/",$ChartWhere);

$ChartOwner=str_replace(' ','//B/',$queryGenerator->getChartOwner());
$smarty->assign('CHARTFROM',$ChartFrom);
$smarty->assign('CHARTWHERE',$ChartWhere);
$smarty->assign('CHARTOWNER',$ChartOwner);

$where = $queryGenerator->getConditionalWhere();

$queryMode = (isset($_REQUEST['query']) && $_REQUEST['query'] == 'true');

$count_sql = $queryGenerator->getQueryRow_Count();
//zxm 2021-0506【单据序时簿列表界面，进度漏斗增加穿透功能】 https://www.tapd.cn/63637123/prong/stories/view/1163637123001001609
//因无法使用高级查询 拼接advance_stage条件
$fromtype = $_REQUEST['fromtype'];
$LIST_NOCHECKBOX = 'yes';
if($fromtype=='salesfunnel'){
    $LIST_NOCHECKBOX = 'no';
    $smarty->assign('LIST_NOCHECKBOX',$LIST_NOCHECKBOX);
    $smarty->assign('fromtype',$fromtype);
}
$advance_stage =  $_REQUEST['advance_stage'];
if(!empty($advance_stage)){
    $count_sql_explode = explode('group by',$count_sql);
    $count_sql_explode[0] = $count_sql_explode[0].' and '.$focus->table_name.'.advance_stage like "%'.$advance_stage.'%" ';
    $count_sql = implode(' group by ',$count_sql_explode);
}
$count_result = $adb->query($count_sql);

if(!empty($count_result))
	$noofrows = $adb->query_result($count_result,0,0);
else 
	$noofrows = null;
$smarty->assign('NUMOFROWS',$noofrows);
$start = ListViewSession::getRequestCurrentPage($currentModule, $noofrows, $viewid, $queryMode);
$navigation_array = VT_getSimpleNavigationValues($start,$list_max_entries_per_page_new,$noofrows);
$limit_start_rec = ($start-1) * $list_max_entries_per_page_new;

//$customsortorder = $customView->getCustomViewOrderBy($viewid);
//$orderby = " ORDER BY $customsortorder $focus->table_name.$focus->table_index desc";

/**
 * 排序的逻辑集中到CRMEntity类中，方便处�?
 * @author Tujt 2015-04-23
 */


 
list($page_list_query,$order_by,$sorder) = $queryGenerator->customview->getOrderWhere($page_list_query);
//echo $page_list_query;
$list_query=$list_query." inner join ( $page_list_query  limit $limit_start_rec,$list_max_entries_per_page_new ) as temp on temp.customform12id=ld_customform12.customform12id";
$list_query=$list_query.$queryGenerator->getWhereClause();////不能删除，删除后，查询条件为产品明细有bug;



/**
 * 排序的逻辑集中到CRMEntity类中，方便处�?
 * @author Tujt 2015-04-23
 */

list($list_query,$order_by,$sorder) = $queryGenerator->customview->getOrderWhere($list_query,'',$queryGenerator);
//echo $list_query;
$list_result = $adb->pquery($list_query);
/**
 * edit:can
 * date:20131212
 * reason:5648: 序时簿全选功能异常：需要选两次，才能出现 全选小页签
 * */
if($noofrows-$list_max_entries_per_page_new-$limit_start_rec>0)
    $recordListRangeMsg = getRecordRangeMessageForServieCharge($list_max_entries_per_page_new, $limit_start_rec,$noofrows);
else
    $recordListRangeMsg = getRecordRangeMessageForServieCharge($noofrows-$limit_start_rec, $limit_start_rec,$noofrows);


$smarty->assign('recordListRange',$recordListRangeMsg);
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
crm_load_class_file('ProductDetail_ListController','include/ListView/ProductDetail');
$controller = new ProductDetail_ListController($adb, $current_user, $queryGenerator);


if(isset($skipAction)==false){
	$skipAction==false;
}
 //得到列头
$listview_header = $controller->getListViewHeader($focus,$currentModule,$url_string,$sorder,$order_by,$skipAction);

$listview_entries = $controller->getListViewEntries($focus,$currentModule,$list_result,$navigation_array,$skipAction);



$listview_header_search=$queryGenerator->productDetails->getListViewHeaderSearch();
//中能特殊控制 - 明细库存数量不显�?
foreach($listview_header_search as $column_str => $fieldlabel){
	if(strpos($column_str,'zhongneng_ware_qty') !== false){
		unset($listview_header_search[$column_str]);
	}
}


/**
 * @project PROT26 序时簿增加合计项
 * @author Tujt 2014-06-05
 */
crm_load_class_file('clsTotal_List','include/ListView');
$clstotalobj=new clsTotal_List($controller);
$totalfldhtml = $clstotalobj->getTotalFldCount($page_list_query ." limit $limit_start_rec,$list_max_entries_per_page_new",$list_result,$noofrows);
$smarty->assign('TOTALFLDHTML',$totalfldhtml);

//菜单查询和立即查找的数据
$smarty->assign('LISTHEADER', $listview_header);

//合并�?
$smarty->assign('LISTHEADERCOUNT', count($listview_header)+1);
//$smarty->assign('LISTENTITY', $listview_entries);
$row_count=$queryGenerator->getMainColumnCount();

$row_header = count($listview_header)+1;
$smarty->assign('PROHTML',Inventory::createModWithDetailhtml($listview_entries,$row_count,$row_header,$LIST_NOCHECKBOX,"",$controller));
$smarty->assign('SEARCHLISTHEADER',$listview_header_search);
//getMoneyKeyCount($listview_entries)
$smarty->assign('ROW_COUNT', $row_count);
// Module Search//拼音查找
//$alphabetical = AlphabeticalSearch($currentModule,'index',$focus->def_basicsearch_col,'true','basic','','','','',$viewid);
$fieldnames = $controller->getAdvancedSearchOptionString();

//$criteria = getcriteria_options();
//$smarty->assign("ALPHABETICAL", $alphabetical);
$smarty->assign("FIELDNAMES", $fieldnames);
$smarty->assign("CRITERIA", $criteria);

//Added to select Multiple records in multiple pages
$smarty->assign("SELECTEDIDS", vtlib_purify($_REQUEST['selobjs']));
$smarty->assign("ALLSELECTEDIDS", vtlib_purify($_REQUEST['allselobjs']));




$smarty->assign('IS_ADMIN', is_admin($current_user));

//中英文包
require("user_privileges/user_language_".$current_user->id.'.php');
if(empty($languageType))
{
    $languageType = 'zh';
}
$trades=getVersionTradeInfo();

$smarty->assign('TRADE',$trades['trade']);   
//派息单弹出层(在列表界面直接点击编辑按�?
if($_SESSION[globalStatic::$session_prevfix_bol."popup_finance_dividendorder"]=='yes' && isPermitted("DividendOrder","index",'') == 'yes')
{
  if($_REQUEST['record'])
  {
    $smarty->assign("RECORDID",$_REQUEST['record']);
    $smarty->assign("CREATEPOPDIVIDENDORDER",'yes');
  }
  unset($_SESSION[globalStatic::$session_prevfix_bol."popup_finance_dividendorder"]);   
}
$smarty->assign("LANUGAGETYPE",$languageType);
//获取列表操作列按钮名称总汇，并返回宽度
$headerinfo=$queryGenerator->productDetails->getListViewHeaderInfo();
$smarty->assign('HEADERNAME',$headerinfo['fieldname']);
$smarty->assign('HEADERMODULE',$headerinfo['module']);
/**
 * 每列宽度的信息
 * edit:can 20200720
 * */
$smarty->assign("FieldWidthSetting",ldcrm_json_encode($controller->getModuleViewFieldsWidth()));
$operationWidth = $focus->getModuleLogic($currentModule)->getListButtomName();
$smarty->assign('OPERATIONWIDTH',$operationWidth);
$widthinfo=getModuleWidth($focus,$controller->getModuleViewFieldsWidth(),$currentModule);
$smarty->assign('LISTHEADERWIDTH',$widthinfo);
$total_width=$controller->getListTotalWidth($widthinfo,$operationWidth);
$smarty->assign('TOTALWIDTH',$total_width);
$smarty->assign("CHKBOXWIDTH",$controller->listchkbox_width);
//获取批量操作时记录数上限
$deployarray=getSys_deploy(67);
$smarty->assign('BATCHNUM',$deployarray['deploy_value']);
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
//zkt 2021/12/28 平铺查找条件保存在数据库
$sql = 'select id,searchvalue from ld_searchhistory where modulename = ? and smownerid = ? and searchtype = ? order by searchtime desc';
$result = $adb->pquery($sql,array($currentModule,$current_user->id,'tiled'));
$num_rows = $adb->num_rows($result);
$tiledSearch = '';
if($num_rows >0){
    $tiledSearch = $adb->query_result($result,0,'searchvalue');
}
$smarty->assign("tiledSearch",html_entity_decode($tiledSearch));

setGLobalURLSmarty($smarty);//����js,css�ȷ���·��
//zkt 20220923 BUG0056886CustomForm12-CustomForm20,CustomForm36-CustomForm45没有显示列表小编辑
$fields=$focus->fieldobj->getFieldListArray();
$smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));

//xll 20221214 获取最近一次的基本搜索框字段选项
$controller->getFieldStorage($smarty);

// ljj 2023-08-29 XUQIU1001610 树结构设置和成员管理，左侧分类名称增加计数功能
$cls_MyCRMcryptobj=new cls_MyCRMcrypt();
$smarty->assign("Encrypt_TreeWhere",$cls_MyCRMcryptobj->encode($queryGenerator->getSqlNoTreeWhere($page_list_query)));

//zxm 20230614 获取列表页面公共参数并assign到tpl
ListViewCommonAssign($currentModule,$smarty,$focus);



if(isset($_REQUEST['ajax']) && $_REQUEST['ajax'] != '')
{
    $smarty->display("ProductListViewEntries.tpl");
}
	
else
	$smarty->display('ListView.tpl');
 if($_SESSION['kiserror']&&$_SESSION['kiserror']!='')
{
    echo "<script>alert('".$_SESSION['kiserror']."')</script>";
    $_SESSION['kiserror']='';
    
}

unset($app_strings);
unset($mod_strings);
unset($currentModule) ;
unset($theme) ;
unset ($list_max_entries_per_page_new);
?>