<?php

class SmsSender
{
    public $adb;
    public $rootdir;
    public $appid;//短信配置信息  appid appkey sign 客服电话
    public $appkey;
    public $sign;
    public $service_tel;
    public $sender;
    public function __construct($adb,$rootdir)
    {
        $this->adb = $adb;
        $this->rootdir = $rootdir;
        $SMSarray = GetSMSAutograph();
        $this->appid = $SMSarray['account_name'];
        $this->appkey = $SMSarray['account_pwd'];
        $this->sign = $SMSarray['autograph'];
        $this->service_tel = $SMSarray['service_tel'];
        crm_load_class_file('SmsMultiSender','include/utils');
        $this->sender = new SmsMultiSender($this->appid,$this->appkey);
    }
    public function index()
    {
        // 判断手机号是否有被注册过
        $apply_phone  = $_REQUEST['mobile'];
        $phone_sql = "select 1 from ld_ambassador where apply_phone=? and deleted=0";
        $phone_res = $this->adb->pquery($phone_sql,[$apply_phone]);
        $phone_nums = $this->adb->num_rows($phone_res);
        if($phone_nums>0){
            return ['code'=>-1,'data'=>"该手机号码已经申请过推广大使！"];
        }
        // 需要发送短信的手机号码 格式如[15001773008,15100000000]
        $phoneNumbers = Array();
        $phoneNumbers[0] = $_REQUEST['mobile'];
        $code = $_REQUEST['code']; // 验证码
        $getTimes = $_REQUEST['times'];//验证码有效时间
        if($getTimes > 3){
            $times = $getTimes - 3;
            $times .= "小时";
        }else{
            $times = $getTimes * 15;
            $times .= "分钟";
        }
        // 群发
        try {
            //短信内容
            $receivecontent = $code."为您的".$this->sign."验证码，请在".$times."内完成输入。如非本人操作，请忽略。";
            if(!empty($this->service_tel)){
                $receivecontent .= '详询客服'.$this->service_tel;
            }
            $receivecontent .= '【'.$this->sign.'】';
            $result = $this->sender->send(0, "86", $phoneNumbers,$receivecontent, "", "");
            $rsp = json_decode($result,true);

            if(isset( $rsp['result'])&&$rsp['result']==0){
                return ['code'=>1,'data'=>"成功"];
            }else{
                $tip = '发送验证码失败，请检查CRM服务器系统设置-短信账号设置';
                //$error_msg = array('detail'=>array(0=>array('result'=>-1,'errmsg'=>$tip)));
                return ['code'=>-1,'data'=>$tip];
            }
        } catch(\Exception $e) {
            var_dump($e);
        }
        exit();
    }
}