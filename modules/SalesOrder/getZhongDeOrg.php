<?php
//chj 2022/9/20 中德信用额度控制下单(2)_1663310360000_576
/*
* orgvlue  授信组织
* account_id 客户id
* cf_5153  是否可查信用
* assigned_user_id 负责人
*/
global $theme,$currentModule,$singlepane_view,$current_user;
$_REQUEST['diony']='yes';
$orgvlue = $_REQUEST['orgvlue'];
$account_id =$_REQUEST['account_id'];
$cf_5153 = $_REQUEST['cf_5153'];
$assigned_user_id = $_REQUEST['assigned_user_id'];
$acc_org_value = '';
$user_org_value = '';
if(!empty($orgvlue) && !empty($account_id) && !empty($cf_5153) && !empty($assigned_user_id)){
	$orgs = getORGOrganizations();
	$fsaleorglist = array_search($orgvlue,$orgs);
	if($cf_5153 == '是'){
		$acc_org_value = getAccOrgValue($account_id,$fsaleorglist);
		$acc_org_value = str_ireplace(',', '', $acc_org_value);
	}
	if(!empty($assigned_user_id)){
		$user_org_value = getUserOrgValue($assigned_user_id,$fsaleorglist);
		$user_org_value = str_ireplace(',', '', $user_org_value);
	}
}
ConvertTojsonString(1,array('acc_org_value'=>$acc_org_value,'html_acc_org_value'=>number_format($acc_org_value),'user_org_value'=>$user_org_value,'html_user_org_value'=>number_format($user_org_value)),'success');


function getAccOrgValue($account_id,$fsaleorglist){
	$accountname = getAccountNameForId($account_id);
	$FilterString = "fname='".$accountname."'";
	$data = '[{"FormId":"BD_Customer","FieldKeys":"fnumber","FilterString":"'.$FilterString.'","OrderString":"","TopRowCount":"0","StartRow":"0","Limit":"0"}]';
    $result =selectApiResult($data);
	$fnumber = $result[0][0];
	if(!empty($fnumber)){
		$data = '["CRE_Rpt_CreditInfo",{
			"FieldKeys": "FSalerId,FLIMITBALANCE",
			"SchemeId": "",
			"StartRow": 0,
			"Limit": 0,
			"IsVerifyBaseDataField": "true",
			"Model": {
				"FSaleOrgList": "'.$fsaleorglist.'",
				"FObjectType": "BD_Customer",
				"FStartCustId": {
					"FNumber": "'.$fnumber.'"
				},
				"FEndCustId": {
					"FNumber": "'.$fnumber.'"
				},
				"FCreditStatus": "ALL",
				"FIsExceeds": "-1",
				"FMultiSelect": "false"
			}
		}]';
		$result =selectApiResult($data,'report');
		if($result->Result->IsSuccess == 1 && !empty($result->Result->Rows)){
			foreach($result->Result->Rows as $rows){
				if(empty($rows[0])){
					return $rows[1];
				}
			}
		}
	}
	return '';
}

function getUserOrgValue($userid,$fsaleorglist){
	$username = getUserFullName($userid);

	$FilterString = "fname='".$username."'";
	$data = '[{"FormId":"BD_Saler","FieldKeys":"FNumber","FilterString":"'.$FilterString.'","OrderString":"","TopRowCount":"0","StartRow":"0","Limit":"0"}]';
    $result =selectApiResult($data);
	$fnumber = $result[0][0];
	if(!empty($fnumber)){
		$data = '["CRE_Rpt_CreditInfo",{
			"FieldKeys": "FLIMITBALANCE",
			"SchemeId": "",
			"StartRow": 0,
			"Limit": 0,
			"IsVerifyBaseDataField": "true",
			"Model": {
				"FSaleOrgList": "'.$fsaleorglist.'",
				"FObjectType": "BD_Saler",
				"FStartSalerId": {
					"FNumber": "'.$fnumber.'"
				},
				"FEndSalerId": {
					"FNumber": "'.$fnumber.'"
				},
				"FCreditStatus": "ALL",
				"FIsExceeds": "-1",
				"FMultiSelect": false
			}
		}]';
		$result =selectApiResult($data,'report');
		if($result->Result->IsSuccess == 1 && !empty($result->Result->Rows)){
			foreach($result->Result->Rows as $rows){
				return $rows[0];
			}
		}
	}
	return '';
}

function getAccountNameForId($account_id){
	global $adb;
	$query = "select accountname from ld_account where accountid = ? and deleted = 0";
	$result = $adb->pquery($query,array($account_id));
	if($adb->num_rows($result) >= 1){
		return $adb->query_result($result,0,0);
	}
	return '';
}
//api查询方法
function  selectApiResult($data,$stype='select'){
	$data = json_decode($data);
	
	$cloudUrl = 'http://218.28.182.50:8081/k3cloud/';
	$dbname = '62fc5cdd6f62fb';
	$user = '周青青';
	$pwd = '000000';
	//登陆参数
	$login_data = array(
		$dbname,//帐套Id
		$user,//用户名
		$pwd,//密码
		2052//语言标识
	);

	//定义记录Cloud服务端返回的Session
	$cookie_jar = tempnam(cloud_tmppath,'CloudSession');
	$post_content = create_postdata($login_data);
	$a = invoke_login($cloudUrl,$post_content,$cookie_jar);
	$post_content = create_postdata($data);
	if($stype == 'report'){
		$result = invoke_getsysreportdata($cloudUrl,$post_content,$cookie_jar);
	}else{
		$result = invoke_select($cloudUrl,$post_content,$cookie_jar);
	}
	$result = json_decode($result);
	return $result;
}

function getORGOrganizations(){
        $data = '[{"FormId":"ORG_Organizations","FieldKeys":"FOrgID,FNAME","FilterString":"FForbidStatus=\'A\' and FDocumentStatus=\'C\'","OrderString":"","TopRowCount":"0","StartRow":"0","Limit":"0"}]';
        $result =selectApiResult($data);
        if(!empty($result)){
            foreach($result as $info){
                $res[$info[0]] = $info[1];
            }
        }
        return $res;
    }

//K3 Cloud 登陆验证
function check_invoke_login($cloudUrl,$user,$pwd,$dbname)
{ 
	//登陆参数
	$data = array(      
		$dbname,//帐套Id
		$user,//用户名
		$pwd,//密码
		2052//语言标识
	);
	//定义记录Cloud服务端返回的Session
	$cookie_jar = tempnam(cloud_tmppath,'CloudSession');
	$post_content = create_postdata($data);
	$loginurl = $cloudUrl.'Kingdee.BOS.WebApi.ServicesStub.AuthService.ValidateUser.common.kdsvc';
	return invoke_post($loginurl,$post_content,$cookie_jar,TRUE);
}
//K3 Cloud 登陆
function invoke_login($cloudUrl,$post_content,$cookie_jar)
{
		$loginurl = $cloudUrl.'Kingdee.BOS.WebApi.ServicesStub.AuthService.ValidateUser.common.kdsvc';
		return invoke_post($loginurl,$post_content,$cookie_jar,TRUE);
}

//K3 Cloud 保存
function invoke_save($cloudUrl,$post_content,$cookie_jar)
{
		$invokeurl = $cloudUrl.'Kingdee.BOS.WebApi.ServicesStub.DynamicFormService.Save.common.kdsvc';
		return invoke_post($invokeurl,$post_content,$cookie_jar,FALSE);
}

//K3 Cloud 审核
function invoke_audit($cloudUrl,$post_content,$cookie_jar)
{
		$invokeurl = $cloudUrl.'Kingdee.BOS.WebApi.ServicesStub.DynamicFormService.Audit.common.kdsvc';
		return invoke_post($invokeurl,$post_content,$cookie_jar,FALSE);
}
//K3 Cloud 查看
function invoke_view($cloudUrl,$post_content,$cookie_jar)
{
		$invokeurl = $cloudUrl.'Kingdee.BOS.WebApi.ServicesStub.DynamicFormService.View.common.kdsvc';
		return invoke_post($invokeurl,$post_content,$cookie_jar,FALSE);
}
//K3 Cloud 删除
function invoke_delete($cloudUrl,$post_content,$cookie_jar)
{
		$invokeurl = $cloudUrl.'Kingdee.BOS.WebApi.ServicesStub.DynamicFormService.Delete.common.kdsvc';
		return invoke_post($invokeurl,$post_content,$cookie_jar,FALSE);
}
//K3 Cloud 分配
function invoke_allocate($cloudUrl,$post_content,$cookie_jar)
{
		$invokeurl = $cloudUrl.'Kingdee.BOS.WebApi.ServicesStub.DynamicFormService.Allocate.common.kdsvc';
		return invoke_post($invokeurl,$post_content,$cookie_jar,FALSE);
}
//K3 Cloud 反审核
function invoke_unaudit($cloudUrl,$post_content,$cookie_jar)
{
		$invokeurl = $cloudUrl.'Kingdee.BOS.WebApi.ServicesStub.DynamicFormService.unAudit.common.kdsvc';
		return invoke_post($invokeurl,$post_content,$cookie_jar,FALSE);
}
//K3 Cloud 提交
function invoke_submit($cloudUrl,$post_content,$cookie_jar)
{
		$invokeurl = $cloudUrl.'Kingdee.BOS.WebApi.ServicesStub.DynamicFormService.Submit.common.kdsvc';
		return invoke_post($invokeurl,$post_content,$cookie_jar,FALSE);
}
//K3 Cloud 状态转换
function invoke_statusconvert($cloudUrl,$post_content,$cookie_jar)
{
		$invokeurl = $cloudUrl.'Kingdee.BOS.WebApi.ServicesStub.DynamicFormService.StatusConvert.common.kdsvc';
		return invoke_post($invokeurl,$post_content,$cookie_jar,FALSE);
}
function invoke_select($cloudUrl,$post_content,$cookie_jar)
{
		$invokeurl = $cloudUrl.'Kingdee.BOS.WebApi.ServicesStub.DynamicFormService.ExecuteBillQuery.common.kdsvc';
		return invoke_post($invokeurl,$post_content,$cookie_jar,FALSE);
}

//K3 Cloud 查询报表数据
function invoke_getsysreportdata($cloudUrl, $post_content, $cookie_jar)
{
    $invokeurl = $cloudUrl . 'Kingdee.BOS.WebApi.ServicesStub.DynamicFormService.GetSysReportData.common.kdsvc';
    return invoke_post($invokeurl, $post_content, $cookie_jar, FALSE);
}

function invoke_post($url,$post_content,$cookie_jar,$isLogin)
{
		$ch = curl_init($url);

		$this_header = array(
				'Content-Type: application/json',
				'Content-Length: '.strlen($post_content)
		);
	   
		curl_setopt($ch, CURLOPT_CUSTOMREQUEST, 'POST');
		curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
		curl_setopt($ch, CURLOPT_HTTPHEADER, $this_header);
		curl_setopt($ch, CURLOPT_POSTFIELDS, $post_content);
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
		if($isLogin){
				curl_setopt($ch, CURLOPT_COOKIEJAR, $cookie_jar);
		}
		else{
				curl_setopt($ch, CURLOPT_COOKIEFILE, $cookie_jar);
		}
		curl_setopt($ch, CURLOPT_TIMEOUT, 30);
		  
		$result = curl_exec($ch);
		curl_close($ch);  
	   
		return $result;
}

//构造Web API请求格式
function create_postdata($args) {
	 $postdata = array(
			'format'=>1,
		'useragent'=>'ApiClient',
		'rid'=>create_guid(),
		'parameters'=>$args,
		'timestamp'=>date('Y-m-d'),
		'v'=>'1.0'
	);
	return json_encode($postdata);
}

//生成guid
function create_guid() {
	$charid = strtoupper(md5(uniqid(mt_rand(), true)));
	$hyphen = chr(45);// "-"
	$uuid = chr(123)// "{"
	.substr($charid, 0, 8).$hyphen
	.substr($charid, 8, 4).$hyphen
	.substr($charid,12, 4).$hyphen
	.substr($charid,16, 4).$hyphen
	.substr($charid,20,12)
	.chr(125);// "}"
	return $uuid;
}
?>