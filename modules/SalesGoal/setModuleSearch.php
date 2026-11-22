<?php
/*+********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ********************************************************************************/
$advft_criteria = array();

//销售目标点击跳转
global $current_user,$languageType;
$searchmodule = $_REQUEST['searchmodule'];
//判断是否有该模块权限，若无权限则不跳转对应模块
if(!isPermitted($seachmodule))
{
    ConvertTojsonString(-1,array(),'error');//'modulelabel'=>getTranstab($searchmodule)
}
$search_date_value =$_REQUEST['search_date_value'];
$date = explode('~',$search_date_value);
$comparator='bw';
if(sizeof($date) < 2){
    $data_start= $search_date_value.'-01';
    $data_end =$search_date_value.'-'.DateOperation::getMonthDays($search_date_value.'-01');
    $date_value=$data_start.','.$data_end;
}else{
    $date_value=$date[0].','.$date[1];
}

switch ($searchmodule){
    case 'Accounts': //客户
        $columnname ='ld_account:createdtime:createdtime:Accounts_创建时间:D';
        break;
    case 'SalesOrder': //订单
        $columnname ='ld_salesorder:signed_data:signed_data:SalesOrder_签约日期:D';
        break;
    case 'ServiceContracts': //服务合同
        //ls 2022-05-20 0051778（https://81mis.com/kfbcrm/index.php）销售目标》目标查看页签，查看签约额，点击蓝色字体的已完成签约额，跳转到服务合同和合同订单后，服务合同高级查找没带入条件
        $columnname ='ld_servicecontracts:due_date:due_date:ServiceContracts_签约日期:D';
        break;
    case 'CashBill': //回款
        $columnname ='ld_cashbill:cashbilldate:cashbilldate:CashBill_收款日期:D';
        break;
    case 'Invoice': //开票
        $columnname ='ld_invoice:invoicedate:invoicedate:Invoice_开票日期:D';
        break;
    case 'OutboundOrder': //出库
        $columnname ='ld_outboundorder:outdate:outdate:OutboundOrder_出库日期:D';
        break;
    default:
        break;
}

$query[] = array(
    'groupid'=>1,
    'columnname'=>$columnname,
    'comparator'=>$comparator,
    'value'=>$date_value,
    'columncondition'=>'',
);
//print_r($query);
$arr['advft_criteria'] = $query;
$arr['pageto_module'] = $searchmodule;
$input['advft_criteria'] = json_encode($query);
$input['advft_criteria_groups'] = '';
$input['searchtype'] = 'advance';
$_SESSION['LiveViewSearch'][$searchmodule]['input'] = $input;
//清空当前模块的搜索条件
$_SESSION['lvs'][$searchmodule] = array();
$_SESSION['lvs'][$searchmodule]['SearchScope'] = 'smowner_search_senior';
$_SESSION['lvs'][$searchmodule]['senioruserid'] = $_REQUEST['selectuserid'];
//zkt 20220424 【ID1002776】【销售目标的超链接只跳转到销售合同模块】
ConvertTojsonString(1,$arr,'success');
//exit();
?>