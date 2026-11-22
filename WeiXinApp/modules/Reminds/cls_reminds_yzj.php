<?php
//云之家消息提醒
require_once(globalStatic::$root_directory . 'WeiXinApp/modules/Reminds/MessageCorpconversation.php');

class cls_reminds_yzj 
{
    protected $eventModel;
    public $statusRead = ['read'=>1];//已读
    public $statusProcessed = ['deal'=>1,'read'=>1];//已处理
    public $statusDeleted = ['delete'=>1];//删除
	public $crm_url;
	public $appid;
	public $rRemindType;
    public $token;
    public $appname;

	public function __construct()
    {

	}
    //立即发送所有提醒
    public function sendAllTypeRemindsImmediately($ids, $r_multi_content,$rRemindType='',$rOtherParam=array())
    {
		$this->rRemindType = $rRemindType;
		if(!empty($r_multi_content)){
			foreach($r_multi_content as $key => $info){
                $r_weidu_remindsid = $info['weidu_remindsid'];
				if(!empty($info['received_id'])){
					$openid = $this->getUserOpenid($info['received_id']);
					if(empty($openid))continue;
					$info['userid_openid'] = $openid;
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
	
	//获取用户的openid
	public function getUserOpenid($received_id){
		global $adb;
		$sql = 'select GROUP_CONCAT(yunzhijia_openid) from ld_users 
            where id in( ' . $received_id . ') and ifnull(yunzhijia_openid,\'\') <> \'\'  AND push_wx_reminds=1 ';
		$result = $adb->pquery($sql, array());
		return $adb->query_result($result,0,0);
	}
    //发送提醒,包含企业微信和钉钉提醒
    public function sendReminds($ids, $r_multi_content)
    {
        global $adb;
		$yunzhijia = $this->setInstallYzj();
		if($yunzhijia){
			if (sizeof($ids) > 0 && $ids[0] > 0) {
				$listKeyIds = $this->sendMessage($ids,$r_multi_content);
				if($this->rRemindType != 'workreport_remind'){
					$idsNew = array();
					$i = 0;
					foreach ($ids as $key=>$value){
						$idsNew[$i] = $value;
                        $i++;
					}
					$sql = 'update ld_reminds set push_to_yzj=? ,push_time_yzj=? where remindsid in(' . implode(',', $idsNew) . ')';
                     
					$adb->pquery($sql, array(3, date("Y-m-d H:i:s")));
				}
			}
		}
		return $listKeyIds;
    }

    //发送钉钉提醒
    protected function sendMessage($ids,$r_multi_content)
    {
        global $adb;
        $token = $this->getTokenCache();
        if (!$token) {
            return true;
        }
		$listIds = array();
		if(!empty($ids)){
			foreach($ids as $key => $remindsid){
				foreach ($r_multi_content as $news_content) {
					$userid_openid = $news_content['userid_openid'];
					if (empty($userid_openid)) {
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
						if(empty($news_content['modulelabel'])){
							$modulelabel = $title;
						}
						else{
							$modulelabel = $news_content['modulelabel'];
						}

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
					$userid_array = explode(',',$news_content['received_id']);
					$userid_userid = $userid_array[$key];
					$url = 'https://yunzhijia.com/gateway/newtodo/open/generatetodo.json?accessToken='.$token;
					$messageUrl = $this->crm_url . '/WeiXinApp/yunzhijia/websaas/' . $location . '?corpid=' . $this->appid . '&corpurl=' . $this->crm_url . '/'. '&userid=' . $userid_userid;
					//echo $messageUrl;echo '<br><br>';die;
					$newsArr['url'] = $messageUrl;
					$openid_array = !is_array($userid_openid)?explode(',',$userid_openid):$userid_openid;//云之家移动端没有收到工作汇报【点赞】消息提醒
					if(!isset($openid_array[$key]))
                        break;
                    $openid = $openid_array[$key];
					$params[0] = array('openId'=>$openid);
					//$openid = '5f7fffa7e4b08696ee72f129';
					/*foreach($openid_array as $key => $id){
						$params[$key] = array('openId'=>$id);
					}*/
					$newsArr['sourceId'] = $remindsid;
					//$newsArr['sourceId'] = $r_related_to.'_'.$ids[0].mt_rand(0,1000);
					$newsArr['content'] = $describ;
					if(!empty($this->appname)){
						$newsArr['title'] = $this->appname;
					}else{
						$newsArr['title'] = 'CRM';
					}
                    if($news_title=='')
                    {
                        $news_title='消息提醒';
                    }
					$newsArr['itemtitle'] = $news_title;
					$newsArr['headImg'] = '';
					$newsArr['appId'] = $this->appid;
					$newsArr['senderId'] = $openid;
					$newsArr['params'] = $params;
					$newsArr['openId'] = $openid;
					$newsArr['sync'] = 'false';

					if($r_remindtype == 'Approve'){
						$approveresult = $news_content['approveresult'];
						/*if ($approveresult == 3 || $approveresult == 4) { //拒绝、驳回配合提醒类型
							$remindType = 2;
						} elseif ($approveresult == 2) { // 批准配合提醒类型
							$remindType = 1;
						} elseif ($approveresult == 1 || $approveresult == 5||$approveresult == 6) {   //审批中配合提醒类型
							$remindType = 0;
						}*/
						if ($approveresult == 1 || $approveresult == 5||$approveresult == 6) {
							$newsArr['todoType'] =1;	//待办类型: 0:待阅(通知);1:待审批(待办);
						}else{
							$newsArr['todoType'] = 0;
						}
					}else{
						$newsArr['todoType'] = 0;
					}
					$body = ldcrm_json_encode($newsArr);
					$result = $this->_CurlGet($url,$body);
					$result = json_decode($result);

					//认证失败  token失效
					if($result->errorCode == '10000401'){
						$token = $this->getTokenCache('refresh');
						$url = 'https://yunzhijia.com/gateway/newtodo/open/generatetodo.json?accessToken='.$token;
                        $result = $this->_CurlGet($url,$body);
                        $result = json_decode($result);
					}

                    if ($result->errorCode != '0') {
                        file_put_contents(globalStatic::$root_directory . 'dataCache/weixin/yunzhijia_MessageSend_errorlog.txt', date('Y-m-d H:i:s').': 待办请求数据(错误)：'.$body,JSON_UNESCAPED_UNICODE . "\r\n", FILE_APPEND);
                        file_put_contents(globalStatic::$root_directory . 'dataCache/weixin/yunzhijia_MessageSend_errorlog.txt', date('Y-m-d H:i:s').': 待办响应数据(错误)：'.json_encode($result,JSON_UNESCAPED_UNICODE) . "\r\n", FILE_APPEND);
                    }

					$listIds[$ids[0]] = 1;
				}
			}
		}
        /*foreach ($r_multi_content as $key => $news_content) {
            $userid_openid = $news_content['userid_openid'];
            if (empty($userid_openid)) {
                break;
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
				$listtype = 'list';
            } elseif ($r_reltab == 'Users') {
                //指向成员详情界面的提醒，由于企业微信没做成员详情模块，现将关联模块是用户的提醒，不赋值跳转链接，禁止消息穿透
                $news_title = '消息提醒';
                $listtype = 'list';
                $r_related_to = '';
            } else {
                if ($r_remindtype == 'massallocate' || $r_remindtype == 'massshare') {
                    $news_title = '消息提醒';
                } elseif ($r_remindtype == 'Approve') {
                    $listtype = 'approvelist';	//approvelist
                    $news_title = '审批提醒';
                } else {
                    $news_title = '消息提醒';
                    $listtype = 'list';
                }
            }
            $describ = str_replace('&#039;', '\'', htmlspecialchars_decode(html_entity_decode($massageContent)));
            $newsArr = array();//消息体
			$describ = strip_tags(str_replace('"', '\"', $describ), '');
			$describ = str_replace('<br>', PHP_EOL, $describ);
            if (!empty($r_related_to) && empty($location)) {
                $modulelabel = urlencode(getTranstab($r_reltab));
                $location = 'ldcrm/index.html#!/detailview/' . $r_reltab . '/' . $r_related_to . '/' . $modulelabel . '/' . $listtype . '/no/-1';
            } elseif (empty($r_related_to)) {
                //CRM端没有指向的消息提醒或企业微信端还没做跳转的提醒，给它跳转到应用首页  2019/5/29 17:44 0037105
                $location = 'ldcrm/index.html#!/';
            }
			$url = 'https://yunzhijia.com/gateway/newtodo/open/generatetodo.json?accessToken='.$token;
            $messageUrl = $this->crm_url . '/WeiXinApp/yunzhijia/websaas/' . $location . '?corpid=' . $this->appid . '&corpurl=' . $this->crm_url . '/';
			//echo $messageUrl;echo '<br><br>';die;
            $newsArr['url'] = $messageUrl;
			$openid_array = explode(',',$userid_openid);
			$openid = $openid_array[0];
			//$openid = '5f7fffa7e4b08696ee72f129';
			foreach($openid_array as $key => $id){
				$params[$key] = array('openId'=>$id);
			}
			if(!empty($news_content['remindsid'])){
				$newsArr['sourceId'] = $news_content['remindsid'];
			}else{
				$newsArr['sourceId'] = $r_related_to.'_'.$ids[0].mt_rand(0,1000);
			}
            
            $newsArr['content'] = $describ;
			if(!empty($this->appname)){
				$newsArr['title'] = $this->appname;
			}else{
				$newsArr['title'] = 'CRM';
			}
            
			$newsArr['itemtitle'] = $news_title;
			$newsArr['headImg'] = '';
			$newsArr['appId'] = $this->appid;
			$newsArr['senderId'] = $openid;
			$newsArr['params'] = $params;
			$newsArr['openId'] = $openid;
			$newsArr['sync'] = 'false';
			if($r_remindtype == 'Approve'){
				$approveresult = $news_content['approveresult'];
				/*if ($approveresult == 3 || $approveresult == 4) { //拒绝、驳回配合提醒类型
					$remindType = 2;
				} elseif ($approveresult == 2) { // 批准配合提醒类型
					$remindType = 1;
				} elseif ($approveresult == 1 || $approveresult == 5||$approveresult == 6) {   //审批中配合提醒类型
					$remindType = 0;
				}*/
				/*if ($approveresult == 1 || $approveresult == 5||$approveresult == 6) {
					$newsArr['todoType'] =1;	//待办类型: 0:待阅(通知);1:待审批(待办);
				}else{
					$newsArr['todoType'] = 0;
				}
			}else{
				$newsArr['todoType'] = 0;
			}
			$body = ldcrm_json_encode($newsArr);
			$result = $this->_CurlGet($url,$body);
			$result = json_decode($result);
			//认证失败  token失效
            if($result->errorCode == '10000401'){
				$token = $this->getTokenCache('refresh');
                $url = 'https://yunzhijia.com/gateway/newtodo/open/generatetodo.json?accessToken='.$token;
                $this->_CurlGet($url,$body);
            }
            $listIds[$ids[0]] = 1;
        }*/
        return $listIds;
    }

	//初始化云之家 - 判断是会否安装云之家
	public function setInstallYzj(){
		global $adb;
		$query = "select * from ld_wx_config where `name` = 'yunzhijia_setting' and para_content <> ''";
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
	
    //获取提醒接口秘钥
    public function getTokenCache($rType='')
    {
        global $adb;
        if(!empty($this->token) && $rType != 'refresh')
        {
            return $this->token;
        }
        $sql = 'select time,datetime,para_one,para_content from ld_wx_config where name=?';
        $result = $adb->pquery($sql, array('yunzhijia_setting'));
        $time = $adb->query_result($result, 0, 'time');
        $datetime = $adb->query_result($result, 0, 'datetime');
        $token = $adb->query_result($result, 0, 'para_one');
		$para_content = $adb->query_result($result, 0, 'para_content');
		$para_content = Zend_Json::decode($para_content);
		$this->crm_url = urldecode($para_content['login_url']);
		$this->appid = $para_content['login_appid'];
		$this->appname = $para_content['login_appname'];
        $timeinteval = time() - intval($time);
        if ($timeinteval > 6000 || $rType=='refresh') {
			$url = 'https://yunzhijia.com/gateway/oauth2/token/getAccessToken';
			$unixtimestamp = $this->getUnixTimestamp();
			$body = array();
			$body['appId'] = $para_content['login_appid'];
			$body['secret'] = $para_content['login_secret'];
			$body['timestamp'] = $unixtimestamp;
			$body['scope'] = 'app';
			$body = ldcrm_json_encode($body);
            $result = $this->_CurlGet($url,$body);
            $url_content = json_decode($result, true);
            if (!empty($url_content['data']) && $url_content['errorCode'] === 0) {
                $token = $url_content['data']['accessToken'];
                $sql_update = 'update ld_wx_config set para_one=?,time=?,datetime=? where name=?';
                $adb->pquery($sql_update, array($token, time(), date('Y-m-d H:i:s', time()), 'yunzhijia_setting'));
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
            $token = $this->getTokenCache();
            $weidu_remindsid = explode(',',$r_weidu_remindsid);
            $url = 'https://yunzhijia.com/gateway/newtodo/open/action.json?accessToken='.$token;
            $success_arr = [];
            $error_arr = [];
            foreach($weidu_remindsid as $id){
                $arr = array();
                $arr['sourceitemid'] = $id;
                $arr['sourcetype'] = $this->appid;
                $arr['actiontype'] = $actiontype;	//deal 目标处理状态，0表示未办，1表示已办，默认为0   read 目标读状态，0表示未读，1表示已读，默认为0
                $arr['sync'] = 'true';
                $arr_json = ldcrm_json_encode($arr);
                $result = $this->_CurlGet($url,$arr_json);
                $result_arr = json_decode($result,true);

                //认证失败  token失效
                if ($result_arr['errorCode'] == '10000401') {
                    $token = $this->getTokenCache('refresh');
                    $url = 'https://yunzhijia.com/gateway/newtodo/open/action.json?accessToken='.$token;
                    $result = $this->_CurlGet($url,$arr_json);
                    $result_arr = json_decode($result,true);
                }
                //200表示为调用成功
                if($result_arr['errorCode'] == 200){
                    $success_arr[] = $id;
                }else{
                    $error_arr[] = $id;
                    file_put_contents(globalStatic::$root_directory . 'dataCache/weixin/yunzhijia_MessageSend_errorlog2.txt', date('Y-m-d H:i:s').': 已办请求数据(错误)：'.$arr_json . "\r\n", FILE_APPEND);
                    file_put_contents(globalStatic::$root_directory . 'dataCache/weixin/yunzhijia_MessageSend_errorlog2.txt', date('Y-m-d H:i:s').': 已办响应数据(错误)：'.json_encode($result_arr,JSON_UNESCAPED_UNICODE) . "\r\n", FILE_APPEND);
                }
            }
            //duan 20241030 记录调用失败的id再次调用
            foreach($error_arr as $id){
                $arr = array();
                $arr['sourceitemid'] = $id;
                $arr['sourcetype'] = $this->appid;
                $arr['actiontype'] = $actiontype;	//deal 目标处理状态，0表示未办，1表示已办，默认为0   read 目标读状态，0表示未读，1表示已读，默认为0
                $arr['sync'] = 'true';
                $arr_json = ldcrm_json_encode($arr);
                $result = $this->_CurlGet($url,$arr_json);

                $result_arr = json_decode($result,true);
                if($result_arr['errorCode'] == 200){
                    $success_arr[] = $id;
                }
            }

            if(sizeof($success_arr)>0){
                //duan 20231128 将已经更新为已办的提醒记录为4 ,避免重复请求
                $sql = 'update ld_reminds set push_to_yzj=? where remindsid in(' . implode(',',$success_arr). ')';
                $adb->pquery($sql, array(4));
            }

        }
    }


}