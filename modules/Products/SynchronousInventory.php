<?php
/*+**********************************************************************************
 * edit:diony
 * time:2014-06-09
 * reson:库存同步
 * synchronous:只更新本系统产品库存数量
 * synchronousandinput:更新本系统产品库存数量，并导入新产品
 ************************************************************************************/

global $adb,$current_user, $mod_strings,$currentModule;
require_once("mssql/SqlServer.php");

$typename = $_REQUEST['type'];

//获取本系统中的产品信息
//$productsSql='select productid,product_no,productname,qtyinstock from ld_products';
$productsSql='select productid,product_no from ld_products where productid > 0 ';
$productsResult=$adb->pquery($productsSql,array());
$productsNum=$adb->num_rows($productsResult);

$productsArr=array();

if($typename == 'synchronousandinput')
{
    //获取本系统中的计量单位
    //Eidtor:gyq_64M Reason:下拉框改进 Date:2018/3/19 0019 下午 3:35
	crm_load_class_file("cls_PickList", 'modules/PickList');
	$objpinklist = new cls_PickList();
	$result_pick = $objpinklist->getPickListValues('usageunit','',array(),'id');
    $usageunitArr = array_flip($result_pick);

    /*$usageunitSql='select usageunitid,usageunit,presence,picklist_valueid  from ld_usageunit where usageunitid > 0 ';
    $usageunitResult=$adb->pquery($usageunitSql,array());
    $usageunitNum=$adb->num_rows($usageunitResult);
    
    $usageunitArr=array();
    if($usageunitNum){
        for($i=0;$i<$usageunitNum;$i++)
        {
            $usageunit = $adb->query_result($usageunitResult,$i,'usageunit');
            $usageunitArr[$usageunit]=$adb->query_result($usageunitResult,$i,'usageunitid');
        }
    }*/
}else{
	if($productsNum){
		for($i=0;$i<$productsNum;$i++)
		{
			$product_no = $adb->query_result($productsResult,$i,'product_no');
			$productsArr[$product_no]=$adb->query_result($productsResult,$i,'productid');
		}
	}
}

//获取本系统中的数据接口信息
/*
$dataInterfaceSql='select * from ld_DataInterface where id > 0 limit 1';
$dataInterfaceResult=$adb->pquery($dataInterfaceSql,array());
$sa=$adb->query_result($dataInterfaceResult,0,'sa');
$pwd=$adb->query_result($dataInterfaceResult,0,'pwd');
$databasename=$adb->query_result($dataInterfaceResult,0,'databasename');
$hostname=$adb->query_result($dataInterfaceResult,0,'hostname');
*/
$sa=getDatainterface('sa');
$pwd=getDatainterface('pwd');
$databasename=getDatainterface('databasename');
$hostname=getDatainterface('hostname');
$soft_version=getDatainterface('soft_version');

//链接数据库 
$con = conSqlserver($hostname,$sa,$pwd,$databasename);
if($con['conResult'] != 1){
	
}
$SqlCon = $con['sqlcon'];
$conResult=$con['conResult'];
//U8
if($soft_version == 102){
	$sql = "select inventory.cinvccode,CurrentStock.cinvcode,inventory.cinvname,inventory.cinvstd,
	computationUnit.cComunitName,InventoryClass.cinvcname,CurrentStock.iquantity,CurrentStock.iquantity from CurrentStock
	left join inventory on inventory.cinvcode = CurrentStock.cinvcode
	left join computationUnit on computationUnit.ccomunitcode = inventory.cComUnitCode
	left join InventoryClass on InventoryClass.cinvccode = inventory.cinvccode";
	//query语句 
	$result=$SqlCon->Query_result($sql);
	//输出结果
	$kisNum=$SqlCon->num_rows($result);


	$kis3Arr=array();
	if($kisNum){
		for($i=0;$i<$kisNum;$i++)
		{
			$row=$SqlCon->fetch_row($result);      
			if(isset($productsArr[$row[1]]))
			{
				$inventorySql='update ld_products set qtyinstock = ? where product_no = ?';
				$adb->pquery($inventorySql,array($row[6],$productsArr[$row[1]]));
				unset($productsArr[$row[1]]);
			}else{
				$kis3Arr[]=array(
					'FItemID'=> $row[0],	//物料ID
					'FNumber'=> $row[1],	//编号
					'FName'=> convert2utf8($row[2]),	//物料名称
					'FFullName'=> convert2utf8($row[3]),	//描述
					'FUnitName'=> convert2utf8($row[4]),	//计量单位
					'FHelpCode'=> convert2utf8($row[5]),	//编码/条码
					'FSecInv'=> $row[6],	//总库存
					'FAllQty'=> $row[6],	//安全库存
					'FModel'=> convert2utf8($row[3])	//规格型号
				); 
				
			}
			
		}    
	}
}else{
	//获取KIS3系统中所有的产品信息和对应的产品库存
	$kis3sql = "SELECT ti.FItemID,ti.FNumber,ti.FName,ti.FFullName,tmu.FName AS FUnitName,ti.FHelpCode,ti.FSecInv,tc.FAllQty,ti.FModel
	  FROM t_ICItem ti 
	  LEFT JOIN t_Item ti2 ON ti.FItemID = ti2.FItemID 
	  LEFT JOIN t_MeasureUnit tmu ON ti.FUnitID = tmu.FMeasureUnitID  
	  LEFT JOIN (SELECT T1.FItemID,SUM(T1.FQty) AS FAllQty 
		FROM ICInventory AS T1 LEFT JOIN t_Item T2 ON T1.FItemID = T2.FItemID
		WHERE T2.FDeleted = 0 GROUP BY T1.FItemID,T2.Fnumber) AS tc ON ti.FItemID = tc.FItemID
	WHERE ti.FDeleted = 0 AND ti.Fname != '*'  
	ORDER BY ti.FItemID  "; 
	//query语句 
	$kis3Result=$SqlCon->Query_result($kis3sql);
	//输出结果
	$kisNum=$SqlCon->num_rows($kis3Result);


	$kis3Arr=array();
	if($kisNum){
		for($i=0;$i<$kisNum;$i++)
		{
			$row=$SqlCon->fetch_row($kis3Result);        
			if(isset($productsArr[$row[1]]))
			{
				$inventorySql='update ld_products set qtyinstock = ? where product_no = ?';
				$adb->pquery($inventorySql,array($row[7],$productsArr[$row[1]]));
				unset($productsArr[$row[1]]);
			}
			else
			{
				$kis3Arr[]=array(
					'FItemID'=> $row[0],	//物料ID
					'FNumber'=> convert2utf8($row[1]),	//编号
					'FName'=> convert2utf8($row[2]),	//物料名称
					'FFullName'=> convert2utf8($row[3]),	//描述
					'FUnitName'=> convert2utf8($row[4]),	//计量单位
					'FHelpCode'=> convert2utf8($row[5]),	//编码/条码
					'FSecInv'=> $row[6],	//总库存
					'FAllQty'=> $row[7],	//安全库存
					'FModel'=> convert2utf8($row[8])	//规格型号
				); 
			}  
		}    
	}
}

if($typename == 'synchronousandinput')
{
    if(!empty($kis3Arr))
    {
        
		$entityInSql="insert into ld_crmentity(crmid,setype) value(?,?)";  
		
		$productInSql="insert into ld_products(productid,productsheet,product_no,productname,productcode,
		usageunit,qtyinstock,qtyearly,smcreatorid,smownerid,modifiedby,description,
		createdtime,modifiedtime,productcategory) value(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
		
		$productUpdateSql="update ld_products set productcategory = ?,productsheet = ?,productcode=?,usageunit=?,qtyinstock=?,qtyearly=? where productid = ?";
		for($i=0;$i<count($kis3Arr);$i++)
		{            
			
			$crmID = $adb->getUniqueID('ld_crmentity');
			$userid = $current_user->id;
			$FFullName = $kis3Arr[$i]['FFullName'];
			$time = date('Y-m-d H:i:s');            
			
			$FNumber = $kis3Arr[$i]['FNumber'];
			$FName = $kis3Arr[$i]['FName'];
			$FUnitName = $kis3Arr[$i]['FUnitName'];
			$FHelpCode = $kis3Arr[$i]['FHelpCode'];
			$FSecInv = $kis3Arr[$i]['FSecInv'];
			$FAllQty = $kis3Arr[$i]['FAllQty'];//数量
			$FModel = $kis3Arr[$i]['FModel'];//规格型号
            //Eidtor:gyq_64M Reason:下拉框改进 Date:2018/3/19 0019 下午 3:37
			//$usageunitInSql="insert into ld_usageunit(usageunit,presence,picklist_valueid) value(?,?,?)";
			$query = 'select productid from ld_products where product_no = ? and deleted = 0 limit 1';
			$result = $adb->pquery($query,array($FNumber));
			//判断本系统中是否有计量单位，如果没有那么插入到本系统中
			if(!isset($usageunitArr[$FUnitName]))
			{
                $objpinklist->addPickValue('usageunit',$FUnitName);
				/*$picklist_valueID = $adb->getUniqueID('ld_picklistvalues');
				$adb->pquery($usageunitInSql,array($FUnitName,1,$picklist_valueID));*/
			}
			if($adb->num_rows($result) >= 1){
				$productid = $adb->query_result($result,0,0);
				//print_r(array($FHelpCode,$FModel,$FHelpCode,$FUnitName,$FSecInv,$FAllQty,$productid));
				//die;
				$adb->pquery($productUpdateSql,array($FHelpCode,$FModel,$FHelpCode,$FUnitName,$FSecInv,$FAllQty,$productid));
			}
			else{
			
				//保存到ld_crmentity中
				$adb->pquery($entityInSql,array($crmID,'Products'));
			
				//保存到ld_products中
				$adb->pquery($productInSql,array($crmID,$FModel,$FNumber,$FName,$FHelpCode,$FUnitName,$FSecInv,$FAllQty,$userid,$userid,$userid,$FFullName,$time,$time,$FHelpCode));
			}
		}
    }
	$adb->pquery('update ld_crmentity_seq set id=(select max(crmid) from ld_crmentity)',array());
}

echo "###SUCCESS###";  
exit();






?>