<?php
/*+**********************************************************************************
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
global $current_language, $currentModule, $theme,$current_user;
global $adb;
//require_once('Smarty_setup.php');
crm_load_class_file('cls_SendCashBill_EntityHtml','modules/SendCashBill/EntityData');
$focus = CRMEntity::getInstance($currentModule);
$smarty = new lingdangCRM_Smarty();
$record = $_REQUEST['record'];
$isduplicate = vtlib_purify($_REQUEST['isDuplicate']);
//added to fix the issue4600
$searchurl = getBasic_Advance_SearchURL();
$smarty->assign("SEARCH", $searchurl);
//模块是否被激活
$smarty->assign('MODULE_ACTIVATE',vtlib_isModuleActive('PurchaseOrder'));
$convertmode=false;
//选择源单
$sourcemodules=getSourceModule($currentModule);
if(sizeof($sourcemodules)>0){
    $smarty->assign('MODULE_ACTIVATE',true);
}
$smarty->assign('SOURCEMODULE',$sourcemodules);
foreach($sourcemodules as $val){
    if($val['default'] == 1){
        $selectSourceModuleName = $val['entitytype'];
    }
    $entitypes[]=$val['entitytype'];
}
if(empty($selectSourceModuleName)){
	//$selectSourceModuleName = $sourcemodules[0]['entitytype'];
}
$default_selectSourceModule=$selectSourceModuleName;

if($record) {
	$focus->id = $record;
	$focus->mode = 'edit';
	$selectSourceModuleName = $focus->getSourceField('entitytype',$record);
    if(empty($selectSourceModuleName))
    {
        $selectSourceModuleName=$default_selectSourceModule;

    }
   
    
	$smarty->assign('LISTVAL_PURCHASEORDER_NO',getDetailListValName($record,$selectSourceModuleName,2));
    $smarty->assign('LISTALLVAL',getDetailListValName($record,$selectSourceModuleName,3));  //id
    if (isset ($_REQUEST['convertmode']) && $_REQUEST['convertmode'] == 'update_so_val'){
        foreach ($focus->column_fields as $fieldname => $val) {
            if (isset ($_REQUEST[$fieldname])){
                $value = $_REQUEST[$fieldname];
                $focus->column_fields[$fieldname] = $value;
            }
        }
    }else {
        $focus->retrieve_entity_info($record, $currentModule);
        $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey('columnname',$focus->getSmownerColumName());
         if($focus->column_fields[$fieldinfo->getFieldName()]!=$current_user->id)
         {
          
                crm_load_class_file('cls_CurUserDataScope','include/ListView');
                $datascopeobj=cls_CurUserDataScope::getInstance($currentModule,'record');
                $datascopeobj->isMyViewData($_REQUEST['record']);
         }
    }
    $smarty->assign('CURRENCYID',$focus->column_fields['currency_id']); 
	
	if($isduplicate)
    {
        //037436: 单据复制默认值问题：费用报销单、加班单、请假单，自定义表单10-20，日期、日期时间类型的字段复制的时候带出了原来的值
        $focus->mode='create';
        $focus->id=0;
    }
}
else{
    $focus->mode = 'create';
}
if(empty($_REQUEST['record']) && $focus->mode != 'edit'){
	setObjectValuesFromRequest($focus);
}
//第二次选择原单
if(!empty($_REQUEST['Ajax']) && $_REQUEST['Ajax'] == 'yes' && !empty($_REQUEST['idstring'])){
	$_REQUEST['listval'] = $_REQUEST['idstring'];
	$selectSourceModuleName = $_REQUEST['sourcemodule'];
}else{
	//获取选择的源单tab
   
    
	if(!empty($_REQUEST['selectsource'])){
		$selectSourceModuleName = $_REQUEST['selectsource'];
	}else{
		if(isset($_REQUEST['selectsourcename'])){
			$selectSourceModuleName = $_REQUEST['selectsourcename'];
		}else{
			if($record)
				$selectSourceModuleName = $focus->getSourceField('entitytype',$record);
		}
	}
}
 
//相关信息、关联创建
if(!empty($_REQUEST['fromid']) && $_REQUEST['fromid'] > 0 && !empty($_REQUEST['frommodule'])){
	$selectSourceModuleName = $_REQUEST['frommodule'];
	$_REQUEST['selectsourcename']=$selectSourceModuleName;
    foreach($sourcemodules as $sourcemoduleinfo)
    {
        if($sourcemoduleinfo['entitytype']==$selectSourceModuleName)
        {
            if($selectSourceModuleName == 'SendPayment'){
        		$_REQUEST['listval'] = $_REQUEST['fromid'];
        	}else{
        		$_REQUEST['listval'] = getLineitemId($_REQUEST['fromid'],$selectSourceModuleName);
        	}
            break;
        }
    }
	
	$_REQUEST['relate_create'] = 1;
}
if(!empty($_REQUEST['fromid'])){
	 $relatedrecord=$_REQUEST['fromid'];
}
//关联创建
$issourcefrommodule='no';
if(!empty($_REQUEST['fromid']) && $_REQUEST['fromid'] > 0 && !empty($_REQUEST['frommodule'])){
	
	
	foreach($sourcemodules as $tmpsourceinfo)
	{
		if($tmpsourceinfo['entitytype']==$_REQUEST['frommodule'])
		{
			$issourcefrommodule='yes';
			break;
		}
		
	}
	if($issourcefrommodule=='yes')
	{
		$selectSourceModuleName = $_REQUEST['frommodule'];
		$_REQUEST['selectsourcename']=$selectSourceModuleName;
		if($selectSourceModuleName == 'SendPayment'){
			$_REQUEST['listval'] = $_REQUEST['fromid'];
		}else{
			$_REQUEST['listval'] = getLineitemId($_REQUEST['fromid'],$selectSourceModuleName);
		}
		
	}
	$_REQUEST['relate_create'] = 1;
}
//获取源单信息
$listval_ids = '';
if(!empty($_REQUEST['listval']) && $_REQUEST['listval'] != ''){
	$lineitem_ids = rtrim($_REQUEST['listval'],",");
	$lineitem_ids_arr = explode(',',$lineitem_ids);//lineitem_id
	if(!empty($selectSourceModuleName)){
		if(get_file_address($selectSourceModuleName,'ProductDetails')){
		    $source_focus=CRMEntity::getInstance($selectSourceModuleName);
            $source_focus->lineitemIds = $lineitem_ids;
            $source_focus->id=$_REQUEST['fromid'];
            $detailtable=$source_focus->Detail_table;
			$query = "select id,lineitem_id from $detailtable where lineitem_id in ($lineitem_ids)";
			$result = $adb->pquery($query,array());
			$num_rows = $adb->num_rows($result);
            $relatedrecord=$adb->query_result($result,0,'id');
            //$_REQUEST['fromid']=$adb->query_result($result,0,'id');//源单id
			for($i = 0; $i<$num_rows; $i++){
				$id = $adb->query_result($result,$i,'id');//源单id
                
				if($i == 0)$entitytypeid = $id;
				$entitytype_recordid[] = $id;
				$entitytype_no[] = getModuleHref($selectSourceModuleName,$id);//获取单据的超链接字段
			}
			
		}else{
		  $relatedrecord=$lineitem_ids_arr[0];
			for($i = 0; $i<count($lineitem_ids_arr); $i++){
				$entitytype_recordid[] = $lineitem_ids_arr[$i];
				$entitytype_no[] = getModuleHref($selectSourceModuleName,$lineitem_ids_arr[$i]);
			}
			$entitytypeid = $lineitem_ids_arr[0];
		}
		
		if($selectSourceModuleName == 'PurchaseInvoice' || $selectSourceModuleName == 'Stock'){
			$listval_ids = $lineitem_ids;
		}else{
			$listval_ids = implode(',',$entitytype_recordid);
		}
	}
  
	$entitytype_no = array_unique($entitytype_no);
	$entitytype_no = set_array_unique($entitytype_no);
	$smarty->assign('LISTALLVAL', implode(',', $entitytype_recordid));//源单id
	$smarty->assign('LISTVAL_PURCHASEORDER_NO',implode(',', $entitytype_no));
    $fieldinfo=$focus->getSourceFieldInfo();
     if($fieldinfo&&$fieldinfo->getFieldName()!='')
     {
         $focus->column_fields[$fieldinfo->getFieldName()]=$_REQUEST['fromid'];//关联创建原单
         if($selectSourceModuleName=='SendPayment')
         {
            //38651: (51mis.com/kfbcrm)财务管理>付款单：序列表点击“新增”字段，源单选择“付款计划”有错误。
            $focus->column_fields[$fieldinfo->getFieldName()]=$_REQUEST['listval'];//关联创建原单
         }
     }
    
	$smarty->assign('LISTVAL',$_REQUEST['listval']); 
    $productdetail_fromFocus = $source_focus;
    $productdetail_mode = 'sourcemodule_create';
	
}
//chj:获取币种ID
if(!isset($_REQUEST['currency_id'])){
    $_REQUEST['currency_id']=1;//edit:can 14638: 付款单-新增保存：提示：币种不能为空
}

if(isset($_REQUEST['record']) && $_REQUEST['record'] > 0&&empty($_REQUEST['listval'])){
	$currency_id = $focus->column_fields['currency_id'];
	$currency_info = getModuleCurrencyInfo($_REQUEST['record'],'SendCashBill');
	$currency_rate = $currency_info['rate'];
    
	$_REQUEST['sendcashbill_currency_id']=$currency_id;
    //获取源单所在的模块
    if(empty($selectSourceModuleName)&&!empty($focus->column_fields['selectlistval'])){
        $tmpselectlistval_arr = explode(',',$focus->column_fields['selectlistval']);
        $selectSourceModuleName = getSalesEntityType($tmpselectlistval_arr[0]);
    }
    $productdetail_fromFocus = $focus;
    $productdetail_mode = 'edit';
}else{
	//选择原单时，币种默认根据原单的第一条记录带出
    //$currency_info获取币种的汇率和币种符号   函数中不包括币种的ID
    //BUG20240315-07 ls 20240315 去掉带出负责人的关系（华雯妍）
	/*if(!empty($_REQUEST['listval']) && $_REQUEST['listval'] != ''&&empty($_REQUEST['Ajax'])){
		
		//0018288: 收款单和付款单-新增界面：选择源单后，负责人没有自动更新为第一个源单的负责人。
		$sql="select smownerid from ld_purchaseorder
			LEFT JOIN ld_purchaseorderdetail on ld_purchaseorderdetail.id = ld_purchaseorder.purchaseorderid 
			where lineitem_id=".substrTd($_REQUEST['listval'],1);
		$source_result=$adb->pquery($sql,array());
		if($adb->num_rows($source_result)>0)
			$focus->column_fields['assigned_user_id']=$adb->query_result($source_result,0,0);
	}*/
	//选择源单
	if(!empty($_REQUEST['listval']) && $_REQUEST['listval'] != ''&&empty($_REQUEST['Ajax']) && empty($_REQUEST['fromid'])){
		$sendpayemntids = explode(',',$ids);
		$currency_info = getModuleCurrencyInfo($sendpayemntids[0],$selectSourceModuleName);
		$focus->column_fields['currency_id'] = $currency_info['curid'];
	}else if(!empty($_REQUEST['fromid']) && $_REQUEST['fromid'] > 0 && !empty($_REQUEST['frommodule'])&&in_array($_REQUEST['frommodule'],$entitypes)){
		//如果采购订单关联创建并且源单默认是付款计划，按照付款计划的付款日期倒叙排序，默认取第一条
		if($_REQUEST['frommodule'] == 'PurchaseOrder' && $_REQUEST['quickcreate'] == 'yes' && $selectSourceModuleName == 'SendPayment' && $default_selectSourceModule == 'SendPayment'){
			$sendpayemntids = explode(',',$_REQUEST['listval']);
			$currency_info = getModuleCurrencyInfo($sendpayemntids[0],$selectSourceModuleName);
		}else{
		  
			$currency_info = getModuleCurrencyInfo($_REQUEST['fromid'],$_REQUEST['frommodule']);
		}
        //zkt 20220615 Bug0052656（https://81mis.com/kfbtest/index.php）采购订单》相关创建付款单，1、付款单币种没有按采购订单相关带出对应美元币种
        $focus->column_fields['currency_id'] = $currency_info['curid'];
		$_REQUEST['sendcashbill_currency_id'] = $currency_info['curid'];
	}else {
	   //供应商关联创建
	   if($_REQUEST['frommodule']!=''&&$_REQUEST['fromid']>0&&!in_array($_REQUEST['frommodule'],$entitytypes))
           {
                    $selectSourceModuleName=$default_selectSourceModule;
           }
		$currencyobj=Currency::getInstance($adb,$_REQUEST['currency_id']);
		$currency_info['rate'] = $currencyobj->getCurrencyRate();
		$currency_info['curid'] = $_REQUEST['currency_id'];//以界面的币种为标准（edit:can)

        if(!empty($selectSourceModuleName)){
            $from_focus = CRMEntity::getInstance($selectSourceModuleName);
        }else{
            $from_focus = CRMEntity::getInstance($currentModule);
        }
        $from_focus->id = $_REQUEST['fromid'];
        $productdetail_fromFocus = $from_focus;
        $productdetail_mode = 'sourcemodule_create';
    }
   
	if($currency_info == ''){
		$currency_id = 1;
		$currencyobj=Currency::getInstance($adb);
		$currencyobj=Currency::getInstance($adb);
		$currency_rate = $currencyobj->getCurrencyRate();
		$_REQUEST['sendcashbill_currency_id']=$currencyobj->getCurrencyId();
 	     // $smarty->assign('THHTML',$obj_entity->createHtml());//收款信息明细html
	}else{
		$currency_id = $currency_info['curid'];//edit:can reason:15139: 收款单/付款单>新增,关于选择源单带出币种的问题
		$currency_rate = $currency_info['rate'];
        $_REQUEST['sendcashbill_currency_id']=$currency_id;//edit:can reason:15195: 付款单>新增,关于本次收款金额计算错误的问题
       
	}
}
if (isset ($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true') {
	$focus->id = $_REQUEST['record'];
	$smarty->assign("DUPLICATE_FROM", $focus->id);
    crm_load_function_file('getInventoryCurrencyInfo','include/utils','InventoryUtils');
    $inventory_cur_info = getInventoryCurrencyInfo($currentModule, $focus->id);
	$currencyid = $inventory_cur_info['currency_id'];
    //复制,产品明细丢失
    $productdetail_fromFocus=$focus;
     
    $productdetail_mode='edit';
	$focus->id = "";
	$focus->mode = '';
    $smarty->assign("MODE", $focus->mode);
}
$totalnosendpaymentamount=0;
$totalhavesendpaymentamount=0;
$smarty->assign('ISADMIN',$current_user->is_admin);
if( $focus->mode == 'edit')
{
    $sqlpayment = 'select nosendpayment,total from ld_sendcashbill 
        where ld_sendcashbill.sendcashbillid=' . $record;
    $result = $adb->pquery($sqlpayment);
    $totalnosendpaymentamount = $adb->query_result($result,0,'nosendpayment'); 
    $totalall = $adb->query_result($result,0,'total');        
}
    
if($totalnosendpaymentamount >= 0)
	$smarty->assign('ISSELECT',1);  //增加
else
	$smarty->assign('ISSELECT',2);  //减少
$smarty->assign("SENDPAYMENTLIST",$trPayment);
$smarty->assign("TOTALSENDPAYMENTAMOUNT",$totalall);
$smarty->assign("TOTALHAVEESENDPAYMENTAMOUNT",$totalhavesendpaymentamount);
//echo $totalnosendpaymentamount;
if(empty($totalnosendpaymentamount))
{
    $totalnosendpaymentamount=0;
}
$smarty->assign("TOTALNOSENDPAYMENTAMOUNT",abs($totalnosendpaymentamount));

$smarty->assign('CURRENCYID',$currency_id);


$disp_view = getView($focus->mode);
//ls 20230208 BUG0061232 复制付款单，复制不出付款方法
/*if($isduplicate&&$focus->id<=0)
{
    $focus->column_fields["criscashbill"]="未开";
    $focus->column_fields["crpaymentmethod"]="现金";
}*/
$smarty->assign('SELECTSOURCENAME',$selectSourceModuleName);
/**
 * @by andy
 * @date 20140729
 * @reason 系统编号改进
 */ 
$isallow= $focus->Library('SystemCode')->getModentityfield('isallow',$currentModule);
$smarty->assign('ISALLOW',$isallow);


/* 关联创建单据统一处理方法 begin */
if(isset($_REQUEST['parent_id']) && $_REQUEST['parent_id'] > 0){
	$focus->getModuleLogic($currentModule)->setQuickCreateColumn($_REQUEST['parent_module'],$_REQUEST['parent_id']);
}

if($relatedrecord > 0){
    //带出相关信息
	$focus->getModuleLogic($currentModule)->setQuickCreateColumnValues($currentModule,$relatedrecord);
}

if(isset($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true') {
	$focus->id = "";
	$focus->mode = '';
//	$focus->column_fields['assigned_user_id'] = $current_user->id;
}
if($focus->mode!='edit'){
	$value = $focus->Library('SystemCode')->getModuleSeqNumRecord($_REQUEST['module']);
    
	if(!$value) $value = getFixedLabel('MSG_AUTO_GEN_ON_SAVE');
	$focus->column_fields['sendcashbill_no'] = $value;
}
global $global_pick_list_values,$edit_column_fields_value;
$act_data=getBlocks($currentModule, $disp_view, $mode, $focus->column_fields);
$smarty->assign("COLUMN_FIELDS_VALUE",ldcrm_json_encode($edit_column_fields_value));

//zkt 1000091 收付款单按产品明细收付款及增加单据分录定制功能 
//获取分录界面
if($isduplicate == 'true'){
    $focus->id=$_REQUEST['record'];//一定要这样，不然复制后明细没有了；
    $focus->mode = 'edit';
}
if(isset($_REQUEST['sourcemodule_changetype'])&&$_REQUEST['changeheader']=='true')
{
    $selectSourceModuleName=$_REQUEST['sourcemodule_changetype'];
    $productdetail_mode = 'sourcemodule_create';
    $productdetail_fromFocus=CRMEntity::getInstance($selectSourceModuleName);
    if(empty($selectSourceModuleName)){
        $productdetail_fromFocus = new stdClass();
    }else{
        $productdetail_fromFocus=CRMEntity::getInstance($selectSourceModuleName);
    }
    $productdetail_fromFocus->id = '';
    
}
$productdetail_fromFocusid=$productdetail_fromFocus->id;
$obj_entity=new cls_SendCashBill_EntityHtml($focus->id,$listval_ids,$selectSourceModuleName);

$withProductdetail  = $obj_entity->getSourceWithDetail($obj_entity->sourceModule);
if($withProductdetail  == 'yes'){
    $obj_entity->Detailobj->frommdouleFocus = $productdetail_fromFocus;
    $obj_entity->Detailobj->frommdouleFocus->id=$productdetail_fromFocusid;
    $obj_entity->Detailobj->productdetail_mode = $productdetail_mode;
    //wym 240411 BUG20240412-62 付款单新建界面，选择自动带出所选源单的产品分录的源单类型时，界面应该不显示“付款信息”区块
    $smarty->assign('DISPLAYTABDETAIL','no');
}
else{
    $obj_entity->Detailobj->entitytypeid = $entitytypeid;
    //zkt 20221121 BUG0058996kfbcrm  佣金单分录---增加引用字段，引用跟进记录里的联系方式，并保存数据库---当保存佣金单后，修改器源单跟进记录的联系方式字段---列表界面和编辑界面引用字段出现不统一
    if(!empty($_REQUEST['fromid']) && !empty($_REQUEST['frommodule'])&&$_REQUEST['relatedcreate']=='yes'){
    	$obj_entity->Detailobj->DetailsHtmlobj->tabDetailFieldData->row_mode = 'related_create';
    }
    $smarty->assign('DISPLAYTABDETAIL','yes');
}
$detailtablehtml = $obj_entity->createHtml();
$smarty->assign('THHTML',$detailtablehtml);//收款信息明细html

if($isduplicate == 'true') {
	$focus->id = '';
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
$smarty->assign('OP_MODE',$disp_view);
$smarty->assign('MODULE', $currentModule);

$fields=$focus->fieldobj->getFieldListArray();
$smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));
$smarty->assign("MODULELINKFIELD",$focus->list_link_field);
$smarty->assign("SMOWNERCOLUMNNAME",$focus->getSmownerColumName());

// TODO: Update Single Module Instance name here.
$smarty->assign('SINGLE_MOD', 'SINGLE_'.$currentModule);
$smarty->assign("THEME", $theme);
$smarty->assign('IMAGE_PATH', "themes/$theme/images/");
$smarty->assign('ID', $focus->id);
$smarty->assign('MODE', $focus->mode);
$smarty->assign('CREATEMODE', vtlib_purify($_REQUEST['createmode']));

//$smarty->assign('CHECK', Button_Check($currentModule));
$smarty->assign('DUPLICATE', $isduplicate);

if($focus->mode == 'edit' || $isduplicate) {
	$recordName = $focus->column_fields[$focus->list_link_field];
	$smarty->assign('NAME', $recordName);
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
global $global_pick_list_depencyfield;
crm_load_class_file("lingdang_DependencyPicklist",'modules/PickList');
$picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasource($currentModule);
$smarty->assign("PICKLISTDEPENCYFIELDS", ldcrm_json_encode($global_pick_list_depencyfield));
$smarty->assign("PICKIST_DEPENDENCY_DATASOURCE", ldcrm_json_encode($picklistDependencyDatasource));
//if($isduplicate){
//    $focus->column_fields['criscashbill']="未开";
//    $focus->column_fields['crpaymentmethod']="现金";
//}
$sendPayment_field_obj=Field::getInstance('SendPayment',$adb);
$arrpaymentLabel=$sendPayment_field_obj->getFieldLables();
if( (isset($_REQUEST['Create'])&&($_REQUEST['Create']=='true' || $_REQUEST['Create']=='yes')) ||$_REQUEST['isDuplicate']=='true'){
    $smarty->assign('CREATE','true');
}else{
    $smarty->assign('CREATE','false');
}
//$smarty->assign("RELATEDORDERINFORMATION", $obj_entity->showSourceHtml());//原单信息
$relmodule = (isset($_REQUEST['module']))?$_REQUEST['module']:$currentModule;
$smarty->assign("IS_REL_LIST",isPresentRelatedLists($relmodule));
$smarty->assign("PICKLISTCONTENT",ldcrm_json_encode($global_pick_list_values));
setGLobalURLSmarty($smarty);//设置js,css等访问路径


//相关信息日期高级查询
//Crm_load_class_file("CommonView","modules/CustomView");
//$smarty->assign("DATETIMESTR",json_encode(CommonView::stdFilterDateTimeStr()));
$smarty->assign("ReferenceUitypes",cls_module_uitype::getAllUitypes());
$smarty->assign("UITYPEMODULES",cls_module_uitype::getUitypeModules());

//新增、编辑单据可直接保存并提交审批
$approveobj=Approve::getInstance($currentModule);
$approve_arr=[];
global $weixin_user;
if($focus->id>0)
{
    if(!array_key_exists('approvestatus',$focus->column_fields)&&empty($focus->column_fields['approvestatus']))
    {
        //审批状态字段隐藏
        $sql= "select approvestatus from "  .$focus->table_name." where "  .$focus->table_index."=?";
        $result=$adb->pquery($sql,array($focus->id));
        $focus->column_fields['approvestatus']=$adb->query_result($result,0,0);

    }
    $status=$approveobj->getApproveStatus($focus->column_fields['approvestatus']);
    if($status==0||$status==3 ||$status==4 || ($status == 2 && $approveobj->recordAgainSubmit($currentModule)))
    {
        $weixin_user->action='default_on_submit';
        $weixin_user->environment='pc';
        $approve_arr=$approveobj->showSubmitPopup($currentModule,$smarty);
    }
}
else{
    $weixin_user->action='default_on_new';
    $weixin_user->environment='pc';
    $approve_arr=$approveobj->showSubmitPopup($currentModule,$smarty);

}
$smarty->assign("APPROVE_ARR",$approve_arr);

 //布局规则
crm_load_class_file('cls_fieldrule','include/fields/fieldrule');
$fieldruleobj=cls_fieldrule::getInstance($currentModule);
$smarty->assign('jsonFieldRuleFieldNames',ldcrm_json_encode($fieldruleobj->getAllFieldNameSetChangeEvent()));//获取所有的触发字段
//editor:gyq_161 reason:带分录模块弹出层   2019/11/27 13:46
//$smarty->display("DetailView/EditRelated.tpl");
$data = $focus->fieldobj->split_validationdataArray();
$fields=$focus->fieldobj->getFieldListArray();
$str=$smarty->fetch("DetailView/PopupEditRelated.tpl");
$_REQUEST['diony']='diony';

//wym BUG0074511 当关联创建模块包含附件或图片类型的引用字段时，focus对象上有fieldjsondata（此时foucs->id无值）
$fieldjsondata = empty($focus->fieldjsondata)?array():$focus->fieldjsondata;
if(($focus->id>0||$_REQUEST['record']>0)&&$focus->fieldobj->getFieldInfoBykeyValue('bigtype','fileattachment','fieldname')!='')
{
    if($focus->id>0){
        $tmp_record = $focus->id;
    }else if($_REQUEST['record']>0){ //edit:duan date:2021-9-30 复制的时候带出附件信息
        $tmp_record = $_REQUEST['record'];
    }
    $fieldjsondata=getAllFile_imageInfo($tmp_record,$currentModule);
}
$detailfilejsondata=array();
//edit: xll 2023/08/24 BUG0071518 服务合同（FWHT20230822214）单据编辑界面，分录明细附件字段没有显示上传的附件
$detailfilearr = $focus->detailfieldobj->getFieldInfoobjBykey_arr("bigtype", 'fileattachment');
$detailimagearr = $focus->detailfieldobj->getFieldInfoobjBykey_arr("bigtype", 'image');
if (($focus->id > 0) && (!empty($detailfilearr) || !empty($detailimagearr)) ) {
    if($focus->id>0){
        $tmp_record = $focus->id;
    }

    $detailfilejsondata=getAllDetailFile_imageInfo($tmp_record,$currentModule);
}
//zxm 2021-0902 结尾返回的arr提取
require_once 'modules/lingdang/CommonEditViewReturn.php';
$CommonEditViewReturnObj = new CommonEditViewReturn();
$arr = $CommonEditViewReturnObj->getReturnArr($focus);
    

$arr['detailfieldmodule']=$currentModule.'detailhtml';
$arr['isduplicate'] ='yes';
$arr['approve_arr']=$approve_arr;
$arr['content']='';
$arr['allcontent']=$str;
$arr['detailtablehtml']=$detailtablehtml;
$TabDetailFieldsobj = new TabDetailFields(getTabid($currentModule));
$TabDetailFieldsobj->setsourceModulesqlwhere($obj_entity->sourceModule);
$detailfieldruleobj=cls_detailfieldrule::getInstance($module);
$arr['detailfieldruleinfo']=$detailfieldruleobj->getFieldRuleProperty();
$detailfieldrulecolumn=$detailfieldruleobj->getAllFieldNameSetChangeEvent();//获取所有的触发明细字段;
$arr['detailfieldrulefieldnames']=$detailfieldrulecolumn;
$arr['detailfields']=$TabDetailFieldsobj->getFieldListArray();
$arr['fieldname']=$data['fieldname'];
$arr['datatype']=$data['datatype'];
$arr['fieldlabel']=$data['fieldlabel'];
$arr['fields']=$fields['fields'];
$arr['filejsondata']=$fieldjsondata;
$arr['detailfilejsondata']=$detailfilejsondata;
//$arr['columnfields_value']=$focus->column_fields;
$arr['picklistDependencyDatasource']=$picklistDependencyDatasource;
$arr['picklistcontent']=$global_pick_list_values;
$arr['picklistdepencyfields']=$global_pick_list_depencyfield;
crm_load_class_file('TabDetailFields','include/TabDetailFields');
$TabDetailFields = new TabDetailFields($tabid);
$TabDetailFields->setsourceModuleType($obj_entity->sourceModule);
$productFields['fields']=$TabDetailFields->getTabDetailFormulaField();
$versiontrade=getVersionTradeInfo();
$productFields['trade']=$versiontrade['trade'];
$arr['product_fields_info'] = $productFields;

$arr['detailtablename']=$focus->Detail_table;
$arr['detailtablenamescf']=$focus->Detail_table_scf;
$arr['warningmsg'] = '';

//布局规则
crm_load_class_file('cls_fieldrule','include/fields/fieldrule');
$fieldruleobj=cls_fieldrule::getInstance($currentModule);
$fieldrulenames =$fieldruleobj->getAllFieldNameSetChangeEvent();//获取所有的触发字段
$arr['fieldrulefieldnames'] = $fieldrulenames;

if($withProductdetail=='yes'){
    $arr['detailfieldmodule']='Products';
    $ProductDetailsHtml = $obj_entity->Detailobj->DetailsHtmlobj;
    $ProductDetailsData = $obj_entity->Detailobj->DetailsDataobj;
    
    $productFields['fields']=$ProductDetailsData->moduleProductToolField;
    $productFields['system_deploy']=$ProductDetailsData->system_deploy_formulas;	//单据分录明细中录入价税合计重算的字段
    $versiontrade=getVersionTradeInfo();
    $productFields['trade']=$versiontrade['trade'];
    $systemmethod = $ProductDetailsData->getSystemMethod();
    $productFields['lengthdecimaldigits'] = $systemmethod['lengthdecimaldigits'];
    $productFields['lengthprice'] = $systemmethod['lengthprice'];
    $productFields['SystemArgument'] = $systemmethod['SystemArgument'];
    $productFields['addproductrow'] = $systemmethod['addproductrow'];
    $arr['productfieldinfo']=$productFields;
    
    //zkt 20221008 BUG0057369收款单，选择合同后合同那个文本框里面是代码，分录信息没有带过来，看附件
    //获取下拉框字段
    crm_load_class_file('cls_PickList','modules/PickList');
    $picklistfield_arr=$ProductDetailsHtml->ProductDetailsData->productToolFields->geFieldInfoArrByProperty("uitype",60);
    $picklist = [];
    $picklistseq = [];
    foreach($picklistfield_arr as $tmpindex=>$detailfieldinfo)
    {
        if(!$detailfieldinfo)
            continue;//edit:can 2020-09-29 042830: （http://81.68.73.36:85/crm [^]）客户问题（刘家武的问题），客户单据查看详情界面，相关信息中关联创建合同订单，点击新建，界面一直显示加载中（仅普通成员有问题）
        $tmpcolumnname=$detailfieldinfo->getColumnName();
        $tmpfieldname=$detailfieldinfo->getFieldName();
        $picklist_array=[];
        if($tmpcolumnname=='wareid')
        {
            crm_load_function_file('getWareidAll','include/Stock','CommonStock');
            $allwarehouseinfo = getWareAllInfo($current_user);
            //edit:can 51424 （http://139.186.155.61:85/crm/）（客户问题-驼鹿超）用户在出库单选择入库源单时确定不了，在入库单详情可以创建出库单 
            $picklist[$tmpcolumnname]=[];
            foreach($allwarehouseinfo as $tmpidex=>$wareinfo)
            {
                $picklist[$tmpcolumnname][$wareinfo['name']]=$wareinfo['id'];
            }
        }
        else{
            $objPickList =cls_PickList::getInstance($tmpcolumnname,$focus->detailfieldobj);
			$picklistvalue = $objPickList->getPickListValues($tmpcolumnname,$detailfieldinfo,'','');


            $picklist_array[''] = '';
			if(!empty($picklistvalue)){
				foreach($picklistvalue as $key => $val){
					$picklist_array[$key] = $val;
				}
			}
			$picklist[$tmpcolumnname] = $picklist_array;
            //zkt 20240509 BUG20240509-23  收款单选择源单关联三个模块 销售合同、入伙管理、认购协议定金：单据分录：银行账号下拉框字段 添加下拉值与显示的值不一致，编辑下拉款 新增下拉框值 不显示付款单 也有类似问题（详情有视频）
            $tmppicklistseq  =array_keys($picklist_array);
            foreach($tmppicklistseq as &$tmpvalue){
                $tmpvalue .='';
            }
            $picklistseq[$tmpcolumnname] = $tmppicklistseq;
        }
        
    }
    global $global_picklist_colors_byvalue;
    $arr['global_picklist_colors_values']=$global_picklist_colors_byvalue;
    $arr['detailpicklist']=$picklist;
    $arr['detailpicklistseq']=$picklistseq;

    $arr['detailfields']=$ProductDetailsHtml->ProductDetailsData->productToolFields->getFieldListArray();
    $arr['detailfieldmodudle']='Products';
    $deploys=getSys_deploy(124);
    $base_column = $deploys['deploy_value'];
    //ls 2022-03-30 设置单据分录明细中产品管理的价格和金额计算时的基准字段  选择的基准字段分录不能隐藏，如果系统参数是不含税单价且不含税单价隐藏，则基准字段改为含税单价
    if ($base_column == 'listprice' && !empty($ProductDetailsHtml->ProductDetailsData->presenceToolField['listprice'])) {
        $base_column = 'listprice';
    }else{
        $base_column = 'taxprice';
    }
    ////edit:can 2020-10-12 产品分录明细：系统参数“价格和金额计算时的基准字段”设置为“不含税单价”，录入“税率”应反算“含税单价”
    $arr['baseColumn']=$base_column;
    crm_load_class_file("cls_strategy",'modules/Products');
    //价格策略
    $cls_strategy=new cls_strategy();
    $arr["productstrategyobj"]=$cls_strategy->getstrategyByProductId($ProductDetailsHtml->ProductDetailsData->strategyproductids);
    
    ////没有价税合计的字段权限
    $ProductToolFields = ProductToolFields::getInstance($currentModule);   
    $user_noprofile_fields = $ProductToolFields->user_noprofile_fields;
    $arr['noprofilefields']=$user_noprofile_fields;
    
    $arr['detailfieldruleinfo']=$ProductDetailsHtml->detailfieldruleobj->getFieldRuleProperty();
    $arr["relatedproducttoolfield"]=getRelatedProducttoolfield($currentModule);
    $arr['warningmsg'] = $ProductDetailsHtml->ProductDetailsData->warningmsg;
    $arr['detailtableindex']=$focus->Detail_table_id;
    if (is_array($detailfieldrulecolumn) && is_array($fieldrulenames)) {
        $fieldrulenames = array_merge($fieldrulenames, $detailfieldrulecolumn);
    } else if (is_array($detailfieldrulecolumn)) {
        $fieldrulenames = $detailfieldrulecolumn;
    }
    $arr['fieldrulefieldnames'] = $fieldrulenames;//获取所有的触发字段
    $arr['detaildatavalues'] = $ProductDetailsHtml->productToolFieldsValues;
}
$arr['from_module'] = $_REQUEST['frommodule'];
$fieldinfo=$focus->fieldobj->getFieldInfoobjBykey("bigtype",'selectsource');
if($fieldinfo&&$fieldinfo->getFieldName()!='')
{
    $arr['sourcemodule']=getSourceModule($currentModule);
}
//duan 20240124 在编辑页面结尾对返回值增加统一操作
$arr = $CommonEditViewReturnObj->setReturnArr($arr);

ConvertTojsonString(1,$arr,"success");
?>