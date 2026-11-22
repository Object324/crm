<?php
require_once(globalStatic::$root_directory . 'WeiXinApp/modules/Reminds/MessageCorpconversation.php');

class cls_reminds_fanwei
{
    public $code;
    public $syscode;
    public $crm_url;
    public $appcrm_url;
    public $fanwei_url;
    public $agenda_url;
    public $common_url;
    public $processdone_url;
    public $appid;
    public $rRemindType;

    public $statusAgenda = '0';//待办
    public $statusProcessed = '2';//已办
    public $statusDone = '4';//办结    0：待办 2：已办 4：办结 8：抄送（待阅）

    public $version_account;
    public function __construct()
    {
        global $adb;
        $sql = "select para_content from ld_wx_config where `name`=? and ifnull(para_content,'') <> ''";
        $result = $adb->pquery($sql, array('fanwei_setting'));
        if($adb->num_rows($result) > 0){
            $para_content = $adb->query_result($result, 0, 'para_content');
            $para_content = Zend_Json::decode($para_content);
            $this->syscode = $para_content['syscode'];
            $this->code = $para_content['code'];
            $this->crm_url = rtrim(urldecode($para_content['crm_url']),'/');
            $this->appcrm_url = rtrim(urldecode($para_content['appcrm_url']),'/');
            $this->fanwei_url = rtrim(urldecode($para_content['fanwei_url']),'/');
            $this->agenda_url = $this->fanwei_url."/rest/ofs/ReceiveRequestInfoByJson";//待办消息地址
            $this->common_url = $this->fanwei_url."/api/ec/dev/message/sendCustomMessageSingle";//普通消息地址
        }


        $this->version_account = getVersionInfo()['account'];

    }

    //立即发送所有提醒
    public function sendAllTypeRemindsImmediately($ids, $r_multi_content,$rRemindType='',$rOtherParam=array())
    {
        $this->rRemindType = $rRemindType;
        if(!empty($r_multi_content)){
            foreach($r_multi_content as $key => $info){
                $r_weidu_remindsid = $info['weidu_remindsid_fanwei'];
                if(!empty($info['received_id'])){
                    $fanwei_userid = $this->getUserid($info['received_id']);
                    if(empty($fanwei_userid))continue;
                    $info['userid_fanwei'] = $fanwei_userid;
                }
                $data[$key] = $info;
            }
            //duan 20221205 将更新历史消息状态单独拿出来，避免因为最后一个人的提醒发送失败时，状态未更新的问题
            $this->UpdateMessageStatus($r_weidu_remindsid,$this->statusProcessed);

            if (count($r_multi_content) > 0) {
                return $this->sendReminds($ids, $data);
            }
        }
    }
    //获取用户的fanwei_userid   工号
    public function getUserid($received_id){
        global $adb;
        $sql = 'select GROUP_CONCAT(fanwei_userid) from ld_users 
            where id in( ' . $received_id . ') and ifnull(fanwei_userid,\'\') <> \'\'  AND push_wx_reminds=1 ';
        $result = $adb->pquery($sql, array());
        return $adb->query_result($result,0,0);
    }
    //发送提醒
    public function sendReminds($ids, $r_multi_content)
    {
        global $adb;
        $fanwei = $this->setInstallFanwei();
        if($fanwei){
            if (sizeof($ids) > 0 && $ids[0] > 0) {
                $listKeyIds = $this->sendMessage($ids,$r_multi_content);
                if($this->rRemindType != 'workreport_remind'){
                    $idsNew = array();
                    $i = 0;
                    foreach ($ids as $key=>$value){
                        $idsNew[$i] = $value;
                        $i++;
                    }
                    $sql = 'update ld_reminds set push_to_fw=? ,push_time_fw=? where remindsid in(' . implode(',', $idsNew) . ')';

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
        $syscode = $this->syscode;
        if (!$syscode) {
            return true;
        }
        $listIds = array();
        if(!empty($ids)){
            foreach($ids as $key => $remindsid){
                foreach ($r_multi_content as $news_content) {
                    $userid_fanwei = $news_content['userid_fanwei'];
                    if (empty($userid_fanwei)) {
                        break;
                    }
                    $r_recieverids = array();
                    $massageContent =  $news_content['message'];
                    $r_reltab = $news_content['reltab'];
                    $r_related_to = $news_content['related_to'];
                    $r_date_time = $news_content['date_time'];
                    $r_remindtype = $news_content['remindtype'];
                    $r_weidu_remindsid = $news_content['weidu_remindsid_fanwei'];
                    if(!empty($news_content['recieverids'])){
                        $r_recieverids = $news_content['recieverids'];
                    }

                    if ($this->version_account == 'tiandi' && in_array($r_reltab,["CustomForm11","Quotes"]) && in_array($r_remindtype,['Approve','ExpeditingApprove','ForceAntiApprove','AntiApprove'])) {//天地，模块CustomForm11、Quotes要求不发送审批类型的泛微消息,其他消息端不做控制，按已发送处理
                        $listIds[$ids[0]] = 1;
                        continue;
                    }

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
                    if(in_array($r_remindtype,array('AccountsRECYCLEREMIND','LeadsRECYCLEREMIND','AccountsHEDGINGREMIND','AccountsBEFOREREMIND','LeadsBEFOREREMIND'))){
                        $modulelabel = getTranstab($r_reltab);
                        if(empty($r_related_to)&&!empty($r_reltab)){
                            $remindsid = $news_content['remindsid'];
                            $location = 'ldcrm/index.html#!/listview/' . $r_reltab . '/' . $this->filterstring($modulelabel) . '/-1/mass_remind/' . $remindsid;
                        }
                    }
//                    $userid_array = explode(',',$news_content['received_id']);
//                    $userid_userid = $userid_array[$key];
                    if($news_title=='')
                    {
                        $news_title='消息提醒';
                    }
                    if (is_array($userid_fanwei)) {
                        $fanwei_userid_arr = $userid_fanwei;
                    }else{
                        $fanwei_userid_arr = explode(',',$userid_fanwei);
                    }
                    $fanwei_userid = $fanwei_userid_arr[$key];

                    $appurl = 'WeiXinApp/selfbuildSass/' . $location . '?ssotype=fanwei&corpurl=' . $this->appcrm_url . '/'. '&gonghao=' . base64_encode(date("YmdHis").$fanwei_userid);

                    crm_load_class_file('cls_MyCRMcrypt',"Register");
                    $cls_MyCRMcryptobj=new cls_MyCRMcrypt();
                    $encrypt_userid = $cls_MyCRMcryptobj->encode($fanwei_userid);

                    $redirect_uri = 'index.php?pageto_module='.$r_reltab.'&pageto_action=index&pageto_record='.$r_related_to;//相对路径(PC端)
                    $redirect_uri = urlencode($redirect_uri);
                    $messageUrl = 'FanweiLogin.php?userid='.$encrypt_userid.'&redirect_uri='.$redirect_uri;
                    //echo $messageUrl;echo '<br><br>';die;


                    if (isset($news_content['creator']) && !empty($news_content['creator'])) {
                        $creatorid = $news_content['creator'];//扫描提醒
                    }else{
                        $creatorid = $current_user->id;//立即提醒消息
                    }
                    $creator = $this->getUserid($creatorid);
                    if (empty($creator)) {
                        $creator = $fanwei_userid;//创建人如果没有绑定泛微通讯录账号,则使用接收人作为发送人
                    }

                    $approveresult = $news_content['approveresult'];
                    if($r_remindtype == 'Approve' && ($approveresult == 1 || $approveresult == 5||$approveresult == 6)){
                        if ($this->version_account == 'tiandi') {
                            //BUG20240704-02 240704 代办类消息客户要创建人始终为审批发起人
                            $related_to_focus = CRMEntity::getInstance($r_reltab);
                            $related_to_sql='select approvesubmitter from '.$related_to_focus->table_name.'  where '.$related_to_focus->table_index.'=?';
                            $related_to_result=$adb->pquery($related_to_sql,array($r_related_to));
                            if($adb->num_rows($related_to_result)>0) {
                                $approvesubmitter =  $adb->query_result($related_to_result,0,'approvesubmitter');
                                if($approvesubmitter > 0){
                                    $creator = $this->getUserid($approvesubmitter);
                                    if (empty($creator)) {
                                        $creator = $fanwei_userid;
                                    }
                                }

                            }

                            $news_title = '';// 天地要求为空
                        }


                        //走待办消息通知接口
                        $newsArr['syscode'] = $syscode;
                        $newsArr['flowid'] = (string)$remindsid;//主键不重复就行  可以使用remindsid
                        $newsArr['requestname'] = $describ;
                        $newsArr['workflowname'] = getTranstab($r_reltab);//TODO
                        $newsArr['nodename'] = $news_title;//TODO
                        $newsArr['pcurl'] = $messageUrl;
                        $newsArr['appurl'] = $appurl;
                        $newsArr['isremark'] = "0";	//流程处理状态 0：待办 2：已办 4：办结 8：抄送（待阅）
                        $newsArr['viewtype'] = "0";
                        $newsArr['creator'] = $creator;
                        $newsArr['createdatetime'] = $news_content['date_time'];
                        $newsArr['receiver'] = $fanwei_userid;
                        $newsArr['receivedatetime'] = date("Y-m-d H:i:s");
                        $newsArr['receivets'] = (string)time();
//                    $newsArr['requestlevel'] = '0';//紧急程度（非必传）0：正常、1：重要、2：紧急

//                    $url = 'http://218.28.182.50:8071/rest/ofs/ReceiveRequestInfoByJson';//泛微地址
                        $url = $this->agenda_url;//泛微地址
                        $body = json_encode($newsArr);
                        $response = $this->_CurlGet($url,$body);
                        $response = json_decode($response,true);//数组形式

                        //发送成功后插入临时表
                        if ($response['operResult'] == '1' && $newsArr['isremark'] == '0') {
                            $select_result = $adb->pquery("select 1 from ld_reminds_agenda where remindsid=? limit 1", array($remindsid));
                            if ($adb->num_rows($select_result) > 0) {
                                $adb->pquery("update ld_reminds_agenda set agendadata=?,approvelogid=? where remindsid=?", array($body,$news_content['approvelogid'],$remindsid));
                            }else{
                                $inser_sql = "insert into ld_reminds_agenda(remindsid,agendadata,approvelogid) VALUES (?,?,?)";
                                $params = array($newsArr['flowid'],$body,$news_content['approvelogid']);
                                $adb->pquery($inser_sql, $params);
                            }

                        } else {
                            file_put_contents(globalStatic::$root_directory . 'dataCache/weixin/fanwei_MessageSend_errorlog.txt', date('Y-m-d H:i:s').': 待办请求数据：'.json_encode($newsArr,JSON_UNESCAPED_UNICODE) . "\r\n", FILE_APPEND);
                            file_put_contents(globalStatic::$root_directory . 'dataCache/weixin/fanwei_MessageSend_errorlog.txt', date('Y-m-d H:i:s').': 待办响应数据：'.json_encode($response,JSON_UNESCAPED_UNICODE) . "\r\n", FILE_APPEND);
                        }
                    }else{
                        //走普通消息通知接口
                        $newsArr['code'] = $this->code;
                        $newsArr['workCodeList'] = $fanwei_userid;//接收	人编号
                        $newsArr['creater'] = $creator;
                        $newsArr['title'] = $news_title;
                        $newsArr['context'] = $describ;//内容
                        $newsArr['linkUrl'] = $this->crm_url.'/'.$messageUrl;//天地pc端只能用外网访问，移动端需要用外网，所以需要分开
                        $newsArr['linkMobileUrl'] = $this->appcrm_url.'/'.$appurl;
                        $url = $this->common_url;//泛微普通消息接口地址

                        //$body = json_encode($newsArr);
                        //$response = $this->_CurlGet($url,$body);//通知类消息接口只接受x-www-form-urlencoded数据,不接收json数据
                        $response = $this->_CurlPostUrlencode($url,$newsArr);
                        $response = json_decode($response,true);//数组形式

                    }


                    $listIds[$ids[0]] = 1;
                }
            }
        }

        return $listIds;
    }

    public function setInstallFanwei(){
        global $adb;
        $query = "select * from ld_wx_config where `name` = 'fanwei_setting' and ifnull(para_content,'') <> '' ";
        $result = $adb->pquery($query,array());
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


    public function _CurlGet($url,$body){
        $oCurl = curl_init();
        if(substr($url, 0, 5) == 'https') {
            curl_setopt($oCurl, CURLOPT_SSL_VERIFYPEER, false);    //SSL 报错时使用
            curl_setopt($oCurl, CURLOPT_SSL_VERIFYHOST, false);    //SSL 报错时使用
        }
        curl_setopt($oCurl, CURLOPT_URL, $url);
        curl_setopt($oCurl, CURLOPT_POST, true);
        curl_setopt($oCurl, CURLOPT_POSTFIELDS, $body);
        curl_setopt($oCurl, CURLOPT_RETURNTRANSFER, 1 );
        curl_setopt($oCurl, CURLOPT_HTTPHEADER,array('content-type: application/json;charset=utf-8;'));
        curl_setopt($oCurl, CURLOPT_CONNECTTIMEOUT, 100);
        curl_setopt($oCurl, CURLOPT_TIMEOUT, 100);
        $sContent = curl_exec($oCurl);
        curl_close($oCurl);
        return $sContent;
    }
    public function _CurlPostUrlencode($url,$formData){
        $oCurl = curl_init();
        if(substr($url, 0, 5) == 'https') {
            curl_setopt($oCurl, CURLOPT_SSL_VERIFYPEER, false);
            curl_setopt($oCurl, CURLOPT_SSL_VERIFYHOST, false);
        }
        curl_setopt($oCurl, CURLOPT_URL, $url);
        curl_setopt($oCurl, CURLOPT_POST, true);

        $formDataString = http_build_query($formData);// 将关联数组转换为form-data格式的字符串
        curl_setopt($oCurl, CURLOPT_POSTFIELDS, $formDataString);// 设置传递的数据为form-data
        curl_setopt($oCurl, CURLOPT_HTTPHEADER, array('Content-Type: application/x-www-form-urlencoded'));
        curl_setopt($oCurl, CURLOPT_RETURNTRANSFER, 1 );
        curl_setopt($oCurl, CURLOPT_CONNECTTIMEOUT, 100);
        curl_setopt($oCurl, CURLOPT_TIMEOUT, 100);
        $sContent = curl_exec($oCurl);
        curl_close($oCurl);
        return $sContent;
    }

    //duan 20221205 将更新历史消息状态单独拿出来，避免因为最后一个人的提醒发送失败时，状态未更新的问题
    public function UpdateMessageStatus($r_weidu_remindsid,$actiontype='2'){
        //变更待办消息的处理状态
        if(!empty($r_weidu_remindsid)){
            global $adb;
//            $weidu_remindsid = explode(',',$r_weidu_remindsid);

            $sql = "select tmp.*,ld_approvelog.isfinished from ld_reminds_agenda AS tmp LEFT JOIN ld_reminds ON tmp.remindsid = ld_reminds.remindsid 
             LEFT JOIN ld_approvelog ON tmp.approvelogid = ld_approvelog.id
             where tmp.remindsid in(" . $r_weidu_remindsid. ") and  ld_reminds.push_to_fw = 3";
            $result = $adb->pquery($sql, array());
            $result_arr = $adb->query_result_all($result);

            $url = $this->agenda_url;//泛微地址
            foreach($result_arr as $tmp_arr){
                if ($tmp_arr['isfinished'] == 'no') {
                    continue;
                }
                $agendtada_arr = Zend_Json::decode(html_entity_decode($tmp_arr['agendadata']));
                $agendtada_arr['isremark'] = $actiontype;//状态改为已办
                $agendtada_arr['receivets'] = (string)time();
                $agendtada_json = json_encode($agendtada_arr);

                $response = $this->_CurlGet($url,$agendtada_json);
                $response = json_decode($response,true);//数组形式
                if ($response['operResult'] == '1') {
                } else {
                    file_put_contents(globalStatic::$root_directory . 'dataCache/weixin/fanwei_MessageSend_errorlog.txt', date('Y-m-d H:i:s').': 已办请求数据：'.json_encode($agendtada_arr,JSON_UNESCAPED_UNICODE) . "\r\n", FILE_APPEND);
                    file_put_contents(globalStatic::$root_directory . 'dataCache/weixin/fanwei_MessageSend_errorlog.txt', date('Y-m-d H:i:s').': 已办响应数据：'.json_encode($response,JSON_UNESCAPED_UNICODE) . "\r\n", FILE_APPEND);
                }


                $sql = 'update ld_reminds set push_to_fw=? where remindsid = ?';
                $adb->pquery($sql, array(4,$agendtada_arr['flowid']));
            }
            //duan 20231128 将已经更新为已办的提醒记录为4 ,避免重复请求
            //$sql = 'update ld_reminds set push_to_fw=? where remindsid in(' . $r_weidu_remindsid. ')';
            //$adb->pquery($sql, array(4));
        }
    }

}