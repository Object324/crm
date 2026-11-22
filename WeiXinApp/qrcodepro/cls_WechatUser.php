<?php
class cls_WechatUser
{
	public function __construct(){
	   global $adb;
       $this->adb = $adb;
	}

	//获取微信用户信息
	public function curlGet($url)
    {
        //初始化
        $ch = curl_init();

        curl_setopt($ch, CURLOPT_URL,$url);
        // 执行后不直接打印出来
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_HEADER, false);
        // 跳过证书检查
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
        // 不从证书中检查SSL加密算法是否存在
        curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, false);

        //执行并获取HTML文档内容
        $output = curl_exec($ch);

        //释放curl句柄
        curl_close($ch);

        return $output;
    }
    
    public function getwxuserInfo($code){
        require_once(globalStatic::$root_directory.'/WeiXinApp/minipro/EventMiniModel.php');
        $model = new EventMiniModel();
        $sql = "select usertype from ld_wx_config where name=?";
        $result = $this->adb->pquery($sql,array('wechat_miniprogram_setting'));
        $usertype = $this->adb->query_result($result,0,'usertype');
        $para_content = $model->get_appid_secret($usertype);
        $appid = $para_content['appid'];
        $secret = $para_content['secret'];
        // return array(-1,array($appid,$secret),'appid+secret');
        if(empty($code)){
            return array(-1,array($_REQUEST),'Code Missing');
        }else{
            $URL = "https://api.weixin.qq.com/sns/jscode2session?appid=$appid&secret=$secret&js_code=$code&grant_type=authorization_code";
            $result = $this->curlGet($URL);
            $apiDatainfo = json_decode($result,true);
            if(isset($apiDatainfo['openid'])){
                $openid = $apiDatainfo['openid'];
            }else{
                return array(-1,array(),'获取小程序用户唯一标识失败');
            }
        }
        return $this->Authorization($openid);
	}
    
    public function Authorization($open_id){
        // 通过openid去数据库匹配之前是否授权过 没有则新增一条数据 有则更新基本信息
        // 带参授权的 accountid客户ID  wechatuserid微信用户ID
        // 参数 nickname   openid
        $userfrom = '表单码';
        $userfromvalue = 'ld_formcode';
        
        $sql = 'select wechatuserid from ld_wechatuser where open_id=? and userfrom=? and userfromvalue=? and deleted = 0 limit 1';
        $result = $this->adb->pquery($sql,array($open_id,$userfrom,$userfromvalue));
        
        $num_rows = $this->adb->num_rows($result);
        if($num_rows<=0){
            //插入数据库
            if(isset($_REQUEST['action'])&&$_REQUEST['action']=='auth_login'){
                $wechatuserid = $this->insertWechatUser($open_id,$userfrom,$userfromvalue);
            }else{
                return array(-2, array('openid'=>$open_id), '未授权登录');
            }
        }else{
            $wechatuserid = $this->adb->query_result($result,0,'wechatuserid');
        }
        $nickname = $_REQUEST['nickName'];
        $avatarurl = $_REQUEST['avatarUrl'];
        $gender = $_REQUEST['gender'];
        //编辑
        if($gender == 1){
            $sex = '男';
        }
        else if($gender == 2){
            $sex = '女';
        }else{
            $sex = '未知';
        }
        
        if(isset($_REQUEST['action'])&&$_REQUEST['action']=='auth_login'){
            $query = 'update ld_wechatuser set lastname = ?,imagename = ?,sex=? where open_id = ?';
            $this->adb->pquery($query,array($nickname,$avatarurl,$sex,$open_id));
        }
        //获取授权用户信息
        $accountInfo = $this->getAccountInfo($open_id);
        $arr['accountInfo']  = $accountInfo;
        $arr['openid']  = $open_id;
        
        require_once(globalStatic::$root_directory.'/WeiXinApp/qrcodepro/cls_QrcodeField.php');
        $QrcodeField = new cls_QrcodeField();
        $fieldinfo = $QrcodeField->qrcode_effctive($wechatuserid);
        if($fieldinfo[0]<0){
            return $fieldinfo;
        }else{
            $arr['list'] = $fieldinfo[1]['data'];
            $arr['modulename'] = $fieldinfo[1]['modulename'];
            $arr['record'] = $fieldinfo[1]['record'];
            $arr['page_title'] = $fieldinfo[1]['label'];
            $arr['userid'] = $fieldinfo[1]['userid'];
            $arr['mini_basename'] = $fieldinfo[1]['mini_basename'];
            $arr['url'] = $fieldinfo[1]['url'];
            $arr['token'] = $fieldinfo[1]['token'];
            $arr['allow_save'] = $fieldinfo[1]['allow_save'];
            $arr['entry'] = $fieldinfo[1]['entry'];
        }
        return array(1, $arr, 'success');
    }
    //
	public function insertWechatUser($openid,$userfrom,$userfromvalue){
        //插入数据
        require_once(globalStatic::$root_directory.'modules/WeChatUser/WeChatUser.php');
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
            $this->adb->pquery($query,array($openid,$userfrom,$userfromvalue,$module_focus->id));
            return $module_focus->id;
        }
        return 0;
    }
    
    public function getAccountInfo($open_id){
        $accountInfo = array(
            'logoimg'=>$this->corpurl.'themes/ldmallimg/logo/logo.png',
            'balance_amount'=>0,
            'accountname'=>'',
            'imagename'=>'',
            'lastname'=>'',
            'accountid'=>0,
            'open_id'=>$open_id,
            'session_key' => $_REQUEST['session_key'],
            'unionid'=>'',
            'mobile'=>'',
            'hidemobile'=>'',
            'wechatuserid'=>0,
        );
        if(!empty($open_id)) {
            $select_query = 'select * from ld_wechatuser where open_id=? and deleted=0 ';
            $select_result = $this->adb->pquery($select_query, array($open_id));
            
            $select_rows = $this->adb->num_rows($select_result);
            if ($select_rows > 0) {
                $deleted = $this->adb->query_result($select_result, 0, 'deleted');
                $accountInfo['balance_amount'] = 0;
                $accountInfo['accountname'] = '';
                if ($deleted == 0) {
                    $accountInfo['balance_amount'] = $this->adb->query_result($select_result, 0, 'balance_amount');//公司余额
                    $accountInfo['balance_amount'] = empty($accountInfo['balance_amount']) ? 0 : $accountInfo['balance_amount'];
                    $accountInfo['accountname'] = $this->adb->query_result($select_result, 0, 'accountname');//公司名字
                }
                $accountInfo['imagename'] = $this->adb->query_result($select_result, 0, 'imagename');//$avatarurl;//微信头像
                $accountInfo['lastname'] = $this->adb->query_result($select_result, 0, 'lastname');//姓名
                $accountInfo['accountid'] = $this->adb->query_result($select_result, 0, 'accountid');
                $accountInfo['open_id'] = $this->adb->query_result($select_result, 0, 'open_id');;
                $accountInfo['unionid'] = $this->adb->query_result($select_result, 0, 'unionid');
                $accountInfo['mobile'] = $this->adb->query_result($select_result, 0, 'mobile');
                //电话中间四位隐藏
                if(!empty($accountInfo['mobile'])){
                    $accountInfo['hidemobile'] = substr_replace($accountInfo['mobile'],'****',3,4);
                }
                $accountInfo['wechatuserid'] = $this->adb->query_result($select_result, 0, 'wechatuserid');
            }
        }
        
        return $accountInfo;
    }
}
?>