<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 
require_once("modules/SendPayment/SendPayment.php");

global $current_user,$adb;
$focus=new SendPayment();
$smownerid=$_REQUEST['SmOwnerSearchScope'];
$modules=array("ld_sendpayment"=>"SendPayment",'ld_sendpaymentscf'=>'SendPayment');
//获取币种ID
if(isset($_REQUEST['currency_id']))
    $currency_id = $_REQUEST['currency_id'];
else
    $currency_id = 1;

$currencyobj=Currency::getInstance($adb,$currency_id);
$currency_info['rate'] = $currencyobj->getCurrencyRate();
$currency_info['symbol'] = $currencyobj->getCurrencySymbol();
$cols=array(
				"ld_crmentity"=>array('setype'=>'SendPayment'),
				"ld_sendpayment"=>array(
                    'sendpayment_no'=>'','vendorid'=>'','purchaseorder_id'=>'',
                    'cpperiodtime'=>'','plandate'=>'','amount'=>'','cpstatus'=>'',
    				"smcreatorid"=>$current_user->id,"smownerid"=>$smownerid,'modifiedby'=>$current_user->id,'createdtime'=>'',
                    'modifiedtime'=>'','currency_id'=>$currency_id,'conversion_rate'=>$currency_info['rate'],'currency_symbol'=>decode_html($currency_info['symbol'])
                    ),
               "ld_sendpaymentscf"=>array('sendpaymentid'=>'')
               );

$columns=array();
$i=1;
$paymentstatus="未付";
$d = date('Y-m-d H:i:s',time());
crm_load_class_file('cls_ParentRelatedField_Data','include/RelatedField');
$cls_ParentRelatedFields = new cls_ParentRelatedField_Data('SendPayment',$_REQUEST["cust"],'');

$relatedfielddata=$cls_ParentRelatedFields->getEffectValues('html_input');
//edit:can 20210331 45234: （http://42.193.112.228:85/crm [^])；客户—北京永和嘉业房地产经纪有限公司；付款计划单据中两个引用字段“房东联系方式” “房源名称” 引用失败
foreach($relatedfielddata  as $relateinfo)
{
    $rawvalue_arr=$relateinfo['rawValue'];
    $fieldname=$rawvalue_arr['input_name'];
    $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey("fieldname",$fieldname);
    if($fieldinfo&&$fieldinfo->getSaveDataBase()=='yes')
    {
        $cols[$fieldinfo->getTableName()][$fieldinfo->getColumnName()]=$rawvalue_arr['value'];
        
    }
    
}


$cls_ParentRelatedFields = new cls_ParentRelatedField_Data('SendPayment',$_REQUEST["record"],'');

$relatedfielddata=$cls_ParentRelatedFields->getEffectValues('html_input');
//edit:can 20210331 45234: （http://42.193.112.228:85/crm [^])；客户—北京永和嘉业房地产经纪有限公司；付款计划单据中两个引用字段“房东联系方式” “房源名称” 引用失败
foreach($relatedfielddata  as $relateinfo)
{
    $rawvalue_arr=$relateinfo['rawValue'];
    $fieldname=$rawvalue_arr['input_name'];
    $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey("fieldname",$fieldname);
    if($fieldinfo&&$fieldinfo->getSaveDataBase()=='yes')
    {
        $cols[$fieldinfo->getTableName()][$fieldinfo->getColumnName()]=$rawvalue_arr['value'];
        
    }
    
}


while(true)
{
    if(!isset($_REQUEST['plandate'.$i]))
    {
        break;
    }
    $cols['ld_sendpayment']['createdtime']=$d;
    $cols['ld_sendpayment']['modifiedtime']=$d;
    //$cols['ld_CrmEntity']['viewedtime']=$d;
    
    $cols['ld_sendpayment']['sendpayment_no']="#:#:#:#:#";//自动生成编号
    $cols['ld_sendpayment']['vendorid']=$_REQUEST["cust"];//供应商id
    $cols['ld_sendpayment']['description']=$_REQUEST["description$i"];//备注
    $cols['ld_sendpayment']['purchaseorder_id']=$_REQUEST["record"];//源单
	$cols['ld_sendpayment']['entitytype'] = $_REQUEST['entitytype'];
    $cols['ld_sendpayment']['cpperiodtime']=$_REQUEST["periodtime$i"];
    $cols['ld_sendpayment']['plandate']=$_REQUEST["plandate$i"];
    $cols['ld_sendpayment']['amount']=$_REQUEST["amount$i"];
    $cols['ld_sendpayment']['cpstatus']=$paymentstatus;

    $columns[$i-1]=$cols;
    $i++;
}
 
$focus->MassSave($modules,$columns);
$_REQUEST['diony']='diony';
ConvertTojsonString(1,array(),"success");

?>