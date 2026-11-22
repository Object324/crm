<?php
//XUQIU1002056 xxy 2023-10-31 【大数据平台】“证书分类查询”增加“领取”客户功能（刘素）
//领取客户和证书
global  $currentModule, $theme;
global $list_max_entries_per_page_new;
global $current_user,$adb;

$smarty = new lingdangCRM_Smarty();
$currentModule = $_REQUEST['module'];
$focus = CRMEntity::getInstance($currentModule);
$focus->getModuleLogic($currentModule);
$moduleFields=$focus->fieldobj->getModuleFields();
$users_focus = CRMEntity::getInstance('Users');
$users_moduleFields=$users_focus->fieldobj->getModuleFields();//成员管理模块字段
crm_load_class_file('cls_share','include/Functions/Share');//共享
$objShare = new cls_share();

$main_table = $focus->table_name;//模块主表
$custom_table = $focus->customFieldTable[0];//自定义字段表
$detail_table = $focus->Detail_table;
$tableindex = $focus->table_index;//模块表主键

$excludedRecords = $_REQUEST['excludedRecords']?:'';
$select_ids = $_REQUEST['select_ids'];
if($select_ids != 'all'){
	$select_ids = explode(';',$select_ids);
	$select_ids = array_filter($select_ids);
}else{
	$select_ids = getSelectedRecords($_REQUEST, $module, rtrim($_REQUEST['select_ids'], ';'), $excludedRecords);//全选
}
$selectlen = $_REQUEST['selectlen'];//所选条数
$startrow = $_REQUEST['startrow'];

if($startrow == 0){
	$acc_success_total = 0;//客户成功个数
	$cert_success_total = 0;//证书成功个数
	$acc_err_total = 0;//客户失败个数
	$cert_err_total = 0;//证书失败个数
	$acc_total = 0;
	$cert_total = 0;
	$acc_success_ids = [];//客户成功单据
	$cert_success_ids = [];//证书成功单据
	$acc_err_ids = [];//客户失败单据
	$cert_err_ids = [];//证书失败单据
	//领取日志
	foreach ($select_ids as $key => $select_id) {
		$focus->getModuleStatic('ModTracker');
		$focus->modstatic->saveOperationLog($currentModule,$select_id,'Receive','');
	}
}else{
	$resultdata = json_decode($_REQUEST['resultdata'],true);
	$acc_success_total = $resultdata['acc_success_num'];
	$cert_success_total = $resultdata['cert_success_num'];
	$acc_err_total = $resultdata['acc_err_num'];
	$cert_err_total = $resultdata['cert_err_num'];

	$acc_total = $resultdata['acc_total'];
	$cert_total = $resultdata['cert_total'];

	$acc_success_ids = $resultdata['acc_success_ids'];
	$cert_success_ids = $resultdata['cert_success_ids'];
	$acc_err_ids = $resultdata['acc_err_ids'];
	$cert_err_ids = $resultdata['cert_err_ids'];
}

if($_REQUEST['setype'] == 'check'){
	$current_user_sql = 'SELECT * from ld_users WHERE id = ?';
	$current_user_result = $adb->pquery($current_user_sql,array($current_user->id));
	$crm_url = $adb->query_result($current_user_result,0,'access_address');//当前账户对应crm地址
	$receivable_total = $adb->query_result($current_user_result,0,'receivable_total');//总领取条数
	$receivable_remain = $adb->query_result($current_user_result,0,'receivable_remain');//剩余条数

	$crm_url_label = $users_moduleFields['access_address']->getFieldLabel();
	$receivable_total_label = $users_moduleFields['receivable_total']->getFieldLabel();
	if(empty($receivable_total)){
		$err_msg = getFixedLabel('GotoUsersCheck').'“'.$receivable_total_label.'”'.getFixedLabel('isEnteredCorrectly');
		ConvertTojsonString(-1,'error',$err_msg);
	}else{
		$idLength = implode(',', array_fill(0, count($select_ids), '?'));
		$sql = "SELECT DISTINCT accountid FROM ".$main_table." WHERE ".$tableindex." in (".$idLength.")";
		// $tmp_select_ids = implode(',',$select_ids);
		$result = $adb->pquery($sql,array($select_ids));
		$num_rows = $adb->num_rows($result);
		if($num_rows > $receivable_remain){
			$receivable_remain_label = $users_moduleFields['receivable_remain']->getFieldLabel();
			$err_msg = getFixedLabel('CurrentUsers').'“'.$receivable_remain_label.'”'.getFixedLabel('isInsufficient');
			ConvertTojsonString(-1,'error',$err_msg);
		}
	}
	if($crm_url != ''){
		$arr['confirm_msg'] = getVarFixedLabel('SynchronizedToCRM', $crm_url_label);
		$arr['local_get'] = '';
	}else{
		$arr['confirm_msg'] = getFixedLabel('ReceiveToTheCurrentUser');
		$arr['local_get'] = 'yes';
	}
	$_REQUEST['diony'] = 'yes';	
	ConvertTojsonString(1,$arr,'success');
}
//共享单据和反写团队成员
function receivecertificate_share($module,$rRecord,$rSelectUsers){
	global $adb,$current_user;
	$arr_selectuser = explode(',', $rSelectUsers);
	$sql = 'SELECT group_concat(viewuserid) AS viewusers FROM ld_tabshare WHERE crmid=' . $rRecord;
	$result = $adb->pquery($sql, array());
	if ($adb->num_rows($result) > 0) {
		$arr_viewusers = explode(',', $adb->query_result($result, 0, 'viewusers'));
		//获取新分配的用户，且排除空值
		$arr_new_users = array_filter(array_diff($arr_selectuser, $arr_viewusers));
		foreach ($arr_new_users as $selectuser) {
			$sql_insert = 'INSERT INTO ld_tabshare (crmid, viewuserid, Shareuserid,createdtime) VALUE (?,?,?,?)';
			$adb->pquery($sql_insert, array($rRecord, $selectuser, $current_user->id, date('Y-m-d H:i:s')));
		}
	}
	crm_load_class_file('cls_share','include/Functions/Share');//共享
	$objShare = new cls_share();
	$objShare->ReverseWriteTeam_memberID($module,$rRecord);
}
if($_REQUEST['setype'] == 'get'){
	$startrow = $_REQUEST['startrow'];
	$endrow = $_REQUEST['endrow'];

	$import_fields_certificate = [//证书模块同步导入的字段
		"accountid" => 'accountid',
		"customform54_no" => 'customform54_no',
		"certificate_no" => 'cf_7754',//证书编号
		"state" => 'cf_7829',//省份
		"city" => 'cf_7830',//城市
		"address" => 'cf_7816',//注册地址
		"status" => 'cf_7755',//证书状态
		"issuancedate" => 'cf_7756',//颁证日期
		"duedate" => 'cf_7757',//到期日期
		"basis" => 'cf_7759',//认证依据
		"project" => 'cf_7758',//认证项目
		"scope" => 'cf_7760',//认证范围
		"authority" => 'cf_7763',//发证机构
		"mark" => 'cf_7761',//认可标识
		"peoplenum" => 'cf_7762',//覆盖人数
	];

	$import_fields_account = [//客户模块同步导入的字段
		"accountname" => 'accountname',
		'account_no'=> 'account_no',
		"state" => 'bill_state',//省份
		"city" => 'bill_city',//城市
		"phone" => 'phone',//公司电话
		"account_type" => 'account_type',//客户类型
		"bill_street" => 'bill_street',//详细地址
		"scope_of_business" => 'scope_of_business',//经营范围
		"industry" => 'industry',//所属行业
		"accountproperty" => 'accountproperty',//公司性质
		"email1" => 'email1',//公司Email
		"accountsize" => 'accountsize',//人员规模
		"registeredcapital" => 'registeredcapital',//注册资金
		"taxpayer_number" => 'taxpayer_number',//纳税人识别编号
		"registration_time" => 'registration_time',//注册时间
		"legal_representative" => 'legal_representative',//法定代表人
		"website" => 'website',//网址
		"insurer" => 'cf_7551',//参保人数
		"leadsource" => 'leadsource',//客户来源
		"locationaddress" => 'locationaddress',//定位
		"longtitude" => 'longtitude',//经纬度
		"latitude" => 'latitude',
	];

	$import_fields_contact = [//联系人模块同步导入的字段
		"accountid" => 'accountid',
		"lastname" => 'lastname',//联系人姓名
		"mobile" => 'mobile',//联系人手机
		"reference" => 'reference',
	];

	$idLength = implode(',', array_fill(0, count($select_ids), '?'));
	$sql = "SELECT DISTINCT accountid FROM ".$main_table." WHERE ".$tableindex." in (".$idLength.")";
	$result = $adb->pquery($sql,array($select_ids));
	$account_num_rows = $adb->num_rows($result);
	if($account_num_rows >= 1){
		for($i = 0; $i < $account_num_rows; $i++){
			$accountid_arr[$i] = $adb->query_result($result,$i,'accountid');
		}
	}

	$accountid_arr = array_slice($accountid_arr, $startrow, $endrow - $startrow);
	// dump($accountid_arr);
	//更新客户剩余领取数
	$user_query = "SELECT receivable_remain,receivable_haved FROM ld_users WHERE id = ?";
	$user_result = $adb->pquery($user_query, array($current_user->id));
	$receivable_remain = $adb->query_result($user_result,0,'receivable_remain');
	$receivable_remain_tmp = $receivable_remain - count($accountid_arr);
	$receivable_haved = $adb->query_result($user_result,0,'receivable_haved');
	$receivable_haved_tmp = $receivable_haved + count($accountid_arr);
	$update_remain = "UPDATE ld_users SET receivable_remain = ?,receivable_haved = ? where id = ?";
	$update_result=$adb->pquery($update_remain,array($receivable_remain_tmp,$receivable_haved_tmp,$current_user->id));
	//获取客户信息
	$accidLength = implode(',', array_fill(0, count($accountid_arr), '?'));
	$acc_sql = "SELECT ld_account.*,ld_accountscf.* FROM ld_account LEFT JOIN ld_accountscf ON ld_account.accountid = ld_accountscf.accountid WHERE ld_account.accountid in (".$accidLength.")";
	$acc_result = $adb->pquery($acc_sql,$accountid_arr);
	$num_rows = $adb->num_rows($acc_result);
	if($num_rows >= 1){
		for($i = 0; $i < $num_rows; $i++){
			$accid = $adb->query_result($acc_result,$i,'accountid');
			$con_sql = "SELECT * FROM ld_contactdetails WHERE accountid = ? and reference = ?";//获取联系人信息
			$con_result = $adb->pquery($con_sql,array($accid,1));
			$conid = $adb->query_result($con_result,$i,'contactid');
			$con_num_rows = $adb->num_rows($con_result);
			// foreach($import_allfields_account as $tablename => $fields_arr){
				foreach($import_fields_account as $key => $acc_field){
					$account_arr[$accid][$acc_field] = $adb->query_result($acc_result,$i,$acc_field);
					if($acc_field == 'leadsource'){
						$account_arr[$accid][$acc_field] = '平台领取';
					}
				}
			// }
			if($con_num_rows >= 1){
				foreach($import_fields_contact as $key => $con_field){
					$contact_arr[$conid][$con_field] = $adb->query_result($con_result,$i,$con_field);
					if($con_field == 'reference'){
						$contact_arr[$accid][$con_field] = 1;
					}
				}
			}
		}
	}
	$certificateid_arr = array();
	//获取证书信息
	$cert_sql = "SELECT ".$main_table.".*,".$custom_table.".*,".$main_table.".cf_7757 FROM ".$main_table." LEFT JOIN ".$custom_table." ON ".$custom_table.".".$tableindex." = ".$main_table.".".$tableindex." WHERE accountid in (".$accidLength.")";
	$cert_result = $adb->pquery($cert_sql,$accountid_arr);
	$num_rows = $adb->num_rows($cert_result);
	if($num_rows >= 1){
		for($i = 0; $i < $num_rows; $i++){
			$certid = $adb->query_result($cert_result,$i,$tableindex);
			$certificateid_arr[$i] = $certid;
			// foreach($import_allfields_certificate as $tablename => $fields_arr){
				foreach($import_fields_certificate as $key => $cert_field){
					$certificate_arr[$certid][$cert_field] = $adb->query_result($cert_result,$i,$cert_field);
				}
			// }
		}
	}

	$data_arr = [//客户模块同步导入的字段
		"Accounts" => $account_arr,
		"CustomForm54" => $certificate_arr,
		"Contacts" => $contact_arr,
	];
	$jsonData['data'] = $data_arr;

	if($startrow == 0){
		$jsonData['start'] = 'yes';
	}else{
		$jsonData['start'] = 'no';
	}
	//领取到对应crm地址
	if($_REQUEST['localget'] != 'yes'){
		$sql = "SELECT access_address FROM ld_users WHERE id = ?";
		$result = $adb->pquery($sql,array($current_user->id));
		$crm_url = $adb->query_result($result,0,'access_address');
		if (substr($crm_url, -1) == '/') {
			$url = $crm_url.'crmapi/api_getAccountCertificate.php';
		} else {
			$url = $crm_url.'/crmapi/api_getAccountCertificate.php';
		}
		require_once ("include/cls_UrlEncryptyJudge.php");
		$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
		$cls_UrlEncryptyJudgeobj->encrypturlkey = 'lingdangencryptyurl';
		$cls_UrlEncryptyJudgeobj->encrypttimestampkey = 'lingdangtimestamp';
		$jsonData = $cls_UrlEncryptyJudgeobj->EncryptyBynosorturlparseQueryParamshavearr($url,$jsonData);
		$jsonData = json_encode($jsonData);
		
		$ch = curl_init(); // 初始化curl
		curl_setopt($ch, CURLOPT_URL, $url);
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
		curl_setopt($ch, CURLOPT_HEADER, 0);
		curl_setopt($ch, CURLOPT_POST, 1);
		// curl_setopt($ch, CURLOPT_TIMEOUT,5); //只需要设置一个秒的数量就可以
		curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
		curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, false); //不验证证书
		curl_setopt($ch, CURLOPT_POSTFIELDS, $jsonData);
		curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
		$response = json_decode(curl_exec($ch),true); // 执行请求
		if(!empty($crm_url)){
			if (curl_errno($ch)) {
				ConvertTojsonString("-1",array($response),$crm_url_label.getFixedLabel('CannotAccessedPleaseRefer').'https://www.51mis.com/crm');//crm地址无法访问
			} else {
				if(empty($response)){
					ConvertTojsonString("-1",array($response),$crm_url_label.getFixedLabel('CannotAccessedPleaseRefer').'https://www.51mis.com/crm');//crm地址无法访问
				}else{
					if($response['code'] && $response['code'] == 1){
						$response_arr = $response['result'];
					}else{
						file_put_contents(globalStatic::$root_directory.'modules/CustomForm54/receivelogs.txt',$current_user->id.' : 领取客户数 '.count($account_arr).' '.$current_user->id.date("Y-m-d H:i:s")."\r\n",FILE_APPEND);
					}
				}
			}
		}
		curl_close($ch);

		$acc_success_total += $response_arr['acc_success_num'];
		$cert_success_total += $response_arr['cert_success_num'];
		$acc_err_total += $response_arr['acc_err_num'];
		$cert_err_total += $response_arr['cert_err_num'];

		$acc_total = $acc_success_total + $acc_err_total;
		$cert_total = $cert_success_total + $cert_err_total;
		
		function mergeArrays($arr1, $arr2) {
			foreach ($arr2 as $key => $value) {
				$arr1[$key] = $value;
			}
			return $arr1;
		}
		$acc_success_ids = mergeArrays($acc_success_ids, $response_arr['acc_success_ids']);
		$cert_success_ids = mergeArrays($cert_success_ids, $response_arr['cert_success_ids']);
		$acc_err_ids = mergeArrays($acc_err_ids, $response_arr['acc_err_ids']);
		$cert_err_ids = mergeArrays($cert_err_ids, $response_arr['cert_err_ids']);
	}else{
		//只领取，并非领取到指定crm地址
		$acc_alluser_shared = $objShare->getAllSelectedUsers($accountid_arr);
		if($acc_alluser_shared != array()){
            foreach($acc_alluser_shared as $crmid => $userids){
                if(!empty($userids)){
                    $userids = explode(',',$userids);
                    if(in_array($current_user->id,$userids)){
                        $acc_err_ids[$crmid] = $account_arr[$crmid]['accountname'];
                        $acc_err_total++;
						$remove_acc_arr = array($crmid);
						$accountid_arr = array_diff($accountid_arr,$remove_acc_arr);
                    }
                }
            }
			if(!empty($accountid_arr)){
				foreach($accountid_arr as $index => $crmid){
					$acc_success_ids[$crmid] = $account_arr[$crmid]['accountname'];
					$acc_success_total++;
				}
			}
        }else{
            foreach($accountid_arr as $index => $crmid){
                $acc_success_ids[$crmid] = $account_arr[$crmid]['accountname'];
                $acc_success_total++;
            }
        }
		$cert_alluser_shared = $objShare->getAllSelectedUsers($certificateid_arr);
		if($cert_alluser_shared != array()){
            foreach($cert_alluser_shared as $crmid => $userids){
                if(!empty($userids)){
                    $userids = explode(',',$userids);
                    if(in_array($current_user->id,$userids)){
                        $cert_err_ids[$crmid] = $certificate_arr[$crmid]['customform54_no'];
                        $cert_err_total++;
						$remove_cert_arr = array($crmid);
						$certificateid_arr = array_diff($certificateid_arr,$remove_cert_arr);
                    }
                }
            }
			if(!empty($certificateid_arr)){
				foreach($certificateid_arr as $index => $crmid){
					$cert_success_ids[$crmid] = $certificate_arr[$crmid]['customform54_no'];
					$cert_success_total++;
				}
			}
        }else{
            foreach($certificateid_arr as $index => $crmid){
                $cert_success_ids[$crmid] = $certificate_arr[$crmid]['customform54_no'];
                $cert_success_total++;
            }
        }
		$acc_total = $acc_success_total + $acc_err_total;
		$cert_total = $cert_success_total + $cert_err_total;
	}

	$result_data = [
		"acc_success_num" => $acc_success_total,
		"cert_success_num" => $cert_success_total,
		"acc_err_num" => $acc_err_total,
		"cert_err_num" => $cert_err_total,

		"acc_total" => $acc_total,
		"cert_total" => $cert_total,

		"acc_success_ids" => $acc_success_ids,
		"cert_success_ids" => $cert_success_ids,
		"acc_err_ids" => $acc_err_ids,
		"cert_err_ids" => $cert_err_ids,
	];
	
	$content_html = '';
	if($endrow >= $account_num_rows){
		//再次更新客户剩余领取数
		$user_query2 = "SELECT receivable_remain,receivable_haved FROM ld_users WHERE id = ?";
		$user_result2 = $adb->pquery($user_query2, array($current_user->id));
		$receivable_remain = $adb->query_result($user_result2,0,'receivable_remain');
		$receivable_remain_new = $receivable_remain + $acc_err_total;
		$receivable_haved = $adb->query_result($user_result2,0,'receivable_haved');
		$receivable_haved_new = $receivable_haved - $acc_err_total;
		$update_remain2 = "UPDATE ld_users SET receivable_remain = ?,receivable_haved = ? where id = ?";
		$update_result2 = $adb->pquery($update_remain2,array($receivable_remain_new,$receivable_haved_new,$current_user->id));
		//单据全部共享
		// $acc_ids = array_merge(array_keys($acc_success_ids), array_keys($acc_err_ids));
		// $acc_ids_str = implode(';', $acc_ids);
    	// $recordArr_acc = $objShare->check_permit('Accounts',$acc_ids_str,'',$current_user->id,'listview');
		
		// $cert_ids = array_merge(array_keys($cert_success_ids), array_keys($cert_err_ids));
		// $cert_ids_str = implode(';', $cert_ids);
    	// $recordArr_cert = $objShare->check_permit('CustomForm54',$cert_ids_str,'',$current_user->id,'listview');
    
		$content_html = '<div class="ld-description"><b class="info-icon"></b><div class="ld-description-content">';
        $content_html .= '<div>共同步 '.$acc_total.' 条客户单据，成功领取 '.$acc_success_total.' 条，失败 '.$acc_err_total.' 条。</div>';
        $content_html .= '<div>共同步 '.$cert_total.' 条证书单据，成功领取 '.$cert_success_total.' 条，失败 '.$cert_err_total.' 条。</div>';
		$content_html .= '<div>客户剩余领取数 '.$receivable_remain_new.' 条，客户已领取数 '.$receivable_haved_new.' 条。</div></div></div>';
		$content_html .= '<div class="pop_prc_content" style="overflow-y: unset;">';
		if(!empty($acc_success_ids)){
			foreach($acc_success_ids as $acc_id => $value){
				$content_html .= getFixedLabel('BIll').'[<a href="javascript:;" referencemodule="Accounts" referencerecord="'.$acc_id.'" onclick="ListReferenceLinkClick(ld(this),event)" style="color:#32A636;">'.$value.'</a>';
				$content_html .= ']'.getFixedLabel('SUCCESSFULLYRECEIVED').'<br>';
				receivecertificate_share('Accounts',$acc_id,$current_user->id);
			}
			$content_html .= '<div style="width: 550px;height: 1px;background-color: #d9d9d9;margin: 5px auto;"></div>';
		}
		if(!empty($cert_success_ids)){
			foreach($cert_success_ids as $cert_id => $value){
				$content_html .= getFixedLabel('BIll').'[<a href="javascript:;" referencemodule="CustomForm54" referencerecord="'.$cert_id.'" onclick="ListReferenceLinkClick(ld(this),event)" style="color:#32A636;">'.$value.'</a>';
				$content_html .= ']'.getFixedLabel('SUCCESSFULLYRECEIVED').'<br>';
				receivecertificate_share('CustomForm54',$cert_id,$current_user->id);
			}
			$content_html .= '<div style="width: 550px;height: 1px;background-color: #d9d9d9;margin: 5px auto;"></div>';
		}
		if(!empty($acc_err_ids)){
			foreach($acc_err_ids as $acc_id => $value){
				$content_html .= getFixedLabel('BIll').'[<a href="javascript:;" referencemodule="Accounts" referencerecord="'.$acc_id.'" onclick="ListReferenceLinkClick(ld(this),event)" style="color:#32A636;">'.$value.'</a>';
				if($_REQUEST['localget'] != 'yes'){
					$content_html .= ']'.getFixedLabel('ReceivedFailedCustomerUpdated').'<br>';
				}else{
					$content_html .= ']'.getFixedLabel('ReceivedFailedAlreadyReceived').'<br>';
				}
				receivecertificate_share('Accounts',$acc_id,$current_user->id);
			}
			$content_html .= '<div style="width: 550px;height: 1px;background-color: #d9d9d9;margin: 5px auto;"></div>';
		}
		if(!empty($cert_err_ids)){
			foreach($cert_err_ids as $cert_id => $value){
				$content_html .= getFixedLabel('BIll').'[<a href="javascript:;" referencemodule="CustomForm54" referencerecord="'.$cert_id.'" onclick="ListReferenceLinkClick(ld(this),event)" style="color:#32A636;">'.$value.'</a>';
				if($_REQUEST['localget'] != 'yes'){
					$content_html .= ']'.getFixedLabel('ReceivedFailed').'<br>';
				}else{
					$content_html .= ']'.getFixedLabel('ReceivedFailedAlreadyReceived').'<br>';
				}
				receivecertificate_share('CustomForm54',$cert_id,$current_user->id);
			}
			$content_html .= '<div style="width: 550px;height: 1px;background-color: #d9d9d9;margin: 5px auto;"></div>';
		}
		$content_html .= '</div>';
	}

	$arr['title'] = getFixedLabel('CF54massget');
	$arr['account_total'] = $account_num_rows;
	$arr['content_html'] = $content_html;
	$arr['result_data'] = json_encode($result_data);

	$_REQUEST['diony'] = 'yes';
	ConvertTojsonString(1,$arr,'success');
}
?>