<?php
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
require_once('modules/SalesOrder/SalesOrder.php');

include("modules/Emails/mail.php");
//$local_log =LoggerManager::getLogger('index');
$focus = CRMEntity::getInstance('SalesOrder');
//added to fix 4600
$search=$_REQUEST['search_url'];
if(isset($_REQUEST['mode']))
{
	$focus->mode = $_REQUEST['mode'];
}
if($focus->mode == 'edit')
{
    /**
     * edit:kevin
     * date:2013-07-23
     * reason:编辑单据时,更新客户
     */
     
	$focus->id = $_REQUEST['record'];
    /*$account=new Accounts();
    $account->updateAccountInfo($currentModule,'',1,$focus->id);*/
    //获取单据在DB中的币种ID
	$focus->retrieve_entity_info($focus->id,"SalesOrder");
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
}
setObjectValuesFromRequest($focus);//获取到界面上的字段对应值。
//海格

$VersionInfo = getVersionInfo();
if($VersionInfo['account'] == 'haige')
{
    $quoteid=$_REQUEST['quote_id'];
    for($i=1;$i<10000;$i++)
    {
        if(!empty($_REQUEST['hdnProductId'.$i]) && $_REQUEST['hidden_rowid_'.$i] == 0){
            if($_REQUEST['lineitem_id'.$i]<=0)
            {
                $productid=$_REQUEST['hdnProductId'.$i];
                $sql='select lineitem_id from ld_quotesdetail  where id=? and productid=? ';
                $result=$adb->pquery($sql,array($quoteid,$productid));
                $_REQUEST['lineitem_id'.$i]=$adb->query_result($result,0,'lineitem_id');
                
            }
        }
        else
        {
            break;
        }
    }
}

//chj:如果币种改变，则更改单据中原单的币种类型 和 汇率
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

$focus->getBefore_SumDetailValues();//获取保存前明细字段的合计

$focus->save("SalesOrder");

$return_id = $focus->id;
$parenttab = getParentTab();
if(isset($_REQUEST['return_module']) && $_REQUEST['return_module'] != "") $return_module = vtlib_purify($_REQUEST['return_module']);
else $return_module = "SalesOrder";
if(isset($_REQUEST['return_action']) && $_REQUEST['return_action'] != "") $return_action = vtlib_purify($_REQUEST['return_action']);
else $return_action = "DetailView";
if(isset($_REQUEST['return_id']) && $_REQUEST['return_id'] != "") $return_id = vtlib_purify($_REQUEST['return_id']);

/**********合同订单保存后自动创建出库单 end************/
//获取订单同步接口触发点
$deployarray=getSys_deploy(92);
if(!empty($deployarray)){
    $salestype =  $deployarray['deploy_value'];
    if($salestype == 0){
        if(get_versiontrade() == 'yangduan'){
            //crm_load_class_file('cls_interface_yadon','include/InterfaceClass');
            //$cls_interface_yadon = new cls_interface_yadon();
            //$_SESSION['kiserror'] = $cls_interface_yadon->Sales_Synchronous($focus->id,'SalesOrder');
        }else{
            $focus->SyDataInterFace($focus);
        }
        
    }
}

/**
 * 列表编辑后，返回列表时，增加query_session=1的参数，启用列表页面搜索session
 * @project 序时簿查询记住搜索条件
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

/**
 * diony    
 * 2014-11-27
 * 合同订单保存后是否立即打印1:否，0:是
 */
$deployarray=getSys_deploy('57');
$pirintStr = '';
if($deployarray['deploy_value'] == 0)
{
    $pirintStr = '&isprint=yes';
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
if($focus->getKisError()!='')
{
//$location.="&kiserror=".urlencode($focus->getKisError());

    $_SESSION['kiserror']=$focus->getKisError();
   
}
//editor:gyq_161 reason:带分录模块弹出层   2019/12/4 20:01
$_REQUEST['diony']='diony';
$focus->column_fields['record_module']=$focus->module_name;
//if($_REQUEST['refreshpage']=='no')
//{
    //保存后的返回值
     $focus->ReturnAfterSave($before_columnfieldvalue);
    
//}
//header("Location:".$location);



?>