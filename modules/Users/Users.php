<?php

 //include($root_directory.'modules/Users/CreateUserPrivilegeFile.php');
#[AllowDynamicProperties]
class Users extends CRMEntity {
    
    	// For Alphabetical search
	var $def_basicsearch_col = 'user_name';
    static  function require_file($requiremodules='')
    {
        global $root_directory;
        globalStatic::$arr_module_require['Users']='Users';
         if(!empty($requiremodules)&&empty(globalStatic::$arr_module_require[$requiremodules]))
            {
                globalStatic::$arr_module_require[$requiremodules]=$requiremodules;
                if(!class_exists("$requiremodules"))//美的入库单打印
                    require_once($root_directory."modules/$requiremodules/$requiremodules.php");
                
            }
    }
    //var $log;
    /**
     * @var PearDatabase
     */
    var $db;
    // Stored fields

    public $approvestatus;
    public $approveby;
    public $access_address;
    public $receivable_total;
    public $receivable_remain;
    public $receivable_haved;
    public $first_name;
    public $departments;
    public $IP_Filename;
    public $latestpushtime;
    public $is_mobile_style;
    public $select_servicedetail;
    public $select_due_date;
    public $accountallview;
    public $telephone_view;
    public $push_work_reminds;
    public $push_news_reminds;
    public $environment;
    public $action;
    public $groupname;
    public $profileid;
    var $status;
    var $confirm_password;
    var $last_name;
    var $setmenuprofileid;
    var $real_name;
    var $gender;
    var $groupid;
    var $phone_mobile;
    var $phone_home;
    var $email1;
    var $wx_userid;
    var $wx_openid;
    var $dingtalk_userid;
    var $lead_view;
    var $userlevel;
    var $activity_view;
    var $hour_format;
    var $start_hour;
    var $description;
    var $hire_date;
    var $imagename;
    var $createdtime;
    var $smcreatorid;
    var $modifiedtime;
    var $modifiedby;
    var $yunzhijia_wbuserid;
    var $fanwei_userid;
    var $zhiyuan_userid;
    var $currency_grouping_pattern;
    var $currency_decimal_separator;
    var $currency_symbol_placement;
    var $email2;
    var $secondaryemail;
    var $reports_to_id;
    var $accesskey;
    var $scopeauthority;
    var $helpdesk_log;
    var $campaignsview;
    var $push_wx_reminds;
    var $jw_user;
    var $sopho_exten;
    var $sopho_queue;
    var $hantian_exten;
    var $tianrun_exten;
    var $filename;
    var $currency_name;
    var $currency_code;
    var $currency_symbol;
    var $conv_rate;
    var $crm_user_type;
    var $time_zone;
    var $theme;
    var $currency_grouping_separator;
    var $phone_other;
    var $date_format;
    var $language;
    var $reminder_interval;
    var $edit_me_mobile;
    var $cf_4475;
    var $user_hash;
    var $edit_other_mobile;
    var $date_modified;
    var $pwd_checkcondition;
    var $authenticated = false;
    var $error_string;
    var $is_admin;
    var $deleted;
    var $user_password;
    
    //新增手机验证码登陆字段 by andy
    var $login_sms;
    var $user_name;
    var $customFieldTable = Array('ld_usersscf','id');//自定义
    var $tab_name = Array('ld_crmentity','ld_users','ld_attachments','ld_usersscf');
    var $tab_name_index = Array('ld_crmentity' => 'crmid', 'ld_users'=>'id','ld_attachments'=>'attachmentsid','ld_usersscf'=>'id');
  /*
    edit:can
    date:20131024
    reason:打印关模块
    */
    var $relatedtab=array('users'=>'','company'=>'');
      

    var $table_name = "ld_users";
    var $table_index= 'id';

    // This is the list of fields that are in the lists.
    var $list_link_field= 'last_name';

    var $list_mode;
    var $popup_type;

    /***
    更新操作
        edit：cdw
        date：20131211
        reason：0005669: 控制面板->用户，录入“审批人”时，希望打开的窗口中，列表显示依次为“账号、姓名、角色、Email、手机”。
                内容加上了角色，账号，手机
    **/
    var $search_fields = Array(
            'UserName'=>Array('ld_users'=>'user_name'),
            'Name'=>Array('ld_users'=>'last_name'),
            'PROFILES'=>Array('ld_profile'=>'profileid'),
            'Email'=>Array('ld_users'=>'email1'),
            'Phone_mobile'=>Array('ld_users'=>'phone_mobile')
            //'Email2'=>Array('ld_users'=>'email2')
    );
    var $search_fields_name = Array(
            'UserName'=>'user_name',
            'Name'=>'last_name',
            'Email'=>'email1',
            'PROFILES'=>'profileid',
            'Phone_mobile'=>'phone_mobile'
           // 'Email2'=>'email2'
    );

    var $module_name = "Users";

    var $object_name = "Users";
    var $user_preferences;
    var $homeorder_array = array('HDB','ALVT','PLVT','QLTQ','CVLVT','HLT','GRT','OLTSO','ILTI','MNL','OLTPO','LTFAQ', 'UA', 'PA');

    var $encodeFields = Array("first_name", "last_name", "description");

    // This is used to retrieve related fields from form posts.
    var $additional_column_fields = Array('reports_to_name');
    /*****
    更新操作
    edit：cdw
    date：20131211
    reason：0005669: 控制面板->用户，录入“审批人”时，希望打开的窗口中，列表显示依次为“账号、姓名、角色、Email、手机”。
                 查询的内容加上了ld_role.rolename as rolename
    ******/
    var $sortby_fields = Array('user_name','status','email1','phone_home','is_admin','last_name','phone_mobile','userlevel');

    // This is the list of lingdang_fields that are in the lists.
    var $list_fields = Array(
            'User Name'=>Array('ld_users'=>'user_name'),
            'Last Name'=>Array('ld_users'=>'last_name'),
            'Role Name'=>Array('ld_profile'=>'profileid'),
            'Email'=>Array('ld_users'=>'email1'),
            'Phone'=>Array('ld_users'=>'phone_mobile'),
            'LEV'=>Array('ld_users'=>'userlevel'),
            'Admin'=>Array('ld_users'=>'is_admin'),
            'Status'=>Array('ld_users'=>'status')
            
    );
    var $list_fields_name = Array(
                 'User Name'=>'user_name',
            'Last Name'=>'last_name',
            'Role Name'=>'profileid',
            'Email'=>'email1',
             'Phone'=>'phone_mobile',
            'LEV'=>'userlevel',
            'Admin'=>'is_admin',
            'Status'=>'status'
    );

    //Default Fields for Email Templates -- Pavani
    var $emailTemplate_defaultFields = array('last_name','title','department','phone_home','phone_mobile','signature','email1','email2','address_street','address_city','address_state','address_country','address_postalcode');

    var $popup_fields = array('last_name');

    // This is the list of fields that are in the lists.
    var $default_order_by = "user_name";
    var $default_sort_order = 'ASC';

    var $record_id;
    var $new_schema = true;

    var $DEFAULT_PASSWORD_CRYPT_TYPE; //'BLOWFISH', /* before PHP5.3*/ MD5;

    /** constructor function for the main user class
     instantiates the Logger class and PearDatabase Class
     *
     */

	public $access = array(
		'data'=>0,//数据权限：授权范围(1:个人，2全部，3：高级)
		'view'=>0,//查看其他用户单据(查看所有)
		'edit'=>0,//编辑其他用户单据(编辑所有)
		'delete'=>0,//删除其他用户单据(删除所有)
		'creator'=>0,//查看自己创建的单据
	);

	public $user_type = 'crm';

    function __construct() {
  
        $this->db = PearDatabase::getInstance();
        //$this->DEFAULT_PASSWORD_CRYPT_TYPE = (version_compare(PHP_VERSION, '5.3.0') >= 0)?
        //        'PHP5.3MD5': 'MD5';
        $this->DEFAULT_PASSWORD_CRYPT_TYPE='MD5';//php5.4和php5.2通用
        //$this->column_fields = getColumnFields('Users');
       
        $this->fieldobj=Field::getInstance('Users',$this->db);
       
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
      
        $this->column_fields['currency_name'] = '';
        $this->column_fields['currency_code'] = '';
        $this->column_fields['currency_symbol'] = '';
        $this->column_fields['conv_rate'] = '';
        //edit:can 20210203 044456: （本地php72,8.3.7.1版本）系统设置-页面设置-成员管理；成员管理页面设置中，“账号”“姓名”“密码”“确认密码”字段请改为灰色必填，参考“启用”的设置； 批量编辑改为灰色不可选，参考“手机”字段的批量编辑
        $this->mandatory_fields = Array('user_name', 'user_password', 'confirm_password');
        //$this->log->debug("Exiting Users() method ...");
    }
    /**
     * 获取用户的角色名称
     * */
    public function getUserOfProfileName($profileid=0)
    {
        global $adb;
        if(empty($profileid))
        {
            $profileid=$this->column_fields['profileid'];
        }
        $result=$adb->pquery('select profilename from ld_profile where profileid=?',array($profileid));
        if($adb->num_rows($result)>0)
        {
            return $adb->query_result($result,0,0);
        }
        return '';
    }

    /**
     * 获取用户头像
     * edit:can
     * */
     function getUserImage($userid)
     {
         global $adb;
        // require(globalStatic::$root_directory.'user_privileges/user_privileges_'.$this->id.'.php');
         $sql='select path,name,ld_attachments.attachmentsid,storage_location,cloud_path,ld_attachments.newfile_name from
                    ld_salesmanattachmentsrel INNER JOIN ld_attachments  
                    on ld_attachments.attachmentsid=ld_salesmanattachmentsrel.attachmentsid
                    where smid=? ';
         if(!empty($userid)){
             $user_result=$adb->pquery($sql,array($userid));
         }else{
             $user_result=$adb->pquery($sql,array($this->id));
             $userid=$this->id;
         }


         if($adb->num_rows($user_result)>0)
         {
             $attachmentsid=$adb->query_result($user_result,0,'attachmentsid');
             $path=$adb->query_result($user_result,0,'path');
             $newfile_name=$adb->query_result($user_result,0,'newfile_name');
             $userimagename=$adb->query_result($user_result,0,'name');
             $cloud_path=$adb->query_result($user_result,0,'cloud_path');
             $storage_location=$adb->query_result($user_result,0,'storage_location');
             $userimagetypes=explode('.',$userimagename);
             $userimagetype=$userimagetypes[sizeof($userimagetypes)-1];//获取用户照片的后缀名
             ////@edit:liushuai,2020-11-17,reason:修改获取头像路径
             if(!empty($attachmentsid)&&!empty($path)){
                 $filepath=$path.$attachmentsid.'_1.'.$userimagetype;
                 if (!file_exists($filepath)) {
                     $filepath = $path.$newfile_name;
                 }
             }
         }
         $this->userimageinfo_arr=['storagelocation'=>$storage_location];

         if($storage_location=='cos'){
             return $cloud_path;
         }
         if(!file_exists($filepath))
         {
             // ljj 20231201 XUQIU1000927 更换默认头像
             $filepath=getDefaultAvatar($userid);
         }

         return $filepath;
     }
    // Mike Crowe Mod --------------------------------------------------------Default ordering for us
    /**
     * Function to get sort order
     * return string  $sorder    - sortorder string either 'ASC' or 'DESC'
     */
    function getSortOrder() {

        if (!empty($this->reportSortType)){
            return $this->reportSortType;
        }
        if(isset($_REQUEST['sorder']))
            $sorder = $this->db->sql_escape_string($_REQUEST['sorder']);
        else
            $sorder = (($_SESSION['USERS_SORT_ORDER'] != '')?($_SESSION['USERS_SORT_ORDER']):($this->default_sort_order));
       
        return $sorder;
    }

    /**
     * Function to get order by
     * return string  $order_by    - fieldname(eg: 'subject')
    
    function getOrderBy() {
      
        $use_default_order_by = '';
        if(PerformancePrefs::getBoolean('LISTVIEW_DEFAULT_SORTING', true)) {
            $use_default_order_by = $this->default_order_by;
        }
        if (isset($_REQUEST['order_by']))
            $order_by = $_SESSION['USERS_ORDER_BY'] = $this->db->sql_escape_string($_REQUEST['order_by']);
        elseif(isset($_SESSION['USERS_ORDER_BY'])){
            $order_by = (($_SESSION['USERS_ORDER_BY'] != '')?($_SESSION['USERS_ORDER_BY']):($use_default_order_by));
        }else{
           
            $order_by= ' user_name ';
        }
       
        return $order_by;
    } */
      public function getEntityDeletedQuery(){
	
        return " ld_users.id>0 ";
		//return "ld_users.status='Active'";
	}

    /** Function to set the user preferences in the session
     * @param $name -- name:: Type varchar
     * @param $value -- value:: Type varchar
     *
     */
    function setPreference($name, $value) {
        if(!isset($this->user_preferences)) {
            if(isset($_SESSION["USER_PREFERENCES"]))
                $this->user_preferences = $_SESSION["USER_PREFERENCES"];
            else
                $this->user_preferences = array();
        }
        if(!array_key_exists($name,$this->user_preferences )|| $this->user_preferences[$name] != $value) {
            //$this->log->debug("Saving To Preferences:". $name."=".$value);
            $this->user_preferences[$name] = $value;
            $this->savePreferecesToDB();

        }
        $_SESSION[$name] = $value;


    }

    /**
     * @param $setmenuname:后台菜单名称
     * @return string：yes:有权限
     */
    public function getHaveSetProfile($setmenuname)
    {
        global $adb;
        if(is_admin($this))
        {
            return 'yes';

        }
        $sql='select setmenuprofileid  from ld_users where id=? and ifnull(setmenuprofileid,"")="1"';

        if($adb->num_rows($adb->pquery($sql,array($this->id)))>0)
        {
            return 'yes';
        }
        return 'no';

    }
    function getSmownerColumName()
    {
        return "";
        
    }
    /** Function to save the user preferences to db
     *
     */

    function savePreferecesToDB() {
        $data = base64_encode(serialize($this->user_preferences));
        $query = "UPDATE $this->table_name SET user_preferences=? where id=?";
        $result =& $this->db->pquery($query, array($data, $this->id));
        //$this->log->debug("SAVING: PREFERENCES SIZE ". strlen($data)."ROWS AFFECTED WHILE UPDATING USER PREFERENCES:".$this->db->getAffectedRowCount($result));
        $_SESSION["USER_PREFERENCES"] = $this->user_preferences;
    }

    /** Function to load the user preferences from db
     *
     */
    function loadPreferencesFromDB($value) {

        if(isset($value) && !empty($value)) {
            //$this->log->debug("LOADING :PREFERENCES SIZE ". strlen($value));
            $this->user_preferences = unserialize(base64_decode($value));
            $_SESSION = array_merge($this->user_preferences, $_SESSION);
            //$this->log->debug("Finished Loading");
            $_SESSION["USER_PREFERENCES"] = $this->user_preferences;


        }

    }


    function encrypt_password($user_password, $crypt_type='') {
        // encrypt the password.
        /*
        edit:Can
        date:20130407
        reason:用户名称不用区分大小写
        */
        $salt = strtolower(substr($this->column_fields["user_name"], 0, 2));

        // Fix for: http://trac.lingdang.com/cgi-bin/trac.cgi/ticket/4923
        if($crypt_type == '') {
            // Try to get the crypt_type which is in database for the user
            $crypt_type = $this->get_user_crypt_type();
        }

        // For more details on salt format look at: http://in.php.net/crypt
        if($crypt_type == 'MD5') {
            $salt = '$1$' . $salt . '$';
        } elseif($crypt_type == 'BLOWFISH') {
            $salt = '$2$' . $salt . '$';
        } elseif($crypt_type == 'PHP5.3MD5') {
            //only change salt for php 5.3 or higher version for backward
            //compactibility.
            //crypt API is lot stricter in taking the value for salt.
            $salt = '$1$' . str_pad($salt, 9, '0');
        }
        //edit: xll 2024/02/22 特殊字符处理统一到 encrypt_password 这个方法中，'&'经过 htmlspecialchars 后长度会变为5
        $user_password=addslashes($user_password);
        $user_password=htmlspecialchars($user_password);
        $encrypted_password = crypt($user_password, $salt);
        return $encrypted_password;
    }


    /** Function to authenticate the current user with the given password
     * @param $password -- password::Type varchar
     * @returns true if authenticated or false if not authenticated
     */
    function authenticate_user($password) {
        $usr_name = $this->column_fields["user_name"];

        $query = "SELECT * from $this->table_name where user_name=? AND user_hash=?";
        $params = array($usr_name, $password);
        $result = $this->db->requirePsSingleResult($query, $params, false);

        if(empty($result)) {
            //$this->log->fatal("SECURITY: failed login by $usr_name");
            return false;
        }

        return true;
    }

    /** Function for validation check
     *
     */
    function validation_check($validate, $md5, $alt='') {
        $validate = base64_decode($validate);
        if(file_exists($validate) && $handle = fopen($validate, 'rb', true)) {
            $buffer = fread($handle, filesize($validate));
            if(md5($buffer) == $md5 || (!empty($alt) && md5($buffer) == $alt)) {
                return 1;
            }
            return -1;

        }else {
            return -1;
        }

    }

    /** Function for authorization check
     *
     */
    function authorization_check($validate, $authkey, $i) {
        $validate = base64_decode($validate);
        $authkey = base64_decode($authkey);
        if(file_exists($validate) && $handle = fopen($validate, 'rb', true)) {
            $buffer = fread($handle, filesize($validate));
            if(substr_count($buffer, $authkey) < $i)
                return -1;
        }else {
            return -1;
        }

    }
    /**
     * Checks the config.php AUTHCFG value for login type and forks off to the proper module
     *
     * @param string $user_password - The password of the user to authenticate
     * @return true if the user is authenticated, false otherwise
     */
    function doLogin($user_password) {
       
       crm_load_class_file('User_login','modules/Users');
       return User_login::doLogin($user_password,$this);
       
    }


    /**
     * Load a user based on the user_name in $this
     * @return -- this if load was successul and null if load failed.
     * Portions created by SugarCRM are Copyright (C) SugarCRM, Inc..
     * All Rights Reserved..
     * Contributor(s): ______________________________________..
     */
    function load_user($user_password) {
        crm_load_class_file('User_login','modules/Users');
       return User_login::load_user($user_password,$this);
    }

    /**
     * Get crypt type to use for password for the user.
     * Fix for: http://trac.lingdang.com/cgi-bin/trac.cgi/ticket/4923
     */
    function get_user_crypt_type() {

        $crypt_res = null;
        $crypt_type = $this->DEFAULT_PASSWORD_CRYPT_TYPE;

        // For backward compatability, we need to make sure to handle this case.
        global $adb;
        $table_cols = $adb->getColumnNames("ld_users");
        if(!in_array("crypt_type", $table_cols)) {
            return $crypt_type;
        }

        if(isset($this->id)) {
            // Get the type of crypt used on password before actual comparision
            $qcrypt_sql = "SELECT crypt_type from $this->table_name where id=?";
            $crypt_res = $this->db->pquery($qcrypt_sql, array($this->id), true);
        } else if(isset($this->column_fields["user_name"])) {
            $qcrypt_sql = "SELECT crypt_type from $this->table_name where user_name=?";
            $crypt_res = $this->db->pquery($qcrypt_sql, array($this->column_fields["user_name"]));
        } else {
            $crypt_type = $this->DEFAULT_PASSWORD_CRYPT_TYPE;
        }

        if($crypt_res && $this->db->num_rows($crypt_res)) {
            $crypt_row = $this->db->fetchByAssoc($crypt_res);
            $crypt_type = $crypt_row['crypt_type'];
        }
        return $crypt_type;
    }

    /**
     * @param string $user name - Must be non null and at least 1 character.
     * @param string $user_password - Must be non null and at least 1 character.
     * @param string $new_password - Must be non null and at least 1 character.
     * @return boolean - If passwords pass verification and query succeeds, return true, else return false.
     * @desc Verify that the current password is correct and write the new password to the DB.
     * Portions created by SugarCRM are Copyright (C) SugarCRM, Inc..
     * All Rights Reserved..
     * Contributor(s): ______________________________________..
     */
    function change_password($user_password, $new_password, $dieOnError = true) {

         crm_load_class_file('User_Special','modules/Users');
         return  User_Special::change_password($user_password, $new_password,$this, $dieOnError );
    }

	//判断新旧密码是否一致
    function verifyPassword($password) {
        $query = "SELECT user_name,user_password,crypt_type FROM {$this->table_name} WHERE id=?";
        $result =$this->db->pquery($query, array($this->id));
        $row = $this->db->fetchByAssoc($result);
        //$this->log->debug("select old password query: $query");
        //$this->log->debug("return result of $row");
        $encryptedPassword = $this->encrypt_password($password, $row['crypt_type']);
        if($encryptedPassword != $row['user_password']) {
            return false;
        }
        return true;
    }

    function is_authenticated() {

        return $this->authenticated;
    }


    /** gives the user id for the specified user name
     * @param $user_name -- user name:: Type varchar
     * @returns user id
     */

    function retrieve_user_id($user_name) {
        global $adb;
        $query = "SELECT id from ld_users where user_name=? AND deleted=0";
        $result  =$adb->pquery($query, array($user_name));
        $userid = $adb->query_result($result,0,'id');
        return $userid;
    }



    /** Function to get the current user information from the user_privileges file
     * @param $userid -- user id:: Type integer
     * @returns user info in $this->column_fields array:: Type array
     *
     */

    function retrieveCurrentUserInfoFromFile($userid)
     {
         global $adb,$weixin_user;
        global $global_crmredisobj;
        global $PlatformMC;
        $global_crmredisobj=CRMRedis::getInstance();
        if($global_crmredisobj!='error')
        {
           
            $user_info=$global_crmredisobj->getvalue("loginuser".$userid);
            
            
            if(empty($user_info))
            {
                if(!file_exists(globalStatic::$root_directory.'user_privileges/user_privileges_'.$userid.'.php'))
                {
                    require_once("modules/Users/CreateUserPrivilegeFile.php");
                    
                    createUserPrivilegesfile($userid);
                }
                else
                  require(globalStatic::$root_directory.'user_privileges/user_privileges_'.$userid.'.php');
            }
        }
        else
        {
              if(!file_exists(globalStatic::$root_directory.'user_privileges/user_privileges_'.$userid.'.php'))
                {
                    require_once("modules/Users/CreateUserPrivilegeFile.php");
                    
                    createUserPrivilegesfile($userid);
                }
                else
              require(globalStatic::$root_directory.'user_privileges/user_privileges_'.$userid.'.php');
        }
        //edit:can 中孚手机端
         //@edit:zkt @date:2024/12/5 @reason:empty($weixin_user)兼容PHP72, $weixin_user在PHP72中没有
        if((empty($weixin_user)||isset($weixin_user->environment)&&$weixin_user->environment=='pc')&&
        (!is_array($PlatformMC)|| (!array_key_exists('mobileapp',$PlatformMC)&&$PlatformMC['mobileapp']!='yes'))
        &&$_REQUEST['file']!='OperateRestoreDataBase'&&$_REQUEST['file']!='RestoreDataBasePopup'){
            $query = "SELECT user_name ,id,scopeauthority from $this->table_name where  deleted = 0  and status ='Active' and id=? and  user_name=? AND user_password=? limit 1;";
            $userresult=$adb->pquery($query,array($userid,$user_info['user_name'],$_SESSION[globalStatic::$root_directory.'user_password']));
            if($adb->num_rows($userresult)<=0&&$_SESSION['restoredata']!='yes')
            {
                if($_REQUEST['action']=='RemindsAjax')
                {
                    ob_clean();
                    echo '#LoginUSERERROR#';
                    exit();
                }
               
                return null;
            }
        }


        //}
        

        foreach($this->column_fields as $field=>$value_iter) {
            if(isset($user_info[$field])) {
                $this->$field = $user_info[$field];
                $this->column_fields[$field] = $user_info[$field];
            }
        }
        $this->hour_format=$user_info['hour_format'];//0014891: 日程管理>日历视图：设定功能失效。
        $this->start_hour=$user_info['start_hour'];//0014891: 日程管理>日历视图：设定功能失效。
        $this->id = $userid;

        $user_type = 'crm';
        $sql = 'select crm_user_type from ld_users where id = ?;';
        $result = $adb->pquery($sql,array($userid));
        if($adb->num_rows($result) > 0){
            $user_type = $adb->query_result($result,0,'crm_user_type');
        }
        if(empty($user_type)){
            $user_type = 'crm';
        }
        $this->setuser_type($user_type);
		//用户 数据权限，放入全局变量中
		/*$this->access['data'] = $adb->query_result($userresult,0,'scopeauthority');
		$this->access['view'] = $adb->query_result($userresult,0,'viewothers');
		$this->access['edit'] = $adb->query_result($userresult,0,'editothers');
		$this->access['delete'] = $adb->query_result($userresult,0,'delothers');
		$this->access['creator'] = $adb->query_result($userresult,0,'viewselfbills');*/
        
        if($global_crmredisobj!='error')
        {
            $global_crmredisobj->setvalue('loginuser'.$userid,$user_info);
            
        }
        return $this;
    }

    /** Function to save the user information into the database
     * @param $module -- module name:: Type varchar
     *
     */
    function saveentity($module, $fileid = '') {
        global $current_user;//$adb added by raju for mass mailing
        $insertion_mode = $this->mode;
        global $adb;
        crm_load_class_file('DateTimeField','include/fields');
        if(!is_admin($current_user))
        {
            if(empty($this->id))
                $this->column_fields['setmenuprofileid']=0;
            else
            {
                $sql='select setmenuprofileid  from ld_users where id=?';
                $result=$adb->pquery($sql,array($this->id));
                $this->column_fields['setmenuprofileid']=$adb->query_result($result,0,'setmenuprofileid');

            }
        }

        //BUG20240613-55 ls 240705 	成员管理模块的验证规则不生效
        //保存时判断
        if($this->saveentityNoJudge != 'yes'){
            if($this->CheckValidata != 'no'){
                crm_load_class_file('cls_PageValidataSave','data');
                $PageValidataSaveobj=new cls_PageValidataSave($module,$this->id,$_REQUEST['rowcnt']);
                $PageValidataSaveobj->setAllowSave('no');

                $currency_id=$_REQUEST['currency_id'];

                if(empty($currency_id))
                {
                    //zxm 20240506 币种传过来为空 重置下币种从字段里面去查出来
                    $PageValidataSaveobj->ResetCurrencyid();
                    $currency_id = $PageValidataSaveobj->currencyid;
                    //$currency_id=1;
                }

                $PageValidataSaveobj->setCurrencyId($currency_id);
                $PageValidataSaveobj->getValidDataInfoPhp();


                if(!empty($PageValidataSaveobj->errortip)){
                    //edit:can 20210425 保存验证规则
                    $_REQUEST['diony']='yes';
                    //savebyerrormsg验证规则判断不通过,不直接converttojsonstring
                    if($this->is_batchbackfill == 'yes' || $this->savebyerrormsg == 'yes' ){
                        $this->saveerrormsg=$PageValidataSaveobj->errortip;
                        return ;
                    }

                    ConvertTojsonString("-1",array(),$PageValidataSaveobj->errortip);

                }
            }
        }

        if($this->column_fields['approvestatus']==getFixedLabel("INACTIVATE"))
        {
            $this->column_fields['approvestatus']=1;
        }
        else if($this->column_fields['approvestatus']==getFixedLabel("ACTIVATE"))
        {
            $this->column_fields['approvestatus']=0;
        }
        if(empty($this->column_fields['time_zone'])) {
            $dbDefaultTimeZone = DateTimeField::getDBTimeZone();
            $this->column_fields['time_zone'] = $dbDefaultTimeZone;
            $this->time_zone = $dbDefaultTimeZone;
        }
        if(empty($this->column_fields['currency_id'])) {
            $this->column_fields['currency_id'] = $this->column_fields['currency_id'];
        }
        if(empty($this->column_fields['date_format'])) {
            $this->column_fields['date_format'] = 'yyyy-mm-dd';
        }
         if(empty($this->column_fields['first_name'])) {
            $this->column_fields['first_name'] = '';
        }
        if($this->column_fields['is_admin']==1||$this->column_fields['is_admin']=='on')
        {
            $this->column_fields['is_admin']='on';
        }
        else
        {
            $this->column_fields['is_admin']='off';
        }
        $this->db->println("TRANS saveentity starts $module");
        $this->db->startTransaction();

        foreach($this->tab_name as $table_name) {
            if (strtolower($table_name) == "ld_crmentity") {
                $this->insertIntoCrmEntity($module, $fileid);
            }
            else if(strtolower($table_name) == 'ld_attachments') {
//                @edit:liushuai,2020-12-30,reason:43859: （61mis.com/kfbcrm）系统设置-成员管理-详情；在成员管理界面进行小编辑操作，保存后个人头像没有了(小编辑其他字段导致个人头像被删除)
                if ($_REQUEST['ajxaction'] =='DETAILVIEW' && $this->mode =='edit') {
                }else
                    $this->insertIntoAttachment($this->id,$module);
            }
            else {
                $this->insertIntoEntityTable($table_name, $module);
            }
        }
        $this->save_module($module);
        crm_load_function_file('createUserPrivilegesfile','modules/Users','CreateUserPrivilegeFile');
        createUserPrivilegesfile($this->id);
        unset($_SESSION['next_reminder_interval']);
        unset($_SESSION['next_reminder_time']);
        if($insertion_mode != 'edit') {
            $this->createAccessKey();
        }
		 $this->addFileToAttachment($this->id,$module);
        $this->db->completeTransaction();
        $this->db->println("TRANS saveentity ends");
    }
    function save_module($module){
        global $adb,$current_user;
        //wym XUQIU1002097 数据分类负责人排序代码优化：用户表增加一个姓名拼音的字段
        if(judgeCorpInfo('kehu001'))
            $sql_pinyin = "UPDATE ld_users SET pinyin_name = getpinyin(real_name) where id=? ;";
        else
            $sql_pinyin = "UPDATE ld_users SET pinyin_name = getpinyin(last_name) where id=? ;";
        $adb->pquery($sql_pinyin, array($this->id));

        //20240726 hzx XUQIU1001729 经销商用PRM成员管理设置
        if($this->mode == 'edit'){
            if($this->user_type != 'crm'){
                $sql_type = 'update ld_users set is_admin = "off",setmenuprofileid=0 where id = ?';
                $adb->pquery($sql_type, array($this->id));
            }
        }
        else{
            $reg=RegOp::getInstance();
            if($this->user_type == 'crm'){
                $sql_type = 'update ld_users set crm_user_type = "crm" where id = ?';

                $user_query="select 1 from ld_users where status='active' and crm_user_type = 'crm'";
                $result=$adb->pquery($user_query);
                $strUsingCount=$adb->num_rows($result);
                $regCount=$reg->GetUserCount();
            }
            else{
                $sql_type = 'update ld_users set crm_user_type = "'.$this->user_type.'",is_admin = "off",setmenuprofileid=0 where id = ?';

                $user_query="select 1 from ld_users where status='active' and crm_user_type = 'prm'";
                $result=$adb->pquery($user_query);
                $strUsingCount=$adb->num_rows($result);
                $regCount=$reg->getPrmUserCount();
            }
            $adb->pquery($sql_type, array($this->id));
            if($reg->compareCount($regCount,$strUsingCount) <= 0){
                $sql_status = 'update ld_users set status = "Inactive" where id = ?';
                $adb->pquery($sql_status, array($this->id));
            }
        }
        //edit:duan date:2024/10/24 reason:用户模块的职位级别字段特殊处理
        if(isset($_REQUEST['jsonvalue_userlevel'])){
            $json_value = $_REQUEST['jsonvalue_userlevel'];
            $json_arr = json_decode($json_value,true);
            $cur_groupset_arr = [];
            $old_value_arr = [];
            if($this->mode == 'edit'){
                $sql = "SELECT id,groupid,content from ld_user_group_set where userid = ? and type = 'userlevel' order by groupid asc ";
                $result = $adb->pquery($sql,[$this->id]);
                $num_rows = $adb->num_rows($result);
                for ($tmp_index=0;$tmp_index < $num_rows;$tmp_index++){
                    $tmp_groupid = $adb->query_result($result,$tmp_index,'groupid');
                    $tmp_content = $adb->query_result($result,$tmp_index,'content');
                    $tmp_id = $adb->query_result($result,$tmp_index,'id');
                    $cur_groupset_arr[$tmp_groupid] = $tmp_id;
                    $old_value_arr[] = ['id'=>$tmp_groupid,'value'=>$tmp_content];
                }
            }
            $old_json_value = json_encode($old_value_arr);
            if($old_json_value != $json_value){
                $this->modstatic->saveFieldLogOne($module,'userlevel',$this->id,$old_json_value, $json_value);
            }
            $copy_arr = $cur_groupset_arr;
            foreach ($json_arr as $tmp_arr){
                $tmp_groupid = $tmp_arr['id'];
                if(array_key_exists($tmp_groupid,$cur_groupset_arr)){
                    $sql = 'UPDATE ld_user_group_set set content = ? where id = ?;';
                    $value_arr = [$tmp_arr['value'],$cur_groupset_arr[$tmp_groupid]];
                    unset($copy_arr[$tmp_groupid]);
                }else{
                    $sql = 'INSERT into ld_user_group_set(`userid`,`groupid`,`type`,`content`) value(?,?,?,?);';
                    $value_arr = [$this->id,$tmp_groupid,'userlevel',$tmp_arr['value']];
                }
                $adb->pquery($sql,$value_arr);
            }
            if(sizeof($copy_arr)>0){
                $sql = 'DELETE from ld_user_group_set where id in ('.implode(',',$copy_arr).')';
                $adb->query($sql);
            }

        }

    }

    function createAccessKey() {
        global $adb;
        /*
        edit:can
        date:20130706
        reason:用户保存更新first_name字段值，以保证视图中负责人可以查询
        
        */
        $updateQuery = "update ld_users set accesskey=?,first_name='' where id=?";
        $insertResult = $adb->pquery($updateQuery,array($this->vtws_generateRandomAccessKey(16),$this->id));
        
    }
	function vtws_generateRandomAccessKey($length=10){
		$source = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
		$accesskey = "";
		$maxIndex = strlen($source);
		for($i=0;$i<$length;++$i){
			$accesskey = $accesskey.substr($source,rand(null,$maxIndex),1);
		}
		return $accesskey;
	}
    /** Function to insert values in the specifed table for the specified module
     * @param $table_name -- table name:: Type varchar
     * @param $module -- module:: Type varchar
     */
    function insertIntoEntityTable($table_name, $module,$fileid = '') {
       
        crm_load_class_file('User_Special','modules/Users');
         return  User_Special::insertIntoEntityTable($table_name, $module,$this,$fileid);
    }



    /** Function to insert values into the attachment table
     * @param $id -- entity id:: Type integer
     * @param $module -- module:: Type varchar
     */
   public  function insertIntoAttachment($id,$module) {
       //BUG0067634 ls 20230606 kfbcrm-成员管理-图片字段-点击上传图片，保存后显示为空(uploadAndSaveFile只处理了个人头像uitype为105,没有处理新增的图片字段)
        parent::insertIntoAttachment($id,$module);
     //   foreach($_FILES as $fileindex => $files) {
          //  if($files['name'] != '') {
           //     $files['original_name'] = vtlib_purify($_REQUEST[$fileindex.'_hidden']);
                $this->uploadAndSaveFile($id,$module,$files);
            //}
        //}

        // $log->debug("Exiting from insertIntoAttachment($id,$module) method.");
    }
    /**
     * 获取用户所拥有查看的范围的用户
     * edit:can
     * */
    public function getUserOfUsers($module_name)
    {
		global $adb,$current_user;
		$assigned_user_id = $this->id;
		
		$search_senior = false;
		$ScopOfAuthority = ScopOfAuthority::getInstance($adb,$module_name);
		$scopeauthority = $ScopOfAuthority->getUserModuleScoperType();//用户对应当前模块的单据业务授权范围类型
		$moduleshare =$ScopOfAuthority->getModuleShareInfo();//3:私有
		if($moduleshare=='')$moduleshare=3;
		//管理员、模块共享、用户授权非私有
		if('on' == $this->is_admin || 3 != $moduleshare || $scopeauthority > 0){
		  
			$search_senior = true;//显示查看范围高级选项
		}
		if('on' == $current_user->is_admin || 3 != $moduleshare || 1 == $scopeauthority){
			//管理员、模块共享、用户授权为全部
            
			$userscope = get_user_array(FALSE, "Active");
		}else if(2 == $scopeauthority || $scopeauthority == 3){
			//非管理员、模块私有、用户授权为高级
		 
			$userscope = $this->getUserScopeInfo($this->id);//获取授权范围
			
		}else{//私有
			$userscope[$assigned_user_id] = getUserFullName($assigned_user_id);
		
		}
        return $userscope;
  }
    /** Function to retreive the user info of the specifed user id The user info will be available in $this->column_fields array
     * @param $record -- record id:: Type integer
     * @param $module -- module:: Type varchar
     */
    function retrieve_entity_info($record, $module) {
        global $adb;
        if($record == '') {
          
            return null;
        }

        $result = Array();
        
        foreach($this->tab_name_index as $table_name=>$index) {
          
            $result[$table_name] = $adb->pquery("select * from ".$table_name." where ".$index."=?", array($record));
        }
         
        $tabid = getTabid($module);
       // $sql1 =  "select columnname,tablename,fieldname from ld_field where tabid=? and ld_field.presence in (0,2)";
      //  $result1 = $adb->pquery($sql1, array($tabid));
        //$noofrows = $adb->num_rows($result1);
        $fieldmodules=$this->fieldobj->getModuleFields();
        foreach($fieldmodules as $fieldname=>$fieldinfo) {
            $fieldcolname = $fieldinfo->getColumnName();
            $tablename =$fieldinfo->getTableName();
            $fieldname =$fieldname;
            $fld_value='';
              if($adb->num_rows($result[$tablename])>0)
                 $fld_value = $adb->query_result($result[$tablename],0,$fieldcolname);
            $this->column_fields[$fieldname] = $fld_value;
            $this->$fieldname = $fld_value;

        }
      
      
        $this->column_fields["record_id"] = $record;
        $this->column_fields["record_module"] = $module;

      
        $this->column_fields["currency_name"]= $this->currency_name = 'China, Yuan Renminbi';
        $this->column_fields["currency_code"]= $this->currency_code = 'CNY';
        $this->column_fields["currency_symbol"]= $this->currency_symbol = '¥';
        $this->column_fields["conv_rate"]= $this->conv_rate = '1.000000';

		// TODO - This needs to be cleaned up once default values for fields are picked up in a cleaner way.
		// This is just a quick fix to ensure things doesn't start breaking when the user currency configuration is missing
		if($this->column_fields['currency_grouping_pattern'] == ''
				&& $this->column_fields['currency_symbol_placement'] == '') {

			$this->column_fields['currency_grouping_pattern'] = $this->currency_grouping_pattern = '123,456,789';
			$this->column_fields['currency_decimal_separator'] = $this->currency_decimal_separator = '.';
			$this->column_fields['currency_grouping_separator'] = $this->currency_grouping_separator = ',';
			$this->column_fields['currency_symbol_placement'] = $this->currency_symbol_placement = '$1.0';
		}

		// TODO - This needs to be cleaned up once default values for fields are picked up in a cleaner way.
		// This is just a quick fix to ensure things doesn't start breaking when the user currency configuration is missing
		if($this->column_fields['currency_grouping_pattern'] == ''
				&& $this->column_fields['currency_symbol_placement'] == '') {

			$this->column_fields['currency_grouping_pattern'] = $this->currency_grouping_pattern = '123,456,789';
			$this->column_fields['currency_decimal_separator'] = $this->currency_decimal_separator = '.';
			$this->column_fields['currency_grouping_separator'] = $this->currency_grouping_separator = ',';
			$this->column_fields['currency_symbol_placement'] = $this->currency_symbol_placement = '$1.0';
		}

		$this->id = $record;
	

        return $this;
    }


    /** Function to upload the file to the server and add the file details in the attachments table
     * @param $id -- user id:: Type varchar
     * @param $module -- module name:: Type varchar
     * @param $file_details -- file details array:: Type array
     */
    function uploadAndSaveFile($id,$module,$file_details) {
       crm_load_class_file('User_Special','modules/Users');
         return  User_Special::uploadAndSaveFile($id,$module,$file_details,$this);
    }


    /** Function to save the user information into the database
     * @param $module -- module name:: Type varchar
     *
     */
    function save($module_name, $fileid = '') {
        global  $adb,$current_user,$root_directory;
        $this->getModuleStatic('ModTracker');

		$this->modstatic->init($this,$module_name);
        if(file_exists('project_company.php'))
            {
                ////汇付天下
                $saveuser='yes';
                include('project_company.php');
            }
        if(!isset($_REQUEST['is_admin'])||$_REQUEST['is_admin']=='')
            $_REQUEST['is_admin']='off';
            
        $this->saveentity($module_name);

        // Added for Reminder Popup support
        $query_prev_interval = $adb->pquery("SELECT reminder_interval from ld_users where id=?",
                array($this->id));
        $prev_reminder_interval = $adb->query_result($query_prev_interval,0,'reminder_interval');
        //37983: （1.6）使用系统管理员登录>成员管理>用户编辑界面>修改该成员的【职位级别】修改后保存：系统生成的修改日志中的修改人显示的是用户本人，而不是当前操作人。（需要补丁）
        
        //$current_user->id=$this->id;//这个语句不能删除，删除后51mis.com/registration.php注册保存后有bug
        ///$this->resetReminderInterval($prev_reminder_interval);
       
		//处理用户高级授权 只有管理员才可以编辑
		if('on' == $current_user->is_admin||isPermitted("Users", 'index','') == 'yes')
			$this->save_user_scope($this->id,$this->column_fields['scopeauthority'],$_REQUEST['scopeuserid']);
      
        createUserPrivilegesfile($this->id);
        if($_REQUEST['mode']=='create'){
            $uid=$this->id;
            require_once('SaveScope.php');
        }
        if (isset($_REQUEST['ODuplicateID']) && !empty($_REQUEST['ODuplicateID'])){

        }else{
            $this->modstatic->triggerEvent($module_name);
        }
        //系统操作日志
        crm_load_class_file('cls_OperationLogs','modules/Settings/cls_OperationLogs');
        $logcontent = $_REQUEST;
        if($this->logaction != ''){
            $logcontent['logaction'] = $this->logaction;
        }
        if($this->mode != ''){
            $actiontype = $this->mode;
        }
        $this->logId = cls_OperationLogs::saveLogs($module_name,$actiontype,$this->id,$logcontent);
        cls_OperationLogs::SaveOperationLogsRelation($this);
        return ['code'=>"ok",[],'success'];
    }
    /**
     * 用户管理选择部门插入ld_users2group表
     * cme 2016-01-12
     * */
    function insertUsersGroup($groupid,$userid){
        global $adb,$current_user;
        if(!empty($userid)){
            $sql= 'delete from ld_users2group where userid='.$userid;
            $adb->pquery($sql);
        }
        if(!empty($groupid)){
            $groupidarr = explode(',',$groupid);
            for($i=0;$i<count($groupidarr);$i++){
                $query='insert into ld_users2group (groupid,userid)value('.$groupidarr[$i].','.$userid.')';
                $adb->pquery($query);
            }
        }
    }
	/**
	 * 用户授权范围处理方法
	 * @param Integer $userid 用户ID
	 * @param String $scopeauthority 用户授权范围
	 * @param String $scopeuserid 高级授权用户
	 * @author Tujt 2015-03-25
	 */
	public function save_user_scope($userid,$scopeauthority,$scopeuserid) {
		global $adb;
		//删除原有授权用户
		$this->delete_user_scope($userid);
	    if(2 == $scopeauthority){//授权范围为高级
			$scopeuserid = trim($scopeuserid,',');
			$scopeuserarr = explode(',',$scopeuserid);
			$scopeuserarr = f_array_unique($scopeuserarr);//删除重复元素
			if(!f_array_search($userid,$scopeuserarr)){
				$scopeuserarr[] = $userid;//用户授权范围中必须包括自己
			}
			foreach($scopeuserarr as $id){
				$insert = 'insert into ld_userscoperhigher(userid,viewuserid) values(?,?);';
				$adb->pquery($insert,array($userid,$id));
			}
		}
	}
	/**
	 * 删除用户关联授权范围
	 * @param Integer $userid 用户ID
	 * @return
	 * @author Tujt 2015-03-25
	 */
	public function delete_user_scope($userid) {
	    global $adb;
		//删除原有授权用户
		$delete = 'delete from ld_userscoperhigher where userid = ? ';
		$adb->pquery($delete,array($userid));
	}

	/**
	 * 获取用户高级授权范围
	 * @param Integer $userid 用户ID
	 * @return Array userid=>lastname 数组格式
	 * @author Tujt 2015-03-25
	 */
	public function getUserScopeInfo($userid,$module='') {
		static $staticUserScopeInfo;
		global $adb,$currentModule;
		if(empty($module)){
			$module = $currentModule;
		}
		$statickey = 'UserScopeInfo'.$module.'_'.$userid;
		if(!empty($staticUserScopeInfo) && isset($staticUserScopeInfo[$statickey]))
			return $staticUserScopeInfo[$statickey];
		$ScopOfAuthority = ScopOfAuthority::getInstance($adb,$module);
		$viewUserArr = $ScopOfAuthority->getUserModuleScopeHigher();
        
		foreach($viewUserArr as $user_id){
			$viewuser[$user_id] = getUserFullName($user_id);
		}
		//如果为空  默认为自己
		if(empty($viewuser)){
			$viewuser[$userid] = getUserFullName($userid);
		}
		return $staticUserScopeInfo[$statickey] = $viewuser;
	}
    /**
     * 获取高级用户的数量
     * */
    public function getHigerUserCounts($userid=0)
    {
         global $adb;
		$query = 'select count(viewuserid) from ld_userscoperhigher where userid = ? ';
        if(!empty($userid))
		  $result = $adb->pquery($query,array($userid));
        else
        {
            $result = $adb->pquery($query,array($this->id));
        }
		
		return $adb->num_rows($result);
    }
	
	/**
	 * 获取用户共享数据的共享人结果集
	 * @param Integer $userid 用户ID
	 * @return Array userid=>lastname 数组格式
	 * @author Tujt 2015-03-26
	 */
	public function getShareUserId($module,$userid) {
	    global $adb;
        if($module=='Event')
        {
            $module='Calendar';
        }
        else if($module=='ServiceCharge')
        {
            $module='Accounts';
        }
		//chj:因为附件没有页面设置，所有新增单据时，ld_crmentity表里是不会插入单据的。
		if($module == 'Attachment'){
			$query = 'SELECT shareuserid FROM ld_tabshare 
					INNER JOIN ld_attachmentsforbills 
						ON ld_attachmentsforbills.`attachmentsid` = ld_tabshare.`crmid`
					WHERE ld_attachmentsforbills.deleted = 0 and (viewuserid = ? or Shareuserid = ?)   
					GROUP BY shareuserid ORDER BY ld_tabshare.`crmid`;';
			$result = $adb->pquery($query,array($userid,$userid));
		}else{
			$query = 'SELECT shareuserid FROM ld_tabshare 
					INNER JOIN ld_crmentity 
						ON ld_crmentity.`crmid` = ld_tabshare.`crmid`
					WHERE ld_crmentity.`setype` = ? AND (viewuserid = ? or Shareuserid = ?) 
					GROUP BY shareuserid ORDER BY ld_tabshare.`crmid`;';
			$result = $adb->pquery($query,array($module,$userid,$userid));
		}

		$rows = $adb->num_rows($result);
		$shareuser = array();
		if($rows > 0){
			for($i=0;$i<$rows;++ $i){
				$shareuserid = $adb->query_result($result,$i,'shareuserid');
				$shareuser[$shareuserid] = getUserFullName($shareuserid);
			}
		}
		return $shareuser;
	}
   

    /**
     * edit:can 20200826
     * 判断用户模块的汇报人字段是否启用
     * 有：yes
     * */
    public function isExistReprotertouserField()
    {
       $allpresencefield= $this->fieldobj->getModuleAllPreseneceFields();
        foreach($allpresencefield as $fieldname=>$fieldinfo )
        {
            if($fieldname=='reportertouser')
            {
                return 'yes';
            }
        }
        return 'no';
    }

   
    function track_view($user_id, $current_module,$id='') {
        //$this->log->debug("About to call lingdang_tracker (user_id, module_name, item_id)($user_id, $current_module, $this->id)");

        $tracker = new Tracker();
        $tracker->track_view($user_id, $current_module, $id, '');
    }

    /**
     * Function to get the column value of a field
     * @param $column_name -- Column name
     * @param $input_value -- Input value for the column taken from the User
     * @return Column value of the field.
     */
    function get_column_value($columname, $fldvalue, $fieldname, $uitype, $datatype='') {
        if (is_uitype($uitype, "_date_") && $fldvalue == '') {
            return null;
        }
        if ($datatype == 'I' || $datatype == 'N' || $datatype == 'NN') {
            return 0;
        }
        return $fldvalue;
    }

    
   

    function filterInactiveFields($module) {
        // TODO Nothing do right now
    }

    function deleteImage() {
        $sql1 = 'SELECT attachmentsid FROM ld_salesmanattachmentsrel WHERE smid = ?';
        $res1 = $this->db->pquery($sql1, array($this->id));
        if ($this->db->num_rows($res1) > 0) {
            $attachmentId = $this->db->query_result($res1, 0, 'attachmentsid');

            $sql2 = "DELETE FROM ld_crmentity WHERE crmid=? AND setype='Users Attachments'";
            $this->db->pquery($sql2, array($attachmentId));

            $sql3 = 'DELETE FROM ld_salesmanattachmentsrel WHERE smid=? AND attachmentsid=?';
            $this->db->pquery($sql3, array($this->id, $attachmentId));

            $sql2 = "UPDATE ld_users SET imagename='' WHERE id=?";
            $this->db->pquery($sql2, array($this->id));

            $sql4 = 'DELETE FROM ld_attachments WHERE attachmentsid=?';
            $this->db->pquery($sql4, array($attachmentId));
        }
    }

    /** Function to delete an entity with given Id */
    function trash($module, $id) {
        global  $current_user;

        $this->mark_deleted($id);
    }

	function transformOwnerShipAndDelete($userId,$transformToUserId){
		$adb = PearDatabase::getInstance();
		require_once(globalStatic::$root_directory.'include/events/VTEventCondition.php');
		require_once(globalStatic::$root_directory.'include/events/VTEventTrigger.inc');
		require_once(globalStatic::$root_directory.'include/events/VTEventsManager.inc');
		require_once(globalStatic::$root_directory.'include/events/VTEntityData.inc');
        
		$em = new VTEventsManager($adb);

        // Initialize Event trigger cache
		$em->initTriggerCache();

		$entityData  = VTEntityData::fromUserId($adb, $userId);
		
		//set transform user id
		$entityData->set('transformtouserid',$transformToUserId);

        $em->triggerEvent("lingdang.entity.beforedelete", $entityData);

		$this->vtws_transferOwnership($userId, $transformToUserId);
		//系统操作日志
        crm_load_class_file('cls_OperationLogs','modules/Settings/cls_OperationLogs');
        cls_OperationLogs::saveDeletedRecordInfo('Users',[$userId]);

		//delete from user lingdang_table;
		$sql = "delete from ld_users where id=?";
		$adb->pquery($sql, array($userId));
        cls_OperationLogs::saveLogs('Users','Delete',$userId,$_REQUEST);
	}
    //删除用户后插入负责人变更记录
    function update_user_Smownerid($name,$tablename,$columnname,$fieldname,$ownerId){
        if($name=='')
        return '';
       	global $adb;
        $focus = CRMEntity::getInstance($name);
       	//$module_tablename = $focus->table_name;//当前模块的主表名
        $module_tableindex = $focus->table_index;//当前模块的主表的ID
        $focus->getModuleStatic('ModTracker');//字段修改日志
        $sql = "select $module_tableindex from $tablename where $columnname=$ownerId";  
             
       	$result = $adb->pquery($sql,array());
        $num_rows = $adb->num_rows($result);
        if($num_rows > 0){
    		for($i = 0; $i<$num_rows; $i++){
    		  	$rec_id = $adb->query_result($result,$i,$focus->table_index);
                $focus->modstatic->saveFieldLogOne($name,$fieldname,$rec_id,$ownerId, $newOwnerId);
				
  		    }
        }
    }
	function vtws_transferOwnership($ownerId, $newOwnerId, $delete=true) {
	    crm_load_class_file('User_Special','modules/Users');
         return  User_Special::vtws_transferOwnership($ownerId, $newOwnerId, $this,$delete);
	}
    /**
     * This function should be overridden in each module.  It marks an item as deleted.
     * @param <type> $id
     */
    function mark_deleted($id) {
        global  $current_user, $adb;
        $date_var = date('Y-m-d H:i:s');
        $query = "UPDATE ld_users set status=?,date_modified=?,modified_user_id=? where id=?";
        $adb->pquery($query, array('Inactive', $adb->formatDate($date_var, true),
                $current_user->id, $id), true,"Error marking record deleted: ");
    }

  
  
    /**
    *@author:andy
    *@data:
    *@reason:获取用户登陆信息
    *@version:true:该用户在24小时内已经登陆
    * @mobile:yes:表示手机登陆
    */
    public function SmsLoginCheck24Hours($mobile='no'){
        crm_load_class_file('User_Special','modules/Users');
         return  User_Special::SmsLoginCheck24Hours($mobile,$this);
    }
    
    function getListQuery($module, $where = '') {
		$list_fields = $this->list_fields;//列表显示字段
        $query = "SELECT id,user_name,last_name,email1,is_admin,phone_home,
						phone_mobile,status,ld_profile.profilename as rolename,
						ld_profile.profileid as roleid,userlevel
				 	FROM ld_users 
				 	    LEFT JOIN ld_profile ON ld_profile.profileid = ld_users.profileid 
					WHERE deleted = 0 " . $where;    
        return $query;
    }
	//获取用户管理模块列表
	function getList($result){
		  crm_load_class_file('User_Special','modules/Users');
         return  User_Special::getList($result,$this);
	}
	
	//判断是否是kehu001
	function getAuthType(){
		//require_once globalStatic::$root_directory.'WeiXinApp/WeiXin_common/cls_StaticCommonFun.php';
        //edit:can BUG20241021-55
        $regop=RegOp::getInstance();

        if(get_class($regop)=='Reg_weixinInfo') {
			return 'yes';
		}else{
			return 'no';
		}
	}
	//判断是否安装企业微信
	function getInstallApp(){

		//require_once globalStatic::$root_directory.'appCommon/appCommon.php';
		if(!judgeCorpInfo('install_app')){
			return 'no';
		}else{
			return 'yes';
		}
	}

	//判断是否客户001预置账套
	function getVersionKehu001(){
		//require_once globalStatic::$root_directory.'appCommon/appCommon.php';
        
        if(isKehu001ServerPc()=='yes'){
            return 'yes';
        }
        else {
            return 'no'; 
        }
        
        /*
		if(!judgeCorpInfo('kehu001')){
			return 'no';
		}else{
			return 'yes';
		}
        */
	}
    ////zxm 2021-0122【修改密码增加操作日志】 https://www.tapd.cn/63637123/prong/stories/view/1163637123001001248
	function insertUserLog($module,$crmid,$whodid,$prevalue,$postvalue,$fieldname)
    {
        global $adb;
        $time = date('Y-m-d H:i:s',time());
        $status = 0;
        $modtrackerId = $adb->getUniqueID('ld_modtracker_basic');
        $query = 'insert into ld_modtracker_basic(id,crmid,module,whodid,changedon,status) values (?,?,?,?,?,?);';
        $adb->pquery($query,array($modtrackerId,$crmid,$module,$whodid,$time,$status));
        $query = 'insert into ld_modtracker_detail(id,fieldname,prevalue,postvalue) values(?,?,?,?);';
        $adb->pquery($query,array($modtrackerId,$fieldname,$prevalue,$postvalue));
    }

    //ls 2021-12-15 【1002160】企业微信通讯录及部门同步(企业微信绑定CRM且开启通讯录同步API接口时,客户001账套也不显示)
    function getAddressbookSync(){
        global $adb;
        $result = $adb->pquery("select * from ld_wx_config where switch = 'open' and  IFNULL(para_content,'') <> '' and name = 'addressbook_setting'",array());
        if($adb->num_rows($result) < 1){
            return false;
        }
        $result = $adb->pquery("select para_content from ld_wx_config where IFNULL(para_content,'') <> '' and `name` = 'addressbook_setting_corpid'",array());
        if($adb->num_rows($result) < 1){
            return false;
        }

        /*require_once globalStatic::$root_directory.'appCommon/appCommon.php';
        if(!judgeCorpInfo('install_app')){
            return false;
        }*/

        if(isKehu001ServerPc() == 'yes'){
            return false;
        }
        return true;
    }

    public function getDefaultProfileid(){
        global $adb;
        $sql = "SELECT
                CASE
                    WHEN EXISTS (SELECT 1 FROM ld_profile WHERE profileid=12) THEN 12
                    WHEN EXISTS (SELECT 1 FROM ld_profile WHERE profileid NOT IN (1,12)) THEN
                        (SELECT profileid FROM ld_profile WHERE profileid NOT IN (1,12) LIMIT 1)
                    WHEN NOT EXISTS (SELECT 1 FROM ld_profile WHERE profileid>1) THEN 1
					ELSE 0
                END AS profileid";
        $result = $adb->pquery($sql,array());
        $seller_profileid = 0;
        if($adb->num_rows($result)>0) {
            $seller_profileid = $adb->query_result($result, 0, 'profileid');
        }

        return $seller_profileid;
    }

    public function getAddressbookSetting() {
        global $adb;
        $query = "select * from ld_wx_config where name = ?";
        $result = $adb->pquery($query, array('addressbook_setting'));
        $data = [];
        if ($adb->num_rows($result) >= 1) {
            $data = array(
                "switch"=>$adb->query_result($result,0,'switch'),//通讯录是否开启且配置成功
                "secret"=>$adb->query_result($result,0,'para_content'),
                "corp_link"=>$adb->query_result($result,0,'para_one'),
                "token"=>$adb->query_result($result,0,'para_two'),
                "encodingAesKey"=>$adb->query_result($result,0,'para_three'),
            );
        }

        return $data;
    }
    
    //获取不显示字段
    function getSearchNoshowfields() {
        
        $modulenoshowfields = array('activity_view', 'lead_view', 'hour_format', 'end_hour'
        , 'start_hour', 'title', 'reports_to_id', 'phone_other'
        , 'secondaryemail', 'signature', 'address_street', 'address_city', 'address_state', 'address_postalcode'
        , 'address_country', 'accesskey', 'time_zone', 'currency_id', 'currency_grouping_pattern', 'currency_decimal_separator'
        , 'currency_grouping_separator', 'currency_symbol_placement', 'internal_mailer', 'theme', 'language'
        , 'reminder_interval', 'asterisk_extension', 'use_asterisk', 'attachmentsid', 'date_format', 'email2'
        , 'confirm_password', 'user_password', 'viewothers', 'editothers', 'imagename'
        , 'delothers', 'viewselfbills', 'edit_other_mobile', 'edit_me_mobile', 'is_mobile_style'
        , 'select_servicedetail', 'select_due_date', 'trackpostion', 'login_sms', 'telephone_view'
        , 'push_work_reminds', 'push_news_reminds', 'push_wx_reminds', 'scopeauthority', 'accountallview');
            $deployarray = getSys_deploy(55);//呼叫中心类型
            $deploy_value = $deployarray['deploy_value']??'';
            if ($deploy_value == '汉天EC2') {
                $modulenoshowfields[] = 'sopho_exten';
                $modulenoshowfields[] = 'sopho_queue';
                $modulenoshowfields[] = 'jw_user';

            } else if ($deploy_value == '苏州思孚') {
                $modulenoshowfields[] = 'hantian_exten';
                $modulenoshowfields[] = 'jw_user';
            } else if ($deploy_value == '苏州九维') {
                $modulenoshowfields[] = 'hantian_exten';
                $modulenoshowfields[] = 'sopho_exten';
                $modulenoshowfields[] = 'sopho_queue';
            } else {
                $modulenoshowfields[] = 'hantian_exten';
                $modulenoshowfields[] = 'sopho_exten';
                $modulenoshowfields[] = 'sopho_queue';
                $modulenoshowfields[] = 'jw_user';
            }
            if(strpos($deploy_value,'天润融通')===false){
                $modulenoshowfields['Users'][] = 'tianrun_exten';
            }
       
        return $modulenoshowfields;
    }

    //20240726 hzx XUQIU1001729 经销商用PRM成员管理设置
    //获取user_type过滤  where sql
    public function getusertypewheresql(){
        if(!empty($this->user_type)){
            $where = $this->table_name.'.crm_user_type="'.$this->user_type.'"';
            $whereMainJoinTable_arr = [$this->table_name];
            return array('where'=>$where,'maintabarr'=>$whereMainJoinTable_arr);
        }
    }

    public function setuser_type($type){
        $this->user_type = $type;
        $this->crm_user_type=$type;
    }

    public function getuser_type(){
        return $this->user_type;
    }

    public static function getAllUsersImages(){
        global $adb;
        $list = [];
        $sql = 'SELECT
                ld_users.id,ld_users.gender,a.`name`,a.path,a.newfile_name,a.storage_location,a.cloud_path
            FROM
                ld_users
            LEFT JOIN ld_salesmanattachmentsrel s ON s.smid = ld_users.id
            LEFT JOIN ld_attachments a ON a.attachmentsid = s.attachmentsid';
        $result = $adb->pquery($sql,array());
        $num = $adb->num_rows($result);
        if($num > 0){
            for($i = 0;$i < $num;$i++){

                $userid = $adb->query_result($result,$i,'id');
                $gender = $adb->query_result($result,$i,'gender');
                $userimgpath = $adb->query_result($result,$i,'path');
                $userimgname = $adb->query_result($result,$i,'newfile_name');
                $storage_location = $adb->query_result($result,$i,'storage_location');
                $cloud_path = $adb->query_result($result,$i,'cloud_path');

                $userfilepath = '';
                if(empty($userimgname)){
                    $userfilepath=getDefaultAvatarBygender($gender);
                }
                else{
                    if($storage_location == 'cos'){
                        $userfilepath = $cloud_path;
                    }
                    else{
                        $image_str = $userimgpath.$userimgname;
                        //curPageURL();
                        $userfilepath = $image_str;
                        if(!file_exists(globalStatic::$root_directory.$image_str)||!@getimagesize(globalStatic::$root_directory.$image_str)){
                            $userfilepath=getDefaultAvatarBygender($gender);
                        }
                    }
                }
                $list[$userid] = $userfilepath;
            }
        }
        return $list;
    }


    public function getUserinfoByColumnname($columnname,$columnvalue){
        global $adb;
        $sql="select * from ld_users where ".$columnname."=? and `status`='Active'";
        $result=$adb->pquery($sql,array($columnvalue));
        $num_rows = $adb->num_rows($result);
        $arr = [];
        if($num_rows>0){
            for($i = 0; $i<$num_rows; $i++) {
                $arr[] = array(
                    "id"=>$adb->query_result($result,0,'id'),
                    "user_name"=>$adb->query_result($result,0,'user_name'),
                    "user_password"=>$adb->query_result($result,0,'user_password'),
                );

            }
        }

        return $arr;
    }
	
}
Users::require_file();
?>