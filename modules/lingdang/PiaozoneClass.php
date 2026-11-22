<?php
// ls 240827  XUQIU20240815-01 对接发票云的API接口
class PiaozoneClass
{

    public $focus;
    public $module;

    public $isauthorize = false;//是否授权
    public $appId;//应用id
    public $appSecret;
    public $accountId;//租户数据中心id（苍穹数据中心id）
    public $user;//登录用户 手机号

    public $service_url;//发票云地址（非固定，申请账套后提供）
    public $taxno;//需要核算的税号（比如lingdang授权给B公司，那就是B公司的税号），即接口billTaxNo的值
    public $orgNumber;//苍穹组织编码
    public $billType = "er_dailyreimbursebill";
    public $companyInfo;//后台设置的公司抬头税号信息

    public $selectcompanyInfo;//需要控制上传的公司抬头税号信息
    //public $company_taxno;//税号
    //public $company_name;//公司名称

    public $version_account;
    private $config_name = 'piaozone_setting';
    public $resource = 'crm';
    public $access_token;
    public $invoicetype_arr = array(
        "1"=>"电子普通发票","2"=>"电子专用发票","3"=>"纸质普通发票","4"=>"纸质专用发票","5"=>"普通纸质卷票",
        "6"=>"","7"=>"普通纸质卷票","8"=>"出租车票","9"=>"火车/高铁票","10"=>"飞机行程单",
        "11"=>"其他票","12"=>"机动车销售发票","13"=>"二手车销售发票","14"=>"定额发票","15"=>"通行费电子发票",
        "16"=>"公路汽车票","17"=>"过路桥费发票","18"=>"","19"=>"完税证明","20"=>"轮船票",
        "21"=>"海关缴款书","22"=>"","23"=>"通用机打电子发票","24"=>"火车票退票凭证","25"=>"财政电子票据",
        "26"=>"数电普票","27"=>"数电专票","28"=>"数电航空","29"=>"数电铁路","30"=>"数电铁路",
    );
    public $scopeCompanyInfo;
    public $companyInfoByApplication;//含有适用范围用户id和label的 后台设置的公司抬头税号信息

    public function __construct($module)
    {
        $this->module = $module;
        $focus = CRMEntity::getInstance($module);
        $this->focus = $focus;
        $piaozoneInfo = $focus->getPiaozoneInfo();
        if ($piaozoneInfo['isauthorize']) {
            $this->isauthorize = $piaozoneInfo['isauthorize'];
            $this->appId = $piaozoneInfo['appId'];
            $this->appSecret = $piaozoneInfo['appSecret'];
            $this->accountId = $piaozoneInfo['accountId'];
            $this->user = $piaozoneInfo['user'];
//            $this->taxno = $piaozoneInfo['taxno'];
            $this->orgNumber = $piaozoneInfo['orgNumber'];

//            $this->company_taxno = $piaozoneInfo['taxno'];
//            $this->company_name = $piaozoneInfo['name'];

            $this->service_url = rtrim(urldecode($piaozoneInfo['service_url']), '/');
        }
        $this->companyInfo = $piaozoneInfo['companyInfo'];
        $this->getCompanyInfoByApplication();

        if (!is_dir(globalStatic::$root_directory.'dataCache/Piaozone')) {// dir doesn't exist, make it
            mkdir(globalStatic::$root_directory.'dataCache/Piaozone',0777,true);
        }


    }
    /*
     * 获取指定成员id可见范围内的公司信息
     * */
    public function getScopeCompanyInfo($userid='')
    {
        $this->scopeCompanyInfo = []; 
        if(empty($userid)){
            global $current_user;
            $userid = $current_user->id;
        }
        
        foreach ($this->companyInfoByApplication as $info) {
            if(array_key_exists($userid, $info['scope_userid'])){
                $this->scopeCompanyInfo[] = $info;
            }
        }
        return $this->scopeCompanyInfo;

    }

    public static function getInstance($module)
    {
        static $static_piaozoneobj_arr;
        if (is_array($static_piaozoneobj_arr)) {
            if ($static_piaozoneobj_arr[$module]) {
                return $static_piaozoneobj_arr[$module];
            }
        } else {
            $static_piaozoneobj_arr = array();
        }

        $static_piaozoneobj_arr[$module] = new PiaozoneClass($module);
        return $static_piaozoneobj_arr[$module];
    }

    public function getImportInvoiceConfig($record)
    {
        $service_url = $this->service_url;
        $access_token = $this->getAccessToken();

        $time = time();

        if ($record > 0) {//编辑
            $focus = CRMEntity::getInstance($this->module);
            $focus->id =$record;
            $focus->mode = 'edit';
            $focus->retrieve_entity_info($record, $this->module);

            $billid = $focus->id;
            $billno = $focus->column_fields[$focus->table_code];
        } else {
            $billid = $billno = $time . mt_rand(1, 100000);//新建页面临时单据id/单据编号
        }

        $linkKey = 'socket' . $time;

        $eventCode = $this->getImportPageEventCode($time, $billid, $billno, $linkKey);


        $invoicetype_arr = $this->invoicetype_arr;
        return compact("service_url","access_token", "billid", "billno", "linkKey", "eventCode","invoicetype_arr");
    }

    public function getAppToken()
    {
        //return '123';
        $app_token = '';
        $url = $this->service_url . "/api/getAppToken.do";
        $body = array();
        $body['appId'] = $this->appId;
        $body['appSecret'] = $this->appSecret;
        $body['accountId'] = $this->accountId;
        $result = $this->_CurlPost($url, $body);
        $response = json_decode($result, true);
        if (isset($response['data']['app_token']) && !empty($response['data']['app_token'])) {
            $app_token = $response['data']['app_token'];
        }
        return $app_token;

    }

    public function getAccessToken($rType = '')
    {
        //return '2020380673113595904_7909CTpn4yBxO64T6wKwGm2DSv3esCJiiEX15O3iI5CT3kzYAJ5ydtBakUx42v1mzd1FPb3xNYFxu35ceiHx47Kk3tjOvwxVgryj';
        global $adb;
        if(!empty($this->access_token) && empty($rType))
        {
            return $this->access_token;
        }
        $sql = 'select time,para_one from ld_wx_config where name=?';
        $result = $adb->pquery($sql, array($this->config_name));
        $time = $adb->query_result($result, 0, 'time');
        $access_token = $adb->query_result($result, 0, 'para_one');

        $timeinteval = time() - intval($time);
        if ($timeinteval > 1000 || $rType == 'refresh') {
            $app_token = $this->getAppToken();

            $url = $this->service_url . "/api/login.do";
            $body = array();
            $body['user'] = $this->user;
            $body['apptoken'] = $app_token;
            $body['accountId'] = $this->accountId;
            $result = $this->_CurlPost($url, $body);
            $response = json_decode($result, true);
            if (isset($response['data']['access_token']) && !empty($response['data']['access_token'])) {
                $access_token = $response['data']['access_token'];
                $sql_update = 'update ld_wx_config set para_one=?,time=?,datetime=? where name=?';
                $adb->pquery($sql_update, array($access_token, time(), date('Y-m-d H:i:s', time()), $this->config_name));
                $this->access_token = $access_token;
                return $access_token;
            } else {
                return false;
            }
        } else {
            $this->access_token = $access_token;
            return $access_token;
        }
    }



    //打开发票采集页面获取eventCode
    public function getImportPageEventCode($time, $billid, $billno, $linkKey)
    {
        //return '4872a0918d8f4db38c43045755989d3c0';
        global $current_user;
        $eventCode = '';
        $url = $this->service_url . "/kapi/app/rim/message?access_token=" . $this->access_token;
        $post_data = array();
        $post_data['messageType'] = 'getEventCode';
        $post_data['messageId'] = $time;
        $data = array(
            "billId" => $billid,
            "billNo" => $billno,
            "billType" => $this->billType,
            "resource" => $this->resource,
            "billTaxNo" => $this->selectcompanyInfo[0]['taxNo'],//$this->taxno
            "orgNumber" => $this->orgNumber,
            "userId" => $current_user->id,//可以理解为报销人id,不过因为没有集成成员数据,故可以随便传不校验
            "pushType" => 'socket',
            "linkKey" => $linkKey,
            // "companyInfo" => array(
            //     array(
            //         "taxNo" => $this->company_taxno,
            //         "name" => $this->company_name,
            //     )
            // ),
            "companyInfo" => $this->selectcompanyInfo,
        );
        $post_data['data'] = $data;
        $result = $this->_CurlPost($url, $post_data);
        $response = json_decode($result, true);
        if (isset($response['data']['eventCode']) && !empty($response['data']['eventCode'])) {
            $eventCode = $response['data']['eventCode'];
        }
        return $eventCode;

    }

    //EditView.php调用  or 详情页
    public function invoiceDataToHtmlByid($record)
    {
        global $adb;
        $sql = "select * from ld_piaozone where crmid=?";
        $result = $adb->pquery($sql,array($record));
        $num_rows = $adb->num_rows($result);

        $tableContent = '';
        if ($num_rows >= 1) {
            for($i = 0; $i<$num_rows; $i++) {
                $serialno = $adb->query_result($result, $i, 'serialno');
//                $invoicedata[] = Zend_Json::decode(decode_html($adb->query_result($result, $i, 'invoicedata')));

                $rowid = $i+1;
                if($rowid%2 ==0) {
                    $tableContent .='<tr serialno="'.$serialno.'" rowid="'.$rowid.'" onmouseover="listOnMouseOver(ld(this))" onmouseout="listOnMouseOut(ld(this),\'On\')" class="lvtColDataBj">';
                } else{
                    $tableContent .='<tr serialno="'.$serialno.'" rowid="'.$rowid.'" onmouseover="listOnMouseOver(ld(this))" onmouseout="listOnMouseOut(ld(this),\'on\')" class="lvtColData">';
                }

                $downloadurl = $adb->query_result($result, $i, 'downloadurl');

                $tableContent .='<td class="ld-form-item-content-entry" style="width:65px;text-align: center;">'.$rowid.'</td>
                            <td class="ld-form-item-content-entry">'.$adb->query_result($result, $i, 'invoicetype_zh').'</td>
                            <td class="ld-form-item-content-entry">'.$adb->query_result($result, $i, 'invoicecode').'</td>
                            <td class="ld-form-item-content-entry">'.$adb->query_result($result, $i, 'invoiceno').'</td>
                            <td class="ld-form-item-content-entry">'.$adb->query_result($result, $i, 'invoicedate').'</td>
                            <td class="ld-form-item-content-entry">'.$adb->query_result($result, $i, 'totalamount').'</td>
                            <td class="ld-form-item-content-entry">'.$adb->query_result($result, $i, 'buyername').'</td>';
                if($this->isauthorize){
                    $tableContent .= '<td class="ld-form-item-content-entry">';
                    if(isPermitted($this->module,'DownloadInvoice','') == 'yes' ){
                        $tableContent .= '<a onclick="PiaozoneObj.downloadInvoice(ld(this),\''.$this->module.'\',\''.$record.'\',\''.$downloadurl.'\',\'download\');" href="javascript:void(0);">'.getFixedLabel('DOWNLOAD').'&nbsp;</a>';
                    }
                    if(isPermitted($this->module,'DownloadInvoice','') == 'yes'){
                        $tableContent .='<a onclick="PiaozoneObj.downloadInvoice(ld(this),\''.$this->module.'\',\''.$record.'\',\''.$downloadurl.'\',\'view\');" href="javascript:void(0);">'.getFixedLabel('VIEW').'&nbsp;</a>';
                    }
                    if($this->focus->mode != 'Details' && isPermitted($this->module,'EditView','') == 'yes'){
                        $tableContent .= '<a onclick="PiaozoneObj.deleteInvoice(ld(this),\''.$this->module.'\',\''.$record.'\');" href="javascript:void(0);">'.getFixedLabel('DELETE').'</a>';
                    }
                    $tableContent .= '</td>';
                }
               
                $tableContent .= '</tr>';

            }
        }

        return $tableContent;

    }

    public function getInvioceData($record)
    {
        global $adb;
        $sql = "select * from ld_piaozone where crmid=?";
        $result = $adb->pquery($sql,array($record));
        $num_rows = $adb->num_rows($result);

        $invoicedata_arr = [];
        if ($num_rows >= 1) {
            for($i = 0; $i<$num_rows; $i++) {
                $invoicetype = $adb->query_result($result, $i, 'invoicetype');
                $invoicetype_zh = $adb->query_result($result, $i, 'invoicetype_zh');
                $invoicecode = $adb->query_result($result, $i, 'invoicecode');
                $invoiceno = $adb->query_result($result, $i, 'invoiceno');
                $invoicedate = $adb->query_result($result, $i, 'invoicedate');
                $totalamount = $adb->query_result($result, $i, 'totalamount');
                $buyername = $adb->query_result($result, $i, 'buyername');
                $salername = $adb->query_result($result, $i, 'salername');
                $serialno = $adb->query_result($result, $i, 'serialno');
                $downloadurl = $adb->query_result($result, $i, 'downloadurl');
                $snapshoturl = $adb->query_result($result, $i, 'snapshoturl');
                $invoicedata = $adb->query_result($result, $i, 'invoicedata');
                $invoicedata_arr[$serialno] = Zend_Json::decode(decode_html($adb->query_result($result, $i, 'invoicedata')));
            }
        }

        return $invoicedata_arr;
    }

    public function getInvoiceTotal($record)
    {

        $invoicetotal = '0.00';
        if($record>0){
            global $adb;
            $sql = "select ifnull(invoicetotal,'0.00') from ".$this->focus->table_name." where ".$this->focus->table_index." =? limit 1";
            $result = $adb->pquery($sql,array($record));
            if ($adb->num_rows($result) > 0) {
                $invoicetotal = $adb->query_result($result, 0, 0);
            }
        }

        return $invoicetotal;
    }


    public function getDownloadUrl($filePath,$type) {
        if (empty($filePath)) {
            return '';
        }
        // 下载文件地址使用download.do；预览文件地址使用preview.do
        $access_token = $this->getAccessToken();
        if ($type == 'download') {
            $url = $this->service_url . "/attachment/download.do";
        }else{
            $url = $this->service_url . "/attachment/preview.do";
        }
        $url .= "?path=" . urlencode($filePath) . "&access_token=" . $access_token;

        $value = $access_token . "~~" . time()*1000;
        $encodeValue = base64_encode($value);
        $flag = "&";

        if (strpos($url, "?") === false) {
            $flag = "?";
        }

        return $url . $flag . "kdedcba=" . urlencode($encodeValue);
    }


    public function billDel($post_data)
    {
        $access_token = $this->getAccessToken();
        $url = $this->service_url . "/kapi/app/rim/message?access_token=" . $access_token;

        $resp= $this->_CurlPost($url, $post_data);
        return json_decode($resp, true);
        
    }

    //保存单据只是建立单据与发票的关联关系，不会关注发票的组织信息，可以直接保存
    public function billSave($post_data)
    {
        $access_token = $this->getAccessToken();
        $url = $this->service_url . "/kapi/app/rim/message?access_token=" . $access_token;

        $resp= $this->_CurlPost($url, $post_data);
        return json_decode($resp, true);
        
    }

    public function _CurlGet($url, $post_data, $accessToken)
    {
        $headers = [
            'Authorization: Bearer ' . $accessToken
        ];

        $url = $url . "?" . http_build_query($post_data);

        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, FALSE);
        curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, FALSE);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
        curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
        $response = curl_exec($ch);
        if ($error = curl_errno($ch)) {
            //print "Error: " . curl_error($ch);
            return '';
        } else {
            curl_close($ch);

            return $response;
        }
    }

    public function _CurlPost($url, $post_data, $accessToken = '')
    {
        $ch = curl_init();
        if (substr($url, 0, 5) == 'https') {
            curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
            curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, false);
        }
        /*if (!empty($accessToken)) {
            $url .= '?access_token='.$accessToken;
        }*/
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($post_data));
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
        curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type: application/json'));
        curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, 30);
        curl_setopt($ch, CURLOPT_TIMEOUT, 30);
        $response = curl_exec($ch);
        $httpcode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        if (curl_error($ch)) {
            $httpcode = 500;
        }
        curl_close($ch);
        return $response;


    }

    //保存发票识别验证设置 除发票抬头部分
    public function savePiaozoneSetting($dataArr){
        global $adb;
        $this->appId = $dataArr['appId'];
        $this->appSecret = $dataArr['appSecret'];
        $this->accountId = $dataArr['accountId'];
        $this->user = $dataArr['user'];
        $this->orgNumber = $dataArr['orgNumber'];
        $this->service_url =$dataArr['service_url'];
        $arr = array(
            'service_url'=>$this->service_url,
            'appId'=>$this->appId,
            'appSecret'=>$this->appSecret,
            'accountId'=>$this->accountId,
            'user'=>$this->user,
            'orgNumber'=>$this->orgNumber,
            'companyInfo'=>$this->companyInfo,
            );
//        $content = Zend_Json::encode($arr);
        $content = json_encode($arr,JSON_UNESCAPED_UNICODE);;
        $sql = 'update ld_wx_config set para_content = ?,para_one=?,time=?,datetime=? where name=?';
        $adb->pquery($sql, array($content,'','','',$this->config_name));
        unset($arr,$content,$sql);
    }

    //新增/编辑发票抬头 保存
    public function savePiaozoneTax($dataArr){
        global $adb;
        $companyInfo = $this->companyInfo;
        if ($dataArr['taxNo'] != $dataArr['oldTaxNo']){
            foreach ($companyInfo as $key => $info){
                if ($info['taxNo'] == $dataArr['taxNo'] ){
                    unset($companyInfo);
                    return false;
                }
            }
        }
        if (empty($dataArr['oldTaxNo'])){//新增
            $this->companyInfo[] = array('taxNo'=>$dataArr['taxNo'],'name'=>$dataArr['name'],'scopeType'=>$dataArr['scopeType'],'scopeValue'=>$dataArr['scopeValue']);
        }else{
            foreach ($companyInfo as $key => $info){
                if ($info['taxNo'] == $dataArr['oldTaxNo'] ){
                    $companyInfo[$key]['taxNo'] = $dataArr['taxNo'];
                    $companyInfo[$key]['name'] = $dataArr['name'];
                    $companyInfo[$key]['scopeType'] = $dataArr['scopeType'];
                    $companyInfo[$key]['scopeValue'] = $dataArr['scopeValue'];
                }
            }
            $this->companyInfo = $companyInfo;
        }

        $arr = array(
            'service_url'=>$this->service_url,
            'appId'=>$this->appId,
            'appSecret'=>$this->appSecret,
            'accountId'=>$this->accountId,
            'user'=>$this->user,
            'orgNumber'=>$this->orgNumber,
            'companyInfo'=>$this->companyInfo,
        );
        $content = json_encode($arr,JSON_UNESCAPED_UNICODE);
        $sql = 'update ld_wx_config set para_content = ? where name=?';
        $adb->pquery($sql, array($content,$this->config_name));
        unset($companyInfo,$arr,$content,$sql);
        return true;
    }


    //获取发票抬头的适用范围和label
    public function getCompanyInfoByApplication(){
        $companyInfo = $this->companyInfo;
        foreach ($companyInfo as $key => $info){
            $scopeType = $info['scopeType'];
            $scopeValue = $info['scopeValue'];
            $companyInfo[$key]['scope_userid'] = $this->getUseridByType($scopeType,$scopeValue);
            $companyInfo[$key]['scope_label'] = $this->getLabelByType($scopeType,$scopeValue);
            unset($scopeType,$scopeValue);
        }
        $this->companyInfoByApplication = $companyInfo;
        unset($companyInfo);
        return $this->companyInfoByApplication;
    }


    //获取部门、角色下是所有启用的user信息
    public function getUseridByType($type,$value_str){
        global $current_user;
        if (empty($value_str) && $type != 'all'){
            unset($type,$value_str);
            return '';
        }
        if($type == 'group' || $type == 'user' || $type == 'Users' || $type == 'all'){
            crm_load_class_file('UsersUtils','modules/Users');
            $UsersUtilsObj = new UsersUtils();
            if($type == 'group' || $type == 'user' || $type == 'all'){
                if ($type == 'all'){
                    $arr = $UsersUtilsObj->get_user_array(false);
                }else{
                    $value_arr = explode(',',$value_str);
                    foreach ($value_arr as $key => $id){
                        if ($type == 'group'){
                            $userinfo = $UsersUtilsObj->getGroupOfActiveUsers($id);
                            foreach ($userinfo as $userid => $last_name){
                                $arr[$userid] = $last_name;
                            }
                        }else{
                            $arr[$id] = $UsersUtilsObj->getUserFullName($id);
                        }
                    }
                    unset($value_arr);
                }

            }else if ($type == 'Users'){
                $focus = CRMEntity::getInstance('Users');
                $focus->retrieve_entity_info($current_user->id,'Users');
                $userid = $focus->column_fields[$value_str];
                $arr[$userid] = $UsersUtilsObj->getUserFullName($userid);
                unset($focus);
            }
            unset($userid,$UsersUtilsObj);
        }else if($type == 'role'){
            $profileobj=Profile::getInstance();
            $value_arr = explode(',',$value_str);
            foreach ($value_arr as $key => $id){
                $userinfo = $profileobj->getProfileOfActiveUsers($id);
                foreach ($userinfo as $userid => $last_name){
                    $arr[$userid] = $last_name;
                }
                unset($userinfo);
            }
            unset($profileobj,$value_arr);
        }
        unset($type,$value_str);
        return $arr;
    }


    //获取选择成员名、部门名、角色名
    public function getLabelByType($type,$value_str){
        if (empty($value_str)){
            unset($value_str,$type);
            return '';
        }
        $arr = [];
        if ($type == 'user' || $type == 'group') {
            crm_load_class_file('UsersUtils','modules/Users');
            $UsersUtilsObj = new UsersUtils();
            $value_arr = explode(',',$value_str);
            foreach ($value_arr as $key => $id){
                if ($type == 'user'){
                    $arr[] = $UsersUtilsObj->getUserFullName($id);
                }else{
                    $arr[] = $UsersUtilsObj->getGroupFullName($id);
                }
            }
            unset($UsersUtilsObj,$value_arr,$type);
            return implode(',',$arr);
        }elseif($type == 'role'){
            $profileobj=Profile::getInstance();
            $value_arr = explode(',',$value_str);
            foreach ($value_arr as $key => $id){
                $profileinfo = $profileobj->getProfileinfo($id);
                $arr[] = $profileinfo['profilename'];
            }
            unset($profileobj,$value_arr,$type);
            return implode(',',$arr);
        }elseif ($type == 'all'){
            unset($type);
            return getFixedLabel('ALLTHEUSERS');
        }
    }

    //删除指定发票抬头
    public function deleteTax($taxNo){
        global $adb;
        foreach ($this->companyInfo as $key => $info){
            if ($info['taxNo'] == $taxNo){
                unset($this->companyInfo[$key]);
                break;
            }
        }
        $arr = array(
            'service_url'=>$this->service_url,
            'appId'=>$this->appId,
            'appSecret'=>$this->appSecret,
            'accountId'=>$this->accountId,
            'user'=>$this->user,
            'orgNumber'=>$this->orgNumber,
            'companyInfo'=>$this->companyInfo,
        );
        $content = json_encode($arr,JSON_UNESCAPED_UNICODE);;
        $sql = 'update ld_wx_config set para_content = ? where name=?';
        $adb->pquery($sql, array($content,$this->config_name));
        unset($taxNo,$arr,$content,$sql);
        return true;
    }


    //更改公司税号的适用范围
    public function saveTaxScope($taxNo,$scopeType,$scopeValue){
        global $adb;
        foreach ($this->companyInfo as $key => $info){
            if ($info['taxNo'] == $taxNo){
                $this->companyInfo[$key]['scopeType'] = $scopeType;
                $this->companyInfo[$key]['scopeValue'] = $scopeValue;
                break;
            }
        }
        $arr = array(
            'service_url'=>$this->service_url,
            'appId'=>$this->appId,
            'appSecret'=>$this->appSecret,
            'accountId'=>$this->accountId,
            'user'=>$this->user,
            'orgNumber'=>$this->orgNumber,
            'companyInfo'=>$this->companyInfo,
        );
        $content = json_encode($arr,JSON_UNESCAPED_UNICODE);;
        $sql = 'update ld_wx_config set para_content = ? where name=?';
        $adb->pquery($sql, array($content,$this->config_name));
        unset($taxNo,$arr,$content,$sql);
        return true;
    }

    /*
     * 获取可用模块
     */
    public function getAvailableModules()
    {
        $available_modules_arr = [
            'Expense',
        ];
        
        return $available_modules_arr;
    }


}