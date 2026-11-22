<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 
/*保存短信*/

global $adb;
global $current_user;
$smarty = new lingdangCRM_Smarty;
//getOutAccounts
$AccArr = array();

$receivephone = $_REQUEST['textRecipient'];
//$receivephone = str_replace('>',';',$receivephone);
#将转换后的信息分割成数组
//$receivephoneresults = explode(">",$receivephone);
$receivephoneresults=explode("\r\n",$receivephone);

$SMSarray = GetSMSAutograph();
crm_load_class_file('cls_Send_MassSms','include/utils');
$cls_Send_MassSms = new cls_Send_MassSms();
$i = 0;
foreach ($receivephoneresults as $result)
{    
    if(isset($result[10]))
    {   
        #获取电话号码
        $CalledNumber = substr($result, 0, 11);
        if($CalledNumber!='' && preg_match("/^((\(\d{3}\))|(\d{3}\-))?1\d{10}$/",$CalledNumber))
        {
			$cls_Send_MassSms->send($result,$_REQUEST['textContext']);
        }
    }
}
?>