<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt
 */
 global $adb;
 if(isset($_REQUEST['type']) && $_REQUEST['type'] == 'getProductQtyInstock'){
	$wareid = $_REQUEST['wareid'];
	$productstr = $_REQUEST['productstr'];
	$productInfo = array();
    
	if(!empty($productstr)){
		$productids = explode(',',$productstr);
		crm_load_function_file('getProductQtySaveOrCheck','include/Stock','CommonStock');
        $tmpproductqtys= getProductQtySaveOrCheck($productstr,$wareid,"");
        
		/*for($i = 0; $i<count($productid); $i++){
			if(!empty($productid[$i])){
				$query = 'select ifnull(productqty,0) as productqty  from ld_warehouse2products where warehouseid = ? and productid = ?';
				$result = $adb->pquery($query,array($wareid,$productid[$i]));
				$productqty = $adb->query_result($result,$i,'productqty');
				if(empty($productqty))$productqty = 0.00;
				$productInfo[$i] = $productid[$i] .'|'.$productqty;
			}
		}*/
       foreach($productids as $index=>$productid )
       {
            $tmp_productqtys=$tmpproductqtys[$productid][$wareid];
            $tmpcount=0;
            foreach($tmp_productqtys as $batchtext=>$productqty)
            {
               $tmpcount+=$productqty;
            }
             $productInfo[$i] = $productid .'|'.$tmpcount;
       }
        
		echo "success:".implode(',',$productInfo);exit();
	}
 }
$excludedRecords = vtlib_purify($_REQUEST['excludedRecords']);
$smowner=vtlib_purify($_REQUEST['smowner']);//by kevin

$SearchScope=$_REQUEST['SearchScope'];
$focus = CRMEntity::getInstance($currentModule);
$focus->mode = '';
$mode = 'mass_edit';
$disp_view = getView($focus->mode);
$idstring = vtlib_purify($_REQUEST['idlist']);
$storearray = getSelectedRecords($_REQUEST, $currentModule, $_REQUEST['idlist'],$excludedRecords);

$idlists = $idstring;
/**
*@andrew
* @time:20140620
* 0009539: 以下模块序时簿界面：全选所有的单据记录，进行批量修改、删除操作时没有判断单据是否在审批中、已审批，导致已审批或者正在审批的记录批量修改删除了
*/
if($idlists=='all'){
	$idlist="'".implode("','",$storearray)."'" ;
}else{
	$idlist = substr(str_replace(";",",",$idlists),0,-1);
}
//presence 1:已审核  0  未审核
$sql = "select 1 from ld_checks WHERE id in ($idlist) AND presence='已审核'";
$result=$adb->pquery($sql,array());
$rowCount = $adb->num_rows($result);
if($rowCount==0){
	echo "#####:success";
}else{
	echo "#####:error";
}
exit();
?>