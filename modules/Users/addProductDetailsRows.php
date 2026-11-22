<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Chj
 */
if(isset($_REQUEST['rowid']) && !empty($_REQUEST['rowid'])&&isset($_REQUEST['frommodule']) && !empty($_REQUEST['frommodule'])){
	$frommodule = $_REQUEST['frommodule'];
	$rowid = $_REQUEST['rowid'];
    $nextrowcount=$_REQUEST['nextrowcount'];
    
	$ProductDetailsHtml = crm_load_class_obj('cls_productDetailsHtml',"modules/$frommodule/ProductDetails",array($frommodule));
	for($rowid;$rowid<$nextrowcount;$rowid++)
    {
        $ProductDetailsHtml->tablecontents=array();
       
        $productDetailsTr[] = $ProductDetailsHtml->getProductHtmlContent($rowid);
    }
   
	$jsonentity = Zend_Json::encode($productDetailsTr);
	echo $jsonentity;exit();
	
}
?>