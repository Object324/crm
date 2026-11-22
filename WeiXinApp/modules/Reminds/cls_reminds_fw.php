<?php
//ls 20221025 XUQIU1000796    泛微电脑端审批消息推送开发
//泛微消息提醒
//require_once(globalStatic::$root_directory . 'WeiXinApp/modules/Reminds/MessageCorpconversation.php');

class cls_reminds_fw
{
    public $syscode;
    public $fanwei_url;
    public $processdone_url;
    public $appid;
    public $rRemindType;
    public function __construct()
    {
        global $adb;
        $result = $adb->pquery('select para_one,para_two,para_three from ld_wx_config where name = ?',array('fanwei_setting'));
        if($adb->num_rows($result) > 0){
            $this->syscode = $adb->query_result($result,0,'para_one');
            $this->fanwei_url = $adb->query_result($result,0,'para_two');
            $this->processdone_url = $adb->query_result($result,0,'para_three');
        }else{
            $adb->pquery("insert into ld_wx_config (name,description) select 'fanwei_setting','泛微设置' from dual where not exists(select 1 from ld_wx_config where name='fanwei_setting');",array());
        }
    }
    //立即发送所有提醒
    public function sendAllTypeRemindsImmediately($ids, $r_multi_content,$rRemindType='',$rOtherParam=array())
    {
        global $adb;
        $this->rRemindType = $rRemindType;
        if(!empty($r_multi_content)){
            foreach($r_multi_content as $key => $info){
                $userid_mobile_info = [];
                if(!empty($info['received_id'])){
                    $sql = 'select id,phone_mobile from ld_users 
            where id in( ' . $info['received_id'] . ')   AND push_wx_reminds=1 ';
                    $result = $adb->pquery($sql, array());
                    for ($i = 0; $i < $adb->num_rows($result); $i++) {
                        $userid = $adb->query_result($result,$i,'id');
                        $mobile = $adb->query_result($result,$i,'phone_mobile');
                        $userid_mobile_info[$userid] = $mobile;//接收人id  和  手机号要对应起来
                    }

//					$mobile = $this->getUserMobile($info['received_id']);
                    if(empty(array_values($userid_mobile_info))) continue;
                    $info['userid_mobile_arr'] = array_unique($userid_mobile_info);
                }
                if(!empty($info['creator'])){
                    $creator_mobile = $this->getUserMobile($info['creator']);
                    if(empty($creator_mobile))continue;
                    $info['creator_mobile'] = $creator_mobile;
                }

                $data[$key] = $info;
            }
            if (count($r_multi_content) > 0) {
                return $this->sendReminds($ids, $data);
            }
        }
    }

    //获取用户的手机号
    public function getUserMobile($received_id){
        global $adb;
        $sql = 'select GROUP_CONCAT(phone_mobile) from ld_users 
            where id in( ' . $received_id . ') and ifnull(phone_mobile,\'\') <> \'\'  AND push_wx_reminds=1 ';
        $result = $adb->pquery($sql, array());
        return $adb->query_result($result,0,0);
    }
    //发送提醒,包含企业微信和钉钉提醒
    public function sendReminds($ids, $r_multi_content)
    {
        global $adb;
        $fw = $this->setInstallFw();
        if($fw){
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

    //发送泛微提醒
    protected function sendMessage($ids,$r_multi_content)
    {
        global $adb;
        $syscode = $this->syscode;
        if (!$syscode) {
            return true;
        }
        $listIds = array();
        if(!empty($ids)){
            foreach ($r_multi_content as $key=>$news_content) {
                $userid_mobile_arr = $news_content['userid_mobile_arr'];//接收人手机号
                if (!is_array($userid_mobile_arr) || empty($userid_mobile_arr)) {
                    continue;
                }
                $r_recieverids = array();
                $massageContent =  $news_content['message'];
                $r_reltab = $news_content['reltab'];
                $r_related_to = $news_content['related_to'];
                $r_date_time = $news_content['date_time'];
                $r_remindtype = $news_content['remindtype'];
                if(!empty($news_content['recieverids'])){
                    $r_recieverids = $news_content['recieverids'];
                }

                $related_to_str = '';
                if ($r_reltab == 'Users') {
                    //指向成员详情界面的提醒，由于企业微信没做成员详情模块，现将关联模块是用户的提醒，不赋值跳转链接，禁止消息穿透
                    $news_title = '消息提醒';
                    $listtype = 'list';
                    $r_related_to = '';
                } else {
                    if ($r_remindtype == 'Approve'|| $r_remindtype == 'ExpeditingApprove') {
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
                        $massageContent .= " \r\n".$related_to_str;
                    }
                }
                $describ = str_replace('&#039;', '\'', htmlspecialchars_decode(html_entity_decode($massageContent)));
                $newsArr = array();//消息体
                $describ = str_replace('<br>', PHP_EOL, $describ);
                $describ = strip_tags(str_replace('"', '\"', $describ), '');

                //先将已审批的单据从待办改为已办
                $yiban_sql = "select tmp.* from ld_tmp_reminds_agenda AS tmp LEFT JOIN ld_reminds ON tmp.remindsid = ld_reminds.remindsid where tmp.crmid = ? and tmp.status = '未发送'";
                $yiban_sql .= " union SELECT tmp.* from ld_tmp_reminds_agenda AS tmp LEFT JOIN ld_reminds_accepted ON tmp.remindsid = ld_reminds_accepted.remindsid where tmp.crmid = ? and tmp.status = '未发送'";
                $yiban_result = $adb->pquery($yiban_sql, array($r_related_to,$r_related_to));
                $yiban_num_rows = $adb->num_rows($yiban_result);

                //注释的代码是调试使用,可以将未发送的再发一次 转为已办
                /*$yiban_sql = "select tmp.* from ld_tmp_reminds_agenda AS tmp left JOIN ld_reminds ON tmp.remindsid = ld_reminds.remindsid where tmp.status = '未发送'";
                $yiban_sql .= " union SELECT tmp.* from ld_tmp_reminds_agenda AS tmp left JOIN ld_reminds_accepted ON tmp.remindsid = ld_reminds_accepted.remindsid where tmp.status = '未发送'";
                $yiban_result = $adb->pquery($yiban_sql, array());*/

                if ($yiban_num_rows >= 1) {
                    for($i = 0; $i<$yiban_num_rows; $i++)
                    {
                        $yiban_agendaid = $adb->query_result($yiban_result, $i, "agendaid");
                        $yiban_remindsid = $adb->query_result($yiban_result, $i, "remindsid");
                        $yibanArr['syscode'] = $adb->query_result($yiban_result, $i, "syscode");
                        $yibanArr['flowid'] = $adb->query_result($yiban_result, $i, "flowid");
                        $yibanArr['requestname']= $adb->query_result($yiban_result, $i, "requestname");
                        $yibanArr['workflowname']= $adb->query_result($yiban_result, $i, "workflowname");
                        $yibanArr['nodename']= $adb->query_result($yiban_result, $i, "nodename");
                        $yibanArr['pcurl']= htmlspecialchars_decode($adb->query_result($yiban_result, $i, "pcurl"));
                        $yibanArr['appurl']= $adb->query_result($yiban_result, $i, "appurl");
                        $yibanArr['receiver']= str_replace(' ','',$adb->query_result($yiban_result, $i, "receiver"));

                        $yiban_body = ldcrm_json_encode($yibanArr);
                        $yiban_return_result = $this->_CurlGet($this->processdone_url,$yiban_body);
                        $yiban_return_result = json_decode($yiban_return_result,true);//数组形式

                        //删除对应的临时表
                        if ($yiban_return_result['operResult'] == '1') {//成功
                            $adb->pquery('delete from ld_tmp_reminds_agenda where agendaid = ?', array($yiban_agendaid));
//                            $adb->pquery('update ld_tmp_reminds_agenda SET status=?,returnResult=? where agendaid = ?', array('发送成功',json_encode($yiban_return_result,JSON_UNESCAPED_UNICODE),$yiban_agendaid));
                        }else{
                            $adb->pquery('update ld_tmp_reminds_agenda SET status=?,returnResult=? where agendaid = ?', array('已发送',json_encode($yiban_return_result,JSON_UNESCAPED_UNICODE),$yiban_agendaid));
                        }

                    }

                    //{"syscode":"xtxccrm","operResult":"0","dataType":"WfData","operType":"Check","message":"调用接口并发过高，1000ms内禁止syscode + flowid + receiver相同的流程调用接口 "}
                    //因此需要间隔一秒  // 休息1.1秒（1100000 微秒）
                    usleep(1100000);

                }


                foreach($userid_mobile_arr as $tmp_userid=>$tmp_mobile) {
                    if (empty($tmp_mobile)) continue;
//                    $url = 'http://218.28.182.50:8071/rest/ofs/ReceiveRequestInfoByJson';//泛微地址
                    $url = $this->fanwei_url;//泛微地址

                    crm_load_class_file('cls_MyCRMcrypt',"Register");
                    $cls_MyCRMcryptobj=new cls_MyCRMcrypt();
                    $encrypt_userid = $cls_MyCRMcryptobj->encode($tmp_userid);

                    $redirect_uri = 'index.php?pageto_module='.$r_reltab.'&pageto_action=index&pageto_record='.$r_related_to;//相对路径(PC端)
                    $redirect_uri = urlencode($redirect_uri);
                    $messageUrl = 'FanweiLogin.php?userid='.$encrypt_userid.'&redirect_uri='.$redirect_uri;
                    //echo $messageUrl;echo '<br><br>';die;

                    $newsArr['syscode'] = $syscode;
                    $newsArr['flowid'] = $news_content['remindsid'];//主键不重复就行  可以使用remindsid
                    $newsArr['requestname'] = $describ;
                    $newsArr['workflowname'] = getTranstab($r_reltab);//TODO
                    $newsArr['nodename'] = $news_title;//TODO
                    $newsArr['pcurl'] = $messageUrl;
                    $newsArr['appurl'] = "";
                    $newsArr['isremark'] = "0";
                    $newsArr['viewtype'] = "0";
                    $newsArr['creator'] = $news_content['creator_mobile'];//创建人手机号
                    $newsArr['createdatetime'] = $news_content['date_time'];
                    $newsArr['receiver'] = str_replace(' ','',$tmp_mobile);//接收人手机号（逗号隔开），由于接收人消息需要带上userid，因此需要每个接收人单独发送
                    $newsArr['receivedatetime'] = date("Y-m-d H:i:s");
//                    $newsArr['requestlevel'] = '0';//紧急程度（非必传）0：正常、1：重要、2：紧急


                    if(in_array($r_remindtype,array('Approve','ExpeditingApprove','ForceAntiApprove','AntiApprove'))){//审批消息时  实际上要发送的消息都是审批消息,可以去掉if判断
                        $tmp_focus = CRMEntity::getInstance($r_reltab);
                        $sql1='select '.$tmp_focus->getApproveStatusColumnName().' from '.$tmp_focus->table_name.'  where '.$tmp_focus->table_index.'=?';

//                        $sql1 = "select approveresult from ld_approvelog where crmid = ? order by id desc limit 0,1";//createdtime可能会相同，故加上id排序
                        $result1=$adb->pquery($sql1,array($r_related_to));
                        if ($adb->num_rows($result1) > 0) {
                            $approveresult = $adb->query_result($result1,0,0);
//                            if (in_array($approveresult,array("0","2","3","4")) ) {//2 审批成功，结束流程; 3 审批失败，结束流程,此时为已办
                            if (in_array($approveresult,array("已批准","已拒绝","已驳回")) ) {//从审批日志获取审批状态改为从单据获取
                                $newsArr['isremark'] = "2";	//流程处理状态  0：待办 2：已办 4：办结

                                //保险起见，再次处理一下，后期没有bug的话就可以去掉了
                                //先将已审批的单据从待办改为已办
                                $yiban_sql = "select tmp.* from ld_tmp_reminds_agenda AS tmp LEFT JOIN ld_reminds ON tmp.remindsid = ld_reminds.remindsid where tmp.crmid = ? and tmp.status = '未发送'";
                                $yiban_sql .= " union SELECT tmp.* from ld_tmp_reminds_agenda AS tmp LEFT JOIN ld_reminds_accepted ON tmp.remindsid = ld_reminds_accepted.remindsid where tmp.crmid = ? and tmp.status = '未发送'";
                                $yiban_result = $adb->pquery($yiban_sql, array($r_related_to,$r_related_to));
                                $yiban_num_rows = $adb->num_rows($yiban_result);
                                if ($yiban_num_rows >= 1) {
                                    for($i = 0; $i<$yiban_num_rows; $i++)
                                    {
                                        $yiban_agendaid = $adb->query_result($yiban_result, $i, "agendaid");
                                        $yiban_remindsid = $adb->query_result($yiban_result, $i, "remindsid");
                                        $yibanArr['syscode'] = $adb->query_result($yiban_result, $i, "syscode");
                                        $yibanArr['flowid'] = $adb->query_result($yiban_result, $i, "flowid");
                                        $yibanArr['requestname']= $adb->query_result($yiban_result, $i, "requestname");
                                        $yibanArr['workflowname']= $adb->query_result($yiban_result, $i, "workflowname");
                                        $yibanArr['nodename']= $adb->query_result($yiban_result, $i, "nodename");
                                        $yibanArr['pcurl']= htmlspecialchars_decode($adb->query_result($yiban_result, $i, "pcurl"));
                                        $yibanArr['appurl']= $adb->query_result($yiban_result, $i, "appurl");
                                        $yibanArr['receiver']= str_replace(' ','',$adb->query_result($yiban_result, $i, "receiver"));

                                        $yiban_body = ldcrm_json_encode($yibanArr);
                                        $yiban_return_result = $this->_CurlGet($this->processdone_url,$yiban_body);
                                        $yiban_return_result = json_decode($yiban_return_result,true);//数组形式

                                        //删除对应的临时表
                                        if ($yiban_return_result['operResult'] == '1') {//成功
                                            $adb->pquery('delete from ld_tmp_reminds_agenda where agendaid = ?', array($yiban_agendaid));
                                        }else{
                                            $adb->pquery('update ld_tmp_reminds_agenda SET status=?,returnResult=? where agendaid = ?', array('已发送',json_encode($yiban_return_result,JSON_UNESCAPED_UNICODE),$yiban_agendaid));
                                        }

                                    }

                                    usleep(1100000);
                                }

                            }
                        }
                    }

                    $body = ldcrm_json_encode($newsArr);
                    $result = $this->_CurlGet($url,$body);
                    $result = json_decode($result,true);//数组形式

                    //发送成功后插入临时待办表，且审批流程未结束时插入
                    if ($result['operResult'] == '1' && $newsArr['isremark'] == '0') {
                        $inser_sql = "insert into ld_tmp_reminds_agenda(remindsid,crmid,syscode,flowid,requestname,workflowname,nodename,pcurl,appurl,receiver) VALUES (?,?,?,?,?,?,?,?,?,?)";
                        $params = array($newsArr['flowid'],$r_related_to,$newsArr['syscode'],$newsArr['flowid'],$newsArr['requestname'],$newsArr['workflowname'],$newsArr['nodename'],$newsArr['pcurl'],$newsArr['appurl'],$newsArr['receiver']);
                        $adb->pquery($inser_sql, $params);
                    }

                }

                $listIds[$ids[$key]] = 1;
            }
		}

        return $listIds;
    }

	public function setInstallFw(){
		global $adb;
		$query = "select * from ld_wx_config where `name` = 'fanwei_setting' and ifnull(para_one,'') <> '' and ifnull(para_two,'') <> '' ";
		$result = $adb->pquery($query,array());
		$num_rows = $adb->num_rows($result);
		if($num_rows >= 1){
			return true;
		}else{
			return false;
		}
	}

    //更新为已办   回撤(反审批时)，不会发送消息，因此不会触发流程已办更新
    public function UpdateMessageStatus($r_related_to){
        global $adb;
        //先将已审批的单据从待办改为已办
        $yiban_sql = "select tmp.* from ld_tmp_reminds_agenda AS tmp LEFT JOIN ld_reminds ON tmp.remindsid = ld_reminds.remindsid where tmp.crmid = ? and tmp.status = '未发送'";
        $yiban_sql .= " union SELECT tmp.* from ld_tmp_reminds_agenda AS tmp LEFT JOIN ld_reminds_accepted ON tmp.remindsid = ld_reminds_accepted.remindsid where tmp.crmid = ? and tmp.status = '未发送'";
        $yiban_result = $adb->pquery($yiban_sql, array($r_related_to,$r_related_to));
        $yiban_num_rows = $adb->num_rows($yiban_result);
        if ($yiban_num_rows >= 1) {
            for($i = 0; $i<$yiban_num_rows; $i++)
            {
                $yiban_agendaid = $adb->query_result($yiban_result, $i, "agendaid");
                $yiban_remindsid = $adb->query_result($yiban_result, $i, "remindsid");
                $yibanArr['syscode'] = $adb->query_result($yiban_result, $i, "syscode");
                $yibanArr['flowid'] = $adb->query_result($yiban_result, $i, "flowid");
                $yibanArr['requestname']= $adb->query_result($yiban_result, $i, "requestname");
                $yibanArr['workflowname']= $adb->query_result($yiban_result, $i, "workflowname");
                $yibanArr['nodename']= $adb->query_result($yiban_result, $i, "nodename");
                $yibanArr['pcurl']= htmlspecialchars_decode($adb->query_result($yiban_result, $i, "pcurl"));
                $yibanArr['appurl']= $adb->query_result($yiban_result, $i, "appurl");
                $yibanArr['receiver']= str_replace(' ','',$adb->query_result($yiban_result, $i, "receiver"));

                $yiban_body = ldcrm_json_encode($yibanArr);
                $yiban_return_result = $this->_CurlGet($this->processdone_url,$yiban_body);
                $yiban_return_result = json_decode($yiban_return_result,true);//数组形式

                //删除对应的临时表
                if ($yiban_return_result['operResult'] == '1') {//成功
                    $adb->pquery('delete from ld_tmp_reminds_agenda where agendaid = ?', array($yiban_agendaid));
                }else{
                    $adb->pquery('update ld_tmp_reminds_agenda SET status=?,returnResult=? where agendaid = ?', array('已发送',json_encode($yiban_return_result,JSON_UNESCAPED_UNICODE),$yiban_agendaid));
                }

            }

            usleep(1100000);
        }
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

}