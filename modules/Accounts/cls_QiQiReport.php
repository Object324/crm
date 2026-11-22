<?php

/**
 * User: Dong
 * Project: LINK2ERP
 * Date: 2024/4/17 10:38
 * Description: 企企报表
 */


class cls_qiQiReport
{
    public $configFilePath = 'user_privileges/QiQiReport_Config.php';
    public $defaultConfigFilePath = 'user_privileges/QiQiReport_Config_Default.php';
    public $apiHost = 'https://api2.77hub.com';
    /**
     * @var array
     */
    public $erpInfo;
    /**
     * @var string
     */
    public $reportJson;

    public function __construct()
    {
        global $adb;
    }
    public function checkConfigFile(): bool
    {
        if(file_exists(globalStatic::$root_directory.$this->configFilePath)){
            require_once globalStatic::$root_directory.$this->configFilePath;
            if(QiqiReport_Config::$reportJson && QiqiReport_Config::$openid) return true;
        }else{
            copy(globalStatic::$root_directory.$this->defaultConfigFilePath,globalStatic::$root_directory.$this->configFilePath);
        }
        return false;
    }

    public function loadConfig()
    {
        if($this->checkConfigFile()){
            $this->erpInfo = [
                'openid' => QiqiReport_Config::$openid,
                'secretAccessKey' => QiqiReport_Config::$secretAccessKey,
                'accessKeyId' => QiqiReport_Config::$accessKeyId
            ];
            $this->reportJson = QiQiReport_Config::$reportJson;
            return true;
        }
        return false;
    }
    public function formatResultDataToCrm($data){
        $return = [];
        //表头字段
        $return['header']=[];
        //表体里面的值
        $return['entries']=[];
        //每个字段的宽度
        $return['fieldwidth']=[];
        //总宽度
        $return['total_width']=0;
        //可能用于排序 直接传和表头字段一样数量的share+列号
        $return['headername']=[];

        foreach ($data['corners'][1] as $item){
            $return['header'][] =$item['displayValue'];
        }
        foreach ($data['cols'][1] as $key=> $item){
            $return['header'][] =$data['cols'][0][$key]['displayValue'].$item['displayValue'];
        }

        foreach ($data['rows'] as $key=> $row){
            $tmpRow=[];
            foreach ($row as $item){
                $tmpRow[] = $item['displayValue'];
            }
            if(is_array($data['datas'][$key])){
                $tmpRow= array_merge($tmpRow,$data['datas'][$key]);
            }
            $return['entries'][] = $tmpRow;
        }
        for ($i=0;$i<count($return['header']);$i++){
            $return['headername']['columnname'][]='share'.($i+1);
            $return['headername']['fieldname'][]='share'.($i+1);
        }


        foreach ($data['columns'] as $key =>$item){
            $return['fieldwidth'][]=$item['width'];
            $return['total_width'] += $item['width'];
        }

        $return['navigation']=[
            '共 '.count($data['rows']).' 条'
        ];
        $return['relcount']=count($data['rows']);
        $return['noofrows']=count($data['rows']);



        return $return;
    }


    public function makeGet77ListCondition($erpModule, $fields,$criteriaStr=''): array
    {
        $return = [];
        $return['objectType'] = $erpModule;
        $return['criteriaStr'] =$criteriaStr?:'id is not null';
        $useField = [];
        foreach ($fields as $key => $field) {
            if (strpos($field, '.') !== false) {
                $tmpArr = explode('.', $field);
                if ($useField[$tmpArr[0]]) {
                    $useField[$tmpArr[0]]['fields'][] = $tmpArr[1];
                } else {
                    $useField[$tmpArr[0]] = [
                        "fieldName" => $tmpArr[0],
                        "fields" => [$tmpArr[1]]
                    ];
                }
            } else {
                $useField[$field] = $field;
            }
        }
        $return['fields'] = array_values($useField);
        return $return;
    }


    function get77HubList($data)
    {
        $openId = $this->erpInfo['openid'];
        $secret = $this->erpInfo['secretAccessKey'];
        $accessKeyId = $this->erpInfo['accessKeyId'];
        $region = 'cn-northwest-1';
        $service = 'execute-api';
        $host = $this->apiHost;
        $timestamp = time();
        $method = "POST";
        $path = '/v1/list';
        $currentDateTime = new \DateTime('UTC');
        if (!empty($timestamp)) {
            $currentDateTime->setTimestamp($timestamp);
        }
        //$reqDate = $currentDateTime->format('Ymd');
        $reqDateTime = $currentDateTime->format('Ymd\THis\Z');
        $headers = [];
        $headers['Content-Type'] = "application/json";
        $headers['Access-Key-Id'] = $accessKeyId;
        $headers['Open-Id'] = $openId;
        $headers['X-Amz-Date'] = $reqDateTime;
        $headers['host'] = str_replace(["https://", "http://"], '', $host);
        $str = str_replace('"', '\"', json_encode($data));
        $bodyContent = '{"json":' . '"' . $str . '"}';
        $AwsSignUtils = new AwsSignatureV4();
        $signForHeader = $AwsSignUtils->geneSignForHeader($region, $service, $accessKeyId, $secret, $timestamp, $method, $path, null, $headers, $bodyContent);
        $headers['Authorization'] = $signForHeader;
        $requestHeader = [];
        foreach ($headers as $k => $v) {
            $requestHeader[] = $k . ': ' . $v;
        }

        $result = $this->http($host . $path, $bodyContent, [], $requestHeader);

        return $result;
    }
    //通过客户编码获取联系人信息
    function get77CustomerContants($customerId)
    {
        $erpModule='Customer';
        $fields = ['id','code','name','contacts.id','contacts.name','contacts.mobile'];
        $criteriaStr = "id = '$customerId'";
        $param = $this->makeGet77ListCondition($erpModule, $fields,$criteriaStr);
        $result = $this->get77HubList($param);
        $result = json_decode(json_decode($result, true)['json'], true);
        return $result['data']['list'][0];
    }

    public function getCrmKid($focus)
    {
        global  $adb;
        $sql = 'select kis_id from ld_account where accountid = ' .$focus->id;
        $result = $adb->pquery($sql);
        return $adb->query_result($result,0,0);
    }

    public function get77ReportData($focus)
    {
        $return = [];
        if($this->loadConfig()){
            $erpId = $this->getCrmKid($focus);
            if(!$erpId) return $return;
            //$customerInfo = $this->get77CustomerContants($erpId);
            //if(!$customerInfo)return $return;
            $json = str_replace('##?##',$erpId,$this->reportJson);
            $postArr = json_decode($json,true);
            $result = $this->get77Report($postArr);
            //echo json_encode($result['data'],256);die;
            if($result['data']){
                $return = $this->formatResultDataToCrm($result['data']);
            }

        }else{

        }
        return $return;
    }
    public function get77Report($data)
    {
        $path = '/v1/reportdefinition';
        $method = "POST";
        $openId = $this->erpInfo['openid'];
        $secret = $this->erpInfo['secretAccessKey'];
        $accessKeyId = $this->erpInfo['accessKeyId'];
        $region = 'cn-northwest-1';
        $service = 'execute-api';
        $host = $this->apiHost;
        $timestamp = time();
        $currentDateTime = new \DateTime('UTC');
        if (!empty($timestamp)) {
            $currentDateTime->setTimestamp($timestamp);
        }
        //$reqDate = $currentDateTime->format('Ymd');
        $reqDateTime = $currentDateTime->format('Ymd\THis\Z');
        $headers = [];
        $headers['Content-Type'] = "application/json";
        $headers['Access-Key-Id'] = $accessKeyId;
        $headers['Open-Id'] = $openId;
        $headers['X-Amz-Date'] = $reqDateTime;
        $headers['host'] = str_replace(["https://", "http://"], '', $host);
        $str = str_replace('"', '\"', json_encode($data));
        $bodyContent = '{"params":' . '"' . $str . '"}';
        $AwsSignUtils = new AwsSignatureV4();
        $signForHeader = $AwsSignUtils->geneSignForHeader($region, $service, $accessKeyId, $secret, $timestamp, $method, $path, null, $headers, $bodyContent);
        $headers['Authorization'] = $signForHeader;
        $requestHeader = [];
        foreach ($headers as $k => $v) {
            $requestHeader[] = $k . ': ' . $v;
        }
        $result = $this->http($host . $path, $bodyContent, [], $requestHeader, 'data', $method);

        $result = json_decode(json_decode($result, true)['data'], true);
        return $result;
    }





    function zget($var, $key, $valueWhenNone = false, $valueWhenExists = false)
    {
        if (!is_array($var) and !is_object($var)) return false;

        $type = is_array($var) ? 'array' : 'object';
        $checkExists = $type == 'array' ? isset($var[$key]) : isset($var->$key);

        if ($checkExists) {
            if ($valueWhenExists !== false) return $valueWhenExists;
            return $type == 'array' ? $var[$key] : $var->$key;
        }

        if ($valueWhenNone !== false) return $valueWhenNone;
        return $key;
    }

    public function http($url, $data = null, $options = array(), $headers = array(), $dataType = 'data', $method = 'POST')
    {

        if (!is_array($headers)) $headers = (array)$headers;
        $headers[] = "API-RemoteIP: " . $this->zget($_SERVER, 'REMOTE_ADDR', '');
        if ($dataType == 'json') {
            $headers[] = 'Content-Type: application/json;charset=utf-8';
            if (!empty($data)) $data = json_encode($data);
        }

        $curl = curl_init();
        if ($method === 'PUT') {
            curl_setopt($curl, CURLOPT_CUSTOMREQUEST, 'PUT'); //定义请求类型，必须为大写
        }
        curl_setopt($curl, CURLOPT_HTTP_VERSION, CURL_HTTP_VERSION_1_0);
        curl_setopt($curl, CURLOPT_USERAGENT, 'Sae T OAuth2 v0.1');
        curl_setopt($curl, CURLOPT_CONNECTTIMEOUT, 30);
        curl_setopt($curl, CURLOPT_TIMEOUT, 30);
        curl_setopt($curl, CURLOPT_RETURNTRANSFER, TRUE);
        curl_setopt($curl, CURLOPT_ENCODING, "");
        curl_setopt($curl, CURLOPT_SSL_VERIFYPEER, FALSE);
        curl_setopt($curl, CURLOPT_SSL_VERIFYHOST, FALSE);
        curl_setopt($curl, CURLOPT_IPRESOLVE, CURL_IPRESOLVE_V4);
        curl_setopt($curl, CURLOPT_HEADER, FALSE);
        curl_setopt($curl, CURLINFO_HEADER_OUT, TRUE);
        curl_setopt($curl, CURLOPT_HTTPHEADER, $headers);
        curl_setopt($curl, CURLOPT_URL, $url);

        if (!empty($data)) {
            if (is_object($data)) $data = (array)$data;
            curl_setopt($curl, CURLOPT_POST, true);
            curl_setopt($curl, CURLOPT_POSTFIELDS, $data);
        }

        if ($options) curl_setopt_array($curl, $options);
        $response = curl_exec($curl);
        $errors = curl_error($curl);

        curl_close($curl);

        $logFile = 'saas.' . date('Ymd') . '.log.php';
        if (!file_exists($logFile)) file_put_contents($logFile, '<?php die(); ?' . '>');

        $fh = @fopen($logFile, 'a');
        if ($fh) {
            fwrite($fh, date('Ymd H:i:s') . ": " . 'test' . "\n");
            fwrite($fh, "url:    " . $url . "\n");
            if (!empty($data)) fwrite($fh, "data:   " . print_r($data, true) . "\n");
            fwrite($fh, "results:" . print_r($response, true) . "\n");
            if (!empty($errors)) fwrite($fh, "errors: " . $errors . "\n");
            fclose($fh);
        }

        return $response;
    }


}













class AwsSignatureV4
{

    const ISO8601_BASIC = 'Ymd\THis\Z';
    //const AMZ_CONTENT_SHA256_HEADER = 'X-Amz-Content-Sha256';
    const  AWS_CRYPTO_TYPE = 'AWS4-HMAC-SHA256';
    const  AWS4_REQUEST    = "aws4_request";


    public function geneSignForHeader($region, $service, $accessKeyId, $secret, $timestamp, $method, $path,
        $query, $headers, $body
    )
    {

        $signature = $this->sign($region, $service, $secret, $timestamp, $method, $path, $query, $headers, $body);

        $authorizationHeader = array();
        $authorizationHeader[] = 'Credential=' . $accessKeyId . '/' . $this->getCredentialScope($timestamp, $region, $service);
        $authorizationHeader[] = 'SignedHeaders=' . $this->getSignedHeaders($headers);
        $authorizationHeader[] = 'Signature=' . ($signature);
        $authorizationHeaderStr = self::AWS_CRYPTO_TYPE . ' ' . implode(',', $authorizationHeader);
        return $authorizationHeaderStr;

    }


    /**
     * @param $region
     * @param $service
     * @param $accessKeyId
     * @param $secret
     * @param $timestamp
     * @param $method
     * @param $path
     * @param $query
     * @param $headers
     * @param $body
     * @return string
     */
    public function sign($region, $service, $secret,
        $timestamp, $method, $path, $query, $headers, $body): string
    {
        //规范请求
        $hashedCanonicalRequest = $this->getHashedCanonicalRequest($method, $path, $query, $headers, $body);
        //待签字符串
        $stringToSign = $this->getStringToSign($timestamp, $hashedCanonicalRequest, $region, $service);
        // 派生签名秘钥
        $getSignatureKey = $this->getSignatureKey($timestamp, $secret, $region, $service);
        // 计算签名
        return hash_hmac('sha256', $stringToSign, $getSignatureKey);
    }


    //创建规范请求的hash-256结果
    public function getHashedCanonicalRequest($method, $path, $querys = '', $headers, $body)
    {

        $canonicalHeadersStr = $this->getCanonicalQueryString($headers);
        $signedHeaders = $this->getSignedHeaders($headers);

        if ($method == 'GET') {
            $requestHashedPayload = hash('sha256', '');
        } else {
            $requestHashedPayload = hash('sha256', $body);
        }

        $canonicalRequest = array();
        $canonicalRequest[] = strtoupper($method); //请求方法
        $canonicalRequest[] = $path; // 规范 URI 参数
        $canonicalRequest[] = $this->getCanonicalURI($querys);//$querys; //规范查询字符串; 暂时为空 @todo 不支持 getCanonicalURI
        $canonicalRequest[] = $canonicalHeadersStr;//请求头拼接的字符串
        $canonicalRequest[] = $signedHeaders; //需要签名的header
        $canonicalRequest[] = $requestHashedPayload; //内容
        $requestCanonicalRequest = implode("\n", $canonicalRequest);
        $requestCanonicalRequest = iconv("UTF-8", "UTF-8", $requestCanonicalRequest);
        $requestHashedCanonicalRequest = hash('sha256', $requestCanonicalRequest);
//        echo '<br/>创建规范请求---------<br/>';
//        echo '<pre>';
//        echo $requestCanonicalRequest;
//        echo '</pre>';
        return $requestHashedCanonicalRequest;

    }

    //step 2：在 Signature Version 4 中创建待签字符串

    /**
     * 拼接请求头
     *   请将所有标头名称转换为小写形式并删除前导空格和尾随空格。将标头值中的连续空格转换为单个空格。
     *    然后对标头进行排序
     * @param $headers
     * @return string
     */

    public function getCanonicalQueryString($headers)
    {
        $headersStr = '';
        $newHeaders = $this->convertHeaders($headers);
        ksort($newHeaders);
        foreach ($newHeaders as $k => $v) {
            $headersStr .= $k . ':' . $v . "\n";
        }
        return $headersStr;
    }

    /**
     * 将所有key去除头尾空格并转小写，将所有value去除头尾空格并将连续空格转换为单个空格
     * @param $headers
     * @return array
     */
    private function convertHeaders($headers)
    {
        $newHeaders = [];
        foreach ($headers as $key => $v) {
            $newHeaders[strtolower($key)] = preg_replace('/\s\s+/', ' ', trim($v));
        }
        return $newHeaders;
    }

    /**
     * 获取已签名的标头
     *
     * @param headers
     * @return
     */
    private function getSignedHeaders($headers)
    {

        $headers = $this->convertHeaders($headers);
        ksort($headers);
        return implode(';', array_keys($headers));
    }

    /**
     * 查询参数名称自然排序，拼接成字符串
     * <pre>
     *   /list?param1=1&params2=2&key=1
     *
     *   key=1&
     *   param1=1&
     *   param2=2
     *
     * </pre>
     *
     * @param query
     * @return
     */
    private function getCanonicalURI($query)
    {
        parse_str($query, $arr);
        ksort($arr);
        return http_build_query($arr);
        //Action=ListUsers&Version=2010-05-08
    }

    public function getStringToSign($timestamp, $hashedCanonicalRequest, $regionName, $service)
    {

        $currentDateTime = new \DateTime('UTC');
        $currentDateTime->setTimestamp($timestamp);
        // $reqDate = $currentDateTime->format('Ymd');
        $reqDateTime = $currentDateTime->format('Ymd\THis\Z');

        /*
        StringToSign =
        Algorithm + \n +
        RequestDateTime + \n +
        CredentialScope + \n +
        HashedCanonicalRequest
        */
        $credentialScopeStr = $this->getCredentialScope($timestamp, $regionName, $service);

        $stringToSign = self::AWS_CRYPTO_TYPE . "\n";
        $stringToSign .= $reqDateTime . "\n";
        $stringToSign .= $credentialScopeStr . "\n"; //追加凭证范围值
        $stringToSign .= $hashedCanonicalRequest;
        return $stringToSign;


    }

    /**
     * 凭证值范围
     *
     * @param $timestamp  时间戳
     * @param $regionName 访问区域
     * @param $service    服务
     * @return String
     */
    private function getCredentialScope($timestamp, $regionName, $service): string
    {

        $currentDateTime = new \DateTime('UTC');
        $currentDateTime->setTimestamp($timestamp);
        $reqDate = $currentDateTime->format('Ymd');
        return $reqDate . '/' . $regionName . '/' . $service . '/' . self::AWS4_REQUEST;
    }

    /**
     *  任务 3-1： 派生签名密钥
     *
     * @param $timestamp
     * @param $secretKey
     * @param $region
     * @param $service
     * @return string
     */
    public function getSignatureKey($timestamp, $secretKey, $region, $service)
    {
        $currentDateTime = new \DateTime('UTC');
        $currentDateTime->setTimestamp($timestamp);
        $reqDate = $currentDateTime->format('Ymd');
        $kDate = hash_hmac('sha256', $reqDate, 'AWS4' . $secretKey, true);
        $kRegion = hash_hmac('sha256', $region, $kDate, true);
        $kService = hash_hmac('sha256', $service, $kRegion, true);
        $kSigning = hash_hmac('sha256', self::AWS4_REQUEST, $kService, true);
        //$kSigning = hash_hmac('sha256', self::AWS4_REQUEST, $kService);
        return $kSigning;
    }

}
