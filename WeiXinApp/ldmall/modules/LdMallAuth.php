<?php

require_once(globalStatic::$root_directory.'WeiXinApp/ldmall/miniprogram/wxBizDataCrypt.php');
class LdMallAuth extends LdMall
{
    //授权手机号
    public function setPhone(){
        $open_id = $_REQUEST['open_id'];
        $session_key = $_REQUEST['session_key'];
        $code = $_REQUEST['code'];
		$smownerid = isset($_REQUEST['usid']) ? $_REQUEST['usid'] : 1;;
        $accountInfo = $this->getAccountInfo($open_id);
        if(isset($_REQUEST['code'])&&!empty($code)){
            //获取手机号 -- 新方法 有code才用这个方法
            $mobile = $this->getWeChatUserMobileByCode($code);
        }else{
            //获取手机号 -- 旧方法
            $mobile = $this->getWeChatUserMobile($session_key);
        }
        if(empty($mobile)){
            return array(-1, array(), '授权手机号失败');
        }
        //1.查找这个手机号在联系人表里面有没有
        $select_sql = "select contactid,accountid from ld_contactdetails where mobile=? and deleted=0 limit 1";
        $select_res = $this->adb->pquery($select_sql,array($mobile));
        $select_nums = $this->adb->num_rows($select_res);
        if($select_nums>0){
            //2.有的话将微信用户与联系人关联
            $contactid = $this->adb->query_result($select_res,0,'contactid');
            $accountid = $this->adb->query_result($select_res,0,'accountid');
            if($accountid<=0){
                $account_focus = CRMEntity::getInstance("Accounts");
                $account_focus->column_fields['accountname'] = $accountInfo['lastname'];
                $account_focus->column_fields['leadsource'] = "小程序注册";
                $account_focus->column_fields['assigned_user_id'] = $smownerid;
                $account_focus->column_fields['mobile'] = $mobile;
                $account_focus->save('Accounts');
                $accountid = $account_focus->id;
                //更新contact表客户
                $update_contact_sql = "update ld_contactdetails set accountid=?,reference=1 where contactid=?";
                $this->adb->pquery($update_contact_sql,array($accountid,$contactid));
            }
        }else{
            //3.没有的话增加一个联系人一个客户
            $account_focus = CRMEntity::getInstance("Accounts");
            $account_focus->column_fields['accountname'] = $accountInfo['lastname'];
            $account_focus->column_fields['leadsource'] = "小程序注册";
            $account_focus->column_fields['assigned_user_id'] = $smownerid;
            $account_focus->column_fields['mobile'] = $mobile;
            $account_focus->column_fields['sourcefrom'] = "商城小程序";
            $account_focus->save('Accounts');
            $contact_focus = CRMEntity::getInstance("Contacts");
            $contact_focus->column_fields['lastname'] = $accountInfo['lastname'];
            $contact_focus->column_fields['mobile'] = $mobile;
            $contact_focus->column_fields['assigned_user_id'] = $smownerid;
            $contact_focus->column_fields['reference'] = 1;
            $contact_focus->column_fields['account_id'] = $account_focus->id;
            $contact_focus->column_fields['sourcefrom'] = "商城小程序";

            $contact_focus->save('Contacts');
            $accountid = $account_focus->id;
            $contactid = $contact_focus->id;
        }
        $update_sql = "update ld_wechatuser set mobile=?,contactid=?,accountid=? where open_id=? and userfromvalue = ?";
        $this->adb->pquery($update_sql,array($mobile,$contactid,$accountid,$open_id,'miniprogram_mall'));
        $accountInfo = $this->getAccountInfo($open_id);
        return array(1, array('accountInfo'=>$accountInfo), 'success');
    }
    //获取联系人手机号--新方法 根据code获取
    public function getWeChatUserMobileByCode($code){
        $result = $this->getWeChatUserMobileByCodeFun($code);
        $mobile = '';
        if ($result['errcode'] == 0) {
            $data = $result['phone_info'];
            $mobile = $data['phoneNumber'];//用户绑定的手机号（国外手机号会有区号）
            //$purePhoneNumber = $data['purePhoneNumber'];//没有区号的手机号
        }else{
            //token失效 清除token重新获取
            $appid = $this->configArr['appid'];
            $projectname = 'ldmall';
            file_put_contents(globalStatic::$root_directory.'storage/accesstoken/'.$projectname.'_'.$appid.'.txt','');//删掉token
            $result = $this->getWeChatUserMobileByCodeFun($code);
            $mobile = '';
            if ($result['errcode'] == 0) {
                $data = $result['phone_info'];
                $mobile = $data['phoneNumber'];//用户绑定的手机号（国外手机号会有区号）
            }
        }
        return $mobile;
    }
    public function getWeChatUserMobileByCodeFun($code){
        $access_token = $this->getAccessToken();
        $url = 'https://api.weixin.qq.com/wxa/business/getuserphonenumber?access_token='.$access_token;
        $para = array(
            'code'=> $code
        );
        $result = CurlPost($url,$para);
        $result = $result['content'];
        $result = json_decode($result,true);
        return $result;
    }
    //获取联系人手机号--旧方法 根据encryptedData iv获取
    public function getWeChatUserMobile($session_key){
        $pc = new ldmallBizDataCrypt($this->configArr['appid'], $session_key);
        $errCode = $pc->decryptData($_REQUEST['encryptedData'], $_REQUEST['iv'], $data );
        $mobile = '';
        if ($errCode == 0) {
            $data = json_decode($data,true);
            $mobile = $data['phoneNumber'];//用户绑定的手机号（国外手机号会有区号）
            //$purePhoneNumber = $data['purePhoneNumber'];//没有区号的手机号
        }
        return $mobile;
    }

    /**
     * @return array
     * @throws Exception
     * 微信授权   保存微信用户信息
     */
    public function Authorization(){
        $open_id =$_REQUEST['open_id'];
        $nickname =$_REQUEST['nickName'];
        $avatarurl = $_REQUEST['avatarUrl'];
        $gender = $_REQUEST['gender'];
        $unionid = $_REQUEST['unionid'];
        $smownerid = isset($_REQUEST['usid']) ? $_REQUEST['usid'] : 1;

        // 通过openid去数据库匹配之前是否授权过 没有则新增一条数据 有则更新基本信息
        // 带参授权的 accountid客户ID  wechatuserid微信用户ID
        // 参数 nickname   openid
        $query = 'select wechatuserid from ld_wechatuser where open_id = ? and deleted = 0 limit 1';
        $result = $this->adb->pquery($query,array($open_id));
        $num_rows = $this->adb->num_rows($result);
        if($num_rows<=0){
            //插入数据库
            $wechatuserid = $this->insertWechatUser($open_id);
        }else{
            $wechatuserid = $this->adb->query_result($result,0,'wechatuserid');
        }
        //编辑
        if($gender == 1){
            $sex = '男';
        }
        else if($gender == 2){
            $sex = '女';
        }else{
            $sex = '未知';
        }

        $query = 'update ld_wechatuser set lastname = ?,imagename = ?,sex=?,unionid=?,userfrom = ?,userfromvalue = ?,smownerid = ? where open_id = ?';
        $this->adb->pquery($query,array($nickname,$avatarurl,$sex,$unionid,'商城小程序','miniprogram_mall',$smownerid,$open_id));
        $accountInfo = $this->getAccountInfo($open_id);
        $arr['accountInfo']  = $accountInfo;
        return array(1, $arr, 'success');
    }
    /**
     * @return array
     * 微信小程序的解析code  判断登录状态
     */
    public function Login()
    {
        $appid = $this->configArr['appid'];
        $secret = $this->configArr['appsecret'];
        //获取TOKEN
        $code = trim($_REQUEST['code']);
        if(empty($code)){
            $Convert = array(-1,array('data'=>[]),'Code Missing') ;
        }else{
            $URL = "https://api.weixin.qq.com/sns/jscode2session?appid=$appid&secret=$secret&js_code=$code&grant_type=authorization_code";

            $result = CurlGet($URL);

            $apiDatainfo = json_decode($result['content'],true);
            if(isset($apiDatainfo['openid'])){
                $_SESSION['WX_SESSION_KEY'] = $apiDatainfo['session_key'];
                $_SESSION['OPENID'] = $apiDatainfo['openid'];
                $query = 'select wechatuserid,ifnull(accountid,0)as accountid from ld_wechatuser where open_id = ? and deleted = 0 limit 1';
                $result = $this->adb->pquery($query,array($apiDatainfo['openid']));
                $num_rows = $this->adb->num_rows($result);
                $accountInfo = $this->getAccountInfo($apiDatainfo['openid']);
                $accountInfo['session_key'] = $apiDatainfo['session_key'];
                $accountInfo['open_id'] = $apiDatainfo['openid'];
                if($num_rows <= 0){
                    $accountInfo['unionid'] = $apiDatainfo['unionid'];
                    $Convert = array(1,array('data'=>$accountInfo),'你还没有登录，请先登录！');
                }else{
                    $Convert = array(1,array('data'=>$accountInfo),'success');
                }
            }else{
                $Convert = array(-1,array('data'=>$result),'获取小程序用户唯一标识失败');
            }
        }
        return $Convert;
    }
    public function insertWechatUser($openid){
        //插入数据
        include(globalStatic::$root_directory.'modules/WeChatUser/WeChatUser.php');
        $module_focus = new WeChatUser();
        $module_focus->column_fields['open_id'] = $openid;
        $module_focus->column_fields['unionid'] = '';
        $module_focus->column_fields['assigned_user_id'] = 1;
        $module_focus->column_fields['smcreatorid'] = 1;
        $module_focus->column_fields['createdtime'] = date('Y-m-d H:i:s');
        $module_focus->operate_api = 'api';
        $module_focus->save('WeChatUser');
        if($module_focus->id > 0){
            $query = 'update ld_wechatuser set open_id = ?,userfrom = ?,userfromvalue = ? where wechatuserid = ?';
            $this->adb->pquery($query,array($openid,'商城小程序','miniprogram_mall',$module_focus->id));
            return $module_focus->id;
        }
        return 0;
    }
}