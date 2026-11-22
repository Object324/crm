<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global  $currentModule, $theme;
global $list_max_entries_per_page_new;
global $current_user;
require_once("modules/$currentModule/$currentModule.php");
require('user_privileges/user_privileges_'.$current_user->id.'.php');
crm_load_class_file("ListViewSession",'include/ListView');
include(globalStatic::$root_directory."include/cls_PHPCsv.php");
set_time_limit(0);
unset($_REQUEST['search_field']);
unset($_REQUEST['search_text']);
unset($_REQUEST['SearchScope']);
unset($_REQUEST['searchtype']);
unset($_REQUEST['type']);
unset($_REQUEST['advft_criteria']);
unset($_REQUEST['advft_criteria_groups']);
unset($_REQUEST['SearchScope']);
unset($_REQUEST['searchtype']);


$startexportindex=$_REQUEST['startexportrow'];
$endexportrow=$_REQUEST['endexportrow'];

$eachexportcount=$endexportrow-$startexportindex;//每次导出的记录数量50

if($startexportindex<=0)
{
    $startexportindex=0;
   
}

$_SESSION[$currentModule][$current_user->id]['export']['startexportindex']=$startexportindex+$eachexportcount;
if($_SESSION[$currentModule][$current_user->id]['export']['listcounts'])
{
    $listcounts=$_SESSION[$currentModule][$current_user->id]['export']['listcounts'];
    $detailcounts=$_SESSION[$currentModule][$current_user->id]['export']['detailcounts'];
}


$category = getParentTab();
$warehouseid = 0;
$url_string = '';
$stockquery = '';

$focus = CRMEntity::getInstance($currentModule);
if(ListViewSession::hasViewChanged($currentModule,$viewid)) {
	$_SESSION[$currentModule."_Order_By"] = '';
}

/**
*edit:diony
*time:2014-05-21
*reson:转换成大写
*/
$sorder = strtoupper($focus->getSortOrder());
if(isset($_REQUEST['order_by'])&&$_REQUEST['order_by']!='')
{
    $order_by=$_REQUEST['order_by'];
}
else
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

$queryGenerator = QueryGenerator::getInstance($currentModule, $current_user,$customView);
/**
 * query_session=1时，读取session中的搜索条件，否则将清空session
 * 查看页面返回列表、列表编辑之后保存 返回列表时，返回query_session=1的参数
 * @project 序时簿查询记住搜索条件
 * @author Tujt 2014-04-25
 */
if(isset($_SESSION['LiveViewSearch'][$currentModule])&&($_REQUEST['search_type']=='includesearch'||$_REQUEST['search_type']=='withoutsearch'||$_REQUEST['search_type']=='selecteddata')){
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
	}else if($input['searchtype'] == 'advance'||$input['searchtype'] == 'tiled'){
		if(!empty($input['advft_criteria']) && $input['advft_criteria'] != '[]'){
			$_REQUEST['advft_criteria'] = $input['advft_criteria'];
			$_REQUEST['advft_criteria_groups'] = $input['advft_criteria_groups'];
			$_REQUEST['SearchScope'] = $input['SearchScope'];
			$_REQUEST['searchtype'] = $input['searchtype'];
            $tmpurl = $_SESSION['LiveViewSearch'][$currentModule]['url'];
            if(strpos($tmpurl,'&tag_search=true')===false)
            {
                
            }
            else
            {
                $_REQUEST['tag_search'] = 'true';
            }
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
		}
	}else if($_REQUEST['searchtype'] == 'advance'){
		$_REQUEST['advft_criteria'] = trim($_REQUEST['advft_criteria']);
		if(!empty($_REQUEST['advft_criteria']) && $_REQUEST['advft_criteria'] != '[]'){
			$input['advft_criteria'] = $_REQUEST['advft_criteria'];
			$input['advft_criteria_groups'] = trim($_REQUEST['advft_criteria_groups']);
			$input['SearchScope'] = trim($_REQUEST['SearchScope']);
			$input['searchtype'] = trim($_REQUEST['searchtype']);
		}
	}
	$ustring = getSearchURL($_REQUEST);
	$url_string .= "&query=true$ustring";
	if(!empty($input)){
		$_SESSION['LiveViewSearch'][$currentModule]['input'] = $input;
		$_SESSION['LiveViewSearch'][$currentModule]['url'] = $url_string;
	}
}
$page_list_query = $queryGenerator->getQuery("",1);
$list_query = $queryGenerator->getQuery("",2);

$where = $queryGenerator->getConditionalWhere();

$params = array();
$search_type = $_REQUEST['search_type'];

$where=' where  '.$focus->table_name.'.deleted=0';
if($search_type == 'includesearch') {
    $where = $queryGenerator->getWhereClause();
}
if($_REQUEST['idstring']!=''&&$search_type == 'selecteddata'&&$_REQUEST['idstring']!='all'){
    $_REQUEST['idstring']=rtrim($_REQUEST['idstring'],',');
    $idstring = explode(";", $_REQUEST['idstring']);
    $querywhere = ' and '.$focus->table_name.'.'.$focus->table_index.' in ('.implode(",",array_filter($idstring)).')';
  

}

if((!is_array($idstring)|| count($idstring)<=0)&&$search_type == 'selecteddata'&&$_REQUEST['idstring']!='all')$querywhere=" and 1<>1 ";
$chart_owner=$queryGenerator->getSmOwnerSearchSql();  
if($_SESSION[$currentModule][$current_user->id]['export']['page_list_query'])
    $page_list_query=$_SESSION[$currentModule][$current_user->id]['export']['page_list_query'];
else
{
    //$chart_owner:edit:can 2020-09-10 ,开启用户界面汇报人，非管理员导出的的文件没有数据
    $page_list_query=$page_list_query.$FoSearchSQL.$querywhere.$querysearch;
    $_SESSION[$currentModule][$current_user->id]['export']['page_list_query']=$page_list_query;
}
    

$queryMode = (isset($_REQUEST['query']) && $_REQUEST['query'] == 'true');
$start = ListViewSession::getRequestCurrentPage($currentModule, $list_query, $viewid, $queryMode);

//echo $list_query. " OFFSET $limit_start_rec LIMIT $list_max_entries_per_page_new";
crm_load_function_file('VT_getSimpleNavigationValues','include/utils','ListViewUtils');
$navigation_array = VT_getSimpleNavigationValues($start,$list_max_entries_per_page_new,$noofrows);;
$limit_start_rec = ($start-1) * $list_max_entries_per_page_new;

$list_query=$list_query." inner join ( $page_list_query  ) as temp on temp.$focus->table_index=$focus->table_name.$focus->table_index $where";
crm_load_class_file('ExportTabDetailController','include/ListView');
$controller = new ExportTabDetailController($adb, $current_user, $queryGenerator,$currentModule,'csv');

if(isset($skipAction)==false){
	$skipAction=false;
}

//得到列头
$listview_header = $controller->getListViewHeader($focus,$currentModule,$url_string,$sorder,$order_by,$skipAction);

foreach($listview_header as $key=>$arr){
    $listview_header[$key]=strip_tags($arr);
}

//zkt 20220909 XUQIU1000234 带分录和带产品分录的表单，导出弹出层中增加“导出样式”参数（胡斐） 
$groupby = '';
if($_REQUEST['export_style']=='onlycolheader'){
    //仅显示单据头字段（一行）
    $groupby = $queryGenerator->getGroupBy();
}
$csv=new cls_PHPCsv();
$csv->setTitle($currentModule);
$csv->SheetHeader = $listview_header;
if(!array_key_exists('exportgetcount',$_SESSION[$currentModule][$current_user->id]['export']))
{
       $list_query_detail=str_ireplace(' distinct '," ",$page_list_query);
      $detail_result = $adb->pquery($list_query_detail, $params);
    $detailcounts = $adb->num_rows($detail_result);      
    $listcounts_result = $adb->pquery($page_list_query, $params);
    $listcounts = $adb->num_rows($listcounts_result);
   $_SESSION[$currentModule][$current_user->id]['export']['detailcount']=$detailcounts;
     $_SESSION[$currentModule][$current_user->id]['export']['listcounts']=$listcounts;
     $_SESSION[$currentModule][$current_user->id]['export']['exportgetcount']="##SUCCESS##". $listcounts.'details'.$detailcounts;

    $csv->init();
}
else
{
    $csv->openfile();
}

$listcounts=$_SESSION[$currentModule][$current_user->id]['export']['listcounts'];
$detailcounts=$_SESSION[$currentModule][$current_user->id]['export']['detailcount'];

list($page_list_query,$order_by,$sorder) = $queryGenerator->customview->getOrderWhere($page_list_query);


$where=$queryGenerator->getWhereClause();
$list_query = $queryGenerator->getQuery('',2);//所有数据查询
$prev_totalrows=0;
if(empty($detailcounts))
{
    $progress_step=0;
}
else
$progress_step=$page_width/$detailcounts;

$nums =$eachexportcount/2;
$step = $eachexportcount/$nums;
if($startexportindex==0&&$startexportindex==$listcounts)
 {
   
  //  $objWriter->save($pathname); 
    unset($_SESSION[$currentModule][$current_user->id]['export']); 
     $ret_arr['startexportrow']=$startexportindex;
      $ret_arr['endexportrow']=$endexportrow;
      $ret_arr['listcount']=-1;
      $ret_arr['detailcount']=-1;
    //$ret_arr['title']=getTranstab($currentModule).'>>'. getFixedLabel('EXPORTDATATITLE');
     global $languageType;
     if($languageType == 'en') {
         $ret_arr['title'] = getFixedLabel("EXPORT") .' '. getTranstab($currentModule);
     }
     else{
         $ret_arr['title'] = getFixedLabel("EXPORT") . getTranstab($currentModule);
     }
    ConvertTojsonString(1,$ret_arr,'success');
 }

 if(!empty($_SESSION[$currentModule][$current_user->id]['export']['detailcount']))
    $progress_step=$page_width/$_SESSION[$currentModule][$current_user->id]['export']['detailcount'];
else
    $progress_step=0;;
if($startexportindex<$listcounts)
{
        if(array_key_exists('exportprev_totalrows',$_SESSION[$currentModule][$current_user->id]['export']))
       {
            $prev_totalrows=$_SESSION[$currentModule][$current_user->id]['export']['exportprev_totalrows'];
       }
         for($s=1;$s<=$step;$s++)
         {
            $start=($s-1)*$nums+$startexportindex;
            $queryLIMIT = ' LIMIT '.$start.','.$nums;
            $tmplist_query="$list_query inner join ($page_list_query   $queryLIMIT) as tmp on tmp.$focus->table_index=$focus->table_name.$focus->table_index $where  ";
            $list_result=$adb->pquery($tmplist_query);
            $rows=$adb->num_rows($list_result);
              if($rows<=0)
              {
                break;
              }
                
              $nextrows=$start+$rows;
              $listview_entries = $controller->getListViewEntries($focus,$currentModule,$list_result,$navigation_array,$skipAction,true,'export');
            $tmprow=array();
            foreach($listview_entries as $key=>$row)
            {
               $tmprow=array();
                 foreach($row as $index=>$content)
                {
                    if(isKehu001ServerPc()=='yes'){
                         //https://work.weixin.qq.com/api/doc/90001/90143/91889,
                         //目前只支持txt,csv,xls,xlsx,doc,docx文件格式，且文件内容必须为utf8编码
                         $tmprow[]=mb_convert_encoding($content,"UTF-8","auto");
                    }
                    else
                        $tmprow[]=mb_convert_encoding($content,"GBK","auto");
                }
                 fputcsv($csv->fp, $tmprow);
                    
            }
              $prev_totalrows+=$rows;  
              unset($listview_entries);
         }
    $_SESSION[$currentModule][$current_user->id]['export']['total_list_query']="$list_query inner join ($page_list_query  $querywhere $orderby ) as tmp on tmp.$focus->table_index=$focus->table_name.$focus->table_index $where  $orderby";
    $_SESSION[$currentModule][$current_user->id]['export']['list_query']="$list_query inner join ($page_list_query  $querywhere $orderby ) as tmp on tmp.$focus->table_index=$focus->table_name.$focus->table_index $where  $orderby";
    $_SESSION[$currentModule][$current_user->id]['export']['exportprev_totalrows']=$prev_totalrows;
    
   $tmptmp=$startexportindex+$eachexportcount;
   if($tmptmp<$listcounts)
    {
        
         

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
                        if(isKehu001ServerPc()=='yes'){
                            //https://work.weixin.qq.com/api/doc/90001/90143/91889,
                            //目前只支持txt,csv,xls,xlsx,doc,docx文件格式，且文件内容必须为utf8编码
                             $tmprows[$key]=mb_convert_encoding($value,"UTF-8","auto");
                        }
                        else
                            $tmprows[$key]=mb_convert_encoding($value,"GBK","auto");
                    }
                    
                    
                     fputcsv($csv->fp, $tmprows);
                    

            }
           
         unset($_SESSION[$currentModule][$current_user->id]['export']);
        
     
    }
     fclose($csv->fp);
    include(globalStatic::$root_directory.'modules/lingdang/Export/ExportProgressDescription.php');
    $ret_arr['timedescription']=$time_description;
    $ret_arr['content']=$progresshtml;
   
    $ret_arr['startexportrow']=$startexportindex;
    $ret_arr['endexportrow']=$endexportrow;
    $ret_arr['listcount']=$listcounts;
    //$ret_arr['writefilelabel']=getFixedLabel('WRITEEXCELFILE');
    $ret_arr['detailcount']=$detailcounts;
    //$ret_arr['title']=getTranstab($currentModule).'>'. getFixedLabel('EXPORTDATATITLE');
    global $languageType;
    if($languageType == 'en') {
        $ret_arr['title'] = getFixedLabel("EXPORT") .' '. getTranstab($currentModule);
    }
    else{
        $ret_arr['title'] = getFixedLabel("EXPORT") . getTranstab($currentModule);
    }
    ConvertTojsonString(1,$ret_arr,'success');

}

?>