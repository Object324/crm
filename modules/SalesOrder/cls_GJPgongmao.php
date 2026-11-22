<?php

/**
 * 管家婆 工贸版
 */


class cls_GJPgongmao
{
    public $configFilePath = 'user_privileges/GJPgongmaoReport_Config.php';
    public $defaultConfigFilePath = 'user_privileges/GJPgongmaoReport_Config_Default.php';
    public $apiHost = 'http://api.cmgrasp.com/CMGraspApi/GateWay';
    /**
     * @var array
     */
    public $erpInfo;
    /**
     * @var string
     */
    public $reportJson;
    /**
     * @var string
     */
    public $cachePrefix;

    public function __construct()
    {
        global $adb;
        $this->cachePrefix = 'guanjiapogongmao_1';
    }

    public function getErpData($focus)
    {
        $result = [];
        $status = $this->loadConfig();
        if ($status) {

            $erpModule = $_REQUEST['erpModuleName'];
            if ($erpModule == 'erpOutboundOrder') {
                $erpModule = 'DlyOutDepotData';
            } elseif ($erpModule == 'erpCashBill') {
                $erpModule = 'DlySettleGatheringData';
            } else {
                $erpModule = 'DlyInvoiceData';
            }

            $numberField = $this->erpInfo['BillNoFieldName'] ?: $focus->table_code;
            $paramArr['Number'] = $focus->column_fields[$numberField];
            $result = $this->getErpLists($erpModule, $paramArr);
        }
        $result = $this->formatResultDataToCrm($_REQUEST['erpModuleName'], $result);
        if (!$status) {
            $result['NoRecords_CONTENT'] = '<span style="color:red">功能未配置, 请访问user_privileges/GJPgongmaoReport_Config.php配置所需参数</span>';
        }
        return $result;
    }

    public function loadConfig()
    {
        if ($this->checkConfigFile()) {
            $this->erpInfo = [
                'appkey' => GJPgongmaoReport_Config::$AppKey,
                'appsecret' => GJPgongmaoReport_Config::$SercretKey,
                'userid' => GJPgongmaoReport_Config::$UserId,
                'dbname' => GJPgongmaoReport_Config::$DbName,
                'BillNoFieldName' => GJPgongmaoReport_Config::$BillNoFieldName,
                'OutboundOrderHeadFields' => GJPgongmaoReport_Config::$OutboundOrderHeadFields,
                'OutboundOrderEntryFields' => GJPgongmaoReport_Config::$OutboundOrderEntryFields,
                'CashBillHeadFields' => GJPgongmaoReport_Config::$CashBillHeadFields,

                'InvoiceHeadFields' => GJPgongmaoReport_Config::$InvoiceHeadFields,
                'InvoiceEntryFields' => GJPgongmaoReport_Config::$InvoiceEntryFields,
            ];
            return true;
        }
        return false;
    }

    public function checkConfigFile(): bool
    {
        if (file_exists(globalStatic::$root_directory . $this->configFilePath)) {
            require_once globalStatic::$root_directory . $this->configFilePath;
            if (GJPgongmaoReport_Config::$AppKey) return true;
        } else {
            copy(globalStatic::$root_directory . $this->defaultConfigFilePath, globalStatic::$root_directory . $this->configFilePath);
        }
        return false;
    }

    public function getErpLists(string $erpModuleName, array $paramArr = []): array
    {
        $pageSize = 200;
        $pageIndex = 1;
        if (!$paramArr['pageindex']) $paramArr['pageindex'] = $pageIndex;
        if (!$paramArr['pagesize']) $paramArr['pagesize'] = $pageSize;

        $return = [];
        $result = $this->getErpList($erpModuleName, $paramArr);
        $return = $result->response;
        while ($result->pagetotal > $pageIndex * $pageSize) {
            $pageIndex++;
            $paramArr['pageindex'] = $pageIndex;
            $paramArr['pagesize'] = $pageSize;
            $result = $this->getErpList($erpModuleName, $paramArr);
            $return = array_merge($return, $result->response);
        }

        return $return;
    }

    public function getErpList($erpModuleName, $paramArr)
    {
        $apiUrl = $this->gatApiUrlAndParam()->ApiServerAddress;
        $ApiParam = $this->gatApiUrlAndParam()->ApiParam;
        $mobile = $this->gatApiUrlAndParam()->GraspCloudMobile ?: 0;
        $serviceid = $this->gatApiUrlAndParam()->GraspCloudServerId ?: 0;

        $postArr = [
            'managename' => 'GraspCMServerApi.dll',
            'dbname' => $this->erpInfo['dbname'],
            'paramkey' => $erpModuleName,
            'paramjson' => json_encode($paramArr, 256),
            'apiparam' => $ApiParam,
            'apitype' => 'query',
            'mobile' => $mobile,
            'serviceid' => $serviceid,
            'interiorapi' => 1,
        ];

        $postArr['sign'] = $this->makeSignStr($postArr, $this->getSignKey()->SignKey);

        $header = array(
            'application/x-www-form-urlencoded;Charset=UTF-8',
        );
        $resultObj = $this->curl_post($apiUrl, $postArr, 'POST', $header);
        return $resultObj;
    }

    public function gatApiUrlAndParam()
    {
        $key = $this->cachePrefix . '_ApiUrlAndParam';
        $return = Cache($key);
        if (empty($return) || $return->expirationTime <= time()) {
            $apiUrl = 'http://api.cmgrasp.com/CMGraspApi/GateWay';
            $postArr = [
                'MethodName' => 'graspcm.cmapi.getcustomerapiurl',
                'AppKey' => $this->erpInfo['appkey'],
                'UserId' => $this->erpInfo['userid'],
                'InvalidTime' => date('Y-m-d H:i:s'),
                'RandamStr' => $this->randomString(),
            ];

            $postArr['SignStr'] = $this->makeSignStr($postArr, $this->erpInfo['appsecret']);
            $postArrp['DbName'] = $this->erpInfo['dbname'];

            $resultObj = $this->curl_post($apiUrl, json_encode($postArr, 256));
            $retObj = json_decode(stripslashes($resultObj->RetMsg));

            if ($retObj->ApiServerAddress) {
                /*   $retObj->ApiServerAddress;
                  $retObj->ApiParam;
                   $retObj->GraspCloud;
                   $retObj->GraspCloudMobile;
                   $retObj->GraspCloudServerId;*/
                $retObj->expirationTime = time() + 3600 * 23;
                Cache($key, $retObj);
                $return = $retObj;
            }
        }
        return $return;
    }

    /**
     * Name: 生成随机字符串
     * User: Dong
     * Date: 2024/9/4 15:35
     */
    public function randomString(int $length = 10): string
    {
        $characters = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
        $randomString = '';
        for ($i = 0; $i < $length; $i++) {
            $randomString .= $characters[random_int(0, strlen($characters) - 1)];
        }
        return $randomString;
    }

    /**
     * Name: 1
     * User: Dong
     * Date: 2024/9/4 15:39
     * @param array $arr
     * @return string
     */
    public function makeSignStr(array $arr, string $lastString): string
    {
        if (!$arr['InvalidTime'] && $arr['MethodName']) return '';
        if ($arr['InvalidTime']) {
            $arr['InvalidTime'] = date('YmdHis', strtotime($arr['InvalidTime']));
        }
        ksort($arr);
        $encryptStr = '';
        foreach ($arr as $key => $value) {
            if ($key == 'MethodName') continue;
            $encryptStr .= $key . $value;
        }
        $encryptStr .= $lastString;
        //       dd($arr,$lastString,2222,$encryptStr);
        return md5($encryptStr);
    }

    /**
     * Name: 发起请求
     * User: Dong
     * Date: 2024/9/4 16:01
     * @param string $url
     * @param string $data
     * @param string $method
     * @param array $header
     * @return object
     * @throws Exception
     */
    public function curl_post($url, $data = '', $method = 'POST', $header = array())
    {
        $curl = curl_init();
        curl_setopt($curl, CURLOPT_URL, $url);
        if (substr($url, 0, 5) == 'https') {
            curl_setopt($curl, CURLOPT_SSL_VERIFYPEER, false);    //SSL 报错时使用
            curl_setopt($curl, CURLOPT_SSL_VERIFYHOST, false);    //SSL 报错时使用
        }
        if ($method != "GET") {
            if ($method == 'POST') {
                curl_setopt($curl, CURLOPT_POST, true); //请求方式为post请求
            }
            if ($method == 'PUT' || strtoupper($method) == 'DELETE') {
                curl_setopt($curl, CURLOPT_CUSTOMREQUEST, $method); //设置请求方式
            }
            curl_setopt($curl, CURLOPT_POSTFIELDS, $data); //请求数据
        }
        if (empty($header)) $header = array('Content-Type: application/json');
        curl_setopt($curl, CURLOPT_HTTPHEADER, $header);
        curl_setopt($curl, CURLOPT_RETURNTRANSFER, 1);
        // 在尝试连接时等待的秒数
        curl_setopt($curl, CURLOPT_CONNECTTIMEOUT, 10);
        // 最大执行时间
        curl_setopt($curl, CURLOPT_TIMEOUT, 240);

        $result = curl_exec($curl);
        $curlErrorNo = curl_errno($curl);
        $curlError = curl_error($curl);
        curl_close($curl);
        if ($result === false && $curlError) {
            //dump(debug_backtrace());
            ConvertTojsonString(-11, __FILE__ . ':' . __LINE__ . '  ' . $url . '  curl_errno:' . $curlErrorNo . '   curl_error:' . $curlError, 'CURL ERROR');
        }
        $result = json_decode($result);
        if ($result->RetCode != 0) {
            throw new Exception($url . $result->RetMsg);
        }
        if ($result->code < 0) {
            throw new Exception($url . $result->message);
        }
        return $result;
    }

    /**
     * Name: 获取接口所需的SignKey
     * User: Dong
     * Date: 2024/9/4 15:26
     */
    public function getSignKey(bool $type = false): object
    {
        $key = $this->cachePrefix . '_signkey';
        $return = Cache($key);
        if (!$return || $type || $return->expirationTime <= time()) {
            $apiUrl = 'http://api.cmgrasp.com/CMGraspApi/GateWay';
            $postArr = [
                'MethodName' => 'graspcm.cmapi.getsignstr',
                'AppKey' => $this->erpInfo['appkey'],
                'InvalidTime' => date('Y-m-d H:i:s'),
                'RandamStr' => $this->randomString(),
            ];
            $postArr['SignStr'] = $this->makeSignStr($postArr, $this->erpInfo['appsecret']);
            $resultObj = $this->curl_post($apiUrl, json_encode($postArr, 256));
            $retObj = json_decode(stripslashes($resultObj->RetMsg));
            if ($retObj->SignKey) {

                $retObj->expirationTime = time() + 3600 * 23;
                $return = $retObj;
                Cache($key, $return);
            }
        }
        return $return;
    }

    public function formatResultDataToCrm($erpModule, $data)
    {
        if ($erpModule == 'erpOutboundOrder') {
            $headField = $this->erpInfo['OutboundOrderHeadFields'];
            $entryField = $this->erpInfo['OutboundOrderEntryFields'];
            $titleName = '出库情况';
        } elseif ($erpModule == 'erpCashBill') {
            $headField = $this->erpInfo['CashBillHeadFields'];
            $entryField = [];
            $titleName = '收款情况';
        } else if ($erpModule == 'erpInvoice') {
            $headField = $this->erpInfo['InvoiceHeadFields'];
            $entryField = $this->erpInfo['InvoiceEntryFields'];
            $titleName = '开票情况';
        }
        $return = [];
        //表头字段
        $return['header'] = [];
        //表体里面的值
        $return['entries'] = [];
        //每个字段的宽度
        $return['fieldwidth'] = [];
        //总宽度
        $return['total_width'] = 0;
        //可能用于排序 直接传和表头字段一样数量的share+列号
        $return['headername'] = [];

        $return['header'] = array_merge($headField??[], $entryField??[]);
        $rowCount= 0;
        foreach ($data as $key => $row) {
            $showRowArr = [];
            foreach ($headField as $showfield => $showFieldName) {
                if (isset($row->$showfield)) {
                    $showRowArr[$showfield] = $row->$showfield;
                } else {
                    $showRowArr[$showfield] = '';
                }

            }
            $showRowArrEntry=[];
            $emptyRowArrEntry=[];
            if($row->detail){
                foreach ($row->detail as $line => $entryRow) {
                    $rowCount++;
                    foreach ($entryField as $showfield => $showFieldName) {
                        if (isset($entryRow->$showfield)) {
                            $showRowArrEntry[$line][$showfield] = $entryRow->$showfield;
                        } else {
                            $showRowArrEntry[$line][$showfield] = '';
                        }
                    }
                }
            }else{
                $rowCount++;
                foreach ($entryField as $showfield=>$fields){
                    $emptyRowArrEntry[$showfield] = '';
                }
            }



            if ($showRowArrEntry) {
                foreach ($showRowArrEntry as $arr) {
                    $return['entries'][] = array_merge($showRowArr, $arr);
                }
            }else{
                $return['entries'][] = array_merge($showRowArr, $emptyRowArrEntry);
            }
        }

        if ($return['header']) {
            foreach ($return['header'] as $key => $value) {
                $return['headername']['module'][$key] = $erpModule;
                $return['headername']['fieldname'][$key] = $key;
            }
        }
        //module fieldname 及数组header 中的索引值  会影响拖动 需要重新排序
        $return['headername']['module'] = array_values($return['headername']['module']??[]);
        $return['headername']['fieldname'] = array_values($return['headername']['fieldname']??[]);
        $return['header'] = array_values($return['header']??[]);


        foreach ($data['columns'] as $key => $item) {
            $return['fieldwidth'][] = $item['width'];
            $return['total_width'] += $item['width'];
        }

        $return['navigation'] = [
            '共 ' . $rowCount . ' 条'
        ];
        //左上角内容
        $return['CUSTOM_BUTTON'] = '<span>' . $titleName . '</span>';
        $return['relcount'] = $rowCount;
        $return['noofrows'] = $rowCount;
        return $return;
    }

    public function OutboundOrderFields()
    {
        return [];
    }

}
