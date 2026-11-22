<?php
class cls_WeidijiaReportVoucher
{
	
	public function __construct(){
		$this->FormId = 'GL_VOUCHER';
		$this->exchaccount_info['erp_dbhost'] = 'http://123.57.138.188/K3Cloud/';
		$this->exchaccount_info['erp_dbname'] = '5ffd41530501b6';
		$this->exchaccount_info['erp_dbuser'] = 'Administrator';
		$this->exchaccount_info['erp_dbpswd'] = '888888';
        define('CLOUDTMPPATH', dirname(__DIR__, 4) . '/tmp');
	}
	public function getAccNo($accountname){
		
		$data = '[{"FormId":"BD_CUSTOMER","FieldKeys":"FNumber","FilterString":"FName=\''.$accountname.'\'","OrderString":"","TopRowCount":"0","StartRow":"0","Limit":"0"}]';
        $result =$this->selectApiResult($data);
        return $result[0][0];
	}
	//获取凭证号
	public function getVoucherRgroupno($year,$month){
		$data = '
		[{
			"FormId": "GL_VOUCHER",
			"FieldKeys": "FVOUCHERGROUPNO",
			"FilterString": "FPERIOD='.$month.' and FYEAR='.$year.'",
			"OrderString": "FVOUCHERGROUPNO desc ",
			"TopRowCount": 0,
			"StartRow": 0,
			"Limit": 1
		}]';
		$result =$this->selectApiResult($data);
		if(!empty($result)){
			return $result[0][0];
		}
		return 1;
	}
	public function setVoucher($data){
		global $adb;
		if(!empty($data)){
			$record = $data['salesorderid'];
			$sequence_no = $data['sequence_no'];
			$date = date('Y-m-d');
			//$date = '2022-04-11';
			$timestamp=strtotime($date);
			$lastmonth=date('Y-m',strtotime(date('Y',$timestamp).'-'.(date('m',$timestamp)-1).'-01'));
			$FDate = date('Y-m-t',strtotime('-1 month'));
			
			$key = $lastmonth . '(不含税)';
			$amount = $data[$key];
			$lineitem_id = $data['lineitem_id'];
			$query = "select 1 from voucher_log where salesorderid = ? and sequence_no = ?";
			$db_result = $adb->pquery($query,array($record,$lineitem_id));
			if($adb->num_rows($db_result) >= 1){
				return 'error';
			}
			$year = date('Y',strtotime($FDate));
			$month = date('n',strtotime($FDate));
			$voucher_rgroupno = $this->getVoucherRgroupno($year,$month);
			$account_no = $this->getAccNo($data['accountname']);
			
			$data_model = '{
				"NeedUpDateFields": [],
				"NeedReturnFields": [],
				"IsDeleteEntry": "true",
				"SubSystemId": "",
				"IsVerifyBaseDataField": "false",
				"IsEntryBatchFill": "true",
				"ValidateFlag": "true",
				"NumberSearch": "true",
				"InterationFlags": "",
				"Model": {
					"FVOUCHERID": 0,
					"FAccountBookID": {
						"FNumber": "100"
					},
					"FDate": "'.$FDate.'",
					"FBUSDATE": "'.$FDate.'",
					"FVOUCHERGROUPID": {
						"FNumber": "PRE001"
					},
					"FVOUCHERGROUPNO": "'.$voucher_rgroupno.'",
					"FISADJUSTVOUCHER": false,
					"FDocumentStatus": "Z",
					"FYEAR": '.$year.',
					"FSourceBillKey": {
						"FNumber": "78050206-2fa6-40e3-b7c8-bd608146fa38"
					},
					"FPERIOD": '.$month.',
					"FEntity": [
						{
							"FEXPLANATION": "收入确认",
							"FACCOUNTID": {
								"FNumber": "2204.01"
							},
							"FDetailID": {
								"FDETAILID__FFLEX6": {
									"FNumber": "'.$account_no.'"
								}
							},
							"FCURRENCYID": {
								"FNumber": "PRE001"
							},
							"FEXCHANGERATETYPE": {
								"FNumber": "HLTX01_SYS"
							},
							"FEXCHANGERATE": 1.0,
							"FAMOUNTFOR": '.$data[$key].',
							"FDEBIT": '.$data[$key].'
						},
						{
							"FEXPLANATION": "收入确认",
							"FACCOUNTID": {
								"FNumber": "6001.01"
							},
							"FDetailID": {
								"FDETAILID__FFLEX6": {
									"FNumber": "'.$account_no.'"
								}
							},
							"FCURRENCYID": {
								"FNumber": "PRE001"
							},
							"FEXCHANGERATETYPE": {
								"FNumber": "HLTX01_SYS"
							},
							"FEXCHANGERATE": 1.0,
							"FAMOUNTFOR": '.$data[$key].',
							"FCREDIT": '.$data[$key].'
						}
					]
				}
			}';
		}
		
		$result = $this->saveApiResult($record,$data_model);
		$errorMsg='';
		if($result->Result->ResponseStatus->IsSuccess == 1){
			$query = "insert into voucher_log(salesorderid,sequence_no) values (?,?)";
			$adb->pquery($query,array($record,$lineitem_id));
		}else{
			$errorMsg=$result->Result->ResponseStatus->Errors[0]->Message;
			$query = "insert into voucher_log(salesorderid,sequence_no,data_model,error) values (?,?,?,?)";
			$adb->pquery($query,array($record,$lineitem_id,$data_model,$errorMsg));
			
		}
		//echo $errorMsg . '<br>';
		//print_r(array($record,$lineitem_id));die;
		return $errorMsg;
	}
	//保存
	public function saveApiResult($record,$data_model){
		$data = array(
            $this->FormId,//业务对象标识FormId
            $data_model//具体Json字串
        );
		$cloudUrl = $this->exchaccount_info['erp_dbhost'];
        $dbname = $this->exchaccount_info['erp_dbname'];
        $user = $this->exchaccount_info['erp_dbuser'];
        $pwd = $this->exchaccount_info['erp_dbpswd'];
		
        //登陆参数
        $login_data = array(
            $dbname,//帐套Id
            $user,//用户名
            $pwd,//密码
            2052//语言标识
        );

        //定义记录Cloud服务端返回的Session
        $cookie_jar = tempnam(CLOUDTMPPATH,'CloudSession');
        $post_content = create_postdata($login_data);
        $a = invoke_login($cloudUrl,$post_content,$cookie_jar);
        $post_content = create_postdata($data);
		$result = invoke_save($cloudUrl,$post_content,$cookie_jar);
		$result = json_decode($result);
		return $result;
	}
	
	//查询
	public function  selectApiResult($data){
        $cloudUrl = $this->exchaccount_info['erp_dbhost'];
        $dbname = $this->exchaccount_info['erp_dbname'];
        $user = $this->exchaccount_info['erp_dbuser'];
        $pwd = $this->exchaccount_info['erp_dbpswd'];
		
        //登陆参数
        $login_data = array(
            $dbname,//帐套Id
            $user,//用户名
            $pwd,//密码
            2052//语言标识
        );

        //定义记录Cloud服务端返回的Session
        $cookie_jar = tempnam(CLOUDTMPPATH,'CloudSession');
        $post_content = create_postdata($login_data);
        $a = invoke_login($cloudUrl,$post_content,$cookie_jar);
        $post_content = create_postdata($data);
        $result = invoke_select($cloudUrl,$post_content,$cookie_jar);
        $result = json_decode($result);
        return $result;
    }
}



//K3 Cloud 登陆验证
function check_invoke_login($cloudUrl, $user, $pwd, $dbname)
{
    //登陆参数
    $data = array(
        $dbname,//帐套Id
        $user,//用户名
        $pwd,//密码
        2052//语言标识
    );
    //定义记录Cloud服务端返回的Session
    $cookie_jar = tempnam(CLOUDTMPPATH, 'CloudSession');
    $post_content = create_postdata($data);
    $loginurl = $cloudUrl . 'Kingdee.BOS.WebApi.ServicesStub.AuthService.ValidateUser.common.kdsvc';
    return invoke_post($loginurl, $post_content, $cookie_jar, TRUE);
}

//K3 Cloud 登陆
function invoke_login($cloudUrl, $post_content, $cookie_jar)
{
    $loginurl = $cloudUrl . 'Kingdee.BOS.WebApi.ServicesStub.AuthService.ValidateUser.common.kdsvc';
    return invoke_post($loginurl, $post_content, $cookie_jar, TRUE);
}

//K3 Cloud 保存
function invoke_save($cloudUrl, $post_content, $cookie_jar)
{
    $invokeurl = $cloudUrl . 'Kingdee.BOS.WebApi.ServicesStub.DynamicFormService.Save.common.kdsvc';
    return invoke_post($invokeurl, $post_content, $cookie_jar, FALSE);
}

//K3 Cloud 审核
function invoke_audit($cloudUrl, $post_content, $cookie_jar)
{
    $invokeurl = $cloudUrl . 'Kingdee.BOS.WebApi.ServicesStub.DynamicFormService.Audit.common.kdsvc';
    return invoke_post($invokeurl, $post_content, $cookie_jar, FALSE);
}

//K3 Cloud 查看
function invoke_view($cloudUrl, $post_content, $cookie_jar)
{
    $invokeurl = $cloudUrl . 'Kingdee.BOS.WebApi.ServicesStub.DynamicFormService.View.common.kdsvc';
    return invoke_post($invokeurl, $post_content, $cookie_jar, FALSE);
}

//K3 Cloud 删除
function invoke_delete($cloudUrl, $post_content, $cookie_jar)
{
    $invokeurl = $cloudUrl . 'Kingdee.BOS.WebApi.ServicesStub.DynamicFormService.Delete.common.kdsvc';
    return invoke_post($invokeurl, $post_content, $cookie_jar, FALSE);
}

//K3 Cloud 分配
function invoke_allocate($cloudUrl, $post_content, $cookie_jar)
{
    $invokeurl = $cloudUrl . 'Kingdee.BOS.WebApi.ServicesStub.DynamicFormService.Allocate.common.kdsvc';
    return invoke_post($invokeurl, $post_content, $cookie_jar, FALSE);
}

//K3 Cloud 反审核
function invoke_unaudit($cloudUrl, $post_content, $cookie_jar)
{
    $invokeurl = $cloudUrl . 'Kingdee.BOS.WebApi.ServicesStub.DynamicFormService.unAudit.common.kdsvc';
    return invoke_post($invokeurl, $post_content, $cookie_jar, FALSE);
}

//K3 Cloud 提交
function invoke_submit($cloudUrl, $post_content, $cookie_jar)
{

    $invokeurl = $cloudUrl . 'Kingdee.BOS.WebApi.ServicesStub.DynamicFormService.Submit.common.kdsvc';
    return invoke_post($invokeurl, $post_content, $cookie_jar, FALSE);
}

//K3 Cloud 状态转换
function invoke_statusconvert($cloudUrl, $post_content, $cookie_jar)
{
    $invokeurl = $cloudUrl . 'Kingdee.BOS.WebApi.ServicesStub.DynamicFormService.StatusConvert.common.kdsvc';
    return invoke_post($invokeurl, $post_content, $cookie_jar, FALSE);
}

function invoke_select($cloudUrl, $post_content, $cookie_jar)
{
    $invokeurl = $cloudUrl . 'Kingdee.BOS.WebApi.ServicesStub.DynamicFormService.ExecuteBillQuery.common.kdsvc';
    return invoke_post($invokeurl, $post_content, $cookie_jar, FALSE);
}

function invoke_post($url, $post_content, $cookie_jar, $isLogin)
{
    $ch = curl_init($url);

    $this_header = array(
        'Content-Type: application/json',
        'Content-Length: ' . strlen($post_content)
    );
//    curl_setopt($ch,CURLOPT_PROXY,'127.0.0.1:8888'); //代理用于fiddler 抓包
    curl_setopt($ch, CURLOPT_CUSTOMREQUEST, 'POST');
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
    curl_setopt($ch, CURLOPT_HTTPHEADER, $this_header);
    curl_setopt($ch, CURLOPT_POSTFIELDS, $post_content);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    if ($isLogin) {
        curl_setopt($ch, CURLOPT_COOKIEJAR, $cookie_jar);
    } else {
        curl_setopt($ch, CURLOPT_COOKIEFILE, $cookie_jar);
    }
    curl_setopt($ch, CURLOPT_TIMEOUT, 30);

    $result = curl_exec($ch);
    curl_close($ch);

    return $result;
}

//构造Web API请求格式
function create_postdata($args)
{
    $postdata = array(
        'format' => 1,
        'useragent' => 'ApiClient',
        'rid' => create_guid(),
        'parameters' => $args,
        'timestamp' => date('Y-m-d'),
        'v' => '1.0'
    );
    return json_encode($postdata);
}

//生成guid
function create_guid()
{
    $charid = strtoupper(md5(uniqid(mt_rand(), true)));
    $hyphen = chr(45);// "-"
    $uuid = chr(123)// "{"
        . substr($charid, 0, 8) . $hyphen
        . substr($charid, 8, 4) . $hyphen
        . substr($charid, 12, 4) . $hyphen
        . substr($charid, 16, 4) . $hyphen
        . substr($charid, 20, 12)
        . chr(125);// "}"
    return $uuid;
}
?>