<?php
//editor:gyq_135 reason:企业微信打卡数据同步接口  2019/8/8 13:11 ID1000568
header('Content-Type:text/html;charset=UTF-8');
date_default_timezone_set("Asia/Shanghai");
global $adb,$current_user;
//editor:gyq_155 reason:钉钉考勤同步  2019/10/30 11:34 ID1000624
$sql = "select usertype from ld_wx_config where name=?";
$result = $adb->pquery($sql,array('checkin_monthly'));
if($adb->num_rows($result)){
    $interfaceType = $adb->query_result($result,0,'usertype');
    if($interfaceType=='dingtalk'){
        include globalStatic::$root_directory.'modules/OftenUseReport/module/checkin_monthly/sync_dingtalk.php';
        exit;
    }
}
$_REQUEST['diony'] = 'diony';
require_once(globalStatic::$root_directory.'appCommon/appCommon.php');
require_once(globalStatic::$root_directory.'WeiXinApp/lib/EventFromApiModel.php');
$model_api = new EventFromApiModel();
//```````````格式化同步时间范围
$startmonth = $_REQUEST['startmonth'];
if(empty( $startmonth)){
    $month = date('Y-m');
    $month_start = strtotime($month);//指定月份月初时间戳
    $month_end = mktime(23, 59, 59, date('m', strtotime($month))+1, 00);//指定月份月末时间戳
}else{
    $month_start =  strtotime( $startmonth.' 00:00:00');
    $month_end = strtotime( $_REQUEST['endmonth'].' 23:59:59');
}
//``````````获取系统配置参数
$sql = 'select para_one,para_two,para_three,datetime from ld_wx_config where name=?';
$result = $adb->pquery($sql,array('checkin_monthly'));
$access_token = false;
if($adb->num_rows($result) > 0) {
    $corpid = $adb->query_result($result, 0, 'para_two');
    $secret_checkin = $adb->query_result($result, 0, 'para_three');
    $secret_approve = $adb->query_result($result, 0, 'para_one');
}else{
    ConvertTojsonString(-1,array(),getFixedLabel('CHECKINSETTING_TITLE4'));
}

//`````````````获取待同步的成员列表
$sql = 'select wx_userid,id,groupid,last_name from ld_users where status=? and deleted=? and ifnull(wx_userid,\'\')<>\'\'';
$result = $adb->pquery($sql,array('Active',0));
$nums  = $adb->num_rows($result);
$useridlist = array();
$userwx2id = [];
for($i=0;$i<$nums;$i++) {
    $tmpuserid = $adb->query_result($result, $i, 'id');
	$tmpwx_userid = $adb->query_result($result, $i, 'wx_userid');
	$userwx2id[$tmpwx_userid] =  $tmpuserid;//键值对是wx_userid=>ld_users表的id
    $useridlist[] = $tmpwx_userid;
}


//$useridlist = array('TangHe','chrirYaDan','JinShan','HuangJin','YuLongXue','ray');

$next_spnum = null;
$list = array();
$sp_num_exist = array();

//`````````````获取签到数据
crm_load_class_file("cls_WeiXinSelfBuiltApp", 'WeiXinApp/WeiXin_common');
$wxselfbuilt_obj = new cls_WeiXinSelfBuiltApp();
//$wxselfbuilt_obj->installWXSelfBuilt = false;
if ($wxselfbuilt_obj->installWXSelfBuilt) {
    //企业微信自建应用获取员工打卡数据
    include_once(globalStatic::$root_directory."vendor/weworkapi_php/api/src/CorpAPI.class.php");
    $corpApiObj = new CorpAPI($corpid, $secret_checkin);
    $opencheckindatatype = 1;//打卡类型。1：上下班打卡；2：外出打卡；3：全部打卡
    $result = $corpApiObj->CheckinDataGet($opencheckindatatype,$month_start,$month_end,$useridlist);//修改接口返回值，返回初始数据

//    var_export($corpApiObj->rspJson);
    if(isset($result['errcode']) && $result['errcode']===0){
        $checkin_data = $result['checkindata'];
    }elseif(isset($result['errcode']) && $result['errcode']==301024){
        ConvertTojsonString(-1,array($result),getFixedLabel('CHECKINSETTING_TITLE5'));
    }else{
        ConvertTojsonString(-1,array($result),getFixedLabel('CHECKINSETTING_TITLE4'));
    }

    //自建应用审批打卡
    $corpApiObj = new CorpAPI($corpid, $secret_approve);
    $reissue_data = getapprovaldata_recurve_selfbuilt($month_start,$month_end,$corpApiObj,$list,$next_spnum);


}else{
    //ls 20221021  BUG0057760 客户问题（佰易文化传媒），常用报表->月度考勤统计表，点击同步企业微信考勤打卡记录时，一直提示配置错误
    //使用服务商token获取数据  客户的企业微信后台应用需要允许打卡审批权限（灵当CRM申请打卡审批权限需要重新上架应用，故改为从打卡应用获取数据）。
    //5) 打卡相关的接口，只能由系统应用“打卡”调用，或由配置到打卡“可调用应用”列表中的自建应用调用，或由申请了打卡权限的第三方应用/代开发应用调用。

    //ls 20230323 BUG0063453 kfbcrm以前企业微信通讯录账号是明文的,使用的是打卡应用secret获取的token调用,现在是密文的,需要通过服务商token调用获取,逻辑需要兼容新老用户
    //将明文的wxuserid转化为密文
    require_once(globalStatic::$root_directory . 'WeiXinApp/WeiXin_common/cls_WeixinPort.php');
    $weixinportobj=new cls_WeixinPort();
    $converuseridarr=$weixinportobj->getConvertUserId($useridlist);//$useridlist 如果既有明文,又有密文,则正确的密文会原封不动的返回(userid和open_userid一样),正确的明文会被转为第三方密文(open_userid),错误的明文和密文会返回到$converuseridarr['invalid_userid_list'],正确的数据返回到$converuseridarr['result']
    if(is_array($converuseridarr['result'])&&sizeof($converuseridarr['result'])>0) {
        $useridlist = array_column($converuseridarr['result'], 'open_userid');//有效的wxuserid的集合
    }
	//zxm 20231115 将明文密文数据存储到表中  ld_wechatconvertuserid
	foreach($converuseridarr['result'] as $convertinfo){
		$tempmingwen = $convertinfo['userid'];
		$tempmiwen = $convertinfo['open_userid'];
		
		if(isset($userwx2id[$tempmingwen])){
			$tempuserid = $userwx2id[$tempmingwen];
			$insertsql = "insert into ld_wechatconvertuserid 
			(userid,wechatuserid,convertuserid,createdtime,modifiedtime) select ?,?,?,?,? from dual
			where not exists(select 1 from ld_wechatconvertuserid where wechatuserid=? and userid=?)";
			
			$insertresult = $adb->pquery($insertsql,array(
			$tempuserid,
			$tempmingwen,
			$tempmiwen,
			date('Y-m-d H:i:s'),
			date('Y-m-d H:i:s'),
			$tempmingwen,
			$tempuserid
			));
		}
		
	}
    //`````````````获取打卡接口秘钥
    $token = $model_api->getcheckintoken($corpid,$secret_checkin);
    //`````````````获取签到数据
    //BUG0070930 20230810 企业微信考勤报表获取数据报错(接口一次只支持100个userid)
    $chunks = array_chunk($useridlist, 100);
    $checkin_data = array();
    foreach ($chunks as $chunk) {
        $checkin_data = array_merge($checkin_data,$model_api->getcheckindata($token,$month_start,$month_end,$chunk));
    }

//    $checkin_data = $model_api->getcheckindata($token,$month_start,$month_end,$useridlist);

    //editor:gyq_139 reason:月度考勤增加显示补卡  2019/8/27 17:20
//`````````````获取审批（补卡）接口秘钥
    $token = $model_api->getcheckintoken($corpid,$secret_approve);
//由于一次请求返回的审批记录上限100条，超过100条记录使用next_spnum进行分页拉取。故使用递归实现分页拉取
    $reissue_data = [];//getapprovaldata_recurve($token,$month_start,$month_end,$model_api,$list,$next_spnum);
}
//删除同步时间段内的旧数据后插入新数据
$sql = 'delete from ld_wx_checkin where checkin_time between ? and ?';
$adb->pquery($sql,array($month_start,$month_end));
//zxm 20240425 优化insert语句
$checkin_data_arr = array_chunk($checkin_data,5000);
foreach ($checkin_data_arr as $checkin_data_trunk) {
    $insert_sql = 'insert into ld_wx_checkin (userid, groupname, checkin_type, exception_type, checkin_time, checkin_time_date,
        location_title, location_detail, wifiname, notes, wifimac, mediaids)
      values ';
    $placeholder_str = '';
    $placeholder_arr = array();
    $values_arr = array();
    foreach ($checkin_data_trunk as $key => $value) {
        $placeholder_arr[] = '(?,?,?,?,?,?,?,?,?,?,?,?)';
        $values_arr[] = $value['userid'];
        $values_arr[] = $value['groupname'];
        $values_arr[] = $value['checkin_type'];
        $values_arr[] = $value['exception_type'];
        $values_arr[] = $value['checkin_time'];
        $values_arr[] = date('Y-m-d H:i:s', $value['checkin_time']);
        $values_arr[] = $value['location_title'];
        $values_arr[] = $value['location_detail'];
        $values_arr[] = $value['wifiname'];
        $values_arr[] = $value['notes'];
        $values_arr[] = $value['wifimac'];
        $values_arr[] = json_encode($value['mediaids']);
    }
    $placeholder_str = implode(',',$placeholder_arr);
    $adb->pquery($insert_sql.$placeholder_str, $values_arr);
}


$sql = 'delete from ld_wx_checkin_reissue where checkin_time between ? and ?';
$adb->pquery($sql,array($month_start,$month_end));

/*$next_spnum = null;
$list = array();
$sp_num_exist = array();
//由于一次请求返回的审批记录上限100条，超过100条记录使用next_spnum进行分页拉取。故使用递归实现分页拉取
$reissue_data = [];//getapprovaldata_recurve($token,$month_start,$month_end,$model_api,$list,$next_spnum);*/

foreach ($reissue_data as $key=>$value){
    //避免分页时，分页第一条重复插入
    if(in_array($value['sp_num'],$sp_num_exist)){
        continue;
    }else{
        $sp_num_exist[] = $value['sp_num'];
    }
    $apply_data = json_decode($value['comm']['apply_data'],true);
    //可能有三种数据结构，故兼容处理
    if(isset($apply_data['applyBK'])){
        $checkin_value = $apply_data['applyBK']['value'];
    }else{
        if(is_array($apply_data[0]['value']))
            $checkin_value = $apply_data[0]['value'];
        else
            $checkin_value = $apply_data;
    }
    //获取补卡的时间
    $checkin_time = 0;
    foreach ($checkin_value as $key_two=>$value_two){
        if($value_two['type']=='datehour'){
            $checkin_time = substr( $value_two['value'],0,strlen( $value_two['value'])-3);
            break;
        }
    }
    if ($checkin_time > 0) {
        $checkin_time_date = date('Y-m-d H:i:s', $checkin_time );
        $sql = 'insert ld_wx_checkin_reissue ( sp_num, userid, sp_status,checkin_time, checkin_time_date) value (?,?,?,?,?)';
        $adb->pquery($sql,array($value['sp_num'],$value['apply_user_id'],$value['sp_status'],$checkin_time,$checkin_time_date));
    }
}
ConvertTojsonString(1,array($checkin_data,$reissue_data),'success');

//递归获取补卡列表
function getapprovaldata_recurve($token,$month_start,$month_end,$model_api,&$r_list,$next_spnum){
    $reissue_result = $model_api->getapprovaldata($token,$month_start,$month_end,$next_spnum);
    $reissue_data = $reissue_result['data'];
    $total = $reissue_result['total'];
    $count = $reissue_result['count'];
    $next_spnum = $reissue_result['next_spnum'];
    if($total > 100){
        getapprovaldata_recurve($token,$month_start,$month_end,$model_api,$r_list,$next_spnum);
    }
    $r_list = array_merge($reissue_data,$r_list) ;
    return $r_list;

}

function getapprovaldata_recurve_selfbuilt($month_start,$month_end,$corpApiObj,&$r_list,$next_spnum){
    $reissue_result = $corpApiObj->ApprovalDataGet($month_start,$month_end,$next_spnum);//修改接口返回值，返回初始数据
    if($reissue_result['errcode']===0) {
    }else{
        ConvertTojsonString(-1,array($reissue_result),getFixedLabel('CHECKINSETTING_TITLE4'));
    }
//    $reissue_result = $model_api->getapprovaldata($token,$month_start,$month_end,$next_spnum);
    $reissue_data = $reissue_result['data'];
    $total = $reissue_result['total'];
    $count = $reissue_result['count'];
    $next_spnum = $reissue_result['next_spnum'];
    if($total > 100){
        getapprovaldata_recurve_selfbuilt($month_start,$month_end,$corpApiObj,$r_list,$next_spnum);
    }
    $r_list = array_merge($reissue_data,$r_list) ;
    return $r_list;

}