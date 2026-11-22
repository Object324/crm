<?php
/****************************************************************
**更新操作
**edit:kevin
**date:2013-11-04
reason:禁用仓库
****************************************************************/
global $adb;
if(isset($_REQUEST['record']) && $_REQUEST['record'])
$record=$_REQUEST['record'];
crm_load_function_file('getProductQtySaveOrCheck','include/Stock','CommonStock');
$tmpproductqtys= getProductQtySaveOrCheck("",$record,"");
$row_ware_pro = 0;
foreach($tmpproductqtys as $productid => $pro_arr){
	foreach($pro_arr[$record] as $ware_qty){
		$productqty += $ware_qty;
		$row_ware_pro++;
	}
}
if(isset($_REQUEST['status']) && $_REQUEST['status']!='')
$status=$_REQUEST['status'];
if($status=='forbidden'){
    if($productqty != 0){
        echo '###Used###';
        exit();
    }else{
        if($row_ware_pro == 0)
        {
            $query='update ld_warehouse set status=1 where id=?';
        }
        else
        {
            $query='update ld_warehouse set status=1,started=1 where id=?';
        }
        $adb->pquery($query,array($record));       
        $sql='select * from ld_warehouse where status=0';
        $result=$adb->pquery($sql,array());
        if($adb->num_rows($result)<=0)
        {
            $sql="update ld_field set presence=1 where tabid=14 and(columnname=? or columnname=?) ";
            $adb->pquery($sql,array('qtyinstock','qtyearly'));
            unsetCacheDirectory("fields");
            
        } 
        echo '###Successed##';
        exit();
    }
}else{
    $query='update ld_warehouse set status=0 where id=?';
    $adb->pquery($query,array($record));
    echo '###Successed##';
    exit();
}

?>