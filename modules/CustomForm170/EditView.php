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
/**
 * ���²���
 * edit:can
 * date:20131211
 * reason:6191: ��ͬ��������Ʊ���ƽ��棺���۵��ֶΡ���ͬ�����ֶ�ѡ��ֵ��ҳ��ˢ�£����ҳ�����Ƹ����к�ͬ��������Ʊ�����������ͬ��������Ʊ
 * */
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
/*
edit:can
date:20130812
reason:4729: �½����ף���ͬ������ϸ����������� ��Ʊʱ����Ʊ��ϸ������ ���� �Զ�������ʾ�˺�ͬ�����ı���

*/
 if(isset ($_REQUEST['convertmode']) && $_REQUEST['convertmode'] == 'sotoinvoice')
{
	
	$focus->column_fields['subject']='';
}
if (isset ($_REQUEST['opportunity_id']) && $_REQUEST['opportunity_id'] != '') {
	$potfocus =CRMEntity::getInstance('Potentials');
	$potfocus->column_fields['potential_id'] = $_REQUEST['opportunity_id'];
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
}elseif(isset($_REQUEST['record']) && isset($_REQUEST['record']) > 0){//�༭,����

    if(!isset($_REQUEST['salesorder_id']))//���������Ϣ����
    {
        crm_load_class_file("Detail_Edit_View",'include/utils');
        $isSourceModule = Detail_Edit_View::getInventoryField('entitytype',$_REQUEST['record']);//edit:can 014169: ���۷�Ʊ--��ϸ�����ƹ��ܴ���
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

/**
 * @by andy
 * @date 20140729
 * @reason ϵͳ��ŸĽ�
 */ 
$isallow= $focus->Library('SystemCode')->getModentityfield('isallow',$currentModule);
$smarty->assign('ISALLOW',$isallow);

/*---�ֿ���Ϣ---*/
require_once (globalStatic::$root_directory.'include/Stock/CommonStock.php');
$wareresult = selWareAll($current_user->id);
for($i = 0; $i<$adb->num_rows($wareresult); $i++)
{
    $wareArray[$adb->query_result($wareresult, $i, "id")] = $adb->query_result($wareresult, $i, "name");
}
$smarty->assign("WAREALL", $wareArray);

/**
 * ��������ʱ�����Ϊ�Զ����ɺ�ı��
 * @project ��������ʱ���Զ����ɱ��
 * @author Tujt 2014-05-13
 */
 $customformno_columnname=$focus->fieldobj->getFieldInfoBykeyValue('uitype',4,'fieldname');
if($focus->mode!='edit'||$_REQUEST['isDuplicate']=='true'){
	$value = $focus->Library('SystemCode')->getModuleSeqNumRecord($currentModule);
	if(!$value) $value = getFixedLabel('MSG_AUTO_GEN_ON_SAVE');
   
	$focus->column_fields[$customformno_columnname] = $value;
}


if(!empty($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == true){
	$disp_view = 'create_view';
}
//���� - ����
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
$smarty->assign('FROM_MODULE','');//���������ɹ��������жϺ�ͬ�����Ǵ��ĸ�ģ�鴴���ģ��ֶι�ʽ���õ���,
                                  //  ��Ϊ��Ʒ���������ֶι�ʽ�Բ���˰����Ϊ��׼


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
		$smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($focus,'product_create'));//��Ʒ��������
        $smarty->assign('FROM_MODULE','Products');//
	}else{
	    if(isset ($_REQUEST['listval']) && $_REQUEST['listval'])
        {
            //33543: ���۷�Ʊ�༭����>����һ�����۷�Ʊ��д���ϣ�ѡ��Դ���ֶ�ѡ���ͬ�������м۸�Ķ�����>����>�༭�ղű���ĵ���>����ѡ��Դ���ֶΣ�����ͬ������Ϊ�����ͬ��ѡ���м۸�ĵ���>�鿴��Ʒ���������С�ƣ������������ˡ���
        }
        else
	       {
	           	if($focus->id > 0){
		 
            			$smarty->assign("ASSOCIATEDPRODUCTS", $ProductDetailsHtml->getProductDetailsHtml($focus,'edit'));
            		}else if($_REQUEST['fromid']<=0||$issourcemodulecreate=='no'){
            			$smarty->assign("ASSOCIATEDPRODUCTS", $ProductDetailsHtml->getProductDetailsHtml($focus,'create'));
            		}
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
$smarty->assign('BASECOLUMN',$ProductDetailsData->module_productbasefield);//���㹫ʽ�л�׼�ֶ�
if (isset ($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true') {
	$smarty->assign("DUPLICATE_FROM", $focus->id);
	//14169: ���۷�Ʊ--��ϸ�����ƹ��ܴ���,edit:can
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

/**
* edit:chj
* date:2014-1-14
* reason: Դ����Ʒ����ʾ
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
    
    $smarty->assign('ASSOCIATEDPRODUCTS',$ProductDetailsHtml->getProductDetailsHtml($so_focus,'sourcemodule_create'));
    $setListVal = count(explode(',',$so_focus->lineitemIds));
	$ids = explode(',',rtrim($_REQUEST['listval'],','));
    $source_detail_table=$so_focus->Detail_table;
    
	$so_focus->retrieve_entity_info($so_focus->id, $isSelectModule);
	$focus->column_fields['account_id']= $so_focus->column_fields['account_id'];
    $fieldinfo=$focus->getSourceFieldInfo();//��ȡԭ���ֶ���Ϣ
    if($fieldinfo&&$fieldinfo->getFieldName()!='')
        $focus->column_fields[$fieldinfo->getFieldName()]=$_REQUEST['fromid'];//��������ԭ��
	
	
    
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

/* ������������ͳһ������ begin */
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
  /**
  * ���²���
  * edit:can
  * date:20131223
  * reason:��Ӹ��ı���
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
reason:�����ͱ༭Ȩ�޷ֿ�
*/
if( (isset($_REQUEST['Create'])&&($_REQUEST['Create']=='true' || $_REQUEST['Create']=='yes')) ||$_REQUEST['isDuplicate']=='true'){
	$smarty->assign('CREATE','true');
}
else{
	$smarty->assign('CREATE','false');
}
//��ȡ�汾����
$version_info = getVersionInfo();
$smarty->assign('VERSIONINFO',$version_info);
$smarty->assign('VERSIONTRADE',$version_info['trade']);
$smarty->assign('VERSION_ACCOUNT',$version_info['account']);
//��ȡ�ͻ�����ϵ��������Ϣ
$block_info = getBlockDisplayInfo('AccountContacts');
//��ʾλ��
$smarty->assign('DISPLAY_POSITION',$block_info['display_position']);
 //�Ƿ���ʾ
if($block_info['is_display'] == 0)
    $smarty->assign('BESTATUS','YES');
else
    $smarty->assign('BESTATUS','NO');
$fields=$focus->fieldobj->getFieldListArray();
//$fields['module']=$currentModule;
//$smarty->assign('RELATEDORDERINFORMATION',$obj_entity->showSourceHtml());//�տ���Ϣ��ϸhtml
$smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));
$smarty->assign("MODULELINKFIELD",$focus->list_link_field);
$smarty->assign("SMOWNERCOLUMNNAME",$focus->getSmownerColumName());
/**
 * �༭������ҳ�棬���Ӹ�����Ϣ�����
 * @author Tujt 2014-04-11
 */
$relmodule = (isset($currentModule))?$currentModule:$_REQUEST['module'];
$smarty->assign("IS_REL_LIST",isPresentRelatedLists($relmodule));
$smarty->assign("PICKLISTCONTENT",ldcrm_json_encode($global_pick_list_values));
$smarty->assign('FROMID',$_REQUEST['fromid']);
///�����ж�


$smarty->assign("VALIDATASAVE",ldcrm_json_encode(getValidataSave($currentModule)));
//��ϸ�ֶ�
$smarty->assign("TABDETAILFIELDS",ldcrm_json_encode($ProductDetailsHtml->ProductDetailsData->productToolFields->getFieldListArray()));

setGLobalURLSmarty($smarty);//����js,css�ȷ���·��

$smarty->assign("ReferenceUitypes",cls_module_uitype::getAllUitypes());
$smarty->assign("UITYPEMODULES",cls_module_uitype::getUitypeModules());
//�����Ϣ���ڸ߼���ѯ
//Crm_load_class_file("CommonView","modules/CustomView");
//$smarty->assign("DATETIMESTR",json_encode(CommonView::stdFilterDateTimeStr()));

 //���ֹ���
crm_load_class_file('cls_fieldrule','include/fields/fieldrule');
$fieldruleobj=cls_fieldrule::getInstance($currentModule);
$smarty->assign('jsonFieldRuleFieldNames',ldcrm_json_encode($fieldruleobj->getAllFieldNameSetChangeEvent()));//��ȡ���еĴ����ֶ�

//editor:gyq_170 reason:带分录模块弹出层   2019/11/20 14:12
/*if($focus->mode == 'edit')
	$smarty->display("DetailView/InventoryEditView.tpl");
else
	$smarty->display('DetailView/InventoryCreateView.tpl');*/
$arr = $ProductDetailsHtml->detailPopup($smarty,$fields,$productFields,$data);
ConvertTojsonString(1,$arr,"success");
?>