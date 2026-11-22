<?php

//获取相关信息的relateid
//客户服务收费管理往来对账
global $adb;
if(!isset($adb))
    exit('www');
$module=$_REQUEST['module'];
$relatemodule=$_REQUEST['relatemodule'];
$tabid=getTabid($module);
$related_tabid=getTabid($relatemodule);
$sql='select relation_id from ld_relatedlists where tabid=? and  related_tabid=? ';
 $result=$adb->pquery($sql,array($tabid,$related_tabid));

$relation_id=$adb->query_result($result,0,'relation_id');
$_REQUEST['diony']='yes';
ConvertTojsonString(1,array("id"=>$relation_id),'success');

?>