<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global  $currentModule, $theme,$languageType;
global $list_max_entries_per_page_new;
global $current_user,$adb;
global $current_user;
//wym 230605 获取该模块列表最多条数
//wym 231221 XUQIU1002380 列表显示条数可按成员设置不同的条数
$list_max_entries_per_page_new=getUsersettingByLabel($currentModule,$current_user->id,'MaxEntriesPerPageByuser')??getUsersettingByLabel($currentModule,1,'MaxEntriesPerPage');
$list_max_entries_per_page_new=empty($list_max_entries_per_page_new)?'20':$list_max_entries_per_page_new;

if(isset($_REQUEST['SearchScope'])&&$_REQUEST['SearchScope']!='')
{
    //越权访问
    $ScopOfAuthority=ScopOfAuthority::getInstance($adb,$currentModule);
    $ScopOfAuthority->isCorrectSearchScope($_REQUEST['SearchScope']);
}
if(isset($_REQUEST['senioruserid']))
{
    //越权访问
    $ScopOfAuthority=ScopOfAuthority::getInstance($adb,$currentModule);
    $userids=explode(',',$_REQUEST['senioruserid']);
    for($i=0;$i<sizeof($userids);$i++)
    {
        $ScopOfAuthority->isCorrectSearchScope($userids[$i]);
    }
    
}
crm_load_function_file('VT_getSimpleNavigationValues','include/utils','ListViewUtils');

crm_load_class_file('Inventory','data');
$fromtype = $_REQUEST['fromtype'];
$sales_stage = $_REQUEST['advance_stage'];
$oldcustomer_marketing = $_REQUEST['oldcustomer_marketing'];
$select_stage_value = $_REQUEST['select_stage_value'];
if(!empty($fromtype)&&$fromtype=='salesfunnel'){
     $focus = CRMEntity::getInstance($currentModule);
    crm_load_class_file('cls_module_advance','modules/Settings');
    $cls_module_advance = new cls_module_advance($currentModule);
    $ModuleAdvanceinfo=$cls_module_advance->getModuleAdvance();
    $advancfieldname=$ModuleAdvanceinfo['module_field'];
    $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey('fieldname',$advancfieldname);
    $advft_criteria = $_REQUEST['advft_criteria'];
    $advft_criteria_groups = $_REQUEST['advft_criteria_groups'];
    $advft_criteria = empty($advft_criteria)?[]:json_decode($advft_criteria,true);
    $advft_criteria_groups = empty($advft_criteria_groups)?'[null,{"groupcondition":""}]':$advft_criteria_groups;
    //edit:can 20210830 047740: （https://www.51mis.com/hy/laitai99999 [^] ） 项目管理-服务项目中的漏斗 不进行类型选择数据显示正常，一旦进行选择数据显示不正常
    if(!empty($sales_stage)){
        $lenOfAdv = count($advft_criteria);
        //	BUG0060791	zxm20230329  bug管理，高级查找搜索数据后，点击进度漏斗弹出层中有数据的阶段选项后，阶段列表界面显示没有数据
        $tmpgroupid = 1;
        if($lenOfAdv>=1){
            $advft_criteria[$lenOfAdv-1]['columncondition'] = 'and';
            $tmpgroupid = $advft_criteria[$lenOfAdv-1]['groupid'];
        }

        $advft_criteria[] = ['groupid'=>$tmpgroupid,
            'columnname'=>$fieldinfo->getTableName().":".$fieldinfo->getColumnName().":$advancfieldname:$currentModule_".$fieldinfo->getFieldType().":V",
            'comparator'=>'e',
            'value'=>$sales_stage,
            'columncondition'=>''
        ];
    }
    if(!empty($oldcustomer_marketing)){
        $lenOfAdv = count($advft_criteria);
        if($lenOfAdv>=1){
            $advft_criteria[$lenOfAdv-1]['columncondition'] = 'and';
        }
        $advft_criteria[] = ['groupid'=>1,
            'columnname'=>'ld_potential:oldcustomer_marketing:oldcustomer_marketing:Potentials_老客户营销:V',
            'comparator'=>'c',
            'value'=>$oldcustomer_marketing,
            'columncondition'=>''
        ];
    }

    if(!empty($select_stage_value)){
        //抄的ListViewAdvanceStageCharte.php的代码
        global $global_pick_list_depencyfield;
       
        crm_load_class_file('lingdang_DependencyPicklist', 'modules/PickList');
        $picklistdepency = lingdang_DependencyPicklist::getPicklistDependencyDatasource($currentModule);
        $picklistdepencyfields = json_decode(ldcrm_json_encode($global_pick_list_depencyfield), true);
        $cur_advance_columnname = $cls_module_advance->moduleadvance['module_field'];
        $prev_advance_fieldname = $picklistdepencyfields[$cur_advance_columnname];
        $fieldobj = $focus->fieldobj->getFieldInfoobjBykey("fieldname", $prev_advance_fieldname);
        $all_prev_advance_fieldname_value = getAllPickListValues($prev_advance_fieldname);
       
        if(in_array($select_stage_value, $all_prev_advance_fieldname_value)){
            $lenOfAdv = count($advft_criteria);
            if($lenOfAdv>=1){
                $advft_criteria[$lenOfAdv-1]['columncondition'] = 'and';
            }
            $typeOfData = explode('~',$fieldobj->typeofData);
            $advft_criteria[] = ['groupid'=>1,
                'columnname'=>$fieldobj->tableName.':'.$fieldobj->columnName.':'.$fieldobj->fieldName.':'.'Potentials_'.$fieldobj->fieldLableKey.':'.$typeOfData[0],
                'comparator'=>'e',
                'value'=>$select_stage_value,
                'columncondition'=>''
            ];
        }
    }
   
    $_REQUEST['advft_criteria'] = json_encode($advft_criteria);
    $_REQUEST['advft_criteria_groups'] = $advft_criteria_groups;
}
$smarty = new lingdangCRM_Smarty();

//zkt 列表界面增加树结构显示
crm_load_class_file('cls_Module_Tree', 'include/utils');
$cls_module_tree = cls_Module_Tree::getInstance($currentModule);
if(isset($_REQUEST['ajax']) && $_REQUEST['ajax'] != '')
{
    
}
else
{
    if($cls_module_tree->moduleenable=='yes'){
        //加载初始listview树状结构
        $modulelisttree = $cls_module_tree->getModuleListTree();
        $smarty->assign('MODULElISTTREE',$modulelisttree);
        $module_list_treeselectrecord=0;
        //若$_SESSION中储存的selectrecord值,为级联下拉值id，设置selectrecord为0（或获取下级对应html）
        if(isset($modulelisttree)&&$modulelisttree['enable']=='yes'&&!isset($modulelisttree['list'][$_SESSION['module_list_tree'][$currentModule]['selectrecord']])){
            //$_SESSION['module_list_tree'][$currentModule] = array('selectrecord'=>0,'list'=>array());
            //获取下级对应html
            $sessionarr = $_SESSION['module_list_tree'][$currentModule];
            $Inithtmlexpand = $cls_module_tree->getInithtmlexpand($sessionarr['selectrecord'],$sessionarr['list']);
            $smarty->assign('Inithtmlexpand',$Inithtmlexpand);
        }
    }
    //获取设置选中的树结构id和list
    $module_list_treeselectrecord=0;
    if(isset($_SESSION['module_list_tree'][$currentModule])){
        $module_list_treeselectrecord= $_SESSION['module_list_tree'][$currentModule]['selectrecord'];
    }
    $smarty->assign('MODULE_TREE_PICKLIST_ID',$module_list_treeselectrecord);
}





//$_SESSION['module_list_tree'][$currentModule]=$_REQUEST['groupid'];
//$smarty->assign('MODULETREElIST',$modulelisttree['list']);
//$smarty->assign('MODULETREEENABLE',$modulelisttree['enable']);
//$smarty->assign('MODULETREElIST',$modulelisttree['list']);
//$smarty->assign('MODULETREElIST',$modulelisttree['list']);

$warehouseid = 0;
$url_string = '';
$stockquery = '';

$focus = CRMEntity::getInstance($currentModule);
//$focus->initSortbyField($currentModule);

//$focus->initSortbyField($currentModule);
/* 列表按钮 begin */
$focus->getModuleLogic($currentModule)->getListViewButtons();


/*
By LD Can;
Date:20121225;
reason:增加用户查询范围需求

*/
$MergeSmowner=getCurSmOwnerSearchScope($currentModule);
if(is_array($MergeSmowner))
    unset($MergeSmowner["UserCombo"][$current_user->id]);//去除当前用户

$fieldobj =$focus->fieldobj;
$smarty->assign('FIELDOBJ',$fieldobj);

//$smarty->assign('CUSTOM_MODULE', $focus->IsCustomModule);
$smarty->assign('Merge_SmOwner',$MergeSmowner);
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
$smarty->assign('MAX_RECORDS', $list_max_entries_per_page_new);

$smarty->assign('MODULE', $currentModule);
//$smarty->assign('SINGLE_MOD', getTranstab($currentModule));
$smarty->assign('CATEGORY', $category);

//$smarty->assign('CHECK', $tool_buttons);
$smarty->assign('THEME', $theme);
$smarty->assign('IMAGE_PATH', "themes/$theme/images/");

// @edit:dong @date:2020/10/28 @reason: 数据分类设置为自定义链接模块
if(isset($_REQUEST['ajaxtype']) && $_REQUEST['ajaxtype'] =='ld_linkmodulecustom'){
    $smarty->assign('LINKMODULECUSTOM', true);
}
/*
edit:Can
date:20130605
reason:4067: 视图中：排序功能失效。
*/
if(isset($_REQUEST["selectedColumnsString2"]))
{
    include("modules/lingdang/ViewOrderEditSave.php");
    
}
// Custom View
$customView = CustomView::getInstance($currentModule);
 $viewid = $customView->getViewId($currentModule);


$smarty->assign("VIEWID", $viewid);
if(isset($_REQUEST['ajaxtype']) && $_REQUEST['ajaxtype'] =='ld_linkmodulecustom'){
    $smarty->assign('LINKMODULECUSTOM', true);
}
//视图hTML
$customview_html = $customView->getCustomViewAll($viewid,$module,$category);
//@edit zsk 2024/06/11 XUQIU20240516-01 查询分类功能优化
//获取查询分类分组列表
$groupList=$customView->getCustomViewGroupList($customview_html);
$smarty->assign("CUSTOMVIEWGROUPLIST",$groupList);

//前五个数据分类
//$customview_html_before = $customView->getCustomViewCombo2Before($viewid,$module,$category);

//$edit_permit = $customView->isPermittedCustomView($viewid,'Create',$currentModule);
//$delete_permit = $customView->isPermittedCustomView($viewid,'Delete',$currentModule);

//$smarty->assign("CUSTOMVIEW_PERMISSION",$statusdetails);
//$smarty->assign("CV_EDIT_PERMIT",$edit_permit);
//$smarty->assign("CV_DELETE_PERMIT",$delete_permit); 


//by LD tifa 20130104 bug0003118
/*
edit:can
date:20130426
reason:记住上次查询范围

*/
if($_REQUEST['senioruserid']!="")
{
     $_SESSION['lvs'][$currentModule]['senioruserid']=$_REQUEST['senioruserid'];
}
if($_SESSION['lvs'][$currentModule]['senioruserid']!="")
{
    $smarty->assign("senioruserid",$_SESSION['lvs'][$currentModule]['senioruserid']);
}
if($_REQUEST['SearchScope'] !=null&&$_REQUEST['SearchScope'] !='')
{
     $SearchScope=$_REQUEST['SearchScope'];
     $_SESSION['lvs'][$currentModule]['SearchScope']=$SearchScope;
     
    $smarty->assign('SelectedOwner2', $_REQUEST['SearchScope']);
    
} 
else if(isset($_SESSION['lvs'][$currentModule]['SearchScope'])&&$_SESSION['lvs'][$currentModule]['SearchScope']!=null)
{
    $smarty->assign('SelectedOwner2',$_SESSION['lvs'][$currentModule]['SearchScope']);
    
}
else 
{
    $SearchScope="SmOwner_Search_All";
    $_SESSION['lvs'][$currentModule]['SearchScope']=$SearchScope;
    $smarty->assign('SelectedOwner2',"SmOwner_Search_All");
}
//获取批量操作时记录数上限
$deployarray=getSys_deploy(67);
$smarty->assign('BATCHNUM',$deployarray['deploy_value']);
$viewname = $customView->getViewNameDetail($viewid);
$smarty->assign('ALL', $viewname);
if($viewname == 'All'){
    $viewname = getFixedLabel('ALL');
}
$smarty->assign("VIEWNAME", $viewname);

if($viewid ==0 ) {
 
    include(globalStatic::$root_directory."modules/lingdang/ExitWithoutPermission.php");
	exit;
}


$queryGenerator =  QueryGenerator::getInstance($currentModule, $current_user,$customView);

/**
 * query_session=1时，读取session中的搜索条件，否则将清空session
 * 查看页面返回列表、列表编辑之后保存 返回列表时，返回query_session=1的参数
 * @project 序时簿查询记住搜索条件
 * @author Tujt 2014-04-25
 */
if(isset($_REQUEST['query_session']) && $_REQUEST['query_session'] == '1' 
		&& isset($_SESSION['LiveViewSearch'][$currentModule])){
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
		}else{
			$search_session = 0;
			unset($_SESSION['LiveViewSearch'][$currentModule]);
		}
        // @edit:dong @date:2020/08/24 @reason: 添加平铺查找
    }else if($input['searchtype'] == 'advance' || $input['searchtype'] == 'tiled'){
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
			$smarty->assign('CRITERIA_GROUPS',$advfilterlist);
		}else{
			$search_session = 0;
			unset($_SESSION['LiveViewSearch'][$currentModule]);
		}
	}
	if($search_session == 1){
		$smarty->assign('SEATCH_INPUT',$input);
		$smarty->assign('SEARCH_URL', $_SESSION['LiveViewSearch'][$currentModule]['url']);
		$_REQUEST['query'] = 'true';
	}
}else{
	unset($_SESSION['LiveViewSearch'][$currentModule]);
}
///得到对应视图的查询字段
if ($viewid != "0") {
   $queryGenerator->initForCustomViewById($viewid);
} else {
	$queryGenerator->initForDefaultCustomView();
}
$smarty->assign("LISTPAGEURL", getlisturl_aftersave());
// Enabling Module Search
Crm_load_class_file("CommonView","modules/CustomView");
$smarty->assign("DATETIMESTR",json_encode(CommonView::stdFilterDateTimeStr()));

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
        //18399: 回款计划、付款计划、收款单、付款单、费用报销单、佣金单、提现单、存现单-序列表界面：基本查找，按照金额等于0查找，结果基本查找区块会自动收起
		if($_REQUEST['search_text']!='' || (empty($_REQUEST['search_text']) && 'D' == $searcharr[count($searcharr)-1])){
			$input['search_field'] = trim($_REQUEST['search_field']);
			$input['search_text'] = trim($_REQUEST['search_text']);
			$input['SearchScope'] = trim($_REQUEST['SearchScope']);
			$input['searchtype'] = trim($_REQUEST['searchtype']);
			$input['type'] = trim($_REQUEST['type']??'');
		}else{
			unset($_SESSION['LiveViewSearch'][$currentModule]);
		}
        // @edit:dong @date:2020/08/24 @reason: 平铺搜索
    }else if($_REQUEST['searchtype'] == 'advance' || $_REQUEST['searchtype'] == 'tiled'){
		$_REQUEST['advft_criteria'] = trim($_REQUEST['advft_criteria']);
		if(!empty($_REQUEST['advft_criteria']) && $_REQUEST['advft_criteria'] != '[]'){
			$input['advft_criteria'] = $_REQUEST['advft_criteria'];
			$input['advft_criteria_groups'] = trim($_REQUEST['advft_criteria_groups']);
			$input['SearchScope'] = trim($_REQUEST['SearchScope']);
			$input['searchtype'] = trim($_REQUEST['searchtype']);
		}else{
			unset($_SESSION['LiveViewSearch'][$currentModule]);
		}
	}
    ////上一页和下一页点击使用使用
	$ustring = getSearchURL($_REQUEST);
	$url_string .= "&query=true$ustring";
	$smarty->assign('SEARCH_URL', $url_string);
   
	if(!empty($input)){
		$_SESSION['LiveViewSearch'][$currentModule]['input'] = $input;
		$_SESSION['LiveViewSearch'][$currentModule]['url'] = $url_string;
		$smarty->assign('SEATCH_INPUT',$input);
	}
}

$page_list_query = $queryGenerator->getQuery('','groupby');


if(isset($_REQUEST['btn_type'])){
     if($_REQUEST['btn_type']=='list'){
        $_SESSION["customform01_type.$current_user->id"]='list';

     }else{
        $_SESSION["customform01_type.$current_user->id"]='calendar';
     }
}
if($VersionInfo['account']=='shenglawei'&&$_SESSION["customform01_type.$current_user->id"]=='calendar')
{
    
     
         
        //当前设置为圣拉维的婚期字段，后续做成公共方法时可以修改
        $search_columnname ='cf_7441';
        $search_fieldInfoobj = $focus->fieldobj->getFieldInfoobjBykey('columnname',$search_columnname);
        $search_tablename = $search_fieldInfoobj->getTableName();
        $table_name = $focus->table_name;
        $table_index = $focus->table_index;
        if(!in_array($search_tablename.'.'.$search_columnname,$select_column_arr)){
            $select_column_arr[] = $search_tablename.'.'.$search_columnname;
        }
        
        //查找字段
        $list_query = "SELECT distinct ".$table_name.'.'.$table_index.','.implode(',',$select_column_arr)." FROM $table_name  ";
        //连接表
        foreach ($table_arr as $tmpindex=>$tmptabname){
            if($tmptabname != $table_name){
                if(in_array($tmptabname,$focus->tab_name )){
                    $tmptable_index = $focus->tab_name_index[$tmptabname];
                    $list_query .= " left join $tmptabname on $tmptabname.$tmptable_index = $table_name.$table_index ";
                }
            }
        }
        if(!in_array($search_tablename,$table_arr)&&in_array($search_tablename,$focus->tab_name )){
            $searchtable_index = $focus->tab_name_index[$tmptabname];
            $list_query .= " left join $search_tablename on $search_tablename.$searchtable_index = $table_name.$table_index ";
        }
        
        if(isset($_REQUEST['date'])){
            $date = $_REQUEST['date'];
            $date = str_replace("年","-",$date);
            $date = str_replace("月","-",$date);
        }
        else{
            $date = date('Y-m-');
        }
        
        $start_date = $date . '01';
        $cond_start = $start_date.' 00:00:00';
        $end_date = date('Y-m-d', strtotime("$start_date +1 month -1 day"));
        $cond_end = $end_date.' 23:59:59';
        $time_cod = " between '$cond_start' and '$cond_end' ";
        $calendar_page_list_query = "select slwtmp_one.customform01id  from ($page_list_query)  as slwtmp_one
                            inner join (select ld_customform01scf.customform01id from ld_customform01scf  where ld_customform01scf.$search_columnname $time_cod)
                             as slwtmp_two  on  slwtmp_one.customform01id = slwtmp_two.customform01id ";
        
     
         
    
    
}




$list_query = $queryGenerator->getQuery('',2);
//zxm 2021-0506【单据序时簿列表界面，进度漏斗增加穿透功能】 https://www.tapd.cn/63637123/prong/stories/view/1163637123001001609
//因无法使用高级查询 拼接advance_stage条件
$advance_stage =  $_REQUEST['advance_stage'];
if(!empty($advance_stage)){
    $page_list_query_explode = explode('group by',$page_list_query);
    $page_list_query_explode[0] = $page_list_query_explode[0].' and '.$focus->table_name.'.advance_stage like "%'.$advance_stage.'%" ';
    $page_list_query = implode(' group by ',$page_list_query_explode);
}
//echo $page_list_query;echo $list_query;die;
if(isset($_REQUEST['wareid']) && $_REQUEST['wareid'] != '' && $_REQUEST['wareid'] > 0)
{
    $warehouseid = $_REQUEST['wareid'];
}
$ChartFrom=str_replace(' ','//B/',$queryGenerator->page_left_join . $queryGenerator->gettabshareSql());//$queryGenerator->getChartFrom()
$ChartFrom=str_replace("'","//,/",$ChartFrom);
$ChartFrom=str_replace("%'","//,,/",$ChartFrom);
$ChartFrom= str_replace('"','',$ChartFrom);


$ChartWhere=str_replace('<','//lt/',$queryGenerator->getChartWhere());
$ChartWhere=str_replace(' ','//B/',$ChartWhere);
$ChartWhere=str_replace("'","//,/",$ChartWhere);
$ChartWhere=str_replace(">","//tgt/",$ChartWhere);
//bug 23792 edit cyb date:2016-07-28 替换掉"%";
$ChartWhere=str_replace("%","//lk/",$ChartWhere);//%
$ChartWhere=str_replace("<=",'//lteq/',$ChartWhere);//<=

$ChartOwner=str_replace(' ','//B/',$queryGenerator->getChartOwner());
$smarty->assign('CHARTFROM',$ChartFrom);
$smarty->assign('CHARTWHERE',$ChartWhere);
$smarty->assign('CHARTOWNER',$ChartOwner);
$where = $queryGenerator->getConditionalWhere();
//$queryGenerator->getQueryRow_Count()
$count_sql = $queryGenerator->getQueryRow_Count('','groupby');
//zxm 2021-0506【单据序时簿列表界面，进度漏斗增加穿透功能】 https://www.tapd.cn/63637123/prong/stories/view/1163637123001001609
//因无法使用高级查询 拼接advance_stage条件
$fromtype = $_REQUEST['fromtype'];
$LIST_NOCHECKBOX = 'yes';
if($fromtype=='salesfunnel'){
    $LIST_NOCHECKBOX = 'no';
    $smarty->assign('LIST_NOCHECKBOX',$LIST_NOCHECKBOX);
    $smarty->assign('fromtype',$fromtype);
}
$advance_stage =  $_REQUEST['advance_stage'];
if(!empty($advance_stage)){
    $count_sql_explode = explode('group by',$count_sql);
    $count_sql_explode[0] = $count_sql_explode[0].' and '.$focus->table_name.'.advance_stage like "%'.$advance_stage.'%" ';
    $count_sql = implode(' group by ',$count_sql_explode);
}


$count_result = $adb->query($count_sql);
if(!empty($count_result))
	$noofrows = $adb->query_result($count_result,0,0);
else 
	$noofrows = 0;


if(empty($order_by)){
	$orderModArr = array('InventoryAccount'=>1,'InventoryQuery'=>1,'Checks'=>1);
	if(isset($orderModArr[$module])){
		$stockquery  = $queryGenerator->isStockQuery($module);
        $page_list_query.=$stockquery;
    
        $order_by=' ld_warehousecondtions.operationtime ';
	}
    else
    {
       
        list($page_list_query,$order_by,$sorder) = $queryGenerator->customview->getOrderWhere($page_list_query);

    }
}


ListViewSession::setSessionQuery($currentModule,$page_list_query,$viewid);

//by ld tifa 20120116 bug 0003154


 

$queryMode = (isset($_REQUEST['query']) && $_REQUEST['query'] == 'true');
$start = ListViewSession::getRequestCurrentPage($currentModule, $noofrows, $viewid, $queryMode);

$navigation_array = VT_getSimpleNavigationValues($start,$list_max_entries_per_page_new,$noofrows);
$table_id_index=$focus->table_index;

$limit_start_rec = ($start-1) * $list_max_entries_per_page_new;
$list_query.=' inner join ( '.$page_list_query. " LIMIT $limit_start_rec, $list_max_entries_per_page_new ) as tmp
             on tmp.$table_id_index=".$focus->table_name.'.'.$table_id_index;
 
list($list_query,$order_by,$sorder) = $queryGenerator->customview->getOrderWhere($list_query,'',$queryGenerator);

$list_result = $adb->pquery($list_query, array());
    //echo $list_query;
$recordListRangeMsg = getRecordRangeMessage($list_result, $limit_start_rec,$noofrows);
/**
 * edit:can
 * date:20131212
 * reason:5648: 序时簿全选功能异常：需要选两次，才能出现 全选小页签
 * */
$smarty->assign('recordListRange',$recordListRangeMsg);
$smarty->assign('NUMOFROWS',$noofrows);
$smarty->assign("CUSTOMVIEW_OPTION",$customview_html);
//$smarty->assign("CUSTOMVIEW_OPTION_BEFORE",$customview_html_before);

// Navigation
$navigationOutput = getTableHeaderSimpleNavigation2($navigation_array, $url_string, $currentModule, 'index', $viewid);
$smarty->assign("NAVIGATION", $navigationOutput);

//hzx 20231207 XUQIU1002273 PC端模块列表界面，分页样式优化
$smarty->assign("TABNAME", getParentTab());
$smarty->assign("STARTPAGE", ceil($start));
$smarty->assign("LISTVIEWRECORDCOUNT", ceil($noofrows));
$smarty->assign("LISTVIEWPAGECOUNT", ceil($noofrows/$list_max_entries_per_page_new));
$smarty->assign("LISTVIEWPERPAGENUM", json_encode(getlistmaxentries_per_page($list_max_entries_per_page_new)));

$controller = new ListViewController($adb, $current_user, $queryGenerator);

 
//得到列头
$listview_header = $controller->getListViewHeader($focus,$currentModule,$url_string,$sorder,$order_by,$skipAction);

$listview_entries = $controller->getListViewEntries($focus,$currentModule,$list_result,$navigation_array,false);

/**
 * @project PROT26 序时簿增加合计项
 * @author Tujt 2014-06-05
 */
 crm_load_class_file('clsTotal_List','include/ListView');
 $clstotalobj=new clsTotal_List($controller);
$totalfldhtml = $clstotalobj->getTotalFldCount($page_list_query." LIMIT $limit_start_rec, $list_max_entries_per_page_new ",$list_result,$noofrows);
$smarty->assign('TOTALFLDHTML',$totalfldhtml);

$listview_header_search = $controller->getBasicSearchFieldInfoList();

//菜单查询和立即查找的数据
$smarty->assign('LISTHEADER', $listview_header);
$smarty->assign("HEADERNAME",$controller->headername);
//$smarty->assign('LISTENTITY', $listview_entries);
//合并列
$smarty->assign('LISTHEADERCOUNT', count($listview_header)+1);
/**
 * edit:chj
 * date:20131225
 * reason:5648: 库存台账不显示统计数量查询字段
 * */
if($module == 'InventoryQuery')
{
    $languageType= getLanguageType($current_user);
    if($languageType =='en')
        $listview_header_search = $focus->header_search_en;
    else
        $listview_header_search = $focus->header_search;
}
$smarty->assign('SEARCHLISTHEADER',$listview_header_search);

// Module Search//拼音查找
//$alphabetical = AlphabeticalSearch($currentModule,'index',$focus->def_basicsearch_col,'true','basic','','','','',$viewid);
$fieldnames = $controller->getAdvancedSearchOptionString();
//$criteria = getcriteria_options();
$smarty->assign("ALPHABETICAL", $alphabetical);
$smarty->assign("FIELDNAMES", $fieldnames);
$smarty->assign("CRITERIA", $criteria);

//Added to select Multiple records in multiple pages
$smarty->assign("SELECTEDIDS", vtlib_purify($_REQUEST['selobjs']));
$smarty->assign("ALLSELECTEDIDS", vtlib_purify($_REQUEST['allselobjs']));


/*
edit:chj
date:2013-11-14
reson:入库单仓库检索
*/
if($module == 'InventoryAccount' || $module == 'InventoryQuery' )
{
    $num_rows=$adb->num_rows(selWareAll());
    $warehouses=array();
    for($i=0;$i<$num_rows;$i++){
        $warehouses[]=array(
        'id'=>$adb->query_result($result,$i,'id'),
        'name'=>$adb->query_result($result,$i,'name'),
        //'type'=>getpower($current_user->id,$adb->query_result($result,$i,'id'),1)
        );
    }
    if(count($warehouses)>5){
        $warehousesofeight=array();
        for($i=0;$i<5;$i++){
            $warehousesofeight[]=$warehouses[$i];
        }
        $warehouseslast=array();
        for($i=5;$i<count($warehouses);$i++){
            $warehouseslast[$warehouses[$i]['id']]=$warehouses[$i]['name'];
        }
        $smarty->assign('WAREHOUSES',$warehousesofeight);//仓库信息
        $smarty->assign('MOREWAREHOUSES',$warehouseslast);
        
    }
    else
    {
        $smarty->assign('WAREHOUSES',$warehouses);//仓库信息
    }
    $smarty->assign('WAREHOUSEID',$warehouseid);
}
$smarty->assign('IS_ADMIN', is_admin($current_user));
//add by tifa 20130221 for reminds
//$CASHBILLCREATE
 

//中英文包
/*
require("user_privileges/user_language_".$current_user->id.'.php');
if(empty($languageType))
{
    $languageType = 'zh';
}*/

$languageType=getLanguageType($current_user);

$smarty->assign("LANUGAGETYPE",$languageType);
/**
 * 每列宽度的信息
 * edit:can 20200720
 * */
$smarty->assign("FieldWidthSetting",ldcrm_json_encode($controller->getModuleViewFieldsWidth()));

//获取列表操作列按钮名称总汇，并返回宽度
$operationWidth = $focus->getModuleLogic($currentModule)->getListButtomName();
$widthinfo=getModuleWidth($focus,$controller->getModuleViewFieldsWidth(),$currentModule);
$smarty->assign('LISTHEADERWIDTH',$widthinfo);
$total_width=$controller->getListTotalWidth($widthinfo,$operationWidth);
$smarty->assign('TOTALWIDTH',$total_width);
$smarty->assign('OPERATIONWIDTH',$operationWidth);
$smarty->assign("CHKBOXWIDTH",$controller->listchkbox_width);
/**
 * 判断当前模块是否开启审批，开启的话就显示批量提交按钮
 * @project PROT144 审批功能改进
 * @author Tujt 2014-12-26
 
//include_once('./modules/Approve/Approve.php');
//$approve_focus = new Approve();
$approve_focus = Approve::getInstance($currentModule);
$startapprovemodule = $approve_focus->startBlocksApprove();
$issubmit = 0;
if(isset($startapprovemodule[$currentModule])) $issubmit = 1;
$smarty->assign('APPROVEDISSUBMIT',$issubmit);*/
if($currentModule == 'Project'){
   $tradeSQL = "SELECT trade FROM ld_version;";
    $result = $adb->pquery($tradeSQL,array());
    $trade=$adb->query_result($result,0,'trade');
    $smarty->assign('TRADE', $trade); 
}

$smarty->assign('VERSION_ACCOUNT',$VersionInfo['account']);
/*
edit:Can
date:20130902
reason:4917: 控制面板 模块管理中将 本次查询统计图表 关闭，但是在客户等模块打开界面时，下面还是能显示 本次查询统计图表
*/
//销售机会序时簿增加跟进操作按钮列宽控制andy
if($currentModule == 'Potentials')
{
    if(isPermitted('ContactRecords',"Create","") == 'yes' && vtlib_isModuleActive('ContactRecords'))
        $smarty->assign('CREATECONTRACTRECORDS', 'yes');
}    
//库存流水账列表没有操作列
if($currentModule == 'InventoryAccount'){
	$colspan_count = sizeof($listview_header);//没有内容时，合并列
}else{
	$colspan_count = sizeof($listview_header)+1;
}
//单据推进管理 - 推进漏斗
/*crm_load_class_file('cls_module_advance','modules/Settings');
$cls_module_advance = new cls_module_advance($currentModule);
$smarty->assign('MODULEADVANCESTAGESTATUS',$cls_module_advance->is_Enable());*/
$smarty->assign('DEAILHTML',Inventory::createHTML($listview_entries,$currentModule,0,$colspan_count,$focus->logic->list_buttons,$controller,$LIST_NOCHECKBOX));


//$smarty->assign('DEAILHTML',Inventory::createHTML($listview_entries,$currentModule,0,sizeof($listview_header)+1,$focus->logic->list_buttons));

//0026303: 服务回访单列表：点击【如何创建服务回访单】，弹出层中的提示信息“客户服务单或项目计划”现在显示成了客户服务单项目计划
if($currentModule == 'ServiceReturn'){
    if(vtlib_isModuleActive('HelpDesk') && vtlib_isModuleActive('ProjectTask')){
        $smarty->assign('HOWTOCREATERETURN1',getFixedLabel('How_to_create_return1_or'));
        $smarty->assign('HOWTOCREATERETURN2',getFixedLabel('How_to_create_return2_or'));   
    }else{
        $smarty->assign('HOWTOCREATERETURN1',getFixedLabel('How_to_create_return1'));
        $smarty->assign('HOWTOCREATERETURN2',getFixedLabel('How_to_create_return2'));
    }
}

//市场活动本次查询统计图表字段权限
if($currentModule == 'Campaigns'){
    if(array_key_exists('campaignstatus',$focus->column_fields))
    {
        $smarty->assign("CHART_CAMPAINSTATUS",'yes');
    }
    if(array_key_exists('campaigntype',$focus->column_fields))
    {
        $smarty->assign("CHART_CAMPAIGNTYPE",'yes');
    }
    if(array_key_exists('expectedresponse',$focus->column_fields))
    {
        $smarty->assign("CHART_EXPECTEDRESPONSE",'yes');
    }
}
 
 
 



 setGLobalURLSmarty($smarty);//设置js,css等访问路径

 $fields=$focus->fieldobj->getListViewFields();
$smarty->assign('FIELDINFOJSON',ldcrm_json_encode($fields['fields']));
$smarty->assign('MODULEBILLNOTIP',$_SESSION[$currentModule.'_modulebillnotip']);
$_SESSION[$currentModule.'_modulebillnotip']='no';
// @edit:dong @date:2020/08/19 @reason: 查找 用于区分搜索类型
$smarty->assign('SEARCHTYPE',$_REQUEST['searchtype']);
//zkt 2021/12/27 用于区分是否为销售漏斗
if(isset($_REQUEST['fromtype'])&&$_REQUEST['fromtype']=='salesfunnel'){
    $smarty->assign('ISSALESFUNNEL','yes');
}
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

//xll 20221214 获取最近一次的基本搜索框字段选项
$controller->getFieldStorage($smarty);

// ljj 2023-08-29 XUQIU1001610 树结构设置和成员管理，左侧分类名称增加计数功能
$cls_MyCRMcryptobj=new cls_MyCRMcrypt();
$smarty->assign("Encrypt_TreeWhere",$cls_MyCRMcryptobj->encode($queryGenerator->getSqlNoTreeWhere($page_list_query)));

//zxm 20230614 获取列表页面公共参数并assign到tpl
ListViewCommonAssign($currentModule,$smarty,$focus);
global $languageType;
$smarty->assign("current_language",$languageType);
 
//230711 wym 客户“圣拉维”，自定义表单01切换日历视图
 
$smarty->assign("customform01_type",$_SESSION["customform01_type.$current_user->id"]);
           
if($_SESSION["customform01_type.$current_user->id"]=='calendar')
{

    $field_query = "select columnname,rownumber,listnumber,showtag from ld_cvcolumnlist_wx where modulename = '$currentModule' and presence=0 order by rownumber,listnumber";
    $field_result = $adb->pquery($field_query);
    $field_num = $adb->num_rows($field_result);
    $select_column_arr = array();
    for($i=0;$i<$field_num;$i++) {
        for($j=0;$j<4;$j++){
            $field_arr[$i][]=$adb->query_result($field_result,$i,$j);
        }
        $col_arr[$i] = explode(':',$field_arr[$i][0]);

        if (isset($col_arr[$i][0]) && !in_array($col_arr[$i][0],$table_arr)) {
            $table_arr[] = $col_arr[$i][0];
        }
        if (isset($col_arr[$i][1]) && isset($col_arr[$i][1])) {
            $col_name = $col_arr[$i][1];
            $fieldInfoobj = $focus->fieldobj->getFieldInfoobjBykey('columnname',$col_name);
            if(!empty($fieldInfoobj)){
                $col_name_arr[$i]['columname'] = $col_name;
                $col_name_arr[$i]['fieldName'] = $fieldInfoobj->getFieldName();
                $col_name_arr[$i]['fieldLableKey'] = $fieldInfoobj->getfieldLabel();
                $col_name_arr[$i]['tableName'] = $fieldInfoobj->getTableName();
                $col_name_arr[$i]['FieldValueColor'] = $fieldInfoobj->getFieldValueColor();
                $col_name_arr[$i]['uitype'] = $fieldInfoobj->getUIType();
                $col_name_arr[$i]['rownumber'] = $field_arr[$i][1];
                $col_name_arr[$i]['listnumber'] = $field_arr[$i][2];
                $col_name_arr[$i]['showtag'] = $field_arr[$i][3];
                $select_column_arr[] = $col_name_arr[$i]['tableName'].'.'.$col_name_arr[$i]['columname'];
            }
        }
    }
    //当前设置为圣拉维的婚期字段，后续做成公共方法时可以修改
    $search_columnname ='cf_7441';
    $search_fieldInfoobj = $focus->fieldobj->getFieldInfoobjBykey('columnname',$search_columnname);
    $search_tablename = $search_fieldInfoobj->getTableName();
    $table_name = $focus->table_name;
    $table_index = $focus->table_index;
    if(!in_array($search_tablename.'.'.$search_columnname,$select_column_arr)){
        $select_column_arr[] = $search_tablename.'.'.$search_columnname;
    }

    //查找字段
    $list_query = "SELECT distinct ".$table_name.'.'.$table_index.','.implode(',',$select_column_arr)." FROM $table_name  ";
    //连接表
    foreach ($table_arr as $tmpindex=>$tmptabname){
        if($tmptabname != $table_name){
            if(in_array($tmptabname,$focus->tab_name )){
                $tmptable_index = $focus->tab_name_index[$tmptabname];
                $list_query .= " left join $tmptabname on $tmptabname.$tmptable_index = $table_name.$table_index ";
            }
        }
    }
    if(!in_array($search_tablename,$table_arr)&&in_array($search_tablename,$focus->tab_name )){
        $searchtable_index = $focus->tab_name_index[$tmptabname];
        $list_query .= " left join $search_tablename on $search_tablename.$searchtable_index = $table_name.$table_index ";
    }

    if($_REQUEST['date']) {
         $date = $_REQUEST['date'];//点击年月
         $dateNum=$_REQUEST['dateNum'];//点击的日
    } else {
         $date=date("Y-m").'-';
         $dateNum=date("d");
    }

    $date = str_replace("年","-",$date);
    $date = str_replace("月","-",$date);
    $clickdate=date("Y-m-d",strtotime($date.$dateNum));//点击日期

    $start_date = $date . '01';
    $cond_start = $start_date.' 00:00:00';
    $end_date = date('Y-m-d', strtotime("$start_date +1 month -1 day"));
    $cond_end = $end_date.' 23:59:59';
    $time_cod = " between '$cond_start' and '$cond_end' ";
    $list_query.= ' inner join ('.$calendar_page_list_query.' ) as tmpthree  on tmpthree.customform01id=ld_customform01scf.customform01id ';
    $list_query .= " where ld_customform01scf.$search_columnname $time_cod";

    $list_result = $adb->pquery($list_query);
    $num_rows = $adb->num_rows($list_result);
    for($i=0;$i<$num_rows;$i++) {
        $customform01id = $adb->query_result($list_result,$i,'customform01id');
        foreach($col_name_arr as $key => $item) {
            $fieldname = $item['fieldName'];
            crm_load_class_file('Cls_FieldShowValue', 'modules/Users');
            $cls_fieldshowvalueobj = new Cls_FieldShowValue($currentModule, $customform01id, $fieldname);
            $ShowfieldValue = $cls_fieldshowvalueobj->getShowfieldValue()['value'];
            if (!empty($ShowfieldValue)){
                if ($item['uitype'] == 33) {
                    $ShowfieldValue = trim($ShowfieldValue);
                    $ShowfieldValue = explode('|##|', $ShowfieldValue);
                    $ShowfieldValue = implode(',', array_filter($ShowfieldValue));
                }
                $list_arr[$customform01id][$fieldname] = $ShowfieldValue;
            }
        }
        $list_arr[$customform01id][$search_columnname]=$adb->query_result($list_result,$i,$search_columnname);
    }

    $result=[];
    $daterowCount_arr=[];
    for($i=1;$i<=31;$i++) {
        $daterowCount_arr[date("Y-m").'-'.$i]=0;
    }
    $rightcontent='<ul>';
    $hageclickdate = 'no';
    $row_count = 0;
    foreach($list_arr as $tmprecord=>$tmpinfo) {
        if($tmpinfo['cf_7441']==$clickdate) {
            $hageclickdate = 'yes';
            $rightcontent.='<li class="schedule-item">';
            $rownumber = 0;
            //BUG0070318 slw 右侧日程需要按移动端列表定制中的行数列数显示
            foreach ($col_name_arr as $key2=>$item2){
                $fieldName = $item2['fieldName'];
                $showcontent = '';
                if($item2['showtag']=='yes'){
                    $showcontent.=$item2['fieldLableKey'].": ".$tmpinfo[$fieldName];
                } else {
                    $showcontent.=$tmpinfo[$fieldName];
                }
                if($key2==0){
                    $rightcontent.='<p class="content" module="CustomForm01" record="'.$tmprecord.'" onclick="ListLinkClick(ld(this),event)" 
                     lasturl="" style="color:">'.$showcontent;
                    $rownumber ++;
                    $row_count ++;
                } else {
                    if($item2['rownumber']!= $rownumber){
                        $rightcontent.= '</p>';
                        $rightcontent.='<p class="date" module="CustomForm01" record="'.$tmprecord.'" onclick="ListLinkClick(ld(this),event)" 
                          lasturl="" style="color:">'.$showcontent;
                        $rownumber ++ ;
                    } else {
                        $rightcontent.=' | '.$showcontent;
                    }
                }
            }
            if($rownumber>0){
                $rightcontent.= '</p>';
            }
            $rightcontent.='</li>';
        }
        $daterowCount_arr[intval(date("d",strtotime($tmpinfo['cf_7441'])))]+=1;
    }
    $rightcontent.='</ul>';

    // WYM 230731 BUG0070331 圣拉维-点击日期 右上角的条数没有根据当前日期更新
    $noofrows = $row_count;
    $recordListRangeMsg = getRecordRangeMessage($list_result, $limit_start_rec,$noofrows);
    //wym 240105 BUG0078406 圣拉维-分页显示错误
    $navigation_array = VT_getSimpleNavigationValues($start,$noofrows,$noofrows);
    $navigationOutput = getTableHeaderSimpleNavigation2($navigation_array, $url_string, $currentModule, 'index', $viewid);
    $smarty->assign('recordListRange',$recordListRangeMsg);
    $smarty->assign("NAVIGATION", $navigationOutput);

    //wym 240105 XUQIU1002273 PC端模块列表界面，分页样式优化 (这里要重新传一边给日历视图)
    $smarty->assign("TABNAME", getParentTab());
    $smarty->assign("STARTPAGE", ceil($start));
    $smarty->assign("LISTVIEWRECORDCOUNT", ceil($noofrows));
    $smarty->assign("LISTVIEWPAGECOUNT", ceil($noofrows/$noofrows));
    $smarty->assign("LISTVIEWPERPAGENUM", json_encode(getlistmaxentries_per_page($list_max_entries_per_page_new)));

    if($hageclickdate == 'no'){
        $rightcontent = '<div style="text-align: center;color: #666;margin: 10px 0;">暂无内容</div>';
    }
         
    //日程右边显示
    $smarty->assign("rightcontent",$rightcontent);
    //查询日期当月每天单据数量
    $smarty->assign("daterowcount",json_encode($daterowCount_arr));

    $time_cod = " where date_start <= ' $cond_end ' AND date_end >= '$cond_start'";
    $color_query = "select * from ld_calendarcolorsetting";
    $color_query .= $time_cod;
    $color_result = $adb->pquery($color_query);
    $color_rows = $adb->num_rows($color_result);
    for($i=0;$i<$color_rows;$i++) {
        $colorsetting_id = $adb->query_result($color_result,$i,'colorsetting_id');
        $color_setting[$colorsetting_id]['start'] = $adb->query_result($color_result,$i,'date_start');
        $color_setting[$colorsetting_id]['end'] = $adb->query_result($color_result,$i,'date_end');
        $color_setting[$colorsetting_id]['color'] = $adb->query_result($color_result,$i,'color');
    }

    foreach ($color_setting as $key => $item) {
        $startDate = $item['start'];
        $startDate = ($startDate <= $cond_start) ? $cond_start:$startDate;
        $startDay = (new DateTime($startDate))->format("j");

        $endDate = $item['end'];
        $endDate = ($endDate >= $cond_end) ? $cond_end:$endDate;
        $endDay = (new DateTime($endDate))->format("j");

        for($i=$startDay;$i<=$endDay;$i++){
            $color_setting_result[$i] = $item['color'];
        }
    }

    $smarty->assign("clickDate",date("Y-m-d",strtotime($clickdate)));
    $smarty->assign("clickDateLabel",date("Y年m月d日",strtotime($clickdate)));
    $smarty->assign('shenglaweiColor',json_encode($color_setting_result));// $data['color']=$color_setting_result;
}

if($_REQUEST['btn_type']!=''){
    $smarty->display("ListViewEntries.tpl");
} else if(isset($_REQUEST['ajax']) && $_REQUEST['ajax'] != '') {
	$smarty->display("ListViewEntries.tpl");
} else {
    $smarty->display('ListView.tpl');
}

?>