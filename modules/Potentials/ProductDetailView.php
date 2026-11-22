<?php
//zkt 20231014 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $theme,$currentModule,$singlepane_view,$current_user;
$smarty = new lingdangCRM_Smarty;


$focus = CRMEntity::getInstance($currentModule);

if(isset($_REQUEST['record']) && $_REQUEST['record']!= '') {
    $focus->retrieve_entity_info($_REQUEST['record'],$currentModule);
   

    $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey('columnname',$focus->getSmownerColumName());
    if($focus->column_fields[$fieldinfo->getFieldName()]!=$current_user->id)
    {
            crm_load_class_file('cls_CurUserDataScope','include/ListView');
            $datascopeobj=cls_CurUserDataScope::getInstance($currentModule,'record');
            $datascopeobj->isMyViewData($_REQUEST['record']);
    }
    $focus->id = $_REQUEST['record'];
    $focus->name=$focus->column_fields[$focus->list_link_field];
   
    $contactid= $focus->column_fields['contact_id'];
    $potentialid= $focus->column_fields['potential_id'];
    $quote_id= $focus->column_fields['quote_id'];
    //print_r($focus->column_fields);
    if($contactid != 0){
        $smarty->assign('CONTACTID',$contactid);
    } 
    if($potentialid != 0){
        $smarty->assign('POTENTIALID',$potentialid);
    } 
    if($quote_id != 0){
        $smarty->assign('QUOTEID',$quote_id);
    }
    
   //edit:can 20200716 销售阶段推进历史
    $focus->id = $_REQUEST['record'];	
    $focus->name=$focus->column_fields[$focus->list_link_field];
    $sql = "select lastmodified,sales_stage,smownerid from ld_potstagehistory where potentialid = ? order by historyid desc";
    $result = $adb->pquery($sql,array($focus->id));
    $num_rows = $adb->num_rows($result);
   
    for($i = 0; $i<$num_rows;$i++){
        $potenialsArr[$i] = array(
            'lastmodified' => $adb->query_result($result,$i,'lastmodified'),
            'sales_stage' => $adb->query_result($result,$i,'sales_stage'),
            'smownerid' => getOwnerName($adb->query_result($result,$i,'smownerid'))
        );
    }
    $smarty->assign('POTENIALSARR',$potenialsArr);
    $smarty->assign('NUMROWS',$num_rows);


}
/* 详情页按钮 begin */
$focus->getModuleLogic($currentModule)->getDetailViewButton();
$smarty->assign('DETAILBUTTON',$focus->logic->detail_buttons);
$smarty->assign('APPROVESTATUS',$focus->logic->getApproveImage());//审批状态图片

if(isset($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true') {
	$focus->id = "";
} 
//用户创建出库单权限
//$smarty->assign("PROPRESENCE",getpower($current_user->id,'OutboundOrder',1));

//$smarty->assign("HELPDESKLIMIT",getpower($current_user->id,'HelpDesk',1));
$smarty->assign("ACCOUNTID",$focus->column_fields['account_id']);
$smarty->assign("POTENTIALID",$focus->column_fields['potential_id']);
$smarty->assign("CONTACTID",$focus->column_fields['contact_id']);
//$TabArray = array();
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";

$smarty->assign('ISSUBMIT',$issubmit);
$smarty->assign('ISAPPROVE',$isapprove);
$smarty->assign('ISCANCEL',$iscancel);
//$smarty->assign('APPROVE',$approvelog);
$smarty->assign('APPROVEMOD','1');//审批模块，是否加载审批历史
$smarty->assign('ISEDIT',$isedit);
$smarty->assign('ISDELETE',$isdelete);


$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH", $image_path);
$smarty->assign("PRINT_URL", "phprint.php?jt=".session_id().$GLOBALS['request_string']);

if (isset($focus->name)) 
$smarty->assign("NAME", $focus->name);
else 
$smarty->assign("NAME", "");

global $detail_column_fields_value;

global $global_pick_list_values;

$blocks= getBlocks($currentModule,"detail_view",'',$focus->column_fields);

$smarty->assign("COLUMN_FIELDS_VALUE",ldcrm_json_encode($detail_column_fields_value));
$smarty->assign("BLOCKS", $blocks);
$smarty->assign("DETAILVIEWTITLE",getDetailViewTitleHtml($focus));
//放在getblock函数后面，否则会影响布局规则
//$fields=$focus->fieldobj->getFieldListArray();
//$smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));
//
$fields=$focus->fieldobj->getFieldListArray();
$smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));
$smarty->assign("MODULELINKFIELD",$focus->list_link_field);
$smarty->assign("SMOWNERCOLUMNNAME",$focus->getSmownerColumName());


$fieldobj=Field::getInstance($currentModule,$adb);

$smarty->assign("CUSTOMFIELD", $cust_fld);
$smarty->assign("ID", vtlib_purify($_REQUEST['record']));
//$salesorder_no = getModuleSequenceNumber($currentModule,vtlib_purify($_REQUEST['record']));
//$smarty->assign("SO_NO",$salesorder_no);
// Module Sequence Numbering
$mod_seq_field = $fieldobj->FieldInfoListByKeyValue('uitype',4);
if ($mod_seq_field != null) {
	$mod_seq_id = $focus->column_fields[$mod_seq_field['fieldname']];
} else {
	$mod_seq_id = $focus->id;
}
$smarty->assign('MOD_SEQ_ID', $mod_seq_id);
// END
$smarty->assign("ACCOUNTID",$focus->column_fields['account_id']);
$smarty->assign("SINGLE_MOD", $currentModule);
//$category = getParentTab();
//$smarty->assign("CATEGORY",$category);


/*当且仅当“上级合同”（'parentid'）显示，并且当前用户有“合同订单”创建权限的时候显示该按钮*/ 

if(isset($focus->column_fields['salesorder_id']) && $focus->column_fields['salesorder_id'] !=0)
{
    //echo $focus->column_fields['salesorder_id'];
    $smarty->assign('FORSHOW','yes');
}


$smarty->assign("CREATEPDF","permitted");


 



$smarty->assign("MODULE", $currentModule);
$smarty->assign("CONVERTMODE",'sotoinvoice');

$ProductDetailsHtml = crm_load_class_obj('cls_productDetailsHtml',"modules/$currentModule/ProductDetails",array($currentModule));
$smarty->assign('ASSOCIATED_PRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($focus,'details'));


$tabid = getTabid($currentModule);
$data = $fieldobj->split_validationdataArray();

$smarty->assign("VALIDATION_DATA_FIELDNAME",$data['fieldname']);
$smarty->assign("VALIDATION_DATA_FIELDDATATYPE",$data['datatype']);
$smarty->assign("VALIDATION_DATA_FIELDLABEL",$data['fieldlabel']);

if( $check_button['moduleSettings'] == 'yes'){
    $list_buttons_moreD['moduleSettings'] = getFixedLabel('LBL_PAGE_SET');
}
$is_rel_list=isPresentRelatedLists($currentModule);
$is_rel_list=Detail_Edit_View::setForeachRelatedLists($is_rel_list);

$smarty->assign("IS_REL_LIST",$is_rel_list);
$smarty->assign("SinglePane_View", $singlepane_view);

/*上一条和下一条数据信息*/
//审批中心上一条和下一条
//if(PerformancePrefs::getBoolean('DETAILVIEW_RECORD_NAVIGATION', true) && isset($_SESSION[$currentModule.'_listquery'])){
	//$recordNavigationInfo = ListViewSession::getListViewNavigation($focus->id);
//  
//	VT_detailViewNavigation($smarty,$recordNavigationInfo,$focus->id);
//}


$deployarray=getSys_deploy(1);
$deployvalue = $deployarray['deploy_value'];
$total = 0;
$total = $focus->column_fields['hdnGrandTotal'];
$smarty->assign('isADMIN',is_admin($current_user));




//$smarty->assign('QUICKACTIONLINK',$focus->logic->getActionUserd());
//$smarty->assign('ACTION_SHOW_NO',$focus->logic->getIsShowAction());
/* 关联创建 end */
$smarty->assign('DETAILVIEW_AJAX_EDIT', PerformancePrefs::getBoolean('DETAILVIEW_AJAX_EDIT', true));
/**
 * 更新操作
 * edit:diony
 * date:2015-01-08
 * reason:获取产品ID组合
 */ 
$productSql='select productid from ld_potentialsdetail where id = '.$_REQUEST['record'];
$productSqlResult=$adb->pquery($productSql,array());
if($adb->num_rows($productSqlResult))
{
    for($i=0;$i<$adb->num_rows($productSqlResult);$i++)
    {
        $productid=$adb->query_result($productSqlResult,$i,"productid");
        $productids .= $productid.',';
    }
    $smarty->assign('SENDSMSPRODUCTIDS',$productids);
        /**
     * 合同订单增加创建服务单按钮
     * by andy
     * 201415
     */
    $smarty->assign("PRODUCTID",$productid=$adb->query_result($productSqlResult,0,'productid'));
}


//获取客户和联系人区块信息
//$block_info = getBlockDisplayInfo('AccountContacts');
////显示位置
//$smarty->assign('DISPLAY_POSITION',$block_info['display_position']);
// //是否显示
//if($block_info['is_display'] == 0)
//    $smarty->assign('BESTATUS','YES');
//else
//    $smarty->assign('BESTATUS','NO');
$smarty->assign('ACCOUNTID',$focus->column_fields['account_id']);
$smarty->assign('CONTACTID',$focus->column_fields['contact_id']);
$smarty->assign('KISERROR',$_SESSION['kiserror']);
//获取版本类型
$version_info = getVersionInfo();
$smarty->assign('VERSIONINFO',$version_info);
//源美特殊控制
if($version_info['account'] == 'yuanmei'){
	$smarty->assign('ordertype_onclick',$focus->getOrdertypeByField());
}

$trade_jijin=getVersionTradeInfo();
$smarty->assign('TRADEJIJIN',$trade_jijin['trade']);
global $global_pick_list_depencyfield;
crm_load_class_file('lingdang_DependencyPicklist','modules/PickList');
$picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasource($currentModule);
//$smarty->assign("PICKIST_DEPENDENCY_DATASOURCE", ldcrm_json_encode($picklistDependencyDatasource));
//$smarty->assign("PICKLISTDEPENCYFIELDS", ldcrm_json_encode($global_pick_list_depencyfield));
include(globalStatic::$root_directory.'include/DetailViewBlockStatus.php');
$smarty->assign("PICKLISTCONTENT",ldcrm_json_encode($global_pick_list_values));

///保存判断
//$smarty->assign("VALIDATASAVE",ldcrm_json_encode(getValidataSave($currentModule)));
setGLobalURLSmarty($smarty);//设置js,css等访问路径
$smarty->assign('MODULEBILLNOTIP',$_SESSION[$currentModule.'_modulebillnotip']);
$_SESSION[$currentModule.'_modulebillnotip']='no';


//相关信息日期高级查询
//Crm_load_class_file("CommonView","modules/CustomView");
//$smarty->assign("DATETIMESTR",json_encode(CommonView::stdFilterDateTimeStr()));
//
$smarty->assign("ReferenceUitypes",cls_module_uitype::getAllUitypes());
$smarty->assign("UITYPEMODULES",cls_module_uitype::getUitypeModules());
DetailViewReturnWithProductDetail($currentModule,$focus,$ProductDetailsHtml,$smarty);
 //布局规则
// crm_load_class_file('cls_fieldrule','include/fields/fieldrule');
// $fieldruleobj=cls_fieldrule::getInstance($currentModule);
// $smarty->assign('jsonFieldRuleFieldNames',ldcrm_json_encode($fieldruleobj->getAllFieldNameSetChangeEvent()));//获取所有的触发字段
//    
//$smarty->display("DetailView/InventoryDetailRelated.tpl");

?>