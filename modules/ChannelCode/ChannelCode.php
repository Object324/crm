<?php



class ChannelCode extends CRMEntity {
    
    static  function require_file($requiremodules='')
    {
            globalStatic::$arr_module_require['ChannelCode']='ChannelCode';
         
            
           
            if(!empty($requiremodules)&&empty(globalStatic::$arr_module_require[$requiremodules]))
            {
                globalStatic::$arr_module_require[$requiremodules]=$requiremodules;
                include(globalStatic::$root_directory."modules/$requiremodules/$requiremodules.php");
                
            }

    }
    var $module_name='ChannelCode';
	var $table_name = "ld_channelcode";
	var $table_index= 'id';
	var $tab_name_index = Array('ld_channelcode'=>'id');
	var $tab_name = Array('ld_crmentity','ld_channelcode');

	function __construct() {
	
		$this->db = PearDatabase::getInstance();
        $this->fieldobj=Field::getInstance('ChannelCode',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
        $entityname=getEntitynameByModulename('ChannelCode');
        $this->list_link_field=$entityname['fieldname'];
       
	}


	//获取系统中所有已绑定企业微信得用户
	function getUserName($userid)
	{
		global $adb;
		if(!empty($userid)){
			$query = "select GROUP_CONCAT(last_name) as name from ld_users where id in ($userid) and wx_userid <> '' and `status` = 'Active'";
			$result = $adb->pquery($query,array());
			return $adb->query_result($result,0,0);
		}
		return '';      
	}
	//获取渠道码标签
	function getChannelLabel($record) {
		global $adb;
		if(!empty($record)){
			$query = "select channelcode_id,label,label_string from ld_channellabel where channelcode_id = ?";
			$result = $adb->pquery($query,array($record));
			$num_rows = $adb->num_rows($result);
			if($num_rows >= 1){
				for($i = 0; $i < $num_rows; $i++){
					$channellabels['label'][] = $adb->query_result($result,$i,'label');
					$channellabels['label_string'][] = $adb->query_result($result,$i,'label_string');
				}
				return array('label' => implode(',',$channellabels['label']),'label_string' => implode('|::##::|',$channellabels['label_string']));
			}
			return '';
		}
   	}
	//保存图片
	function saveImage($file_name,$record){
		global $adb;
		$fyear=date("Y");
		$fmonth=date('F');
		$fday=date('j');//获取当前月份第几天
		$fweek='week'.ceil($fday/7);//获取当前日期所属月份的第几周
		if(!file_exists(globalstatic::$root_directory.'storage/'.$fyear)){
			 mkdir(globalstatic::$root_directory.'storage/'.$fyear,0777);
		}
		if(!file_exists(globalstatic::$root_directory.'storage/'.$fyear.'/'.$fmonth)){
			 mkdir(globalstatic::$root_directory.'storage/'.$fyear.'/'.$fmonth,0777);
		}
	
		if(!file_exists(globalstatic::$root_directory.'storage/'.$fyear.'/'.$fmonth.'/'.$fday))
		{
			 mkdir(globalstatic::$root_directory.'storage/'.$fyear.'/'.$fmonth.'/'.$fday,0777);
		}
		$file_path = 'storage/'.$fyear.'/'.$fmonth.'/'.$fday.'/';
		$uploadDir=globalstatic::$root_directory.'storage/'.$fyear.'/'.$fmonth.'/'.$fday.'/';
		$binFile = $_FILES[$file_name]['name'];
		//echo $btn_file_name.'_hidden';echo '<br><br>';
		if(isset($_REQUEST[$file_name.'_hidden']) && $_REQUEST[$file_name.'_hidden'] != '') {
			$filename = $_REQUEST[$file_name.'_hidden'];
		} else {
			$filename = ltrim(basename(" ".$binFile));
		}
		//echo $file_name.'_hidden';echo '<br><br>';
		//echo $_REQUEST[$file_name.'_hidden'];echo '<br><br>';die;
		$new_filename = $filename;
		$filetype= $_FILES[$file_name]['type'];
		$ffilesize = $_FILES[$file_name]['size'];
		$arr=array("ASCII","UTF-8","GB2312","GBK",'BIG-5');
		$encode=mb_detect_encoding($filename, $arr); 
		if(strtolower(PHP_OS)=='freebsd'||strtolower(PHP_OS)=='linux'||strtolower(PHP_OS)=='unix')
		{
		//获取系统类型，如果是非windows系统则不用修改编码格式

		}
		else if($encode=='UTF-8')
		{
			$filename=iconv('UTF-8','gb2312',$filename);
		}
		if(move_uploaded_file($_FILES[$file_name]["tmp_name"],$uploadDir.$record.'_'.$filename)){
			$query = "update ld_channelcode set file_path = ?,file_name = ? where id = ?";
			$adb->pquery($query,array($file_path,$record.'_'.$new_filename,$record));
			//图片上传企业微信
			$filepath = $file_path.$record.'_'.$new_filename;
			$renamefile = $record.'_'.$new_filename;
			if(strtolower(PHP_OS)=='freebsd'||strtolower(PHP_OS)=='linux'||strtolower(PHP_OS)=='unix')
			{//获取系统类型，如果是非windows系统则不用修改编码格式
				$fileurl =urldecode($filepath);
				
			}else{
				$fileurl = iconv('utf-8','gbk',$filepath);
			}
			$access_token=$this->getAccessToken();
			//上传导出文件
			if($file_name == 'imgFile' || $file_name == 'appFile'){
				$url = 'https://qyapi.weixin.qq.com/cgi-bin/media/upload?access_token='.$access_token.'&type=image';
			}else{
				$url = 'https://qyapi.weixin.qq.com/cgi-bin/media/uploadimg?access_token='.$access_token.'&type=image';
			}
			if(PHP_VERSION>=7){
				//edit:can 20200713 php5.5废弃了@，但是kehu001还要php5.4
				$fileobj=new \CURLFile($fileurl);
				$fileobj->setPostFilename($renamefile);
				$post_data=array("media"=> $fileobj);
			}
			else{
				$post_data = array("media"=>'@'.realpath($fileurl).';filename='.$renamefile,);
			}
			crm_load_class_file("cls_WeixinPort", 'WeiXinApp/WeiXin_common');
			$portObj = new cls_WeixinPort();//gyq_41 //gyq_33
			$res_json = $portObj->curlUploadFile($post_data,$url);
			$res = json_decode($res_json);
			if($res->errcode == 0){
				if($file_name == 'imgFile' || $file_name == 'appFile'){
					$query = "update ld_channelcode set file_media_id = ? where id = ?";
					$adb->pquery($query,array($res->media_id,$record));
				}else{
					$query = "update ld_channelcode set file_pic_url = ? where id = ?";
					$adb->pquery($query,array($res->url,$record));
				}
			}
		}

	}
	function getChannelUserQuery($text){
		global $adb;
		$query = "select id from ld_users where last_name like '%".$text."%' and wx_userid <> '' and `status` = 'Active' ";
		$result = $adb->pquery($query,array());
		$num_rows = $adb->num_rows($result);
		if($num_rows >= 1){
			for($i = 0; $i < $num_rows; $i++){
				$id = $adb->query_result($result,$i,'id');
				$where[] = "find_in_set ( $id, ld_channelcode.channel_userid)";
			}

			return "(".implode(' or ',$where).")";
		}
		return ' 1= 2 ';
	}

	//生成渠道码
	function addContactWay($record){
		global $adb;
		if(!empty($record)){
			$query = "select ld_channelcode.id,channel_name,channel_userid,channelverify,scan_times,card_title,card_description,card_href,app_title,app_id,app_src,ld_users.last_name,ld_channelcode.createdtime from ld_channelcode
			left join ld_users on ld_users.id = ld_channelcode.smcreatorid
			where ld_channelcode.deleted = 0 and ld_channelcode.id = ?";
			$result = $adb->pquery($query,array($record));
			$channel_name = $adb->query_result($result,0,'channel_name');
			$channelverify = $adb->query_result($result,0,'channelverify');
			$channel_userid = $adb->query_result($result,0,'channel_userid');
			$wxuserid = $this->getWxUserid($channel_userid);
			$id = $adb->query_result($result,0,'id');
			require_once globalStatic::$root_directory.'WeiXinApp/WeiXin_common/StaticConst.php';
			$token=$this->getAccessToken();
			$url = 'https://qyapi.weixin.qq.com/cgi-bin/externalcontact/add_contact_way?access_token='.$token;
			//$crop_json = $this->object_array(json_decode($crop_json));
			if($channelverify == 'yes'){
				$contact_way_array['skip_verify'] = true;	//外部客户添加时是否无需验证，默认为true
			}else{
				$contact_way_array['skip_verify'] = false;
			}
			if(is_array($wxuserid) && sizeOf($wxuserid) > 1){
				$type = 2;
			}else{
				$type = 1;
			}
			$contact_way_array = array(
				'type' => $type,	//联系方式类型,1-单人, 2-多人
				'scene' => 2,	//场景，1-在小程序中联系，2-通过二维码联系
				'style' => 1,	//在小程序中联系时使用的控件样式，详见附表
				'remark' => $channel_name,	//联系方式的备注信息，用于助记，不超过30个字符
				'state' => 'qudaoma_'.$id,	//企业自定义的state参数，用于区分不同的添加渠道，在调用“获取外部联系人详情”时会返回该参数值，不超过30个字符
				'user' => $wxuserid,	//使用该联系方式的用户userID列表，在type为1时为必填，且只能有一个
				'is_temp' => false,	//是否临时会话模式，true表示使用临时会话模式，默认为false
				//'expires_in' => 86400,
				//"chat_expires_in"=>86400,
			);
			$res=$this->wx_post($url,$contact_way_array);
			if($res['errcode'] == 0){
				$query = "update ld_channelcode set config_id = ?,qr_code = ? where id = ?";
				$adb->pquery($query,array($res['config_id'],$res['qr_code'],$record));
			}
		}
	}
	//获取客户的标签
	function getChannelLabelTag($record){
		$channellabels = $this->getChannelLabel($record);
		if(!empty($channellabels['label_string'])){
			$label_array = explode('|::##::|',$channellabels['label_string']);
			foreach($label_array as $label){
				$labels = explode('|::|',$label);
				$data[] = $labels[3];
			}
			return $data;
		}
		return '';
	}
	//post请求
	function wx_post($url,$data){

		//将post的数据转换为json格式
		$post_data=json_encode($data,JSON_UNESCAPED_UNICODE);
		//$post_data = $this -> encode_json($data);
		$chr = curl_init();
		curl_setopt ($chr, CURLOPT_URL, $url );
		curl_setopt ($chr, CURLOPT_SSL_VERIFYPEER, FALSE );
		curl_setopt ($chr, CURLOPT_SSL_VERIFYHOST, FALSE );
		curl_setopt($chr, CURLOPT_HEADER, 0);//设置header
	   // curl_setopt($chr, CURLOPT_CONNECTTIMEOUT, 1);
		curl_setopt($chr, CURLOPT_POST, true);  
		curl_setopt($chr, CURLOPT_POSTFIELDS, $post_data);  
		curl_setopt($chr, CURLOPT_RETURNTRANSFER, true);   
		$output = curl_exec($chr);
			if($error=curl_error($chr)){  
			die($error);  
		}  
		curl_close($chr);
		//数据转换成数组格式
		$jsoninfo = json_decode($output, true);

		return $jsoninfo;
	}
	
	//get请求
	function wx_get($url){

		//访问数据接口
		$ch = curl_init();
		curl_setopt($ch, CURLOPT_URL, $url);
		curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, FALSE); 
		curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, FALSE); 
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
		$output = curl_exec($ch);
		curl_close($ch);

		//数据转换成数组格式
		$jsoninfo = json_decode($output, true);

		return $jsoninfo;
	}

	//获取企业微信渠道码设置
	function getWxConfigForChannel(){
		global $adb;
		$data = array();
		$query = "select para_content,para_one,para_two,para_three from ld_wx_config where name = 'channelcode_setting' limit 1";
		$result = $adb->pquery($query,array());
		$num_rows = $adb->num_rows($result);
		if($num_rows >= 1){
			$data['secret'] = $adb->query_result($result,0,'para_content');
			$data['token_url'] = $adb->query_result($result,0,'para_one');
			$data['token'] = $adb->query_result($result,0,'para_two');
			$data['encodingaeskey'] = $adb->query_result($result,0,'para_three');
		}
		return $data;
	}
	
	//获取企业微信客户联系人的所有标签
	function getWxTag(){
		$token=$this->getAccessToken();
		$channellabel_array = [];
		//$token = 'AOavrmtQ-Qx0azzXfJF8BKb1b4u5wzQ51JpzRTgTubhgonbZoPeDclby98m7bfkeULgA5rRjYlGKHSTrt0UuQtwmwB5rjii0oM2SvV6ZM2ZOXsspQCh_MxBauDollPiWafE8mbQlsJIlvy891lxypVMBFiPURub9rYbtitqGkg8WmsKF4OM2e1njzgOnk75cNKPdm8ovOy_d0fHicNUYqA';
		$url = 'https://qyapi.weixin.qq.com/cgi-bin/externalcontact/get_corp_tag_list?access_token='.$token;
		$result=$this->wx_get($url);
		if($result['errcode'] == 0){
			$i = 0;
			foreach($result['tag_group'] as $key => $channellabel){
				foreach($channellabel['tag'] as $key2 => $labelobj){
					$channellabel_array['tag'][$i]['id'] = $labelobj['id'];
					$channellabel_array['tag'][$i]['name'] = $labelobj['name'];
					$i++;
				}
			}
		}
		return $result['tag_group'];
	}
	//获取token
	function getAccessToken(){
        crm_load_class_file("cls_WeiXinSelfBuiltApp", 'WeiXinApp/WeiXin_common');
        $wxselfbuilt_obj = new cls_WeiXinSelfBuiltApp();
        if (!$wxselfbuilt_obj->installWXSelfBuilt) {
            crm_load_class_file("cls_WeixinPort", 'WeiXinApp/WeiXin_common');
            $port_obj = new cls_WeixinPort();
            $token = $port_obj->getCorpToken();
            return $token;
        }


		require_once (globalStatic::$root_directory . 'appCommon/appCommon.php');
		$json = doCorpInfo('get_auth_info',array());
		if($json){
			$json_arr = ldcrm_json_decode($json);
			$corpid = $json_arr['crm']['auth_corp_info']['corpid'];
			$wxconfig = $this->getWxConfigForChannel();
			//$secret = 'fbEQ5nCWng9Z9lJ0K5TR8-ursJyUBA_h2yjQG_A9zu8';
			$url = "https://qyapi.weixin.qq.com/cgi-bin/gettoken?corpid=$corpid&corpsecret=".$wxconfig['secret'];
			//访问数据接口
			$ch = curl_init();
			curl_setopt($ch, CURLOPT_URL, $url);
			curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, FALSE); 
			curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, FALSE); 
			curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
			$output = curl_exec($ch);
			curl_close($ch);

			$jsoninfo = json_decode($output, true);
			$access_token = $jsoninfo["access_token"];

			return $access_token;
		}
		return '';
	}

	//获取需要发送得欢迎语
	function getChannelContactway($record,$weixin_external_userid){
		global $adb;
		if(!empty($record)){
			$query = "select ld_channelcode.id,channel_name,channel_userid,channelverify,scan_times,card_title,card_description,card_href,app_title,app_id,app_src,ld_users.last_name,ld_channelcode.createdtime,words,contact_way_type,file_pic_url,file_media_id,servicecharge_id from ld_channelcode
			left join ld_users on ld_users.id = ld_channelcode.smcreatorid
			where ld_channelcode.deleted = 0 and ld_channelcode.id = ?";
			$result = $adb->pquery($query,array($record));
			$num_rows = $adb->num_rows($result);
			
			if($num_rows >= 1){
				$words = $adb->query_result($result,0,'words');	//文字
				$card_title = $adb->query_result($result,0,'card_title');
				$contact_way_type = $adb->query_result($result,0,'contact_way_type');
				$file_media_id = $adb->query_result($result,0,'file_media_id');
				$card_description = $adb->query_result($result,0,'card_description');
				$card_href = $adb->query_result($result,0,'card_href');
				$servicecharge_id = $adb->query_result($result,0,'servicecharge_id');
				/*$version_info = getVersionInfo();
				//东贸 渠道码特殊开发
				if($version_info['account'] == 'dongmao'){
					 $card_href .= '?id='.$weixin_external_userid.'&servicecharge_id='.$servicecharge_id;
					 //渠道码链接反写到客户联系人模块上
					 $update = 'update ld_contactscf LEFT JOIN ld_contactdetails on ld_contactdetails.contactid = ld_contactscf.contactid set cf_4645 = ? where weixin_external_userid = ? and deleted = 0';
					 $adb->pquery($update,array($card_href,$weixin_external_userid));
				}*/
				$file_pic_url = $adb->query_result($result,0,'file_pic_url');
				$app_title = $adb->query_result($result,0,'app_title');
				$app_id = $adb->query_result($result,0,'app_id');
				$app_src = $adb->query_result($result,0,'app_src');
				if(!empty($words)){
					$data['text']['content'] = htmlspecialchars_decode($words);
				}

				//图片
				if($contact_way_type == 'img' && !empty($file_media_id)){
//					$data['image']['media_id'] = $file_media_id;
                    //原接口数据格式已废弃，使用新的
                    $data['attachments'][] = array(
                        "msgtype"=>"image",
                        "image"=>[
                            "media_id"=>$file_media_id
                        ],
                    );
				}
				//链接卡片
				elseif($contact_way_type == 'card' && !empty($file_pic_url)){
					/*$data['link']['title'] = htmlspecialchars_decode($card_title);
					$data['link']['picurl'] = $file_pic_url;
					$data['link']['desc'] = htmlspecialchars_decode($card_description);
					$data['link']['url'] = $card_href;*/

                    $data['attachments'][] = array(
                        "msgtype"=>"link",
                        "link"=>[
                            "title"=>htmlspecialchars_decode($card_title),
                            "picurl"=>$file_pic_url,
                            "desc"=>htmlspecialchars_decode($card_description),
                            "url"=>$card_href,
                        ],
                    );
				}
				//小程序
                elseif($contact_way_type == 'app' && !empty($file_media_id)){
					/*$data['miniprogram']['title'] = htmlspecialchars_decode($app_title);
					$data['miniprogram']['pic_media_id'] = $file_media_id;
					$data['miniprogram']['appid'] = $app_id;
					$data['miniprogram']['page'] = $app_src;*/

                    $data['attachments'][] = array(
                        "msgtype"=>"miniprogram",
                        "miniprogram"=>[
                            "title"=>htmlspecialchars_decode($app_title),
                            "pic_media_id"=>$file_media_id,
                            "appid"=>$app_id,
                            "page"=>$app_src,
                        ],
                    );
				}
				return $data;
			}
			return '';
		}
	}
	//当企业员工有多个时，随机取一个
	function getWxUserid($channel_userid){
		global $adb;
		$data = array();
		/*$userids = explode(',',$channel_userid);
		if(sizeOf($userids) > 1){
			$randnum = rand(0, sizeOf($userids) - 1);
			$userid = $userids[$randnum];
		}else{
			$userid = $channel_userid;
		}*/
		$query = "select wx_userid from ld_users where id in ($channel_userid) and wx_userid <> '' and `status` = 'Active'";
		$result = $adb->pquery($query,array());
		$num_rows = $adb->num_rows($result);
		if($num_rows>=1){
			for($i = 0; $i < $num_rows; $i++){
				$data[] = $adb->query_result($result,$i,'wx_userid');
			}
		}
		return $data;
	}

	//更新渠道码的扫码次数
	function updateChannelScanTimes($record){
		global $adb;
		$query = 'update ld_channelcode set scan_times = scan_times + 1 where id = ?';
		$adb->pquery($query,array($record));
	}

	//添加、删除扫码客户记录
    /*
     * $wx_userid  被扫码成员 UserID   需要作为负责人,得转为userid，即  smownerid
     * */
	function setChannelExternalLog($record,$externaluserid,$changetype,$wx_userid){
		global $adb;
		if($changetype == 'add_external_contact'){
			$access_token=$this->getAccessToken();
			$url = 'https://qyapi.weixin.qq.com/cgi-bin/externalcontact/get?access_token='.$access_token.'&external_userid='.$externaluserid;
			$externalcontact = $this->wx_get($url);
			if(!empty($externalcontact) && $externalcontact['errcode'] == 0){
				$external_contact_name = $externalcontact['external_contact']['name'];	//外部联系人的名称
				$external_corp_name = $externalcontact['external_contact']['corp_name'];	//外部联系人所在企业的简称
				$external_type = $externalcontact['external_contact']['type'];	//外部联系人的类型，1表示该外部联系人是微信用户，2表示该外部联系人是企业微信用户
				$unionid = '';	//外部联系人在微信开放平台的唯一身份标识（微信unionid），通过此字段企业可将外部联系人与公众号/小程序用户关联起来。
				if(isset($externalcontact['external_contact']['unionid'])){
					$unionid = $externalcontact['external_contact']['unionid'];
				}
				foreach($externalcontact['follow_user'] as $follow_user){
					$userid = $follow_user['userid'];
					$createtime = $follow_user['createtime'];
					$createtime = date('Y-m-d H:i:s',$createtime);
					$createtime = date('Y-m-d H:i:s');
					$state = $follow_user['state'];
					if($state == 'qudaoma_'.$record && $follow_user['add_way'] == 1){
						$query = "insert into ld_channelcode_history(record,wx_userid,external_contact_name,external_contact_corpname,external_contact_type,externaluserid,createdtime,changetype) values (?,?,?,?,?,?,?,?)";
						$adb->pquery($query,array($record,$userid,$external_contact_name,$external_corp_name,$external_type,$externaluserid,$createtime,$changetype));
						break;//@edit:liushuai,2021-06-24,reason:46557: （81mis.com/kfbcrm）营销-渠道码，扫描渠道码添加企业微信后，渠道码显示扫码客户重复三次(该外部联系人有多个好友时)
					}
				}

                $query = 'select channel_userid from ld_channelcode where id = ?';
                $quert_result = $adb->pquery($query,array($record));
                $channel_userid = $adb->query_result($quert_result,0,'channel_userid');//渠道码的负责人,可能为多个
//				$version_info = getVersionInfo();
//                @edit:liushuai,2021-06-23,reason:【ID1001720】扫渠道码，自动添加客户和联系人后，联系人默认为客户首要联系人
//                @edit:liushuai,2021-06-23,reason:通过获取外部联系人详情接口新增客户和联系人时，调用统一接口
				/*if($version_info['account'] == 'dongmao'){
					crm_load_class_file("WeiXinPortContacts_dongmao", 'crmapi/WeiXinPort');
					$WeixinPortContactsObj = new WeiXinPortContacts_dongmao();
				}else{*/
					crm_load_class_file("WeiXinPortContacts", 'crmapi/WeiXinPort');
					$WeixinPortContactsObj = new WeiXinPortContacts();
//				}

                $sql = 'select id from ld_users where wx_userid = ? LIMIT 1';
                $sql_result = $adb->pquery($sql,array($wx_userid));
                if ($adb->num_rows($sql_result) > 0) {
                    $smownerid = $adb->query_result($sql_result,0,'id');
                }else{
                    $smownerid = explode(",",trim($channel_userid,','))[0];
                }

				$WeixinPortContactsObj->setSmownerID($smownerid);
				$WeixinPortContactsObj->setChannelUserid($channel_userid);
				$WeixinPortContactsObj->setWeixinExternalUserid($externaluserid);
				$WeixinPortContactsObj->setLastname($external_contact_name);
				$WeixinPortContactsObj->setSourceFrom("qudaoma");
				$WeixinPortContactsObj->insert_contact_record($external_type,$external_corp_name,$externalcontact['external_contact']['corp_full_name'],$unionid);
				//chj 2021/7/1 东贸：扫渠道码，打招呼推送客户信息链接，客户可自行补充信息
				/*if($version_info['account'] == 'dongmao'){
					$this->updateContactsForDongmao($record,$WeixinPortContactsObj->weixin_external_userid,$unionid);
				}*/
				return $WeixinPortContactsObj->weixin_external_userid;

			}
		}
	}
	
	//东贸：扫渠道码，打招呼推送客户信息链接，客户可自行补充信息
	function updateContactsForDongmao($record,$weixin_external_userid,$unionid){
		global $adb;
		if(!empty($unionid)){
			$contactid = 0;
			$query = 'select contactid,accountid from ld_contactdetails where weixin_external_userid = ? and unionid = ? and deleted = 0 limit 1';
			$result = $adb->pquery($query,array($weixin_external_userid,$unionid));
			$num_rows = $adb->num_rows($result);
			if($num_rows >= 1){
				$contactid = $adb->query_result($result,0,'contactid');
				$accountid = $adb->query_result($result,0,'accountid');
				$update = 'update ld_wechatuser set accountid = ?,contactid = ? where unionid = ?';
				$adb->pquery($update,array($accountid,$contactid,$unionid));
				if(!empty($accountid)){
					$update = "update ld_account set customform10_id = (select customform10id from ld_customform10 where form10_type = '下游客户' and deleted = 0) where ld_account.accountid = ?";
					$adb->pquery($update,array($accountid));
				}
			}
			if(!empty($contactid)){
				$query = 'select 1 from ld_contactscf where contactid = ?';
				$result = $adb->pquery($query,array($contactid));
				$num_rows = $adb->num_rows($result);
				if(empty($num_rows)){
					$insert = 'insert into ld_contactscf(contactid) values (?)';
					$adb->pquery($insert,array($contactid));
				}

				//获取渠道码标签
				$query = 'select label from ld_channellabel where channelcode_id = ?';
				$result = $adb->pquery($query,array($record));
				$num_rows = $adb->num_rows($result);
				if($num_rows >= 1){
					for($i = 0; $i < $num_rows; $i++){
						$label = $adb->query_result($result,$i,'label');
						$this->addModuleDataForChannelLabel($label,'Contacts',$contactid);
					}
				}
			}
			//根据unionid获取外部联系人的ID
			require_once (globalStatic::$root_directory . 'appCommon/appCommon.php');
			$json = doCorpInfo('get_auth_info',array());
			if($json){
				$json_arr = ldcrm_json_decode($json);
				$corpid = $json_arr['crm']['auth_corp_info']['corpid'];
				crm_load_class_file('cls_WeixinPort','WeiXinApp/WeiXin_common');
				$o_port = new cls_WeixinPort();
				$url = 'http://www.51mis.cn/webapi/crm_free/server.php?action=get_unionid_externaluserid&corpid='.$corpid.'&unionid='.$unionid;
				$result = json_decode($o_port->primary_curl($url),true);
				$contact_external_userid = $result['result']['contact_external_userid'];
				if(!empty($contact_external_userid)){
					$update = 'update ld_contactdetails set unionid_external_userid = ? where unionid = ?';
					$adb->pquery($update,array($contact_external_userid,$unionid));
				}
			}
		}
		$query = 'select card_href from ld_channelcode where id = ? and deleted = 0 limit 1';
		$result = $adb->pquery($query,array($record));
		$num_rows = $adb->num_rows($result);
		if($num_rows >= 1){
			$card_href = $adb->query_result($result,0,'card_href');
			$update = 'update ld_contactdetails LEFT JOIN ld_contactscf on ld_contactscf.contactid = ld_contactdetails.contactid set lxr_type = ? where weixin_external_userid = ? and deleted = 0';
			$adb->pquery($update,array('下游客户联系人',$weixin_external_userid));
		}

	}
	
	//给单据添加标签
	function addModuleDataForChannelLabel($tag,$module,$record){
		global $adb;
		$tag_query = 'select id from ld_module_tag where userid = 1 and tag = ? and tag_type = ?';
		$tag_result = $adb->pquery($tag_query,array($tag,'company'));
		$tag_num_rows = $adb->num_rows($tag_result);
		//创建标签
		if(empty($tag_num_rows)){
			$tag_query = 'select max(tag_sequence) + 1  from ld_module_tag where userid = 1 and module = ?';
			$tag_result = $adb->pquery($tag_query,array($module));
			$tag_num_rows = $adb->num_rows($tag_result);
			if($tag_num_rows >= 1){
				$tag_sequence = $adb->query_result($tag_result,0,0);
			}
			if(empty($tag_sequence))
				$tag_sequence = 1;
			$tag_insert = 'insert into ld_module_tag(userid,module,tag,createdtime,tag_type,tag_sequence) values (?,?,?,?,?,?)';
			$adb->pquery($tag_insert,array(1,$module,$tag,date('Y-m-d H:i:s'),'company',$tag_sequence));
			$tag_id = $adb->getLastInsertID();
		}else{
			$tag_id = $adb->query_result($tag_result,0,0);
		}
		//添加标签
		$tag_query = 'select id from ld_moduledata_tag where record = ? and parentid = ?';
		$tag_result = $adb->pquery($tag_query,array($record,$tag_id));
		$tag_num_rows = $adb->num_rows($tag_result);
		if(empty($tag_num_rows)){
			$tag_query = 'select max(tag_sequence) + 1  from ld_moduledata_tag where record = ?';
			$tag_result = $adb->pquery($tag_query,array($record));
			$tag_num_rows = $adb->num_rows($tag_result);
			if($tag_num_rows >= 1){
				$tag_sequence = $adb->query_result($tag_result,0,0);
			}
			if(empty($tag_sequence))
				$tag_sequence = 1;
			$tag_insert = 'insert into ld_moduledata_tag(record,parentid,tagged_on,tag_userid,tag_sequence) values (?,?,?,?,?)';
			$adb->pquery($tag_insert,array($record,$tag_id,date('Y-m-d H:i:s'),1,$tag_sequence));
		}
	}

	//获取扫码客户历史记录条目数
	function getChannelCodeHistoryCount($record){
		global $adb;
		$data = array();
		$query = "select count(1) from ld_channelcode_history
			LEFT JOIN ld_users on ld_users.wx_userid = ld_channelcode_history.wx_userid
			where record = ? and ld_channelcode_history.deleted = 0 order by ld_channelcode_history.createdtime desc";
		$result = $adb->pquery($query,array($record));
		$num_rows = $adb->num_rows($result);
		if($num_rows >= 1){
			return $adb->query_result($result,0,0);
		}
		return 0;
	}
	// Function to unlink an entity with given Id from another entity
	function unlinkRelationship($id, $return_module, $return_id) {
	  	
		
	}
	
	
 

}
ChannelCode::require_file();
?>