<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();

//require_once('modules/CustomForm11/CustomForm11.php');
//
//include("modules/Emails/mail.php");

//$local_log =LoggerManager::getLogger('index');

global $currentModule;
global $adb;
$focus = CRMEntity::getInstance($currentModule);
//added to fix 4600
$search=$_REQUEST['search_url'];
if(isset($_REQUEST['mode']))
{
	$focus->mode = $_REQUEST['mode'];
}
if($focus->mode == 'edit'||$_REQUEST['record']>0)
{
    /**
     * edit:kevin
     * date:2013-07-23
     * reason:缂栬緫鍗曟嵁鏃?鏇存柊瀹㈡埛
     */
	$focus->id = $_REQUEST['record'];
  
   
	$focus->retrieve_entity_info($focus->id,$currentModule);
    $before_columnfieldvalue=$focus->column_fields;
    $currency_id = $focus->column_fields['currency_id'];
    $focus->before_field_info=array();
    foreach($focus->column_fields as $fieldname=>$value)
    {
        $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey("fieldname",$fieldname); 
        if($fieldinfo)   
        {
            $fieldinfo->setColumn_Value($focus->column_fields[$fieldname]);
            $focus->before_field_info[]=$fieldinfo;
        }        
    } 
    $fieldinfo=new fieldInfo();
    $fieldinfo->setcolumnName('currencyid');
    $fieldinfo->setFieldName('currency_id');
    $fieldinfo->setColumn_Value($currency_id);
    $focus->before_field_info[]=$fieldinfo;
    $focus->mode='edit';
}
setObjectValuesFromRequest($focus);//鑾峰彇鍒扮晫闈笂鐨勫瓧娈靛搴斿€笺€?


if($currency_id != $_REQUEST['inventory_currency'])
    $focus->currency_status = true;
else
    $focus->currency_status = false;
if($focus->currency_status === true)
{
    
	$currencyobj=Currency::getInstance($adb,$_REQUEST['inventory_currency']);
	$focus->column_fields['currency_symbol'] = decode_html($currencyobj->getCurrencySymbol());
	$focus->column_fields['conversion_rate'] = $currencyobj->getCurrencyRate();
  
}
$focus->column_fields['currency_id'] = $_REQUEST['inventory_currency'];
$fieldinfo=new fieldInfo();
$fieldinfo->setcolumnName('currencyid');
$fieldinfo->setFieldName('currency_id');
$fieldinfo->setColumn_Value($_REQUEST['inventory_currency']);
$focus->after_field_info[]=$fieldinfo;

$fieldinfo=new fieldInfo();
$fieldinfo->setcolumnName('conversion_rate');
$fieldinfo->setFieldName('conversion_rate');
$fieldinfo->setColumn_Value($focus->column_fields['conversion_rate'] );
$focus->after_field_info[]=$fieldinfo;
if($_REQUEST['assigned_type'] == 'U') {
	$focus->column_fields['assigned_user_id'] = $_REQUEST['assigned_user_id'];
} elseif($_REQUEST['assigntype'] == 'T') {
	$focus->column_fields['assigned_user_id'] = $_REQUEST['assigned_group_id'];
}
$focus->save($currentModule);

$return_id = $focus->id;


//editor:gyq_161 reason:带分录模块弹出层   2019/12/4 20:01
$_REQUEST['diony']='diony';
$focus->column_fields['record_module']=$focus->module_name;
if($_REQUEST['refreshpage']=='no')
{
    $VersionInfo = getVersionInfo();
    if($VersionInfo['account']=='langjie')
    {
        //edit:can 2020-10-19 刷新列表的费用状态
        $focus->setRefreshListModules(array('CustomForm02','CustomForm21','CustomForm22'
                    ,'CustomForm23','CustomForm24','CustomForm27','CustomForm28','Commission'));
    }
    $focus->ReturnAfterSave($before_columnfieldvalue);
    //$arr['fieldhrefname']=$focus->list_link_field;
//    $arr['fieldvalue']=$focus->column_fields;
//    $arr['fieldvalue']['maintable_id']=$focus->id;
//    $arr['modulebillnotip']=$_SESSION[$currentModule.'_modulebillnotip'];
//    $_SESSION[$currentModule.'_modulebillnotip']='no';
//    ConvertTojsonString(1,$arr,"success");
}
    



?>