<?php        
//群发短信保存
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 
global $adb;
 
 #随机获取批次号
 function GetBatchNo()
 {
    global $adb;
    
    $strBatchNo = "";
    $strDigit = "000001";
    $strZero = "";
    $digit = 0;
    $i=0;
    $strBatchNoSql = "select BatchNo from ld_smssend where date(CreateTime) = curdate() order by taskid desc limit 0,1";
    $resultBatchNo =$adb->pquery($strBatchNoSql);
    $strBatchNo='000001';
    if($adb->num_rows($resultBatchNo)>0)
    {
        $strBatchNo = $adb->query_result($resultBatchNo,'BatchNo');//批次号  
        $strDigit = substr($strBatchNo,12, strlen($strBatchNo) - 6); 
        
        $digit = intval($strDigit) + 1;
        if(strlen($digit)<6)
        {
            $Count =  6-strlen($digit);
            for($i=0;$i<$Count;$i++)
            {
                $strZero .= "0";
            }
        }
        $strDigit = $digit;    
    }
    if ($strZero!="")
    {
        $strBatchNo = date("ymd").$strZero.$strDigit;
    }
    else
    {
        $strBatchNo = date("ymd").$strDigit;
    }
    
    //print_r($strBatchNo);
    //exit();
    /*判断是否存在批次号，如果存在再次生成新的批次号*/
    $strCheck = substr($strBatchNo,6, strlen($strBatchNo) - 6); 
    $checkBatchNo = 'SELECT count(1) as count FROM ld_smssend where BatchNo = '.$strCheck;
    $checkBatchNoresult =$adb->pquery($checkBatchNo);
    //$BatchNoCount = $adb->query_result($checkBatchNoresult,0,'count');
    $num_rows=$adb->num_rows($checkBatchNoresult);
    if(!$num_rows)
    {
        GetBatchNo();
    }    
    /*随机生成6位字符串*/
    $chars='0123456789abcdefghijklmnopqrstuvwxyz';
    mt_srand((double)microtime()*1000000*getmypid());  
    $strRand=""; 
    while(strlen($strRand)<6)  
    {
        $strRand.=substr($chars,(mt_rand()%strlen($chars)),1);
    }
    $strBatchNo = $strRand.$strBatchNo;
    return $strBatchNo;
 }
  require_once('include/Ajax/CommonAjax.php');
//require_once('modules/MassSMS/SendView.php');
/*if(isset($_REQUEST['mode']) && $_REQUEST['mode'] == 'ajax'){
    require_once('include/Ajax/CommonAjax.php');
}else{
  header("Location:index.php?module=MassSMS&action=SendView");  
}*/
?>