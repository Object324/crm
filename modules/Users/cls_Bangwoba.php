<?php


class cls_Bangwoba
{
	public $version_account;
    public $bw_username;
    public $bw_password;
    public function __construct()
    {
        $BangwoSupportInfo = $this->getBangwoSupportName();
		$this->bw_username = $BangwoSupportInfo['supportname'];
		$this->bw_password = $BangwoSupportInfo['pwd'];

        $this->version_account = getVersionInfo()['account'];
    }
	
	//同步客户和联系人
	public function SyncAccountsAndContacts(){
		$account_info = $this->getAccountInfo('');
		if(!empty($account_info)){
			foreach($account_info as $accountid => $acc_info){
				//同步客户
				$sync_acc = $this->SyncAccounts($accountid,$acc_info);
				if($sync_acc > 0){
					$contact_info = $this->getContactsInfo('',$accountid);
					if(!empty($contact_info)){
						foreach($contact_info as $contactid => $con_info){
							//同步联系人
							$this->SyncContacts($contactid,$con_info);
						}
					}
				}
			}
		}
	}
	
	//添加、更新客户  -  帮我吧
	public function setAccountToBangwoba($accountid,$mode){
		if(!empty($accountid)){
			$account_info = $this->getAccountInfo($accountid);
			if(!empty($account_info)){
				foreach($account_info as $accountid => $acc_info){
					//同步添加客户
					if(empty($acc_info['bw_id']))
						$this->SyncAccounts($accountid,$acc_info);
					else
						$this->UpdateSyncAccounts($accountid,$acc_info);
				}
			}
		}
	}
	
	//添加、更新联系人  -  帮我吧
	public function setContactsToBangwoba($contactid,$mode){
		if(!empty($contactid)){
			$contact_info = $this->getContactsInfo($contactid);
			if(!empty($contact_info)){
				foreach($contact_info as $contactid => $con_info){
					//同步联系人
					if(empty($con_info['bw_id']))
						$this->SyncContacts($contactid,$con_info);
					else
						$this->UpdateSyncContacts($contactid,$con_info);
				}
			}
		}
	}

	//同步添加客户
	public function SyncAccounts($accountid,$acc_info){
		global $adb,$current_user;
        $data = urlencode('companyName:'.$acc_info['accountname']);
        $url='https://www.bangwo8.com/api/v1/companies/search.json?query='.$data;
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
        curl_setopt($ch, CURLOPT_HEADER, 0);
        curl_setopt($ch, CURLOPT_TIMEOUT,5); //只需要设置一个秒的数量就可以
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
        curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, false); //不验证证书
        curl_setopt($ch, CURLOPT_USERPWD, "".$this->bw_username.":".$this->bw_password."");
        $ret_data = json_decode(curl_exec($ch));


        $uId = 0;
        if($ret_data->count >= 1){
            $count = $ret_data->count;
            if($count > 1){
                $key = $count - 1;
                $uId = $ret_data->results[$key]->uId;
            }else{
                $uId = $ret_data->results[0]->uId;
            }
        }
        if($uId > 0){
            $acc_info['bw_id'] = $uId;
            $this->UpdateSyncAccounts($accountid,$acc_info);
            //反写客户，更新同步到帮我吧客户的id
            $query = 'update ld_account set bw_id = ? where accountid = ?';
            $adb->pquery($query,array($uId,$accountid));
            return $ret_data->company->uId;
        }else{
            if(!empty($accountid) && !empty($acc_info)){
                $url='https://www.bangwo8.com/api/v1/companies.json';
                $ch = curl_init(); //请求的URL地址
                curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "POST");
                curl_setopt($ch, CURLOPT_URL, $url);
                curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false); //不验证证书
                curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, false); //不验证证书
                curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
                curl_setopt($ch, CURLOPT_HTTPAUTH, CURLAUTH_BASIC);
                curl_setopt($ch, CURLOPT_USERPWD, "".$this->bw_username.":".$this->bw_password."");
                $campany_info['company']['companyName'] = $acc_info['accountname'];
                $campany_info['company']['servicestarttime'] = $acc_info['createdtime'];
                $campany_info['company']['serviceendtime'] = $acc_info['lastservicedate'];
                $campany_info['company']['address'] = $acc_info['bill_street'];
                if ($this->version_account == 'shuntongda') {
                    $campany_info['company']['userGroup'] = $acc_info['important_level'];
                }
                $campany_info['company']['userGroup'] = $acc_info['important_level'];
                $data=json_encode($campany_info);
                curl_setopt($ch, CURLOPT_POSTFIELDS, $data);//$data JSON类型字符串
                curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type: application/json', 'Content-Length: ' . strlen($data)));

                $ret_data = json_decode(curl_exec($ch));
                /*if($accountid == '11124'){
                    echo $this->bw_username;die;
                    echo '<pre>';
                    print_r($campany_info);
                    echo '</pre>';
                    echo '<pre>';
                    print_r($ret_data);
                    echo '</pre>';
                    *die;
                }*/
                //同步成功
                if(!empty($ret_data->company->uId)){
                    //反写客户，更新同步到帮我吧客户的id
                    $query = 'update ld_account set bw_id = ? where accountid = ?';
                    $adb->pquery($query,array($ret_data->company->uId,$accountid));
                    return $ret_data->company->uId;
                }
            }
        }
        return 0;

	}

	//同步更新客户
	public function UpdateSyncAccounts($accountid,$acc_info){
		global $adb;
		if(!empty($accountid) && !empty($acc_info)){
			if(empty($acc_info['bw_id'])){
				//echo $acc_info['accountname'];
				$data = urlencode('companyName:'.$acc_info['accountname']);
				$url='https://www.bangwo8.com/api/v1/companies/search.json?query='.$data;
				$ch = curl_init();
				curl_setopt($ch, CURLOPT_URL, $url);
				curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
				curl_setopt($ch, CURLOPT_HEADER, 0);
				curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
				curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, false); //不验证证书
				curl_setopt($ch, CURLOPT_USERPWD, "".$this->bw_username.":".$this->bw_password."");
				$ret_data = json_decode(curl_exec($ch));
				$uId = 0;
				if($ret_data->count >= 1){
					$count = $ret_data->count;
					if($count > 1){
						$key = $count - 1;
						$acc_info['bw_id'] = $ret_data->results[$key]->uId;
					}else{
						$acc_info['bw_id'] = $ret_data->results[0]->uId;
					}
				}
			}
			$url='https://www.bangwo8.com/api/v1/companies/'.$acc_info['bw_id'].'.json';
			$ch = curl_init(); //请求的URL地址
			curl_setopt($ch, CURLOPT_CUSTOMREQUEST, 'PUT');
			curl_setopt($ch, CURLOPT_URL, $url);
			curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false); //不验证证书
			curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, false); //不验证证书
			curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
			curl_setopt($ch, CURLOPT_HTTPAUTH, CURLAUTH_BASIC);
			curl_setopt($ch, CURLOPT_USERPWD, "".$this->bw_username.":".$this->bw_password."");
			$campany_info['company']['companyName'] = $acc_info['accountname'];
			$campany_info['company']['servicestarttime'] = $acc_info['createdtime'];
			$campany_info['company']['serviceendtime'] = $acc_info['lastservicedate'];
			$campany_info['company']['address'] = $acc_info['bill_street'];
            if ($this->version_account == 'shuntongda') {
                $campany_info['company']['userGroup'] = $acc_info['important_level'];
            }
			$data=json_encode($campany_info);
			//curl_setopt($ch,CURLOPT_HTTPHEADER,array("X-HTTP-Method-Override: PUT"));//设置HTTP头信息  
			curl_setopt($ch, CURLOPT_POSTFIELDS, $data);//设置提交的字符串  
			curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type: application/json', 'Content-Length: ' . strlen($data)));
			$ret_data = json_decode(curl_exec($ch));
			if(!empty($ret_data) && $ret_data->status == '110030'){
				$this->SyncAccounts($accountid,$acc_info);
			}
		}
		return 0;
	}

	//同步添加联系人
	public function SyncContacts($contactid,$con_info){
		global $adb;
		if(!empty($contactid) && !empty($con_info)){
			$url='https://www.bangwo8.com/api/v1/users.json';
			$ch = curl_init(); //请求的URL地址
			curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "POST");
			curl_setopt($ch, CURLOPT_URL, $url);
			curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false); //不验证证书
			curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, false); //不验证证书
			curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
			curl_setopt($ch, CURLOPT_HTTPAUTH, CURLAUTH_BASIC);
			curl_setopt($ch, CURLOPT_USERPWD, "".$this->bw_username.":".$this->bw_password."");
			$info['user']['name'] = $con_info['lastname'];
			$info['user']['mobile'] = $con_info['mobile'];
			$info['user']['fixnumber'] = $con_info['pphone'];
			$info['user']['companyId'] = $con_info['bw_accountid'];
			$info['user']['QQ'] = $con_info['qq'];
			$info['user']['position'] = $con_info['title'];
			$info['user']['note'] = $con_info['description'];
			$info['user']['default'] = $con_info['reference'];
			$data=json_encode($info);
			curl_setopt($ch, CURLOPT_POSTFIELDS, $data);//$data JSON类型字符串
			curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type: application/json', 'Content-Length: ' . strlen($data)));
			$ret_data = json_decode(curl_exec($ch));
			//同步成功
			if(!empty($ret_data->user->cId)){
				//反写客户，更新同步到帮我吧客户的id
				$query = 'update ld_contactdetails set bw_id = ? where contactid = ?';
				$adb->pquery($query,array($ret_data->user->cId,$contactid));
				return $ret_data->user->cId;
			}
		}
	}

	//更新联系人
	public function UpdateSyncContacts($contactid,$con_info){
		global $adb;
		if(!empty($contactid) && !empty($con_info)){
			$url='https://www.bangwo8.com/api/v1/users/'.$con_info['bw_id'].'.json';
			$ch = curl_init(); //请求的URL地址
			curl_setopt($ch, CURLOPT_CUSTOMREQUEST, 'PUT');
			curl_setopt($ch, CURLOPT_URL, $url);
			curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false); //不验证证书
			curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, false); //不验证证书
			curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
			curl_setopt($ch, CURLOPT_HTTPAUTH, CURLAUTH_BASIC);
			curl_setopt($ch, CURLOPT_USERPWD, "".$this->bw_username.":".$this->bw_password."");
			$info['user']['name'] = $con_info['lastname'];
			$info['user']['mobile'] = $con_info['mobile'];
			$info['user']['fixnumber'] = $con_info['pphone'];
			$info['user']['companyId'] = $con_info['bw_accountid'];
			$info['user']['QQ'] = $con_info['qq'];
			$info['user']['position'] = $con_info['title'];
			$info['user']['note'] = $con_info['description'];
			$info['user']['default'] = $con_info['reference'];
			$data=json_encode($info);
			curl_setopt($ch,CURLOPT_HTTPHEADER,array("X-HTTP-Method-Override: PUT"));//设置HTTP头信息  
			curl_setopt($ch, CURLOPT_POSTFIELDS, $data);//设置提交的字符串  
			$ret_data = curl_exec($ch);
		}
	}
	
	//获取客户信息
	public function getAccountInfo($accountid = ''){
		global $adb;
        $query = 'select DISTINCT accountname,lastservicedate,DATE_FORMAT(ld_account.createdtime,\'%Y-%m-%d\') as createdtime,bill_street,ld_accountscf.important_level,ld_account.accountid,ld_account.bw_id from ld_account 
    LEFT JOIN ld_accountscf on ld_accountscf.accountid = ld_account.accountid 
    LEFT JOIN ld_contactdetails on ld_contactdetails.accountid = ld_account.accountid';
        if(!empty($accountid)){
            $query .= ' where ld_account.deleted = 0 and ld_account.accountid = ' . $accountid;
        }else{
            $query .= ' where ld_account.deleted = 0 ';
            $query .= ' and ld_account.bw_id <= 0 ';
        }
        $advfilterlist = $this->getAdvFilterByCvidRemind();
        if(!empty($advfilterlist[1]['columns'])){
            $query .= ' and (';
            foreach($advfilterlist[1]['columns'] as $arr){
                $col = explode(':',$arr['columnname']);
                if ($col[4] == 'D' || ($col[4] == 'T' && $col[1] != 'time_start' && $col[1] != 'time_end') || ($col[4] == 'DT')) {
                    $datefilter = $this->getDateforautoStdFilterBytype($arr["comparator"]);
                    $stdfilterlist["startdate"] = $datefilter[0] . ' ' . "00:00:00";
                    $stdfilterlist["enddate"] = $datefilter[1] . ' ' . "23:59:59";
                    $query .= $col[0].'.'.$col[1].' between "' . $stdfilterlist["startdate"] . '" and "' . $stdfilterlist["enddate"] . '" ' . $arr['column_condition']. ' ';
                }else{
                    $datefilter = $this->getAdvComparator($arr["comparator"],$arr["value"]);
                    $query .= $col[0].'.'.$col[1] . $datefilter .  ' ' .$arr['column_condition']. ' ';
                }
            }
            $query .= ')';
        }
        if(empty($accountid)){
            $query .= ' ORDER BY ld_account.createdtime desc';
        }
        $result = $adb->pquery($query,array());
        $num_rows = $adb->num_rows($result);
        if($num_rows >= 1){
            for($i = 0; $i<$num_rows; $i++){
                $accountname = $adb->query_result($result,$i,'accountname');	//客户名称
                $lastservicedate = $adb->query_result($result,$i,'lastservicedate');	//最晚服务到日期
                $createdtime = $adb->query_result($result,$i,'createdtime');	//创建时间
                $bill_street = $adb->query_result($result,$i,'bill_street');	//地址
                $important_level = $adb->query_result($result,$i,'important_level');	//客户分组
                $accountid = $adb->query_result($result,$i,'accountid');
                $bw_id = $adb->query_result($result,$i,'bw_id');
                if(empty($lastservicedate))$lastservicedate = '0000-00-00';
                if(empty($createdtime))$createdtime = '0000-00-00';
                $acc_data[$accountid] = array(
                    'accountname' => $accountname,
                    'lastservicedate' => $lastservicedate,
                    'createdtime' => $createdtime,
                    'bill_street' => $bill_street,
                    'important_level' => $important_level,
                    'bw_id' => $bw_id,
                );
            }
        }

        return $acc_data;

	}

	//获取联系人信息
	public function getContactsInfo($contactid = '',$accountid = ''){
		global $adb;
		if(!empty($contactid) || !empty($accountid)){
			$query = 'SELECT
				lastname,
				mobile,
				pphone,
				title,
				ld_contactscf.qq,
				ld_contactdetails.contactid,
				ld_contactdetails.description,
				ld_contactdetails.reference,
				ld_contactdetails.accountid,
				ld_account.bw_id as account_bw_id,
				ld_contactdetails.bw_id
			FROM
				ld_contactdetails
			LEFT JOIN ld_account on ld_account.accountid = ld_contactdetails.accountid
			LEFT JOIN ld_contactscf ON ld_contactscf.contactid = ld_contactdetails.contactid';
			if(!empty($accountid) && empty($contactid)){
				$query .= ' WHERE ld_contactdetails.accountid = ' . $accountid;
			}else{
				$query .= ' WHERE ld_contactdetails.contactid = ' . $contactid;
			}

			$result = $adb->pquery($query,array());
			$num_rows = $adb->num_rows($result);
			if($num_rows >= 1){
				for($i = 0; $i<$num_rows; $i++){
					$contactid = $adb->query_result($result,$i,'contactid');
					$con_data[$contactid]['lastname'] = $adb->query_result($result,$i,'lastname');	//联系人姓名
					$con_data[$contactid]['mobile'] = $adb->query_result($result,$i,'mobile');	//手机
					$con_data[$contactid]['pphone'] = $adb->query_result($result,$i,'pphone');	//座机
					$con_data[$contactid]['title'] = $adb->query_result($result,$i,'title');	//职务
					$con_data[$contactid]['qq'] = $adb->query_result($result,$i,'qq');	//QQ
					$con_data[$contactid]['description'] = $adb->query_result($result,$i,'description');	//备注
					$con_data[$contactid]['reference'] = $adb->query_result($result,$i,'reference');	//首要联系人
					$con_data[$contactid]['bw_accountid'] = $adb->query_result($result,$i,'account_bw_id');	//联系人关联的客户名称  account_bw_id
					$con_data[$contactid]['bw_id'] = $adb->query_result($result,$i,'bw_id');	//联系人bw_id

				}
			}
			return $con_data;
		}
	}
	
	//数据范围
	public function getAdvFilterByCvidRemind() {

		global $adb,  $default_charset;

		$advft_criteria = array();

		$sql = 'SELECT * FROM ld_bangwobacvadvfilter_grouping WHERE id = 1 ORDER BY groupid';
		$groupsresult = $adb->pquery($sql, array());
		$i = 1;
		$j = 0;
		while ($relcriteriagroup = $adb->fetch_array($groupsresult)) {
			$groupId = $relcriteriagroup["groupid"];
			$groupCondition = $relcriteriagroup["group_condition"];

			$ssql = 'select ld_bangwobacvadvfilter.* from ld_bangwobacvadvfilter
						left join ld_bangwobacvadvfilter_grouping on ld_bangwobacvadvfilter.id = ld_bangwobacvadvfilter_grouping.id
								';
			$ssql.= " where ld_bangwobacvadvfilter.id = ? AND ld_bangwobacvadvfilter.groupid = ? order by ld_bangwobacvadvfilter.columnindex";

			$result = $adb->pquery($ssql, array(1, $groupId));
			
			$noOfColumns = $adb->num_rows($result);
			if ($noOfColumns <= 0)
				continue;

			while ($relcriteriarow = $adb->fetch_array($result)) {
				$columnIndex = $relcriteriarow["columnindex"];
				$criteria = array();
				$criteria['columnname'] = html_entity_decode($relcriteriarow["columnname"], ENT_QUOTES, $default_charset);
				$criteria['comparator'] = $relcriteriarow["comparator"];
				$advfilterval = html_entity_decode($relcriteriarow["value"], ENT_QUOTES, $default_charset);
				$col = explode(":", $relcriteriarow["columnname"]);
				$temp_val = explode(",", $relcriteriarow["value"]);
				if ($col[4] == 'D' || ($col[4] == 'T' && $col[1] != 'time_start' && $col[1] != 'time_end') || ($col[4] == 'DT')) {
					 crm_load_class_file("DateTimeField","include/fields");
					$val = Array();
					for ($x = 0; $x < count($temp_val); $x++) {
						if ($col[4] == 'D') {
							$date = new DateTimeField(trim($temp_val[$x]));
							$val[$x] = $date->getDisplayDate();
						} elseif ($col[4] == 'DT') {
							$date = new DateTimeField(trim($temp_val[$x]));
							$val[$x] = $date->getDisplayDateTimeValue();
						} else {
							$date = new DateTimeField(trim($temp_val[$x]));
							$val[$x] = $date->getDisplayTime();
						}
					}
					$advfilterval = implode(",", $val);
				}
				$criteria['value'] = $advfilterval;
				$criteria['column_condition'] = $relcriteriarow["column_condition"];

				$advft_criteria[$i]['columns'][$j] = $criteria;
				$advft_criteria[$i]['condition'] = $groupCondition;
				$j++;
			}
			if (!empty($advft_criteria[$i]['columns'][$j - 1]['column_condition'])) {
				$advft_criteria[$i]['columns'][$j - 1]['column_condition'] = '';
			}
			$i++;
		}
		// Clear the condition (and/or) for last group, if any.
		if (!empty($advft_criteria[$i - 1]['condition']))
			$advft_criteria[$i - 1]['condition'] = '';
		return $advft_criteria;
	}

	private function getBangwoSupportName(){
		global $adb;
		$query = 'select supportname,supportpwd from ld_bangwo8_supportname where supportpwd != "" limit 1';
		$result = $adb->pquery($query,array());
		if($adb->num_rows($result) >= 1){
			$data = array(
				'supportname' => $adb->query_result($result,0,'supportname'),
				'pwd' => $adb->query_result($result,0,'supportpwd'),
			);
		}
		return $data;
	}

	private function getAdvComparator($comparator,$value,$datatype="")
	{

		global $adb,$default_charset,$ogReport;
		$value=html_entity_decode(trim($value),ENT_QUOTES,$default_charset);
		$value_len = strlen($value);
		$is_field = false;
		if($value_len > 1 && $value[0]=='$' && $value[$value_len-1]=='$'){
			$temp = str_replace('$','',$value);
			$is_field = true;
		}
		if($datatype=='C'){
			$value = str_replace("yes","1",str_replace("no","0",$value));
		}

		if($is_field==true){
		//	$value = $this->getFilterComparedField($temp);
		}
		if($comparator == "e")
		{
			if(trim($value) == "NULL")
			{
				$rtvalue = " is NULL";
			}elseif(trim($value) != "")
			{
				$rtvalue = " = ".$adb->quote($value);
			}elseif(trim($value) == "" && $datatype == "V")
			{
				$rtvalue = " = ".$adb->quote($value);
			}else
			{
				$rtvalue = " is NULL";
			}
		}
		if($comparator == "n")
		{
			if(trim($value) == "NULL")
			{
				$rtvalue = " is NOT NULL";
			}elseif(trim($value) != "")
			{
				$rtvalue = " <> ".$adb->quote($value);
			}elseif(trim($value) == "" && $datatype == "V")
			{
				$rtvalue = " <> ".$adb->quote($value);
			}else
			{
				$rtvalue = " is NOT NULL";
			}
		}
		if($comparator == "s")
		{
			$rtvalue = " like '". formatForSqlLike($value, 2,$is_field) ."%'";
		}
		if($comparator == "ew")
		{
			$rtvalue = " like '%". formatForSqlLike($value, 1,$is_field) ."'";
		}
		if($comparator == "c")
		{
			$rtvalue = " like '%". formatForSqlLike($value,0,$is_field) ."%'";
		}
		if($comparator == "k")
		{
			$rtvalue = " not like '%". formatForSqlLike($value,0,$is_field) ."%'";
		}
		if($comparator == "l")
		{
			$rtvalue = " < ".$adb->quote($value);
		}
		if($comparator == "g")
		{
			$rtvalue = " > ".$adb->quote($value);
		}
		if($comparator == "m")
		{
			$rtvalue = " <= ".$adb->quote($value);
		}
		if($comparator == "h")
		{
			$rtvalue = " >= ".$adb->quote($value);
		}
		if($comparator == "b") {
			$rtvalue = " < ".$adb->quote($value);
		}
		if($comparator == "a") {
			$rtvalue = " > ".$adb->quote($value);
		}
		if($comparator == "isnull") {
			$rtvalue = " = ".$adb->quote($value);
		}
		if($comparator == "isnotnull") {
			$rtvalue = " <> ".$adb->quote($value);
		}
		if($is_field==true){
			$rtvalue = str_replace("'","",$rtvalue);
			$rtvalue = str_replace("\\","",$rtvalue);
		}
	
		return $rtvalue;
	}
	 /**
	 * 获取基本查询自定义条件信息
	 * */
	private function getDateforautoStdFilterBytype($type) {
		
		$thisyear = date("Y");
		$today = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d"), date("Y")));
		$tomorrow = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 1, date("Y")));
		$syesterday = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 1, date("Y")));

		$currentmonth0 = date("Y-m-d", mktime(0, 0, 0, date("m"), "01", date("Y")));
		$currentmonth1 = date("Y-m-t");
		$lastmonth0 = date("Y-m-d", mktime(0, 0, 0, date("m") - 1, "01", date("Y")));
		$lastmonth1 = date("Y-m-t", strtotime("-1 Month"));
		$nextmonth0 = date("Y-m-d", mktime(0, 0, 0, date("m") + 1, "01", date("Y")));
		$nextmonth1 = date("Y-m-t", strtotime("+1 Month"));

		$lastweek0 = date("Y-m-d", strtotime("-2 week Sunday"));
		$lastweek1 = date("Y-m-d", strtotime("-1 week Saturday"));

		$thisweek0 = date("Y-m-d", strtotime("-1 week Sunday"));
		$thisweek1 = date("Y-m-d", strtotime("this Saturday"));

		$nextweek0 = date("Y-m-d", strtotime("this Sunday"));
		$nextweek1 = date("Y-m-d", strtotime("+1 week Saturday"));
		$next3days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 2, date("Y")));
		$next7days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 6, date("Y")));
		$next15days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 14, date("Y")));
		$next30days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 29, date("Y")));
		$next60days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 59, date("Y")));
		$next90days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 89, date("Y")));
		$next120days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 119, date("Y")));
		$next180days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 179, date("Y")));
		$last1days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 0, date("Y")));
		$last2days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 1, date("Y")));
		$last3days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 2, date("Y")));
		$last4days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 3, date("Y")));
		$last5days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 4, date("Y")));
		$last6days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 5, date("Y")));
		$last7days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 6, date("Y")));
		$last8days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 7, date("Y")));
		$last9days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 8, date("Y")));
		$last10days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 9, date("Y")));
		$last11days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 10, date("Y")));
		$last12days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 11, date("Y")));
		$last13days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 12, date("Y")));
		$last14days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 13, date("Y")));
		$last15days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 14, date("Y")));
		$last30days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 29, date("Y")));
		$last60days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 59, date("Y")));
		$last90days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 89, date("Y")));
		$last120days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 119, date("Y")));
		$last180days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 179, date("Y")));
		
		$defaultStartDate='1960-01-01';
		$defaultEndDate='9999-12-31';
		$after1days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 0, date("Y")));
		$after2days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 1, date("Y")));
		$after3days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 2, date("Y")));
		$after4days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 3, date("Y")));
		$after5days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 4, date("Y")));
		$after4days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 5, date("Y")));
		$after7days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 6, date("Y")));
		$after8days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 7, date("Y")));
		$after9days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 8, date("Y")));
		$after10days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 9, date("Y")));
		$after11days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 10, date("Y")));
		$after12days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 11, date("Y")));
		$after13days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 12, date("Y")));
		$after14days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 13, date("Y")));
		$after15days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 14, date("Y")));
		$after30days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 29, date("Y")));
		$after60days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 59, date("Y")));
		$after90days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 89, date("Y")));
		$after120days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 119, date("Y")));
		$after180days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 179, date("Y")));
	  
		$before0days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 0, date("Y")));
		$before3days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 2, date("Y")));
		$before7days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 6, date("Y")));
		$before15days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 14, date("Y")));
		$before30days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 29, date("Y")));
		$before60days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 59, date("Y")));
		$before90days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 89, date("Y")));
		$before120days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 119, date("Y")));
		$before120days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 179, date("Y")));

		$currentFY0 = date("Y-m-d", mktime(0, 0, 0, "01", "01", date("Y")));
		$currentFY1 = date("Y-m-t", mktime(0, 0, 0, "12", date("d"), date("Y")));
		$lastFY0 = date("Y-m-d", mktime(0, 0, 0, "01", "01", date("Y") - 1));
		$lastFY1 = date("Y-m-t", mktime(0, 0, 0, "12", date("d"), date("Y") - 1));
		$nextFY0 = date("Y-m-d", mktime(0, 0, 0, "01", "01", date("Y") + 1));
		$nextFY1 = date("Y-m-t", mktime(0, 0, 0, "12", date("d"), date("Y") + 1));

		if (date("m") <= 4) {
			$cFq = date("Y-m-d", mktime(0, 0, 0, "01", "01", date("Y")));
			$cFq1 = date("Y-m-d", mktime(0, 0, 0, "04", "30", date("Y")));
			$nFq = date("Y-m-d", mktime(0, 0, 0, "05", "01", date("Y")));
			$nFq1 = date("Y-m-d", mktime(0, 0, 0, "08", "31", date("Y")));
			$pFq = date("Y-m-d", mktime(0, 0, 0, "09", "01", date("Y") - 1));
			$pFq1 = date("Y-m-d", mktime(0, 0, 0, "12", "31", date("Y") - 1));
		} else if (date("m") > 4 and date("m") <= 8) {
			$pFq = date("Y-m-d", mktime(0, 0, 0, "01", "01", date("Y")));
			$pFq1 = date("Y-m-d", mktime(0, 0, 0, "04", "30", date("Y")));
			$cFq = date("Y-m-d", mktime(0, 0, 0, "05", "01", date("Y")));
			$cFq1 = date("Y-m-d", mktime(0, 0, 0, "08", "31", date("Y")));
			$nFq = date("Y-m-d", mktime(0, 0, 0, "09", "01", date("Y")));
			$nFq1 = date("Y-m-d", mktime(0, 0, 0, "12", "31", date("Y")));
		} else {
			$nFq = date("Y-m-d", mktime(0, 0, 0, "01", "01", date("Y") + 1));
			$nFq1 = date("Y-m-d", mktime(0, 0, 0, "04", "30", date("Y") + 1));
			$pFq = date("Y-m-d", mktime(0, 0, 0, "05", "01", date("Y")));
			$pFq1 = date("Y-m-d", mktime(0, 0, 0, "08", "31", date("Y")));
			$cFq = date("Y-m-d", mktime(0, 0, 0, "09", "01", date("Y")));
			$cFq1 = date("Y-m-d", mktime(0, 0, 0, "12", "31", date("Y")));
		}

		if ($type == "today") {

			$datevalue[0] = $today;
			$datevalue[1] = $today;
		} elseif ($type == "syesterday") {

			$datevalue[0] = $syesterday;
			$datevalue[1] = $syesterday;
		} elseif ($type == "tomorrow") {

			$datevalue[0] = $tomorrow;
			$datevalue[1] = $tomorrow;
		} elseif ($type == "thisweek") {

			$datevalue[0] = $thisweek0;
			$datevalue[1] = $thisweek1;
		} elseif ($type == "lastweek") {

			$datevalue[0] = $lastweek0;
			$datevalue[1] = $lastweek1;
		} elseif ($type == "nextweek") {

			$datevalue[0] = $nextweek0;
			$datevalue[1] = $nextweek1;
		} elseif ($type == "thismonth") {

			$datevalue[0] = $currentmonth0;
			$datevalue[1] = $currentmonth1;
		} elseif ($type == "lastmonth") {

			$datevalue[0] = $lastmonth0;
			$datevalue[1] = $lastmonth1;
		} elseif ($type == "nextmonth") {

			$datevalue[0] = $nextmonth0;
			$datevalue[1] = $nextmonth1;
		} elseif ($type == "next7days") {

			$datevalue[0] = $today;
			$datevalue[1] = $next7days;
		}
		elseif($type=="next15days")
		{
			$datevalue[0] = $today;
			$datevalue[1] = $next15days;
		}
		elseif ($type == "next30days") {

			$datevalue[0] = $today;
			$datevalue[1] = $next30days;
		} elseif ($type == "next60days") {

			$datevalue[0] = $today;
			$datevalue[1] = $next60days;
		} elseif ($type == "next90days") {

			$datevalue[0] = $today;
			$datevalue[1] = $next90days;
		} elseif ($type == "next120days") {

			$datevalue[0] = $today;
			$datevalue[1] = $next120days;
		}elseif ($type == "next180days") {

			$datevalue[0] = $today;
			$datevalue[1] = $next180days;
		}
		elseif($type=='last1days')
		{
			$datevalue[0] = $last1days;
			$datevalue[1] = $today;
		}
		elseif($type=='last2days')
		{
			$datevalue[0] = $last2days;
			$datevalue[1] = $today;
		} 
		elseif($type=='last3days')
		{
			$datevalue[0] = $last3days;
			$datevalue[1] = $today;
		}
		elseif($type=='last4days')
		{
			$datevalue[0] = $last4days;
			$datevalue[1] = $today;
		} 
		elseif($type=='last5days')
		{
			$datevalue[0] = $last5days;
			$datevalue[1] = $today;
		} 
		elseif($type=='last6days')
		{
			$datevalue[0] = $last6days;
			$datevalue[1] = $today;
		} 
		elseif($type=='last7days')
		{
			$datevalue[0] = $last7days;
			$datevalue[1] = $today;
		} 
		elseif($type=='last8days')
		{
			$datevalue[0] = $last8days;
			$datevalue[1] = $today;
		} 
		elseif ($type == "last9days") {

			$datevalue[0] = $last9days;
			$datevalue[1] = $today;
		}
		elseif($type=='last10days')
		{
			$datevalue[0] = $last10days;
			$datevalue[1] = $today;
		} 
		elseif($type=='last11days')
		{
			$datevalue[0] = $last11days;
			$datevalue[1] = $today;
		} 
		elseif($type=='last12days')
		{
			$datevalue[0] = $last12days;
			$datevalue[1] = $today;
		} 
		elseif($type=='last13days')
		{
			$datevalue[0] = $last13days;
			$datevalue[1] = $today;
		} 
		elseif($type=='last14days')
		{
			$datevalue[0] = $last14days;
			$datevalue[1] = $today;
		} 
		else if($type=='last15days')
		{
			$datevalue[0] = $last15days;
			$datevalue[1] = $today;
		} 
		elseif ($type == "last30days") {

			$datevalue[0] = $last30days;
			$datevalue[1] = $today;
		} elseif ($type == "last60days") {

			$datevalue[0] = $last60days;
			$datevalue[1] = $today;
		} else if ($type == "last90days") {

			$datevalue[0] = $last90days;
			$datevalue[1] = $today;
		} elseif ($type == "last120days") {

			$datevalue[0] = $last120days;
			$datevalue[1] = $today;
		}elseif ($type == "last180days") {

			$datevalue[0] = $last180days;
			$datevalue[1] = $today;
		}
		elseif ($type == "thisfy") {

			$datevalue[0] = $currentFY0;
			$datevalue[1] = $currentFY1;
		} elseif ($type == "prevfy") {

			$datevalue[0] = $lastFY0;
			$datevalue[1] = $lastFY1;
		} elseif ($type == "nextfy") {

			$datevalue[0] = $nextFY0;
			$datevalue[1] = $nextFY1;
		} elseif ($type == "nextfq") {

			$datevalue[0] = $nFq;
			$datevalue[1] = $nFq1;
		} elseif ($type == "prevfq") {

			$datevalue[0] = $pFq;
			$datevalue[1] = $pFq1;
		} elseif ($type == "thisfq") {
			$datevalue[0] = $cFq;
			$datevalue[1] = $cFq1;
		} 
		else if($type=='before0days')
		{
			$datevalue[0] = $defaultStartDate;
			$datevalue[1] = $before0days;
		}
		else if($type=='before3days')
		{
			$datevalue[0] = $defaultStartDate;
			$datevalue[1] = $before3days;
		}
		else if ($type == "before7days") {

			$datevalue[0] = $defaultStartDate;
			$datevalue[1] = $before7days;
		}
		else if($type == 'before15days')
		{
			$datevalue[0] = $defaultStartDate;
			$datevalue[1] = $before15days;
		}
		else if ($type == "before30days") {

			$datevalue[0] = $defaultStartDate;
			$datevalue[1] = $before30days;
		}else if ($type == "before60days") {

			$datevalue[0] = $defaultStartDate;
			$datevalue[1] = $before60days;
		}else if ($type == "before90days") {

			$datevalue[0] = $defaultStartDate;
			$datevalue[1] = $before90days;
		}else if ($type == "before120days") {

			$datevalue[0] = $defaultStartDate;
			$datevalue[1] = $before120days;
		}else if ($type == "before180days") {

			$datevalue[0] = $defaultStartDate;
			$datevalue[1] = $before180days;
		}
		else if($type=='after3days')
		{
			$datevalue[0] = $after3days;
			$datevalue[1] = $defaultEndDate;
		}
		else if ($type == "after7days") {

			$datevalue[0] = $after7days;
			$datevalue[1] = $defaultEndDate;
		}
		else if($type=='after15days')
		{
			$datevalue[0] = $after15days;
			$datevalue[1] = $defaultEndDate;
		}
		else if ($type == "after30days") {

			$datevalue[0] = $after30days;
			$datevalue[1] = $defaultEndDate;
		}else if ($type == "after60days") {

			$datevalue[0] = $after60days;
			$datevalue[1] = $defaultEndDate;
		}else if ($type == "after90days") {

			$datevalue[0] = $after90days;
			$datevalue[1] = $defaultEndDate;
		}else if ($type == "after120days") {

			$datevalue[0] = $after120days;
			$datevalue[1] = $defaultEndDate;
		}else if ($type == "after180days") {

			$datevalue[0] = $after180days;
			$datevalue[1] = $defaultEndDate;
		}else {
			$datevalue[0] = "";
			$datevalue[1] = "";
		}
		return $datevalue;
	}

}


?>