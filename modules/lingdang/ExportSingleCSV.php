<?php

///不带明细数据导出
global  $currentModule, $theme;
global $list_max_entries_per_page_new;
global $current_user;

require_once('include/ListView/ListViewSession.php');
include(globalStatic::$root_directory."include/cls_PHPCsv.php");
set_time_limit(0);

$smarty=new lingdangCRM_Smarty();
$page_width= 559;
$smarty->assign("PAGEWIDTH",$page_width);
if($_SESSION[$currentModule][$current_user->id]['export']['startexportindex'])
    $startexportindex=$_SESSION[$currentModule][$current_user->id]['export']['startexportindex'];
else
{
    $startexportindex=0;
}
$eachexportcount=10000;//每次导出的记录数量为10000
if($startexportindex<=0)
{
    $startexportindex=0;
   
}

$_SESSION[$currentModule][$current_user->id]['export']['startexportindex']=$startexportindex+$eachexportcount;
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

$smarty->assign("STARTEXPORTINDEX",100);

$smarty->assign("MODULE",$currentModule);
$smarty->assign("EXPORTFORMAT",'exportcsv');
$smarty->display('ExportRecords.tpl');



$focus = CRMEntity::getInstance($currentModule);
//$focus->initSortbyField($currentModule);

if(ListViewSession::hasViewChanged($currentModule,$viewid)) {
	$_SESSION[$currentModule."_Order_By"] = '';
}
$sorder = $focus->getSortOrder();
$order_by = $focus->getOrderBy();

$_SESSION[$currentModule."_Order_By"] = $order_by;
$_SESSION[$currentModule."_Sort_Order"]=$sorder;

// Custom View
$customView = new CustomView($currentModule);

$viewid = $customView->getViewId($currentModule);
if(isset($_SESSION['lvs'][$currentModule]['SearchScope'])&&$_SESSION['lvs'][$currentModule]['SearchScope']!=null)
{
}
else 
{
    $SearchScope="SmOwner_Search_All";
    $_SESSION['lvs'][$currentModule]['SearchScope']=$SearchScope;
}

$queryGenerator =  QueryGenerator::getInstance($currentModule, $current_user,$customView);
/**
 * query_session=1时，读取session中的搜索条件，否则将清空session
 * 查看页面返回列表、列表编辑之后保存 返回列表时，返回query_session=1的参数
 * @project 序时簿查询记住搜索条件
 * @author Tujt 2014-04-25
 */
if( isset($_SESSION['LiveViewSearch'][$currentModule])&&($_REQUEST['search_type']=='includesearch'||$_REQUEST['search_type']=='withoutsearch')){
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
			$advfilterlist = getAdvancedSearchCriteriaList($advft_criteria, $advft_criteria_groups, $currentModule);
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
$page_list_query=$queryGenerator->getQuery("",1);
$list_query = $queryGenerator->getQuery("",2);


$tablename=$focus->table_name;
$table_index=$focus->table_index;
$where = $queryGenerator->getConditionalWhere();

$params = array();
$search_type = $_REQUEST['search_type'];
$where=' where '.$tablename.'.deleted = 0 ';
if($search_type == 'includesearch') {
    $where = $queryGenerator->getWhereClause();
}
if($_REQUEST['idstring']!=''&&$search_type == 'selecteddata'&&$_REQUEST['idstring']!='all'){
    $_REQUEST['idstring']=rtrim($_REQUEST['idstring'],',');
    $idstring = explode(";", $_REQUEST['idstring']);
    $querywhere = ' and '.$tablename.'.'.$table_index.' in ('.implode(",",array_filter($idstring)).')';
    //array_push($params, $idstring);
}

if((!is_array($idstring)|| count($idstring)<=0)&&$search_type == 'selecteddata'&&$_REQUEST['idstring']!='all')$querywhere=" and 1<>1 ";

if($module!='InventoryAccount')
	$chart_owner=$queryGenerator->getSmOwnerSearchSql();  
if($_SESSION[$currentModule][$current_user->id]['export']['page_list_query'])
    $page_list_query=$_SESSION[$currentModule][$current_user->id]['export']['page_list_query'];
else
{
    $page_list_query=$page_list_query.$chart_owner.$FoSearchSQL.$querywhere.$querysearch;
   $_SESSION[$currentModule][$current_user->id]['export']['page_list_query']=$page_list_query;
}
 if(empty($order_by)&&$module=='InventoryAccount')
 {
    //28921: 库存流水账：导出，点击【其他仓库】页签，导出，结果导出了库存流水账中所有的数据了
    		$stockquery  = $queryGenerator->isStockQuery($module);
            $page_list_query.=$stockquery;
        
            
 }
 crm_load_class_file('cls_ExportListView','include/ListView/ExportListView');
$controller = new cls_ExportListView($adb, $current_user, $queryGenerator,'csv');

if(isset($skipAction)==false){
	$skipAction==false;
}
 //得到列头
 //print_r($list_result);
$listview_header = $controller->getListViewHeader($focus,$currentModule,$url_string,$sorder,$order_by,$skipAction);

foreach($listview_header as $key=>$arr){
    $listview_header[$key]=strip_tags($arr);
}


 $csv=new cls_PHPCsv();
$csv->setTitle(($currentModule));
$csv->SheetHeader = $listview_header;
if(!array_key_exists('exportgetcount',$_SESSION[$currentModule][$current_user->id]['export']))
{
    
    $listcounts_result = $adb->pquery($page_list_query, $params);
    $listcounts = $adb->num_rows($listcounts_result);
   
     $_SESSION[$currentModule][$current_user->id]['export']['listcounts']=$listcounts;
     $_SESSION[$currentModule][$current_user->id]['export']['exportgetcount']="##SUCCESS##". $listcounts;
       
    $csv->init();
}
else
{
    $csv->openfile();
}

 list($page_list_query,$order_by,$sorder) = $queryGenerator->customview->getOrderWhere($page_list_query);

 if(empty($order_by)&&$module=='InventoryAccount')
 {
    //28921: 库存流水账：导出，点击【其他仓库】页签，导出，结果导出了库存流水账中所有的数据了
    $order_by=' ld_warehousecondtions.id desc';
 }
$queryMode = (isset($_REQUEST['query']) && $_REQUEST['query'] == 'true');


$listcounts=$_SESSION[$currentModule][$current_user->id]['export']['listcounts'];
$prev_totalrows=0;

$nums =100;
$step = ceil($eachexportcount/$nums);

  if($startexportindex==0&&$startexportindex==$listcounts)
 {
   
    $objWriter->save($pathname); 
    unset($_SESSION[$currentModule][$current_user->id]['export']); 
    echo '<script>showExportResult();</script>';
 }
$progress_step=$page_width/$listcounts;
if($startexportindex<$listcounts)
{
       if(array_key_exists('exportprev_totalrows',$_SESSION[$currentModule][$current_user->id]['export']))
       {
                $prev_totalrows=$_SESSION[$currentModule][$current_user->id]['export']['exportprev_totalrows'];
       }
       for($s = 1; $s <= $step; ++$s) {

                $start = ($s - 1) * $nums+$startexportindex;
              $queryLIMIT =  ' LIMIT '.$start.','.$nums;
            if($currentModule=='InventoryAccount')
            {
                     $tmplist_query=$list_query." inner join ($page_list_query $queryLIMIT) as tmp
                     on tmp.id=$tablename.id order by $order_by";
            }
            else
            $tmplist_query=$list_query." inner join ($page_list_query $queryLIMIT) as tmp
                     on tmp.$table_index=$tablename.$table_index ";
            list($tmplist_query,$order_by,$sorder) = $queryGenerator->customview->getOrderWhere($tmplist_query);
           
            $list_result = $adb->pquery($tmplist_query, $params);
             
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
                 $tmprow=array();
                foreach($row as $index=>$content)
                {
                    $tmprow[]=mb_convert_encoding($content,"GBK","auto");
                }
                 fputcsv($csv->fp, $tmprow);
                  echo '<script> 
                       document.getElementById("dvctimedescription").innerHTML="正在导出第'.($key+1+$prev_totalrows).'条数据"
                       document.getElementById("dv").innerHTML="共'.$listcounts.'条数据";
                       document.getElementById("dvExportprogress").style.width = "'.$cur_progress_step.'px"</script>';
                  ob_flush();
                  flush();
            }
             
             //$csv->addSheetBody($listview_entries);
             
              $prev_totalrows+= $rows;
              unset($listview_entries);
              
     }
      
    $_SESSION[$currentModule][$current_user->id]['export']['total_list_query']="$list_query inner join ($page_list_query  $querywhere $orderby ) as tmp on tmp.$focus->table_index=$focus->table_name.$focus->table_index $where  $orderby";
    $_SESSION[$currentModule][$current_user->id]['export']['list_query']="$list_query inner join ($page_list_query  $querywhere $orderby ) as tmp on tmp.$focus->table_index=$focus->table_name.$focus->table_index $where  $orderby";
    $_SESSION[$currentModule][$current_user->id]['export']['exportprev_totalrows']=$prev_totalrows;
    $_SESSION[$currentModule][$current_user->id]['export']['cur_progress_step']=$cur_progress_step;
   $tmptmp=$startexportindex+$eachexportcount;
    ob_flush();
    ob_clean();
     if($tmptmp<$listcounts)
    {
         fclose($csv->fp);
         echo '<script type="text/javascript">';
         echo "document.forms['Export_Records'].submit();";
        echo '</script>';

    }
    else
    {
           
          
           $query=$_SESSION[$currentModule][$current_user->id]['export']['list_query'];
         $total_query=$_SESSION[$currentModule][$current_user->id]['export']['total_list_query'];
         crm_load_class_file('clsTotal_ExportList','include/ListView/ExportListView');
        $clstotalobj=new clsTotal_ExportList($controller);
    
        $totalfldhtml = $clstotalobj->getTotalFldCount($page_list_query,$list_result,$listcounts);
      
       $headerlistfields=$controller->listViewFields;
            
            if(!empty($totalfldhtml)&&is_array($totalfldhtml)&&sizeof(array_keys($totalfldhtml))>0)
            {
                    $tmprows=array();
                    foreach($headerlistfields as $key=>$value)
                    {
                        $tmprows[$key]="";
                    }
                    
                    foreach($totalfldhtml as $key=>$value)
                    {
                        $value = str_replace('&yen;','¥',strip_tags($value)); 
                        
                        $tmprows[$key]=mb_convert_encoding($value,"GBK","auto");
                    }
                    
                    
                     fputcsv($csv->fp, $tmprows);
            }
            fclose($csv->fp);
          
            unset($_SESSION[$currentModule][$current_user->id]['export']);
           echo '<script>showExportResult();</script>';
         
      }

}
else
{
    
}
  
?>