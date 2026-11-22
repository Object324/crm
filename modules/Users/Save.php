<?php


require_once('Register/RegOp.php');
//$log = LoggerManager::getLogger('index');


global $adb;
$user_name = $_REQUEST['userName'];
if(isset($_REQUEST['status']) && $_REQUEST['status'] != '')
	$_REQUEST['status']=$_REQUEST['status'];
else
	$_REQUEST['status']='Active';
/*
edit:can
date:20130403
reason:用户新增或修改判断用户数是否超过注册用户数

*/
if(isset($_REQUEST['register_check']) && $_REQUEST['register_check']=='yes')
{
    
            $user_query="select 1 from ld_users where status='active'";
                if(isset($_REQUEST['userid'])&& $_REQUEST['userid']>0)
                {
                    $user_query .=' and id!='.$_REQUEST['userid'];
                }
                $result=$adb->pquery($user_query);
                $strUsingCount=$adb->num_rows($result);
              
                if($_REQUEST['userStatus']=='Active'||!isset($_REQUEST['userid'])||$_REQUEST['userid']<=0)
                {
                     
                    $strUsingCount=$strUsingCount+1;
                   
                }
             
                 $reg=RegOp::getInstance();
                 $regCount=$reg->GetUserCount();
                 if($reg->compareCount($regCount,$strUsingCount)<=0)
                 {
                        echo getFixedLabel('USERSAVEREGISTER').$regCount.",".getFixedLabel('USERSAVEFAIL');
                        die;
                 }
               
                 
}
if(isset($_REQUEST['dup_check']) && $_REQUEST['dup_check'] !='')
{

		       
	        echo 'SUCCESS';
	        die;
	
}
$user_name=$_REQUEST['user_name'];
$user_query = "SELECT user_name FROM ld_users WHERE user_name =? and id<>?";

if(isset($_REQUEST["record"]))
    $user_result = $adb->pquery($user_query, array($user_name,$_REQUEST["record"]));
else
    $user_result = $adb->pquery($user_query, array($user_name,0));
        //$group_query = "SELECT groupname FROM ld_groups WHERE groupname =?";
        //$group_result = $adb->pquery($group_query, array($user_name));
        
if($adb->num_rows($user_result) > 0) {
		//	echo getFixedLabel('auserwiththesepecifiednamealreadyexists');
//			die;
$_REQUEST['diony']='yes';
ConvertTojsonString("-1",array(),getFixedLabel('auserwiththesepecifiednamealreadyexists'));

}
$versioninfo = getVersionInfo();
if($versioninfo['account'] == "zhongsi" && $versioninfo['trade'] == "zhongsiplatfrom"){
    $users_focus = CRMEntity::getInstance('Users');
    $users_moduleFields=$users_focus->fieldobj->getModuleFields();//成员管理模块字段
    $crm_url_label = $users_moduleFields['access_address']->getFieldLabel();

    $crm_url = $_REQUEST['access_address'];
    $user_query = "SELECT IP_Filename FROM ld_users WHERE IP_Filename =? and id<>?";

    $mode['mode'] = 'check';
    $url = $crm_url.'/crmapi/api_getAccountCertificate.php';
	require_once ("include/cls_UrlEncryptyJudge.php");
	$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
	$mode = $cls_UrlEncryptyJudgeobj->EncryptyBynosorturlparseQueryParamshavearr($url,$mode);
    $jsonData = json_encode($mode);

    $ch = curl_init(); // 初始化curl
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
    curl_setopt($ch, CURLOPT_HEADER, 0);
    curl_setopt($ch, CURLOPT_POST, 1);
    curl_setopt($ch, CURLOPT_TIMEOUT,5); //只需要设置一个秒的数量就可以
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
    curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, false); //不验证证书
    curl_setopt($ch, CURLOPT_POSTFIELDS, $jsonData);
    curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
    $crmurl_response = json_decode(curl_exec($ch),true); // 执行请求
    if(!empty($crm_url)){
        if (curl_errno($ch)) {
            ConvertTojsonString("-1",array($crmurl_response),$crm_url_label.getFixedLabel('CannotAccessedPleaseRefer').'https://www.51mis.com/crm');//crm地址无法访问
        } else {
            if(empty($crmurl_response)){
                ConvertTojsonString("-1",array($crmurl_response),$crm_url_label.getFixedLabel('CannotAccessedPleaseRefer').'https://www.51mis.com/crm');//crm地址无法访问
            }else{
                $access_address = $crmurl_response['result'];
            }
        }
    }
    curl_close($ch);

    if(isset($_REQUEST["record"]))
        $user_result = $adb->pquery($user_query, array($access_address,$_REQUEST["record"]));
    else
        $user_result = $adb->pquery($user_query, array($access_address,0));

    if($adb->num_rows($user_result) > 0) {
        $_REQUEST['diony']='yes';
        ConvertTojsonString("-1",array(),$crm_url_label.getFixedLabel('CannotEnteredRepeatedly'));//crm地址已被其他成员录入，无法重复录入
    }
    $receivable_total = $_REQUEST['receivable_total'];
    if(isset($_REQUEST['receivable_total']) && isset($_REQUEST["record"])){//编辑时若更改了客户领取总数，则更新“客户剩余领取数”
        $amount_sql = "SELECT receivable_total,receivable_remain FROM ld_users WHERE id =?";
        $update_sql='UPDATE ld_users set receivable_remain = ? where id= ?';
        $amount_result = $adb->pquery($amount_sql,array($_REQUEST["record"]));
        $tmp_total = $adb->query_result($amount_result,0,'receivable_total');
        $tmp_remain = $adb->query_result($amount_result,0,'receivable_remain');
        $total_diff = $receivable_total - $tmp_total;//取输入的总数与数据库中的总数差
        $tmp_remain = $tmp_remain + $total_diff;//更新“客户剩余领取数”
        $adb->pquery($update_sql,array($tmp_remain,$_REQUEST["record"]));
    }
}

//14946 控制面板>>用户管理：打开2个用户编辑界面，然后分别点击【保存】，结果有一个会提示没有权限。 || $_SESSION['Users_FORM_TOKEN'] !== (int)$_REQUEST['form_token'])
if(empty($_SESSION['Users_FORM_TOKEN']) && $_REQUEST['deleteImage'] != 'true' &&
		$_REQUEST['changepassword'] != 'true') {
	header("Location: index.php?action=Error&module=Users&error_string=".
			urlencode($app_strings['LBL_PERMISSION']));
	die;
}

if (isset($_POST['record']) && !is_admin($current_user) && isPermitted("Users", 'index','') == 'no' && $_POST['record'] != $current_user->id) echo ("Unauthorized access to user administration.");
elseif (!isset($_POST['record']) && isPermitted("Users", 'index','') == 'no' && !is_admin($current_user)) echo ("Unauthorized access to user administration.");

$focus = new Users();
if(isset($_REQUEST["record"]) && $_REQUEST["record"] != '')
{
    global $current_user;
    $focus->mode='edit';
	$focus->id = $_REQUEST["record"];
    if($_REQUEST['record']==$current_user->id&&isPermitted("Users",'EditView')=='no')
    {
       
        	$focus->retrieve_entity_info($_REQUEST['record'],'Users');
            $modulefields=$focus->fieldobj->getModuleFields();
            foreach($modulefields as $fieldname =>$fieldinfo)
            {
                if($fieldinfo->getProfileEditField()=='no')
                {
                    //个人用户允许编辑部分用户信息字段
                    $_REQUEST[$fieldname]=$focus->column_fields[$fieldname];
                }
            }
    }
   /** if($current_user->is_admin!='on')
    {
        
         * 更新操作
         * edit:can
         * date:20131130
         * reason:5752: 建议：个人设置页面：“职位级别”、“允许查看客户全景”这2个字段应该只有管理员用户能够编辑修改，非管理员用户应该不允许编辑
         
        $sql='select level,accountallview from ld_users where id=?';
        $useresult=$adb->pquery($sql,array($_REQUEST["record"]));
        $_REQUEST['level']=$adb->query_result($useresult,0,'level');
        $_REQUEST['accountallview']=$adb->query_result($useresult,0,'accountallview');
    }* */
    
}
else
{
    $focus->mode='';
}

//20240726 hzx XUQIU1001729 经销商用PRM成员管理设置
if(isset($_REQUEST['user_type']) && !empty($_REQUEST['user_type'])){
    $focus->setuser_type($_REQUEST['user_type']);
}

if($_REQUEST['deleteImage'] == 'true') {
	$focus->id = $_REQUEST['recordid'];
	$focus->deleteImage();
	echo "SUCCESS";
	exit;
}

if($_REQUEST['changepassword'] == 'true') {
	$focus->retrieve_entity_info($_REQUEST['record'],'Users');
	$focus->id = $_REQUEST['record'];
	if (isset($_REQUEST['new_password'])) {
		if (!$focus->change_password($_REQUEST['old_password'], $_REQUEST['new_password'])) {
			header("Location: index.php?action=Error&module=Users&error_string=".urlencode($focus->error_string));
			exit;
		}
	}
}	

//save user Image
if(! $_REQUEST['changepassword'] == 'true')
{
	if(strtolower($current_user->is_admin) == 'off' && isPermitted("Users", 'index','') == 'no'  && $current_user->id != $focus->id)
	{
	
		header("Location: index.php?module=Users&action=Logout");
		exit;
	}
	if(strtolower($current_user->is_admin) == 'off' && isPermitted("Users", 'index','') == 'no'  && isset($_POST['is_admin']) && strtolower($_POST['is_admin']) == 'on')
	{
		
		header("Location: index.php?module=Users&action=Logout");
		exit;
	}
	
	if (!isset($_POST['is_admin'])) $_REQUEST["is_admin"] = 'off';
	//Code contributed by mike crowe for rearrange the home page and tab
	if (!isset($_POST['deleted'])) $_REQUEST["deleted"] = '0';
	if (!isset($_POST['homeorder']) || $_POST['homeorder'] == "" ) $_REQUEST["homeorder"] = 'ILTI,QLTQ,ALVT,PLVT,CVLVT,HLT,OLV,GRT,OLTSO';
	if(isset($_REQUEST['internal_mailer']) && $_REQUEST['internal_mailer'] == 'on')
		$focus->column_fields['internal_mailer'] = 1;
	else
		$focus->column_fields['internal_mailer'] = 0;
	if(isset($_SESSION['internal_mailer']) && $_SESSION['internal_mailer'] != $focus->column_fields['internal_mailer'])
		$_SESSION['internal_mailer'] = $focus->column_fields['internal_mailer'];
        if($focus->id>0&&isPermitted("Users","AllowSetRoleDataProfile")=='no')
        {
            $focus->retrieve_entity_info($focus->id,"Users");
            $_REQUEST['profileid']=$focus->column_fields['profileid'];
            
            
        }
        
    setObjectValuesFromRequest($focus);
    require_once(globalStatic::$root_directory.'appCommon/appCommon.php');
    
    if(isKehu001ServerPc()=='yes'){
        $focus->column_fields['last_name']=$focus->column_fields['wx_userid'];
        
    }

	if(empty($focus->column_fields['profileid']) && !empty($_POST['user_role'])) {
		$focus->column_fields['profileid'] = $_POST['user_role'];
	}
        
    if(empty($focus->column_fields['approveby']))
    {
        $focus->column_fields['approveby']=0;
    }
    if(empty($focus->column_fields['scopeauthority']))
    {
        $focus->column_fields['scopeauthority']=1;
    }
    if(empty($focus->column_fields['level']))
    {
        $focus->column_fields['level']=0;
       
    }
    
	$focus->save("Users");
   
    if(isset($focus->column_fields['groupid'])&&$focus->column_fields['groupid'] !=''){
        $focus->insertUsersGroup($focus->column_fields['groupid'],$focus->id);
    
    }
    
    if($_REQUEST['status']=='Inactive'){
        //下拉框选择离职，员工状态变为离职，删除员工相关通讯录
        $sql='update ld_users set wx_userid = "" ,wx_openid = "",dingtalk_userid = "",yunzhijia_openid = "",yunzhijia_wbuserid ="",fanwei_userid ="",zhiyuan_userid =""
        where id= ? and status ="Inactive"';
        $adb->pquery($sql,array($focus->id));
    }
    if($versioninfo['account'] == "zhongsi"){
        if(isset($_REQUEST['access_address'])){//若有填写crm外网访问地址，则更新IP_Filename字段
            $sql='update ld_users set IP_Filename = ? where id= ?';
            $adb->pquery($sql,array($access_address,$focus->id));
        }
        if(isset($_REQUEST['receivable_total'])){//创建时若有客户领取总数，则更新“客户剩余领取数”
            if($_REQUEST['mode'] == 'create'){
                $update_sql='UPDATE ld_users set receivable_remain = ? where id= ?';
                $adb->pquery($update_sql,array($receivable_total,$focus->id));
            }
        }
    }

	$return_id = $focus->id;
 
    if (isset($_POST['user_name']) && isset($_POST['new_password'])&&$_POST['new_password']!='') {
    		$new_pass = $_POST['new_password'];
    		$new_passwd = $_POST['new_password'];
    		$new_pass = md5($new_pass);
    		$uname = $_POST['user_name'];
             
    		if (!$focus->change_password($_POST['confirm_new_password'], $_POST['new_password'])) {
    		
    			header("Location: index.php?action=Error&module=Users&error_string=".urlencode($focus->error_string));
    		exit;
    }
    }  
    /** Function to update user to group mapping based on the userid
      * @param $groupname -- Group Name:: Type varchar
      * @param $userid User Id:: Type integer
      *
     */
    function updateUsers2GroupMapping($groupname,$userid)
    {
   
      global $adb;
      $sqldelete = "delete from ld_users2group where userid = ?";
      $delparams = array($userid);
      $result_delete = $adb->pquery($sqldelete, $delparams);
    
      $sql = "insert into ld_users2group(groupname,userid) values(?,?)";
      $params = array($groupname,$userid);
      $result = $adb->pquery($sql, $params);
      
    }
    if(isset($focus->id) && $focus->id != '')
    {
      if(isset($_POST['group_name']) && $_POST['group_name'] != '')
      {
        updateUsers2GroupMapping($_POST['group_name'],$focus->id);
      }
    }
}

//duan 20220919 设置审批委托后，判断是否需要更新所有审批人
if(isset($_REQUEST['resetapprover'])&&$_REQUEST['resetapprover'] == 'yes'&&!empty($_REQUEST['approveby'])){
    $old_approver = $focus->id;
    $new_approver = $_REQUEST['approveby'];
    //避免出现特殊情况
    if(is_numeric($old_approver)&&$old_approver>0 &&is_numeric($new_approver)&& $new_approver>0){
        crm_load_class_file("ApproveCommon","modules/Approve");
        $approvecommonobj = ApproveCommon::getInstance('Users');
        //获取所有启用审批的模块
        $ApproveModuleInfo = $approvecommonobj->getApproveModuleInfo();
        $module_str = implode(',',$ApproveModuleInfo);
        $sql = " SELECT `name`,main_tablename,primary_key from ld_tab where FIND_IN_SET(`name`,?)";
        $result = $adb->pquery($sql,array($module_str));
        $num_rows = $adb->num_rows($result);
        for($i=0;$i<$num_rows;$i++){
            $tmp_module = $adb->query_result($result,$i,'name');
            $maintablename = $adb->query_result($result,$i,'main_tablename');
            $tableindex = $adb->query_result($result,$i,'primary_key');
            //更新日志中的审批人
            $sql_log = "UPDATE ld_approvelog 
                LEFT JOIN (SELECT max(id) as tmp_id FROM ld_approvelog GROUP BY crmid) as tmp_data 
                ON ld_approvelog.id = tmp_data.tmp_id
                SET nextstepapproveby = trim( ',' FROM
            		REPLACE (
            			CONCAT(',', nextstepapproveby, ','),
            			CONCAT(',' ,?, ','),
            			CASE 
            				when FIND_IN_SET(?,nextstepapproveby) THEN ',' 
            				ELSE CONCAT(',' ,?, ',')
            			END
            		)
                )
                where FIND_IN_SET(?,nextstepapproveby) 
                AND (IFNULL(tmp_id,0)>0 or ld_approvelog.isfinished = 'no')
                AND crmid IN (SELECT $tableindex from $maintablename where deleted =0 AND approvestatus = ?);";
            $adb->pquery($sql_log,array($old_approver,$new_approver,$new_approver,$old_approver,constant('D_A_S_APPROVALOF')));
            //更新单据中的审批人
            $sql_tab = "UPDATE $maintablename 
                SET currentapprover = trim(',' FROM
            		REPLACE (
            			CONCAT(',', currentapprover, ','),
            			CONCAT(',' ,?, ','),
            			CASE 
            				when FIND_IN_SET(?,currentapprover) THEN ',' 
            				ELSE CONCAT(',' ,?, ',')
            			END
            		)
                )
                where FIND_IN_SET(?,currentapprover) AND deleted = 0 AND approvestatus = ?;";
            $adb->pquery($sql_tab,array($old_approver,$new_approver,$new_approver,$old_approver,constant('D_A_S_APPROVALOF')));
        }
    }
}


if(isset($_POST['return_module']) && $_POST['return_module'] != "") $return_module = vtlib_purify($_REQUEST['return_module']);
else $return_module = "Users";
if(isset($_POST['return_action']) && $_POST['return_action'] != "") $return_action = vtlib_purify($_REQUEST['return_action']);
else $return_action = "DetailView";
if(isset($_POST['return_id']) && $_POST['return_id'] != "") $return_id = vtlib_purify($_REQUEST['return_id']);
if(isset($_REQUEST['activity_mode']))   $activitymode = '&activity_mode='.vtlib_purify($_REQUEST['activity_mode']);
if(isset($_POST['parenttab'])) $parenttab = getParentTab();

$profile = new Profile();
//Asha: Added Check to see if the mode is User Creation and if yes, then sending the email notification to the User with Login details.
if($_REQUEST['mode'] == 'create') {
	global $app_strings, $mod_strings, $default_charset;
	require_once('modules/Emails/mail.php');
    $user_emailid = $focus->column_fields['email1'];
	// send email on Create user only if NOTIFY_OWNER_EMAILS is set to true
	CreateUseLanguageType($focus);
	$subject = getFixedLabel('USERLOGINDETAILS');
	$email_body = getFixedLabel('MSG_DEAR')." ". $focus->column_fields['last_name'] .",<br><br>";
	$email_body .= getFixedLabel('LBL_PLEASE_CLICK') . " <a href='" . $site_URL . "' target='_blank'>"
									. getFixedLabel('LBL_HERE') . "</a> " . getFixedLabel('LBL_TO_LOGIN') . "<br><br>";
	$email_body .= getFixedLabel('USERNAME').'：' . $focus->column_fields['user_name'] . "<br>";
	$email_body .= getFixedLabel('PASWD') .'：' . $focus->column_fields['user_password'] . "<br>";
	$profileinfo = $profile->getProfileinfo($_REQUEST['profileid']);
	$email_body .= getFixedLabel('LBL_ROLE_NAME') . " : " . $profileinfo['profilename'] . "<br>";
	$email_body .= "<br>" . getFixedLabel('MSG_THANKS') . "<br>" . $current_user->user_name;
	$email_body = htmlentities($email_body, ENT_QUOTES, $default_charset);
   
    /**
     * AUTHOR:BY LD KEVIN
     * DATE:2013-04-26
     * DESPRITION:新增用户时，发送邮件不成功
     */ 
    $sql="select * from ld_systems where server_type = ?";
	$records=$adb->num_rows($adb->pquery($sql, array('email')),0,"id");    
	if($records != ''){
	  
	   $sender=$adb->query_result($adb->pquery($sql, array('email')),$i,'server_username'); 
         // $mail_status = send_mail('Users',$user_emailid,$HELPDESK_SUPPORT_NAME,$sender,$subject,$email_body,'','','','','',$sender);
    	
        if($mail_status != 1) {
    		$mail_status_str = $user_emailid."=".$mail_status."&&&";		
    		$error_str = getMailErrorString($mail_status_str);
    	}       		
	} 
  
	
}
if(empty($_REQUEST['blockidsetting']) && empty($_REQUEST['fieldidsetting'])){
	$location = "Location: index.php?action=".vtlib_purify($return_action)."&module=".vtlib_purify($return_module)."&record=".vtlib_purify($return_id);
}else{
	$location = "Location: index.php?action=".vtlib_purify($return_action)."&module=".vtlib_purify($return_module)."&record=".vtlib_purify($return_id)."&blockidsetting=".$_REQUEST['blockidsetting']."&fieldidsetting=".$_REQUEST['fieldidsetting'];
}

/*if($_REQUEST['modechk'] != 'prefview') {
	$location .= "&parenttab=".vtlib_purify($parenttab);
}*/

if ($error_str != '') {	
    $user = $focus->column_fields['user_name'];
	$location .= "&user=$user&$error_str";
}

$cachekey = 'cache_getusercachenameinfo';
unsetCache($cachekey);

$focus->ReturnAfterSave(array());
//header($location);
?>