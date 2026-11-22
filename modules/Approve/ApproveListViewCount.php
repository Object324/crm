<?php
/**
*edit:xiaoshun
*date:2016-11-09
*reason:我的审批中心
**/
crm_load_class_file('cls_Approve_countListView','modules/Approve');
$smarty=new lingdangCRM_Smarty;
if(isset($_REQUEST['tabtype']) && !empty($_REQUEST['tabtype'])){
    $tabtype = $_REQUEST['tabtype'];
}else{
    $tabtype = 0;
}

$obj = new cls_Approve_countListView($tabtype);
$approveinfo = $obj->getapprovelist();

$total = 0;
foreach($approveinfo as $val){
    $total += $val['num'];
}

$smarty->assign('APPROVEARR',$approveinfo);
$smarty->assign('TABTYPE',$tabtype);
$smarty->assign('APPROVESTATUS',$tabtype);
$smarty->assign('TOTAL',$total);
$smarty->display('Approve/ListViewCount.tpl');
?>