<?php
/**
 * 更新操作
 * edit:andrew
 * date:20140126
 * reason:导出模板文件
 * */
global $adb;
set_time_limit(0);
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global  $currentModule, $theme;

global $current_user;
if($_REQUEST['exportformat']=='exportcsv')
{
    //导出csv格式
    include(globalStatic::$root_directory."modules/lingdang/ExportInventoryCSV.php");
    exit();
}
require_once(globalStatic::$root_directory.'include/ListView/ListViewSession.php');
require_once(globalStatic::$root_directory."modules/$currentModule/$currentModule.php");
crm_load_class_file('ProductDetails',"include/ProductDetails");
require(globalStatic::$root_directory.'user_privileges/user_privileges_'.$current_user->id.'.php');
include(globalStatic::$root_directory.'PHPExcel/PHPExcel.php');
$pathname='storage/'.$current_user->id.'_'.$currentModule.'.xls';

$smarty=new lingdangCRM_Smarty();
if($_SESSION[$currentModule][$current_user->id]['export']['startexportindex'])
    $startexportindex=$_SESSION[$currentModule][$current_user->id]['export']['startexportindex'];
else
{
    $startexportindex=0;
}
$eachexportcount=10000;//每次导出的记录数量为500
if($startexportindex<=0)
{
    $startexportindex=0;
   
}

$_SESSION[$currentModule][$current_user->id]['export']['startexportindex']=$startexportindex+$eachexportcount;
if($_SESSION[$currentModule][$current_user->id]['export']['listcounts'])
{
    $listcounts=$_SESSION[$currentModule][$current_user->id]['export']['listcounts'];
}

$smarty->assign("STARTEXPORTINDEX",100);
$smarty->assign("MODULE",$currentModule);
$page_width= 559;
$smarty->assign("PAGEWIDTH",$page_width);

$smarty->assign("EXPORTFORMAT",'exportexcel');    
$smarty->display('ExportRecords.tpl');


if(array_key_exists('objphpexcel',$_SESSION[$currentModule][$current_user->id]['export']))
{
    $objPHPExcel =PHPExcel_IOFactory::load($pathname);
  
}
else
{
    $objPHPExcel = new PHPExcel();
    $_SESSION[$currentModule][$current_user->id]['export']['objphpexcel']=serialize($objPHPExcel);

}
 $objWriter = PHPExcel_IOFactory::createWriter($objPHPExcel, 'Excel5');
$objPHPExcel->setActiveSheetIndex(0);
$activesheet=$objPHPExcel->getActiveSheet();
$moduleName = $currentModule;
if(!array_key_exists('objphpexcel',$_SESSION[$currentModule][$current_user->id]['export']))
{

    $modulelabel = getTranstab($moduleName);
    $modulelabel = str_replace(' ','_',$modulelabel);
    $modulelabel = str_replace('/','_',$modulelabel);
    $modulelabel = str_replace('\\','_',$modulelabel);
    $modulelabel = str_replace('?','_',$modulelabel);
    $modulelabel = str_replace('[','(',$modulelabel);
    $modulelabel = str_replace(']',')',$modulelabel);
    $objPHPExcel->getActiveSheet()->setTitle($modulelabel);
    
}




$category = getParentTab();
$warehouseid = 0;
$morelist = 0;
$url_string = '';


$focus = CRMEntity::getInstance($currentModule);

$sorder = $focus->getSortOrder();
$order_by = $focus->getOrderBy();

$_SESSION[$currentModule."_Order_By"] = $order_by;
$_SESSION[$currentModule."_Sort_Order"]=$sorder;
$morelist = 1;

// Custom View
$customView = new CustomView($currentModule);

$viewid = $customView->getViewId($currentModule);

$queryGenerator = QueryGenerator::getInstance($currentModule, $current_user);

if(isset($_SESSION['LiveViewSearch'][$currentModule])){
	$input = $_SESSION['LiveViewSearch'][$currentModule]['input'];
	global $search_session;
	$search_session = 1;
	if($input['searchtype'] == 'BasicSearch'){
		if(!empty($input['search_text'])){
			$_REQUEST['search_field'] = $input['search_field'];
			$_REQUEST['search_text'] = $input['search_text'];
			$_REQUEST['SearchScope'] = $input['SearchScope'];
			$_REQUEST['searchtype'] = $input['searchtype'];
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
		}else{
			$search_session = 0;
			unset($_SESSION['LiveViewSearch'][$currentModule]);
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
     $queryGenerator->addUserSearchConditions($_REQUEST);
	//$ustring = getSearchURL($_REQUEST);
	//$url_string .= "&query=true$ustring";
	
   
}
$list_query = $queryGenerator->getQuery('',2);//所有数据查询
$page_list_query=$queryGenerator->getQuery('',1);//分页查询语句

$where = $queryGenerator->getConditionalWhere();

// Sorting
$params = array();
$search_type = $_REQUEST['search_type'];

$where=' where  '.$focus->table_name.'.deleted=0';
if($search_type == 'includesearch') {
 $where = $queryGenerator->getWhereClause();
 //echo $where;die;
}
if($search_type == 'selecteddata'&&$_REQUEST['idstring']!='all'){
    $_REQUEST['idstring']=rtrim($_REQUEST['idstring'],',');
    $idstring = explode(";", $_REQUEST['idstring']);
 
    $querywhere = ' and '.$focus->table_name.'.'.$focus->table_index.' in ('.implode(",",array_filter($idstring)).')';

    //array_push($params, $idstring);
}
if(((!is_array($idstring)|| count($idstring)<=0)&&$search_type == 'selecteddata')&&$_REQUEST['idstring']!='all')$querywhere=" and 1<>1 ";

$chart_owner=$queryGenerator->getSmOwnerSearchSql();  
if($_SESSION[$currentModule][$current_user->id]['export']['page_list_query'])
    $page_list_query=$_SESSION[$currentModule][$current_user->id]['export']['page_list_query'];
else
{
    $page_list_query=$page_list_query.$chart_owner.$FoSearchSQL.$querywhere.$querysearch;
  $_SESSION[$currentModule][$current_user->id]['export']['page_list_query']=$page_list_query;
}

$queryMode = (isset($_REQUEST['query']) && $_REQUEST['query'] == 'true');
$customsortorder = $customView->getCustomViewOrderBy($viewid);
$where= $queryGenerator->getWhereClause();
$orderby = " ORDER BY $customsortorder $focus->table_name.$focus->table_index desc";
$list_query=$list_query." inner join ( $page_list_query   ) as temp on temp.$focus->table_index=$focus->table_name.$focus->table_index $where";

$list_count_sql= $page_list_query;
if(!array_key_exists('exportgetcount',$_SESSION[$currentModule][$current_user->id]['export']))
{
     $detail_result = $adb->pquery($list_query, $params);
    $detailcounts = $adb->num_rows($detail_result);       
    
    $listcounts_result = $adb->pquery($list_count_sql, $params);
    $listcounts = $adb->num_rows($listcounts_result);       
    $_SESSION[$currentModule][$current_user->id]['export']['listcounts']=$listcounts;
    $_SESSION[$currentModule][$current_user->id]['export']['detailcount']=$detailcounts;
    
     $_SESSION[$currentModule][$current_user->id]['export']['exportgetcount']="##SUCCESS##". $listcounts.'details'.$detailcounts;
       
    
}
$listcounts=$_SESSION[$currentModule][$current_user->id]['export']['listcounts'];
 $smarty->assign("TOTALEXPORTCOUNT",$_SESSION[$currentModule][$current_user->id]['export']['listcounts']);
 $smarty->assign("TOTALEXPORTDETAILCOUNT",$_SESSION[$currentModule][$current_user->id]['export']['detailcount']);
     
crm_load_class_file('ExportProductDetailController','include/ListView');
$controller = new ExportProductDetailController($adb, $current_user, $queryGenerator,'excel');

if(isset($skipAction)==false){
	$skipAction==false;
}
 list($page_list_query,$order_by,$sorder) = $queryGenerator->customview->getOrderWhere($page_list_query);

 //得到列头
        $listview_header = $controller->getListViewHeader($focus,$currentModule,$url_string,$sorder,$order_by,$skipAction);
        
        foreach($listview_header as $key=>$arr){
            if($arr=='税种'||$arr=='Tax Type'){
                $checkkey=$key;
            }
            if(isset($checkkey)){
                $listview_header[$key]=$listview_header[$key+1];
            } 
        }
        
        foreach($listview_header as $key=>$arr){
            $listview_header[$key]=strip_tags($arr);
        }
        
        foreach($listview_header as $key=>$arr){
            $activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex($key).'1',trim($arr));
        }

$list_query = $queryGenerator->getQuery('',2);//所有数据查询
$prev_totalrows=0;
$nums=100;//每次获取的记录数量
$step=$eachexportcount/$nums;

$progress_step=if(!empty($_SESSION[$currentModule][$current_user->id]['export']['detailcount']))
    $progress_step=$page_width/$_SESSION[$currentModule][$current_user->id]['export']['detailcount'];
else
    $progress_step=0;;
if(array_key_exists('exportprev_totalrows',$_SESSION[$currentModule][$current_user->id]['export']))
{
        $prev_totalrows=$_SESSION[$currentModule][$current_user->id]['export']['exportprev_totalrows'];
}
 crm_load_class_file("cls_excelImage",'include');
 $excelimageobj=new cls_excelImage();
   if($startexportindex==0&&$startexportindex==$listcounts)
 {
   
    $objWriter->save($pathname); 
    unset($_SESSION[$currentModule][$current_user->id]['export']); 
    echo '<script>showExportResult();</script>';
 }
if($startexportindex<$listcounts)
{
    //230530 wym 图片字段添加超链接
    $sql="select crm_address from ld_organizationdetails";
    $result = $adb->pquery($sql, array());
    $organization_crm_address = $adb->query_result($result,0,'crm_address');
          for($s=1;$s<=$step;$s++)
          {
               $start=($s-1)*$nums+$startexportindex;
         	   $queryLIMIT = ' LIMIT '.$start.','.$nums;
                
               $tmplist_query="$list_query inner join ($page_list_query   $queryLIMIT) as tmp on tmp.$focus->table_index=$focus->table_name.$focus->table_index $where  ";
               list($tmplist_query,$order_by,$sorder) = $queryGenerator->customview->getOrderWhere($tmplist_query,"",$queryGenerator);
            
           
               $list_result = $adb->pquery($tmplist_query, $params);
               $rows=$adb->num_rows($list_result);
               if($rows<=0)
               {
                break;
               }
                $nextrows=$start+$rows;
              //  unset($_SESSION[$currentModule][$current_user->id]['export']);
               $listview_entries = $controller->getListViewEntries($focus,$currentModule,$list_result,$navigation_array,$skipAction,true,'export');
               $headerlistfields=$controller->listViewFields;
               
             
                $a=2;
                //居中显示
                $objPHPExcel->getDefaultStyle()->getAlignment()->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_CENTER);
                $objPHPExcel->getDefaultStyle()->getAlignment()->setVertical(PHPExcel_Style_Alignment::VERTICAL_CENTER);
                foreach($listview_entries as $key=>$arr)
                {
                                
                        foreach($arr as $key2=>$arr2){
                            
                            $fieldname=$headerlistfields[$key2];
                            $fieldinfo=$controller->getListViewFieldobj($key2,$fieldname);
                            
                            
                            if($fieldinfo->isImageField()=="yes")
                            {
                                
                                $excelimageobj->setCellImage($objPHPExcel,$arr2,$key+$a+$prev_totalrows,$key2,$activesheet,$organization_crm_address);
                                
                                
                            }
                            else
                            {
                                if($fieldinfo&&($fieldinfo->istotalFldMoneyField()))
                                {
                                    $activesheet->setCellValueExplicit(PHPExcel_Cell::stringFromColumnIndex($key2).($key+$a+$prev_totalrows), trim($arr2),PHPExcel_Cell_DataType::TYPE_NUMERIC);
                                    if($fieldinfo->isAmountorCurrencyField()){
                                        //设置单元格为数值型，并设置对应小数位数
                                        $tmparr2 = explode('.',$arr2);
                                        $tmpFormatCode = '0';
                                        if(count($tmparr2)>1){
                                            $tmpFormatCode = "".setNumberFormatEmptySeperator(0,strlen($tmparr2[1]))."";
                                        }
                                        $activesheet->getStyle(PHPExcel_Cell::stringFromColumnIndex($key2).($key+$a+$prev_totalrows))->getNumberFormat()->setFormatCode('0');
                                    }
                                }
                                else
                                    $activesheet->setCellValueExplicit(PHPExcel_Cell::stringFromColumnIndex($key2).($key+$a+($prev_totalrows)), trim($arr2),PHPExcel_Cell_DataType::TYPE_STRING);

                            }
                            
                        
                        }
                        //$key是从0开始的所以要加1
                        $cur_progress_step=($key+1+$prev_totalrows)*$progress_step;
                        if($cur_progress_step>$page_width)
                         {
                            $cur_progress_step=$page_width;
                         }
                       
                       //$key是从0开始的，所以要加1
                        echo '<script> 
                               document.getElementById("dvctimedescription").innerHTML="正在导出第'.($key+$prev_totalrows+1).'条数据"
                               document.getElementById("dv").innerHTML="共'.$listcounts.'条数据，明细'.($_SESSION[$currentModule][$current_user->id]['export']['detailcount']).'";
                               document.getElementById("dvExportprogress").style.width = "'.$cur_progress_step.'px"</script>';
                        
                        ob_flush(); 
                        flush(); 
                              
                }
                
                $prev_totalrows+= $rows;//明细
                
                unset($listview_entries);
          }
    

          /* */
            
            $_SESSION[$currentModule][$current_user->id]['export']['total_list_query']="$list_query inner join ($page_list_query    ) as tmp on tmp.$focus->table_index=$focus->table_name.$focus->table_index $where  $orderby";
            $_SESSION[$currentModule][$current_user->id]['export']['list_query']="$list_query inner join ($page_list_query    ) as tmp on tmp.$focus->table_index=$focus->table_name.$focus->table_index $where  $orderby";
            $_SESSION[$currentModule][$current_user->id]['export']['exportprev_totalrows']=$prev_totalrows;
           
            ob_flush();
            ob_clean();
            
      $tmptmp=$startexportindex+$eachexportcount;
   
     
     if($tmptmp<$listcounts)
    {
        $objWriter->save($pathname);  
         echo '<script type="text/javascript">';
         echo "document.forms['Export_Records'].submit();";
        echo '</script>';

    }
    else
    {
       
     
        $headerlistfields=$controller->listViewFields;
        
         foreach($listview_header as $key=>$arr)//设置数字列和金额列的宽度
         {
            $fieldname=$headerlistfields[$key];
            $fieldinfo=$controller->getListViewFieldobj($key,$fieldname);
            if($fieldinfo&&($fieldinfo->istotalFldMoneyField()))
            {
                $tmp= PHPExcel_Cell::stringFromColumnIndex($key);
                $objPHPExcel->getActiveSheet()->getColumnDimension($tmp)->setWidth(12);
            }
         }
       
         $query=$_SESSION[$currentModule][$current_user->id]['export']['list_query'];
    
          // $list_result=$adb->pquery($query);
          $total_query=$_SESSION[$currentModule][$current_user->id]['export']['total_list_query'];
      
             crm_load_class_file('clsTotal_ExportList','include/ListView/ExportListView');
            $clstotalobj=new clsTotal_ExportList($controller);
            $totalfldhtml = $clstotalobj->getTotalFldCount($page_list_query,$list_result,$listcounts);
     
            if(!empty($totalfldhtml))
            {
                 
                 $_SESSION[$currentModule][$current_user->id]['export']['totalfldhtml']=$totalfldhtml;
                 $maxkey=$_SESSION[$currentModule][$current_user->id]['export']['exportprev_totalrows'];
                
                if(is_array($totalfldhtml)&&sizeof(array_keys($totalfldhtml))>0)
                    foreach($totalfldhtml as $key=>$arr){
                        $arr = str_replace('&yen;','¥',strip_tags($arr)); 
                        $activesheet->setCellValueExplicit(PHPExcel_Cell::stringFromColumnIndex($key).($maxkey+2), trim($arr),PHPExcel_Cell_DataType::TYPE_STRING);
                    }
                  
            }
          
            $objWriter->save($pathname);  
            unset($_SESSION[$currentModule][$current_user->id]['export']);
            echo '<script>showExportResult();</script>';
     
    }
    
}
else
{ 
 
   
     $query=$_SESSION[$currentModule][$current_user->id]['export']['list_query'];
      $total_query=$_SESSION[$currentModule][$current_user->id]['export']['total_list_query'];
  
         crm_load_class_file('clsTotal_ExportList','include/ListView/ExportListView');
        $clstotalobj=new clsTotal_ExportList($controller);
        $totalfldhtml = $clstotalobj->getTotalFldCount($page_list_query,$list_result,$listcounts);
 
        if(!empty($totalfldhtml))
        {
             
             $_SESSION[$currentModule][$current_user->id]['export']['totalfldhtml']=$totalfldhtml;
             $maxkey=$_SESSION[$currentModule][$current_user->id]['export']['exportprev_totalrows'];
            
           
            
            if(is_array($totalfldhtml)&&sizeof(array_keys($totalfldhtml))>0)
                foreach($totalfldhtml as $key=>$arr){
                    $arr = str_replace('&yen;','¥',strip_tags($arr)); 
                    $activesheet->setCellValueExplicit(PHPExcel_Cell::stringFromColumnIndex($key).($maxkey+2), trim($arr),PHPExcel_Cell_DataType::TYPE_STRING);
                }
              
        }

        $objWriter->save($pathname);  
    
    unset($_SESSION[$currentModule][$current_user->id]['export']);
    $_REQUEST['frommodule']=$currentModule;
    include(globalStatic::$root_directory.'modules/uploads/downloadxls.php');
    //header("Location:http://localhost/ldcrm/index.php?module=uploads&action=downloadxls&frommodule="+$currentModule);
    
}

exit();
?>