<?php

/**
 * Created by PhpStorm.
 * User: gyq
 * Date: 2016/11/1 0001
 * Time: 上午 11:20
 */
class cls_remindsWX
{
    public $newsport;
    public $workmodel;
    protected $successids_workreport; //发送成功的id数组,工作协同提醒
    protected $successids_reminds; //发送成功的id数组，消息提醒
    protected $limitnum;
    //0034510: 企业微信>消息通知：当企业微信的通知同步到个人微信时内容中显示有乱码。
    //此处必须是<br>,若是<br/>则企业微信提醒内容换行正常，个人微信换行异常原样输出
    protected $newline = '<br>';
    protected $crm_suite_name = '';
    protected $work_remind =array();//gyq_53


    //提醒触发，判断是否开启提醒和时间间隔  gyq_23 date:20170207
    public function time_interval()
    {
        global $adb, $current_user;
        $sql = 'SELECT time,time_interval,switch,limitnum FROM ld_wx_config WHERE name=\'remind_time\' LIMIT 1';
        $result = $adb->pquery($sql, array());
        $nums = $adb->num_rows($result);
        if ($nums > 0) {
            $time = $adb->query_result($result, 0, 'time');
            $time_interval = $adb->query_result($result, 0, 'time_interval');
            $switch = $adb->query_result($result, 0, 'switch');
            $this->limitnum = $limitnum = $adb->query_result($result, 0, 'limitnum');
            $current_time = time();
            if ($switch == 'open'&& $current_time >= ($time_interval + $time)) {//&& $current_time >= ($time_interval + $time)
                //gyq_41 定时更新时间
                $updateSql = 'UPDATE ld_wx_config SET time=?,datetime=NOW() WHERE name=\'remind_time\'';
                $result = $adb->pquery($updateSql, array($current_time));
                $info = $this->letsbegin()->interval();
                return $info;
            } else {
                return '';
            }
        }
    }
    //初始化接口对象
    public function letsbegin()
    {
        crm_load_class_file("cls_WeixinPort", 'WeiXinApp/WeiXin_common');
        crm_load_class_file("StaticConst", 'WeiXinApp/WeiXin_common');
        crm_load_class_file("config", 'WeiXinApp');
        $this->newsport = new cls_WeixinPort();//gyq_31
        //editor:gyq_110 reason:企业微信小程序提醒  2019/5/14 13:09 
        $this->newsport->init_port_info();
        //$this->newsport->getAgentId();//gyqCom0306  gyq_33
        //$this->newsport->getAgentid_AccessTokenFromServer('send_news');
        return $this;
    }
    /*

    工作汇报中立即发送没有发送成功的提醒
    */
    public function sendErrorWorkReport()
    {
        if (!empty($this->newsport->corpindex)) {

            $this->workreport_reminds_typeone();//工作协同的提醒
            $this->workreport_reminds_half();//工作协同中的回复等提醒
            $workremindarr = $this->work_remind;
            $multiremind = array_merge($remindarr,$workremindarr);
            if(empty($multiremind)){
                return array();
            }else{
                $multiremindarr['corpid'] =  $this->newsport->corpid;
                $multiremindarr['count'] =  count($remindarr);
                $multiremindarr['version'] = $this->newsport->get_server_version();
                $multiremindarr['corp_link'] = $this->newsport->corp_link;
                $multiremindarr['content'] =  $multiremind;
                //更新消息状态为已发送
                if (!empty($this->successids_workreport)) {
                    global $adb;
                    $idlist = implode(",", $this->successids_workreport);
                    $updatesql = 'update ld_workreport_remind set push_to_weixin = 3,push_time=NOW() WHERE id in (' . $idlist . ')';
                    $adb->pquery($updatesql, array());
                }
                return $multiremindarr;
            }

        }else{
            return array();
        }
    }
    //获取提醒内容包
    public function interval()
    {
        if (!empty($this->newsport->corpindex)) {
            $remindarr = $this->common_reminds(); //ld_remind 表中的提醒
            $this->workreport_reminds_typeone();//工作协同的提醒
            $this->workreport_reminds_half();//工作协同中的回复等提醒
            $workremindarr = $this->work_remind;
            $multiremind = array_merge($remindarr,$workremindarr);
            if(empty($multiremind)){
                return array();
            }else{
                $multiremindarr['corpid'] =  $this->newsport->corpid;
                $multiremindarr['count'] =  count($remindarr);
                $multiremindarr['version'] = $this->newsport->get_server_version();
                $multiremindarr['corp_link'] = $this->newsport->corp_link;
                $multiremindarr['content'] =  $multiremind;
                //更新消息状态为已发送
                if (!empty($this->successids_workreport)) {
                    global $adb;
                    $idlist = implode(",", $this->successids_workreport);
                    $updatesql = 'update ld_workreport_remind set push_to_weixin = 3,push_time=NOW() WHERE id in (' . $idlist . ')';
                    $adb->pquery($updatesql, array());
                }
                return $multiremindarr;
            }

        }else{
            return array();
        }
    }

    //过滤表情
    protected function filterImage($worksummary)
    {
        $worksummary_orign = preg_replace("/<img height=\"18\" width=\"18\" style=\"vertical-align:middle\" src=\".*\" >/U", "", htmlspecialchars_decode($worksummary));
        return $worksummary_orign;
    }

    //ld_reminds表的分配审批等消息提醒
    protected function common_reminds()
    {
        global $adb, $current_user;
        $date = date('Y-m-d H:i:s', time());
        $limitnum = $this->limitnum;
        $remindsarr = array();
        $sql = '(SELECT
            GROUP_CONCAT(remindsid) remindsid,
            GROUP_CONCAT(ld_users.wx_userid SEPARATOR \'|\') wx_userid,
            recieverid,
            content,
            date_time,
            related_to,
            reltab,
            push_to_weixin,
            remindstype,
            reminds_ruleid
        FROM ld_reminds Q 
        LEFT JOIN ld_users on ld_users.id = Q.recieverid
        LEFT JOIN ld_tab on ld_tab.name=Q.reltab
        WHERE Q.deleted = 0 
            AND Q.status_rmd = "未读" 
            AND Q.is_del_rec = 0 
            AND Q.push_to_weixin = 2 
            AND Q.date_time<=DATE_ADD(NOW(),INTERVAL 10 MINUTE) 
            AND Q.date_time>=NOW() 
            AND ld_tab.mobilepresence like \'%weixin%\'
            AND length(ld_users.wx_userid) > 0
            AND ld_users.push_wx_reminds=1 
        GROUP BY content,related_to,reltab,date_time
        ORDER BY Q.date_time ASC limit ' . $limitnum . ')
        UNION (SELECT
            GROUP_CONCAT(remindsid) remindsid,
            GROUP_CONCAT(ld_users.wx_userid SEPARATOR \'|\') wx_userid,
            recieverid,
            content,
            date_time,
            related_to,
            reltab,
            push_to_weixin,
            remindstype,
            reminds_ruleid
        FROM ld_reminds Q 
        LEFT JOIN ld_users on ld_users.id = Q.recieverid
        LEFT JOIN ld_tab on ld_tab.name=Q.reltab
        WHERE Q.deleted = 0 
            AND Q.status_rmd = "未读" 
            AND Q.is_del_rec = 0 
            AND Q.push_to_weixin = 2 
            AND Q.date_time < NOW()
            AND Q.date_time>DATE_SUB(NOW(),INTERVAL 1 DAY)
            AND ld_tab.mobilepresence like \'%weixin%\'
            AND length(ld_users.wx_userid) > 0
            AND ld_users.push_wx_reminds=1
        GROUP BY content,related_to,reltab,date_time
        ORDER BY Q.date_time DESC limit ' . $limitnum . ')';
        $detailarr = array();
        $result = $adb->pquery($sql, array());
        $nums = $adb->num_rows($result);
        if ($nums > 0) {
            //$access_token = $this->newsport->getAccessToken('crm');//gyq_33
            $tmpremindids=array();
            for ($i = 0; $i < $nums; $i++) {
                $remindsid = $adb->query_result($result, $i, 'remindsid');
                $wx_userid = $adb->query_result($result, $i, 'wx_userid');
                $recieverid = $adb->query_result($result, $i, 'recieverid');
                $content = $adb->query_result($result, $i, 'content');
                $date_time = $adb->query_result($result, $i, 'date_time');
                $related_to = $adb->query_result($result, $i, 'related_to');
                $reltab = $adb->query_result($result, $i, 'reltab');
                $remindstype = $adb->query_result($result, $i, 'remindstype');
                $reminds_ruleid = $adb->query_result($result, $i, 'reminds_ruleid');
                $content = $content;
                $temparr['remindsid'] = $remindsid;
                $temparr['description'] = $content;
                $temparr['related_to'] = $related_to;
                $temparr['wx_userid'] = $wx_userid;
                $temparr['date_time'] = $date_time;
                $temparr['reltab'] = $reltab;
                $temparr['remindstype'] = $remindstype;
                $temparr['reminds_ruleid'] = $reminds_ruleid;
                $detailarr[$wx_userid][] = $temparr;
                $tmpremindids[]=$remindsid;
                
            }
            $remindsarr = $this->multiSendNews($detailarr);

            if (!empty($tmpremindids)) {
                $remindsid = implode(',', $tmpremindids);
                $updatesql = 'update ld_reminds set push_to_weixin = 3,push_time=NOW() WHERE remindsid in (' . $remindsid . ')';
                $adb->pquery($updatesql, array());
                $this->successids_reminds = array();
            }
        }
        return $remindsarr;
    }
    //ld_reminds表的提醒拼装方法
    public function multiSendNews($detailarr)
    {
        global $adb;
        $corp_link = $this->newsport->corp_link;
        $multi_news = array();
        foreach ($detailarr as $userid => $val) {
            $newArr['touser'] = $userid;
            $newArr['toparty'] = '';
            $newArr['totag'] = '';
            $newArr['msgtype'] = 'news';
            foreach ($val as $key => $detail) {
                $newdetail = $this->processRemindContentsNov($detail);
                $r_remindtype = $detail['remindstype'];
                $r_reminds_ruleid = $detail['reminds_ruleid'];
                if(strtolower($r_remindtype)=='antiapprove')
                {
                    $title = '反审批提醒';
                }
                //zkt 20220427  【ID1002781】【审批、分配、共享等“消息提醒”标签修改为【模块】操作提醒（第一版）】
                elseif($r_remindtype =='AntiApprove'){//强制驳回提交审批
                    $title = sprintf(getFixedLabel('MODULEEXPEDITINGREMIND'),getTranstab($detail['reltab']));
                }elseif($r_remindtype == 'share'){//共享，add_remind添加的提醒
                    $title = sprintf(getFixedLabel('MODULESHAREREMIND'),getTranstab($detail['reltab']));//【模块名称】共享提醒
                }
                elseif(in_array($r_remindtype,array('SalesOrderDueDate','ServiceContractsDueDate','PaymentPlanPlanDate','SendPaymentPlanDate'))){
                    //合同交付提醒、服务合同产品到期提醒、收款计划到期提醒、付款计划到期提醒
                    $title = getFixedLabel($r_remindtype.'Remind');//【合同订单】交付提醒
                }elseif($r_remindtype == 'MODULECOMMENTRemind'){//评论提醒
                    $title = sprintf(getFixedLabel($r_remindtype),getTranstab($detail['reltab']));//【模块名称】评论提醒
                }
                elseif(in_array($r_remindtype,array('AccountsRECYCLEREMIND','LeadsRECYCLEREMIND','AccountsHEDGINGREMIND','CreateRemind','AccountsBEFOREREMIND','LeadsBEFOREREMIND'))){
                    //remindstype直接转为翻译：公海回收、报备提醒、新增提醒
                    $title = getFixedLabel($r_remindtype);
                }
                elseif(empty($r_remindtype)&&!empty($r_reminds_ruleid)){//自动提醒
                    $tmpsql = 'select `name` from ld_automaticreminds where id = ?';
                    $tmpresult = $adb->pquery($tmpsql,array($r_reminds_ruleid));
                    $title = '消息提醒';
                    if($adb->num_rows($tmpresult)>0){
                        $tmprulename = $adb->query_result($tmpresult,0,'name');
                        //zkt 20220520 51988(https://81mis.com/kfbcrm/index.php)（消息提醒标签修改）系统设置》参数设置》自动提醒设置》合同订单》在移动端提醒没有【模块名称】
                        $title = sprintf(getFixedLabel('MODULEAUTOREMINDREMIND'),getTranstab($detail['reltab']),$tmprulename);//【模块名称】$规则名称$提醒
                    }
                }
                else{
                    $title = '消息提醒';
                }
                $describ = str_replace('&#039;', '\'', htmlspecialchars_decode(html_entity_decode($newdetail['description'])));
                //editor:gyq_110 reason:企业微信小程序提醒  2019/5/14 11:06
                if ($this->newsport->type_mini) {
                    $newArr = $this->newsport->miniprogram_notice($describ,$title,$detail['reltab'],$detail['related_to'],$detail['date_time']);
                }else{
                    $newArr['agentid'] = $newdetail['agentid'];
                    $newArr['news']['articles'][0]['title'] = $title;
                    //editor:gyq reason:过滤html标签 date:20180703 0034309: （公司自用帐套）企业微信>灵当CRM：自动提醒的提醒内容格式有问题。
                    $describ = strip_tags(str_replace('"', '\"', $describ),'<br>');
                    $newArr['news']['articles'][0]['description'] = $describ;
                    $newArr['news']['articles'][0]['url'] = $newdetail['url'];
                    //$newArr['news']['articles'][0]['picurl'] = 'storage/2016/October/week4/1477463435997.jpg';
                    $newArr['news']['articles'][0]['picurl'] = '';
                    $newArr['url_info'] = $newdetail['url_info'];
                }
                $multi_news[] = $newArr;
                $this->successids_reminds[] = $detail['remindsid'];
            }
        }
        return $multi_news;
    }
    //ld_reminds表的加工消息提醒内容
    protected function processRemindContentsNov($detailarr)
    {
        $n = $this->newline;
        $Module =$detailarr['reltab'];
        $focus = CRMEntity::getInstance($Module);
        $_REQUEST['CheckFromRemind'] = true; //提醒单据中包含删除的单据会报错
        $focus->retrieve_entity_info($detailarr['related_to'], $Module);
        $focus->id = $related_to = $detailarr['related_to'];
        $focus->name = $focus->column_fields['content'];
        $fieldObj = $focus->fieldobj->getFieldInfoobjBykey("fieldname",$focus->list_link_field,"fieldlabel");
        $linkname = $fieldObj->fieldLableKey;//超链接字段
        /*$detail = getBlocks("Reminds", "detail_view", '', $focus->column_fields);
        $relatedobj = strip_tags($detail['基本信息'][0]['相关对象']['value']);
        $relatedtab = $detail['基本信息'][1]['相关模块']['value'];*/
        $newdetial['description'] = $detailarr['description'] . $n . $n;
        $newdetial['description'] = str_replace("\n", $n, $newdetial['description']);    //0030329: 微信端--消息提醒--回款计划提醒，提醒内容中显示了符号“rn”
        $ormod = $detailarr['reltab'];dump($linkname);
        //editor:gyq_20190326 reason:指向成员详情界面的提醒，由于企业微信没做成员详情模块，
        //现将关联模块是用户的提醒，不赋值跳转链接，禁止消息穿透
        if(empty($related_to) || $ormod=='Users'){
            $newdetial['url_info']['location'] = '';
        }else{
            $newdetial['description'] .= $linkname . " : " . $focus->column_fields[$fieldObj->fieldName] . $n;
            // $static_address = $this->newsport->static_address;
            $corp_index = $this->newsport->corpindex[StaticConst::$suite_crm];

            $userid = $detailarr['wx_userid'];
            //gyq_41
            $modulelabel = getTranstab($ormod);
            //0049128: （kfbcrm，企业微信移动端）催审提醒后，审批人直接点击提醒消息详情，应该进入审批中心待审批单据查看详情界面
            if($detailarr['remindstype']=='Approve'||$detailarr['remindstype'] == 'ExpeditingApprove'){
                $listtype = 'approvelist';
            }else{
                $listtype = 'list';
            }
            $location = 'ldcrm/index.html#!/detailview/' . $ormod . '/' . $detailarr['related_to'] . '/' . $modulelabel . '/'.$listtype.'/yes/-1';
            $newdetial['url_info']['location'] = $location;
        }

        $newdetial['description'] .= '操作时间：' . $detailarr['date_time'];
        $newdetial['url'] = '';
        $newdetial['agentid'] = $this->newsport->agentid['ldcrm'];
        $newdetial['url_info']['corpindex'] = $this->newsport->corpindex[StaticConst::$suite_crm];
        $newdetial['url_info']['suitename'] = $this->newsport->suitename_coll[StaticConst::$suite_crm];
        return $newdetial;

    }

    //工作协同提醒初始化消息内容格式   gyq_41 新增参数$module_label
    public function initForSendNews($jumpurl, $purposeUser, $Title, $Description, $picurl, $reportid, $module_label)
    {
        global $current_user;
        $Description = $this->filterImage($Description);
        //$server_url = $this->newsport->static_address;
        if (!empty($picurl)) {
            $picurl = $this->newsport->corp_link . $picurl;
        }
        foreach ($purposeUser as $user) {
            //$sys_144 = getSys_deploy(144);
            //$sys_144_info = $sys_144['deploy_value']?'no':'yes';
            $location = $jumpurl . '/' . $module_label;//.'/'.$sys_144_info;
            $newArr['touser'] = $user;
            $newArr['toparty'] = '';
            $newArr['totag'] = '';
            $newArr['msgtype'] = 'news';
            $newArr['agentid'] = $this->newsport->agentid['Home'];

            $describ = str_replace('&#039;', '\'', htmlspecialchars_decode(html_entity_decode($Description)));
            $describ = strip_tags(str_replace('"', '\"', $describ),'<br>');
            
            $newArr['news']['articles'][0]['title'] = $Title;
            $newArr['news']['articles'][0]['description'] = $describ;
            $newArr['news']['articles'][0]['url'] = '';
            //$newArr['news']['articles'][0]['picurl'] = 'storage/2016/October/week4/1477463435997.jpg';
            $newArr['news']['articles'][0]['picurl'] = $picurl;
            $newArr['url_info']['location'] = $location;
            $newArr['url_info']['corpindex'] = $this->newsport->corpindex['app'];
            $newArr['url_info']['suitename'] = $this->newsport->suitename_coll['app'];
            $this->work_remind[] = $newArr;

            $this->successids_workreport[] = $reportid;
        }
    }
    //工作协同新日志等发出后的标准提醒
    protected function workreport_reminds_typeone()
    {
        global $adb;
        $n = $this->newline;
        crm_load_class_file('WorkReportModel', 'modules/Home');
        $this->workmodel = $workobj = new WorkReportModel();
        $workfldarr = $workobj->getWorkCfFieldInfo('workreport');
        $workfldsql = '';
        $limitnum = floor(($this->limitnum) / 2);
        if (!empty($workfldarr)) {
            $workfldkeyarr = array_keys($workfldarr);
            $workfldsql = ',ld_workreportcf.' . join(',ld_workreportcf.', $workfldkeyarr);
        }
        $sql = '(SELECT
                ld_workreport_remind.id,
                ld_workreport_remind.relatedto,
                ld_workreport.entitytype
            FROM ld_workreport_remind
            LEFT JOIN ld_workreport on ld_workreport.workreportid = ld_workreport_remind.relatedto
            WHERE ld_workreport_remind.remind_status = 0 
                AND ld_workreport_remind.push_to_weixin = 2
                AND ld_workreport_remind.relatedto > 0  
                AND ld_workreport_remind.remindtype=1
                AND ld_workreport_remind.createdtime < NOW() 
                AND ld_workreport_remind.createdtime>DATE_SUB(NOW(),INTERVAL 1 DAY)
            ORDER BY ld_workreport_remind.createdtime DESC limit ' . $limitnum . ')
            UNION (SELECT
                ld_workreport_remind.id,
                ld_workreport_remind.relatedto,
                ld_workreport.entitytype
            FROM ld_workreport_remind
            LEFT JOIN ld_workreport on ld_workreport.workreportid = ld_workreport_remind.relatedto
            WHERE ld_workreport_remind.remind_status = 0 
                AND ld_workreport_remind.push_to_weixin = 2
                AND ld_workreport_remind.relatedto > 0  
                AND ld_workreport_remind.remindtype=1
                AND ld_workreport_remind.createdtime<=DATE_ADD(NOW(),INTERVAL 10 MINUTE) 
                AND ld_workreport_remind.createdtime>=NOW() 
            ORDER BY ld_workreport_remind.createdtime ASC limit ' . $limitnum . ')';

        $usersql = 'SELECT 
                        GROUP_CONCAT(ld_users.wx_userid SEPARATOR \'|\') wx_userid,
                        ld_workreport2user.User_type
                    FROM ld_workreport2user 
                    LEFT JOIN ld_users on ld_users.id = ld_workreport2user.userid
                    WHERE length(ld_users.wx_userid)>0 
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
                        concat(ld_workachments.path,ld_workachments.name) as picpath,
                        ld_workachments.type as atttype,
                        ld_workreport.smcreatorid' . $workfldsql . '
                    FROM ld_workreport
                    LEFT JOIN ld_users on ld_users.id = ld_workreport.smcreatorid
                    LEFT JOIN ld_workreportcf on ld_workreportcf.workreportid = ld_workreport.workreportid
                    LEFT JOIN ld_workachments on ld_workachments.workreportid = ld_workreport.workreportid
                    WHERE length(ld_workreport.entitytype) > 0 AND ld_workreport.workreportid=?';

        $TransforSecondCategory = array(1 => getFixedLabel('JOURNAL'), 2 => getFixedLabel('WEEKPLAN'), 3 => getFixedLabel('MONTHPLAN'));
        $HomeTransfor = array('1' => 'dayreport', '2' => 'weekreport', '3' => 'monthreport');
        $result = $adb->pquery($sql, array());
        $number = $adb->num_rows($result);
        if ($number > 0) {
           // $token = $this->newsport->getAccessToken('app');//gyq_33
           // if (!empty($token)) {
                for ($i = 0; $i < $number; $i++) {
                    $id = $adb->query_result($result, $i, 'id');
                    $relatedto = $adb->query_result($result, $i, 'relatedto');
                    $entitytype = $adb->query_result($result, $i, 'entitytype');
                    $workresult = $adb->pquery($worksql, array($relatedto));
                    $last_name = $adb->query_result($workresult, 0, 'last_name');
                    $type = $adb->query_result($workresult, 0, 'type');
                    $createdtime = $adb->query_result($workresult, 0, 'createdtime');
                    $startdate = $adb->query_result($workresult, 0, 'startdate');
                    $worksummary = $adb->query_result($workresult, 0, 'worksummary');
                    $lastname = $adb->query_result($workresult, 0, 'last_name');
                    $workplan = $adb->query_result($workresult, 0, 'workplan');
                    $workexperience = $adb->query_result($workresult, 0, 'workexperience');
                    $picurl = '';
                    for ($k = 0; $k < $adb->num_rows($workresult); $k++) {
                        $picpath = $adb->query_result($workresult, $k, 'picpath');
                        $atttype = $adb->query_result($workresult, $k, 'atttype');
                        if ($atttype == 'image' && !empty($picpath)) {
                            $picurl = $picpath;
                            break;
                        }
                    }
                    if (!empty($workfldkeyarr) && $entitytype == 'workreport') {
                        foreach ($workfldkeyarr as $workfld) {
                            $value = $adb->query_result($workresult, 0, $workfld);
                            if (!empty($value)) {
                                $value = str_replace($n, "<br>", $value);
                            } else {
                                $value = '';
                            }
                            if (!empty($value)) {
                                $$workfld = $this->filterImage($value);
                            }
                        }
                    }

                    if ($entitytype == 'workreport') {
                        $workReportTemplate = $workobj->getallFieldsForTable();
                        $workTemplate = $workReportTemplate['workreport'][$HomeTransfor[$type]]['fieldinfo'];
                        $descriptionW = '';
                        foreach ($workTemplate as $key => $val) {
                            if (!empty($$val['name'])) {
                                $fname = $$val['name'];
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
                    if($this->newsport->suitename_coll['app']==StaticConst::$suite_crm){
                        //http://www.51mis.cn/websaas/weixinsaas/ceshi/ldcrm/index.html#!/work_detail/838/workreport/%E6%97%A5%E5%BF%97
                        $jumpurl = 'ldcrm/index.html#!/work_detail/'.$relatedto.'/'.$entitytype;
                    }else{
                        $jumpurl = 'ldwork/index.html#!/detail/' . $relatedto . '/' . $entitytype;
                    }
                    $user_purpose = array();
                    $userresult = $adb->pquery($usersql, array($relatedto));
                    $useridexist = array();
                    for ($j = 0; $j < $adb->num_rows($userresult); $j++) {
                        $descriptionFinal = '';
                        $userid2 = $adb->query_result($userresult, $j, 'wx_userid');
                        if (array_search($userid2, $useridexist) === false) {
                            $usertype2 = $adb->query_result($userresult, $j, 'user_type');
                            if ($usertype2 == 5) {
                                $useridexist[] = $userid2;
                                $descriptionFinal .= '发布人：' . $last_name . $n . '发布时间: ' . $createdtime . $n . $descriptionW;
                                $secondPara = $TransforSecondCategory[$type];
                                $secondLine =  '【' .getTranstab('CooperativeWork').'】点评提醒|有新的' . $secondPara . '需要您点评';
                                $this->initForSendNews($jumpurl, array($userid2), $secondLine, $descriptionFinal, $picurl, $id, $secondPara);
                            } elseif ($usertype2 == 6) {
                                $useridexist[] = $userid2;
                                $descriptionFinal .= '请于' . $startdate . '之前完成' . $n;
                                $descriptionFinal .= '发布人：' . $last_name . $n . '发布时间: ' . $createdtime . $n . $workexperience;
                                $secondLine = '工作提醒|有新的任务需要您执行';
                                $this->initForSendNews($jumpurl, array($userid2), $secondLine, $descriptionFinal, $picurl, $id, '任务');
                            } elseif ($usertype2 == 1 || $usertype2 == 2) {
                                $useridexist[] = $userid2;
                                if ($entitytype == 'workreport') {
                                    $secondPara = $TransforSecondCategory[$type];
                                    $descriptionFinal .= '发布人：' . $last_name . $n . '发布时间: ' . $createdtime . $n . $descriptionW;
                                } elseif ($entitytype == 'cocmd') {
                                    $secondPara = getFixedLabel('TASK');
                                    $descriptionFinal .= '发布人：' . $last_name . $n . '发布时间: ' . $createdtime . $n . $workexperience;
                                } else {
                                    $secondPara = getFixedLabel('BLOG');
                                    $descriptionFinal .= '发布人：' . $last_name . $n . '发布时间: ' . $createdtime . $n . $workexperience;
                                }
                                if ($usertype2 == 1) {
                                    $secondLine = '【' .getTranstab('CooperativeWork').'】抄送提醒|有新的' . $secondPara . '抄送给您';
                                    $this->initForSendNews($jumpurl, array($userid2), $secondLine, $descriptionFinal, $picurl, $id, $secondPara);
                                } elseif ($usertype2 == 2) {
                                    $secondLine = '工作提醒|有新的' . $secondPara . '@您';

                                    $this->initForSendNews($jumpurl, array($userid2), $secondLine, $descriptionFinal, $picurl, $id, $secondPara);
                                }
                            }
                        }
                    }
                }
         }
    }
    //工作协同回复，赞等提醒
    public function workreport_reminds_half()
    {
        global $adb;
        $n = $this->newline;
        $TransforSecondCategory = array(1 => getFixedLabel('JOURNAL'), 2 => getFixedLabel('WEEKPLAN'), 3 => getFixedLabel('MONTHPLAN'));
        $HomeTransfor = array('1' => 'dayreport', '2' => 'weekreport', '3' => 'monthreport');
        $workobj = $this->workmodel;
        $limitnum = floor(($this->limitnum) / 2);
        $sql = '(SELECT
                  ld_workreport_remind.id,
                  ld_workreport_remind.remindtype,
                  ld_workreport_remind.remind_status,
                  ld_workreport_remind.relatedto,
                  ld_workreport_remind.userid,
                  ld_workreport_remind.createdtime,
                  B.wx_userid,
                  ld_workreport_remind.operationtype,
                  ld_workreport_remind.content
                FROM ld_workreport_remind
                LEFT JOIN ld_users B on B.id = ld_workreport_remind.userid
                WHERE ld_workreport_remind.remind_status = 0 
                    AND ld_workreport_remind.push_to_weixin = 2 
                    AND ld_workreport_remind.relatedto > 0 
                    AND length(B.wx_userid) > 0
                    AND ld_workreport_remind.remindtype <> 1 
                    AND ld_workreport_remind.remindtype <> 3
                    AND B.push_wx_reminds=1
                ORDER BY createdtime ASC limit ' . $limitnum . ')
            UNION(SELECT
                  ld_workreport_remind.id,
                  ld_workreport_remind.remindtype,
                  ld_workreport_remind.remind_status,
                  ld_workreport_remind.relatedto,
                  ld_workreport_remind.userid,
                  ld_workreport_remind.createdtime,
                  B.wx_userid,
                  ld_workreport_remind.operationtype,
                  ld_workreport_remind.content
                FROM ld_workreport_remind
                LEFT JOIN ld_users B on B.id = ld_workreport_remind.userid
                WHERE ld_workreport_remind.remind_status = 0 
                    AND ld_workreport_remind.push_to_weixin = 2 
                    AND ld_workreport_remind.relatedto > 0 
                    AND length(B.wx_userid) > 0
                    AND ld_workreport_remind.remindtype <> 1 
                    AND ld_workreport_remind.remindtype <> 3
                    AND B.push_wx_reminds=1
                ORDER BY createdtime DESC limit ' . $limitnum . ')';
        $worksql = 'SELECT
                  ld_workreport.entitytype,
                  ld_workreport.workexperience,
                  ld_workreport.type,
                  A.last_name,
                  ld_workreport.createdtime,
                  ld_workreport.worksummary,
                  ld_workreport.workplan,
                  ld_workreport.enddate,
                  ld_workreport.startdate
                FROM ld_workreport
                  LEFT JOIN ld_users A on A.id = ld_workreport.smcreatorid
                WHERE length(ld_workreport.entitytype) > 0 AND ld_workreport.workreportid=? ';
        $sqlreplay = 'SELECT workreportid from ld_workreply WHERE workreplyid=? limit 1';
        // $sql='insert into ld_praise(workreportid,userid,createdtime)values(?,?,?)';
        $sqlpraise = 'SELECT workreportid from ld_praise WHERE praiseid=? limit 1';
        $user_purpose = array();
        $userresult = $adb->pquery($sql, array());
        $number = $adb->num_rows($userresult);
        if ($number > 0) {
           /* $token = $this->newsport->getAccessToken('app');//gyq_33
            if (!empty($token)) {*/
                for ($j = 0; $j < $adb->num_rows($userresult); $j++) {
                    $id = $adb->query_result($userresult, $j, 'id');
                    $remindtype = $adb->query_result($userresult, $j, 'remindtype');
                    $userid = $adb->query_result($userresult, $j, 'userid');
                    $operationtype = $adb->query_result($userresult, $j, 'operationtype');
                    $content = $adb->query_result($userresult, $j, 'content');
                    $wx_userid = $adb->query_result($userresult, $j, 'wx_userid');

                    if ($remindtype == 6) {
                        $relatedto = $adb->query_result($userresult, $j, 'relatedto');
                        $praiseresult = $adb->pquery($sqlpraise, array($relatedto));
                        $relatedto = $adb->query_result($praiseresult, 0, 'workreportid');
                        $workresult = $adb->pquery($worksql, array($relatedto));

                    } else {
                        $related_replayid = $adb->query_result($userresult, $j, 'relatedto');
                        $relatedto_replay = $adb->pquery($sqlreplay, array($related_replayid));
                        $relatedto = $adb->query_result($relatedto_replay, 0, 'workreportid');
                        $workresult = $adb->pquery($worksql, array($relatedto));
                    }

                    $entitytype = $adb->query_result($workresult, 0, 'entitytype');
                    $workexperience = $adb->query_result($workresult, 0, 'workexperience');
                    $worksummary = $adb->query_result($workresult, 0, 'worksummary');
                    $workplan = $adb->query_result($workresult, 0, 'workplan');
                    $type = $adb->query_result($workresult, 0, 'type');
                    $last_name = $adb->query_result($workresult, 0, 'last_name');
                    $enddate = $adb->query_result($workresult, 0, 'enddate');
                    $startdate = $adb->query_result($workresult, 0, 'startdate');
                    $createdtime = $adb->query_result($userresult, $j, 'createdtime');
                    $description = '';
                    //$jumpurl = 'work/index.html#!/detail/'.$relatedto.'/'.$entitytype;
                    if($this->newsport->suitename_coll['app']==StaticConst::$suite_crm){
                        $jumpurl = 'ldcrm/index.html#!/work_detail/'.$relatedto.'/'.$entitytype;
                    }else{
                        $jumpurl = 'ldwork/index.html#!/detail/' . $relatedto . '/' . $entitytype;
                    }
                    //$jumpurl = 'ldwork/index.html#!/detail/' . $relatedto . '/' . $entitytype;

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
                            $description .= '发布人：' . $last_name . $n . '发布时间: ' . $createdtime . $n . $descriptionW;
                            $secondPara = $TransforSecondCategory[$type];
                            $secondLineM = '有新的' . $secondPara . '需要您点评';
                        } else {
                            $description .= $content . $n;
                            $description .= '操作时间：' . $createdtime . $n . $descriptionW;
                        }
                    } elseif ($entitytype == 'cocmd') {
                        if ($remindtype == 1) {
                            $description .= '请于' . $startdate . '之前完成' . $n;
                            $description .= '发布人：' . $last_name . '|' . '发布时间:' . $createdtime . $n;
                            $secondLineM = '有新的任务需要您执行';
                        } else {
                            $description .= $content . $n;
                            $description .= '操作时间：' . $createdtime . $n;
                        }
                        $description .= $workexperience;
                    } else {
                        $description .= $content . $n;
                        $description .= '操作时间：' . $createdtime . $n;
                        $description .= $workexperience;
                    }
                    if ($remindtype == 3 || $remindtype == 4) {
                        $secondLineM = '@我';
                    } elseif ($remindtype == 6) {
                        $secondLineM = '点赞';
                    } elseif ($remindtype == 2) {
                        $secondLineM = '回复';
                    } elseif ($remindtype == 5) {
                        if ($operationtype == 1) {
                            $secondLineM = '完成任务';
                        } else {
                            $secondLineM = '点评';
                        }
                    }
                    $secondLineFinal =  '【' .getTranstab('CooperativeWork').'】提醒|' . $secondLineM;
                    $this->initForSendNews($jumpurl, array($wx_userid), $secondLineFinal, $description, '', $id, $secondLineM);
                }
            }
    }
    //eidtor:gyq_20180817  reason:主动发送消息提醒
    public function send_multi_reminds($r_multi_content){
        global $adb;
        $this->letsbegin();
        $multiremindarr['corpid'] = $this->newsport->corpid;
        $multiremindarr['count'] = count($r_multi_content);
        $multiremindarr['version'] = $this->newsport->get_server_version();
        $multiremindarr['corp_link'] = $this->newsport->corp_link;
        foreach ($r_multi_content as $key=>$news_content) {
            $r_userid_arr = $news_content['userid'];
            if(!is_array($r_userid_arr) || empty($r_userid_arr)){
                ConvertTojsonString(-1,array(),'Error:userid数据异常!');
            }
            $r_content = $news_content['message'];
            $r_reltab = $news_content['reltab'];
            $r_related_to = $news_content['related_to'];
            $r_date_time = $news_content['date_time'];
            $r_remindtype = $news_content['remindtype'];
            $location = '';
            if($r_remindtype=='massallocate'||$r_remindtype=='massshare'){
                $news_title = '消息提醒';
                $modulelabel = getTranstab($r_reltab);
                $location = 'ldcrm/index.html#!/listview/' . $r_reltab . '/' . $modulelabel . '/-1/mass_remind/'.$r_related_to;
            }elseif ($r_remindtype == 'Approve'||$r_remindtype == 'ExpeditingApprove') {
                $listtype = 'approvelist';
                $news_title = '审批提醒';
            } else {
                $news_title = '消息提醒';
                $listtype = 'list';
            }
            //zkt 20220718 BUG0053999企业微信移动端，合同订单（SO17）审批通过消息提醒中，提醒标题默认值显示错误，目前显示的是审批提醒
            //zkt 20220520 51988(https://81mis.com/kfbcrm/index.php)（消息提醒标签修改）系统设置》参数设置》自动提醒设置》合同订单》在移动端提醒没有【模块名称】
            //zkt 20220520  【ID1002781】【审批、分配、共享等“消息提醒”标签修改为【模块】操作提醒（第一版）】
            if($r_remindtype =='ForceAntiApprove'){//强制驳回提交审批
                $news_title = '【'.getTranstab($r_reltab).'】'.getFixedLabel('FORCEDREJECTSUBMITAPPROVAL');
            }elseif($r_remindtype =='AntiApprove'){//反审批
                $news_title = '【'.getTranstab($r_reltab).'】'.'反审批提醒';
            }
            elseif($r_remindtype == 'share'){//共享，add_remind添加的提醒
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
                $r_content .= $this->newline .$related_to_lable.'：'.$related_to_name;
            }
            $newArr = array();//消息体
            $newArr['agentid'] = $this->newsport->agentid['ldcrm'];
            if (!empty($r_related_to) && empty($location)) {
                if($r_reltab=='CooperativeWork')
                {
                    $modulelabel = $r_multi_content['modulelabel'];

                }
                else
                {
                    $modulelabel = getTranstab($r_reltab);

                }

                $location = 'ldcrm/index.html#!/detailview/' . $r_reltab . '/' . $r_related_to . '/' . $modulelabel . '/' . $listtype . '/yes/-1';

            }
            $newArr['url_info']['location']  = $location;
            $newArr['url_info']['corpindex'] = $this->newsport->corpindex[StaticConst::$suite_crm];
            $newArr['url_info']['suitename'] = $this->newsport->suitename_coll[StaticConst::$suite_crm];

            $newArr['touser'] = implode('|', $r_userid_arr);
            $newArr['toparty'] = '';
            $newArr['totag'] = '';
            $newArr['msgtype'] = 'news';
            $newArr['agentid'] = $this->newsport->agentid['ldcrm'];
            $newArr['news']['articles'][0]['title'] = $news_title;
            //wym 240513 XUQIU1002193 销售线索、客户，即将回收和回收消息提醒内容单据查看详情界面，客户名称增加显示超链接，移动端不显示该超链接
            $describ = str_replace('&#039;', '\'', htmlspecialchars_decode(strip_tags(html_entity_decode($r_content),'<br>')));
            $describ = str_replace('"', '\"', $describ);
            $describ .= $this->newline.'操作时间：' . $r_date_time;
            $newArr['news']['articles'][0]['description'] = $describ;
            $newArr['news']['articles'][0]['url'] = '';
            $newArr['news']['articles'][0]['picurl'] = '';
            $newArr['news']['articles'][0]['btntxt'] = '详情';
            $multiremindarr['content'][] = $newArr;
        }
        $news_data['news'] = json_encode($multiremindarr,JSON_UNESCAPED_UNICODE);
        $errno = $this->newsport->push_news(StaticConst::$server_remindapi,$news_data);
        return $errno;
    }

    //editor:gyq_20181011 获取单次多条提醒
    public function get_mass_remind($r_parentid,$r_queryobj){
        global $adb;
        $sql = 'SELECT related_to,reltab FROM ld_reminds  WHERE  parentid=?';
        $sql .= ' union all SELECT related_to,reltab FROM ld_reminds_accepted  WHERE  parentid=?';
        $detailarr = array();
        $result = $adb->pquery($sql, array($r_parentid,$r_parentid));
        $nums = $adb->num_rows($result);
        $related_to_arr = array();
        if ($nums > 0) {
            for ($i = 0; $i < $nums; $i++) {
                $related_to_arr[] = $adb->query_result($result, $i, 'related_to');
            }
        }
        $relatedids = implode(',',$related_to_arr);

        $baseTable = $r_queryobj->moduleobj->table_name;
        $moduleTableIndexList = $r_queryobj->moduleobj->tab_name_index;
        $baseTableIndex = $moduleTableIndexList[$baseTable];

        $wheresql .= " AND $baseTable.$baseTableIndex in ($relatedids)";
        return $wheresql;
    }
}