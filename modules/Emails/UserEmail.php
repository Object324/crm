<?php
global $adb;
$allids=trim($_REQUEST['allids']);
$allids=substr($allids,0,strlen($allids)-1);

$sqlfield='select fieldid from ld_field where tabid=29 and columnname=?';
$fieldResult=$adb->pquery($sqlfield,array('email1'));
if($adb->num_rows($fieldResult)>0)
{
        $fieldid=$adb->query_result($fieldResult,0,0);
}

$sql_value = "SELECT last_name,email1,id
				 	FROM ld_users
					WHERE id in(".$allids.") and email1<>''";
$result_value = $adb->pquery($sql_value,array());

$num_rows = $adb->num_rows($result_value);
if($result_value)
{
            for($j=0;$j<$num_rows;$j++){
                //echo $info[$i][columnname]."|";
           $value_all .= $adb->query_result($result_value,$j,'last_name').";";
           $value_all .= $adb->query_result($result_value,$j,'email1').";";
            $emailidslists[]= $adb->query_result($result_value,$j,'id').'@'.$fieldid;
           }
}

$information = $value_all;

$information = explode(";",$information);
$num_info = sizeof($information)-1;
$information_all = '';
//print_r($information);
for($i=0;$i<$num_info;$i++)
{
   $j = $i+1;
  // echo $information[$j];
  $cc = htmlspecialchars("<");
  $cc2 = htmlspecialchars(">");
  if(!empty($_REQUEST['popup_type']) && $_REQUEST['popup_type'] == 'set_return_emails'){
		$information_all .= $information[$i].$cc.$information[$j].">;";
  }else{
		$information_all .= $information[$j].$cc.$information[$i].">\r";
  }
    $i++;
}

 $information_all=htmlspecialchars_decode($information_all);

echo "#####SUCCESS#####".$information_all."#####SUCCESS#####".implode(',',$emailidslists);
exit();
?>