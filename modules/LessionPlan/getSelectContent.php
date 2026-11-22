<?php

require_once('modules/LessionPlan/LessionPlanCommon.php');
$_REQUEST['diony']='yes';
$fieldlabel=$_REQUEST['fieldlabel'];
$id=$_REQUEST['id'];

$arr['content']=getSelectContent($fieldlabel,$id);
ConvertTojsonString(1,$arr,'success');

?>