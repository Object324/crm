<?php
/*******************************************************
**edit:chj
**date:2014-4-16
**reason:期间入库\期间出库 详细
*******************************************************/
global $adb,$currentModule,$current_user;
global $list_max_entries_per_page_new;
$smarty=new lingdangCRM_Smarty;
$pricetype = $_REQUEST['pricetype'];
$firstdate = $_REQUEST['startdate'];
$lastdate = $_REQUEST['enddate'];
$productid = $_REQUEST['productid'];
$warehouseid = $_REQUEST['warehouseid'];
$ledger = $_REQUEST['ledger'];
if($_REQUEST['type'] == 1)
{
    $query = "select a.type,c.name,a.inputqty as qty,b.productname,b.product_no,b.productsheet,a.inputqty,d.last_name,a.operationtime,a.modulename from ld_warehousecondtions a, ld_products b,ld_warehouse c,ld_users d   
where a.productid = b.productid and a.warehouseid = c.id and a.smownerid = d.id  
    and a.operationtime between '$firstdate' and '$lastdate' 
    and a.productid = $productid and a.warehouseid = $warehouseid and (type='确认初始库存' or type='确认入库' or type='撤销入库' or type ='退货入库' or type ='新增入库单' or type ='编辑入库单' or type ='删除入库单' or (type ='撤销退货' and modulename ='SalesBack') ";
    if($ledger == 1)
    {
        $query .= " or (`type` = '确认盘点' and a.inputqty>0) or (type = '撤销盘点' and a.outputqty>0) ";
    }
}
else
{
    $query = "select a.type,c.name,a.outputqty as qty,b.productname,b.product_no,b.productsheet,a.inputqty,d.last_name,a.operationtime,a.modulename,a.entityid,e.out_no as storeno 
    from ld_warehousecondtions a, ld_products b,ld_warehouse c,ld_users d,ld_outboundorder e where a.productid = b.productid and a.warehouseid = c.id and a.smownerid = d.id and e.out_id = a.entityid 
    and a.operationtime between '$firstdate' and '$lastdate' 
    and a.productid = $productid and a.warehouseid = $warehouseid and ( type='确认出库' or type='撤销出库' or type='新增出库单' or type='编辑出库单' or type='删除出库单' ";
    if($ledger == 1)
    {
        $query.=" or (type='撤销盘点' and a.inputqty>0) or (type='确认盘点' and a.outputqty>0) ";
    }
}
$query.=' )';
$smarty->assign('TYPE',$_REQUEST['type']);
$smarty->assign('PRICETYPE',$_REQUEST['pricetype']);
$smarty->assign('STARTDATE',$_REQUEST['startdate']);
$smarty->assign('ENDDATE',$_REQUEST['enddate']);
$smarty->assign('PRODUCTID',$_REQUEST['productid']);
$smarty->assign('WAREHOUSEID',$_REQUEST['warehouseid']);
$smarty->assign('LEDGER',$_REQUEST['ledger']);
$noofrows =$adb->num_rows($adb->pquery($query,array()));
$smarty->assign('NUMOFROWS',$noofrows);
$queryMode = (isset($_REQUEST['query']) && $_REQUEST['query'] == 'true');
$start = ListViewSession::getRequestCurrentPage($currentModule, $noofrows,0, $queryMode);
$smarty->assign('START',$start);
$navigation_array = VT_getSimpleNavigationValues($start,$list_max_entries_per_page_new,$noofrows);
$limit_start_rec = ($start-1) * $list_max_entries_per_page_new;
//echo $query. " LIMIT $limit_start_rec, $list_max_entries_per_page_new";
$result = $adb->pquery($query);

$recordListRangeMsg = getRecordRangeMessage($result, $limit_start_rec,$noofrows);

$smarty->assign('RECORDLISTRANGMSG',$recordListRangeMsg);
// Navigation
$navigationOutput = getTableHeaderSimpleNavigation2($navigation_array, '', $currentModule, 'index', 0);

$smarty->assign("NAVIGATION", $navigationOutput);

$num_rows=$adb->num_rows($result);
$Inventoryinfo=array();
for($i=0;$i<$num_rows;$i++){
    $Inventoryinfo[]=array('type'=>$adb->query_result($result,$i,'type'),
    'name'=>$adb->query_result($result,$i,'name'),
    'qty'=>$adb->query_result($result,$i,'qty'),
    'productname'=>$adb->query_result($result,$i,'productname'),
    'product_no'=>$adb->query_result($result,$i,'product_no'),
    'productsheet'=>$adb->query_result($result,$i,'productsheet'),
    'last_name'=>$adb->query_result($result,$i,'last_name'),
    'operationtime'=>$adb->query_result($result,$i,'operationtime'),
    'modulename'=>$adb->query_result($result,$i,'modulename'),
    'storeno'=>$adb->query_result($result,$i,'storeno'),
    );
}
$smarty->assign('INVENTAORYINFO',$Inventoryinfo);
echo '##SUCCESS##';

$smarty->display("InventoryLedger/InventoryDivListView.tpl");
exit();
?>