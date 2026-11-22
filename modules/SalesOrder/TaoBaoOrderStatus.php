<?php
/**
 * edit:can
 * reason:修改淘宝订单状态，将其修改为已发货
 * */
 global $adb;
$excludedRecords = vtlib_purify($_REQUEST['excludedRecords']);
$smowner=vtlib_purify($_REQUEST['smowner']);//by kevin
$SearchScope=$_REQUEST['SearchScope'];
$focus = CRMEntity::getInstance($currentModule);

$disp_view = getView($focus->mode);
$idstring = vtlib_purify($_REQUEST['idstring']);
$storearray = getSelectedRecords($_REQUEST, $currentModule, $_REQUEST['idstring'],$excludedRecords);
$records=str_replace(';',',',$idstring);
if($idstring=='all')
{
    $records="'".implode("','",$storearray)."'" ;
}
if(sizeof($storearray)>200)
{
    $page_size=ceil(sizeof($storearray)/200);
    
}
if($page_size*200<sizeof($storearray))
{
    $page_size+=1;
}
 require_once('include/taobao/OrderAPI.php');
for($j=0;$j<$page_size;$j++)
{
    $page_ids=array_slice($storearray,$j*200,200);//一次获取200个id,因为如果“全选",id字符串太长可能会导致sql错误
     $records="'".implode("','",$page_ids)."'" ;
    $sql="select salesorder_no,ziptype,logistics_no,salesorderid from ld_salesorder  where salesorderid in($records)  ";
    $result=$adb->pquery($sql,array());
    
     for($i=0;$i<$adb->num_rows($result);$i++)
     {
        $salesorder_no=$adb->query_result($result,$i,'salesorder_no');
        $ziptype=$adb->query_result($result,$i,'ziptype');
        $logistics_no=$adb->query_result($result,$i,'logistics_no');
         $salesorderid=$adb->query_result($result,$i,'salesorderid');
        $orderapi=new OrderAPI();
        if(!empty($logistics_no)&&!empty($ziptype))
        {
             $orderapi->logistics_online_send($ziptypeistics_no,$salesorder_no,$salesorderid);
             $sql=' update ld_salesorder set due_date=? where salesorder_no=?';
             $adb->pquery($sql,array(date("Y-m-d"),$salesorder_no));
        }
     }
}

 header("Location: index.php?module=SalesOrder&action=ListView");
?>