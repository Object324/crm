<?php
/*
zyh
用户详情页增加附件
PROT197 
20150420
*/
    require_once('data/Inventory.php');
    global $adb,$current_user,$currentModule,$url_string,$list_max_entries_per_page_new;
    $smarty = new lingdangCRM_Smarty;
    $module = $_REQUEST['frommodule'];
    $focus = CRMEntity::getInstance($module);
    $customView = new CustomView($module);
    $viewid = $customView->getViewId($module);
    $record = $_REQUEST['record'];//详情页用户userid
    $current_userid = $current_user->id;//获取当前登录用户id
    $page = $_REQUEST['page'];
    $sorder = $focus->getSortOrder();
    $order_by = $focus->getOrderBy();
    //按钮
	$button = '';
	if (isPermitted('Attachment', "Create", '') == 'yes') {
	    $button .= '<a title="'.getFixedLabel('CREATE').'" target="_blank" 
	    href="index.php?module='.$module.'&action=EditView&return_module='.$module.'&return_action=DetailView&Create=yes&swid='.$record.'&user_id='.$record.'" target="_blank">
        <span>'.getFixedLabel('CREATE').'</span></a>';
	}
    //$queryGenerator = new QueryGenerator($module, $current_user);
    $queryGenerator =QueryGenerator::getInstance($module, $current_user,$customView);
    ///得到对应视图的查询字段
    if ($viewid != "0") {
       $queryGenerator->initForCustomViewById($viewid);
    } else {
    	$queryGenerator->initForDefaultCustomView();
    }


 
 
 
    //$controller = new ListViewController($adb, $current_user, $queryGenerator);
    crm_load_function_file('AttachmentsListViewController','include/ListView','AttachmentsListViewController'); 
    $controller = new AttachmentsListViewController($adb, $current_user, $queryGenerator,$module);
    
    $page_list_query = $queryGenerator->getQuery("",1);
    $list_query = $queryGenerator->getQuery("",2);
    //25022: 用户管理：进入系统管理员明细，新增附件保存后，编辑附件，结果系统管理员明细不显示附件了
    //因为全部数据分类设置了查询条件
    //$page_list_query='select  DISTINCT ld_attachmentsforbills.attachmentsid '.$queryGenerator->getFromClause().' where ld_attachmentsforbills.deleted=0 ';
    
    $page_list_query .= ' and ld_attachmentsforbills.reltab in ("用户","Users") and ld_attachmentsforbills.smownerid = ' . $record;
    $where = $queryGenerator->getConditionalWhere();
    $customsortorder = $customView->getCustomViewOrderBy($viewid);
    $queryMode = (isset($_REQUEST['query']) && $_REQUEST['query'] == 'true');
    //获取sql总条目数
   
    $count_result = $adb->query($page_list_query);
	$noofrows = $adb->num_rows($count_result);
    $start = $page;
    crm_load_function_file('VT_getSimpleNavigationValues','include/utils','ListViewUtils');
    $navigation_array = VT_getSimpleNavigationValues($start,$list_max_entries_per_page_new,$noofrows);
    // Navigation
    $navigationOutput = str_replace('class="Link"','class=""',getTableHeaderSimpleNavigation2($navigation_array, $url_string, $module, 'ModulesDetails', $record));
    $limit_start_rec = ($start-1) * $list_max_entries_per_page_new;
  //  $page_list_query .= " ORDER BY $customsortorder $focus->table_name.$focus->table_index $sorder";
    list($page_list_query,$order_by,$sorder) = $queryGenerator->customview->getOrderWhere($page_list_query);
    $list_query=$list_query."  inner join ($page_list_query LIMIT $limit_start_rec, $list_max_entries_per_page_new ) as tmp 
                            on tmp.attachmentsid=ld_attachmentsforbills.attachmentsid ";
    //28804: 控制面板 > 用户管理 明细界面：附件区块，点击蓝色字体列头进行排序，没有反应
   list($list_query,$order_by,$sorder) = $queryGenerator->customview->getOrderWhere($list_query);                         
                            // ORDER BY $customsortorder $focus->table_name.$focus->table_index $sorder ";
    $list_result = $adb->pquery($list_query, array());
    //获取列头
    $listview_header = $controller->getListViewHeader($focus,$module,$url_string,$sorder,$order_by,$skipAction);
    foreach($listview_header as $index=>$headerhtml)
    {
        //28804: 控制面板 > 用户管理 明细界面：附件区块，点击蓝色字体列头进行排序，没有反应
        $tmp_listview_header[]=str_replace('getListViewEntries_js','getUserAttachEntries_js',$headerhtml);
        
    }
    $listview_header=$tmp_listview_header;
  //  array_splice($listview_header,5,2);//不显示‘相关模块’‘相关对象’ zyh
    //获取内容
    $listview_entries = $controller->getListViewEntries($focus,$module,$list_result,$navigation_array,$skipAction);

    $row_count=$queryGenerator->getMainColumnCount();
    $row_header = count($listview_header);

    $PROHTML=Inventory::createModWithDetailhtml($listview_entries,$row_count,$row_header,"No","",$controller->listchkbox_width);

    $smarty->assign('PROHTML',$PROHTML);
    
    $smarty->assign("NAVIGATION", $navigationOutput);
    $smarty->assign('RELATEDHEADER',$listview_header);
    $smarty->assign('RELATEDENTRIES',$listview_entries);
    $smarty->assign("CUSTOM_BUTTON",$button);
    $smarty->assign("RELATEDLISTDATA", $return_value);
    $smarty->assign("record",$record);
    $smarty->assign("page",$page);
    $smarty->display('DetailView/UsersAttachments.tpl');
    die;
?>