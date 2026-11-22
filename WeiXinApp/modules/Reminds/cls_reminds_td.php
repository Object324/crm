<?php
require_once(globalStatic::$root_directory . 'WeiXinApp/modules/Reminds/MessageCorpconversation.php');
//通达OA
class cls_reminds_td
{

    public $exsId;//由OA系统颁发的第三方系统id
    public $client_id;//应用id
    public $client_secret;
    public $isEncrypted;

    public $crm_url;
    public $api_url;
    public $agenda_url;//待办消息地址
    public $common_url;
    public $rRemindType;
    public $version_account;
    private $config_name = 'tongda_setting';
    public $token;
    public function __construct()
    {
        global $adb;
        $sql = "select para_content from ld_wx_config where `name`=? and ifnull(para_content,'') <> ''";
        $result = $adb->pquery($sql, array($this->config_name));
        if($adb->num_rows($result) > 0){
            $para_content = $adb->query_result($result, 0, 'para_content');
            $para_content = Zend_Json::decode($para_content);
            $this->exsId = $para_content['exsId'];
            $this->client_id = $para_content['client_id'];

            $client_secret = $para_content['client_secret'];
            $this->isEncrypted = $para_content['isEncrypted'];
            if ($this->isEncrypted == "yes") {
                $this->client_secret = $client_secret;
            }else{
                $this->client_secret = $this->aes_encode($client_secret,$client_secret);
            }
            $this->crm_url = rtrim(urldecode($para_content['crm_url']),'/');
            $this->api_url = rtrim(urldecode($para_content['api_url']),'/');
            $this->agenda_url = $this->api_url."/restapi/1_0/appcenter/affairprocessing";//待办消息地址 //事务状态（1待办，2已办）
        }

    }

    //立即发送所有提醒
    public function sendAllTypeRemindsImmediately($ids, $r_multi_content,$rRemindType='',$rOtherParam=array())
    {
        $this->rRemindType = $rRemindType;
        if(!empty($r_multi_content)){
            foreach($r_multi_content as $key => $info){
                if(!empty($info['received_id'])){
                    $receivedid_tongda = $this->getUserName($info['received_id']);
                    if(empty($receivedid_tongda))continue;
                    $info['userid_tongda'] = $receivedid_tongda;
                }
                $data[$key] = $info;
            }

            if (count($r_multi_content) > 0) {
                return $this->sendReminds($ids, $data);
            }
        }
    }
    //获取用户的账号  使用账号绑定
    public function getUserName($received_id){
        global $adb;
        $sql = 'select GROUP_CONCAT(user_name) from ld_users 
            where id in( ' . $received_id . ') and ifnull(user_name,\'\') <> \'\'  AND push_wx_reminds=1 ';
        $result = $adb->pquery($sql, array());
        return $adb->query_result($result,0,0);
    }
    //发送提醒
    public function sendReminds($ids, $r_multi_content)
    {
        global $adb;
        $tongda = $this->setInstallTd();
        if($tongda){
            if (sizeof($ids) > 0 && $ids[0] > 0) {
                $listKeyIds = $this->sendMessage($ids,$r_multi_content);
                if($this->rRemindType != 'workreport_remind'){
                    $idsNew = array();
                    $i = 0;
                    foreach ($ids as $key=>$value){
                        $idsNew[$i] = $value;
                        $i++;
                    }
                    $sql = 'update ld_reminds set push_to_td=? ,push_time_td=? where remindsid in(' . implode(',', $idsNew) . ')';

                    $adb->pquery($sql, array(3, date("Y-m-d H:i:s")));
                }
            }
        }
        return $listKeyIds;
    }

    //发送提醒
    protected function sendMessage($ids,$r_multi_content)
    {
        global $adb,$current_user;
        $listIds = array();
        if(!empty($ids)){
            foreach($ids as $key => $remindsid){
                foreach ($r_multi_content as $news_content) {
                    $userid_tongda = $news_content['userid_tongda'];
                    if (empty($userid_tongda)) {
                        break;
                    }
                    $massageContent =  $news_content['message'];
                    $r_reltab = $news_content['reltab'];
                    $r_related_to = $news_content['related_to'];
                    $r_date_time = $news_content['date_time'];
                    $r_remindtype = $news_content['remindtype'];

                    $location = '';
                    $related_to_str = '';
                    if ($r_reltab == 'CooperativeWork') {
                        $title = $news_content['title'];
                        if(empty($title)){
                            $title = getTranstab('CooperativeWork');
                        }
                        $entitytype = $news_content['entitytype'];
                        $news_title = $title;
                        $modulelabel = $news_content['modulelabel'];

                        $location = 'ldcrm/index.html#!/work_detail/' . $r_related_to . '/' . $entitytype . '/' . urlencode($this->filterstring($modulelabel));
                        $listtype = 'list';
                    } elseif ($r_reltab == 'Users') {
                        //指向成员详情界面的提醒，由于企业微信没做成员详情模块，现将关联模块是用户的提醒，不赋值跳转链接，禁止消息穿透
                        $news_title = '消息提醒';
                        $listtype = 'list';
                        $r_related_to = '';
                    } else {
                        if ($r_remindtype == 'massallocate' || $r_remindtype == 'massshare') {
                            $news_title = '消息提醒';
                            //zkt 20230707 BUG0069099 V8.5.0.6 云之家消息提醒，若同时分配或者共享了多条客户数据 分配、共享等消息点击后无法正常跳转至CRM（点击后白屏）
                            $modulelabel = urlencode(getTranstab($r_reltab));
                            $location = 'ldcrm/index.html#!/listview/' . $r_reltab . '/' . $modulelabel . '/-1/mass_remind/' . $r_related_to;
                        } elseif ($r_remindtype == 'Approve'|| $r_remindtype == 'ExpeditingApprove') {
                            $listtype = 'approvelist';	//approvelist
                            $news_title = '审批提醒';
                        } else {
                            $news_title = '消息提醒';
                            $listtype = 'list';
                        }
                        //zkt 20220520 51988(https://81mis.com/kfbcrm/index.php)（消息提醒标签修改）系统设置》参数设置》自动提醒设置》合同订单》在移动端提醒没有【模块名称】
                        //zkt 20220520  【ID1002781】【审批、分配、共享等“消息提醒”标签修改为【模块】操作提醒（第一版）】
                        if($r_remindtype =='ForceAntiApprove'){//强制驳回提交审批
                            $news_title = '【'.getTranstab($r_reltab).'】'.getFixedLabel('FORCEDREJECTSUBMITAPPROVAL');
                        }elseif($r_remindtype =='AntiApprove'){//反审批
                            $news_title = '【'.getTranstab($r_reltab).'】'.'反审批提醒';
                        }elseif($r_remindtype == 'share'){//共享，add_remind添加的提醒
                            $news_title = sprintf(getFixedLabel('MODULESHAREREMIND'),getTranstab($r_reltab));//【模块名称】共享提醒
                        }
                        elseif($r_remindtype == 'cancelshare'){//共享，add_remind添加的提醒
                            $news_title = sprintf(getFixedLabel('MODULECANCELSHAREREMIND'),getTranstab($r_reltab));//【模块名称】取消共享提醒
                        }
                        elseif(in_array($r_remindtype,array('SalesOrderDueDate','ServiceContractsDueDate','PaymentPlanPlanDate','SendPaymentPlanDate','ContactRecordsDate'))){
                            //合同交付提醒、服务合同产品到期提醒、收款计划到期提醒、付款计划到期提醒、跟进记录回访提醒
                            $news_title = getFixedLabel($r_remindtype.'Remind');//【合同订单】交付提醒
                        }elseif($r_remindtype == 'MODULECOMMENTRemind'){//评论提醒
                            $news_title = sprintf(getFixedLabel($r_remindtype),getTranstab($r_reltab));//【模块名称】评论提醒
                        }
                        elseif(in_array($r_remindtype,array('AccountsRECYCLEREMIND','LeadsRECYCLEREMIND','AccountsHEDGINGREMIND','CreateRemind','AccountsBEFOREREMIND','LeadsBEFOREREMIND'))){
                            //remindstype直接转为翻译：公海回收、报备提醒、新增提醒
                            $news_title = getFixedLabel($r_remindtype);
                            //zkt 20240808 BUG20240730-40 企业微信的公海客户回收提醒，点击进去进入的是工作台，不是客户列表或者消息提醒的界面
                            if(empty($r_related_to)&&!empty($r_reltab)){
                                $location = 'ldcrm/index.html#!/listview/' . $r_reltab . '/' . $this->filterstring($modulelabel) . '/-1/mass_remind/' . $r_related_to;
                            }
                        }
                        elseif(empty($r_remindtype)&&!empty($news_content['reminds_ruleid'])){//自动提醒
                            $tmpsql = 'select `name` from ld_automaticreminds where id = ?';
                            $tmpresult = $adb->pquery($tmpsql,array($news_content['reminds_ruleid']));
                            $news_title = '消息提醒';
                            if($adb->num_rows($tmpresult)>0){
                                $tmprulename = $adb->query_result($tmpresult,0,'name');
                                //zkt 20220520 51988(https://81mis.com/kfbcrm/index.php)（消息提醒标签修改）系统设置》参数设置》自动提醒设置》合同订单》在移动端提醒没有【模块名称】
                                $news_title = sprintf(getFixedLabel('MODULEAUTOREMINDREMIND'),getTranstab($r_reltab),$tmprulename);//【模块名称】$规则名称$提醒
                            }
                        }
                        //消息提醒前添加模块名
                        if($news_title == '消息提醒'&&!empty($r_reltab)){
                            $news_title = '【'.getTranstab($r_reltab).'】'.$news_title;
                        }
                        //zkt 20220427  【ID1002781】【审批、分配、共享等“消息提醒”标签修改为【模块】操作提醒（第一版）】
                        if(!empty($news_content['title'])){
                            $news_title = $news_content['title'];
                        }
                        //zkt 20220708 1000017  审批、分配、共享等“消息提醒”标签修改为【模块】操作提醒（第二版）
                        if (!empty($r_related_to)&&$r_remindtype != 'massallocate' && $r_remindtype != 'massshare'){
                            $tmpr_reltab =$r_reltab;
                            if(empty($tmpr_reltab)){
                                $tmpr_reltab = getSalesEntityType($r_related_to);
                            }
                            $related_to_name = getModuleHref($tmpr_reltab,$r_related_to);//管理超链接值
                            if(array_key_exists($tmpr_reltab, globalStatic::$moduleHrefArr)){
                                $modulehrefs= globalStatic::$moduleHrefArr;
                                $entitynames=$modulehrefs[$tmpr_reltab];
                            }else{
                                $entitynames = getEntitynameByModulename($tmpr_reltab);
                            }
                            //获取超链接对应的label
                            $related_to_focus = CRMEntity::getInstance($tmpr_reltab);
                            $related_to_lable = $related_to_focus->fieldobj->getFieldInfoBykeyValue('fieldname',$entitynames['fieldname'],'fieldlabel');
                            $related_to_str = $related_to_lable.'：'.$related_to_name;
                            $massageContent .= '<br>'.$related_to_str;
                        }
                    }
                    $describ = str_replace('&#039;', '\'', htmlspecialchars_decode(html_entity_decode($massageContent)));
                    $newsArr = array();//消息体
                    $describ = str_replace('<br>', PHP_EOL, $describ);
                    $describ = strip_tags(str_replace('"', '\"', $describ), '');

                    if (!empty($r_related_to) && empty($location)) {
                        $modulelabel = urlencode(getTranstab($r_reltab));
                        $location = 'ldcrm/index.html#!/detailview/' . $r_reltab . '/' . $r_related_to . '/' . $modulelabel . '/' . $listtype . '/yes/-1';
                    }
                    elseif (empty($r_related_to)) {
                        //CRM端没有指向的消息提醒或企业微信端还没做跳转的提醒，给它跳转到应用首页  2019/5/29 17:44 0037105
                        if ($r_reltab == 'CooperativeWork') {
                            $location = 'ldcrm/index.html#!/work/'. urlencode($this->filterstring(getTranstab($r_reltab)));
                        }
                        else{
                            $location = 'ldcrm/index.html#!/';
                        }
                    }

                    if($news_title=='')
                    {
                        $news_title='消息提醒';
                    }
                    $userid_tongda_arr = explode(',',$userid_tongda);
                    if(!isset($userid_tongda_arr[$key]))
                        break;
                    $tongda_userid = $userid_tongda_arr[$key];//实际上是用户账号user_name

                    //$appurl = $this->crm_url . 'WeiXinApp/selfbuildSass/' . $location . '?ssotype=tongda&corpurl=' . $this->crm_url;

                   /* crm_load_class_file('cls_MyCRMcrypt',"Register");
                    $cls_MyCRMcryptobj=new cls_MyCRMcrypt();
                    $encrypt_userid = $cls_MyCRMcryptobj->encode($tongda_userid);*/

                    $redirect_uri = 'index.php?pageto_module='.$r_reltab.'&pageto_action=index&pageto_record='.$r_related_to;//相对路径(PC端)
                    $redirect_uri = urlencode($redirect_uri);
//                    $messageUrl = $this->crm_url.'/SSOLogin.php?ssotype=tongda&userid='.$encrypt_userid.'&redirect_uri='.$redirect_uri;
                    $messageUrl = $this->crm_url.'/SSOLogin.php?ssotype=tongda&redirect_uri='.$redirect_uri;//OA点击消息链接时会附加code，拿code换登录账号



                    if (isset($news_content['creator']) && !empty($news_content['creator'])) {
                        $creatorid = $news_content['creator'];//扫描提醒
                    }else{
                        $creatorid = $current_user->id;//立即提醒消息
                    }
                    $creator = $this->getUserName($creatorid);
                    if (empty($creator)) {
                        $creator = $tongda_userid;//创建人如果没有,则使用接收人作为发送人
                    }

                    $approveresult = $news_content['approveresult'];
                    if($r_remindtype == 'Approve' && ($approveresult == 1 || $approveresult == 5||$approveresult == 6)){
                        //走待办消息通知接口
                        $newsArr['exsId'] = $this->exsId;
//                        $newsArr['flowid'] = $remindsid;
                        $newsArr['status'] = "1";//事务状态（1待办，2已办）
                        $newsArr['content'] = json_encode($describ);
                        $newsArr['sender'] = $creator;//发送人 (绑定的第三方系统用户id)
                        $newsArr['recipient'] = $tongda_userid;//收件人 (绑定的第三方系统用户id；如果是多个人需要用逗号拼接)
                        $newsArr['url'] = base64_encode($messageUrl);

                        $accessToken = $this->getAccessToken();
                        $response = $this->_CurlGet($this->agenda_url,$newsArr,$accessToken);
                        $response = json_decode($response,true);//数组形式

                        if (isset($response['error']) && $response['error']['message']== 'Unauthorized') {//token 失效 重发   通达OA技术说根据message判断
                            $accessToken = $this->getAccessToken('refresh');
                            $response = $this->_CurlGet($this->agenda_url,$newsArr,$accessToken);
                            $response = json_decode($response,true);
                        }
                        //发送成功
                        if (isset($response['state']) && $response['state']== 'ok') {
                            file_put_contents(globalStatic::$root_directory . 'dataCache/weixin/tongda_MessageSend_errorlog.txt', date('Y-m-d H:i:s').': 待办成功请求数据：'.json_encode($newsArr,JSON_UNESCAPED_UNICODE) . "\r\n", FILE_APPEND);
                            file_put_contents(globalStatic::$root_directory . 'dataCache/weixin/tongda_MessageSend_errorlog.txt', date('Y-m-d H:i:s').': 待办成功响应数据：'.json_encode($response,JSON_UNESCAPED_UNICODE) . "\r\n", FILE_APPEND);
                        } else {
                            file_put_contents(globalStatic::$root_directory . 'dataCache/weixin/tongda_MessageSend_errorlog.txt', date('Y-m-d H:i:s').': 待办失败请求数据：'.json_encode($newsArr,JSON_UNESCAPED_UNICODE) . "\r\n", FILE_APPEND);
                            file_put_contents(globalStatic::$root_directory . 'dataCache/weixin/tongda_MessageSend_errorlog.txt', date('Y-m-d H:i:s').': 待办失败响应数据：'.json_encode($response,JSON_UNESCAPED_UNICODE) . "\r\n", FILE_APPEND);
                        }
                    }else{
                        //走普通消息通知接口
                       break;

                    }


                    $listIds[$ids[0]] = 1;
                }
            }
        }

        return $listIds;
    }

    public function setInstallTd(){
        global $adb;
        $query = "select 1 from ld_wx_config where `name` = ? and ifnull(para_content,'') <> '' ";
        $result = $adb->pquery($query,array($this->config_name));
        $num_rows = $adb->num_rows($result);
        if($num_rows >= 1){
            return true;
        }else{
            return false;
        }
    }

    //过滤指定内容
    public function filterstring($r_string)
    {
        global $weixin_user;
        $result = str_replace('/', '', $r_string);
        //editor:gyq_165 reason:消息链接中文元素需要处理   2019/12/28 15:00
        if($weixin_user->action == 'dingtalk_remind'){
            $result = urlencode($result);
        }
        return $result;
    }

    public function getAccessToken($rType='')
    {
        global $adb;
        if(!empty($this->token) && empty($rType))
        {
            return $this->token;
        }
        $sql = 'select time,para_one from ld_wx_config where name=?';
        $result = $adb->pquery($sql, array($this->config_name));
        $time = $adb->query_result($result, 0, 'time');
        $token = $adb->query_result($result, 0, 'para_one');

        $timeinteval = time() - intval($time);
        if ($timeinteval > 1000 || $rType=='refresh') {
            $url = $this->api_url."/oauth2/token";
            $body = array();
            $body['grant_type'] = "password";
            $body['client_id'] = $this->client_id;
            $body['client_secret'] = $this->client_secret;
            $body['username'] = "username";
            $body['password'] = 'password';
            $result = $this->_CurlPost($url,$body);
            $url_content = json_decode($result, true);
            if (isset($url_content['access_token'])) {
                $token = $url_content['access_token'];
                $sql_update = 'update ld_wx_config set para_one=?,time=?,datetime=? where name=?';
                $adb->pquery($sql_update, array($token, time(), date('Y-m-d H:i:s', time()), $this->config_name));
                $this->token=$token;
                return $token;
            } else {
                return false;
            }
        } else {
            $this->token=$token;
            return $token;
        }
    }
    public function _CurlGet($url,$post_data,$accessToken){
        $headers = [
            'Authorization: Bearer ' . $accessToken
        ];

        $url =  $url."?".http_build_query($post_data);

        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, FALSE);
        curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, FALSE);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
        curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
        $output = curl_exec($ch);
        if ($error = curl_errno($ch)) {
            //print "Error: " . curl_error($ch);
            return '';
        } else {
            curl_close($ch);

            return $output;
        }
    }

    public function _CurlPost($url,$post_data){
        $oCurl = curl_init();
        if(substr($url, 0, 5) == 'https') {
            curl_setopt($oCurl, CURLOPT_SSL_VERIFYPEER, false);    //SSL 报错时使用
            curl_setopt($oCurl, CURLOPT_SSL_VERIFYHOST, false);    //SSL 报错时使用
        }
        curl_setopt($oCurl, CURLOPT_URL, $url);
        curl_setopt($oCurl, CURLOPT_POST, true);
        curl_setopt($oCurl, CURLOPT_POSTFIELDS, http_build_query($post_data));
        curl_setopt($oCurl, CURLOPT_RETURNTRANSFER, 1 );
        curl_setopt($oCurl, CURLOPT_HTTPHEADER,array('content-type: application/x-www-form-urlencoded;'));
        curl_setopt($oCurl, CURLOPT_CONNECTTIMEOUT, 30);
        curl_setopt($oCurl, CURLOPT_TIMEOUT, 30);
        $sContent = curl_exec($oCurl);
        curl_close($oCurl);
        return $sContent;
    }

    //方法还需要验证，为以后预留。
    public function aes_encode($key,$str){
        $data = openssl_encrypt($str, 'AES-128-ECB', $key, OPENSSL_RAW_DATA);
        $data = strtolower(bin2hex($data));
        return $data;
    }


}