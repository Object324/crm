<?php
/**
*@another :      Andrew
*@date :         2014-08-25
*@brief :        保存公海客户按角色限制
**/

$count = $_REQUEST['count'];//角色限制数量
$roleid = $_REQUEST['roleid'];//该角色的roleid
$_REQUEST['diony']='diony';
if($count!==''||$roleid!==''){
    //查询ld_role_astrictcount表中是否有该数据
    $sql = 'SELECT count(1) as count FROM ld_role_astrictcount WHERE roleid=?;';
    $result = $adb->pquery($sql, array($roleid));
    $iscount = $adb->query_result($result,0,'count');

    if($iscount==0){
        $iSQL = 'insert into ld_role_astrictcount (roleid,astrictcount) value (?,?)';
        $result = $adb->pquery($iSQL, array($roleid,$count));
        ConvertTojsonString(1,array(),"success");
    }elseif($iscount>0){
        $iSQL = 'update ld_role_astrictcount set astrictcount=? where roleid=?';
        $result = $adb->pquery($iSQL, array($count,$roleid));
        ConvertTojsonString(1,array(),"success");
    }
}else{
        ConvertTojsonString(-1,array(),"success");
}
?>