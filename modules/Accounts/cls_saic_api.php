<?php
/**
 * edit: chj
 * date: 2020-07-21
 * reason: 赛克出行api接口类6
 */

class cls_saic_api
{
    
    public function __construct()
    {
        $this->url = 'https://partner-uat.saicmobility.com/common/';
		$this->curtime = date('YmdHis');
		$this->token = 'u9uJyIEs';
		$this->merchantid = 'open_app_RpJwcjmLECzQP2PZ';
      
    }
	
	/* 
	*param: $mobile(下单手机号),$complaintSource(类型 1乘客 2司机),$orderId(MIS订单号),$vehicleNo(车牌号),$startTime(下单时间),$endTime(下单时间),$matchOrderTimeStart(接单时间),$matchOrderTimeEnd(接单时间),$appId(订单来源)
	*edit: chj
	*date: 2020/7/30
	*reason: 获取手机号对应的订单列表信息
	*/
	public function getOrderList($mobile,$complaintSource,$orderId = '',$vehicleNo='',$startTime='',$endTime='',$matchOrderTimeStart='',$matchOrderTimeEnd='',$appId=''){
		if(empty($complaintSource))$complaintSource = 1;
		if(empty($startTime))$startTime = date('Y-m-01', strtotime(date("Y-m-d")));
		if(empty($endTime))$endTime = date('Y-m-d', strtotime("$startTime +1 month -1 day"));
		$body = array();
		$body['mail'] = 'user@saicmobility.com';
		$body['title'] = '';
		$body['message'] = '';
		if(!empty($mobile)){
			$body['userMobile'] = $mobile;	//下单手机号
		}
		if(!empty($complaintSource)){
			$body['complaintSource'] = $complaintSource;	//类型 1乘客 2司机
		}
		if(!empty($orderId)){
			$body['orderId'] = $orderId;	//MIS订单号
		}
		if(!empty($vehicleNo)){
			$body['vehicleNo'] = $vehicleNo;	//车牌号
		}
		if(!empty($startTime) && !empty($endTime)){
			$body['startTime'] = $startTime . ' 00:00:00';
			$body['endTime'] = $endTime ." 23:59:59";
		}
		if(!empty($matchOrderTimeStart) && !empty($matchOrderTimeEnd)){
			$body['matchOrderTimeStart'] = $matchOrderTimeStart . ' 00:00:00';
			$body['matchOrderTimeEnd'] = $matchOrderTimeEnd ." 23:59:59";
		}
		if(!empty($appId)){
			$body['appId'] = $appId;	//车牌号
		}
		$body = ldcrm_json_encode($body);
		$sign = sha1($body.$this->curtime.$this->token);
		$url = $this->url . 'complain/queryorders';
		$data = $this->getCurlData($url,$body,$sign);
		return $data;
	}

	 /**
	 * 根据mis订单号，获取订单的详情数据信息
	 * @param
	 * @return
	 * @author Chj
	 */
	public function getOrderDetail($orderId) {
		$body = array();
		$body['orderId'] = $orderId;
		$body = ldcrm_json_encode($body);
		$sign = sha1($body.$this->curtime.$this->token);
		$url = $this->url . 'complain/queryorderdetail';
		$api_return_data = $this->getCurlData($url,$body,$sign);
		if(!empty($api_return_data)){
			foreach($api_return_data as $key => $value){
				//责任方
				if($key == 'complainFlag'){
					if($value == 1){
						$value = '乘客';
					}else if($value == 2){
						$value = '司机';
					}else if($value == 3){
						$value = '其他';
					}else{
						$value = '无责';
					}
				}
				//取消方
				if($key == 'cancelFlag'){
					if($value == 1){
						$value = '乘客';
					}else if($value == 2){
						$value = '司机';
					}else{
						$value = '平台';
					}
				}
				//订单类型
				if($key == 'orderType'){
					if($value == 1){
						$value = '实时单';
					}else if($value == 2){
						$value = '预约单';
					}
				}
				//支付状态
				if($key == 'payStatus'){
					if($value == 1){
						$value = '是';
					}else if($value == 0){
						$value = '否';
					}
				}
				//产品类型 1.专车 2.出租车
				if($key == 'productType'){
					if($value == 1){
						$value = '专车';
					}else if($value == 2){
						$value = '出租车';
					}
				}
				//用车方式，0：普通，1：接机 2：送机 3: 包车
				if($key == 'useCarType'){
					if($value == 1){
						$value = '接机';
					}else if($value == 2){
						$value = '送机';
					}else if($value == 3){
						$value = '包车';
					}else{
						$value = '普通';
					}
				}
				//订单车级
				if($key == 'carLevelName'){
					if($value == '舒享型'){
						$value = '舒享';
					}else if($value == '尊享型'){
						$value = '尊享';
					}else{
						$value = '商务六座';
					}
				}
				//订单状态
				if($key == 'orderStatus'){
					if($value == 10){
						$value = '下单成功';
					}else if($value == 18){
						$value = '抢单成功';
					}else if($value == 20){
						$value = '已接单';
					}else if($value == 30){
						$value = '到达接客点';
					}else if($value == 40){
						$value = '接到乘客';
					}else if($value == 50){
						$value = '到达目的地';
					}else if($value == 70){
						$value = '待支付';
					}else if($value == 80){
						$value = '已完成';
					}else{
						$value = '已取消';	//91
					}
				}
				//实际金额
				if($key == 'amount'){
					$value = sprintf("%.2f",$value/100);
				}
				
				$data[$key] = $value;
			}
		}
		return $data;
	}

	//根据进线号码->获取历史中对应的工单信息(显示历史最近10条)
	public function getOrderListLog($usermobile){
		global $adb;
		$data = array();
		if(!empty($usermobile)){
			$query = '
			select 
				ld_account.accountid,account_no,cf_2880,cf_2882,cf_2834,accountname,industry,bill_city,createdtime,leadsource 
			from ld_account 
			LEFT JOIN ld_accountscf on ld_account.accountid = ld_accountscf.accountid 
			where accountname = ? 
			ORDER BY createdtime desc limit 10';
			$result = $adb->pquery($query,array($usermobile));
			$num_rows = $adb->num_rows($result);
			if($num_rows >= 1){
				for($i = 0; $i < $num_rows; $i++){
					$data[] = array(
						'accountid' => $adb->query_result($result,$i,'accountid'),
						'account_no' => $adb->query_result($result,$i,'account_no'),	//工单号码
						'cf_2880' => $adb->query_result($result,$i,'cf_2880'),	//工单主状态
						'cf_2882' => $adb->query_result($result,$i,'cf_2882'),	//工单子状态
						'cf_2834' => $adb->query_result($result,$i,'cf_2834'),	//订单号码
						'accountname' => $adb->query_result($result,$i,'accountname'),	//进线号码
						'industry' => $adb->query_result($result,$i,'industry'),	//来电方
						'leadsource' => $adb->query_result($result,$i,'leadsource'),	//工单来源
						'createdtime' => $adb->query_result($result,$i,'createdtime'),	//创建时间
						'bill_city' => $adb->query_result($result,$i,'bill_city'),	//订单城市
					);
				}
				return $data;
			}
		}
		return $data;
	}
	
	public function getCurlData($url,$body,$sign){
		$curl = curl_init();
		curl_setopt($curl, CURLOPT_URL, $url);
		if(substr($url, 0, 5) == 'https') {
			curl_setopt($curl, CURLOPT_SSL_VERIFYPEER, false);    //SSL 报错时使用
			curl_setopt($curl, CURLOPT_SSL_VERIFYHOST, false);    //SSL 报错时使用
		}
		curl_setopt($curl, CURLOPT_POST, true);
		curl_setopt($curl, CURLOPT_POSTFIELDS, $body);
		curl_setopt($curl, CURLOPT_RETURNTRANSFER, 1);
		curl_setopt($curl, CURLOPT_HTTPHEADER,array('content-type: application/json;charset=utf-8','x-dyeing:424550','X-Sign:'.$sign.'','X-SignAlgorithm:1','X-Timestamp:'.$this->curtime.'','X-MerchantId:'.$this->merchantid.''));
		$result = curl_exec($curl);
		curl_close($curl);
		$result = json_decode($result);
		return $result;
	}

	//获取linux时间戳
	public function getUnixTimestamp ()
	{
		list($s1, $s2) = explode(' ', microtime());
		return (float)sprintf('%.0f',(floatval($s1) + floatval($s2)) * 1000);
	}
	//工单投诉结果回调（工单保存、流转、结案）
	/*
	回调触发点1：工单审批后（会启用审批，第一次保存工单后提交审批，自己审核成功后触发，会设置审核后还可以修改工单）
	回调触发点2：点流转，流转（共享）成功后触发
	回调触发点3：点结案，保存数据成功后
	回调触发点4：点结案备注，保存数据成功后
	涉及到回调数据中含投诉处理结果的字段（faq表中的），取最新一条记录中的。
	*/
	public function saveOrderResult($accountid,$status){
		global $adb,$current_user;
		if(!empty($accountid)){
			$query = 'select 
				ld_account.customform46_id as questiontype,
				ld_account.customform06_id as questiontypeone,
				ld_account.customform07_id as questiontypetwo,
				ld_account.customform08_id as questiontypethree,
				ld_account.customform09_id as questiontypefour,
				ld_account.customform47_id as questiontypefive,faq.answer,
				cf_2834,cf_2890,cf_2913,cf_2832,account_no,cf_2794,ld_accountscf.cf_2884 as createdtime,question,cf_2909,cf_2902,cf_2919,"" as cf_2796,cf_2908,cf_3625,leadsource,cf_2880,ld_account.createdtime as acc_time,ld_account.description,cf_2904 
			from ld_account 
			LEFT JOIN ld_accountscf on ld_accountscf.accountid = ld_account.accountid 
			LEFT JOIN(
				select ld_faq.accountid,createdtime,cf_2794,question,cf_2796,ld_faq.answer from ld_faq 
				LEFT JOIN ld_faqscf on ld_faqscf.faqid = ld_faq.id 
				where ld_faq.accountid = ?
			) as faq on faq.accountid = ld_account.accountid
			LEFT JOIN(
				select ld_customform05.accountid,cf_2913,cf_2909,cf_2919,cf_2908,cf_3625 from ld_customform05 
				LEFT JOIN ld_customform05scf on ld_customform05.customform05id = ld_customform05scf.customform05id 
				where ld_customform05.accountid = ?
			) as customform05 on customform05.accountid = ld_account.accountid
			where ld_account.accountid = ? and deleted = 0 limit 1';
			$result = $adb->pquery($query,array($accountid,$accountid,$accountid));
			$num_rows = $adb->num_rows($result);
			if($num_rows >= 1){
				$this->curApiResolveResult($result,$status);
			}
		}
	}
	//工单投诉结果回调（工单处理和判责单）
	public function saveResolveResult($faqid,$status){
		global $adb,$current_user;
		if(!empty($faqid)){
			$query = 'select 
					ld_account.customform46_id as questiontype,
					ld_account.customform06_id as questiontypeone,
					ld_account.customform07_id as questiontypetwo,
					ld_account.customform08_id as questiontypethree,
					ld_account.customform09_id as questiontypefour,
					ld_account.customform47_id as questiontypefive,ld_faq.answer,
					cf_2834,question,cf_2832,ld_accountscf.cf_2884 as createdtime,cf_2794,cf_2890,cf_2880,industry,leadsource,cf_3625,cf_2909,ld_account.account_no,cf_2913,cf_2908,"" as cf_2796,cf_2919,cf_2902,ld_account.createdtime as acc_time,ld_account.description,cf_2904 
				from ld_faq 
				LEFT JOIN ld_faqscf on ld_faqscf.faqid = ld_faq.id
				LEFT JOIN ld_account on ld_account.accountid = ld_faq.accountid
				LEFT JOIN ld_accountscf on ld_accountscf.accountid = ld_account.accountid
				LEFT JOIN ld_customform05 on ld_customform05.accountid = ld_account.accountid 
				LEFT JOIN ld_customform05scf on ld_customform05.customform05id = ld_customform05scf.customform05id 
				where id = ? and ld_faq.deleted = 0 order by ld_customform05.createdtime desc limit 1';
			$result = $adb->pquery($query,array($faqid));
			$num_rows = $adb->num_rows($result);
			if($num_rows >= 1){
				$this->curApiResolveResult($result,$status);
			}
		}
	}
	public function curApiResolveResult($result,$status){
		global $adb,$current_user;
			$uuid = $this->getUUID();
			$orderId = $adb->query_result($result,0,'cf_2834');	//MIS订单号
			$description = $adb->query_result($result,0,'cf_2890');	//问题描述
			$complaintsMobile = $adb->query_result($result,0,'cf_2913');	//投诉手机号
			$passengerMobile = $adb->query_result($result,0,'cf_2832');	//下单手机号
			if(empty($complaintsMobile)){
				$complaintsMobile = $passengerMobile;
			}
			$complaintSource = $adb->query_result($result,0,'industry');	//投诉来源 1.乘客 2.司机
			if($complaintSource == '司机'){
				$complaintSource = 2;
			}else{
				$complaintSource = 1;
			}
			$closeTime = $adb->query_result($result,0,'createdtime');	//处理时间 格式yyyy-MM-dd HH:mm:ss
			if(empty($closeTime)){
				$closeTime = $adb->query_result($result,0,'acc_time');
			}
			$complaintTime = $adb->query_result($result,0,'cf_2909');	//投诉事件
			$worksheetId = $adb->query_result($result,0,'account_no');	//客服工单号
			$current_user->user_name = 12001;
			$agentId = $current_user->user_name;	//客服工号
			$agentName = $current_user->last_name;	//客服姓名
			$resolveResult = $adb->query_result($result,0,'answer');	//处理结果cf_2794
			if(empty($resolveResult)){
				$resolveResult = $description;
			}
			$insideResolveResult = $adb->query_result($result,0,'question');	//内部处理方案
			$cf_2880 = $adb->query_result($result,0,'cf_2880');	//工单主状态
			$leadsource = $adb->query_result($result,0,'leadsource');	//工单来源
			$thirdOrderId = $adb->query_result($result,0,'cf_3625');	//外部工单号
			$appName = $adb->query_result($result,0,'cf_2908');	//渠道应用名称
			$cf_2796 = $adb->query_result($result,0,'cf_2796');	//责任方
			$priority = $adb->query_result($result,0,'cf_2919');	//映射投诉优先级
			$statusDes = $adb->query_result($result,0,'cf_2902');	//工单系统依照客服业务逻辑定义   工单状态说明
			$remark = $adb->query_result($result,0,'description');	//备注
			$cf_2904 = $adb->query_result($result,0,'cf_2904');	//工单标签
			$questiontype = $adb->query_result($result,0,'questiontype');	//问题类型：1 表示 司机问题类型 2 表示 乘客问题类型； 默认是0 表示 车享问题类型
			$questiontypeone = $adb->query_result($result,0,'questiontypeone');	//对应一级问题分类code
			$questiontypetwo = $adb->query_result($result,0,'questiontypetwo');	//对应一级问题分类下面的二级问题分类code此级code如果传,那么对应的上级code必需传;
			$questiontypethree = $adb->query_result($result,0,'questiontypethree');	//对应二级问题分类下面的三级问题分类code此级code如果传,那么对应的上级code必需传;
			$questiontypefour = $adb->query_result($result,0,'questiontypefour');	//对应三级问题分类下面的四级问题分类code此级code如果传,那么对应的上级code必需传;
			$questiontypefive = $adb->query_result($result,0,'questiontypefive');	//对应四级问题分类下面的五级问题分类code此级code如果传,那么对应的上级code必需传;
			if($cf_2796 == '乘客'){
				$complainFlag = 1;
			}else if($cf_2796 == '司机'){
				$complainFlag = 2;
			}else if($cf_2796 == '无责'){
				$complainFlag = 0;
			}else{
				$complainFlag = 3;	//其他
			}
			$body = array();
			$body['requestId'] = $uuid;
			$body['orderId'] = $orderId;
			$body['description'] = $description;
			$body['complaintsMobile'] = $complaintsMobile;
			$body['passengerMobile'] = $passengerMobile;
			$body['closeTime'] = $closeTime;
			$body['worksheetId'] = $worksheetId;
			$body['agentId'] = $agentId;
			$body['agentName'] = $agentName;
			$body['resolveResult'] = $resolveResult;
			$body['insideResolveResult'] = $insideResolveResult;
			$body['thirdCategory'] = 1;
			$body['questionTypeOne']= 1;
			$body['status'] = $status;	//工单主状态：1 创建/ 2 未结案-保存/ 3未结案-流转/ 4 结案
			$body['complaintSource'] = $complaintSource;
			$body['complainFlag'] = $complainFlag;
			$body['complaintTime'] = $complaintTime;
			$body['statusDes'] = $statusDes;
			$body['tag'] = $cf_2904;
			$body['questionType'] = $questiontype;
			$body['questionTypeOne'] = $questiontypeone;
			$body['questionTypeTwo'] = $questiontypetwo;
			$body['questionTypeThree'] = $questiontypethree;
			$body['questionTypeFour'] = $questiontypefour;
			$body['questionTypeFive'] = $questiontypefive;
			if(strlen($priority) == 2){
				$priority = substr($priority, -1);
			}else{
				$priority = 1;
			}
			$body['priority'] = $priority;
			if($leadsource == '聚合平台推送'){
				$body['thirdOrderId'] = $thirdOrderId;
				$body['complaintChannel'] = 2;	//投诉渠道 1.享道 2.渠道合作方
				$body['thirdWorksheetId'] = $worksheetId;
			}else{
				$body['complaintChannel'] = 1;
			}
			$body['appName']= $appName;
			$body['remark']= $remark;
			$body = ldcrm_json_encode($body);
			$sign = sha1($body.$this->curtime.$this->token);
			$url = $this->url . 'complain/resolveresult';
			$data = $this->getCurlData($url,$body,$sign);
			/*echo '<pre>';
			print_r($body);
			echo '</pre>';
			echo '<pre>';
			print_r($data);
			echo '</pre>';
			die;*/
	}

	public function getUUID(){
		$chars = md5(uniqid(mt_rand(), true));
		$uuid = substr ( $chars, 0, 8 ) . '-'
		. substr ( $chars, 8, 4 ) . '-'
		. substr ( $chars, 12, 4 ) . '-'
		. substr ( $chars, 16, 4 ) . '-'
		. substr ( $chars, 20, 12 );
		$uuid = str_replace("-","",$uuid);
		return $uuid;
	}
	
	public function insertAttachemnt($record,$module,$attachments){
		global $adb;
		if(!empty($attachments)){
			foreach($attachments as $attachs){
				$imgId = $attachs->imgId;
				//插入附件表
				$current_id = $adb->getUniqueID("ld_crmentity");//附件明细id 
				$sql1 = 'insert into ld_crmentity (crmid,setype) values(?,?);';
				$adb->pquery($sql1,array($current_id,'Attachment'));

				//插入知识管理与附件明细关联表ld_seattachmentsrel
				$sqlInsertRel='insert into ld_seattachmentsrel(crmid,attachmentsid,attachmentcolumnname)values(?,?,?);';
				$adb->pquery($sqlInsertRel,array($record,$current_id,'filename'));

				//插入附件明细表ld_attachments
				$sqlInsertAttachments='insert into ld_attachments(attachmentsid,name,newfile_name,description,type,path,size,imagefromtype,storage_location) values(?,?, ?, ?, ?, ?,?,?,?)';//description不知道什么，暂时去掉
				$adb->pquery($sqlInsertAttachments,array($current_id,$imgId,'','-无-','image/jpeg','','','Computer','local'));
			}
		}
	}

	public function uploadImg($imgId,$module){
		global $adb;
		$root_directory=dirname(dirname(dirname(__FILE__)));//获取根目录
		if(!empty($imgId)){
			$body = array();
			$body['fileId'] = $imgId;
			$body['sign'] = MD5($imgId.$this->curtime.'e294d2f15b3f404dbd49d516b6fa50e2');
			$body['timestamp'] = $this->curtime;
			$body = ldcrm_json_encode($body);
			$sign = sha1($body.$this->curtime.$this->token);
			$url = $this->url . 'complain/getpicture';
			$imgdata = $this->getCurlImgData($url,$body,$sign);
			$file_path = $this->getUpload();
			$uploadDir = $root_directory.'/'.$file_path;
			$filename=$module.'_'.$this->getUUID().".jpg";//要生成的图片名字
			$jpg = $imgdata;//得到post过来的二进制原始数据
			$file = fopen($uploadDir.$filename,"w");//打开文件准备写入
			fwrite($file,$jpg);//写入
			fclose($file);//关闭
			return array('filename'=>$filename,'filepath'=>$file_path);
		}
	}
	
	function getFormattedFileSize($filesize) {
		if($filesize < 1024)
			$filesize = sprintf("%0.2f",round($filesize, 2)).'b';
		elseif($filesize > 1024 && $filesize < 1048576)
			$filesize = sprintf("%0.2f",round($filesize/1024, 2)).'kB';
		else if($filesize > 1048576)
			$filesize = sprintf("%0.2f",round($filesize/(1024*1024), 2)).'MB';
		return $filesize;
	}

	public function getUpload(){
		$root_directory=dirname(dirname(dirname(__FILE__)));//获取根目录
		$fyear=date("Y");
		$fmonth=date('F');
		$fday=date('j');//获取当前月份第几天
		if(!file_exists($root_directory.'/storage/'.$fyear)){
			 mkdir($root_directory.'/storage/'.$fyear,0777);
		}
		if(!file_exists($root_directory.'/storage/'.$fyear.'/'.$fmonth)){
			 mkdir($root_directory.'/storage/'.$fyear.'/'.$fmonth,0777);
		}
		if(!file_exists($root_directory.'/storage/'.$fyear.'/'.$fmonth.'/'.$fday)){
			 mkdir($root_directory.'/storage/'.$fyear.'/'.$fmonth.'/'.$fday,0777);
		}
		$uploadDir='storage/'.$fyear.'/'.$fmonth.'/'.$fday.'/';
		return $uploadDir;
	}
	public function getCurlImgData($url,$body,$sign){
		$curl = curl_init();
		curl_setopt($curl, CURLOPT_URL, $url);
		if(substr($url, 0, 5) == 'https') {
			curl_setopt($curl, CURLOPT_SSL_VERIFYPEER, false);    //SSL 报错时使用
			curl_setopt($curl, CURLOPT_SSL_VERIFYHOST, false);    //SSL 报错时使用
		}
		curl_setopt($curl, CURLOPT_POST, true);
		curl_setopt($curl, CURLOPT_POSTFIELDS, $body);
		curl_setopt($curl, CURLOPT_RETURNTRANSFER, 1);
		curl_setopt($curl, CURLOPT_HTTPHEADER,array('content-type: application/json;charset=utf-8','x-dyeing:424550','X-Sign:'.$sign.'','X-SignAlgorithm:1','X-Timestamp:'.$this->curtime.'','X-MerchantId:'.$this->merchantid.''));
		$result = curl_exec($curl);
		curl_close($curl);
		return $result;
	}
}