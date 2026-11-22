<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 
require_once("modules/PaymentPlan/PaymentPlan.php");

global $current_user,$adb;
$focus=new PaymentPlan();
$smownerid=$_REQUEST['SmOwnerSearchScope'];	//回款计划负责人
$paymenttype = $_REQUEST['paymenttype'];	//回款计划类型
$modules=array("ld_paymentplan"=>"PaymentPlan");
//获取币种ID
if(isset($_REQUEST['currency_id']))
    $currency_id = $_REQUEST['currency_id'];
else
    $currency_id = 1;
$currencyobj=Currency::getInstance($adb,$currency_id);
$currency_info['rate'] = $currencyobj->getCurrencyRate();
$currency_info['symbol'] = decode_html($currencyobj->getCurrencySymbol());
$cols=array(
               "ld_crmentity"=>array('setype'=>'PaymentPlan'),
               "ld_paymentplan"=>array('paymentplan_no'=>'','accountid'=>'','salesorderid'=>'0',
                                    'periodtime'=>'','plandate'=>'','amount'=>'','paymentstatus'=>'','paymenttype'=>$paymenttype,
									"smcreatorid"=>$current_user->id,"smownerid"=>$smownerid,'modifiedby'=>$current_user->id,'createdtime'=>'',
                                    'modifiedtime'=>'','currency_id'=>$currency_id,'conversion_rate'=>$currency_info['rate'],'currency_symbol'=>decode_html($currency_info['symbol'])),
				"ld_paymentplanscf"=>array('paymentplanid'=>'')//,'viewedtime'=>''$currency_info
               
			   );
$columns[]=array();
$i=1;
$paymentstatus="未收";
$d = date('Y-m-d H:i:s',time());
//$setsystem = getSys_deploy(53);//读取系统设置缓存 回款计划按照项目状态收款和提醒。1：是，2：否

crm_load_class_file('cls_ParentRelatedField_Data','include/RelatedField');
$cls_ParentRelatedFields = new cls_ParentRelatedField_Data('PaymentPlan',$_REQUEST["cust"],'');

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


$cls_ParentRelatedFields = new cls_ParentRelatedField_Data('PaymentPlan',$_REQUEST["record"],'');

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
    if(!isset($_REQUEST['plandate'.$i])&&!isset($_REQUEST['projectstatus'.$i]))
    {
        break;
    }
    $cols['ld_paymentplan']['createdtime']=$d;
    $cols['ld_paymentplan']['modifiedtime']=$d;
    //$cols['ld_paymentplan']['viewedtime']=$d;
    
    $cols['ld_paymentplan']['paymentplan_no']="#:#:#:#:#";//自动生成编号
    $cols['ld_paymentplan']['accountid']=$_REQUEST["cust"];//客户id
    $cols['ld_paymentplan']['entitytypeid']=$_REQUEST["record"];//合同订单或服务合同ID
    $cols['ld_paymentplan']['entitytype']=$_REQUEST["entitytype"];//  类型
    $cols['ld_paymentplan']['periodtime']=$_REQUEST["periodtime$i"];
    $cols['ld_paymentplan']['description']=$_REQUEST["description$i"];//备注
    if($paymenttype=='计划收款日期' || $paymenttype=='计划回款日期'){
        $cols['ld_paymentplan']['plandate']=$_REQUEST["plandate$i"];
    }else{
        $cols['ld_paymentplan']['plandate']=NULL;
    }
    if($paymenttype=='项目状态'){
        $cols['ld_paymentplan']['projectstatus']=$_REQUEST["projectstatus$i"];
        $cols['ld_paymentplan']['projectid']=$_REQUEST["projectid$i"]; //wym XUQIU1001598 收款计划增加单选“项目立项”字段，保存项目立项字段
    }else{
        $cols['ld_paymentplan']['projectstatus']='';
        $cols['ld_paymentplan']['projectid']='';
    }
    $cols['ld_paymentplan']['amount']=$_REQUEST["amount$i"];
    $cols['ld_paymentplan']['paymentstatus']=$paymentstatus;      
    //$adb->query($sql_PaymentPlan);
    $columns[$i-1]=$cols;
    $i++;
}
//16837: 合同订单-查看界面：创建回款计划保存后，结果弹出了一个打印弹出层
/**
 * diony    
 * 2014-11-27
 * 合同订单保存后是否立即打印1:否，0:是

$deployarray=getSys_deploy('57');
$pirintStr = '';
if($deployarray['deploy_value'] == 0)
{
    $pirintStr = '&isprint=yes';
} 
 */
$arr = array();
$go_module = $_REQUEST["entitytype"];
 //16893: 合同订单>新增，关于新增保存后没有弹出打印模板弹出窗的问题
 if(isset($_REQUEST['printstr'])&&$_REQUEST['printstr']!=''&&$go_module=='SalesOrder'){
    $printstr=$_REQUEST['printstr'];
    $deployarray=getSys_deploy(57);
    $deployvalue = $deployarray['deploy_value'];
    if($deployvalue==0&&isPermitted($go_module,"Print",'') == 'yes'){
        $arr['sysdeploy'] =array($go_module=>array('deploytype'=>57,'deployvalue'=>$deployvalue,'record'=>$_REQUEST['record']));
    }
 }

$focus->MassSave($modules,$columns);


$_REQUEST['diony']='diony';
ConvertTojsonString(1,$arr,"success");
?>