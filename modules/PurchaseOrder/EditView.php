<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $current_user,$theme,$currentModule;
$languageType= getLanguageType($current_user);
$focus = CRMEntity::getInstance($currentModule);
$fieldobj=$focus->fieldobj;
$smarty = new lingdangCRM_Smarty();
$searchurl = getBasic_Advance_SearchURL();
$smarty->assign("SEARCH", $searchurl);
$setListVal = 0;
global $current_user;
//选择源单，获取多个源单模块
$sourcemodules=getSourceModule($currentModule);
if(sizeof($sourcemodules)>0)
{
    $smarty->assign('MODULE_ACTIVATE',true);
}
$smarty->assign('SOURCEMODULE',$sourcemodules);
foreach($sourcemodules as $val){
    if($val['default'] == 1){
        $isSelectModule = $val['entitytype'];
    }
}
if((isset($_REQUEST['parent_id']) || isset($_REQUEST['fromid']))||($_REQUEST['convertmode']&&$_REQUEST['convertmode']=='update_purchase_val'))
{
	if(!empty($_REQUEST['parent_id']))
	{
	   $parent_id = $_REQUEST['parent_id'];
       $_REQUEST['frommodule']=getSalesEntityType($parent_id);
	}
	elseif(!empty($_REQUEST['fromid']))
		$parent_id = $_REQUEST['fromid'];
    foreach($sourcemodules as $tmp=>$sourcemoduleinfo)
    {
        if($_REQUEST['frommodule']==$sourcemoduleinfo['entitytype'])
        {
            $isfromsourcemodule='yes';
            break;
        }
    }
    if($isfromsourcemodule=='yes')
    {
        $sourcefocus=CRMEntity::getInstance($_REQUEST['frommodule']);
        $productsql='select lineitem_id from '. $sourcefocus->Detail_table .' where id=?';
        $productresult=$adb->pquery($productsql,array($parent_id));
        for($i=0;$i<$adb->num_rows($productresult);$i++)
        {
            $_REQUEST['listval'].=$adb->query_result($productresult,$i,'lineitem_id').',';
        }
    	$from_module = getSalesEntityType($parent_id);
    	$_REQUEST['selectsourcename'] = $from_module;
    }
}
/**
 * 更新操作
 * edit:can
 * date:20131211
 * reason:6191: 合同订单、发票复制界面：报价单字段、合同订单字段选择值后页面刷新，结果页面名称复制中合同订单、发票变成了新增合同订单、发票
 * */
if(isset($_REQUEST['duplicate_from'])&&$_REQUEST['duplicate_from']!='')
{
    $_REQUEST['isDuplicate']='true';
    $_REQUEST['record']=$_REQUEST['duplicate_from'];
}
if(isset($_REQUEST['record']) && $_REQUEST['record'] != '')
{
	crm_load_class_file("Detail_Edit_View",'include/utils');
    $isSelectModule = Detail_Edit_View::getInventoryField('entitytype',$_REQUEST['record']);
    $focus->id = $_REQUEST['record'];
    $focus->mode = 'edit';
    $focus->retrieve_entity_info($_REQUEST['record'],"PurchaseOrder");
    $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey('columnname',$focus->getSmownerColumName());
     if($focus->column_fields[$fieldinfo->getFieldName()]!=$current_user->id)
     {
      
            crm_load_class_file('cls_CurUserDataScope','include/ListView');
            $datascopeobj=cls_CurUserDataScope::getInstance($currentModule,'record');
            $datascopeobj->isMyViewData($_REQUEST['record']);
     }
    $focus->name=$focus->column_fields[$focus->list_link_field];
	$approve = Approve::getInstance($currentModule);
    if(isset($_REQUEST['ajax']) && $_REQUEST['ajax']==true){
        echo $approve->EditBlocks($focus->column_fields['assigned_user_id'],$focus->id);
        exit();
    }
}
if(empty($_REQUEST['record']) && $focus->mode != 'edit'){
	setObjectValuesFromRequest($focus);
}
//合同订单创建采购订单。调出合同订单数据
if((isset($_REQUEST['parent_id']) && $_REQUEST['parent_id'] >0) || (!empty($_REQUEST['entityid']) && $_REQUEST['entityname'] == 'SalesOrder'))
{
	if(!empty($_REQUEST['parent_id']))
		$salesorder_id = $_REQUEST['parent_id'];
    else
		$salesorder_id = $_REQUEST['entityid'];
	$sql = "select a.subject,a.contactid,a.currency_id from ld_salesorder a 
    where  a.salesorderid = $salesorder_id  ";
    $result=$adb->pquery($sql);
	
    $smarty->assign("SALESORDERNAME", $adb->query_result($result,0,"subject"));
	$smarty->assign("SALESCURRENCYID", $adb->query_result($result,0,"currency_id"));
    $smarty->assign("PARENTID", $salesorder_id);
  
    $productsql='select lineitem_id from ld_salesorderdetail where id=?';
    $productresult=$adb->pquery($productsql,array($salesorder_id));
    for($i=0;$i<$adb->num_rows($productresult);$i++){
        $_REQUEST['listval'].=$adb->query_result($productresult,$i,'lineitem_id').',';
    }
}
if(isset($_REQUEST['vendorcontactid']) && $_REQUEST['vendorcontactid']>0){
	$focus->column_fields['contact_id']=$_REQUEST['vendorcontactid'];
}

if((isset ($_REQUEST['listval']) && $_REQUEST['listval'] != ""))
{
	$isSelectModule = $_REQUEST['selectsourcename']; 
    
    $so_focus = CRMEntity::getInstance($isSelectModule);
    $so_focus->lineitemIds = rtrim($_REQUEST['listval'], ",");
	$so_focus->mode = 'edit';
    $so_focus->id=$_REQUEST['fromid'];
    $productdetail_focus=$so_focus;
    $productdetail_mode='sourcemodule_create';
    
	//$smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($so_focus,'sourcemodule_create'));
    $setListVal = count(explode(',',$so_focus->lineitemIds));
	//原单的单据名字
    $smarty->assign('LISTVAL_PURCHASEORDER_NO',getEditListValName($so_focus->lineitemIds,$isSelectModule));
    $fieldinfo=$focus->getSourceFieldInfo();//获取原单字段信息
    if($fieldinfo&&$fieldinfo->getFieldName()!='')
        $focus->column_fields[$fieldinfo->getFieldName()]=$_REQUEST['fromid'];//关联创建原单
}else{
	if($focus->mode == 'edit'){
		$setListVal = 1;
		//原单的单据名字
		if(!empty($isSelectModule)){
			$smarty->assign('LISTVAL_PURCHASEORDER_NO',getDetailListValName($focus->id,$isSelectModule,2));
		}
	}
	if(isset($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true'){
		$focus->id = $_REQUEST['record'];
		$focus->mode = 'edit';
	}
     
	//报表库关联创建
	if(!empty($_REQUEST['productdetail_products']) && $_REQUEST['frommodule'] == 'Customreport'){
		$so_focus = CRMEntity::getInstance('SalesOrder');
		$productdetail_products = json_decode($_REQUEST['productdetail_products']);
        
		if(!empty($productdetail_products[0]->productid)){
			foreach($productdetail_products as $obj){
				$pro[] = $obj->productid;
			}
			if(sizeOf($pro) >= 0){
				$_REQUEST['product_id'] = implode(',',$pro);
			}
           
            $productdetail_focus=$focus;
             $productdetail_mode='product_create';			
			//$smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($focus,'product_create'));
			//$_REQUEST['product_id'] = '';
		}else{
			foreach($products as $product_info){
				$entitypeid_arr[] = $product_info->lineitem_id;
				$_REQUEST['Customreport_entitytype'] = $product_info->entitytype;
			}
			$_REQUEST['listval'] = implode(',',$entitypeid_arr);
			$so_focus->lineitemIds = implode(',',$entitypeid_arr);
             $productdetail_focus=$so_focus;
             $productdetail_mode='sourcemodule_create';
             
			//$smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($so_focus,'sourcemodule_create'));//产品关联创建
			//原单的单据名字
			$smarty->assign('LISTVAL_PURCHASEORDER_NO',getEditListValName($so_focus->lineitemIds,'SalesOrder'));
		}
		
	}else{
		if($focus->id > 0){
		      $productdetail_focus=$focus;
             $productdetail_mode='edit';
			//$smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($focus,'edit'));	
		}else{
		     $productdetail_focus=$focus;
             $productdetail_mode='create';
			//$smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($focus,'create'));
            //zkt 20221219关联选择单据字段-相关创建带出产品详情
            if(isset($_REQUEST['frommodule'])&&get_file_address($_REQUEST['frommodule'],'ProductDetails')&&$_REQUEST['relatedcreate']=='yes'){
                $infos=Field::getAllFieldTypeInfo($adb);
                foreach($infos as $index=>$info)
                {
                    if($info['type']!=''&&$info['type']!='Users'&&$info['fieldtype']=='reference'){
                        $reference_uitypes[$info['uitype']]=$info['type'];//获取相关的referencefield
                    }
                }
                $tmpfields = $focus->fieldobj->getModuleFields();
                foreach($tmpfields as $tmpindex=>$tmpinfo)
                {
                    if(!empty($tmpinfo))
                    {
                        $tmpuitype = $tmpinfo->getUIType();
                        if($tmpinfo->getBigType()=='reference'&&$tmpinfo->getadddetails()=='yes'
                        &&isset($reference_uitypes[$tmpuitype])&&$reference_uitypes[$tmpuitype] == $_REQUEST['frommodule']){
                            $frommodule=$_REQUEST['frommodule'];
                            $tmp_fromid=$_REQUEST['fromid'];
                			$tmp_focus = CRMEntity::getInstance($frommodule);
                			$tmpidstr = getLineitemId($tmp_fromid,$tmp_focus->moduleName);
                			$tmp_focus->lineitemIds = $tmpidstr;
                			$tmp_focus->mode = 'edit';
                			$tmp_focus->id=$tmp_fromid;
                		    $productdetail_focus=$tmp_focus;
                            $productdetail_mode='module_create';
                            break;
                        }
                    }
                }
             }
		}
	}
}

if(isset($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true') {
	$smarty->assign("DUPLICATE_FROM", $focus->id);
    crm_load_function_file("getInventoryCurrencyInfo",'include/utils','InventoryUtils');
    $inventory_cur_info = getInventoryCurrencyInfo($currentModule, $focus->id);
	
}


$versiontrade=getVersionTradeInfo();
$smarty->assign('TRADEJIJIN',$versiontrade['trade']);
$productFields['trade']=$versiontrade['trade'];


$smarty->assign('FROM_MODULE','');//关联创建采购订单，判断合同订单是从哪个模块创建的，字段公式会用到的,
                                  //  因为产品关联创建字段公式以不含税单价为基准
//产品关联创建
//@edit:liushuai,2021-03-16,reason:【ID1001451】产品管理单据查看详情界面，相关信息关联创建自动带出产品分录信息
if($_REQUEST['frommodule']=='Products'&&$_REQUEST['fromid']>0)
{
    $_REQUEST['product_id']=$_REQUEST['fromid'];
}
if(isset($_REQUEST['product_id']) && $_REQUEST['product_id'] !=''){
	$focus->column_fields['product_id'] = $_REQUEST['product_id'];
    $productdetail_focus=$focus;
    $productdetail_mode='product_create';
             
	//$smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($focus,'product_create'));
    $smarty->assign('FROM_MODULE','Products');
   
	if($_REQUEST['return_module'] == 'Products'){
		$smarty->assign("PRODUCT_ID",vtlib_purify($_REQUEST['product_id']));
		$smarty->assign("PRODUCT_NAME",getModuleHref('Products',$_REQUEST['product_id']));
		$smarty->assign("UNIT_PRICE",vtlib_purify($_REQUEST['product_id']));
		$smarty->assign("QTY_IN_STOCK",getPrdQtyInStck($_REQUEST['product_id']));
		$smarty->assign("VAT_TAX",getProductTaxPercentage("VAT",$_REQUEST['product_id']));
		$smarty->assign("SALES_TAX",getProductTaxPercentage("Sales",$_REQUEST['product_id']));
		$smarty->assign("SERVICE_TAX",getProductTaxPercentage("Service",$_REQUEST['product_id']));
	}
}
if(isset($_REQUEST['vendor_id']) && $_REQUEST['vendor_id'] > 0 && $_REQUEST['record']==''){
	$vend_focus = CRMEntity::getInstance('Vendors');
	$vend_focus->retrieve_entity_info($_REQUEST['vendor_id'],"Vendors");
	$focus->column_fields['bill_city']=$vend_focus->column_fields['city'];
	$focus->column_fields['ship_city']=$vend_focus->column_fields['city'];
	$focus->column_fields['bill_street']=$vend_focus->column_fields['street'];
	$focus->column_fields['ship_street']=$vend_focus->column_fields['street'];
	$focus->column_fields['bill_state']=$vend_focus->column_fields['state'];
	$focus->column_fields['ship_state']=$vend_focus->column_fields['state'];
	$focus->column_fields['bill_code']=$vend_focus->column_fields['postalcode'];
	$focus->column_fields['ship_code']=$vend_focus->column_fields['postalcode'];
	$focus->column_fields['bill_country']=$vend_focus->column_fields['country'];
	$focus->column_fields['ship_country']=$vend_focus->column_fields['country'];
	$focus->column_fields['bill_pobox']=$vend_focus->column_fields['pobox'];
	$focus->column_fields['ship_pobox']=$vend_focus->column_fields['pobox'];
}
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";
$smarty->assign('ISADMIN',$current_user->is_admin);
$disp_view = getView($focus->mode);
// END
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
	$focus->column_fields['purchaseorder_no'] = $value;
}
/* 关联创建单据统一处理方法 begin */
if(isset($_REQUEST['parent_id']) && $_REQUEST['parent_id'] > 0){
	$focus->getModuleLogic($currentModule)->setQuickCreateColumn($_REQUEST['parent_module'],$_REQUEST['parent_id']);
}
if(isset($_REQUEST['fromid']) && $_REQUEST['fromid'] > 0){
	//杨锻：订单下推销售确认单,没有将订单中的合同流水号   核算项目(客户名称)带入到销售确认单中.
	if(!empty($_REQUEST['entityid']) && $_REQUEST['entityname'] == 'SalesOrder' && get_versiontrade() == 'yangduan'){
		$query = 'select ld_salesorder.accountid,cf_2191,cf_2331 from ld_salesorder
		LEFT JOIN ld_salesordercf on ld_salesordercf.salesorderid = ld_salesorder.salesorderid 
		where ld_salesorder.salesorderid = ?';
		$result = $adb->pquery($query,array($_REQUEST['entityid']));
		$accountid = $adb->query_result($result,0,0);	//客户ID
		$cf_2191 = $adb->query_result($result,0,1);	//合同流水号
		$cf_2331 = $adb->query_result($result,0,'cf_2331');	//订单类型
		$focus->column_fields['account_id'] = $accountid;
		$focus->column_fields['cf_2332'] = $cf_2191;
		$focus->column_fields['cf_2348'] = $cf_2331;
	}
	$focus->getModuleLogic($currentModule)->setQuickCreateColumnValues($currentModule,$_REQUEST['fromid']);
}
/* 关联创建单据统一处理方法 end */
if (isset ($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true') {
	/**
	 * 复制时，负责人设置为自己
	 * @author Tujt 2015-07-20
	 */
//	$focus->column_fields['assigned_user_id'] = $current_user->id;
	$value = $focus->Library('SystemCode')->getModuleSeqNumRecord($_REQUEST['module']);
	if(!$value) $value = getFixedLabel('MSG_AUTO_GEN_ON_SAVE');
	$focus->column_fields['purchaseinvoice_no'] = $value;
}
global $global_pick_list_values,$edit_column_fields_value;
$act_data=getBlocks($currentModule, $disp_view, $mode, $focus->column_fields);
$smarty->assign("COLUMN_FIELDS_VALUE",ldcrm_json_encode($edit_column_fields_value));
//edit:can 20200723 必须放在getBlocks后边（因为明细字段的布局规则）
$ProductDetailsHtml = crm_load_class_obj('cls_productDetailsHtml',"modules/$currentModule/ProductDetails",array($currentModule));
$ProductDetailsData = crm_load_class_obj('cls_productDetailsData',"modules/$currentModule/ProductDetails",array($currentModule));
$smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($productdetail_focus,$productdetail_mode));

$productFields['fields']=$ProductDetailsData->moduleProductToolField;
$productFields['system_deploy']=$ProductDetailsData->system_deploy_formulas;
$smarty->assign('PRODUCTFIELDSINFOJSON',ldcrm_json_encode($productFields));
$smarty->assign('BASECOLUMN',$ProductDetailsData->module_productbasefield);//计算公式中基准字段
$systemmethod = $ProductDetailsData->getSystemMethod();
$productFields['lengthdecimaldigits'] = $systemmethod['lengthdecimaldigits'];
$productFields['lengthprice'] = $systemmethod['lengthprice'];
$productFields['SystemArgument'] = $systemmethod['SystemArgument'];
$productFields['addproductrow'] = $systemmethod['addproductrow'];
$smarty->assign('PRODUCTFIELDSINFOJSON',ldcrm_json_encode($productFields));
$smarty->assign('FROMID',$_REQUEST['fromid']);
if(isset($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true') 
{
    $focus->id = "";
    $focus->mode = '';
}
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
$smarty->assign("BLOCKS",$act_data);
$smarty->assign("OP_MODE",$disp_view);
$smarty->assign("MODULE",$currentModule);
$smarty->assign("SINGLE_MOD",'PurchaseOrder');
$category = getParentTab();
$smarty->assign("CATEGORY",$category);
$smarty->assign("MOD", $mod_strings);
$smarty->assign("APP", $app_strings);
$smarty->assign('LISTALLVAL',$setListVal);
$smarty->assign('SELECTSOURCENAME',$isSelectModule);
$smarty->assign('ISSOURCEMODULE',$isSelectModule);

if (isset($focus->name)) $smarty->assign("NAME", $focus->name);
else $smarty->assign("NAME", "");
$smarty->assign("MODE", $focus->mode);
if(isset($cust_fld))
{
    $smarty->assign("CUSTOMFIELD", $cust_fld);
}		

if(isset($_REQUEST['return_module'])) $smarty->assign("RETURN_MODULE", vtlib_purify($_REQUEST['return_module']));
else $smarty->assign("RETURN_MODULE","PurchaseOrder");
if(isset($_REQUEST['return_action'])) $smarty->assign("RETURN_ACTION", vtlib_purify($_REQUEST['return_action']));
if(isset($_REQUEST['return_id'])) $smarty->assign("RETURN_ID", vtlib_purify($_REQUEST['return_id']));
if (isset($_REQUEST['return_viewname'])) $smarty->assign("RETURN_VIEWNAME", vtlib_purify($_REQUEST['return_viewname']));
$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH", $image_path);
$smarty->assign("MODULE","PurchaseOrder");
$smarty->assign("PRINT_URL", "phprint.php?jt=".session_id().$GLOBALS['request_string']);
$smarty->assign("ID", $focus->id);
$smarty->assign("CALENDAR_LANG", $app_strings['LBL_JSCALENDAR_LANG']);
$smarty->assign("CALENDAR_DATEFORMAT", 'YYYY-mm-dd');
//合同模块是否被激活
$smarty->assign('MODULE_ACTIVATE',vtlib_isModuleActive('SalesOrder'));
$data =$fieldobj->split_validationdataArray();
$smarty->assign("VALIDATION_DATA_FIELDNAME",$data['fieldname']);
$smarty->assign("VALIDATION_DATA_FIELDDATATYPE",$data['datatype']);
$smarty->assign("VALIDATION_DATA_FIELDLABEL",$data['fieldlabel']);

//复制
$smarty->assign("DUPLICATE",vtlib_purify($_REQUEST['isDuplicate']));

global $adb;
$smarty->assign('CREATEMODE', vtlib_purify($_REQUEST['createmode']));
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
if( (isset($_REQUEST['Create'])&&($_REQUEST['Create']=='true' || $_REQUEST['Create']=='yes') ||$_REQUEST['isDuplicate']=='true')){
	$smarty->assign('CREATE','true');
}
else{
	$smarty->assign('CREATE','false');
}

if (isset($_REQUEST['record']) && $_REQUEST['record'] != '') {
    $smarty->assign("VENDOR_ID", $focus->column_fields['vendor_id']);
    $smarty->assign("CONTACTID", $focus->column_fields['contact_id']);
}
//获取版本类型
$version_info = getVersionInfo();
$smarty->assign('VERSIONINFO',$version_info);

//源美特殊控制
if($version_info['account'] == 'yuanmei'){
	$smarty->assign('ordertype_onclick',$focus->getOrdertypeByField());
}
/**
 * 编辑、创建页面，增加更多信息左边栏
 * @author Tujt 2014-04-11
 */
$relmodule = (isset($currentModule))?$currentModule:$_REQUEST['module'];
$smarty->assign("IS_REL_LIST",isPresentRelatedLists($relmodule));
$fields=$focus->fieldobj->getFieldListArray();
$fields['module']=$currentModule;
$smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));
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
 //editor:gyq_161 reason:带分录模块弹出层   2019/11/20 11:35
/*if($focus->mode == 'edit')
	$smarty->display("DetailView/InventoryEditView.tpl");
else
	$smarty->display('DetailView/InventoryCreateView.tpl');*/
$arr = $ProductDetailsHtml->detailPopup($smarty,$fields,$productFields,$data);
ConvertTojsonString(1,$arr,"success");
?>