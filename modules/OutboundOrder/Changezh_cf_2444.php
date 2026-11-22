<?php
global $adb;
global $current_user;
$_REQUEST['diony']='yes';
if($_REQUEST['operatetype']=='showpopup')
{
    $smarty=new lingdangCRM_Smarty();
    $arr=array();
    $arr['oktext']='保存';
    $arr['canceltext']='取消';
    $arr['title']='更改签回状态';
    $arr['content']=$smarty->fetch("changecf_2444.tpl");
    ConvertTojsonString(1,$arr,'success');
}
else
{
    require('modules/ModTracker/staticModTracker.class.php');

    $out_id=$_REQUEST['out_id'];//发货单id
    $cf_2444=$_REQUEST['cf_2444'];
    $staticModTrackerobj=new staticModTracker();
    
    $sql='select cf_2444 from ld_outboundordercf  where out_id=?';
    $result=$adb->pquery($sql,array($out_id));
    $beforevalue=$adb->query_result($result,0,'cf_2444');
    
    $sql='update ld_outboundordercf set cf_2444=? where out_id=? ';
   
    $adb->pquery($sql,array($cf_2444,$out_id));
    
    $staticModTrackerobj->saveFieldLogOne('OutboundOrder','cf_2444',$out_id,$beforevalue,$cf_2444);
    ConvertTojsonString(1,array(),'success');

}




?>