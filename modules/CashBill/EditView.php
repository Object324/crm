<?php
//zkt 20231012 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();

global  $currentModule, $theme,$current_user;
global $adb;
crm_load_class_file('cls_CashBill_EntityHtml','modules/CashBill/EntityData');


$focus = CRMEntity::getInstance($currentModule);
$fieldobj=Field::getInstance($currentModule,$adb);
$smarty = new lingdangCRM_Smarty();
$languageType= getLanguageType($current_user);
$smarty->assign("LANGUAGETYPE",$languageType);

$record = $_REQUEST['record'];
$setListVal = 0;
$befidval = array();
$languageType= getLanguageType($current_user);
$smarty->assign("LANGUAGETYPE",$languageType);

$CashBilltype='cashbill';
$smarty->assign("CashBillType",'cashbill');
if($_REQUEST['cashbilltype'])
{
    //收款还是预收
    $smarty->assign("CashBillType",$_REQUEST['cashbilltype']);
    $CashBilltype=$_REQUEST['cashbilltype'];
    
}

$isduplicate = vtlib_purify($_REQUEST['isDuplicate']);
if($record>0||$isduplicate)
{
    $approve = Approve::getInstance($currentModule);
    
         if($_REQUEST['isDuplicate'] != 'true')
        {
            //判断是否已批准（是否允许编辑)
           $retapproveinfo= $focus->getModuleLogic($currentModule)->checkEditInfo($currentModule,$_REQUEST['record']);
            if($retapproveinfo!=''&&strtolower($retapproveinfo)!='success')
           {
             $_REQUEST['diony']='yes';
             ConvertTojsonString("-1",array(),$retapproveinfo);
           }
            
        }
        
    $sql='select cashtype from ld_cashbill  where cashbillid=?';
    $tmpresult=$adb->pquery($sql,array($record));
    $CashBilltype=$adb->query_result($tmpresult,0,0);
    $focus->column_fields['cashtype']=$adb->query_result($tmpresult,0,0);
    $smarty->assign("CashBillType",$adb->query_result($tmpresult,0,0));
}

$isduplicate = vtlib_purify($_REQUEST['isDuplicate']);
//选择源单
$sourcemodules=getSourceModule($currentModule);
if(sizeof($sourcemodules)>0){
    $smarty->assign('MODULE_ACTIVATE',true);
}
$smarty->assign('SOURCEMODULE',$sourcemodules);
$isfromsourcemodule='no';
 foreach($sourcemodules as $tmp=>$sourcemoduleinfo)
{
    if($_REQUEST['frommodule']==$sourcemoduleinfo['entitytype'])
    {
        $isfromsourcemodule='yes';
        break;
    }
}

foreach($sourcemodules as $val){
    if($val['default'] == 1){
        $selectSourceModuleName = $val['entitytype'];
    }
    $entitytypes[]=$val['entitytype'];
}
if(empty($selectSourceModuleName)){
	// $selectSourceModuleName = $sourcemodules[0]['entitytype'];
}
$default_selectSourceModuleName = $selectSourceModuleName;
if($CashBilltype=='debuction')
{
    $selectSourceModuleName='';
}
else{
    if(!empty($selectSourceModuleName)&&empty($record)){//新增收款单，没有选择源单字段权限，默认值应为空
        $fieldinfo = $fieldobj->getFieldInfoobjBykey('columnname','source_list');
        if(empty($fieldinfo)){
            $selectSourceModuleName='';
        }
    }
}

//相关信息、关联创建
if($isfromsourcemodule=='yes')
        if(!empty($_REQUEST['fromid']) && $_REQUEST['fromid'] > 0 && !empty($_REQUEST['frommodule'])){
        	$_REQUEST['selectsourcename']=$_REQUEST['frommodule'];
        	if($_REQUEST['selectsourcename'] == 'PaymentPlan'){
        		$_REQUEST['listval'] = $_REQUEST['fromid'];
        	}else{
        		$_REQUEST['listval'] = getLineitemId($_REQUEST['fromid'],$_REQUEST['selectsourcename']);
        	}
        	$_REQUEST['relate_create'] = 1;
        	$selectSourceModuleName = $_REQUEST['frommodule'];
        }

if($record) {
    
    //编辑代码要放在第二次选择原单代码签名，不然编辑界面重新选择别的模块原单回有bug,edit:can
	$focus->id = $record;
	$focus->mode = 'edit';
    $selectSourceModuleName = $focus->getSourceField('entitytype',$record);
    if(empty($selectSourceModuleName)){
		//$selectSourceModuleName	= $default_selectSourceModuleName;
	}
	$smarty->assign('LISTVAL_PURCHASEORDER_NO',getDetailListValName($record,$selectSourceModuleName,2));
    $smarty->assign('LISTALLVAL',getDetailListValName($record,$selectSourceModuleName,3));  //id
    if (isset ($_REQUEST['convertmode']) && $_REQUEST['convertmode'] == 'update_so_val'){
        foreach ($focus->column_fields as $fieldname => $val) {
            if (isset ($_REQUEST[$fieldname])) {
                $value = $_REQUEST[$fieldname];
                $focus->column_fields[$fieldname] = $value;
            }
        }
    }else{
        $focus->retrieve_entity_info($record, $currentModule);
         $_REQUEST['cashbilltype']=$focus->column_fields['cashtype'];
         $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey('columnname',$focus->getSmownerColumName());
         $CashBilltype=$focus->column_fields['cashtype'];
         if($focus->column_fields[$fieldinfo->getFieldName()]!=$current_user->id)
         {
          
                crm_load_class_file('cls_CurUserDataScope','include/ListView');
                $datascopeobj=cls_CurUserDataScope::getInstance($currentModule,'record');
                $datascopeobj->isMyViewData($_REQUEST['record']);
         }
    }
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

//第二次选择原单
if(!empty($_REQUEST['Ajax']) && $_REQUEST['Ajax'] == 'yes' && !empty($_REQUEST['idstring'])){
	$_REQUEST['listval'] = $_REQUEST['idstring'];
	$selectSourceModuleName = $_REQUEST['sourcemodule'];
}else{
	if($_REQUEST['action'] == 'CashBillAjax' && $_REQUEST['sourcemodule'] != ''){
		$selectSourceModuleName = $_REQUEST['sourcemodule'];  
	}else{
	  
    	if(isset($_REQUEST['selectsourcename'])){
    		$selectSourceModuleName = $_REQUEST['selectsourcename'];
    	}
	}
}
$searchurl = getBasic_Advance_SearchURL();
$smarty->assign("SEARCH", $searchurl);
if(empty($_REQUEST['record']) && $focus->mode != 'edit'){
	setObjectValuesFromRequest($focus);
    $focus->column_fields['cashtype']=$CashBilltype;
}
$convertmode=false;
$entityInfo = getEntitynameByModulename($selectSourceModuleName);
$fieldname = !empty($entityInfo['fieldname'])?$entityInfo['fieldname']:'';
$smarty->assign('ISADMIN',$current_user->is_admin);
//合同订单、服务合同关联创建 - 收款单
if(!empty($_REQUEST['fromid']) && $_REQUEST['fromid'] > 0 
&& !empty($_REQUEST['frommodule']) && $_REQUEST['quickcreate']=='yes' && ($_REQUEST['frommodule'] == 'SalesOrder' || $_REQUEST['frommodule'] == 'ServiceContracts') && $default_selectSourceModuleName=='PaymentPlan'){
	//源单类型默认为回款计划
	if(vtlib_isModuleActive('PaymentPlan') == 'yes'){
		$_REQUEST['selectsourcename']=$_REQUEST['frommodule'];
		$sql='select (paymentplanid)  from ld_paymentplan where entitytypeid=? 
                and deleted=0 and (paymentstatus = \'未收\' or paymentstatus = \'部分已收\')  order by plandate desc ';
        $result=$adb->pquery($sql,array($_REQUEST['fromid']));
        
        for($i=0;$i<$adb->num_rows($result);$i++){
            $paymentplanids[]=$adb->query_result($result,$i,0);
            
        }
        if(sizeof($paymentplanids)){
            $_REQUEST['selectsourcename']='PaymentPlan';
            $_REQUEST['listval']=implode(',',$paymentplanids);
        }
		$selectSourceModuleName = 'PaymentPlan';
	}else{
		$selectSourceModuleName = '';
	}
	$_REQUEST['relate_create'] = 1;
}
//获取源单信息
$listval_ids = '';
if (isset($_REQUEST['listval']) && $_REQUEST['listval'] != ''){
	$lineitem_ids = rtrim($_REQUEST['listval'],",");
	$lineitem_ids_arr = explode(',',$lineitem_ids);//lineitem_id
	$entitytypeid = 0;
	if(!empty($selectSourceModuleName)){
		if(get_file_address($selectSourceModuleName,'ProductDetails')){
		  $source_focus=CRMEntity::getInstance($selectSourceModuleName);
          $source_focus->lineitemIds = $lineitem_ids;
          $source_focus->id=$_REQUEST['fromid'];
          $detailtable=$source_focus->Detail_table;
			$query = "select id,lineitem_id from $detailtable where lineitem_id in ($lineitem_ids)";
			$result = $adb->pquery($query,array());
			$num_rows = $adb->num_rows($result);
			for($i = 0; $i<$num_rows; $i++){
				$id = $adb->query_result($result,$i,'id');//源单id
				if($i == 0)$entitytypeid = $id;
				$entitytype_recordid[] = $id;
				$entitytype_no[] = getModuleHref($selectSourceModuleName,$id);//获取单据的超链接字段
			}
		}else{
			for($i = 0; $i<count($lineitem_ids_arr); $i++){
				if($i == 0)$entitytypeid = $lineitem_ids_arr[$i];
				$entitytype_recordid[] = $lineitem_ids_arr[$i];
				$entitytype_no[] = getModuleHref($selectSourceModuleName,$lineitem_ids_arr[$i]);
			}
		}
		//获取选择源单关联带出值(客户)
		if($entitytypeid > 0){
			crm_load_class_file('cls_ParentRelatedFields','include/RelatedFields');
			$cls_tabledetail_focus=cls_ParentRelatedFields::getInstance("CashBill","$entitytypeid","");
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
			$_REQUEST['fromid'] = $entitytypeid;
            $_REQUEST['frommodule'] = $selectSourceModuleName;
           $fieldinfo=$focus->getSourceFieldInfo();
           if($fieldinfo&&$fieldinfo->getFieldName()!='')
                $focus->column_fields[$fieldinfo->getFieldName()]=$_REQUEST['fromid'];//关联创建原单
		}
		if($selectSourceModuleName == 'Invoice' || $selectSourceModuleName == 'OutboundOrder'){
			$listval_ids = $lineitem_ids;
		}else{
			$listval_ids = implode(',',$entitytype_recordid);
		}
	}
	$entitytype_no = array_unique($entitytype_no);
	$entitytype_no = set_array_unique($entitytype_no); 
	$smarty->assign('LISTALLVAL', implode(',', $entitytype_recordid));//源单id
	$smarty->assign('LISTVAL_PURCHASEORDER_NO',implode(',', $entitytype_no));
	$smarty->assign('LISTVAL',$_REQUEST['listval']); 

    $productdetail_fromFocus = $source_focus;
    
    $productdetail_mode = 'sourcemodule_create';
	
}
global $currency_info;
//根据源单获取币种
if($focus->mode == 'edit'&&empty($_REQUEST['listval'])){
	$currency_id = $focus->column_fields['currency_id'];
    $currency_info = getModuleCurrencyInfo($_REQUEST['record'],'CashBill');
    $_REQUEST['cashbill_currency_id']=$currency_id;
    //获取源单所在的模块
    if(empty($selectSourceModuleName)&&!empty($focus->column_fields['selectlistval'])){
        $tmpselectlistval_arr = explode(',',$focus->column_fields['selectlistval']);
        $selectSourceModuleName = getSalesEntityType($tmpselectlistval_arr[0]);
    }
    
    $productdetail_fromFocus = $focus;
    $productdetail_mode = 'edit';
}else{//0025716: 服务收费管理，客户：明细界面,关联创建收款单报错
	//相关创建带出源单的币种信息
	//选择源单

	if(!empty($_REQUEST['listval']) && $_REQUEST['listval'] != ''&&empty($_REQUEST['Ajax']) && empty($_REQUEST['fromid'])){
          
	}
	else if(!empty($_REQUEST['fromid']) && $_REQUEST['fromid'] > 0 && !empty($_REQUEST['frommodule'])&&in_array($_REQUEST['frommodule'],$entitytypes)){
		  
        if($default_selectSourceModuleName=='PaymentPlan' && $selectSourceModuleName == 'PaymentPlan' && ($_REQUEST['frommodule'] == 'SalesOrder' || $_REQUEST['frommodule'] == 'ServiceContracts')){
			$currency_info = getModuleCurrencyInfo($paymentplanids[0],'PaymentPlan');
		}else{
			$currency_info = getModuleCurrencyInfo($_REQUEST['fromid'],$_REQUEST['frommodule']);
		}
        $from_focus = CRMEntity::getInstance($selectSourceModuleName);
        $from_focus->id = $_REQUEST['fromid'];
        $productdetail_fromFocus = $from_focus;
     
        $productdetail_mode = 'sourcemodule_create';
	}else {
    	   if(!isset($_REQUEST['currency_id']))
           {
                $_REQUEST['currency_id']=1;
           }
           //客户，服务收费管理关联创建
           if($_REQUEST['frommodule']!=''&&$_REQUEST['fromid']>0&&!in_array($_REQUEST['frommodule'],$entitytypes))
           {
            $selectSourceModuleName=$default_selectSourceModuleName;
           }
		$currencyobj=Currency::getInstance($adb,$_REQUEST['currency_id']);
		$currency_info['rate'] = $currencyobj->getCurrencyRate();
		$currency_info['curid'] = $_REQUEST['currency_id'];  
        $from_focus = CRMEntity::getInstance($selectSourceModuleName);
        if(!empty($from_focus)){
            $from_focus->id = $_REQUEST['fromid'];
        }
        $productdetail_fromFocus = $from_focus;
        $productdetail_mode = 'sourcemodule_create';
      
    }
    
	if($currency_info == ''){
	   
		$currency_id = 1;
		$currencyobj=Currency::getInstance($adb);
		$currency_rate = $currencyobj->getCurrencyRate();
        $_REQUEST['cashbill_currency_id']=$currencyobj->getCurrencyId();
        //$smarty->assign('THHTML',$obj_entity->createHtml());//收款信息明细html
	}else{
		$_REQUEST['cashbill_currency_id']=$currency_info['curid'];
		$currency_id = $_REQUEST['cashbill_currency_id'];
		$currency_rate = $currency_info['rate'];
	}
    $focus->column_fields['currency_id']= $_REQUEST['cashbill_currency_id'];
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
$smarty->assign('CURRENCYID',$currency_id);

if($isduplicate == 'true') {
	$focus->id = '';
	$focus->mode = '';
}
$disp_view = getView($focus->mode);
//end
/**
 * @by andy
 * @date 20140729
 * @reason 系统编号改进
 */ 
$isallow= $focus->Library('SystemCode')->getModentityfield('isallow',$currentModule);
$smarty->assign('ISALLOW',$isallow);


/*if($isduplicate&&$focus->id<=0){
     //单据复制，默认值设置,https://www.tapd.cn/my_worktable?source_user=2004112531&workspace_id=20699121&workitem_type=story&workitem_id=1120699121001000517#&filter_close=true
	//$focus->column_fields['assigned_user_id'] = $current_user->id;
    $focus->column_fields["iscashbill"]="未开";
    $focus->column_fields["paymentmethod"]="现金";
}*/
if($focus->mode!='edit'){
	$value = $focus->Library('SystemCode')->getModuleSeqNumRecord($currentModule);
	if(!$value) $value = getFixedLabel('MSG_AUTO_GEN_ON_SAVE');
	$focus->column_fields['cashbill_no'] = $value;
}

if(isset($_REQUEST['PaymentPlan']) && $_REQUEST['accountid'] > 0)
	$focus->column_fields['account_id'] = $_REQUEST['accountid'];
    
if(isset($_REQUEST['account_id']) && $_REQUEST['account_id'] > 0 && $_REQUEST['Create'] == 'yes' && $_REQUEST['contact_id']==''){
    $accountid = $_REQUEST['account_id'];
    $account_focus = CRMEntity::getInstance('Accounts');
    $account_focus->id = $accountid;
    $account_focus->retrieve_entity_info($accountid, "Accounts");
    $focus->column_fields['assigned_user_id'] = $account_focus->column_fields['assigned_user_id'];
}

/* 关联创建单据统一处理方法 begin */
if(isset($_REQUEST['parent_id']) && $_REQUEST['parent_id'] > 0){
	$focus->getModuleLogic($currentModule)->setQuickCreateColumn($_REQUEST['parent_module'],$_REQUEST['parent_id']);
}
if(isset($_REQUEST['fromid']) && $_REQUEST['fromid'] > 0){
	$focus->getModuleLogic($currentModule)->setQuickCreateColumnValues($currentModule,$_REQUEST['fromid']);
}
if(!empty($_REQUEST['account_id']) && $_REQUEST['account_id'] > 0){
	$focus->column_fields['account_id'] = $_REQUEST['account_id'];
}


global $global_pick_list_values,$edit_column_fields_value;

$act_data=getBlocks($currentModule, $disp_view, $mode, $focus->column_fields);
$smarty->assign("COLUMN_FIELDS_VALUE",ldcrm_json_encode($edit_column_fields_value));

$focus->column_fields['bankaccountsetid']=$edit_column_fields_value['bankaccountsetid'][0];

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
    if(empty($selectSourceModuleName)){
        $productdetail_fromFocus = new stdClass();
    }else{
        $productdetail_fromFocus=CRMEntity::getInstance($selectSourceModuleName);
    }
    $productdetail_fromFocus->id = '';
    
}
$productdetail_fromFocusid=$productdetail_fromFocus->id;
 
$obj_entity=new cls_CashBill_EntityHtml($focus->id,$listval_ids,$selectSourceModuleName);
$withProductdetail  = $obj_entity->getSourceWithDetail($obj_entity->sourceModule);

if($withProductdetail  == 'yes'){
    $obj_entity->Detailobj->frommdouleFocus = $productdetail_fromFocus;
    $obj_entity->Detailobj->frommdouleFocus->id=$productdetail_fromFocusid;
    $obj_entity->Detailobj->productdetail_mode = $productdetail_mode;
    if(isset($_REQUEST['frompagetype'])&&$_REQUEST['frompagetype']=='edit'){
        $obj_entity->Detailobj->DetailsHtmlobj->pagetype = 'edit';
    }
    //wym 240411 BUG20240410-37 收款单新建界面，选择自动带出所选源单的产品分录的源单类型时，界面应该不显示“付款信息”区块
    $smarty->assign('DISPLAYTABDETAIL','no');
}
else{
    $obj_entity->Detailobj->entitytypeid = $entitytypeid;
    //zkt 20221121 BUG0058996kfbcrm  佣金单分录---增加引用字段，引用跟进记录里的联系方式，并保存数据库---当保存佣金单后，修改器源单跟进记录的联系方式字段---列表界面和编辑界面引用字段出现不统一
    if(!empty($_REQUEST['fromid']) && !empty($_REQUEST['frommodule'])&&$_REQUEST['relatedcreate']=='yes'){
    	$obj_entity->Detailobj->DetailsHtmlobj->tabDetailFieldData->row_mode = 'related_create';
    }
    if(isset($_REQUEST['frompagetype'])&&$_REQUEST['frompagetype']=='edit'){
        $obj_entity->Detailobj->DetailsHtmlobj->pagetype = 'edit';
    }
    $smarty->assign('DISPLAYTABDETAIL','yes');
}

$detailtablehtml = $obj_entity->createHtml();
$smarty->assign('THHTML',$detailtablehtml);//付款信息明细html

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
$smarty->assign('BLOCKS', $act_data);

$smarty->assign('OP_MODE',$disp_view);
$smarty->assign('MODULE', $currentModule);

// TODO: Update Single Module Instance name here.
$smarty->assign('SINGLE_MOD', 'SINGLE_'.$currentModule);

$smarty->assign("THEME", $theme);
$smarty->assign('IMAGE_PATH', "themes/$theme/images/");
$smarty->assign('ID', $focus->id);
$smarty->assign('MODE', $focus->mode);
$smarty->assign('CREATEMODE', vtlib_purify($_REQUEST['createmode']));
$smarty->assign('DUPLICATE', $isduplicate);

if($focus->mode == 'edit' || $isduplicate) {
	$recordName = $focus->column_fields[$focus->list_link_field];
	$smarty->assign('NAME', $recordName);
}

if(isset($_REQUEST['return_module']))$smarty->assign("RETURN_MODULE", vtlib_purify($_REQUEST['return_module']));
if(isset($_REQUEST['return_action']))$smarty->assign("RETURN_ACTION", vtlib_purify($_REQUEST['return_action']));
if(isset($_REQUEST['return_id']))$smarty->assign("RETURN_ID", vtlib_purify($_REQUEST['return_id']));
if (isset($_REQUEST['return_viewname']))$smarty->assign("RETURN_VIEWNAME", vtlib_purify($_REQUEST['return_viewname']));
if(isset($_REQUEST['SearchScope']))$smarty->assign("SEARCHSCOPE",$_REQUEST['SearchScope']);
// Field Validation Information
$tabid = getTabid($currentModule);

$validationArray =$focus->fieldobj->split_validationdataArray();
$smarty->assign("VALIDATION_DATA_FIELDNAME",$validationArray['fieldname']);
$smarty->assign("VALIDATION_DATA_FIELDDATATYPE",$validationArray['datatype']);
$smarty->assign("VALIDATION_DATA_FIELDLABEL",$validationArray['fieldlabel']);
global $global_pick_list_depencyfield;
crm_load_class_file("lingdang_DependencyPicklist",'modules/PickList');
$picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasource($currentModule);
$smarty->assign("PICKIST_DEPENDENCY_DATASOURCE", ldcrm_json_encode($picklistDependencyDatasource));
$smarty->assign("PICKLISTDEPENCYFIELDS", ldcrm_json_encode($global_pick_list_depencyfield));

$smarty->assign('SELECTSOURCENAME',$selectSourceModuleName);
$smarty->assign("ReferenceUitypes",cls_module_uitype::getAllUitypes());
$smarty->assign("UITYPEMODULES",cls_module_uitype::getUitypeModules());
if($record)
    $smarty->assign('ISSOURCEMODULE',$focus->getSourceField('entitytype',$record));
else
    $smarty->assign('ISSOURCEMODULE',$selectSourceModuleName);

/*
edit:can
date:20130530
reason:创建和编辑权限分开
*/
if( ($_REQUEST['relatedcreate']=='yes')|| $_REQUEST['isDuplicate']=='true'||(isset($_REQUEST['Create'])&&($_REQUEST['Create']=='true' || $_REQUEST['Create']=='yes')))
{
	$smarty->assign('CREATE','true');
}else{
	$smarty->assign('CREATE','false');
}
$smarty->assign("ACCOUNTID",$focus->column_fields['account_id']);
//获取客户和联系人区块信息
//$block_info = getBlockDisplayInfo('AccountContacts');
////显示位置
//$smarty->assign('DISPLAY_POSITION',$block_info['display_position']);
// //是否显示
//if($block_info['is_display'] == 0)
//    $smarty->assign('BESTATUS','YES');
//else
//    $smarty->assign('BESTATUS','NO');
$fields=$focus->fieldobj->getFieldListArray();
//$fields['module']=$currentModule;
//$smarty->assign('RELATEDORDERINFORMATION',$obj_entity->showSourceHtml());//收款信息明细html
$smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));
$smarty->assign("MODULELINKFIELD",$focus->list_link_field);
$smarty->assign("SMOWNERCOLUMNNAME",$focus->getSmownerColumName());
$relmodule = (isset($_REQUEST['module']))?$_REQUEST['module']:$currentModule;
//$smarty->assign("IS_REL_LIST",isPresentRelatedLists($relmodule));
$smarty->assign("PICKLISTCONTENT",ldcrm_json_encode($global_pick_list_values));
setGLobalURLSmarty($smarty);//设置js,css等访问路径
///保存判断
$smarty->assign("VALIDATASAVE",ldcrm_json_encode(getValidataSave($currentModule)));

 //布局规则
crm_load_class_file('cls_fieldrule','include/fields/fieldrule');
$fieldruleobj=cls_fieldrule::getInstance($currentModule);
$smarty->assign('jsonFieldRuleFieldNames',ldcrm_json_encode($fieldruleobj->getAllFieldNameSetChangeEvent()));//获取所有的触发字段
//editor:gyq_161 reason:带分录模块弹出层   2019/11/25 9:47
//$smarty->display("DetailView/EditRelated.tpl");
$data = $focus->fieldobj->split_validationdataArray();

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
        if(isset($weixin_user)){
          $weixin_user->action='default_on_submit';
          $weixin_user->environment='pc';
        }
          $approve_arr=$approveobj->showSubmitPopup($currentModule,$smarty);
    }
}
else{
    if(isset($weixin_user))
    {
        $weixin_user->action='default_on_new';
        $weixin_user->environment='pc';
    }
        $approve_arr=$approveobj->showSubmitPopup($currentModule,$smarty);
    
}
$smarty->assign("APPROVE_ARR",$approve_arr);
$str=$smarty->fetch("DetailView/PopupEditRelated.tpl");
$_REQUEST['diony']='diony';

$arr['detailfieldmodule']=$currentModule.'detailhtml';
$arr['isduplicate'] ='yes';
//wym BUG0074511 当关联创建模块包含附件或图片类型的引用字段时，focus对象上有fieldjsondata（此时foucs->id无值）
$fieldjsondata = empty($focus->fieldjsondata)?array():$focus->fieldjsondata;
//if($focus->id>0&&$focus->fieldobj->getFieldInfoBykeyValue("uitype",1109,'fieldname')!='')
//    $fieldjsondata[$focus->fieldobj->getFieldInfoBykeyValue("uitype",1109,'fieldname')]=json_decode( getAttachmentsTableInfo($focus->id,$currentModule));
//if($focus->id>0&&$focus->fieldobj->getFieldInfoBykeyValue("uitype",69,'fieldname')!='')
//    $fieldjsondata[$focus->fieldobj->getFieldInfoBykeyValue("uitype",69,'fieldname')]= json_decode(getImageFileInfo($focus->id,$currentModule));
//
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
$TabDetailFieldsobj = new TabDetailFields(getTabid($currentModule));
$TabDetailFieldsobj->setsourceModulesqlwhere($selectSourceModuleName);
if (isset($_REQUEST['is_linkmodulecustom']) && $_REQUEST['is_linkmodulecustom'] == '1') {
    require_once globalStatic::$root_directory . 'include/utils/cls_LinkModuleCustom.php';
    $arr['title'] = cls_LinkModuleCustom::getLinkModuleCustomTitle($currentModule);
} else {
    $arr['title'] = getTranstab($currentModule);
}
$arr['approve_arr']=$approve_arr;
//zxm 2021-0701 新建编辑页面增加页面设置按钮 判断是否有页面设置按钮
$settingsBtn = $focus->getModuleLogic($currentModule)->getSettingsBtn();
$is_page_setting = "no";
if(isset($settingsBtn['Settings'])&&$settingsBtn['Settings']['permit']=='yes'){
    $is_page_setting = "yes";
}
$arr['is_page_setting'] = $is_page_setting;
$arr['mainfieldformula']=$focus->fieldobj->getFormula();
$arr['savesubmittext']=getFixedLabel('SaveSubmitApprove');
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$arr['content']='';
$arr['allcontent']=$str;
$arr['detailtablehtml']=$detailtablehtml;
$arr['detailfields']=$TabDetailFieldsobj->getFieldListArray();
$arr['fieldname']=$data['fieldname'];
$arr['datatype']=$data['datatype'];
$arr['fieldlabel']=$data['fieldlabel'];

if($CashBilltype=='debuction'){
    //40907: (公司自用账套）收款单模块>新建预收单界面：无法录入和保存
    foreach($fields['fields'] as $fieldindex=>$tmp_arr){
        if($tmp_arr['bigtype']=='selectsource'){
            
            $fields['fields'][$fieldindex]['typeofdata']='V~O';
            break;
        }
    }
}
$detailfieldruleobj=cls_detailfieldrule::getInstance($module);
$arr['detailfieldruleinfo']=$detailfieldruleobj->getFieldRuleProperty();
$detailfieldrulecolumn=$detailfieldruleobj->getAllFieldNameSetChangeEvent();//获取所有的触发明细字段;
$arr['detailfieldrulefieldnames']=$detailfieldrulecolumn;
$arr['fields']=$fields['fields'];
$arr['filejsondata']=$fieldjsondata;
$arr['detailfilejsondata']=$detailfilejsondata;
$arr['isadmin']=$current_user->is_admin;
$arr['columnfields_value']=$focus->column_fields;
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



///保存判断
$arr["validatasave"]=getValidataSave($currentModule);
$arr["validatasaverule"]=getAllRule($currentModule);
//布局规则
crm_load_class_file('cls_fieldrule','include/fields/fieldrule');
$fieldruleobj=cls_fieldrule::getInstance($currentModule);
$fieldrulenames =$fieldruleobj->getAllFieldNameSetChangeEvent();//获取所有的触发字段
$arr['fieldrulefieldnames'] = $fieldrulenames;
//敏感规则 zkt 20231116 XUQIU1002041 单据头字段增加敏感规则设置，实现对单个字段的加密与编辑的控制
crm_load_class_file('cls_fieldSensitiverule','include/fields');
$fieldSensitiveruleobj=cls_fieldSensitiverule::getInstance($currentModule);
$arr['sensitiverelatedfield']=$fieldSensitiveruleobj->getAllRealtedfieldbyfieldname();//获取所有的触发字段
$arr['cashbilltype']=$CashBilltype;
$arr['warningmsg'] = '';

//duan 20240923 在编辑页面结尾对返回值增加统一操作
crm_load_class_file('CommonEditViewReturn','modules/lingdang');
$CommonEditViewReturnObj = new CommonEditViewReturn();
$arr = $CommonEditViewReturnObj->setReturnArr($arr);

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
            // js 最大精度9007199254740991 ，设置值 11260270000000109,超过了最大精度，因此要转换为字符串
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
    
	//edit:can 20230412 BUG0063903
    $arr['baseColumn']='amount';
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


ConvertTojsonString(1,$arr,"success");

?>