<?php
/*+**********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ************************************************************************************/
 //zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $edit_column_fields_value,$currentModule;


require_once 'modules/lingdang/EditView.php';
$smarty->assign("COLUMN_FIELDS_VALUE",ldcrm_json_encode($edit_column_fields_value));
$potentialdeployarray=getSys_deploy(205);//设置销售机会是否显示产品分录明细:0是，1否
$deployarrays[205]=$potentialdeployarray['deploy_value'];
global $theme;
$theme_path = "themes/" . $theme . "/";
$image_path = $theme_path . "images/";
$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH", $image_path);
$ProductDetailsHtml = crm_load_class_obj('cls_productDetailsHtml',"modules/$currentModule/ProductDetails",array($currentModule));
$ProductDetailsData = crm_load_class_obj('cls_productDetailsData',"modules/$currentModule/ProductDetails",array($currentModule));
if(!empty($_REQUEST['return_id']) && !empty($_REQUEST['return_module'])) {
	$invModule = $_REQUEST['return_module'];
	$inventoryObj = CRMEntity::getInstance($invModule);
	$inventoryObj->retrieve_entity_info($_REQUEST['return_id'], $invModule);
	if(empty($_REQUEST['sc_related_to'])) {
		if(!empty($inventoryObj->column_fields['account_id'])) {
			$focus->column_fields['sc_related_to_type'] = 'Accounts';
			$focus->column_fields['sc_related_to'] = $inventoryObj->column_fields['account_id'];
		} else if(!empty($inventoryObj->column_fields['contact_id'])) {
			$focus->column_fields['sc_related_to_type'] = 'Contacts';
			$focus->column_fields['sc_related_to'] = $inventoryObj->column_fields['contact_id'];		
		}
	}
}
 
$smarty->assign("ACCOUNTID", $focus->column_fields['account_id']);
$smarty->assign("CONTACTID", $focus->column_fields['contact_id']);
$VersionInfo = getVersionInfo();
if (isset ($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true') {
	$smarty->assign("DUPLICATE_FROM", $focus->id);
    $focus->id = $_REQUEST['record'];
	$focus->mode = 'edit';
	$smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($focus,'edit'));
	$focus->id = "";
	$focus->mode = '';
}
else if (isset ($_REQUEST['convertmode']) && $_REQUEST['convertmode'] == 'update_potential_val') 
{       
    foreach ($focus->column_fields as $fieldname => $val) {
        			if (isset ($_REQUEST[$fieldname])) {
        				$value = $_REQUEST[$fieldname];
        				$focus->column_fields[$fieldname] = $value;
        			}
            }
            $tmp_fromid=$focus->column_fields['potential_id'];
			$potentials_focus = CRMEntity::getInstance('Potentials');
			$quoteidstr = getLineitemId($tmp_fromid,$potentials_focus->moduleName);
			$potentials_focus->lineitemIds = $quoteidstr;
			$potentials_focus->mode = 'edit';
			$potentials_focus->id=$tmp_fromid;
			$potentials_focus->retrieve_entity_info($tmp_fromid, $frommodule);
			$currencyid = $potentials_focus->column_fields['currency_id'];
			$rate = $potentials_focus->column_fields['conversion_rate'];
		   
			$smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($potentials_focus,'module_create'));
			$smarty->assign("CONVERT_MODE", vtlib_purify($_REQUEST['convertmode']));
}
else if(empty($_REQUEST['productid'])){
 
	if(!empty($_REQUEST['fromid']) && $_REQUEST['fromid'] > 0 && empty($_REQUEST['salesorder_id'])){
	   $frommodule=$_REQUEST['frommodule'];
      
       if(empty($frommodule))
            $frommodule='Quotes';
        //021574: 合同订单>查看明细界面：关联创建中点击【创建服务合同】，结果无法打开服务合同新增界面
            //说明	合同订单>查看明细界面
            $quote_focus = CRMEntity::getInstance($frommodule);
         if(get_file_address($frommodule,'ProductDetails')&&$frommodule!='ServiceCharge')
         {
              
              $frommodule= $_REQUEST['frommodule'];
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
            		    
            			$smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($potentials_focus,'module_create'));
            			$smarty->assign("CONVERT_MODE", vtlib_purify($_REQUEST['convertmode']));
                }
                else
                {
                        $quoteidstr = substrTd($_REQUEST['fromid'] . ',',0,$frommodule);
              
                		$quote_focus->lineitemIds = $quoteidstr;
                		$quote_focus->retrieve_entity_info($_REQUEST['fromid'], $frommodule);
                		$quote_focus->mode = 'edit';
                        $quote_focus->id=$_REQUEST['fromid'];
                		$focus = getConvertQuoteToSoObject($focus, $quote_focus, $_REQUEST['fromid']);
                		$currencyid = $quote_focus->column_fields['currency_id'];
                		$rate = $quote_focus->column_fields['conversion_rate'];
                       
                 	   $smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($quote_focus,'sourcemodule_create'));
                }
                $smarty->assign("SELECTSOURCENAME",$frommodule);
                $smarty->assign("LISTVAL",$_REQUEST['fromid']);
                $smarty->assign("LISTVAL_PURCHASEORDER_NO",$quote_focus->column_fields[$quote_focus->list_link_field]);
         }
         else
         {
                //21991: 联系人>查看明细界面，关联创建服务合同时，服务合同界面产品信息区块未显示输入框
                //24983: 销售机会明细：关联创建服务合同，新增界面产品信息栏没有显示录入产品的文本框

            	$smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($focus,'create'));
         }
	}else{
            //服务合同选择合同订单  - 单选
          
            if(!empty($_REQUEST['salesorder_id'])){
                $so_focus = CRMEntity::getInstance('SalesOrder');
                $so_focus->lineitemIds = getLineitemId($_REQUEST['salesorder_id'],"SalesOrder");
               
            	$so_focus->mode = 'edit';
                $so_focus->id=$_REQUEST['salesorder_id'];
				//克莱门特：仅当关联的销售合同的合同性质是”维保合同“时才能保存。
				if($VersionInfo['account'] == 'climaveneta'){
					$so_focus->retrieve_entity_info($_REQUEST['salesorder_id'], 'SalesOrder');
					$smarty->assign('ORDERTYPE',$so_focus->column_fields['cf_2323']);
					$smarty->assign('VERSION_ACCOUNT',$VersionInfo['account']);
				}
				//editor:gyq_112 reason:PC参考-选择合同订单带出分录值,  2019/5/16 17:13
            	$smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($so_focus,'sourcemodule_create'));
            }else{
               
                
                if(isset($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true')
            	{
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
	}
}

//@edit:liushuai,2021-03-16,reason:【ID1001451】产品管理单据查看详情界面，相关信息关联创建自动带出产品分录信息
if($_REQUEST['frommodule']=='Products'&&$_REQUEST['fromid']>0)
{
    $_REQUEST['product_id']=$_REQUEST['fromid'];
}
//产品关联创建服务合同，带出产品
if (isset ($_REQUEST['productid']) && $_REQUEST['productid'] != ''){
	$_REQUEST['product_id'] = $_REQUEST['productid'];  
}
if (isset ($_REQUEST['product_id']) && $_REQUEST['product_id'] != '') {
	$focus->column_fields['product_id'] = $_REQUEST['product_id'];
    $ProductDetailsHtml->tablecontents=[];
	$smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($focus,'product_create'));//产品关联创建
    $smarty->assign('FROM_MODULE','Products');
}


$productFields['fields']=$ProductDetailsData->moduleProductToolField;
$productFields['system_deploy']=$ProductDetailsData->system_deploy_formulas;
$systemmethod = $ProductDetailsData->getSystemMethod();
$productFields['lengthdecimaldigits'] = $systemmethod['lengthdecimaldigits'];
$productFields['lengthprice'] = $systemmethod['lengthprice'];
$productFields['SystemArgument'] = $systemmethod['SystemArgument'];
$productFields['addproductrow'] = $systemmethod['addproductrow'];
$smarty->assign('PRODUCTFIELDSINFOJSON',ldcrm_json_encode($productFields));
$smarty->assign('BASECOLUMN',$ProductDetailsData->module_productbasefield);//计算公式中基准字段
$smarty->assign("MODE", $focus->mode);
if ($focus->mode == 'edit') {
	$inventory_cur_info = getInventoryCurrencyInfo('ServiceContracts', $focus->id);
	$smarty->assign("INV_CURRENCY_ID", $inventory_cur_info['currency_id']);
} else {
	$smarty->assign("INV_CURRENCY_ID", $currencyid);
}
global $global_pick_list_depencyfield;
crm_load_class_file('lingdang_DependencyPicklist','modules/PickList');
$picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasource($currentModule);
$smarty->assign("PICKIST_DEPENDENCY_DATASOURCE", ldcrm_json_encode($picklistDependencyDatasource));
$smarty->assign("PICKLISTDEPENCYFIELDS", ldcrm_json_encode($global_pick_list_depencyfield));
/**
 * 编辑、创建页面，增加更多信息左边栏
 * @author Tujt 2014-04-10
 */
$relmodule = (isset($currentModule))?$currentModule:$_REQUEST['module'];
$smarty->assign("IS_REL_LIST",isPresentRelatedLists($relmodule));
$smarty->assign('VERSIONTRADE',$version_info['trade']);
$smarty->assign('VERSION_ACCOUNT',$VersionInfo['account']);
$smarty->assign('VERSIONINFO',$version_info);
/**
 * 客户编辑页面，增加更多信息左边栏
 * @author Tujt 2014-04-09
 */
 //获取客户和联系人区块信息
$block_info = getBlockDisplayInfo('AccountContacts');
//显示位置
$smarty->assign('DISPLAY_POSITION',$block_info['display_position']);
 //是否显示
if($block_info['is_display'] == 0)
    $smarty->assign('BESTATUS','YES');
else
    $smarty->assign('BESTATUS','NO');
$module = (isset($_REQUEST['module']))?$_REQUEST['module']:$currentModule;
$smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));
$smarty->assign("MODULELINKFIELD",$focus->list_link_field);
$smarty->assign("SMOWNERCOLUMNNAME",$focus->getSmownerColumName());
$smarty->assign("PICKLISTCONTENT",ldcrm_json_encode($global_pick_list_values));

///保存判断
$smarty->assign("VALIDATASAVE",ldcrm_json_encode(getValidataSave($currentModule)));
//明细字段
$smarty->assign("TABDETAILFIELDS",ldcrm_json_encode($ProductDetailsHtml->ProductDetailsData->productToolFields->getFieldListArray()));


crm_load_class_file("cls_strategy",'modules/Products');
$cls_strategy=new cls_strategy();
$smarty->assign("PRODUCTSTRATEGY",ldcrm_json_encode($cls_strategy->getstrategyByProductId($ProductDetailsHtml->ProductDetailsData->strategyproductids)));
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
$smarty->assign("jsondeployarrays", ldcrm_json_encode($deployarrays));
 $smarty->assign('DEPLOY_VALUE_205',$deployarrays[205]);
//editor:gyq_161 reason:带分录模块弹出层   2019/11/20 11:25
/*if($focus->mode == 'edit')
	$smarty->display("DetailView/InventoryEditView.tpl");
else
	$smarty->display('DetailView/InventoryCreateView.tpl');*/
$arr = $ProductDetailsHtml->detailPopup($smarty,$fields,$productFields,$data);
ConvertTojsonString(1,$arr,"success");
?>