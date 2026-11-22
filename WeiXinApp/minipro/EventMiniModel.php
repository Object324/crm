<?php
/**
 * Created by PhpStorm.
 * User: gao
 * Date: 2018/9/12
 * Time: 14:00
 */

class EventMiniModel
{
    //小程序用户绑定检测用户名和密码是否匹配
    public function user_check(){
        global $adb;
        if(!empty($_REQUEST['username'])){
            $user_name = $_REQUEST['username'];
            $user_password = $_REQUEST['pwd'];
            $cls_AESencryptionbykeyobj = cls_AESencryptionbykey::getInstance();
            $cls_AESencryptionbykeyobj->setencryptkey($user_password);
            $user_name = $cls_AESencryptionbykeyobj->getdecryption($user_name);
            $cls_AESencryptionbykeyobj->setencryptkey($user_name);
            $user_password = $cls_AESencryptionbykeyobj->getdecryption($user_password);

            $extraid = $_REQUEST['extraid'];
//            $loginsecret=$_REQUEST['loginsecret'];

            $userobj = new Users();
            $dandianlogin = false;
            $version_account = getVersionInfo()['account'];
            //ls 20241225 XUQIU20241202-01 亿海蓝--AD域控对接集成
            if ($version_account == 'yihailan') {
                $login_user_info = $userobj->getUserinfoByColumnname("ldap_userid",$user_name);
                if(empty($login_user_info) || !isset($login_user_info[0]['user_name']) || empty($login_user_info[0]['user_name'])){
                    //查无此用户
                    $loginerror = "请管理员前去CRM维护用户";
                    echo "bind_loginerror##".$loginerror;
                    exit();
                }

                try {
                    crm_load_class_file("LDAP", 'include/LDAP');
                    $ldapobj = LDAP::getInstance();
                    $ldapobj->connect();
                    if ($ldapobj->authenticate($user_name,$user_password,true)) {
                        $user_name = $login_user_info[0]['user_name'];
                        $dandianlogin = true;
                    } else{
                        //锁定CRM中账号
                        $user_name = $login_user_info[0]['user_name']??'';
                        $user_password = uniqid();
                    }
                } catch (Exception $e) {
                    $loginerror = "登录异常，请检查LDAP扩展";
                    echo "bind_loginerror##".$loginerror;
                    exit();
                } finally {
                    unset($ldapobj);
                }
            }

            $userobj->column_fields['user_name'] = $user_name;
            $crypt_type='MD5';

            // 登陆控制，多次输错密码将锁定
            require_once(globalStatic::$root_directory.'include/utils/LoginFun.php');
            $loginerror=LoginSecurityCheck($user_name);
            if($loginerror!='')
            {
                //edit:can 20210415 成员管理，增加【登陆控制
                echo "bind_loginerror##".$loginerror;
                exit();
            }
            
            $encrypted_password = $userobj->encrypt_password($user_password, $crypt_type);
            $query_1 = "SELECT wx_openid,id,last_name,user_name from $userobj->table_name where deleted = 0  and status =  'Active' and wx_openid=? ";
            $result_1 = $adb->pquery($query_1,array($extraid));
            $nums_1 = $adb->num_rows($result_1);
            if($nums_1 > 0){
                $last_name_1 = $adb->query_result($result_1,0,'last_name');
                $user_name_1 = $adb->query_result($result_1,0,'user_name');
                $wx_openid_1 = $adb->query_result($result_1,0,'wx_openid');
                $userid_1 = $adb->query_result($result_1,0,'id');
                // possible01 重复绑定同一个CRM用户
                if(strtolower($user_name_1)==strtolower($user_name)){
                    $msg = 'bind_success,'.$userid_1;
                }else{
                    if ($dandianlogin) {
                        $query = "SELECT wx_openid,id,last_name from $userobj->table_name where deleted = 0  and status =  'Active' and user_name=?";
                        $param=array($user_name);
                    }else{
                        $query = "SELECT wx_openid,id,last_name from $userobj->table_name where deleted = 0  and status =  'Active' and user_name=? AND user_password=?";
                        $param=array($user_name, $encrypted_password);
                    }

                    $result = $adb->pquery($query,array($param));
                    if($adb->num_rows($result) >= 1){
                        $wx_openid = $adb->query_result($result,0,'wx_openid');
                        $id = $adb->query_result($result,0,'id');
                        $last_name = $adb->query_result($result,0,'last_name');
                        //possible02  从crm张三到绑定crm李四，李四未被绑定
                        if(empty($wx_openid)){
                            $sql_1 = 'update '.$userobj->table_name.' set wx_openid=? where wx_openid=?';
                            $adb->pquery($sql_1,array('',$extraid));
                            $sql_1 = 'update '.$userobj->table_name.' set wx_openid=? where id=?';
                            $adb->pquery($sql_1,array($extraid,$id));
                            $msg = 'bind_success,'.$id;
                        }else{
                            //possible03 从张三到绑定李四，李四被绑定
                            //editor:gyq_128 reason:允许用户替换微信绑定  2019/7/9 13:46 ID1000504
                            $msg = 'bind_repeat,replace_bind,'.$id.','.$extraid;
                            // 设置移动端登录时已被关联的账号是否允许其他用户继续登录 
                            $system_360 = getSys_deploy(360);
                            if($system_360['deploy_value']==1){
                                $msg = 'bind_repeat,noreplace_bind,'.$id.','.$extraid;
                            }
                        }
                        $delete_sql = 'delete from ld_loginerror where userid=? ';
                        $adb->pquery($delete_sql, array($id));
                        
                    }else{
                        //possible04 李四的密码不对
                        $select_query = "SELECT id from $userobj->table_name where deleted = 0  and status =  'Active' and user_name=? ";
                        $select_result = $adb->pquery($select_query,array($user_name));
                        if($adb->num_rows($select_result)>0)
                        {
                            $insert_sql = 'insert into ld_loginerror(logintime,userid)value(?,?)';
                            $adb->pquery($insert_sql, array(date("Y-m-d H:i:s"), $adb->query_result($select_result, 0, 'id')));
                            
                        }
                        
                        $msg = 'bind_fail,';
                    }
                }
            }else{
                if ($dandianlogin) {
                    $query = "SELECT wx_openid,id,last_name from $userobj->table_name where deleted = 0  and status =  'Active' and user_name=?";
                    $param=array($user_name);
                }else{
                    $query = "SELECT wx_openid,id,last_name from $userobj->table_name where deleted = 0  and status =  'Active' and user_name=? AND user_password=?";
                    $param=array($user_name, $encrypted_password);
                }

                $result = $adb->pquery($query,array($param));
                if($adb->num_rows($result) >= 1){
                    $wx_openid = $adb->query_result($result,0,'wx_openid');
                    $id = $adb->query_result($result,0,'id');
                    $last_name = $adb->query_result($result,0,'last_name');
                    //possible05 绑定张三
                    if(empty($wx_openid)){
                        $sql_1 = 'update '.$userobj->table_name.' set wx_openid=? where id=?';
                        $adb->pquery($sql_1,array($extraid,$id));
                        $msg = 'bind_success,'.$id;
                    }else{
                        //possible05 张三已被其他人绑定
                        $msg = 'bind_repeat,replace_bind,'.$id.','.$extraid;
                        // 设置移动端登录时已被关联的账号是否允许其他用户继续登录 
                        $system_360 = getSys_deploy(360);
                        if($system_360['deploy_value']==1){
                            $msg = 'bind_repeat,noreplace_bind,'.$id.','.$extraid;
                        }
                    }

                    $delete_sql = 'delete from ld_loginerror where userid=? ';
                    $adb->pquery($delete_sql, array($id));
                }else{

                    $select_query = "SELECT id from $userobj->table_name where deleted = 0  and status =  'Active' and user_name=? ";
                    $select_result = $adb->pquery($select_query,array($user_name));
                    if($adb->num_rows($select_result)>0)
                    {
                        $insert_sql = 'insert into ld_loginerror(logintime,userid)value(?,?)';
                        $adb->pquery($insert_sql, array(date("Y-m-d H:i:s"), $adb->query_result($select_result, 0, 'id')));
                        
                    }

                    $msg = 'bind_fail,';
                }
            }
            echo $msg.',check_loginsecret';
            exit();
        }
    }
    //editor:gyq_20181017 小程序二维码绑定
    public function user_check_qrcode(){
        global $adb;
        if(!empty($_REQUEST['userid'])){
            $userid = $_REQUEST['userid'];
            $extraid = $_REQUEST['extraid'];
            //初始化用户表wx_openid
            $sql_1 = 'update ld_users set wx_openid=? where wx_openid=?';
            $adb->pquery($sql_1,array('',$extraid));
            //绑定
            $sql_2 = 'update ld_users set wx_openid=? where id=?';
            $adb->pquery($sql_2,array($extraid,$userid));
            $msg = 'bind_success,'.$userid;
            echo $msg;
            exit();
        }
    }
    //小程序根据openid获取用户ID
    public function get_userinfo(){
        global $adb;
        $openid = $_REQUEST['openid'];
        $_REQUEST['userid']=0;
        $sql= 'select id,status from ld_users where wx_openid=?';
        $result  = $adb->pquery($sql,array($openid));
        $output = array();
        if($adb->num_rows($result) > 0){
            $userid = $adb->query_result($result,0,'id');
            $_REQUEST['userid'] = $userid;
            //editor:gyq_114 reason:小程序绑定优化  2019/5/23 17:41 
            $status = $adb->query_result($result,0,'status');
            $_REQUEST['status'] = $status;
            $output = array('id'=>$userid,'status'=>$status);
        }
        $this->addWechatUser();
        echo json_encode($output);exit;
    }
    //zxm 20220623 同步小程序用户信息到ld_wechatuser表  openid userid unionid 三个字段  用来发送公众号模板消息的
    //zxm 20221013 对应微信公众号的openid unionid 接收到 且存储到微信用户表
    public function addWechatUser(){
        global $adb;
        $openid = $_REQUEST['openid'];
        $offiaccount_openid = $_REQUEST['offiaccount_openid'];//公众号的openid
        $unionid = $_REQUEST['unionid'];
        $userid = $_REQUEST['userid'];
        $status = $_REQUEST['status'];
        if($userid>0&&$status=='Active'){
            //如果用户登录成功  把这个成员绑定的其他微信用户解绑
            $jiebangSql = "update ld_wechatuser set userid=0 where userid=?";
            $adb->pquery($jiebangSql,array($userid));
        }
        // 查询openid有没有在表里存在
        $selectSql = "select wechatuserid from ld_wechatuser where open_id=? and deleted=0 limit 1 ";
        $selectRes = $adb->pquery($selectSql,array($openid));
        $selectNums = $adb->num_rows($selectRes);

        if($selectNums<=0){
            //插入数据
            $module_focus = CRMEntity::getInstance('WeChatUser');
            $module_focus->column_fields['open_id'] = $openid;
            $module_focus->column_fields['unionid'] = $unionid;
            $module_focus->column_fields['assigned_user_id'] = 1;
            $module_focus->column_fields['smcreatorid'] = 1;
            $module_focus->column_fields['bindtype'] = '用户';
            $module_focus->column_fields['createdtime'] = date('Y-m-d H:i:s');
            $module_focus->operate_api = 'api';
            $module_focus->save('WeChatUser');

            $wechatuserid = $module_focus->id;
        }else{
            $wechatuserid = $adb->query_result($selectRes,0,0);
        }
        $query = 'update ld_wechatuser set open_id=?,unionid=?,userfrom=?,userfromvalue=?,userid=? where wechatuserid=? and deleted=0';
        $adb->pquery($query,array($openid,$unionid,'CRM小程序','CRMminiprogram',$userid,$wechatuserid));

        //公众号的用户 zxm 20221013 公众号用户同步过来
        if(!empty($offiaccount_openid)){
            $_REQUEST['openid'] = $offiaccount_openid;
            // 查询公众号的用户 openid有没有在表里存在
            $selectSql = "select wechatuserid from ld_wechatuser where open_id=? and deleted=0 limit 1 ";
            $selectRes = $adb->pquery($selectSql,array($offiaccount_openid));
            $selectNums = $adb->num_rows($selectRes);

            if($selectNums<=0){
                //插入数据
                $module_focus = CRMEntity::getInstance('WeChatUser');
                $module_focus->column_fields['open_id'] = $offiaccount_openid;
                $module_focus->column_fields['unionid'] = $unionid;
                $module_focus->column_fields['assigned_user_id'] = 1;
                $module_focus->column_fields['smcreatorid'] = 1;
                $module_focus->column_fields['bindtype'] = '用户';
                $module_focus->column_fields['createdtime'] = date('Y-m-d H:i:s');
                $module_focus->operate_api = 'api';
                $module_focus->save('WeChatUser');

                $wechatuserid = $module_focus->id;
            }else{
                $wechatuserid = $adb->query_result($selectRes,0,0);
            }
            $query = 'update ld_wechatuser set open_id=?,unionid=?,userfrom=?,userfromvalue=?,userid=? where wechatuserid=? and deleted=0';
            $adb->pquery($query,array($offiaccount_openid,$unionid,'CRM公众号','CRMoffiaccount',0,$wechatuserid));
        }
    }

    //小程序退出登录
    public function logout(){
        global $adb;
        $userid = $_REQUEST['userid'];
        $mini_basename = $_REQUEST['mini_basename'];
        $sql= 'select wx_openid,user_name from ld_users where id=?';
        $result  = $adb->pquery($sql,array($userid));
        $output = array();
        if($adb->num_rows($result) > 0){
            // edit：hzx 47043 成员xia，在crm微信小程序操作登录退出，日志中只记录了登录的历史
            $tmp_user_name = $adb->query_result($result,0,"user_name");
            crm_load_class_file('LoginHistory','modules/Users');
            $outtime=date("Y/m/d H:i:s");
            $loghistory=new LoginHistory();
            $usip = '';
            $loghistory->user_logout($tmp_user_name,$usip,$outtime);
            //如果用户退出成功  把这个成员绑定的其他微信用户解绑 zxm20230510  
            $jiebangSql = "update ld_wechatuser set userid=0 where userid=?";
            $adb->pquery($jiebangSql,array($userid));

            //清除openid
            $wx_openid = $adb->query_result($result,0,'wx_openid');
            $sql_update = 'update ld_users set wx_openid=? where id=?';
            $sql_update_result = $adb->pquery($sql_update,array('',$userid));
            $url = const_mini::$api_url.'?action_api=logout&openid='.$wx_openid.'&mini_basename='.$mini_basename;
            $result_get = CurlGet($url);
            ConvertTojsonString(1,array('openid'=>$wx_openid),'success');
        }else{
            ConvertTojsonString(1,array('openid'=>$wx_openid),'success,but empty userid');
        }
    }
    //小程序切换企业号
    public function switch_account(){
        global $adb;
        $userid = $_REQUEST['userid'];
        $mini_basename = $_REQUEST['mini_basename'];
        $sql= 'select wx_openid from ld_users where id=?';
        $result  = $adb->pquery($sql,array($userid));
        $output = array();
        if($adb->num_rows($result) > 0){
            $wx_openid = $adb->query_result($result,0,'wx_openid');
            $url = const_mini::$api_url.'?action_api=switch_account&openid='.$wx_openid;
            $result_get = CurlGet($url)['content'];
            echo $result_get;exit;
        }else{
            ConvertTojsonString(-1,array('openid'=>$wx_openid),'empty:userid');
        }
    }
    //获取小程序版本
    public function get_version(){
        $version = 'V7.5.3';
        ConvertTojsonString(1,array('version'=>$version),'success');
    }
    //editor:gyq_106 reason:自助小程序登录修改  2019/3/28 16:21
    public function get_weixinmp_bindtype(){
        //editor:gyq_125 reason:自助服务/订单小程序,初次使用，允许灵活新增/绑定  2019/6/19 15:46 
        $list = cls_MP_CommonFun::redirect_bind_html($_REQUEST['const_type']);
        echo json_encode($list);exit;
    }
    //editor:gyq_20190426 reason:【ID1000444】服务小程序的短信验证码， 应该走客户自己的短信通道
    public function get_smssetting(){
        //系统设置 > 短信账户设置
//        $SMSarray = GetSMSAutograph();
        crm_load_class_file('cls_Send_MassSms','include/utils');
        $cls_Send_MassSms = cls_Send_MassSms::getInstance();
        $SMSarray = $cls_Send_MassSms->smsarray;

        //duan 20230424 增加版本信息读取,用于客户个性化定制短信内容
        $version = getVersionInfo();
        $result = array('code'=>-1);
        if(!empty($SMSarray['account_name'])){
            $result['name']= $SMSarray['account_name'];
            $result['pwd']= $SMSarray['account_pwd'];
            $result['sign']= $SMSarray['autograph'];
            $result['tel']= $SMSarray['service_tel'];
            $result['code']= 1;
            $result['account']= $version['account'];
            $result['trade']= $version['trade'];
            $result['platform']= $cls_Send_MassSms->platform;
        }
        echo json_encode($result);
    }

    public function sendAliyun(){
        //系统设置 > 短信账户设置
        $result = array('code'=>-1);

        $code = $_REQUEST['code']??'';
        $phone = $_REQUEST['phone']??'';
        if (!empty($code) && !empty($phone)) {
            crm_load_class_file('cls_Send_MassSms','include/utils');
            $cls_Send_MassSms = cls_Send_MassSms::getInstance();

            if ($cls_Send_MassSms->platform == 'aliyun') {
                $smsdetail_arr = $cls_Send_MassSms->getSmsRelatedByScene($cls_Send_MassSms->platform,'weixinmp_bindtype_verifycode');
                if(!empty($smsdetail_arr)){
                    $templateParam_arr = Zend_Json::decode($smsdetail_arr['templateparamconf']);
                    foreach($templateParam_arr as &$val){
                        $val = $code;
                        break;//登录验证码默认仅有一个变量
                    }
                    $templateParam = json_encode($templateParam_arr);
                    $sendresult = $cls_Send_MassSms->send($phone,'','','',$smsdetail_arr['templateid'],$templateParam);
                    $result['code'] = $sendresult['smsresult'];//1 发送成功  0 发送失败
                    $result['msg'] = $sendresult['errormsg'];
                }

            }
        }

        echo json_encode($result);

    }

    //editor:gyq_154 reason:获取小程序的后台参数  2019/10/19 17:12
    public function get_appid_secret($r_const_type){
        require_once globalStatic::$root_directory.'WeiXinApp/minipro/const_mini.php';
        if($r_const_type=='demo'){
            $appid  =  const_mini::$demo_appid ;
            $secret =  const_mini::$demo_secret;
        }elseif($r_const_type=='tianyaoyun') {
            $appid  =  const_mini::$tyy_appid ;
            $secret =  const_mini::$tyy_secret;
        }elseif($r_const_type=='xingyeshujin') {
            $appid  =  const_mini::$xysj_appid ;
            $secret =  const_mini::$xysj_secret;
        }elseif($r_const_type=='genghangcrm') {
            $appid  =  const_mini::$genghang_appid ;
            $secret =  const_mini::$genghang_secret;
        }elseif($r_const_type=='caixuntongcrm') {
            $appid  =  const_mini::$caixuntong_appid ;
            $secret =  const_mini::$caixuntong_secret;
        }elseif($r_const_type=='benzhucrm') {
            $appid  =  const_mini::$benzhu_appid ;
            $secret =  const_mini::$benzhu_secret;
        }elseif($r_const_type=='xundacrm') {
            $appid  =  const_mini::$xunda_appid ;
            $secret =  const_mini::$xunda_secret;
        }elseif($r_const_type=='hbhuixinnongye') {
            $appid  =  const_mini::$hbhxnongye_appid ;
            $secret =  const_mini::$hbhxnongye_secret;
        }elseif($r_const_type=='yichongcrm') {
            $appid  =  const_mini::$yichongcrm_appid ;
            $secret =  const_mini::$yichongcrm_secret;
        }elseif($r_const_type=='kunchicrm') {
            $appid  =  const_mini::$kunchicrm_appid ;
            $secret =  const_mini::$kunchicrm_secret;
        }elseif($r_const_type=='yongyincrm') {
            $appid  =  const_mini::$yongyincrm_appid ;
            $secret =  const_mini::$yongyincrm_secret;
        }elseif($r_const_type=='langjiecrm') {
            $appid  =  const_mini::$langjiecrm_appid ;
            $secret =  const_mini::$langjiecrm_secret;
        }elseif($r_const_type=='tianliaocrm') {
            $appid  =  const_mini::$tianliaocrm_appid;
            $secret =  const_mini::$tianliaocrm_secret;
        }elseif($r_const_type=='yichongdemo') {
            $appid  =  const_mini::$yichongdemo_appid;
            $secret =  const_mini::$yichongdemo_secret;
        }elseif($r_const_type=='dongmaocrm') {
            $appid  =  const_mini::$dongmaocrm_appid;
            $secret =  const_mini::$dongmaocrm_secret;
        }elseif($r_const_type=='huboshicrm') {
            $appid  =  const_mini::$huboshicrm_appid;
            $secret =  const_mini::$huboshicrm_secret;
        }elseif($r_const_type=='sdlinuotebocrm') {
            $appid  =  const_mini::$sdlinuotebocrm_appid;
            $secret =  const_mini::$sdlinuotebocrm_secret;
        }elseif($r_const_type=='zhuojiedianzicrm') {
            $appid  =  const_mini::$zhuojiedianzicrm_appid;
            $secret =  const_mini::$zhuojiedianzicrm_secret;
        }elseif($r_const_type=='yihailancrm') {
            $appid  =  const_mini::$yihailancrm_appid;
            $secret =  const_mini::$yihailancrm_secret;
        }elseif($r_const_type=='daminkejicrm') {
            $appid  =  const_mini::$daminkejicrm_appid;
            $secret =  const_mini::$daminkejicrm_secret;
        }elseif($r_const_type=='mianyanghanliancrm') {
            $appid  =  const_mini::$mianyanghanliancrm_appid;
            $secret =  const_mini::$mianyanghanliancrm_secret;
        }elseif($r_const_type=='jxyfnongshangcrm') {
            $appid  =  const_mini::$jxyfnongshangcrm_appid;
            $secret =  const_mini::$jxyfnongshangcrm_secret;
        }elseif($r_const_type=='qilicrm') {
            $appid  =  const_mini::$qilicrm_appid;
            $secret =  const_mini::$qilicrm_secret;
        }elseif($r_const_type=='zhongtianhuojiancrm') {
            $appid  =  const_mini::$zhongtianhuojiancrm_appid;
            $secret =  const_mini::$zhongtianhuojiancrm_secret;
        }elseif($r_const_type=='xintexincailiaocrm') {
            $appid  =  const_mini::$xintexincailiaocrm_appid;
            $secret =  const_mini::$xintexincailiaocrm_secret;
        }elseif($r_const_type=='lichuangliercrm') {
            $appid  =  const_mini::$lichuangliercrm_appid;
            $secret =  const_mini::$lichuangliercrm_secret;
        }elseif($r_const_type=='shidakejicrm') {
            $appid  =  const_mini::$shidakejicrm_appid;
            $secret =  const_mini::$shidakejicrm_secret;
        }else{
            //minipro_const_type = formal
            $appid  =  const_mini::$default_appid ;
            $secret =  const_mini::$default_secret;
        }
        return array('appid'=>$appid,'secret'=>$secret);
    }
    //生成小程序二维码
    public function mini_get_qrcode($r_coid,$r_const_type){
        //默认值
        if(empty($r_const_type))
            $r_const_type = 'formal';
        $root_dir =dirname (dirname(dirname(__FILE__)));
        $para_content = $this->get_appid_secret($r_const_type);
        $appid = $para_content['appid'];
        $secret = $para_content['secret'];
        $imgsrc = '';
        if($r_coid > 0){
            $token_url = 'https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid='.$appid.'&secret='.$secret;
            $content_result = CurlGet($token_url)['content'];
            $token_result = json_decode($content_result,true);
            if(!empty($token_result['access_token'])){
                $access_token = $token_result['access_token'];
                //参考文档 https://developers.weixin.qq.com/minigame/dev/api-backend/getWXACodeUnlimit.html?search-key=getwxacodeunlimit
                $qrcode_url = 'https://api.weixin.qq.com/wxa/getwxacodeunlimit?access_token='.$access_token;
                $param['scene'] = 'coid='.$r_coid;
                //eidtor:gyq_20190327 必须是已经发布的小程序存在的页面（否则报错）
                $param['page'] = 'pages/home/home';
                $qrcode_result = CurlPost($qrcode_url,$param)['content'];
                $filename = 'wechat_miniprogram_crm.jpg';
//editor:gyq_20190123 0036057: 成员管理明细界面-客户自助服务平台小程序码，点击生成图片，如果【storage】中没有【weixinqrcode】文件夹，生成图片失败
                $uploadDir = $root_dir.'/storage/weixinqrcode/';
                if(!file_exists($uploadDir)){
                    mkdir($uploadDir,0777);
                }
                file_put_contents($uploadDir.$filename,$qrcode_result);
                $imgsrc = 'storage/weixinqrcode/'.$filename;
            }
        }

        return $imgsrc;
    }
}