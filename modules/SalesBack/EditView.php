<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global  $current_language, $currentModule, $theme,$current_user;
global $adb;

//require_once('Smarty_setup.php');
require('user_privileges/user_language_'.$current_user->id.'.php');
$focus = CRMEntity::getInstance($currentModule);
$smarty = new lingdangCRM_Smarty();

$category = getParentTab($currentModule);
$record = $_REQUEST['record'];


$isduplicate = vtlib_purify($_REQUEST['isDuplicate']);

/**
 * 获取系统参数 表体录入样式配置信息 1:外贸行业
 * @project PROT99 奥特林：产品明细录入改进
 * @author Tujt 2014-10-15
 */
$deployarray_52 = getSys_deploy(52);
global $productsdetailstyle;
$productsdetailstyle = 0;
if(1 == $deployarray_52['deploy_value']){
	$productsdetailstyle = 1;
}
$smarty->assign("PRODUCTSDETAILSTYLE", $productsdetailstyle);
checkWarehouseUser();//判断仓库权限 tujt 2014-11-12
//added to fix the issue4600
$searchurl = getBasic_Advance_SearchURL();
$smarty->assign("SEARCH", $searchurl);

//ls 20221101 Xuqiu1000213 服务回访单、销售退货单、采购退货单、销售退款单、采购退款单增加“新建”功能（销售退货单）
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
$ProductDetailsHtml = crm_load_class_obj('cls_productDetailsHtml',"modules/$currentModule/ProductDetails",array($currentModule));
$ProductDetailsData = crm_load_class_obj('cls_productDetailsData',"modules/$currentModule/ProductDetails",array($currentModule));
if (isset ($_REQUEST['record']) && $_REQUEST['record'] != '') {
    crm_load_class_file("Detail_Edit_View",'include/utils');
    $isSelectModule = Detail_Edit_View::getInventoryField('entitytype',$_REQUEST['record']);//编辑单据时单据的源单模块
    if (isset ($_REQUEST['convertmode']) && $_REQUEST['convertmode'] == 'update_so_val') {
        //Updating the Selected SO Value in Edit Mode
        foreach ($focus->column_fields as $fieldname => $val) {
            if (isset ($_REQUEST[$fieldname])) {
                $value = $_REQUEST[$fieldname];
                $focus->column_fields[$fieldname] = $value;
            }

        }
        //Handling for dateformat in lingdang_invoicedate ld_field
        if ($focus->column_fields['salesbackdate'] != '') {
            $curr_due_date = $focus->column_fields['salesbackdate'];
            $focus->column_fields['salesbackdate'] = DateTimeField::convertToDBFormat($curr_due_date);
        }

        $soid = $focus->column_fields['salesorder_id'];
        $so_focus = CRMEntity::getInstance($isSelectModule);
        $so_focus->id = $soid;
        $so_focus->retrieve_entity_info($soid, $isSelectModule);
        $focus = getConvertSoToInvoice($focus, $so_focus, $soid);
        $focus->id = $_REQUEST['record'];
        $focus->mode = 'edit';
        $focus->name = $focus->column_fields['subject'];
        $focus->column_fields['account_id']= $so_focus->column_fields['account_id'];
    } else {
        $focus->id = $_REQUEST['record'];
        $focus->mode = 'edit';
        $focus->retrieve_entity_info($_REQUEST['record'], $currentModule);
        //$focus->name = $focus->column_fields['subject'];
        //require_once('modules/Approve/Approve.php');
        //$approve=new Approve();
        $approve = Approve::getInstance($currentModule);
        if(isset($_REQUEST['ajax']) && $_REQUEST['ajax']==true){
            echo $approve->EditBlocks($focus->column_fields['assigned_user_id'],$focus->id);
            exit();
        }
    }
    $smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($focus,'edit'));
    $smarty->assign("CONTACTID",$focus->column_fields['contact_id']);
    $smarty->assign("ACCOUNTID",$focus->column_fields['account_id']);
}
else{
//    $currencyinfo = getModuleCurrencyInfo($_REQUEST['fromid'],'SalesOrder');

    if (isset ($_REQUEST['convertmode']) && $_REQUEST['convertmode'] == 'sotosalesback') {
        $soid = $_REQUEST['fromid'];
        $lineitemid = getLineitemId($soid,$_REQUEST['frommodule']);
        $so_focus =CRMEntity::getInstance($_REQUEST['frommodule']);
        $so_focus->lineitemIds = $lineitemid;
        $so_focus->retrieve_entity_info($soid, $_REQUEST['frommodule']);
        $so_focus->mode='edit';
        $so_focus->id=$soid;
        //added to set the PO number and terms and conditions
        $focus->column_fields['ld_purchaseorder'] = $so_focus->column_fields['ld_purchaseorder'];
        $focus->column_fields['terms_conditions'] = $so_focus->column_fields['terms_conditions'];
        $focus->column_fields['account_id']= $so_focus->column_fields['account_id'];

        //Added to display the SalesOrder's associated lingdang_products -- when we create lingdang_invoice from SO DetailView
        $txtTax = (($so_focus->column_fields['txtTax'] != '') ? $so_focus->column_fields['txtTax'] : '0.000');
        $txtAdj = (($so_focus->column_fields['txtAdjustment'] != '') ? $so_focus->column_fields['txtAdjustment'] : '0.000');
		$smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($so_focus,'module_create'));
    }
    elseif (isset ($_REQUEST['convertmode']) && $_REQUEST['convertmode'] == 'potentosalesback') {
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
        if ($focus->column_fields['salesbackdate'] != '') {
            $curr_due_date = $focus->column_fields['salesbackdate'];
            $focus->column_fields['salesbackdate'] = DateTimeField::convertToDBFormat($curr_due_date);
        }

        $soid = $focus->column_fields['salesorder_id'];
        $so_focus = CRMEntity::getInstance($_REQUEST['frommodule']);;
        $so_focus->id = $soid;
        $so_focus->retrieve_entity_info($soid, $_REQUEST['frommodule']);
        $focus = getConvertSoToInvoice($focus, $so_focus, $soid);
        $focus->id = $_REQUEST['record'];
        $focus->mode = 'edit';
        $focus->name = $focus->column_fields['subject'];
        $focus->column_fields['account_id']= $so_focus->column_fields['account_id'];
    }
}

/*if($_REQUEST['frommodule']=="SalesOrder")
{
    //合同订单相关信息创建销售退货单
    $_REQUEST['salesorder_id']=$_REQUEST['fromid'];
    $_REQUEST['convertmode']='sotosalesback';
}*/
/*if (isset($_REQUEST['salesorder_id']))
{
    $currencyinfo = getModuleCurrencyInfo($_REQUEST['salesorder_id'],'SalesOrder');
    $_REQUEST['fromid']=$_REQUEST['salesorder_id'];

    if (isset ($_REQUEST['convertmode']) && $_REQUEST['convertmode'] == 'sotosalesback') {
        $soid = $_REQUEST['salesorder_id'];
		$lineitemid = getLineitemId($soid,"SalesOrder");
        $so_focus =CRMEntity::getInstance('SalesOrder');
		$so_focus->lineitemIds = $lineitemid;
		$so_focus->retrieve_entity_info($soid, "SalesOrder");
		$so_focus->mode='edit';
        $so_focus->id=$soid;
		//added to set the PO number and terms and conditions
		$focus->column_fields['ld_purchaseorder'] = $so_focus->column_fields['ld_purchaseorder'];
		$focus->column_fields['terms_conditions'] = $so_focus->column_fields['terms_conditions'];
        $focus->column_fields['account_id']= $so_focus->column_fields['account_id'];
        
		//Added to display the SalesOrder's associated lingdang_products -- when we create lingdang_invoice from SO DetailView
		$txtTax = (($so_focus->column_fields['txtTax'] != '') ? $so_focus->column_fields['txtTax'] : '0.000');
		$txtAdj = (($so_focus->column_fields['txtAdjustment'] != '') ? $so_focus->column_fields['txtAdjustment'] : '0.000');
		$smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($so_focus,'module_create'));
	}
    elseif (isset ($_REQUEST['convertmode']) && $_REQUEST['convertmode'] == 'potentosalesback') {
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
		if ($focus->column_fields['salesbackdate'] != '') {
			$curr_due_date = $focus->column_fields['salesbackdate'];
			$focus->column_fields['salesbackdate'] = DateTimeField::convertToDBFormat($curr_due_date);
		}

		$soid = $focus->column_fields['salesorder_id'];
		$so_focus = CRMEntity::getInstance('SalesOrder');;
		$so_focus->id = $soid;
		$so_focus->retrieve_entity_info($soid, "SalesOrder");
		$focus = getConvertSoToInvoice($focus, $so_focus, $soid);
		$focus->id = $_REQUEST['record'];
		$focus->mode = 'edit';
		$focus->name = $focus->column_fields['subject'];
        $focus->column_fields['account_id']= $so_focus->column_fields['account_id'];
	}
}
//zkt 0047876: （81mis.com/kfbcrm）（需要补丁）库存管理-出库单相关创建销售退货单，界面一直空白转圈
// 除合同订单外模块关联创建销售退货单，显示产品分录
else if($_REQUEST['relatedcreate']=='yes'&& isset($_REQUEST['frommodule'])&&$_REQUEST['frommodule']!='SalesOrder' && $_REQUEST['Create']=='true'){
    $frommodule=$_REQUEST['frommodule'];
    $tmp_fromid=$_REQUEST['fromid'];
    $relate_focus = CRMEntity::getInstance($frommodule);
    $relate_focus->id=$tmp_fromid;
	$relate_focus->retrieve_entity_info($tmp_fromid, $frommodule);
    $smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($relate_focus,'module_create'));
}*/


$smarty->assign('ISADMIN',$current_user->is_admin);
$productFields['fields']=$ProductDetailsData->moduleProductToolField;
$productFields['system_deploy']=$ProductDetailsData->system_deploy_formulas;
$systemmethod = $ProductDetailsData->getSystemMethod();
$productFields['lengthdecimaldigits'] = $systemmethod['lengthdecimaldigits'];
$productFields['lengthprice'] = $systemmethod['lengthprice'];
$productFields['SystemArgument'] = $systemmethod['SystemArgument'];
$productFields['addproductrow'] = $systemmethod['addproductrow'];
$smarty->assign('PRODUCTFIELDSINFOJSON',ldcrm_json_encode($productFields));
$smarty->assign('BASECOLUMN',$ProductDetailsData->module_productbasefield);
if($focus->mode!='edit'||$_REQUEST['fromid']>0)//18554: 销售退货单>列表/明细：点击编辑按钮，结果：编辑界面，编号、合同订单、退货日期、客户名称都显示为空白。
    setObjectValuesFromRequest($focus);
$disp_view = getView($focus->mode);
//$disp_View:edit_view

//参考出库单  带出源单分录
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

/**
 * 创建单据时，编号为自动生成后的编号
 * @project 创建单据时，自动生成编号
 * @author Tujt 2014-05-13
 */
if($focus->mode!='edit'){
	$value = $focus->Library('SystemCode')->getModuleSeqNumRecord($_REQUEST['module']);
	if(!$value) $value = getFixedLabel('MSG_AUTO_GEN_ON_SAVE');
	$focus->column_fields['salesback_no'] = $value;
}

/* 关联创建单据统一处理方法 begin */
if(isset($_REQUEST['parent_id']) && $_REQUEST['parent_id'] > 0){
	$focus->getModuleLogic($currentModule)->setQuickCreateColumn($_REQUEST['parent_module'],$_REQUEST['parent_id']);
}
if(isset($_REQUEST['fromid']) && $_REQUEST['fromid'] > 0){
	$focus->getModuleLogic($currentModule)->setQuickCreateColumnValues($currentModule,$_REQUEST['fromid']);
}
/* 关联创建单据统一处理方法 end */
global $global_pick_list_values;
global $edit_column_fields_value;

/*if($focus->mode != 'edit'){
    //关联创建，新增 
	 global $current_user;
	crm_load_class_file('cls_ParentRelatedField_Data', 'include/RelatedField');
	$field = $focus->fieldobj->getFieldInfoobjBykey('columnname','smownerid');
	if(!empty($field)){
	   //fromid的判断不添加了，以后又问题再修改吧
       
		$fieldname = $field->getFieldName();
		$_REQUEST['selecttype'] = 'select';
		$cls_ParentRelatedFields = new cls_ParentRelatedField_Data($currentModule,$current_user->id, $fieldname);
		$relatedfielddata = $cls_ParentRelatedFields->getEffectValues('html_input');
		$effectfieldname_arr=[];
		if(!empty($relatedfielddata)){
			foreach($relatedfielddata as $key => $vals){
				$focus->column_fields[$vals['rawValue']['input_name']] = $vals['rawValue']['value'];
                $effectfieldname_arr[$vals['rawValue']['input_name']]= $vals['rawValue']['value'];
			}
            global $adb;
            
            $sql='select ld_field.fieldname from ld_related_field 

                inner join ld_field 
                on ld_field.fieldid=ld_related_field.trigger_fieldid
                where ld_field.tabid=?  group by fieldname';
            $tmpresult=$adb->pquery($sql,array(getTabid($currentModule)));
            $rows =$adb->num_rows($tmpresult);
            $effectfieldname1_arr=[];
            for($i=0;$i<$rows;$i++)
            {
                $tmp_effectname=$adb->query_result($tmpresult,$i,'fieldname');
              
                if(array_key_exists($tmp_effectname,$effectfieldname_arr))
                {
                    	$tmpvalue=$effectfieldname_arr[$tmp_effectname];
                        
                        $cls_ParentRelatedFields = new cls_ParentRelatedField_Data($currentModule,$tmpvalue, $tmp_effectname);
        				$relatedfielddata = $cls_ParentRelatedFields->getEffectValues('html_input');
        				if(!empty($relatedfielddata)){
        					foreach($relatedfielddata as $key => $vals){
        					    $effectfieldname1_arr[$vals['rawValue']['input_name']]=$vals['rawValue']['value'];
        						$focus->column_fields[$vals['rawValue']['input_name']] = $vals['rawValue']['value'];
        					}
        				}
                }
                else if ($_REQUEST[$tmp_effectname])
				{
					  $effectfieldname1_arr[$tmp_effectname]=$_REQUEST[$tmp_effectname];
				}
            }
            
            for($i=0;$i<$rows;$i++)
            {
                $tmp_effectname=$adb->query_result($tmpresult,$i,'fieldname');
                if(array_key_exists($tmp_effectname,$effectfieldname1_arr))
                {
                    	$tmpvalue=$effectfieldname1_arr[$tmp_effectname];
                        $cls_ParentRelatedFields = new cls_ParentRelatedField_Data($currentModule,$tmpvalue, $tmp_effectname);
        				$relatedfielddata = $cls_ParentRelatedFields->getEffectValues('html_input');
        				if(!empty($relatedfielddata)){
        					foreach($relatedfielddata as $key => $vals){
        					    $effectfieldname1_arr[$vals['rawValue']['input_name']]=$vals['rawValue']['value'];
        						$focus->column_fields[$vals['rawValue']['input_name']] = $vals['rawValue']['value'];
        					}
        				}
                }
                
            }
            
            
            
                
		}
	}
}*/
$act_data=getBlocks($currentModule, $disp_view, $focus->mode, $focus->column_fields);
$smarty->assign("COLUMN_FIELDS_VALUE",ldcrm_json_encode($edit_column_fields_value));
if(isset($_REQUEST['account_id']))
	$smarty->assign("ACCOUNTID",$_REQUEST['account_id']);
/**
* 更新操作
* edit:can
* date:20131223
* reason:添加富文本框
* */
if(isset($act_data['RichText']) && !empty($act_data['RichText'])){
	$richText = $act_data['RichText'];
	unset($act_data['RichText']);
	$smarty->assign('RICHTEXTBOX',implode(',',$richText));
	$smarty->assign('RICHTEXTCOUNT',sizeof($richText));
}else{
	$smarty->assign('RICHTEXTBOX','');
	$smarty->assign('RICHTEXTCOUNT','');
}
$smarty->assign('BLOCKS', $act_data);
    
$smarty->assign('OP_MODE',$disp_view);
$smarty->assign('APP', $app_strings);
$smarty->assign('MOD', $mod_strings);
$smarty->assign('MODULE', $currentModule);
/*---仓库信息---*/
//17381: 合同订单>明细,关于关联创建销售退货单选择仓库的问题 
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
$smarty->assign('DUPLICATE', $isduplicate);
$smarty->assign('SELECTSOURCENAME',$isSelectModule);
$smarty->assign('ISSOURCEMODULE',$isSelectModule);

if($focus->mode == 'edit' || $isduplicate) {
	$recordName = array_values(getEntityName($currentModule, $record));
	$recordName = $recordName[0];
	$smarty->assign('NAME', $recordName);
	//$smarty->assign('UPDATEINFO',updateInfo($record));
}

if(isset($_REQUEST['return_module']))    $smarty->assign("RETURN_MODULE", vtlib_purify($_REQUEST['return_module']));
if(isset($_REQUEST['return_action']))    $smarty->assign("RETURN_ACTION", vtlib_purify($_REQUEST['return_action']));
if(isset($_REQUEST['return_id']))        $smarty->assign("RETURN_ID", vtlib_purify($_REQUEST['return_id']));
if (isset($_REQUEST['return_viewname'])) $smarty->assign("RETURN_VIEWNAME", vtlib_purify($_REQUEST['return_viewname']));
if(isset($_REQUEST['SearchScope'])) $smarty->assign("SEARCHSCOPE",$_REQUEST['SearchScope']);

$tabid = getTabid($currentModule);
$validationArray =$focus->fieldobj->split_validationdataArray();
$smarty->assign("VALIDATION_DATA_FIELDNAME",$validationArray['fieldname']);
$smarty->assign("VALIDATION_DATA_FIELDDATATYPE",$validationArray['datatype']);
$smarty->assign("VALIDATION_DATA_FIELDLABEL",$validationArray['fieldlabel']);

global $global_pick_list_values;
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
}
else{
	$smarty->assign('CREATE','false');
}

/**
 * @by andy
 * @date 20140729
 * @reason 系统编号改进
 */ 
$isallow= $focus->Library('SystemCode')->getModentityfield('isallow',$currentModule);
$smarty->assign('ISALLOW',$isallow);

/**
* edit:chj
* date:2014-6-3
* reason:系统参数控制合同订单、报价单、发票等单据上成本、GP是否显示
*/
$smarty->assign('PRODUCTDETAILTYPE',$deployarray['deploy_value']);
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
 //editor:gyq_161 reason:带分录模块弹出层   2019/11/20 11:18
/*if($focus->mode == 'edit')
	$smarty->display("DetailView/InventoryEditView.tpl");
else
	$smarty->display('DetailView/InventoryCreateView.tpl');*/
$arr = $ProductDetailsHtml->detailPopup($smarty,$fields,$productFields,$data);
ConvertTojsonString(1,$arr,"success");
?>