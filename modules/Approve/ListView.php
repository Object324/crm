<?php
/***********************************************
**edit:Chj
**date:2016-11-14
**reason:我的审批中心
***********************************************/
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $list_max_entries_per_page_new,$current_user,$currentModule;
global $approvestatus;

//wym 230605 获取该模块列表最多条数
//wym 231221 XUQIU1002380 列表显示条数可按成员设置不同的条数
$list_max_entries_per_page_new=getUsersettingByLabel($currentModule,$current_user->id,'MaxEntriesPerPageByuser')??getUsersettingByLabel($currentModule,1,'MaxEntriesPerPage');
$list_max_entries_per_page_new=empty($list_max_entries_per_page_new)?'20':$list_max_entries_per_page_new;

if(!empty($_REQUEST['fromapprovemodule'])){

	if(empty($_REQUEST['approvestatus'])){
		$approvestatus = 0;
	}else{
		$approvestatus = $_REQUEST['approvestatus'];
	}

	crm_load_class_file('Inventory','data');
	$smarty=new lingdangCRM_Smarty;
	$fromApproveModule = $_REQUEST['fromapprovemodule'];
	$focus = CRMEntity::getInstance($fromApproveModule);
	$skipAction==false;

	
	if(!empty($_REQUEST['customview']) && $_REQUEST['customview'] == 'yes'){
		$_SESSION['customview'][$currentModule.'_'.$fromApproveModule]['viewid'] = $approvestatus;
	}
	if($_SESSION['customview'][$currentModule.'_'.$fromApproveModule]['viewid'] != ''){
		$approvestatus = $_SESSION['customview'][$currentModule.'_'.$fromApproveModule]['viewid'];
	}
	//列表按钮
	$focus->getModuleLogic($currentModule)->getListViewButtons();

	//获取查看范围
	$MergeSmowner=getCurSmOwnerSearchScope($currentModule);
	unset($MergeSmowner["UserCombo"][$current_user->id]);
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
        $SmOwner_option_arr[] = array('label'=>getFixedLabel('ALL'),'value'=>'SmOwner_Search_All','selected'=>true);
    }
    $smarty->assign('Merge_SmOwner_arr',json_encode($SmOwner_option_arr));
	//$criteria = getcriteria_options();
	
	//实例化数据分类
	crm_load_class_file('cls_Approve_CustomView','modules/Approve/ListView');
    include(globalStatic::$root_directory.'modules/Approve/ListView/ApproveCommon.php');

	$customView = new cls_Approve_CustomView($fromApproveModule);

		//记住上次查询范围
	if($_REQUEST['SearchScope'] !=null&&$_REQUEST['SearchScope'] !=''){
		$SearchScope=$_REQUEST['SearchScope'];
		$_SESSION['lvs'][$currentModule.'_'.$fromApproveModule]['SearchScope']=$SearchScope;
		$smarty->assign('SelectedOwner2', $_REQUEST['SearchScope']);
	}else if(isset($_SESSION['lvs'][$currentModule.'_'.$fromApproveModule]['SearchScope'])&&$_SESSION['lvs'][$currentModule.'_'.$fromApproveModule]['SearchScope']!=null&&$_SESSION['lvs'][$currentModule.'_'.$fromApproveModule]['SearchScope']!=''){
		$_REQUEST['SearchScope'] = $_SESSION['lvs'][$currentModule.'_'.$fromApproveModule]['SearchScope'];
		$smarty->assign('SelectedOwner2',$_SESSION['lvs'][$currentModule.'_'.$fromApproveModule]['SearchScope']);
	}else {
		$SearchScope="SmOwner_Search_All";
		$_REQUEST['SearchScope'] = $SearchScope;
		$_SESSION['lvs'][$currentModule.'_'.$fromApproveModule]['SearchScope']=$SearchScope;
		$smarty->assign('SelectedOwner2',"SmOwner_Search_All");
	}

	//实例化列表SQL类
	crm_load_class_file('cls_Approve_ListView','modules/Approve/ListView');
	$queryGenerator = new cls_Approve_ListView();
 
	$list_query = $queryGenerator->getquery($fromApproveModule, $current_user,$customView);

	if($_REQUEST['query'] == 'true') {
		$_REQUEST['searchtype'] = trim($_REQUEST['searchtype']);
		$queryGenerator->queryGenerator->addUserSearchConditions($_REQUEST);
		//序时簿查询记住搜索条件
		if($_REQUEST['searchtype'] == 'BasicSearch'){
			$_REQUEST['search_text'] = trim($_REQUEST['search_text']);
			$searcharr = explode(':',$_REQUEST['search_field']);
			if($_REQUEST['search_text']!='' || (empty($_REQUEST['search_text']) && 'D' == $searcharr[count($searcharr)-1])){
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
		//审批中心，设置查询条件后，跳转到下一页， 查询条件没了
		$ustring = getSearchURL($_REQUEST);
		$url_string .= "&query=true$ustring";
		$smarty->assign('SEARCH_URL', $url_string);
		if(!empty($input)){
			$smarty->assign('SEATCH_INPUT',$input);
		}
	}
    
	if(get_file_address($fromApproveModule,$fromApproveModule.'DetailFieldsHtml')){
		crm_load_class_file('cls_Approve_TabDetailListViewController','modules/Approve/ListView');
		$controller = new cls_Approve_TabDetailListViewController($adb, $current_user, $queryGenerator->queryGenerator,$fromApproveModule);	
	}else if(get_file_address($fromApproveModule,'ProductDetails')||$fromApproveModule=='Accounts'||$fromApproveModule=='Vendors')
    {
   	    crm_load_class_file('cls_Approve_ProductListViewController','modules/Approve/ListView');
		$controller = new cls_Approve_ProductListViewController($adb, $current_user, $queryGenerator->queryGenerator,$fromApproveModule);	
    }
    else if(get_file_address($fromApproveModule,$fromApproveModule.'Details'))
    {
        crm_load_class_file('cls_Approve_AttachmentListViewController','modules/Approve/ListView');
		$controller = new cls_Approve_AttachmentListViewController($adb, $current_user, $queryGenerator->queryGenerator,$fromApproveModule);
    }
    else{
		crm_load_class_file('cls_Approve_ListViewController','modules/Approve/ListView');
		$controller = new cls_Approve_ListViewController($adb, $current_user, $queryGenerator->queryGenerator);	
	}

	//高级查询字段
	$advanced_search = $controller->getAdvancedSearchOptionString();
    //20230613 duan BUG0068189 审批列表查找后获取页面url时,缺少参数
    $listpageurl = getlisturl_aftersave();
    if(strpos('fromapprovemodule',$listpageurl) === false){
        $listpageurl .= '&fromapprovemodule='.$fromApproveModule;
    }
	$smarty->assign("LISTPAGEURL", $listpageurl);
//	$alphabetical = AlphabeticalSearch($currentModule,'index',$focus->def_basicsearch_col,'true','basic','','','','','');
    crm_load_function_file('AlphabeticalSearch','include/utils','ListViewUtils');
	//数据分类视图
	$customview_html = $customView->getCustomViewAll($approvestatus,$fromApproveModule,'');
    //@edit zsk 2024/06/11 XUQIU20240516-01 查询分类功能优化
//获取查询分类分组列表
    $groupList=$customView->getCustomViewGroupList($customview_html);
    $smarty->assign("CUSTOMVIEWGROUPLIST",$groupList);

	//分页
	$page_list_query=$queryGenerator->getPageListQuery();
    // dump($page_list_query);
    
	$count_result=$adb->pquery($page_list_query,array());
	$noofrows=$adb->num_rows($count_result);
    //35555: （xiaoshou360.com/ldcrm）审批中心>待处理列表界面>点击翻页>切换到已处理界面>点击打开任意模块：打开的列界面显示的是第二页。
	

	//列表sql
	list($page_list_query,$order_by,$sorder) = $customView->getOrderWhere($page_list_query);
   
    
    if($_REQUEST['order_by']&&empty($order_by))
     {
      
        $order_by=$_REQUEST['order_by'];
        $sorder=$_REQUEST['sorder'];
        $page_list_query.=' order by '.$order_by.' '.$sorder.' ,'.$focus->table_name.'.'.$focus->table_index. ' '.$sorder;
        
     }
     else 	if($_SESSION[$focus->module_name.'Approve'.$focus->order_by_session_col]!=''&&empty($order_by))
    {
        //28402: 审批中心：列表表格【发起时间】列列头增加点击排序功能
        $order_by=$_SESSION[$focus->module_name.'Approve'.$focus->order_by_session_col];
        $sorder=$_SESSION[$focus->module_name.'Approve'.$focus->desc_session_col];
        $page_list_query.=' order by '.$order_by.' '.$sorder.', '.$focus->table_name.'.'.$focus->table_index. ' '.$sorder;
    }
   
    $_SESSION[$fromApproveModule.'_approve_listquery']=$page_list_query;
   	$tmp_result=$adb->pquery("$page_list_query");
    $noofrows=$adb->num_rows($tmp_result);
	 for($i=0;$i<$noofrows;$i++)
    {
        $navigationids[]=$adb->query_result($tmp_result,$i,0);
    }
    
    $start = ListViewSession::getRequestCurrentPage($currentModule.'##'.$fromApproveModule, $noofrows, '', '');
	$navigation_array = VT_getSimpleNavigationValues($start,$list_max_entries_per_page_new,$noofrows);
	$navigationOutput = getTableHeaderSimpleNavigation2($navigation_array, '', $currentModule, 'index','');
    
   
	$navigationOutput = strtr($navigationOutput,array('getListViewEntries_js'=>'getApproveEntries_js'));

    //hzx 20231207 XUQIU1002273 PC端模块列表界面，分页样式优化
    $smarty->assign("TABNAME", getParentTab());
    $smarty->assign("STARTPAGE", ceil($start));
    $smarty->assign("LISTVIEWRECORDCOUNT", ceil($noofrows));
    $smarty->assign("LISTVIEWPAGECOUNT", ceil($noofrows/$list_max_entries_per_page_new));
	$smarty->assign("LISTVIEWPERPAGENUM", json_encode(getlistmaxentries_per_page($list_max_entries_per_page_new)));

	$limit_start_rec = ($start-1) * $list_max_entries_per_page_new;
	$countsql = $list_query;
    
     //28382: 审批中心>待处理列表>单据列表：进入单据明细审批单据，最后一步审批通过后。下一页按钮显示为灰色不可点击。应该是可以点击下一页
	$tmp_limit_start_rec=$limit_start_rec;
	if($limit_start_rec>0)
	{
		$tmp_limit_start_rec=$limit_start_rec-1;
	}
	$tmp_list_max=$list_max_entries_per_page_new+1;

	$list_query.=" inner join ( $page_list_query limit $limit_start_rec,$list_max_entries_per_page_new ) as temp on temp.$focus->table_index=$focus->table_name.$focus->table_index ";
	$list_query .= $queryGenerator->queryGenerator->getWhereClause();
	list($list_query,$order_by,$sorder) = $customView->getOrderWhere($list_query,'',$queryGenerator->queryGenerator);
     
     if($_REQUEST['order_by']&&empty($order_by))
     {
        $order_by=$_REQUEST['order_by'];
        $sorder=$_REQUEST['sorder'];
        $list_query.=' order by '.$order_by.' '.$sorder.' ,temp.'.$focus->table_index. ' '.$sorder;
       
        
     }
     else 	if($_SESSION[$focus->module_name.'Approve'.$focus->order_by_session_col]!=''&&empty($order_by))
    {
        $order_by=$_SESSION[$focus->module_name.'Approve'.$focus->order_by_session_col];
        $sorder=$_SESSION[$focus->module_name.'Approve'.$focus->desc_session_col];
        $list_query.=' order by '.$order_by.' '.$sorder.', temp.'.$focus->table_index. ' '.$sorder;
    }

    $_SESSION[$fromApproveModule.'_approve_Ids']=$navigationids;

	$list_result = $adb->pquery($list_query,array());

	//获取列头
	$listview_header = $controller->getListViewHeader($focus,$fromApproveModule,$url_string,$sorder,$order_by,$skipAction);
   
  
	//获取列对应宽度
	$listview_headerwidth=getModuleWidth($focus,$controller->getModuleViewFieldsWidth(),$fromApproveModule);
        /**
     * 列宽具体信息
     * 
     * */
    $smarty->assign('LISTHEADERWIDTH',getModuleWidth($focus,$controller->getModuleViewFieldsWidth(),$currentModule));
	//获取列表内容
	$listview_entries = $controller->getListViewEntries($focus,$fromApproveModule,$list_result,$navigation_array,false);

	//总列数
	$colspan_count = sizeof($listview_header)+1;

	//获取操作列的宽度
    $operationWidth=0;
    //zkt 20220506 51452	（http://tuvaustria.gnway.cc/crm/）审批中心》知识管理审批，列表显示字段错位了（火狐浏览器）
    if($_REQUEST['approvestatus']==1||$fromApproveModule=='Documents')
	   $operationWidth = $focus->getModuleLogic($currentModule)->getListButtomName();
  //  $operationWidth=0;

	$smarty->assign('OPERATIONWIDTH',$operationWidth);
	
	//获取列表总宽度
	$total_width=$controller->getListTotalWidth($listview_headerwidth,$operationWidth);
	$smarty->assign('TOTALWIDTH',$total_width);

	//列表内容checkbox是否显示，待处理：yes，已处理：no
	if($approvestatus == 1){
		$checkbox = 'no';
	}else{
		$checkbox = 'yes';
	}
     $smarty->assign('RESULT_APPROVE',$_REQUEST['result_aprove']);

	//获取列表html
    $listview_header_search = [];
	if((get_file_address($fromApproveModule,'ProductDetails') || get_file_address($fromApproveModule,'ContactsDetails') || get_file_address($fromApproveModule,'VendorsDetails'))){
		//列表字段对应的columnname 和 module
		$headerinfo=$queryGenerator->queryGenerator->productDetails->getListViewHeaderInfo();
       
		//基本查询字段
		//$listview_header_search['approveby_user']=getFixedLabel('Sponsor');
		//$listview_header_search['approveby_datetime']=getFixedLabel('Launch_time');
		$tmp_listview_header_search = $queryGenerator->queryGenerator->productDetails->getBasicSearchFieldInfoList();
           
		crm_load_class_file('clsTotal_List','include/ListView');
		$clstotalobj=new clsTotal_List($controller);
        $clstotalobj->setCurpageModule($currentModule);
		$totalfldhtml = $clstotalobj->getTotalFldCount($page_list_query." LIMIT $limit_start_rec, $list_max_entries_per_page_new ",$list_result,$noofrows);
		
		$row_count=$queryGenerator->queryGenerator->getMainColumnCount();
		$smarty->assign('PROHTML',Inventory::createModWithDetailhtml($listview_entries,$row_count,$colspan_count,$checkbox,"",$controller));
		$smarty->assign('HEADERNAME',$headerinfo['fieldname']);
		$smarty->assign('HEADERMODULE',$headerinfo['module']);
		//分页 总条目数
		if($noofrows-$list_max_entries_per_page_new-$limit_start_rec>0)
			$recordListRangeMsg = getRecordRangeMessageForServieCharge($list_max_entries_per_page_new, $limit_start_rec,$noofrows);
		else
			$recordListRangeMsg = getRecordRangeMessageForServieCharge($noofrows-$limit_start_rec, $limit_start_rec,$noofrows);
	}else if(get_file_address($fromApproveModule,$fromApproveModule.'DetailFieldsHtml')){
		//列表字段对应的columnname 和 module
		$headerinfo=$queryGenerator->queryGenerator->TabDetails->getListViewHeaderInfo();
		//基本查询字段
		//$listview_header_search['approveby_user']=getFixedLabel('Sponsor');
		//$listview_header_search['approveby_datetime']=getFixedLabel('Launch_time');
        //edit:can 2020-09-23 42725: （ http://111.30.26.19:8020/crm/ [^]）苏宁客户问题，审批中心 > 我提交的>查找；进行查找操作，每个查找字段 设置关键字都无法查找到单据信息
		$tmp_listview_header_search = $queryGenerator->queryGenerator->TabDetails->getBasicSearchFieldInfoList();
		crm_load_class_file('clsTotal_List','include/ListView');
		$clstotalobj=new clsTotal_List($controller);
        $clstotalobj->setCurpageModule($currentModule);
		$totalfldhtml = $clstotalobj->getTotalFldCount($page_list_query." LIMIT $limit_start_rec, $list_max_entries_per_page_new ",$list_result,$noofrows);
		$row_count=$queryGenerator->queryGenerator->getMainColumnCount();
		$smarty->assign('PROHTML',Inventory::createModWithDetailhtml($listview_entries,$row_count,$colspan_count,$checkbox,"",$controller));
		$smarty->assign('HEADERNAME',$headerinfo['fieldname']);
		$smarty->assign('HEADERMODULE',$headerinfo['module']);
		//分页 总条目数
		if($noofrows-$list_max_entries_per_page_new-$limit_start_rec>0)
			$recordListRangeMsg = getRecordRangeMessageForServieCharge($list_max_entries_per_page_new, $limit_start_rec,$noofrows);
		else
			$recordListRangeMsg = getRecordRangeMessageForServieCharge($noofrows-$limit_start_rec, $limit_start_rec,$noofrows);
	}else{
		//基本查询字段
		//$listview_header_search['approveby_user']=getFixedLabel('Sponsor');
		//$listview_header_search['approveby_datetime']=getFixedLabel('Launch_time');
		$tmp_listview_header_search = $controller->getBasicSearchFieldInfoList();
		crm_load_class_file('clsTotal_List','include/ListView');
		$clstotalobj=new clsTotal_List($controller);
        $clstotalobj->setCurpageModule($currentModule);
		$totalfldhtml = $clstotalobj->getTotalFldCount($page_list_query." LIMIT $limit_start_rec, $list_max_entries_per_page_new ",$list_result,$noofrows);
		$smarty->assign('DEAILHTML',Inventory::createHTML($listview_entries,$fromApproveModule,0,$colspan_count,$focus->logic->list_buttons,$controller,$checkbox));
		$smarty->assign("HEADERNAME",$controller->headername);
		//分页 总条目数
		$recordListRangeMsg = getRecordRangeMessage($list_result, $limit_start_rec,$noofrows);
	}
	/*
	*edit: chj
	*date; 2020/9/16
	*reason: 单据列表和相关信息界面性能优化:全部合计
	*/
	if(!empty($_REQUEST['getTotalHtml']) && $_REQUEST['getTotalHtml'] == 'yes'){
		$thistotal=$clstotalobj->getAllTotalColumnData();
		$totalfldhtml=$clstotalobj->getAllTotalRow_html($thistotal,'list');
		$_REQUEST['diony']='yes';
		$arr['content']=$totalfldhtml;
		ConvertTojsonString(1,$arr,'success');
	}
	Crm_load_class_file("CommonView","modules/CustomView");
	$smarty->assign("DATETIMESTR",json_encode(CommonView::stdFilterDateTimeStr()));
   if($_REQUEST['approvestatus']==1)
   {
    //已处理
    $listview_header_search=array();
   }
	foreach($tmp_listview_header_search as $key=>$searchcolumn)
    {
        $listview_header_search[$key]=$searchcolumn;
    }
	//获取批量操作时记录数上限
	$deployarray=getSys_deploy(67);
	//列表是否有操作列
	$list_nooperating = 'no';
	if($approvestatus == 1){
		$list_nooperating = 'yes';
	}
	//列表header是否显示checkbox
	if($approvestatus == 1){
		$smarty->assign('LIST_NOCHECKBOX','no');
	}
	$smarty->assign('LISTHEADER', $listview_header);
	$smarty->assign('SEARCHLISTHEADER',$listview_header_search);
	$smarty->assign('TOTALFLDHTML',$totalfldhtml);
	$smarty->assign("ALPHABETICAL", $alphabetical);
	$smarty->assign("FIELDNAMES", $advanced_search);
	$smarty->assign("CRITERIA", $criteria);
	$smarty->assign('MODULE',$currentModule);
	$smarty->assign('FROMAPPROVEMODULE',$fromApproveModule);
	$smarty->assign('APPROVESTATUS',$_REQUEST['approvestatus']);
	$smarty->assign('Merge_SmOwner',$MergeSmowner);
	$smarty->assign("CUSTOMVIEW_OPTION",$customview_html);
	$smarty->assign('NO_CUSTOMVIEW','yes');
	$smarty->assign('NUMOFROWS',$noofrows);
	$smarty->assign('recordListRange',$recordListRangeMsg);
	$smarty->assign("NAVIGATION", $navigationOutput);
	$smarty->assign('LISTHEADERWIDTH',$listview_headerwidth);
	$smarty->assign('BATCHNUM',$deployarray['deploy_value']);
	$smarty->assign('LIST_NOOPERATING',$list_nooperating);
	$smarty->assign('MAX_RECORDS', $list_max_entries_per_page_new);
	$smarty->assign('LISTHEADERCOUNT', $colspan_count);
    $smarty->assign('CHKBOXWIDTH',$controller->listchkbox_width);

    // @edit:dong @date:2020/08/19 @reason: 查找 用于区分搜索类型
    $smarty->assign('SEARCHTYPE',$_REQUEST['searchtype']);
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

    // ljj 2023-08-29 XUQIU1001610 树结构设置和成员管理，左侧分类名称增加计数功能
    $cls_MyCRMcryptobj=new cls_MyCRMcrypt();
    $smarty->assign("Encrypt_TreeWhere",$cls_MyCRMcryptobj->encode($queryGenerator->queryGenerator->getSqlNoTreeWhere($page_list_query)));

    //zxm 20230614 获取列表页面公共参数并assign到tpl
    ListViewCommonAssign($currentModule,$smarty,$focus);
    //diony 20231114 审批中心不应该有报表图标 BUG0075483
    $smarty->assign("MODULEADVANCESTAGESTATUS", 'no');

	if(isset($_REQUEST['ajax']) && $_REQUEST['ajax'] != ''){
		if((get_file_address($fromApproveModule,'ProductDetails') || get_file_address($fromApproveModule,'ContactsDetails') || get_file_address($fromApproveModule,'VendorsDetails') || get_file_address($fromApproveModule,$fromApproveModule.'DetailFieldsHtml'))){
			$smarty->display("ProductListViewEntries.tpl");
		}else{
			 $smarty->display("ListViewEntries.tpl");
		}
		
	}else{
		$smarty->display('ListView.tpl');
	}
}

?>