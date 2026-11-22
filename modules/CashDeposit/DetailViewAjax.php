<?php

global $adb,$mod_strings;
global $current_user;

global $currentModule;
$modObj = CRMEntity::getInstance($currentModule);
$ajaxaction = $_REQUEST["ajxaction"];
if($ajaxaction == "DETAILVIEW")
{
     $crmid = $_REQUEST["recordid"];
     $tablename = $_REQUEST["tableName"];
     $fieldname = $_REQUEST["fldName"];

     $fieldvalue = utf8RawUrlDecode($_REQUEST["fieldValue"]);
     
     /*andrew
     *0009838: “提现单”、“存现单”：当金额大于转出账户的余额，保存时，建议给出提示“金额大于转出账户余额，是否保存”，确定后可以保存。
     */
     $checkod = 1;
     if($fieldname=='cashmoney'&&$_REQUEST["checkOK"]!=='OK'){
    	$sql = 'SELECT Outaccount,cashmoney from ld_'.$module.' where '.$module.'id='.$crmid;
       // echo $sql.'<br>';
        $result=$adb->pquery($sql,array());
        $bankid = $adb->query_result($result, 0, 'outaccount');
        $cashmoney = $adb->query_result($result, 0, 'cashmoney');
        $sql = 'SELECT curbalancemoney FROM ld_bankaccountset WHERE Bankaccountsetid='.$bankid;
        // echo $sql.'<br>';
        $result=$adb->pquery($sql,array());
        $curbalancemoney = $adb->query_result($result, 0, 'curbalancemoney');
        $monery = str_replace(',','',vtlib_purify($fieldvalue));
        if($cashmoney-($monery-$curbalancemoney)<0){
            $checkod=0;
        }
     }
     
     if($crmid != ""&&$checkod==1)
	 {
	     crm_load_class_file("DetailViewAjaxSave",'data');
     $crmid = $_REQUEST["recordid"];
     $tablename = $_REQUEST["tableName"];
     $fieldname = $_REQUEST["fldName"];
     $fieldvalue = utf8RawUrlDecode($_REQUEST["fieldValue"]); 
     $DetailViewAjaxSaveobj=new DetailViewAjaxSave($currentModule,$crmid,$fieldname,$fieldvalue);
     $DetailViewAjaxSaveobj->save();
     $DetailViewAjaxSaveobj->setEcho();
  }
     

}else  if($ajaxaction == "LOADRELATEDLIST" || $ajaxaction == "DISABLEMODULE"){
	require_once 'include/ListView/RelatedListViewContents.php';
}
?>