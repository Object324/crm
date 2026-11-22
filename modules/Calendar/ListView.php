<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $app_strings, $mod_strings, $adb;
global $current_user;
require(globalStatic::$root_directory.'user_privileges/user_language_'.$current_user->id.'.php');
global $currentModule, $theme;
global $list_max_entries_per_page_new;

//wym 230605 获取该模块列表最多条数
//wym 231221 XUQIU1002380 列表显示条数可按成员设置不同的条数
$list_max_entries_per_page_new=getUsersettingByLabel($currentModule,$current_user->id,'MaxEntriesPerPageByuser')??getUsersettingByLabel($currentModule,1,'MaxEntriesPerPage');
$list_max_entries_per_page_new=empty($list_max_entries_per_page_new)?'20':$list_max_entries_per_page_new;

crm_load_function_file('VT_getSimpleNavigationValues','include/utils','ListViewUtils');
crm_load_class_file('Inventory','data');
$smarty = new lingdangCRM_Smarty();
$warehouseid = 0;$url_string = '';$stockquery = '';
$focus = CRMEntity::getInstance($currentModule);

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

/* 列表按钮 begin */
$focus->getModuleLogic($currentModule)->getListViewButtons();

//$list_buttons=$focus->getListButtons($app_strings,$mod_strings);
/*
 * edit:yangliu
 * date:2014-07-29
 * reason:列表界面更多按钮权限判断
 */
//$list_buttons_moreL=$focus->getListButtons_moreforL($app_strings,$mod_strings);
 
if(ListViewSession::hasViewChanged($currentModule,$viewid)) {
	$_SESSION[$currentModule."_Order_By"] = '';
}
/*
By LD Can;
Date:20121225;
reason:增加用户查询范围需求

*/
$MergeSmowner=getCurSmOwnerSearchScope($currentModule);
unset($MergeSmowner["UserCombo"][$current_user->id]);//去除当前用户


if(isset($_REQUEST['ajaxtype']) && $_REQUEST['ajaxtype'] =='ld_linkmodulecustom'){
    $smarty->assign('LINKMODULECUSTOM', true);
}
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
$smarty->assign("VIEWID", $viewid);
$_REQUEST['calendar_viewid']=$viewid;

//视图hTML
$customview_html = $customView->getCustomViewAll($viewid,$currentModule,$category);
//@edit zsk 2024/06/11 XUQIU20240516-01 查询分类功能优化
//获取查询分类分组列表
$groupList=$customView->getCustomViewGroupList($customview_html);
$smarty->assign("CUSTOMVIEWGROUPLIST",$groupList);
//前五个数据分类
//$customview_html_before = $customView->getCustomViewCombo2Before($viewid,$module,$category);

//$edit_permit = $customView->isPermittedCustomView($viewid,'Create',$currentModule);
//$delete_permit = $customView->isPermittedCustomView($viewid,'Delete',$currentModule);
//$smarty->assign("CV_EDIT_PERMIT",$edit_permit);
//$smarty->assign("CV_DELETE_PERMIT",$delete_permit); 

Crm_load_class_file("CommonView","modules/CustomView");
$smarty->assign("DATETIMESTR",json_encode(CommonView::stdFilterDateTimeStr()));

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
    //XUQIU20240722-05 悦锦-日程管理查看范围页签需求 日程管理查看范围默认'我的'
    $SearchScope="SmOwner_Search_MeAndShareMe";
    $_SESSION['lvs'][$currentModule]['SearchScope']=$SearchScope;
    $smarty->assign('SelectedOwner2',"SmOwner_Search_MeAndShareMe");
}
$viewname = $customView->getViewNameDetail($viewid);
if($viewname == 'All'){
    $viewname = getFixedLabel('ALL');
}
$smarty->assign("VIEWNAME", $viewname);
$smarty->assign('ALL', $customView->getViewNameDetail($viewid));
if($viewid ==0 ) {
    echo "  <div style='width: 30%;overflow: hidden;border-radius: 20px;box-shadow: 0px 2px 12px 3px rgb(0 0 0 / 20%);position: relative;top: 200px;left:34%;'>
                <div style='overflow: hidden;padding: 20px 50px;display: flex;'>
                    <div style='float:left;width: 100px;'>
                        <img style='width: 100px;' src='". lingdang_imageurl('nopermission.jpg', $theme) ."' >
                    </div>
                    <div style='float: left;margin-left: 32px;line-height: 40px;'>
                        <div style='padding-top: 10px;color:#2d82f4;font-size: 18px;font-weight:bold;'>".getFixedLabel('WARMPROMPT')."</div>
                        <div style='line-height: 30px;'>".getFixedLabel('NOPERMITTEDEXECUTE')."</div>
                    </div>
                </div>
            </div>
        ";
	exit;
}

$queryGenerator = new QueryGenerator($currentModule, $current_user,$customView);
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
	}else if($input['searchtype'] == 'advance' || $_REQUEST['searchtype'] == 'tiled'){
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
//获取批量操作时记录数上限
$deployarray=getSys_deploy(67);
$smarty->assign('BATCHNUM',$deployarray['deploy_value']);
$smarty->assign("LISTPAGEURL", getlisturl_aftersave());
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
	}else if($_REQUEST['searchtype'] == 'advance' || $_REQUEST['searchtype'] == 'tiled'){
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
// zxm 2021-0506【单据序时簿列表界面，进度漏斗增加穿透功能】
// zxm 20231007 修改 调用高级查找
$advance_stage =  $_REQUEST['advance_stage'];
$select_stage_value = $_REQUEST['select_stage_value'];//$select_stage_value是推进阶段是级联字段的时候 有上级字段的上级字段的值
addUserSearchConditions_advancestage($queryGenerator,$focus,$advance_stage,$select_stage_value);

$page_list_query = $queryGenerator->getQuery();
$list_query = $queryGenerator->getQuery('',2);

crm_load_class_file('cls_MyCRMcrypt',"Register");

$cls_MyCRMcryptobj=new cls_MyCRMcrypt();
$smarty->assign("Encrypt_page_list_query",$cls_MyCRMcryptobj->encode($page_list_query));


$ChartFrom=str_replace(' ','//B/',$queryGenerator->getChartFrom());
$ChartFrom=str_replace("'","//,/",$ChartFrom);
$ChartFrom=str_replace("%'","//,,/",$ChartFrom);

$ChartWhere=str_replace(' ','//B/',$queryGenerator->getChartWhere());
$ChartWhere=str_replace("'","//,/",$ChartWhere);
$ChartWhere=str_replace("<>","//!=/",$ChartWhere);
$ChartOwner=str_replace(' ','//B/',$queryGenerator->getChartOwner());
$smarty->assign('CHARTFROM',$ChartFrom);
$smarty->assign('CHARTWHERE',$ChartWhere);
$smarty->assign('CHARTOWNER',$ChartOwner);

$where = $queryGenerator->getConditionalWhere();

//zxm 2021-0506【单据序时簿列表界面，进度漏斗增加穿透功能】 https://www.tapd.cn/63637123/prong/stories/view/1163637123001001609
//因无法使用高级查询 拼接advance_stage条件
$fromtype = $_REQUEST['fromtype'];
$LIST_NOCHECKBOX = 'yes';
if($fromtype=='salesfunnel'){
    $LIST_NOCHECKBOX = 'no';
    $smarty->assign('LIST_NOCHECKBOX',$LIST_NOCHECKBOX);
    $smarty->assign('fromtype',$fromtype);
}
/**
	 * 新写 mkListCountQuery 方法，替代 mkCounntListQuery
	 * @author Tujt 2014-07-24
	 */
    $count_result = $adb->query( $page_list_query);
    //by ld tifa 20120116 bug 0003154
    if(!empty($count_result))
		$noofrows = $adb->num_rows($count_result);
		//$noofrows=$adb->num_rows($count_result);
    else 
		$noofrows = null;




$queryMode = (isset($_REQUEST['query']) && $_REQUEST['query'] == 'true');
$start = ListViewSession::getRequestCurrentPage($currentModule, $noofrows, $viewid, $queryMode);
list($page_list_query,$order_by,$sorder)=$queryGenerator->customview->getOrderWhere($page_list_query);
$navigation_array = VT_getSimpleNavigationValues($start,$list_max_entries_per_page_new,$noofrows);;
$limit_start_rec = ($start-1) * $list_max_entries_per_page_new;
$list_query.=' inner join  ('.$page_list_query." LIMIT $limit_start_rec, $list_max_entries_per_page_new" .' ) as tmp 
 on tmp.activityid=ld_activity.activityid ';
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

$controller = new ListViewController($adb, $current_user, $queryGenerator);

if(isset($skipAction)==false){
	$skipAction==false;
}
$old_order_by=$order_by;
//得到列头
$listview_header = $controller->getListViewHeader($focus,$currentModule,$url_string,$sorder,$old_order_by,$skipAction);

$listview_entries = $controller->getListViewEntries($focus,$currentModule,$list_result,$navigation_array,$skipAction);

/**
 * @project PROT26 序时簿增加合计项
 * @author Tujt 2014-06-05
 */
 crm_load_class_file('clsTotal_List','include/ListView');
 $totalobj=new clsTotal_List($controller);
 
$totalfldhtml = $totalobj->getTotalFldCount($page_list_query." LIMIT $limit_start_rec, $list_max_entries_per_page_new ",$list_result,$noofrows);
$smarty->assign('TOTALFLDHTML',$totalfldhtml);

$listview_header_search = $controller->getBasicSearchFieldInfoList();

$smarty->assign('SEARCHLISTHEADER',$listview_header_search);
$smarty->assign("HEADERNAME",$controller->headername);


//菜单查询和立即查找的数据
$smarty->assign('LISTHEADER', $listview_header);

$smarty->assign('LISTENTITY', $listview_entries);
//合并列
$smarty->assign('LISTHEADERCOUNT', count($listview_header)+1);
//单据推进管理 - 推进漏斗
/*crm_load_class_file('cls_module_advance','modules/Settings');
$cls_module_advance = new cls_module_advance($currentModule);
$smarty->assign('MODULEADVANCESTAGESTATUS',$cls_module_advance->is_Enable());*/
// Module Search//拼音查找
//$alphabetical = AlphabeticalSearch($currentModule,'index',$focus->def_basicsearch_col,'true','basic','','','','',$viewid);
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
//zxm 20221227 统计图表一直显示
$smarty->assign("DashboardPermitt",'yes');

//中英文包
require(globalStatic::$root_directory."user_privileges/user_language_".$current_user->id.'.php');
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
$widthinfo=getModuleWidth($focus,$controller->getModuleViewFieldsWidth(),$currentModule);
$smarty->assign('LISTHEADERWIDTH',$widthinfo);
$total_width=$controller->getListTotalWidth($widthinfo,$operationWidth);
$fieldnames = $controller->getAdvancedSearchOptionString();
$smarty->assign("FIELDNAMES", $fieldnames);
$smarty->assign('TOTALWIDTH',$total_width);
$smarty->assign('OPERATIONWIDTH',$operationWidth);
$smarty->assign("CHKBOXWIDTH",$controller->listchkbox_width);

$table_Hundred_percent_width=getModuleWidth($focus,$controller->table_Hundred_percent_width,$currentModule);
$table_Hundred_percent_width=$controller->getListTotalWidth($table_Hundred_percent_width,$operationWidth);
$smarty->assign("TABLE_HUNDRED_PERCENT_WIDTH",$table_Hundred_percent_width);
$smarty->assign("LAST_FIELD_WIDTH",is_array($widthinfo)?$widthinfo[sizeof($widthinfo)-1]:'');
setGLobalURLSmarty($smarty);//设置js,css等访问路径
if(vtlib_isModuleActive('Dashboard'))
{
    $smarty->assign("DashboardActive",'active');
}
$fields=$focus->fieldobj->getFieldListArray();
$smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));
$smarty->assign('DEAILHTML',Inventory::createHTML($listview_entries,$currentModule,0,sizeof($listview_header)+1,$focus->logic->list_buttons,$controller,$LIST_NOCHECKBOX));

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

//xll 20221214 获取最近一次的基本搜索框字段选项
$controller->getFieldStorage($smarty);

// ljj 2023-08-29 XUQIU1001610 树结构设置和成员管理，左侧分类名称增加计数功能
$cls_MyCRMcryptobj=new cls_MyCRMcrypt();
$smarty->assign("Encrypt_TreeWhere",$cls_MyCRMcryptobj->encode($queryGenerator->getSqlNoTreeWhere($page_list_query)));

//zxm 20230614 获取列表页面公共参数并assign到tpl
ListViewCommonAssign($currentModule,$smarty,$focus);

//hzx 20231215 列表页面页签优化
$Navbarlist = [
    array(
        'value'=>0,
        'label'=>getFixedLabel('CALENDARVIEW')
    ),
    array(
        'value'=>1,
        'label'=>getFixedLabel('LISTVIEW')
    )
];
$smarty->assign('ListViewNavbarcur',1);
$smarty->assign('ListViewNavbarlist',json_encode($Navbarlist));


if(isset($_REQUEST['ajax']) && $_REQUEST['ajax'] != ''){
	$smarty->display("ListViewEntriesforC.tpl");
}else{
    $smarty->display("modules/Calendar/Calendar.tpl");//ActivityListView.tpl
}
?>