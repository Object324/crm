<?php
class User_login
{
    
    static function load_user($user_password,$userobj) {
        global $adb;


        $usr_name = $userobj->column_fields["user_name"];
		unset($_SESSION['userprofileerror']);
        
        /**
         * edit:kevin
         * date:2013-07-12
         * reason:密码为空，允许登入
         */ 
        if( !isset($userobj->column_fields["user_name"]) || $userobj->column_fields["user_name"] == "" || !isset($user_password))
            return null;

        $authCheck = false;
       
        $authCheck = User_login::doLogin($user_password,$userobj);
        $tempsql = "select last_name from ld_users WHERE user_name=".'\''.$usr_name.'\'';

        $tempresult = $adb->pquery($tempsql)->fields;
    
        if(!$tempresult||sizeof($tempresult)<=0)
        {
            $_SESSION['useraccountnotexists'] =1;
            return null;
        }
        if(!$authCheck) {
        
            return null;
        }
        $userobj->authenticated = true;

        /*
         * editor:gyq
         * reason:密码管理，密码不能包含用户名，给column_fields增加用户名
         * date:2016 . 1 .21
         * */
        
        $userobj->column_fields["last_name"] = $tempresult[0];


        //chj : 如果登录用户没有权限  则不能登录
        if(empty($userobj->profileid) || $userobj->profileid <= 0){
            $_SESSION['userprofileerror']=1;
            $userobj->authenticated = false;
            return null;
        }



        //新增手机登陆验证字段 by andy
        $userobj->login_sms = $userobj->login_sms;
        $userobj->user_name = $userobj->user_name;

        //zxm  2021-0414 云之家网页端单点登录
        if($_REQUEST['from_yunzhijia']=='yes' || $_REQUEST['from_dandian']=='yes' || $_REQUEST['from_fanwei']=='yes'|| $_REQUEST['from_zhiyuan']=='yes'){
            $user_hash = $user_password;
        }else{
            $user_hash = strtolower(md5($user_password));
        }

                  
        
        // If there is no user_hash is not present or is out of date, then create a new one.
        if(!isset($userobj->user_hash) || $userobj->user_hash != $user_hash) {
            $query = "UPDATE $userobj->table_name SET user_hash=? where id=?";
            $userobj->db->pquery($query, array($user_hash, $userobj->id), true, "Error setting new hash for {$userobj->user_name}: ");
        }
        $userobj->loadPreferencesFromDB($userobj->user_preferences);
        
        if ($userobj->status != "Inactive") $userobj->authenticated = true;

        unset($_SESSION['loginattempts']);
         
      
       
        return $userobj;
    }
   static function doLogin($user_password,$userobj) {
        global $AUTHCFG;
        global $global_dandianlogin;
        $usr_name = $userobj->column_fields["user_name"];
        $crypt_type='MD5';
        //zxm  2021-0414 云之家网页端单点登录
        $from_yunzhijia = $_REQUEST['from_yunzhijia'];
        $from_fanwei = $_REQUEST['from_fanwei'];
        $from_zhiyuan = $_REQUEST['from_zhiyuan'];

        if($from_yunzhijia=='yes' || $_REQUEST['from_dandian']=='yes' || $from_fanwei=='yes' || $from_zhiyuan=='yes'){
            $encrypted_password = $user_password;
        }else{
            $encrypted_password = $userobj->encrypt_password($user_password, $crypt_type);
        }
        if(isset($global_dandianlogin)&&$global_dandianlogin=='yes')//外网体验登陆不需要验证boss密码
        {
            $query = "SELECT  pwd_checkcondition,user_password,date_modified ,is_admin,user_name ,id,user_hash,user_preferences,status
                ,user_name,login_sms,case when ifnull(profileid,1)=0 and is_admin='on' then 1  else profileid end as profileid from $userobj->table_name where deleted = 0  and status =  'Active' and user_name=? ";
            $param=array($usr_name);
        }
        else
        {
        
            //edit_other_mobile,
            $query = "SELECT pwd_checkcondition, date_modified,is_admin,user_name ,id,user_hash,user_preferences,status,user_name,
            login_sms,case when ifnull(profileid,1)=0 and is_admin='on' then 1  else profileid end as profileid from $userobj->table_name where deleted = 0  and status =  'Active' and user_name=? AND user_password=?";
            $param=array($usr_name, $encrypted_password);
        }
              
        $result=$userobj->db->pquery($query,$param);
    
        if (empty($result)||$userobj->db->num_rows($result)<=0) {
            $result=$userobj->db->pquery('select id from ld_users where user_name=?',array($usr_name));
            if($userobj->db->num_rows($result)>0)
            {
                //edit:can 20210414 成员管理，增加【登陆控制】操作按钮
                $sql='insert into ld_loginerror(logintime,userid)value(?,?)';
                $userobj->db->pquery($sql,array(date("Y-m-d H:i:s"),$userobj->db->query_result($result,0,'id')));
                
            }
            
            return false;
        } else {
            //edit:can 20210414 删除登录错误信息日志
            $sql='delete from ld_loginerror where userid=?';
            $userobj->db->pquery($sql,array($userobj->db->query_result($result,0,'id')));
            $userobj->id=$userobj->db->query_result($result,0,'id');
            //edit:can 13229: 同一个apache虚拟目录发布的CRM，用户登录后，只要知道其他用户的虚拟目录，就能够绕过密码，进入其他用户的CRM系统中。
            $userobj->user_password=$encrypted_password;
            /*editor:gyq_X160329 reason:新增赋值id_admin date:2016 3 29*/
            $userobj->is_admin=$userobj->db->query_result($result,0,'is_admin');
            $userobj->user_name=$userobj->db->query_result($result,0,'user_name');
            $userobj->profileid=$userobj->db->query_result($result,0,'profileid');
            $userobj->login_sms=$userobj->db->query_result($result,0,'login_sms');
            $userobj->status=$userobj->db->query_result($result,0,'status');
            $userobj->user_hash=$userobj->db->query_result($result,0,'user_hash');
            $userobj->user_preferences=$userobj->db->query_result($result,0,'user_preferences');
            $userobj->edit_other_mobile=$userobj->db->query_result($result,0,'edit_other_mobile');
            $userobj->date_modified=$userobj->db->query_result($result,0,'date_modified');
            $userobj->pwd_checkcondition=$userobj->db->query_result($result,0,'pwd_checkcondition');
                  
            if(isset($global_dandianlogin)&&$global_dandianlogin == 'yes')
            {
                //单点登陆
                $_SESSION[globalStatic::$root_directory.'user_password']=$userobj->db->query_result($result,0,'user_password');
            }
            else// //修改密码，重新登录
                $_SESSION[globalStatic::$root_directory.'user_password']=$encrypted_password;
                
            return true;
        }
         
        return false;
    }
}

?>