<?php
/*****************************************************
**更新操作
**edit:kevin
**date:2013-11-05
**reason:保存库存初始化--暂存
*****************************************************/
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb,$default_charset;
if(isset($_REQUEST['idlist']) && $_REQUEST['idlist']!='')
$idlist=$_REQUEST['idlist'];
if(isset($_REQUEST['warehouseid']) && $_REQUEST['warehouseid'])
$warehouseid=$_REQUEST['warehouseid'];
//$idlist=mb_substr($idlist,0,strlen($idlist)-1,$default_charset);
$idlist = rtrim($idlist, ";"); 

$query='select productid from ld_warehouse2startedproducts where warehouseid=?';
$result=$adb->pquery($query,array($warehouseid));

$num_rows=$adb->num_rows($result);
$startproductids=array();
for($i=0;$i<$num_rows;$i++){
    $startproductids[]=$adb->query_result($result,$i,'productid');
}


if(count($startproductids) > 0)
{
    //edit:can reason:10870: 库存初始化：【确认】功能存在问题 other:可以分页暂存
    //$adb->pquery("delete from ld_warehouse2startedproducts where warehouseid=$warehouseid");
}
$productidsarr=explode(';',$idlist);
//$prdids=array_diff($productidsarr,$startproductids);//去掉已经初始化过的产品id
//foreach($productidsarr as $productid){
foreach($productidsarr as $productid){
    if(isset($_REQUEST[$productid.'_qtyinstock']) && $_REQUEST[$productid.'_qtyinstock'] != '')
        $qty=$_REQUEST[$productid.'_qtyinstock'];
    else
        $qty = 0;
    if($qty == 0)
        $qty = 0;
    //$values .='('.$warehouseid.','.$productid.','.$qty.'),';
    
    //edit:can reason:12208: 库存初始化：如下面有2个产品，录入数量后，点击【暂存】，结果产品会变成4个，再次点击【暂存】，产品会一直增加。
    $sql='delete from ld_warehouse2startedproducts  where warehouseid=? and productid=?';
    $adb->pquery($sql,array($warehouseid,$productid));
    
    $query = "insert into ld_warehouse2startedproducts(warehouseid,productid,qty)value(?,?,?)";
    $adb->pquery($query,array($warehouseid,$productid,$qty));
    //echo $values . '<br>';
    //$conditionid=$adb->getUniqueID('ld_warehousecondtions');
    //$valuescondition .='('.$conditionid.',0,'."'库存初始化'".','."'确认初始库存',".$warehouseid.','.$productid.
    //',0,'.$qty.',0,'.$qty.",'".date('Y-m-d H:i:s')."',".$current_user->id.'),';
}

if(!empty($prdids)){
    $values=substr($values,0,strlen($values)-1);
    $adb->query($query.$values);
   
}
/**
 * 更新操作
 * edit:kevin
 * date:2013-11-27
 * reason:	0005871: 仓库初始化界面：勾选产品更改产品数量保存后不点击确认按钮，再次勾选该产品更改产品数量点击保存后结果数量无法更改了
 */ 
foreach($startproductids as $productid){
    if(isset($_REQUEST[$productid.'_qtyinstock']) && $_REQUEST[$productid.'_qtyinstock'] != null || $_REQUEST[$productid.'_qtyinstock']===0)
    {
        $qty=$_REQUEST[$productid.'_qtyinstock'];
        if($qty == 0)
            $qty = 0;
    }
    else
    {
        $qty = selWareHouseProductNum($warehouseid,$productid);
    }
    //echo $query . '--' . $warehouseid .'--' . $productid . '--' . $qty . '<br>';
    $query='update ld_warehouse2startedproducts set qty=? where warehouseid=? and productid=?';
    $adb->pquery($query,array($qty,$warehouseid,$productid));
}
function selWareHouseProductNum($warehouseid,$productid)
{
    global $adb,$default_charset;
    $sql = "select qty from ld_warehouse2startedproducts where warehouseid = ? and productid = ?";
    $result=$adb->pquery($sql,array($warehouseid,$productid));
    return $adb->query_result($result,0,'qty');
}
$_REQUEST['diony']='diony';
 ConvertTojsonString(1,array(),"success");
//header('Location:index.php?module=Prdtnums&action=index&parenttab=Stock&warehouseid='.$warehouseid);
?>