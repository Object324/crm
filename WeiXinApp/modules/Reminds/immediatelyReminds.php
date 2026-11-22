<?php

require_once(globalStatic::$root_directory . '/appCommon/appCommon.php');

class immediatelyReminds
{
    protected $newline = '<br>';
    public $newsport;
    public $workmodel;
    public $ids;


    public function getRemindIds()
    {
        return $this->ids;
    }
    public function setRemindIds($ids)
    {
        if (!empty($ids) && is_array($ids)) {
            $this->ids = $ids;
        }
    }

        public function sendReminds($ids, $r_multi_content)
    {
        global $adb;
        // require_once(globalStatic::$root_directory.'/WeiXinApp/modules/Reminds/immediatelyReminds.php');
        crm_load_class_file('cls_StaticCommonFun', 'WeiXinApp/WeiXin_common');
        crm_load_class_file('StaticConst', 'WeiXinApp/WeiXin_common');

        if (sizeof($ids) > 0 && $ids[0] > 0) {
            $errorno = $this->send_multi_reminds($r_multi_content);
            if (!$errorno) {
                $sql = 'update ld_reminds set push_to_weixin=? ,push_time=? where remindsid in(' . implode(',', $ids) . ')';
                $adb->pquery($sql, array(3, date("Y-m-d H:i:s")));

            }
        }
    }

    //初始化接口对象
    public function letsbegin()
    {
        crm_load_class_file("cls_WeixinPort", 'WeiXinApp/WeiXin_common');
        crm_load_class_file("StaticConst", 'WeiXinApp/WeiXin_common');
        crm_load_class_file("config", 'WeiXinApp');
        $this->newsport = new cls_WeixinPort('');
        //editor:gyq_110 reason:企业微信小程序提醒  2019/5/9 15:49
        $this->newsport->init_port_info();
        return $this;
    }

    public function send_multi_reminds($r_multi_content)
    {
        global $adb;
        $this->letsbegin();
        $approveremind_arr = [];//审批消息的集合

        $multiremindarr['corpid'] = $this->newsport->corpid;
        $multiremindarr['count'] = count($r_multi_content);
        $multiremindarr['version'] = $this->newsport->get_server_version();
        $multiremindarr['corp_link'] = $this->newsport->corp_link;
        $multiremindarr['content'] = [];
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
                if($r_remindtype =='ForceAntiApprove'){//强制驳回审批
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
                    //edit:can 20231222 75459 跟进记录--自动提醒设置--推送的消息显示乱码 
                        $tmprulename = html_entity_decode($adb->query_result($tmpresult,0,'name'));//规则名称包含中文双引号
                         
                         
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
				}else{
                    $news_title='消息提醒';
                }

                
                //zkt 20220708 1000017  审批、分配、共享等“消息提醒”标签修改为【模块】操作提醒（第二版）
                //wym 240522 BUG20240520-15  销售线索即将回收提醒，右上角弹窗中多了个编号字段 (relatedto为0时也是为空)
                if ($r_related_to && $r_remindtype != 'massallocate' && $r_remindtype != 'massshare'&& !in_array($r_remindtype,array('AccountsRECYCLEREMIND','LeadsRECYCLEREMIND','AccountsBEFOREREMIND','LeadsBEFOREREMIND'))){
                    $tmpr_reltab = $r_reltab;
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
        
            $newArr = array();//消息体
            //editor:gyq_110 reason:企业微信小程序提醒  2019/5/10 15:19
            if ($this->newsport->type_mini) {
                if ($r_reltab == 'CooperativeWork')
                    $describ = $news_content['message_mini'];
                $newArr = $this->newsport->miniprogram_notice($describ,$news_title,$r_reltab,$r_related_to,$r_date_time,$listtype);
            } else {
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

                $describ .= $this->newline ;
                //zkt 20231219 BUG0077456 用户杨彬 提交的工作日报抄送消息里 重要事项 有个字【操】，请排查，另排查重要事项为空时 也会发消息提醒
                //消息内容最大长度 512字节 478：512-34 （34 ： '操作时间：' . $r_date_time）
                if(strlen($describ)>478){
                    $len = mb_strlen($describ, 'utf-8');
                    $newstr = '';
                    for ($tmpi=0;$tmpi<$len; $tmpi++){
                        $tmpstri = mb_substr($describ, $tmpi, 1, 'utf-8');
                        //467 = 512-34-11 （34 ： '操作时间：' . $r_date_time，11：<br>...<br>）
                        if(strlen($newstr.$tmpstri)>467){
                            break;
                        }
                        $newstr .= $tmpstri;
                    }
                    $describ = $newstr.'<br>...<br>操作时间：' . $r_date_time;
                }
                else{
                    $describ .=  '操作时间：' . $r_date_time;
                }

                if (!empty($r_related_to) && empty($location)) {
                    $modulelabel = getTranstab($r_reltab);
                    $location = 'ldcrm/index.html#!/detailview/' . $r_reltab . '/' . $r_related_to . '/' . $this->filterstring($modulelabel) . '/' . $listtype . '/yes/-1';
                }
                elseif(empty($r_related_to)){
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
                $location.="?fromlogintype=remindsmsg";
                
                $newArr['url_info']['location'] = $location;
                $newArr['toparty'] = '';
                $newArr['totag'] = '';
                $newArr['msgtype'] = 'news';
                $newArr['agentid'] = $this->newsport->agentid['ldcrm'];

                $newArr['news']['articles'][0]['title'] = $news_title;
                $newArr['news']['articles'][0]['description'] = $describ;
                $newArr['news']['articles'][0]['url'] = '';
                $newArr['news']['articles'][0]['picurl'] = '';
                $newArr['news']['articles'][0]['btntxt'] = '详情';
            }
            $newArr['enable_id_trans']=1;//表示是否开启id转译，0表示否，1表示是，默认0
            $newArr['touser'] = implode('|', $r_userid_arr);
            $newArr['url_info']['corpindex'] = $this->newsport->corpindex[StaticConst::$suite_crm];
            $newArr['url_info']['suitename'] = $this->newsport->suitename_coll[StaticConst::$suite_crm];
            $newArr['url_info']['newmsgtype'] =  'yes';//新消息参数，用于后续code判断

            //审批待办消息
            $approveresult = $news_content['approveresult'];
            if(!$this->newsport->type_mini && $r_remindtype == 'Approve' && ($approveresult == 1 || $approveresult == 5||$approveresult == 6)){
                $news_content["location"] = $location;
                $news_content["describ"] = $describ;
                $news_content["news_title"] = $news_title;
                $news_content["agentid"] = $newArr['agentid'];
                $news_content["enable_id_trans"] = $newArr['enable_id_trans'];
                $news_content['url_info']['corpindex'] = $newArr['url_info']['corpindex'];//将这些参数值组装好，以防后期修改时漏掉
                $news_content['url_info']['suitename'] = $newArr['url_info']['suitename'];
                $news_content['url_info']['newmsgtype'] = $newArr['url_info']['newmsgtype'];
                $approveremind_arr[] = $news_content;
                continue;

            }else{
                $newArr['url_info']['agenda_remindsid_arr'] = $this->getWeixinAgendaRemindsid($news_content["weidu_remindsid_weixin"]);//需要转已办的remindsid的集合。
                $this->UpdateWeixinStatusDone($newArr['url_info']['agenda_remindsid_arr']);//更新为已办
            }
            //duan 20240611 消息推送优化,避免一次性发送消息过多导致丢失的问题
            if(is_array($multiremindarr['content'])&& count($multiremindarr['content']) >=20){
                $multiremindarr['count'] = count($multiremindarr['content']);
                $news_data['news'] = json_encode($multiremindarr, JSON_UNESCAPED_UNICODE);
                $errno = $this->newsport->push_news(StaticConst::$server_remindapi, $news_data);
                $multiremindarr['content'] = [];
            }

            $multiremindarr['content'][] = $newArr;
        }
        // dump($newArr);
        $multiremindarr['count'] = count($multiremindarr['content']);
        $news_data['news'] = json_encode($multiremindarr, JSON_UNESCAPED_UNICODE);
          
        $errno = $this->newsport->push_news(StaticConst::$server_remindapi, $news_data);


        //审批消息
        $multiremindarr['content'] = [];
        // crm_load_class_file('cls_dandian', 'WeiXinApp/lib');

        $ids = $this->getRemindIds();
        if(!empty($ids)){
            foreach($ids as $key => $remindsid){
                foreach ($approveremind_arr as $news_content) {
                    $r_userid_arr = $news_content['userid'];
                    if (!is_array($r_userid_arr) || empty($r_userid_arr)) {
                        continue;
                    }

                    $newArr = array();//消息体
                    $approveresult = $news_content['approveresult'];
                    if($r_remindtype == 'Approve' && ($approveresult == 1 || $approveresult == 5||$approveresult == 6)){
                    }else{
                        continue;
                    }

                    if(!isset($r_userid_arr[$key]))
                        break;
                    $wx_userid = $r_userid_arr[$key];//单个成员

                    $newArr['msgtype'] = 'template_card';
                    $newArr['agentid'] = $news_content['agentid'];

                    $newArr['template_card']['task_id'] = $remindsid;
                    $newArr['template_card']['card_type'] = "button_interaction";
                    $newArr['template_card']['main_title']['title'] = $news_content["news_title"];//一级标题
                    $newArr['template_card']['sub_title_text'] = $news_content["describ"];//二级标题
                    $newArr['template_card']['button_list'][0] = array(
                        "type"=>1,//按钮点击事件类型，0 或不填代表回调点击事件，1 代表跳转url
                        "text"=>"未处理",//按钮文案
                        "style"=> 1,//按钮样式，目前可填1~4，不填或错填默认1
                        "key"=> "button_key_1",
                        "url"=> "",//从71mis赋值
                    );

                    $newArr['enable_id_trans'] = $news_content['enable_id_trans'];//表示是否开启id转译，0表示否，1表示是，默认0
                    $newArr['touser'] = $wx_userid;//implode('|', $userid_arr);
                    $newArr['url_info']['location'] = $news_content["location"];
                    $newArr['url_info']['corpindex'] = $news_content['url_info']['corpindex'];
                    $newArr['url_info']['suitename'] = $news_content['url_info']['suitename'];
                    $newArr['url_info']['newmsgtype'] =  $news_content['url_info']['newmsgtype'];//新消息参数，用于后续code判断

                    $newArr['url_info']['remindtype'] = 'approve_agenda';//区分审批消息和普通消息  审批代办
                    $newArr['url_info']['approvelogid'] = $news_content['approvelogid'];
                    $newArr['url_info']['remindsid'] = $remindsid;
                    $newArr['url_info']['agenda_remindsid_arr'] = $this->getWeixinAgendaRemindsid($news_content["weidu_remindsid_weixin"]);//需要转已办的remindsid的集合。
                    $this->UpdateWeixinStatusDone($newArr['url_info']['agenda_remindsid_arr']);//更新为已办

                    $select_result = $adb->pquery("select 1 from ld_reminds_agenda where remindsid=? limit 1", array($remindsid));
                    if ($adb->num_rows($select_result) > 0) {
                        $adb->pquery("update ld_reminds_agenda set approvelogid=? where remindsid=?", array($news_content['approvelogid'],$remindsid));
                    }else{
                        $inser_sql = "insert into ld_reminds_agenda(remindsid,approvelogid) VALUES (?,?)";
                        $params = array($remindsid,$news_content['approvelogid']);
                        $adb->pquery($inser_sql, $params);
                    }

                    //duan 20240611 消息推送优化,避免一次性发送消息过多导致丢失的问题
                    if(is_array($multiremindarr['content'])&& count($multiremindarr['content']) >=20){
                        $multiremindarr['count'] = count($multiremindarr['content']);
                        $news_data['news'] = json_encode($multiremindarr, JSON_UNESCAPED_UNICODE);
                        $errno = $this->newsport->push_news(StaticConst::$server_remindapi, $news_data);
                        $multiremindarr['content'] = [];
                    }
                    $multiremindarr['content'][] = $newArr;
                }
            }
        }

        //  dump($newArr);
        if (count($multiremindarr['content']) > 0) {
            $multiremindarr['count'] = count($multiremindarr['content']);
            $news_data['news'] = json_encode($multiremindarr, JSON_UNESCAPED_UNICODE);

            //file_put_contents(globalStatic::$root_directory . 'dataCache/weixin/weixin_MessageSend_errorlog.txt', date('Y-m-d H:i:s').': 待办请求数据：'.json_encode($news_data,JSON_UNESCAPED_UNICODE) . "\r\n", FILE_APPEND);

            $errno = $this->newsport->push_news(StaticConst::$server_remindapi, $news_data);
        }


        return $errno;
    }

    /**
     * 工作汇报提醒
     *
     * */
    public function workreport_reminds_aftersave($workreportid)
    {

        if (judgeCorpInfo("install_app")) {

            global $adb;
            $n = $this->newline;
            crm_load_class_file('WorkReportModel', 'modules/Home');
            $this->workmodel = $workobj = new WorkReportModel();
            $workfldarr = $workobj->getWorkCfFieldInfo('workreport');
            $workfldsql = '';

            if (!empty($workfldarr)) {
                $workfldkeyarr = array_keys($workfldarr);
                $workfldsql = ',ld_workreportcf.' . join(',ld_workreportcf.', $workfldkeyarr);
            }


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
                                            ld_users.wx_userid,
                                            ld_workreport.smcreatorid' . $workfldsql . '
                                        FROM ld_workreport
                                        inner join ld_workreport_remind on ld_workreport.workreportid = ld_workreport_remind.relatedto
                                        LEFT JOIN ld_users on ld_users.id = ld_workreport.smcreatorid
                                        LEFT JOIN ld_workreportcf on ld_workreportcf.workreportid = ld_workreport.workreportid
                                        
                                        WHERE length(ld_workreport.entitytype) > 0 AND ld_workreport.workreportid=?';

            $TransforSecondCategory = array(1 => getFixedLabel('JOURNAL'), 2 => getFixedLabel('WEEKPLAN'), 3 => getFixedLabel('MONTHPLAN'));
            $HomeTransfor = array('1' => 'dayreport', '2' => 'weekreport', '3' => 'monthreport');

            $result = $adb->pquery($worksql, array($workreportid));
            $number = $adb->num_rows($result);


            for ($i = 0; $i < $number; $i++) {
                $id = $adb->query_result($result, $i, 'id');
                $relatedto = $adb->query_result($result, $i, 'relatedto');
                $entitytype = $adb->query_result($result, $i, 'entitytype');

                $last_name = $adb->query_result($result, $i, 'last_name');
                $reminder_wx_userid=$adb->query_result($result,$i,'wx_userid');
                $userobj=new Users();
                $userobj->wx_userid=$reminder_wx_userid;
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

                $user_purpose = array();

                //提醒人

                $userresult = $adb->pquery($usersql, array($workreportid));
                $useridexist = array();
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
                            $title[$usertype2] = '工作提醒|有新的' . $secondPara . '需要您点评';
                            $description_mini[$usertype2][0] = array('key'=>'发布人','value'=>$last_name) ;
                            $description_mini[$usertype2][1] = array('key'=>'发布时间','value'=>$createdtime);
                            $description_mini[$usertype2][2] = array('key'=>'内容','value'=>$descriptionW);
                        } elseif ($usertype2 == 6) {
                            $useridexist[$usertype2] = $userid2;
                            $descriptionFinal[$usertype2] = '请于' . $startdate . '之前完成' . $n . '发布人：' . $last_name . $n . '发布时间: ' . $createdtime . $n . $workexperience;
                            $secondLine = '工作提醒|有新的任务需要您执行';
                            $title[$usertype2] = $secondLine;
                            $description_mini[$usertype2][0] = array('key'=>'内容一','value'=>'请于' . $startdate . '之前完成') ;
                            $description_mini[$usertype2][1] = array('key'=>'发布人','value'=>$last_name);
                            $description_mini[$usertype2][2] = array('key'=>'发布时间','value'=>$createdtime);
                            $description_mini[$usertype2][3] = array('key'=>'内容二','value'=>$workexperience);
                        } elseif ($usertype2 == 1 || $usertype2 == 2) {
                            $useridexist[$usertype2] = $userid2;
                            if ($entitytype == 'workreport') {
                                $secondPara = $TransforSecondCategory[$type];
                                $descriptionFinal[$usertype2] = '发布人：' . $last_name . $n . '发布时间: ' . $createdtime . $n . $descriptionW;
                                $description_mini[$usertype2][0] = array('key'=>'发布人','value'=>$last_name) ;
                                $description_mini[$usertype2][1] = array('key'=>'发布时间','value'=>$createdtime);
                                $description_mini[$usertype2][2] = array('key'=>'内容','value'=>$descriptionW);
                            } elseif ($entitytype == 'cocmd') {
                                $secondPara = getFixedLabel('TASK');
                                $descriptionFinal [$usertype2] = '发布人：' . $last_name . $n . '发布时间: ' . $createdtime . $n . $workexperience;
                                $description_mini[$usertype2][0] = array('key'=>'发布人','value'=>$last_name) ;
                                $description_mini[$usertype2][1] = array('key'=>'发布时间','value'=>$createdtime);
                                $description_mini[$usertype2][2] = array('key'=>'内容','value'=>$workexperience);
                            } else {
                                $secondPara = getFixedLabel('BLOG');
                                $descriptionFinal[$usertype2] = '发布人：' . $last_name . $n . '发布时间: ' . $createdtime . $n . $workexperience;
                                $description_mini[$usertype2][0] = array('key'=>'发布人','value'=>$last_name) ;
                                $description_mini[$usertype2][1] = array('key'=>'发布时间','value'=>$createdtime);
                                $description_mini[$usertype2][2] = array('key'=>'内容','value'=>$workexperience);
                            }
                            $modulelabel[$usertype2] = $secondPara;
                            if ($usertype2 == 1) {
                                $title[$usertype2] = '工作提醒|有新的' . $secondPara . '抄送给您';

                            } elseif ($usertype2 == 2) {
                                $title[$usertype2] = '工作提醒|有新的' . $secondPara . '@您';
                            }
                        }
                    }
                }
            }
            $r_multi_content = array();

            foreach ($useridexist as $usertype2 => $userids) {
                $tmpuserids = trim($useridexist[$usertype2], '|');
                if (empty($tmpuserids)) {
                    continue;
                }
                $wxuserids = explode('|', $tmpuserids);
                $tmparray = array();
                $tmparray['userid'] = $wxuserids;
                $tmparray['message'] = $descriptionFinal[$usertype2];
                $tmparray['reltab'] = 'CooperativeWork';
                $tmparray['related_to'] = $workreportid;
                $tmparray['date_time'] = date("Y-m-d H:i:s");
                $tmparray['modulelabel'] = $this->filterstring($modulelabel[$usertype2]);
                $tmparray['entitytype'] = $entitytype;
                $tmparray['title'] = $title[$usertype2];
                $tmparray['message_mini'] = $description_mini[$usertype2];
                $r_multi_content[] = $tmparray;
            }
            if (sizeof($useridexist) > 0) {
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
           
        }
    }


    //工作协同回复，赞等提醒
    public function workreport_reminds_half($workreportid, $relatedto, $type)
    {
        global $adb;
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
                  ld_workreport_remind.remindtype
                FROM ld_workreport
              
                  inner JOIN ld_users A on A.id = ld_workreport.smcreatorid
                 
                ';
        if ($type == 'praise') {
            $worksql .= " inner join ld_praise on ld_praise.workreportid=ld_workreport.workreportid 
                 inner join ld_workreport_remind on ld_workreport_remind.relatedto=ld_praise.praiseid  and relatedtable='praise'  ";

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
        $workobj = new WorkReportModel();
        for ($j = 0; $j < $adb->num_rows($userresult); $j++) {
            $id = $adb->query_result($userresult, $j, 'id');

            $userid = $adb->query_result($userresult, $j, 'userid');

            $operationtype = $adb->query_result($userresult, $j, 'operationtype');
            $content = $adb->query_result($userresult, $j, 'content');
            $wx_userid = $adb->query_result($userresult, $j, 'wx_userid');
            $remindtype = $adb->query_result($userresult, $j, 'remindtype');
            $useridexist[$remindtype][] = $wx_userid;


            $entitytype = $adb->query_result($userresult, 0, 'entitytype');
            $workexperience = $adb->query_result($userresult, 0, 'workexperience');
            $worksummary = $adb->query_result($userresult, 0, 'worksummary');
            $workplan = $adb->query_result($userresult, 0, 'workplan');
            $type = $adb->query_result($userresult, 0, 'type');
            $last_name = $adb->query_result($userresult, 0, 'last_name');
            $reminder_wx_userid=$adb->query_result($userresult, 0, 'wx_userid');
            $userobj=new Users();
            $userobj->last_name=$last_name;
            $userobj->wx_userid=$wx_userid;
            $last_name=getWxMobileRemindInfo($userobj);
            // dump('1q23');
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
                    $description_mini[$remindtype][0] = array('key'=>'发布人','value'=>$last_name) ;
                    $description_mini[$remindtype][1] = array('key'=>'发布时间','value'=>$createdtime);
                    $description_mini[$remindtype][2] = array('key'=>'内容','value'=>$descriptionW);
                } else {
                    $description[$remindtype] = $content . $n . '操作时间：' . $createdtime . $n . $descriptionW;
                    $description_mini[$remindtype][0] = array('key'=>'内容一','value'=>$content) ;
                    $description_mini[$remindtype][1] = array('key'=>'操作时间','value'=>$createdtime);
                    $description_mini[$remindtype][2] = array('key'=>'内容二','value'=>$descriptionW);
                }
            } elseif ($entitytype == 'cocmd') {
                if ($remindtype == 1) {
                    $description[$remindtype] = '请于' . $startdate . '之前完成' . $n . '发布人：' . $last_name . '|' . '发布时间:' . $createdtime . $n;
                    $secondLineM = '有新的任务需要您执行';
                    $description_mini[$remindtype][0] = array('key'=>'内容一','value'=>'请于' . $startdate . '之前完成') ;
                    $description_mini[$remindtype][1] = array('key'=>'发布人','value'=>$last_name);
                    $description_mini[$remindtype][2] = array('key'=>'发布时间','value'=>$createdtime);
                } else {
                    $description[$remindtype] = $content . $n . '操作时间：' . $createdtime . $n;
                    $description_mini[$remindtype][0] = array('key'=>'内容一','value'=>$content) ;
                    $description_mini[$remindtype][1] = array('key'=>'操作时间','value'=>$createdtime);
                }
                $description[$remindtype] = $description[$remindtype] . $workexperience;
                $description_mini[$remindtype][] = array('key'=>'内容二','value'=>$workexperience) ;
            } else {
                $description[$remindtype] = $content . $n . '操作时间：' . $createdtime . $n . $workexperience;
                $description_mini[$remindtype][0] = array('key'=>'内容一','value'=>$content) ;
                $description_mini[$remindtype][1] = array('key'=>'操作时间','value'=>$createdtime);
                $description_mini[$remindtype][2] = array('key'=>'内容二','value'=>$workexperience);
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
            $title[$remindtype] = '工作提醒|' . $secondLineM;
            $modulelabel[$remindtype] = $secondLineM;
        }

        $r_multi_content = array();

        foreach ($useridexist as $usertype2 => $userids) {
            $tmparray = array();
            $tmparray['userid'] = $useridexist[$usertype2];
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
        if (is_array($r_multi_content) && sizeof($r_multi_content[0]) > 1) {
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
    /*
     * zkt
     * 20240902
     * XUQIU20240612-01 企业微信能否屏蔽复制链接地址，可能导致不安全：造成内部别有用心之人将信息推送给竞争对手查阅工作日报
     * 生成code值,后续添加至URL中,在访问后台时实现url判断
     * */
    public static function setClickRemindsCode($crm_directurl,$wx_userid)
    {
        global $adb;
        //增加code
        //精确到秒的时间字段+加密的(url+随机数)
        $time = date("YmdHis");
        $to_encrypt_str = $crm_directurl.time().rand(100000,999999);
        $to_encrypt_str2 = time().rand(100000,999999).$crm_directurl;
        $cls_AESencryptionbykeyobj = cls_AESencryptionbykey::getInstance();
        $cls_AESencryptionbykeyobj->setencryptkey($time);
        $code = $time.md5($cls_AESencryptionbykeyobj->getencryption($to_encrypt_str));
        $localstorage = $time.md5($cls_AESencryptionbykeyobj->getencryption($to_encrypt_str2));


        //获取的code插入数据库
        $query = "insert into ld_click_remind_code_log(wx_userid,crm_directurl,remindscode,remindsstoragecode) values (?,?,?,?)";
        $adb->pquery($query,array($wx_userid,$crm_directurl,$code,$localstorage));
        return $code;
    }


    public function getWeixinAgendaRemindsid($r_weidu_remindsid){
        //变更待办消息的处理状态
        $agenda_remindsid_arr = [];
        if(!empty($r_weidu_remindsid)){
            global $adb;
            $sql = "select tmp.*,ld_approvelog.isfinished from ld_reminds_agenda AS tmp INNER JOIN ld_reminds ON tmp.remindsid = ld_reminds.remindsid 
             LEFT JOIN ld_approvelog ON tmp.approvelogid = ld_approvelog.id
             where tmp.remindsid in(" . $r_weidu_remindsid. ") and  ld_reminds.push_to_weixin = 3";
            $result = $adb->pquery($sql, array());
            $result_arr = $adb->query_result_all($result);

            if (empty($result_arr))  return;
            foreach($result_arr as $tmp_arr){
                if ($tmp_arr['isfinished'] == 'no') {//并发步骤还未审批  不需要转已办
                    continue;
                }
                $tmp_remindsid = $tmp_arr['remindsid'];
                array_push($agenda_remindsid_arr,$tmp_remindsid);

            }

            unset($result,$result_arr);
        }


        return $agenda_remindsid_arr;
    }
    public function UpdateWeixinStatusDone($agenda_remindsid_arr){
        global $adb;
        if (is_array($agenda_remindsid_arr) && count($agenda_remindsid_arr)>0) {
            $sql = 'update ld_reminds set push_to_weixin=?,push_time=? where remindsid in(' . implode(',', $agenda_remindsid_arr) . ')';
            $adb->pquery($sql, array(4, date("Y-m-d H:i:s")));
        }
    }

    //回撤时调用
    public function UpdateWeixinMessageStatus($r_weidu_remindsid){
        //变更待办消息的处理状态
        if(!empty($r_weidu_remindsid)){
            $this->letsbegin();

            $arr = [];
            $arr['corpid'] = $this->newsport->corpid;
            $arr['version'] = $this->newsport->get_server_version();
            $arr['corp_link'] = $this->newsport->corp_link;

            $arr['corpindex'] = $this->newsport->corpindex[StaticConst::$suite_crm];
            $arr['suitename'] = $this->newsport->suitename_coll[StaticConst::$suite_crm];
            $arr['agenda_remindsid_arr'] = $this->getWeixinAgendaRemindsid($r_weidu_remindsid);


            $news_data['update_news'] = json_encode($arr, JSON_UNESCAPED_UNICODE);
            //非即时发送，故无实际接口返回值
            $response = $this->newsport->push_news(strstr(StaticConst::$server_remindapi, '?', true)."?action=update_template_card", $news_data);

            $this->UpdateWeixinStatusDone($arr['agenda_remindsid_arr']);

            //file_put_contents(globalStatic::$root_directory . 'dataCache/weixin/weixin_MessageSend_errorlog.txt', date('Y-m-d H:i:s').': 已办请求数据：'.json_encode($news_data,JSON_UNESCAPED_UNICODE)  . "\r\n", FILE_APPEND);
            //file_put_contents(globalStatic::$root_directory . 'dataCache/weixin/weixin_MessageSend_errorlog.txt', date('Y-m-d H:i:s').': 已办响应数据：'.json_encode($response,JSON_UNESCAPED_UNICODE) . "\r\n", FILE_APPEND);
            unset($news_data,$response);
        }
    }
}

?>