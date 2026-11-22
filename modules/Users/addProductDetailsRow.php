<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Chj
 */
if(isset($_REQUEST['rowid']) && !empty($_REQUEST['rowid'])&&isset($_REQUEST['frommodule']) && !empty($_REQUEST['frommodule']) && !empty($_REQUEST['pagemode'])){
	$frommodule = $_REQUEST['frommodule'];
	$rowid = $_REQUEST['rowid'];
	//if(empty($_SESSION['cls_productDetailsHtml_obj'])){
	   if($frommodule=='CashBill'||$frommodule=='SendCashBill'){
	       $ProductDetailsHtml = crm_load_class_obj('cls_productDetailsHtml',"modules/$frommodule/productDetail",array($frommodule,$_REQUEST['sourcemodule']));
	   }
       else{
        $ProductDetailsHtml = crm_load_class_obj('cls_productDetailsHtml',"modules/$frommodule/ProductDetails",array($frommodule));
        }
    $ProductDetailsHtml->pagetype = $_REQUEST['pagemode'];
    /*}else{
	   require_once globalStatic::$root_directory.'modules/'.$frommodule.'/ProductDetails/cls_productDetailsHtml.php';
	    require_once globalStatic::$root_directory.'modules/'.$frommodule.'/ProductDetails/cls_productDetailsData.php';
	    require_once globalStatic::$root_directory.'include/ProductDetails/ProductFields.php';
	    require_once globalStatic::$root_directory.'include/ProductDetails/ProductToolFields.php';
        $ProductDetailsHtml = unserialize( $_SESSION['cls_productDetailsHtml_obj']);
   }*/
    if($frommodule=='WorkSheet'){
        if($_REQUEST['producttype']=='part'){
            $ProductDetailsHtml->producttype = 'part';
            $ProductDetailsHtml->related_productid = $_REQUEST['related_productid'];
            $productDetailsTr = $ProductDetailsHtml->getProductHtmlContent($rowid);
        }else{
            $selectedmodule = $_REQUEST['selected_module'];
            $sourse_detailobj = $ProductDetailsHtml->getDetailobjbyEntitytype($selectedmodule);
            $productDetailsTr = $sourse_detailobj->getProductHtmlContent($rowid);
        }
    }else{
        $productDetailsTr = $ProductDetailsHtml->getProductHtmlContent($rowid);
    }
    
    if(empty($_SESSION['cls_productDetailsHtml_obj'])){
        $_SESSION['cls_productDetailsHtml_obj'] = serialize($ProductDetailsHtml);
    }
    echo $productDetailsTr;
    exit;
}
?>