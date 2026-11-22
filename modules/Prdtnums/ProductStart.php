<?php
/*****************************************************
**更新操作
**edit:kevin
**date:2013-11-05
**reason:保存库存初始化
*****************************************************/
global $adb,$default_charset,$currentModule, $current_user;
require_once ('include/Stock/CommonStock.php');
$sumqty = 0;
//@edit:liushuai,2020-08-10,reason:0042268: （61mis.com/kfbcrm）库存初始化模块>选择“货仓”：勾选了两页产品，在结束初始化后，只显示出第一页的产品。（需要补丁）
//多页面初始化，初始化数据应该根据页面‘暂存’按钮存到ld_warehouse2startedproducts表的数据去初始化，而不是根据前端form表单提交的当前页去初始化。（前端数据没啥用，$idlist，$productidsarr相关逻辑已注释）
/*if(isset($_REQUEST['idlist']) && $_REQUEST['idlist']!='')
$idlist=$_REQUEST['idlist'];*/

if(isset($_REQUEST['warehouseid']) && $_REQUEST['warehouseid'])
$warehouseid=$_REQUEST['warehouseid'];
//$idlist=mb_substr($idlist,0,strlen($idlist)-1,$default_charset);
/*$idlist = trim($idlist,';');
$productidsarr=explode(';',$idlist);*/
//edit:can date:20140522 reason:初始化后不再往暂存表插入数据
//$query='insert into ld_warehouse2startedproducts(warehouseid,productid,qty)value';
$selSql = "select productid,qty from ld_warehouse2startedproducts where warehouseid = ? order by productid asc";//初始化后跟当前排序保持一致
$result=$adb->pquery($selSql,array($warehouseid));
$num_rows = $adb->num_rows($result);

if($num_rows >= 1)
{
    for($i = 0; $i<$num_rows; $i++)
    {
        $productid = $adb->query_result($result,$i,"productid");
        $qty = $adb->query_result($result,$i,"qty");
        insertProductQty($productid,$qty,1);
//        $values .='('.$warehouseid.','.$productid.','.$qty.'),';

        $conditionid=$adb->getUniqueID('ld_warehousecondtions');
        $sql=" insert into ld_warehousecondtions(id,entityid,modulename,type,warehouseid,productid,firstqty,inputqty,outputqty,lastqty,operationtime,smownerid,module) values ";
        $valuescondition =' ('.$conditionid.',0,'."'库存初始化'".','."'确认初始库存',".$warehouseid.','.$productid.
        ',0,'.$qty.',0,'.$qty.",'".date('Y-m-d H:i:s')."',".$current_user->id.',"'.$currentModule.'")';
        $sql=$sql.$valuescondition;

        $adb->pquery($sql,array());
    }
    $querystr='delete from ld_warehouse2startedproducts where warehouseid=?';
    $adb->pquery($querystr,array($warehouseid));

    $query='update ld_warehouse set started=0 where id=?';
    $adb->pquery($query,array($warehouseid));
}
 
/*foreach($productidsarr as $productid){
       // if(isset($_REQUEST[$productid.'_qtyinstock']) && $_REQUEST[$productid.'_qtyinstock'] >= 0)
			//$qty=$_REQUEST[$productid.'_qtyinstock'];
		//else
			//continue;
		$qty=$_REQUEST[$productid.'_qtyinstock'];
		if(empty($qty)) $qty = 0;
        insertProductQty($productid,$qty,1);
         $conditionid=$adb->getUniqueID('ld_warehousecondtions');
	   	$sql=" insert into ld_warehousecondtions(id,entityid,modulename,type,warehouseid,productid,firstqty,inputqty,outputqty,lastqty,operationtime,smownerid,module) values ";
       
        $valuescondition=' ('.$conditionid.',0,'."'库存初始化'".','."'确认初始库存',".$warehouseid.','.$productid.
        ',0,'.$qty.',0,'.$qty.",'".date('Y-m-d H:i:s')."',".$current_user->id.',"'.$currentModule.'")';
        $sql=$sql.$valuescondition;
        
        $adb->pquery($sql,array());
  
        
}*/

//if(!empty($productidsarr)){
//
//   // $adb->query($query.$values);
//    //$adb->query('insert into ld_warehouse2products(warehouseid,productid,productqty)value'.$values);
//   /* $query='insert into ld_warehousecondtions(id,entityid,modulename,type,warehouseid,productid,firstqty,
//    inputqty,outputqty,lastqty,operationtime,smownerid,module)value';
//    $valuescondition=substr($valuescondition,0,strlen($valuescondition)-1);
//    $adb->query($query.$valuescondition);*/
//
//    $query='update ld_warehouse set started=0 where id=?';
//    $adb->pquery($query,array($warehouseid));
//}

/**
 * 更新操作
 * edit:can
 * date:20140103
 * reason:6670: 新增一个产品，对该产品做完库存初始化后，结果该产品查看明细中“总库存数量”显示的是空白，希望库存初始化后，应该更新产品明细界面的“总库存数量”。
 * */
/*foreach($productidsarr as $productid){
    if(isset($_REQUEST[$productid.'_qtyinstock']) && $_REQUEST[$productid.'_qtyinstock'])
    $qty=$_REQUEST[$productid.'_qtyinstock'];
    insertProductQty($productid,$qty,1);
    
}*/
$_REQUEST['diony']='diony';
 ConvertTojsonString(1,array(),"success");
//header('Location:index.php?module=Prdtnums&action=index&parenttab=Stock&warehouseid='.$warehouseid);
?>