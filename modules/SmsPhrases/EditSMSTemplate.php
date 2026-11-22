<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 

/**
 * edit:kevin
 * date:2013-06-25
 * reason:编辑短信模板
 */ 
 $mode='create';
 if(isset($_REQUEST['templateid'])&&$_REQUEST['templateid']!=''){
    $templateid=$_REQUEST['templateid'];
    $mode='edit';
 }
 $query="select * from ld_smstemplates where templateid=?";
 $result=$adb->pquery($query,array($templateid));
 $num_rows=$adb->num_rows($result);
 if($num_rows){
    $templatename=$adb->query_result($result,0,'templatename');
    $body=$adb->query_result($result,0,'body');
	$template_type=$adb->query_result($result,0,'template_type');
 }

 $smarty=new lingdangCRM_Smarty;
 $smarty->assign('TEMPLATENAME',$templatename);
 $smarty->assign('TEMPLATEID',$templateid);
 $smarty->assign('BODY',$body);
 $smarty->assign('APP',$app_strings);
 $smarty->assign('TEMPLATE_TYPE',$template_type);
  $_REQUEST['diony']='diony';
if($mode == 'edit')
	$arr['title'] = getFixedLabel('EDIT');
else
	$arr['title'] = getFixedLabel('NEW');
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$str=$smarty->fetch("createsmstemplate.tpl");
$arr['content']=$str;
ConvertTojsonString(1,$arr,"success");
exit();
?>