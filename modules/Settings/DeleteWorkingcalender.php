<?php
  global $adb;
  $workcalender_id=$_REQUEST['workcalender_id'];
  $deletequery="DELETE from ld_workcalender where workcalender_id=$workcalender_id";
  $adb->pquery($deletequery);
  $sql="DELETE from ld_workingdays where workcalender_id=$workcalender_id";
  $adb->pquery($sql);
  exit();
?>