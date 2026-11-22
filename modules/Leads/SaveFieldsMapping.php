<?php
global $adb,$theme;
if(!empty($_REQUEST['record']) && !empty($_REQUEST['mappingfields_info'])){
	$mappingfields_info = json_decode($_REQUEST['mappingfields_info'],true);
	echo '<pre>';
	print_r($mappingfields_info);
	echo '</pre>';
	
}
exit();
?>