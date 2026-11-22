<?php
class LdMallWeChatUser extends LdMall
{

    //登出  解除客户与微信用户的绑定
    //前端要清除登录缓存  跳转登录页
    public function Logout(){
        $open_id = $_REQUEST['open_id'];
        $update_sql = "update ld_wechatuser set accountid=0 where open_id=?";
        $this->adb->pquery($update_sql,array($open_id));
        return array(1, array(), 'success');
    }


}