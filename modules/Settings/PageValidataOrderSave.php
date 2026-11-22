<?php

global $adb;
$movetype=$_REQUEST['movetype'];
$id=$_REQUEST['id'];
$frommodule = $_REQUEST['frommodule'];

$sql='select id,sequence from ld_validatasavemain where isshowlist=? and module=? order by sequence desc,  id desc ';

$result=$adb->pquery($sql,array('yes',$frommodule));
$rows=$adb->num_rows($result);
$change_sequence=0;
$change_id=0;
$cur_sequence=0;
for($i=0;$i<$rows;$i++)
{
    $tmp_id=$adb->query_result($result,$i,'id');
    if($id==$tmp_id)
        break;
   
}
$cur_sequence=$adb->query_result($result,$i,'sequence');

if($movetype=='up')
{
    $change_sequence=$adb->query_result($result,$i-1,'sequence');
    $change_id=$adb->query_result($result,$i-1,'id');
}
else if($movetype=='down')
{
    $change_sequence=$adb->query_result($result,$i+1,'sequence');
    $change_id=$adb->query_result($result,$i+1,'id');
}
$adb->pquery('update ld_validatasavemain set sequence=? where id=? ',array($change_sequence,$id));
$adb->pquery('update ld_validatasavemain set sequence=? where id=? ',array($cur_sequence,$change_id));
$_REQUEST['diony']='yes';

ConvertTojsonString(1,array(),'success');


?>