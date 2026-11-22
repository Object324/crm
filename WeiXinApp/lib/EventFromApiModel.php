<?php

/**
 * Created by PhpStorm.
 * User: gyq_47
 * Explain:eventFromApi模型
 * Date: 2017/11/20 0020
 * Time: 下午 3:26
 */
class EventFromApiModel
{
    public $m_rootdir;
    public $m_adb;
    //打卡信息上次同步时间
    public $checkin_sync_time;

    public function __construct()
    {
        $this->m_rootdir = dirname(dirname(dirname(__FILE__))) . '/';
    }

    public function setAdb($rAdb)
    {
        $this->m_adb = $rAdb;
    }

    //暂只出现在注册定制化有CRM的情况
    public function setInfoType($rInfoType, $rAuthInfo)
    {

        if ($rInfoType == 'register_corp') {//注册定制化  更新用户微信账号
            $user_createid = $rAuthInfo['user_createid'];
            $auth_user_name = $rAuthInfo['auth_user_name'];
            // include($this->m_rootdir . 'includefile.php');
            global $adb;
            //初始化微信ID       Eidtor:gyq Reason:不应该初始化用户状态 Date:2018/3/8 0008 下午 3:40
            //0033194: 在官网点击【无企业微信】，注册并绑定了CRM账套。CRM的成员管理同步到了企业微信通信录。但是没有邀请成功时，CRM系统成员管理，状态显示为“离职”
            /*$sql = "UPDATE ld_users SET wx_userid = '',status='Inactive'";
            $adb->pquery($sql, array());*/
            $user_createid_arr = json_decode($user_createid, true);
            foreach ($user_createid_arr as $username => $id) {
                if ($username == $auth_user_name) {
                    continue;
                }
                $sql = "UPDATE ld_users SET wx_userid=? WHERE id=?";
                $params = array($username, $id);
                $adb->pquery($sql, $params);
            }
            //授权人对应当时填URL界面的用户密码
            $userid = $rAuthInfo['auth_user_info']['userid'];
            $sql = "UPDATE ld_users SET wx_userid=? WHERE user_name=?";
            $params = array($userid, $auth_user_name);
            $adb->pquery($sql, $params);
            return false;
            /*
            $name =$rAuthInfo['auth_user_info']['name'];
            $sql = 'SELECT id,last_name,user_name,status FROM ld_users WHERE wx_userid=\''.$userid.'\'';
            if(!empty($mobile)){
                $sql .=  " OR phone_mobile ='$mobile' ";
            }
            if(!empty($email)){
                $sql .=  " OR email1='$email' ";
            }
            $sql .= ' LIMIT 1';

            $result = $adb->pquery($sql, array());
            $num_rows=$adb->num_rows($result);
            if($num_rows>0){
                $id=$adb->query_result($result,0,'id');
                $last_name=$adb->query_result($result,0,'last_name');
                $sql = "UPDATE ld_users SET wx_userid=? WHERE id=?";
                $params = array($userid, $id);
                $adb->pquery($sql, $params);
            }else{
                include(globalStatic::$root_directory . 'crmapi/modules/Cloud_Users_api.php');
                $clude = new Cloud_Users_api();
                $clude->saveSingleUser($userid,$name,1);
            }*/
        }
    }

    //gyq_51
    public function crmLogin($wx_userid)
    {
        $adb = $this->m_adb;
      
        $sql = 'SELECT id,last_name,user_name,status FROM ld_users WHERE wx_userid = ? LIMIT 1';
        $result = $adb->pquery($sql, array($wx_userid));
        $userid = $adb->query_result($result, 0, 'id');
        $status = $adb->query_result($result, 0, 'status');
        $user_name = $adb->query_result($result, 0, 'user_name');
        $rows = $adb->num_rows($result);
        $current_url = $_SERVER['HTTP_HOST'] . $_SERVER['REQUEST_URI'];

		
        if ($rows == 1) {

         //   file_put_contents($this->m_rootdir."dataCache/ty.txt","$user_name:".$user_name,":wxid:".$wx_userid.";status:".$status."\n\n",FILE_APPEND);

            if ($status == 'Inactive') {//languageType='.$_REQUEST['languageType']
                $deal_url = 'http://' . substr($current_url, 0, strrpos($current_url, 'WeiXinApp') - 1) . '/index.php?languageType=' . $_REQUEST['languageType'] . '&weixinloginerror=登录失败,您绑定的CRM用户已停用';
                header('location:' . $deal_url);
            } else {
                $deal_url = substr($current_url, 0, strrpos($current_url, 'WeiXinApp') - 1);
                require_once('cls_dandian.php');
                $shakey=base64_encode(md5($user_name.strtotime(date("Y-m-d H:i:s")))) ;
                
                $objdandian = new cls_dandian($user_name);
                $deployvalues=getSys_deploy(105);
                $secretKey = $deployvalues['deploy_value'];
                $timestamp = time();//加密key使用的时间戳
                $encryptedKey = $objdandian->getencryptedKeybykey($secretKey,$timestamp);
                $temporaryToken = $objdandian->setgenerateTokenbyencryptedkey($encryptedKey);
                $encryptusername = $objdandian->ldencryptstring($user_name,$timestamp,false);
                //Eidtor:gyq Reason:增加bodywidth参数 Date:2018/5/4 0004 下午 1:23
                //editor:gyq_20190116 0036175: （kehu001）扫码登录后按钮都挤在一起来了。
                if (empty($_REQUEST['bodywidth'])) {
                    $_REQUEST['bodywidth'] = 1366;
                }
                 $slhttp = ((isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] == 'on') || (isset($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] == 'https')) ? 'https://' : 'http://';
				 include_once($this->m_rootdir . '/appCommon/appCommon.php');
				 $authinfo_arr=json_decode(doCorpInfo('get_auth_info',[]),true);
                if($slhttp!='https://'&&is_array($authinfo_arr)&&array_key_exists( 'corpurl', $authinfo_arr['crm'] ))
				{
					if(stripos($authinfo_arr['crm']['corpurl'],'https:')!==false)
					{
						$slhttp='https://';
						
					}
				}
                //duan 20240829 因为可能存在代理服务器的原因，所以在直接获取crm路径时有问题，需要额外配置路径
                global $global_base_crm_url;
                if(!empty($global_base_crm_url)){
                    $base_crm_url = $global_base_crm_url;
                }else{
                    $base_crm_url = $slhttp . $deal_url;
                }
                if($base_crm_url[strlen($base_crm_url)-1] == '/'){
                    $base_crm_url = rtrim($base_crm_url,'/');
                }

                $corp_link = $base_crm_url . '/index.php?module=Users&action=Authenticate&temporary_token=' . $temporaryToken . '&timestamp=' . $timestamp . '&bodywidth=' . $_REQUEST['bodywidth'] . '&dandian_weixin=true';
                if(isset($_REQUEST['qrcode'])&&$_REQUEST['qrcode']=='yes')
                {
                    $corp_link.='&qiyeweixinqrcode=yes';
                    
                }
                
                //edit:can 20220223 49995: （https://www.cubenergy.com.cn/crm/ [^]）客户问题（库博能源），企业微信PC端，从消息提醒界面点击【进入首页】，界面报错
                if($slhttp=='http://'&&file_exists(globalStatic::$root_directory.'dataCache/weixin/auth_info.txt'))
				{
					$weixininfo_arr=json_decode(getWeiXinAuthInfo(),true);
				}
				if(is_array($weixininfo_arr)&&stripos($weixininfo_arr['crm']['corpurl'],'https://')!==false)
				{
					$slhttp='https://';
						
				}
				 
                
                header('location:' . $corp_link.'&shakey='.$shakey);
            }
        } else {
            /*若没有绑定CRM账号，则返回到登录界面，再弹出提示信息【请先绑定企业微信】，英文标签【Please bind enterprise WeChat first】*/
            if ($_REQUEST['languageType'] == 'en') {
                $remind = 'Please bind enterprise WeChat first';
            } else {
                // $remind = '请先绑定企业微信';
                //0033020: 企业微信后台点击前往服务商后台，转到crm登录界面提示请先绑定企业微信。（已经绑定过企业微信了）
                $remind = '请登录企业微信APP，进入灵当CRM应用绑定CRM账号';
            }
             $slhttp = ((isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] == 'on') || (isset($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] == 'https')) ? 'https://' : 'http://';

                
              //  $corp_link = $slhttp . $deal_url . '/index.php?module=Users&action=Authenticate&name=' . $username . '&timetoken=' . $timetoken . '&tokename=' . $tokenname . '&bodywidth=' . $_REQUEST['bodywidth'] . '&dandian_weixin=true';
              
              
            $deal_url = $slhttp . substr($current_url, 0, strrpos($current_url, 'WeiXinApp') - 1) . '/index.php?languageType=' . $_REQUEST['languageType'] . '&weixinloginerror=' . $remind;
            header('location:' . $deal_url);
        }
    }

    public function changeAuth($r_result)
    {
        //调试BUG用缓存文件

        /*$rResult = json_decode(file_get_contents($this->m_rootdir.'WeiXinApp/qwe.txt'),true);*/
      
        global $adb;
        //初始化全局变量
        $_REQUEST['changetype'] = 'create_user';//绕过user_special判断
        $_REQUEST['sessionrand'] = md5('569HuQv' . strtotime(date("Y-m-d H:i:s")));
        //初始化公海缓存 reason:清除公海缓存，方便邀请或变更得来的新用户，不手动清缓存序时簿也可以显示出公海标签
        $cache_account_setting = Cache('account_set');
        if (!empty($cache_account_setting) && isset($cache_account_setting['usersaccount'])) {
            unset($cache_account_setting['usersaccount']);
            Cache('account_set', $cache_account_setting);
        }
        //初始化用户状态 reason:0032488: 企业微信授权：更改授权范围，会导致授权人在CRM成员管理中出现两次，并且admin被停用
        $sql = "UPDATE ld_users SET status = 'Inactive' ";
        $adb->pquery($sql, array());
        //***********逻辑代码正式开始**************
        $r_departmentlist = $r_result['department_list'];
        $r_user_list = $r_result['user_list'];
        //授权安装时，由于接口中没传，故没有下面这两个键值department_corpname_check single_user_list
        $r_corpname_check = $r_result['department_corpname_check'];
        $r_single_user_list = $r_result['single_user_list'];

        //给成员管理员信息赋值，不更新管理员字段
        foreach ($r_user_list as $key => $content) {
            $sql = 'SELECT id,user_name,last_name,status,is_admin,groupid from ld_users WHERE wx_userid=?';
            $result = $adb->pquery($sql, array($content['userid']));
            $rows = $adb->num_rows($result);
            if ($rows > 0) {
                $r_user_list[$key]['crm_user_name'] = $adb->query_result($result, 0, 'user_name');
                //0034505: 客户001账套，企业微信中灵当CRM应用变更可见范围后，不同步管理员。仅首次授权应用时同步管理员至CRM系统。
                $r_user_list[$key]['is_admin'] = $adb->query_result($result, 0, 'is_admin');
            }
        }
        //若部门同步为空，赋初值【推测这段为多余判断，可删】
        if (empty($r_departmentlist)) {
            $sql = 'SELECT groupname from ld_groups WHERE parentid=-1 limit 1';
            $result = $adb->pquery($sql, array());
            $rows = $adb->num_rows($result);
            if ($rows > 0)
                $groupname = $adb->query_result($result, 0, 'groupname');
            $r_departmentlist[] = array(
                'id' => 1, 'name' => $groupname, 'parentid' => 0, 'order' => 100000000
            );
        }

        //同步部门
        $department_result = $this->txl_group_operation($r_departmentlist,$r_corpname_check);

        //可见范围无部门独立成员，特殊新增部门
        if(!empty($r_single_user_list))
            $this->txl_alone_user_group_update($department_result,$r_single_user_list);
        //可见范围包含根部门,缓存部门树
        if ($r_corpname_check > 0) {
            $department_sql_del = 'delete from ld_wx_config where name=?';
            $adb->pquery($department_sql_del, array('department_list'));
            $department_sql = 'insert into ld_wx_config (name, description, para_one) value (?,?,?)';
            $adb->pquery($department_sql, array('department_list', '企业微信通讯录部门树', json_encode($department_result)));
        }
      //  file_put_contents( $this->m_rootdir ."storage/user.txt","dataa:".json_encode($r_user_list)."\n\n",FILE_APPEND);


        //同步成员
        $this->txl_user_operation($r_user_list);

       // file_put_contents( $this->m_rootdir ."storage/user.txt","datah:".json_encode($r_user_list)."\n\n",FILE_APPEND);

    }

    public function marketAuth()
    {
        global $adb;
        include_once($this->m_rootdir . 'WeiXinApp/WeiXin_common/cls_WeixinPort.php');
        $o_port = new cls_WeixinPort();
        $weixin_callback_orign = $_POST['weixin_callback'];

      //  $weixin_callback = json_decode(file_get_contents($this->m_rootdir . 'dataCache/weixin/auth_info_all.txt'), true);
        $weixin_callback=json_decode(json_encode($weixin_callback_orign),true);
      
        //$weixin_callback = $_POST['weixin_callback'] = json_decode(file_get_contents(globalStatic::$root_directory.'dataCache/weixin/auth_info_all.txt'),true);
        $auth_info = $weixin_callback['auth_info'];
        $department_list = $weixin_callback['department_list'];
        $user_list_orign = $weixin_callback['user_list'];

        if($auth_info['auth_info']['agent'][0]['auth_mode']==1)
        {
            //普通用户授权
            $admin_wx_userid = $auth_info['auth_user_info']['userid'];
            $_REQUEST['admin_wx_userid']=$admin_wx_userid;
            
        }
        else
            $_REQUEST['admin_wx_userid'] = $admin_wx_userid = $auth_info['auth_user_info']['userid'];
        $key_exist = array_filter($user_list_orign, function ($rT) use ($admin_wx_userid) {
            return $rT['userid'] == $admin_wx_userid;
        });

        /*0033208: 成员太多时间，企业微信授权出现问题
        Eidtor:gyq_64 Date:2018/3/12 0012 上午 11:16
        Reason:判断授权人是否在可见范围，若不再，在用户数组第一位加入授权人，若在，则将授权人的用户信息放到数组第一位 */
        if (!$key_exist) {
            $auth_user_created = array(
                'userid' => $admin_wx_userid,
                'name' => $auth_info['auth_user_info']['name'],
                'department' => array(1),
                'avatar' => $auth_info['auth_user_info']['avatar'],
                'status' => 1
            );
            $user_list = array_merge(array($auth_user_created), $user_list_orign);
        } else {
            $key_num = array_keys($key_exist)[0];
            unset($user_list_orign[$key_num]);
            $user_list = array_merge($key_exist, $user_list_orign);
        }
        $getWeiXinAuthInfoParams=array();
        $getWeiXinAuthInfoParams['root_directory']=$this->m_rootdir;
        $exist_auth_info = getWeiXinAuthInfo($getWeiXinAuthInfoParams);

        $exist_auth_arr = json_decode($exist_auth_info, true);

        if (empty($exist_auth_arr)) {
            $exist_auth_arr = array();
        }
        $suitename_arr = array(StaticConst::$suite_crm, StaticConst::$suite_app, StaticConst::$suite_txl);
        foreach ($exist_auth_arr as $key => $val) {
            if (!in_array($key, $suitename_arr)) {
                unset($exist_auth_arr[$key]);
            }
        }
        //editor:gyq_110 reason:授权时，auth_info中的首位key应固定赋值为crm  2019/5/15 10:39
        $exist_auth_arr[StaticConst::$suite_crm] = $auth_info;

        file_put_contents($this->m_rootdir . 'dataCache/weixin/auth_info.txt', encryptStringByLabel(json_encode($exist_auth_arr),'auth_info'));
        //保存部门
        $nowtime = strtotime(date("Y-m-d H:i:s"));
        $_REQUEST['sessionrand'] = md5('569HuQv' . $nowtime);

        $_POST['department'] = json_encode($department_list);

        require_once($this->m_rootdir . 'wxApi/GroupOperation.php');

        $_POST['user_list'] = $user_list;//post被异常清空
//保存用户
        $_REQUEST["module"] = "Cloud_Users";
        $_REQUEST["func"] = "changeAuthForUser";
        require($this->m_rootdir ."crmapi/ApiAuthenKey.php");
        $apikeyobj=new ApiAuthenKey();
        $keyToken_arr=  $apikeyobj->getnewToken("marketAuth");
        $_REQUEST['apikey']=$keyToken_arr['apikey'];
        $_REQUEST['token']=$keyToken_arr['token'];;
        $_REQUEST['changetype'] = 'create_user';//绕过user_special判断
        include($this->m_rootdir . 'crmapi/crmoperation.php');

        /*************Eidtor:gyq Reason:临时改动 Date:2018/3/9 0009 下午 5:15****************/
        $this->marketAuth_SaveCompanyInfo($weixin_callback, $o_port);
        $this->createDefaultData($auth_info, 1);
        /*****************************/

    }

    public function createDefaultData($rAuthinfo, $rUserid)
    {
        //  $filehandler=fopen(globalStatic::$root_directory.'WeiXinApp/lib/1.txt','w+');
        // fwrite($filehandler,$_REQUEST['firstauthen']);
        // fclose($filehandler);
        if ($_REQUEST['firstauthen'] != 'yes') {

            return false;
        }

        $rUserid = 1;
        cls_StaticCommonFun::initUserPrivileges($rUserid);
        global $current_user;
        $current_user->id = 1;
        $module = 'Accounts';
        $main_fieldname = 'accountname';
        $main_fieldvalue = '模拟客户（' . $rAuthinfo['auth_corp_info']['corp_name'] . '）';
        // $result = judgeFieldDuplicate($module,$main_fieldname,$main_fieldvalue,null);

        $account_focus = CRMEntity::getInstance($module);
        $account_focus->column_fields['rating']='潜在客户';
        
        $account_focus->column_fields[$main_fieldname] = $main_fieldvalue;
        $account_focus->column_fields['servicecasher'] = $rUserid;//服务收费人
        $account_focus->column_fields['assigned_user_id'] = $rUserid;
        $account_focus->save($module);
        $account_id = $account_focus->id;

        //联系人
        $module = 'Contacts';
        $main_fieldname = 'lastname';
        $main_fieldvalue = '模拟联系人（' . $rAuthinfo['auth_user_info']['name'] . '）';
        $focus = CRMEntity::getInstance($module);
        $focus->column_fields[$main_fieldname] = $main_fieldvalue;

        $focus->column_fields['mobile'] = $_REQUEST['mobile'];
        $focus->column_fields['email'] = $_REQUEST['email'];
        $focus->column_fields['assigned_user_id'] = $rUserid;
        $focus->column_fields['reference'] = 1;
        $focus->column_fields['account_id'] = $account_id;
        $focus->save($module);

        //产品
        $module = 'Products';
        $main_fieldname = 'productname';
        $main_fieldvalue = '模拟产品（灵当CRM）';
        $focus = CRMEntity::getInstance($module);
        $focus->column_fields[$main_fieldname] = $main_fieldvalue;
        $focus->column_fields['assigned_user_id'] = $rUserid;
        $focus->save($module);

    }

    public function marketAuth_SaveCompanyInfo($rInfo, $rPort)
    {
        global $adb;
        $address = $rInfo['corpurl'];
        $auth_info = $rInfo['auth_info']['auth_corp_info'];
        $corp_name = $auth_info['corp_full_name'];
        if (empty($corp_name))
            $corp_name = $auth_info['corp_name'];
        $logo_url = $auth_info['corp_square_logo_url'];
        //$logo_url= 'http://p.qlogo.cn/bizmail/7XlC1f88KgFRKmmJSUFqAfHt4OvdjCKMv5OibNqCrpvyjAstcOjpbqg/0';
        //0033013: 企业微信授权：当设定的查看范围中一个人都没有的时候，授权后logo没有改变，也没有添加模拟数据
        //0033047: 在pc端管理后台更改企业logo后，对应的pc端不会同步更改。
        
        //edit:can 20220427 ID1002635】 001账套系统预置菜单显示优化
    //    exec('rm -Rf ' . $this->m_rootdir . 'dataCache/test/logo/logo_wx.png');
      //  $rPort->curlDownLoadUrl($logo_url, $this->m_rootdir . "dataCache/test/logo/logo_wx.png");
        /*$sql = "SELECT * FROM ld_organizationdetails";
        $result = $adb->query($sql);
        $num_rows = $adb->num_rows($result);
        $organization_id = $adb->query_result($result, 0, 'organization_id');
        if (!$num_rows) {
            $organizationId = $adb->getUniqueID('ld_organizationdetails');
            $sql = "INSERT INTO ld_organizationdetails (organization_id,organizationname, logoname,address) values (?,?,?,?)";
            $params = array($organizationId, $corp_name, 'logo_wx.png', $address);
        } else {
            $sql = "UPDATE ld_organizationdetails SET organizationname = ?,logoname = ?,address=? WHERE organization_id = ?";
            $params = array($corp_name, 'logo_wx.png', $address, $organization_id);
        }
        $adb->pquery($sql, $params);*/
        
    }

    protected function changenumtoalpha($num)
    {
        $arr = array(
            1 => 'a',
            2 => 'b',
            3 => 'c',
            4 => 'd',
            5 => 'e',
            6 => 'f',
            7 => 'g',
            8 => 'h',
            9 => 'i',
            0 => 'j'
        );
        $str = '';
        for ($i = 0; $i < strlen($num); $i++) {

            $ch = substr($num, $i, 1);
            $str .= $arr[$ch];
        }
        return $str;

    }

    //editor:gyq_109 reason:变更可见范围部门同步修改 ，参考GroupOperation.php 2019/4/18 14:03
    public function txl_group_operation($r_departmentlist,$r_corpname_check)
    {
        global $adb;
        $bol = false;
        $sessionrand = $_REQUEST['sessionrand'];
        $nowtime = strtotime(date("Y-m-d H:i:s"));
        $what = $nowtime - 10;
        for ($what; $what <= $nowtime; $what++) {
            if (md5('569HuQv' . $what) == $sessionrand) {
                $bol = true;
                break;
            }
        }

        if (!$bol)
            exit('参数错误');
        //**********旧代码结束***********
        require_once(globalStatic::$root_directory . 'modules/Users/Group.class.php');
        $groupobj = new Group();//1114

        $groupobj->deleteAllGroup();

        require_once(globalStatic::$root_directory . 'appCommon/include/cls_tree.php');
        $departments = ClassTree::getCateTree($r_departmentlist);

        $output_departments = array();
        foreach ($departments as $index => $departinfo) {
            $output_departments[$departinfo['id']] = $departinfo;
            $wxgroupid = $departinfo['id'];
            $wxgroupname = $departinfo['name'];
            $wxparentid = $departinfo['parentid'];
            $_REQUEST['wxgroupid'] = $wxgroupid;
            $_REQUEST['groupid'] = 0;
            if ($wxparentid == 0) {
                $wxparentid = '-1';
                $_REQUEST['groupid'] = 1;
            }
            $_REQUEST['description'] = '';
            $_REQUEST['parentid'] = $wxparentid;
            $_REQUEST['groupname'] = $wxgroupname;

            $groupTree[$wxgroupid] = $groupobj->save($_REQUEST);

           // $sql = 'update ld_groups set wxgroupid=? where groupid=?';
          //  $adb->pquery($sql, array($wxgroupid, $groupTree[$wxgroupid]));
        }

        return $output_departments;
    }
    //可见范围中单独用户，为其额外增加部门树
    public function txl_alone_user_group_update($r_departmentlist,$r_single_user_list)
    {
        global $adb;
        //待增加部门
        $department_list_add = array();
        //0035702: 企业微信管理后台>灵当CRM>修改可见范围：如果可见范围中只勾选了成员没有勾选部门的话，同步到CRM成员管理时，成员的所属部门自动同步为根部门。
        if (!empty($r_single_user_list)) {
            //当前部门树 $r_departmentlist
            //数据库存储的完整部门树
            $department_list_cache = array();
            $department_sql = 'select para_one from ld_wx_config where name=?';
            $result = $adb->pquery($department_sql, array('department_list'));
            if($adb->num_rows($result) > 0){
                $department_list_cache = Zend_Json::decode( $adb->query_result($result,0,'para_one'));
                foreach ($r_single_user_list as $key => $value) {
                    $user_departs = $value['department'];
                    foreach ($user_departs as $key=>$value){
                        if(!array_key_exists($value,$r_departmentlist) && !empty($department_list_cache[$value])){
                            $department_list_add[$value] = $department_list_cache[$value];
                        }
                    }
                }
            }
        }
        $bol = false;
        $sessionrand = $_REQUEST['sessionrand'];
        $nowtime = strtotime(date("Y-m-d H:i:s"));
        $what = $nowtime - 10;
        for ($what; $what <= $nowtime; $what++) {
            if (md5('569HuQv' . $what) == $sessionrand) {
                $bol = true;
                break;
            }
        }
        if (!$bol)
            exit('参数错误');
        require_once(globalStatic::$root_directory . 'modules/Users/Group.class.php');
        $groupobj = new Group();//1114
        if(!empty($department_list_cache)){
            foreach ($department_list_cache as $index => $departinfo) {
                $wxgroupid = $departinfo['id'];
                $wxgroupname = $departinfo['name'];
                $wxparentid = $departinfo['parentid'];
                $_REQUEST['wxgroupid'] = $wxgroupid;
                $_REQUEST['groupid'] = 0;
                if ($wxparentid == 0) {
                    $wxparentid = '-1';
                    $_REQUEST['groupid'] = 1;
                }
                $_REQUEST['description'] = '';
                $_REQUEST['parentid'] = $wxparentid;
                $_REQUEST['groupname'] = $wxgroupname;
                $groupTree[$wxgroupid] = $groupobj->save($_REQUEST);
                $sql = 'update ld_groups set wxgroupid=? where groupid=?';
                $adb->pquery($sql, array($wxgroupid, $groupTree[$wxgroupid]));
            }
        }
        return null;
    }
    //editor:gyq_109 reason:变更可见范围用户同步修改 ，参考Cloud_Users_api.php 2019/4/18 14:03
    public function txl_user_operation($r_user_list)
    {
        global $adb;
        //将系统管理员身份的成员优先同步 Start  editor:gyq_73 date:20180712 reason：成员同步速度优化
        $admin_arr = array();
        foreach ($r_user_list as $key => $value) {
            if ($value['is_admin'] == 'on') {
                $admin_arr[] = $value;
                unset($r_user_list[$key]);
            }
        }
        $user_list = array_merge($admin_arr, $r_user_list);
        //file_put_contents($this->m_rootdir.'WeiXinApp/lib/qwe.txt',"\r\n\r\nF1;",FILE_APPEND);
        //将系统管理员身份的成员优先同步 End
        require_once globalStatic::$root_directory . 'modules/Users/CreateUserPrivilegeFile.php';
        crm_load_class_file('UsersSync', 'WeiXinApp/modules/Users');

        $sql = "SELECT
                CASE
                    WHEN EXISTS (SELECT 1 FROM ld_profile WHERE profileid=12) THEN 12
                    WHEN EXISTS (SELECT 1 FROM ld_profile WHERE profileid NOT IN (1,12)) THEN
                        (SELECT profileid FROM ld_profile WHERE profileid NOT IN (1,12) LIMIT 1)
                    WHEN NOT EXISTS (SELECT 1 FROM ld_profile WHERE profileid>1) THEN 1
					ELSE 0
                END AS profileid";
        $result = $adb->pquery($sql, array());
        if ($adb->num_rows($result) > 0) {
            $seller_profileid = $adb->query_result($result, 0, 'profileid');
        }

        $nowtime = strtotime(date("Y-m-d H:i:s"));
        $_REQUEST['sessionrand'] = md5('iK123' . $nowtime);
        $_REQUEST['scopeauthority'] = 1;//个人
        $_REQUEST['seller_profileid'] = $seller_profileid;//个人
        $firstauthen = 'no';
        //@edit:zhaosk @date:2024/10/21 @reason:XUQIU1001877 企业微信 wx_corp 表增加记录不加密的 corpid
        $getWeiXinAuthInfoParams=array();
        $getWeiXinAuthInfoParams['root_directory']=$this->m_rootdir;
        $authInfo_arr=json_decode(getWeiXinAuthInfo($getWeiXinAuthInfoParams), true);

        $sql = "select id,wx_userid from ld_users where id=1 and ifnull(wx_userid,'')=''";
        $result = $adb->pquery($sql, array());
        if ($adb->num_rows($result) > 0) {
            $firstauthen = 'yes';
            if($authInfo_arr['crm']['auth_info']['agent'][0]['auth_mode']==1&&!empty($admin_arr))
            {
                $_REQUEST['admin_wx_userid']=$admin_arr[0]['userid'];
            }
        }

        foreach ($user_list as $key => $value) {
            $UserArr = array();
            if (!empty($value['crm_user_name'])) {//暂只出现在更新用户信息  用户的用户名
                $UserArr['user_name'] = $value['crm_user_name'];
            } else {
                $UserArr['user_name'] = $value['userid'];
            }
            //暂只出现在更新用户信息  用户头像    editor:gyq date:20180703 reason:微信接口已不再提供头像信息
            /*if(!empty($value['avatar'])){
                $UserArr['sync_wx_headerimage_url'] = $value['avatar'];
            }*/
            if (isset($value['status'])) {
                if ($value['status'] == 2 || $value['status'] == 4) {//  激活状态：1=激活或关注， 2=禁用， 4=退出企业（退出企业并且取消关注时触发）
                    $UserArr['status'] = 'Inactive';
                } else {
                    $UserArr['status'] = 'Active';
                }
            } elseif ($_REQUEST['changetype'] == 'create_user') {//微信管理后台通讯录中，带邀请标志的成员，其新增事件不会携带status参数
                $UserArr['status'] = 'Inactive';
            }
            if (!empty($value['name'])) {//用户姓名	0033653: （客户001帐套）成员管理，当一个用户是离职状态，修改部门又变成在职状态了
                //	0032974: 企业微信：在企业微信中邀请用户，用户未加入之前，在CRM系统看成员管理，用户姓名显示为空白
                $last_name = filterEmoji($value['name']);
                if (empty($last_name)) $last_name = $UserArr['user_name'];
                $UserArr['last_name'] = $last_name;
            }

            if (!empty($value['department'])) {//用户部门
                $UserArr['groupid'] = implode(',', $value['department']);//1114
            }
            if (!empty($value['is_admin'])) {//用户是否是管理员 只在授权时有此参数
                $UserArr['is_admin'] = $value['is_admin'];
            }

            $UserArr['wx_userid'] = $value['userid'];//admin_wx_userid 授权人的微信ID
            if ($value['userid'] == $_REQUEST['admin_wx_userid'] && !empty($_REQUEST['admin_wx_userid'])) {
            
                $UserArr['is_admin'] = 'on';
                //	0033013: 企业微信授权：当设定的查看范围中一个人都没有的时候，授权后logo没有改变，也没有添加模拟数据
                $UserArr['status'] = 'Active';
                if ($firstauthen == 'yes'&&!empty($admin_arr))//如果第一次授权
                {
                    $sql = 'update ld_users set user_name=? where id=1 and ( user_name is null or user_name="")';
                        $adb->pquery($sql, array('admin'));
                    $UserArr['user_name'] = 'admin';
                }

                $_REQUEST['auth_admin_userid'] = $this->txl_user_save($UserArr);
            } else {
                $userobj_id = $this->txl_user_save($UserArr);
            }

            //微信帐号(newuserid)由系统生成，只允许修改一次。	0032579: 企业微信：修改微信用户ID，没有做处理（目前会新增一个用户）
            if (!empty($value['newuserid'])) {
                $sql = 'update ld_users set user_name=?,wx_userid=?,wx_userid_old=? where id=?';
                $adb->pquery($sql, array($value['newuserid'], $value['newuserid'], $value['userid'], $userobj_id));
                createUserPrivilegesfile($userobj_id);
            }

        }

        $_REQUEST['firstauthen'] = $firstauthen;
        if ($firstauthen == 'yes'&&!empty($admin_arr))//如果管理员第一次授权
        {
            //一定要放在保存之前，因为要更新user_privileges
            
                $sql = 'update ld_users set user_name=wx_userid where id=1 and user_name=?';
                $adb->pquery($sql, array('admin'));
            
            createUserPrivilegesfile(1);
        }
    }
    //txl_user_operation 子方法
    public function txl_user_save($rUserArr)
    {
        global $adb;

        foreach ($rUserArr as $key => $value) {
            $_REQUEST[$key] = $value;
        }
        $sql = 'select id,wx_userid from ld_users where user_name=?';
        $result = $adb->pquery($sql, array($_REQUEST['user_name']));
        //editor:gyq_20180814  避免批量保存时粘带上一个循环中userobj的值
        //file_put_contents( $this->m_rootdir ."storage/user1.txt","datab:\n\n",FILE_APPEND);
        $userobj = new UsersSync();

        if ($adb->num_rows($result) > 0) {
            $userobj->id = $adb->query_result($result, 0, 'id');
            $wx_userid = $adb->query_result($result, 0, 'wx_userid');
            //editor:gyq_73 date:20180712 reason：成员同步速度优化
            $update_sql = 'update ld_users set ';
            $param_arr = array();
            if (!empty($rUserArr['status'])) {
                $update_sql .= 'status=?,';
                $param_arr[] = $rUserArr['status'];
            }
            if (!empty($rUserArr['last_name'])) {
                $update_sql .= 'last_name=?,';
                $param_arr[] = $rUserArr['last_name'];
            }

            if ($_REQUEST['user_name'] == 'admin' && empty($wx_userid)) {
                //新匹配的admin默认开启提醒
                $update_sql .= 'wx_userid=?,push_wx_reminds=? where id=?';
                $adb->pquery($update_sql, array_merge($param_arr, array($rUserArr['wx_userid'], 1, $userobj->id)));
                $userobj->change_password(null, getRandChar(6));
            } else {
                $update_sql .= 'wx_userid=? where id=?';
                $adb->pquery($update_sql, array_merge($param_arr, array($rUserArr['wx_userid'], $userobj->id)));
            }
          //  file_put_contents( $this->m_rootdir ."storage/user1.txt","datac:".$update_sql."\n\n",FILE_APPEND);
          //  file_put_contents( $this->m_rootdir ."storage/user1.txt","datad:".json_encode(array_merge($param_arr, array($rUserArr['wx_userid'], $userobj->id)))."\n\n",FILE_APPEND);
           $str= json_encode(array_merge($param_arr, array($rUserArr['wx_userid'], $userobj->id)));

            //0034889: （客户001账套）在企业微信服务商管理后台修改了成员名称后，被修改名称的成员在不登录pc端的情况下，企业微信显示的还是被改之前的名字。（清除缓存也没有用）
            if (!empty($rUserArr['last_name'])) {
                createUserPrivilegesfile($userobj->id, '');
            }
        } else {
            if ($_REQUEST['changetype'] == 'update_user') {
                //51mis.com curl create_user和update_user消息并发传值
                return;
            }

            $userobj->mode = 'create';
            $_REQUEST['user_password'] = getRandChar(6);
            if ($_REQUEST['is_admin'] == 'on') {//非管理员默认为销售人员权限
                $_REQUEST['profileid'] = 1;
            } else {
                $_REQUEST['is_admin'] = 'off';
                $_REQUEST['profileid'] = $_REQUEST['seller_profileid'];
            }
            //32636: 成员权限默认值
            $_REQUEST['viewothers'] = 1;
            $_REQUEST['editothers'] = 1;
            $_REQUEST['edit_me_mobile'] = 1;
            $_REQUEST['accountallview'] = 1;
            $_REQUEST['push_wx_reminds'] = 1;//新增用户默认开启提醒
            $_REQUEST['approvestatus'] = 1;//新增用户时，审批委托应该赋值“停用”
            $filter_column_arr = array('phone_mobile', 'phone_home', 'email1', 'approveby',
                'lead_view', 'userlevel', 'activity_view', 'hour_format', 'start_hour', 'description',
                'hire_date', 'imagename', 'modifiedtime', 'currency_grouping_pattern',
                'currency_decimal_separator', 'currency_grouping_separator',
                'currency_symbol_placement', 'email2', 'secondaryemail', 'reports_to_id', 'phone_other',
                'date_format', 'time_zone', 'theme', 'address_street', 'address_country', 'address_city',
                'address_postalcode', 'address_state', 'jw_user', 'sopho_exten', 'sopho_queue',
                'hantian_exten', 'currency_name', 'currency_code', 'currency_symbol', 'conv_rate'
            );
            foreach ($filter_column_arr as $key => $value) {
                unset($userobj->column_fields[$value]);
            }

            setObjectValuesFromRequest($userobj);

            $userobj->save('Users');

        }

        if (!empty($_REQUEST['groupid'])) {//1114

            $userobj->insertUsersGroup($_REQUEST['groupid'], $userobj->id);
            //editor:gyq_20200305 reason:用户列表显示的部门，读的是用户表中groupid,而不是ld_user2group
            $upsql = 'update ld_users set groupid=? where id=?';
            $result = $adb->pquery($upsql,array($_REQUEST['groupid'],$userobj->id));
        }
        foreach ($rUserArr as $key => $value) {
            unset($_REQUEST[$key]);
        }
        return $userobj->id;
    }
    //editor:gyq_135 reason:微信打卡同步至月度考勤表  2019/8/9 16:26 ID1000568
    /* 获取打卡规则
        datetime	是	需要获取规则的日期当天0点的Unix时间戳
        useridlist	是	需要获取打卡规则的用户列表*/
    public function getcheckinoption($r_token,$r_useridlist){
        $datetime = strtotime(date('Y-m-d',time()));
        $url = 'https://qyapi.weixin.qq.com/cgi-bin/checkin/getcheckinoption?access_token='.$r_token;
        $para = array(
            'datetime'=> $datetime,
            'useridlist'=> $r_useridlist
        );
        $result = json_decode(CurlPost($url,$para)['content'],true) ;
        if(isset($result['errcode']) && $result['errcode']===0) {
            $checkindata = $result['info'];
            return $checkindata;
        }
    }
    //获取打卡信息
    public function getcheckindata($r_token,$starttime,$endtime,$useridlist){
        /*
         * opencheckindatatype	是	打卡类型。1：上下班打卡；2：外出打卡；3：全部打卡
            starttime	是	获取打卡记录的开始时间。Unix时间戳
            endtime	是	获取打卡记录的结束时间。Unix时间戳
            useridlist	是	需要获取打卡记录的用户列表
            获取记录时间跨度不超过一个月
            用户列表不超过100个。若用户超过100个，请分批获取
         * */
         
           crm_load_class_file('cls_WeixinPort','WeiXinApp/WeiXin_common');
        $portobj=new cls_WeixinPort();
        $result=$portobj->getcheckindata($starttime,$endtime,$useridlist);
		 if(isset($result['errcode']) && $result['errcode']===0){
            $checkindata = $result['checkindata'];
            return $checkindata;
        }elseif(isset($result['errcode']) && $result['errcode']==301024){
            ConvertTojsonString(-1,array($result),getFixedLabel('CHECKINSETTING_TITLE5'));
        }else{
            //editor:gyq_139 reason:月度考勤提醒内容优化  2019/8/28 13:31
            ConvertTojsonString(-1,array($result),getFixedLabel('CHECKINSETTING_TITLE4'));
        }
        
        
        
        
        $url = 'https://qyapi.weixin.qq.com/cgi-bin/checkin/getcheckindata?access_token='.$r_token;
       /* $current_time = time();
        $starttime = $current_time-24*60*60*7;
        $endtime = $current_time;*/
        $para = array(
            'opencheckindatatype'=> 1,
            'starttime'=> $starttime,
            'endtime'=> $endtime,
            'useridlist'=> $useridlist
           
        );
        $result = json_decode(CurlPost($url,$para)['content'],true) ;
        if($result['errcode']===0){
            $checkindata = $result['checkindata'];
            return $checkindata;
        }elseif($result['errcode']==301024){
            ConvertTojsonString(-1,array($result),getFixedLabel('CHECKINSETTING_TITLE5'));
        }else{
            //editor:gyq_139 reason:月度考勤提醒内容优化  2019/8/28 13:31
            ConvertTojsonString(-1,array($result),getFixedLabel('CHECKINSETTING_TITLE4'));
        }
    }
     //获取打卡token
    public function getcheckintoken($corpid,$secret){
        
        return '';
        
         crm_load_class_file('cls_WeixinPort','WeiXinApp/WeiXin_common');
        $portobj=new cls_WeixinPort();
     
        return $portobj->getCorpToken();
        
        //editor:gyq_139 reason:将获取系统参数的代码抽出  2019/8/27 17:21
       /* $url_access='https://qyapi.weixin.qq.com/cgi-bin/gettoken?corpid='.$corpid.'&corpsecret='.$secret;
        $result = json_decode(CurlGet($url_access)['content'],true) ;
        $errormsg = false;
        if($result['errcode']===0) {
            $access_token = $result['access_token'];
        }
        if($access_token){
            return $access_token;
        }else{
            ConvertTojsonString(-1,array($result),getFixedLabel('CHECKINSETTING_TITLE4'));
        }*/
    }
    //获取审批数据
    public function getapprovaldata($r_token,$starttime,$endtime,$r_next_spnum){
        //通过本接口来获取公司一段时间内的审批记录。一次拉取调用最多拉取100个审批记录，可以通过多次拉取的方式来满足需求，但调用频率不可超过600次/分。
        $url = 'https://qyapi.weixin.qq.com/cgi-bin/corp/getapprovaldata?access_token='.$r_token;
        $para = array(
            'starttime'=> $starttime,
            'endtime'=> $endtime
        );
        if(!empty($r_next_spnum)){
            $para['next_spnum'] = $r_next_spnum;
        }
        $result = json_decode(CurlPost($url,$para)['content'],true) ;
        if($result['errcode']===0) {
            return $result;
        }else{
            ConvertTojsonString(-1,array($result),getFixedLabel('CHECKINSETTING_TITLE4'));
        }
    }
   

    //ls 2021-12-27 【1002356】公费电话直拨支持数据统计报表（蔡云桥-山水）【获取通话记录】
    public function get_dial_record($corpid,$secret,$start_time,$end_time,$offset = 0,$limit = 100)
    {
        if (!empty($corpid) && !empty($secret)) {
            include_once(globalStatic::$root_directory."vendor/weworkapi_php/api/src/CorpAPI.class.php");
            // 实例化 API 类   之后直接调用相关方法
            $api = new CorpAPI($corpid, $secret);
            $params = array("start_time"=>$start_time,"end_time"=>$end_time,"offset"=>$offset,"limit"=>$limit);
            $dialRecord = $api->getDialRecord($params);

            return $dialRecord;
        }else{
            return [];
        }
    }

    //渠道码扫码业务回调逻辑处理
    public function qudaomaCallBack($rMessageObject)
    {
        $statestr = $rMessageObject->State;
        $state = explode('qudaoma_',$statestr);
        if(!empty($state[1])){
            $focus = CRMEntity::getInstance("ChannelCode");

            //从51mis.cn 传token到crm
            $token = $focus->getAccessToken();

            //编辑客户企业标签
            $mark_tag = $focus->getChannelLabelTag($state[1]);
            if(!empty($mark_tag)){
                $url = 'https://qyapi.weixin.qq.com/cgi-bin/externalcontact/mark_tag?access_token='.$token;
                $post_data['userid'] = $rMessageObject->UserID;
                $post_data['external_userid'] = $rMessageObject->ExternalUserID;
                $post_data['add_tag'] = $mark_tag;
                $post_data['remove_tag'] = array();
                $focus->wx_post($url,$post_data);
            }

            //增加扫码次数
            $focus->updateChannelScanTimes($state[1]);
            //添加、删除扫码客户记录
            $weixin_external_userid = $focus->setChannelExternalLog($state[1],$rMessageObject->ExternalUserID,$rMessageObject->ChangeType,$rMessageObject->UserID);

            //发送欢迎语
            if(!empty($rMessageObject->WelcomeCode)){
                $welcome_msg = $focus->getChannelContactway($state[1],$weixin_external_userid);
                $welcome_msg['welcome_code'] = $rMessageObject->WelcomeCode;
                $url = 'https://qyapi.weixin.qq.com/cgi-bin/externalcontact/send_welcome_msg?access_token='.$token;
                $res = $focus->wx_post($url,$welcome_msg);

            }

        }
    }

}