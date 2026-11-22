<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global  $theme, $currentModule, $current_user, $adb;
require('user_privileges/user_language_'.$current_user->id.'.php');
/*crm_load_class_file('cls_ProductDetailUitype_PageRecordValue','include/ProductDetailsHtml');

$obj=new cls_ProductDetailUitype_PageRecordValue('SalesOrder','create','','');
$dataHeaderInfos=$obj->getValues();
echo '<pre>';
print_r($dataHeaderInfos);
echo '</pre>';
exit();*/
$focus = CRMEntity::getInstance($currentModule);
$smarty = new lingdangCRM_Smarty();
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
//added to fix the issue4600
$searchurl = getBasic_Advance_SearchURL();
$smarty->assign("SEARCH", $searchurl);
$currencyid = 1;



/**
 * 更新操作
 * edit:can
 * date:20131211
 * reason:6191: 合同订单、发票复制界面：报价单字段、合同订单字段选择值后页面刷新，结果页面名称复制中合同订单、发票变成了新增合同订单、发票
 * */
if(isset($_REQUEST['duplicate_from'])&&$_REQUEST['duplicate_from']!=''){
    $_REQUEST['isDuplicate']='true';
}
$smarty->assign('FROM_MODULE','');//关联创建合同订单，判断合同订单是从哪个模块创建的，字段公式会用到的,
                                  //  因为产品关联创建字段公式以不含税单价为基准
//产品关联创建 合同订单 和 相关信息创建合同订单，传入的ID值不一样
if (isset ($_REQUEST['productid']) && $_REQUEST['productid'] != ''){
	$_REQUEST['product_id'] = $_REQUEST['productid'];

    
}
crm_load_function_file("getConvertQuoteToSoObject","include/utils",'EditViewUtils');
crm_load_function_file('getInventoryCurrencyInfo','include/utils','InventoryUtils');
if (isset ($_REQUEST['record']) && $_REQUEST['record'] != '') {
	if (isset ($_REQUEST['convertmode']) && $_REQUEST['convertmode'] == 'update_quote_val'){
		//Updating the Selected Quote Value in Edit Mode
		foreach ($focus->column_fields as $fieldname => $val) {
			if (isset ($_REQUEST[$fieldname])) {
				$value = $_REQUEST[$fieldname];
				$focus->column_fields[$fieldname] = $value;
			}
		}
		//Handling for dateformat in due_date lingdang_field
		if ($focus->column_fields['duedate'] != '') {
			$curr_due_date = $focus->column_fields['duedate'];
			$focus->column_fields['duedate'] = getValidDBInsertDateValue($curr_due_date);
		}

		$quoteid = $focus->column_fields['quote_id'];
       
		$smarty->assign("QUOTE_ID", $focus->column_fields['quote_id']);
		$quote_focus = CRMEntity::getInstance('Quotes');
		$quote_focus->id = $quoteid;
		$quote_focus->retrieve_entity_info($quoteid, "Quotes");
		$focus = getConvertQuoteToSoObject($focus, $quote_focus, $quoteid);
		$focus->id = $_REQUEST['record'];
		$focus->mode = 'edit';
		$focus->name = $focus->column_fields[$focus->list_link_field];
		$currencyid = $quote_focus->column_fields['currency_id'];
		$rate = $quote_focus->column_fields['conversion_rate'];

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
		$focus->name = $focus->column_fields[$focus->list_link_field];
        //审批流程begin
        //判断单据的审批状态，如果是已审批或者审批中，小编辑功能失效
		//require_once('modules/Approve/Approve.php');
        //$approve=new Approve();
		$approve = Approve::getInstance($currentModule);
        if(isset($_REQUEST['ajax']) && $_REQUEST['ajax']==true){
            echo $approve->EditBlocks($focus->column_fields['assigned_user_id'],$focus->id);
            exit();
        }
        //审批流程end
        
	}
} else {
	if (isset ($_REQUEST['convertmode']) && $_REQUEST['convertmode'] == 'update_quote_val') {
		//Updating the Select Quote Value in Create Mode
		foreach ($focus->column_fields as $fieldname => $val) {
			if (isset ($_REQUEST[$fieldname])) {
				$value = $_REQUEST[$fieldname];
				$focus->column_fields[$fieldname] = $value;
			}
		}
		//Handling for dateformat in due_date lingdang_field
		if ($focus->column_fields['duedate'] != '') {
			$curr_due_date = $focus->column_fields['duedate'];
			$focus->column_fields['duedate'] = getValidDBInsertDateValue($curr_due_date);
		}
		$quoteid = $focus->column_fields['quote_id'];
		$quote_focus = CRMEntity::getInstance('Quotes');;
	//	$quoteidstr = substrTd($quoteid . ',',0,$quote_focus->moduleName);
      // $quote_focus->lineitemIds=$quoteidstr;
		$quote_focus->id = $quoteidstr;
		$quote_focus->retrieve_entity_info($quoteid, "Quotes");
		$focus = getConvertQuoteToSoObject($focus, $quote_focus, $quoteid);
		$currencyid = $quote_focus->column_fields['currency_id'];
		$rate = $quote_focus->column_fields['conversion_rate'];
		$smarty->assign("QUOTE_ID", $focus->column_fields['quote_id']);
	//	$smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($quote_focus,'module_create'));
       
		$smarty->assign("MODE", $quote_focus->mode);
                $selectAccountIDSQL='SELECT accountid,contactid
            FROM ld_quotes 
             where quoteid='.$focus->column_fields['quote_id'];
        $resultINFO = $adb->pquery($selectAccountIDSQL,array());
		$_REQUEST['fromid']=$quoteid;
	}

}
if (isset ($_REQUEST['fromid']) && $_REQUEST['fromid'] != ''&& $_REQUEST['fromid'] != 0) {
    if($_REQUEST['frommodule']=='')
		$frommodule = getSalesEntityType($_REQUEST['fromid']);
    else
        $frommodule=$_REQUEST['frommodule'];
}
        
if (isset ($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true') {
	$focus->id = $_REQUEST['record'];
	$smarty->assign("DUPLICATE_FROM", $focus->id);
    crm_load_function_file('getInventoryCurrencyInfo','include/utils','InventoryUtils');
    $inventory_cur_info = getInventoryCurrencyInfo($currentModule, $focus->id);
	$currencyid = $inventory_cur_info['currency_id'];
	$productdetailhtml_focus = $focus;
    $productdetail_mode = 'edit';
	//$smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($focus,'edit'));//复制
	$focus->id = "";
	$focus->mode = '';
	$smarty->assign("MODE", $focus->mode);
	/**
	 * 复制时，负责人设置为自己
	 * @author Tujt 2015-07-20
	 */
      //单据复制，默认值设置,https://www.tapd.cn/my_worktable?source_user=2004112531&workspace_id=20699121&workitem_type=story&workitem_id=1120699121001000517#&filter_close=true
	//$focus->column_fields['assigned_user_id'] = $current_user->id;
}else{
	//报价单关联创建合同订单,选择报价单
	if(isset ($_REQUEST['quoteid']) && $_REQUEST['quoteid'] != ''){
		$_REQUEST['quote_id'] = $_REQUEST['quoteid'];
	}
   if ($frommodule == 'QuotesChange') {
	//	$frommodule = getSalesEntityType($_REQUEST['fromid']);
        
		if($frommodule == 'QuotesChange'){
			$quotechange_id = $_REQUEST['fromid'];
			$focus->column_fields['quote_id'] = $quotechange_id;
			$quotechange_focus = CRMEntity::getInstance('QuotesChange');
			$quoteidstr = getLineitemId($quotechange_id,$quotechange_focus->moduleName);
			$quotechange_focus->lineitemIds = $quoteidstr;
			$quotechange_focus->mode = 'edit';
			$quotechange_focus->id=$quotechange_id;
			$quotechange_focus->retrieve_entity_info($quotechange_id, "QuotesChange");
			$currencyid = $quotechange_focus->column_fields['currency_id'];
			$rate = $quotechange_focus->column_fields['conversion_rate'];
		   
			$productdetailhtml_focus = $quotechange_focus;
            $productdetail_mode = 'module_create';
        	//$smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($quotechange_focus,'module_create'));
			$smarty->assign("CONVERT_MODE", vtlib_purify($_REQUEST['convertmode']));
		}
	}else if (isset ($_REQUEST['product_id']) && $_REQUEST['product_id'] != '') {
		$focus->column_fields['product_id'] = $_REQUEST['product_id'];
		$productdetailhtml_focus = $focus;
        $productdetail_mode = 'product_create';
    	//$smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($focus,'product_create'));//产品关联创建
        $smarty->assign('FROM_MODULE','Products');//
	}else{
		
			if(!empty($focus->id)){
			    $productdetailhtml_focus = $focus;
                $productdetail_mode = 'edit';
            	//$smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($focus,'edit'));//单据编辑
			}else{
				$productdetailhtml_focus = $focus;
                $productdetail_mode = 'create';
            	//$smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($focus,'create'));//单据新增
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
                    		    $productdetailhtml_focus=$tmp_focus;
                                $productdetail_mode='module_create';
                                break;
                            }
                        }
                    }
                 }
			}
		
		$smarty->assign("MODE", $focus->mode);
	}
}


$smarty->assign('ISADMIN',$current_user->is_admin);
$smarty->assign('SELECTSOURCENAME',$isSelectModule);
$smarty->assign('ISSOURCEMODULE',$isSelectModule);
if(empty($_REQUEST['record']) && $focus->mode != 'edit'){
	setObjectValuesFromRequest($focus);
}

/**
 * 创建单据时，编号为自动生成后的编号
 * @project 创建单据时，自动生成编号
 * @author Tujt 2014-05-13
 */
if($focus->mode!='edit'){
	$value = $focus->Library('SystemCode')->getModuleSeqNumRecord($_REQUEST['module']);
	if(!$value) $value = getFixedLabel('MSG_AUTO_GEN_ON_SAVE');
    $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey("uitype",4);
    if($fieldinfo)
    	$focus->column_fields[$fieldinfo->getFieldName()] = $value;
}
$theme_path = "themes/" . $theme . "/";
$image_path = $theme_path . "images/";
$disp_view = getView($focus->mode);
$mode = $focus->mode;


/* 关联创建单据统一处理方法 begin */
if(isset($_REQUEST['parent_id']) && $_REQUEST['parent_id'] > 0){
	$focus->getModuleLogic($currentModule)->setQuickCreateColumn($_REQUEST['parent_module'],$_REQUEST['parent_id']);
}
if(isset($_REQUEST['fromid']) && $_REQUEST['fromid'] > 0){
	$focus->getModuleLogic($currentModule)->setQuickCreateColumnValues($currentModule,$_REQUEST['fromid']);
}
$smarty->assign("upgradefrommodule",$_REQUEST['upgradefrommodule']);
$smarty->assign("upgradefromid",$_REQUEST['upgradefromid']);
//wym 240321 XUQIU20240204-09 销售线索可编辑追踪字段（把原先内容整理成方法）
if($_REQUEST['upgradefrommodule']!=''&&$_REQUEST['upgradefromid']>0) {
    crm_load_class_file('cls_MappingFields', 'modules/Leads');
    $cls_MappingFields = new cls_MappingFields($_REQUEST['upgradefrommodule']);
    //获取升级设置对应字段
    $mapped_arr = $cls_MappingFields->getMapfieldsTomodule($_REQUEST['upgradefromid'],$currentModule);
    $focus->column_fields=array_merge($focus->column_fields,$mapped_arr['mapped_column_fields']);
    $fieldjsondata=$mapped_arr['mapped_fieldjsondata'];
}

global $global_pick_list_values,$edit_column_fields_value;
$act_data=getBlocks($currentModule, $disp_view, $mode, $focus->column_fields);
$smarty->assign("COLUMN_FIELDS_VALUE",ldcrm_json_encode($edit_column_fields_value));
//zkt 20221219 必须放在getBlocks后边（因为明细字段的布局规则）
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
 $focus->mode='create';//@edit:liushuai,2021-07-06,reason:0046728: （81mis.com/kfbcrm）销售管理-合同，单据编号SO78，该单据处于审批中，复制该单据时，界面没有“保存并提交审批”按钮
}
$productFields['fields']=$ProductDetailsData->moduleProductToolField;
$productFields['system_deploy']=$ProductDetailsData->system_deploy_formulas;	//单据分录明细中录入价税合计重算的字段
$systemmethod = $ProductDetailsData->getSystemMethod();

$versiontrade=getVersionTradeInfo();
$smarty->assign('TRADEJIJIN',$versiontrade['trade']);
$productFields['trade']=$versiontrade['trade'];
$productFields['lengthdecimaldigits'] = $systemmethod['lengthdecimaldigits'];
$productFields['lengthprice'] = $systemmethod['lengthprice'];
$productFields['SystemArgument'] = $systemmethod['SystemArgument'];
$productFields['addproductrow'] = $systemmethod['addproductrow'];
$smarty->assign('PRODUCTFIELDSINFOJSON',ldcrm_json_encode($productFields));
$smarty->assign('BASECOLUMN',$ProductDetailsData->module_productbasefield);//计算公式中基准字段
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
$smarty->assign('BLOCKS',$act_data);
$smarty->assign("OP_MODE", $disp_view);

$smarty->assign("MODULE", $currentModule);


$category = getParentTab();
$smarty->assign("CATEGORY", $category);

if (isset ($focus->name))
	$smarty->assign("NAME", $focus->name);
else
	$smarty->assign("NAME", "");

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
$smarty->assign("MODULE", $currentModule);
$smarty->assign("PRINT_URL", "phprint.php?jt=" . session_id() . $GLOBALS['request_string']);
$smarty->assign("ID", $focus->id);
$tabid = getTabid($currentModule);

$data =$focus->fieldobj->split_validationdataArray();
$smarty->assign("VALIDATION_DATA_FIELDNAME", $data['fieldname']);
$smarty->assign("VALIDATION_DATA_FIELDDATATYPE", $data['datatype']);
$smarty->assign("VALIDATION_DATA_FIELDLABEL", $data['fieldlabel']);

global $adb;

if ($focus->mode == 'edit') {
	$inventory_cur_info = getInventoryCurrencyInfo($currentModule, $focus->id);
	$smarty->assign("INV_CURRENCY_ID", $inventory_cur_info['currency_id']);
} else {
	$smarty->assign("INV_CURRENCY_ID", $currencyid);
}
$smarty->assign("DUPLICATE",vtlib_purify($_REQUEST['isDuplicate']));
$smarty->assign("RELATEDCREATE",vtlib_purify($_REQUEST['relatedcreate']));
$smarty->assign('CREATEMODE', vtlib_purify($_REQUEST['createmode']));
global $global_pick_list_depencyfield;
crm_load_class_file('lingdang_DependencyPicklist','modules/PickList');
//$picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasource($currentModule);
//$smarty->assign("PICKIST_DEPENDENCY_DATASOURCE", ldcrm_json_encode($picklistDependencyDatasource));
$smarty->assign("PICKLISTDEPENCYFIELDS", ldcrm_json_encode($global_pick_list_depencyfield));

/*
edit:can
date:20130530
reason:创建和编辑权限分开
*/

if( (isset($_REQUEST['Create'])&&($_REQUEST['Create']=='true' || $_REQUEST['Create']=='yes'))||$_REQUEST['relatedcreate']=='yes'||$_REQUEST['isDuplicate']=='true'){
	$smarty->assign('CREATE','true');
}
else{
	$smarty->assign('CREATE','false');
}
if (isset($_REQUEST['record']) && $_REQUEST['record'] != '') {
    $smarty->assign("ACCOUNTID", $focus->column_fields['account_id']);
    $smarty->assign("CONTACTID", $focus->column_fields['contact_id']);
    $smarty->assign("POTENTIALID", $focus->column_fields['potential_id']);
}

if(!empty($_REQUEST['frommodule']) && $_REQUEST['frommodule'] == 'Accounts' && $_REQUEST['account_id'] > 0){
	$smarty->assign('FROM_MODULE',$_REQUEST['frommodule']);
}
$smarty->assign('ACCOUNTID',$focus->column_fields['account_id']);
$smarty->assign('CONTACTID',$focus->column_fields['contact_id']);
/**
 * @by andy
 * @date 20140729
 * @reason 系统编号改进
 */ 
$isallow= $focus->Library('SystemCode')->getModentityfield('isallow',$currentModule);
$smarty->assign('ISALLOW',$isallow);
//获取客户和联系人区块信息
$block_info = getBlockDisplayInfo('AccountContacts');
//显示位置
$smarty->assign('DISPLAY_POSITION',$block_info['display_position']);
 //是否显示
if($block_info['is_display'] == 0)
    $smarty->assign('BESTATUS','YES');
else
    $smarty->assign('BESTATUS','NO');
/**
 * 编辑、创建页面，增加更多信息左边栏
 * @author Tujt 2014-04-10
 */
$smarty->assign('CURRENT_DATE',date('Y-m-d',time()));
//获取版本类型
$version_info = getVersionInfo();
$smarty->assign('VERSIONINFO',$version_info);
$smarty->assign('VERSIONTRADE',$version_info['trade']);
//源美特殊控制
if($version_info['account'] == 'yuanmei'){
	$smarty->assign('ordertype_onclick',$focus->getOrdertypeByField());
}



$relmodule = (isset($currentModule))?$currentModule:$_REQUEST['module'];
$fields=$focus->fieldobj->getFieldListArray();
$fields['module']=$currentModule;
$smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));
$smarty->assign("MODULELINKFIELD",$focus->list_link_field);
$smarty->assign("SMOWNERCOLUMNNAME",$focus->getSmownerColumName());
$smarty->assign("IS_REL_LIST",isPresentRelatedLists($relmodule));
$smarty->assign("PICKLISTCONTENT",ldcrm_json_encode($global_pick_list_values));

///保存判断
$smarty->assign("VALIDATASAVE",ldcrm_json_encode(getValidataSave($currentModule)));


setGLobalURLSmarty($smarty);//设置js,css等访问路径
$ProductDetailsHtml->ProductDetailsData->productid;

//相关信息日期高级查询
//Crm_load_class_file("CommonView","modules/CustomView");
//$smarty->assign("DATETIMESTR",json_encode(CommonView::stdFilterDateTimeStr()));
$smarty->assign("ReferenceUitypes",cls_module_uitype::getAllUitypes());
$smarty->assign("UITYPEMODULES",cls_module_uitype::getUitypeModules());

 //布局规则
crm_load_class_file('cls_fieldrule','include/fields/fieldrule');
$fieldruleobj=cls_fieldrule::getInstance($currentModule);
$smarty->assign('jsonFieldRuleFieldNames',ldcrm_json_encode($fieldruleobj->getAllFieldNameSetChangeEvent()));//获取所有的触发字段
    /*
if($focus->mode == 'edit')
	$smarty->display("DetailView/InventoryEditView.tpl");
else
	$smarty->display('DetailView/InventoryCreateView.tpl');
*/
$arr = $ProductDetailsHtml->detailPopup($smarty,$fields,$productFields,$data);

$arr['upgradefromid']=0;
$arr['upgradefrommodule']='';
if($_REQUEST['upgradefrommodule']!=''&&$_REQUEST['upgradefromid']>0)
{
    $arr['isduplicate']='yes';
    $arr['upgradefromid']=$_REQUEST['upgradefromid'];
    $arr['upgradefrommodule']=$_REQUEST['upgradefrommodule'];
    $arr['upgradestatus']=$_REQUEST['upgradestatus'];

}
if(isset($_REQUEST['upgradetomodule'])&&$_REQUEST['upgradetomodule']!=''){
    $arr['upgradetomodule']=$_REQUEST['upgradetomodule'];
    $arr['upgradestatus']=$_REQUEST['upgradestatus'];
}
ConvertTojsonString(1,$arr,"success");
?>