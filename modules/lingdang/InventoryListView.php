
<?php
/**
 * edit:can
 * reason:发票，出入库列表界面(带产品明细的模块)
 * */
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global  $currentModule, $theme;
global $list_max_entries_per_page_new;
global $current_user,$adb;

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

crm_load_function_file('VT_getSimpleNavigationValues','include/utils','ListViewUtils');
crm_load_class_file('Inventory','data');
//$category = getParentTab();
$category = '';
$warehouseid = 0;
$url_string = '';
$stockquery = '';
$smarty = new lingdangCRM_Smarty();
//if(isset($tool_buttons)==false) {
	//$tool_buttons = Button_Check($currentModule);
//}

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

// @edit:dong @date:2020/10/28 @reason: 数据分类设置为自定义链接模块
if(isset($_REQUEST['ajaxtype']) && $_REQUEST['ajaxtype'] =='ld_linkmodulecustom'){
    $smarty->assign('LINKMODULECUSTOM', true);
}

$customView = CustomView::getInstance($currentModule);

$viewid = $customView->getViewId($currentModule);


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
//}
// END
//获取批量操作时记录数上限
$deployarray=getSys_deploy(67);
$smarty->assign('BATCHNUM',$deployarray['deploy_value']);
//序时簿列表页面是否显示本次查询统计图表
$arr_module = array('ContactRecords','Campaigns','Potentials');
if( in_array($currentModule,$arr_module)){
//    $deployarray=getSys_deploy(137);
//    if($deployarray['deploy_value'] == 0){
        $smarty->assign("DashboardPermitt",'yes');
//    }
    if($currentModule=='ContactRecords')
    {
        if(array_key_exists('contactrecordtype',$focus->column_fields))
        {
            $smarty->assign("CHART_CONTACTRECORDTYPE",'yes');
        }
        if(array_key_exists('account_id',$focus->column_fields))
        {
            $smarty->assign("CHART_CONTANCTRECORD_ACCOUNT",'yes');
        }
    }
}
//销售机会本次查询统计图表字段权限
if($currentModule == 'Potentials'){
    if(array_key_exists('potentialtype',$focus->column_fields))
    {
        $smarty->assign("CHART_POTENTIALTYPE",'yes');
    }
    if(array_key_exists('leadsource',$focus->column_fields))
    {
        $smarty->assign("CHART_POTENTIAL_LEADSOURCE",'yes');
    }
    if(array_key_exists('possibility',$focus->column_fields))
    {
        $smarty->assign("CHART_POTENTIAL_POSSIBILITY",'yes');
    }
    if(array_key_exists('sales_stage',$focus->column_fields))
    {
        $smarty->assign("CHART_POTENTIAL_SALES_STAGE",'yes');
    }
    if(array_key_exists('createdtime',$focus->column_fields))
    {
        $smarty->assign("CHART_POTENTIAL_CREATEDTIME",'yes');
    }
    if(array_key_exists('closingdate',$focus->column_fields))
    {
        $smarty->assign("CHART_POTENTIAL_CLOSINGDATE",'yes');
    }

    //wyt XUQIU1000540 销售机会增加“列表视图”和“看板视图”图标按钮（熊少波） BUG0065603 kfbcrm -销售机会界面，没有列表视图 看板视图图标按钮
    $iskanbanshow='no';
    $advshowSQL="select enable,method,module_field from ld_settings_advance where module=?";
    $advresult = $adb->pquery($advshowSQL,array($currentModule));
    if($adb->num_rows($advresult)>0){
        $advshow = $adb->query_result($advresult,0,"enable");
        $method = $adb->query_result($advresult,0,"method");
        $module_field = $adb->query_result($advresult,0,"module_field");
        if (array_key_exists($module_field,$focus->column_fields) && $method == 'field' && $advshow == 'yes'){
            $smarty->assign('SHOWKANBAN',$advshow);
            $smarty->assign('SHOWKANBANVALUE',$advshow);
            $iskanbanshow = 'yes';
        }
        //记住用户最新一次操作(数据库记录)
        if (!isset($_REQUEST['viewmode'])){
            $viewmode = getUsersettingByLabel($currentModule,$current_user->id,'VIEWMODE');
            if ($viewmode == 'kanban'){
                if ($method =='field' && $advshow == 'yes'){
                    $viewmode = 'kanban';
                }else{
                    $viewmode = 'listview';

                }
            }
            if (empty($viewmode)){
                $viewmode = 'listview';
            }else{
                $viewmode = $viewmode;
            }
        }else{
            $viewmode = $_REQUEST['viewmode'];
        }
        $smarty->assign('VIEWMODE',$viewmode);
        setUsersettingByLabel($currentModule,$current_user->id,'VIEWMODE', $viewmode);
    }
}
/*
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
$url_string = '';
if($_REQUEST['query'] == 'true') {
	$_REQUEST['searchtype'] = trim($_REQUEST['searchtype']??'');
	$queryGenerator->addUserSearchConditions($_REQUEST);
	/**
	 * query=true时 把搜索参数存入session中
	 * @project 序时簿查询记住搜索条件
	 * @author Tujt 2014-04-25
	 */
	if($_REQUEST['searchtype'] == 'BasicSearch'){
		$_REQUEST['search_text'] = trim($_REQUEST['search_text']??'');
		$searcharr = explode(':',$_REQUEST['search_field']);
		if(!empty($_REQUEST['search_text']) || (empty($_REQUEST['search_text']) && 'D' == $searcharr[count($searcharr)-1])){
			$input['search_field'] = trim($_REQUEST['search_field']??'');
			$input['search_text'] = trim($_REQUEST['search_text']??'');
			$input['SearchScope'] = trim($_REQUEST['SearchScope']??'');
			$input['searchtype'] = trim($_REQUEST['searchtype']??'');
			$input['type'] = trim($_REQUEST['type']??'');
		}else{
			unset($_SESSION['LiveViewSearch'][$currentModule]);
		}
        // zkt 2021/12/27 平铺搜索 优化（批量操作按钮）-批量导出
	}else if($_REQUEST['searchtype'] == 'advance'|| $_REQUEST['searchtype'] == 'tiled'){
		$_REQUEST['advft_criteria'] = trim($_REQUEST['advft_criteria']??'');
		if(!empty($_REQUEST['advft_criteria']) && $_REQUEST['advft_criteria'] != '[]'){
			$input['advft_criteria'] = $_REQUEST['advft_criteria'];
			$input['advft_criteria_groups'] = trim($_REQUEST['advft_criteria_groups']??'');
			$input['SearchScope'] = trim($_REQUEST['SearchScope']??'');
			$input['searchtype'] = trim($_REQUEST['searchtype']??'');
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
// zxm 2021-0506【单据序时簿列表界面，进度漏斗增加穿透功能】
// zxm 20231007 修改 调用高级查找
$advance_stage =  $_REQUEST['advance_stage'];
$select_stage_value = $_REQUEST['select_stage_value'];//$select_stage_value是推进阶段是级联字段的时候 有上级字段的上级字段的值
addUserSearchConditions_advancestage($queryGenerator,$focus,$advance_stage,$select_stage_value);

$list_query = $queryGenerator->getQuery('',2);
$page_list_query=$queryGenerator->getQuery('','groupby');

ListViewSession::setSessionQuery($currentModule,$page_list_query,$viewid);


if(isset($_REQUEST['wareid']) && $_REQUEST['wareid'] != '' && $_REQUEST['wareid'] > 0)
{
    $warehouseid = $_REQUEST['wareid'];
}
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


//$smarty->assign('BUTTONS', $list_buttons);

if(isset($where) && $where != '') {
	$_SESSION['export_where'] = $where;
} else {
	unset($_SESSION['export_where']);
}

$count_sql = $queryGenerator->getQueryRow_Count('','groupby');
//zxm 2021-0506【单据序时簿列表界面，进度漏斗增加穿透功能】 https://www.tapd.cn/63637123/prong/stories/view/1163637123001001609
//因无法使用高级查询 拼接advance_stage条件
$fromtype = $_REQUEST['fromtype'];
$LIST_NOCHECKBOX = 'yes';
if($fromtype=='salesfunnel'){
    $LIST_NOCHECKBOX = 'no';
    $smarty->assign('LIST_NOCHECKBOX',$LIST_NOCHECKBOX);
    $smarty->assign('fromtype',$fromtype);
}

// 	@edit:liushuai,2020-07-17,reason:0042209: （61mis.com/kfbcrm）出库单、入库单列表界面：页面底部“合计”没有显示出来。
//if(PerformancePrefs::getBoolean('LISTVIEW_COMPUTE_PAGE_COUNT', false) === true) {
     $count_result = $adb->query($count_sql);
    if(!empty($count_result))
    	$noofrows = $adb->query_result($count_result,0,0);
        
    else 
    	$noofrows = null;
//}else {
//	$noofrows = null;
//}


$queryMode = (isset($_REQUEST['query']) && $_REQUEST['query'] == 'true');
$start = ListViewSession::getRequestCurrentPage($currentModule, $noofrows, $viewid, $queryMode);
$navigation_array = VT_getSimpleNavigationValues($start,$list_max_entries_per_page_new,$noofrows);;
$limit_start_rec = ($start-1) * $list_max_entries_per_page_new;
//分类默认排序设置
//$customsortorder = $customView->getCustomViewOrderBy($viewid);
//$orderby = "  ORDER BY $customsortorder $focus->table_name.$focus->table_index desc";


$countsql = $page_list_query;

/**
 * 排序的逻辑集中到CRMEntity类中，方便处理
 * @author Tujt 2015-04-23
 */
list($page_list_query,$order_by,$sorder) = $queryGenerator->customview->getOrderWhere($page_list_query);

$list_query=$list_query." inner join ( $page_list_query  limit $limit_start_rec,$list_max_entries_per_page_new ) as temp on temp.$focus->table_index=$focus->table_name.$focus->table_index";

$list_query=$list_query.$cosler;

//$countsql .= $queryGenerator->getWhereClause();

/**
 * 排序的逻辑集中到CRMEntity类中，方便处理
 * @author Tujt 2015-04-23
 */
 //18866: 采购订单>序列表>高级查询：基本信息里的【合同订单】按条件“为空值”、“不为空值”查找不到数据。
 //一定要在最终的sql语句后添加where条件
$list_query.= $queryGenerator->getWhereClause();
list($list_query,$order_by,$sorder) = $queryGenerator->customview->getOrderWhere($list_query,'',$queryGenerator);
//echo $list_query;
$list_result = $adb->pquery($list_query );
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
crm_load_class_file('clsTotal_List','include/ListView');
$clstotalobj=new clsTotal_List($controller);
$totalfldhtml = $clstotalobj->getTotalFldCount($page_list_query." LIMIT $limit_start_rec, $list_max_entries_per_page_new ",$list_result,$noofrows);
$smarty->assign('TOTALFLDHTML',$totalfldhtml);
//基本查找
$listview_header_search = $queryGenerator->productDetails->getListViewBasicSearch();
$productsFields = $queryGenerator->productDetails->getModuleFields();
//基本查找：明细过滤源单和源单的合同信息
foreach($listview_header_search as $column_str => $fieldlabel){
	$columns = explode(':',$column_str);
	$columnname = $columns[1];
	$field = $productsFields[$columnname];
	if(!empty($field)){
		$uitype = $field->getUIType();
        //不显示：源单（200、201、202）、选择源单202、合同信息205
        //if($uitype == 200 || $uitype == 201 || $uitype == 202 || $uitype == 205){
		if( $uitype == 205){//不显示合同信息
			unset($listview_header_search[$column_str]);
		}
	}
	//中能特殊控制 - 明细库存数量不显示
	if(strpos($column_str,'zhongneng_ware_qty') !== false){
		unset($listview_header_search[$column_str]);
	}
}
$headerinfo=$queryGenerator->productDetails->getListViewHeaderInfo();
$smarty->assign('HEADERNAME',$headerinfo['fieldname']);
$smarty->assign('HEADERMODULE',$headerinfo['module']);
//菜单查询和立即查找的数据
$smarty->assign('LISTHEADER', $listview_header);
//单据推进管理 - 推进漏斗
/*crm_load_class_file('cls_module_advance','modules/Settings');
$cls_module_advance = new cls_module_advance($currentModule);
$smarty->assign('MODULEADVANCESTAGESTATUS',$cls_module_advance->is_Enable());*/
//合并列
$smarty->assign('LISTHEADERCOUNT', count($listview_header)+1);
//$smarty->assign('LISTENTITY', $listview_entries);
$row_count=$queryGenerator->getMainColumnCount();
$row_header = count($listview_header)+1;
$smarty->assign('PROHTML',Inventory::createModWithDetailhtml($listview_entries,$row_count,$row_header,$LIST_NOCHECKBOX,"",$controller));
$smarty->assign('SEARCHLISTHEADER',$listview_header_search);
$smarty->assign('ROW_COUNT', $row_count);
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


// ljj 2023-08-29 XUQIU1001610 树结构设置和成员管理，左侧分类名称增加计数功能
$cls_MyCRMcryptobj=new cls_MyCRMcrypt();
$smarty->assign("Encrypt_TreeWhere",$cls_MyCRMcryptobj->encode($queryGenerator->getSqlNoTreeWhere($page_list_query)));

//销售机会序时簿 - 客户漏斗
if($currentModule == 'Potentials'){
	$smarty->assign('CUSTOMERFUNNEL',$focus->getCustomerFunnelForPresence($focus));
    if($viewmode=='kanban' && $iskanbanshow == 'yes'){//wyt 230516 BUG0066420 商机项目---看板视图按钮点不动
        //单据推进管理 - 推进漏斗
        crm_load_class_file('cls_module_advance','modules/Settings');
        $cls_module_advance_obj =  cls_module_advance::getInstance($focus->module_name);
        $smarty->assign('MODULEADVANCESTAGESTATUS',$cls_module_advance_obj->is_Enable());
        crm_load_class_file('cls_KanBan','modules/lingdang');
        $Kanbanobj = cls_KanBan::getInstance($currentModule);
        $kanbanView=$Kanbanobj->getKanBanViewList($_REQUEST['pageleftwidth'],$_REQUEST['pagetopheight']);
        $smarty->assign('TMPKANBAN',$kanbanView);
        if (isset($_REQUEST['kanbanajax'])){
            $inactive_userinfo=get_user_array(FALSE, "Inactive", "");
            $inactive_userid=array_keys($inactive_userinfo);
            $smarty->assign("inactiveuser",$inactive_userid);
            $smarty->assign("inactiveuser_arr",json_encode($inactive_userid));
            if ($_REQUEST['kanbanajax'] == 'true' ){
                ConvertTojsonString(1, $kanbanView, "success");
            }else{
                $kanbanhtml=$smarty->fetch('Smarty/templates/KanbanView.tpl');
                ConvertTojsonString(1, $kanbanhtml, "success");
            }
        }
    }
}

/*
edit:chj
date:2013-11-14
reson:入库单仓库检索
*/
if($module == 'Stock' || $module == 'OutboundOrder' || $module == 'InventoryAccount' || $module == 'InventoryQuery' || $module == 'Checks')
{	
    crm_load_function_file('selWareAll','include/Stock','CommonStock');
    $result=selWareAll();//获取所有仓库
    
    $num_rows=$adb->num_rows($result);
    if($num_rows<=0)
        ConvertTojsonString(-1,[],getFixedLabel('INSUFFICIENTWAREHOUSE'));
    $warehouses=array();
    for($i=0;$i<$num_rows;$i++){
        $warehouses[]=array(
        'id'=>$adb->query_result($result,$i,'id'),
        'name'=>$adb->query_result($result,$i,'name'),
        'label'=>$adb->query_result($result,$i,'name'),
       // 'type'=>getpower($current_user->id,$adb->query_result($result,$i,'id'),1)
        );
    }
    array_unshift($warehouses,array(
        'id'=>0,
        'name'=>getFixedLabel('ALLWAREHOUSE'),
        'label'=>getFixedLabel('ALLWAREHOUSE')
    ));
    /*if(count($warehouses)>5){
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
    }*/
    //hzx 20231215 列表页面页签优化
    $smarty->assign('WAREHOUSEID',$warehouseid);
    $ListViewNavbarcur = 0;
    for($i = 0;$i<count($warehouses);$i++){
        if($warehouseid == $warehouses[$i]['id']){
            $ListViewNavbarcur = $i;
        }
    }
    $smarty->assign('ListViewNavbarcur',$ListViewNavbarcur);
    $smarty->assign('ListViewNavbarlist',json_encode($warehouses));
}
$smarty->assign('IS_ADMIN', is_admin($current_user));
//add by tifa 20130221 for reminds
//$CASHBILLCREATE
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

//中英文包
$languageType= getLanguageType($current_user);
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
$smarty->assign("CHKBOXWIDTH",$controller->listchkbox_width);
setGLobalURLSmarty($smarty);//设置js,css等访问路径
$fields=$focus->fieldobj->getListViewFields();
$smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));
$smarty->assign('MODULEBILLNOTIP',$_SESSION[$currentModule.'_modulebillnotip']);
$_SESSION[$currentModule.'_modulebillnotip']='no';
$smarty->assign("HaigeSaveTip",$_SESSION[$currentModule.'haigesavetip']);
$_SESSION[$currentModule.'haigesavetip']='';
// @edit:dong @date:2020/08/19 @reason: 查找 用于区分搜索类型
$smarty->assign('SEARCHTYPE',$_REQUEST['searchtype']);
//zkt 2021/12/27 用于区分是否为销售漏斗
if(isset($_REQUEST['fromtype'])&&$_REQUEST['fromtype']=='salesfunnel'){
    $smarty->assign('ISSALESFUNNEL','yes');
}
//zkt 2021/12/27 用于区分是否显示平铺搜索界面
if(isset($_REQUEST['tiledSearchdisplay'])&&$_REQUEST['tiledSearchdisplay']=='none'&&$_REQUEST['searchtype']=='tiled'){
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

//xll 20221214 获取最近一次的基本搜索框字段选项
$controller->getFieldStorage($smarty);

//zxm 20230614 获取列表页面公共参数并assign到tpl
ListViewCommonAssign($currentModule,$smarty,$focus);



if(isset($_REQUEST['ajax']) && $_REQUEST['ajax'] != '')
{
   if(get_file_address($currentModule,'ProductDetails'))
        $smarty->display("ProductListViewEntries.tpl");
    else
        $smarty->display("ListViewEntries.tpl");
}
else
{
    $smarty->display('ListView.tpl');
}

unset($app_strings);
unset($mod_strings);
unset($currentModule) ;
unset($theme) ;
unset ($list_max_entries_per_page_new);
?>