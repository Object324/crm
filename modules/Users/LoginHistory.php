<?php

/*********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
** The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
* 
 ********************************************************************************/

include_once(globalStatic::$root_directory.'config.php');


require_once(globalStatic::$root_directory.'include/ListView/ListView.php');

/** This class is used to store and display the login history of all the Users.
  * An Admin User can view his login history details  and of all the other users as well.
  * StandardUser is allowed to view only his login history details.
**/
class LoginHistory {
	var $log;
	var $db;

	// Stored lingdang_fields
	var $login_id;
	var $user_name;
	var $user_ip;
	var $login_time;
	var $logout_time;
	var $status;
	var $module_name = "Users";

	var $table_name = "ld_loginhistory";

	var $object_name = "LoginHistory";
	
	var $new_schema = true;

	var $column_fields = Array("id"
		,"login_id"
		,"user_name"
		,"user_ip"
		,"login_time"
		,"logout_time"
		,"status"
		);
	public $languageType = 'zh';
    public static $error_message;

	function __construct() {
	//	$this->log = LoggerManager::getLogger('loginhistory');
        global $current_user;
		$this->db = PearDatabase::getInstance();
        include(globalStatic::$root_directory.'user_privileges/user_language_'.$current_user->id.'.php');
        $this->languageType = $languageType;
    }
	
	var $sortby_fields = Array('user_name', 'user_ip', 'login_time', 'logout_time', 'status');	 
       	
	// This is the list of lingdang_fields that are in the lists.
	var $list_fields = Array(
			'User Name'=>Array('ld_loginhistory'=>'user_name'), 
			'User IP'=>Array('ld_loginhistory'=>'user_ip'), 
			'Signin Time'=>Array('ld_loginhistory'=>'login_time'),
		        'Signout Time'=>Array('ld_loginhistory'=>'logout_time'), 
			'Status'=>Array('ld_loginhistory'=>'status'),
		);	
	
	var $list_fields_name = Array(
		'User Name'=>'user_name',
		'User IP'=>'user_ip',
		'Signin Time'=>'login_time',
		'Signout Time'=>'logout_time',
		'Status'=>'status'
		);	
	var $default_order_by = "login_time";
	var $default_sort_order = 'DESC';
	//edior:gyq_20181220 reason:0035840: 系统设置->登录日志查询界面：登录方式没有翻译
	public $login_type_shift_zh = array('all'=>'全部',''=>'PC端登录','qiyeweixin'=>'企业微信端登录','qrcodeweixin'=>'PC端企业微信扫码登录','pcqiyeweixin'=>'企业微信PC端登录','mini_weixin'=>'CRM微信小程序登录','mini_wxwork'=>'CRM企业微信小程序登录','dingtalk'=>'钉钉端登陆','pc_dingtalk'=>'钉钉PC端登陆','yunzhijia'=>'云之家端登陆','pc_yunzhijia'=>'云之家PC端登录','app'=>'APP登录','fanwei'=>'泛微端登陆','pc_fanwei'=>'泛微PC端登陆','zhiyuan'=>'致远端登陆','pc_zhiyuan'=>'致远PC端登陆');
	public $login_type_shift_en = array('all'=>'All',''=>'PC login','qiyeweixin'=>'Enterprise WeChat login','qrcodeweixin'=>'PC enterprise WeChat scan code login','pcqiyeweixin'=>'Enterprise WeChat PC login','mini_weixin'=>'CRM WeChat mini-program login','mini_wxwork'=>'CRM enterprise WeChat mini- program login','dingtalk'=>'Dingtalk login','pc_dingtalk'=>'Dingtalk PC login','yunzhijia'=>'yunzhijia login','pc_yunzhijia'=>'yunzhijia PC login','app'=>'APP login','fanwei'=>'fanwei login','pc_fanwei'=>'fanwei PC login','zhiyuan'=>'zhiyuan login','pc_zhiyuan'=>'zhiyuan PC login');
	public $username = '';
	public $logintype = '';

/**
 * Function to get the Header values of Login History.
 * Returns Header Values like UserName, IP, LoginTime etc in an array format.
**/
	function getHistoryListViewHeader()
	{
	
		global $app_strings;
		
		//old::$header_array = array(getFixedLabel('USERNAME'), getFixedLabel('USERIP'), getFixedLabel('LOGINTIME'), getFixedLabel('LOGOUTTIME'), getFixedLabel('STATUS'));
        /**
        *@author:andy
        *@data:20141020
        *@reason:手机验证码登陆，登陆日志显示新增 手机号码、机器名、验证码、是否为手机验证码登陆 几个字段
        *@version:|
        */
        $header_array = array(getFixedLabel('LOGINMODE'),getFixedLabel('USERNAME'), getFixedLabel('USERIP'), getFixedLabel('operatoroertime'), getFixedLabel('LOGOUTTIME'), getFixedLabel('OPERATORTYPE'),getFixedLabel('OperationModule'),getFixedLabel('MOBILENUMBER'),getFixedLabel('LBL_SECURITYCODE_SET'),getFixedLabel('WHETHERTHEMOBILELANGING'),getFixedLabel('Mobile').'UDID');//getFixedLabel('MACHINENAME')
		
		return $header_array;
		
	}

/**
  * Function to get the Login History values of the User.
  * @param $navigation_array - Array values to navigate through the number of entries.
  * @param $sortorder - DESC
  * @param $orderby - login_time
  * Returns the login history entries in an array format.
**/
	public function getHistoryListViewEntries( $navigation_array, $sorder='', $orderby='')
	{
		global $adb, $current_user;
        /**
         * andy
         * reason 0009303: 英文版：登录日志界面， 状态列的 登录、退出值未英译
         * data 20140505
         */
		$lantype = $this->languageType;
        $exportlabel=getFixedLabel('EXPORT');
        if($lantype == 'zh'){
        	$action1='登录';
        	$action2='退出';
        }
        else
        {
        	$action1='Signed in';
        	$action2='Sign out';
        }
        /**
        *@author:andy
        *@data:20141020
        *@reason:手机验证码登陆，登陆日志显示新增 手机号码、机器名、验证码、是否为手机验证码登陆 几个字段
        *@version:|
        */
        if($lantype == 'zh'){
        	$logintype1='是';
        	$logintype2='否';
        }
        else
        {
        	$logintype1='yes';
        	$logintype2='no';
        }
		
        //editor:gyq_92 reason:系统设置登录日志查询增加分类功能  2018/12/21 11:12
		if($sorder != '' && $order_by != '')
	       		$list_query = "Select login_type,login_id,user_name,user_ip,entitytype,logout_time,login_time,case when status = 'Signed in' 
                   then '{$action1}' when status = 'Signed off'  then '{$action2}'  when status ='Export' then '{$exportlabel}' else status end as status,mobile,security_code,machinename,
                   case when whethercodelogin=0 then '{$logintype2}' when whethercodelogin =1  then '{$logintype1}' else whethercodelogin end as whethercodelogin,udid 
                   from ld_loginhistory where case when '$this->username'='' THEN 1=1 else user_name= '$this->username' END
         and case when '$this->logintype'='all' then 1=1 else login_type='$this->logintype' END
                   order by ".$order_by." ".$sorder;
		else
				$list_query = "Select login_type,login_id,user_name,user_ip,entitytype,logout_time,login_time,case when status = 'Signed in' then '{$action1}'
                 when status = 'Signed off'  then '{$action2}'  when status ='Export' then '{$exportlabel}' else status end as status,security_code,machinename,case when whethercodelogin=0 then '{$logintype2}' when whethercodelogin =1  then '{$logintype1}' 
                 else whethercodelogin end as whethercodelogin,mobile,udid from ld_loginhistory 
                 where case when '$this->username'='' THEN 1=1 else user_name= '$this->username' END
         and case when '$this->logintype'='all' then 1=1 else login_type='$this->logintype' END
                 order by ".$this->default_order_by." ".$this->default_sort_order; 
		
		$result = $adb->pquery($list_query, array());
          
		$entries_list = array();
	if($navigation_array['end_val'] != 0)
	{
		for($i = $navigation_array['start']; $i <= $navigation_array['end_val']; $i++)
		{
			$entries = array();
            
			$loginid = $adb->query_result($result, $i-1, 'login_id');
			if($this->languageType=='en'){
                $entries[] = $this->login_type_shift_en[$adb->query_result($result, $i-1, 'login_type')];
            }else
                $entries[] = $this->login_type_shift_zh[$adb->query_result($result, $i-1, 'login_type')];
            $entries[] = strtolower($adb->query_result($result, $i-1, 'user_name'));
            $user_ip = $adb->query_result($result, $i-1, 'user_ip');
			$entries[] = $user_ip=='::1'?'127.0.0.1':$user_ip;
			$entries[] = $adb->query_result($result, $i-1, 'login_time');
			$entries[] = $adb->query_result($result, $i-1, 'logout_time');
			$entries[] = $adb->query_result($result, $i-1, 'status');
            $entitytype=$adb->query_result($result, $i-1, 'entitytype');
            $modulelabel='';
            //登录日志查询增加显示“导出”日志
            if($entitytype)
            {
                $modulelabel=getTranstab($entitytype);
            }
            $entries[] = $modulelabel;
            $entries[] = $adb->query_result($result, $i-1, 'mobile');
            $entries[] = $adb->query_result($result, $i-1, 'security_code');
           // $entries[] = $adb->query_result($result, $i-1, 'machinename');
            $entries[] = $adb->query_result($result, $i-1, 'whethercodelogin');
            $entries[] = $adb->query_result($result, $i-1, 'udid');
 
			$entries_list[] = $entries;
		}	
    
        
		return $entries_list;
	}	
	}
    //操作日志
	public function user_operation_history($button,$module)
    {
        global $adb, $current_user;
        $intime=date("Y-m-d H:i:s");
        $sql=' insert into ld_loginhistory(user_name,login_time,status,entitytype)value(?,?,?,?)';
        $adb->pquery($sql,array($current_user->user_name,$intime,$button,$module));
     
        
    }
	/** Function that Records the Login info of the User 
	 *  @param ref variable $usname :: Type varchar
	 *  @param ref variable $usip :: Type varchar
	 *  @param ref variable $intime :: Type timestamp
	 *  Returns the query result which contains the details of User Login Info
	*/
	//editor:gyq_92 reason:系统设置登录日志查询增加分类功能  2018/12/18 15:06
	function user_login(&$usname,&$usip,&$intime,$mobile='',$code='',$machinename='',$whetherodelogin='',$r_login_type='',$login_check=''
        ,$languagetype='')
	{
		global $adb;
		//Kiran: Setting logout time to '0000-00-00 00:00:00' instead of null
		/**
      *@author:andy
      *@data:
      *@reason:登陆短信验证，
      *@version:|
      */
		if(empty($r_login_type)) $r_login_type='';
      $intime=date("Y-m-d H:i:s");
      
        if($code==''){
            $query = "Insert into ld_loginhistory (user_name, user_ip, logout_time, login_time, status, machinename,login_type,login_check,languagetype) values (?,?,?,?,?,?,?,?,?)";
            $params = array($usname,$usip,'0000-00-00 00:00:00', $intime,'Signed in',$machinename,$r_login_type,$login_check,$languagetype);
		}else{
            $query = "Insert into ld_loginhistory (user_name, user_ip, logout_time, login_time, status,mobile,security_code,machinename,whethercodelogin,login_type,login_check,languagetype) values (?,?,?,?,?,?,?,?,?,?,?,?)";
            $params = array($usname,$usip,'0000-00-00 00:00:00', $intime,'Signed in',$mobile,$code,$machinename,1,$r_login_type,$login_check,$languagetype);
		}
      
        $result = $adb->pquery($query, $params);

		return $result;
	}
	
	/** Function that Records the Logout info of the User 
	 *  @param ref variable $usname :: Type varchar
	 *  @param ref variable $usip :: Type varchar
	 *  @param ref variable $outime :: Type timestamp
	 *  Returns the query result which contains the details of User Logout Info
	*/
	function user_logout(&$usname,&$usip,&$outtime)
	{
		global $adb;
		$logid_qry = "SELECT max(login_id) AS login_id from ld_loginhistory where user_name=? and user_ip=?";
		$result = $adb->pquery($logid_qry, array($usname, $usip));
		$loginid = $adb->query_result($result,0,"login_id");
		if ($loginid == '')
                {
                        return;
                }
		// update the user login info.
		$query = "Update ld_loginhistory set logout_time =?, status=? where login_id = ?";
		$result = $adb->pquery($query, array($this->db->formatDate($outtime, true), 'Signed off', $loginid))
                        or die("MySQL error: ".mysql_error());
	}
    
    //更新当前登录的UDID
    function user_setudid($usname,$usip,$udid)
	{
	   	global $adb;
		$logid_qry = "SELECT max(login_id) AS login_id from ld_loginhistory where user_name=? and user_ip=?";
		$result = $adb->pquery($logid_qry, array($usname, $usip));
		$loginid = $adb->query_result($result,0,"login_id");
		if ($loginid == '')
                {
                        return;
                }
		// update the user login info.
		$query = "Update ld_loginhistory set udid =? where login_id = ?";
		$result = $adb->pquery($query, array($udid, $loginid))
                        or die("MySQL error: ".mysql_error());
	}

	/** Function to create list query 
	* @param reference variable - order by is passed when the query is executed
	* @param reference variable - where condition is passed when the query is executed
	* Returns Query.
	*/
  	function create_list_query(&$order_by, &$where)
  	{
		// Determine if the lingdang_account name is present in the where clause.
		global $current_user, $adb;
		$query = "SELECT user_name,user_ip, status,
				".$this->db->getDBDateString("login_time")." AS login_time,
				".$this->db->getDBDateString("logout_time")." AS logout_time
			FROM ".$this->table_name;
		if($where != "")
		{
			if(!is_admin($current_user))
			$where .=" AND user_name = '". $adb->sql_escape_string($current_user->user_name) ."'";
			$query .= " WHERE ($where)";
		}
		else
		{
			if(!is_admin($current_user))
			$query .= " WHERE user_name = '". $adb->sql_escape_string($current_user->user_name) ."'";
		}
		
		if(!empty($order_by))
			$query .= " ORDER BY ". $adb->sql_escape_string($order_by);
        
		return $query;
	}

	/**
	 * Determine if the user has logged-in first
	 * @param accept_delay_seconds Allow the delay (in seconds) between login_time recorded and current time as first time.
	 * This will be helpful if login is performed and client is redirected for home page where this function is invoked.
	 */
	static function firstTimeLoggedIn($user_name, $accept_delay_seconds=10) {		
		$firstTimeLoginStatus = false;
		
		global $adb;
		
		// Search for at-least two records.
		$query = 'SELECT login_time, logout_time FROM ld_loginhistory WHERE user_name=? ORDER BY login_id DESC LIMIT 2';
		$result= $adb->pquery($query, array($user_name));
		$recordCount = $result? $adb->num_rows($result) : 0;
		
		if ($recordCount === 0) {
			$firstTimeLoginStatus = true;
		} else {		
			if ($recordCount == 1) { // Only first time?
				$row = $adb->fetch_array($result);
				$login_delay = time() - strtotime($row['login_time']);
				// User not logged out and is within expected delay?			
				if (strcmp('0000-00-00 00:00:00', $row['logout_time']) === 0 && $login_delay < $accept_delay_seconds) {
					$firstTimeLoginStatus = true;
				}				
			}
		}
		return $firstTimeLoginStatus;
	}
    //获取中英文登陆类型下拉选项 editor:gyq_92 reason:系统设置登录日志查询增加分类功能  2018/12/21 14:08 
    public function get_login_method(){
        if($this->languageType=='en'){
            $login_type_shift = $this->login_type_shift_en;
        }else{
            $login_type_shift = $this->login_type_shift_zh;
        }
        return $login_type_shift;
    }
    //获取登陆日志主体分页数据
    public function get_loginlog_page_number($r_userid,$r_logintype){
        global $adb;
        if(empty($r_userid) || $r_userid=='none')
            $username = '';
        else{
			$query = 'select user_name from ld_users where id = ?';
			$result = $adb->pquery($query,array($r_userid));
			$username = $adb->query_result($result,0,0);
            //$username = getModuleHref('Users',$r_userid);
		}
        if(empty($r_logintype)&&$_REQUEST['ajax'] != 'true')
            $r_logintype = 'all';
        //登录方式选择pc端登录，筛选条件值为空

        $this->username=$username;
        $this->logintype = $r_logintype;
        $qry = "Select login_id,user_name,user_ip,logout_time,login_time,
          case when status = 'Signed in' then '登录' when status = 'Signed off'  then '退出' else status
          end as status,mobile,udid from ld_loginhistory where case when '$username'='' THEN 1=1 else user_name= '$username' end 
          and case when '$r_logintype'='all' then 1=1 else login_type='$r_logintype' end";
		 // echo $qry;echo '<br><br>';
        $qry_result = $adb->pquery($qry, array());
        $no_of_rows = $adb->num_rows($qry_result);
		//echo $no_of_rows;echo '<br><br>';die;
        return $no_of_rows;
    }
    //异地登录
    public function checkLogin($retvaluetype)
    {
        if($_REQUEST['file']=='RestoreDataBasePopup')
            return '';
        if($_REQUEST['file']=='OperateRestoreDataBase') 
        return '';
        $_REQUEST['diony']='yes';
        $regop=RegOp::getInstance();
        if($regop->getallowmulti_login()==1)//允许同一个成员多次登陆
                return '';
                
      
        if(isset($_SESSION['login_check']) && isset($_SESSION['login_type']) && isset($_SESSION['authenticated_user_id']) && $_SESSION['authenticated_user_id']!=''){
            global $adb;
            $sql = 'select l.login_check from ld_loginhistory as l LEFT JOIN ld_users as u on l.user_name = u.user_name where u.id = ? and l.`status`=? 
            and login_type = ? ORDER BY l.login_id desc LIMIT 0,1';
            $result = $adb->pquery($sql,array($_SESSION['authenticated_user_id'],'Signed in',$_SESSION['login_type']));
            if ($adb->num_rows($result)>0) {
                $tmp_login_check = $adb->query_result($result,0,"login_check");

                if($tmp_login_check!=''&&$tmp_login_check != $_SESSION['login_check']){
                    session_destroy();
                    if($retvaluetype=='ajax'){
                        ConvertTojsonString('logincontrol',array(),'faile'.$_REQUEST['file']);
                    }else{
                        session_destroy();
                        header("location:index.php?pageto_module=Home&pageto_action=index");
                    }
                }
            }

        }
    }
    //移动端异地登录
    public function yidong_checkLogin($loginassion,$retvaluetype)
    {
        //获取
        global $adb;
        $_REQUEST['diony']='yes';
     
        if($_REQUEST['file']=='RestoreDataBasePopup')
            return '';
        if($_REQUEST['file']=='OperateRestoreDataBase') 
        return '';   
        if(isset($loginassion) && $loginassion!=""){
            $loginassion_array = explode("|",$loginassion['loginsession']);
            $tmpcurrentuserid = self::getUseridBymobiletype($loginassion['userid'],$loginassion_array[0]);

            //判断用户密码是否修改，若修改返回重新登陆
            //zkt 20240718 XUQIU20240626-12 修改密码，需要强制登录移动端
            if(self::CheckpasswordChange_bymobiletype($tmpcurrentuserid,$loginassion_array[0])){
                $sql = 'select l.login_check,l.languagetype from ld_loginhistory as l LEFT JOIN ld_users as u on l.user_name = u.user_name where u.id = ? and l.`status`= ? and login_type = ? ORDER BY l.login_id desc LIMIT 0,1';
                $result = $adb->pquery($sql,array($loginassion['currentuserid'],'Signed in',$loginassion_array[0]));
                $languagetype = $adb->query_result($result,0,"languagetype");
                $msg = $languagetype=='en'?'The CRM user password you have bound is incorrect. Please log in again!':'您绑定的CRM用户密码错误，请重新登陆！';
                ConvertTojsonString('logincontrol',array(),$msg);
            }
            crm_load_class_file("RegOp","Register");
            $regop=RegOp::getInstance();
            if($regop->getallowmulti_login()==1)//允许同一个成员多次登陆
                return '';


            if($loginassion_array[0] == 'qiyeweixin'){//企业微信$loginassion['userid']->ld_users.wx_userid
                $sql = 'select l.login_check,l.languagetype from ld_loginhistory as l LEFT JOIN ld_users as u on l.user_name = u.user_name where u.wx_userid = ? and l.`status`= ?
                and login_type = ? ORDER BY l.login_id desc LIMIT 0,1';
                $result = $adb->pquery($sql,array($loginassion['userid'],'Signed in',$loginassion_array[0]));
            }else if($loginassion_array[0] == 'dingtalk'){//钉钉移动端$loginassion['userid']->ld_users.dingtalk_userid
                $sql = 'select l.login_check,l.languagetype from ld_loginhistory as l LEFT JOIN ld_users as u on l.user_name = u.user_name where u.dingtalk_userid = ? and l.`status`= ?
                and login_type = ? ORDER BY l.login_id desc LIMIT 0,1';
                $result = $adb->pquery($sql,array($loginassion['userid'],'Signed in',$loginassion_array[0]));
            }else if($loginassion_array[0] == 'fanwei'){//泛微OA，泛微通过用户id判断
                $sql = 'select l.login_check,l.languagetype from ld_loginhistory as l LEFT JOIN ld_users as u on l.user_name = u.user_name where u.id = ? and l.`status`= ?
                and login_type = ? ORDER BY l.login_id desc LIMIT 0,1';
                $result = $adb->pquery($sql,array($loginassion['userid'],'Signed in',$loginassion_array[0]));
            }else if($loginassion_array[0] == 'zhiyuan'){//致远OA
                $sql = 'select l.login_check,l.languagetype from ld_loginhistory as l LEFT JOIN ld_users as u on l.user_name = u.user_name where u.zhiyuan_userid = ? and l.`status`= ?
                and login_type = ? ORDER BY l.login_id desc LIMIT 0,1';
                $result = $adb->pquery($sql,array($loginassion['userid'],'Signed in',$loginassion_array[0]));
            }else{//云之家、微信小程序、企业微信小程序$loginassion['userid']->ld_users.id
                $sql = 'select l.login_check,l.languagetype from ld_loginhistory as l LEFT JOIN ld_users as u on l.user_name = u.user_name where u.id = ? and l.`status`=? 
                and login_type = ? ORDER BY l.login_id desc LIMIT 0,1';
                $result = $adb->pquery($sql,array($loginassion['userid'],'Signed in',$loginassion_array[0]));
            }
            
            $tmp_login_check = $adb->query_result($result,0,"login_check");
            $languagetype = $adb->query_result($result,0,"languagetype");
            if($tmp_login_check != $loginassion['loginsession']){
                if($retvaluetype=='ajax'){
                    $msg = $languagetype=='en'?'Your account is logged in on another device, and you have been forced to log out!':'您的账号在其他设备上登录，您已被迫退出！';
                    ConvertTojsonString('logincontrol',array(),$msg);
                }
            }
        }
    }




	static function get_ip_city($ip){
		$ch = curl_init();
		$url = 'https://whois.pconline.com.cn/ipJson.jsp?ip=' . $ip;
		//用curl发送接收数据
		curl_setopt($ch, CURLOPT_URL, $url);
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
		//请求为https
		curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
		curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, false);
		$location = curl_exec($ch);
		curl_close($ch);
		//转码
		$location = mb_convert_encoding($location, 'utf-8', 'GB2312');
		//var_dump($location);
		//截取{}中的字符串
		$location = substr($location, strlen('({') + strpos($location, '({'), (strlen($location) - strpos($location, '})')) * (-1));
		//将截取的字符串$location中的‘，’替换成‘&’   将字符串中的‘：‘替换成‘=’
		$location = str_replace('"', "", str_replace(":", "=", str_replace(",", "&", $location)));
		//php内置函数，将处理成类似于url参数的格式的字符串  转换成数组
		parse_str($location, $ip_location);
		// return $ip_location['addr']; # 返回字符串
		return $ip_location["city"]; # 返回数组
	}

	static function getIp(){
		//strcasecmp 比较两个字符，不区分大小写。返回0，>0，<0。
		if (getenv('HTTP_CLIENT_IP') && strcasecmp(getenv('HTTP_CLIENT_IP'), 'unknown')) {
			$ip = getenv('HTTP_CLIENT_IP');
		} else if (getenv('HTTP_X_FORWARDED_FOR') && strcasecmp(getenv('HTTP_X_FORWARDED_FOR'), 'unknown')) {
			$ip = getenv('HTTP_X_FORWARDED_FOR');
		} else if (getenv('REMOTE_ADDR') && strcasecmp(getenv('REMOTE_ADDR'), 'unknown')) {
			$ip = getenv('REMOTE_ADDR');
		} else if (isset($_SERVER['REMOTE_ADDR']) && $_SERVER['REMOTE_ADDR'] && strcasecmp($_SERVER['REMOTE_ADDR'], 'unknown')) {
			$ip = $_SERVER['REMOTE_ADDR'];
		}
		$res =  preg_match ( '/[\d\.]{7,15}/', $ip, $matches ) ? $matches [0] : '';
		return $res;
	}
	//判断IP是否在指定网段内
	static function isInSubnet($ip,$subnet='') {
		// $subnet = '172.17.64.0/24';
		$ipLong = ip2long($ip);
		list($subnetIp, $subnetBits) = explode('/', $subnet);
		$subnetLong = ip2long($subnetIp);
		$mask = -1 << (32 - $subnetBits);
	
		return ($ipLong & $mask) == ($subnetLong & $mask);
	}
	//判断是否为网段
	static function isCIDR($address) {
		return strpos($address, '/') !== false;
	}
	//被限制登录提示
	static function errorMsg($languagetype,$msgtype) {
		$error_codes = array(
			'zh' => array(
				1 => '登录失败，您在当前状态下被限制登录',
				2 => '登录失败，您在当前设备下被限制登录',
				3 => '登录失败，您在当前位置下被限制登录',
				4 => '登录失败，您的当前IP地址被限制登录'
			),
			'en' => array(
				1 => 'Login failed, you are currently restricted from logging in',
				2 => 'Login failed, you are currently restricted from logging in',
				3 => 'Login failed, you are currently restricted from logging in',
				4 => 'Login failed, you are currently restricted from logging in',
			)
		);
		$error_message = $error_codes[$languagetype][$msgtype];
        self::$error_message = $error_message;
		//$_SESSION['login_error'] = $error_message;
	}
	/**
	 *2023-7-10 xxy XUQIU1001427 【广东丰明】成员登录内外网登录控制，登录策略管理
	 *登录策略判断
	 */
	static function loginPolicy($user_name,$devicetype,$languageType) {
        global $adb;

        $sql = "SELECT * from ld_users where user_name=?";
        $result = $adb->pquery($sql,[$user_name]);
        $userid = $adb->query_result($result,0,'id');
        $groupid = $adb->query_result($result,0,'groupid');
		// $groupid = explode(',',$groupid);
        $profileid = $adb->query_result($result,0,'profileid');

		$sql_loginpolicy = 'SELECT * from ld_loginpolicy where ruleid in (
			SELECT DISTINCT ld_loginpolicy.ruleid from ld_loginpolicy INNER JOIN ld_loginpolicy_user on ld_loginpolicy.ruleid = ld_loginpolicy_user.ruleid 
			where 
			case 
				when ld_loginpolicy.applicablescope = "all" then "yes"
				when ld_loginpolicy.applicablescope = "group" and  FIND_IN_SET(ld_loginpolicy_user.userid,?) then "yes"
				when ld_loginpolicy.applicablescope = "user" and  FIND_IN_SET(ld_loginpolicy_user.userid,?) then "yes"
				when ld_loginpolicy.applicablescope = "role" and  FIND_IN_SET(ld_loginpolicy_user.userid,?) then "yes"
				ELSE "no"
			END = "yes"	
			) ORDER BY `priority` asc';

        // $sql_loginpolicy_user = "SELECT * from ld_loginpolicy_user where ruleid=?";
        // $sql_loginpolicy = "SELECT * from ld_loginpolicy ORDER BY `priority`";
        $result_loginpolicy = $adb->pquery($sql_loginpolicy,[$groupid,$userid,$profileid]);
        $num_rows = $adb->num_rows($result_loginpolicy);
        for($i=0;$i<$num_rows;$i++){
            $ruleid[$i] = $adb->query_result($result_loginpolicy,$i,'ruleid');
            $rulename[$i] = $adb->query_result($result_loginpolicy,$i,'rulename');
            $ruletype[$i] = $adb->query_result($result_loginpolicy,$i,'ruletype');
            $priority[$i] = $adb->query_result($result_loginpolicy,$i,'priority');
            $controlmode[$i] = $adb->query_result($result_loginpolicy,$i,'controlmode');
            $enablestatus[$i] = $adb->query_result($result_loginpolicy,$i,'enablestatus');
            $typecontent[$i] = $adb->query_result($result_loginpolicy,$i,'typecontent');
            $statusvalue[$i] = $adb->query_result($result_loginpolicy,$i,'statusvalue');
            $applicablescope[$i] = $adb->query_result($result_loginpolicy,$i,'applicablescope');
            // $result_loginpolicy_user = $adb->pquery($sql_loginpolicy_user,[$ruleid[$i]]);
            // $user_num_rows = $adb->num_rows($result_loginpolicy_user);
            // for($j=0;$j<$user_num_rows;$j++){
            //     $targetid[$ruleid[$i]][$j] = $adb->query_result($result_loginpolicy_user,$j,'userid');
            // }
        }

        //获取用户IP地址
        // if(!empty($ip))
        //      $currentuser_IP =$ip;
        // else
            $currentuser_IP=LoginHistory::getIP();
          
        $currentuser_region='';

        for($i=0;$i<$num_rows;$i++){
            if($enablestatus[$i]=='yes'){//规则是否开启
                //无限制(all user,group ,role)
                if($ruletype[$i]=='Unlimited'){
                    if($controlmode[$i]=='enable'){//允许登录
                        return true;
                    }
                    else{
						LoginHistory::errorMsg($languageType,1);
                        return false;
                    }
                }
                //WEB端
                if($ruletype[$i]=='WEB'){
					if($controlmode[$i]=='enable'){ //WEB端允许登录
						if($devicetype == 'mobile'){ 

						}
						else{ //WEB端按适用范围判断是否允许登录
                            return true;
                        }
					}
                    else{ //WEB端不允许登录，则移动端不做判断继续下一条规则
						if($devicetype == 'mobile'){
							
						}
						else {
							LoginHistory::errorMsg($languageType,2);
							return false;
						}
                    }
                }
                //移动端
                if($ruletype[$i]=='Mobile'){
					if($controlmode[$i]=='enable'){//移动端判断是否允许登录
						if($devicetype == 'web'){
							
						}else{ 
                            return true;
                        }
					}
					else{
						if($devicetype == 'web'){
							
						}
						else{
							LoginHistory::errorMsg($languageType,2);
							return false;
						}
					}
                }
                //地理区域
                if($ruletype[$i]=='Geographicalregion'){
                    //获取用户所在城市
                    if(empty($currentuser_region)){
                        $currentuser_region =LoginHistory::get_ip_city($currentuser_IP);
					}
                    $typecontent[$i] = explode(',',$typecontent[$i]);
                    if($controlmode[$i]=='enable'){
                        for($j=0;$j<count($typecontent[$i]);$j++){
                            if($typecontent[$i][$j]==$currentuser_region){
                                return true;
                            }
                        }                                
						LoginHistory::errorMsg($languageType,3);
						return false;
                    }else{
                        for($j=0;$j<count($typecontent[$i]);$j++){
                            if($typecontent[$i][$j]==$currentuser_region){
								LoginHistory::errorMsg($languageType,3);
								return false;
                            }
                        }
						return true;
                    }
                }
				//IP地址
                if($ruletype[$i]=='IPaddress'){
                    $typecontent[$i] = explode(',',$typecontent[$i]);
                    if($controlmode[$i]=='enable'){
                        for($j=0;$j<count($typecontent[$i]);$j++){
							$isCIDR = LoginHistory::isCIDR($typecontent[$i][$j]);//判断当前读取的IP是否为网段
							$isInSubnet = $isCIDR && LoginHistory::isInSubnet($currentuser_IP, $typecontent[$i][$j]);//判断当前IP是否在该网段内
							$isIPMatch = !$isCIDR && $currentuser_IP == $typecontent[$i][$j];//判断当前IP地址是否允许登录
							if ($isInSubnet || $isIPMatch) {
								return true;
							}
                        }
						LoginHistory::errorMsg($languageType,4);
						return false;
                    }
                    else{
                        for($j=0;$j<count($typecontent[$i]);$j++){
							$isCIDR = LoginHistory::isCIDR($typecontent[$i][$j]);
							$isInSubnet = $isCIDR && LoginHistory::isInSubnet($currentuser_IP, $typecontent[$i][$j]);
							$isIPMatch = !$isCIDR && $currentuser_IP == $typecontent[$i][$j];
							if ($isInSubnet || $isIPMatch) {
								LoginHistory::errorMsg($languageType,4);
								return false;
							}
                        }
						return true;
                    }
                }
            }
        }
		LoginHistory::errorMsg($languageType,1);
        return false;
    }

    /**
     * XUQIU20240626-12 修改密码，需要强制登录移动端
     * 记录用户密码被修改
     */
    static function Changepassword($userid)
    {
        global $adb;
        $mobile_type_arr = ['qiyeweixin','dingtalk','yunzhijia','zhiyuan','mini_wxwork','mini_weixin','fanwei'];//'app'不使用此方法
        $query = "DELETE FROM ld_passwordchangecheckuser WHERE userid = ?;";
        $adb->pquery($query, array($userid));
        //插入数据记录当前用户密码有被修改，移动端判断
        foreach ( $mobile_type_arr as $mobile_type){
            $insert_query = "insert into ld_passwordchangecheckuser(userid,mobiletype) VALUES(?,?)";
            $adb->pquery($insert_query, array($userid,$mobile_type));
        }
    }
    /**
     * XUQIU20240626-12 修改密码，需要强制登录移动端
     * 判断用户密码是否被修改
     */
    static function CheckpasswordChange_bymobiletype($userid,$mobile_type)
    {
        global $adb;
        if(isKehu001ServerPc()=='yes'){
            return false;
        }
        $query = "select * from ld_passwordchangecheckuser where userid = ? and mobiletype = ?;";
        $result = $adb->pquery($query, array($userid,$mobile_type));
        $num_rows = $adb->num_rows($result);
        $flage = false;
        if($num_rows>0){
            $flage = true;
        }
        return $flage;
    }
    /**
     * XUQIU20240626-12 修改密码，需要强制登录移动端
     * 获取用户id
     */
    static function getUseridBymobiletype($userid,$mobile_type)
    {
        global $adb;
        $checkkey = 'id';
        $mobile_type_arr = array('qiyeweixin'=>'wx_userid','dingtalk'=>'dingtalk_userid','zhiyuan'=>'zhiyuan_userid','fanwei'=>'id');
        if(!empty($mobile_type)&&array_key_exists($mobile_type,$mobile_type_arr))
        {
            $checkkey = $mobile_type_arr[$mobile_type];
        }
        $query = "select * from ld_users where $checkkey = ? ;";
        $result = $adb->pquery($query, array($userid));
        $num_rows = $adb->num_rows($result);
        $crmuserid = 0;
        if($num_rows>0){
            $crmuserid = $adb->query_result($result,0,"id");
        }
        return $crmuserid;
    }


    /**
     * XUQIU20240626-12 修改密码，需要强制登录移动端
     * 登陆成功后清除对应移动端修改密码记录
     */
    static function DeletepasswordChange_bymobiletype($userid,$mobile_type)
    {
        global $adb;
        if(!empty($userid)){
            $deletequery = "DELETE FROM ld_passwordchangecheckuser  WHERE userid = ? and mobiletype = ?;";
            $adb->pquery($deletequery, array($userid,$mobile_type));
        }
    }


       
}



?>