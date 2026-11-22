<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 
/*保存短信*/
//合同订单，出库单,销售退货单等弹出层短信保存

global $adb;
global $current_user;
$smarty = new lingdangCRM_Smarty;
$outid=$_REQUEST['outid'];
//getOutAccounts
$AccArr = array();

$receivephone = $_POST['textRecipient'];
//$receivephone = str_replace('>',';',$receivephone);
#将转换后的信息分割成数组
//$receivephoneresults = explode(">",$receivephone);
$receivephoneresults=explode("\r\n",$receivephone);

$SMSarray = GetSMSAutograph();
$autograph = $SMSarray['autograph'];
        
$i = 0;
foreach ($receivephoneresults as $result)
{    
    if(isset($result[10]))
    {   
        #获取电话号码
        $CalledNumber = substr($result, 0, 11);
        if($CalledNumber!='' && preg_match("/^((\(\d{3}\))|(\d{3}\-))?1\d{10}$/",$CalledNumber))
        {
            #获取接收名称
            if(strpos($result,"<"))
            {
                $arr1 = explode("<",$result);
                $ReceiveContacts = str_replace('>','',$arr1[1]);
            }
            else
            {
                $ReceiveContacts = $CalledNumber;
            }
            
            
            $AccArr[$i]['phone'] = $CalledNumber;
            $AccArr[$i]['accountname'] = $ReceiveContacts;
            
            $sql_salutation = "select salutation from ld_contactdetails where phone = ?";
            $result_salutation = $adb->pquery($sql_salutation, array($CalledNumber));
            $nums_con=$adb->num_rows($result_salutation);
            $salutation = '';
            if($nums_con>0)
            {
                $salutation = $adb->query_result($result_salutation,0,'salutation');
            }
            $AccArr[$i]['salutation']=$salutation;
            $i++;
        }
    }
}
crm_load_class_file('cls_Send_MassSms','include/utils');
$cls_Send_MassSms = new cls_Send_MassSms();
/**
 *@edit:andy
 *@date:20140421
 *@reason:v5.3 出库单短信通知改进
 */ 
for($i = 0; $i<count($AccArr); $i++)
{
    if(isset($AccArr[$i]['phone']) && $AccArr[$i]['phone'] != '')
    {
        //$id=$adb->getUniqueID('ld_smssend');
        $BatchNo=GetSMSBatchNo();
        $CalledNumber = $AccArr[$i]['phone'];
        $SmsContent = $_REQUEST['textContext'];
        $name=$AccArr[$i]['accountname'];
        if($AccArr[$i]['salutation']== '')
        {
            $app='';
        }
        else
        {
            $app=$AccArr[$i]['salutation'];
            if($app=='--无--'){
                 $app='';   
            }
        }
        $SmsContent = str_replace('{name}',$name,$SmsContent);
        $SmsContent = str_replace('{app}',$app,$SmsContent);
        $now = date("Y-m-d H:i:s");
		if(isset($_REQUEST['frommodule'])){
			if($_REQUEST['frommodule'] == 'SalesOrder'){
				$receiveTheme = '合同产品下单短信';
			}
            else if($_REQUEST['frommodule'] == 'SalesBack')
            {
                $receiveTheme = '结束退货短信';
            }
            else{
				$receiveTheme = "确认出库短信";		
			}
		}
        $operator = $current_user->user_name;
        $accountname = $name;
        $SmsContent = $SmsContent.'【'.$autograph.'】';
		if(!empty($accountname)){
			$CalledNumber = $CalledNumber . '<'.$accountname.'>';
		}
		$cls_Send_MassSms->send($CalledNumber,$SmsContent);
    }
}

header("Location: index.php?action=DetailView&module=".$_REQUEST['frommodule']."&record=".$outid);

?>