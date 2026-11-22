<?php
//editor:gyq_128 reason:允许用户替换微信绑定  2019/7/8 16:02 ID1000504
class login_model
{
	//云之家：检查用户、密码，绑定云之家账号
	public function yunzhijia_bind(){
		global $adb,$current_user,$weixin_user;
        $focus = CRMEntity::getInstance('Users');
        $focus->column_fields["user_name"] = to_html($_REQUEST['user_name']);
        $user_password = vtlib_purify($_REQUEST['user_password']);
		$focus->load_user($user_password);
        if($_SESSION['useraccountnotexists'] == 1){
            $msg = $_REQUEST['mobile_language_type'] == 'en'?'The CRM user does not exist!':'该CRM用户不存在!';
            ConvertTojsonString(-1,null,$msg);
        }
		//重新绑定
		$get_userid = $_REQUEST['userid'];
		if(!empty($get_userid)){
			//若原绑定的A用户被禁用了，此时绑定B用户，先初始化所有绑定有当前wx_userid的用户
			$SQL1 = 'UPDATE ld_users set yunzhijia_wbuserid = ?,yunzhijia_openid = ? WHERE yunzhijia_wbuserid = ?';
			$SQL2 = 'UPDATE ld_users set yunzhijia_wbuserid = ?,yunzhijia_openid = ? WHERE id=?';
			$adb->pquery($SQL1,array('','',$_REQUEST['wbuserid']));
			$adb->pquery($SQL2,array($_REQUEST['wbuserid'],$_REQUEST['openid'],$get_userid));
			ConvertTojsonString(1, array(), 'success');
		}
		if($focus->is_authenticated()){
			if(!empty($_REQUEST['openid'])){
				$query = 'SELECT yunzhijia_openid,yunzhijia_wbuserid FROM ld_users WHERE id = ? ';
				$result = $adb->pquery($query,array($focus->id));
				$yunzhijia_wbuserid = $adb->query_result($result,0,0);
				if(!empty($yunzhijia_wbuserid) && $yunzhijia_wbuserid != $_REQUEST['wbuserid'] && empty($get_userid)){
					if(empty($get_userid) && $get_userid != $focus->id){
                        $msg = $_REQUEST['mobile_language_type'] == 'en'?'This account has been associated with other users, do you want to continue to log in?':'此账号已被其他用户关联,是否继续登录？';
                        // 设置移动端登录时已被关联的账号是否允许其他用户继续登录 
                        $system_360 = getSys_deploy(360);
                        if($system_360['deploy_value']==1){
                            $msg = $_REQUEST['mobile_language_type'] == 'en'?'This account has been associated with other users?':'此账号已被其他用户关联';
                            ConvertTojsonString(-1,array('id'=>$focus->id),$msg);
                        }
						ConvertTojsonString('yunzhijia_bind',array('id'=>$focus->id),$msg);
					}
				}else{
					//若原绑定的A用户被禁用了，此时绑定B用户，先初始化所有绑定有当前wx_userid的用户
					$SQL1 = 'UPDATE ld_users set yunzhijia_wbuserid = ?,yunzhijia_openid = ? WHERE yunzhijia_wbuserid = ?';
					$SQL2 = 'UPDATE ld_users set yunzhijia_wbuserid = ?,yunzhijia_openid = ? WHERE id=?';
					$adb->pquery($SQL1,array('','',$_REQUEST['wbuserid']));
					$adb->pquery($SQL2,array($_REQUEST['wbuserid'],$_REQUEST['openid'],$focus->id));

                    $this->Afterupdatebindusers($focus->id);
					ConvertTojsonString(1, array(), 'success');
				}
			}else{
			     $msg = $_REQUEST['mobile_language_type'] == 'en'?'Login failed, missing parameters:':'登录失败，缺少参数：';
				 ConvertTojsonString(-1,null,$msg.'openid,wbuserid');
			}
		}else{
            $status='Active';
            $sql="select status from ld_users where user_name=?";
            $result=$adb->pquery($sql,array($focus->column_fields["user_name"]));
            if($adb->num_rows($result)>0)
                $status=$adb->query_result($result,0,0);
            if($status=='Inactive'){
                $msg = $_REQUEST['mobile_language_type'] == 'en'?'The CRM user you bound has resigned or deactivated':'您绑定的CRM用户已离职或停用';
                ConvertTojsonString(-1,null,$msg);
            }else{
                //您的账户或密码有误，请重新输入
                $msg = $_REQUEST['mobile_language_type'] == 'en'?'Your account or password is incorrect, please re-enter':'您的账户或密码有误，请重新输入';
                ConvertTojsonString(-1,null,$msg);
            }
        }
	}
    //检查密码，绑定微信账号
    public function check_and_bind(){
        global $adb,$current_user,$weixin_user;
        $focus = CRMEntity::getInstance('Users');
        $focus->column_fields["user_name"] = to_html($_REQUEST['user_name']);
        $user_password = vtlib_purify($_REQUEST['user_password']);
        require_once(globalStatic::$root_directory.'include/utils/LoginFun.php');
        
        $loginerror=LoginSecurityCheck($focus->column_fields["user_name"]);
        if($loginerror!='')
        {
            //edit:can 20210415 成员管理，增加【登陆控制
            ConvertTojsonString(-1,null,$loginerror);
        }
            
        $focus->load_user($user_password);
        if($_SESSION['useraccountnotexists'] == 1){
            //0026212: （微信端）关联界面，没有判断登录的用户在CRM系统中是否存在
            $msg = $_REQUEST['mobile_language_type'] == 'en'?'The CRM user does not exist!':'该CRM用户不存在!';
            ConvertTojsonString(-1,null,$msg);
        }
      
        if($weixin_user->environment=='fanwei'){
            $fanwei_userid_decode = base64_decode($_REQUEST['fanwei_userid_encode']);//泛微的userid是base64加密后的值（时间戳+用户名）
            $_REQUEST['userid'] = substr($fanwei_userid_decode,14);
        } else if($weixin_user->environment=='zhiyuan'){
            $_REQUEST['userid'] = $_REQUEST['zhiyuan_userid'] ;
        }
        
        //editor:gyq_114 reason:小程序绑定优化  2019/5/23 20:20
        if(empty($_REQUEST['userid']))
            ConvertTojsonString(-1,null,'ERROR:USERID MISSING');
        $get_userid = $_REQUEST['userid'];

        if($focus->is_authenticated()){
            if($weixin_user->environment=='dingtalk') {
                $SQL = 'SELECT dingtalk_userid as wx_userid FROM ld_users WHERE id=?';
            }elseif($weixin_user->environment=='fanwei'){
                $SQL = 'SELECT fanwei_userid as wx_userid FROM ld_users WHERE id=?';
            }elseif($weixin_user->environment=='zhiyuan'){
                $SQL = 'SELECT zhiyuan_userid as wx_userid FROM ld_users WHERE id=?';
            }else{
                $SQL = 'SELECT wx_userid FROM ld_users WHERE id=?';
            }
            $result = $adb->pquery($SQL,array($focus->id));
            $wx_userid = $adb->query_result($result,0,'wx_userid');
            //允许自己重复绑定自己，故增加判断$wx_userid!=$get_userid
            if(!empty($wx_userid) && $wx_userid!=$get_userid){
                //reason:允许用户替换微信绑定  2019/7/8 15:14 ID1000504
                //editor:20190813 reason:0037764: 个人微信小程序、企业微信显示提示优化
                //原提示:此账号已经被其他企业微信用户关联，继续关联将删除之前的关联关系，是否继续?
                $msg = $_REQUEST['mobile_language_type'] == 'en'?'This account has been associated with other users, do you want to continue to log in?':'此账号已被其他用户关联,是否继续登录？';
                // 设置移动端登录时已被关联的账号是否允许其他用户继续登录 
                $system_360 = getSys_deploy(360);
                if($system_360['deploy_value']==1){
                    $msg = $_REQUEST['mobile_language_type'] == 'en'?'This account has been associated with other users?':'此账号已被其他用户关联';
                    ConvertTojsonString(-1,array('id'=>$focus->id,'userid'=>$get_userid),$msg);
                }
                ConvertTojsonString('replace_bind',array('id'=>$focus->id,'userid'=>$get_userid),$msg);
            }else{
                //若原绑定的A用户被禁用了，此时绑定B用户，先初始化所有绑定有当前wx_userid的用户
                if($weixin_user->environment=='dingtalk'){
                    $SQL1 = 'UPDATE ld_users set dingtalk_userid=?,dingtalk_unionid="" WHERE dingtalk_userid=?';
                    $SQL2 = 'UPDATE ld_users set dingtalk_userid=? WHERE id=?';
                }elseif($weixin_user->environment=='fanwei'){
                    $SQL1 = 'UPDATE ld_users set fanwei_userid=? WHERE fanwei_userid=?';
                    $SQL2 = 'UPDATE ld_users set fanwei_userid=? WHERE id=?';
                }elseif($weixin_user->environment=='zhiyuan'){
                    $SQL1 = 'UPDATE ld_users set zhiyuan_userid=? WHERE zhiyuan_userid=?';
                    $SQL2 = 'UPDATE ld_users set zhiyuan_userid=? WHERE id=?';
                }else{
                    $SQL1 = 'UPDATE ld_users set wx_userid=? WHERE wx_userid=?';
                    $SQL2 = 'UPDATE ld_users set wx_userid=? WHERE id=?';
                }
                $adb->pquery($SQL1,array('',$get_userid));
                $adb->pquery($SQL2,array($get_userid,$focus->id));
                $this->Afterupdatebindusers($focus->id);
                ConvertTojsonString(1, array(), 'success');
            }
        }else{
            $status='Active';
            $sql="select status from ld_users where user_name=? and status='Inactive'";
            $result=$adb->pquery($sql,array($focus->column_fields["user_name"]));
            if($adb->num_rows($result)>0)
                $status=$adb->query_result($result,0,0);
            if($status=='Inactive'){
                $msg = $_REQUEST['mobile_language_type'] == 'en'?'The CRM user you bound has resigned or deactivated':'您绑定的CRM用户已离职或停用';
                ConvertTojsonString(-1,null,$msg);
            }else{
                //您的账户或密码有误，请重新输入
                $msg = $_REQUEST['mobile_language_type'] == 'en'?'Your account or password is incorrect, please re-enter':'您的账户或密码有误，请重新输入';
                ConvertTojsonString(-1,null,$msg);
            }
        }
    }
    //替换微信绑定
    public function replace_bind(){
        global $adb,$weixin_user;
        //$weixin_user->environment='weixin';
            //个人微信小程序
           
        if($weixin_user->environment=='weixin'){
            require_once(globalStatic::$root_directory . 'WeiXinApp/WeiXin_common/cls_WeixinPort.php');
            require_once(globalStatic::$root_directory . 'WeiXinApp/minipro/const_mini.php');
            $o_port = new cls_WeixinPort();
            $openid = $_REQUEST['userid'];
            $sql_1 = 'update ld_users set wx_openid=? where wx_openid=?';
            $adb->pquery($sql_1,array('',$openid));
            $sql_1 = 'update ld_users set wx_openid=? where id=?';
            $adb->pquery($sql_1,array($openid,$_REQUEST['id']));
            //向接口表插入用户绑定信息
            $url = const_mini::$api_url . '?action_api=insert_user_from_replace_bind'.
            '&environment=weixin&openid='.$openid.'&basename='.$_REQUEST['mini_basename'];
            $result = $o_port->primary_curl($url);
           
            //企业微信及企业微信小程序
        }
        else if($weixin_user->environment=='yunzhijia'){
            //若原绑定的A用户被禁用了，此时绑定B用户，先初始化所有绑定有当前wx_userid的用户
            $SQL1 = 'UPDATE ld_users set yunzhijia_wbuserid = ?,yunzhijia_openid = ? WHERE yunzhijia_wbuserid = ?';
            $SQL2 = 'UPDATE ld_users set yunzhijia_wbuserid = ?,yunzhijia_openid = ? WHERE id=?';
            $adb->pquery($SQL1,array('','',$_REQUEST['wbuserid']));
            $adb->pquery($SQL2,array($_REQUEST['wbuserid'],$_REQUEST['openid'],$_REQUEST['id']));
        }
        else if($weixin_user->environment=='fanwei'){
            $fanwei_userid_decode = base64_decode($_REQUEST['fanwei_userid_encode']);//泛微的userid是base64加密后的值（时间戳+用户名）
            $_REQUEST['userid'] = substr($fanwei_userid_decode,14);

            //若原绑定的A用户被禁用了，此时绑定B用户，先初始化所有绑定有当前wx_userid的用户
            $SQL1 = 'UPDATE ld_users set fanwei_userid = ? WHERE fanwei_userid = ?';
            $SQL2 = 'UPDATE ld_users set fanwei_userid = ? WHERE id=?';
            $adb->pquery($SQL1,array('','',$_REQUEST['userid']));
            $adb->pquery($SQL2,array($_REQUEST['userid'],$_REQUEST['id']));
        }
        else if($weixin_user->environment=='zhiyuan'){

            //若原绑定的A用户被禁用了，此时绑定B用户，先初始化所有绑定有当前wx_userid的用户
            $SQL1 = 'UPDATE ld_users set zhiyuan_userid = ? WHERE zhiyuan_userid = ?';
            $SQL2 = 'UPDATE ld_users set zhiyuan_userid = ? WHERE id=?';
            $adb->pquery($SQL1,array('','',$_REQUEST['userid']));
            $adb->pquery($SQL2,array($_REQUEST['userid'],$_REQUEST['id']));
        }
        else{
            $get_userid = $_REQUEST['userid'];
            //若原绑定的A用户被禁用了，此时绑定B用户，先初始化所有绑定有当前wx_userid的用户
            if($weixin_user->environment=='dingtalk'){
                $SQL1 = 'UPDATE ld_users set dingtalk_userid=?,dingtalk_unionid="" WHERE dingtalk_userid=?';
                $SQL2 = 'UPDATE ld_users set dingtalk_userid=?,dingtalk_unionid="" WHERE id=?';
            }else{
                $SQL1 = 'UPDATE ld_users set wx_userid=? WHERE wx_userid=?';
                $SQL2 = 'UPDATE ld_users set wx_userid=? WHERE id=?';
            }
            $adb->pquery($SQL1,array('',$get_userid));
            $adb->pquery($SQL2,array($get_userid,$_REQUEST['id']));
        }
        $this->Afterupdatebindusers($_REQUEST['id']);
        ConvertTojsonString(1, array(),'success');
    }

    //登陆成功，绑定用户后处理
    public function Afterupdatebindusers($crmuserid){
        global $weixin_user;
        //登陆成功后清除对应移动端修改密码记录
        crm_load_class_file('LoginHistory','modules/Users');
        LoginHistory::DeletepasswordChange_bymobiletype($crmuserid,$weixin_user->getMobiletype());
    }
}