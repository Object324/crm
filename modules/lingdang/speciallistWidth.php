<?php
global $current_user,$adb;

$widths=$_REQUEST['listwidth'];

$widths=array_filter(explode(",",$widths));
$widths=implode(',',$widths);
$widths=explode(",",$widths);
$viewid=0;
$module=$_REQUEST['type'];
$SQL='delete from ld_list_headerwidth where module=? and type=?  and userid=? and relateid=?';
$adb->pquery($SQL,array($module,$_REQUEST['type'],$current_user->id,$viewid));
$i=0;
$headername=$_REQUEST['headername'];
$headernames=array_filter(explode(",",$headername));
$headernames=implode(',',$headernames);
$headernames=explode(",",$headernames);//fieldname  

foreach($widths as $td_width){
		if($td_width>=0){
			$SQL='insert into ld_list_headerwidth(module,type,userid,header_width,columns,relateid)value(?,?,?,?,?,?)';
            
			$adb->pquery($SQL,array($module,$_REQUEST['type'],$current_user->id,$td_width,$headernames[$i],$viewid));
		}
		$i++;
}
?>