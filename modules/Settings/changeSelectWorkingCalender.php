<?php

global $adb;
$trackpostion_id=$_REQUEST['trackpostion_id'];  
$query ='
        select 
            ld_workcalender.workcalender_id
        from ld_trackpostion 
        LEFT JOIN ld_workcalender ON ld_trackpostion.workcalender_id=ld_workcalender.workcalender_id
        where ld_trackpostion.trackpostion_id=?';
$result = $adb->pquery($query,array($trackpostion_id));
$workcalenderid=$adb->query_result($result,0,'workcalender_id');
$workcalenderquery='SELECT workcalender_id,workcalender_name from ld_workcalender';
$workcalender_result = $adb->pquery($workcalenderquery);
$workcalender_num_rows = $adb->num_rows($workcalender_result);
$selectHtml='';
for($j = 0; $j<$workcalender_num_rows; $j++){
    $workcalender_id=$adb->query_result($workcalender_result,$j,'workcalender_id');
    $workcalender_name=$adb->query_result($workcalender_result,$j,'workcalender_name');
    if($workcalender_id==$workcalenderid){
        $selected='selected="true"';
    }else{
        $selected='';
    }
    $selectHtml.='<option value=\''.$workcalender_id.'\''.$selected.'>'.$workcalender_name.'</option>';
}
echo '&#&#&#'.$selectHtml;die;
?>