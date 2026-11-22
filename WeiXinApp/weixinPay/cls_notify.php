<?php

/**
 * Class cls_notify
 * 公用的通知处理方法
 */
require globalStatic::$root_directory.'wechatpay/autoload.php';
use WeChatPay\Crypto\Rsa;
use WeChatPay\Crypto\AesGcm;
use WeChatPay\Formatter;

class cls_notify
{
    public $configPath;
    public $configArr;
    public function __construct($configArr,$configPath){
        $this->configArr = $configArr;//小程序商城配置
        $this->configPath = $configPath;//商户证书路径  平台证书路径
    }
    public function getNotifyArr(){
        try {
        /**中间通过销售助手转发需要这段代码
        $serverinfo = $_REQUEST['serverinfo'];//请求头信息
        $serverinfo = json_decode($serverinfo,true);
        //$inBody = '';// 请根据实际情况获取，例如: file_get_contents('php://input');
        $inBody = $_REQUEST['payback'];
         **/
        $serverinfo = $_REQUEST['serverinfo'];//请求头信息
        $serverinfo = json_decode($serverinfo,true);
        $inBody = $_REQUEST['payback'];

        $inWechatpaySignature = $serverinfo['HTTP_WECHATPAY_SIGNATURE'];// 请根据实际情况获取
        $inWechatpayTimestamp = $serverinfo['HTTP_WECHATPAY_TIMESTAMP'];// 请根据实际情况获取
        $inWechatpaySerial = $serverinfo['HTTP_WECHATPAY_SERIAL'];// 请根据实际情况获取
        $inWechatpayNonce = $serverinfo['HTTP_WECHATPAY_NONCE'];// 请根据实际情况获取
        $apiv3Key = $this->configArr['apiv3key'];// 在商户平台上设置的APIv3密钥

        //$platformCertificateFilePath = 'file://'.globalStatic::$root_directory.'WeiXinApp/ldmall/WXCertUtil/cert/cert.pem';// 注意 `file://` 开头协议不能少
        $platformCertificateFilePath = $this->configPath['platformCertificateFilePath'];// 注意 `file://` 开头协议不能少
        // 加载「平台证书」公钥
        $platformPublicKeyInstance = Rsa::from($platformCertificateFilePath, Rsa::KEY_TYPE_PUBLIC);

        // 检查通知时间偏移量，允许5分钟之内的偏移 300
        $timeOffsetStatus = 300 >= abs(Formatter::timestamp() - (int)$inWechatpayTimestamp);

        $verifiedStatus = Rsa::verify(
        //构造验签名串
            Formatter::joinedByLineFeed($inWechatpayTimestamp, $inWechatpayNonce, $inBody),
            $inWechatpaySignature,
            $platformPublicKeyInstance
        );

        $inBodyArray = Zend_Json::decode($inBody);
        if ($timeOffsetStatus && $verifiedStatus) {

            // 转换通知的JSON文本消息为PHP Array数组
            //$inBodyArray = (array)json_decode($inBody, true);
            // 使用PHP7的数据解构语法，从Array中解构并赋值变量
            ['resource' => [
                'ciphertext'      => $ciphertext,
                'nonce'           => $nonce,
                'associated_data' => $aad
            ]] = $inBodyArray;
            // 加密文本消息解密
            $inBodyResource = AesGcm::decrypt($ciphertext, $apiv3Key, $nonce, $aad);

            // 把解密后的文本转换为PHP Array数组
            $inBodyResourceArray = (array)json_decode($inBodyResource, true);
            //数组示例
            //$inBodyResourceArray = Array (
            //        [mchid] => 1614866164
            //        [appid] => wx17e39c2922581cd9
            //        [out_trade_no] => SHXX-20211011-158
            //        [transaction_id] => 4200001148202110118733732358
            //        [trade_type] => JSAPI
            //        [trade_state] => SUCCESS
            //        [trade_state_desc] => 支付成功
            //        [bank_type] => OTHERS
            //        [attach] =>
            //        [success_time] => 2021-10-11T14:40:48+08:00
            //        [payer] => Array ( [openid] => opBfU4uzpKghKigdVgMHgXISpUwc )
            //        [amount] => Array ( [total] => 1 [payer_total] => 1 [currency] => CNY [payer_currency] => CNY )
            //    )
            return $inBodyResourceArray;
        }
        return [];
        }catch (Exception $e){
            file_put_contents('ldmall_error.txt','</br>'.date('Y-m-d H:i:s').'报错信息'.$e->getMessage(),FILE_APPEND);
        }
    }

    //扫码付款即native支付解析回调数据 zxm 20230423
    public function getNativeNotifyArr(){
        try {
            $inBody = file_get_contents('php://input');// 请根据实际情况获取，例如: file_get_contents('php://input');
            $inWechatpaySignature = $_SERVER['HTTP_WECHATPAY_SIGNATURE'];// 请根据实际情况获取
            $inWechatpayTimestamp = $_SERVER['HTTP_WECHATPAY_TIMESTAMP'];// 请根据实际情况获取
            $inWechatpaySerial = $_SERVER['HTTP_WECHATPAY_SERIAL'];// 请根据实际情况获取
            $inWechatpayNonce = $_SERVER['HTTP_WECHATPAY_NONCE'];// 请根据实际情况获取

            $apiv3Key = $this->configArr['apiv3key'];// 在商户平台上设置的APIv3密钥

            //$platformCertificateFilePath = 'file://'.globalStatic::$root_directory.'WeiXinApp/ldmall/WXCertUtil/cert/cert.pem';// 注意 `file://` 开头协议不能少
            $platformCertificateFilePath = $this->configPath['platformCertificateFilePath'];// 注意 `file://` 开头协议不能少
            // 加载「平台证书」公钥
            $platformPublicKeyInstance = Rsa::from($platformCertificateFilePath, Rsa::KEY_TYPE_PUBLIC);

            // 检查通知时间偏移量，允许5分钟之内的偏移 300
            $timeOffsetStatus = 300 >= abs(Formatter::timestamp() - (int)$inWechatpayTimestamp);

            $verifiedStatus = Rsa::verify(
            //构造验签名串
                Formatter::joinedByLineFeed($inWechatpayTimestamp, $inWechatpayNonce, $inBody),
                $inWechatpaySignature,
                $platformPublicKeyInstance
            );

            $inBodyArray = Zend_Json::decode($inBody);
            if ($timeOffsetStatus && $verifiedStatus) {

                // 转换通知的JSON文本消息为PHP Array数组
                //$inBodyArray = (array)json_decode($inBody, true);
                // 使用PHP7的数据解构语法，从Array中解构并赋值变量
                ['resource' => [
                    'ciphertext'      => $ciphertext,
                    'nonce'           => $nonce,
                    'associated_data' => $aad
                ]] = $inBodyArray;
                // 加密文本消息解密
                $inBodyResource = AesGcm::decrypt($ciphertext, $apiv3Key, $nonce, $aad);
                // 把解密后的文本转换为PHP Array数组
                $inBodyResourceArray = (array)json_decode($inBodyResource, true);
                //数组示例
                //$inBodyResourceArray = Array (
                //        [mchid] => 1614866164
                //        [appid] => wx17e39c2922581cd9
                //        [out_trade_no] => SHXX-20211011-158
                //        [transaction_id] => 4200001148202110118733732358
                //        [trade_type] => JSAPI
                //        [trade_state] => SUCCESS
                //        [trade_state_desc] => 支付成功
                //        [bank_type] => OTHERS
                //        [attach] =>
                //        [success_time] => 2021-10-11T14:40:48+08:00
                //        [payer] => Array ( [openid] => opBfU4uzpKghKigdVgMHgXISpUwc )
                //        [amount] => Array ( [total] => 1 [payer_total] => 1 [currency] => CNY [payer_currency] => CNY )
                //    )
                return $inBodyResourceArray;
            }
            return [];
        }catch (Exception $e){
            file_put_contents('ldmall_error.txt','</br>'.date('Y-m-d H:i:s').'报错信息'.$e->getMessage(),FILE_APPEND);
        }
    }
}