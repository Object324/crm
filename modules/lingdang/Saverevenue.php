<?php
/*
edit:duan
reason:中孚账套添加收入确认计划功能，保存页面
*/
global $currentModule,$adb,$current_user;
$fld_module = "CustomForm48";
$userid = $current_user->id;
$revenueyear = $_REQUEST['revenueyear'];
$revenuemouth =$_REQUEST['revenuemouth'];
$amount_type = $_REQUEST['amounttype'];
if($_REQUEST['selectid'] == 'all'){ //全部
    $id_list = getSelectedRecords($_REQUEST,$currentModule,$_REQUEST['selectid'],$_REQUEST['excludedRecords']); 
}else{
    $select_ids = $_REQUEST['selectid'];
    $select_id = trim($select_ids,",");
    $id_list = explode(",",$select_id); 
}

foreach($id_list as $id )//遍历所有选定的单据
{
    $focus = CRMEntity::getInstance($fld_module);
    setObjectValuesFromRequest($focus);//读取默认值
    if($currentModule =='Potentials')
    {
        $sql = "select amount,accountid from ld_potential WHERE potentialid = ?";
        $result = $adb->pquery($sql,array($id));
        $accountid = $adb->query_result($result, 0, 'accountid');
        $focus->column_fields['potential_id'] =$id;
        $revenuemoney = $adb->query_result($result, 0, 'amount');
    }
    else if($currentModule =='SalesOrder')
    {
        $sql = "select total,accountid,potentialid from ld_salesorder WHERE salesorderid = ?";
        $result = $adb->pquery($sql,array($id));
        $accountid = $adb->query_result($result, 0, 'accountid');
        $potentialid = $adb->query_result($result, 0, 'potentialid');
        $focus->column_fields['salesorder_id'] =$id;
        $focus->column_fields['potential_id'] =$potentialid;
        $revenuemoney = $adb->query_result($result, 0, 'total');
    }    
    if($amount_type=="input_amount")
    {
        $revenuemoney = $_REQUEST['revenuemoney'];
    }
    
    $focus->column_fields['cf_4284'] =$revenuemoney;
    $focus->column_fields['cf_4285'] =$revenuemouth;
    $focus->column_fields['cf_4288'] =$revenueyear;
    $focus->column_fields['account_id'] =$accountid;
    $focus->column_fields['smcreatorid'] =$userid;
    $focus->column_fields['assigned_user_id'] =$userid;
    $focus->save($fld_module);
}
$_REQUEST['diony']='diony';
ConvertTojsonString(1,array(),"success");
?>