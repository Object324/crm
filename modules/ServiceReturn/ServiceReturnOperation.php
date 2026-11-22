<?php

global $adb,$current_user,$currentModule;

$type = $_REQUEST['tag'];
$record = $_REQUEST['record'];
$ajax = $_REQUEST['ajaxmode'];
$fmodule = $_REQUEST['fmodule'];

if($ajax=='check')
{  
    //判断该服务单是否已创建回访单
    if($fmodule == 'HelpDesk'){
        $sql = "select 1 from ld_servicereturn where troubleticketid = ? and deleted = 0";
    }
    if($fmodule == 'ProjectTask'){
        $sql = "select 1 from ld_servicereturn where projecttaskid = ? and deleted = 0";
    }

    $result=$adb->pquery($sql,array($record));
   
    $num_rows=$adb->num_rows($result);
    for ($i = 0; $i < $num_rows; $i++)
    {
        echo '###EXIST###'; 
    }
}

 exit();
 
?>