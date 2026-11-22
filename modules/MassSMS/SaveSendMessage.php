<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 
/*保存短信*/
//合同订单，出库单,销售退货单等弹出层短信保存

global $adb;
global $current_user;
$smarty = new lingdangCRM_Smarty;

$AccArr = array();
$SMSarray = GetSMSAutograph();
$autograph = $SMSarray['autograph'];
crm_load_class_file('cls_Send_MassSms','include/utils');
$cls_Send_MassSms = new cls_Send_MassSms();
for($i=0;$i<$_REQUEST['count_con'];$i++){

    $phone = $_REQUEST['text_'.$i];
    $content = $_REQUEST['area_'.$i];
    $smsto = $_REQUEST['type_'.$i];
    $username = $_REQUEST['user_'.$i];
    
    //详情页新增的号码没有record_$i，直接取ticketid值
    if($_REQUEST['fromview'] == 'listview'){
        $record = $_REQUEST['record_'.$i];
    }else{
        $record = $_REQUEST['ticketid'];
    }
    
    $CalledNumber = substr($phone, 0, 11);
    
    if($CalledNumber!='' && preg_match("/^((\(\d{3}\))|(\d{3}\-))?1\d{10}$/",$CalledNumber)){
        if(isset($_REQUEST['box_'.$i]) && $_REQUEST['box_'.$i] == 1){
			$SmsContent = $content.'【'.$autograph.'】';
			if(!empty($username)){
				$CalledNumber = $CalledNumber . '<'.$username.'>';
			}
			$cls_Send_MassSms->send($CalledNumber,$SmsContent);
        }
    }
}

if($_REQUEST['fromview'] == 'listview'){//列表页
    header("Location: index.php?module=HelpDesk&action=index&parenttab=Service");
}else{//详情页
    header("Location: index.php?action=DetailView&module=".$_REQUEST['frommodule']."&record=".$_REQUEST['ticketid']);
}

?>