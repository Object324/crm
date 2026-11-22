<?php
require globalStatic::$root_directory . 'wechatpay/autoload.php';

use WeChatPay\Builder;
use WeChatPay\Crypto\Rsa;
use WeChatPay\Util\PemUtil;
use WeChatPay\Formatter;

class cls_WeiXinPay
{
    // 商户号，假定为`1000100`
    public $merchantId;
    public $instance;
    public $appid;
    public $merchantCertificateSerial;// API证书不重置，商户证书序列号就是个常量
    public $apiv3Key;
    public $merchantPrivateKeyFilePath;
    public $merchantPrivateKeyInstance;
    public $platformCertificateFilePath;
    public $notifyUrl;

    public function __construct($configArr,$configPath,$notifyUrl)
    {
        //支付通知路径
        $this->notifyUrl = $notifyUrl;
        //配置信息 5个 apiKey不用  先不写
        $this->appid = $configArr['appid'];
        $this->merchantId = $configArr['merchantId'];
        $this->merchantCertificateSerial = $configArr['merchantCertificateSerial'];
        $this->apiv3Key = $configArr['apiv3Key'];
        //文件配置信息
        // 商户私钥，文件路径假定为 `/path/to/merchant/apiclient_key.pem`
        //$this->merchantPrivateKeyFilePath = 'file://' . globalStatic::$root_directory . 'WeiXinApp/ldmall/WXCertUtil/cert/apiclient_key.pem';// 注意 `file://` 开头协议不能少
        $this->merchantPrivateKeyFilePath = $configPath['merchantPrivateKeyFilePath'];// 注意 `file://` 开头协议不能少
        // 加载商户私钥
        $this->merchantPrivateKeyInstance = Rsa::from($this->merchantPrivateKeyFilePath, Rsa::KEY_TYPE_PRIVATE);
        // // 也可以使用openssl命令行获取证书序列号
        // // openssl x509 -in /path/to/merchant/apiclient_cert.pem -noout -serial | awk -F= '{print $2}'
        // // 或者从以下代码也可以直接加载
        // // 「商户证书」，文件路径假定为 `/path/to/merchant/apiclient_cert.pem`
        // $merchantCertificateFilePath = 'file:///path/to/merchant/apiclient_cert.pem';// 注意 `file://` 开头协议不能少
        // // 解析「商户证书」序列号
        // $merchantCertificateSerial = PemUtil::parseCertificateSerialNo($merchantCertificateFilePath);
        // 「平台证书」，可由下载器 `./bin/CertificateDownloader.php` 生成并假定保存为 `/path/to/wechatpay/cert.pem`
        //$this->platformCertificateFilePath = 'file://' . globalStatic::$root_directory . 'WeiXinApp/ldmall/WXCertUtil/cert/cert.pem';;// 注意 `file://` 开头协议不能少
        $this->platformCertificateFilePath = $configPath['platformCertificateFilePath'];// 注意 `file://` 开头协议不能少
        // 加载「平台证书」公钥
        $platformPublicKeyInstance = Rsa::from($this->platformCertificateFilePath, Rsa::KEY_TYPE_PUBLIC);
        // 解析「平台证书」序列号，「平台证书」当前五年一换，缓存后就是个常量
        $platformCertificateSerial = PemUtil::parseCertificateSerialNo($this->platformCertificateFilePath);
        // 工厂方法构造一个实例
        $this->instance = Builder::factory(['mchid' => $this->merchantId,
            'serial' => $this->merchantCertificateSerial,
            'privateKey' => $this->merchantPrivateKeyInstance,
            'certs' => [$platformCertificateSerial => $platformPublicKeyInstance,]
        ]);
    }


    /**
     * @param $openid
     * @param $description
     * @param $out_trade_no
     * @param $total
     * @param $attach
     * @return array
     * 获取预付单ID
     */
    public function getPrepayId($openid,$description,$out_trade_no,$total,$attach)
    {
        $total = $total * 100;//价格单位为分
        $total = round($total);
        $total = (int)$total;
        $now = strtotime('+5 min');//交易结束时间  设置五分钟
        $datetime = date(DATE_RFC3339 ,$now);
        try {
            $resp = $this->instance
                ->v3->pay->transactions->jsapi
                ->post(['json' => [
                    'mchid' => $this->merchantId,
                    'out_trade_no' => $out_trade_no,
                    'time_expire'=> $datetime,
                    'appid' => $this->appid,
                    'description' => $description,
                    'notify_url' => $this->notifyUrl,
                    'attach'=>$attach,//附加数据  传输模块名称 用以判断是订单支付还是充值  订单编号等附加信息
                    //'notify_url' => $this->corpurl . 'WeiXinApp/ldmall/notify.php',
                    'amount' => [
                        'total' => $total,
                        'currency' => 'CNY'
                    ],
                    "payer" => [
                        "openid" => $openid
                    ]
                ]]);
            return ['statusCode' => $resp->getStatusCode(), 'data' => $resp->getBody()];
        } catch (\Exception $e) {
            $res = [];
            // 进行错误处理
            $res['msg'] = $e->getMessage();
            if ($e instanceof \GuzzleHttp\Exception\RequestException && $e->hasResponse()) {
                $r = $e->getResponse();
                $res['statusCode'] = $r->getStatusCode();
                $res['data'] = $r->getBody();
                $res['reasonPhrase'] = $r->getReasonPhrase();
            }
            $res['traceAsString'] = $e->getTraceAsString();
            return $res;
        }
    }

    /**
     * @param $prepay_id
     * @return array
     * APIv3小程序/JSAPI调起支付数据签名
     */
    public function getSign($prepay_id)
    {
        $merchantPrivateKeyFilePath = $this->merchantPrivateKeyFilePath;
        $merchantPrivateKeyInstance = Rsa::from($merchantPrivateKeyFilePath);
        $params = [
            'appId' => $this->appid,
            'timeStamp' => (string)Formatter::timestamp(),
            'nonceStr' => Formatter::nonce(),
            'package' => 'prepay_id=' . $prepay_id,
        ];
        $params += ['paySign' => Rsa::sign(
            Formatter::joinedByLineFeed(...array_values($params)),
            $merchantPrivateKeyInstance
        ), 'signType' => 'RSA'];
        return $params;
    }

    /**
     * @param $description
     * @param $out_trade_no
     * @param $total
     * @param $attach
     * @return array
     * 获取native支付的二维码链接
     */
    public function getNativePayCodeUrl($description,$out_trade_no,$total,$attach){
        $total = $total * 100;//价格单位为分
        $total = round($total);
        $total = (int)$total;
        try {
            $resp = $this->instance
                ->v3->pay->transactions->native
                ->post(['json' => [
                    'mchid' => $this->merchantId,
                    'out_trade_no' => $out_trade_no,
                    'appid' => $this->appid,
                    'description' => $description,
                    'notify_url' => $this->notifyUrl,
                    'attach'=>$attach,//附加数据  传输模块名称 用以判断是订单支付还是充值  订单编号等附加信息
                    //'notify_url' => $this->corpurl . 'WeiXinApp/ldmall/notify.php',
                    'amount' => [
                        'total' => $total,
                        'currency' => 'CNY'
                    ]
                ]]);
            return ['statusCode' => $resp->getStatusCode(), 'data' => $resp->getBody()->getContents()];
        } catch (\Exception $e) {
            $res = [];
            // 进行错误处理
            $res['msg'] = $e->getMessage();
            if ($e instanceof \GuzzleHttp\Exception\RequestException && $e->hasResponse()) {
                $r = $e->getResponse();
                $res['statusCode'] = $r->getStatusCode();
                $res['data'] = $r->getBody();
                $res['reasonPhrase'] = $r->getReasonPhrase();
            }
            $res['traceAsString'] = $e->getTraceAsString();
            return $res;
        }
    }
    //将支付链接生成二维码
    public function getNativePayCode($code_url,$filename){
        //生成二维码
        require_once(globalStatic::$root_directory.'marketplateform/phpqrcode/phpqrcode.php');
        $level = 'L';// 纠错级别：L、M、Q、H
        $size = 10;//元素尺寸
        $margin = 1;//边距
        //storage/weixinpay/nativepay 二维码存放位置
        if(!is_dir(globalStatic::$root_directory.'storage/weixinpay/')){
            mkdir(globalStatic::$root_directory.'storage/weixinpay/',0777);
        }
        if(!is_dir(globalStatic::$root_directory.'storage/weixinpay/nativepay/')){
            mkdir(globalStatic::$root_directory.'storage/weixinpay/nativepay/',0777);
        }
        //文件名命名规则:模块名小写+单据id
        if(file_exists(globalStatic::$root_directory.'storage/weixinpay/nativepay/'.$filename.'.png')){
            unlink(globalStatic::$root_directory.'storage/weixinpay/nativepay/'.$filename.'.png');
        }
        $outfile = globalStatic::$root_directory.'storage/weixinpay/nativepay/'.$filename.'.png';
        $saveandprint = false;// true直接输出屏幕  false 保存到文件中
        $QRcode = new QRcode();
        //生成png图片
        $QRcode->png($code_url, $outfile, $level, $size, $margin, false);
        return 'storage/weixinpay/nativepay/'.$filename.'.png';
    }

    //关闭订单 //无返回值
    public function closeNativePayCodeUrl($out_trade_no){
        $resp = $this->instance
            ->v3->pay->transactions->close
            ->post(['json' => [
                'mchid' => $this->merchantId,
                'out_trade_no' => $out_trade_no
            ]]);
        return ['statusCode' => $resp->getStatusCode()];
    }
    /**
     * @param $transaction_id
     * 查单--暂时没有用到
     */
    public function queryOrder($transaction_id)
    {
        $res = $this->instance
            ->v3->pay->transactions->id->{'{transaction_id}'}
            ->getAsync([
                // 查询参数结构
                'query' => ['mchid' => $this->merchantId],
                // uri_template 字面量参数
                'transaction_id' => $transaction_id,
            ])
            ->then(static function ($response) {
                dump($response);
                die;
                // 正常逻辑回调处理
                return ['statusCode' => $response->getStatusCode(), 'data' => $response->getBody()];
            })
            ->otherwise(static function ($e) {
                $data = array();
                // 进行错误处理
                $data['msg'] = $e->getMessage();
                if ($e instanceof \GuzzleHttp\Exception\RequestException && $e->hasResponse()) {
                    $r = $e->getResponse();
                    $data['statusCode'] = $r->getStatusCode();
                    $data['data'] = $r->getBody();
                    $data['reasonPhrase'] = $r->getReasonPhrase();
                }
                $data['traceAsString'] = $e->getTraceAsString();
                return $data;
            })
            ->wait();
        return $res;
    }
}
