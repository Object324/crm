<?php
/**
* @edit:dong
* @data:2020/08/26
* @reason:小程序商城顶部设置
* @description:
*/
global $adb,$current_user,$languageType;
$type = $_REQUEST['type'];
$id = $_REQUEST['id'];
$sql = 'SELECT id FROM ld_wxshoppingmall_banner ORDER BY  sequence,id';
$result = $adb->pquery($sql);
$num_row =$adb->num_rows($result);
if($num_row>0){
    for ($i=0;$i<$num_row;$i++){
        $tmpid = $adb->query_result($result,$i,'id');
        $sql ='UPDATE ld_wxshoppingmall_banner SET sequence =? WHERE  id =?';
        $adb->pquery($sql,array($i+1,$tmpid));
    }
}
$sql ='select sequence from ld_wxshoppingmall_banner where id=?';
$result = $adb->pquery($sql,array($id));
if(!$result){
    ConvertTojsonString(0,$arr,"success");
}
$sequence = $adb->query_result($result,0,'sequence');
$upSql = 'update ld_wxshoppingmall_banner set sequence = ? WHERE  sequence =?';
$upSql2 = 'update ld_wxshoppingmall_banner set sequence = ? WHERE  id =?';

if($type=='up'){
    $adb->pquery($upSql,array($sequence,$sequence-1));
    $adb->pquery($upSql2,array($sequence-1,$id));
}else{
    $adb->pquery($upSql,array($sequence,$sequence+1));
    $adb->pquery($upSql2,array($sequence+1,$id));
}

ConvertTojsonString(1,$arr,"success");
?>