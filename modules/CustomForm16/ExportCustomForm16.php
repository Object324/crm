<?php
$version_info = getVersionInfo();
if($version_info['account'] == 'haochen'){
	include(globalStatic::$root_directory.'modules/CustomForm16/ExportCustomForm16ForHaochenNew.php');
}else{
	include(globalStatic::$root_directory.'modules/lingdang/Export/ExportInventoryListViewNew.php');
}
 


?>