<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Chj
 */
if(isset($_REQUEST['rowid']) && !empty($_REQUEST['rowid'])&&isset($_REQUEST['frommodule']) && !empty($_REQUEST['frommodule']) && !empty($_REQUEST['pagemode'])){
	require_once('include/TabDetailFields/cls_TabDetailFieldsHtml.php');
	$frommodule = $_REQUEST['frommodule'];
	$rowid = $_REQUEST['rowid'];
	$focus = CRMEntity::getInstance($frommodule);
    $focus->mode = $_REQUEST['pagemode'];
    if($frommodule=='CashBill'){
        include ($root_directory.'modules/CashBill/CashBillDetailFieldsHtml.php');
        $TabDetailFieldsHtml = new CashBillDetailFieldsHtml($focus,$frommodule,$_REQUEST['sourcemodule']);
    }else if($frommodule=='SendCashBill'){
        include ($root_directory.'modules/SendCashBill/SendCashBillDetailFieldsHtml.php');
        $TabDetailFieldsHtml = new SendCashBillDetailFieldsHtml($focus,$frommodule,$_REQUEST['sourcemodule']);
    }
    else{
        $TabDetailFieldsHtml = new cls_TabDetailFieldsHtml($focus,$frommodule);
    }
    $focus->mode = $_REQUEST['pagemode'];
	$tabDetailsTr = $TabDetailFieldsHtml->getTabDetailHtmlContent($rowid);
	echo $tabDetailsTr;
	exit;
}
?>