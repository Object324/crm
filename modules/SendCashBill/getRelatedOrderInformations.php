<?php

global $currentModule;

$selectedIdstring=trim($_REQUEST['idstring'],',');
if($_REQUEST['frommod'] == 'PurchaseOrder'){
    $selectedIdstring=str_replace(';',',',$selectedIdstring);
}else{
    $orderinfo = explode('|',rtrim($selectedIdstring, "|"));
    for($i = 0; $i<count($orderinfo); $i++)
    {
        $orderinfoArr = explode(',',$orderinfo[$i]);
        $relatedOrderIdArr[] = $orderinfoArr[0];
    }
    $selectedIdstring = implode(',', $relatedOrderIdArr);
}

//数据格式不一致，判断处理
if($_REQUEST['relatedOrderIdString'] != '' && $_REQUEST['frommod'] == 'PurchaseOrder')
    $selectedIdstring.=$_REQUEST['relatedOrderIdString'];
else
    $selectedIdstring.=','.$_REQUEST['relatedOrderIdString'];


//区分编辑、新建
if($_REQUEST['edittype'] == 'create' && $_REQUEST['frommod'] == 'PurchaseOrder')
    $relatedinformations=getRelatedOrderInformation($_REQUEST['module'],$selectedIdstring,1,1);
else
    $relatedinformations=getRelatedOrderInformation($_REQUEST['module'],$selectedIdstring,1);

    $smarty = new lingdangCRM_Smarty();
    
    $smarty->assign("RELATEDORDERINFORMATION",$relatedinformations);
    $smarty->assign("RELATEDORDERIDSTRING", $selectedIdstring);//源单id
    echo '###gotpl###';
    $smarty->display("RelatedOrderInformation.tpl");
ob_clean();
ob_flush();
echo '###gotpl###';
exit();
?>