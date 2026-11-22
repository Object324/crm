<?php
/*+**********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ************************************************************************************/
 //date:2021-10-14 duan reason:客户和客户服务单详情页面的服务合同信息控制分开，所以客户模块下也要有文件
 global $adb, $currentModule, $current_user;
 $smarty=new lingdangCRM_Smarty();

 if(vtlib_isModuleActive('ServiceContracts') == false || $current_user->select_servicedetail == 0)
 {
    echo '###SUCCESS###1';
    exit; 
 }
$tmp_content_arr = [];
 if(isset($_REQUEST['accountid']) && $_REQUEST['accountid'] > 0)
 {
	 $nowdate = date('Y-m-d');
     $focus=CRMEntity::getInstance('ServiceContracts');
     if($focus->end_accountid_enable() == "yes")
         $tmp_accountid = "end_accountid";
     else
         $tmp_accountid = "accountid";

     //18037: 客户、服务单明细模块：服务信息中一个产品出现多少次
    $sql = '
		SELECT
			ld_servicecontracts.contract_no,
			ld_servicecontracts.subject,
			ld_servicecontracts.due_date,
			ld_products.productname,
			ld_products.productid,
			ld_products.product_no,
			ld_servicecontractsdetail.servicecontracts_end_date,
			ld_servicecontractsdetail.id,
			ifnull(
				ld_servicecontractsdetail.lineitem_id,
				0
			) AS lineitem_id,
			ld_servicecontracts.currency_id,
			ld_account.accountid,
			ld_servicecontracts.description 
		FROM ld_account 
		INNER JOIN (SELECT DISTINCT * FROM ld_maxservicedate) ld_maxservicedate ON ld_maxservicedate.accountid = ld_account.accountid
        LEFT JOIN ld_servicecontractsdetail ON ld_servicecontractsdetail.id=ld_maxservicedate.inventoryid AND ld_servicecontractsdetail.productid = ld_maxservicedate.productid 
		LEFT JOIN ld_servicecontracts ON ld_servicecontracts.'.$tmp_accountid.'=ld_account.accountid AND ld_servicecontractsdetail.id=ld_servicecontracts.servicecontractsid 
        LEFT JOIN ld_products ON ld_products.productid = ld_maxservicedate.productid
		WHERE ld_account.deleted = 0
			AND ld_servicecontracts.deleted=0
			AND ld_account.accountid > 0  
			AND ld_account.accountid=?
		ORDER BY ld_account.accountid DESC,ld_servicecontractsdetail.servicecontracts_end_date DESC
    ';
    $result = $adb->pquery($sql,array($_REQUEST['accountid']));

    $num_rows = $adb->num_rows($result);

    for($i = 0; $i<$num_rows; $i++)
    {
        //$current_user->select_servicedetail

        $tmp_content_arr[$i]['productname'] = '<a href="javascript:;" referencemodule="Products" referencerecord="'.$adb->query_result($result,$i,'productid').'"  onclick="DetailViewReferenceLinkClick(ld(this),event)">' . $adb->query_result($result,$i,'productname') . '</a>';
        $tmp_content_arr[$i]['product_no'] = $adb->query_result($result,$i,'product_no');
        $servicecontracts_end_date = $adb->query_result($result,$i,'servicecontracts_end_date');
        if($current_user->select_due_date == 0)
        {
            if($servicecontracts_end_date > $nowdate)
                $servicecontracts_end_date = getFixedLabel('PERIODOFSERVICE');
            else
                $servicecontracts_end_date = '<span style=color:#ff0000;"">' . getFixedLabel('OUTSIDEPERIODOFSERVICE') . '</span>';
        }
        $tmp_content_arr[$i]['servicecontracts_end_date'] = $servicecontracts_end_date;
        $tmp_content_arr[$i]['contract_no'] = $adb->query_result($result,$i,'contract_no');
        $tmp_content_arr[$i]['due_date'] = $adb->query_result($result,$i,'due_date');
        $tmp_content_arr[$i]['description'] = $adb->query_result($result,$i,'description');
    }
 }
$smarty->assign('CONTENT',$tmp_content_arr);
echo '###SUCCESS###';
$smarty->display("DetailView/AccountsDetailService.tpl");
exit();
 ?>