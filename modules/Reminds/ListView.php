<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global  $currentModule, $theme;
global $list_max_entries_per_page_new;
global $current_user;
$skipAction=true;//edit:can reason:12564: 提醒叙事簿界面：序列表中多显示了一列“操作列”-如图，1024*768

//wym 230605 获取该模块列表最多条数
//wym 231221 XUQIU1002380 列表显示条数可按成员设置不同的条数
$list_max_entries_per_page_new=getUsersettingByLabel($currentModule,$current_user->id,'MaxEntriesPerPageByuser')??getUsersettingByLabel($currentModule,1,'MaxEntriesPerPage');
$list_max_entries_per_page_new=empty($list_max_entries_per_page_new)?'20':$list_max_entries_per_page_new;

include(globalStatic::$root_directory.'data/Inventory.php');
include(globalStatic::$root_directory.'include/QueryGenerator/RemindsQueryGenerator.php');

$category = getParentTab();
$smarty = new lingdangCRM_Smarty();
$warehouseid = 0;
$url_string = '';
$stockquery = '';

$focus = CRMEntity::getInstance($currentModule);
//$focus->initSortbyField($currentModule);

//$focus->initSortbyField($currentModule);
/* 列表按钮 begin */
$focus->getModuleLogic($currentModule)->getListViewButtons();
$smarty->assign('LISTBUTTON',$focus->logic->list_buttons);

if(isset($_REQUEST['ajaxtype']) && $_REQUEST['ajaxtype'] =='ld_linkmodulecustom'){
    $smarty->assign('LINKMODULECUSTOM', true);
}

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
// $smarty->assign('Merge_SmOwner_arr',json_encode($SmOwner_option_arr));
$smarty->assign('MAX_RECORDS', $list_max_entries_per_page_new);

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
crm_load_class_file("RemindsCustomView",'modules/Reminds');
$customView = new RemindsCustomView();
// $customView = CustomView::getInstance($currentModule);

/**
 * reason:提醒序时簿>未读、已读、发件箱页签，删除序列表中的一条数据 结果把序列表中的所有数据都给删除了
 * date:20130807
 * edit:can
 * */
if(isset($_REQUEST['viewname'])&&($_REQUEST['viewname']==115||$_REQUEST['viewname']==114||$_REQUEST['viewname']==108||$_REQUEST['viewname']==getRemindsCvid('all')))
{
    $viewid=$_REQUEST['viewname'];//提醒
    $_SESSION['lvs'][$currentModule]["viewname"]=$viewid;
    $SearchScope='SmOwner_Search_All';
    $_SESSION['lvs'][$currentModule]['SearchScope']="SmOwner_Search_All";
   
}

else
{
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
    else
    $viewid = $customView->getViewId($currentModule);
}
//26635: 提醒列表：拖动列宽后，点击翻页栏处，翻页后没有记录之前拖动的位置
$customView->cvid=$viewid;

$smarty->assign("VIEWID", $viewid);

//视图hTML
$customview_html = $customView->getCustomViewCombo2($viewid,$module,$category);

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


$queryGenerator = new RemindsQueryGenerator($currentModule, $current_user,$customView);
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
// 得到对应视图的查询字段
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
	$ustring = getSearchURL($_REQUEST);
	$url_string .= "&query=true$ustring";
	$smarty->assign('SEARCH_URL', $url_string);
   
	if(!empty($input)){
		$_SESSION['LiveViewSearch'][$currentModule]['input'] = $input;
		$_SESSION['LiveViewSearch'][$currentModule]['url'] = $url_string;
		$smarty->assign('SEATCH_INPUT',$input);
	}
}

// 2024-09-11 xxy 消息中心样式修改
crm_load_class_file('cls_RemindsCenter','modules/Reminds');
$remindscenterObj = new cls_RemindsCenter();
// 消息列表左侧增加分类的列
$category_arr = $remindscenterObj->getDataCategory();
$smarty->assign("Category_arr",$category_arr);
$remindscategoryid = 0;
if(isset($_REQUEST['remindscategoryid']) && !empty($_REQUEST['remindscategoryid'])){
	$remindscategoryid = $_REQUEST['remindscategoryid'];
	$_SESSION['lvs'][$currentModule]["remindscategoryid"] = $remindscategoryid;// 记住上次选择的分类
}else{
	$sessionkeys=array('lvs',$currentModule ,'remindscategoryid');
	if(issetSession($sessionkeys) && !empty(getSession($sessionkeys)) && getSession($sessionkeys) != 'undefined'){
		$remindscategoryid = getSession($sessionkeys);
	}else{
		$remindscategoryid = $category_arr[0]['remindscategoryid'];
	}
}
if($remindscategoryid != 0){
	$remindscenterObj->queryGenerator = $queryGenerator;
	$remindscenterObj->addDataCategoryConditions($remindscategoryid);
}
$smarty->assign('selected_remindscategoryid',$remindscategoryid);// 所选分类

$page_list_query=$queryGenerator->getQuery();
$count_result = $adb->query($page_list_query);
    //by ld tifa 20120116 bug 0003154
    if(!empty($count_result))
		$noofrows = $adb->num_rows($count_result);
		//$noofrows=$adb->num_rows($count_result);
    else 
		$noofrows = null;

//ls 2022-06-29 BUG0053291 系统界面右上角消息入口进去：想按照相关模块字段排序，一点击就界面变空白
//list($page_list_query,$order_by,$order)=$queryGenerator->customview->getOrderWhere($page_list_query,'Remindds',$queryGenerator);


    
$list_query = $queryGenerator->getQuery('',2);
$list_query=$list_query." inner join ($page_list_query ) as tmp on tmp.remindsid=ld_reminds.remindsid";

$where = $queryGenerator->getConditionalWhere();
$pagelist=array(array('LBL_UNREADEN','108'),array('LBL_READEN','114'),array('LBL_SENDED','115'));
if($viewid==115){
}
else if($viewid==114){

}else{

    $smarty->assign('ISBOLD', '1');
}
//$list_buttons['mass_del'] = getFixedLabel('CELARALL');
$smarty->assign('PAGELIST',$pagelist);

$NavBar_arr = $customView->getCustomView_RemindsNavBar();
$Navbarlist = [];
$Navbarlistcur = 0;
for($i=0;$i<count($NavBar_arr);$i++){
    $Navbarlist[$i] = array(
        'value' => $NavBar_arr[$i]['cvid'],
        'label' => $NavBar_arr[$i]['viewname'],
		'rawlabel' => $NavBar_arr[$i]['viewname']
    );
	if(!in_array($NavBar_arr[$i]['cvid'],['114','115'])){
		// 获取当前分类当前页签下的条数, 上面获取分类时已经记录了"未读"页签下数量, 加个判断防止重复获取
		if(empty($remindscenterObj->noofrows_arr[$remindscategoryid][$NavBar_arr[$i]['cvid']])){
			$remindscenterObj->getEntireListSql($remindscategoryid,$NavBar_arr[$i]['cvid']);
		}
		$Navbarlist[$i]['num'] = $remindscenterObj->noofrows_arr[$remindscategoryid][$NavBar_arr[$i]['cvid']];
		if($focus->show_customview_num == 'yes'){
			$Navbarlist[$i]['label'] .= '（'.$remindscenterObj->noofrows_arr[$remindscategoryid][$NavBar_arr[$i]['cvid']].'）';
		}
	}
    if($viewid == $NavBar_arr[$i]['cvid']){
        $Navbarlistcur = $i;
    }
}
$smarty->assign('ListViewNavbarcur',$Navbarlistcur);
$smarty->assign('ListViewNavbarlist',json_encode($Navbarlist));
$smarty->assign('show_customview_num',$focus->show_customview_num);
// dump($customView->getCustomView_RemindsNavBar());


if(isset($where) && $where != '') {
	$_SESSION['export_where'] = $where;
} else {
	unset($_SESSION['export_where']);
}


/**
 * 排序的逻辑集中到CRMEntity类中，方便处理
 * @author Tujt 2015-04-23
 */
list($list_query,$order_by,$sorder) = $queryGenerator->customview->getOrderWhere($list_query);

//echo $list_query;

	/**
	 * 新写 mkListCountQuery 方法，替代 mkCounntListQuery
	 * @author Tujt 2014-07-24
	 */
   
   


$fields = $queryGenerator->getFields();
 
$queryMode = (isset($_REQUEST['query']) && $_REQUEST['query'] == 'true');
$start = ListViewSession::getRequestCurrentPage($currentModule, $noofrows, $viewid, $queryMode);

//echo $list_query. "  $limit_start_rec LIMIT $list_max_entries_per_page_new";
crm_load_function_file('VT_getSimpleNavigationValues','include/utils','ListViewUtils');
$navigation_array = VT_getSimpleNavigationValues($start,$list_max_entries_per_page_new,$noofrows);;
$limit_start_rec = ($start-1) * $list_max_entries_per_page_new;
//28382: 审批中心>待处理列表>单据列表：进入单据明细审批单据，最后一步审批通过后。下一页按钮显示为灰色不可点击。应该是可以点击下一页
$tmp_limit_start_rec=$limit_start_rec;
if($limit_start_rec>0)
{
    $tmp_limit_start_rec=$limit_start_rec-1;
}
  $tmp_list_max=$list_max_entries_per_page_new+1;   


$tmp_result=$adb->pquery("$page_list_query limit $tmp_limit_start_rec,$tmp_list_max");
for($i=0;$i<$adb->num_rows($tmp_result);$i++)
{
        $navigationids[]=$adb->query_result($tmp_result,$i,0);

}

$_SESSION['Reminds_reminds_Ids']=$navigationids;

$list_result = $adb->pquery($list_query. " LIMIT $limit_start_rec, $list_max_entries_per_page_new", array());


$recordListRangeMsg = getRecordRangeMessage($list_result, $limit_start_rec,$noofrows);
/**
 * edit:can
 * date:20131212
 * reason:5648: 序时簿全选功能异常：需要选两次，才能出现 全选小页签
 * */
$smarty->assign('recordListRange',$recordListRangeMsg);
$smarty->assign('NUMOFROWS',$noofrows);
$smarty->assign("CUSTOMVIEW_OPTION",$customview_html);

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

if(isset($skipAction)==false){
	$skipAction==false;
}

//得到列头
$listview_header = $controller->getListViewHeader($focus,$currentModule,$url_string,$sorder,$order_by,$skipAction);



$skipAction=false;//edit:can reaosn:12564: 提醒叙事簿界面：序列表中多显示了一列“操作列”-如图，1024*768

$listview_entries = $controller->getListViewEntries($focus,$currentModule,$list_result,$navigation_array,$skipAction);


$listview_header_search = $controller->getBasicSearchFieldInfoList();

//菜单查询和立即查找的数据
$smarty->assign('LISTHEADER', $listview_header);

//合并列
$smarty->assign('LISTHEADERCOUNT', count($listview_header)+1);

$smarty->assign('SEARCHLISTHEADER',$listview_header_search);
$smarty->assign("HEADERNAME",$controller->headername);
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

ListViewSession::setSessionQuery($currentModule,$list_query,$viewid);


$smarty->assign('IS_ADMIN', is_admin($current_user));

//$smarty->assign("ReportPermitt",isPermitted("Reports","index",''));

//中英文包
$languageType= getLanguageType($current_user);
$smarty->assign("LANUGAGETYPE",$languageType);
//获取列表操作列按钮名称总汇，并返回宽度
$operationWidth = $focus->getModuleLogic($currentModule)->getListButtomName();
$smarty->assign('OPERATIONWIDTH',$operationWidth);

$widthinfo=getModuleWidth($focus,$controller->getModuleViewFieldsWidth(),$currentModule);
$smarty->assign('LISTHEADERWIDTH',$widthinfo);
$total_width=$controller->getListTotalWidth($widthinfo,$operationWidth);
$smarty->assign('TOTALWIDTH',$total_width);
$smarty->assign('CHKBOXWIDTH',$controller->listchkbox_width);
$issubmit = 0;
if(isset($startapprovemodule[$currentModule])) $issubmit = 1;
$smarty->assign('APPROVEDISSUBMIT',$issubmit);
Crm_load_class_file("CommonView","modules/CustomView");
$smarty->assign("DATETIMESTR",json_encode(CommonView::stdFilterDateTimeStr()));

setGLobalURLSmarty($smarty);//设置js,css等访问路径
$smarty->assign('DEAILHTML',Inventory::createHTML($listview_entries,$currentModule,0,sizeof($listview_header)+1,$focus->logic->list_buttons,$controller));

// @edit:dong @date:2020/08/19 @reason: 查找 用于区分搜索类型
$smarty->assign('SEARCHTYPE',$_REQUEST['searchtype']);
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

// ljj 2023-08-29 XUQIU1001610 树结构设置和成员管理，左侧分类名称增加计数功能
$cls_MyCRMcryptobj=new cls_MyCRMcrypt();
$smarty->assign("Encrypt_TreeWhere",$cls_MyCRMcryptobj->encode($queryGenerator->getSqlNoTreeWhere($page_list_query)));

//zxm 20230614 获取列表页面公共参数并assign到tpl
ListViewCommonAssign($currentModule,$smarty,$focus);

if(isset($_REQUEST['ajax']) && $_REQUEST['ajax'] != '')
{
    
    $smarty->display("ListViewEntries.tpl");
}
else
{
    $smarty->display('modules/Reminds/ListView.tpl');   
}

?>