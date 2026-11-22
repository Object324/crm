<?php

/*
 * editor : gyq_01
 * reason : 新增用户密码严格管理
 * date   : 2016.1.15
 * */
class cls_CheckPwd
{
    private $userobj;
    private $days = array('on' => 30, 'off' => 90);
    private $password_len = array('on' => 15, 'off' => 8);
    private $role = array('on'=>'ADMIN','off'=>'ORDINARYUSER');
    public $errorinfo = array();

    public function __construct($userobj)
    {
        $this->userobj = $userobj;
        $this->userobj->user_password = $_REQUEST['user_password'];

    }
 
    public function __get($name)
    {
        if($name == 'role' ){
            $arr = $this->$name;
            return getFixedLabel($arr[$this->userobj->is_admin]);
        }else {
            $arr = $this->$name;
            return $arr[$this->userobj->is_admin];
        }

    }
   /**
    * 判断管理员和非管理员密码是否超时
    * 未超时：false,超时:true
    * */
    public function PasswordInterval(){

        // 密码修改时间 $interval

        $between_days = DateOperation::days_between_date(date("Y-m-d H:i:s",time()),$this->userobj->date_modified);

        if ($between_days > $this->days[$this->userobj->is_admin]) {
            return true;
        }else{
            return false;
        }

    }
    /**
     * 判断密码格式是否正确,正确：false,否则:true
     * 
     * */
    public function PasswordManage()
    {
        
        //edit:can 20210416 单点登录->增加校验密码是否严格管理
        
        if($this->userobj->pwd_checkcondition=='yes'&&!isset($_REQUEST['save_checkstrictpwd']))
            return true;
         if(isset($_REQUEST['tokenkey']))
         {
            //edit:can 202104 16 单点登录 不要做密码严格验证的 2，3,4项
            return false;
         }
        $password = $this->userobj->user_password;

        if(isset($_REQUEST['passwordinfo'])){

            $password = $_REQUEST['passwordinfo'];

        }

        // 密码长度
        $length = strlen($password) - $this->password_len[$this->userobj->is_admin] ;

        if($length < 0) array_push($this->errorinfo,sprintf(getFixedLabel('PMLEASTPASSWORDLENGTH'),$this->password_len[$this->userobj->is_admin]));

        // 包含用户账号user_name或者用户姓名last_name
        /*
         * editor:gyq
         * reason:密码管理，密码不能包含用户名，给noname增加用户名last_name
         * date:2016 . 1 .21
         * */
        $noname = preg_match('/'.$this->userobj->user_name.'/', $password) + preg_match('/'.$this->userobj->column_fields["last_name"].'/', $password);

        if($noname > 0)  array_push($this->errorinfo,getFixedLabel('PMPASSWORDILLEGALCONTAIN'));

        // 字符类型 $match_result
        $match_result = preg_match('/[A-Z]/', $password)+ preg_match('/[a-z]/', $password) + preg_match('/\d/', $password) + preg_match('/((?=[\x21-\x7e]+)[^A-Za-z0-9])/', $password);

        if($match_result < 3)  array_push($this->errorinfo,sprintf(getFixedLabel('PMREQUIREMENTLACK'),$match_result));
		
		//判断新密码和旧密码是否一致
		$verifyPassword = $this->userobj->verifyPassword($password);
		if($verifyPassword){
			array_push($this->errorinfo,sprintf(getFixedLabel('thenewpwdisnotbesameastheoldone')));
		}
        if( $length < 0 || $noname>0 || $match_result < 3)
            return true;
        else
            return false;

    }
}

if(isset($_REQUEST['passwordinfo'])){



    global $current_user,$adb;

    if($_REQUEST['passwordinfo']== null){

        echo getFixedLabel('PMENTERNEWPASSWORD').'FI';

    }else{

         $current_user = new Users();
        $result = $current_user->retrieveCurrentUserInfoFromFile($_SESSION['authenticated_user_id']);
        $temp = new cls_CheckPwd($current_user);
        $_REQUEST['save_checkstrictpwd']='yes';
        $temp->PasswordManage();//校验密码
       
        $errorinfo = $temp->errorinfo;//校验密码结果信息

        if(!empty($errorinfo[0])) {

            echo $errorinfo[0].'FI';

        } elseif($_REQUEST['confirmpasswordinfo']== null) {

            echo getFixedLabel('PMENTERCONFIRMPASSWORD').'SE';


        } elseif($_REQUEST['passwordinfo'] != $_REQUEST['confirmpasswordinfo'])

            echo getFixedLabel('PMINCONSISTENTPASSWORD').'SE';

        else {
            $_SESSION['USERPMLogin']='no';
            $current_user->change_password('', $_REQUEST['passwordinfo']);
			crm_load_function_file("createUserPrivilegesfile",'modules/Users','CreateUserPrivilegeFile');
            createUserPrivilegesfile($current_user->id);
            unset($_SESSION['USERPMLogin']);  
            //edit:can 20210416 单点登录->增加校验密码是否严格管理
            $sql='update ld_users set pwd_checkcondition=? where id=?';
            $adb->pquery($sql,array('no',$current_user->id));
            
            $sql='select user_password from ld_users where id=? ';
            $result=$adb->pquery($sql,array($current_user->id));
            $_SESSION[globalStatic::$root_directory.'user_password']=$adb->query_result($result,0,'user_password');
            
            echo 'user_name='.$current_user->user_name;
        }

    }
    
    exit;
}


?>