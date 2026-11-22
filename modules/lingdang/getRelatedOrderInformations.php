<?php

/*******{*修改编码格式:统一编码：UTF-8*}********/
/**
 *@edit: andy 
 *@date: 2014121
 *@reason: 收款单、销售发票新增源单信息区块
 *@version: v5.9
 */
global $currentModule;

$selectedIdstring=$_REQUEST['idstring'];
if($_REQUEST['frommod'] == 'Invoice'){
    $selectedIdstring=str_replace(';',',',$selectedIdstring);
}else{
    $orderinfo = explode('|',rtrim($_REQUEST['idstring'], "|"));
    for($i = 0; $i<count($orderinfo); $i++)
    {
        $orderinfoArr = explode(',',$orderinfo[$i]);
        $relatedOrderIdArr[] = $orderinfoArr[0];
    }
    $selectedIdstring = implode(',', $relatedOrderIdArr);
}

//数据格式不一致，判断处理
if($_REQUEST['relatedOrderIdString'] != '' && $_REQUEST['frommod'] == 'Invoice')
    $selectedIdstring.=$_REQUEST['relatedOrderIdString'];
else
    $selectedIdstring.=','.$_REQUEST['relatedOrderIdString'];


//区分编辑、新建
if($_REQUEST['edittype'] == 'create' && $_REQUEST['frommod'] == 'Invoice')
    $relatedinformations=getRelatedOrderInformation($_REQUEST['module'],$selectedIdstring,1,1);
else
    $relatedinformations=getRelatedOrderInformation($_REQUEST['module'],$selectedIdstring,1);

    $smarty = new lingdangCRM_Smarty();
    
    $smarty->assign("RELATEDORDERINFORMATION",$relatedinformations);
    $smarty->assign("RELATEDORDERIDSTRING", $selectedIdstring);//源单id
    echo '###gotpl###';
    $smarty->display("RelatedOrderInformation.tpl");
?>