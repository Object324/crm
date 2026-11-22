<?php
require_once($root_directory."include/Popup/PopUpListView.php");
include($root_directory.'data/PopInventory.php');
global $app_strings, $default_charset;
global $currentModule, $current_user,$list_max_entries_per_page_new;
global $theme, $adb;
require('user_privileges/user_language_'.$current_user->id.'.php');
$url_string = '';
$_REQUEST['SearchScope']='SmOwner_Search_All';//037028: 分录中关联选择源单，例如:选产品、或者选合同等，在源单列表做了查询之后，会影响选择这里
$_REQUEST['diony']='yes';

//关联选择单据 将moduel 改为 Users
if($currentModule == 'Users' && isset($_REQUEST['selectmodule']) && !empty($_REQUEST['selectmodule'])){
    $currentModule = $_REQUEST['selectmodule'];
    $_REQUEST['module'] = $_REQUEST['selectmodule'];
    $module = $_REQUEST['selectmodule'];
}


$smarty = new lingdangCRM_Smarty;
if (!isset($where)) $where = "";
//XUQIU1001421 关联选择单据（单选）、关联选择单据（多选）、选择源单、分录选择产品弹出层中，增加“全屏/恢复”图标按钮（郭惠宇）
if($_REQUEST['fullscreen']){
    setUsersettingByLabel('notbymodule', $current_user->id, 'Fullscreen', $_REQUEST['fullscreen']);
    return;
}
if($currentModule=='Accounts'||$currentModule=='Leads')
{
                
        setSearchAllAccount();//设置查询所有的客户（包括公海客户）
            
}
        
/**
 * 选择产品弹出框中，添加产品、套餐选择标签，默认为产品
 * 判断如果有isbom变量，则不显示标签
 * @project PROT127 爱哆哆需求1：产品套餐
 * @author Tujt 2014-11-26
 */
if('Products' == $_REQUEST['module']){
	/**
	 * 添加这个变量的话，产品的链接方法会被替换掉
	 * @reason 0012826 牵涉到录入产品模块录入产品时有问题
	 * @author Tujt 2014-12-05
	 */
    $tmp_return_module = $_REQUEST['return_module'];
	if(!isset($_REQUEST['isbom']) && vtlib_isModuleActive('Productbom') && $isbom = isPermitted('Productbom','index','') == 'yes' && !empty($tmp_return_module) && (get_file_address($tmp_return_module,'ProductDetails') || $tmp_return_module == 'CashBill' || $tmp_return_module == 'SendCashBill')){
		$prodbomtagarr = array('1'=>getTranstab('Products'),'2'=>getTranstab('Productbom'));
		$prodbomtag_d = '1';//默认是产品
		if(isset($_REQUEST['prodbomtag_d'])){
			$prodbomtag_d = $_REQUEST['prodbomtag_d'];
		}
		if(2 == $prodbomtag_d){
			$_REQUEST['module'] = $module = $currentModule = 'Productbom';
            $_REQUEST['fieldname'] = '';
		}
        $list_max_entries_per_page_new=getUsersettingByLabel($_REQUEST['module'],$current_user->id,'MaxEntriesPerPageByuser')??getUsersettingByLabel($currentModule,1,'MaxEntriesPerPage');
        $list_max_entries_per_page_new=empty($list_max_entries_per_page_new)?'20':$list_max_entries_per_page_new;

        if(isset($_REQUEST['related_productid'])&&$_REQUEST['frommodule']=='WorkSheet'){
            unset($prodbomtagarr['2']);
            $prodbomtagarr['1'] = getFixedLabel('ACCESSORYINFORMATION');
            $prodbomtagarr['3'] = getFixedLabel('RECENTUSE');
            
        }
        
		$smarty->assign('PRODBOMTAGARR',$prodbomtagarr);
		$smarty->assign('PRODBOMTAG_D',$prodbomtag_d);
		$smarty->assign('CURR_ROW',$_REQUEST['curr_row']);
	}
    unset($tmp_return_module);
}
//ljj XUQIU20240425-01 关联选择单据（单选）、关联选择单据（多选）、选择源单弹出层界面，增加显示树结构分类（徐昱轩）
crm_load_class_file('cls_Module_Tree', 'include/utils');
$cls_module_tree = cls_Module_Tree::getInstance($currentModule);
if(isset($_REQUEST['ajax']) && $_REQUEST['ajax'] != '')
{
    if (isset($_REQUEST['isshowModuleListTree']) && $_REQUEST['isshowModuleListTree'] == 'yes'){
        $smarty->assign('tree_enable','yes');
    }
}
else
{
    if($cls_module_tree->moduleenable=='yes'){
        //加载初始树状结构
        $modulelisttree = $cls_module_tree->getModuleListTree();
        $smarty->assign('POPUPMODULElISTTREE',$modulelisttree);
        //【近期使用】不使用树结构
        if(isset($_REQUEST['prodbomtag_d'])&&$_REQUEST['prodbomtag_d']=='3'){
            $modulelisttree['enable'] = 'no';
            $modulelisttree->moduleenable = 'no';
        }
        $smarty->assign('tree_enable', $modulelisttree['enable']);
        $tree_width = $modulelisttree['tree_width'];
        $tree_expand = $modulelisttree['tree_expand'];
        //BUG20240118-61 ls 240122 合同订单分录选产品，树结构选中分类和列表数据不符，列表数据为全部数据
        if ($modulelisttree['enable']=='yes') {
            $_REQUEST['isshowModuleListTree'] = 'yes';
        }
        $module_list_treeselectrecord=0;
        //若$_SESSION中储存的selectrecord值,为级联下拉值id，获取下级对应html
        if(isset($modulelisttree)&&$modulelisttree['enable']=='yes'&&!isset($modulelisttree['list'][$_SESSION['module_list_tree'][$currentModule]['selectrecord']])){
            //获取下级对应html
            $sessionarr = $_SESSION['module_list_tree'][$currentModule];
            $Inithtmlexpand = $cls_module_tree->getInithtmlexpand($sessionarr['selectrecord'],$sessionarr['list']);
            $smarty->assign('Inithtmlexpand',$Inithtmlexpand);
        }
    }
    //获取设置选中的树结构id
    $module_list_treeselectrecord=0;
    if(isset($_SESSION['module_list_tree'][$currentModule])){
        $module_list_treeselectrecord= $_SESSION['module_list_tree'][$currentModule]['selectrecord'];
    }
    $smarty->assign('POPUPMODULE_TREE_PICKLIST_ID',$module_list_treeselectrecord);
}
$smarty->assign("CATEGORY",$parent_tab);

$url = '';
$popuptype = '';
$fromModule = '';

/*
相关对象弹窗没有popuptype
*/
$popuptype = vtlib_purify($_REQUEST["popuptype"]);
    if($popuptype==''){
        if($module=='Accounts'){
            $popuptype='specific_account_address';
        }else{
            $popuptype='specific';
        }
    }
$warehouseid = $_REQUEST['wareid'];
$smarty->assign('WAREHOUSEID',$warehouseid);
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";
$smarty->assign("MOD", $mod_strings);
$smarty->assign("APP", $app_strings);
$smarty->assign("THEME", $theme);
$smarty->assign("THEME_PATH",$theme_path);
$smarty->assign("MODULE",$currentModule);
$customView = CustomView::getInstance($currentModule);
/**
更新操作
edit：andrew
date：20140214
reason：添加数据分类
**/
$viewid=0;
if($_REQUEST['viewname']){
    $viewid = $_REQUEST['viewname'];
}

if($_REQUEST['popuptype']=='selectsource' || ($_REQUEST['frommodule']=='ServiceContracts' &&  $currentModule=='SalesOrder'))
{
	$smarty->assign("HIDEDATACATEGORY",'yes');
    $viewid = $customView->getViewIdByName('All',$currentModule);//选择源单界面和查询功能改进
  
    $_REQUEST['viewid']=$viewid;
}
else if($viewid==0)
    $viewid = $customView->getViewId($currentModule);
$smarty->assign("VIEWID", $viewid);
//$category = getParentTab();
$smarty->assign('ALLOTACCOUNT',$_REQUEST['allotaccount']);

$customview_html = $customView->getCustomViewAll($viewid,$module,$category,'popup');

$smarty->assign("CUSTOMVIEW_OPTION",$customview_html);

$accounttype="ALLACCOUNT";
$smarty->assign("ACCOUNTTYPE",$accounttype);

$form = vtlib_purify($_REQUEST['form']);
//added to get relatedto field value for todo, while selecting from the popup list, after done the alphabet or basic search.
if(isset($_REQUEST['maintab']) && $_REQUEST['maintab'] != '')
{
        $act_tab = vtlib_purify($_REQUEST['maintab']);
        $url = "&maintab=".$act_tab;
}
$smarty->assign("MAINTAB",$act_tab);
			
// This is added to support the type of popup and callback
if(isset($_REQUEST['popupmode']) && isset($_REQUEST['callback'])) {
	$url = "&popupmode=".$_REQUEST['popupmode']."&callback=".$_REQUEST['callback'];
	$smarty->assign("POPUPMODE", $_REQUEST['popupmode']);
	$smarty->assign("CALLBACK", $_REQUEST['callback']);
}	
crm_load_function_file('AlphabeticalSearch','include/utils','ListViewUtils');
switch($currentModule)
{
	case 'Contacts':
		$focus = CRMEntity::getInstance('Contacts');
	//	$log = LoggerManager::getLogger('contact_list');
		$smarty->assign("SINGLE_MOD",'Contact');
		if(isset($_REQUEST['return_module']) && $_REQUEST['return_module'] !='')
			$smarty->assign("RETURN_MODULE",vtlib_purify($_REQUEST['return_module']));
		else
			$smarty->assign("RETURN_MODULE",'Emails');
		if (isset($_REQUEST['select'])) $smarty->assign("SELECT",'enable');
      //  crm_load_function_file('AlphabeticalSearch','include/utils','ListViewUtils'); 
	//	$alphabetical = AlphabeticalSearch($currentModule,'Popup','lastname','true','basic',$popuptype,"","",$url);
		break;
	case 'Campaigns':
		$focus = CRMEntity::getInstance('Campaigns');
	//	$log = LoggerManager::getLogger('campaign_list');
		$smarty->assign("SINGLE_MOD",'Campaign');
		if(isset($_REQUEST['return_module']) && $_REQUEST['return_module'] !='')
			$smarty->assign("RETURN_MODULE",vtlib_purify($_REQUEST['return_module']));
		if (isset($_REQUEST['select'])) $smarty->assign("SELECT",'enable');
	//	$alphabetical = AlphabeticalSearch($currentModule,'Popup','campaignname','true','basic',$popuptype,"","",$url);
		break;
	case 'Accounts':
		$focus = CRMEntity::getInstance('Accounts');
	//	$log = LoggerManager::getLogger('account_list');
		if (isset($_REQUEST['select'])) $smarty->assign("SELECT",'enable');
		$smarty->assign("SINGLE_MOD",'Account');
		if(isset($_REQUEST['return_module']) && $_REQUEST['return_module'] !='')
			$smarty->assign("RETURN_MODULE",vtlib_purify($_REQUEST['return_module']));
		else
			$smarty->assign("RETURN_MODULE",'Emails');
		//$alphabetical = AlphabeticalSearch($currentModule,'Popup','accountname','true','basic',$popuptype,"","",$url);

		break;

	case 'Potentials':
		$focus = CRMEntity::getInstance('Potentials');
		//$log = LoggerManager::getLogger('potential_list');
		if (isset($_REQUEST['select'])) $smarty->assign("SELECT",'enable');
		$smarty->assign("SINGLE_MOD",'Opportunity');
		if(isset($_REQUEST['return_module']) && $_REQUEST['return_module'] !='')
			$smarty->assign("RETURN_MODULE",vtlib_purify($_REQUEST['return_module']));
		//$alphabetical = AlphabeticalSearch($currentModule,'Popup','potentialname','true','basic',$popuptype,"","",$url);
		break;
	case 'Quotes':
		$focus = CRMEntity::getInstance('Quotes');
	//	$log = LoggerManager::getLogger('quotes_list');
		$smarty->assign("SINGLE_MOD",'Quote');
		if (isset($_REQUEST['select'])) $smarty->assign("SELECT",'enable');
	//	$alphabetical = AlphabeticalSearch($currentModule,'Popup','subject','true','basic',$popuptype,"","",$url);
		break;
	case 'Invoice':
		$focus = CRMEntity::getInstance('Invoice');
		$smarty->assign("SINGLE_MOD",'Invoice');
		if(isset($_REQUEST['return_module']) && $_REQUEST['return_module'] !='')
			$smarty->assign("RETURN_MODULE",vtlib_purify($_REQUEST['return_module']));
        if (isset($_REQUEST['select']))
            $smarty->assign("SELECT",'enable');
	//	$alphabetical = AlphabeticalSearch($currentModule,'Popup','subject','true','basic',$popuptype,"","",$url);
		break;
	case 'Products':
		$focus = CRMEntity::getInstance('Products');
		$smarty->assign("SINGLE_MOD",getTranslatedString('SINGLE_'.$currentModule));
		if(isset($_REQUEST['curr_row']))
		{
			$curr_row = vtlib_purify($_REQUEST['curr_row']);
			$smarty->assign("CURR_ROW", $curr_row);
			$url_string .="&curr_row=".vtlib_purify($_REQUEST['curr_row']);
		}
		if(isset($_REQUEST['return_module']) && $_REQUEST['return_module'] !='')
			$smarty->assign("RETURN_MODULE",vtlib_purify($_REQUEST['return_module']));
		if (isset($_REQUEST['select'])) $smarty->assign("SELECT",'enable');	
	//	$alphabetical = AlphabeticalSearch($currentModule,'Popup','productname','true','basic',$popuptype,"","",$url);
		break;
	case 'Vendors':
		$focus = CRMEntity::getInstance('Vendors');
		$smarty->assign("SINGLE_MOD",'Vendor');
		if (isset($_REQUEST['select'])) $smarty->assign("SELECT",'enable');
	//	$alphabetical = AlphabeticalSearch($currentModule,'Popup','vendorname','true','basic',$popuptype,"","",$url);
		break;
	case 'SalesOrder':
		$focus = CRMEntity::getInstance('SalesOrder');
		$smarty->assign("SINGLE_MOD",'SalesOrder');
		if(isset($_REQUEST['return_module']) && $_REQUEST['return_module'] !='')
			$smarty->assign("RETURN_MODULE",vtlib_purify($_REQUEST['return_module']));
        if (isset($_REQUEST['select']))//服务单选择合同订单不需要checkbox edit:can
            $smarty->assign("SELECT",'enable');
	//	$alphabetical = AlphabeticalSearch($currentModule,'Popup','subject','true','basic',$popuptype,"","",$url);
		break;
	case 'PurchaseOrder':
		$focus = CRMEntity::getInstance('PurchaseOrder');
		$smarty->assign("SINGLE_MOD",'PurchaseOrder');
        if (isset($_REQUEST['select'])) $smarty->assign("SELECT",'enable');
		if(isset($_REQUEST['return_module']) && $_REQUEST['return_module'] !='')
			$smarty->assign("RETURN_MODULE",vtlib_purify($_REQUEST['return_module']));
	//	$alphabetical = AlphabeticalSearch($currentModule,'Popup','subject','true','basic',$popuptype,"","",$url);
		break;
	case 'PriceBooks':
		$focus = CRMEntity::getInstance('PriceBooks');
		$smarty->assign("SINGLE_MOD",'PriceBook');
		if(isset($_REQUEST['return_module']) && $_REQUEST['return_module'] !='')
			$smarty->assign("RETURN_MODULE",vtlib_purify($_REQUEST['return_module']));
		if(isset($_REQUEST['fldname']) && $_REQUEST['fldname'] !='')
		{
			$smarty->assign("FIELDNAME",vtlib_purify($_REQUEST['fldname']));
			$url_string .="&fldname=".vtlib_purify($_REQUEST['fldname']);
		}
		if(isset($_REQUEST['productid']) && $_REQUEST['productid'] !='')
		{
			$smarty->assign("PRODUCTID",vtlib_purify($_REQUEST['productid']));
			$url_string .="&productid=".vtlib_purify($_REQUEST['productid']);
		}
		//$alphabetical = AlphabeticalSearch($currentModule,'Popup','bookname','true','basic',$popuptype,"","",$url);
		break;
	case 'Users':
				$focus = CRMEntity::getInstance('Users');
                $smarty->assign("SINGLE_MOD",'Users');
                if(isset($_REQUEST['return_module']) && $_REQUEST['return_module'] !='')
                    $smarty->assign("RETURN_MODULE",vtlib_purify($_REQUEST['return_module']));
                $alphabetical = AlphabeticalSearch($currentModule,'Popup','user_name','true','basic',$popuptype,"","",$url);
		if (isset($_REQUEST['select'])) $smarty->assign("SELECT",'enable');
                break;	
	case 'HelpDesk':
		$focus = CRMEntity::getInstance('HelpDesk');
		$smarty->assign("SINGLE_MOD",'HelpDesk');
		if(isset($_REQUEST['return_module']) && $_REQUEST['return_module'] !='')
			$smarty->assign("RETURN_MODULE",vtlib_purify($_REQUEST['return_module']));
	//	$alphabetical = AlphabeticalSearch($currentModule,'Popup','title','true','basic',$popuptype,"","",$url);
		if (isset($_REQUEST['select'])) $smarty->assign("SELECT",'enable');
		break;
    /*
    *新增操作 by andy
    *联系记录新增项目任务字段，弹出窗信息
    *date:20140108
    */
    case 'ProjectTask':
		$focus = CRMEntity::getInstance('ProjectTask');
		$smarty->assign("SINGLE_MOD",'ProjectTask');
		if(isset($_REQUEST['return_module']) && $_REQUEST['return_module'] !='')
			$smarty->assign("RETURN_MODULE",vtlib_purify($_REQUEST['return_module']));
	//	$alphabetical = AlphabeticalSearch($currentModule,'Popup','projecttaskname','true','basic',$popuptype,"","",$url);
		if (isset($_REQUEST['select'])) $smarty->assign("SELECT",'enable');
		break;
    /*
    *新增操作 by andy
    *退款单带出退货单
    *date:20140120
    */
    case 'SalesBack':
		$focus = CRMEntity::getInstance('SalesBack');
		$smarty->assign("SINGLE_MOD",'SalesBack');
		if(isset($_REQUEST['return_module']) && $_REQUEST['return_module'] !='')
			$smarty->assign("RETURN_MODULE",vtlib_purify($_REQUEST['return_module']));
	//	$alphabetical = AlphabeticalSearch($currentModule,'Popup','ticket_title','true','basic',$popuptype,"","",$url);
		if (isset($_REQUEST['select'])) $smarty->assign("SELECT",'enable');
		break;
	case 'Documents':
		$focus = CRMEntity::getInstance('Documents');
		$smarty->assign("SINGLE_MOD",'Document');
		if(isset($_REQUEST['return_module']) && $_REQUEST['return_module'] !='')
			$smarty->assign("RETURN_MODULE",vtlib_purify($_REQUEST['return_module']));
		else
			$smarty->assign("RETURN_MODULE",'Emails');
		if (isset($_REQUEST['select'])) $smarty->assign("SELECT",'enable');
		//$alphabetical = AlphabeticalSearch($currentModule,'Popup','notes_title','true','basic',$popuptype,"","",$url);
		break;


	default:
		$focus = CRMEntity::getInstance($currentModule);
		$smarty->assign("SINGLE_MOD", $currentModule);		
		if(isset($_REQUEST['return_module']) && $_REQUEST['return_module'] !='')
			$smarty->assign("RETURN_MODULE",vtlib_purify($_REQUEST['return_module']));
	//	$alphabetical = AlphabeticalSearch($currentModule,'Popup',$focus->def_basicsearch_col,'true','basic',$popuptype,"","",$url);
		if (isset($_REQUEST['select'])) $smarty->assign("SELECT",'enable');
		break;
	// END

}


// vtlib customization: Initialize focus to get generic popup
if($_REQUEST['form'] == 'vtlibPopupView') {
	//vtlib_setup_modulevars($currentModule, $focus);
}
// END

$smarty->assign("RETURN_ACTION",vtlib_purify($_REQUEST['return_action']));
//Retreive the list from Database
if($currentModule == 'PriceBooks')
{
	$productid=$_REQUEST['productid'];
	$currency_id=$_REQUEST['currencyid'];
	if($currency_id == null) $currency_id = 1;
	$query = 'select ld_pricebook.*, ld_pricebookproductrel.productid, ld_pricebookproductrel.listprice, ' .
					'ld_pricebook.pricebookid as crmid, ld_pricebook.smownerid, ld_pricebook.modifiedtime ' .
					'from ld_pricebook inner join ld_pricebookproductrel on ld_pricebookproductrel.pricebookid = ld_pricebook.pricebookid '.
					'where ld_pricebookproductrel.productid='.$adb->sql_escape_string($productid).' and ld_pricebook.deleted=0 ' .
							'and ld_pricebook.currency_id='.$adb->sql_escape_string($currency_id).' and ld_pricebook.active=1';

}
else
{
	if(isset($_REQUEST['recordid']) && $_REQUEST['recordid'] != '')
	{
		$smarty->assign("RECORDID",vtlib_purify($_REQUEST['recordid']));
		$url_string .='&recordid='.vtlib_purify($_REQUEST['recordid']);
        	$where_relquery = getRelCheckquery($currentModule,$_REQUEST['return_module'],$_REQUEST['recordid']);
	}
	if(isset($_REQUEST['relmod_id']) || isset($_REQUEST['fromPotential']))
	{
		if($_REQUEST['relmod_id'] !='')
		{
			$mod = vtlib_purify($_REQUEST['parent_module']);
			$id = vtlib_purify($_REQUEST['relmod_id']);
		}
		else if($_REQUEST['fromPotential'] != '')
		{
			$mod = "Accounts";
			$id= vtlib_purify($_REQUEST['acc_id']);
		}

		$smarty->assign("mod_var_name", "parent_module");
		$smarty->assign("mod_var_value", $mod);
		$smarty->assign("recid_var_name", "relmod_id");
		$smarty->assign("recid_var_value",$id);
	//	$where_relquery.= getPopupCheckquery($currentModule,$mod,$id);
	}
	else if(isset($_REQUEST['task_relmod_id']))
	{
		$smarty->assign("mod_var_name", "task_parent_module");
		$smarty->assign("mod_var_value", vtlib_purify($_REQUEST['task_parent_module']));
		$smarty->assign("recid_var_name", "task_relmod_id");
		$smarty->assign("recid_var_value",vtlib_purify($_REQUEST['task_relmod_id']));
	//	$where_relquery.= getPopupCheckquery($currentModule,$_REQUEST['task_parent_module'],$_REQUEST['task_relmod_id']);
	}
	if($currentModule == 'Products' && !$_REQUEST['record_id'] && ($popuptype == 'inventory_prod' || $popuptype == 'inventory_prod_po'))
       		$where_relquery .=" and ld_products.discontinued <> 0 AND (ld_products.productid NOT IN (SELECT crmid FROM ld_seproductsrel WHERE setype='Products'))";
	elseif($currentModule == 'Products' && $_REQUEST['record_id'] && ($popuptype == 'inventory_prod' || $popuptype == 'inventory_prod_po'))
        	$where_relquery .=" and ld_products.discontinued <> 0 AND (ld_products.productid IN (SELECT crmid FROM ld_seproductsrel WHERE setype='Products' AND productid=".$adb->sql_escape_string($_REQUEST['record_id'])."))";
	elseif($currentModule == 'Products' && $_REQUEST['return_module'] != 'Products')
       	//	$where_relquery .=" and ld_products.discontinued <> 0";	
	if($_REQUEST['return_module'] == 'Products' && $currentModule == 'Products' && $_REQUEST['recordid'])
       	$where_relquery .=" and ld_products.discontinued <> 0 AND (ld_crmentity.crmid NOT IN (".$adb->sql_escape_string($_REQUEST['recordid']).") AND ld_crmentity.crmid NOT IN (SELECT productid FROM ld_seproductsrel WHERE setype='Products') AND ld_crmentity.crmid NOT IN (SELECT crmid FROM ld_seproductsrel WHERE setype='Products' AND productid=".$adb->sql_escape_string($_REQUEST['recordid'])."))";
	
	if($currentModule == 'Services' && $popuptype == 'inventory_service') {
		$where_relquery .=" and ld_service.discontinued <> 0";
	}

	//Avoiding Current Record to show up in the popups When editing.
	if($currentModule == 'Accounts' && $_REQUEST['recordid']!=''){
		$where_relquery .=" and ld_account.accountid!=".$adb->sql_escape_string($_REQUEST['recordid']);
		$smarty->assign("RECORDID",vtlib_purify($_REQUEST['recordid']));
	}
    
	if($currentModule == 'Contacts' && $_REQUEST['recordid']!=''){
		$where_relquery .=" and ld_contactdetails.contactid!=".$adb->sql_escape_string($_REQUEST['recordid']);
		$smarty->assign("RECORDID",vtlib_purify($_REQUEST['recordid']));
	}
	
	if($currentModule == 'Users' && $_REQUEST['recordid']!=''){
		$where_relquery .=" and ld_users.id!=".$adb->sql_escape_string($_REQUEST['recordid']);
		$smarty->assign("RECORDID",vtlib_purify($_REQUEST['recordid']));
	}
    if($currentModule == 'PurchaseOrder' && $_REQUEST['frommodule']=='Stock')
    {
        //$where_relquery .=" and ld_purchaseorder.stockpresence != '全部入库'";
        $smarty->assign("RECORDID",vtlib_purify($_REQUEST['recordid']));
    }
    if($currentModule == 'SalesOrder' && $_REQUEST['frommodule']=='OutboundOrder')
    {
       // $where_relquery .=" and ld_salesorder.stockpresence != '全部出库'";
        $smarty->assign("RECORDID",vtlib_purify($_REQUEST['recordid']));
    }


}

$popuplistview=new PopUpListView();


$withproductdetail = $_REQUEST['withproductdetail'];
$unallowrepeat = $_REQUEST['unallowrepeat'];

$selectlistvalue = isset($_REQUEST['selectListValue']) ? $_REQUEST['selectListValue'] : '';
$selectDetailLineitemid = isset($_REQUEST['selectDetailLineitemid']) ? $_REQUEST['selectDetailLineitemid'] : '';

$selectlistvalue = implode(',',array_filter(explode(',',$selectlistvalue)));
$selectDetailLineitemid = implode(',',array_filter(explode(',',$selectDetailLineitemid)));
$NoRepeatQueryWithDetail = '';
if ($withproductdetail == 'yes' && $unallowrepeat == 'yes' && !empty($selectDetailLineitemid) && $selectDetailLineitemid != '0'){//不允许重复开启且开启带出分录，且有已选分录
    $NoRepeatQueryWithDetail = 'yes';
    $popuplistview->setQueryWithDetail('yes');
}else if ($unallowrepeat == 'yes' && $withproductdetail == 'no' && !empty($selectlistvalue)){//不允许重复开启但不开启带出分录，且有已选源单单据
    $NoRepeatQueryWithDetail = 'no';
    $popuplistview->setQueryWithDetail('yes');
}

$tmp_session = [];
/**
 * 用户弹出框特别处理
 * @reason 0008999 审批委托人 无法选择用户
 * @author Tujt 2014-05-26
 */
if($currentModule != 'Users'){

    if($_SESSION['lvs'][$currentModule] && !empty($_SESSION['lvs'][$currentModule])){
        $tmp_session = $_SESSION['lvs'][$currentModule];
        $_SESSION['lvs'][$currentModule] = [];https://saas.wecrm.com/experience
    }

    if(get_file_address($currentModule,'ProductDetails')) {
        if (isset($_REQUEST['listval']) && $_REQUEST['listval'] != '')
            $smarty->assign('SELECTLISTVAL', $_REQUEST['listval']);
        else
            $smarty->assign('SELECTLISTVAL', '');
        if ($NoRepeatQueryWithDetail == 'yes' || $NoRepeatQueryWithDetail == 'no') {
            if ($NoRepeatQueryWithDetail == 'yes' && !empty($focus->Detail_table)) {//不允许重复开启且开启带出分录
                // $page_list_query .= ' AND '.$focus->Detail_table.'.'.$focus->Detail_table_id.' not in ('.$selectDetailLineitemid.') ';
                $popuplistview->AddQueyGeneratorObjWhere(' AND '.$focus->Detail_table.'.'.$focus->Detail_table_id.' not in ('.$selectDetailLineitemid.') ',[],[$focus->Detail_table=>""]);

            } else if ($NoRepeatQueryWithDetail == 'no' && !empty($focus->table_name)) {//不允许重复开启但不开启带出分录
                //   $page_list_query .= ' AND '.$focus->table_name.'.'.$focus->table_index.' not in ('.$selectlistvalue.') ';
                $popuplistview->AddQueyGeneratorObjWhere( ' AND '.$focus->table_name.'.'.$focus->table_index.' not in ('.$selectlistvalue.') ',[$focus->table_name=>""],[]);

            }
        }
    }
	$query = $popuplistview->getpopupquery($currentModule,$current_user,$viewid);
 
    if(!$_REQUEST['projectid']&&$_REQUEST['account_id']!=''&&$currentModule=='ProjectTask'){
       $query.=" AND ld_projecttask.accountid = ".$_REQUEST['account_id']; 
    }
	if('Accounts' == $currentModule){//优化客户弹出窗，客户地址字段汇率字段默认读取
		$acctquerywhere = $popuplistview->queryGenerator->getSelectClauseColumnSQL();
		$acctaddressfld = array('bill_street', 'bill_city', 'bill_code', 'bill_pobox', 
								'bill_country', 'bill_state','ship_street', 'ship_city', 'ship_code', 'ship_pobox', 'ship_country', 'ship_state');
		foreach($acctaddressfld as $addressfld){
			if(!strpos(strtolower($acctquerywhere),'ld_account.'.$addressfld)){
				$acctquerywhere .= ',ld_account.'.$addressfld;
			}
		}
		$pos = strpos($query,'FROM ')?strpos($query,'FROM '):strpos($query,'from ');
		$query = 'SELECT distinct '.$acctquerywhere.',ld_account.discount_rate,
					ld_account.accountid as crmid  '.substr($query,$pos,strlen($query));
	}
}else{
	$getwhere = $popuplistview->getpopupquery($currentModule,$current_user,$viewid);
	$query = 'SELECT DISTINCT 
				  ld_users.*,
				  ld_profile.profilename as rolename
				FROM
				  ld_users 
				  LEFT JOIN ld_profile 
				    ON ld_profile.profileid = ld_users.profileid 
				' . $getwhere;
	if(isset($_REQUEST['search_text']) && !empty($_REQUEST['search_text'])){
		if($_REQUEST['search_field'] == 'profileid'){
			$_REQUEST['search_field'] = 'ld_profile.profilename';
		}
		$query .= ' and '.$_REQUEST['search_field'].' like "%'.$_REQUEST['search_text'].'%" ';
	}
}

$page_list_query=$popuplistview->getPageListQuery();

if(isset($_REQUEST['frommodule']) && $_REQUEST['frommodule'] != "" || isset($_REQUEST['fromModule']) && $_REQUEST['fromModule'] != "")
{
    if(isset($_REQUEST['frommodule']))
        $fromModule = $_REQUEST['frommodule'];
    else
        $fromModule = $_REQUEST['fromModule'];
    $smarty->assign("FROMMODULE",vtlib_purify($fromModule));
    
}
/**
* edit:chj
* date:2014-6-23
* reason:(教育行业)班级选择学员时 获取当前班级中已招募总学员数、班级的人数限制
*/
if(getEduType('Edu') == true)
{
    if($_REQUEST['module'] == 'Accounts' && $_REQUEST['return_module'] == 'Project')
    {
        $sql = 'select count(*) as count from ld_lessionplanorg 
					inner join ld_crmentity on ld_crmentity.crmid = ld_lessionplanorg.otherid 
					where ld_lessionplanorg.otherid = ? and ld_lessionplanorg.type = 1 ';
        $result = $adb->pquery($sql,array($_REQUEST['recordid']));
        $smarty->assign('CLASSROOMACCOUNTALL',$adb->query_result($result,0,0));
        $smarty->assign('GETPROJECTGALLERYFUL',getProjectGalleryful($_REQUEST['recordid']));
        $smarty->assign('PROJECTSTATUS',getEduType('Edu'));   
    }
}
/**
 * edit:kevin
 * date:2013-06-19
 * reason:群发短信"联系人","客户","用户"sql语句处理
 */ 
if($popuptype=='set_return_groupmasssms'){
    switch($currentModule){
        case 'Accounts':
        $query ="select * FROM (select ld_contactdetails.accountid,ld_contactdetails.mobile from ld_contactdetails
         where ld_contactdetails.deleted=0) as T1
          inner join (".$query.") as T2 on T1.accountid=T2.crmid LEFT JOIN ld_account on ld_account.accountid=T1.accountid where mobile<>'' and ld_account.accountid>0";break;
          case 'Contacts':
          $page_list_query=$page_list_query." and ld_contactdetails.mobile<>''";break;
          case 'Users':
          $query=$query." and phone_mobile<>''";break;
    }   
}

if($currentModule == 'Products' && $_REQUEST['record_id'] && ($popuptype == 'inventory_prod' || $popuptype == 'inventory_prod_po'))
{
	$product_name = getModuleHref('Products',$_REQUEST['record_id']);
	$smarty->assign("PRODUCT_NAME", $product_name);
	$smarty->assign("RECORD_ID", vtlib_purify($_REQUEST['record_id']));
}

//$smarty->assign("ALPHABETICAL", $alphabetical);

$smarty->assign("ACCOUNTID",$_REQUEST['accountid']);
$smarty->assign('VENDORID',$_REQUEST['vendorid']);

/*
* 根据module判断是否显示产品明细，如果URL中存在select=enable为多选
*/
if($_REQUEST['module']&&get_file_address($_REQUEST['module'],'ProductDetails'))
{
   $listview_header_search = $popuplistview->queryGenerator->productDetails->getListViewHeaderSearch();
   
   $popuplistview->queryGenerator->productDetails->RemoveFieldSearch($listview_header_search);
}
else
{
    $listview_header_search=$popuplistview->getPopupBasicSearch();
    
}

//if($_REQUEST['popuptype']=='selectsource')
//{
    if(get_file_address($currentModule,'ProductDetails'))
    {
         crm_load_class_file('ProductDetail_ListController','include/ListView/ProductDetail');
          $controller = new ProductDetail_ListController($adb, $current_user, $popuplistview->queryGenerator);
    }
    else if(get_file_address($currentModule,$currentModule.'DetailFieldsHtml')){
       
        crm_load_class_file('TabDetailListViewController','include/ListView','TabDetailListViewController'); 
        $controller = new TabDetailListViewController($adb, $current_user, $popuplistview->queryGenerator,$currentModule);
    }
    else
    {
        $controller = new ListViewController($adb, $current_user, $popuplistview->queryGenerator);
    }
    $fieldnames = $controller->getAdvancedSearchOptionString();
    $smarty->assign("FIELDNAMES", $fieldnames);


if ($popuptype == 'selectsource' && get_file_address($currentModule,'ProductDetails')){
    $isHaveDetailField = $controller->isHaveDetailField();
    $smarty->assign("isHaveDetailField", $isHaveDetailField);
}
//}
/**
* @author andrew
* @data 2015-5-19
* @param $ApproveModuleStatus 模块是否开启审批
* @param $deployarray 系统参数设置--关联单据只能选择已审批单据 0：否，1：是
* @param $modulearray 不需要判断的模块
* @param $entityarray 模块信息
*/
$modulearray=array('Contacts','Accounts','Users','ContactRecords','Vendors','VendorContact','VendorContactRecords','Products','ServiceCharge','PriceBooks');
//$deployarray=getSys_deploy(68);
$from_mod=$_REQUEST['frommodule'];//父模块
$srcmodule=vtlib_purify($_REQUEST['srcmodule']);
if(!empty($srcmodule)){
    $from_mod=$srcmodule;
}
//zkt 20230626 BUG0068464  出库单的选择源单中销售合同审批要求设置为已批准无数据 
/*
//project:PROT387 edit：cyb date:2016-08-05 description:获取审批要求字段值；
if(!in_array($currentModule,$modulearray)){
    $approve_demand=$focus->get_approve_demand_byModule($fromModule);
    if($approve_demand==1){
		$ApproveModuleStatus=Approve::getApproveModuleInfo();
		if($ApproveModuleStatus[$currentModule]==$currentModule){
			$tabid = getTabid($currentModule);
			$entityarray = getEntitynameInfo($tabid);
			$page_list_query .= ' and '.$entityarray['tablename'].".approvestatus='".constant('D_A_S_APPROVED')."' ";
			$query .= ' and '.$entityarray['tablename'].".approvestatus='".constant('D_A_S_APPROVED')."' ";
		}
	} 
}
*/
if($module!='Users')
    $listcountquery = $popuplistview->queryGenerator->getQuery('',1);//获取列表单据的总数

/**
 * edit:chj
 * date:2014-9-10
 * reason:产品关键字模糊查询 根据查询的fieldname和输入关键字，带入弹出窗口检索
 * */
if(isset($_REQUEST['searchfieldname']))
{
    //判断传入的fieldname是否在当前窗口的条件检索中
    if(isset($listview_header_search[$_REQUEST['searchfieldname']]))
    {
        $smarty->assign('SEARCHFIELDNAME',$_REQUEST['searchfieldname']);
        //关键字
        if(isset($_REQUEST['searchvalue']))
        {
            $smarty->assign('SEARCHVALUE',$_REQUEST['searchvalue']);
        }
        if($module == 'Products' && isset($_REQUEST['searchvalue']) && $_REQUEST['searchvalue'] != '')
        {
            $page_list_query .= " and ld_products.productname like '%".$_REQUEST['searchvalue']."%'";
            //$query .= " and ld_products.productname like '%".$_REQUEST['searchvalue']."%'";
			$listcountquery .=" and ld_products.productname like '%".$_REQUEST['searchvalue']."%'";
        }
    }
}
/**
* @author andrew
* @data 2015-7-7
* @param 选择产品时，是否判断已经审批
*/
$deployarray=getSys_deploy(71);//选择产品是否判断审批
$deployarray_select=getSys_deploy(70);//产品模块审批是否开启

if($deployarray['deploy_value']==='0'&&$currentModule=='Products'&&$deployarray_select['deploy_value']=='0'&&get_file_address($_REQUEST['frommodule'],'ProductDetails')){
        $page_list_query .= " and ld_products.approvestatus='".constant('D_A_S_APPROVED')."' ";
        //bug:23286 选择产品是否判断审批参数开启，但是列表不显示数据；
        //$query .= " and ld_products.approvestatus='".constant('D_A_S_APPROVED')."' ";
		$listcountquery .= " and ld_products.approvestatus='".constant('D_A_S_APPROVED')."' ";
}
//chj 2021/4/28 45693: （61mis.com/kfbcrm）财务管理-收款单-新建；新建收款单，客户名称“YHC”，源单选择收款计划，点击第2分页，已收款的计划源单会显示出来
if(!empty($_REQUEST['page_popup']) && $_REQUEST['page_popup'] == 'yes' && $module == 'PaymentPlan' && !empty($_REQUEST['frommodule'])){
	$page_list_query .= ' and ld_paymentplan.receivable_balance > 0 ';
}

//BUG20240604-25 ls 240605 退货单新建选择未出库的订单退货时，应该根据系统参数“设置未出库的销售订单是否允许退货”和“设置未入库的采购订单是否允许退货”控制(以前条件是设置在选择源单的‘其他条件’里)
if ($fromModule == 'SalesBack' && $_REQUEST['module'] == 'SalesOrder') {
    $saleback_deploy_arr=getSys_deploy(85);
    if($saleback_deploy_arr['deploy_value']==0){
        $page_list_query.=" AND (ld_salesorder.stockpresence = '全部出库' OR ld_salesorder.stockpresence = '部分出库')";
    }
} elseif ($fromModule == 'PurchaseBack' && $_REQUEST['module'] == 'PurchaseOrder') {
    $purchaseback_deploy_arr=getSys_deploy(132);
    if($purchaseback_deploy_arr['deploy_value']==0){
        $page_list_query.=" AND (ld_purchaseorder.stockpresence = '全部入库' OR ld_purchaseorder.stockpresence = '部分入库')";
    }
}
$VersionInfo = getVersionInfo();
$smarty->assign("AccountVersionInfo",$VersionInfo);
//克莱门特 热线单选择客户后，商品选择只能选择该客户的商品，或该经销商所有下级客户对应的商品。     这个多次在会上讨论过，需要做控制。
if($_REQUEST['return_module'] == 'Potentials' && $_REQUEST['module'] == 'Products' && $VersionInfo['account'] == 'climaveneta' && ($_REQUEST['recordid'] > 0 || $_REQUEST['record_id'] > 0)){
	if(!empty($_REQUEST['record_id']))
		$cli_record = $_REQUEST['record_id'];
	else
		$cli_record = $_REQUEST['recordid'];
	$relaccount_query = 'select GROUP_CONCAT(accountid) as acc_id from ld_account where parentid = (
					select accountid from ld_potential where potentialid = ?)';
	$relaccount_result = $adb->pquery($relaccount_query,array($cli_record));
	$rel_accountid = $adb->query_result($relaccount_result,0,0);
	if(!empty($rel_accountid)){
		$page_list_query .= ' and ld_products.realaccountid in ('.$rel_accountid.') ';
	}else{
		$relaccount_query = 'select accountid from ld_potential where potentialid = ?';
		$relaccount_result = $adb->pquery($relaccount_query,array($cli_record));
		$rel_accountid = $adb->query_result($relaccount_result,0,0);
		$page_list_query .= ' and ld_products.realaccountid in ('.$rel_accountid.') ';
	}
	$smarty->assign("RECORD_ID", $cli_record);
}
//海格，报价单不允许选择相同的产品
if($_REQUEST['return_module'] == 'Quotes' && $_REQUEST['module'] == 'Products' && $VersionInfo['account'] == 'haige'){
    if(isset($_REQUEST['productid_str'])){
        $selected_productid = $_REQUEST['productid_str'];
        $_SESSION['haige'][$currentModule][$current_user->id]['productid_str'] = $selected_productid;
    }else if(isset($_SESSION['haige'][$currentModule][$current_user->id]['productid_str'])){
        $selected_productid = $_SESSION['haige'][$currentModule][$current_user->id]['productid_str'];
    }
    if($selected_productid !=""){
        $page_list_query .= ' and ld_products.productid not in ('.$selected_productid.') ';
    }
}


//中午电器报价单模块产品分录不含税单价的价格表弹窗列表  (需求只显示已批准的价格表)
if($fromModule == 'Quotes' && $_REQUEST['module'] == 'PriceBooks' && $VersionInfo['account'] == 'zhongwu'){
    $setsystem_approve_209 = getSys_deploy(209);	//价格表是否开启审批流程  0是  1否
    if(vtlib_isModuleActive('PriceBooks') && $setsystem_approve_209['deploy_value'] == '0'){
        $page_list_query .= ' AND ld_pricebook.approvestatus=\'已批准\' ';
    }

    $cf_4376 = vtlib_purify($_REQUEST['cf_4376']);//销售类型,销售类型名称 等于 价格表名称
    if (!empty($cf_4376)) {
        $page_list_query .= ' AND ld_pricebook.bookname=\''.$cf_4376.'\' ';
    }
}

//克莱门特 发货单选择报损单和报损变更单时，已经选择过的，则不在显示
if(!empty($_REQUEST['frommodule']) && $_REQUEST['frommodule'] == 'PurchaseInquiryOrder' && $VersionInfo['account'] == 'climaveneta'){
    $page_list_query .=' and ld_purchaseinquiryorderdetail.lineitem_id not in (select parent_lineitem_id from ld_purchaseinquiryorder
		LEFT JOIN ld_purchaseinquiryorderdetail on ld_purchaseinquiryorderdetail.id = ld_purchaseinquiryorder.purchaseinquiryorderid
		where ld_purchaseinquiryorderdetail.entitytype = "'.$module.'" and ld_purchaseinquiryorder.deleted <> 1) ';
};
$relate_create_where_sql = '';
if($_REQUEST['module']!='Users')
{
    crm_load_class_file('cls_RelateCreateCondition','include');
    $relatecreateconditionobj=cls_RelateCreateCondition::getInstance($_REQUEST['module'],$_REQUEST['frommodule']);
    $columnvalues=ldcrm_json_decode($_REQUEST['requestvalues']);
    //$columnvalues=json_decode($_REQUEST['requestvalues'],true);
    // dump($_REQUEST['requestvalues']);
    $relatecreateconditioninfos=  $relatecreateconditionobj->getChooseDataWhere($columnvalues);

    $page_list_query .= $relatecreateconditioninfos['where'];

    $relate_create_where_sql = $relatecreateconditioninfos['where'];

    if($_REQUEST['worksheetinfo']=='recentuse' && $_REQUEST['related_productid']>0){
        //工单管理模块选择配件时，显示使用过的配件
        $related_productid = $_REQUEST['related_productid'];
        $page_list_query .= ' and ld_products.productid in (select productid from ld_worksheetdetail  where related_productid = '.$related_productid.')';
    }
    //BUG20240612-77 ls 240612 销售订单-产品选导入测试，然后价格表显示有单据但是列表里没有数据（计算总条数的代码$page_list_query应该都拿到$noofrows逻辑之前）
    if($currentModule == 'PriceBooks')
    {
        $productid=empty($_REQUEST['productid'])?0:$_REQUEST['productid'];
        $currency_id=$_REQUEST['currencyid'];
        if($currency_id == null) $currency_id = 1;
        $page_list_query .= ' and ld_pricebook.pricebookid in (select pricebookid from ld_pricebookproductrel  where productid = '.$adb->sql_escape_string($productid).') and ld_pricebook.currency_id='.$adb->sql_escape_string($currency_id).'  ';
    }
}

if(get_file_address($currentModule,'ProductDetails'))
{
    if(isset($_REQUEST['listval']) && $_REQUEST['listval'] != '')
        $smarty->assign('SELECTLISTVAL',$_REQUEST['listval']);
    else
        $smarty->assign('SELECTLISTVAL','');
    if ($NoRepeatQueryWithDetail =='yes' || $NoRepeatQueryWithDetail == 'no'){
        if ($NoRepeatQueryWithDetail == 'yes' && !empty($focus->Detail_table)){//不允许重复开启且开启带出分录
           // $page_list_query .= ' AND '.$focus->Detail_table.'.'.$focus->Detail_table_id.' not in ('.$selectDetailLineitemid.') ';
        }else if ($NoRepeatQueryWithDetail == 'no' && !empty($focus->table_name)){//不允许重复开启但不开启带出分录
         //   $page_list_query .= ' AND '.$focus->table_name.'.'.$focus->table_index.' not in ('.$selectlistvalue.') ';
        }
    }
    $arr['page_list_query'] = json_encode($page_list_query);
    if ($popuptype !== 'MultiplePopup'){
        $count_result = $adb->query( $page_list_query);
        $noofrows = $adb->num_rows($count_result);

    }
}
else if ($popuptype !== 'MultiplePopup'){

    //0018858: 群发短信、群发邮件界面：选择客户弹出层报错
    if ($currentModule != 'Users') {
        $count_result = $adb->query($page_list_query);
    } else {
        //echo $query;
        $count_result = $adb->query($query);
    }
    $noofrows = $adb->num_rows($count_result);

}

//wym 1000016 pc端 页面设置，增加“关联选择单据（多选）”字段类型----关联需求：XUQIU1001753
if($_REQUEST['popuptype']=='MultiplePopup' ){
    $fieldname = $_REQUEST['fieldname'];
    if(!empty($fieldname)){
        if(substr($fieldname,0,12)=='defaultvalue'){
            //后台设置-新增字段-设置默认值 从设置界面获取设置属性 需要先将页面上的信息处理成和数据库一样的格式
            //设置默认值先不用做按照审批要求查找
/*            $advance_demand = array_filter(ldcrm_json_decode($_REQUEST['advancedemand']), function($item) {
                return !is_null($item);
            });
            $advance_demand = array_values($advance_demand);
            $advance_demand = json_encode($advance_demand,JSON_UNESCAPED_UNICODE);
            $advance_demand_groups = array_filter(ldcrm_json_decode($_REQUEST['advancedemandgroups']), function($item) {
                return !is_null($item);
            });
            $advance_demand_groups = array_values($advance_demand_groups);
            $advance_demand_groups = json_encode($advance_demand_groups,JSON_UNESCAPED_UNICODE);
            $approve_demand = $_REQUEST['approvedemand'];*/
        }else{
            //编辑页-多选字段选值 从数据库获取该字段的设置属性
            $tabid = getTabid($fromModule);
            if ($tabid > 0) {
                $query_advance = "SELECT * FROM ld_field WHERE tabid=? AND fieldname=? AND displaytype=1 LIMIT 1";
                $result_advance = $adb->pquery($query_advance,array($tabid, $fieldname));
                $rows = $adb->num_rows($result_advance);
                if($rows > 0){
                    $uitype = $adb->query_result($result_advance,0,'uitype');
                    $advance_demand = $adb->query_result($result_advance,0,'advance_demand');
                    $advance_demand_groups = $adb->query_result($result_advance,0,'advance_demand_groups');
                }
                $focus->setPopuptype($_REQUEST['popuptype']);
                $approve_demand = $focus->get_approve_demand_byModule($fromModule);
            }
        }
        if ($advance_demand && $advance_demand != '[]') {
            //审批要求控制
            $advance_demand_group_arr=json_decode($advance_demand_groups,true);
            //$advance_demand_group_arr[sizeof($advance_demand_group_arr)-1]['groupcondition']='';
            //$advance_demand_groups=json_encode($advance_demand_group_arr);
            //$queryGenerator =QueryGenerator::getInstance($_REQUEST['module'], $current_user,$popuplistview->queryGenerator->customview);
            $queryGenerator =$popuplistview->queryGenerator;
            $tmpinput = [];
            $tmpinput['advft_criteria'] = $advance_demand;
            $tmpinput['advft_criteria_groups'] = $advance_demand_groups;
            $tmpinput['searchtype'] = 'advance';
            $queryGenerator->addUserSearchConditions($tmpinput);
            $page_list_query = $queryGenerator->getQuery('droppop', 1);
            //duan 20241010 因为多选单据时,不添加上面的特殊业务逻辑,重新生成sql并,重新添加额外自定义条件
            $page_list_query .= ' '.$relate_create_where_sql;
        }
        if ($approve_demand == 1) {
            //审批“已批准”
            $tablename = $focus->table_name;
            $wheretable = ' and ifnull( ' . $tablename . ".approvestatus,'')='" . constant('D_A_S_APPROVED') . "' ";
            $page_list_query .=$wheretable;
        }
    }
}

//29741: 市场活动明细界面，相关信息-联系人，选择联系人界面勾选全选复选框，结果没有显示“全选所有 n条记录”的按钮
$smarty->assign("NUMOFROWS",$noofrows);
$smarty->assign("CURPAGECOUNT",$list_max_entries_per_page_new);
//ls BUG0065470  没有显示共几条记录，前一次修改的错误代码此处已经删了
$recordListRangeMsg = getRecordRangeMessage('', '',$noofrows);
$smarty->assign('recordListRange',$recordListRangeMsg);


// vtlib customization: To override module specific popup query for a given field
$override_query = false;
if(method_exists($focus, 'getQueryByModuleField')) {
	$override_query = $focus->getQueryByModuleField(vtlib_purify($_REQUEST['srcmodule']), vtlib_purify($_REQUEST['forfield']), vtlib_purify($_REQUEST['forrecord']), $query);
	if($override_query) {
		$query = $override_query;
	}
}
$smarty->assign('SRCMODULE',vtlib_purify($_REQUEST['srcmodule']));
//Retreiving the start value from request
if(isset($_REQUEST['start']) && $_REQUEST['start'] != '') {
	$start = vtlib_purify($_REQUEST['start']);
	if($start == 'last'){
		$count_result = $adb->query( mkCountQuery($query));
		$noofrows = $adb->query_result($count_result,0,"count");
		if($noofrows > 0){
			$start = ceil($noofrows/$list_max_entries_per_page_new);
		}
	}
	if(!is_numeric($start)){
		$start = 1;
	}elseif($start < 1){
		$start = 1;
	}
	$start = ceil($start);
} else {
	$start = 1;
}
$limstart=($start-1)*$list_max_entries_per_page_new;

$modulefieldobj=Field::getInstance($_REQUEST['module'],$adb);
$modulecolumn_fields =$modulefieldobj->getFieldArray('fieldname','');

$frommodulefieldobj=Field::getInstance($_REQUEST['frommodule'],$adb);
$frommodulecolumn_fields =$frommodulefieldobj->getFieldArray('fieldname','');

$parent_modulefieldobj=Field::getInstance($_REQUEST['parent_module'],$adb);
$parent_modulecolumn_fields =$frommodulefieldobj->getFieldArray('fieldname','');
/*echo "<pre>";
print_r($modulecolumn_fields);
echo "<pre>";
print_r($frommodulecolumn_fields);*/
$selectfor='&&';
if(array_key_exists('vendor_id',$modulecolumn_fields)&&array_key_exists('vendor_id',$frommodulecolumn_fields)){
   $selectfor = 'vendorid';
}

if(array_key_exists('account_id',$modulecolumn_fields)&&array_key_exists('account_id',$frommodulecolumn_fields)){
   $selectfor = 'accountid';
}     
if(array_key_exists('vendor_id',$modulecolumn_fields)&&array_key_exists('vendor_id',$parent_modulecolumn_fields)){
   $selectfor = 'vendorid';
}

if(array_key_exists('account_id',$modulecolumn_fields)&&array_key_exists('account_id',$parent_modulecolumn_fields)){
   $selectfor = 'accountid';
}  

if($_REQUEST['module']=='Quotes')
$selectfor = 'accountid';

if(get_file_address($_REQUEST['module'],'ProductDetails') || $_REQUEST['module'] == 'Documents')
{
  if($_REQUEST['frommodule'] == 'PurchaseOrder'&&$_REQUEST['module']=='SalesOrder'){
      
  
    $listview_header_search = $popuplistview->queryGenerator->productDetails->getListViewHeaderSearch();
           
  }else{
    /**
	 * 排序的逻辑集中到CRMEntity类中，方便处理
	 * @author Tujt 2015-04-23
	 */

    //如果选择客户只显示5条
    //echo $_REQUEST['module'];
    if($_REQUEST['module']=='Productbom'||($_REQUEST['parent_module']=='Vendors'||$_REQUEST['parent_module']=='Accounts'
    ||$_REQUEST[$selectfor])){
      
    }else{
      
        if($_REQUEST['module']=='SalesOrder'&&$_REQUEST['frommodule']=='SalesOrder'){
            $smarty->assign('DSNCOCOTSTP5TQR', 'SOQD5D');
        }elseif($selectfor=='accountid'){
            $smarty->assign('DSNCOCOTSTP5TQR', 'DSNCOCOTSTP5TQR');
        }elseif($selectfor=='vendorid'){
            $smarty->assign('DSNCOCOTSTP5TQR', 'DSNCOCOTSTP5TQRVENDOR');
        }
        $entitytypes= getSourceModule($_REQUEST['frommodule']);
        $entityModules = [];
        foreach($entitytypes as $index=>$entityinfo)
        {
            $entityModules[]=$entityinfo['entitytype'];
            
        }
        if(in_array($_REQUEST['module'],$entityModules))
        {
            
        }
        else
            $smarty->assign('NAVI', 'NAVI');
    }
  
    $listview_header_search = $popuplistview->queryGenerator->productDetails->getListViewHeaderSearch();
    
  }

}
else if(get_file_address($_REQUEST['module'],$_REQUEST['module'].'DetailFieldsHtml'))
{
  
  
    $listview_header_search = $popuplistview->queryGenerator->TabDetails->getListViewHeaderSearch();
           
  }
else
{

    $listview_header_search=$popuplistview->getPopupBasicSearch();
    
}

/*if($_REQUEST['frommodule'] == 'PurchaseOrder'&&$_REQUEST['module']=='SalesOrder'){
      
    list($page_list_query,$order_by,$sorder) = $popuplistview->queryGenerator->customview->getOrderWhere($page_list_query);       
    $query.=" inner join ( $page_list_query limit $limstart,$list_max_entries_per_page_new ) as temp on temp.$focus->table_index=$focus->table_name.$focus->table_index";
    $query.=$popuplistview->queryGenerator->getWhereClause();
    $query.=$popuplistview->queryGenerator->getPopupwhereclause();
	list($query,$order_by,$sorder) = $popuplistview->queryGenerator->customview->getOrderWhere($query);
    //38601: （http://51mis.com/kfbcrm [^]）采购订单新增界面>选择源单字段，选择合同订单模块：选择合同订单界面没有受“源单类型定制”参数控制。
           
  }else{*/

    if($_REQUEST['module']!='Users')//23157: 群发短信：接收人手机：用户管理，点击【+】时弹出页面报错
    {

           //edit:can 2020-11-09 043164: (61mis.com/kfbcrm/index.php)营销-群发邮件-添加联系人（需要补丁）；在操作群发邮件选择联系人时，左侧勾选权限框后，显示所有单据的条数，但点击选择后只是显示列表中的联系人email；需选择全部联系人email
            $_SESSION['popup_'.$_REQUEST['module']."_".$_REQUEST['frommodule']."_pagequery"]=$page_list_query;
            $page_list_query_noorder = $page_list_query;
        	list($page_list_query,$order_by,$sorder) = $popuplistview->queryGenerator->customview->getOrderWhere($page_list_query);
            //如果选择客户只显示5条
            //echo $_REQUEST['module'];

            if( $_REQUEST['module']=='Productbom'||($_REQUEST['parent_module']=='Vendors'
                    ||$_REQUEST['parent_module']=='Accounts'
                ||$_REQUEST[$selectfor])||!get_file_address('ProductDetails',$_REQUEST['module']))
            {
                //edit: xll 2023/06/05 XUQIU1001203 相关对象改为选择源单样式，此处为最大显示条数控制
               if($_REQUEST['popuptype']=='selectsource' || $_REQUEST['popuptype']=='related_to')
                {
                    $frommodule=$_REQUEST['frommodule'];
                    $tabid=getTabid($frommodule);
                    //37536: 销售发票-选择合同订单界面-高级查询，设置查找条件：客户名称不为空值，产品名称不为空值
                    $selectentitytype=$_REQUEST['module'];

                    $option_tabid=getTabid($selectentitytype);
                   $optionmoduleobj= cls_OptionModule::getInstance($frommodule);
                   $options=$optionmoduleobj->getData();
                   
                   $maxrowsshow=$options[$tabid][$option_tabid]['maxrowsshow'];
				   $limstart=($start-1)*$maxrowsshow;
				   $list_max_entries_per_page_new = $maxrowsshow;
                   $query.=" inner join ( $page_list_query limit $limstart,$maxrowsshow ) as temp on temp.$focus->table_index=$focus->table_name.$focus->table_index";
                }
               else if($_REQUEST['popuptype']=='specific' && !empty($_REQUEST['fieldname'])){
					//39164: （51mis.com/kfbcrm）页面设置>选择“服务合同”进入页面设置界面： 1.点击“合同订单”字段编辑按钮，“*最多显示数据条数 ”选择为“5”； 2.进入“服务合同”新建单据界面，选择“合同订单”弹出层显示数据条数未按参数控制显示5条
                   $fromfocus = CRMEntity::getInstance($_REQUEST['frommodule']);
                   $fieldinfo = $fromfocus->fieldobj->getFieldInfoobjBykey("fieldname", $_REQUEST['fieldname']);
					 if(!empty($fieldinfo)){
						$maxrowsshow = $fieldinfo->getMaxRowsShow();//获取最大显示行数
					 }else{
						$maxrowsshow = 5;
					 }
					 $list_max_entries_per_page_new = $maxrowsshow;
					 $limstart=($start-1)*$list_max_entries_per_page_new;
					 $query.=" inner join ( $page_list_query limit $limstart,$maxrowsshow ) as temp on temp.$focus->table_index=$focus->table_name.$focus->table_index";
				}
               else if($_REQUEST['popuptype']=='MultiplePopup'){
                   //wym 1000016 pc端 页面设置，增加“关联选择单据（多选）”字段类型----关联需求：XUQIU1001753
                   //focus添加非空判断
                   $fromfocus = CRMEntity::getInstance($_REQUEST['frommodule']);
                   $fieldname = $_REQUEST['fieldname'];
                   if(!empty($fieldname)){
                       $fieldinfo = $fromfocus->fieldobj->getFieldInfoobjBykey("fieldname", $fieldname);
                       if(substr($fieldname,0,12)=='defaultvalue'){
                           //后台设置-新增字段-设置默认值 从设置界面获取设置属性
                           $maxrowsshow=$_REQUEST['maxrowsshow'];//获取最大显示行数
                           $datarange=$_REQUEST['datarange'];//获取数据范围
                       }else if(!empty($fieldinfo)){
                           //编辑页-多选字段选值 从字段信息获取该字段的设置属性
                           $maxrowsshow = $fieldinfo->getMaxRowsShow();
                           $datarange = $fieldinfo->getDataRang();
                       }
                   }
                   $change_page='yes';
                   $list_max_entries_per_page_new = $maxrowsshow??$list_max_entries_per_page_new;
                   $limstart=($start-1)*$list_max_entries_per_page_new;
                   if(!is_admin($current_user) && $_REQUEST['datarange']=='permit') {
                       $query.= " LEFT JOIN ld_tabshare  on ld_tabshare.crmid = $focus->table_name.$focus->table_index";
                   }
                   $query.=" inner join ( $page_list_query limit $limstart,$list_max_entries_per_page_new ) as temp on temp.$focus->table_index=$focus->table_name.$focus->table_index";
                   $MultiplePopup_page_list_query_havelimit = "$page_list_query limit $limstart,$list_max_entries_per_page_new";
                   $num_row_sql = "$page_list_query limit $limstart,$list_max_entries_per_page_new";
                   $num_row_result = $adb->pquery($num_row_sql,array());
                   $noofrows = $adb->num_rows($num_row_result);
                   $recordListRangeMsg = getRecordRangeMessage('', '',$noofrows);
               }
                else
                    $query.=" inner join ( $page_list_query limit $limstart,$list_max_entries_per_page_new ) as temp on temp.$focus->table_index=$focus->table_name.$focus->table_index";
            
            }else{
                
                $query.=" inner join ( $page_list_query limit 0,5 ) as temp on temp.$focus->table_index=$focus->table_name.$focus->table_index";
               
            }
           
			  if(get_file_address($_REQUEST['module'],'ProductDetails'))//25042: 项目计划：相关信息-知识管理-选择，按负责人查找查不出单据
			  {
				/*
                    徐艳楠（哥乐巴客户）：采购订单关联销售订单，客户说同一销售订单部分采购时，未采购数量为0的产品不会显示，而现在升到最新版后。该订单会全部显示
                */
				  $query.= $popuplistview->queryGenerator->getWhereClause().$popuplistview->queryGenerator->popuwhereclause;////不能删除，删除后，查询条件为产品明细有bug;

                  //选择源单 类型设置添加不允许重复
                  if ($NoRepeatQueryWithDetail =='yes' || $NoRepeatQueryWithDetail == 'no'){
                      if ($NoRepeatQueryWithDetail == 'yes' && !empty($focus->Detail_table)){//不允许重复开启且开启带出分录
                        //  $query .= ' AND '.$focus->Detail_table.'.'.$focus->Detail_table_id.' not in ('.$selectDetailLineitemid.') ';
                      }else if ($NoRepeatQueryWithDetail == 'no' && !empty($focus->table_name)){//不允许重复开启但不开启带出分录
                        //  $query .= ' AND '.$focus->table_name.'.'.$focus->table_index.' not in ('.$selectlistvalue.') ';
                      }
                  }
			  }
              //edit:can 2020-11-24 043411: （https://61mis.com/kfbcrm [^]）客户问题（蔡云桥），收款单选择“合同订单”源单弹出层界面，若合同有多条产品分录时，合同订单单据应该只显示一行（需要补丁）
             if(method_exists($popuplistview->queryGenerator,'getListQueryGroupBy'))
                $query.=$popuplistview->queryGenerator->getListQueryGroupBy();
            //BUG0071973 liushuai 20230901 销售发票选源单出库单,分录排序没有按原模块分录显示的顺序排列
          	list($query,$order_by,$sorder) = $popuplistview->queryGenerator->customview->getOrderWhere($query,'',$popuplistview->queryGenerator);
    }
    else
      {
        $query.= " limit $limstart,$list_max_entries_per_page_new";
      }


//dump($query);
 // }

//zkt 20220506 51449	(https://81mis.com/kfbcrm/index.php) 财务管理》销售发票》新建》选择源单》服务合同，服务合同选择界面中未开票数量不显示
//查询下拉框不显示产品图片字段
if(get_file_address($_REQUEST['module'],'ProductDetails'))
{
     $listview_header_search_tmp  = $listview_header_search;
    foreach($listview_header_search_tmp as $optionvalue => $optionlabel)
    {
        $tmpoptionvaluearr = explode(':',$optionvalue);
        if($tmpoptionvaluearr[0] == 'ld_products')
        {
            $tmpcolumnname = $tmpoptionvaluearr[1];
            $tmpfieldinfo = $focus->detailfieldobj->getFieldInfoobjBykey('columnname',$tmpcolumnname);
            if(!empty($tmpfieldinfo)&&$tmpfieldinfo->getUIType()==69)
            {
                unset($listview_header_search[$optionvalue]);
            }
        }
    }
}
//print_r($listview_header_search);
$smarty->assign("SEARCHLISTHEADER", $listview_header_search);
if(strpos($query,'ld_modcomments.reltab'))
{
    $query=str_replace("ld_modcomments.reltab","(select fieldlabel from ld_tranlabel 
where tabid in (select tabid from ld_tab where name = ld_modcomments.reltab )
and trantable = 'ld_tab' and languagetype = '$languageType') as reltab",$query);
}

//echo $query;die;
//dump($query);
$list_result = $adb->query($query);
if(!empty($tmp_session)){
    $_SESSION['lvs'][$currentModule] = $tmp_session;
}

$navigation_array = VT_getSimpleNavigationValues($start, $list_max_entries_per_page_new,$noofrows);

//Retreive the List View Table Header
//$focus->initSortbyField($currentModule);
$focus->list_mode="search";
$focus->popup_type=$popuptype;
$url_string .='&popuptype='.$popuptype;
if(isset($_REQUEST['select']) && $_REQUEST['select'] == 'enable')
	$url_string .='&select=enable';
if(isset($_REQUEST['return_module']) && $_REQUEST['return_module'] != '')
	$url_string .='&return_module='.vtlib_purify($_REQUEST['return_module']);
//by ld kevin
if($popuptype == 'set_return_emails'||$popuptype=='set_return_groupemails'){
	$tabid = getTabid($currentModule);
	$mail_arr = getMailFields($tabid); 
	
	if(!empty($mail_arr)){
		$tablename = str_replace("ld_","",$mail_arr['tablename']);
		$fieldname = $mail_arr['fieldname'];
		$fieldlabel = $mail_arr['fieldlabel'];
		$focus->search_fields[$fieldlabel] = Array($tablename=>$fieldname);
		$focus->search_fields_name[$fieldlabel] = $fieldname;
	}
}

//列头
$listview = getSearchListViewHeader($focus,"$currentModule",$url_string,$sorder,$order_by,$popuplistview->queryGenerator);
$listview_header = $listview['listview_header'];

//ljj XUQIU20240425-01 关联选择单据（单选）、关联选择单据（多选）、选择源单弹出层界面，增加显示树结构分类（徐昱轩） 列表宽度调整
if(isset($_REQUEST['ajax']) && $_REQUEST['ajax'] != ''){
    if (isset($_REQUEST['isshowModuleListTree']) && $_REQUEST['isshowModuleListTree'] == 'yes'){
        $tree_width = $cls_module_tree->getTreeWidth();
        $smarty->assign('tree_width',$tree_width);
        if ($_REQUEST['tree_expand'] == 'yes'){
            $listview['listview_totalwidth'] = $listview['listview_totalwidth']-$tree_width;
        }
    }
}else{
    if ($cls_module_tree->moduleenable == 'yes' && $modulelisttree['tree_expand'] == 'yes'){
        $tree_width = $modulelisttree['tree_width'];
        $listview['listview_totalwidth'] = $listview['listview_totalwidth']-$tree_width;
    }
}
//列宽

$smarty->assign('LISTHEADERWIDTH',$listview['listview_width']);
$smarty->assign('LISTVIEWTOTALWIDTH',$listview['listview_totalwidth']);

$smarty->assign("CHKBOXWIDTH",$listview['listview_checkboxwidth']);

if(get_file_address($_REQUEST['module'],'ProductDetails')||get_file_address($_REQUEST['module'],$_REQUEST['module'].'DetailFieldsHtml')||get_file_address($_REQUEST['module'],'VendorsDetails'))
{
	$row_count = $popuplistview->queryGenerator->getMainColumnCount();
	$smarty->assign('ROW_COUNT',$row_count);   
	//列表字段对应的columnname 和 module
	if(get_file_address($_REQUEST['module'],$_REQUEST['module'].'DetailFieldsHtml'))
		$headerinfo=$popuplistview->queryGenerator->TabDetails->getListViewHeaderInfo();
	else
		$headerinfo=$popuplistview->queryGenerator->productDetails->getListViewHeaderInfo();
        
          
	$smarty->assign('HEADERNAME',$headerinfo['fieldname']);
	$smarty->assign('HEADERMODULE',$headerinfo['module']);
}else{
	$smarty->assign('HEADERNAME',$listview['listview_headername']['fieldname']);
	$smarty->assign('HEADERMODULE',$listview['listview_headername']['module']);
}
$smarty->assign("LISTHEADER", $listview_header);
if(isset($_REQUEST['select']) && $_REQUEST['select'] == 'enable')
	$header_count = count($listview_header)+1;//+1表示多选 checkbox
else
	$header_count = count($listview_header);
// ljj 20231123 XUQIU1001991 选择源单优化
if (isset($_REQUEST['setsequence']) && $_REQUEST['setsequence'] == 'yes'){
    $smarty->assign("SETSEQUENCE",$_REQUEST['setsequence']);
    $header_count +=1;
}
if('Productbom'==$module){
	$header_count++;
}
$smarty->assign("HEADERCOUNT",$header_count);


//内容
//弹出选择框序时簿内容
$listview_entries = getSearchListViewEntries($focus,"$currentModule",$list_result,$navigation_array,$form,$popuplistview->queryGenerator);
// edit: xll 2024/10/24 XUQIU20240909-02 选择产品增加产品属性的选择（需求暂停）
if($_REQUEST['module'] === 'Products') {
    $num = $adb->num_rows($list_result);
    $propertyStatusArr = [];
    for ($i = 0; $i < $num; $i++) {
        $productid = $adb->query_result($list_result, $i, 'productid');
        $status = $adb->query_result($list_result, $i, 'property_status');
        $status = $status ? 'yes' : 'no';
        $propertyStatusArr[$productid] = 'property_status="'.$status .'"';
    }
    $smarty->assign("propertyStatusArr",$propertyStatusArr);
}
$_REQUEST['selectmodule']=$_REQUEST['module'];//选择的原单，createPopWithDetailhtml中setProductsInfo使用

if(get_file_address($_REQUEST['module'],'ProductDetails')||get_file_address($_REQUEST['module'],$_REQUEST['module'].'DetailFieldsHtml')||get_file_address($_REQUEST['module'],"VendorsDetails")){
 
	$smarty->assign('POPHTML',PopInventory::createPopWithDetailhtml($listview_entries,$_REQUEST['select'],$row_count,$header_count,$_REQUEST['listval'],$controller));
}else{         
	$smarty->assign("LISTENTITY", $listview_entries);
}

$navigationOutput = getTableHeaderSimpleNavigation2($navigation_array, $url_string,$currentModule,"Popup");


if($change_page=='yes') {
    //29741: 市场活动明细界面，相关信息-联系人，选择联系人界面勾选全选复选框，结果没有显示“全选所有 n条记录”的按钮
    $smarty->assign("NUMOFROWS", $noofrows);
    $smarty->assign("CURPAGECOUNT", $list_max_entries_per_page_new);
    $smarty->assign('recordListRange', $recordListRangeMsg);
}
//BUG0075352多选字段弹出层界面，增加显示提示信息“说明：支持多字段模糊查询，仅显示符合条件的前5条数据”，5根据字段属性中的显示记录条数动态显示（同单选字段）
$smarty->assign("LIMITCOUNT", $list_max_entries_per_page_new);
$smarty->assign("NAVIGATION", $navigationOutput);
$smarty->assign("RECORD_COUNTS", $record_string);
$smarty->assign("POPUPTYPE", $popuptype);
$smarty->assign("PARENT_MODULE", vtlib_purify($_REQUEST['parent_module']));
$smarty->assign('FROMLINK',$_REQUEST['fromlink']);
//0019204: 合同订单>新建：点击产品的“+”，弹出选择产品弹出层，点击产品套餐页签，操作列按钮显示了省略号。
if($currentModule == 'Productbom'){
	$listview_fieldwidth = getSearchListViewFieldWidth($focus,"$currentModule",$url_string,$sorder,$order_by,$popuplistview->queryGenerator);
	$smarty->assign('LISTHEADERWIDTH',$listview_fieldwidth);
	$smarty->assign('OPERATIONWIDTH','135');
}
/**
* edit :chj
* date:2014-5-5
* reason: 选择源单，不覆盖第一次的选择记录。
**/
if(isset($_REQUEST['listval']) && $_REQUEST['listval'] > 0)
    $smarty->assign('LISTVAL',$_REQUEST['listval']);
else
    $smarty->assign('LISTVAL',0);
//产品行总函数
if(isset($_REQUEST['rowcnt']) && $_REQUEST['rowcnt'] > 0)
    $smarty->assign('ROWCNT',$_REQUEST['rowcnt']);
else
    $smarty->assign('ROWCNT',0);
/**
edit :chj
date"2013-12-04
reson:选择产品，不自动带出产品数量"
**/
$smarty->assign("RETURNMODULE", $_REQUEST['return_module']);
/**
更新操作
edit：cdw
date：20131204
reason：营销群发短信选择联系人界面改进
**/
$num_rows_contact = is_array($contact_SMS)?sizeof($contact_SMS):0;
$smarty->assign("html_contact_SMS",$html_contact_SMS);
$smarty->assign("num_rows_contact",$num_rows_contact);
/**
更新操作
edit：cdw
date：20131204
reason：营销群发短信选择客户界面改进
**/
$smarty->assign("html_accounttype_SMS",$html_accounttype_SMS);
$num_rows_account = is_array($accounttype_SMS)?sizeof($accounttype_SMS):0;
$smarty->assign("num_rows_account",$num_rows_account);
/**
更新操作
edit：cdw
date：20131204
reason：营销群发邮件选择联系人界面改进
**/
$smarty->assign("html_contact_Email",$html_contact_Email);
$smarty->assign("num_rows_contact_Email",$num_rows_contact_Email);
/**
更新操作
edit：cdw
date：20131204
reason：营销群发邮件选择联系人界面改进
**/
$smarty->assign("html_accounttype_Email",$html_accounttype_Email);
$smarty->assign("num_rows_account_Email",$num_rows_account_Email);
$smarty->assign('LANGUAGETYPE',$languageType);

// ljj 20231114 XUQIU1002047 选择源单界面，增加“已选单据合计”、“本页合计”和“全部合计”功能（邹晓宇）
if (isset($_REQUEST['isselectsearchdetail']) && $_REQUEST['isselectsearchdetail']=='yes'){//isselectsearchdetail 是否是选择原单
    crm_load_class_file('clsTotal_List','include/ListView');
    $clstotalobj=new clsTotal_List($controller);
    // ljj 20231207 BUG0076940 收款计划编辑界面，选择销售订单源单界面，显示列字段错位
    //选择源单 收款计划付款计划 合计部分无复选框colspan数量-1
    if (!isset($_REQUEST['select']) && isset($_REQUEST['frommodule'])){
        if ($_REQUEST['frommodule'] == 'PaymentPlan' || $_REQUEST['frommodule'] == 'SendPayment')
        $controller->setListCheckedBox('no');
    }
    $clstotalobj->setSourceType('Popup');
    //20231213 BUG0077154 选择源单”全部合计“ 选择了客户但全部合计是全部，没有限定范围
    $gettotaltype = $_REQUEST['gettotal'];

    $clstotalobj->setallTotalQueryFromPopup($page_list_query_noorder);
    $totalfldhtml='';
    if (!empty($gettotaltype)){
        $sourceInfo_arr=ldcrm_json_decode($_REQUEST['chooseSourceInfoarr']);
        if ($gettotaltype == 'select'){
            //isgetallselectedbillstotal = select 勾选复选框或取消复选框 获取已选单据合计 只增加或刷新'已选单据合计'
            $totalfldhtml .= $clstotalobj->getTotalSelectedBillsCount($page_list_query_noorder,$sourceInfo_arr,$list_result,$noofrows);
            $arr["content"]=$totalfldhtml;
            ConvertTojsonString(1,$arr,"success");
        }elseif ($gettotaltype == 'total'){
            //实例化类
            if($currentModule=='ServiceCharge')
            {
                crm_load_class_file('cls_servicecharge_totalList','modules/ServiceCharge');
                $clstotalobj=new cls_servicecharge_totalList($controller);
                $clstotalobj->setSourceType('Popup');
            }
            $thistotal=$clstotalobj->getAllTotalColumnData();
            $totalhtml=$clstotalobj->getAllTotalRow_html($thistotal,'list');
            $arr['content']=$totalhtml;
            ConvertTojsonString(1,$arr,'success');
        } elseif ($gettotaltype == 'all'){
            if (!empty($sourceInfo_arr)){
                //isgetallselectedbillstotal = all 基本查找、高级查找、翻页 若有"已选单据"，则刷新全部时带上“已选单据合计”部分
                $totalfldhtml .=$clstotalobj->getTotalSelectedBillsCount($page_list_query_noorder,$sourceInfo_arr,$list_result,$noofrows);
            }
        }
    }
    //固定有"本页合计""全部合计"的html部分
    $totalfldhtml .= $clstotalobj->getTotalFldCount($page_list_query." LIMIT  $limstart,$list_max_entries_per_page_new ",$list_result,$noofrows);
    $smarty->assign('TOTALFLDHTML',$totalfldhtml);
}

if(isset($_REQUEST['jsfile'])&&isset($_REQUEST['jspath']))
{
   
    //echo var_dump(file_exists(globalStatic::$root_directory.$_REQUEST['jspath'].'/'.$_REQUEST['jsfile'].".js"));
    
    if(file_exists(globalStatic::$root_directory.$_REQUEST['jspath'].'/'.$_REQUEST['jsfile'].".js"))
    {
        $js_url='http://'.$_SERVER['SERVER_NAME'].':'.$_SERVER["SERVER_PORT"]; 
    
        $js_PHP_SELF= $_SERVER['PHP_SELF'];
        $js_selfs=explode('/',$js_PHP_SELF);
       
        $js_self=$js_selfs[1].'/';
        
        $js_url.="/".$js_self.$_REQUEST['jspath'].'/'.$_REQUEST['jsfile'].".js";
        $js_script="<script src='$js_url' type='text/javascript'></script>";
        $smarty->assign("JS_SCRIPT",$js_script);
    }
    
    
}
$smarty->assign('WITHPRODUCTDETAIL',$withproductdetail);
//相关信息日期高级查询
//Crm_load_class_file("CommonView","modules/CustomView");
//$smarty->assign("DATETIMESTR",json_encode(CommonView::stdFilterDateTimeStr()));
setGLobalURLSmarty($smarty);//设置js,css等访问路径

//ljj XUQIU20240425-01 关联选择单据（单选）、关联选择单据（多选）、选择源单弹出层界面，增加显示树结构分类（徐昱轩） 左侧分类名称增加计数功能
if ($_REQUEST['isshowModuleListTree'] && $_REQUEST['isshowModuleListTree'] == 'yes'){
    $cls_MyCRMcryptobj=new cls_MyCRMcrypt();
    if ($popuptype == 'MultiplePopup'){
        $tmp_page_list_query = $cls_MyCRMcryptobj->encode($MultiplePopup_page_list_query_havelimit);
    }else{
        $tmp_page_list_query = $cls_MyCRMcryptobj->encode($popuplistview->queryGenerator->getSqlNoTreeWhere($page_list_query));
    }
    $smarty->assign("Encrypt_TreeWhere",$tmp_page_list_query);
}


if($_REQUEST['popup'] == 'yes'){
	$_REQUEST['diony']='diony';
    //XUQIU1001421 关联选择单据（单选）、关联选择单据（多选）、选择源单、分录选择产品弹出层中，增加“全屏/恢复”图标按钮（郭惠宇）
    $arr['fullscreen']=getUsersettingByLabel('notbymodule','','Fullscreen');
	$arr['title']=getTransTab($currentModule);
	if(!empty($_REQUEST['sendgroupemail']) && $_REQUEST['sendgroupemail'] == 'yes') {
        if ($popuptype != 'set_return_groupemails' && $popuptype != 'set_return_emails') {
            $arr['title'] = getFixedLabel('PLEASESELECTPHONE');
        } else {
            $arr['title'] = getFixedLabel('PLEASESELECTEMAIL');
        }
        $str = $smarty->fetch("GroupEmails.tpl");
	}else{

		$str=$smarty->fetch("PopupLayer.tpl");
	}
    
    if($_REQUEST['related_productid']>0&& $_REQUEST['frommodule']=='WorkSheet'){
        //工单管理模块，更改标题为’更换配件‘
        $arr['title'] = getFixedLabel('REPLACEACCESSORIES');
    }
    
    $arr['advancefieldnames']=$fieldnames;
	$arr['mail_field'] = $mail_field;	$arr['content']=$str;
    $arr['curr_row']=$_REQUEST['curr_row'];
    if(!empty($_REQUEST['fieldname']))
    {
        $arr['fieldname']=$_REQUEST['fieldname'];//相关对象
    }
    if(!empty($_REQUEST['selectrelationfrom']))
    {
        $arr['selectrelationfrom']=$_REQUEST['selectrelationfrom'];//相关对象
    }
    if($_REQUEST['module'] == 'CustomForm02' && isset($_REQUEST['account']) && $_REQUEST['account'] == 'yiwen'){
        // @edit:ls @date:2020-7-8 @reason: 义文机电一键检测需求
        $arr['account'] = $_REQUEST['account'];//相关对象
    }
    //wym 231201 给弹窗添加fields信息
    $fields=$focus->fieldobj->getListViewFields();
    $arr["fields"]=ldcrm_json_encode($fields['fields']);
	ConvertTojsonString(1,$arr,"success");
	exit();
}else{
	if(isset($_REQUEST['ajax']) && $_REQUEST['ajax'] != '')
	{
	   if($_REQUEST['page_popup'])
       {
            if(get_file_address($_REQUEST['module'],'ProductDetails')||get_file_address($_REQUEST['module'],$_REQUEST['module'].'DetailFieldsHtml'))
    		{
    			$smarty->display("PopupProductContentsLayer.tpl");//合同订单 - 选择源单 -报价单
    		}else if(get_file_address($_REQUEST['module'],"VendorsDetails")){
    			$smarty->display("ListPopupContentsLayer.tpl");//
    		}
    		else
    		{
    			$smarty->display("PopupContentsLayer.tpl");
    		}
       }
       else
       {
        	if(get_file_address($_REQUEST['module'],'ProductDetails')||get_file_address($_REQUEST['module'],$_REQUEST['module'].'DetailFieldsHtml'))
    		{
    			$smarty->display("PopupProductContents.tpl");
    		}else if(get_file_address($_REQUEST['module'],"VendorsDetails")){
    			$smarty->display("ListPopupContents.tpl");
    		}
    		else
    		{
    			$smarty->display("PopupContents.tpl");
    		}
       }
	}
	else
	{
		$smarty->display("Popup.tpl");
	}
}
/**
* edit:chj
* date:2014-6-23
* reason:教育行业 获取班级(项目)的学员人数上限
*/
function getProjectGalleryful($projectid)
{
    global  $adb;
    $sql = "select galleryful from ld_project where projectid = ?";
    $result = $adb->pquery($sql,array($projectid));
    return $adb->query_result($result,0,0);
}
?>