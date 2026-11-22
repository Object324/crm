<?php

global $adb;
if(!isset($adb))
{
    exit('fff');
}
$sql='select * from ld_users2group ';

$result=$adb->pquery($sql,array());

$rows=$adb->num_rows($result);
$arr=[];
for($i=0;$i<$rows;$i++)
{
    $userid=$adb->query_result($result,$i,'userid');
    $groupid=$adb->query_result($result,$i,'groupid');
    if(!array_key_exists($userid.'aa',$arr))
    {
        $arr[$userid.'aa'][]=$groupid;
    }
    else{
        
        $arr[$userid.'aa'][]=$groupid;
    }
}
$_REQUEST['diony']='yes';
ConvertTojsonString(1,['list'=>$arr],'success');

?>