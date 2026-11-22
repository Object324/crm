<?php
//editor:gyq_120 reason:企业微信增加外挂类  2019/6/10 18:19
class Plug{
    //des:客户授权企业微信小程序的版本是V7.6.7版本，虽然后来升级成V7.7.7,但提醒会有问题
    //更新auth_info.txt中的key
    public function update_authkey(){
        $root_dir = dirname(dirname(dirname(__FILE__)));
        $getWeiXinAuthInfoParams=array();
        $getWeiXinAuthInfoParams['root_directory']=$root_dir.'/';
        $auth_info = getWeiXinAuthInfo($getWeiXinAuthInfoParams);
        $auth_info_arr = json_decode($auth_info,true);
        if(array_key_exists('crm_mini',$auth_info_arr)){
            $auth_info_new[StaticConst::$suite_crm] = $auth_info_arr['crm_mini'];
            file_put_contents($root_dir . '/dataCache/weixin/auth_info.txt',  encryptStringByLabel(json_encode($auth_info_new),'auth_info'));
        }
        $auth_info = getWeiXinAuthInfo($getWeiXinAuthInfoParams);
        echo $auth_info;
    }
}