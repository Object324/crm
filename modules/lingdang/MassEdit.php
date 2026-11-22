<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();

global $theme,$currentModule,$current_user,$default_charset;
$smarty = new lingdangCRM_Smarty;
$excludedRecords = vtlib_purify($_REQUEST['excludedRecords']);
$smowner=vtlib_purify($_REQUEST['smowner']);//by kevin
$SearchScope=$_REQUEST['SearchScope'];
$focus = CRMEntity::getInstance($currentModule);
$fieldobj=$focus->fieldobj;
$focus->mode = '';
if($smowner == "smowner")
{
    $mode='allocate';//批量编辑不允许编辑负责人，所以$mode值分开
}
else
$mode = 'mass_edit';
//获取批量处理数
$deployarray=getSys_deploy(67);
$btach_num =  $deployarray['deploy_value'];

$disp_view = getView($focus->mode);
$idstring = vtlib_purify($_REQUEST['idstring']);
if($idstring=='all')
{
    $_REQUEST['mass_batch_num_all']=$btach_num;
    $smarty->assign('TOTALSELECTROWS',$_REQUEST['totalrows']);
}
$storearray = getSelectedRecords($_REQUEST, $currentModule, $_REQUEST['idstring'],$excludedRecords);

//审批流程单据
//id不是单据名称和id组合，需要增加特殊处理
if(isset($_REQUEST['ajax']) && $_REQUEST['ajax']==true){
	$records=str_replace(';',',',$idstring);
	$records=mb_substr($records,0,strlen($records)-1,$default_charset);
    /**
    *@andrew
    * @time:20140620
    * 0009539: 以下模块序时簿界面：全选所有的单据记录，进行批量修改、删除操作时没有判断单据是否在审批中、已审批，导致已审批或者正在审批的记录批量修改删除了
    */
	if($idstring=='all'){
		$records="'".implode("','",$storearray)."'" ;
	}
}

$smarty->assign("SEARCHSCOPE",$SearchScope);
$smarty->assign('MODULE',$currentModule);

$smarty->assign('THEME', $theme);
$smarty->assign('IMAGE_PATH', "themes/$theme/images/");
$smarty->assign('CURRENCYID',1);//默认为人民币

/**
 * edit：chj
 * date:2014-9-9
 * reason:客户服务单、项目、项目任务详细界面添加 分配按钮
 * description:0011039: 建议：在“客户服务单”、“项目”、“项目任务”明细查看界面，增加一个【分配】按钮，可以实现分配功能。
 * */
$smarty->assign('RETURN_ACTION','index');
if(isset($_REQUEST['return_action']))
{
    $smarty->assign('RETURN_ACTION',$_REQUEST['return_action']);
}
if(isset($_REQUEST['return_module']))
{
    $smarty->assign('RETURN_MODULE',$_REQUEST['return_module']);
}
$idstringval=implode(';',$storearray);
$smarty->assign("IDS",$idstringval);
$smarty->assign('MASS_EDIT','1');
//230726 wym XUQIU1000102 更多币种弹窗/隐藏域传值
crm_load_function_file('getInventoryCurrencyInfo','include/utils','InventoryUtils');
$currencyobj=Currency::getInstance($adb);
$product_base_currency=$currencyobj->getCurrencyId();
//参考价 - 价格设定
$price_details = getPriceDetailsForProduct('','', 'available',$currentModule,'unit_price');
$smarty->assign("PRICE_DETAILS", $price_details);
$smarty->assign("PRICE_DETAILS_NUM", sizeOf($price_details));
$base_currency = 'unit_price_curname' . $product_base_currency;
$smarty->assign("BASE_CURRENCY", $base_currency);
//参考成本价 - 价格设定
$price_details = getPriceDetailsForProduct('','', 'available',$currentModule,'procostprice');
$smarty->assign("PROCOSTPRICE_DETAILS", $price_details);
$smarty->assign("PROCOSTPRICE_DETAILS_NUM", sizeOf($price_details));
$base_currency = 'procostprice_curname' . $product_base_currency;
$smarty->assign("PROCOSTBASE_CURRENCY", $base_currency);

global $global_pick_list_values;

$BLOCKS = getBlocks($currentModule,$disp_view,$mode,$focus->column_fields);
if(empty($BLOCKS)){
    ConvertTojsonString(-1,array(),getFixedLabel('NoMassEditField'));
}
$smarty->assign('BLOCKS',$BLOCKS);
$smarty->assign('CURRENT_USERID',$current_user->id);
$smarty->assign('IS_ADMIN',is_admin($current_user));
$idstringsmownerids="";
$storearray=array_filter($storearray);
for($i=0;$i<count($storearray);$i++)
{
    if($idstringsmownerids=="")
    {
        $idstringsmownerids=$storearray[$i];
    }
    else
    {
        $idstringsmownerids.=",".$storearray[$i];
    }
}

$smarty->assign("MASSTYPE","massedit");
/**
* edit:chj
* date:2014-7-23
* reason:选择源单，获取多个源单模块
* */
//$smarty->assign('SOURCEMODULE',getSourceModule($currentModule));
// Field Validation Information
$tabid = getTabid($currentModule);

$validationArray =$fieldobj->split_validationdataArray();
if($fieldobj->getFieldInfoBykeyValue("columnname","wareid","fieldname")!="")
{
    require_once ('include/Stock/CommonStock.php');
    $wareresult = selWareAll();
    for($i = 0; $i<$adb->num_rows($wareresult); $i++)
    {
        $wareArray[$adb->query_result($wareresult, $i, "id")] = $adb->query_result($wareresult, $i, "name");
    }
    $smarty->assign("WAREALL", $wareArray);
}

/**
 * @by andy
 * @date 20140729
 * @reason 系统编号改进
 */ 
$isallow= $focus->Library('SystemCode')->getModentityfield('isallow',$currentModule);
$smarty->assign('ISALLOW',$isallow);
if($currentModule=='HelpDesk'){
    $TransferMessager ='Transfer_clients_and_contacts_server';
}elseif($currentModule == 'Expense' || $currentModule == 'Commission'){
    $TransferMessager = 'MODIFYEXPENSETO';
}elseif($currentModule == 'PutCash' || $currentModule == 'CashDeposit'){
    $TransferMessager = 'MODIFYOPERATORTO';
}else{
    $TransferMessager ='Transfer_clients_and_contacts';
}
$fields=$fieldobj->getFieldListArray();
$fields['module']=$currentModule;

$smarty->assign("TRANSFERMESSAGER",$TransferMessager);
global $global_pick_list_depencyfield;
crm_load_class_file('lingdang_DependencyPicklist','modules/PickList');
$picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasource($currentModule);
//edit:can 20210508 45800: （61mis.com/kfbcrm）客户管理-联系人，多选联系人单据，操作批量编辑，备注区块里关联“跟进记录”单选字段有空格但没有显示
$smarty->assign("ReferenceUitypes",cls_module_uitype::getAllUitypes());
$smarty->assign("UITYPEMODULES",cls_module_uitype::getUitypeModules());

//$smarty->assign("PICKIST_DEPENDENCY_DATASOURCE", Zend_Json::encode($picklistDependencyDatasource));

if($smowner == "smowner")
{   
    $smarty->assign('MASS_EDIT','0');
    
    $strcontent= $smarty->fetch('SmownerEditFrom.tpl');
}
else
{

   $strcontent=$smarty->fetch('MassEditForm.tpl'); 
}
$_REQUEST['diony']='diony';
$arr['title']=getFixedLabel('MASSEDIT');
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$arr['content']=$strcontent;
$arr['fieldname']=$validationArray['fieldname'];
$arr['datatype']=$validationArray['datatype'];
$arr['fieldlabel']=$validationArray['fieldlabel'];
//edit:can 2020-11-16 43279: （61mis.com/kfbcrm）OA表单-佣金单-详情(需要补丁)；打开佣金单详情编辑报销日期，保存会提示“报销日期不能大于当前日期”；但操作批量编辑可以选择之后的日期并保存编辑成功
$arr["validatasave"]=getValidataSave($currentModule);
$arr['fields']=$fields['fields'];
$arr['picklistDependencyDatasource']=$picklistDependencyDatasource;
$arr['picklistcontent']=$global_pick_list_values;
$arr['picklistdepencyfields']=$global_pick_list_depencyfield;
ConvertTojsonString(1,$arr,"success");

?>