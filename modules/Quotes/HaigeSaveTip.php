<?php

global $adb;
$_REQUEST['diony']='diony';
if($_REQUEST['duplicateid']>0)
{
    
}
else if($_REQUEST['record']>0)
{
     $sql='select copyid from ld_quotes where quoteid=?';
     $result=$adb->pquery($sql,array($_REQUEST['record']));
     $_REQUEST['duplicateid']=$adb->query_result($result,0,'copyid');

}
if($_REQUEST['duplicateid']<=0)
{
     ConvertTojsonString(-1,array(),'');
}
$quotetype=$_REQUEST['quotetype'];
$total=$_REQUEST['total'];
crm_load_class_file("cls_HaigeApproveJudge",'modules/Quotes');
$cls_HaigeApproveJudge=new cls_HaigeApproveJudge($potentialid,$quotetype,$total);
          
if($cls_HaigeApproveJudge->isChange()=='yes')
{
    ConvertTojsonString(1,array(),'本次变更需要走快速审批流程');
}
                    
ConvertTojsonString(1,array(),'本次变更程需要走完整审批流程');
                
                


?>