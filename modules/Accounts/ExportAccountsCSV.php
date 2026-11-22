<?php



global  $currentModule, $theme;
global $list_max_entries_per_page_new;
global $current_user;
$languageType= getLanguageType($current_user);
include(globalStatic::$root_directory."include/cls_PHPCsv.php");
set_time_limit(0);
// 使用示例
$eachexportcount=1000;//每次导出的记录数量为2000
$smarty=new lingdangCRM_Smarty();
$page_width= 559;
$smarty->assign("PAGEWIDTH",$page_width);
if($_SESSION[$currentModule][$current_user->id]['export']['startexportindex'])
    $startexportindex=$_SESSION[$currentModule][$current_user->id]['export']['startexportindex'];
else
{
    $startexportindex=0;
}

if($startexportindex<=0)
{
    $startexportindex=0;
   
}
$_SESSION[$currentModule][$current_user->id]['export']['startexportindex']=$startexportindex+$eachexportcount;
$cur_progress_step=0;
if($_SESSION[$currentModule][$current_user->id]['export']['listcounts'])
{
    $listcounts=$_SESSION[$currentModule][$current_user->id]['export']['listcounts'];
    $cur_progress_step=$_SESSION[$currentModule][$current_user->id]['export']['cur_progress_step'];
}
else
{
    $cur_progress_step=0;
    $listcounts=0;
    
}
$smarty->assign("CUR_PROGRESS_STEP",$cur_progress_step);
$smarty->assign("STARTEXPORTINDEX",100);
$smarty->assign("MODULE",$currentModule);
$smarty->assign("EXPORTFORMAT",'exportcsv');
$smarty->display('ExportRecords.tpl');

//$focus = new $currentModule();
$focus = CRMEntity::getInstance($currentModule);
//$focus->initSortbyField($currentModule);//代码优化，初始化客户对象赋值
if(ListViewSession::hasViewChanged($currentModule,$viewid)) {
	$_SESSION[$currentModule."_Order_By"] = '';
}
$sorder = $focus->getSortOrder();
$order_by = $focus->getOrderBy();

$_SESSION[$currentModule."_Order_By"] = $order_by;
$_SESSION[$currentModule."_Sort_Order"]=$sorder;

$accounttype="ALLACCOUNT";
if(isset( $_SESSION['lvsAccount'][$currentModule]['pagepublicaccounttype']))
{
    $accounttype=$_SESSION['lvsAccount'][$currentModule]['pagepublicaccounttype'];
}
$customView = new CustomView($currentModule);

$viewid = $customView->getViewId($currentModule);

if(isset($_SESSION['lvs'][$currentModule]['SearchScope'])&&$_SESSION['lvs'][$currentModule]['SearchScope']!=null)
{}
else 
{
    $SearchScope="SmOwner_Search_All";
    $_SESSION['lvs'][$currentModule]['SearchScope']=$SearchScope;
}


$queryGenerator = QueryGenerator::getInstance($currentModule, $current_user,$customView);

/**
 * query_session=1时，读取session中的搜索条件，否则将清空session
 * 查看页面返回列表、列表编辑之后保存 返回列表时，返回query_session=1的参数
 * @project 序时簿查询记住搜索条件
 * @author Tujt 2014-04-24
 */
// editor:gyqX160816 reason:新增在search_type=selecteddata时，仍要利用查询信息
// Bug:0023863: 项目>项目进度>序列表界面：使用基本查找帅选数据后全选所有记录，导出>"导出选定结果"，结果导出了全部的数据
if(isset($_SESSION['LiveViewSearch'][$currentModule])&&($_REQUEST['search_type']=='includesearch'||
        $_REQUEST['search_type']=='withoutsearch' || $_REQUEST['search_type']=='selecteddata')){
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
		}
	}
	if($search_session == 1){
		$_REQUEST['query'] = 'true';
	}
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

}

$list_query = $queryGenerator->getQuery('',2);

$page_list_query=$queryGenerator->getQuery('',1);

crm_load_class_file('ExportProductDetailController','include/ListView');
$controller = new ExportProductDetailController($adb, $current_user, $queryGenerator,'csv');
/**
 * 更新操作
 * date:20131228
 * edit:can
 * reason:(批量修改/修改负责人/批量分配领取)页面刷新会重复发送短信
 * other:把该语句移动到（批量修改/修改负责人/批量分配领取）保存页面
*/

//$sql="select * from ld_Account_set";
//$accountset=$adb->pquery($sql,array());
/*$status=1;
$adminaccount="";
$usersaccount="";
$dataProfile=1;
$getProfile=1;*/

//by andy 公海客户改进
/*$wheathershow=1;
$userid='';
$status=getAccount_Set('status');
$adminaccount=getAccount_Set("adminaccount");
$usersaccount=getAccount_Set('usersaccount');
$dataProfile=getAccount_Set('dataprofile');
$getProfile=getAccount_Set('getprofile');
$wheathershow=getAccount_Set('wheathershow');
$userid=getAccount_Set('userid');
$splitadmin=explode(",",$adminaccount);
$splituser=explode(',',$usersaccount);*/
 //得到列头
$listview_header = $controller->getListViewHeader($focus,$currentModule,$url_string,$sorder,$order_by,$skipAction);
//array_pop($listview_header);
foreach($listview_header as $key=>$arr){
    $listview_header[$key]=strip_tags($arr);
}


$where = $queryGenerator->getConditionalWhere();

/*$focus->setaccountstatus($status);
$focus->setadminaccount($adminaccount);
$focus->setuseraccount($usersaccount);*/

/*if($status==0)//启用公海参数
{
   if($accounttype=='PUBLICALLOCATE')
    {
       $ChartWhere=" and ld_account.publicaccount>1 ";
    }
}

if($status==0&&($current_user->is_admin=="on"||in_array($current_user->id,$splitadmin)||in_array($current_user->id,$splituser)))
{
     if($accounttype=='NOALLOCATE')
    {
        $ChartWhere=" and ld_account.publicaccount=1";
    }
}
if($status==0&&($wheathershow == 1 || $wheathershow == 2 || $wheathershow == 3)&&$accounttype=='ALLACCOUNT')
{
	if($wheathershow == 1)
        $ChartWhere .=' and ld_account.publicaccount = 0 ';
	else if($wheathershow == 2)
        $ChartWhere .=' and ( ld_account.publicaccount > 1  or ifnull(ld_account.publicaccount,0)=0)';
	else if($wheathershow == 3)
        $ChartWhere .=' and  ifnull(ld_account.publicaccount,0)<= 1 ';
}*/
$ChartFrom=$queryGenerator->getChartFrom();

//$page_list_query .=$ChartWhere;

$ChartOwner=$queryGenerator->getChartOwner();

$list_query .=$ChartOwner;


if(PerformancePrefs::getBoolean('LISTVIEW_COMPUTE_PAGE_COUNT', false) === true) {
	$count_result = $adb->query($page_list_query);
    if(!empty($count_result))
        $noofrows=$adb->num_rows($count_result);
    else 
		$noofrows = null;
}else {
	$noofrows = null;
}

$queryMode = (isset($_REQUEST['query']) && $_REQUEST['query'] == 'true');
$start = ListViewSession::getRequestCurrentPage($currentModule, $list_query, $viewid, $queryMode);
 crm_load_function_file('VT_getSimpleNavigationValues','include/utils','ListViewUtils');
$navigation_array = VT_getSimpleNavigationValues($start,$list_max_entries_per_page_new,$noofrows);
//分类默认排序设置
//$queryGenerator->getReferenceOrderBy()获取首要联系人
$customsortorder = $queryGenerator->getSequence_fields() . $queryGenerator->getReferenceOrderBy();
$limit_start_rec = ($start-1) * $list_max_entries_per_page_new;
$countsql = $list_query;

//统计
$countsql .= 'inner join ( '.$page_list_query.' ) as temp on temp.accountid=ld_account.accountid ';
$countsql .= $queryGenerator->getWhereClause();
$params = array();
$search_type = $_REQUEST['search_type'];
//$export_data = $_REQUEST['export_data'];
$wheres=' where ld_account.deleted = 0 ';

if(!empty($querysearch)){
		$wheres = $queryGenerator->getWhereClause();
}

if($_REQUEST['idstring']!=''&&$search_type == 'selecteddata'){
    if($_REQUEST['idstring']!='all'){
    $_REQUEST['idstring']=rtrim($_REQUEST['idstring'],',');
    $idstring = explode(";", $_REQUEST['idstring']);
    $querywhere = ' and ld_account.accountid in ('.generateQuestionMarks($idstring).')';
    array_push($params, $idstring);
    }
}

if((!is_array($idstring)|| count($idstring)<=0)&&$search_type == 'selecteddata'&&$_REQUEST['idstring']!='all')$querywhere=" and 1<>1 ";

if($search_type == 'currentpage'){
	if ($limit_start_rec < 0) $limit_start_rec = 0;
	$queryLIMIT = ' LIMIT '.$limit_start_rec.','.$list_max_entries_per_page_new;
}

$list_query=$list_query." inner join ( $page_list_query ".$FoSearchSQL.$querywhere.$querysearch.  $queryLIMIT." ) as temp on temp.$focus->table_index=$focus->table_name.$focus->table_index";

$list_query=$list_query.$wheres;
$list_count_sql= $page_list_query;
$csv=new cls_PHPCsv();
$csv->setTitle(($currentModule));
$csv->SheetHeader = $listview_header;
if(!array_key_exists('exportgetcount',$_SESSION[$currentModule][$current_user->id]['export']))
{
    //32405: 客户模块-导出数据，导出搜索的结果，数据已经导出完成了，导出数据的进度条还在页面显示并且没有进度条
     $detail_result = $adb->pquery($list_query, $params);
    $detailcounts = $adb->num_rows($detail_result);       

    $listcounts_result = $adb->pquery($page_list_query . $querywhere, $params);
    $listcounts = $adb->num_rows($listcounts_result);  
    $_SESSION[$currentModule][$current_user->id]['export']['listcounts']=$listcounts;
    $_SESSION[$currentModule][$current_user->id]['export']['detailcount']=$detailcounts;
    
     $_SESSION[$currentModule][$current_user->id]['export']['exportgetcount']="##SUCCESS##". $listcounts.'details'.$detailcounts;
       
    $csv->init();
}
else
{
    $csv->openfile();
}
   
    

if(isset($skipAction)==false){
	$skipAction==false;
}

list($list_query,$order_by,$sorder) = $queryGenerator->customview->getOrderWhere($list_query);

$list_query = $queryGenerator->getQuery('',2);//所有数据查询
$where=$queryGenerator->getWhereClause();
$prev_totalrows=0;

$nums =100;
$step = $eachexportcount/$nums;


$progress_step=if(!empty($_SESSION[$currentModule][$current_user->id]['export']['detailcount']))
    $progress_step=$page_width/$_SESSION[$currentModule][$current_user->id]['export']['detailcount'];
else
    $progress_step=0;;
if($startexportindex<$listcounts)
{
       if(array_key_exists('exportprev_totalrows',$_SESSION[$currentModule][$current_user->id]['export']))
       {
            $prev_totalrows=$_SESSION[$currentModule][$current_user->id]['export']['exportprev_totalrows'];
       }
       for($s = 1; $s <= $step; ++$s) {

               $start = ($s - 1) * $nums+$startexportindex;
             $queryLIMIT = ' LIMIT '.$start.','.$nums;
              $list_result = $adb->pquery("$list_query inner join ($page_list_query $querywhere order by $order_by desc $queryLIMIT) as tmp on tmp.$focus->table_index=$focus->table_name.$focus->table_index $where   order by $order_by desc", $params);
              $rows=$adb->num_rows($list_result);
              if($rows<=0)
              {
                break;
              }
                
              $nextrows=$start+$rows;
              $listview_entries = $controller->getListViewEntries($focus,$currentModule,$list_result,$navigation_array,$skipAction,true,'export');
           
            foreach($listview_entries as $key=>$row)
            {
                //$key是从0开始的，所以要加1
                  $cur_progress_step=($key+1+$prev_totalrows)*$progress_step;
            
                 echo '<script> 
                       document.getElementById("dvctimedescription").innerHTML="正在导出'.($key+1+$prev_totalrows).'条数据"
                       document.getElementById("dv").innerHTML="共'.$listcounts.'条数据，明细'.($_SESSION[$currentModule][$current_user->id]['export']['detailcount']).'";
                       document.getElementById("dvExportprogress").style.width = "'.trim($cur_progress_step).'px"</script>';
                  ob_flush();
                  flush();
                 
                 $tmprow=array();
                foreach($row as $index=>$content)
                {
                    $tmprow[]=mb_convert_encoding($content,"GBK","auto");
                }
                 fputcsv($csv->fp, $tmprow);
                
            }
              
              $prev_totalrows+= count($listview_entries);
              unset($listview_entries);
              
     }
    $_SESSION[$currentModule][$current_user->id]['export']['total_list_query']="$list_query inner join ($page_list_query  $querywhere $orderby ) as tmp on tmp.$focus->table_index=$focus->table_name.$focus->table_index $where  $orderby";
    $_SESSION[$currentModule][$current_user->id]['export']['list_query']="$list_query inner join ($page_list_query  $querywhere $orderby ) as tmp on tmp.$focus->table_index=$focus->table_name.$focus->table_index $where  $orderby";
    $_SESSION[$currentModule][$current_user->id]['export']['exportprev_totalrows']=$prev_totalrows;
    $_SESSION[$currentModule][$current_user->id]['export']['cur_progress_step']=$cur_progress_step;
     fclose($csv->fp);
    
     $tmptmp=$startexportindex+$eachexportcount;
     if($tmptmp<$listcounts)
    {
         echo '<script type="text/javascript">';
         echo "document.forms['Export_Records'].submit();";
        echo '</script>';

    }
    else
    {
       
       ob_flush();
       flush();
 
     echo '<script>showExportResult();</script>';
     
    }
}
else
{
    unset($_SESSION[$currentModule][$current_user->id]['export']);
    $_REQUEST['frommodule']=$currentModule;
    include(globalStatic::$root_directory.'modules/uploads/downloadxls.php');
}
exit();