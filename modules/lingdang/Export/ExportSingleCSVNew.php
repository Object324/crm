<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
///不带明细数据导出
global  $currentModule, $theme;

global $current_user;
$_REQUEST['diony']='yes';


crm_load_class_file("ListViewSession",'include/ListView');
include(globalStatic::$root_directory."include/cls_PHPCsv.php");
set_time_limit(0);

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
    $cur_progress_step=$_SESSION[$currentModule][$current_user->id]['export']['cur_progress_step'];
}
else
{
    $cur_progress_step=0;
    $listcounts=0;
}




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
if( isset($_SESSION['LiveViewSearch'][$currentModule])&&($_REQUEST['search_type']=='includesearch'||$_REQUEST['search_type']=='withoutsearch'||$_REQUEST['search_type']=='selecteddata')){
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
    $page_list_query=$page_list_query.$querywhere.$querysearch;
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
$bool_opertionbutton=$controller->haveExistsOperationHeader(getTabid($currentModule));

if($bool_opertionbutton=='yes')
        array_pop($listview_header);
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
$detailcounts=$listcounts;
$nums =$eachexportcount/2;
$step = ceil($eachexportcount/$nums);

 
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
                    //ls 2022-07-14 1000072 “手写签名”字段可放在单据列表，也支持导出图片（导出CSV格式，潘露露说可以用逗号(,)拼接显示）
                    $fieldname=$controller->listViewFields[$index];
                    $fieldinfo=$controller->getListViewFieldobj($index,$fieldname);
                    if($fieldinfo&&$fieldinfo->getUIType()==222)
                    {
                        $content = $content['imagepath'].','.$content['datetime'];
                    }

                    if(isKehu001ServerPc()=='yes'){
                            $tmprow[]=mb_convert_encoding($content,"UTF-8","auto");
                        }
                    else
                            $tmprow[]=mb_convert_encoding($content,"GBK","auto");
                }
                 fputcsv($csv->fp, $tmprow);
                 
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
  
     if($tmptmp<$listcounts)
    {
         fclose($csv->fp);
        

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
                        $value = preg_replace('/="([^"]+)"/', '$1', $value);
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
            fclose($csv->fp);
          unset($_SESSION[$currentModule][$current_user->id]['export']); 
         
           
         
      }
        include(globalStatic::$root_directory.'modules/lingdang/Export/ExportProgressDescription.php');
        $ret_arr['timedescription']=$time_description;
      $ret_arr['content']=$progresshtml;
      $ret_arr['startexportrow']=$startexportindex;
      $ret_arr['endexportrow']=$endexportrow;
      $ret_arr['listcount']=$listcounts;
      $ret_arr['detailcount']=$listcounts;
      //$ret_arr['writefilelabel']=getFixedLabel('WRITEEXCELFILE');
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
else
{
    
}
  
?>