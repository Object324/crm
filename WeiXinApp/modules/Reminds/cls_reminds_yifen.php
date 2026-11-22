<?php
//ls 20221025 XUQIU1000796    泛微电脑端审批消息推送开发
//泛微消息提醒
//require_once(globalStatic::$root_directory . 'WeiXinApp/modules/Reminds/MessageCorpconversation.php');

class cls_reminds_yifen
{
 
	public $yifen_url,$yifen_delurl,$yifen_readurl;
	public $appid;
	public $rRemindType;
	public function __construct()
    {
        
        $this->yifen_url='http://oa.zyfchina.com/api/sys-notify/sysNotifyTodoRestService/sendTodo';
        $this->yifen_delurl='http://oa.zyfchina.com/api/sys-notify/sysNotifyTodoRestService/deleteTodo';
		$this->yifen_readurl='http://oa.zyfchina.com/api/sys-notify/sysNotifyTodoRestService/setTodoDone';
		
        
	}
    //立即发送所有提醒
    public function sendAllTypeRemindsImmediately($ids, $r_multi_content,$rRemindType='',$rOtherParam=array())
    {
        global $adb;
		$this->rRemindType = $rRemindType;
		if(!empty($r_multi_content)){
			foreach($r_multi_content as $key => $info){
			

				$data[$key] = $info;
			}
			if (count($r_multi_content) > 0) {
				return $this->sendReminds($ids, $data);
			}
		}
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
        
		$listIds = array();
        crm_load_class_file('cls_MyCRMcrypt',"Register");
		if(!empty($ids)){
		    foreach ($r_multi_content as $key=>$news_content) {
              
                $massageContent =  $news_content['message'];
                $r_reltab = $news_content['reltab'];
                $r_related_to = $news_content['related_to'];
                $r_date_time = $news_content['date_time'];
                $r_remindtype = $news_content['remindtype'];
                $user_name=$news_content['receive_username'];
                

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
                $username_arr=explode(",",$user_name);
                 $crm_url='http://crm.zyfchina.com:8083/crm';
				
                foreach($username_arr as $tmp_userid=>$tmpusername) {
                     
                    $url = $this->yifen_url;//泛微地址
                    $cls_MyCRMcryptobj=new cls_MyCRMcrypt();
                    $encrypt_userid = $cls_MyCRMcryptobj->encode($tmp_userid);
                    $remindsid=$news_content['remindsid'];
                    //$crm_url='http://81mis.com/kfbcrm';
                    $urlencode=urlencode("$crm_url/yifenRootLogin.php?pageto_module=Reminds&pageto_record=$remindsid");
                    $link="http://ekpsso.zyfchina.com:8099/sso/login?service=$urlencode";
 
                    $newsArr['modelId'] = $news_content['remindsid'];
                    $newsArr['appName']="";
                    $newsArr['createTime'] = date("Y-m-d H:i:s");
                    $newsArr['mobileLink'] ="";//TODO
                    $newsArr['modelName'] = "Reminds";//TODO
                    $newsArr['subject']=$massageContent;
                    $newsArr['link']=$link;
                    $newsArr['padLink']="1";
                    $newsArr['type']="1";
                    $newsArr['targets']=json_encode(['LoginName'=>$tmpusername]);


                    $body = ldcrm_json_encode($newsArr);
                    $result = $this->_CurlGet($url,$body);
				//	echo $result;
                    $result = json_decode($result,true);
					/*echo '<pre>';
					print_r($result);
					echo '</pre>';*/
                }

                $listIds[$ids[$key]] = 1;
            }
		}

        return $listIds;
    }

	public function setInstallFw(){
		global $adb;
		return true;
	}
        
        
    public function  delReminds()
    {
        global $adb;
        $sql='select * from ld_yifendelreminds where operation=? ';
        $result=$adb->pquery($sql,array('deleted'));
        $rows=$adb->num_rows($result);
        for($i=0;$i<$rows;$i++)
        {
            $remindsid=$adb->query_result($result,$i,'remindsid');
            $newsArr=[];
            $newsArr['modelName']='Reminds';
            $newsArr['modelId']=$remindsid;
			$newsArr['optType']=1;
            $arr=json_decode($this->_CurlGet($this->yifen_delurl,json_encode($newsArr)),true)  ;
			//echo $arr['returnState'].'del';
            //if($arr['returnState']=='2')
           // {
                $sql='delete from ld_yifendelreminds where remindsid=?';
                $adb->pquery($sql,array($remindsid));
           // }
            
            
        }
        
        
    }
	
    public function setReadenReminds()
    {
        global $adb;
        $sql='select * from ld_yifendelreminds where operation=? ';
        $result=$adb->pquery($sql,array('read'));
        
        $rows=$adb->num_rows($result);
        for($i=0;$i<$rows;$i++)
        {
            $remindsid=$adb->query_result($result,$i,'remindsid');
            $newsArr=[];
            $newsArr['modelName']='Reminds';
            $newsArr['modelId']=$remindsid;
			$newsArr['optType']=1;
            $arr=json_decode($this->_CurlGet($this->yifen_readurl,json_encode($newsArr)),true)  ;
            //if($arr['returnState']=='2')
            //{
                $sql='delete from ld_yifendelreminds where remindsid=?';
                $adb->pquery($sql,array($remindsid));
				//echo $arr['returnState'].'read';
           // }
            
            
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