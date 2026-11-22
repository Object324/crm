<?php
require_once globalStatic::$root_directory.'WeiXinApp/lib/EventFromApiModel.php';
class event_model extends EventFromApiModel
{
    public $token;
    public $_corpid;
    public $_agentid;
    public $_appkey;
    public $_appsecret;
    public $_login_appid;
    public $_login_secret;
    public $_login_url;
	
	public function get_userid($wbuserid,$openid,$applicationType){
		global $adb;
		$id = 0;
		$query = "select id from ld_users where yunzhijia_wbuserid = ? limit 1";
		$result = $adb->pquery($query,array($wbuserid));
		$num_rows = $adb->num_rows($result);
		if($num_rows >= 1){
			$id = $adb->query_result($result,0,0);
		}else{
		    if($applicationType=="market"){
                //不存在则创建 只有平台应用需要创建用户
                $username = rand(1,9999);
                $createdtime = date('Y-m-d H:i:s');
                $insert_sql = "insert into ld_users (user_name,yunzhijia_wbuserid,yunzhijia_openid,createdtime) values('$username','$wbuserid','$openid','$createdtime') ";
                $adb->pquery($insert_sql);
                $id = $adb->getLastInsertID();
            }
        }
		return $id;
	}
    
}