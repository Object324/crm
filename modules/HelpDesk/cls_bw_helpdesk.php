<?php
header('Content-type: text/html; charset=UTF8');
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Chj
 */
class cls_bw_helpdesk {
   
	private $helpDesk_data;
	public $db;
	public function __construct(){
		$this->db = PearDatabase::getInstance();
	}
	
	//是否同步帮我吧服务单
	public function is_sync_helpdesk(){
		$regop=RegOp::getInstance();
        $bwb_interface=$regop->GetbwbInterfaceStatus();
		$query = "select active from ld_settings_field where `name` = 'BANGWO8INTERFACE'";
		$result = $this->db->pquery($query,array());
		$active = $this->db->query_result($result,0,0);
		if($bwb_interface == 0 || $active == 1){
			return 'error';
		}else{
			$this->db->pquery('update ld_wx_config set switch = \'open\' where `name` = \'bw_helpdesk_time\' and switch = \'close\'',array());
		}
		$bwsync_data = $this->getBwSyncTime();
		if(!empty($bwsync_data)) {
			$current_time = time();
			if ($bwsync_data['switch'] == 'open' && $current_time >= ($bwsync_data['time_interval'] + $bwsync_data['time'])) {
				$helpDesk_data = $this->get_bw_helpdesk();
				if(!empty($helpDesk_data) && $helpDesk_data['errmsg'] == 'ok' && (!empty($helpDesk_data['remoteinfo']) || !empty($helpDesk_data['visitinfo']))){
					return 'success';
				}else{
					return 'error';
				}
			} else {
				return 'error';
			}
		}
	}
	
	public function getBwSyncTime(){
		$query = 'SELECT time,time_interval,switch FROM ld_wx_config WHERE name=\'bw_helpdesk_time\' LIMIT 1';
		$result = $this->db->pquery($query,array());
		$nums = $this->db->num_rows($result);
		if($nums > 0) {
			$data['time'] = $this->db->query_result($result, 0, 'time');
			$data['time_interval'] = $this->db->query_result($result, 0, 'time_interval');
			$data['switch'] = $this->db->query_result($result, 0, 'switch');
		}
		return $data;
	}
	//同步帮我吧服务单数据
	public function sync_helpdesk(){
		if(empty($this->helpDesk_data)){
			$this->get_bw_helpdesk();
		}
		$focus=CRMEntity::getInstance('HelpDesk');
        $this->setsavebyerrormsg('yes');//
		$supportnames = $this->getBwSupportname();
		$bwTicketNos = $this->getBwHelpDeskNo('');//获取帮我吧服务数据
		//同步帮我吧历史记录
		$query = 'select accountid from ld_account_bwid';
		$result = $this->db->pquery($query,array());
		$num_rows = $this->db->num_rows($result);
		if($num_rows <= 0){
			if(!empty($this->helpDesk_data['remoteinfo'])){//远程服务
				foreach($this->helpDesk_data['remoteinfo'] as $back_data){
					if(!empty($back_data['companyid'])){
						$query = 'select 1 from ld_account_bwid where accountid = ? and bw_id = ?';
						$result = $this->db->pquery($query,array($back_data['companyid'],$back_data['uniquenumber']));
						if($this->db->num_rows($result) < 1 && $back_data['companyid'] > 0){
							$query = 'insert into ld_account_bwid(accountid,bw_id) values (?,?);';
							$this->db->pquery($query,array($back_data['companyid'],$back_data['uniquenumber']));
						}
					}
				}
			}
		}

		//同步数据
		if($this->helpDesk_data['errmsg'] == 'ok'){
			if(!empty($this->helpDesk_data['remoteinfo'])){//远程服务
				foreach($this->helpDesk_data['remoteinfo'] as $back_data){
					$focus->id  = '';
					$focus->record = '';
					//如果远程服务记录中 companyid 为空，则不同步该记录
					//if(empty($back_data['companyid']))continue;
					//如果帮我吧客服账号为空，则不同步该记录
					//if(empty($back_data['servicername']))continue;
					$ids = $this->getAccountidForClient($back_data['uniquenumber'],$back_data['contactor'],$back_data['servicername'],$back_data['contactmethod'],$supportnames);
					//如果companyname在CRM系统中无法找到对应的客户名称，则不同步该记录
					if(empty($ids['accountid']))continue;
					if(in_array($back_data['id'],$bwTicketNos)){
						$focus->mode = 'edit';
						$bwTicketRecord = array_keys($bwTicketNos,$back_data['id']);
						$focus->id = $bwTicketRecord[0];
						$focus->retrieve_entity_info($focus->id,"HelpDesk");
					}else{
						$focus->mode = '';
					}
					$focus->column_fields['account_id'] = $ids['accountid'];
					$focus->column_fields['contact_id'] = $ids['contactid'];
					$focus->column_fields['productcategory'] = $this->getAccountProductCategory($ids['accountid']);	//产品类别  默认取值客户的产品类别字段
					foreach($back_data as $bw_field => $bw_value){
						if($bw_field == 'remote'){	//CRM 服务方式
							if($bw_value == 0){
								$bw_value = '其他';
							}else{
								$bw_value = '远程';
							}
							$focus->column_fields['servicetype'] = $bw_value;
						}else if($bw_field == 'id'){	//$bw_field
							$focus->column_fields['ticket_no'] = $bw_value;
							$focus->column_fields['ticket_title'] = '帮我吧远程服务记录' . $bw_value;
						}else if($bw_field == 'stat'){
							if(empty($bw_value) && $back_data['isfinish'] == 1){
								$bw_value = 5;
							}
							if(empty($bw_value)){
								$ticketstatus = '无效的服务';
							}else{
								switch($bw_value){
									case '0':
									   $ticketstatus = '无效的服务';
									   break;
									case '5':
									   $ticketstatus = '服务完成';
									   break;
								}
							}
							$focus->column_fields['ticketstatus'] = $ticketstatus;
						}else if($bw_field == 'problem'){
							$focus->column_fields['ticketcategories'] = $bw_value;
						}else if($bw_field == 'btime'){
							$focus->column_fields['hopetime'] = substr($bw_value,0,10) . ' ' . substr($bw_value,-8);;
						}else if($bw_field == 'etime'){
							$focus->column_fields['realtime'] = substr($bw_value,0,10) . ' ' . substr($bw_value,-8);;
						}else if($bw_field == 'servicername'){
							if(empty($supportnames[$bw_value])){
								$focus->column_fields['assigned_user_id'] = 1;
								$focus->column_fields['creator'] = 1;
							}else{
								$focus->column_fields['assigned_user_id'] = $supportnames[$bw_value];
								$focus->column_fields['creator'] = $supportnames[$bw_value];	
							}
						}else if($bw_field == 'note'){
							$focus->column_fields['description'] = $bw_value;
						}else if($bw_field == 'problemsolution'){
							$focus->column_fields['solution'] = $bw_value;
						}else if($bw_field == 'price'){
							$focus->column_fields['fees'] = $bw_value;
						}
					}
					$beizhu = '';//备注
					//解决状态 0-没解决 1-解决
					$isfinish = '没解决';
					if($back_data['isfinish'] == 1){
						 $isfinish = '解决';
					}
					$beizhu .= "解决状态：$isfinish";
					//评分
					if(!empty($back_data['commentscore'])){
						switch($back_data['commentscore']){
							case '0':
							   $commentscore = '无评价';
							   break;
							case '1':
							   $commentscore = '差评';
							   break;
							case '3':
							   $commentscore = '中评';
							   break;
							case '5':
							   $commentscore = '好评';
							   break;
						}
						$beizhu .= "
						评分：$commentscore";
					}
					//评价
					if(!empty($back_data['comment'])){
						$comment = $back_data['comment'];
						$beizhu .=  "
						评价：$comment";
					}
					//支付状态
					if(!empty($back_data['paystat'])){
						switch($back_data['paystat']){
							case '0':
							   $paystat = '没支付';
							   break;
							case '1':
							   $paystat = '支付成功';
							   break;
							case '2':
							   $paystat = '支付失败';
							   break;
							case '3':
							   $paystat = '刚打开支付页面 更新记录';
							   break;
							case '4':
							   $paystat = '在线扣费成功';
							   break;
						}
						$beizhu .="
						支付状态：$paystat";
					}
					$focus->column_fields['createdtime'] = date('Y-m-d H:i:s');
					$focus->column_fields['beizhu'] = $beizhu;
					$focus->operate_api='api'; //表示是通过接口方式调用
					$_REQUEST['ticket_no'] = $back_data['id'];
					$sel_query = "select ticketid from ld_troubletickets where ticket_no = ? and deleted = 0";
					$sel_result = $this->db->pquery($sel_query,array($back_data['id']));
					if($this->db->num_rows($sel_result) >= 1){
						$crm_record = $this->db->query_result($sel_result,0,0);
						$focus->mode = 'edit';
						$focus->id = $crm_record;
						$focus->record = $crm_record;
					}
					$focus->save('HelpDesk');
					if($focus->mode == ''){
						$this->db->pquery('update ld_troubletickets set bw8_id = ? where ticketid = ?',array($back_data['id'],$focus->id));
					}
				}
			}
			//上门服务
			if(!empty($this->helpDesk_data['visitinfo'])){
				foreach($this->helpDesk_data['visitinfo'] as $back_data){
					//如果远程服务记录中 companyid 为空，则不同步该记录
					if(empty($back_data['companyid']))continue;
					//如果帮我吧客服账号为空，则不同步该记录
					//if(empty($back_data['servicername']))continue;
					$ids = $this->getAccountContactId($back_data['companyid'],$back_data['contactor'],$back_data['servicername'],'',$supportnames);
					//如果companyname在CRM系统中无法找到对应的客户名称，则不同步该记录
					if(empty($ids['accountid']))continue;
					if(in_array($back_data['id'],$bwTicketNos)){
						$focus->mode = 'edit';
						$bwTicketRecord = array_keys($bwTicketNos,$back_data['id']);
						$focus->id = $bwTicketRecord[0];
						$focus->retrieve_entity_info($focus->id,"HelpDesk");
					}else{
						$focus->mode = '';
					}
					$focus->column_fields['account_id'] = $ids['accountid'];
					$focus->column_fields['contact_id'] = $ids['contactid'];
					$focus->column_fields['servicetype'] = '上门';//服务方式默认上门
					$focus->column_fields['productcategory'] = $this->getAccountProductCategory($ids['accountid']);	//产品类别  默认取值客户的产品类别字段
					foreach($back_data as $bw_field => $bw_value){
						if($bw_field == 'id'){	//$bw_field
							$focus->column_fields['ticket_no'] = $bw_value;
							$focus->column_fields['ticket_title'] = '帮我吧派单服务记录' . $bw_value;
						}else if($bw_field == 'servicestate'){
							switch($bw_value){
								case '0':
								   $ticketstatus = '未处理';
								   break;
								case '1':
								   $ticketstatus = '处理中';
								   break;
								case '2':
								   $ticketstatus = '等待回应';
								   break;
								case '9':
								   $ticketstatus = '成功关闭';
								   break;
							}
							$focus->column_fields['ticketstatus'] = $ticketstatus;
						}else if($bw_field == 'problem'){
							$focus->column_fields['ticketcategories'] = $bw_value;
						}else if($bw_field == 'begintime'){
							
							$focus->column_fields['hopetime'] = substr($bw_value,0,10) . ' ' . substr($bw_value,-8);
						}else if($bw_field == 'endtime'){
							$focus->column_fields['realtime'] = substr($bw_value,0,10) . ' ' . substr($bw_value,-8);;
						}else if($bw_field == 'servicername'){
							if(empty($supportnames[$bw_value])){
								$focus->column_fields['assigned_user_id'] = 1;
								$focus->column_fields['creator'] = 1;
							}else{
								$focus->column_fields['assigned_user_id'] = $supportnames[$bw_value];
								$focus->column_fields['creator'] = $supportnames[$bw_value];	
							}
						}else if($bw_field == 'problemdescription'){
							$focus->column_fields['description'] = $bw_value;
						}else if($bw_field == 'problemsolution'){
							$focus->column_fields['solution'] = $bw_value;
						}else if($bw_field == 'servicefee'){
							$focus->column_fields['fees'] = $bw_value;
						}
					}
					$beizhu = '';
					//任务状态
					if($back_data['taskstate'] != ''){
						switch($back_data['taskstate']){
							case '0':
							   $taskstate = '正常';
							   break;
							case '1':
							   $taskstate = '申请取消服务单';
							   break;
							case '2':
							   $taskstate = '派单人员同意取消派单';
							   break;
							case '3':
							   $taskstate = '驳回';
							   break;
						}
						$beizhu .= "任务状态：$taskstate";
					}
					//接收派单时间
					if(!empty($back_data['acceptdatetime'])){
						$acceptdatetime = $back_data['acceptdatetime'];
						$beizhu .= "
						接收派单时间：$acceptdatetime";
					}
					//是否解决
					//解决状态 0-没解决 1-解决
					if($back_data['isfinish'] != ''){
						$isfinish = '没解决';
						if($back_data['isfinish'] == 1){
							 $isfinish = '解决';
						}
						$beizhu .= "
						解决状态：$isfinish";
					}
					$focus->column_fields['beizhu'] = $beizhu;
					$focus->operate_api='api'; //表示是通过接口方式调用；
					$_REQUEST['ticket_no'] = $back_data['id'];
					$focus->save('HelpDesk');
					if($focus->mode == ''){
						$this->db->pquery('update ld_troubletickets set bw8_id = ? where ticketid = ?',array($back_data['id'],$focus->id));
					}
				}
			}
			$current_time = time();
			$updateSql = 'UPDATE ld_wx_config SET time=? WHERE name=\'bw_helpdesk_time\'';
			$this->db->pquery($updateSql, array($current_time));
			echo 'success';die;
		}
	}

	//获取客户的产品类别字段信息
	private function getAccountProductCategory($accountid){
		if(!empty($accountid)){
			$query = 'select productcategory from ld_account where accountid = ?';
			$result = $this->db->pquery($query,array($accountid));
			if($this->db->num_rows($result) >= 1){
				return $this->db->query_result($result,0,'productcategory');
			}
		}
		return '';
	}
	//获取帮我吧数据
	public function get_bw_helpdesk($getAll = ''){
		$today = date('Y-m-d H:i:s');
		$bwTicketNos = $this->getBwHelpDeskNo('');//获取帮我吧服务数据
		$query = 'SELECT vendorid,Authcode from ld_bangwo8 where presence = 0';
		$result = $this->db->pquery($query,array());
		$vendorid = $this->db->query_result($result,0,0);
		$authcode = $this->db->query_result($result,0,1);
		$bw_data['vendorID']=$vendorid;
		$bwsync_data = $this->getBwSyncTime();
		if(empty($bwTicketNos) || !empty($getAll)){
			$bw_data['starttime'] = '1600-01-01';
			$bw_data['endtime'] = date("Y-m-d",strtotime("+1 day"));//今天
		}else{
			$bw_data['starttime'] = date("Y-m-d H:i:s", $bwsync_data['time']);	//  上次更新时间
			//$bw_data['starttime'] = date('Y-m-d H:i:s',time()-$bwsync_data['time_interval']);;
			$bw_data['endtime'] = date("Y-m-d H:i:s",strtotime("+1 day"));
		}
		$data=json_encode($bw_data);
		$urlcon='https://www.bangwo8.com/api/apiGetAllCustServers.php?authcode='.$authcode;
		$ch = curl_init($urlcon); //请求的URL地址
		curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "POST");
		curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false); //不验证证书
		curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, false); //不验证证书
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
		curl_setopt($ch, CURLOPT_POSTFIELDS, $data);//$data JSON类型字符串
		curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type: application/json', 'Content-Length: ' . strlen($data)));
		$ret_data = curl_exec($ch);
		$helpDesk_data = $this->enjson($ret_data);
		$helpDesk_data = stripslashes($helpDesk_data);
		$helpDesk_data = preg_replace('/\s/', '', $helpDesk_data);
		$this->helpDesk_data = $this->dejson($helpDesk_data);
		//如果返回值是对象则返回数组格式
		if(is_object($this->helpDesk_data)){
			$this->helpDesk_data = $this->object_array($this->helpDesk_data);
		}
		return $this->helpDesk_data;
	}
	
	//获取已同步到crm的帮我吧数据
	private function getBwHelpDeskNo($today){
		$ticket_no = array();
		$query = 'select ticket_no,ticketid,bw8_id from ld_troubletickets ';
		if(!empty($today)){
			$query .= 'where deleted = 0 and createdtime < "'.$today.'" and bw8_id > 0';
		}else{
			$query .= 'where deleted = 0 and bw8_id > 0';
		}
		$result = $this->db->pquery($query,array());
		$num_rows = $this->db->num_rows($result);
		if($num_rows >= 1){
			for($i = 0; $i<$num_rows; $i++){
				$ticketid = $this->db->query_result($result,$i,'ticketid');
				$ticket_no[$ticketid] = $this->db->query_result($result,$i,'bw8_id');
			}
		}
		return $ticket_no;
	}

	private function enjson($code){
		$code = json_encode($this->urlencodeAry($code));
		return urldecode($code);
	}
	
	private function urlencodeAry($data){
		if(is_array($data)){
			foreach($data as $key=>$val){
				$data[$key] = $this->urlencodeAry($val);
			}
			return $data;
		}
		else{
			return urlencode($data);
		}
	}

	private function dejson($str){
		$str = str_replace("\\", '\\\\', $str);
		$str = str_replace("\r\n", '\n', $str);
		//经测试在5.4版本下，也会存在返回值为空格的问题。
		$str = preg_replace('/\s/','', $str);
		$str=substr($str,1,strlen($str)-2);
		return json_decode($str);
	}

	private function object_array($array) { 
		if(is_object($array)) { 
			$array = (array)$array; 
		} if(is_array($array)) { 
			foreach($array as $key=>$value) { 
				$array[$key] = $this->object_array($value); 
			} 
		} 
		return $array; 
	}

	//获取所有账套和对应的用户id
	private function getBwSupportname(){
		$query = 'select operate_smownerid,supportname from ld_bangwo8_supportname';
		$result = $this->db->pquery($query,array());
		$num_rows = $this->db->num_rows($result);
		for($i = 0; $i<$num_rows; $i++){
			$supportname = $this->db->query_result($result,$i,'supportname');
			$res[$supportname] = $this->db->query_result($result,$i,'operate_smownerid');
		}
		return $res;
	}
	
	//根据9位ID获取对应的客户ID
	private function getAccountidForClient($clientid,$contact_lastname,$servicername,$contactmethod,$supportnames){
		$query = 'select accountid from ld_account_bwid where bw_id = ? ORDER BY id desc limit 1';
		$result = $this->db->pquery($query,array($clientid));
		$num_rows = $this->db->num_rows($result);
		if($num_rows >= 1){
			$accountid = $this->db->query_result($result,0,'accountid');
			$res['accountid'] = $accountid;
			if(!empty($contact_lastname)){
				$query = 'select contactid from ld_contactdetails where accountid = ? and lastname = ? limit 1';
				$result = $this->db->pquery($query,array($accountid,$contact_lastname));
				$num_rows = $this->db->num_rows($result);
				if($num_rows >= 1){
					$res['contactid'] = $this->db->query_result($result,0,0);
				}
			}else{
				$query = 'select contactid from ld_contactdetails where accountid = ? and reference = 1';
				$result = $this->db->pquery($query,array($accountid));
				$num_rows = $this->db->num_rows($result);
				if($num_rows >= 1){
					$res['contactid'] = $this->db->query_result($result,0,'contactid');
				}
			}
		}
		return $res;
	}
	//获取客户联系人id
	private function getAccountContactId($accountid,$contact_lastname,$servicername,$contactmethod,$supportnames){
		$res = array('accountid'=>'','contactid'=>'');
		$contact_focus=CRMEntity::getInstance('Contacts');
		$query = 'select 1 from ld_account where accountid = ? limit 1';
		$result = $this->db->pquery($query,array($accountid));
		$num_rows = $this->db->num_rows($result);
		if($num_rows == 1){
			$res['accountid'] = $accountid;
			if(!empty($contact_lastname)){
				$query = 'select contactid from ld_contactdetails where accountid = ? and lastname = ? limit 1';
				$result = $this->db->pquery($query,array($accountid,$contact_lastname));
				$num_rows = $this->db->num_rows($result);
				if($num_rows >= 1){
					$res['contactid'] = $this->db->query_result($result,0,0);
				}
			}
		}
		return $res;
	}
}
?>