<?php
/**
 * User: hzx
 * Project: 灵当CRM
 * Date: 2022/11/22
 * Description: 双键化工 应收款汇总表报表接口

 */


global $adb,$theme,$current_user;
//dump($current_user);profileid
if(@!$current_user->id){
    echo '没有权限';die;
}
$smarty = new lingdangCRM_Smarty();

$search_orgid = vtlib_purify($_REQUEST['search_orgid']);  //结算组织
$search_account_start = vtlib_purify($_REQUEST['search_account_start']);  //开始客户编号
$search_account_end = vtlib_purify($_REQUEST['search_account_end']);  //结束客户编号
$search_BeginDate = vtlib_purify($_REQUEST['search_BeginDate']);  //开始日期
$search_FEndDate = vtlib_purify($_REQUEST['search_FEndDate']);  //结束日期
$search_FIncludePayEvaluate = $_REQUEST['search_FIncludePayEvaluate'];

$language = $_REQUEST['language']?$_REQUEST['language']:'zh';
$langArr = array(
    'zh'=>array(
        'cx'=>'查询',
    ),
    'en'=>array(
        'cx'=>'Query',
    )
);
$smarty->assign('LANG',$langArr[$language]);
$smarty->assign('LANGUAGE',$language);

$smarty->assign('GLOBALMINVERSION','1');


$smarty->assign('FIELDPERMISSIONS',$fieldPermissions);
//end字段权限
$_REQUEST['diony']='yes';
if(isset($_REQUEST['ajax']) && $_REQUEST['ajax'] != ''){
    $return_data = getSoapData($language);
    //有错误信息直接返回
    if($return_data['Result']['IsSuccess']!=1){
        $content = $smarty->fetch("climaveneta_bomSearch_content.tpl");
        ConvertTojsonString(-1,array('content'=>$content),'接口请求错误');
    }


    $smarty->assign('DATA',$return_data['Result']['Rows']);
}


if (isset($_REQUEST['ajax']) && $_REQUEST['ajax'] != '') {
    $apiMsg = '查询返回'.$return_data['Result']['RowCount'].'条';
    $smarty->assign('APIMSG',$apiMsg);
    $content = $smarty->fetch("doublebond_SumReport_content.tpl");
    ConvertTojsonString(1,array('content'=>$content,'apimsg' =>$apiMsg),'success');
} else {
    $smarty->display('doublebond_SumReport.tpl');
}




//获取接口的数据
function getSoapData($language='zh'){
    if($_REQUEST['search_BeginDate'] == ''){
        $FBeginDate = date('Y-m-d');
    }else{
        $FBeginDate = $_REQUEST['search_BeginDate'];
    }
    if($_REQUEST['search_FEndDate'] == ''){
        $FEndDate = date('Y-m-d');
    }else{
        $FEndDate = $_REQUEST['search_FEndDate'];
    }
    //FIncludePayEvaluate
    $data_CA = '["AR_SumReport",{
        "FieldKeys": "FCONTACTUNITNUMBER,FCONTACTUNITNAME,FBUSINESSORGNAME,FBUSINESSGROUPNAME,FBUSINESSERNAME,FINITAMOUNTFOR,FAMOUNTFOR,FREALAMOUNTFOR,FOFFAMOUNTFOR,FLEFTAMOUNTFOR",
        "SchemeId": "",
        "StartRow": 0,
        "Limit": 2000,
        "IsVerifyBaseDataField": "true",
        "Model": {
            "FAffiliation": {
                "FNAME": ""
            },
            "FENDYEAR": "",
            "FSTARTYEAR": "",
            "FENDPERIOD": "",
            "FSTARTPERIOD": "",
            "FInSettle": "false",
            "FOutSettle": "false",
            "FNoShowForBoth": "false",
            "FSettleOrgLst": "'.vtlib_purify($_REQUEST['search_orgid']).'",
            "FCONTACTUNITFrom": 
            {
                "FNumber": "'.vtlib_purify($_REQUEST['search_account_start']).'"
            },
            "FCONTACTUNITTo": {
                "FNumber": "'.vtlib_purify($_REQUEST['search_account_end']).'"
            },
            "FAccountSystem": {
                "FNumber": ""
            },
            "FEndDate": "'.$FEndDate.'",
            "FBeginDate": "'.$FBeginDate.'",
            "FNoShowForNoLeft": "false",
            "FNoShowForNoOccur": "false",
            "FNOAUDIT": "false",
            "FIncludePayEvaluate_New": "false",
            "FIncludePayEvaluate": "'.$_REQUEST['search_FIncludePayEvaluate'].'",
            "FOnlyShowPayEvaluate_New": "false",
            "FOnlyShowPayEvaluate": "false",
            "FDEFAULTACCTCALENDARID": 0,
            "FShowLocal": "false",
            "FShowSumLocal": "false",
            "FGroupCustomer": "false",
            "FNoPreReceive": "false",
            "FOnlyShowPreReceive": "false",
            "FCONTACTUNITMUL": "",
            "FMULCONTACT": "false",
            "FEXCLUDEB2CAR": "false",
            "FDateRadioGrp": ""
        }
    }]';
    //dump($data_CA);die;
    $data_CA = json_decode($data_CA);
    $result_data_CA = selectReportdataApiResult($data_CA);
    return $result_data_CA;
}

//api查询报表数据换回
function  selectReportdataApiResult($data){
    $cloudUrl = 'http://116.63.168.87/k3cloud/';
    $cookie_jar = erpLogin();
    $post_content = create_postdata($data);
    $result = invoke_getsysreportdata($cloudUrl,$post_content,$cookie_jar);
    return json_decode($result,true);
}
function erpLogin(){
    $cloudUrl = 'http://116.63.168.87/k3cloud/';
    $dbname = '63c79693736bc9';
    $user = 'Administrator';
    $pwd = 'Kingdee123@';
    //登陆参数
    $login_data = array(
        $dbname,//帐套Id
        $user,//用户名
        $pwd,//密码
        2052//语言标识
    );

    //定义记录Cloud服务端返回的Session
    $cookie_jar = tempnam(CLOUDTMPPATH, 'CloudSession');
    $post_content = create_postdata($login_data);
    $a = invoke_login($cloudUrl, $post_content, $cookie_jar);
    return $cookie_jar;
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

    return json_encode($postdata,JSON_HEX_TAG | JSON_HEX_APOS | JSON_HEX_QUOT | JSON_HEX_AMP | JSON_UNESCAPED_UNICODE);
}

//云星空 登陆
function invoke_login($cloudUrl, $post_content, $cookie_jar)
{
    $loginurl = $cloudUrl . 'Kingdee.BOS.WebApi.ServicesStub.AuthService.ValidateUser.common.kdsvc';
    return invoke_post($loginurl, $post_content, $cookie_jar, TRUE);
}

//云星空 查询报表数据
function invoke_getsysreportdata($cloudUrl, $post_content, $cookie_jar)
{
    $invokeurl = $cloudUrl . 'Kingdee.BOS.WebApi.ServicesStub.DynamicFormService.GetSysReportData.common.kdsvc';
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
    // @edit:dong @date:2022/09/28 @reason: 金蝶系统错误
    if(json_decode($result,true)['actionname']=='ShowErrMsg'){
        ConvertTojsonString(-1, '', '云星空系统错误：invoke_post错误'.$result);
    }
    return $result;
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
