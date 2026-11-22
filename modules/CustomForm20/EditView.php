<?php
//zkt 20231012 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
$setListVal = 0;
global $currentModule,  $current_user;
require('user_privileges/user_language_'.$current_user->id.'.php');
$focus = CRMEntity::getInstance($currentModule);
$smarty = new lingdangCRM_Smarty();
//added to fix the issue4600
$searchurl = getBasic_Advance_SearchURL();
$smarty->assign("SEARCH", $searchurl);
$ProductDetailsHtml = crm_load_class_obj('cls_productDetailsHtml',"modules/$currentModule/ProductDetails",array($currentModule));
$ProductDetailsData = crm_load_class_obj('cls_productDetailsData',"modules/$currentModule/ProductDetails",array($currentModule));

if(isset($_REQUEST['duplicate_from'])&&$_REQUEST['duplicate_from']!='')
{
    $_REQUEST['isDuplicate']='true';
    $_REQUEST['record']=$_REQUEST['duplicate_from'];
}

$issourcemodulecreate='no';//�Ƿ�ΪԴ����������
$sourcemodules=getSourceModule($currentModule);

 foreach($sourcemodules as $index=>$sourceinfo)
 {
        if($_REQUEST['frommodule']==$sourceinfo['entitytype'])
        {
                $issourcemodulecreate='yes';
                break;
        }
 }
if(sizeof($sourcemodules)>0)
{
    $smarty->assign('MODULE_ACTIVATE',true);
}
$smarty->assign('SOURCEMODULE',$sourcemodules);
$arr_sourcemodules=array();
foreach($sourcemodules as $val){
    if($val['default'] == 1){
        $isSelectModule = $val['entitytype'];
    }
    $arr_sourcemodules[]=$val['entitytype'];
}
if(empty($selectSourceModuleName)){
	$selectSourceModuleName = $sourcemodules[0]['entitytype'];
}
$potentialdeployarray=getSys_deploy(205);//设置销售机会是否显示产品分录明细:0是，1否
$deploy_value=$potentialdeployarray['deploy_value'];
$smarty->assign('DEPLOY_VALUE_205',$deploy_value);

if (isset ($_REQUEST['record']) && $_REQUEST['record'] != '') {
    crm_load_class_file("Detail_Edit_View",'include/utils');
    $isSelectModule = Detail_Edit_View::getInventoryField('entitytype',$_REQUEST['record']);
    if (isset ($_REQUEST['convertmode']) && $_REQUEST['convertmode'] == 'potentoinvoice') {
		$focus->mode = '';
	}
	elseif (isset ($_REQUEST['convertmode']) && $_REQUEST['convertmode'] == 'update_so_val') {
		//Updating the Selected SO Value in Edit Mode
		foreach ($focus->column_fields as $fieldname => $val) {
			if (isset ($_REQUEST[$fieldname])) {
				$value = $_REQUEST[$fieldname];
				$focus->column_fields[$fieldname] = $value;
			}

		}
		//Handling for dateformat in lingdang_invoicedate ld_field
		if ($focus->column_fields['invoicedate'] != '') {
			$curr_due_date = $focus->column_fields['invoicedate'];
			$focus->column_fields['invoicedate'] = DateTimeField::convertToDBFormat($curr_due_date);
		}

		$soid = $focus->column_fields['salesorder_id'];
		$so_focus =CRMEntity::getInstance('SalesOrder');
		$so_focus->id = $soid;
		$so_focus->retrieve_entity_info($soid, "SalesOrder");
		$focus = getConvertSoToInvoice($focus, $so_focus, $soid);
		$focus->id = $_REQUEST['record'];
		$focus->mode = 'edit';
		$focus->name=$focus->column_fields[$focus->list_link_field];
        $focus->column_fields['account_id']= $so_focus->column_fields['account_id'];
	} else {
	  
		$focus->id = $_REQUEST['record'];
		$focus->mode = 'edit';
		$focus->retrieve_entity_info($_REQUEST['record'], $currentModule);
        $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey('columnname',$focus->getSmownerColumName());
        if($focus->column_fields[$fieldinfo->getFieldName()]!=$current_user->id)
        {
            crm_load_class_file('cls_CurUserDataScope','include/ListView');
            $datascopeobj=cls_CurUserDataScope::getInstance($currentModule,'record');
            $datascopeobj->isMyViewData($_REQUEST['record']);
        }
		$focus->name=$focus->column_fields[$focus->list_link_field];
       // require_once('modules/Approve/Approve.php');
        //$approve=new Approve();
		$approve = Approve::getInstance($currentModule);
        if(isset($_REQUEST['ajax']) && $_REQUEST['ajax']==true){
            echo $approve->EditBlocks($focus->column_fields['assigned_user_id'],$focus->id);
            exit();
        }
        
	}
	$smarty->assign("ACCOUNTID",$focus->column_fields['account_id']);
} else {
	if ((isset ($_REQUEST['convertmode']) && $_REQUEST['convertmode'] == 'update_so_val')||(isset ($_REQUEST['return_module']) && $_REQUEST['return_module'] == 'SalesOrder')) {
		//Updating the Selected SO Value in Create Mode
		foreach ($focus->column_fields as $fieldname => $val) {
			if (isset ($_REQUEST[$fieldname])) {
				$value = $_REQUEST[$fieldname];
				$focus->column_fields[$fieldname] = $value;
			}

		}
		//Handling for dateformat in lingdang_invoicedate ld_field
		if ($focus->column_fields['invoicedate'] != '') {
			$curr_due_date = $focus->column_fields['invoicedate'];
			$focus->column_fields['invoicedate'] = DateTimeField::convertToDBFormat($curr_due_date);
		}

		$soid = $focus->column_fields['salesorder_id'];
		$so_focus =CRMEntity::getInstance('SalesOrder');
		$so_focus->id = $soid;
		$so_focus->retrieve_entity_info($soid, "SalesOrder");
		$focus = getConvertSoToInvoice($focus, $so_focus, $soid);

        $focus->column_fields['account_id']= $so_focus->column_fields['account_id'];
		//Added to display the SO's associated products -- when we select SO in New Invoice page
		if (isset ($_REQUEST['salesorder_id']) && $_REQUEST['salesorder_id'] != '') {
            $smarty->assign('LISTVAL_PURCHASEORDER_NO',getModuleHref('SalesOrder',$_REQUEST['salesorder_id'])); 
		}

		$smarty->assign("SALESORDER_ID", $focus->column_fields['salesorder_id']);
		$smarty->assign("ASSOCIATEDPRODUCTS", $associated_prod);
		$smarty->assign("MODE", $so_focus->mode);
	}
}
if(empty($_REQUEST['record']) && $focus->mode != 'edit'){
	setObjectValuesFromRequest($focus);
}

if(isset ($_REQUEST['convertmode']) && $_REQUEST['convertmode'] == 'sotoinvoice')
{
	
	$focus->column_fields['subject']='';
}
if (isset ($_REQUEST['opportunity_id']) && $_REQUEST['opportunity_id'] != '') {
	$potfocus =CRMEntity::getInstance('Potentials');
	$potfocus->column_fields['potential_id'] = $_REQUEST['opportunity_id'];
}

if((isset($_REQUEST['servicecontractsid'])&&$_REQUEST['servicecontractsid']!=''&&$_REQUEST['servicecontractsid']!='0') || !empty($_REQUEST['report_sourceid']))//�����ͬ�����տ
{
    $_REQUEST['selectsourcename']='ServiceContracts';
	if(!empty($_REQUEST['parent_id'])){
		$id = $_REQUEST['parent_id'];
	}else if(!empty($_REQUEST['report_sourceid'])){
		$id = $_REQUEST['report_sourceid'];
	}
	if(!empty($_REQUEST['report_sourcemodule'])){
		$_REQUEST['selectsourcename'] = $_REQUEST['report_sourcemodule'];
	}
    $productsql='select lineitem_id from ld_inventoryproductrel where id in ('.$id.')';
    $productresult=$adb->pquery($productsql,array());
    for($i=0;$i<$adb->num_rows($productresult);$i++)
    {
        $_REQUEST['listval'].=$adb->query_result($productresult,$i,'lineitem_id').',';
    }
    
}
$smarty->assign('ISADMIN',$current_user->is_admin);

if(isset($_REQUEST['selectsourcename']) && $_REQUEST['selectsourcename'] != ''
    && isset($_REQUEST['listval']) && $_REQUEST['listval'] !='')
{
}elseif(isset($_REQUEST['record']) && isset($_REQUEST['record']) > 0){

    if(!isset($_REQUEST['salesorder_id']))
    {
        crm_load_class_file("Detail_Edit_View",'include/utils');
        $isSourceModule = Detail_Edit_View::getInventoryField('entitytype',$_REQUEST['record']);
        $relatedOrderIdStr=getDetailListValName($_REQUEST['record'],$isSourceModule,3);
        crm_load_class_file("Detail_Edit_View_finance",'include/utils');
      //  $relatedinformations=getRelatedOrderInformation($isSourceModule,str_replace('|',',',$relatedOrderIdStr),1);
 
   
        $relatedinformations=Detail_Edit_View_finance::getInvoice_SoureInfo($isSourceModule,str_replace('|',',',$relatedOrderIdStr));
        
        $smarty->assign("RELATEDORDERIDSTRING", str_replace('|',',',$relatedOrderIdStr));//Դ��id
    }
}else{
    
}
//end
global $theme;
$theme_path = "themes/" . $theme . "/";
$image_path = $theme_path . "images/";

$disp_view = getView($focus->mode);
$mode = $focus->mode;

$isallow= $focus->Library('SystemCode')->getModentityfield('isallow',$currentModule);
$smarty->assign('ISALLOW',$isallow);

require_once (globalStatic::$root_directory.'include/Stock/CommonStock.php');
$wareresult = selWareAll($current_user->id);
for($i = 0; $i<$adb->num_rows($wareresult); $i++)
{
    $wareArray[$adb->query_result($wareresult, $i, "id")] = $adb->query_result($wareresult, $i, "name");
}
$smarty->assign("WAREALL", $wareArray);

$customformno_columnname=$focus->fieldobj->getFieldInfoBykeyValue('uitype',4,'fieldname');
if($focus->mode!='edit'||$_REQUEST['isDuplicate']=='true'){
	$value = $focus->Library('SystemCode')->getModuleSeqNumRecord($currentModule);
	if(!$value) $value = getFixedLabel('MSG_AUTO_GEN_ON_SAVE');
   
	$focus->column_fields[$customformno_columnname] = $value;
}


if(!empty($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == true){
	$disp_view = 'create_view';
}

$VersionInfo = getVersionInfo();
if($VersionInfo['account'] == 'zhongneng' && $focus->mode == '' && empty($_REQUEST['isDuplicate']) && array_key_exists('wareid',$focus->column_fields)){
	
	$user_focus = CRMEntity::getInstance('Users');
	$user_focus->retrieve_entity_info($current_user->id, 'Users');
	$wareid = $user_focus->column_fields['wareid'];
	$focus->column_fields['wareid'] = $wareid;
}
$smarty->assign("OP_MODE", $disp_view);
$smarty->assign("MODULELINKFIELD",$focus->list_link_field);
$smarty->assign("SMOWNERCOLUMNNAME",$focus->getSmownerColumName());
$smarty->assign("MODULE", $currentModule);
$smarty->assign("SINGLE_MOD", $currentModule);

$smarty->assign("MOD", $mod_strings);
$smarty->assign("APP", $app_strings);
$smarty->assign('FROM_MODULE','');


if(isset($_REQUEST['account_id']))
{
    $smarty->assign("ACCOUNTID",$_REQUEST['account_id']);
    $focus->column_fields['account_id']=$_REQUEST['account_id'];
    
}

if (isset ($focus->name))
	$smarty->assign("NAME", $focus->name);
else
	$smarty->assign("NAME", "");
if (isset ($_REQUEST['convertmode']) && $_REQUEST['convertmode'] == 'quotetoinvoice') {
	$smarty->assign("MODE", $quote_focus->mode);
}
else{
	if (isset ($_REQUEST['convertmode']) && ($_REQUEST['convertmode'] == 'sotoinvoice' || $_REQUEST['convertmode'] == 'update_so_val')) {
		$txtTax = (($so_focus->column_fields['txtTax'] != '') ? $so_focus->column_fields['txtTax'] : '0.000');
		$txtAdj = (($so_focus->column_fields['txtAdjustment'] != '') ? $so_focus->column_fields['txtAdjustment'] : '0.000');
	}
	elseif ($focus->mode == 'edit') {
		$setListVal = 1;
		$smarty->assign('LISTVAL_PURCHASEORDER_NO',getDetailListValName($focus->id,$isSelectModule,2));
	}
	elseif (isset ($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true') {
		$focus->id = $_REQUEST['record'];
	}elseif ((isset ($_REQUEST['product_id']) && $_REQUEST['product_id'] != '') || (isset ($_REQUEST['opportunity_id']) && $_REQUEST['opportunity_id'] != '')) {
		$focus->column_fields['product_id'] = $_REQUEST['product_id'];
        $smarty->assign("FROM_MODULE",'Products');
        
		$frommodule = 'Products';
        
		//$InvTotal = getInventoryTotal($_REQUEST['return_module'], $_REQUEST['return_id']);
		//this is to display the Product Details in first row when we create new PO from Product relatedlist
		if ($_REQUEST['return_module'] == 'Products') {
			$smarty->assign("PRODUCT_ID", vtlib_purify($_REQUEST['product_id']));
			$smarty->assign("PRODUCT_NAME", getModuleHref('Products',$_REQUEST['product_id']));
			$smarty->assign("UNIT_PRICE", vtlib_purify($_REQUEST['product_id']));
			$smarty->assign("QTY_IN_STOCK", getPrdQtyInStck($_REQUEST['product_id']));
			$smarty->assign("VAT_TAX", getProductTaxPercentage("VAT", $_REQUEST['product_id']));
			$smarty->assign("SALES_TAX", getProductTaxPercentage("Sales", $_REQUEST['product_id']));
		
		}
	}

	$focus->mode = $focus->mode;
    if($_REQUEST['isDuplicate']=='true'){
          $focus->mode='create';
    }else{
		$smarty->assign("ID", $focus->id);
	}
	if (isset ($_REQUEST['product_id']) && $_REQUEST['product_id'] != '') {
		$focus->column_fields['product_id'] = $_REQUEST['product_id'];
        $productdetail_mode='product_create';
        $productdetailhtml_focus=$focus;
		//$smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($focus,'product_create'));
        $smarty->assign('FROM_MODULE','Products');//
	}else{
	    if(isset ($_REQUEST['listval']) && $_REQUEST['listval'])
        {

        }
        else
	       {
	           	if($focus->id > 0){
                    $productdetail_mode='edit';
                    //$smarty->assign("ASSOCIATEDPRODUCTS", $ProductDetailsHtml->getProductDetailsHtml($focus,'edit'));
	           	}else if($_REQUEST['fromid']<=0||$issourcemodulecreate=='no'){
                    $productdetail_mode='create';
                    //$smarty->assign("ASSOCIATEDPRODUCTS", $ProductDetailsHtml->getProductDetailsHtml($focus,'create'));
	           	}
               $productdetailhtml_focus=$focus;

	       }
	}
}
if((isset($_REQUEST['fromid']) && $_REQUEST['fromid'] >0) )
{
    if($issourcemodulecreate=='yes')
	{
	   $_REQUEST['selectsourcename'] = $_REQUEST['frommodule'];
        $sourcefocus=CRMEntity::getInstance($_REQUEST['selectsourcename']);
        $sourcedetailtable=$sourcefocus->Detail_table;
        $productsql=" select lineitem_id from $sourcedetailtable where id=? ";
        $fromid=$_REQUEST['fromid'];
        $productresult=$adb->pquery($productsql,array($fromid));
        for($i=0;$i<$adb->num_rows($productresult);$i++)
        {
            $_REQUEST['listval'].=$adb->query_result($productresult,$i,'lineitem_id').',';
        }
    }
}
$productFields['fields']=$ProductDetailsData->moduleProductToolField;
$productFields['system_deploy']=$ProductDetailsData->system_deploy_formulas;
$smarty->assign('PRODUCTFIELDSINFOJSON',ldcrm_json_encode($productFields));
$smarty->assign('BASECOLUMN',$ProductDetailsData->module_productbasefield);
if (isset ($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true') {
	$smarty->assign("DUPLICATE_FROM", $focus->id);
    crm_load_class_file("Detail_Edit_View",'include/utils');
	$isSelectModule = Detail_Edit_View::getInventoryField('entitytype',$focus->id);
	$smarty->assign('LISTVAL_PURCHASEORDER_NO',getDetailListValName($focus->id,$isSelectModule,2));
}else{
    if($potentialdeployarray['deploy_value']==0&&$frommodule=='Potentials')
    {

        $tmp_fromid=$_REQUEST['fromid'];
        $potentials_focus = CRMEntity::getInstance($frommodule);
        $quoteidstr = getLineitemId($tmp_fromid,$potentials_focus->moduleName);

        $potentials_focus->lineitemIds = $quoteidstr;
        $potentials_focus->mode = 'edit';
        $potentials_focus->id=$tmp_fromid;
        $potentials_focus->retrieve_entity_info($tmp_fromid, $frommodule);
        $currencyid = $potentials_focus->column_fields['currency_id'];
        $rate = $potentials_focus->column_fields['conversion_rate'];
        $productdetailhtml_focus=$potentials_focus;
        $productdetail_mode='module_create';
        //$smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($potentials_focus,'module_create'));
        $smarty->assign("CONVERT_MODE", vtlib_purify($_REQUEST['convertmode']));
    }
}
$smarty->assign("MODE", $focus->mode);
if (isset ($cust_fld)) {
	$smarty->assign("CUSTOMFIELD", $cust_fld);
}
if (isset ($_REQUEST['return_module']))
	$smarty->assign("RETURN_MODULE", vtlib_purify($_REQUEST['return_module']));
else
	$smarty->assign("RETURN_MODULE", $currentModule);
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
$smarty->assign("PRINT_URL", "phprint.php?jt=" . session_id() . $GLOBALS['request_string']);
//in create new Invoice, get all available product taxes and shipping & Handling taxes
$tabid = getTabid($currentModule);
$data =$focus->fieldobj->split_validationdataArray();
$category = getParentTab();
$smarty->assign("CATEGORY", $category);

$smarty->assign("VALIDATION_DATA_FIELDNAME", $data['fieldname']);
$smarty->assign("VALIDATION_DATA_FIELDDATATYPE", $data['datatype']);
$smarty->assign("VALIDATION_DATA_FIELDLABEL", $data['fieldlabel']);

global $adb;
$smarty->assign("DUPLICATE",vtlib_purify($_REQUEST['isDuplicate']));
$smarty->assign('CREATEMODE', vtlib_purify($_REQUEST['createmode']));
global $global_pick_list_depencyfield;
crm_load_class_file('lingdang_DependencyPicklist','modules/PickList');
$picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasource($currentModule);
$smarty->assign("PICKIST_DEPENDENCY_DATASOURCE", ldcrm_json_encode($picklistDependencyDatasource));
$smarty->assign("PICKLISTDEPENCYFIELDS", ldcrm_json_encode($global_pick_list_depencyfield));


if((isset ($_REQUEST['listval']) && $_REQUEST['listval'] != ""))
{   
	$isSelectModule = $_REQUEST['selectsourcename'];  
    $lineitemid = rtrim($_REQUEST['listval'],',');
    
    
    $so_focus = CRMEntity::getInstance($isSelectModule);
    $soid = $lineitemid;
	$currencyinfo = getModuleCurrencyInfo($soid,"$isSelectModule");
    $so_focus->lineitemIds = $lineitemid;
	$so_focus->mode = 'edit';
    $so_focus->id=$_REQUEST['fromid'];
    $productdetail_mode='sourcemodule_create';
    $productdetailhtml_focus=$so_focus;
    //$smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($so_focus,'sourcemodule_create'));
    $setListVal = count(explode(',',$so_focus->lineitemIds));
	$ids = explode(',',rtrim($_REQUEST['listval'],','));
    $source_detail_table=$so_focus->Detail_table;
  
	$so_focus->retrieve_entity_info($so_focus->id, $isSelectModule);
	$focus->column_fields['account_id']= $so_focus->column_fields['account_id'];
    $fieldinfo=$focus->getSourceFieldInfo();
    if($fieldinfo&&$fieldinfo->getFieldName()!='')
        $focus->column_fields[$fieldinfo->getFieldName()]=$_REQUEST['fromid'];
	
	
    
	$smarty->assign("ACCOUNTID",$focus->column_fields['account_id']);
    $smarty->assign('LISTVAL_PURCHASEORDER_NO',getEditListValName($so_focus->lineitemIds,$isSelectModule));
    crm_load_class_file("Detail_Edit_View_finance",'include/utils');
    $lineitemids=implode(',',$ids);
    $query = " select id  from $source_detail_table where lineitem_id in ( ".$lineitemids." )";

    $result=$adb->pquery($query,array());
    $num_rows=$adb->num_rows($result);
    for($i=0;$i<$num_rows;$i++)
    {
		if($i == 0){
			$entityid = $adb->query_result($result,$i,0);
		}
        $sourceids[]=$adb->query_result($result,$i,0);
    }
	$sourceids=implode(',',$sourceids);
    
    
   
}
if(isset($_REQUEST['parent_id']) && $_REQUEST['parent_id'] > 0){
	$focus->getModuleLogic($currentModule)->setQuickCreateColumn($_REQUEST['parent_module'],$_REQUEST['parent_id']);
}
if(isset($_REQUEST['fromid']) && $_REQUEST['fromid'] > 0){
	$focus->getModuleLogic($currentModule)->setQuickCreateColumnValues($currentModule,$_REQUEST['fromid']);
}
if(!empty($_REQUEST['report_sourcemodule']) && !empty($_REQUEST['accountid'])){
	$focus->column_fields['account_id']= $_REQUEST['accountid'];
	if(!empty($_REQUEST['accountid'])){
		$accounts_focus = CRMEntity::getInstance('Accounts');
		$accounts_focus->retrieve_entity_info($_REQUEST['accountid'], 'Accounts');
		$focus->column_fields['assigned_user_id'] = $accounts_focus->column_fields['assigned_user_id'];
	}
}
$smarty->assign('SELECTSOURCENAME',$isSelectModule);
$smarty->assign('ISSOURCEMODULE',$isSelectModule);
$smarty->assign('LISTALLVAL',$setListVal);
$smarty->assign("RELATEDORDERINFORMATION", $relatedinformations);//ԭ����Ϣ
global $global_pick_list_values,$edit_column_fields_value;
$act_data=getBlocks($currentModule, $disp_view, $mode, $focus->column_fields);
$smarty->assign("COLUMN_FIELDS_VALUE",ldcrm_json_encode($edit_column_fields_value));
//edit:can 20200723 必须放在getBlocks后边（因为明细字段的布局规则）
$ProductDetailsHtml = crm_load_class_obj('cls_productDetailsHtml',"modules/$currentModule/ProductDetails",array($currentModule));
$ProductDetailsData = crm_load_class_obj('cls_productDetailsData',"modules/$currentModule/ProductDetails",array($currentModule));
//复制,产品明细丢失
if (isset ($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true') {
    $productdetailhtml_focus->id=$_REQUEST['record'];
    $productdetailhtml_focus->mode='edit';
}
$smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($productdetailhtml_focus,$productdetail_mode));
if (isset ($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true') {
    $focus->id='';
    $focus->mode='create';
}

if(isset($act_data['RichText']) && !empty($act_data['RichText'])){
	$richText=$act_data['RichText'];
	unset($act_data['RichText']);
	$smarty->assign('RICHTEXTBOX',implode(',',$richText));
	$smarty->assign('RICHTEXTCOUNT',sizeof($richText));
}else{
	$smarty->assign('RICHTEXTBOX','');
	$smarty->assign('RICHTEXTCOUNT','');
}
$smarty->assign("BLOCKS", $act_data);

if( (isset($_REQUEST['Create'])&&($_REQUEST['Create']=='true' || $_REQUEST['Create']=='yes')) ||$_REQUEST['isDuplicate']=='true'){
	$smarty->assign('CREATE','true');
}
else{
	$smarty->assign('CREATE','false');
}

$version_info = getVersionInfo();
$smarty->assign('VERSIONINFO',$version_info);
$smarty->assign('VERSIONTRADE',$version_info['trade']);
$smarty->assign('VERSION_ACCOUNT',$version_info['account']);

$block_info = getBlockDisplayInfo('AccountContacts');
$smarty->assign('DISPLAY_POSITION',$block_info['display_position']);
if($block_info['is_display'] == 0)
    $smarty->assign('BESTATUS','YES');
else
    $smarty->assign('BESTATUS','NO');
$fields=$focus->fieldobj->getFieldListArray();
//$fields['module']=$currentModule;
//$smarty->assign('RELATEDORDERINFORMATION',$obj_entity->showSourceHtml());
$smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));
$smarty->assign("MODULELINKFIELD",$focus->list_link_field);
$smarty->assign("SMOWNERCOLUMNNAME",$focus->getSmownerColumName());

$relmodule = (isset($currentModule))?$currentModule:$_REQUEST['module'];
$smarty->assign("IS_REL_LIST",isPresentRelatedLists($relmodule));
$smarty->assign("PICKLISTCONTENT",ldcrm_json_encode($global_pick_list_values));


$smarty->assign("VALIDATASAVE",ldcrm_json_encode(getValidataSave($currentModule)));
$smarty->assign("TABDETAILFIELDS",ldcrm_json_encode($ProductDetailsHtml->ProductDetailsData->productToolFields->getFieldListArray()));
$smarty->assign('FROMID',$_REQUEST['fromid']);
setGLobalURLSmarty($smarty);

$smarty->assign("ReferenceUitypes",cls_module_uitype::getAllUitypes());
$smarty->assign("UITYPEMODULES",cls_module_uitype::getUitypeModules());
Crm_load_class_file("CommonView","modules/CustomView");
$smarty->assign("DATETIMESTR",json_encode(CommonView::stdFilterDateTimeStr()));

crm_load_class_file('cls_fieldrule','include/fields/fieldrule');
$fieldruleobj=cls_fieldrule::getInstance($currentModule);
$smarty->assign('jsonFieldRuleFieldNames',ldcrm_json_encode($fieldruleobj->getAllFieldNameSetChangeEvent()));

$arr = $ProductDetailsHtml->detailPopup($smarty,$fields,$productFields,$data);
ConvertTojsonString(1,$arr,"success");
?>