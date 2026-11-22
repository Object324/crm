<?php
/*+********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*} 
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 *********************************************************************************/


global $mod_strings, $current_language, $default_charset;
global $current_user,$adb,$theme,$languageType;
$_REQUEST['diony']='yes';
if($_REQUEST['quick_query_session']=='save')//模块选择保存
{
    //灵当crm右上角快速查找增加记住功能
    $search_onlyin = $_REQUEST['search_onlyin'];
    $_SESSION['__UnifiedSearch_SelectedModules__'] = $search_onlyin;
    $sql='update ld_users set searchmodules=? where id=?';
       
    $adb->pquery($sql,array($search_onlyin,$current_user->id));

    ConvertTojsonString(1,array(),'success');
}

$sql='select searchmodules from ld_users where id=?';
$result=$adb->pquery($sql,array($current_user->id));

if($adb->num_rows($result)>0)
{
    $tmpsearchmodules=trim(trim($adb->query_result($result,0,0),','));
    if($tmpsearchmodules==''){
        $tmpsearchmodules='Accounts,Contacts,ContactRecords,SalesOrder';
    }
    if($tmpsearchmodules!='')
    {
        $_SESSION['__UnifiedSearch_SelectedModules__']=explode(',',$tmpsearchmodules);
        $_REQUEST['search_onlyin']=$tmpsearchmodules;
        $_SESSION['__UnifiedSearch_SelectedModules__']=$tmpsearchmodules;
       
        
    }
    
}

 if($_REQUEST['quick_query_session']==1)
 {
        $_REQUEST['query_string']=$_SESSION['quick_query_session'];
        $_REQUEST['search_onlyin']=implode(',',$_SESSION['__UnifiedSearch_SelectedModules__'] );
        
 }
$query_string = trim($_REQUEST['query_string']);
$_SESSION['quick_query_session']=$query_string;
$search_tag = vtlib_purify($_REQUEST['search_tag']);
$total_record_count = 0;
if(isset($query_string) && $query_string != ''){
	// Was the search limited by user for specific modules?
	$search_onlyin = $_REQUEST['search_onlyin'];

	if(!empty($search_onlyin) && $search_onlyin != '--USESELECTED--') {
		$search_onlyin = explode(',', $search_onlyin);
	} else if($search_onlyin == '--USESELECTED--') {
		$search_onlyin = $_SESSION['__UnifiedSearch_SelectedModules__'];
	} else {
		$search_onlyin = array();
	}
	// Save the selection for futur use (UnifiedSearchModules.php)
	$_SESSION['__UnifiedSearch_SelectedModules__'] = $search_onlyin;
   // $sql='update ld_users set searchmodules=? where id=?';
   // $adb->pquery($sql,array($search_onlyin,$current_user->id));
    
	// END

	$object_array = getSearchModules($search_onlyin);
	$theme_path="themes/".$theme."/";
	$image_path=$theme_path."images/";
	
	$search_val = $query_string;
 	$search_module = $_REQUEST['search_module'];
    $content = '';
    $content.='<div class="quicksearch_dv" id="UnifiedSearch">';
	$content.=	getSearchModulesComboList($search_module);

	$i = 0;
    $allsearchfields=array();
	$moduleRecordCount = array();
    global $list_max_entries_per_page_new;
    crm_load_class_file('Inventory','data');
    crm_load_class_file("UnifiedSearch_CustomView",'modules/Home');
    //crm_load_class_file("UnifiedSearch_ListQuery",'modules/Home');
    crm_load_class_file("cls_QuickQuery",'modules/Home/QuickQuery');
    
    crm_load_class_file("cls_UnifiedSearch_Controller",'include/ListView/UnifiedSearch');
    $have_search_data_modules=array();
    //edit:can 2021-03-17 045023: （https://61mis.com/kfbcrm [^]）直接全局搜索客户（测试账号），会有一条单据，但是在客户模块中查看范围选择003，然后在全局查找中搜索客户（测试账号），由于这个查看范围的限制导致搜不到这个客户。全局查找应该不受查看范围的限制
    setSearchAllAccount();
    $nodata_conut = 0;//diony 2023-04-26 记录没有数据的模块数量 BUG0065635
    $moduledata_arr = [];
    $smarty = new lingdangCRM_Smarty;
	foreach($object_array as $module => $object_name){
        global $currentModule;
        $currentModule = $module;
        $focus = CRMEntity::getInstance($module);
        if(!vtlib_isModuleActive($module)){
            $permitted='no';
        } else{
            $permitted=isPermitted($module,"index");
        }
        if(vtlib_isModuleActive($module) && isPermitted($module,"index",'') == 'yes'){
            $smarty->assign("THEME", $theme);
            $smarty->assign("IMAGE_PATH",$image_path);
            $smarty->assign("MODULE",$module);
            $smarty->assign("TAG_SEARCH",$search_tag);
            $smarty->assign("SEARCH_MODULE",vtlib_purify($_REQUEST['search_module']));
            $smarty->assign("SINGLE_MOD",$module);
            $smarty->assign("SEARCH_STRING",htmlentities($search_val, ENT_QUOTES, $default_charset));

            $smarty->assign("LANUGAGETYPE",$languageType);
            if(!empty($_REQUEST['refmodule']) && $_REQUEST['refmodule'] != $module){
                continue;
            }
            $operationWidth = $languageType == 'zh'?90:100;
            $oCustomView = '';

            $queryGenerator =new cls_QuickQuery($module);

            $controller = new cls_UnifiedSearch_Controller($adb, $current_user, $queryGenerator->queryobj,$module);

            $page_list_query=$queryGenerator->getQuery("1");//排序
            $_SESSION[$module.'_quicksearch_listquery']=$page_list_query;
            $list_query=$queryGenerator->getQuery("2");

            //xxy 2023-12-15 全局查找获取每个模块的最大条数
            //wym 231221 XUQIU1002380 列表显示条数可按成员设置不同的条数
            $list_max_entries_per_page_new=getUsersettingByLabel($currentModule,$current_user->id,'MaxEntriesPerPageByuser')??getUsersettingByLabel($currentModule,1,'MaxEntriesPerPage');
            $list_max_entries_per_page_new=empty($list_max_entries_per_page_new)?'20':$list_max_entries_per_page_new;

            if(!empty($_REQUEST['start']) && !empty($_REQUEST['refmodule']) && $_REQUEST['refmodule'] == $module){
                    $start = $_REQUEST['start'];
                    if($start == 'last'){
                        $count_result = $adb->query( $page_list_query);
                        $noofrows = $adb->num_rows($count_result);
                        if($noofrows > 0){
                            $start = ceil($noofrows/$list_max_entries_per_page_new);
                        }
                    }
                if(!is_numeric($start)){
                    $start = 1;
                } elseif($start < 0){
                    $start = 1;
                }
                $start = ceil($start);
            }else{
                $start = 1;

            }
            $count_result = $adb->query( $page_list_query);
            $noofrows = $adb->num_rows($count_result);

            $moduledata_arr[] = $module;
            if($noofrows<=0)
            {
                $nodata_conut++;//diony 2023-04-26 记录没有数据的模块数量 BUG0065635
                continue;//37087: （1.6）快速查找>录入【合同】进行查找：查找出的结果没有数据的模块不显示。（需要补丁）
            }

            $navigation_array['start']=$start;
            $limitStartRecord = ($navigation_array['start'] - 1) * $list_max_entries_per_page_new;

            list($page_list_query,$order_by,$sorder)=$queryGenerator->customviewobj->getOrderWhere($page_list_query);
            if($module=='PublicAnnouncement')
          {
            $listquery=$page_list_query;

          }
            else
            {
                $listquery=$list_query." inner join  ($page_list_query limit $limitStartRecord, $list_max_entries_per_page_new ) as tmp
                    on tmp.".$focus->table_index."=".$focus->table_name.".".$focus->table_index;
                if($module== "ServiceCharge"){
                    $listquery.=$queryGenerator->queryobj->getGroupBy();//服务收费管理查询
                }
                $listquery.=' order by '.$order_by.' '.$sorder.' , '.$focus->table_name.".".$focus->table_index.' '.$sorder;
            }

            $search_msg = ' -- '.getFixedLabel('FINDRESULT').'：';
            $search_msg .=	"<b>".htmlentities($search_val, ENT_QUOTES, $default_charset)."</b>";

            //ljj XUQIU1002184 全局查找，可自由调整列宽
            $viewid = $queryGenerator->customviewobj->getViewId($module);
            $smarty->assign("viewid",$viewid);
            $moduleRecordCount[$module]['count'] = $noofrows;
            crm_load_function_file('VT_getSimpleNavigationValues','include/utils','ListViewUtils');
            $navigation_array = VT_getSimpleNavigationValues($start, $list_max_entries_per_page_new, $noofrows);

            $list_result = $adb->query($listquery);
            $count_result = $adb->query($page_list_query . " limit $limitStartRecord, $list_max_entries_per_page_new");
            $moduleRecordCount[$module]['recordListRangeMessage'] = getRecordRangeMessage($count_result, $limitStartRecord, $noofrows);

            $info_message='&recordcount='.$_REQUEST['recordcount'].'&noofrows='.$_REQUEST['noofrows'].'&message='.$_REQUEST['message'].'&skipped_record_count='.$_REQUEST['skipped_record_count'];
            $url_string = '&modulename='.$_REQUEST['modulename'].'&nav_module='.$module.$info_message;
            $viewid = '';

            $navigationOutput = getTableHeaderSimpleNavigation2($navigation_array, $url_string,$module,"UnifiedSearch",$viewid);

            $listview_header =$controller->getListViewHeader($focus, $module,$url_string,$sorder,$order_by,$skipAction);

            $focus_obj=Field::getInstance($module,$adb);
            $moduleFields = $focus_obj->getModuleFields();
            $tmpfields=$focus_obj->getFieldListArray();
            $allsearchfields[$module]=$tmpfields['fields'];
            $listview_entries = $controller->getListViewEntries($focus,$module,$list_result,$navigation_array,$skipAction);
            if(get_file_address($module,$module.'DetailFieldsHtml')||get_file_address($module,'ProductDetails')||$module=='Accounts'|"Vendords"==$module||'Attachment'==$module||$module=='Documents')
            {
                $row_count=$queryGenerator->queryobj->getMainColumnCount();
                $colspan_count = count($listview_header);
                $searchlisthtml = Inventory::createModWithDetailhtml($listview_entries,$row_count,$colspan_count,"no","",$controller);
            } else
            {
                $colspan_count = sizeof($listview_header);
                $focus->getModuleLogic($module)->getListViewButtons();
                $searchlisthtml = Inventory::createHTML($listview_entries,$module,0,$colspan_count,$focus->logic->list_buttons,$controller,'no');
            }
            $smarty->assign('SEARCHLISTHTML',$searchlisthtml);
            

            //ljj XUQIU1002184 全局查找，可自由调整列宽
            $widthinfo=getModuleWidth($focus,$controller->listviewcontroller->getModuleViewFieldsWidth(),$module);
            $smarty->assign('LISTHEADERWIDTH',$widthinfo);

            if((get_file_address($module,'ProductDetails') || get_file_address($module,'ContactsDetails') || get_file_address($module,'VendorsDetails'))) {
                //列表字段对应的columnname 和 module
                $headerinfo = $queryGenerator->queryobj->productDetails->getListViewHeaderInfo();
            }else if(get_file_address($module,$module.'DetailFieldsHtml')) {
                //列表字段对应的columnname 和 module
                $headerinfo = $queryGenerator->queryobj->TabDetails->getListViewHeaderInfo();
            }else{
                $headerinfo = $controller->listviewcontroller->getHeaderName();
            }
            $smarty->assign('HEADERNAME',$headerinfo['fieldname']);
            $smarty->assign('HEADERMODULE',$headerinfo['module']);

            $operationWidth = $focus->getModuleLogic($currentModule)->getListButtomName();
            if (empty($searchlisthtml)){
                $display_header = 0;
            }else{
                $display_header = 1;
            }

            $smarty->assign("DISPLAYHEADER", $display_header);
            $smarty->assign("NAVIGATION", $navigationOutput);
            $smarty->assign("LISTHEADER", $listview_header);
            $smarty->assign("LISTENTITY", $listview_entries);
            $smarty->assign("HEADERCOUNT", count($listview_header));
            $smarty->assign("ModuleRecordCount", $moduleRecordCount);
            $smarty->assign('OPERATIONWIDTH',$operationWidth);
            $total_record_count = $total_record_count + $noofrows;
            $smarty->assign("SEARCH_CRITERIA","（ $noofrows ）".$search_msg);

            //37087: （1.6）快速查找>录入【合同】进行查找：查找出的结果没有数据的模块不显示。（需要补丁）
            if(isset($object_array['BankAccountSet'])){
                $smarty->assign("BANKACCOUNTSET_JS", 1);
            }else{
                $smarty->assign("BANKACCOUNTSET_JS", 0);
            }

            $smarty->assign('COUNT',$total_record_count);
            $smarty->assign('MODULECOUNT',$noofrows);
            $smarty->assign("CUSTOMVIEW_OPTION",$customviewcombo_html);


            setGLobalURLSmarty($smarty);//设置js,css等访问路径

            /*edit:Can
            date:20130918
            reason:4950: 右上角“快速查找”改进
            */
            if(($i != 0 && empty($_REQUEST['ajax'])) || !(empty($_REQUEST['ajax'])))
            {
               $content.= $smarty->fetch("UnifiedSearchAjax.tpl");
            }
            else
            {
                $content.=	$smarty->fetch('UnifiedSearchDisplay.tpl');
            }
            $i++;

            unset($_SESSION['lvs'][$module]);
        }
	}
    //diony 2023-04-26 记录没有数据的模块数量 BUG0065635 相等,说明查找结果都为空
    if(sizeof($object_array) == $nodata_conut){
        $content .='<div class="warningTableContent" id="warningTable_Content" style="z-index:600;width:100%;padding-top: 0px;padding-top: 12%;left:auto;top:auto;">';
        $content .='<script>
                        s_height = ld(window).height();
                        ld("#"+"warningTable_Content").css("height",s_height-ld("#"+"warningTable_Content").offset().top-20);
                    </script>';
        $content .='<div class="wtc_img" style="margin:0 auto;display: flex;justify-content: center;"><img src="themes/icon2023/ld-no-records.png?v='.$global_minversin.'"></div>';
        $content .='<div class="wtc_content" style="display: flex;justify-content: center;">'.getFixedLabel('NOTFOUNDANYRECORD').'</div>';   
        $content .='</div>';   
    }
    $content.='</div>';
    $_REQUEST['diony']='yes';
    $arr['content']=$content;
    $arr['allfields']=$allsearchfields;
    $arr['rows_description']=getFixedLabel('TOTALRECORDFOUND') ;
    $arr['rows']=$total_record_count;
    $arr['moduledata'] = $moduledata_arr;
    $arr['search_onlyin'] = join(',',$search_onlyin);
    ConvertTojsonString(1,$arr,'success');
}
else {
	echo "<br><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<em>".getFixedLabel('ENTERATLEASTCHAR')."</em>";
}
function getSearchModulesComboList($search_module){
	global $object_array;
    $strcontent = '';
    if(empty($_REQUEST['ajax'])){
        $strcontent.=' <div class="global_search_total" id="global_search_total" name="global_search_total">
        	   <strong style="color:#555;">'. getFixedLabel('SELECTMODULE').'</strong>
                <div class="globalselect_div" style="display: inline; margin-right: 15px;">
                <select id="global_search_module" name="global_search_module" class="commonSelect" onChange="displayModuleList(this);">
        		<option value="All">' .getFixedLabel('ALL').'</option>';
        foreach($object_array as $module => $object_name){
            $selected = '';
            if($search_module != '' && $module == $search_module){
                $selected = 'selected';
            }
            if($search_module == '' && $module == 'All'){
                $selected = 'selected';
            }
            if(isPermitted($module,"index") == "yes"){
                 if($module=='DailyReport')
                 {
                    $modulelabel=getFixedLabel('DAILYREPORT');
                 }
                 else if($module=='WeekReport')
                 {
                     $modulelabel=getFixedLabel('WEEKREPORT');
                 }
                 else if($module=='MonthReport')
                 {
                     $modulelabel=getFixedLabel('MONTHREPORT');
                 }
                 else
                    $modulelabel = getTranstab($module);
                $strcontent.='<option value="'.$module.'"'.  $selected.' >'. $modulelabel.'</option>';
            }
        }
        $strcontent.='</select>&nbsp;&nbsp;</div>
                <span id="global_search_total_count">&nbsp;</span>
				<input type="hidden" id="hidden_total_count" name="hidden_total_count" value="">
            </div>';
     }
    return $strcontent;
}

function getLanguagepackage(){
	global $adb;
    $query="select ld_tab.tabid,ld_tab.tablabel
     from ld_tab 
     where ld_tab.presence=0 and ld_tab.tabid not in(1,7,27,28,29,30,33,35,44,51,52,61,16)
     and ld_tab.tablabel not in ('Attachment','Cache','Often_UseReport') 
     ORDER BY ld_tab.tabsequence";
    $result=$adb->query($query." ORDER BY ld_tab.tabsequence");
    $num_rows=$adb->num_rows($result);
    $alltabs=array();
    for($i=0;$i<$num_rows;$i++){
        $alltabs[]=array(
        'tabid'=>$adb->query_result($result,$i,'tabid'),
        'tablabel'=>$adb->query_result($result,$i,'tablabel'),
        'newtabname'=>$adb->query_result($result,$i,'newtabname')
        );
    }
    $reportlogid=getTabid('ReprotLog');
    $alltabs[]=array(
    'tabid'=>$reportlogid,
    'tablabel'=>'DailyReport',
    'newtabname'=>getFixedLabel('DAILYREPORT')
    );
    $alltabs[]=array(
        'tabid'=>$reportlogid,
        'tablabel'=>'WeekReport',
        'newtabname'=>getFixedLabel('WEEKREPORT')
        );
    $alltabs[]=array(
        'tabid'=>$reportlogid,
        'tablabel'=>'MonthReport',
        'newtabname'=>getFixedLabel('MONTHREPORT')
        );
    return $alltabs;
    //$smarty->assign('ALLTABS',$alltabs);
    
}

/**
 * To get the modules allowed for global search this function returns all the 
 * modules which supports global search as an array in the following structure 
 * array($module_name1=>$object_name1,$module_name2=>$object_name2,$module_name3=>$object_name3,$module_name4=>$object_name4,-----);
 */
function getSearchModules($filter = array()){
	global $adb;
	// vtlib customization: Ignore disabled modules.
	//$sql = 'select distinct ld_field.tabid,name from ld_field inner join lingdang_tab on lingdang_tab.tabid=ld_field.tabid where lingdang_tab.tabid not in (16,29)';
    /*
    *AUTHOR:BY LD KEVIN
    *DATE:20130131
    *DESCRIPTION:修改bug3245
    *and isentitytype=1
    */
	$sql = 'select distinct ld_field.tabid,name from ld_field inner join ld_tab on ld_tab.tabid=ld_field.tabid where ld_tab.tabid not in (16,29) and ld_tab.presence != 1 and 
            (ld_tab.name = "Attachment"  or isentitytype=1) and ld_field.presence in (0,2)  and ld_tab.name!=\'InventoryQuery\' order by ld_tab.tabsequence asc';
	// END
   
	$result = $adb->pquery($sql, array());
	while($module_result = $adb->fetch_array($result)){
		if(!empty($filter)){
			$modulename = $module_result['name'];
			//$modulename.='日报';
			// Do we need to filter the module selection?
			if(!empty($filter) && is_array($filter) && !in_array($modulename, $filter)) {
				continue;
			}
			// END
			if($modulename != 'Calendar'){
				$return_arr[$modulename] = $modulename;
			}else{
				$return_arr[$modulename] = 'Activity';
			}
		}
	}
	return $return_arr;
}

?>