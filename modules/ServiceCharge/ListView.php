<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global  $currentModule, $theme;
global $list_max_entries_per_page_new;
global $current_user;

//wym 230605 获取该模块列表最多条数
//wym 231221 XUQIU1002380 列表显示条数可按成员设置不同的条数
$list_max_entries_per_page_new=getUsersettingByLabel($currentModule,$current_user->id,'MaxEntriesPerPageByuser')??getUsersettingByLabel($currentModule,1,'MaxEntriesPerPage');
$list_max_entries_per_page_new=empty($list_max_entries_per_page_new)?'20':$list_max_entries_per_page_new;

$languageType=getLanguageType($current_user);
crm_load_function_file('VT_getSimpleNavigationValues','include/utils','ListViewUtils');
crm_load_class_file("Inventory",'data');
$deployarray=getSys_deploy(325);	//设置服务收费管理序时簿列表界面显示服务合同或联系人 
if(strtolower($deployarray['deploy_value']) == 'contacts'){
	include(globalStatic::$root_directory."modules/ServiceCharge/Concat_ListView.php");
	exit();
}
//$category = getParentTab();
$category = '';
$url_string = '';
//if(isset($tool_buttons)==false) {
	//$tool_buttons = Button_Check($currentModule);
//}
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
/* 列表按钮 begin */
$focus->getModuleLogic($currentModule)->getListViewButtons();

if(isset($_REQUEST['ajaxtype']) && $_REQUEST['ajaxtype'] =='ld_linkmodulecustom'){
    $smarty->assign('LINKMODULECUSTOM', true);
}
if(ListViewSession::hasViewChanged($currentModule,$viewid)) {
	$_SESSION[$currentModule."_Order_By"] = '';
}
$sorder = $focus->getSortOrder();
$order_by = $focus->getOrderBy();

$_SESSION[$currentModule."_Order_By"] = $order_by;
$_SESSION[$currentModule."_Sort_Order"]=$sorder;
/*
By LD Can;
Date:20121225;
reason:增加用户查询范围需求
*/
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

$smarty->assign('MODULE', $currentModule);
$smarty->assign('SINGLE_MOD', getTranstab($currentModule));
$smarty->assign('CATEGORY', $category);
$smarty->assign('CHECK', $tool_buttons);
$smarty->assign('THEME', $theme);
$smarty->assign('IMAGE_PATH', "themes/$theme/images/");

if(isset($_REQUEST["selectedColumnsString2"]))
{
    include("modules/lingdang/ViewOrderEditSave.php");
    
}
//创建分组 编辑 删除 排序
$smarty->assign('GROUPSELECT',$_REQUEST['groupedit']);
// Custom View
$customView =  CustomView::getInstance($currentModule);

$viewid = $customView->getViewId($currentModule);
//获取批量操作时记录数上限
$deployarray=getSys_deploy(67);
$smarty->assign('BATCHNUM',$deployarray['deploy_value']);
$smarty->assign('ISEDIT',isPermitted($currentModule,'EditView',$_REQUEST['record']));
$is_admin=is_admin($current_user);
if($is_admin==true)
    $smarty->assign('ISADMIN','yes');
else
     $smarty->assign('ISADMIN','no');
$smarty->assign("VIEWID", $viewid);
if(isset($_REQUEST['ajaxtype']) && $_REQUEST['ajaxtype'] =='ld_linkmodulecustom'){
    $smarty->assign('LINKMODULECUSTOM', true);
}
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
if($_REQUEST['senioruserid']!="")
{
     $_SESSION['lvs'][$currentModule]['senioruserid']=$_REQUEST['senioruserid'];
}
if($_SESSION['lvs'][$currentModule]['senioruserid']!="")
{
    $smarty->assign("senioruserid",$_SESSION['lvs'][$currentModule]['senioruserid']);
}
/*
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
//序时簿列表页面是否显示本次查询统计图表
//$deployarray=getSys_deploy(137);
//if($deployarray['deploy_value'] == 0){
	$smarty->assign("DashboardPermitt",'yes');
//}
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
Crm_load_class_file("CommonView","modules/CustomView");
$smarty->assign("DATETIMESTR",json_encode(CommonView::stdFilterDateTimeStr()));

$queryGenerator = QueryGenerator::getInstance($currentModule, $current_user,$customView);
/**
 * query_session=1时，读取session中的搜索条件，否则将清空session
 * 查看页面返回列表、列表编辑之后保存 返回列表时，返回query_session=1的参数
 * @project 序时簿查询记住搜索条件
 * @author Tujt 2014-04-25
 */

if((isset($_REQUEST['query_session']) && $_REQUEST['query_session'] == '1' && isset($_SESSION['LiveViewSearch'][$currentModule]))||isset($_REQUEST['groupid'])){
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
//zxm 2021-0506【单据序时簿列表界面，进度漏斗增加穿透功能】 https://www.tapd.cn/63637123/prong/stories/view/1163637123001001609
//因无法使用高级查询 拼接advance_stage条件
$advance_stage =  $_REQUEST['advance_stage'];
$select_stage_value = $_REQUEST['select_stage_value'];//$select_stage_value是推进阶段是级联字段的时候 有上级字段的上级字段的值
addUserSearchConditions_advancestage($queryGenerator,$focus,$advance_stage,$select_stage_value);

$list_query = $queryGenerator->getQuery('',2);
$page_list_query=$queryGenerator->getQuery('',1);


$groupcntsql=$page_list_query;
$where = $queryGenerator->getConditionalWhere();

$ChartFrom=$queryGenerator->getChartFrom();

$ChartFrom=str_replace(' ','//B/',$ChartFrom);
$ChartFrom=str_replace("'","//,/",$ChartFrom);
$ChartFrom=str_replace("%'","//,,/",$ChartFrom);
$ChartFrom=str_replace('"',"//shao/",$ChartFrom);
$smarty->assign('CHARTFROM',$ChartFrom);

$ChartWhere=$queryGenerator->getChartWhere();
$ChartWhere=str_replace(' ','//B/',$ChartWhere);

$ChartWhere=str_replace("'","//,/",$ChartWhere);
//17987: 客户>列表>全部页签、公海已分配、公海未分配页签：查看范围选择高级，勾选人员（该人员无客户）。查看本次统计图表，显示空白。
$ChartWhere=str_replace('>',"//tgt/",$ChartWhere);//>
$ChartWhere=str_replace('<',"//lt/",$ChartWhere);//<
$ChartWhere=str_replace('<=',"//lteq/",$ChartWhere);//<=
//print_r($pagelist);
$ChartOwner=$queryGenerator->getChartOwner();

$ChartOwner=str_replace(' ','//B/',$ChartOwner);
$smarty->assign('CHARTOWNER',$ChartOwner);

$smarty->assign('CHARTWHERE',$ChartWhere);


if(isset($where) && $where != '') {
	$_SESSION['export_where'] = $where;
} else {
	unset($_SESSION['export_where']);
}

list($page_list_query,$order_by,$sorder) = $queryGenerator->customview->getOrderWhere($page_list_query);

$count_sql = $queryGenerator->getQuery("",4);
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
   if($adb->num_rows($count_result)>0)
        $noofrows=$adb->query_result($count_result,0,0);
    else 
        $noofrows = null;


$queryMode = (isset($_REQUEST['query']) && $_REQUEST['query'] == 'true');
$start = ListViewSession::getRequestCurrentPage($currentModule, $noofrows, $viewid, $queryMode);
$navigation_array = VT_getSimpleNavigationValues($start,$list_max_entries_per_page_new,$noofrows);;
$limit_start_rec = ($start-1) * $list_max_entries_per_page_new;
/*if($noofrows>$limit_start_rec+$list_max_entries_per_page_new)
{
    for($i=$limit_start_rec;$i<$limit_start_rec+$list_max_entries_per_page_new;$i++)
    {
        $Page_Ids[]=$adb->query_result($count_result,$i,'accountid');
    }
}
else
{
    for($i=$limit_start_rec;$i<$noofrows;$i++)
    {
        $Page_Ids[]=$adb->query_result($count_result,$i,'accountid');
    }
}*/

$countsql = $list_query;
$customsortorder = $customView->getCustomViewOrderBy($viewid);
$orderby = "ORDER BY $customsortorder $focus->table_name.$focus->table_index desc";



//edit:can 代码优化
//if(sizeof($Page_Ids)>0){
  //  $Page_Ids=implode(',',$Page_Ids);
	$list_query=$list_query." inner join($page_list_query  LIMIT $limit_start_rec, $list_max_entries_per_page_new) as tmp on tmp.accountid=ld_account.accountid ".$queryGenerator->getWhereClause() ;

/*}else{
	$list_query=$list_query.' where  1<>1';
}*/
//duan 20220906 如果客户关联了服务合同，则合同选择筛选后的最新的合同
if($queryGenerator->with_serviceinfo == 'yes'){
    $list_query .= ' and (ifnull(ld_servicecontracts.servicecontractsid,0)=0 or ld_servicecontracts.servicecontractsid = serviceinfo.servicecontractsid) ';
}

$list_query.=$queryGenerator->getGroupBy();
list($list_query,$order_by,$sorder) = $queryGenerator->customview->getOrderWhere($list_query);

 $list_query.=$queryGenerator->getOrderByClause();

if(empty($page_list_query))
    $list_query=$list_query."  limit $limit_start_rec,$list_max_entries_per_page_new ";

$list_result = $adb->pquery($list_query );

//edit:can 目前先这样优化
if($noofrows-$list_max_entries_per_page_new-$limit_start_rec>0)
    $recordListRangeMsg = getRecordRangeMessageForServieCharge($list_max_entries_per_page_new, $limit_start_rec,$noofrows);
else
    $recordListRangeMsg = getRecordRangeMessageForServieCharge($noofrows-$limit_start_rec, $limit_start_rec,$noofrows);

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

crm_load_class_file('ProductDetail_ListController','include/ListView/ProductDetail');
$controller = new ProductDetail_ListController($adb, $current_user, $queryGenerator);

if(isset($skipAction)==false){
	$skipAction==false;
}
//得到列头
$listview_header = $controller->getListViewHeader($focus,$currentModule,$url_string,$sorder,$order_by,$skipAction);
$listview_entries = $controller->getListViewEntries($focus,$currentModule,$list_result,$navigation_array,$skipAction);


/**
 * @project PROT26 序时簿增加合计项
 * @author Tujt 2014-06-05
 */
 crm_load_class_file('cls_servicecharge_totalList','modules/ServiceCharge');
 $clstotalobj=new cls_servicecharge_totalList($controller);
$totalfldhtml = $clstotalobj->getTotalFldCount($page_list_query." LIMIT $limit_start_rec, $list_max_entries_per_page_new ",$list_result,$noofrows);
$smarty->assign('TOTALFLDHTML',$totalfldhtml);
//基本查找
$listview_header_search = $queryGenerator->productDetails->getListViewHeaderSearch();
$headerinfo=$queryGenerator->productDetails->getListViewHeaderInfo();

$smarty->assign('HEADERNAME',$headerinfo['fieldname']);
$smarty->assign('HEADERMODULE',$headerinfo['module']);
//菜单查询和立即查找的数据
if(isPermitted('ContactRecords',"Create","") == 'yes' && vtlib_isModuleActive('ContactRecords'))
    $smarty->assign('CREATECONTRACTRECORDS', 'yes');
$smarty->assign('LISTHEADER', $listview_header);
$smarty->assign('LISTHEADERWIDTH',getModuleWidth($focus,$controller->getModuleViewFieldsWidth(),$currentModule));
//合并列
$smarty->assign('LISTHEADERCOUNT', count($listview_header)+1);
$row_count=$queryGenerator->getMainColumnCount();
$row_header = count($listview_header)+1;
$smarty->assign('PROHTML',Inventory::createModWithDetailhtml($listview_entries,$row_count,$row_header,$LIST_NOCHECKBOX,"",$controller));
$smarty->assign('SEARCHLISTHEADER',$listview_header_search);
$smarty->assign('ROW_COUNT',$row_count );
// Module Search//拼音查找
$alphabetical = AlphabeticalSearch($currentModule,'index',$focus->def_basicsearch_col,'true','basic','','','','',$viewid);
$fieldnames = $controller->getAdvancedSearchOptionString();
//$criteria = getcriteria_options();
$version_info = getVersionInfo();
$smarty->assign('VERSION_ACCOUNT',$version_info['account']);
$smarty->assign("ALPHABETICAL", $alphabetical);
$smarty->assign("FIELDNAMES", $fieldnames);
$smarty->assign("CRITERIA", $criteria);


//0023310: 客户列表>本次查询统计表：显示了多个分布统计,分布统计图表中的字段隐藏时，对应的统计图不显示
if(array_key_exists('leadsource',$focus->column_fields))
{
    $smarty->assign("CHART_LEADSOURCE",'yes');
}
if(array_key_exists('accounttype',$focus->column_fields))
{
    $smarty->assign("CHART_ACCOUNTTYPE",'yes');
}
if(array_key_exists('rating',$focus->column_fields))
{
    $smarty->assign("CHART_RATING",'yes');
}
if(array_key_exists('accounttype',$focus->column_fields) && array_key_exists('rating',$focus->column_fields))
{
    $smarty->assign("CHART_ACCOUNTTYPE_RATING",'yes');
}
if(array_key_exists('industry',$focus->column_fields))
{
    $smarty->assign("CHART_INDUSTRY",'yes');
}
if(array_key_exists('accountsize',$focus->column_fields))
{
    $smarty->assign("CHART_ACCOUNTSIZE",'yes');
}
if(array_key_exists('accountproperty',$focus->column_fields))
{
    $smarty->assign("CHART_ACCOUNTPROPERTY",'yes');
}
if(array_key_exists('important_level',$focus->column_fields))
{
  
    $smarty->assign("CHART_IMPORTTANT_LEVEL",'yes');
}

if(array_key_exists('accountrelationship',$focus->column_fields))
{
    $smarty->assign("CHART_ACCOUNTRELATIONSHIP",'yes');
}
if(array_key_exists('registeredcapital',$focus->column_fields))
{
    $smarty->assign("CHART_REGISTERREDCAPITAL",'yes');
}
 
if(array_key_exists('annualincome',$focus->column_fields))
{
    $smarty->assign("CHART_ANNUALINCOME",'yes');
}
if(array_key_exists('bill_state',$focus->column_fields))
{
    $smarty->assign("CHART_BILL_STATE",'yes');
}
if(array_key_exists('bill_city',$focus->column_fields))
{
    $smarty->assign("CHART_BILL_CITY",'yes');
}

//单据推进管理 - 推进漏斗
/*crm_load_class_file('cls_module_advance','modules/Settings');
$cls_module_advance = new cls_module_advance($currentModule);
$smarty->assign('MODULEADVANCESTAGESTATUS',$cls_module_advance->is_Enable());*/
//Added to select Multiple records in multiple pages
$smarty->assign("SELECTEDIDS", vtlib_purify($_REQUEST['selobjs']));
$smarty->assign("ALLSELECTEDIDS", vtlib_purify($_REQUEST['allselobjs']));

ListViewSession::setSessionQuery($currentModule,$page_list_query,$viewid);
$smarty->assign('IS_ADMIN', is_admin($current_user));
//add by tifa 20130221 for reminds
//$CASHBILLCREATE
//中英文包
if(empty($languageType))
{
    $languageType = 'zh';
}
$smarty->assign("LANUGAGETYPE",$languageType);
/**
 * 每列宽度的信息
 * edit:can 20200720
 * */
$smarty->assign("FieldWidthSetting",ldcrm_json_encode($controller->getModuleViewFieldsWidth()));

//获取列表操作列按钮名称总汇，并返回宽度
$operationWidth = $focus->getModuleLogic($currentModule)->getListButtomName();
$smarty->assign('OPERATIONWIDTH',$operationWidth);
$widthinfo=getModuleWidth($focus,$controller->getModuleViewFieldsWidth(),$currentModule);
$smarty->assign('LISTHEADERWIDTH',$widthinfo);
$total_width=$controller->getListTotalWidth($widthinfo,$operationWidth);
$smarty->assign('TOTALWIDTH',$total_width);
$smarty->assign('CHKBOXWIDTH',$controller->listchkbox_width);
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

setGLobalURLSmarty($smarty);//设置js,css等访问路径
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
   
    //$smarty->display("servicechargeleft.tpl");
}
else
{
    $smarty->display('ListView.tpl');
}
?>