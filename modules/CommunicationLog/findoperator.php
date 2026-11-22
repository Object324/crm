<?php
if(isset($_REQUEST['operator']))
{
    $user = $_REQUEST['operator'];
    $sql = "select id from ld_users where last_name = '".$user."'";
    
    $result = $adb->pquery($sql,array());
    $num_rows=$adb->num_rows($result);
    if($adb->num_rows($result)<=0)
    {
        echo "#error#";
            
        exit(); 
    }
    $id = $adb->query_result($result,0,"id");
    echo "###SUCCESS###".$id;
    exit();
}
?>