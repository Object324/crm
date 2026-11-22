<?php
require_once globalStatic::$root_directory.'WeiXinApp/lib/EventFromApiModel.php';
class event_model extends EventFromApiModel
{
	public function get_userid($userid){
        $fanwei_userid_decode = base64_decode($userid);//泛微的userid是base64加密后的值（时间戳+用户名）
        $userid = substr($fanwei_userid_decode,14);

		global $adb;
		$id = 0;
		if(!empty($userid)){
			$query = "select id from ld_users where fanwei_userid = ? limit 1";
			$result = $adb->pquery($query,array($userid));
			$num_rows = $adb->num_rows($result);
			if($num_rows >= 1){
				$id = $adb->query_result($result,0,0);
			}
		}
		return $id;
	}
    
}