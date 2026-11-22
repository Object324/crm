<?php


//require_once('modules/CustomForm11/CustomForm11.php');
//
//include("modules/Emails/mail.php");

//$local_log =LoggerManager::getLogger('index');
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
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

$parenttab = getParentTab();
if(isset($_REQUEST['return_module']) && $_REQUEST['return_module'] != "") $return_module = vtlib_purify($_REQUEST['return_module']);
else $return_module = "CustomForm11";
if(isset($_REQUEST['return_action']) && $_REQUEST['return_action'] != "") $return_action = vtlib_purify($_REQUEST['return_action']);
else $return_action = "DetailView";
if(isset($_REQUEST['return_id']) && $_REQUEST['return_id'] != "") $return_id = vtlib_purify($_REQUEST['return_id']);


/**
 * 鍒楄〃缂栬緫鍚庯紝杩斿洖鍒楄〃鏃讹紝澧炲姞query_session=1鐨勫弬鏁帮紝鍚敤鍒楄〃椤甸潰鎼滅储session
 * @project 搴忔椂绨挎煡璇㈣浣忔悳绱㈡潯浠?
 * @author Tujt 2014-04-24
 */
if($return_module == $currentModule && $return_action != 'DetailView'){
	$return_action .= '&query_session=1';
}

//code added for returning back to the current view after edit from list view
$return_viewname='';
if($_REQUEST['return_viewname'] != '') {
	$return_viewname='&viewname='.vtlib_purify($_REQUEST['return_viewname']);
}
$page = '';
if(!empty($_REQUEST['pagenumber'])){
	$page = '&start='.vtlib_purify($_REQUEST['pagenumber']);
}

  
if((isset($_REQUEST['Create'])&&($_REQUEST['Create']=='true' || $_REQUEST['Create']=='yes')) ||$_REQUEST['isDuplicate']=='true')
{
        $location="index.php?action=$return_action&module=$return_module&".
		"record=$return_id$return_viewname$page".$search."&salestype=yes".$pirintStr;
}
else 
{
        $location="index.php?action=$return_action&module=$return_module&".
		"record=$return_id$return_viewname$page".$search.$pirintStr;
        
}

//editor:gyq_161 reason:带分录模块弹出层   2019/12/4 20:01
$_REQUEST['diony']='diony';
$focus->column_fields['record_module']=$focus->module_name;
if($_REQUEST['refreshpage']=='no')
{
    $focus->ReturnAfterSave($before_columnfieldvalue);
    //$arr['fieldhrefname']=$focus->list_link_field;
//    $arr['fieldvalue']=$focus->column_fields;
//    $arr['fieldvalue']['maintable_id']=$focus->id;
//    $arr['modulebillnotip']=$_SESSION[$currentModule.'_modulebillnotip'];
//    $_SESSION[$currentModule.'_modulebillnotip']='no';
//    ConvertTojsonString(1,$arr,"success");
}
    header("Location:".$location);



?>