<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $current_language, $currentModule, $theme,$current_user;
global $adb;

require('user_privileges/user_language_'.$current_user->id.'.php');
$focus = CRMEntity::getInstance($currentModule);
$smarty = new lingdangCRM_Smarty();

$category = getParentTab($currentModule);
$record = $_REQUEST['record'];
$ProductDetailsHtml = crm_load_class_obj('cls_productDetailsHtml',"modules/$currentModule/ProductDetails",array($currentModule));
$ProductDetailsData = crm_load_class_obj('cls_productDetailsData',"modules/$currentModule/ProductDetails",array($currentModule));
$isduplicate = vtlib_purify($_REQUEST['isDuplicate']);

//added to fix the issue4600
$searchurl = getBasic_Advance_SearchURL();
$smarty->assign("SEARCH", $searchurl);

//ls 20221101 Xuqiu1000213 服务回访单、销售退货单、采购退货单、销售退款单、采购退款单增加“新建”功能（采购退款单）
//选择源单，获取多个源单模块
$sourcemodules=getSourceModule($currentModule);
if(sizeof($sourcemodules)>0) {
    $smarty->assign('MODULE_ACTIVATE',true);
}
$smarty->assign('SOURCEMODULE',$sourcemodules);

if((isset($_REQUEST['fromid']) && $_REQUEST['fromid'] >0) )
{
    $entitytypeid = $_REQUEST['fromid'];
    foreach ($sourcemodules as $tmp => $sourcemoduleinfo) {
        if ($_REQUEST['frommodule'] == $sourcemoduleinfo['entitytype']) {
            $isfromsourcemodule = 'yes';
            break;
        }
    }
    if($isfromsourcemodule=='yes')
    {
        $_REQUEST['selectsourcename'] = $_REQUEST['frommodule'];

        $sourcefocus=CRMEntity::getInstance($_REQUEST['selectsourcename']);
        $sourcedetailtable=$sourcefocus->Detail_table;
        $productsql=" select lineitem_id from $sourcedetailtable where id=? ";
        $productresult=$adb->pquery($productsql,array($entitytypeid));
        for($i=0;$i<$adb->num_rows($productresult);$i++)
        {
            $_REQUEST['listval'].=$adb->query_result($productresult,$i,'lineitem_id').',';
        }
    }
}

//$convertmode=false;

if (isset ($_REQUEST['record']) && $_REQUEST['record'] != '') {
	$focus->id = $_REQUEST['record'];
	$focus->mode = 'edit';
	$focus->retrieve_entity_info($_REQUEST['record'], $currentModule);
    $smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($focus,'edit'));
}
if($focus->mode!='edit')//18554: 销售退货单>列表/明细：点击编辑按钮，结果：编辑界面，编号、合同订单、退货日期、客户名称都显示为空白。
    setObjectValuesFromRequest($focus);

$disp_view = getView($focus->mode);

if((isset ($_REQUEST['listval']) && $_REQUEST['listval'] != ""))
{
    $isSelectModule = $_REQUEST['selectsourcename'];
    $so_focus = CRMEntity::getInstance($isSelectModule);

    $so_focus->lineitemIds = rtrim($_REQUEST['listval'], ",");
    $so_focus->id=$_REQUEST['fromid'];
    $sourcedetailtable=$so_focus->Detail_table;
    $smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($so_focus,'sourcemodule_create'));
    $setListVal = count(explode(',',$so_focus->lineitemIds));
    //原单的单据名字
    $smarty->assign('LISTVAL_PURCHASEORDER_NO',getEditListValName($so_focus->lineitemIds,$isSelectModule));
    $lineitemids=implode(',',explode(',',rtrim($_REQUEST['listval'],',')));
    $query = " select id  from $sourcedetailtable where lineitem_id in ( ".$lineitemids." )";

    $result=$adb->pquery($query,array());
    $num_rows=$adb->num_rows($result);
    $entitytypeid = $adb->query_result($result,0,0);
    if($entitytypeid > 0){
        $so_focus->retrieve_entity_info($entitytypeid, $isSelectModule);
        crm_load_class_file('cls_ParentRelatedFields','include/RelatedFields');
        $cls_tabledetail_focus=cls_ParentRelatedFields::getInstance("$currentModule","$entitytypeid","");
        $data = $cls_tabledetail_focus->getData();

        foreach($data['related_list'] as $related_info){
            if(!empty($related_info['main'])){
                foreach($related_info['main'] as $relateds){
                    foreach($relateds as $rel_type => $rel_info){
                        if($rel_type == 'rawValue'){
                            $focus->column_fields[$rel_info['input_name']] = $rel_info['value'];
                        }
                    }
                }
            }
        }
    }
    //22703: 出库单编辑界面：删除原来的合同订单，重新选择一个合同订单保存，结果报错
    $smarty->assign("ID", $focus->id);
    $smarty->assign("RELATEDORDERIDSTRING", $_REQUEST['fromid']);//源单id
    $fieldinfo=$focus->getSourceFieldInfo();
    if($fieldinfo&&$fieldinfo->getFieldName()!='')
        $focus->column_fields[$fieldinfo->getFieldName()]=$_REQUEST['fromid'];//关联创建原单
}
else{
    if($focus->mode == 'edit'){
        $setListVal = 1;
        //原单的单据名字
        //$smarty->assign('LISTVAL_PURCHASEORDER_NO',getDetailListValName($focus->id,$isSelectModule,2));
    }
    if(isset($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true'){
        $focus->id = $_REQUEST['record'];
        $focus->mode = 'edit';
    }
    if($_REQUEST['isDuplicate'] == 'true'){
        $smarty->assign("ID", '');
    }else{
        $smarty->assign("ID", $focus->id);
    }
    if($focus->id > 0){
        $smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($focus,'edit'));
    }else{
        $smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($focus,'create'));
    }
}
if(isset($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true') {//复制
    $smarty->assign("DUPLICATE_FROM", $focus->id);
    $focus->id = "";
    $focus->mode = '';
}

/**
 * @by andy
 * @date 20140729
 * @reason 系统编号改进
 */ 
$isallow= $focus->Library('SystemCode')->getModentityfield('isallow',$currentModule);
$smarty->assign('ISALLOW',$isallow);

/**
 * 创建单据时，编号为自动生成后的编号
 * @project 创建单据时，自动生成编号
 * @author Tujt 2014-05-13
 */
if($focus->mode!='edit'){
	$value = $focus->Library('SystemCode')->getModuleSeqNumRecord($_REQUEST['module']);
	if(!$value) $value = getFixedLabel('MSG_AUTO_GEN_ON_SAVE');
	$focus->column_fields['purchasecashback_no'] = $value;
}
if(isset($_REQUEST['fromid']) && $_REQUEST['fromid'])
	$smarty->assign('ENTITYTYPEID', $_REQUEST['fromid']);
else
	$smarty->assign('ENTITYTYPEID', $focus->column_fields['purchaseback_id']);

/* 关联创建单据统一处理方法 begin */
if(isset($_REQUEST['parent_id']) && $_REQUEST['parent_id'] > 0){
	$focus->getModuleLogic($currentModule)->setQuickCreateColumn($_REQUEST['parent_module'],$_REQUEST['parent_id']);
}
if(isset($_REQUEST['fromid']) && $_REQUEST['fromid'] > 0){
	$focus->getModuleLogic($currentModule)->setQuickCreateColumnValues($currentModule,$_REQUEST['fromid']);
}
/* 关联创建单据统一处理方法 end */

    
$smarty->assign('OP_MODE',$disp_view);
$smarty->assign('APP', $app_strings);
$smarty->assign('MOD', $mod_strings);
$smarty->assign('ISADMIN',$current_user->is_admin);
$smarty->assign('MODULE', $currentModule);
/*---仓库信息---*/
crm_load_function_file('selWareAll','include/Stock','CommonStock');
$wareresult = selWareAll();
for($i = 0; $i<$adb->num_rows($wareresult); $i++)
{
    $wareArray[$adb->query_result($wareresult, $i, "id")] = $adb->query_result($wareresult, $i, "name");
}
$smarty->assign("WAREALL", $wareArray);
// TODO: Update Single Module Instance name here.
$smarty->assign('SINGLE_MOD', 'SINGLE_'.$currentModule);
$smarty->assign('CATEGORY', $category);
$smarty->assign("THEME", $theme);
$smarty->assign('IMAGE_PATH', "themes/$theme/images/");
$smarty->assign('ID', $focus->id);
$smarty->assign('MODE', $focus->mode);
$smarty->assign('CREATEMODE', vtlib_purify($_REQUEST['createmode']));

//$smarty->assign('CHECK', Button_Check($currentModule));
$smarty->assign('DUPLICATE', $isduplicate);


if(isset($_REQUEST['return_module']))    $smarty->assign("RETURN_MODULE", vtlib_purify($_REQUEST['return_module']));
if(isset($_REQUEST['return_action']))    $smarty->assign("RETURN_ACTION", vtlib_purify($_REQUEST['return_action']));
if(isset($_REQUEST['return_id']))        $smarty->assign("RETURN_ID", vtlib_purify($_REQUEST['return_id']));
if (isset($_REQUEST['return_viewname'])) $smarty->assign("RETURN_VIEWNAME", vtlib_purify($_REQUEST['return_viewname']));
if(isset($_REQUEST['SearchScope'])) $smarty->assign("SEARCHSCOPE",$_REQUEST['SearchScope']);
// Field Validation Information
$tabid = getTabid($currentModule);
$validationArray =$focus->fieldobj->split_validationdataArray();

$smarty->assign("VALIDATION_DATA_FIELDNAME",$validationArray['fieldname']);
$smarty->assign("VALIDATION_DATA_FIELDDATATYPE",$validationArray['datatype']);
$smarty->assign("VALIDATION_DATA_FIELDLABEL",$validationArray['fieldlabel']);

// In case you have a date field
$smarty->assign("CALENDAR_LANG", $app_strings['LBL_JSCALENDAR_LANG']);
$smarty->assign("CALENDAR_DATEFORMAT", 'YYYY-mm-dd');
global $global_pick_list_depencyfield;
crm_load_class_file("lingdang_DependencyPicklist",'modules/PickList');
$picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasource($currentModule);
$smarty->assign("PICKIST_DEPENDENCY_DATASOURCE", ldcrm_json_encode($picklistDependencyDatasource));
$smarty->assign("PICKLISTDEPENCYFIELDS", ldcrm_json_encode($global_pick_list_depencyfield));
/*
edit:can
date:20130530
reason:创建和编辑权限分开
*/
if( (isset($_REQUEST['Create'])&&($_REQUEST['Create']=='true' || $_REQUEST['Create']=='yes')) ||$_REQUEST['isDuplicate']=='true'){
	$smarty->assign('CREATE','true');
}else{
	$smarty->assign('CREATE','false');
}
/*if (isset ($_REQUEST['record']) && $_REQUEST['record'] != '') {
    $focus->id = $_REQUEST['record'];
	$smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($focus,'edit'));
	$smarty->assign("MODE", $focus->mode);
    
    $sql = "select a.purchasebackid,a.purchaseback_no,b.vendorname,b.vendorid from ld_purchaseback a,ld_vendor b,ld_purchasecashback c 
    where a.vendorid = b.vendorid and c.purchaseback_id = a.purchasebackid and c.purchasecashbackid = $focus->id";
    $result=$adb->pquery($sql);
    $smarty->assign("PURCHASEBACKID", $adb->query_result($result,0,"purchasebackid"));
    $smarty->assign("PURCHASEBACKNO", $adb->query_result($result,0,"purchaseback_no"));
    $smarty->assign("VENDORNAME", $adb->query_result($result,0,"vendorname"));
    $smarty->assign("VENDORID", $adb->query_result($result,0,"vendorid"));
}*/
/*if(isset($_REQUEST['frommodule'])&&$_REQUEST['frommodule']=='PurchaseBack'&&isset($_REQUEST['fromid'])&&!empty($_REQUEST['fromid'])){
    $_REQUEST['purchaseback_id'] = $_REQUEST['fromid'];
}
if (isset($_REQUEST['purchaseback_id']))
{
	$purchaseback_id=$_REQUEST['purchaseback_id'];
	$lineitemid = getLineitemId($purchaseback_id,"PurchaseBack");
    require_once('modules/PurchaseBack/PurchaseBack.php');
    
    $sql = "select a.purchaseback_no,b.vendorname,b.vendorid from ld_purchaseback a,ld_vendor b where a.vendorid = b.vendorid and a.purchasebackid = $purchaseback_id";
    $result=$adb->pquery($sql);
    $smarty->assign("PURCHASEBACKID", $purchaseback_id);
    $smarty->assign("PURCHASEBACKNO", $adb->query_result($result,0,"purchaseback_no"));
    $smarty->assign("VENDORNAME", $adb->query_result($result,0,"vendorname"));
    $smarty->assign("VENDORID", $adb->query_result($result,0,"vendorid"));
    
   	$soid = $purchaseback_id;
    $so_focus = CRMEntity::getInstance('PurchaseBack');
    $so_focus->lineitemIds = $lineitemid;
	$so_focus->mode = 'edit';
    $so_focus->retrieve_entity_info($soid, "PurchaseBack");
    $focus->column_fields['currency_id']=$so_focus->column_fields['currency_id'];
	$smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($so_focus,'module_create'));
}*/
$productFields['fields']=$ProductDetailsData->moduleProductToolField;
$smarty->assign('PRODUCTFIELDSINFOJSON',ldcrm_json_encode($productFields));
$smarty->assign('BASECOLUMN',$ProductDetailsData->module_productbasefield);
global $global_pick_list_values,$edit_column_fields_value;
$act_data=getBlocks($currentModule, $disp_view, $focus->mode, $focus->column_fields);
$smarty->assign("COLUMN_FIELDS_VALUE",ldcrm_json_encode($edit_column_fields_value));

/**
* 更新操作
* edit:can
* date:20131223
* reason:添加富文本框
* */
if(isset($act_data['RichText']) && !empty($act_data['RichText'])){
	$richText=$act_data['RichText'];
	unset($act_data['RichText']);
	$smarty->assign('RICHTEXTBOX',implode(',',$richText));
	$smarty->assign('RICHTEXTCOUNT',sizeof($richText));
}else{
	$smarty->assign('RICHTEXTBOX','');
	$smarty->assign('RICHTEXTCOUNT','0');
}
$smarty->assign('BLOCKS', $act_data);
if($focus->mode == 'edit' || $isduplicate) {

	$recordName = $focus->column_fields[$focus->list_link_field];
	$smarty->assign('NAME', $recordName);
}
/**
 * 
 * @param
 * @return
 * @author Tujt
 */
function getPurchaseBackEntitytypeid($record) {
    global $adb;
	$query = 'SELECT entitytypeid FROM ld_purchasebackdetail WHERE id = ? limit 1';
	$result = $adb->pquery($query,array($record));
	return $adb->query_result($result,0,0);
}
/**
 * 编辑、创建页面，增加更多信息左边栏
 * @author Tujt 2014-04-11
 */
$relmodule = (isset($currentModule))?$currentModule:$_REQUEST['module'];
$smarty->assign("IS_REL_LIST",isPresentRelatedLists($relmodule));
//$smarty->display("DetailView/InventoryEditView.tpl");
$fields=$focus->fieldobj->getFieldListArray();
$fields['module']=$currentModule;
$smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));
$smarty->assign("MODULELINKFIELD",$focus->list_link_field);
$smarty->assign("SMOWNERCOLUMNNAME",$focus->getSmownerColumName());
$smarty->assign("PICKLISTCONTENT",ldcrm_json_encode($global_pick_list_values));
///保存判断
$smarty->assign("VALIDATASAVE",ldcrm_json_encode(getValidataSave($currentModule)));
//明细字段
$smarty->assign("TABDETAILFIELDS",ldcrm_json_encode($ProductDetailsHtml->ProductDetailsData->productToolFields->getFieldListArray()));
setGLobalURLSmarty($smarty);//设置js,css等访问路径


//相关信息日期高级查询
//Crm_load_class_file("CommonView","modules/CustomView");
//$smarty->assign("DATETIMESTR",json_encode(CommonView::stdFilterDateTimeStr()));

$smarty->assign("ReferenceUitypes",cls_module_uitype::getAllUitypes());
$smarty->assign("UITYPEMODULES",cls_module_uitype::getUitypeModules());

 //布局规则
crm_load_class_file('cls_fieldrule','include/fields/fieldrule');
$fieldruleobj=cls_fieldrule::getInstance($currentModule);
$smarty->assign('jsonFieldRuleFieldNames',ldcrm_json_encode($fieldruleobj->getAllFieldNameSetChangeEvent()));//获取所有的触发字段
//editor:gyq_161 reason:带分录模块弹出层   2019/11/20 11:48
/*if($focus->mode == 'edit')
	$smarty->display("DetailView/InventoryEditView.tpl");
else
	$smarty->display('DetailView/InventoryCreateView.tpl');*/
$arr = $ProductDetailsHtml->detailPopup($smarty,$fields,$productFields,$data);
ConvertTojsonString(1,$arr,"success");
?>