<?php
//致远消息提醒
require_once(globalStatic::$root_directory . 'WeiXinApp/modules/Reminds/MessageCorpconversation.php');

class cls_reminds_zy
{
    protected $eventModel;
//    public $statusRead = ['read'=>1];//已读
//    public $statusProcessed = ['deal'=>1,'read'=>1];//已处理
//    public $statusDeleted = ['delete'=>1];//删除
	public $crm_url;
	public $token;
	public $time;
	public $zhiyuan_url;

    //发消息用的账号密码和系统注册编码
    public $registerCode;
    public $userName;
    public $password;
	public $rRemindType;

	public function __construct()
    {
        global $adb;
        $sql = "select time,para_one,para_content from ld_wx_config where `name`=? and ifnull(para_content,'') <> ''";
        $result = $adb->pquery($sql, array('zhiyuan_setting'));
        if($adb->num_rows($result) > 0){
            $this->time = $adb->query_result($result, 0, 'time');
            $this->token = $adb->query_result($result, 0, 'para_one');
            $para_content = $adb->query_result($result, 0, 'para_content');
            $para_content = Zend_Json::decode($para_content);
            $this->crm_url = rtrim(urldecode($para_content['crm_url']),'/');
            $this->zhiyuan_url = rtrim(urldecode($para_content['zhiyuan_url']),'/');//http://ip:port/seeyon/rest/token/{userName}/{password}
            $this->registerCode = $para_content['registerCode'];
            $this->userName = $para_content['userName'];
            $this->password = $para_content['password'];
        }

	}
    //立即发送所有提醒
    public function sendAllTypeRemindsImmediately($ids, $r_multi_content,$rRemindType='',$rOtherParam=array())
    {
		$this->rRemindType = $rRemindType;
		if(!empty($r_multi_content)){
			foreach($r_multi_content as $key => $info){
                $r_weidu_remindsid = $info['weidu_remindsid'];
                //共享/催审等立即提醒的消息类型没有参received_id,需要增加
				if(!empty($info['received_id'])){
					$zhiyuan_userid = $this->getUserId($info['received_id']);
					if(empty($zhiyuan_userid))continue;
					$info['userid_zhiyuan'] = $zhiyuan_userid;
				}


				$data[$key] = $info;
			}
            //duan 20221205 将更新历史消息状态单独拿出来，避免因为最后一个人的提醒发送失败时，状态未更新的问题
//            $this->UpdateMessageStatus($r_weidu_remindsid,$this->statusProcessed);
            
			if (count($r_multi_content) > 0) {
				return $this->sendReminds($ids, $data);
			}
		}
    }

	public function getUserId($received_id){
		global $adb;
		$sql = 'select GROUP_CONCAT(zhiyuan_userid) from ld_users 
            where id in( ' . $received_id . ') and ifnull(zhiyuan_userid,\'\') <> \'\'  AND push_wx_reminds=1 ';
		$result = $adb->pquery($sql, array());
        $zhiyuan_userid = '';
        if($adb->num_rows($result) > 0){
            $zhiyuan_userid = $adb->query_result($result,0,0);
        }
		return $zhiyuan_userid;
	}

    public function getUserInfo($userid){
        global $adb;
        $sql = 'select last_name,zhiyuan_userid from ld_users 
            where id = ? and ifnull(zhiyuan_userid,\'\') <> \'\'  AND push_wx_reminds=1 ';
        $result = $adb->pquery($sql, array($userid));
        $num_rows = $adb->num_rows($result);
        $userinfo = array();
        if($num_rows > 0){
            $userinfo =  array(
                "last_name"=>$adb->query_result($result,0,'last_name'),
                "zhiyuan_userid"=>$adb->query_result($result,0,'zhiyuan_userid'),
            );
        }
        return $userinfo;

    }
    //发送提醒
    public function sendReminds($ids, $r_multi_content)
    {
        global $adb;
		$zhiyuan = $this->setInstallZy();
		if($zhiyuan){
			if (sizeof($ids) > 0 && $ids[0] > 0) {
				$listKeyIds = $this->sendMessage($ids,$r_multi_content);
				if($this->rRemindType != 'workreport_remind'){
					$idsNew = array();
					$i = 0;
					foreach ($ids as $key=>$value){
						$idsNew[$i] = $value;
                        $i++;
					}
					$sql = 'update ld_reminds set push_to_zy=? ,push_time_zy=? where remindsid in(' . implode(',', $idsNew) . ')';
                     
					$adb->pquery($sql, array(3, date("Y-m-d H:i:s")));
				}
			}
		}
		return $listKeyIds;
    }

    //发送提醒
    protected function sendMessage($ids,$r_multi_content)
    {
        global $adb;
        $this->getTokenCache();
        if (!$this->token) {
            return true;
        }
		$listIds = array();
		if(!empty($ids)){
			//foreach($ids as $key => $remindsid){
				foreach ($r_multi_content as $news_content) {
					$userid_zhiyuan = $news_content['userid_zhiyuan'];
					if (empty($userid_zhiyuan)) {//接收人通讯录账号
						break;
					}
					$r_recieverids = array();
					$massageContent =  $news_content['message'];
					$r_reltab = $news_content['reltab'];
					$r_related_to = $news_content['related_to'];
					$r_date_time = $news_content['date_time'];
					$r_remindtype = $news_content['remindtype'];
					$r_weidu_remindsid = $news_content['weidu_remindsid'];
					if(!empty($news_content['recieverids'])){
						$r_recieverids = $news_content['recieverids'];
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

                    $received_id = $news_content['received_id'];

                    if($news_title=='')
                    {
                        $news_title='消息提醒';
                    }

                    if(in_array($r_remindtype,array('Approve','ExpeditingApprove','ForceAntiApprove','AntiApprove'))){
                        $url = $this->zhiyuan_url."/seeyon/rest/thirdpartyPending/receive?token=".$this->token;

                        $messageUrl = $this->crm_url . '/WeiXinApp/selfbuildSass/' . $location . '?ssotype=zhiyuan&corpurl=' . $this->crm_url . '/'. '&userid=' . $received_id;
                        //echo $messageUrl;echo '<br><br>';die;
                        $newsArr['url'] = "";
                        $newsArr['h5url'] = $messageUrl;


                        $newsArr['taskId'] = $news_content['remindsid'];
                        $newsArr['registerCode'] = $this->registerCode;
//					    $newsArr['content'] = $describ;//原生应用下载地址（仅3和6类型可选）

                        $newsArr['title'] = $news_title;
//                        $tmp_creator_info = $this->getUserInfo($news_content['creator']);
                        $tmp_creator_info = $this->getUserInfo(1);//像企微提醒、自动提醒等是没有创建人概念的，跟苏宁沟通使用系统管理员作为发送人
                        $newsArr['thirdSenderId'] = $tmp_creator_info['zhiyuan_userid'];//待办发起人主键（保证唯一），使用noneBindingSender
                        $newsArr['noneBindingSender'] = $tmp_creator_info['zhiyuan_userid'];//发送人唯一标识
                        $newsArr['senderName'] = $tmp_creator_info['last_name'];//第三方待办发起人姓名

                        $tmp_zhiyuan_userid = $this->getUserId($received_id);
                        $newsArr['thirdReceiverId'] = "";//第三方待办接收人主键（保证唯一），使用noneBindingReceiver，这里保持一致就行；   跟致远开发沟通过需要为空，否则发不出去
                        $newsArr['noneBindingReceiver'] = $tmp_zhiyuan_userid;//接收人唯一标识
                        $newsArr['creationDate'] = date("Y-m-d H:i:s");//待办创建时间（格式：yyyy-MM-dd HH:mm:ss）;

                        $newsArr['state'] = 0;//审批消息暂时都为待办

                        /*if($r_remindtype == 'Approve'){
                            $approveresult = $news_content['approveresult'];
                            if ($approveresult == 1 || $approveresult == 5||$approveresult == 6) {
                                $newsArr['state'] = 0;	//状态：0:未办理；1:已办理
                            }else{
                                $newsArr['state'] = 1;
                            }
                        }else{
                            $newsArr['state'] = 1;
                        }*/

                    }else{
                        $url = $this->zhiyuan_url."/seeyon/rest/thirdpartyMessage/receive/singleMessage?token=".$this->token;

                        $newsArr['thirdpartyMessageId'] = $news_content['remindsid'];
                        $newsArr['thirdpartyRegisterCode'] = $this->registerCode;
                        $newsArr['messageContent'] = $describ;
                        $tmp_creator_info = $this->getUserInfo(1);
//                        $newsArr['thirdpartySenderId'] = $tmp_creator_info['zhiyuan_userid'];//第三方消息发起人主键
                        $newsArr['thirdpartySenderId'] = '';//第三方消息发起人主键
                        $newsArr['noneBindingSender'] = $tmp_creator_info['zhiyuan_userid'];//发送人唯一标识

                        $tmp_zhiyuan_userid = $this->getUserId($received_id);
                        $newsArr['thirdpartyReceiverId'] = $tmp_zhiyuan_userid;//第三方消息接收人主键  这里普通消息跟待办消息不同，这里不能为空
                        $newsArr['noneBindingReceiver'] = $tmp_zhiyuan_userid;//接收人唯一标识
                        $newsArr['creation_date'] = date("Y-m-d H:i:s");//接收人唯一标识
                        $newsArr['messageType'] = 4;//固定4：PC&移动URL接入应用
                    }


					$body = ldcrm_json_encode($newsArr);
					$result = $this->_CurlPost($url,$body);
					$result = json_decode($result);
					//认证失败  token失效
					if($result->errorCode == '1010'){
						$this->getTokenCache('refresh');//致远的人说 token有效期十五分钟
						$this->_CurlPost($url,$body);
					}
					$listIds[$ids[0]] = 1;
				}
//			}
		}

        return $listIds;
    }

	//初始化
	public function setInstallzy(){
		global $adb;
		$query = "select * from ld_wx_config where `name` = 'zhiyuan_setting' and ifnull(para_content,'') <> ''";
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
	
    //获取提醒接口秘钥  有效期15分钟，按十分钟算吧
    public function getTokenCache($rType='')
    {
        global $adb;
        $timeinteval = time() - intval($this->time);
        if ($timeinteval > 600 || $rType=='refresh') {
            $url = $this->zhiyuan_url."/seeyon/rest/token";
			$body = array();
			$body['userName'] = $this->userName;
			$body['password'] = $this->password;

			$body = ldcrm_json_encode($body);
            $result = $this->_CurlPost($url,$body);
            $url_content = json_decode($result, true);
            if (!empty($url_content['id'])) {
                $this->token = $url_content['id'];
                $sql_update = 'update ld_wx_config set para_one=?,time=?,datetime=? where name=?';
                $adb->pquery($sql_update, array($this->token, time(), date('Y-m-d H:i:s', time()), 'zhiyuan_setting'));
                return $this->token;
            } else {
                return false;
            }
        } else {
            return $this->token;
        }
    }
	
	public function _CurlPost($url,$body){
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
	
	private function getUnixTimestamp ()
	{

		list($s1, $s2) = explode(' ', microtime());

		return (float)sprintf('%.0f',(floatval($s1) + floatval($s2)) * 1000);

	}

    //duan 20221205 将更新历史消息状态单独拿出来，避免因为最后一个人的提醒发送失败时，状态未更新的问题
    public function UpdateMessageStatus($r_weidu_remindsid,$actiontype){
        //变更待办消息的处理状态、读状态
        if(!empty($r_weidu_remindsid)){
            global $adb;
            $weidu_remindsid = explode(',',$r_weidu_remindsid);
            /*$this->getTokenCache();
            $url = 'https://yunzhijia.com/gateway/newtodo/open/action.json?accessToken='.$this->token;
            foreach($weidu_remindsid as $id){
                $arr = array();
                $arr['sourceitemid'] = $id;
                $arr['sourcetype'] = $this->appid;
                $arr['actiontype'] = $actiontype;	//deal 目标处理状态，0表示未办，1表示已办，默认为0   read 目标读状态，0表示未读，1表示已读，默认为0
                $arr['sync'] = 'false';
                $arr_json = ldcrm_json_encode($arr);
                $this->_CurlGet($url,$arr_json);
            }*/
            //duan 20231128 将已经更新为已办的提醒记录为4 ,避免重复请求
            $sql = 'update ld_reminds set push_to_zy=? where remindsid in(' . $r_weidu_remindsid. ')';
            $adb->pquery($sql, array(4));
        }
    }

}