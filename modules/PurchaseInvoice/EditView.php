<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global   $theme, $currentModule, $current_user, $adb;
$languageType= getLanguageType($current_user);
$focus = CRMEntity::getInstance($currentModule);
$smarty = new lingdangCRM_Smarty();
$purchaseorder_id = 0;
$searchurl = getBasic_Advance_SearchURL();
$smarty->assign("SEARCH", $searchurl);
$setListVal = 0;

//选择源单，获取多个源单模块
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
//模块是否被激活
$smarty->assign('MODULE_ACTIVATE',vtlib_isModuleActive('PurchaseOrder'));
if(isset($_REQUEST['fromid']) && $_REQUEST['fromid'] > 0&& in_array($_REQUEST['frommodule'],$arr_sourcemodules)){


	$_REQUEST['selectsourcename'] = $_REQUEST['frommodule'];
   
    //24381: 采购订单明细：关联创建采购发票，没有带出采购订单编号和产品信息
    $lineitemids=getLineitemId($_REQUEST['fromid'],$_REQUEST['selectsourcename']);
	
    
    $_REQUEST['listval']=$lineitemids;
    
	if($select_vendorid > 0)
		$_REQUEST['vendor_id'] = $select_vendorid;
}
//report_sourceid 报表 传入的源单id
if(!empty($_REQUEST['report_sourceid']))
{
	$id = $_REQUEST['report_sourceid'];
	if(!empty($_REQUEST['report_sourcemodule'])){
		$_REQUEST['selectsourcename'] = $_REQUEST['report_sourcemodule'];
	}
    else
    {
        $arr_id=explode(',',$id);
        $_REQUEST['selectsourcename']=getSalesEntityType($arr_id[0]);
        
    }
    $so_focus=CRMEntity::getInstance($_REQUEST['selectsourcename']);
    $detailtable=$so_focus->Detail_table;
    $so_focus->id=$id;
    $productsql=" select lineitem_id from $detailtable where id in ( ".$id.')';
    $productresult=$adb->pquery($productsql,array());
    for($i=0;$i<$adb->num_rows($productresult);$i++)
    {
        $_REQUEST['listval'].=$adb->query_result($productresult,$i,'lineitem_id').',';
    }
	if(!empty($_REQUEST['vendor_id'])){
		$focus->column_fields['vendor_id'] = $_REQUEST['vendor_id'];
	}

}
if (isset ($_REQUEST['record']) && $_REQUEST['record'] != '')
{
    crm_load_class_file("Detail_Edit_View",'include/utils');
    $isSelectModule = Detail_Edit_View::getInventoryField('entitytype',$_REQUEST['record']);
	if(isset($_REQUEST['convertmode']) && $_REQUEST['convertmode'] == 'update_quote_val'){
	} else {
		$focus->id = $_REQUEST['record'];
		$focus->mode = 'edit';
		$focus->retrieve_entity_info($_REQUEST['record'], "PurchaseInvoice");
		$focus->name=$focus->column_fields[$focus->list_link_field];
        //require_once('modules/Approve/Approve.php');
        //$approve=new Approve();
		$approve = Approve::getInstance($currentModule);
        if(isset($_REQUEST['ajax']) && $_REQUEST['ajax']==true){
            echo $approve->EditBlocks($focus->column_fields['assigned_user_id'],$focus->id);
            exit();
        }
		// 判断已审批状态不允许编辑
		if(!isset($_REQUEST['isDuplicate']) || $_REQUEST['isDuplicate'] != 'true'){
			$blockbuttons = $approve->blocksButton($focus->column_fields['assigned_user_id'],$focus->id);
			$isdelete=$blockbuttons[3];
			$approvestatus=$blockbuttons[4];
			if($isdelete !=0){
				$alertstr = '';
				switch($approvestatus){
					//case 1:
						//$alertstr = getFixedLabel('Approvalof');
						//break;
					case 2:
						$alertstr = getFixedLabel('Approved');
						break;
				}
				if(!empty($alertstr)){
					echo '<script type="text/javascript">alert("'.$alertstr.'");history.go(-1);</script>';exit();
				}
			}
		}
	}
}

if(empty($_REQUEST['record']) && $focus->mode != 'edit')
{
	setObjectValuesFromRequest($focus);
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
	$focus->column_fields['purchaseinvoice_no'] = $value;
}

/* 关联创建单据统一处理方法 end */
if (isset ($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true') {
	/**
	 * 复制时，负责人设置为自己
	 * @author Tujt 2015-07-20
	 */
	//$focus->column_fields['assigned_user_id'] = $current_user->id;
	$value = $focus->Library('SystemCode')->getModuleSeqNumRecord($_REQUEST['module']);
	if(!$value) $value = getFixedLabel('MSG_AUTO_GEN_ON_SAVE');
	$focus->column_fields['purchaseinvoice_no'] = $value;
}
$smarty->assign('ISADMIN',$current_user->is_admin);
$smarty->assign("OP_MODE", $disp_view);
$smarty->assign("MODULE", $currentModule);
$smarty->assign("SINGLE_MOD", 'PurchaseInvoice');

$category = getParentTab();
$smarty->assign("CATEGORY", $category);
$deployarray=getSys_deploy(10);
$smarty->assign('PERODUCTDEPLOY',$deployarray['deploy_value']);
if (isset ($focus->name))
	$smarty->assign("NAME", $focus->name);
else
	$smarty->assign("NAME", "");
$productdetail_mode='create';
$productdetailhtml_focus='';
/**
* edit:chj
* date:2014-1-14
* reason: 选择源单
**/
if((isset ($_REQUEST['listval']) && $_REQUEST['listval'] != "")){
 
    $isSelectModule = $_REQUEST['selectsourcename'];  
	$listval = rtrim($_REQUEST['listval'],',');
    $po_focus = CRMEntity::getInstance($isSelectModule);
    $soid = $listval;
    $ids = explode(',',rtrim($_REQUEST['listval'],','));
    $po_focus->lineitemIds = $listval;
	$po_focus->mode="edit";
    $po_focus->id=$_REQUEST['fromid'];
    $productdetail_mode='sourcemodule_create';
    $productdetailhtml_focus=$po_focus;
   // $smarty->assign("ASSOCIATEDPRODUCTS", $ProductDetailsHtml->getProductDetailsHtml($po_focus,'sourcemodule_create'));
    $smarty->assign("ALLPRODUCT",getProductLineItemId($po_focus->lineitemIds,$po_focus->moduleName));
    $setListVal = count(explode(',',$po_focus->lineitemIds));
    $smarty->assign('LISTVAL_PURCHASEORDER_NO',getEditListValName($po_focus->lineitemIds,$isSelectModule));
    
    crm_load_class_file("Detail_Edit_View_finance",'include/utils');
    $lineitemids=implode(',',$ids);
    $detailtable=$po_focus->Detail_table;
    $query = " select id  from $detailtable where lineitem_id in ( ".$lineitemids." )";

    $result=$adb->pquery($query,array());
    $num_rows=$adb->num_rows($result);
    for($i=0;$i<$num_rows;$i++)
    {
        $sourceids[]=$adb->query_result($result,$i,0);
    }
    $entitytypeid = $adb->query_result($result,0,0);
	if($entitytypeid > 0){
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
    
	$_REQUEST['fromid'] = $sourceids[0];
    $fieldinfo=$focus->getSourceFieldInfo();//获取原单字段信息
    if($fieldinfo&&$fieldinfo->getFieldName()!='')
        $focus->column_fields[$fieldinfo->getFieldName()]=$_REQUEST['fromid'];//关联创建原单
    $sourceids=implode(',',$sourceids);
    
    $relatedinformations= Detail_Edit_View_finance::getPurchaseInvoice_SoureInfo($isSelectModule,$sourceids);
}else{
	if ($focus->mode == 'edit'){
		$setListVal = 1;
		$smarty->assign('LISTVAL_PURCHASEORDER_NO',getDetailListValName($focus->id,$isSelectModule,2));
      
         $relatedOrderIdStr=getDetailListValName($_REQUEST['record'],$isSelectModule,3);
        crm_load_class_file("Detail_Edit_View_finance",'include/utils');
        
        $relatedinformations=Detail_Edit_View_finance::getPurchaseInvoice_SoureInfo($isSelectModule,str_replace('|',',',$relatedOrderIdStr));
      
	}
	elseif (isset ($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true'){
		$focus->id = $_REQUEST['record'];
		$focus->mode = 'edit';
	}
	if($_REQUEST['isDuplicate'] == 'true'){
		$smarty->assign("ID", '');
	}else{
		$smarty->assign("ID", $focus->id);
	}
    $productdetailhtml_focus=$focus;
	if($focus->id > 0){
	   $productdetail_mode='edit';
       $productdetailhtml_focus=$focus;
	//	$smarty->assign("ASSOCIATEDPRODUCTS", $ProductDetailsHtml->getProductDetailsHtml($focus,'edit'));
	}else{
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
/* 关联创建单据统一处理方法 begin */
if(isset($_REQUEST['parent_id']) && $_REQUEST['parent_id'] > 0){
	$focus->getModuleLogic($currentModule)->setQuickCreateColumn($_REQUEST['parent_module'],$_REQUEST['parent_id']);
}
if(isset($_REQUEST['fromid']) && $_REQUEST['fromid'] > 0){
	$focus->getModuleLogic($currentModule)->setQuickCreateColumnValues($currentModule,$_REQUEST['fromid']);
}


if (isset ($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true')
{
	$smarty->assign("DUPLICATE_FROM", $focus->id);
    $smarty->assign('LISTVAL_PURCHASEORDER_NO',getDetailListValName($focus->id,$isSelectModule,2));
	$focus->id = "";
	$focus->mode = '';
}
global $edit_column_fields_value;
$act_data=getBlocks($currentModule, $disp_view, $mode, $focus->column_fields);
$smarty->assign("COLUMN_FIELDS_VALUE",ldcrm_json_encode($edit_column_fields_value));
$ProductDetailsHtml = crm_load_class_obj('cls_productDetailsHtml',"modules/$currentModule/ProductDetails",array($currentModule));
$ProductDetailsData = crm_load_class_obj('cls_productDetailsData',"modules/$currentModule/ProductDetails",array($currentModule));
//复制,产品明细丢失
 if (isset ($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true') {
 

    $productdetailhtml_focus->id=$_REQUEST['record'];
    $productdetailhtml_focus->mode='edit';
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
$smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($productdetailhtml_focus,$productdetail_mode));
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
$smarty->assign('LISTALLVAL',$setListVal);
$smarty->assign('SELECTSOURCENAME',$isSelectModule);
$smarty->assign('ISSOURCEMODULE',$isSelectModule);
$smarty->assign("MODE", $focus->mode);
$smarty->assign("RELATEDORDERINFORMATION", $relatedinformations);//原单信息
if (isset ($cust_fld))
{
	$smarty->assign("CUSTOMFIELD", $cust_fld);
}

if (isset ($_REQUEST['return_module']) && !isset($_REQUEST['parent_id']))
	$smarty->assign("RETURN_MODULE", vtlib_purify($_REQUEST['return_module']));
else
	$smarty->assign("RETURN_MODULE", "PurchaseInvoice");
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
$smarty->assign("MODULE", "PurchaseInvoice");
$smarty->assign("PRINT_URL", "phprint.php?jt=" . session_id() . $GLOBALS['request_string']);

$smarty->assign("CALENDAR_LANG", $app_strings['LBL_JSCALENDAR_LANG']);
$smarty->assign("CALENDAR_DATEFORMAT", 'YYYY-mm-dd');
//if create SO, get all available product taxes and shipping & Handling taxes
$data =$focus->fieldobj->split_validationdataArray();

$smarty->assign("VALIDATION_DATA_FIELDNAME", $data['fieldname']);
$smarty->assign("VALIDATION_DATA_FIELDDATATYPE", $data['datatype']);
$smarty->assign("VALIDATION_DATA_FIELDLABEL", $data['fieldlabel']);
$smarty->assign("WAREALL", $wareArray);
$smarty->assign('LISTALLVAL',$setListVal);
$smarty->assign("DUPLICATE",vtlib_purify($_REQUEST['isDuplicate']));
$smarty->assign('CREATEMODE', vtlib_purify($_REQUEST['createmode']));
global $global_pick_list_depencyfield;
crm_load_class_file("lingdang_DependencyPicklist",'modules/PickList');
$picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasource($currentModule);
$smarty->assign("PICKIST_DEPENDENCY_DATASOURCE", ldcrm_json_encode($picklistDependencyDatasource));
$smarty->assign("PICKLISTDEPENCYFIELDS", ldcrm_json_encode($global_pick_list_depencyfield));
$fields=$focus->fieldobj->getFieldListArray();
$fields['module']=$currentModule;
$smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));
$smarty->assign('FROMID',$_REQUEST['fromid']);

//0023103: 采购发票明细：点击【复制】，复制单据后保存，关联创建中点击【修改日志】，弹出层中显示了修改的内容
/*
if(!empty($_REQUEST['record'])){
	$smarty->assign("ID", $_REQUEST['record']);
}
*/
$smarty->assign("ID", $focus->id);


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
if($focus->mode == 'edit')
	$operation = 2;
else
	$operation = 1;
/**
 * 编辑、创建页面，增加更多信息左边栏
 * @author Tujt 2014-04-17
 */
$relmodule = (isset($currentModule))?$currentModule:$_REQUEST['module'];
$smarty->assign("IS_REL_LIST",isPresentRelatedLists($relmodule));
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
//editor:gyq_161 reason:带分录模块弹出层   2019/11/20 11:41
/*if($focus->mode == 'edit')
	$smarty->display("DetailView/InventoryEditView.tpl");
else
	$smarty->display('DetailView/InventoryCreateView.tpl');*/
$arr = $ProductDetailsHtml->detailPopup($smarty,$fields,$productFields,$data);
ConvertTojsonString(1,$arr,"success");
?>