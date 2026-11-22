<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
require_once ('include/Stock/CommonStock.php');
global $app_strings, $mod_strings, $theme, $currentModule, $current_user, $adb;
$focus = CRMEntity::getInstance($currentModule);
$smarty = new lingdangCRM_Smarty();
$salesorder_id = 0;
//added to fix the issue4600
$searchurl = getBasic_Advance_SearchURL();
$smarty->assign("SEARCH", $searchurl);
$languageType= getLanguageType($current_user);
$setListVal = 0;
//模块是否被激活
$smarty->assign('MODULE_ACTIVATE',vtlib_isModuleActive('SalesOrder'));
checkWarehouseUser();//判断仓库权限 tujt 2014-11-12
$theme_path = "themes/" . $theme . "/";
$image_path = $theme_path . "images/";
$sourcemodules=getSourceModule($currentModule);
$isfromsourcemodule='no';
/*
合同订单,服务合同  新增出库单
*/

if((isset($_REQUEST['fromid']) && $_REQUEST['fromid'] >0) )
{

		$salesorder_id = $_REQUEST['fromid'];
   
    
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
	   $_REQUEST['selectsourcename'] = $_REQUEST['frommodule'];
    
        $sourcefocus=CRMEntity::getInstance($_REQUEST['selectsourcename']);
        $sourcedetailtable=$sourcefocus->Detail_table;
        $productsql=" select lineitem_id from $sourcedetailtable where id=? ";
        $productresult=$adb->pquery($productsql,array($salesorder_id));
        for($i=0;$i<$adb->num_rows($productresult);$i++)
        {
            $_REQUEST['listval'].=$adb->query_result($productresult,$i,'lineitem_id').',';
        }
    }
}

/**
* edit:chj
* date:2014-7-23
* reason:选择源单，获取多个源单模块
* */

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
if(empty($selectSourceModuleName)){
	$selectSourceModuleName = $sourcemodules[0]['entitytype'];
}//
//$versiontrade=getVersionTradeInfo();
//$smarty->assign('VERSIONTRADE',$versiontrade['trade']);
//if($versiontrade['trade'] != 'sweepbarcode'){
//	if(empty($_REQUEST['record'])){
//		$_REQUEST['listval'] = '';
//	}
//}
//新增 - 中能
$VersionInfo = getVersionInfo();
if($VersionInfo['account'] == 'zhongneng' && $focus->mode == '' && empty($_REQUEST['isDuplicate']) && array_key_exists('wareid',$focus->column_fields)){
	$user_focus = CRMEntity::getInstance('Users');
	$user_focus->retrieve_entity_info($current_user->id, 'Users');
	$wareid = $user_focus->column_fields['wareid'];
	$focus->column_fields['wareid'] = $wareid;
}
if($VersionInfo['trade']=='zhongfu')
{
   $smarty->assign('cf_2444_image',$focus->getcf_2444_Image()) ;
}

if (isset ($_REQUEST['record']) && $_REQUEST['record'] != '') {
    crm_load_class_file("Detail_Edit_View",'include/utils');
    $isSelectModule = Detail_Edit_View::getInventoryField('entitytype',$_REQUEST['record']);
	if (isset ($_REQUEST['convertmode']) && $_REQUEST['convertmode'] == 'update_quote_val') {
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
		$quote_focus = new Quotes();
		$quote_focus->id = $quoteid;
		$quote_focus->retrieve_entity_info($quoteid, "Quotes");
		$focus = getConvertQuoteToSoObject($focus, $quote_focus, $quoteid);
		$focus->id = $_REQUEST['record'];
		$focus->mode = 'edit';
		$focus->name=$focus->column_fields[$focus->list_link_field];
	}else if(isset ($_REQUEST['convertmode']) && $_REQUEST['convertmode'] == 'special_update_quote_val'){//克莱门特：维修内容选择CCF单号，自动带出报损单产品明细（当前带出的数量不对）
		$so_focus = CRMEntity::getInstance('Quotes');
		$_REQUEST['selectsourcename'] = 'Quotes';
		$_REQUEST['listval'] = $focus->getQuotesForPotentials($_REQUEST['potential_id']);
		$_REQUEST['fromid'] = $_REQUEST['potential_id'];
	} else {
		$focus->id = $_REQUEST['record'];
       
		$focus->mode = 'edit';
		$focus->retrieve_entity_info($_REQUEST['record'], "OutboundOrder");
		$focus->name=$focus->column_fields[$focus->list_link_field];
        //require_once('modules/Approve/Approve.php');
        //$approve=new Approve();
		$approve = Approve::getInstance($currentModule);
        if(isset($_REQUEST['ajax']) && $_REQUEST['ajax']==true)
        {
            echo $approve->EditBlocks($focus->column_fields['assigned_user_id'],$focus->id);
            exit();
        }
	}
} else {
	if (isset ($_REQUEST['convertmode']) && $_REQUEST['convertmode'] == 'update_quote_val') {
		//Updating the Select Quote Value in Create Mode
		foreach ($focus->column_fields as $fieldname => $val){
			if (isset ($_REQUEST[$fieldname])){
				$value = $_REQUEST[$fieldname];
				$focus->column_fields[$fieldname] = $value;
			}
		}
		//Handling for dateformat in due_date lingdang_field
		if ($focus->column_fields['duedate'] != ''){
			$curr_due_date = $focus->column_fields['duedate'];
			$focus->column_fields['duedate'] = getValidDBInsertDateValue($curr_due_date);
		}
		
		$quoteid = $focus->column_fields['quote_id'];
		$quote_focus = CRMEntity::getInstance('Quotes');
		$quote_focus->id = $quoteid;
		$quote_focus->retrieve_entity_info($quoteid, "Quotes");
		crm_load_function_file("getConvertQuoteToSoObject","include/utils",'EditViewUtils');
		$focus = getConvertQuoteToSoObject($focus, $quote_focus, $quoteid);
		//Added to      the Quotes's associated lingdang_products -- when we select Quote in New SO page
		if (isset ($_REQUEST['quote_id']) && $_REQUEST['quote_id'] != ''){
			$productdetailhtml_focus = $quote_focus;
            $productdetail_mode = 'module_create';
        	//$smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($quote_focus,'module_create'));
		}

		$smarty->assign("QUOTE_ID", $focus->column_fields['quote_id']);
		$smarty->assign("MODE", $quote_focus->mode);
	}else if(isset ($_REQUEST['convertmode']) && $_REQUEST['convertmode'] == 'special_update_quote_val'){//克莱门特：维修内容选择CCF单号，自动带出报损单产品明细（当前带出的数量不对）
		$so_focus = CRMEntity::getInstance('Quotes');
		$_REQUEST['selectsourcename'] = 'Quotes';
		$_REQUEST['listval'] = $focus->getQuotesForPotentials($_REQUEST['potential_id']);
		$_REQUEST['fromid'] = $_REQUEST['potential_id'];
	}
}

$deployarray=getSys_deploy(10);	//出库或入库时必须严格参照源单（每种产品累计数量不允许超出源单或者出现源单外的产品）。0:是，1:否
$smarty->assign('PERODUCTDEPLOY',$deployarray['deploy_value']);
//19079: 合同订单>查看界面，关联创建中，创建 出库单，没有带出合同订单的客户联系人
if($focus->mode!='edit'||$_REQUEST['fromid']>0)
    setObjectValuesFromRequest($focus);//38282: （1.6）合同订单明细界面>相关>相关创建出库单：出库日期没有把默认值显示出来 ，直接新增出库单是有显示的。（需要补丁



/**
* edit:chj
* date:2014-1-14
* reason: 源单产品列显示
**/

if((isset ($_REQUEST['listval']) && $_REQUEST['listval'] != ""))
{
    $isSelectModule = $_REQUEST['selectsourcename'];
    $so_focus = CRMEntity::getInstance($isSelectModule);
    
    $so_focus->lineitemIds = rtrim($_REQUEST['listval'], ",");
    $so_focus->id=$_REQUEST['fromid'];
    $sourcedetailtable=$so_focus->Detail_table;
	$productdetailhtml_focus = $so_focus;
    $productdetail_mode = 'sourcemodule_create';
	//$smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($so_focus,'sourcemodule_create'));
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
		if($VersionInfo['account'] == 'zhongneng' && array_key_exists('wareid',$so_focus->column_fields) && array_key_exists('wareid',$focus->column_fields)){
			$focus->column_fields['wareid']= $so_focus->column_fields['wareid'];
		}
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
        $productdetailhtml_focus = $focus;
        $productdetail_mode = 'edit';
		//$smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($focus,'edit'));
	}else{
        $productdetailhtml_focus = $focus;
        $productdetail_mode = 'create';
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
            		    $productdetailhtml_focus=$tmp_focus;
                        $productdetail_mode='module_create';
                        break;
                    }
                }
            }
         }
	}
	
}
if(isset($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true') {//复制
	$smarty->assign("DUPLICATE_FROM", $focus->id);
	$focus->id = "";
    $focus->mode = '';
	/**
	 * 复制时，负责人设置为自己
	 * @author Tujt 2015-07-20
	 */
	//$focus->column_fields['assigned_user_id'] = $current_user->id;
}
//$smarty->assign('LISTALLVAL',$setListVal);
$smarty->assign('SELECTSOURCENAME',$isSelectModule);
$smarty->assign('ISSOURCEMODULE',$isSelectModule);
$smarty->assign("MODE", $focus->mode);
$smarty->assign('ISADMIN',$current_user->is_admin);
//产品关联创建 
if (isset ($_REQUEST['product_id']) && $_REQUEST['product_id'] != ''){
	$focus->column_fields['product_id'] = $_REQUEST['product_id'];
    $productdetailhtml_focus = $focus;
    $productdetail_mode = 'product_create';
	//$smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($focus,'product_create'));
}
// Get Account address if lingdang_account is given
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
	$focus->column_fields['out_no'] = $value;
}

if(isset($_REQUEST['account_id']) && $_REQUEST['account_id'] > 0){
	$focus->column_fields['account_id']=$_REQUEST['account_id'];//andy
}

/* 关联创建单据统一处理方法 begin */
if(isset($_REQUEST['parent_id']) && $_REQUEST['parent_id'] > 0){
	$focus->getModuleLogic($currentModule)->setQuickCreateColumn($_REQUEST['parent_module'],$_REQUEST['parent_id']);
}
if(isset($_REQUEST['fromid']) && $_REQUEST['fromid'] > 0){
	//订单下推发货申请单,自动将订单中的 付款方式、流水号,  带到发货申请单中
	if(!empty($_REQUEST['fromid']) && $_REQUEST['frommodule'] == 'SalesOrder' && get_versiontrade() == 'yangduan'){
		$query = 'select cf_2292,cf_2191 from ld_salesorder
		LEFT JOIN ld_salesordercf on ld_salesordercf.salesorderid = ld_salesorder.salesorderid 
		where ld_salesorder.salesorderid = ?';
		$result = $adb->pquery($query,array($_REQUEST['fromid']));
		$cf_2292 = $adb->query_result($result,0,0);
		$cf_2191 = $adb->query_result($result,0,1);
		$focus->column_fields['cf_2181'] = $cf_2292;
		$focus->column_fields['cf_2346'] = $cf_2191;
	}
	$focus->getModuleLogic($currentModule)->setQuickCreateColumnValues($currentModule,$_REQUEST['fromid']);
}
/* 关联创建单据统一处理方法 end */

/**
* 更新操作
* edit:can
* date:20131223
* reason:添加富文本框
* */
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
//0044349: 自用系统（kfbcrm）系统设置-系统参数设置-设置单据分录明细最后一行录入产品后是否自动新增行：失效
$productFields['system_deploy']=$ProductDetailsData->system_deploy_formulas;
$systemmethod = $ProductDetailsData->getSystemMethod();
$versiontrade=getVersionTradeInfo();
$smarty->assign('TRADEJIJIN',$versiontrade['trade']);
$productFields['trade']=$versiontrade['trade'];
$productFields['lengthprice'] = $systemmethod['lengthprice'];
$productFields['SystemArgument'] = $systemmethod['SystemArgument'];
$productFields['addproductrow'] = $systemmethod['addproductrow'];
$productFields['source_other_products'] = $deployarray['deploy_value'];
$smarty->assign('PRODUCTFIELDSINFOJSON',ldcrm_json_encode($productFields));
//计算公式中基准字段
$smarty->assign('BASECOLUMN',$ProductDetailsData->module_productbasefield);

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
$smarty->assign("SINGLE_MOD", 'OutboundOrder');


if (isset ($focus->name))
	$smarty->assign("NAME", $focus->name);
else
	$smarty->assign("NAME", "");

if (isset ($_REQUEST['convertmode']) && ($_REQUEST['convertmode'] == 'quotetoso' || $_REQUEST['convertmode'] == 'update_quote_val'))
{
	$txtTax = (($quote_focus->column_fields['txtTax'] != '') ? $quote_focus->column_fields['txtTax'] : '0.000');
	$txtAdj = (($quote_focus->column_fields['txtAdjustment'] != '') ? $quote_focus->column_fields['txtAdjustment'] : '0.000');
}
if (isset ($cust_fld))
{
	$smarty->assign("CUSTOMFIELD", $cust_fld);
}

if (isset ($_REQUEST['return_module']))
	$smarty->assign("RETURN_MODULE", vtlib_purify($_REQUEST['return_module']));
else
	$smarty->assign("RETURN_MODULE", "OutboundOrder");
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
$smarty->assign("MODULE", "OutboundOrder");
$smarty->assign("PRINT_URL", "phprint.php?jt=" . session_id() . $GLOBALS['request_string']);
$data =$focus->fieldobj->split_validationdataArray();

$smarty->assign("VALIDATION_DATA_FIELDNAME", $data['fieldname']);
$smarty->assign("VALIDATION_DATA_FIELDDATATYPE", $data['datatype']);
$smarty->assign("VALIDATION_DATA_FIELDLABEL", $data['fieldlabel']);
$smarty->assign('LISTALLVAL',$setListVal);
/*---仓库信息---*/
$wareresult = selWareAll();
for($i = 0; $i<$adb->num_rows($wareresult); $i++)
{
    $wareArray[$adb->query_result($wareresult, $i, "id")] = $adb->query_result($wareresult, $i, "name");
}
$smarty->assign("WAREALL", $wareArray);
$smarty->assign("DUPLICATE",vtlib_purify($_REQUEST['isDuplicate']));
$smarty->assign('CREATEMODE', vtlib_purify($_REQUEST['createmode']));
global $global_pick_list_depencyfield;
crm_load_class_file("lingdang_DependencyPicklist",'modules/PickList');
$picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasource($currentModule);

$smarty->assign("PICKIST_DEPENDENCY_DATASOURCE", ldcrm_json_encode($picklistDependencyDatasource));
$smarty->assign("PICKLISTDEPENCYFIELDS", ldcrm_json_encode($global_pick_list_depencyfield));
setGLobalURLSmarty($smarty);//设置js,css等访问路径
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
//获取版本类型
$version_info = getVersionInfo();
$smarty->assign('VERSIONTRADE',$version_info['trade']);
$smarty->assign('VERSION_ACCOUNT',$VersionInfo['account']);
$smarty->assign('VERSIONINFO',$version_info);
$smarty->assign("ACCOUNTID",$focus->column_fields['account_id']);
$smarty->assign("ACCOUNTNAME",getModuleHref('Accounts',$focus->column_fields['account_id']));
$smarty->assign('CONTACTID', $focus->column_fields['contact_id']);
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
$relmodule = (isset($currentModule))?$currentModule:$_REQUEST['module'];
//$smarty->assign("IS_REL_LIST",isPresentRelatedLists($relmodule));
$fields=$focus->fieldobj->getFieldListArray();
$fields['module']=$currentModule;
$smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));
$smarty->assign("MODULELINKFIELD",$focus->list_link_field);
$smarty->assign("SMOWNERCOLUMNNAME",$focus->getSmownerColumName());
$smarty->assign("PICKLISTCONTENT",ldcrm_json_encode($global_pick_list_values));
$smarty->assign('FROMID',$_REQUEST['fromid']);
///保存判断
$smarty->assign("VALIDATASAVE",ldcrm_json_encode(getValidataSave($currentModule)));
//明细字段
$smarty->assign("TABDETAILFIELDS",ldcrm_json_encode($ProductDetailsHtml->ProductDetailsData->productToolFields->getFieldListArray()));

//相关信息日期高级查询
//Crm_load_class_file("CommonView","modules/CustomView");
//$smarty->assign("DATETIMESTR",json_encode(CommonView::stdFilterDateTimeStr()));
$smarty->assign("ReferenceUitypes",cls_module_uitype::getAllUitypes());
$smarty->assign("UITYPEMODULES",cls_module_uitype::getUitypeModules());
 //布局规则
crm_load_class_file('cls_fieldrule','include/fields/fieldrule');
$fieldruleobj=cls_fieldrule::getInstance($currentModule);
$smarty->assign('jsonFieldRuleFieldNames',ldcrm_json_encode($fieldruleobj->getAllFieldNameSetChangeEvent()));//获取所有的触发字段

/*if($focus->mode == 'edit')
	$smarty->display("DetailView/InventoryEditView.tpl");
else
	$smarty->display('DetailView/InventoryCreateView.tpl');*/
//editor:gyq_161 reason:带分录模块弹出层   2019/11/14 11:09
$arr = $ProductDetailsHtml->detailPopup($smarty,$fields,$productFields,$data);
ConvertTojsonString(1,$arr,"success");
?>