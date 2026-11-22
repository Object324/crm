<?php
global $adb;


if($_REQUEST['field'] && $_REQUEST['field'] > 0){
    $sql = 'update ld_settings_field set frequency = frequency+1 where fieldid = ?;';
    $adb->pquery($sql,array($_REQUEST['field']));
}



ConvertTojsonString(1,'','success');

?>