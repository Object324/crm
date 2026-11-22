<?php
/**
 * 更新操作
 * edit:andrew
 * date:20140126
 * reason:导出模板文件
 * */
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb;
set_time_limit(0);
global  $currentModule, $theme;

global $current_user;

$_REQUEST['diony']='yes';
if($_REQUEST['getprogress']=='yes')
{
      crm_load_class_file("LoginHistory",'modules/Users');
    $historyobj=new LoginHistory();
    $historyobj->user_operation_history('Export',$currentModule);
     include(globalStatic::$root_directory.'modules/lingdang/Export/ExportProgressHtml.php');

}
if($_REQUEST['exportformat']=='exportcsv')
{
    //导出csv格式
    
    include(globalStatic::$root_directory."modules/lingdang/Export/ExportInventoryCSVNew.php");
    exit();
}
crm_load_class_file("ListViewSession",'include/ListView');
require_once(globalStatic::$root_directory."modules/$currentModule/$currentModule.php");
crm_load_class_file('ProductDetails',"include/ProductDetails");
require(globalStatic::$root_directory.'user_privileges/user_privileges_'.$current_user->id.'.php');
include(globalStatic::$root_directory.'PHPExcel/PHPExcel.php');
$pathname='storage/'.$current_user->id.'_'.$currentModule.'.xls';

$startexportindex=$_REQUEST['startexportrow'];
$endexportrow=$_REQUEST['endexportrow'];

$eachexportcount=$endexportrow-$startexportindex;//每次导出的记录数量50


$_SESSION[$currentModule][$current_user->id]['export']['startexportindex']=$startexportindex+$eachexportcount;
if($_SESSION[$currentModule][$current_user->id]['export']['listcounts'])
{
    $listcounts=$_SESSION[$currentModule][$current_user->id]['export']['listcounts'];
    $detailcounts=$_SESSION[$currentModule][$current_user->id]['export']['detailcounts'];
}


$_SESSION[$currentModule][$current_user->id]['export']['startexportindex']=$startexportindex+$eachexportcount;
if($_SESSION[$currentModule][$current_user->id]['export']['listcounts'])
{
    $listcounts=$_SESSION[$currentModule][$current_user->id]['export']['listcounts'];
    $detailcounts=$_SESSION[$currentModule][$current_user->id]['export']['detailcounts'];
}




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
        // zkt 2021/12/27 平铺搜索 优化（批量操作按钮）-批量导出
	}else if($input['searchtype'] == 'advance'||$input['searchtype'] == 'tiled'){
		if(!empty($input['advft_criteria']) && $input['advft_criteria'] != '[]'){
			$_REQUEST['advft_criteria'] = $input['advft_criteria'];
			$_REQUEST['advft_criteria_groups'] = $input['advft_criteria_groups'];
			$_REQUEST['SearchScope'] = $input['SearchScope'];
			$_REQUEST['searchtype'] = $input['searchtype'];
            //zkt 20220331 50734: （https://61mis.com/WX/kh46549 [^]）（客户问题：重庆公牛摩托）合同订单经标签查找后，导出就是空白
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
    //$chart_owner:edit:can 2020-09-10 ,开启用户界面汇报人，非管理员导出的文件没有数据
    $page_list_query=$page_list_query.$FoSearchSQL.$querywhere.$querysearch;
  $_SESSION[$currentModule][$current_user->id]['export']['page_list_query']=$page_list_query;
}

$queryMode = (isset($_REQUEST['query']) && $_REQUEST['query'] == 'true');
$customsortorder = $customView->getCustomViewOrderBy($viewid);
$where= $queryGenerator->getWhereClause();
$orderby = " ORDER BY $customsortorder $focus->table_name.$focus->table_index desc";
$list_query=$list_query." inner join ( $page_list_query   ) as temp on temp.$focus->table_index=$focus->table_name.$focus->table_index $where";
$result = $adb->pquery($page_list_query,array());
if($adb->num_rows($result) >= 1){
	for($i = 0; $i < $adb->num_rows($result); $i++){
		$listids[] = $adb->query_result($result,$i,$focus->table_index);
	}
}
$query = "select min(cf_4645),max(cf_4645),sum(IFNULL(cf_4646,0)),sum(IFNULL(cf_4647,0)) from  ld_customform16scf where customform16id in (".implode(',',$listids).")";
$result = $adb->pquery($query,array());
if($adb->num_rows($result) >= 1){
	$start_date = $adb->query_result($result,0,0);
	$end_date = $adb->query_result($result,0,1);
	$before_amount = $adb->query_result($result,0,2);
	$after_amount = $adb->query_result($result,0,3);
}
$_SESSION[$currentModule][$current_user->id]['haochen_export']['start_date'] = $start_date;
$_SESSION[$currentModule][$current_user->id]['haochen_export']['end_date'] = $end_date;
$list_count_sql= $page_list_query;
if(!array_key_exists('exportgetcount',$_SESSION[$currentModule][$current_user->id]['export']))
{
     $detail_result = $adb->pquery($list_query, $params);
    $detailcounts = $adb->num_rows($detail_result);       
    
    $listcounts_result = $adb->pquery($list_count_sql, $params);
    $listcounts = $adb->num_rows($listcounts_result);       
    $_SESSION[$currentModule][$current_user->id]['export']['listcounts']=$listcounts;
    $_SESSION[$currentModule][$current_user->id]['export']['detailcounts']=$detailcounts;
    
     $_SESSION[$currentModule][$current_user->id]['export']['exportgetcount']="##SUCCESS##". $listcounts.'details'.$detailcounts;
       
    
}
$listcounts=$_SESSION[$currentModule][$current_user->id]['export']['listcounts'];
$detailcounts=$_SESSION[$currentModule][$current_user->id]['export']['detailcounts'];

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
        //edit: xll 2023/08/03 BUG0070673 导出优化，系统导出的excel表格的表头应有底色，标题应加粗
        crm_load_class_file('cls_ExportListView','include/ListView/ExportListView');
        $Header_FromArray = cls_ExportListView::getListHeaderFormArray();
        foreach($listview_header as $key=>$arr){//wsh 标签颜色
            $fieldifo = $focus->fieldobj->getFieldByColumnName($controller->listViewFields_permitarr[$key]);
            if (!empty($fieldifo)){
                $Header_FromArray["font"]["color"]["rgb"] = $fieldifo->getExportLabelColor();
            }
            $activesheet->getStyle(PHPExcel_Cell::stringFromColumnIndex($key) . '1')->applyFromArray($Header_FromArray);
            $activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex($key).'1',trim($arr));
        }
//确认收入日期
$activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex(sizeOf($listview_header)).'1',trim('确认收入日期'));
$list_query = $queryGenerator->getQuery('',2);//所有数据查询
$prev_totalrows=0;
$nums=$eachexportcount/2;//每次获取的记录数量
$step=$eachexportcount/$nums;
$version_info = getVersionInfo();
$progress_step=if(!empty($_SESSION[$currentModule][$current_user->id]['export']['detailcount']))
    $progress_step=$page_width/$_SESSION[$currentModule][$current_user->id]['export']['detailcount'];
else
    $progress_step=0;;
if(array_key_exists('exportprev_totalrows',$_SESSION[$currentModule][$current_user->id]['export']))
{
        $prev_totalrows=$_SESSION[$currentModule][$current_user->id]['export']['exportprev_totalrows'];
}
 if($startexportindex==0&&$startexportindex==$listcounts)
 {
   
    $objWriter->save($pathname); 
    unset($_SESSION[$currentModule][$current_user->id]['export']); 
     $ret_arr['startexportrow']=$startexportindex;
      $ret_arr['endexportrow']=$endexportrow;
      $ret_arr['listcount']=-1;
      $ret_arr['detailcount']=-1;
    $ret_arr['title']=getTranstab($currentModule).'>>'. getFixedLabel('EXPORTDATATITLE');
    ConvertTojsonString(1,$ret_arr,'success');
 }
 crm_load_class_file("cls_excelImage",'include');
 $excelimageobj=new cls_excelImage();

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
				//chj 2022/6/15 浩辰特殊开发  合同拆分
				if($version_info['account'] == 'haochen' && $currentModule == 'CustomForm16'){
					$shengji_colkeys = array_keys($headerlistfields,'sf4240');	//免费升级次数
					$orderdate_colkeys = array_keys($headerlistfields,'cf_4645');	//合同签订日期    确认收入日期
					$amount_colkeys = array_keys($headerlistfields,'sf4660');	//拆分后总价（不含税）人民币
					if(!empty($listview_entries)){
    					foreach($listview_entries as $arr){
    						if(!empty($arr[$shengji_colkeys[0]])){
    							$tmp_arr = $arr;
    							//每条记录的总价，需要用该项目计算得到的”拆分后总价（不含税）人民币“除以3得到（注：每条记录总价取整）。拆分单价不变。
    							$hc_list_amount = sprintf('%.2f', $tmp_arr[$amount_colkeys[0]]/$tmp_arr[$shengji_colkeys[0]]);
    							$err_list_amount = sprintf('%.2f', $tmp_arr[$amount_colkeys[0]] - $hc_list_amount * $tmp_arr[$shengji_colkeys[0]]);	//平均后的误差
    							for($v = 0; $v < $tmp_arr[$shengji_colkeys[0]]; $v++){
    								if($v < 1){
    									$arr[$amount_colkeys[0]] = $hc_list_amount + $err_list_amount;
    								}else{
    									$arr[$amount_colkeys[0]] = $hc_list_amount;
    								}
    								$arr[$shengji_colkeys[0]] = 1;
    								//$arr[$orderdate_colkeys[0]] = date('Y-m-d', strtotime('+'.$v.' year',strtotime($tmp_arr[$orderdate_colkeys[0]])));
    								$queren_date = date('Y-m-d', strtotime('+'.$v.' year',strtotime($tmp_arr[$orderdate_colkeys[0]])));
    								$arr[sizeOf($listview_header)] = $queren_date;
    								$new_listview_entries[] = $arr;
    							}
    							
    						}else{
    							
    							$arr[sizeOf($listview_header)] = $arr[$orderdate_colkeys[0]];
    							$new_listview_entries[] = $arr;
    						}
    						
    					}
    					$listview_entries = $new_listview_entries;
                    }
				}
                $a=2;
                //居中显示
                $objPHPExcel->getDefaultStyle()->getAlignment()->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_CENTER);
                $objPHPExcel->getDefaultStyle()->getAlignment()->setVertical(PHPExcel_Style_Alignment::VERTICAL_CENTER);
				
                foreach($listview_entries as $key=>$arr)
                {
                                
                        foreach($arr as $key2=>$arr2){
                            
                            $fieldname=$headerlistfields[$key2];
							if(!empty($fieldname)){
								$fieldinfo=$controller->getListViewFieldobj($key2,$fieldname);
								if(!empty($fieldinfo)){
								
									if($fieldinfo->isImageField()=="yes")
									{
										
										$excelimageobj->setCellImage($objPHPExcel,$arr2,$key+$a+$prev_totalrows,$key2,$activesheet,$organization_crm_address);
										
										
									}
									else
									{
										if($fieldinfo&&($fieldinfo->istotalFldMoneyField()))
										{
											$activesheet->setCellValueExplicit(PHPExcel_Cell::stringFromColumnIndex($key2).($key+$a+$prev_totalrows), trim($arr2),PHPExcel_Cell_DataType::TYPE_NUMERIC);
										}
										else
											$activesheet->setCellValueExplicit(PHPExcel_Cell::stringFromColumnIndex($key2).($key+$a+($prev_totalrows)), trim($arr2),PHPExcel_Cell_DataType::TYPE_STRING);

									}
								}
							}else{
								$activesheet->setCellValueExplicit(PHPExcel_Cell::stringFromColumnIndex($key2).($key+$a+($prev_totalrows)), trim($arr2),PHPExcel_Cell_DataType::TYPE_STRING);
							}
							
						}
                        
                              
                }
                
                $prev_totalrows+= sizeOf($listview_entries);//明细
                
                unset($listview_entries);
          }
    

          /* */
            
            $_SESSION[$currentModule][$current_user->id]['export']['total_list_query']="$list_query inner join ($page_list_query    ) as tmp on tmp.$focus->table_index=$focus->table_name.$focus->table_index $where  $orderby";
            $_SESSION[$currentModule][$current_user->id]['export']['list_query']="$list_query inner join ($page_list_query    ) as tmp on tmp.$focus->table_index=$focus->table_name.$focus->table_index $where  $orderby";
            $_SESSION[$currentModule][$current_user->id]['export']['exportprev_totalrows']=$prev_totalrows;
           
            
            
      $tmptmp=$startexportindex+$eachexportcount;
   
     
     if($tmptmp<$listcounts)
    {
        $objWriter->save($pathname);  
         

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
                        //$arr=strip_tags($arr)
                        $arr = str_replace('&yen;','¥',strip_tags($arr)); 
                     
                       // $arr= mb_convert_encoding($arr,"UTF-8","auto");

                        $activesheet->setCellValueExplicit(PHPExcel_Cell::stringFromColumnIndex($key).($maxkey+2), trim($arr),PHPExcel_Cell_DataType::TYPE_STRING);
                    }
                  
            }
          
            $objWriter->save($pathname);  
            unset($_SESSION[$currentModule][$current_user->id]['export']);
            
     
    }
    include(globalStatic::$root_directory.'modules/lingdang/Export/ExportProgressDescription.php');
      $ret_arr['timedescription']=$time_description;
     
    $ret_arr['content']=$progresshtml;
    $ret_arr['startexportrow']=$startexportindex;
    $ret_arr['endexportrow']=$endexportrow;
    $ret_arr['listcount']=$listcounts;
    //$ret_arr['writefilelabel']=getFixedLabel('WRITEEXCELFILE');
    $ret_arr['detailcount']=$detailcounts;
    $ret_arr['title']=getTranstab($currentModule).'>'. getFixedLabel('EXPORTDATATITLE');
    ConvertTojsonString(1,$ret_arr,'success');
    
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
    include(globalStatic::$root_directory.'modules/uploads/downloadxls_haochen.php');
    //header("Location:http://localhost/ldcrm/index.php?module=uploads&action=downloadxls&frommodule="+$currentModule);
    
}

exit();
?>