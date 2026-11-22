<?php

/**
修改统一语言编码格式utf-8
*/
/**
*@author:andy
*@data:20141024
*@reason:选择客户、选择供应商，分别带出联系人，供应商联系人
*@version:V5.8
*/
if((isset($_REQUEST['actionmodule']) && $_REQUEST['actionmodule'] !='') && (isset($_REQUEST['record']) && $_REQUEST['record'] !=''))
{
    $actionmodule=$_REQUEST['actionmodule'];
    $reslultArr=getcontacts($_REQUEST['record'],$actionmodule);
    if(count($reslultArr)>0){
        $returnstring=$reslultArr['id'].'-@#$&%*-'.$reslultArr['lastname'];
        echo '###SUCCESS###';
        echo $returnstring;exit;
    }else{
        echo 'ERROR';exit;
    }
}
function getcontacts($id,$actionmodule){
    global $adb;
    $arr=array();
    if($actionmodule=='Accounts'){
        $sql='SELECT contactid,lastname from ld_contactdetails where 
            accountid=? and deleted= 0 
            ORDER BY reference desc,contactid desc   limit 1';
        $result=$adb->pquery($sql,array($id));
        if($adb->num_rows($result)>0){
            $arr['id']=$adb->query_result($result,0,'contactid');
            $arr['lastname']=$adb->query_result($result,0,'lastname');
        }
    }elseif($actionmodule=='Vendors'){
        $sql='SELECT vendorcontactsid ,lastname from ld_vendorcontacts where Vendorid=? and deleted=0 order by vendorcontactsid desc  limit 1';
       
        $result=$adb->pquery($sql,array($id));
        if($adb->num_rows($result)>0){
            $arr['id']=$adb->query_result($result,0,'vendorcontactsid');
            $arr['lastname']=$adb->query_result($result,0,'lastname');
        }
    }elseif($actionmodule == 'Contacts'){
		$sql = 'select ld_account.accountname,ld_account.accountid from ld_contactdetails LEFT JOIN ld_account on ld_account.accountid = ld_contactdetails.accountid 
		where ld_contactdetails.contactid = ? limit 1';
		$result=$adb->pquery($sql,array($id));
        if($adb->num_rows($result)>0){
            $arr['id']=$adb->query_result($result,0,'accountid');
            $arr['lastname']=$adb->query_result($result,0,'accountname');
        }
	}
    return $arr;
}
?>