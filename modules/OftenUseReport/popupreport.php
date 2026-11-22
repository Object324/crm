<?php
/**
 * 更新操作
 * edit:andrew
 * date:20150402
 * reason:常用报表复泰弹出层
 * */
//zkt 20231010 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
include('ImportSModule.php');
$smarty = new lingdangCRM_Smarty();
global $current_user,$adb;
$potentialid=$_REQUEST['potentialid'];

$SQL="SELECT 
        ld_contactdetails.lastname,
        ld_potential.closingdate,
        ld_contactdetails.contactid,
        ld_products.productname 
        FROM 
        ld_potential 
        LEFT JOIN ld_contpotentialrel ON ld_potential.potentialid = ld_contpotentialrel.potentialid 
        LEFT JOIN ld_contactdetails ON ld_contactdetails.contactid = ld_contpotentialrel.contactid 
        LEFT JOIN ld_products ON ld_products.productid=ld_potential.product_id
        WHERE 
        ld_potential.deleted = 0 
        AND ld_contactdetails.deleted = 0 
        AND ld_potential.potentialid=$potentialid ORDER BY closingdate DESC;";

$result=$adb->query($SQL);
$rowCount = $adb->num_rows($result);
for ($i = 0; $i < $rowCount; $i++) {      
    $contactid = $adb->query_result($result, $i, 'contactid');
    $ViewList[$contactid]['lastname'] = $adb->query_result($result, $i, 'lastname');
    $ViewList[$contactid]['closingdate'] = $adb->query_result($result, $i, 'closingdate');
    $ViewList[$contactid]['productname'] = $adb->query_result($result, $i, 'productname');
}
$smarty->assign('ViewList',$ViewList);
echo $smarty->display("modules/OftenUseReport/ViewReport_Popup.tpl");
exit();

?>