<?php
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb;
$trackpostion_id = $_REQUEST['trackpostion_id'];
$trackpostion = $_REQUEST['trackpostion'];
$starttime=$_REQUEST['starttime'];
$stoptime=$_REQUEST['stoptime'];
$workcalender_id=$_REQUEST['workcalender_id'];
$operatetype=$_REQUEST['operatetype'];
$frequency=$_REQUEST['frequency'];
$cycle=$_REQUEST['cycle'];

$checknamequery='SELECT trackpostion from ld_trackpostion ';

$checknamequery.=' where trackpostion_id not in('.$trackpostion_id.') 
and trackposition=? limit 1';

$check_result = $adb->pquery($checknamequery,[$trackpostion]);
$num_rows=$adb->num_rows($check_result);

if($adb->num_rows($check_result)>0){ //判断定位组名称是否已存在；
        //ConvertTojsonString();
    ConvertTojsonString(-1,[],getFixedLabel("POSITIONINGGROUPNAMECANNOTBEREPEATED"));
}
else
{
  if($operatetype=='edit'){//编辑轨迹定位组保存；
     $updatequery="
                 UPDATE ld_trackpostion  
                  SET 
                     trackpostion=?,
                     starttime=?,
                     stoptime=?, 
                    frequency=?,
                     cycle=?
                    
                 WHERE trackpostion_id=?";
     $adb->pquery($updatequery,[$trackpostion,$starttime,$stoptime,$frequency,$cycle,$trackpostion_id]);
  }
  else{ //新增轨迹定位组保存；
      $query2="select max(trackpostion_id) from ld_trackpostion"; 
      $result2=$adb->pquery($query2);
      $max_trackpostionid=1;
      if($adb->num_rows($result2)>0)
        $max_trackpostionid=$adb->query_result($result2,0,0);
      $insertquery= "
      INSERT INTO ld_trackpostion(trackpostion,starttime,stoptime,presence,workcalender_id,frequency,cycle) 
      VALUES(?,?,?,?,?,?,?)";
      $adb->pquery($insertquery,[$trackpostion,$starttime,$stoptime,1,$workcalender_id,$frequency,$cycle]);
  }      
}
ConvertTojsonString(1,[],'success');
?>