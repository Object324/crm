<?php

global $adb,$current_user;
$widths=$_REQUEST['listwidth'];

if($_REQUEST['type'])
{
    $module='CommunicationLog';
    $widths=array_filter(explode(",",$widths));
    $widths=implode(',',$widths);
    $widths=explode(",",$widths);
    $SQL='delete from ld_list_headerwidth where module=? and type=?  and userid=? and relateid=?';
	$adb->pquery($SQL,array($module,$_REQUEST['type'],$current_user->id,0));
	$i=0;
    
     $columninfos=array('callednumber','receivecontacts','createdtime','last_name','smscontent','smresultname');
      
        
	foreach($widths as $td_width){
		if($td_width>=0){
			$SQL='insert into ld_list_headerwidth(module,type,userid,header_width,columns,relateid)value(?,?,?,?,?,?)';
			$adb->pquery($SQL,array($module,$_REQUEST['type'],$current_user->id,$td_width,$columninfos[$i],0));
		}
		$i++;
	}
}
 else
 {
    $_REQUEST['type']=$_REQUEST['tabtype'];
 }
require_once('include/Ajax/CommonAjax.php');
?>