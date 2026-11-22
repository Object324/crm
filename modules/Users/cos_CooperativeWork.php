<?php
global $adb;
$newfile_name=$_REQUEST['newfile_name'];
$newfile_name=FileFileterString($newfile_name);
$cloud_path=$_REQUEST['cloud_path'];
$name=$_REQUEST['name'];
$type=$_REQUEST['type'];
$size=$_REQUEST['size'];
$path=$_REQUEST['path'];
$query = 'insert into ld_workachments(newfile_name,name,type,path,storage_location,size,cloud_path) 
						values(?,?,?,?,?,?,?);';
		
$adb->pquery($query,array($newfile_name,$name,$type,$path,'cos',$size,$cloud_path));
$response=[];
$response['record'] = $adb->getLastInsertID();
$_REQUEST['diony']='yes';
            
ConvertTojsonString(1,$response,"success");


?>