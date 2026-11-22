<?php
//editor:gyq_165 reason:钉钉消息提醒   2019/12/24 13:57
require_once globalStatic::$root_directory . 'WeiXinApp/modules/Reminds/immediatelyReminds.php';
require_once(globalStatic::$root_directory . "WeiXinApp/modules/Reminds/cls_reminds_yzj.php");
require_once(globalStatic::$root_directory . "WeiXinApp/modules/Reminds/cls_reminds_zy.php");
require_once(globalStatic::$root_directory . "WeiXinApp/modules/Reminds/cls_reminds_fanwei.php");
require_once(globalStatic::$root_directory . "WeiXinApp/modules/Reminds/cls_reminds_td.php");

class MessageCorpconversation extends immediatelyReminds
{
    protected $eventModel;
    public $installWX;//是否安装企业微信，true 是
    public $installDing;//是否安装钉钉，true 是
    public $installYzj;//是否安装云之家，true 是
    public $installWXSelfBuilt;//是否安装企业微信自建应用，true 是
    public $installZy;//是否安装致远OA，true 是
    public $installFanwei;//是否安装泛微
    public $installTd;//是否安装通达

    protected $remindTypeSet = false;//是否获取定提醒类型
    protected $dingApiName = 'dingtalk_setting';

    public $statusProcessedDing = true;//已办

    /**
     * @return string
     * zxm 判断是否有小程序关联公众号的消息发送
     */
    public function judgeOffiaccount(){
        global $adb;
        $sql = "select 
    offiaccount.open_id,miniprograme.wechatuserid
    from (
        select * from ld_wechatuser where userfromvalue='CRMminiprogram' and deleted=0 and userid>0 and ifnull(unionid,'')<>''
    )miniprograme
    left join( 
        select * from ld_wechatuser where userfromvalue='CRMoffiaccount' and deleted=0 and ifnull(unionid,'')<>'' and  ifnull(open_id,'')<>''
    )offiaccount on miniprograme.unionid=offiaccount.unionid
    where offiaccount.open_id is not null";
        $res = $adb->pquery($sql);
        $nums = $adb->num_rows($res);
        if($nums>0){
            return 'yes';
        }else{
            return 'no';
        }
    }
    //立即发送所有提醒
    public function sendAllTypeRemindsImmediately($ids, $r_multi_content,$rRemindType='',$rOtherParam=array())
    {
        global $adb;
        //zkt 20220926 BUG0056998合同订单的消息提醒为“秦罚魏”，它的提醒消息内容没有换行显示
        $tmpr_multi_content = $r_multi_content;
        foreach($tmpr_multi_content as $tmpindex=>$r_multi_contentinfo){
            $tmpreminds_ruleid = $r_multi_contentinfo['reminds_ruleid'];
            $tmp_r_remindtype = $r_multi_contentinfo['remindtype'];
            if($tmpreminds_ruleid>0||$tmp_r_remindtype == 'Approve'|| $tmp_r_remindtype == 'ExpeditingApprove'){
                //自动提醒内容根据设置的提醒内容样式显示
                $r_multi_content[$tmpindex]['message'] = str_replace("\n", '<br>', $r_multi_content[$tmpindex]['message']);
            }
        }
        $this->setRemindType();
        //zxm 20221116 公众号提醒消息单独请求 将这里注释
       /* if($this->judgeOffiaccount()=='yes'){
            //小程序关联公众号 发送提醒
            require_once(globalStatic::$root_directory . "WeiXinApp/modules/Reminds/cls_reminds_offiaccount.php");
            $offiaccount_remind = new cls_reminds_offiaccount();
            $offiaccount_remind->sendAllTypeRemindsImmediately($ids,$rRemindType,$rOtherParam);
        }*/

        //$rRemindType = 'workreport_reminds_half';
        //$rOtherParam['workreportid'] = 72;
        //$rOtherParam['type'] = 'reply';
        //工作汇报提醒
        if($rRemindType=='workreport_reminds_aftersave'){
            $this->workreport_reminds_aftersave($rOtherParam['workreportid']);
        }elseif($rRemindType=='workreport_reminds_half') {
            //工作协同回复，赞等提醒
            $this->workreport_reminds_half($rOtherParam['workreportid'],$rOtherParam['lastinsertid'],$rOtherParam['type']);
        }else{
            //当钉钉和云之家同时启用的时候，云之家收不到"发件箱"这种扫描提醒，因为钉钉扫描发消息时会调用当前sendAllTypeRemindsImmediately方法，导致也会调用云之家的发消息接口，发送状态直接变为3，导致实际没有发送（先这样处理，他们扫描提醒应该是各走各的）
            if ($rRemindType != 'scanreminder') {
                //云之家提醒
                if($this->installYzj){
                    //require_once(globalStatic::$root_directory . "WeiXinApp/modules/Reminds/cls_reminds_yzj.php");

                    $yzj_remind = new cls_reminds_yzj();
                    $yzj_remind->sendAllTypeRemindsImmediately($ids, $r_multi_content);
                }
                if ($this->installZy) {
                    $zy_remind = new cls_reminds_zy();
                    $zy_remind->sendAllTypeRemindsImmediately($ids, $r_multi_content);
                }
                if ($this->installFanwei) {
                    $fanwei_remind = new cls_reminds_fanwei();
                    $fanwei_remind->sendAllTypeRemindsImmediately($ids, $r_multi_content);
                }
                if ($this->installTd) {
                    $td_remind = new cls_reminds_td();
                    $td_remind->sendAllTypeRemindsImmediately($ids, $r_multi_content);
                }

            }

            //非直接发送，对应原$remind->sendReminds($parenttmpremindid, $r_multi_content)的调用方式
            $remindContentWX = array();
            $remindContentDing = array();
            $remindContentWXSelfBuilt = array();
            $i = 0;
            $j = 0;

            foreach ($r_multi_content as $key => $content) {
                //企业微信
                if (!empty($this->installWX) ) {
                    //已在外部查询企业微信用户标识
                    if (isset($content['userid'])) {
                        $remindContentWX[$i] = $content;
                        $i++;
                    } elseif(isset($content['received_id'])) {
                        //判断接收人是否绑定企业微信
                        $sql = 'select GROUP_CONCAT(wx_userid),count(wx_userid) as usernum_wx from ld_users 
            where id in( ' . $content['received_id'] . ') and ifnull(wx_userid,\'\') <> \'\'  AND push_wx_reminds=1 ';
                        $result = $adb->pquery($sql, array());
                        if ($adb->num_rows($result) > 0) {
                            $recieverid = $adb->query_result($result, 0, 0);
                            $usernumWX = $adb->query_result($result, 0, 'usernum_wx');
                        }
                        if ($usernumWX > 0) {
                            //这是微信用户id，即用户表中的wx_userid
                            $remindContentWX[$i] = $content;
                            $remindContentWX[$i]['userid'] = explode(',', $recieverid);
                            $i++;
                        }
                    }
                }
                //钉钉
                if (!empty( $this->installDing)) {
                    //已在外部查询钉钉用户标识
                    if (isset($content['userid_ding'])) {//扫描提醒
                        $remindContentDing[$j] = $content;
                        $j++;
                    } elseif(isset($content['received_id'])) {
                        //判断接收人是否绑定钉钉
                        $sqlUser = 'select GROUP_CONCAT(dingtalk_userid) as userids,count(dingtalk_userid) as usernum_ding  from ld_users 
            where id in( ' . $content['received_id'] . ') and ifnull(dingtalk_userid,\'\')<>\'\' AND push_wx_reminds=1 ';
                        $resultUser = $adb->pquery($sqlUser, array());
                        if ($adb->num_rows($resultUser) > 0) {
                            $recieveridDing = $adb->query_result($resultUser, 0, 'userids');
                            $usernumDing = $adb->query_result($resultUser, 0, 'usernum_ding');
                        }
                        if ($usernumDing > 0) {
                            $remindContentDing[$j] = $content;
                            $remindContentDing[$j]['userid_ding'] = array_unique(explode(',', $recieveridDing));
                            $j++;
                        } else {
//                            continue;
                        }
                    }

                    //更新钉钉unionid
                    $this->updateDingTalkUnionid();

                    $r_weidu_remindsid_dingtalk = $content['weidu_remindsid_dingtalk'];
                    $this->UpdateDingtalkMessageStatus($r_weidu_remindsid_dingtalk,$this->statusProcessedDing);
                }
                //企业微信自建应用
                if ($this->installWXSelfBuilt) {
                    //已在外部查询企业微信用户标识
                    if (isset($content['userid'])) {//扫描提醒
                        $remindContentWXSelfBuilt[$i] = $content;
                        $i++;
                    }
                    elseif(isset($content['received_id'])) {//审批立即提醒
                        //判断接收人是否绑定企业微信自建应用
                        $sql = 'select GROUP_CONCAT(wx_userid),count(wx_userid) as usernum_wx from ld_users
            where id in( ' . $content['received_id'] . ') and ifnull(wx_userid,\'\') <> \'\'  AND push_wx_reminds=1 ';
                        $result = $adb->pquery($sql, array());
                        if ($adb->num_rows($result) > 0) {
                            $recieverid = $adb->query_result($result, 0, 0);
                            $usernumWXSelfBuilt = $adb->query_result($result, 0, 'usernum_wx');
                        }
                        if ($usernumWXSelfBuilt > 0) {
                            //这是微信用户id，即用户表中的wx_userid
                            $remindContentWXSelfBuilt[$i] = $content;
                            $remindContentWXSelfBuilt[$i]['userid'] = array_unique(explode(',', $recieverid));
                            $i++;
                        } else {
//                            continue;
                        }
                    }
                }
            }

            if (is_array($remindContentWXSelfBuilt)&& count($remindContentWXSelfBuilt) > 0) {
                 $this->sendRemindsWXSelfBuilt($ids, $remindContentWXSelfBuilt);
            }
           
            else if (is_array($remindContentWX)&&count($remindContentWX) > 0) {
                 $this->sendReminds($ids, $remindContentWX);
            }
            
            if (is_array($remindContentDing)&&count($remindContentDing) > 0) {
                $this->sendRemindsDing($ids, $remindContentDing);
            }
           
        }
    }

    //设置提醒类型
    public function setRemindType()
    {
        //避免重复获取提醒参数
        if (!$this->remindTypeSet) {
            require_once(globalStatic::$root_directory . "appCommon/appCommon.php");
            $this->installDing = $this->setEventModel();
            $this->installYzj = $this->setInstallYzj();
            $this->installWX = judgeCorpInfo('install_app');

            $this->installWXSelfBuilt = $this->setInstallWXSelfBuilt();
            $this->installZy = $this->setInstallZy();
            $this->installFanwei = $this->setInstallFanwei();
            $this->installTd = $this->setInstallTd();
            $this->remindTypeSet = true;
        }
    }

    //初始化云之家 - 判断是会否安装云之家
    public function setInstallYzj(){
        global $adb;
        $query = "select * from ld_wx_config where `name` = 'yunzhijia_setting' and para_content <> ''";
        $result = $adb->pquery($query,array());
        $num_rows = $adb->num_rows($result);
        if($num_rows >= 1){
            //require_once(globalStatic::$root_directory . "WeiXinApp/modules/Reminds/cls_reminds_yzj.php");
            return true;
        }else{
            return false;
        }
    }

    //初始化 - 判断是否安装致远OA
    public function setInstallZy(){
        global $adb;
        $query = "select * from ld_wx_config where `name` = 'zhiyuan_setting' and para_content <> ''";
        $result = $adb->pquery($query,array());
        $num_rows = $adb->num_rows($result);
        if($num_rows >= 1){
            return true;
        }else{
            return false;
        }
    }
    public function setInstallFanwei(){
        global $adb;
        $query = "select * from ld_wx_config where `name` = 'fanwei_setting' and para_content <> ''";
        $result = $adb->pquery($query,array());
        $num_rows = $adb->num_rows($result);
        if($num_rows >= 1){
            return true;
        }else{
            return false;
        }
    }
    public function setInstallTd(){
        global $adb;
        $query = "select * from ld_wx_config where `name` = 'tongda_setting' and para_content <> ''";
        $result = $adb->pquery($query,array());
        $num_rows = $adb->num_rows($result);
        if($num_rows >= 1){
            return true;
        }else{
            return false;
        }
    }
   
    //初始化钉钉提醒所需参数
    public function setEventModel()
    {
        require_once globalStatic::$root_directory.'appCommon/appCommon.php';
        //editor:gyq_20200227 reason:避免kehu001没有dingtalk目录，也走了event_model.故将是否安装钉钉抽出event_model
        if(judgeDingTalkInstall()){
            require_once globalStatic::$root_directory . 'WeiXinApp/dingtalk/model/event_model.php';
            $eventModel = new event_model();
            if ($eventModel->initConfig()) {
                $this->eventModel = $eventModel;
                return true;
            } else {
                return false;
            }
        }else{
            return false;
        }
    }
    //初始化企业微信自建应用 - 判断是会否安装企业微信自建应用
    public function setInstallWXSelfBuilt(){
        global $adb;
        $query = "select * from ld_wx_config where `name` = 'wxselfbuiltapp_setting' and para_content <> ''";
        $result = $adb->pquery($query,array());
        $num_rows = $adb->num_rows($result);
        if($num_rows >= 1){
            return true;
        }else{
            return false;
        }
    }
    //覆盖父类中的同名方法
    public function sendReminds($ids, $r_multi_content)
    {
        global $adb;
        // require_once(globalStatic::$root_directory.'/WeiXinApp/modules/Reminds/immediatelyReminds.php');
        crm_load_class_file('cls_StaticCommonFun', 'WeiXinApp/WeiXin_common');
        crm_load_class_file('StaticConst', 'WeiXinApp/WeiXin_common');
        $this->setRemindIds($ids);
        if(empty($ids)){
            $errorno= $this->send_multi_reminds($r_multi_content);
        }else{
            if (sizeof($ids) > 0 && $ids[0] > 0) {
                $errorno = $this->send_multi_reminds($r_multi_content);
                if (!$errorno) {
                    $sql = 'update ld_reminds set push_to_weixin=? ,push_time=?,push_to_wxselfbuilt=3 where remindsid in(' . implode(',', $ids) . ')';
                    $adb->pquery($sql, array(3, date("Y-m-d H:i:s")));

                }
            }
        }
        return $errorno;
    }

    //发送提醒,包含企业微信和钉钉提醒
    public function sendRemindsDing($ids, $r_multi_content)
    {
        global $adb;
        if(empty($ids)){
            //调用该方法后，已在外部更新的ids对应单据内容
            $this->sendMessage($ids,$r_multi_content);
        }else{
            if (sizeof($ids) > 0 && $ids[0] > 0) {
                $listKeyIds = $this->sendMessage($ids,$r_multi_content);
                $idsNew = array();
                $i = 0;
                foreach ($ids as $key=>$value){
                    // if(isset($listKeyIds[$key])){
                    //有两条以上的内容一样的提醒，会重复发送
                    $idsNew[$i] = $value;
                    $i++;
                    // }
                }
                $sql = 'update ld_reminds set push_to_ding=? ,push_time_ding=? where remindsid in(' . implode(',', $idsNew) . ')';
                $adb->pquery($sql, array(3, date("Y-m-d H:i:s")));
                /*if(is_object( $errorno)){
                    //记录钉钉接口调用错误日志
                    $time = date('Y-m-d H:i:s', time());
                    file_put_contents( globalStatic::$root_directory.'dataCache/weixin/sendRemindError.txt', $time.$errorno->errmsg . PHP_EOL, FILE_APPEND);
                }*/
            }
        }
    }

    public function sendRemindsWXSelfBuilt($ids, $r_multi_content)
    {
        global $adb;
//        crm_load_class_file('cls_StaticCommonFun', 'WeiXinApp/WeiXin_common');
        if ($this->installWXSelfBuilt) {
            if (sizeof($ids) > 0 && $ids[0] > 0) {
                $listKeyIds = $this->send_multi_reminds_wxselfbuilt($r_multi_content);
                /*$idsNew = array();
                $i = 0;
                foreach ($ids as $key=>$value){
                    //有两条以上的内容一样的提醒，会重复发送
                    $idsNew[$i] = $value;
                    $i++;
                }*/

                $sql = 'update ld_reminds set push_to_wxselfbuilt=?,push_time_wxselfbuilt=?,push_to_weixin=3 where remindsid in(' . implode(',', $ids) . ')';//全部更新已发送不准确，应该根据每一条发送情况更新发送状态
                $adb->pquery($sql, array(3, date("Y-m-d H:i:s")));
            }
            else{
                    //工作汇报 提醒，例如回复
               
                     $listKeyIds= $this->send_multi_reminds_wxselfbuilt($r_multi_content);
  
            }
        }
        return $listKeyIds;
    }

    //发送钉钉提醒
    protected function sendMessage($ids, $r_multi_content)
    {
        global $adb,$current_user;
        include_once globalStatic::$root_directory . 'WeiXinApp/dingtalk/lib/TopSdk.php';
        global $weixin_user;
        if (!is_object($weixin_user)) {
            crm_load_class_file('weixin_user', 'WeiXinApp/modules/Users');
            $weixin_user = new weixin_user();
        }
        $weixin_user->action = 'dingtalk_remind';
        $weixinNewLine = $this->newline;
        $this->newline = '  
';//就要这样写，否则提醒字体会变大（必须换行，必须换行）
        $token = $this->getTokenCache();
        if (!$token) {
            return true;
        }
        //待审批消息通知是否推送到钉钉待办中
        $deploy_values_491=getSys_deploy(491);

        $listIds = array();
        $client = new DingTalkClient(DingTalkConstant::$CALL_TYPE_OAPI, DingTalkConstant::$METHOD_POST, DingTalkConstant::$FORMAT_JSON);
        $request = new OapiMessageCorpconversationAsyncsendV2Request;
        //因为审批类待办提醒消息是一对多的关系（即ids多个remindsid对应一个消息内容），所以需要循环，因为要用reminds作为消息的唯一标识去记录，然后转已办，，以前的普通消息是不需要去关注remindsid的，可以一条内容发送给多个人，故做此修改。
        if(!empty($ids)){
            foreach($ids as $key => $remindsid){
                foreach ($r_multi_content as $news_content) {
                    $r_userid_arr = $news_content['userid_ding'];
                    if (!is_array($r_userid_arr) || empty($r_userid_arr)) {
                        //editor:gyq_165不确定 reason:此处中断应该如何做   2019/12/27 11:55
                        break;
                    }
                    if (is_array($userid_openid))  $userid_openid = implode(',',$userid_openid);
                    //BUG20240520-14 钉钉移动端，客户即将回收和回收提醒消息中，显示乱码(去掉a标签)
                    $massageContent =  str_replace($weixinNewLine, $this->newline,  htmlspecialchars_decode(html_entity_decode($news_content['message'])));
                    $r_reltab = $news_content['reltab'];
                    $r_related_to = $news_content['related_to'];
                    $r_date_time = $news_content['date_time'];
                    $r_remindtype = $news_content['remindtype'];
                    $location = '';
                    if ($r_reltab == 'CooperativeWork') {
                        $title = $news_content['title'];
                        if(empty($title)){
                            $title = getTranstab('CooperativeWork');
                        }
                        $entitytype = $news_content['entitytype'];
                        $news_title = $title;
                        $modulelabel = $news_content['modulelabel'];

                        $location = 'ldcrm/index.html#!/work_detail/' . $r_related_to . '/' . $entitytype . '/' . $this->filterstring($modulelabel);
                    } elseif ($r_reltab == 'Users') {
                        //指向成员详情界面的提醒，由于企业微信没做成员详情模块，现将关联模块是用户的提醒，不赋值跳转链接，禁止消息穿透
                        $news_title = '消息提醒';
                        $listtype = 'list';
                        $r_related_to = '';
                    } else {
                        if ($r_remindtype == 'massallocate' || $r_remindtype == 'massshare') {
                            $news_title = '消息提醒';
                            $modulelabel = getTranstab($r_reltab);
                            $location = 'ldcrm/index.html#!/listview/' . $r_reltab . '/' . $this->filterstring($modulelabel) . '/-1/mass_remind/' . $r_related_to;
                        } elseif ($r_remindtype == 'Approve'|| $r_remindtype == 'ExpeditingApprove') {
                            $listtype = 'approvelist';
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
                            //合同交付提醒、服务合同产品到期提醒、收款计划到期提醒、付款计划到期提醒
                            $news_title = getFixedLabel($r_remindtype.'Remind');//【合同订单】交付提醒
                        }elseif($r_remindtype == 'MODULECOMMENTRemind'){//评论提醒
                            $news_title = sprintf(getFixedLabel($r_remindtype),getTranstab($r_reltab));//【模块名称】评论提醒
                        }elseif($r_remindtype == 'ModuleCreateRemind'){//新增提醒
                            $r_reltab = !empty($r_reltab)?$r_reltab:'Reminds';//发件箱不选相关对象时,提醒标题错误
                            $news_title = sprintf(getFixedLabel($r_remindtype),getTranstab($r_reltab));//【模块名称】新增提醒
                        }
                        elseif(in_array($r_remindtype,array('AccountsRECYCLEREMIND','LeadsRECYCLEREMIND','AccountsHEDGINGREMIND','AccountsBEFOREREMIND','LeadsBEFOREREMIND'))){
                            //remindstype直接转为翻译：公海回收、报备提醒
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
                        //wym 240522 BUG20240520-15  销售线索即将回收提醒，右上角弹窗中多了个编号字段 (relatedto为0时也是为空)
						$related_to_str = '';//提醒增加相关对象行
                        if ($r_related_to && $r_remindtype != 'massallocate' && $r_remindtype != 'massshare'&& !in_array($r_remindtype,array('AccountsRECYCLEREMIND','LeadsRECYCLEREMIND','AccountsBEFOREREMIND','LeadsBEFOREREMIND'))){
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
                            $massageContent .= $this->newline .$related_to_lable.'：'.$related_to_name;
                        }



                    }
                    if($news_title=='')
                    {
                        $news_title='消息提醒';
                    }



                    //$describ = str_replace('&#039;', '\'', htmlspecialchars_decode(html_entity_decode($massageContent)));
                    $newsArr = array();//消息体
                    $describ = strip_tags(str_replace('"', '\"', $massageContent), '<br>');
                    $describ = str_replace('&lt;br&gt;', $this->newline, $describ);
                    $describ .= $this->newline . '操作时间：' . $r_date_time;
                    if (!empty($r_related_to) && empty($location)) {
                        $modulelabel = getTranstab($r_reltab);
                        $location = 'ldcrm/index.html#!/detailview/' . $r_reltab . '/' . $r_related_to . '/' . $this->filterstring($modulelabel) . '/' . $listtype . '/yes/-1';
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
                    $messageUrl = $this->eventModel->_login_url . '/WeiXinApp/dingtalk/websaas/' . $location . '?corpid=' . $this->eventModel->_corpid . '&corpurl=' . $this->eventModel->_login_url . '/&fromlogintype=remindsmsg';


                    $approveresult = $news_content['approveresult'];
                    if($r_remindtype == 'Approve' && ($approveresult == 1 || $approveresult == 5||$approveresult == 6) && $deploy_values_491['deploy_value']=='yes'){
                        if (empty($r_userid_arr[$key])) continue;
                        $dingtalk_unionid = $this->getDingUnionidByUserid($r_userid_arr[$key]);

                        if (isset($news_content['creator']) && !empty($news_content['creator'])) {
                            $creatorid = $news_content['creator'];//扫描提醒
                        }else{
                            $creatorid = $current_user->id;//立即提醒消息
                        }
                        $creator = $this->getDingUnionidByid($creatorid);
                        if (empty($creator)) {
                            $creator = explode(',',$dingtalk_unionid)[0];
                        }
                        $describ = strip_tags($describ, '<br>');
//                        $remindsid = !empty($news_content['remindsid'])?$news_content['remindsid']:$remindsid;//扫描提醒有remindsid，且与ids是一一对应的,但是审批提醒是多个ids对应一个
                        //走 创建钉钉待办任务 接口
                        $newsArr['sourceId'] = $remindsid;//主键不重复就行  可以使用remindsid或者随机数，钉钉业务这个值后面就用不到了
                        $newsArr['subject'] = $describ;
                        $newsArr['creatorId'] = $creator;//转为 dingtalk_unionid  TODO
                        $newsArr['detailUrl']['pcUrl'] = "dingtalk://dingtalkclient/page/link?url=".urlencode($messageUrl)."&pc_slide=true";
                        $newsArr['detailUrl']['appUrl'] = $messageUrl;
                        $newsArr['done'] = false;
                        $newsArr['executorIds'] = explode(',',$dingtalk_unionid);//执行人(接收人)  TODO
                        $newsArr['isOnlyShowExecutor'] = true;
//                $newsArr['notifyConfigs']['dingNotify'] = "1";//DING通知配置，目前仅支持取值为1，表示应用内DING。



                        $url = "https://api.dingtalk.com/v1.0/todo/users/".$creator."/tasks";//创建钉钉待办任务  operatorId可以不添加
                        $body = json_encode($newsArr);
                        $headers = [
                            'x-acs-dingtalk-access-token:' . $token,
                            'Content-Type: application/json;charset=utf-8;'
                        ];
                        $method = 'POST';
                        $response = $this->_Curl($url,$body,$method,$headers);
                        $response = json_decode($response);
                        if($response->code == 'InvalidAuthentication'){//access_token过期或者不存在，需要重新获取一下。
                            //file_put_contents(globalStatic::$root_directory . 'dataCache/weixin/ding_MessageSend_errorlog.txt', date('Y-m-d H:i:s').': 待办请求数据：'.$body . "\r\n", FILE_APPEND);
                            //file_put_contents(globalStatic::$root_directory . 'dataCache/weixin/ding_MessageSend_errorlog.txt', date('Y-m-d H:i:s').': 待办响应数据：'.json_encode($response,JSON_UNESCAPED_UNICODE) . "\r\n", FILE_APPEND);
                            $token = $this->getTokenCache('refresh');
                            $headers = [
                                'x-acs-dingtalk-access-token:' . $token,
                                'Content-Type: application/json;charset=utf-8;'
                            ];
                            $response = $this->_Curl($url,$body,$method,$headers);
                            $response = json_decode($response);
                        }

                        //发送成功后插入临时表
                        if (!isset($response->code) && isset($response->id)) {
                            $select_result = $adb->pquery("select 1 from ld_reminds_agenda where remindsid=? limit 1", array($remindsid));
                            if ($adb->num_rows($select_result) > 0) {
                                $adb->pquery("update ld_reminds_agenda set dingtalk_agendadata=?,approvelogid=? where remindsid=?", array(json_encode($response,JSON_UNESCAPED_UNICODE),$news_content['approvelogid'],$remindsid));
                            }else{
                                $inser_sql = "insert into ld_reminds_agenda(remindsid,dingtalk_agendadata,approvelogid) VALUES (?,?,?)";
                                $params = array($remindsid,json_encode($response,JSON_UNESCAPED_UNICODE),$news_content['approvelogid']);
                                $adb->pquery($inser_sql, $params);
                            }

                        }else{
                            file_put_contents(globalStatic::$root_directory . 'dataCache/weixin/ding_MessageSend_errorlog.txt', date('Y-m-d H:i:s').': 待办请求数据：'.$body . "\r\n", FILE_APPEND);
                            file_put_contents(globalStatic::$root_directory . 'dataCache/weixin/ding_MessageSend_errorlog.txt', date('Y-m-d H:i:s').': 待办响应数据：'.json_encode($response,JSON_UNESCAPED_UNICODE) . "\r\n", FILE_APPEND);
                        }

                    }else{
                        //组装钉钉提醒结构
                        $request->setUseridList(implode(',', $r_userid_arr));
                        $request->setAgentId($this->eventModel->_agentid);
                        $request->setToAllUser(false);
//                $messageUrl = $this->eventModel->_login_url . '/WeiXinApp/dingtalk/websaas/' . $location . '?corpid=' . $this->eventModel->_corpid . '&corpurl=' . $this->eventModel->_login_url . '/&fromlogintype=remindsmsg';
                        //editor:gyq_20200107
                        //0039099: （kfbcrm）钉钉PC端登录，点击提醒消息，使用新的浏览器打开的详情。预期结果：应该使用钉钉内部浏览器打开详情
                        //$newsArr['link']['picUrl'] = $this->getModuleImg($r_reltab);
                        $newsArr['msgtype'] = 'action_card';
                        $newsArr['action_card']['single_url'] = $messageUrl;
                        $newsArr['action_card']['single_title'] = '查看详情';
                        $newsArr['action_card']['title'] = $news_title;
                        $newsArr['action_card']['markdown'] = '# '.$news_title.$this->newline.$describ;
                        $request->setMsg($newsArr);
                        $result = $client->execute($request, $token, 'https://oapi.dingtalk.com/topapi/message/corpconversation/asyncsend_v2');
                        //接口报错，中断循环
                        /*$remindsid=0;
                        if(array_key_exists('remindsid',$news_content))
                            $remindsid=$news_content['remindsid'];
                        $sql='insert into ld_dingreminds(remindsid,createdtime,content,errorcode)value(?,?,?,?)';
                        $adb->pquery($sql, array($remindsid, date("Y-m-d H:i:s"),$news_content['message'],$result->errcode));*/

                        if($result->errcode == '400002'){
                            continue;
                        }elseif($result->errcode > 0){
                            $token = $this->getTokenCache('refresh');
                            $result = $client->execute($request, $token, 'https://oapi.dingtalk.com/topapi/message/corpconversation/asyncsend_v2');
                            if($result->errcode > 0){
                                break;
                            }
                        }
                    }

                    //拿浏览器测试扫描发送时发小，消息还没发完浏览器就提示404断开服务了，结果已发送的消息状态没更新导致重复发送。
                    $sql = 'update ld_reminds set push_to_ding=? ,push_time_ding=? where remindsid in(' . $remindsid . ')';
                    $adb->pquery($sql, array(3, date("Y-m-d H:i:s")));

                    $listIds[$key] = 1;
                }
            }
        }

        return $listIds;
    }

    public function getDingUnionidByid($received_id){
        global $adb;
        $sql = 'select GROUP_CONCAT(dingtalk_unionid) from ld_users 
            where id in( ' . $received_id . ') and ifnull(dingtalk_unionid,\'\') <> \'\'  AND push_wx_reminds=1 ';
        $result = $adb->pquery($sql, array());
        return $adb->query_result($result,0,0);
    }
    public function getDingUnionidByUserid($received_id){
        global $adb;
        if (is_array($received_id)) {
            $received_id = implode(',',$received_id);
        }
        $sql = 'select GROUP_CONCAT(dingtalk_unionid) from ld_users 
            where FIND_IN_SET(dingtalk_userid,"'.$received_id.'") and ifnull(dingtalk_unionid,\'\') <> \'\'  AND push_wx_reminds=1 ';
        $result = $adb->pquery($sql, array());
        $dingtalk_unionid = '';
        if($adb->num_rows($result)>0){
            $dingtalk_unionid = $adb->query_result($result,0,0);
        }

        return $dingtalk_unionid;
    }
    //获取提醒接口秘钥
    public function getTokenCache($rType='')
    {
        global $adb;
        $sql = 'select time,datetime,para_one from ld_wx_config where name=?';
        $result = $adb->pquery($sql, array($this->dingApiName));
        $time = $adb->query_result($result, 0, 'time');
        $datetime = $adb->query_result($result, 0, 'datetime');
        $token = $adb->query_result($result, 0, 'para_one');
        $timeinteval = time() - intval($time);
        if ($timeinteval > 6000 || $rType=='refresh') {
            $url = 'https://oapi.dingtalk.com/gettoken?appkey=' . $this->eventModel->_appkey . '&appsecret=' . $this->eventModel->_appsecret;
            $result = CurlGet($url)['content'];
            $url_content = json_decode($result, true);
            if ($url_content['errcode'] === 0) {
                $token = $url_content['access_token'];
                $sql_update = 'update ld_wx_config set para_one=?,time=?,datetime=? where name=?';
                $adb->pquery($sql_update, array($token, time(), date('Y-m-d H:i:s', time()), $this->dingApiName));
                return $token;
            } else {
                return false;
            }
        } else {
            return $token;
        }
    }

    //发送企业微信自建应用提醒
    protected function send_multi_reminds_wxselfbuilt($r_multi_content)
    {
        global $adb;
        crm_load_class_file("cls_WeiXinSelfBuiltApp", 'WeiXinApp/WeiXin_common');
        $wxselfbuilt_obj = new cls_WeiXinSelfBuiltApp();
        $corp_link = $wxselfbuilt_obj->corp_link;
        $corpid = $wxselfbuilt_obj->corpid;
        $corpsecret = $wxselfbuilt_obj->corpsecret;
        $agentid = $wxselfbuilt_obj->agentid;

        if (empty($corpid) || empty($corpsecret) || empty($corp_link) || empty($agentid)) {
            return array('errcode'=>'40013');
        }
        include_once(globalStatic::$root_directory."vendor/weworkapi_php/api/src/CorpAPI.class.php");
//        $api = new CorpAPI($corpid, $corpsecret);

        $listIds = array();
        foreach ($r_multi_content as $key => $news_content) {
            $r_userid_arr = $news_content['userid'];
            if (!is_array($r_userid_arr) || empty($r_userid_arr)) {
                // ConvertTojsonString(-1, array(), 'Error:userid数据异常!');
                continue;
            }
            $r_content = $news_content['message'];
            $r_reltab = $news_content['reltab'];
            $r_related_to = $news_content['related_to'];
            $r_date_time = $news_content['date_time'];
            $r_remindtype = $news_content['remindtype'];

            $location = '';
            $related_to_str = '';
            if ($r_reltab == 'CooperativeWork') {
                $title = $news_content['title'];
                $entitytype = $news_content['entitytype'];
                $news_title = $title;
                $modulelabel = $news_content['modulelabel'];

                $location = 'ldcrm/index.html#!/work_detail/' . $r_related_to . '/' . $entitytype . '/' . $this->filterstring($modulelabel);
            } elseif ($r_reltab == 'Users') {
                //editor:gyq_20190326 reason:指向成员详情界面的提醒，由于企业微信没做成员详情模块，
                //现将关联模块是用户的提醒，不赋值跳转链接，禁止消息穿透
                $news_title = '消息提醒';
                $listtype = 'list';
                $r_related_to = '';
            } else {
                if ($r_remindtype == 'massallocate' || $r_remindtype == 'massshare') {
                    $news_title = '消息提醒';
                    $modulelabel = getTranstab($r_reltab);
                    $location = 'ldcrm/index.html#!/listview/' . $r_reltab . '/' . $this->filterstring($modulelabel) . '/-1/mass_remind/' . $r_related_to;
                } elseif ($r_remindtype == 'Approve'|| $r_remindtype == 'ExpeditingApprove') {
                    $listtype = 'approvelist';
                    $news_title = '审批提醒';
                } else {
                    $news_title = '消息提醒';
                    $listtype = 'list';
                }

                //zkt 20220520 51988(https://81mis.com/kfbcrm/index.php)（消息提醒标签修改）系统设置》参数设置》自动提醒设置》合同订单》在移动端提醒没有【模块名称】
                //zkt 20220520  【ID1002781】【审批、分配、共享等“消息提醒”标签修改为【模块】操作提醒（第一版）】
                if($r_remindtype =='ForceAntiApprove'){//强制驳回提交审批
                    $news_title = '【'.getTranstab($r_reltab).'】'.getFixedLabel('FORCEDREJECTSUBMITAPPROVAL');
                }
                elseif($r_remindtype =='AntiApprove'){//反审批
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
                }elseif($r_remindtype == 'ModuleCreateRemind'){//新增提醒
                    $news_title = sprintf(getFixedLabel($r_remindtype),getTranstab($r_reltab));//【模块名称】新增提醒
                }
                elseif(in_array($r_remindtype,array('AccountsRECYCLEREMIND','LeadsRECYCLEREMIND','AccountsHEDGINGREMIND','AccountsBEFOREREMIND','LeadsBEFOREREMIND'))){
                    //remindstype直接转为翻译：公海回收、报备提醒
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
                if ($r_related_to && $r_remindtype != 'massallocate' && $r_remindtype != 'massshare'&& !in_array($r_remindtype,array('AccountsRECYCLEREMIND','LeadsRECYCLEREMIND','AccountsBEFOREREMIND','LeadsBEFOREREMIND'))){
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
                    $r_content .= $this->newline .$related_to_lable.'：'.$related_to_name;
                }
            }

            $describ = str_replace('&#039;', '\'', htmlspecialchars_decode(html_entity_decode($r_content)));


            if(stripos($describ,'/ww-open-data')!==false){
                //企业微信id转义
                require_once(globalStatic::$root_directory."include/simple_html_dom.php");
                $htmlparseobj = new simple_html_dom();
                $htmlparseobj->load($describ);
                $tmphtml_arr=$htmlparseobj->find('ww-open-data');
                foreach($tmphtml_arr as $tmpparser)
                {
                    $type=$tmpparser->type;
                    $openid=$tmpparser->openid;
                    if($type=='userName'){
                        $tmpparser->outertext ='$userName='.$openid.'$';
                    }
                    else
                    {
                        $tmpparser->outertext ='$departmentName='.$openid.'$';
                    }
                }

                $describ=$htmlparseobj->innertext;

            }
            $describ = strip_tags(str_replace('"', '\"', $describ), '<ww-open-data><br>');


            $describ .= $this->newline . '操作时间：' . $r_date_time;
            if (!empty($r_related_to) && empty($location)) {
                $modulelabel = getTranstab($r_reltab);
                $location = 'ldcrm/index.html#!/detailview/' . $r_reltab . '/' . $r_related_to . '/' . $this->filterstring($modulelabel) . '/' . $listtype . '/yes/-1';
            }elseif(empty($r_related_to)){
                //gyq_20190529 reason:现在企业微信提醒，无论传值如何，内容如何，都会有下方的详情按钮。
                //那么CRM端没有指向的消息提醒或企业微信端还没做跳转的提醒，给它跳转到应用首页  2019/5/29 17:44 0037105
                //0037105: 公海客户提醒，无法点击进入“详情”
                $location = 'ldcrm/index.html#!/';
            }

            $url = $corp_link."/WeiXinApp/selfbuildSass/" .$location;

            $nonceStr = $wxselfbuilt_obj->nonceStr;
            $timestamp = $wxselfbuilt_obj->timestamp;
            $signature = $wxselfbuilt_obj->getJsApiSignature();//企业签名
            $agent_signature = $wxselfbuilt_obj->getAgentJsApiSignature();//应用签名

//            $r_userid_arr = array('dolphindreammmmmmms');
//            $wx_userid = $r_userid_arr[0];//给多个用户发送提醒时有问题，取值不对
            foreach($r_userid_arr as $tmp_wxuserid) {
                $tmp_url = "?corpurl=" . $corp_link . "&deviceid=" . $wxselfbuilt_obj->deviceId . "&corpindex=&corpid=" . $corpid . "&tamptimes=" . $timestamp . "&noncestr=" . $nonceStr . "&signature=" . $signature . "&agent_signature=" . $agent_signature . "&expired_type=1";
                if (empty($tmp_wxuserid)) continue;
                $new_url = $url.$tmp_url.'&fromlogintype=remindsmsg';
                //重设访问路径 BUG20240902-27 企业微信和order绑定，看点进去，会提示登录已经过期，登陆后跳转的是工作台界面，不是这个消息，但是我关闭窗口后重新点这个依旧是登录已过期，应该是正确登录的状态
                $new_url = $corp_link."/Register/getMsgCode.php?crm_directurl=".urlencode($new_url);
                $new_url .= "&wx_userid=$tmp_wxuserid";

                if($news_title=='')
                {
                    $news_title='消息提醒';
                }
                $btntxt = '详情';
                $message = new Message();
                {
                    $message->sendToAll = false;
                    $message->touser = array($tmp_wxuserid);//数组
                    $message->toparty = array();
                    $message->totag = array();
                    $message->agentid = $agentid;
                    $message->safe = 0;

                    $message->messageContent = new TextCardMessageContent($news_title, $describ, $new_url, $btntxt);
                }
                $invalidUserIdList = null;
                $invalidPartyIdList = null;
                $invalidTagIdList = null;

                $data = $wxselfbuilt_obj->corpApiObj->MessageSend($message, $invalidUserIdList, $invalidPartyIdList, $invalidTagIdList);
                if ($data['errcode'] === 0) {
//                    $sql = 'update ld_reminds set push_to_wxselfbuilt=?,push_time_wxselfbuilt=?,push_to_weixin=3 where remindsid =?';
//                    $adb->pquery($sql, array(3, date("Y-m-d H:i:s"), $news_content['remindsid']));
                } else {
                    file_put_contents(globalStatic::$root_directory . 'dataCache/weixin/selfbuilt_MessageSend_errorlog.txt', date('Y-m-d H:i:s').': '.json_encode($data,JSON_UNESCAPED_UNICODE) . "\r\n", FILE_APPEND);
                    continue;
                }
            }
            $listIds[$key] = 1;
        }

        return $listIds;

    }

    //获取链接提醒的图标
    public function getModuleImg($modulename)
    {
        $img_url = 'http://www.71mis.cn/wx_images/';
        //默认图标为公告小喇叭图标
        if (empty($modulename)) {
            return $img_url . "crm/crm_PublicAnnouncement.png";
        } else {
            switch ($modulename) {
                case 'salesfunnel': //销售漏斗
                case 'SalesFunnelReport':
                    return $img_url . "report/crm_Report01.png";
                    break;
                case 'ClueSourceReport':
                    return $img_url . "report/crm_Report02.png";
                    break;
                case 'CluedistributionReport':
                    return $img_url . "report/crm_Report03.png";
                    break;
                case 'signednumber': //签约数量龙虎榜
                case 'signedamount': //签约金额龙虎榜
                case 'cashbillamount': //回款金额龙虎榜
                case 'paymentamount':
                case 'expense_commission': //费用佣金统计表
                case 'coststatistics':
                case 'FailureAnalysisReport':
                    return $img_url . "report/crm_Report04.png";
                    break;
                case 'accountaccounttype': //客户类型分布统计
                case 'accountleadsource': //客户来源分布统计
                case 'contractamount': //签约金额同比
                case 'returnamount': //回款金额同比
                case 'salessituation': //最近6个月销售情况
                    return $img_url . "report/crm_Report05.png";
                    break;
                case 'FailureAnalysisReport11':
                    return $img_url . "report/crm_Report06.png";
                    break;
                case 'daylog': //工作汇报日志统计表
                case 'weeklog': //周计划统计表
                case 'monthlog': //月计划统计表
                case 'salesordertrack': //合同跟踪表
                case 'cashbillsum_salesorder': //应收款统计表_按合同统计
                case 'cashbillsum_paymentplan': //应收款统计表_按回款计划统计
                case 'inventoryquery': //即时库存查询
                    return $img_url . "report/crm_Report07.png";
                    break;
                case 'saleskit': //销售简报
                case 'saleskit_yangduan': //扬锻：销售简报
                case 'contractkit': //合同简报
                    return $img_url . "report/crm_Report08.png";
                    break;
            }
            if (stripos($modulename, 'CustomForm') !== false) {
                return $img_url . "crm/crm_CustomForm.png";
            } else {
                return $img_url . "crm/crm_" . $modulename . ".png";
            }
        }
    }

    /**
     * 工作汇报提醒
     *
     * */
    public function workreport_reminds_aftersave($workreportid)
    {
        global $adb;
        //发提醒前先判断可以发哪些类型的提醒
        if (!$this->installDing && !$this->installWX && !$this->installYzj && !$this->installWXSelfBuilt && !$this->installZy && !$this->installFanwei) {
            return false;
        }
        $n = $this->newline;
        crm_load_class_file('WorkReportModel', 'modules/Home');
        $this->workmodel = $workobj = new WorkReportModel();
        $workfldarr = $workobj->getWorkCfFieldInfo('workreport');
        $workfldsql = '';

        if (!empty($workfldarr)) {
            $workfldkeyarr = array_keys($workfldarr);
            $workfldsql = ',ld_workreportcf.' . join(',ld_workreportcf.', $workfldkeyarr);
        }


        $usersql = $wxSelfbuiltUsersql = 'SELECT 
                                            GROUP_CONCAT(ld_users.wx_userid SEPARATOR \'|\') wx_userid,
                                            ld_workreport2user.User_type
                                        FROM ld_workreport2user 
                                        LEFT JOIN ld_users on ld_users.id = ld_workreport2user.userid
                                        WHERE length(ld_users.wx_userid)>0 
                                            AND ld_workreport2user.workreportid=? 
                                            AND ld_users.push_wx_reminds=1
                                        GROUP BY ld_workreport2user.User_type                        
                                        ORDER BY ld_workreport2user.User_type DESC ';
        $dingUserSql = 'SELECT 
                                            GROUP_CONCAT(ld_users.dingtalk_userid SEPARATOR \'|\') dingtalk_userid,
                                            ld_workreport2user.User_type
                                        FROM ld_workreport2user 
                                        LEFT JOIN ld_users on ld_users.id = ld_workreport2user.userid
                                        WHERE length(ld_users.dingtalk_userid)>0 
                                            AND ld_workreport2user.workreportid=? 
                                            AND ld_users.push_wx_reminds=1
                                        GROUP BY ld_workreport2user.User_type                        
                                        ORDER BY ld_workreport2user.User_type DESC ';
        $yzjUserSql = 'SELECT 
                                            GROUP_CONCAT(ld_users.yunzhijia_openid SEPARATOR \'|\') yunzhijia_wbuserid,
                                            ld_workreport2user.User_type
                                        FROM ld_workreport2user 
                                        LEFT JOIN ld_users on ld_users.id = ld_workreport2user.userid
                                        WHERE length(ld_users.yunzhijia_openid)>0 
                                            AND ld_workreport2user.workreportid=? 
                                            AND ld_users.push_wx_reminds=1
                                        GROUP BY ld_workreport2user.User_type                        
                                        ORDER BY ld_workreport2user.User_type DESC ';
        $zyUserSql = 'SELECT 
                                            GROUP_CONCAT(ld_users.zhiyuan_userid SEPARATOR \'|\') zhiyuan_userid,
                                            ld_workreport2user.User_type
                                        FROM ld_workreport2user 
                                        LEFT JOIN ld_users on ld_users.id = ld_workreport2user.userid
                                        WHERE length(ld_users.zhiyuan_userid)>0 
                                            AND ld_workreport2user.workreportid=? 
                                            AND ld_users.push_wx_reminds=1
                                        GROUP BY ld_workreport2user.User_type                        
                                        ORDER BY ld_workreport2user.User_type DESC ';
        $fanweiUserSql = 'SELECT 
                                            GROUP_CONCAT(ld_users.fanwei_userid SEPARATOR \'|\') fanwei_userid,
                                            ld_workreport2user.User_type
                                        FROM ld_workreport2user 
                                        LEFT JOIN ld_users on ld_users.id = ld_workreport2user.userid
                                        WHERE length(ld_users.fanwei_userid)>0 
                                            AND ld_workreport2user.workreportid=? 
                                            AND ld_users.push_wx_reminds=1
                                        GROUP BY ld_workreport2user.User_type                        
                                        ORDER BY ld_workreport2user.User_type DESC ';
        $worksql = 'SELECT
                                            ld_workreport.entitytype,
                                            ld_workreport.workexperience,
                                            ld_workreport.type,
                                            ld_workreport.createdtime,
                                            ld_workreport.worksummary,
                                            ld_workreport.workplan,
                                            ld_workreport.enddate,
                                            ld_workreport.startdate,
                                            ld_users.last_name,
                                            ld_users.wx_userid,
                                            ld_workreport.smcreatorid' . $workfldsql . '
                                        FROM ld_workreport
                                        inner join ld_workreport_remind on ld_workreport.workreportid = ld_workreport_remind.relatedto
                                        LEFT JOIN ld_users on ld_users.id = ld_workreport.smcreatorid
                                        LEFT JOIN ld_workreportcf on ld_workreportcf.workreportid = ld_workreport.workreportid
                                        
                                        WHERE length(ld_workreport.entitytype) > 0 AND ld_workreport.workreportid=?';

        $TransforSecondCategory = array(1 => getFixedLabel('JOURNAL'), 2 => getFixedLabel('WEEKPLAN'), 3 => getFixedLabel('MONTHPLAN'),'6'=>getFixedLabel('TASK'));
        $HomeTransfor = array('1' => 'dayreport', '2' => 'weekreport', '3' => 'monthreport');
        $result = $adb->pquery($worksql, array($workreportid));
        $number = $adb->num_rows($result);

        for ($i = 0; $i < $number; $i++) {
            $id = $adb->query_result($result, $i, 'id');
            $relatedto = $adb->query_result($result, $i, 'relatedto');
            $entitytype = $adb->query_result($result, $i, 'entitytype');
            $wx_userid=$adb->query_result($result,$i,'wx_userid');
            $last_name = $adb->query_result($result, $i, 'last_name');

            $userobj=new Users();
            $userobj->wx_userid=$wx_userid;
            $userobj->last_name=$last_name;
            $last_name=getWxMobileRemindInfo($userobj);
            // dump($last_name);
            $type = $adb->query_result($result, $i, 'type');
            $createdtime = $adb->query_result($result, $i, 'createdtime');
            $startdate = $adb->query_result($result, $i, 'startdate');
            $worksummary = $adb->query_result($result, $i, 'worksummary');
            $lastname = $adb->query_result($result, $i, 'last_name');
            $workplan = $adb->query_result($result, $i, 'workplan');
            $workexperience = $adb->query_result($result, $i, 'workexperience');
            if ($entitytype == 'workreport') {

                $workReportTemplate = $workobj->getallFieldsForTable();

                $workTemplate = $workReportTemplate['workreport'][$HomeTransfor[$type]]['fieldinfo'];
                $descriptionW = '';

                foreach ($workTemplate as $key => $val) {
                    if (!empty($val['name'])) {
                        //edit:can 2020-12-15 43692: （http://81.68.124.239:85/crm/ [^]）（内蒙古润友）企业微信中的工作汇报提醒会显示详情，但是最近不显示了，希望可以显示详情
                        $fname =$adb->query_result($result, $i,  $val['name']);;
                        $fname = str_replace("\n", $n, $fname);
                        if (strpos($val['label'], '请填写') === 0) {
                            $label = substr($val['label'], 9);
                        } else {
                            $label = $val['label'];
                        }
                        $descriptionW .= $label . $n . $fname . $n;
                    }
                }

            }

            //提醒人
            if($this->installWX) {
                $useridexist = array();
                $userresult = $adb->pquery($usersql, array($workreportid));
                for ($j = 0; $j < $adb->num_rows($userresult); $j++) {
                    $remind = '';
                    $userid2 = $adb->query_result($userresult, $j, 'wx_userid');
                    if (array_search($userid2, $useridexist) === false) {
                        $usertype2 = $adb->query_result($userresult, $j, 'user_type');

                        if ($usertype2 == 5) {
                            $useridexist[$usertype2] = $userid2;
                            $descriptionFinal[$usertype2] = '发布人：' . $last_name . $n . '发布时间: ' . $createdtime . $n . $descriptionW;
                            $secondPara = $TransforSecondCategory[$type];
                            $modulelabel[$usertype2] = $secondPara;
                            $title[$usertype2] ='【' .getTranstab('CooperativeWork').'】点评提醒|有新的' . $secondPara . '需要您点评';
                            $description_mini[$usertype2][0] = array('key' => '发布人', 'value' => $last_name);
                            $description_mini[$usertype2][1] = array('key' => '发布时间', 'value' => $createdtime);
                            $description_mini[$usertype2][2] = array('key' => '内容', 'value' => $descriptionW);
                        } elseif ($usertype2 == 6) {
                            $useridexist[$usertype2] = $userid2;
                            $descriptionFinal[$usertype2] = '请于' . $startdate . '之前完成' . $n . '发布人：' . $last_name . $n . '发布时间: ' . $createdtime . $n . $workexperience;
                            //BUG0071296 ls 20230817 收到的任务执行提醒中，消息提醒的标签修改为“【工作汇报】执行提醒|有新的任务需要您执行”
                            $secondLine = '【' .getTranstab('CooperativeWork').'】执行提醒|有新的任务需要您执行';
                            $title[$usertype2] = $secondLine;
                            //edit:can 20211011 48200: （https://61mis.com/WX/kh41300 [^] [^]）（卫诗理灯具）工作汇报发布任务-企业微信PC端口进去-进不去消息详情页，显示空白如图所示，81MISkfbcrm也有这样的问题
                            $modulelabel[$usertype2] = $TransforSecondCategory[$type];;
                            $description_mini[$usertype2][0] = array('key' => '内容一', 'value' => '请于' . $startdate . '之前完成');
                            $description_mini[$usertype2][1] = array('key' => '发布人', 'value' => $last_name);
                            $description_mini[$usertype2][2] = array('key' => '发布时间', 'value' => $createdtime);
                            $description_mini[$usertype2][3] = array('key' => '内容二', 'value' => $workexperience);
                        } elseif ($usertype2 == 1 || $usertype2 == 2) {
                            $useridexist[$usertype2] = $userid2;
                            if ($entitytype == 'workreport') {
                                $secondPara = $TransforSecondCategory[$type];
                                $descriptionFinal[$usertype2] = '发布人：' . $last_name . $n . '发布时间: ' . $createdtime . $n . $descriptionW;
                                $description_mini[$usertype2][0] = array('key' => '发布人', 'value' => $last_name);
                                $description_mini[$usertype2][1] = array('key' => '发布时间', 'value' => $createdtime);
                                $description_mini[$usertype2][2] = array('key' => '内容', 'value' => $descriptionW);
                            } elseif ($entitytype == 'cocmd') {
                                $secondPara = getFixedLabel('TASK');
                                $descriptionFinal [$usertype2] = '发布人：' . $last_name . $n . '发布时间: ' . $createdtime . $n . $workexperience;
                                $description_mini[$usertype2][0] = array('key' => '发布人', 'value' => $last_name);
                                $description_mini[$usertype2][1] = array('key' => '发布时间', 'value' => $createdtime);
                                $description_mini[$usertype2][2] = array('key' => '内容', 'value' => $workexperience);
                            } else {
                                $secondPara = getFixedLabel('BLOG');
                                $descriptionFinal[$usertype2] = '发布人：' . $last_name . $n . '发布时间: ' . $createdtime . $n . $workexperience;
                                $description_mini[$usertype2][0] = array('key' => '发布人', 'value' => $last_name);
                                $description_mini[$usertype2][1] = array('key' => '发布时间', 'value' => $createdtime);
                                $description_mini[$usertype2][2] = array('key' => '内容', 'value' => $workexperience);
                            }
                            $modulelabel[$usertype2] = $secondPara;
                            if ($usertype2 == 1) {
                                $title[$usertype2] ='【' .getTranstab('CooperativeWork').'】抄送提醒|有新的' . $secondPara . '抄送给您';

                            } elseif ($usertype2 == 2) {
                                $title[$usertype2] = '工作提醒|有新的' . $secondPara . '@您';
                            }
                        }
                    }
                }
            }
            if($this->installDing){
                $dingUseridExist = array();
                $userresult = $adb->pquery($dingUserSql, array($workreportid));
                for ($j = 0; $j < $adb->num_rows($userresult); $j++) {
                    $userid2 = $adb->query_result($userresult, $j, 'dingtalk_userid');
                    if (array_search($userid2, $dingUseridExist) === false) {
                        $usertype2 = $adb->query_result($userresult, $j, 'user_type');
                        if ($usertype2 == 5) {
                            $dingUseridExist[$usertype2] =  $userid2;
                            $descriptionFinal[$usertype2] = '发布人：' . $last_name . $n . '发布时间: ' . $createdtime . $n . $descriptionW;
                            $secondPara = $TransforSecondCategory[$type];
                            $modulelabel[$usertype2] = $secondPara;
                            $title[$usertype2] = '【' .getTranstab('CooperativeWork').'】点评提醒|有新的' . $secondPara . '需要您点评';
                        } elseif ($usertype2 == 6) {
                            $dingUseridExist[$usertype2] =  $userid2;
                            $descriptionFinal[$usertype2] = '请于' . $startdate . '之前完成' . $n . '发布人：' . $last_name . $n . '发布时间: ' . $createdtime . $n . $workexperience;
                            $secondLine = '【' .getTranstab('CooperativeWork').'】执行提醒|有新的任务需要您执行';
                            $modulelabel[$usertype2] = $TransforSecondCategory[6];
                            $title[$usertype2] = $secondLine;
                        } elseif ($usertype2 == 1 || $usertype2 == 2) {
                            $dingUseridExist[$usertype2] =  $userid2;
                            if ($entitytype == 'workreport') {
                                $secondPara = $TransforSecondCategory[6];
                                $descriptionFinal[$usertype2] = '发布人：' . $last_name . $n . '发布时间: ' . $createdtime . $n . $descriptionW;
                            } elseif ($entitytype == 'cocmd') {
                                $secondPara = getFixedLabel('TASK');
                                $descriptionFinal [$usertype2] = '发布人：' . $last_name . $n . '发布时间: ' . $createdtime . $n . $workexperience;
                            } else {
                                $secondPara = getFixedLabel('BLOG');
                                $descriptionFinal[$usertype2] = '发布人：' . $last_name . $n . '发布时间: ' . $createdtime . $n . $workexperience;
                            }
                            $modulelabel[$usertype2] = $secondPara;
                            if ($usertype2 == 1) {
                                $title[$usertype2] ='【' .getTranstab('CooperativeWork').'】抄送提醒|有新的' . $secondPara . '抄送给您';

                            } elseif ($usertype2 == 2) {
                                $title[$usertype2] = '工作提醒|有新的' . $secondPara . '@您';
                            }
                        }
                    }
                }
            }

            if($this->installYzj){
                $yzjUseridExist = array();
                $userresult = $adb->pquery($yzjUserSql, array($workreportid));
                for ($j = 0; $j < $adb->num_rows($userresult); $j++) {
                    $userid2 = $adb->query_result($userresult, $j, 'yunzhijia_wbuserid');
                    if (array_search($userid2, $yzjUseridExist) === false) {
                        $usertype2 = $adb->query_result($userresult, $j, 'user_type');
                        if ($usertype2 == 5) {
                            $yzjUseridExist[$usertype2] =  $userid2;
                            $descriptionFinal[$usertype2] = '发布人：' . $last_name . $n . '发布时间: ' . $createdtime . $n . $descriptionW;
                            $secondPara = $TransforSecondCategory[$type];
                            $modulelabel[$usertype2] = $secondPara;
                            $title[$usertype2] = '【' .getTranstab('CooperativeWork').'】点评提醒|有新的' . $secondPara . '需要您点评';
                        } elseif ($usertype2 == 6) {
                            $yzjUseridExist[$usertype2] =  $userid2;
                            $descriptionFinal[$usertype2] = '请于' . $startdate . '之前完成' . $n . '发布人：' . $last_name . $n . '发布时间: ' . $createdtime . $n . $workexperience;
                            $secondLine = '【' .getTranstab('CooperativeWork').'】执行提醒|有新的任务需要您执行';
                            $title[$usertype2] = $secondLine;
                        } elseif ($usertype2 == 1 || $usertype2 == 2) {
                            $yzjUseridExist[$usertype2] =  $userid2;
                            if ($entitytype == 'workreport') {
                                $secondPara = $TransforSecondCategory[$type];
                                $descriptionFinal[$usertype2] = '发布人：' . $last_name . $n . '发布时间: ' . $createdtime . $n . $descriptionW;
                            } elseif ($entitytype == 'cocmd') {
                                $secondPara = getFixedLabel('TASK');
                                $descriptionFinal [$usertype2] = '发布人：' . $last_name . $n . '发布时间: ' . $createdtime . $n . $workexperience;
                            } else {
                                $secondPara = getFixedLabel('BLOG');
                                $descriptionFinal[$usertype2] = '发布人：' . $last_name . $n . '发布时间: ' . $createdtime . $n . $workexperience;
                            }
                            $modulelabel[$usertype2] = $secondPara;
                            if ($usertype2 == 1) {
                                $title[$usertype2] ='【' .getTranstab('CooperativeWork').'】抄送提醒|有新的' . $secondPara . '抄送给您';

                            } elseif ($usertype2 == 2) {
                                $title[$usertype2] = '工作提醒|有新的' . $secondPara . '@您';
                            }
                        }
                    }
                }
            }

            if($this->installWXSelfBuilt) {
                $wxSelfbuiltUseridexist = array();
                $userresult = $adb->pquery($wxSelfbuiltUsersql, array($workreportid));
                for ($j = 0; $j < $adb->num_rows($userresult); $j++) {
                    $remind = '';
                    $userid2 = $adb->query_result($userresult, $j, 'wx_userid');
                    if (array_search($userid2, $wxSelfbuiltUseridexist) === false) {
                        $usertype2 = $adb->query_result($userresult, $j, 'user_type');

                        if ($usertype2 == 5) {
                            $wxSelfbuiltUseridexist[$usertype2] = $userid2;
                            $descriptionFinal[$usertype2] = '发布人：' . $last_name . $n . '发布时间: ' . $createdtime . $n . $descriptionW;
                            $secondPara = $TransforSecondCategory[$type];
                            $modulelabel[$usertype2] = $secondPara;
                            $title[$usertype2] ='【' .getTranstab('CooperativeWork').'】点评提醒|有新的' . $secondPara . '需要您点评';
                            $description_mini[$usertype2][0] = array('key' => '发布人', 'value' => $last_name);
                            $description_mini[$usertype2][1] = array('key' => '发布时间', 'value' => $createdtime);
                            $description_mini[$usertype2][2] = array('key' => '内容', 'value' => $descriptionW);
                        } elseif ($usertype2 == 6) {
                            $wxSelfbuiltUseridexist[$usertype2] = $userid2;
                            $descriptionFinal[$usertype2] = '请于' . $startdate . '之前完成' . $n . '发布人：' . $last_name . $n . '发布时间: ' . $createdtime . $n . $workexperience;
                            $secondLine = '【' .getTranstab('CooperativeWork').'】执行提醒|有新的任务需要您执行';
                            $title[$usertype2] = $secondLine;
                            //edit:can 20211011 48200: （https://61mis.com/WX/kh41300 [^] [^]）（卫诗理灯具）工作汇报发布任务-企业微信PC端口进去-进不去消息详情页，显示空白如图所示，81MISkfbcrm也有这样的问题
                            $modulelabel[$usertype2] = $TransforSecondCategory[$type];;
                            $description_mini[$usertype2][0] = array('key' => '内容一', 'value' => '请于' . $startdate . '之前完成');
                            $description_mini[$usertype2][1] = array('key' => '发布人', 'value' => $last_name);
                            $description_mini[$usertype2][2] = array('key' => '发布时间', 'value' => $createdtime);
                            $description_mini[$usertype2][3] = array('key' => '内容二', 'value' => $workexperience);
                        } elseif ($usertype2 == 1 || $usertype2 == 2) {
                            $wxSelfbuiltUseridexist[$usertype2] = $userid2;
                            if ($entitytype == 'workreport') {
                                $secondPara = $TransforSecondCategory[$type];
                                $descriptionFinal[$usertype2] = '发布人：' . $last_name . $n . '发布时间: ' . $createdtime . $n . $descriptionW;
                                $description_mini[$usertype2][0] = array('key' => '发布人', 'value' => $last_name);
                                $description_mini[$usertype2][1] = array('key' => '发布时间', 'value' => $createdtime);
                                $description_mini[$usertype2][2] = array('key' => '内容', 'value' => $descriptionW);
                            } elseif ($entitytype == 'cocmd') {
                                $secondPara = getFixedLabel('TASK');
                                $descriptionFinal [$usertype2] = '发布人：' . $last_name . $n . '发布时间: ' . $createdtime . $n . $workexperience;
                                $description_mini[$usertype2][0] = array('key' => '发布人', 'value' => $last_name);
                                $description_mini[$usertype2][1] = array('key' => '发布时间', 'value' => $createdtime);
                                $description_mini[$usertype2][2] = array('key' => '内容', 'value' => $workexperience);
                            } else {
                                $secondPara = getFixedLabel('BLOG');
                                $descriptionFinal[$usertype2] = '发布人：' . $last_name . $n . '发布时间: ' . $createdtime . $n . $workexperience;
                                $description_mini[$usertype2][0] = array('key' => '发布人', 'value' => $last_name);
                                $description_mini[$usertype2][1] = array('key' => '发布时间', 'value' => $createdtime);
                                $description_mini[$usertype2][2] = array('key' => '内容', 'value' => $workexperience);
                            }
                            $modulelabel[$usertype2] = $secondPara;
                            if ($usertype2 == 1) {
                                $title[$usertype2] ='【' .getTranstab('CooperativeWork').'】抄送提醒|有新的' . $secondPara . '抄送给您';

                            } elseif ($usertype2 == 2) {
                                $title[$usertype2] = '工作提醒|有新的' . $secondPara . '@您';
                            }
                        }
                    }
                }
            }

            if($this->installZy){
                $zyUseridExist = array();
                $userresult = $adb->pquery($zyUserSql, array($workreportid));
                for ($j = 0; $j < $adb->num_rows($userresult); $j++) {
                    $userid2 = $adb->query_result($userresult, $j, 'zhiyuan_userid');
                    if (array_search($userid2, $zyUseridExist) === false) {
                        $usertype2 = $adb->query_result($userresult, $j, 'user_type');
                        if ($usertype2 == 5) {
                            $zyUseridExist[$usertype2] =  $userid2;
                            $descriptionFinal[$usertype2] = '发布人：' . $last_name . $n . '发布时间: ' . $createdtime . $n . $descriptionW;
                            $secondPara = $TransforSecondCategory[$type];
                            $modulelabel[$usertype2] = $secondPara;
                            $title[$usertype2] = '【' .getTranstab('CooperativeWork').'】点评提醒|有新的' . $secondPara . '需要您点评';
                        } elseif ($usertype2 == 6) {
                            $zyUseridExist[$usertype2] =  $userid2;
                            $descriptionFinal[$usertype2] = '请于' . $startdate . '之前完成' . $n . '发布人：' . $last_name . $n . '发布时间: ' . $createdtime . $n . $workexperience;
                            $secondLine = '【' .getTranstab('CooperativeWork').'】执行提醒|有新的任务需要您执行';
                            $title[$usertype2] = $secondLine;
                        } elseif ($usertype2 == 1 || $usertype2 == 2) {
                            $zyUseridExist[$usertype2] =  $userid2;
                            if ($entitytype == 'workreport') {
                                $secondPara = $TransforSecondCategory[$type];
                                $descriptionFinal[$usertype2] = '发布人：' . $last_name . $n . '发布时间: ' . $createdtime . $n . $descriptionW;
                            } elseif ($entitytype == 'cocmd') {
                                $secondPara = getFixedLabel('TASK');
                                $descriptionFinal [$usertype2] = '发布人：' . $last_name . $n . '发布时间: ' . $createdtime . $n . $workexperience;
                            } else {
                                $secondPara = getFixedLabel('BLOG');
                                $descriptionFinal[$usertype2] = '发布人：' . $last_name . $n . '发布时间: ' . $createdtime . $n . $workexperience;
                            }
                            $modulelabel[$usertype2] = $secondPara;
                            if ($usertype2 == 1) {
                                $title[$usertype2] ='【' .getTranstab('CooperativeWork').'】抄送提醒|有新的' . $secondPara . '抄送给您';

                            } elseif ($usertype2 == 2) {
                                $title[$usertype2] = '工作提醒|有新的' . $secondPara . '@您';
                            }
                        }
                    }
                }
            }

            if($this->installFanwei){
                $fanweiUseridExist = array();
                $userresult = $adb->pquery($fanweiUserSql, array($workreportid));
                for ($j = 0; $j < $adb->num_rows($userresult); $j++) {
                    $userid2 = $adb->query_result($userresult, $j, 'fanwei_userid');
                    if (array_search($userid2, $fanweiUseridExist) === false) {
                        $usertype2 = $adb->query_result($userresult, $j, 'user_type');
                        if ($usertype2 == 5) {
                            $fanweiUseridExist[$usertype2] =  $userid2;
                            $descriptionFinal[$usertype2] = '发布人：' . $last_name . $n . '发布时间: ' . $createdtime . $n . $descriptionW;
                            $secondPara = $TransforSecondCategory[$type];
                            $modulelabel[$usertype2] = $secondPara;
                            $title[$usertype2] = '【' .getTranstab('CooperativeWork').'】点评提醒|有新的' . $secondPara . '需要您点评';
                        } elseif ($usertype2 == 6) {
                            $fanweiUseridExist[$usertype2] =  $userid2;
                            $descriptionFinal[$usertype2] = '请于' . $startdate . '之前完成' . $n . '发布人：' . $last_name . $n . '发布时间: ' . $createdtime . $n . $workexperience;
                            $secondLine = '【' .getTranstab('CooperativeWork').'】执行提醒|有新的任务需要您执行';
                            $title[$usertype2] = $secondLine;
                        } elseif ($usertype2 == 1 || $usertype2 == 2) {
                            $fanweiUseridExist[$usertype2] =  $userid2;
                            if ($entitytype == 'workreport') {
                                $secondPara = $TransforSecondCategory[$type];
                                $descriptionFinal[$usertype2] = '发布人：' . $last_name . $n . '发布时间: ' . $createdtime . $n . $descriptionW;
                            } elseif ($entitytype == 'cocmd') {
                                $secondPara = getFixedLabel('TASK');
                                $descriptionFinal [$usertype2] = '发布人：' . $last_name . $n . '发布时间: ' . $createdtime . $n . $workexperience;
                            } else {
                                $secondPara = getFixedLabel('BLOG');
                                $descriptionFinal[$usertype2] = '发布人：' . $last_name . $n . '发布时间: ' . $createdtime . $n . $workexperience;
                            }
                            $modulelabel[$usertype2] = $secondPara;
                            if ($usertype2 == 1) {
                                $title[$usertype2] ='【' .getTranstab('CooperativeWork').'】抄送提醒|有新的' . $secondPara . '抄送给您';

                            } elseif ($usertype2 == 2) {
                                $title[$usertype2] = '工作提醒|有新的' . $secondPara . '@您';
                            }
                        }
                    }
                }
            }
        }
        $r_multi_content = array();
        foreach ($useridexist as $usertype2 => $userids) {
            $tmpuserids = trim($userids, '|');
            $wxuserids = explode('|', $tmpuserids);
            $tmparray = array();
            $tmparray['message'] = $descriptionFinal[$usertype2];
            $tmparray['reltab'] = 'CooperativeWork';
            $tmparray['related_to'] = $workreportid;
            $tmparray['date_time'] = date("Y-m-d H:i:s");
            $tmparray['modulelabel'] = $this->filterstring($modulelabel[$usertype2]);
            $tmparray['entitytype'] = $entitytype;
            $tmparray['title'] = $title[$usertype2];
            $tmparray['message_mini'] = $description_mini[$usertype2];
            if(!empty($wxuserids[0])){
                $tmparray['userid'] = $wxuserids;
            }
            $r_multi_content[] = $tmparray;
        }
        if (is_array($useridexist) && sizeof($useridexist) > 0 && $this->installWX) {
            require_once(globalStatic::$root_directory . '/WeiXinApp/modules/Reminds/cls_remindsWX.php');

            crm_load_class_file('cls_StaticCommonFun', 'WeiXinApp/WeiXin_common');

            crm_load_class_file('StaticConst', 'WeiXinApp/WeiXin_common');

            $errorno = $this->send_multi_reminds($r_multi_content);

            if (!$errorno) {
                $sql = 'update ld_workreport_remind set push_to_weixin=3,push_time=now() 
                                        where relatedto=?';
                $adb->pquery($sql, array($workreportid));
            }
        }
        $r_multi_content = array();
        foreach ($dingUseridExist as $usertype2 => $userids) {
            $dingTmpUserids = trim($userids, '|');
            $dingUserids = explode('|', $dingTmpUserids);
            $tmparray = array();
            $tmparray['message'] =  $descriptionFinal[$usertype2]; ;
            $tmparray['reltab'] = 'CooperativeWork';
            $tmparray['related_to'] = $workreportid;
            $tmparray['date_time'] = date("Y-m-d H:i:s");
            $tmparray['modulelabel'] = $this->filterstring($modulelabel[$usertype2]);
            $tmparray['entitytype'] = $entitytype;
            $tmparray['title'] = $title[$usertype2];
            if(!empty($dingUserids[0])){
                $tmparray['userid_ding'] = $dingUserids;
            }
            $r_multi_content[] = $tmparray;
        }
        //editor:gyq_165 reason:钉钉消息提醒类型，日志新增提醒   2019/12/30 15:42
        if (is_array($dingUseridExist) && sizeof($dingUseridExist) > 0 && $this->installDing) {
            $errorno = $this->sendMessage([$workreportid],$r_multi_content);
            if (!$errorno) {
                $sql = 'update ld_workreport_remind set push_to_ding=3,push_time_ding=now() 
                                            where relatedto=?';
                $adb->pquery($sql, array($workreportid));
            }
        }
        //云之家提醒
        foreach ($yzjUseridExist as $usertype2 => $userids) {
            $yzjTmpUserids = trim($userids, '|');
            $yzjUserids = explode('|', $yzjTmpUserids);
            $r_multi_content = array();
            foreach($yzjUserids as $yunzhijia_wxuserid){
                $tmparray = array();
                $tmparray['message'] =  $descriptionFinal[$usertype2]; ;
                $tmparray['reltab'] = 'CooperativeWork';
                $tmparray['related_to'] = $workreportid;
                $tmparray['date_time'] = date("Y-m-d H:i:s");
                $tmparray['modulelabel'] = $this->filterstring($modulelabel[$usertype2]);
                $tmparray['entitytype'] = $entitytype;
                $tmparray['title'] = $title[$usertype2];
                $tmparray['userid_openid'] = $yunzhijia_wxuserid;
                $r_multi_content[] = $tmparray;
            }
            if (is_array($r_multi_content) && sizeof($r_multi_content) > 0 && $this->installYzj) {
                $parenttmpremindid[] = $workreportid;;
                $yzj_remind = new cls_reminds_yzj();
                $errorno = $yzj_remind->sendAllTypeRemindsImmediately($parenttmpremindid, $r_multi_content,'workreport_remind');
                if (!$errorno) {
                    $sql = 'update ld_workreport_remind set push_to_yzj=3,push_time_yzj=now() 
												where relatedto=?';
                    $adb->pquery($sql, array($workreportid));
                }
            }

        }

        $r_multi_content = array();
        foreach ($wxSelfbuiltUseridexist as $usertype2 => $userids) {
            $wxSelfbuilt_tmpuserids = trim($userids, '|');
            $wxSelfbuilt_wxuserids = explode('|', $wxSelfbuilt_tmpuserids);
            $tmparray = array();
            $tmparray['message'] = $descriptionFinal[$usertype2];
            $tmparray['reltab'] = 'CooperativeWork';
            $tmparray['related_to'] = $workreportid;
            $tmparray['date_time'] = date("Y-m-d H:i:s");
            $tmparray['modulelabel'] = $this->filterstring($modulelabel[$usertype2]);
            $tmparray['entitytype'] = $entitytype;
            $tmparray['title'] = $title[$usertype2];
            $tmparray['message_mini'] = $description_mini[$usertype2];
            if(!empty($wxSelfbuilt_wxuserids[0])){
                $tmparray['userid'] = $wxSelfbuilt_wxuserids;
            }
            $r_multi_content[] = $tmparray;
        }
        if (is_array($wxSelfbuiltUseridexist) && sizeof($wxSelfbuiltUseridexist) > 0 && $this->installWXSelfBuilt) {
            $output = $this->send_multi_reminds_wxselfbuilt($r_multi_content);

//            if($output['errcode'] === 0){
                $sql = 'update ld_workreport_remind set push_to_wxselfbuilt=3,push_time_wxselfbuilt=now() 
                                        where relatedto=?';
                $adb->pquery($sql, array($workreportid));
//            }
        }

        //致远提醒
        foreach ($zyUseridExist as $usertype2 => $userids) {
            $zyTmpUserids = trim($userids, '|');
            $zyUserids = explode('|', $zyTmpUserids);
            $r_multi_content = array();
            foreach($zyUserids as $zhiyuan_userid){
                $tmparray = array();
                $tmparray['message'] =  $descriptionFinal[$usertype2]; ;
                $tmparray['reltab'] = 'CooperativeWork';
                $tmparray['related_to'] = $workreportid;
                $tmparray['date_time'] = date("Y-m-d H:i:s");
                $tmparray['modulelabel'] = $this->filterstring($modulelabel[$usertype2]);
                $tmparray['entitytype'] = $entitytype;
                $tmparray['title'] = $title[$usertype2];
                //$tmparray['userid_zhiyuan'] = $zhiyuan_userid;
                $tmparray['received_id'] = $zhiyuan_userid;//实际值时ld_user表id，为了传值统一
                $tmparray['remindsid'] = $workreportid.'_'.uniqid();
                $r_multi_content[] = $tmparray;
            }
            if (is_array($r_multi_content) && sizeof($r_multi_content) > 0 && $this->installZy) {
                $zy_remind = new cls_reminds_zy();
                $errorno = $zy_remind->sendAllTypeRemindsImmediately([$workreportid], $r_multi_content,'workreport_remind');
                if (!$errorno) {
                    $sql = 'update ld_workreport_remind set push_to_zy=3,push_time_zy=now() 
												where relatedto=?';
                    $adb->pquery($sql, array($workreportid));
                }
            }

        }

        foreach ($fanweiUseridExist as $usertype2 => $userids) {
            $fanweiTmpUserids = trim($userids, '|');
            $fanweiUserids = explode('|', $fanweiTmpUserids);
            $r_multi_content = array();
            foreach($fanweiUserids as $fanwei_userid){
                $tmparray = array();
                $tmparray['message'] =  $descriptionFinal[$usertype2]; ;
                $tmparray['reltab'] = 'CooperativeWork';
                $tmparray['related_to'] = $workreportid;
                $tmparray['date_time'] = date("Y-m-d H:i:s");
                $tmparray['modulelabel'] = $this->filterstring($modulelabel[$usertype2]);
                $tmparray['entitytype'] = $entitytype;
                $tmparray['title'] = $title[$usertype2];
                $tmparray['userid_fanwei'] = $fanwei_userid;
                $r_multi_content[] = $tmparray;
            }
            if (is_array($r_multi_content) && sizeof($r_multi_content) > 0 && $this->installFanwei) {
                $fanwei_remind = new cls_reminds_fanwei();
                $errorno = $fanwei_remind->sendAllTypeRemindsImmediately([$workreportid], $r_multi_content,'workreport_remind');
                if (!$errorno) {
                    $sql = 'update ld_workreport_remind set push_to_fw=3,push_time_fw=now() 
												where relatedto=?';
                    $adb->pquery($sql, array($workreportid));
                }
            }

        }

    }

    //工作协同回复，赞等提醒
    public function workreport_reminds_half($workreportid, $relatedto, $type)
    {
        global $adb;
        //发提醒前先判断可以发哪些类型的提醒
        if (!$this->installDing && !$this->installWX && !$this->installYzj && !$this->installZy && !$this->installWXSelfBuilt && !$this->installFanwei) {
            return false;
        }
        $n = $this->newline;
        $TransforSecondCategory = array(1 => getFixedLabel('JOURNAL'), 2 => getFixedLabel('WEEKPLAN'), 3 => getFixedLabel('MONTHPLAN'));
        $HomeTransfor = array('1' => 'dayreport', '2' => 'weekreport', '3' => 'monthreport');
        $workobj = $this->workmodel;

        $worksql = 'SELECT
                  ld_workreport.entitytype,
                  ld_workreport.workexperience,
                  ld_workreport.type,
                  A.last_name,A.wx_userid,
                  ld_workreport.createdtime,
                  ld_workreport.worksummary,
                  ld_workreport.workplan,
                  ld_workreport.enddate,
                  ld_workreport.startdate,
                  wxuser.wx_userid,
                  ld_workreport_remind.content,
                  wxuser.dingtalk_userid,
				  wxuser.yunzhijia_openid,
				  wxuser.zhiyuan_userid,
				  wxuser.fanwei_userid,
                  ld_workreport_remind.remindtype
                FROM ld_workreport
              
                  inner JOIN ld_users A on A.id = ld_workreport.smcreatorid
                 
                ';
        if ($type == 'praise') {
            $worksql .= " inner join ld_praise on ld_praise.workreportid=ld_workreport.workreportid 
                 inner join ld_workreport_remind on ld_workreport_remind.relatedto=ld_praise.praiseid and relatedtable='praise' ";

        } else if ($type == 'reply') {
            $worksql .= " inner join ld_workreply on ld_workreply.workreportid=ld_workreport.workreportid 
                 inner join ld_workreport_remind on ld_workreport_remind.relatedto=ld_workreply.workreplyid  and relatedtable='workreply' ";
        }
        $worksql .= "  inner join ld_users as wxuser on wxuser.id=ld_workreport_remind.userid ";

        $where = ' WHERE length(ld_workreport.entitytype) > 0 AND ld_workreport.workreportid=?
                
                    AND ld_workreport_remind.push_to_weixin = 2 
                    AND ld_workreport_remind.relatedto > 0 
                    AND ld_workreport_remind.remindtype <> 1 
                    AND ld_workreport_remind.remindtype <> 3
                    AND wxuser.push_wx_reminds=1 ';
        $user_purpose = array();
        $worksql .= $where;

        $userresult = $adb->pquery($worksql, array($workreportid));
        $number = $adb->num_rows($userresult);

        crm_load_class_file('WorkReportModel', 'modules/Home');
        $workobj = new WorkReportModel();

        for ($j = 0; $j < $number; $j++) {
            $id = $adb->query_result($userresult, $j, 'id');

            $userid = $adb->query_result($userresult, $j, 'userid');

            $operationtype = $adb->query_result($userresult, $j, 'operationtype');
            $content = $adb->query_result($userresult, $j, 'content');
            $wx_userid = $adb->query_result($userresult, $j, 'wx_userid');
            $dingtalk_userid = $adb->query_result($userresult, $j, 'dingtalk_userid');
            $yunzhijia_openid = $adb->query_result($userresult, $j, 'yunzhijia_openid');
            $zhiyuan_userid = $adb->query_result($userresult, $j, 'zhiyuan_userid');
            $fanwei_userid= $adb->query_result($userresult, $j, 'fanwei_userid');
            $remindtype = $adb->query_result($userresult, $j, 'remindtype');
            //未绑定企业微信、钉钉或云之家时，不生成对应提醒
            if(!empty($wx_userid)){
                $useridexist[$remindtype][] = $wx_userid;
            }
            if(!empty($dingtalk_userid)){
                $useridexist[$remindtype . $this->dingApiName][] = $dingtalk_userid;
            }
            if(!empty($yunzhijia_openid)){
                $useridexist[$remindtype . 'yunzhijia'][] = $yunzhijia_openid;	//云之家
            }
            if(!empty($zhiyuan_userid)){
                $useridexist[$remindtype . 'zhiyuan'][] = $zhiyuan_userid;
            }
            if(!empty($fanwei_userid)){
                $useridexist[$remindtype . 'fanwei'][] = $fanwei_userid;
            }
            $entitytype = $adb->query_result($userresult, 0, 'entitytype');
            $workexperience = $adb->query_result($userresult, 0, 'workexperience');
            $worksummary = $adb->query_result($userresult, 0, 'worksummary');
            $workplan = $adb->query_result($userresult, 0, 'workplan');
            $type = $adb->query_result($userresult, 0, 'type');
            $last_name = $adb->query_result($userresult, 0, 'last_name');
            $userobj=new Users();
            $userobj->last_name=$last_name;
            $userobj->wx_userid=$wx_userid;
            $last_name=getWxMobileRemindInfo($userobj);

            $enddate = $adb->query_result($userresult, 0, 'enddate');
            $startdate = $adb->query_result($userresult, 0, 'startdate');
            $createdtime = $adb->query_result($userresult, $j, 'createdtime');


            if ($entitytype == 'workreport') {
                $workReportTemplate = $workobj->getallFieldsForTable();
                $workTemplate = $workReportTemplate['workreport'][$HomeTransfor[$type]]['fieldinfo'];
                $descriptionW = '';
                foreach ($workTemplate as $key => $val) {
                    if (!empty($$val['name'])) {
                        if (strpos($val['label'], '请填写') === 0) {
                            $label = substr($val['label'], 9);
                        } else {
                            $label = $val['label'];
                        }
                        $descriptionW .= $label . $n . $$val['name'] . $n;
                    }
                }//gyqTT

                if ($remindtype == 1) {
                    $description[$remindtype] = '发布人：' . $last_name . $n . '发布时间: ' . $createdtime . $n . $descriptionW;
                    $secondPara = $TransforSecondCategory[$type];
                    $secondLineM = '有新的' . $secondPara . '需要您点评';
                    $description_mini[$remindtype][0] = array('key' => '发布人', 'value' => $last_name);
                    $description_mini[$remindtype][1] = array('key' => '发布时间', 'value' => $createdtime);
                    $description_mini[$remindtype][2] = array('key' => '内容', 'value' => $descriptionW);
                } else if($remindtype == 10) {
					//点评抄送
                    $description[$remindtype] = $content;
                    $description_mini[$remindtype][0] = array('key' => '内容一', 'value' => $content);
                    $description_mini[$remindtype][1] = array('key' => '操作时间', 'value' => $createdtime);
                }else {
                    $description[$remindtype] = $content . $n . $descriptionW;
                    $description_mini[$remindtype][0] = array('key' => '内容一', 'value' => $content);
                    $description_mini[$remindtype][1] = array('key' => '操作时间', 'value' => $createdtime);
                    $description_mini[$remindtype][2] = array('key' => '内容二', 'value' => $descriptionW);
                }
            } elseif ($entitytype == 'cocmd') {
                if ($remindtype == 1) {
                    $description[$remindtype] = '请于' . $startdate . '之前完成' . $n . '发布人：' . $last_name . '|' . '发布时间:' . $createdtime . $n;
                    $secondLineM = '有新的任务需要您执行';
                    $description_mini[$remindtype][0] = array('key' => '内容一', 'value' => '请于' . $startdate . '之前完成');
                    $description_mini[$remindtype][1] = array('key' => '发布人', 'value' => $last_name);
                    $description_mini[$remindtype][2] = array('key' => '发布时间', 'value' => $createdtime);
                } else {
                    $description[$remindtype] = $content . $n;
                    $description_mini[$remindtype][0] = array('key' => '内容一', 'value' => $content);
                    $description_mini[$remindtype][1] = array('key' => '操作时间', 'value' => $createdtime);
                }
                $description[$remindtype] = $description[$remindtype] . $workexperience;
                $description_mini[$remindtype][] = array('key' => '内容二', 'value' => $workexperience);
            } else {
                $description[$remindtype] = $content . $n . $workexperience;
                $description_mini[$remindtype][0] = array('key' => '内容一', 'value' => $content);
                $description_mini[$remindtype][1] = array('key' => '操作时间', 'value' => $createdtime);
                $description_mini[$remindtype][2] = array('key' => '内容二', 'value' => $workexperience);
            }
            if ($remindtype == 3 || $remindtype == 4) {
                $secondLineM = '@我';
            } elseif ($remindtype == 6) {
                $secondLineM = '点赞';
            } elseif ($remindtype == 2) {
                $secondLineM = '回复';
            } elseif ($remindtype == 10) {
                $secondLineM = '有新的点评内容抄送您';
            } elseif ($remindtype == 5) {
                if ($operationtype == 1) {
                    $secondLineM = '完成任务';
                } else {
                    $secondLineM = '您的日志被点评';
                }
            }
            $title[$remindtype] = '【' .getTranstab('CooperativeWork').'】提醒|' . $secondLineM;
            $modulelabel[$remindtype] = $secondLineM;
        }

        $r_multi_content = array();
        foreach ($useridexist as $usertype2 => $userids) {
            $tmparray = array();
            $tmparray['userid'] = $useridexist[$usertype2];
            $tmparray['userid_ding'] = $useridexist[$usertype2 . $this->dingApiName];
            $tmparray['userid_openid'] = $useridexist[$usertype2 . 'yunzhijia'];
            $tmparray['userid_zhiyuan'] = $useridexist[$usertype2 . 'zhiyuan'];
            $tmparray['userid_fanwei'] = $useridexist[$usertype2 . 'fanwei'];
            $tmparray['message'] = $description[$usertype2];
            $tmparray['reltab'] = 'CooperativeWork';
            $tmparray['related_to'] = $workreportid;
            $tmparray['date_time'] = date("Y-m-d H:i:s");
            $tmparray['modulelabel'] = $this->filterstring($modulelabel[$usertype2]);
            $tmparray['entitytype'] = $entitytype;
            $tmparray['title'] = $title[$usertype2];
            //editor:gyq_110 reason:企业微信小程序提醒  2019/5/13 10:46
            $tmparray['message_mini'] = $description_mini[$usertype2];
            $r_multi_content[] = $tmparray;

        }

        if (is_array($r_multi_content[0]) && sizeof($r_multi_content[0]) > 1) {
            //editor:gyq_165 reason:钉钉消息提醒类型，工作协同回复，赞等提醒   2019/12/30 14:17
            if ($this->installWX) {
                require_once(globalStatic::$root_directory . '/WeiXinApp/modules/Reminds/cls_remindsWX.php');
                crm_load_class_file('cls_StaticCommonFun', 'WeiXinApp/WeiXin_common');
                crm_load_class_file('StaticConst', 'WeiXinApp/WeiXin_common');


                $errorno = $this->send_multi_reminds($r_multi_content);
                if (!$errorno) {
                    $sql = 'update ld_workreport_remind set push_to_weixin=3,push_time=now() 
                                            where relatedto=?';
                    $adb->pquery($sql, array($relatedto));
                }

            }
            if ($this->installDing) {
                $errorno = $this->sendMessage([$workreportid],$r_multi_content);
                if (!$errorno) {
                    $sql = 'update ld_workreport_remind set push_to_ding=3,push_time_ding=now() 
                                            where relatedto=?';
                    $adb->pquery($sql, array($relatedto));
                }
            }
            if ($this->installYzj) {
                $parenttmpremindid[] = $workreportid;
//                $errorno = $this->sendMessage($parenttmpremindid,$r_multi_content,'workreport_remind');
                $yzj_remind = new cls_reminds_yzj();
                $errorno = $yzj_remind->sendAllTypeRemindsImmediately([$workreportid], $r_multi_content,'workreport_remind');
                if (!$errorno) {
                    $sql = 'update ld_workreport_remind set push_to_yzj=3,push_time_yzj=now() 
                                            where relatedto=?';
                    $adb->pquery($sql, array($relatedto));
                }
            }

            if ($this->installWXSelfBuilt) {
                $output = $this->send_multi_reminds_wxselfbuilt($r_multi_content);

//                if($output['errcode'] === 0){
                    $sql = 'update ld_workreport_remind set push_to_wxselfbuilt=3,push_time_wxselfbuilt=now() 
                                        where relatedto=?';
                    $adb->pquery($sql, array($workreportid));
//                }

            }

            if ($this->installZy) {
                $zy_remind = new cls_reminds_zy();
                $errorno = $zy_remind->sendAllTypeRemindsImmediately([$workreportid], $r_multi_content,'workreport_remind');
                if (!$errorno) {
                    $sql = 'update ld_workreport_remind set push_to_zy=3,push_time_zy=now() 
                                            where relatedto=?';
                    $adb->pquery($sql, array($relatedto));
                }
            }
            if ($this->installFanwei) {
                $fanwei_remind = new cls_reminds_fanwei();
                $errorno = $fanwei_remind->sendAllTypeRemindsImmediately([$workreportid],$r_multi_content,'workreport_remind');
                if (!$errorno) {
                    $sql = 'update ld_workreport_remind set push_to_fw=3,push_time_fw=now() 
                                            where relatedto=?';
                    $adb->pquery($sql, array($relatedto));
                }
            }

        }
    }
    
    
    
    
    
    
     //发送app提醒
    public function sendNativeMessage(&$r_multi_content)
    {
        global $adb;
         $this->newline="\n";
        global $weixin_user;

        $listIds = array();
        $weixinNewLine='';

        foreach ($r_multi_content as $key => &$news_content) {

            $r_remindtype = $news_content['remindtype'];
          //  $massageContent =  str_replace($weixinNewLine, $this->newline,  $news_content['content']);
            $massageContent=$news_content['content'];
            $r_reltab = $news_content['reltab'];
            $r_related_to = $news_content['related_to'];
            $r_date_time = $news_content['date_time'];
           
            $location = '';
            if ($r_reltab == 'CooperativeWork') {
                $title = $news_content['title'];
                if(empty($title)){
                    $title = getTranstab('CooperativeWork');
                }
                $entitytype = $news_content['entitytype'];
                $news_title = $title;
                $modulelabel = $news_content['modulelabel'];

                $location = 'ldcrm/index.html#!/work_detail/' . $r_related_to . '/' . $entitytype . '/' . $this->filterstring($modulelabel);
            } elseif ($r_reltab == 'Users') {
                //指向成员详情界面的提醒，由于企业微信没做成员详情模块，现将关联模块是用户的提醒，不赋值跳转链接，禁止消息穿透
                $news_title = '消息提醒';
                $listtype = 'list';
                $r_related_to = '';
            } else {
                if ($r_remindtype == 'massallocate' || $r_remindtype == 'massshare') {
                    $news_title = '消息提醒';
                    $modulelabel = getTranstab($r_reltab);
                    $modulelabel='aa';
                    $location = 'ldcrm/index.html#!/listview/' . $r_reltab . '/' . $this->filterstring($modulelabel) . '/-1/mass_remind/' . $r_related_to;
                } elseif ($r_remindtype == 'Approve'|| $r_remindtype == 'ExpeditingApprove') {
                    $listtype = 'approvelist';
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
                    //合同交付提醒、服务合同产品到期提醒、收款计划到期提醒、付款计划到期提醒
                    $news_title = getFixedLabel($r_remindtype.'Remind');//【合同订单】交付提醒
                }elseif($r_remindtype == 'MODULECOMMENTRemind'){//评论提醒
                    $news_title = sprintf(getFixedLabel($r_remindtype),getTranstab($r_reltab));//【模块名称】评论提醒
                }elseif($r_remindtype == 'ModuleCreateRemind'){//新增提醒
                    $news_title = sprintf(getFixedLabel($r_remindtype),getTranstab($r_reltab));//【模块名称】新增提醒
                }
                elseif(in_array($r_remindtype,array('AccountsRECYCLEREMIND','LeadsRECYCLEREMIND','AccountsHEDGINGREMIND','AccountsBEFOREREMIND','LeadsBEFOREREMIND'))){
                    //remindstype直接转为翻译：公海回收、报备提醒
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
                $related_to_str = '';//提醒增加相关对象行
                if ($r_related_to && $r_remindtype != 'massallocate' && $r_remindtype != 'massshare'&& !in_array($r_remindtype,array('AccountsRECYCLEREMIND','LeadsRECYCLEREMIND','AccountsBEFOREREMIND','LeadsBEFOREREMIND'))){
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
                    $massageContent .= "\n" .$related_to_lable.'：'.$related_to_name;
                }



            }
            if($news_title=='')
            {
                $news_title='消息提醒';
            }

            //$describ = str_replace('&#039;', '\'', htmlspecialchars_decode(html_entity_decode($massageContent)));
            $newsArr = array();//消息体
            $describ = strip_tags(str_replace('"', '\"', $massageContent), "<br>");
            $describ = str_replace('&lt;br&gt;', $this->newline, $describ);
            $describ .= $this->newline . '操作时间：' . $r_date_time;
            if (!empty($r_related_to) && empty($location)) {
                $modulelabel ="aa";// getTranstab($r_reltab);
                $location = 'ldcrm/index.html#!/detailview/' . $r_reltab . '/' . $r_related_to . '/' . $this->filterstring($modulelabel) . '/' . $listtype . '/yes/-1';
            } elseif (empty($r_related_to)) {
                //CRM端没有指向的消息提醒或企业微信端还没做跳转的提醒，给它跳转到应用首页  2019/5/29 17:44 0037105
                $location = 'ldcrm/index.html#!/';
            }
             
            
           // $messageUrl = $this->eventModel->_login_url . '/WeiXinApp/dingtalk/websaas/' . $location . '?corpid=' . $this->eventModel->_corpid . '&corpurl=' . $this->eventModel->_login_url . '/';
            //editor:gyq_20200107
            //0039099: （kfbcrm）钉钉PC端登录，点击提醒消息，使用新的浏览器打开的详情。预期结果：应该使用钉钉内部浏览器打开详情
            //$newsArr['link']['picUrl'] = $this->getModuleImg($r_reltab);
            $news_content['url'] = $location;
            $news_content['title'] = $news_title;
            $news_content['content']=$massageContent;
          
            
        }
        // dump($r_multi_content);
    }


    //钉钉开启消息通知且已绑定dingtalk_userid，需要更新历史绑定成员的dingtalk_unionid
    public function updateDingTalkUnionid(){
        global $adb;
        $sql = "select GROUP_CONCAT(dingtalk_userid) from ld_users where ifnull(dingtalk_userid,'') <> ''  AND ifnull(dingtalk_unionid,'') = '' AND status='Active' ";
        $result = $adb->pquery($sql, array());
        if($adb->num_rows($result) > 0){
            $dingtalk_userids = $adb->query_result($result,0,0);
            $dingtalk_userid_arr=[];
            if(!empty($dingtalk_userids))
                $dingtalk_userid_arr = explode(',',$dingtalk_userids);

//            require_once globalStatic::$root_directory . 'WeiXinApp/dingtalk/model/event_model.php';
//            $eventModel = new event_model();
            foreach ($dingtalk_userid_arr as $dingtalk_userid) {
                $tmp_userinfo = $this->eventModel->get_userinfo($dingtalk_userid);//接口不支持批量获取
                if (!empty($tmp_userinfo)) {
                    //duan 20240715 BUG20240713-02 如果钉钉用户已注销，或不在应用授权范围内，则清空dingtalkuserid
					if($tmp_userinfo['active'] == 'yes'){
						$unionid =$tmp_userinfo['unionid'];
						$adb->pquery('UPDATE ld_users set dingtalk_unionid=? WHERE dingtalk_userid=?', array($unionid,$dingtalk_userid));
					}else if($tmp_userinfo['active'] == 'no'){
						$adb->pquery('UPDATE ld_users set dingtalk_userid="" WHERE dingtalk_userid=?', array($dingtalk_userid));
					}
                }
            }
        }

    }
    public function UpdateDingtalkMessageStatus($r_weidu_remindsid,$actiontype=true){
        //变更待办消息的处理状态
        if(!empty($r_weidu_remindsid)){
            global $adb;
//            $weidu_remindsid = explode(',',$r_weidu_remindsid);

            $sql = "select tmp.*,ld_approvelog.isfinished from ld_reminds_agenda AS tmp LEFT JOIN ld_reminds ON tmp.remindsid = ld_reminds.remindsid 
             LEFT JOIN ld_approvelog ON tmp.approvelogid = ld_approvelog.id
             where tmp.remindsid in(" . $r_weidu_remindsid. ") and  ld_reminds.push_to_ding = 3";
            $result = $adb->pquery($sql, array());
            $result_arr = $adb->query_result_all($result);

            $token = $this->getTokenCache('refresh');
            foreach($result_arr as $tmp_arr){
                if ($tmp_arr['isfinished'] == 'no') {
                    continue;
                }
                $agendtdada_arr = Zend_Json::decode(html_entity_decode($tmp_arr['dingtalk_agendadata']));
                $taskid = $agendtdada_arr['id'];
                $creatorId = $agendtdada_arr['creatorId'];

                $donedata_arr['done'] = $actiontype;
//                $donedata_arr['executorIds'] = $agendtdada_arr['executorIds'];//不传也可以，默认全部人员  执行者的unionId列表（俗称接收人）

                $url = "https://api.dingtalk.com/v1.0/todo/users/".$creatorId."/tasks/".$taskid;//更新钉钉待办任务
                $body = json_encode($donedata_arr);
                $headers = [
                    'x-acs-dingtalk-access-token:' . $token,
                    'Content-Type: application/json;charset=utf-8;'
                ];
                $response = $this->_Curl($url,$body,'PUT',$headers);
                $response = json_decode($response);
                if($response->code == 'InvalidAuthentication'){
                    $token = $this->getTokenCache('refresh');
                    $headers = [
                        'x-acs-dingtalk-access-token:' . $token,
                        'Content-Type: application/json;charset=utf-8;'
                    ];
                    $response = $this->_Curl($url,$body,'PUT',$headers);
                    $response = json_decode($response);
                }

                if ($response->result != true) {//id 就是接口返回
                    file_put_contents(globalStatic::$root_directory . 'dataCache/weixin/ding_MessageSend_errorlog.txt', date('Y-m-d H:i:s').': 已办请求数据：'.$url . "\r\n", FILE_APPEND);
                    file_put_contents(globalStatic::$root_directory . 'dataCache/weixin/ding_MessageSend_errorlog.txt', date('Y-m-d H:i:s').': 已办响应数据：'.json_encode($response,JSON_UNESCAPED_UNICODE) . "\r\n", FILE_APPEND);
                }



                $sql = 'update ld_reminds set push_to_ding=? where remindsid = ?';
                $adb->pquery($sql, array(4,$agendtdada_arr['sourceId']));
            }

        }
    }


    public function _Curl($url,$body,$method='POST',$headers=array('content-type: application/json;charset=utf-8;')){
        $oCurl = curl_init();
        if(substr($url, 0, 5) == 'https') {
            curl_setopt($oCurl, CURLOPT_SSL_VERIFYPEER, false);    //SSL 报错时使用
            curl_setopt($oCurl, CURLOPT_SSL_VERIFYHOST, false);    //SSL 报错时使用
        }
        curl_setopt($oCurl, CURLOPT_URL, $url);
//        curl_setopt($oCurl, CURLOPT_POST, true);
        curl_setopt($oCurl, CURLOPT_CUSTOMREQUEST, !empty($method)?$method:'POST'); // 指定请求方法为 PUT POST 等
        curl_setopt($oCurl, CURLOPT_POSTFIELDS, $body);
        curl_setopt($oCurl, CURLOPT_RETURNTRANSFER, 1 );
        curl_setopt($oCurl, CURLOPT_HTTPHEADER,$headers);
        curl_setopt($oCurl, CURLOPT_CONNECTTIMEOUT, 100);
        curl_setopt($oCurl, CURLOPT_TIMEOUT, 100);
        $sContent = curl_exec($oCurl);
        curl_close($oCurl);
        return $sContent;
    }


}