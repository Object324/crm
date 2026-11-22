<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global  $currentModule, $theme,$languageType;
global $list_max_entries_per_page_new;
global $current_user,$adb;
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
crm_load_function_file('VT_getSimpleNavigationValues','include/utils','ListViewUtils');

crm_load_class_file('Inventory','data');
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





//$_SESSION['module_list_tree'][$currentModule]=$_REQUEST['groupid'];
//$smarty->assign('MODULETREElIST',$modulelisttree['list']);
//$smarty->assign('MODULETREEENABLE',$modulelisttree['enable']);
//$smarty->assign('MODULETREElIST',$modulelisttree['list']);
//$smarty->assign('MODULETREElIST',$modulelisttree['list']);

$warehouseid = 0;
$url_string = '';
$stockquery = '';

$focus = CRMEntity::getInstance($currentModule);
//$focus->initSortbyField($currentModule);

//$focus->initSortbyField($currentModule);
/* 列表按钮 begin */
$focus->getModuleLogic($currentModule)->getListViewButtons();


/*
By LD Can;
Date:20121225;
reason:增加用户查询范围需求

*/
$MergeSmowner=getCurSmOwnerSearchScope($currentModule);
if(is_array($MergeSmowner))
    unset($MergeSmowner["UserCombo"][$current_user->id]);//去除当前用户

$fieldobj =$focus->fieldobj;
$smarty->assign('FIELDOBJ',$fieldobj);

//$smarty->assign('CUSTOM_MODULE', $focus->IsCustomModule);
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
    $SmOwner_option_arr[] = array('label'=>getFixedLabel('ALL').getFixedLabel('MEMBER'),'value'=>'SmOwner_Search_All','selected'=>true);
}
$smarty->assign('Merge_SmOwner_arr',json_encode($SmOwner_option_arr));
$smarty->assign('MAX_RECORDS', $list_max_entries_per_page_new);

$smarty->assign('MODULE', $currentModule);
//$smarty->assign('SINGLE_MOD', getTranstab($currentModule));
$smarty->assign('CATEGORY', $category);

//$smarty->assign('CHECK', $tool_buttons);
$smarty->assign('THEME', $theme);
$smarty->assign('IMAGE_PATH', "themes/$theme/images/");

// @edit:dong @date:2020/10/28 @reason: 数据分类设置为自定义链接模块
if(isset($_REQUEST['ajaxtype']) && $_REQUEST['ajaxtype'] =='ld_linkmodulecustom'){
    $smarty->assign('LINKMODULECUSTOM', true);
}
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

//$edit_permit = $customView->isPermittedCustomView($viewid,'Create',$currentModule);
//$delete_permit = $customView->isPermittedCustomView($viewid,'Delete',$currentModule);

//$smarty->assign("CUSTOMVIEW_PERMISSION",$statusdetails);
//$smarty->assign("CV_EDIT_PERMIT",$edit_permit);
//$smarty->assign("CV_DELETE_PERMIT",$delete_permit); 


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
$smarty->assign('ALL', $viewname);
if($viewname == 'All'){
    $viewname = getFixedLabel('ALL');
}
$smarty->assign("VIEWNAME", $viewname);

if($viewid ==0 ) {
    include(globalStatic::$root_directory."modules/lingdang/ExitWithoutPermission.php");
	exit;
}


$queryGenerator =  QueryGenerator::getInstance($currentModule, $current_user,$customView);
//zkt 20240809 BUG20240726-44 他在左边选了一个部门，然后用高级查找查了一下，所有部门的数据都出来了。应该只筛选我选择的那个部门的数据，看附件
if($currentModule=='Users')
{
    if($_REQUEST['groupid'])
    {
        $user_group_list_id=$_REQUEST['groupid'];
    }
    else if(isset($_SESSION['user_group_list_id_'.$current_user->id])){
        $user_group_list_id = $_SESSION['user_group_list_id_'.$current_user->id];
    }
    $queryGenerator->setGroupid($user_group_list_id);
}
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
///得到对应视图的查询字段
if ($viewid != "0") {
   $queryGenerator->initForCustomViewById($viewid);
} else {
	$queryGenerator->initForDefaultCustomView();
}
$smarty->assign("LISTPAGEURL", getlisturl_aftersave());
// Enabling Module Search
Crm_load_class_file("CommonView","modules/CustomView");
$smarty->assign("DATETIMESTR",json_encode(CommonView::stdFilterDateTimeStr()));

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
        // @edit:dong @date:2020/08/24 @reason: 平铺搜索
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
    ////上一页和下一页点击使用使用
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

//20240726 hzx XUQIU1001729 经销商用PRM成员管理设置
if($currentModule == 'Users'){
    $reg=RegOp::getInstance();
    $crmUserCount=$reg->GetUserCount();
    $prmUserCount= $reg->getPrmUserCount();
    $user_type = 'crm';
    $user_navbar_cur = 0;
    if(isset($_REQUEST['user_type']) && !empty($_REQUEST['user_type'])){
        $user_type = $_REQUEST['user_type'];
    }
    $prmsuerstatus = $reg->getPrmAuth();
    $smarty->assign('PRMUSERSTATUS',$prmsuerstatus);
    if($prmsuerstatus == 'yes'){
        if($user_type == 'crm'){
            $user_navbar_cur = 0;
        }else{
            $user_navbar_cur = 1;
        }

        $sql="select 1 from ld_users where status='active' and crm_user_type='crm'";
        $crmresult=$adb->pquery($sql);
        $sql="select 1 from ld_users where status='active' and crm_user_type='prm'";
        $prmresult=$adb->pquery($sql);
        $user_navbarlist = [array('label' => getFixedLabel('COMPANYCRMUSER') . '(' . $adb->num_rows($crmresult) . '/'.$reg->GetUserCount().')', 'value' => 'crm'), array('label' => getFixedLabel('COMPANYPRMUSER')  . '(' . $adb->num_rows($prmresult) . '/'.$reg->GetPrmUserCount().')', 'value' => 'prm')];//用户模块页签
        $smarty->assign('ListViewNavbarcur', $user_navbar_cur);
        $smarty->assign('ListViewNavbarlist', json_encode($user_navbarlist));
    }

    $smarty->assign('user_type', $user_type);
    $focus->setuser_type($user_type);
    $where = $focus->getusertypewheresql();
    if(!empty($where['where'])){
        $queryGenerator->AddSqlWhere(" and ".$where['where'],array(),array());
    }
    $focus->getModuleLogic($currentModule)->getListViewButtons();
}

$page_list_query = $queryGenerator->getQuery('','groupby');

$list_query = $queryGenerator->getQuery('',2);


$cls_MyCRMcryptobj=new cls_MyCRMcrypt();
$smarty->assign("Encrypt_page_list_query",$cls_MyCRMcryptobj->encode($page_list_query));
// ljj 2023-08-29 XUQIU1001610 树结构设置和成员管理，左侧分类名称增加计数功能
$smarty->assign("Encrypt_TreeWhere", $cls_MyCRMcryptobj->encode($queryGenerator->getSqlNoTreeWhere($page_list_query)));

if(isset($_REQUEST['wareid']) && $_REQUEST['wareid'] != '' && $_REQUEST['wareid'] > 0)
{
    $warehouseid = $_REQUEST['wareid'];
}
$ChartFrom=str_replace(' ','//B/',$queryGenerator->page_left_join . $queryGenerator->gettabshareSql());//$queryGenerator->getChartFrom()
$ChartFrom=str_replace("'","//,/",$ChartFrom);
$ChartFrom=str_replace("%'","//,,/",$ChartFrom);
$ChartFrom= str_replace('"','',$ChartFrom);


$ChartWhere=str_replace('<','//lt/',$queryGenerator->getChartWhere());
$ChartWhere=str_replace(' ','//B/',$ChartWhere);
$ChartWhere=str_replace("'","//,/",$ChartWhere);
$ChartWhere=str_replace(">","//tgt/",$ChartWhere);
//bug 23792 edit cyb date:2016-07-28 替换掉"%";
$ChartWhere=str_replace("%","//lk/",$ChartWhere);//%
$ChartWhere=str_replace("<=",'//lteq/',$ChartWhere);//<=

$ChartOwner=str_replace(' ','//B/',$queryGenerator->getChartOwner());
$smarty->assign('CHARTFROM',$ChartFrom);
$smarty->assign('CHARTWHERE',$ChartWhere);
$smarty->assign('CHARTOWNER',$ChartOwner);
$where = $queryGenerator->getConditionalWhere();
//$queryGenerator->getQueryRow_Count()
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



$count_result = $adb->query($count_sql);
if(!empty($count_result))
	$noofrows = $adb->query_result($count_result,0,0);
else 
	$noofrows = 0;


if(empty($order_by)){
	$orderModArr = array('InventoryAccount'=>1,'InventoryQuery'=>1,'Checks'=>1);
	if(isset($orderModArr[$module])){
		$stockquery  = $queryGenerator->isStockQuery($module);
        $page_list_query.=$stockquery;
    
        $order_by=' ld_warehousecondtions.operationtime ';
	}
    else
    {
       
        list($page_list_query,$order_by,$sorder) = $queryGenerator->customview->getOrderWhere($page_list_query);

    }
}


ListViewSession::setSessionQuery($currentModule,$page_list_query,$viewid);

//by ld tifa 20120116 bug 0003154


 

$queryMode = (isset($_REQUEST['query']) && $_REQUEST['query'] == 'true');
$start = ListViewSession::getRequestCurrentPage($currentModule, $noofrows, $viewid, $queryMode);

$navigation_array = VT_getSimpleNavigationValues($start,$list_max_entries_per_page_new,$noofrows);
$table_id_index=$focus->table_index;

$limit_start_rec = ($start-1) * $list_max_entries_per_page_new;
$list_query.=' inner join ( '.$page_list_query. " LIMIT $limit_start_rec, $list_max_entries_per_page_new ) as tmp
             on tmp.$table_id_index=".$focus->table_name.'.'.$table_id_index;
$smarty->assign("Encrypt_list_query",$cls_MyCRMcryptobj->encode($list_query));
//echo $list_query;
list($list_query,$order_by,$sorder) = $queryGenerator->customview->getOrderWhere($list_query,'',$queryGenerator);

$list_result = $adb->pquery($list_query, array());
    //echo $list_query;
//$recordListRangeMsg = getRecordRangeMessage($list_result, $limit_start_rec,$noofrows);
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
//$navigationOutput = getTableHeaderSimpleNavigation2($navigation_array, $url_string, $currentModule, 'index', $viewid);
//$smarty->assign("NAVIGATION", $navigationOutput);

//hzx 20231207 XUQIU1002273 PC端模块列表界面，分页样式优化
$smarty->assign("TABNAME", getParentTab());
$smarty->assign("STARTPAGE", ceil($start));
$smarty->assign("LISTVIEWRECORDCOUNT", ceil($noofrows));
$smarty->assign("LISTVIEWPAGECOUNT", ceil($noofrows/$list_max_entries_per_page_new));
$smarty->assign("LISTVIEWPERPAGENUM", json_encode(getlistmaxentries_per_page($list_max_entries_per_page_new)));

$controller = new ListViewController($adb, $current_user, $queryGenerator);


if($currentModule=='Reminds')
{
    $skipAction=false;//edit:can reaosn:12564: 提醒叙事簿界面：序列表中多显示了一列“操作列”-如图，1024*768
}
//得到列头
$listview_header = $controller->getListViewHeader($focus,$currentModule,$url_string,$sorder,$order_by,$skipAction);

$listview_entries = $controller->getListViewEntries($focus,$currentModule,$list_result,$navigation_array,false);

/**
 * @project PROT26 序时簿增加合计项
 * @author Tujt 2014-06-05
 */
 crm_load_class_file('clsTotal_List','include/ListView');
 $clstotalobj=new clsTotal_List($controller);
$totalfldhtml = $clstotalobj->getTotalFldCount($page_list_query." LIMIT $limit_start_rec, $list_max_entries_per_page_new ",$list_result,$noofrows);
$smarty->assign('TOTALFLDHTML',$totalfldhtml);

$listview_header_search = $controller->getBasicSearchFieldInfoList();

//菜单查询和立即查找的数据
$smarty->assign('LISTHEADER', $listview_header);
$smarty->assign("HEADERNAME",$controller->headername);
//$smarty->assign('LISTENTITY', $listview_entries);
//合并列
$smarty->assign('LISTHEADERCOUNT', count($listview_header)+1);
/**
 * edit:chj
 * date:20131225
 * reason:5648: 库存台账不显示统计数量查询字段
 * */
if($module == 'InventoryQuery')
{
    $languageType= getLanguageType($current_user);
    if($languageType =='en')
        $listview_header_search = $focus->header_search_en;
    else
        $listview_header_search = $focus->header_search;
}
$smarty->assign('SEARCHLISTHEADER',$listview_header_search);

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


/*
edit:chj
date:2013-11-14
reson:入库单仓库检索
*/
if($module == 'InventoryAccount' || $module == 'InventoryQuery' )
{
    $num_rows=$adb->num_rows(selWareAll());
    $warehouses=array();
    for($i=0;$i<$num_rows;$i++){
        $warehouses[]=array(
        'id'=>$adb->query_result($result,$i,'id'),
        'name'=>$adb->query_result($result,$i,'name'),
        //'type'=>getpower($current_user->id,$adb->query_result($result,$i,'id'),1)
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
}
$smarty->assign('IS_ADMIN', is_admin($current_user));
//add by tifa 20130221 for reminds
//$CASHBILLCREATE
//序时簿列表页面是否显示本次查询统计图表
$arr_module = array('ContactRecords','Campaigns','Potentials');
if( in_array($currentModule,$arr_module)){
//	$deployarray=getSys_deploy(137);
//	if($deployarray['deploy_value'] == 0){
		$smarty->assign("DashboardPermitt",'yes');
//	}
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

//中英文包
/*
require("user_privileges/user_language_".$current_user->id.'.php');
if(empty($languageType))
{
    $languageType = 'zh';
}*/

$languageType=getLanguageType($current_user);

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
$smarty->assign('TOTALWIDTH',$total_width);
$smarty->assign('OPERATIONWIDTH',$operationWidth);
$smarty->assign("CHKBOXWIDTH",$controller->listchkbox_width);
/**
 * 判断当前模块是否开启审批，开启的话就显示批量提交按钮
 * @project PROT144 审批功能改进
 * @author Tujt 2014-12-26
 
//include_once('./modules/Approve/Approve.php');
//$approve_focus = new Approve();
$approve_focus = Approve::getInstance($currentModule);
$startapprovemodule = $approve_focus->startBlocksApprove();
$issubmit = 0;
if(isset($startapprovemodule[$currentModule])) $issubmit = 1;
$smarty->assign('APPROVEDISSUBMIT',$issubmit);*/
if($currentModule == 'Project'){
   $tradeSQL = "SELECT trade FROM ld_version;";
    $result = $adb->pquery($tradeSQL,array());
    $trade=$adb->query_result($result,0,'trade');
    $smarty->assign('TRADE', $trade); 
}
$VersionInfo = getVersionInfo();
$smarty->assign('VERSION_ACCOUNT',$VersionInfo['account']);
/*
edit:Can
date:20130902
reason:4917: 控制面板 模块管理中将 本次查询统计图表 关闭，但是在客户等模块打开界面时，下面还是能显示 本次查询统计图表
*/
//销售机会序时簿增加跟进操作按钮列宽控制andy
if($currentModule == 'Potentials')
{
    if(isPermitted('ContactRecords',"Create","") == 'yes' && vtlib_isModuleActive('ContactRecords'))
        $smarty->assign('CREATECONTRACTRECORDS', 'yes');
}    
//库存流水账列表没有操作列
if($currentModule == 'InventoryAccount'){
	$colspan_count = sizeof($listview_header);//没有内容时，合并列
}else{
	$colspan_count = sizeof($listview_header)+1;
}
//单据推进管理 - 推进漏斗
/*crm_load_class_file('cls_module_advance','modules/Settings');
$cls_module_advance = new cls_module_advance($currentModule);
$smarty->assign('MODULEADVANCESTAGESTATUS',$cls_module_advance->is_Enable());*/
$smarty->assign('DEAILHTML',Inventory::createHTML($listview_entries,$currentModule,0,$colspan_count,$focus->logic->list_buttons,$controller,$LIST_NOCHECKBOX));


//$smarty->assign('DEAILHTML',Inventory::createHTML($listview_entries,$currentModule,0,sizeof($listview_header)+1,$focus->logic->list_buttons));

//0026303: 服务回访单列表：点击【如何创建服务回访单】，弹出层中的提示信息“客户服务单或项目计划”现在显示成了客户服务单项目计划
if($currentModule == 'ServiceReturn'){
    if(vtlib_isModuleActive('HelpDesk') && vtlib_isModuleActive('ProjectTask')){
        $smarty->assign('HOWTOCREATERETURN1',getFixedLabel('How_to_create_return1_or'));
        $smarty->assign('HOWTOCREATERETURN2',getFixedLabel('How_to_create_return2_or'));   
    }else{
        $smarty->assign('HOWTOCREATERETURN1',getFixedLabel('How_to_create_return1'));
        $smarty->assign('HOWTOCREATERETURN2',getFixedLabel('How_to_create_return2'));
    }
}

//市场活动本次查询统计图表字段权限
if($currentModule == 'Campaigns'){
    if(array_key_exists('campaignstatus',$focus->column_fields))
    {
        $smarty->assign("CHART_CAMPAINSTATUS",'yes');
    }
    if(array_key_exists('campaigntype',$focus->column_fields))
    {
        $smarty->assign("CHART_CAMPAIGNTYPE",'yes');
    }
    if(array_key_exists('expectedresponse',$focus->column_fields))
    {
        $smarty->assign("CHART_EXPECTEDRESPONSE",'yes');
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
}
//ljj 20240315 XUQIU1001538 项目立项列表增加“看板视图”功能（李鑫华）
if($currentModule == 'Potentials' || $currentModule == 'Project'){
    if ($currentModule == 'Potentials'){
        $smarty->assign('CUSTOMERFUNNEL',$focus->getCustomerFunnelForPresence($focus));
    }
    //wyt XUQIU1000540 销售机会增加“列表视图”和“看板视图”图标按钮（熊少波） BUG0065603 kfbcrm -销售机会界面，没有列表视图 看板视图图标按钮
    crm_load_class_file('cls_module_advance','modules/Settings');
    $advanceObj = cls_module_advance::getInstance($currentModule);
    $ld_settigs_module_advance = $advanceObj->getModuleAdvance();
    $advshow=$ld_settigs_module_advance['enable'];//zxm 20230920 改成读取缓存
    $method=$ld_settigs_module_advance['method'];//zxm 20230920 改成读取缓存
    $module_field=$ld_settigs_module_advance['module_field'];//zxm 20230920 改成读取缓存
    if (array_key_exists($module_field,$focus->column_fields) && $method == 'field' && $advshow == 'yes'){
        $smarty->assign('SHOWKANBAN',$advshow);
        $smarty->assign('SHOWKANBANVALUE',$advshow);
        $showkanban='yes';
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
        }else{
            $viewmode = 'listview';
        }
    }else{
        $viewmode = $_REQUEST['viewmode'];
    }
    $smarty->assign('VIEWMODE',$viewmode);
    setUsersettingByLabel($currentModule,$current_user->id,'VIEWMODE', $viewmode);
}

//gxj 230711 BUG0069245 销售机会的看板视图加上报表按钮
if(($currentModule=='Potentials' || $currentModule == 'Project') &&$viewmode == 'kanban' && $showkanban == 'yes'){
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

if($currentModule=='Users')
{
    require_once globalStatic::$root_directory.'appCommon/appCommon.php';

    if(isKehu001ServerPc()=='yes'){
        //36865: 原客户001版本不允许直接新增部门和成员的控制判断，改为按服务器域名判断
    	$smarty->assign('ISKEHU','yes');
    }
}
//	$smarty->assign('ISKEHU','yes');
if($currentModule=='Documents')
{
    $dbQuery = "select * from ld_attachmentsfolder";
    $result = $adb->pquery($dbQuery,array());
    $foldercount = $adb->num_rows($result);
    for($i=0;$i<$foldercount;$i++)
	{
	   $folder_details=Array();
		$folderid = $adb->query_result($result,$i,"folderid");
		$folder_details['folderid']=$folderid;
		$folder_details['foldername']=$adb->query_result($result,$i,"foldername");
		$foldername = $folder_details['foldername'];
		$folder_details['description']=$adb->query_result($result,$i,"description");
	   $folders[$foldername] = $folder_details;
       $countquery='select DISTINCT ld_notes.notesid '. $queryGenerator->getFromClause();
        $countquery .=' ';   
        $countquery .=$leftsql;
        $countquery .=' ';
        $countquery .=$queryGenerator->getWhereClause();
        $countquery .=' ';
        $countquery .=$queryGenerator->getSmOwnerSearchSql. " and ld_notes.folderid = $folderid";
      
        $count_result = $adb->query(  $countquery );
		$num_records = $adb->num_rows($count_result);
        if($num_records<=0)
            $emptyfolders[$foldername] = $folder_details;
    }
    $smarty->assign("EMPTY_FOLDERS", $emptyfolders);
    $smarty->assign("ALL_FOLDERS", $folders);

}
 if($currentModule=='Users')
 {
            $reg=RegOp::getInstance();
            $regCount=$reg->GetUserCount();
            $testFile=$reg->isExistFile();
            $prmregCount = $reg->getPrmUserCount();
            if($reg->getPrmAuth() == 'yes'){
                $sql="select 1 from ld_users where status='active'";
                $total_user = $regCount+$prmregCount;
            }else{
                $sql="select 1 from ld_users where status='active' and crm_user_type <> 'prm'";
                $total_user = $regCount;
            }
            if($testFile==1)
            {
                $result=$adb->pquery($sql);
                $strUserRegister=getFixedLabel('USED').$adb->num_rows($result).'/'.($regCount+$prmregCount).'（'.getFixedLabel('NOTCONTAINUSER').'）';
                $smarty->assign("REGISTERINFO",$strUserRegister);
            }
            else
            {
                $smarty->assign("REGISTERINFO","");
            }
            
            $group_focus = new Group();
            $group_focus->setgroup_type($user_type);
            $view ='';
            $fld_module = 'Users';//模块
            $filterown = '';//是否过滤自己
            $selecttype = "group";	//选择类型
            $ishighseaallocate='no';
            $filterrecordid = "";//共享时，过滤当前单据的负责人(只控制单个单据)
            $groupuser = $group_focus->getGroupListUser($fld_module,$view,$filterown,$selecttype,$ishighseaallocate,$filterrecordid);
            $groupuserarray = $group_focus->setOneParent($groupuser,"");
            $array[$group_focus->group_parent_key] = $groupuserarray[$group_focus->group_parent_key];
            $groups = $group_focus->getGrouplist();

           if(empty( $user_group_list_id))
           {
			    foreach($groups as $groupid => $group_info){
					if($group_info['depth'] == 0){
						 $user_group_list_id=$groupid;
					}
			   }
           }
            foreach($groupuser as $groupkey=>$content)
            {
               
                 if($content['groupid']==$user_group_list_id)
                 {
                     $groupobj=new Group();
                     $groupobj->groupid=$content['groupid'];
                     $groupobj->groupname=$content['name'];
                     $tmp_groupname=getWx_GroupName($groupobj);
                     if($noofrows==null)
                     {
                        $smarty->assign("GROUPUSERCOUNTINFO",$tmp_groupname);
                     }
                     else
                     {
                           
                        $smarty->assign("GROUPUSERCOUNTINFO",$tmp_groupname."(".$noofrows.getFixedLabel('people').")");
                     }
                    break;
                 }
            }
           
            $grouptreehtml= $group_focus->setGroupExpandTree($array,'',0,0);
            
            $smarty->assign("GROUPTREEHTML",$grouptreehtml);
            $_SESSION['user_group_list_id_'.$current_user->id] = $user_group_list_id;
            $smarty->assign("USER_GROUP_LIST_ID",$user_group_list_id);

            $tree_width = getUsersettingByLabel($currentModule,'','structuretree_width')?:220;
            $tree_expand = getUsersettingByLabel($currentModule,'','structuretree_expend')?:'yes';
            $smarty->assign("MODULElISTTREE",array("tree_width"=>$tree_width,'tree_expand'=>$tree_expand));
 }

//社交推广模块 判断首次访问弹出帮助
 if($currentModule == 'SocialPromotion'){
    if(in_array($current_user->id,getUserFristVisit())){
        $smarty->assign('FIRSTVISIT',1);
    }
 }

 setGLobalURLSmarty($smarty);//设置js,css等访问路径

 $fields=$focus->fieldobj->getListViewFields();
$smarty->assign('FIELDINFOJSON',ldcrm_json_encode($fields['fields']));
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
global $languageType;
$smarty->assign("current_language",$languageType);

//xxy 2023-10-13 地图视图按钮显示
$smarty->assign("isShowMap",$focus->isShowMap);

if(isset($_REQUEST['ajax']) && $_REQUEST['ajax'] != '')
{

	$smarty->display("ListViewEntries.tpl");

}
else
{

    $smarty->display('ListView.tpl');
}

?>