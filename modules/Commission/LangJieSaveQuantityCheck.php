<?php
/**
 * edit:can 20200818 
 * 1.客服下单->出入库订单”，当“出库”类型的单据关联“入库”类型单据单时，
 * 自动计算并带出剩余可出库数量“商品数量”，并且保存时增加校验累积出库数量不允许超出入库数量
 * */
 global $adb;
$record=$_REQUEST['commissionid'];

$quantityinfo=json_decode($_REQUEST['quantityinfo'],true);
$db_quantity_arr=array();

if($record>0)
{
    $sql='select sf217,parent_lineitem_id from ld_commission2payment
     inner join ld_commission2paymentscf on ld_commission2payment.commission2payment_id=ld_commission2paymentscf.commission2payment_id
     where commission_id=?';
     $result=$adb->pquery($sql,array($record));
     $rows=$adb->num_rows($result);
     for($i=0;$i<$rows;$i++)
     {
        $tmp_parent_lineitem_id=$adb->query_result($result,$i,'parent_lineitem_id');
        $sf217=$adb->query_result($result,$i,'sf217');
        $db_quantity_arr[$tmp_parent_lineitem_id]=$sf217;
     }
     
}
$parent_lineitem_id_arr=array();
foreach($quantityinfo as $info)
{
    $parent_lineitem_id_arr[]=$info['parent_lineitem_id'];
    $id_quantity[$info['parent_lineitem_id']]=$info;
}
$parent_lineitem_id_arr=array_unique($parent_lineitem_id_arr);
$sql='select sf217_balance,commission2payment_id  from ld_commission2paymentscf where commission2payment_id in( '.implode(',',$parent_lineitem_id_arr).') ';
$result=$adb->pquery($sql);
$rows=$adb->num_rows($result);
$code=1;
$deploy_value=getSys_deploy(49);//数量字段控制
$decimallen=$deploy_value['deploy_value'];
for($i=0;$i<$rows;$i++)
{
    
    $sf217_balance=$adb->query_result($result,$i,'sf217_balance');
    $commission2payment_id=$adb->query_result($result,$i,'commission2payment_id');
    if(array_key_exists($commission2payment_id,$db_quantity_arr))
    {
        //如果是编辑界面，则剩余的商品数量需要添加当前单据的商品数量值
        $sf217_balance=$sf217_balance+$db_quantity_arr[$commission2payment_id];
        
    }
    
    $sf217count=$id_quantity[$commission2payment_id]['sf217count'];//获取界面商品数量
    $deskrowi=$id_quantity[$commission2payment_id]['rowi'];
   $sf217_balance=number_format($sf217_balance, $decimallen, '.', '');
   $sf217count=number_format($sf217count, $decimallen, '.', '');
    if($sf217_balance<$sf217count)
    {
            //如果剩余商品数量小于界面手动输入数量
            
            $msg.='第'.$deskrowi.'行商品数量('.$sf217count.')不能大于剩余商品数量('.$sf217_balance.")<br>";
            $code='-1';
    }
}
$_REQUEST['diony']='diony';
ConvertTojsonString($code,array(),$msg);

?>