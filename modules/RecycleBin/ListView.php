<?php
/*+**********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ************************************************************************************/
 //zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $app_strings, $mod_strings, $current_language, $currentModule, $theme;

require_once('include/ListView/ListView.php');

require_once('modules/RecycleBin/RecycleBinUtils.php');

global $adb,  $list_max_entries_per_page_new;

$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";
//require_once('modules/lingdang/layout_utils.php');

$is_admin=is_admin($current_user);
$smarty = new lingdangCRM_Smarty;
$producttype = 0;//模块是否带有产品明细

/*
edit:cdw
date:20130827
reason:0004780: 新建帐套：回收站里面 选择模块 日报/周报/月报，弹出提示界面：对不起，您没有访问权限！（当前登录用户为admin）,备注：日报/周报/月报没有删除功能，在下拉框列表中删除 
*/
$skip_modules = array('Webmails','ReportLog');
$version_info = getVersionInfo();
if ($version_info['account']=='guoneng') {
    array_push($skip_modules,'BigScreenDataCockpit');
}
$skip_tab_ids = array(61,80,65,102);

for($i=0; $i<count($skip_modules); $i++) {
	$tab_id = getTabid($skip_modules[$i]);
	if ($tab_id != null && $tab_id != '') $skip_tab_ids[] = $tab_id;
}

$sql = 'SELECT tabid, name FROM ld_tab WHERE presence=0 AND isentitytype=1 and tabid in (select ld_field.tabid from ld_field group by ld_field.tabid)  ';
if (count($skip_tab_ids) > 0) {
	$sql .= ' AND tabid NOT IN ('. generateQuestionMarks($skip_tab_ids) .')';
}
/**
 *edit:chj
 *date:2013-12-19 
 *reason:回收站  选择模块内去除库存相关模块 
 * */
 /**
 *edit:andrew
 *date:2014-01-23 
 *reason:修改排序 
 * */
//ls 2022-03-01 0050190: （https://81mis.com/kfbcrm/index.php [^]）（需要补丁）回收站》自定义统计图表，界面报错（这里不应该有“自定义统计图表”）
//zkt 20230607 BUG0067811  回收站，选择模块选择“订货商城”后，界面报错（通用问题）(邱：回收站不需要有【订货商城】)
//wym 20230822 BUG0071434 回收站，去掉“可视化分析”模块（通用问题）
$sql .=" AND name NOT IN('Navigation','OutboundOrder','Stock','Prdtnums','InventoryLedger',
            'InventoryAccount','InventoryQuery','Checks','BankAccountSet','BankCash','PublicAnnouncement',
                'Attachment','WareHouseTransfer','Customreport','Emails','DividendOrder',
                'management','Mcommission','fundreward','fundrewardcommission','PromotionSetting','CooperativeWork','ChinaMap','CustomTables','Customreport','CustomEcharts','WechatSession','CardSettings','Shopping','VisualAnalysis','ldsoukebao','ldsoukebaomap','BIReportScreen')";
$sql .= ' ORDER BY tabsequence';

$result =$adb->pquery($sql, array($skip_tab_ids));
//print_r($result);
$noofrows = $adb->num_rows($result);
//print_r($result);
$module_name =Array();
$module_data =Array();

if($noofrows > 0) {
	$ScopOfAuthority = ScopOfAuthority::getInstance($adb,$currentModule);
	for($x=0,$y=0; $x<$noofrows;$x++) {
		$tabid = $adb->query_result($result,$x,'tabid');
		if($is_admin || $ScopOfAuthority->getModuleShareInfo() == SHARE_PUBLIC_READONLY) {
			$mod_name = $adb->query_result($result,$x,"name");
			if($mod_name=='CustomEcharts') continue;
			$module_name[$y] = $mod_name;
			$y++;
		}
	}
}
if(isset($_REQUEST['selected_module']) && $_REQUEST['selected_module'] != '') {
	$select_module = vtlib_purify($_REQUEST['selected_module']);
	if (!in_array($select_module, $module_name)) {
		show_error_msg();
	}
} else {
	if (count($module_name) > 0) {
		$select_module = $module_name[0];
	} else {
		show_error_msg('no_permitted_modules');
	}	
}
if($select_module=='Accounts'||$select_module=='Leads')
{
    $before_session = $_SESSION['lvsAccount'][$select_module];
    setSearchAllAccount();//设置查询所有的客户（包括公海客户）
}
$focus = CRMEntity::getInstance($select_module);
include("modules/RecycleBin/Recycle_CustomView.php");

if(count($module_name) > 0)
{
	$cur_mod_view = new Recycle_CustomView($select_module);
	$viewid = $cur_mod_view->getViewIdByName('All', $select_module);
	global $current_user;
	$queryGenerator = QueryGenerator::getInstance($select_module, $current_user);


	$queryGenerator->initForCustomViewById($viewid);
	$meta = $queryGenerator->getMeta($queryGenerator->getModule());
	$entityname = getEntitynameInfo(getTabid($select_module));
	//chj 2021/1/18 44307: （杭州小拇指http://51mis.com.cn/XS/hzxmz/ [^]）门店档案及合同-合同信息（服务合同）；合同新增之后，在回收站也显示对应的单据，在合同列表界面操作删除后，回收站中单据也消失了
	$tablename = $focus->table_name;
	//$tablename = $entityname['tablename'];
	// Enabling Module Search
	$url_string = '';
	if($_REQUEST['query'] == 'true') {
        $_REQUEST['searchtype'] ='BasicSearch';
		$queryGenerator->addUserSearchConditions($_REQUEST);
		//$ustring = getSearchURL($_REQUEST);
		//$url_string .= "&query=true$ustring";
        $smarty->assign('SEATCH_INPUT',$_REQUEST);
		$smarty->assign('SEARCH_URL', $url_string);
	}

    	$page_list_query = $queryGenerator->getQuery("",1);
        list($page_list_query,$order_by,$sorder) = $queryGenerator->customview->getOrderWhere($page_list_query);
    
        $list_query=$queryGenerator->getQuery("",2);
        //33802: PC端：角色权限中增加回收站，默认勾选。WEB端菜单定制中，工具菜单下显示回收站。
        $smowneridcolumnname=$focus->getSmownerColumName();
        $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey("columnname",$smowneridcolumnname);
        //33802: PC端：角色权限中增加回收站，默认勾选。WEB端菜单定制中，工具菜单下显示回收站。
//    BUG0077327 ls 20231220 授权账号maochen有回收站的权限，合同订单的数据范围设置的是全部。但这个账号回收站中看不到删除的记录(根据设置的角色权限显示数据)
        /*if(!empty($smowneridcolumnname)&&$fieldinfo&&!is_admin($current_user))
        $wheresmownerid= " and $tablename.$smowneridcolumnname=".$current_user->id;
        else
        $wheresmownerid="";*/
        
        $page_list_query=preg_replace("/".$tablename.".deleted\s*=\s*0/i", ''.$tablename.'.deleted = 1 ', $page_list_query);
        $list_query=preg_replace("/".$tablename.".deleted\s*=\s*0/i", ''.$tablename.'.deleted = 1 ', $list_query);
      
        $count_result=$adb->pquery($page_list_query,array());
        $noofrows=$adb->num_rows($count_result);
       	
	
	$smarty->assign("NUMOFROWS", $noofrows);
	if(get_file_address($select_module,$select_module.'DetailFieldsHtml') || $select_module == 'MarketSpread'){
	   crm_load_class_file('TabDetailListViewController','include/ListView');
		$controller = new TabDetailListViewController($adb, $current_user, $queryGenerator,$currentModule);
	}else if(get_file_address($select_module,'ProductDetails')||get_file_address($select_module,'ContactsDetails')){
		crm_load_class_file('ProductDetail_ListController','include/ListView/ProductDetail');
		$controller = new ProductDetail_ListController($adb, $current_user, $queryGenerator);
	}else{
		$controller = new ListViewController($adb, $current_user, $queryGenerator);
	}
	$rb_listview_header = $controller->getListViewHeader($focus,$select_module,$url_string,$sorder,$order_by,true);

    if(get_file_address($select_module,'ProductDetails')||get_file_address($select_module,'ContactsDetails')||get_file_address($select_module,'VendorsDetails')){
		//基本查找
		$listview_header_search = $queryGenerator->productDetails->getListViewHeaderSearch();
	}else if(get_file_address($select_module,$select_module.'DetailFieldsHtml')){
		$listview_header_search = $queryGenerator->TabDetails->getListViewHeaderSearch();
	}else{
	   $producttype = 1;
		$listview_header_search = $controller->getBasicSearchFieldInfoList();
	}
	$smarty->assign("SEARCHLISTHEADER", $listview_header_search);

	if(isset($_REQUEST['start']) && $_REQUEST['start'] != '')
		$start = vtlib_purify($_REQUEST['start']);
	else
		$start = 1;

	$navigation_array = getNavigationValues($start, $noofrows, $list_max_entries_per_page_new);

	// Setting the record count string
	//modified by rdhital
	$start_rec = $navigation_array['start'];
	$end_rec = $navigation_array['end_val']; 
	//By Raju Ends

	//limiting the query
	if ($start_rec ==0) 
		$limit_start_rec = 0;
	else
		$limit_start_rec = $start_rec -1;
   // $order_by="   ORDER BY ".$tablename.".modifiedtime desc";
    //$producttype  0代表有产品明细
    //if($producttype == 0)
    //{
  
         $list_query=$list_query." inner join ( $page_list_query   limit $limit_start_rec,$list_max_entries_per_page_new ) as temp on temp.$focus->table_index=$focus->table_name.$focus->table_index";
         $list_query = preg_replace("/".$tablename.".deleted\s*=\s*0/i", ''.$tablename.'.deleted = 1', $list_query);
         $list_query.=' order by '.$order_by.' '.$sorder;
       // echo $list_query;
         $list_result = $adb->query($list_query); 
  
    
	$record_string= getFixedLabel('TOTALOF') ." ".$noofrows." ". getFixedLabel('RECORDNUMS');

	$navigationOutput = getTableHeaderSimpleNavigation2($navigation_array, $url_string,"RecycleBin","index","");
	$lvEntries = $controller->getListViewEntries($focus,$select_module,$list_result,$navigation_array, true);
	
    
}
$smarty->assign("NAVIGATION", $navigationOutput);
$smarty->assign("RECORD_COUNTS", $record_string);
$smarty->assign('MAX_RECORDS', $list_max_entries_per_page_new);
//18867: 工具>回收站：全选所有单据，单据页面靠左侧重叠
//BUG0063732	zxm20230329  “回收站”全选序时簿列表单据，“销售线索”和“跟进记录”模块，部分列显示为灰色
$headercount=sizeof($rb_listview_header)+1;
$smarty->assign('HEADERCOUNT',$headercount);

$entitynames=getEntitynameByModulename($select_module);
$moduleColumnName = $entitynames['fieldname'];
$moduleTableName = $entitynames['tablename'];

if(strpos($moduleColumnName,','))
{
	$field_array = explode(',',$moduleColumnName);
	$moduleColumnName = $field_array[0];
}

$query = "SELECT fieldname FROM ld_field WHERE tablename=? and columnname=?";
$moduleFieldName = $adb->query_result($adb->pquery($query, array($moduleTableName,$moduleColumnName)),0,'fieldname');
$indexField = $moduleFieldName;

$alphabetical = AlphabeticalSearch($currentModule,'index',$indexField,'true','basic',"","","","",$viewid);

$category = getParentTab();;

//$check_button = Button_Check($_REQUEST['module']);
//$check_button['EditView'] = 'no';
//$newCustomView = new ProductDetails($select_module);
//$producttype  0代表有产品明细
if($producttype == 0)
{
	if(get_file_address($select_module,$select_module.'DetailFieldsHtml')){
		$rowcount = $queryGenerator->TabDetails->getRowCount();
	}else{	   
	 
		$rowcount=$queryGenerator->productDetails->getRowCount();  
	}
	
}

//hzx 20231207 XUQIU1002273 PC端模块列表界面，分页样式优化
//dump(ceil($noofrows));
$smarty->assign("TABNAME", getParentTab());
$smarty->assign("STARTPAGE", ceil($start));
$smarty->assign("LISTVIEWRECORDCOUNT", ceil($noofrows));
$smarty->assign("LISTVIEWPAGECOUNT", ceil($noofrows/$list_max_entries_per_page_new));
//$smarty->assign("LISTVIEWPERPAGENUM", json_encode(getlistmaxentries_per_page($list_max_entries_per_page_new)));

//$smarty->assign('ROW_COUNT', $queryGenerator->productDetails->getRowCount());
//$check_button['Export'] = 'no';
//$smarty->assign("CHECK", $check_button);
//获取批量操作时记录数上限
$deployarray=getSys_deploy(67);
$smarty->assign('BATCHNUM',$deployarray['deploy_value']);
$smarty->assign("ALPHABETICAL", $alphabetical);
$smarty->assign("NUMBER_MODULES",$noofrows);
//hzx 20240407 修改回收站模块下拉框
$selsect_module_arr = [];
if(count($module_name) > 0){
    foreach ($module_name as $modulename){
        if($modulename != 'OftenUseReport' && $modulename != 'ReportAnalysis'){
            $ids_selected = false;
            if($select_module == $modulename){
                $ids_selected = true;
            }
            $selsect_module_arr[] = array(
                'label'=>getTranstab($modulename),
                'value'=>$modulename,
                'selected'=>$ids_selected
            );
        }
    }
}
$smarty->assign("SELECT_MODULE_ARR",json_encode($selsect_module_arr));
$smarty->assign("MODULE_NAME",$module_name);
$smarty->assign("SELECTED_MODULE",$select_module);

$smarty->assign("MOD", $mod_strings); 
$smarty->assign("MODULE",$currentModule);
$smarty->assign("CATEGORY",$category);
$smarty->assign("THEME",$theme);
$smarty->assign("IMAGE_PATH",$image_path);
$smarty->assign("APP", $app_strings);
$smarty->assign("lvEntries", $lvEntries);
$smarty->assign("ALLSELECTEDIDS", vtlib_purify($_REQUEST['allselobjs']));
$smarty->assign("CURRENT_PAGE_BOXES", implode(";",array_keys($lvEntries)));
$smarty->assign("IS_ADMIN", $is_admin);
setGLobalURLSmarty($smarty);//设置js,css等访问路径
$smarty->assign("LISTDATAPRODUCT", show_listview_product($rb_listview_header,$lvEntries,$rowcount,$select_module,$headercount,$currentModule,$noofrows));//有产品明细
$smarty->assign("LISTDATA", show_listview($rb_listview_header,$lvEntries,$rowcount,$select_module,$headercount,$currentModule,$noofrows));//无产品明细。
$smarty->assign('SEARCHLISTHEADER',$listview_header_search);
$smarty->assign("DELPERMIT",isPermitted($currentModule,'Delete'));
$smarty->assign("REDUCTIONPERMIT",isPermitted($currentModule,'reduction'));
$controller->getFieldStorage($smarty);

if($select_module=='Accounts'||$select_module=='Leads')
{
    $_SESSION['lvsAccount'][$select_module] = $before_session;
}

if($_REQUEST['mode'] != 'ajax') {
	$smarty->display(vtlib_getModuleTemplate($currentModule,'RecycleBin.tpl'));
} else {
    //$producttype  0代表有产品明细
    if($producttype == 0)
    {
        $smarty->display(vtlib_getModuleTemplate($currentModule,'ProductRecycleBinContents.tpl'));
    }
    else
    {
        $smarty->display(vtlib_getModuleTemplate($currentModule,'RecycleBinContents.tpl'));   
    }
}	
function show_error_msg($error_type='permission_denied') {
	global $theme;
	if ($error_type == 'permission_denied') {		
		//echo "<link rel='stylesheet' type='text/css' href='themes/$theme/style.css'>";	
//		echo "<table border='0' cellpadding='5' cellspacing='0' width='100%' height='450px'><tr><td align='center'>";
//		echo "<div style='border: 3px solid rgb(153, 153, 153); background-color: rgb(255, 255, 255); width: 55%; position: relative; z-index: 10000000;'>
//	
//			<table border='0' cellpadding='5' cellspacing='0' width='98%'>
//			<tbody><tr>
//			<td rowspan='2' width='11%'><img src='" . lingdang_imageurl('denied.gif', $theme) . "' ></td>
//			<td style='border-bottom: 1px solid rgb(204, 204, 204);' nowrap='nowrap' width='70%'><span class='genHeaderSmall'>" 
//				. getFixedLabel('NOPERMITTEDEXECUTE') . "</span></td>
//			</tr>
//			<tr>
//			<td class='small' align='right' nowrap='nowrap'>			   	
//			<a href='javascript:window.history.back();'>" . getFixedLabel('RETURN') . "</a><br>
//			</td>
//			</tr>
//			</tbody></table> 
//			</div>";
//		echo "</td></tr></table>";
        include(globalStatic::$root_directory."modules/lingdang/ExitWithoutPermission.php");
		die();
	} else if ($error_type == 'no_permitted_modules') {		
		//echo "<link rel='stylesheet' type='text/css' href='themes/$theme/style.css'>";	
//		echo "<table border='0' cellpadding='5' cellspacing='0' width='100%' height='450px'><tr><td align='center'>";
//		echo "<div style='border: 3px solid rgb(153, 153, 153); background-color: rgb(255, 255, 255); width: 55%; position: relative; z-index: 1000;'>
//	
//			<table border='0' cellpadding='5' cellspacing='0' width='98%'>
//			<tbody><tr>
//			<td rowspan='2' width='11%'><img src='" . lingdang_imageurl('empty.jpg', $theme) . "' ></td>
//			<td style='border-bottom: 1px solid rgb(204, 204, 204);' nowrap='nowrap' width='70%'><span class='genHeaderSmall'>" 
//				. getFixedLabel('NOMODULEAVAIL') . "</span></td>
//			</tr>
//			</tbody></table> 
//			</div>";
//		echo "</td></tr></table>";
        include(globalStatic::$root_directory."modules/lingdang/ExitWithoutPermission.php");
		die();		
	}
}
//有产品明细的列表界面主体部分数据信息显示。
function show_listview_product($rb_listview_header,$lvEntries,$rowcount,$select_module,$headercount,$currentModule,$noofrows){
    $product_listview_table='';
    $product_listview_table.='<table class="listEntries" border="0" cellspacing="1" cellpadding="0" width="100%" id="producttable">';
    $product_listview_table.='<tr>';
    $product_listview_table.='<th class="firstChild" style="width:25px"><input type="checkbox" onclick="toggleSelect_ListView(this.checked,\'selected_id\')" id="selectCurrentPageRec" name="selectall" /></th>';   
    foreach($rb_listview_header as $mod_data=>$moddata )
    {    
        if($moddata=='操作'||$moddata== 'Action'){
            if(isPermitted($currentModule,'reduction') == 'yes'){
                $product_listview_table.='<th width="48">'.$moddata.'</th>';       
            }
        }else{
            $product_listview_table.='<th >'.$moddata.'</th>';
        }
    }  
	 if( $select_module <> 'ModComments')
		//$product_listview_table.='<th width="48">'.getFixedLabel('OPERATING').'</th>';    
        $product_listview_table.='</tr>'; 
        $product_listview_table.='<tr>';
//		$product_listview_table.='<td id="linkForSelectAll" class="linkForSelectAll" style="display:none;" colspan="'.$headercount.'">';
//		$product_listview_table.='<span id="selectAllRec" class="selectall" style="display:inline;" onClick="toggleSelectAll_Records(\''.$currentModule.'\',true,\'selected_id\')">'.getFixedLabel('SELECTALL').'<span id="count">'.$noofrows.'</span>'.getFixedLabel('RECORDNUMS').'</span>';
//        $product_listview_table.='<span id="deSelectAllRec" class="selectall" style="display:none;" onClick="toggleSelectAll_Records(\''.$currentModule.'\',false,\'selected_id\')">'.getFixedLabel('DESELECTALL').'</span>';
//		$product_listview_table.='</td>';
	    $product_listview_table.='</tr>';
   $i=0;
   if(count($lvEntries)>0)//判断列表数据是否为空。
   {
    $row_index=0;
     foreach($lvEntries as $entity_id =>$lvdata)
     {
        $redcordid=$entity_id;
        $checkvalueid=substrTd($entity_id,1);  
        if ($checkvalueid != $old_checkvalueid){
            $i++;
        }
          $row_td = getTableRowCell($redcordid,$lvEntries,$row_index);  //合并列
        if($checkbox=='yes')
        {
            if ($i%2 ==0) {
                $product_listview_table.=' <tr class="lvtColDataBj" record="'.$checkvalueid.'" onmouseover="listOnMouseOver(ld(this))" onmouseout="listOnMouseOut(ld(this),\'On\')" id="row_'.$entity_id.'">';
            }
            else{
                $product_listview_table.=' <tr class="lvtColData" record="'.$checkvalueid.'" onmouseover="listOnMouseOver(ld(this))" onmouseout="listOnMouseOut(ld(this),\'on\')" id="row_'.$entity_id.'">';
            }
        }
        else
        {
            // if ($i%2 ==0) {
            //     $product_listview_table.=' <tr class="lvtColDataBj" onmouseover="setTrColor(\'row_'.$entity_id.'\',\''.$entity_id.'\',\''.$checkvalueid.'\',\'producttable\')" onmouseout="setTrColorOut(\'row_'.$entity_id.'\',\''.$entity_id.'\',\''.$checkvalueid.'\',\'On\',\'producttable\')" id="row_'.$entity_id.'">';
            // }
            // else{
            //     $product_listview_table.=' <tr class="lvtColData" onmouseover="setTrColor(\'row_'.$entity_id.'\',\''.$entity_id.'\',\''.$checkvalueid.'\',\'producttable\')" onmouseout="setTrColorOut(\'row_'.$entity_id.'\',\''.$entity_id.'\',\''.$checkvalueid.'\',\'on\',\'producttable\')" id="row_'.$entity_id.'">';
            // }
            if ($i%2 ==0) {
                $product_listview_table.=' <tr class="lvtColDataBj" record="'.$checkvalueid.'" onmouseover="listOnMouseOver(ld(this))" onmouseout="listOnMouseOut(ld(this),\'On\')" id="row_'.$entity_id.'">';
            }
            else{
                $product_listview_table.=' <tr class="lvtColData" record="'.$checkvalueid.'" onmouseover="listOnMouseOver(ld(this))" onmouseout="listOnMouseOut(ld(this),\'on\')" id="row_'.$entity_id.'">';
            }
        }
        if($rowcount==0)
        {
            if($checkvalueid<>$old_checkvalueid)
            {
               $product_listview_table.='<td class="firstChild" style="width:25px" onclick="check_objects_parent_td(this)"><input type="checkbox" name="selected_id"  value="'.substrTd($entity_id,1).'" id="'.substrTd($entity_id,1).'"></td>';
            }
        }           
        else
        {
          if($lvEntries[$entity_id][0]<> '&&')
           { 
            if($row_td=='1')
            {
               $product_listview_table.='<td class="firstChild" style="width:25px" onclick="check_objects_parent_td(this)"><input type="checkbox" name="selected_id"  value="'.substrTd($entity_id,1).'" id="'.substrTd($entity_id,1).'"></td>';
            }
            else
            {   
               $product_listview_table.='<td class="firstChild" rowspan="'.$row_td.'" valign="top" width=2% onclick="check_objects_parent_td(this)"><input type="checkbox" name="selected_id" value="'.substrTd($entity_id,1).'" id="'.substrTd($entity_id,1).'"></td>';
            }            
           }           
        }
        if(get_file_address($select_module,'ProductDetails')==true||get_file_address($select_module,$select_module.'DetailFieldsHtml')==true ||get_file_address($select_module,'ContactsDetails')==true||get_file_address($select_module,'VendorsDetails')==true)
        {
            $for_i = 0;
            $old_checkvalueid= substrTd($entity_id,1);            
            foreach($lvdata as $entity_id =>$data)
             {             
              $entity_id = $for_i;     //获取到数组的索引值。
              ++$for_i;
              if($entity_id <=$rowcount && $data <>'&&' &&$row_td>1)
               {
                $product_listview_table.='<td rowspan="'.$row_td.'" valign="top">';
                $product_listview_table.=$data;
                $product_listview_table.='</td>';                        
               }
               elseif(foreachArray($lvdata,$entity_id)==true && $data<> '&&')
               {
                //duan 2022-2-7 每条单据的分录保留一个还原按钮
                if($checkvalueid != $before_recordid){
                    if(isPermitted($currentModule,'reduction') == 'yes'){
                        $product_listview_table.='<td rowspan="'.$row_td.'" valign="top">';
                        $product_listview_table.='<a class="Anu3_a" href="javascript:;" onclick="restore('.substrTd($redcordid,1).',\''.$select_module.'\');">'.getFixedLabel('REDUCTION').'</a>';
                        $product_listview_table.='</td>'; 
                    }
                }
                //记录上一行操作按钮的id
                $before_recordid = $checkvalueid;
               }
               elseif($data == '&&')
               {
                
               }
               else
               {
                $product_listview_table.='<td>';
                $product_listview_table.=$data;
                $product_listview_table.='</td>';
               }
             }
        }
        else
        {
            foreach ($lvdata as $entity_id => $data)
            {
                //edit: xll 2023/03/30 BUG0063726 回收站，中字段类型为“图片”或“签名”的字段内容为空时，会显示还原操作 
                if(foreachArray($lvdata,$entity_id)==true && $data<> '&&')
                {
                    if($checkvalueid != $before_recordid){
                        if(isPermitted($currentModule,'reduction') == 'yes'){
                            $product_listview_table.='<td><a class="Anu3_a" href="javascript:;" onclick="restore('.substrTd($redcordid,1).',\''.$select_module.'\');">'.getFixedLabel('REDUCTION').'</a></td>';  
                        }
                    }
                    //记录上一行操作按钮的id
                    $before_recordid = $checkvalueid;
                }else{
                    $product_listview_table.='<td>';
                    $product_listview_table.=$data;
                    //if($data =='')
                    //if($entity_id == count($lvdata) - 1)
                    
                    $product_listview_table.='</td>';
                }
            }
        }
      $product_listview_table.='</tr>';     
      $row_index++;                      
     }       
   }
   else    //列表数据为空时，合并列表表格单元格。
    {
        global $global_minversin;
        //26953: （芝蒲）回收站：客户模块列表，操作列后显示多余
      $list_headernum=count($rb_listview_header)+1;//数据列头个数(包括checkbox 和操作列)。      
      $product_listview_table.='<tr>';
      $product_listview_table.='<td style="background-color:#FFF;height:340px" align="center" colspan="'.$list_headernum.'">';
      $product_listview_table.='<table width=100% height="400px" align="center">';
      $product_listview_table.='<tr>';
      $product_listview_table.='<td align="center">';  
      $product_listview_table.='<div class="warningTableContent" style="z-index:600;">';
      $product_listview_table.='<div class="wtc_img"><img src="themes/icon2023/ld-no-records.png?v='.$global_minversin.'"></div>';
      $product_listview_table.='<div class="wtc_content">'.getFixedLabel('NOTFOUNDANYRECORD').'</div>';
      $product_listview_table.='<div class="wtc_btn"></div>';
      $product_listview_table.='<div></div>';
      $product_listview_table.='<div>';
      $product_listview_table.='</td>';
      $product_listview_table.='</tr>'; 
      $product_listview_table.='</table>';
      $product_listview_table.='</td>';
      $product_listview_table.='</tr>';  
    }
    $product_listview_table.='</table>';  
    return $product_listview_table;
   	      
}
//没有产品明细的列表界面主体部分数据信息显示。
function show_listview($rb_listview_header,$lvEntries,$rowcount,$select_module,$headercount,$currentModule,$noofrows){
    $listview_table='';

    $listview_table.='<table class="listEntries fir-center" border="0" cellspacing="1" cellpadding="0" width="100%" id="producttable">';
    $listview_table.='<tr>';
    $listview_table.='<th class="firstChild" style="width:25px"><input type="checkbox" onclick="toggleSelect_ListView(this.checked,\'selected_id\')" id="selectCurrentPageRec" name="selectall" /></th>';   
    
    foreach($rb_listview_header as $mod_data=>$moddata )
    {
        if ($moddata == '操作' || $moddata == 'Action') {
            if (isPermitted($currentModule, 'reduction') == 'yes') {
                $listview_table .= '<th width="48">' . $moddata . '</th>';
            }
        } else {
            $listview_table .= '<th >' . $moddata . '</th>';
        }
    }  
	 
	//	$listview_table.='<th width="48">'.getFixedLabel('OPERATING').'</th>';    
        $listview_table.='</tr>'; 
        $listview_table.='<tr>';
		//$listview_table.='<td id="linkForSelectAll" class="linkForSelectAll" style="display:none;" colspan="'.$headercount.'">';
		//$listview_table.='<span id="selectAllRec" class="selectall" style="display:inline;" onClick="toggleSelectAll_Records(\''.$currentModule.'\',true,\'selected_id\')">'.getFixedLabel('SELECTALL').'<span id="count">'.$noofrows.'</span>'.getFixedLabel('RECORDNUMS').'</span>';
        //$listview_table.='<span id="deSelectAllRec" class="selectall" style="display:none;" onClick="toggleSelectAll_Records(\''.$currentModule.'\',false,\'selected_id\')">'.getFixedLabel('DESELECTALL').'</span>';
		//$listview_table.='</td>';
	    $listview_table.='</tr>';
   $i=0;
   if(count($lvEntries)>0)//判断列表数据是否为空。
   {
     foreach($lvEntries as $entity_id =>$lvdata)
     {
        $redcordid=$entity_id;
        $checkvalueid=substrTd($entity_id,1);  
        if ($checkvalueid != $old_checkvalueid){
            $i++;
        }
        if($checkbox=='yes')
        {
            if ($i%2 ==0) {
                $listview_table.=' <tr class="lvtColDataBj" onmouseover="listOnMouseOver(ld(this))" onmouseout="listOnMouseOut(ld(this),\'On\')" id="row_'.$entity_id.'">';
            }
            else{
                $listview_table.=' <tr class="lvtColData" onmouseover="listOnMouseOver(ld(this))" onmouseout="listOnMouseOut(ld(this),\'on\')" id="row_'.$entity_id.'">';
            }
        }
        else
        {
            if ($i%2 ==0) {
                $listview_table.=' <tr class="lvtColDataBj" onmouseover="listOnMouseOver(ld(this))" onmouseout="listOnMouseOut(ld(this),\'On\')" id="row_'.$entity_id.'">';
            }
            else{
                $listview_table.=' <tr class="lvtColData" onmouseover="listOnMouseOver(ld(this))" onmouseout="listOnMouseOut(ld(this),\'on\')" id="row_'.$entity_id.'">';
            }
        }
        if($rowcount==0)
        {
            if($checkvalueid<>$old_checkvalueid)
            {
               $listview_table.='<td class="firstChild" style="width:25px" onclick="check_objects_parent_td(this)"><input type="checkbox" name="selected_id"   value="'.substrTd($entity_id,1).'" id="'.substrTd($entity_id,1).'"></td>';
            }
        }           
        else
        {
          if($lvEntries[$entity_id][0]<> '&&')
           { 
            if(getTableRowCell($redcordid,$lvEntries)=='1')
            {
               $listview_table.='<td class="firstChild" style="width:25px" onclick="check_objects_parent_td(this)"><input type="checkbox" name="selected_id"  value="'.substrTd($entity_id,1).'" id="'.substrTd($entity_id,1).'"></td>';
            }
            else
            {   
               $listview_table.='<td class="firstChild" rowspan="'.getTableRowCell($redcordid,$lvEntries).'" valign="top" width=2% onclick="check_objects_parent_td(this)"><input type="checkbox" name="selected_id" value="'.substrTd($entity_id,1).'" id="'.substrTd($entity_id,1).'"></td>';
            }            
           }           
        }
        if(get_file_address($select_module,'ProductDetails')==true||get_file_address($select_module,$select_module.'DetailFieldsHtml')==true ||get_file_address($select_module,'ContactsDetails')==true||get_file_address($select_module,'VendorsDetails')==true)
        {
            $for_i = 0;
            $old_checkvalueid= substrTd($entity_id,1);            
            foreach($lvdata as $entity_id =>$data)
             {             
              $entity_id = $for_i;     //获取到数组的索引值。
              ++$for_i;
              if($entity_id <=$rowcount && $data <>'&&' &&getTableRowCell($redcordid,$lvEntries)>1)
               {
                $listview_table.='<td rowspan="'.getTableRowCell($redcordid,$lvEntries).'" valign="top">';
                $listview_table.=$data;
                $listview_table.='</td>';                        
               }
               elseif(foreachArray($lvdata,$entity_id)==true && $data<> '&&')
               {
                //duan 2022-2-7 每条单据的分录只保留一个还原按钮
                if($checkvalueid != $before_recordid){
                    if(isPermitted($currentModule,'reduction') == 'yes'){
                        $listview_table.='<td rowspan="'.$row_td.'" valign="top">';
                        $listview_table.='<a class="Anu3_a" href="javascript:;" onclick="restore('.substrTd($redcordid,1).',\''.$select_module.'\');">'.getFixedLabel('REDUCTION').'</a>';
                        $listview_table.='</td>'; 
                    }
                }
                //记录上一行操作按钮的id
                $before_recordid = $checkvalueid;
               }
               elseif($data == '&&')
               {
                
               }
               else
               {
                $listview_table.='<td>';
                //zkt 20220524 51737(https://61mis.com/order/index.php)（自用order）首页》回收站》合同订单模块》出库状态列内容显示没有上下居中
                $listview_table.=$data;
                $listview_table.='</td>';
               }
             }
        }
        else
        {
            foreach ($lvdata as $entity_id => $data)
            {
                //edit: xll 2023/03/30 BUG0063726 回收站，中字段类型为“图片”或“签名”的字段内容为空时，会显示还原操作 
                if(foreachArray($lvdata,$entity_id)==true && $data<> '&&')
                {
                    if($checkvalueid != $before_recordid){//BUG0063977 还原功能单据record取值错误
                        if(isPermitted($currentModule,'reduction') == 'yes'){
                            $listview_table.='<td><a class="Anu3_a" href="javascript:;" onclick="restore('.substrTd($redcordid,1).',\''.$select_module.'\');">'.getFixedLabel('REDUCTION').'</a></td>';  
                        }
                    }
                    //记录上一行操作按钮的id
                    $before_recordid = $checkvalueid;
                }else{
                    $listview_table.='<td>';
                    $listview_table.=$data;
                    //if($data =='')
                    //if($entity_id == count($lvdata) - 1)
                    $listview_table.='</td>';
                }
            }
        }
      $listview_table.='</tr>';                           
     }       
   }
 else
 {   
      global $global_minversin;
      $list_headernum=count($rb_listview_header)+1;//数据列头个数(包括checkbox 和操作列)。      
      $listview_table.='<tr>';
      $listview_table.='<td id="resize_content_tdid" style="background-color:#FFF;height:0px;padding: 0;" align="center" colspan="'.$list_headernum.'">';
      $listview_table.='<script>
                            s_height = ld(window).height();
                            ld("#"+"resize_content_tdid").css("height",s_height-ld("#"+"resize_content_tdid").offset().top-25);
                        </script>';
      $listview_table.='<table width=100% height="400px" align="center">';
      $listview_table.='<tr>';
      $listview_table.='<td align="center">';
      
      $listview_table.='<div class="warningTableContent" style="z-index:600;">';
      $listview_table.='<div class="wtc_img"><img src="themes/icon2023/ld-no-records.png?v='.$global_minversin.'"></div>';
      $listview_table.='<div class="wtc_content">'.getFixedLabel('NOTFOUNDANYRECORD').'</div>';
      $listview_table.='<div class="wtc_btn"></div>';
      $listview_table.='<div></div>';
      $listview_table.='<div>';

      $listview_table.='</td>';
      $listview_table.='</tr>'; 
      $listview_table.='</table>';
      $listview_table.='</td>';
 }
  $listview_table.='</table>';  
  return $listview_table;  
}
?>