<?php
global $adb,$current_user,$PlatformMC;
$idlist = vtlib_purify($_REQUEST['idlist']);
$viewid = vtlib_purify($_REQUEST['viewname']);
$SearchScope=vtlib_purify($_REQUEST['SearchScope']);
$returnmodule = vtlib_purify($_REQUEST['return_module']);
$return_action = vtlib_purify($_REQUEST['return_action']);
$excludedRecords=vtlib_purify($_REQUEST['excludedRecords']);
$rstart='';
//Added to fix 4600
$url = getBasic_Advance_SearchURL();
//获取批量处理数
$deployarray = getSys_deploy(67);
$btach_num =  $deployarray['deploy_value'];
$focus = CRMEntity::getInstance('SendCashBill');
if($_REQUEST['type']==1)	//审核
{
	$focus->updateSendCashBillStatus($_REQUEST['record']);
	//单据审核时，更改单据的审批人为当前操作人，审核状态为已批准(D_A_S_APPROVED 已批准)
	//$adb->pquery('update ld_sendcashbill set approveby=?,approvestatus=?,approvetime=? where sendcashbillid = ?',array($current_user->id,D_A_S_APPROVED,date("Y-m-d H:i:s"), $_REQUEST['record']));
	if(!empty($PlatformMC)) ConvertTojsonString(1,'','');
    exit();
}
elseif($_REQUEST['type']==2)	//反审核
{	
    $focus->upadteBackSendCashBillStatus($_REQUEST['record']);
	//单据审核时，更改单据的审批人为当前操作人，审核状态为已批准(D_A_S_APPROVED 已批准)
//	$adb->pquery('update ld_sendcashbill set approveby=0,approvestatus=?,approvetime=? where sendcashbillid = ?',array(D_A_S_UNAPPROVED,null, $_REQUEST['record']));
	if(!empty($PlatformMC)) ConvertTojsonString(1,'','');
    exit();
}elseif($_REQUEST['type']=='check'){
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
        $sql = "SELECT 1 FROM ld_sendcashbill WHERE sendcashbillid in ($idlist) AND checkoutstatus='已审核'";
        $result=$adb->pquery($sql,array());
        $rowCount = $adb->num_rows($result);
        if($rowCount==0){
            echo "#####:success";
        }else{
            echo "#####:error";
        }
        exit();
}elseif($_REQUEST['type']=='checklist'){	//批量审核

	$idlist = $_REQUEST['idlist'];
	if('all' == $idlist){
		$sql = getListAllQuery('SendCashBill');//获取query
		$select = $sql['query'];
		$rowss_result = $adb->query($select);
		$rowss = $adb->num_rows($rowss_result);//全选情况下，获取选中的数量
		if($btach_num > 0){
			$select .= ' LIMIT '.$btach_num.' ';
		}
		$selectresult = $adb->query($select);
		$rows = $adb->num_rows($selectresult);
		$idlist = '';
		for($i=0;$i<$rows;++ $i){
		    $idlist .= $adb->query_result($selectresult,$i,'crmid').';';
		}
	}else{
	   //这里$aa是为不全选状态下，获取序时簿勾选单据的数量
	   	$aa = trim($idlist,';');
    	$aa = strtr($aa,array(';'=>','));
    	//1、搜索对应的收款单
    	$query = 'SELECT bankaccountsetid,total,sendcashbillid,sendcashbill_no,checkoutstatus 
    				FROM ld_sendcashbill WHERE sendcashbillid IN ('.$aa.');';
    	$result = $adb->pquery($query,array());
    	$rowss = $adb->num_rows($result);
	}
	$idlist = trim($idlist,';');
	$idlist = strtr($idlist,array(';'=>','));
	//1、搜索对应的收款单
	$query = 'SELECT bankaccountsetid,total,sendcashbillid,sendcashbill_no,checkoutstatus 
				FROM ld_sendcashbill WHERE sendcashbillid IN ('.$idlist.');';
	$result = $adb->pquery($query,array());
	$rows = $adb->num_rows($result);
	$batchsuccesslog = getFixedLabel('DOCUMENTSUCCESS');//成功
	$batchtype = getFixedLabel('Checkout');//审核
	$batchsuccesscheck = getFixedLabel('DOCUMENTNOOTHERSUCCESSCHECK');
	$batchLog = '';$idupdate = '';

	if($rows > 0){
		for($i=0;$i<$btach_num;++ $i){
			$sendcashbillid = $adb->query_result($result,$i,'sendcashbillid');
			if(empty($sendcashbillid)){
				continue;
			}
			$sendcashbill_no = $adb->query_result($result,$i,'sendcashbill_no');
		    $checkoutstatus = $adb->query_result($result,$i,'checkoutstatus');
			$monery = $adb->query_result($result,$i,'total');
			$bankaccountsetid = $adb->query_result($result,$i,'bankaccountsetid');
			//操作历史
            $sendcashbillid_row .= $sendcashbillid.","; //Liver 2016/07/20 获取本次实际被选中的付款单ID，用于后面统计已审核的单据，计算失败条数
            
			$subject = '<a referencemodule="'.$currentModule.'" referencerecord="'.$sendcashbillid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" style="color:#32A636;">'.$sendcashbill_no.'</a>';
			if('已审核' == $checkoutstatus){
				$batchLog .= sprintf($batchsuccesscheck,$subject,$batchtype).'<br>';
			}else{
				$batchLog .= sprintf($batchsuccesslog,$subject,$batchtype).'<br>';
				//修改为已审批状态
				$update = 'UPDATE ld_bankaccountset SET curbalancemoney=IFNULL(curbalancemoney,0)-'.$monery.' 
							WHERE deleted=0 and bankaccountsetid='.$bankaccountsetid;
				$adb->pquery($update,array());
				$idupdate .= $sendcashbillid.',';
			}
		}
            $sendcashbillid_row = trim($sendcashbillid_row,',');
            $row_sql = 'select 1 from ld_sendcashbill where checkoutstatus !=\'已审核\' and sendcashbillid in ('.$sendcashbillid_row.')';
            $result_row = $adb->pquery($row_sql,array());
            $row = $adb->num_rows($result_row); //本次实际选中的单据中，包含已审核单据的条数e

		if(!empty($idupdate)){
			$idupdate = trim($idupdate,',');
			//审核操作
			$focus->updateSendCashBillStatus($idupdate);
			//单据审核时，更改单据的审批人为当前操作人，审核状态为已批准(D_A_S_APPROVED 已批准)
			$adb->pquery('update ld_sendcashbill set approveby=?,approvestatus=? where sendcashbillid in ($idupdate)',array($current_user->id,D_A_S_APPROVED));
		}
	}
	$submitlog = getFixedLabel('APPROVE_BATCHSUBMITLOG_INFO');
	$submitlog = sprintf($submitlog,$rowss,$row,$rowss-$row);
	$submitlog = '<div class="ld-description"><b class="info-icon"></b><div class="ld-description-content">'.$submitlog.'</div></div>';
	$batchLog = "<div class='pop_prc_content'>".$batchLog."</div>";
	$entity['log']['value'] = $submitlog.$batchLog;//批量处理信息
	$entity['title']['value'] = getFixedLabel('Batch_checkout');//批量审核
	if(isset($_SESSION['lvs']['CashBill']['viewname'])){
		$viewid = $_SESSION['lvs']['CashBill']['viewname'];
		$start = $_SESSION['lvs']['CashBill'][$viewid]['start'];
	}
	if(!$start) $start = 1;
	$entity['start']['value'] = $start;
	require_once('./include/Zend/Json.php');
	$json = new Zend_Json();
	$jsonentity = $json->encode($entity);
	echo $jsonentity;die;
   
}

header("Location: index.php?module=".$returnmodule."&action=ListView".$rstart."&viewname=".$viewid."&errormsg=".$errormsg.$url."&SearchScope=".$SearchScope);
    
?>