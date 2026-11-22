<?php

//获取支付的配置
//appid
//appsecret
//商户号四个参数
class cls_getConfig
{
    public $adb;
    public function __construct()
    {
        global $adb;
        $this->adb = $adb;
    }
    //小程序商城的配置
    public function getShopSetting(){
        $sql = "SELECT * FROM  ld_shop_settings where name in ('InterfaceSettings','MerchantNoSettings')";
        $res = $this->adb->pquery($sql);
        $nums = $this->adb->num_rows($res);
        //{"appid":"111","appsecret":"222","appname":"\u7075\u5f53\u79d1\u6280","custelno":"18852156321"}
        //{"merchantnum":"211","merchantcertificatenum":"111","apikey":"111","apiv3key":"122"}
        $payConfig = array();
        if($nums>0){
            for($i=0;$i<$nums;$i++){
                $input_content = $this->adb->query_result($res,$i,'input_content');
                if(!empty($input_content)){
                    $input_content =  Zend_Json::decode($input_content);
                    foreach($input_content as $k=>$v){
                        switch ($k){
                            case 'appid':$payConfig['appid'] = $v;break;
                            case 'appsecret':$payConfig['appsecret'] = $v;break;
                            case 'appname':$payConfig['appname'] = $v;break;//小程序名称
                            case 'custelno':$payConfig['custelno'] = $v;break;//客服电话
                            case 'sharedescription':$payConfig['sharedescription'] = $v;break;//小程序分享的标题
                            case 'sharepicture':
                                $sharepicture = 'storage/ShopSettings/'.$v;
                                $payConfig['sharepicture'] = $sharepicture;
                                break;//小程序分享的图片
                            case 'displayinvoice':$payConfig['displayinvoice'] = $v;break;//是否启用发票
                            case 'merchantnum':$payConfig['merchantId'] = $v;break;//商户号
                            case 'merchantcertificatenum':$payConfig['merchantCertificateSerial'] = $v;break;//商户证书编号
                            case 'apikey':$payConfig['apikey'] = $v;break;//apikey
                            case 'apiv3key':$payConfig['apiv3key'] = $v;break;//apiv3key
                        }
                    }
                }
            }

        }
        return $payConfig;
    }
    public function getShopSettingKeyPath (){
        return  array(
            'merchantPrivateKeyFilePath'=>'file://' . globalStatic::$root_directory . 'WeiXinApp/ldmall/WXCertUtil/cert/apiclient_key.pem',// 注意 `file://` 开头协议不能少
            'platformCertificateFilePath'=>'file://' . globalStatic::$root_directory . 'WeiXinApp/ldmall/WXCertUtil/cert/cert.pem'// 注意 `file://` 开头协议不能少
        );
    }
    //获取ld_shop_phones,传出所有客服电话，同时加上参数kefuTels，判断是否有详情列表
    public function getShopPhone(){ 
        $payConfig = array();
        $sql = 'select * from ld_shop_phones where status = \'yes\' order by phoneseq asc';
        $results = $this->adb->pquery($sql);
        $phone_nums = $this->adb->num_rows($results);
        $all_phones = [];
        for($i = 0;$i < $phone_nums;$i++){
            $phone = $this->adb->query_result($results,$i,'phone');
            $name = $this->adb->query_result($results,$i,'name');
            $phone_input = array('custelno'=>$phone, 'name'=>$name);
            $all_phones[] = $phone_input;
        }
        $payConfig['phone_nums'] = $phone_nums;
        $payConfig['phones'] = $all_phones;
        if($phone_nums <= 1) $payConfig['kefuTels'] = 'no';
        else $payConfig['kefuTels'] = 'yes';
        return $payConfig;
    }

    //获取二维码收款的设置信息  appid 商户号 apikey apiv3key
    public function getNativePaySetting(){
        global $adb;
        $sql = "SELECT * FROM ld_wx_config where name='weixinpay_setting';";
        $sms_voice_result =$adb->pquery($sql);
        $payConfig = [];
        if($adb->num_rows($sms_voice_result)>0){
            $para_content = $adb->query_result($sms_voice_result,0,'para_content');
            if(!empty($para_content)) {
                $para_content = Zend_Json::decode($para_content);
                foreach($para_content as $k=>$v) {
                    switch ($k) {
                        case 'apptype':
                            $payConfig['apptype'] = $v;
                            break;
                        case 'appid':
                            if(empty($v)){return array();}
                            $payConfig['appid'] = $v;
                            break;
                        case 'merchantnum':
                            if(empty($v)){return array();}
                            $payConfig['merchantId'] = $v;
                            break;//商户号
                        case 'merchantcertificatenum':
                            if(empty($v)){return array();}
                            $payConfig['merchantCertificateSerial'] = $v;
                            break;//商户证书编号
                        case 'apikey':
                            if(empty($v)){return array();}
                            $payConfig['apikey'] = $v;
                            break;//apikey
                        case 'apiv3key':
                            if(empty($v)){return array();}
                            $payConfig['apiv3key'] = $v;
                            break;//apiv3key
                    }
                }
            }
        }
        return $payConfig;
    }
    //获取二维码收款的微信支付证书文件夹
    public function getNativePayKeyPath(){
        //商户证书路径  平台证书路径
        return array(
            'merchantPrivateKeyFilePath'=>'file://' . globalStatic::$root_directory . 'WeiXinApp/weixinPay/WXCertUtil/cert/apiclient_key.pem',// 注意 `file://` 开头协议不能少
            'platformCertificateFilePath'=>'file://' . globalStatic::$root_directory . 'WeiXinApp/weixinPay/WXCertUtil/cert/cert.pem'// 注意 `file://` 开头协议不能少
        );
    }
}