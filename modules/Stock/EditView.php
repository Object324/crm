<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
require_once ('include/Stock/CommonStock.php');
global  $theme, $currentModule, $current_user, $adb;
$languageType= getLanguageType($current_user);
$focus = CRMEntity::getInstance($currentModule);
$smarty = new lingdangCRM_Smarty();
$purchaseorder_id = 0;
$searchurl = getBasic_Advance_SearchURL();
$smarty->assign("SEARCH", $searchurl);

$setListVal = 0;

//checkWarehouseUser();//判断仓库权限 tujt 2014-11-12
if(empty($_REQUEST['record']) && $focus->mode != 'edit')
{
	setObjectValuesFromRequest($focus);
}


//选择源单，获取多个源单模块
$sourcemodules=getSourceModule($currentModule);
if(is_array($sourcemodules) && sizeof($sourcemodules)>0)
{
    $smarty->assign('MODULE_ACTIVATE',true);
}
$smarty->assign('SOURCEMODULE',$sourcemodules);
$arr_sourcemodules=array();
foreach($sourcemodules as $val){
    if($val['default'] == 1){
        $isSelectModule = $val['entitytype'];
    }
    $arr_sourcemodules[]= $val['entitytype'];
}
if(empty($selectSourceModuleName)){
	$selectSourceModuleName = $sourcemodules[0]['entitytype'];
}
/*
采购订单  新增入库单
*/
if(isset($_REQUEST['fromid'])&&in_array($_REQUEST['frommodule'],$arr_sourcemodules))
{

    $purchaseorderid = $_REQUEST['fromid'];
    $so_focus=CRMEntity::getInstance($_REQUEST['frommodule']);
   $detailtable=$so_focus->Detail_table;
    $productsql=" select lineitem_id from $detailtable where id=?";
    $productresult=$adb->pquery($productsql,array($purchaseorderid));
    for($i=0;$i<$adb->num_rows($productresult);$i++)
    {
        $_REQUEST['listval'].=$adb->query_result($productresult,$i,'lineitem_id').',';
    }
	$from_module = $_REQUEST['frommodule'];
	$_REQUEST['selectsourcename'] = $from_module;
	$so_focus = CRMEntity::getInstance($from_module);
    $so_focus->id = $purchaseorderid;
    $so_focus->retrieve_entity_info($purchaseorderid, $from_module);
	if($from_module == 'PurchaseOrder')
		$focus->column_fields['vendor_id'] = $so_focus->column_fields['vendor_id'];
	else
		$focus->column_fields['vendor_id'] = $purchaseorderid;
}
if (isset ($_REQUEST['record']) && $_REQUEST['record'] != '')
{
    crm_load_class_file("Detail_Edit_View",'include/utils');
    $isSelectModule = Detail_Edit_View::getInventoryField('entitytype',$_REQUEST['record']);
  
	if(isset($_REQUEST['convertmode']) && $_REQUEST['convertmode'] == 'update_quote_val'){
	} else {
		$focus->id = $_REQUEST['record'];
		$focus->mode = 'edit';
		$focus->retrieve_entity_info($_REQUEST['record'], "Stock");
         
        $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey('columnname',$focus->getSmownerColumName());
         if($focus->column_fields[$fieldinfo->getFieldName()]!=$current_user->id)
         {
          
                crm_load_class_file('cls_CurUserDataScope','include/ListView');
                $datascopeobj=cls_CurUserDataScope::getInstance($currentModule,'record');
                $datascopeobj->isMyViewData($_REQUEST['record']);
         } 
		$focus->name=$focus->column_fields[$focus->list_link_field];
        //require_once('modules/Approve/Approve.php');
        //$approve=new Approve();
		$approve = Approve::getInstance($currentModule);
        /*if(isset($_REQUEST['ajax']) && $_REQUEST['ajax']==true){
            echo $approve->EditBlocks($focus->column_fields['assigned_user_id'],$focus->id);
            exit();
        }   */
        
         if($_REQUEST['isDuplicate'] != 'true')
        {
            //判断是否已批准（是否允许编辑)
           $retapproveinfo= $focus->getModuleLogic($currentModule)->checkEditInfo($currentModule,$_REQUEST['record']);
          
           if($retapproveinfo!='SUCCESS')
           {
             $_REQUEST['diony']='yes';
             ConvertTojsonString("-1",array(),$retapproveinfo);
           }
            
        } 
	}
}
if (isset ($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true')
{
	$smarty->assign("DUPLICATE_FROM", $focus->id);
    $smarty->assign('LISTVAL_PURCHASEORDER_NO',getDetailListValName($focus->id,$isSelectModule,2));
	$focus->id = "";
	$focus->mode = '';
	/**
	 * 复制时，负责人设置为自己
	 * @author Tujt 2015-07-20
	 */
//	$focus->column_fields['assigned_user_id'] = $current_user->id;
}

if (isset ($_REQUEST['product_id']) && $_REQUEST['product_id'] != ''){
	$focus->column_fields['product_id'] = $_REQUEST['product_id'];
    $productdetailhtml_focus=$focus;
    $productdetail_mode='product_create';
	//$smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($focus,'product_create'));
}

$theme_path = "themes/" . $theme . "/";
$image_path = $theme_path . "images/";
$disp_view = getView($focus->mode);
$mode = $focus->mode;
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
	$focus->column_fields['ware_stock_no'] = $value;
}

/* 关联创建单据统一处理方法 begin */
if(isset($_REQUEST['parent_id']) && $_REQUEST['parent_id'] > 0){
	$focus->getModuleLogic($currentModule)->setQuickCreateColumn($_REQUEST['parent_module'],$_REQUEST['parent_id']);
}
if(isset($_REQUEST['fromid']) && $_REQUEST['fromid'] > 0){
	$focus->getModuleLogic($currentModule)->setQuickCreateColumnValues($currentModule,$_REQUEST['fromid']);
}
/* 关联创建单据统一处理方法 end */

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
$smarty->assign("OP_MODE", $disp_view);
$smarty->assign("MODULE", $currentModule);
$smarty->assign("SINGLE_MOD", 'Stock');
$smarty->assign("MOD", $mod_strings);
$smarty->assign("APP", $app_strings);
$category = getParentTab();
$smarty->assign("CATEGORY", $category);
$deployarray=getSys_deploy(10);
$smarty->assign('PERODUCTDEPLOY',$deployarray['deploy_value']);
$smarty->assign('ISADMIN',$current_user->is_admin);
if (isset ($focus->name))
	$smarty->assign("NAME", $focus->name);
else
	$smarty->assign("NAME", "");

 if((isset ($_REQUEST['listval']) && $_REQUEST['listval'] != ""))
{
    $isSelectModule = $_REQUEST['selectsourcename'];  
	$so_focus = CRMEntity::getInstance($isSelectModule);
    $so_focus->lineitemIds = rtrim($_REQUEST['listval'], ",");
    $so_focus->id=$_REQUEST['fromid'];
      $productdetailhtml_focus=$so_focus;
      $productdetail_mode='sourcemodule_create';
	//$smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($so_focus,'sourcemodule_create'));
    //$smarty->assign("ALLPRODUCT",getProductLineItemId(rtrim($_REQUEST['listval'], ",")));
    $setListVal = count(explode(',',$so_focus->lineitemIds));
    $detailtable=$so_focus->Detail_table;
	$query = "select id,lineitem_id from $detailtable where lineitem_id in ($so_focus->lineitemIds)";
	$result = $adb->pquery($query,array());
	$num_rows = $adb->num_rows($result);
   
    if($num_rows >= 1){
		$entitytypeid = $adb->query_result($result,0,'id');//源单id
		//获取选择源单关联带出值(客户)
		if($entitytypeid > 0){
			crm_load_class_file('cls_ParentRelatedFields','include/RelatedFields');
			$cls_tabledetail_focus=cls_ParentRelatedFields::getInstance("Stock","$entitytypeid","");
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
	}
	//原单的单据名字
    $smarty->assign("ID", $focus->id);//编辑界面选择源单要给ID赋值，不然保存错误
    $smarty->assign('LISTVAL_PURCHASEORDER_NO',getEditListValName($so_focus->lineitemIds,$isSelectModule));
    $fieldinfo=$focus->getSourceFieldInfo();//获取原单字段信息
    if($fieldinfo&&$fieldinfo->getFieldName()!='')
        $focus->column_fields[$fieldinfo->getFieldName()]=$_REQUEST['fromid'];//关联创建原单
    
}
else{
	if ($focus->mode == 'edit'){
		$setListVal = 1;
		$smarty->assign('LISTVAL_PURCHASEORDER_NO',getDetailListValName($focus->id,$isSelectModule,2));
	}elseif (isset ($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true'){
		$focus->id = $_REQUEST['record'];
		$focus->mode = 'edit';
	}
	if($_REQUEST['isDuplicate'] == 'true'){
		$smarty->assign("ID", '');
	}else{
		$smarty->assign("ID", $focus->id);
	}
	if($focus->id > 0){
	    $productdetailhtml_focus=$focus;
        $productdetail_mode='edit';
	//	$smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($focus,'edit'));
	}else{
	   $productdetailhtml_focus=$focus;
        $productdetail_mode='create';
		//$smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($focus,'create'));
	}
	
}
if(isset($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true') {
	$smarty->assign("DUPLICATE_FROM", $focus->id);
    crm_load_function_file("getInventoryCurrencyInfo",'include/utils',"InventoryUtils");
    $inventory_cur_info = getInventoryCurrencyInfo($currentModule, $focus->id);
	$focus->id = "";
    $focus->mode = '';
}
$smarty->assign("MODE", $focus->mode);
if (isset ($cust_fld)){
	$smarty->assign("CUSTOMFIELD", $cust_fld);
}

if (isset ($_REQUEST['return_module']) && !isset($_REQUEST['parent_id']))
	$smarty->assign("RETURN_MODULE", vtlib_purify($_REQUEST['return_module']));
else
	$smarty->assign("RETURN_MODULE", "Stock");
if (isset ($_REQUEST['return_action']))
	$smarty->assign("RETURN_ACTION", vtlib_purify($_REQUEST['return_action']));
else
	$smarty->assign("RETURN_ACTION", "index");
if (isset ($_REQUEST['return_id']))
	$smarty->assign("RETURN_ID", vtlib_purify($_REQUEST['return_id']));
if (isset ($_REQUEST['return_viewname']))
	$smarty->assign("RETURN_VIEWNAME", vtlib_purify($_REQUEST['return_viewname']));
$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH", $image_path);
$smarty->assign("MODULE", "Stock");
$smarty->assign("PRINT_URL", "phprint.php?jt=" . session_id() . $GLOBALS['request_string']);
$data =$focus->fieldobj->split_validationdataArray();

$versiontrade=getVersionTradeInfo();
$smarty->assign('TRADEJIJIN',$versiontrade['trade']);
$productFields['trade']=$versiontrade['trade'];
$productFields['lengthprice'] = $systemmethod['lengthprice'];
$productFields['SystemArgument'] = $systemmethod['SystemArgument'];
$productFields['addproductrow'] = $systemmethod['addproductrow'];
$productFields['source_other_products'] = $deployarray['deploy_value'];

$smarty->assign('PRODUCTFIELDSINFOJSON',ldcrm_json_encode($productFields));

$smarty->assign("VALIDATION_DATA_FIELDNAME", $data['fieldname']);
$smarty->assign("VALIDATION_DATA_FIELDDATATYPE", $data['datatype']);
$smarty->assign("VALIDATION_DATA_FIELDLABEL", $data['fieldlabel']);
/*---仓库信息---*/
$wareresult = selWareAll($current_user->id);
$tmprows=$adb->num_rows($wareresult);
if($tmprows<=0)
{
    ConvertTojsonString(-1,[],getFixedLabel('INSUFFICIENTWAREHOUSE'));
}
for($i = 0; $i<$adb->num_rows($wareresult); $i++)
{
    $wareArray[$adb->query_result($wareresult, $i, "id")] = $adb->query_result($wareresult, $i, "name");
}
$smarty->assign('LISTALLVAL',$setListVal);
$smarty->assign('SELECTSOURCENAME',$isSelectModule);
$smarty->assign('ISSOURCEMODULE',$isSelectModule);
$smarty->assign("WAREALL", $wareArray);
$smarty->assign('LISTALLVAL',$setListVal);
$smarty->assign("DUPLICATE",vtlib_purify($_REQUEST['isDuplicate']));
$smarty->assign('CREATEMODE', vtlib_purify($_REQUEST['createmode']));
global $edit_column_fields_value;


global $global_pick_list_values;
$act_data=getBlocks($currentModule, $disp_view, $mode, $focus->column_fields);
$smarty->assign("BLOCKS",$act_data);
$smarty->assign("COLUMN_FIELDS_VALUE",ldcrm_json_encode($edit_column_fields_value));
global $global_pick_list_depencyfield;
crm_load_class_file("lingdang_DependencyPicklist",'modules/PickList');

$picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasource($currentModule);
$smarty->assign("PICKIST_DEPENDENCY_DATASOURCE", ldcrm_json_encode($picklistDependencyDatasource));
$smarty->assign("PICKLISTDEPENCYFIELDS", ldcrm_json_encode($global_pick_list_depencyfield));

$ProductDetailsHtml = crm_load_class_obj('cls_productDetailsHtml',"modules/$currentModule/ProductDetails",array($currentModule));
$ProductDetailsData = crm_load_class_obj('cls_productDetailsData',"modules/$currentModule/ProductDetails",array($currentModule));
$productFields['fields']=$ProductDetailsData->moduleProductToolField;
$productFields['system_deploy']=$ProductDetailsData->system_deploy_formulas;
$systemmethod = $ProductDetailsData->getSystemMethod();
$productFields['lengthprice'] = $systemmethod['lengthprice'];
$productFields['SystemArgument'] = $systemmethod['SystemArgument'];
$productFields['addproductrow'] = $systemmethod['addproductrow'];
$productFields['source_other_products'] = $deployarray['deploy_value'];
$smarty->assign('PRODUCTFIELDSINFOJSON',ldcrm_json_encode($productFields));
//计算公式中基准字段
$smarty->assign('BASECOLUMN',$ProductDetailsData->module_productbasefield);
//产品关联创建 
if($_REQUEST['frommodule']=='Products'&&$_REQUEST['fromid']>0)
{
    $_REQUEST['product_id']=$_REQUEST['fromid'];
}
if (isset ($_REQUEST['product_id']) && $_REQUEST['product_id'] != ''){
	$focus->column_fields['product_id'] = $_REQUEST['product_id'];
    //edit:can 2020-11-23 43366: (61mis.com/kfbcrm)工具-产品管理-详情-相关信息-报价单（需要补丁）；在产品详情的相关信息中创建报价单，分录中没有带入产品信息
   $ProductDetailsHtml->tablecontents=[];
    $productdetail_mode = 'product_create';
    $productdetailhtml_focus = $focus;
	//$smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($focus,'product_create'));
   
}
 //复制,产品明细丢失
 if (isset ($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true') {
 

    $productdetailhtml_focus->id=$_REQUEST['record'];
    $productdetailhtml_focus->mode='edit';
}

$smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($productdetailhtml_focus,$productdetail_mode));
/*
edit:can
date:20130530
reason:创建和编辑权限分开
*/
if( (isset($_REQUEST['Create'])&&($_REQUEST['Create']=='true' || $_REQUEST['Create']=='yes')) ||$_REQUEST['isDuplicate']=='true'){
	$smarty->assign('CREATE','true');
}
else{
	$smarty->assign('CREATE','false');
}
/**
 * 编辑、创建页面，增加更多信息左边栏
 * @author Tujt 2014-04-17
 */
$relmodule = (isset($currentModule))?$currentModule:$_REQUEST['module'];
$smarty->assign("IS_REL_LIST",isPresentRelatedLists($relmodule));
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
$smarty->assign('FROMID',$_REQUEST['fromid']);

//相关信息日期高级查询
//Crm_load_class_file("CommonView","modules/CustomView");
//$smarty->assign("DATETIMESTR",json_encode(CommonView::stdFilterDateTimeStr()));
//
$smarty->assign("ReferenceUitypes",cls_module_uitype::getAllUitypes());
$smarty->assign("UITYPEMODULES",cls_module_uitype::getUitypeModules());


 //布局规则
crm_load_class_file('cls_fieldrule','include/fields/fieldrule');
$fieldruleobj=cls_fieldrule::getInstance($currentModule);
$smarty->assign('jsonFieldRuleFieldNames',ldcrm_json_encode($fieldruleobj->getAllFieldNameSetChangeEvent()));//获取所有的触发字段
//editor:gyq_161 reason:带分录模块弹出层   2019/11/19 15:45
/*if($focus->mode == 'edit')
	$smarty->display("DetailView/InventoryEditView.tpl");
else
	$smarty->display('DetailView/InventoryCreateView.tpl');*/

$arr = $ProductDetailsHtml->detailPopup($smarty,$fields,$productFields,$data);
ConvertTojsonString(1,$arr,"success");

?>