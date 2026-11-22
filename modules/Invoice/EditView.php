<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
$setListVal = 0;
global $currentModule,  $current_user;
//require('user_privileges/user_language_'.$current_user->id.'.php');
$languageType=getLanguageType($current_user);
$focus = CRMEntity::getInstance($currentModule);
$smarty = new lingdangCRM_Smarty();
//added to fix the issue4600
$searchurl = getBasic_Advance_SearchURL();
$smarty->assign("SEARCH", $searchurl);
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
/**
* edit:chj
* date:2014-7-23
* reason:选择源单，获取多个源单模块
* */
$sourcemodules=getSourceModule($currentModule);
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
		$focus->retrieve_entity_info($_REQUEST['record'], "Invoice");
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

//@edit:liushuai,2021-03-18,reason:45015: （https://61mis.com/kfbcrm [^]）销售发票模块中新增了一个关联选择单据字段，对象是销售机会。网页端：选择销售机会，分录信息没有
$potentialdeployarray=getSys_deploy(205);//设置销售机会是否显示产品分录明细:0是，1否
$deploy_value=$potentialdeployarray['deploy_value'];
$smarty->assign('DEPLOY_VALUE_205',$deploy_value);
$isfromsourcemodule='no';
/*
edit:can
date:20130812
reason:4729: 新建帐套：合同订单明细界面关联创建 发票时，发票明细界面中 标题 自动带出显示了合同订单的标题

*/
 if(isset ($_REQUEST['convertmode']) && $_REQUEST['convertmode'] == 'sotoinvoice')
{
	
	$focus->column_fields['subject']='';
}
if (isset ($_REQUEST['opportunity_id']) && $_REQUEST['opportunity_id'] != '') {
	$potfocus =CRMEntity::getInstance('Potentials');
	$potfocus->column_fields['potential_id'] = $_REQUEST['opportunity_id'];
}
//report_sourceid 报表 传入的源单id
if((isset($_REQUEST['servicecontractsid'])&&$_REQUEST['servicecontractsid']!=''&&$_REQUEST['servicecontractsid']!='0') || !empty($_REQUEST['report_sourceid']))//服务合同创建收款单
{
    //edit:can reason:16271: 服务合同>明细>关联创建：创建单据，关联信息没有带过来。
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
else if($_REQUEST['fromid']>0&&$_REQUEST['frommodule']!='')
{
   
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
            $fromfocus=CRMEntity::getInstance($_REQUEST['frommodule']);
            $id=$_REQUEST['fromid'];
            $_REQUEST['selectsourcename']=$_REQUEST['frommodule'];
            
            $productsql='select lineitem_id from '.$fromfocus->Detail_table.' where id in ('.$id.')';
            $productresult=$adb->pquery($productsql,array());
            $withproductdetail='yes';
            foreach($sourcemodules as $sourcemoduleinfo)
            {
                if($sourcemoduleinfo['entitytype']==$_REQUEST['frommodule'])
                {
                    $withproductdetail=$sourcemoduleinfo['withdetail'];
                    
                    break;
                }
            }
            //if($withproductdetail=='yes')
            //{
                for($i=0;$i<$adb->num_rows($productresult);$i++)
                {
                   $_REQUEST['listval'].=$adb->query_result($productresult,$i,'lineitem_id').',';
                }
     }
     
    
   // }
    
}
$smarty->assign('ISADMIN',$current_user->is_admin);
/**
 *@edit: andy 
 *@date: 
 *@reason: related orders's information
 *@version: 
 */
if(isset($_REQUEST['selectsourcename']) && $_REQUEST['selectsourcename'] != ''
    && isset($_REQUEST['listval']) && $_REQUEST['listval'] !='')
{
}elseif(isset($_REQUEST['record']) && isset($_REQUEST['record']) > 0){//编辑,复制

    if(!isset($_REQUEST['salesorder_id']))//不是相关信息创建
    {
        crm_load_class_file("Detail_Edit_View",'include/utils');
        $isSourceModule = Detail_Edit_View::getInventoryField('entitytype',$_REQUEST['record']);//edit:can 014169: 销售发票--明细：复制功能错误。
        $relatedOrderIdStr=getDetailListValName($_REQUEST['record'],$isSourceModule,3);
        crm_load_class_file("Detail_Edit_View_finance",'include/utils');
      //  $relatedinformations=getRelatedOrderInformation($isSourceModule,str_replace('|',',',$relatedOrderIdStr),1);
 
   
        $relatedinformations=Detail_Edit_View_finance::getInvoice_SoureInfo($isSourceModule,str_replace('|',',',$relatedOrderIdStr));
        
        $smarty->assign("RELATEDORDERIDSTRING", str_replace('|',',',$relatedOrderIdStr));//源单id
    }
}else{
    
}
//end
global $theme;
$theme_path = "themes/" . $theme . "/";
$image_path = $theme_path . "images/";

$disp_view = getView($focus->mode);
$mode = $focus->mode;

/**
 * @by andy
 * @date 20140811
 * @reason 折扣税小计合计显示改进

$deployarray_42=getSys_deploy(42);
$deployarray_43=getSys_deploy(43);
$isShowNote1=$deployarray_42['deploy_value'];//是否显示小计、调整
$isShowNote2=$deployarray_43['deploy_value'];//是否显示税、折扣
$smarty->assign("IsShowNote1", $isShowNote1);
$smarty->assign("IsShowNote2", $isShowNote2);
 */
/**
 * @by andy
 * @date 20140729
 * @reason 系统编号改进
 */ 
$isallow= $focus->Library('SystemCode')->getModentityfield('isallow',$currentModule);
$smarty->assign('ISALLOW',$isallow);

/*---仓库信息---*/
require_once (globalStatic::$root_directory.'include/Stock/CommonStock.php');
$wareresult = selWareAll($current_user->id);
for($i = 0; $i<$adb->num_rows($wareresult); $i++)
{
    $wareArray[$adb->query_result($wareresult, $i, "id")] = $adb->query_result($wareresult, $i, "name");
}
$smarty->assign("WAREALL", $wareArray);

/**
 * 创建单据时，编号为自动生成后的编号
 * @project 创建单据时，自动生成编号
 * @author Tujt 2014-05-13
 */

if($focus->mode!='edit'||$_REQUEST['isDuplicate']=='true'){
	$value = $focus->Library('SystemCode')->getModuleSeqNumRecord($_REQUEST['module']);
	if(!$value) $value = getFixedLabel('MSG_AUTO_GEN_ON_SAVE');
	$focus->column_fields['invoice_no'] = $value;
}

/* 关联创建单据统一处理方法 end */

if($_REQUEST['isDuplicate'] == 'true'){
    // //单据复制，默认值设置,https://www.tapd.cn/my_worktable?source_user=2004112531&workspace_id=20699121&workitem_type=story&workitem_id=1120699121001000517#&filter_close=true
	//$focus->column_fields['assigned_user_id'] = $current_user->id;
	$value = $focus->Library('SystemCode')->getModuleSeqNumRecord($_REQUEST['module']);
	if(!$value) $value = getFixedLabel('MSG_AUTO_GEN_ON_SAVE');
	$focus->column_fields['invoice_no']=$value;
}
if(!empty($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == true){
	$disp_view = 'create_view';
}
//新增 - 中能
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
$smarty->assign("SINGLE_MOD", 'Invoice');

$smarty->assign("MOD", $mod_strings);
$smarty->assign("APP", $app_strings);
$smarty->assign('FROM_MODULE','');//关联创建采购订单，判断合同订单是从哪个模块创建的，字段公式会用到的,
                                  //  因为产品关联创建字段公式以不含税单价为基准


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
    //产品关联创建
    //@edit:liushuai,2021-03-16,reason:【ID1001451】产品管理单据查看详情界面，相关信息关联创建自动带出产品分录信息
    if($_REQUEST['frommodule']=='Products'&&$_REQUEST['fromid']>0)
    {
        $_REQUEST['product_id']=$_REQUEST['fromid'];
    }
	if (isset ($_REQUEST['product_id']) && $_REQUEST['product_id'] != '') {
		$focus->column_fields['product_id'] = $_REQUEST['product_id'];
        $productdetailhtml_focus = $focus;
        $productdetail_mode = 'product_create';
		//$smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($focus,'product_create'));//产品关联创建
        $smarty->assign('FROM_MODULE','Products');//
	}else{
	    if(isset ($_REQUEST['listval']) && $_REQUEST['listval'])
        {
            //33543: 销售发票编辑界面>新增一条销售发票填写资料，选择源单字段选择合同订单（有价格的订单）>保存>编辑刚才保存的单据>更改选择源单字段，将合同订单改为服务合同（选择有价格的单据>查看产品管理区块的小计：结果计算错误了。）
        }
        else
	       {
	           	if($focus->id > 0){
    	           	    $productdetailhtml_focus = $focus;
                        $productdetail_mode = 'edit';
                        //$smarty->assign("ASSOCIATEDPRODUCTS", $ProductDetailsHtml->getProductDetailsHtml($focus,'edit'));
            		}else{
      		            $productdetailhtml_focus = $focus;
                        $productdetail_mode = 'create';
            			//$smarty->assign("ASSOCIATEDPRODUCTS", $ProductDetailsHtml->getProductDetailsHtml($focus,'create'));
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
	}
}


if (isset ($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true') {
	$smarty->assign("DUPLICATE_FROM", $focus->id);
	//14169: 销售发票--明细：复制功能错误。,edit:can
    crm_load_class_file("Detail_Edit_View",'include/utils');
	$isSelectModule = Detail_Edit_View::getInventoryField('entitytype',$focus->id);
	$smarty->assign('LISTVAL_PURCHASEORDER_NO',getDetailListValName($focus->id,$isSelectModule,2));
	$focus->id = "";
	$focus->mode = '';
}
$smarty->assign("MODE", $focus->mode);
if (isset ($cust_fld)) {
	$smarty->assign("CUSTOMFIELD", $cust_fld);
}
if (isset ($_REQUEST['return_module']))
	$smarty->assign("RETURN_MODULE", vtlib_purify($_REQUEST['return_module']));
else
	$smarty->assign("RETURN_MODULE", "Invoice");
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
$tabid = getTabid("Invoice");
$data =$focus->fieldobj->split_validationdataArray();
//$category = getParentTab();
//$smarty->assign("CATEGORY", $category);
//
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
if (isset ($_REQUEST['quoteid']) && $_REQUEST['quoteid'] != '') {
	$quoteid = $_REQUEST['quoteid'];
	$quoteidstr = substrTd($quoteid . ',',0);
	$quote_focus = CRMEntity::getInstance('Quotes');
	$quote_focus->lineitemIds = $quoteidstr;
	$quote_focus->id = $quoteid;
	$quote_focus->retrieve_entity_info($quoteid, "Quotes");

	$focus->column_fields['quote_id']=$quote_focus->column_fields['quoteid'];
    $productdetailhtml_focus = $quote_focus;
    $productdetail_mode = 'module_create';
	//$smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($quote_focus,'module_create'));
}
/**
* edit:chj
* date:2014-1-14
* reason: 源单产品列显示
**/


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
    
    $productdetailhtml_focus = $so_focus;
    $productdetail_mode = 'sourcemodule_create';
    //$smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($so_focus,'sourcemodule_create'));
    $setListVal = count(explode(',',$so_focus->lineitemIds));
	$ids = explode(',',rtrim($_REQUEST['listval'],','));
    $source_detail_table=$so_focus->Detail_table;
    $query = " select id from $source_detail_table where lineitem_id = ? limit 1";
    $result = $adb->pquery($query,array(end($ids)));
    $selectRecordid = $adb->query_result($result,0,0);
	$so_focus->retrieve_entity_info($selectRecordid, $isSelectModule);
	$focus->column_fields['account_id']= $so_focus->column_fields['account_id'];
	$fieldinfo=$focus->getSourceFieldInfo();//获取原单字段信息
    if($fieldinfo&&$fieldinfo->getFieldName()!='')
        $focus->column_fields[$fieldinfo->getFieldName()]=$_REQUEST['fromid'];//关联创建原单
	
    
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
    
    $relatedinformations= Detail_Edit_View_finance::getInvoice_SoureInfo($isSelectModule,$sourceids);
   
}

if(!empty($entityid)){
	$_REQUEST['fromid'] = $entityid;
}
/* 关联创建单据统一处理方法 begin */
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
$smarty->assign("RELATEDORDERINFORMATION", $relatedinformations);//原单信息
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
 $focus->mode='create';//@edit:liushuai,2021-07-06,reason:0046728: （81mis.com/kfbcrm）销售管理-合同，单据编号SO78，该单据处于审批中，复制该单据时，界面没有“保存并提交审批”按钮
}
$productFields['fields']=$ProductDetailsData->moduleProductToolField;
//0044349: 自用系统（kfbcrm）系统设置-系统参数设置-设置单据分录明细最后一行录入产品后是否自动新增行：失效
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
	$smarty->assign('RICHTEXTCOUNT','');
}
$smarty->assign("BLOCKS", $act_data);
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
$smarty->assign('VERSIONINFO',$version_info);
$smarty->assign('VERSIONTRADE',$version_info['trade']);
//获取客户和联系人区块信息
$block_info = getBlockDisplayInfo('AccountContacts');
//显示位置
$smarty->assign('DISPLAY_POSITION',$block_info['display_position']);
 //是否显示
if($block_info['is_display'] == 0)
    $smarty->assign('BESTATUS','YES');
else
    $smarty->assign('BESTATUS','NO');
$fields=$focus->fieldobj->getFieldListArray();
//$fields['module']=$currentModule;
//$smarty->assign('RELATEDORDERINFORMATION',$obj_entity->showSourceHtml());//收款信息明细html
$smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));
$smarty->assign("MODULELINKFIELD",$focus->list_link_field);
$smarty->assign("SMOWNERCOLUMNNAME",$focus->getSmownerColumName());
/**
 * 编辑、创建页面，增加更多信息左边栏
 * @author Tujt 2014-04-11
 */
$relmodule = (isset($currentModule))?$currentModule:$_REQUEST['module'];
$smarty->assign("IS_REL_LIST",isPresentRelatedLists($relmodule));
$smarty->assign("PICKLISTCONTENT",ldcrm_json_encode($global_pick_list_values));

///保存判断


$smarty->assign("VALIDATASAVE",ldcrm_json_encode(getValidataSave($currentModule)));
//明细字段
$smarty->assign("TABDETAILFIELDS",ldcrm_json_encode($ProductDetailsHtml->ProductDetailsData->productToolFields->getFieldListArray()));
$smarty->assign("ACCOUNTID",$focus->column_fields['account_id']);
$smarty->assign("CONTACTID",$focus->column_fields['contact_id']);
setGLobalURLSmarty($smarty);//设置js,css等访问路径
$smarty->assign('FROMID',$_REQUEST['fromid']);

//相关信息日期高级查询
Crm_load_class_file("CommonView","modules/CustomView");
$smarty->assign("DATETIMESTR",json_encode(CommonView::stdFilterDateTimeStr()));
$smarty->assign("ReferenceUitypes",cls_module_uitype::getAllUitypes());
$smarty->assign("UITYPEMODULES",cls_module_uitype::getUitypeModules());
$smarty->assign('FROMID',$_REQUEST['fromid']);
 //布局规则
crm_load_class_file('cls_fieldrule','include/fields/fieldrule');
$fieldruleobj=cls_fieldrule::getInstance($currentModule);
$smarty->assign('jsonFieldRuleFieldNames',ldcrm_json_encode($fieldruleobj->getAllFieldNameSetChangeEvent()));//获取所有的触发字段
//editor:gyq_161 reason:带分录模块弹出层   2019/11/20 11:57
/*if($focus->mode == 'edit')
	$smarty->display("DetailView/InventoryEditView.tpl");
else
	$smarty->display('DetailView/InventoryCreateView.tpl');*/
$arr = $ProductDetailsHtml->detailPopup($smarty,$fields,$productFields,$data);
ConvertTojsonString(1,$arr,"success");
?>