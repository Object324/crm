<?php

class Customreport
{
   function __construct() {
		
	}

	function getFolderAll(){
		global $adb,$current_user;
		$query = 'select id,folder_name,systemdefault,sequence from ld_customreport_folder where visible=0 order by sequence asc';
		$result = $adb->pquery($query,array());
		for($i = 0; $i<$adb->num_rows($result); $i++){
			$id = $adb->query_result($result,$i,'id');
			$report_folder[$id]['folder_name'] = $adb->query_result($result,$i,'folder_name');
            $report_folder[$id]['systemdefault'] = $adb->query_result($result,$i,'systemdefault');
		}
		return $report_folder;
	}
	function getHideFolder(){//获取隐藏的文件夹
		global $adb,$current_user;
		$query = 'select id,folder_name,sequence from ld_customreport_folder where visible=1 order by sequence asc';
		$result = $adb->pquery($query,array());
		for($i = 0; $i<$adb->num_rows($result); $i++){
			$id = $adb->query_result($result,$i,'id');
			$report_folder[$id]['folder_name'] = $adb->query_result($result,$i,'folder_name');
		}
		return $report_folder;
	}
    
}


?>