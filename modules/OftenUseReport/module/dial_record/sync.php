<?php
//ls 2021-12-27 【1002356】公费电话直拨支持数据统计报表（蔡云桥-山水）
header('Content-Type:text/html;charset=UTF-8');
date_default_timezone_set("PRC");
global $adb,$current_user;

$_REQUEST['diony'] = 'diony';
require_once(globalStatic::$root_directory.'appCommon/appCommon.php');
require_once(globalStatic::$root_directory.'WeiXinApp/lib/EventFromApiModel.php');
$model_api = new EventFromApiModel();

//``````````保存公费电话secret
if (isset($_REQUEST['secret']) && $_REQUEST['secret'] != '') {
    $secret = trim($_REQUEST['secret']);

    $adb->pquery("update ld_wx_config set para_content=? where name=?",array($secret,"dial_record"));
    ConvertTojsonString(1, array(), 'success');
}

//``````````获取系统配置参数
$sql = "select para_content from ld_wx_config where para_content <> '' and name=?";
$result = $adb->pquery($sql,array('dial_record'));

if($adb->num_rows($result) > 0) {
    include_once (globalStatic::$root_directory . 'WeiXinApp/WeiXin_common/StaticConst.php');
    $wx_authinfo = doCorpInfo("get_auth_info",array());
    $wx_authinfo = ldcrm_json_decode($wx_authinfo);
    $corpid = $wx_authinfo['crm']['auth_corp_info']['corpid'];
    $secret = $adb->query_result($result, 0, 'para_content');

//    $corpid = "wwf213ef0a1ca774c4";
//    $secret = "XHMd7xLqRARPhaU59RKYsj4l-5QOkQ6q-ZPmjV6SoJk";
}else{
//    $arr['title'] = "请输入公费电话Secret";
    $arr['title'] = getFixedLabel('DialRecordSyncMsg3');
    $arr['oktext']=getFixedLabel("SAVE");
    $arr['canceltext']=getFixedLabel("CANCEL");
    $arr['content'] = "<div style='padding: 10px 10px;'>
<p style='padding: 0 10px 10px 0;'>请登录企业微信后台-》应用管理-》公费电话-》点击API查看Secret；</p>
<font color='red'>*</font>Secret：<input name='secret' type='text' value='' tag='Secret' style='border:1px solid #dbdbdb;border-radius: 4px;line-height: 25px;margin-left: 15px;width: 400px;'>
</div>";
    ConvertTojsonString(2,$arr,"success");
//    ConvertTojsonString(-1,array(),getFixedLabel('DialRecordSyncMsg3'));
}


//```````````格式化同步时间范围
$start_time = $_REQUEST['startmonth'];
if(empty($start_time)){
    $month = date('Y-m');
    $start_time = strtotime($month);//指定月份月初时间戳
    $end_time = mktime(23, 59, 59, date('m', strtotime($month))+1, 00);//指定月份月末时间戳
}else{
    $start_time =  strtotime( $start_time.' 00:00:00');
    $end_time = strtotime( $_REQUEST['endmonth'].' 23:59:59');
}

if (($end_time < $start_time) || ($start_time > time())) {
    ConvertTojsonString(-1,array(),getFixedLabel('DialRecordSyncMsg1'));
} elseif (($end_time - $start_time) > 86400*60) {
    ConvertTojsonString(-1,array(),getFixedLabel('DialRecordSyncMsg2'));
}


//`````````````获取公费电话拨打记录
$offset = 0;
$list = array();
//$dial_data = get_dial_record_recurve($corpid,$secret,$start_time,$end_time,$model_api,$list,$offset);

$pending_date_arr = prMonths(date("Y-m-d",$start_time),date("Y-m-d",$end_time));
foreach ($pending_date_arr as $pending_date) {
    $dial_data = get_dial_record_recurve($corpid,$secret,strtotime($pending_date['0'].' 00:00:00'),strtotime($pending_date[1].' 23:59:59'),$model_api,$list,$offset);
}

require_once(globalStatic::$root_directory . 'WeiXinApp/WeiXin_common/cls_WeixinPort.php');
$weixinportobj=new cls_WeixinPort();
if (!empty($dial_data)) {
    //删除同步时间段内的旧数据后插入新数据
//    $adb->pquery('delete from ld_dial_record where call_time between ? and ?',array($start_time,$end_time));
    $adb->pquery('DELETE ld_dial_record,ld_dial_record_details FROM ld_dial_record LEFT JOIN ld_dial_record_details ON ld_dial_record.id=ld_dial_record_details.dialid WHERE ld_dial_record.call_time between ? and ?',array(date('Y-m-d H:i:s',$start_time),date('Y-m-d H:i:s',$end_time)));

    foreach ($dial_data as $value){
//ls 2022-04-02 0050788: （https://www.51mis.com/hy/TY315/index.php [^]）常用报表》 公费电话拨打统计表，同步公费电话记录后不显示数据（公费电话wx_userid返回值为明文，表ld_users为密文）
        $converuseridarr=$weixinportobj->getConvertUserId(array($value['caller']['userid']));
        if(is_array($converuseridarr)&&sizeof($converuseridarr['result'])>0) {
            foreach($converuseridarr['result'] as $info) {
                if($info['userid'] == $value['caller']['userid']) {
                    $sql='select 1 from ld_users where wx_userid=? limit 1';
                    $tmpresult=$adb->pquery($sql,array($info['userid']));
                    if($adb->num_rows($tmpresult)<=0)
                        $value['caller']['userid']=$info['open_userid'];
                    break;
                }
            }
        }

        $sql = 'insert into ld_dial_record (call_type, call_time, total_duration, caller_wx_userid, caller_duration) values (?,?,?,?,?)';
        $call_type = $value['call_type'] == 1?'单人':"多人";
        $adb->pquery($sql, array($call_type, date('Y-m-d H:i:s', $value['call_time']), $value['total_duration'], $value['caller']['userid'], $value['caller']['duration']));
        $dialid = $adb->getLastInsertID();
        foreach ($value['callee'] as $tmp_val) {
            $converuseridarr=$weixinportobj->getConvertUserId(array($tmp_val['userid']));
            if(is_array($converuseridarr)&&sizeof($converuseridarr['result'])>0) {
                foreach($converuseridarr['result'] as $info) {
                    if($info['userid'] == $tmp_val['userid']) {
                        $sql='select 1 from ld_users where wx_userid=? limit 1';
                        $tmpresult=$adb->pquery($sql,array($info['userid']));
                        if($adb->num_rows($tmpresult)<=0)
                            $tmp_val['userid']=$info['open_userid'];
                        break;
                    }
                }
            }

            $sql = 'insert into ld_dial_record_details (dialid, callee_wx_userid, callee_phone, callee_duration) values (?,?,?,?)';
            $adb->pquery($sql, array($dialid, $tmp_val['userid'], $tmp_val['phone'], $tmp_val['duration']));
        }
    }
}

ConvertTojsonString(1,$dial_data,'success');

//递归获取
function get_dial_record_recurve($corpid,$secret,$start_time,$end_time,$model_api,&$r_list,$offset){
    $dial_data = $model_api->get_dial_record($corpid,$secret,$start_time,$end_time,$offset);

    if(count($dial_data) == 100){ //说明需要分页获取
        get_dial_record_recurve($corpid,$secret,$start_time,$end_time,$model_api,$r_list,$offset+1);
    }
    if (!empty($dial_data))
        $r_list = array_merge($dial_data,$r_list);
    return $r_list;

}

//获取两个日期间以30天为界 分割 eg：prMonths("2020-10-01","2022-12-31")
function prMonths($start_date='',$end_date='')
{
    if(!$start_date || !$end_date) {
        return [];
    }

    $temp_date = $start_date;
    $month_arr = [];
    $end_time = strtotime($end_date);

    do {

//        $start_date = date('Y-m-d', strtotime("$start_date +1 month -1 day"));
        $start_date = date('Y-m-d', strtotime("$start_date +29 day"));
        $start_time = strtotime($start_date);
        if($end_time<$start_time) {
            $month_arr[] = array($temp_date,$end_date);
            break;
        } else {
            $month_arr[] = array($temp_date,$start_date);
        }
        $temp_date = $start_date = date('Y-m-d', strtotime("+1 day",$start_time));

    }while($start_time < $end_time);

    return $month_arr;
}