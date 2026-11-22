<?php
//ls 2022-05-11 【1002809】页面设置，增加“快递查询组件”字段类型
//获取快递100接口信息
global $adb,$current_user;
$_REQUEST['diony']='yes';
crm_load_class_file('KuaiDi100','WeiXinApp/kuaidi100');
$kuaidi100_obj = new KuaiDi100();
if (empty($kuaidi_100_obj->key) || empty($kuaidi_100_obj->customer)){
    ConvertTojsonString(-1, array(), getFixedLabel('DEFAULTNOTSUPPORTMOBILE'));
}

$type = vtlib_purify($_REQUEST['type']);
if (empty($type))
    $type = 'synquery';

switch ($type) {
    case 'synquery':
        $express_no = vtlib_purify($_REQUEST['express_no']);
        if (empty($express_no)) {
            ConvertTojsonString(-1, array(), getFixedLabel('LOGISTICSCANNOTEMPTY'));
        }

        //查询物流信息
        $result = $adb->pquery("SELECT * FROM ld_expressinfo where express_no = ?",array($express_no));
        $syncquery_time = '';
        if ($adb->num_rows($result) > 0) {
            $express_info = $adb->query_result($result, 0, 'express_info');
            $syncquery_time = $adb->query_result($result, 0, 'query_time');
        }

        //查询的时间点，缓存判断间隔默认40分钟以上
        if (!empty($syncquery_time)) {
            $cur_time = time();
            if (($cur_time-strtotime($syncquery_time)) < 60*40) {
//                ConvertTojsonString(-1, array(), '物流单号查询间隔需再等待'.(40-floor(($cur_time-strtotime($syncquery_time))/60)).'分钟后重试');
                ConvertTojsonString(1, Zend_Json::decode($express_info), sprintf(getFixedLabel('WAITANOTHERTMPMINUTES'),(40-floor(($cur_time-strtotime($syncquery_time))/60))));
            }
        }

        $express_company = vtlib_purify($_REQUEST['express_company']);
        $phone = vtlib_purify($_REQUEST['phone']);

        //判断手机号 实测可无需手机号，先注释
        /*if (in_array($express_company,array('顺丰速运','丰网速运')) && empty($phone)) {
            ConvertTojsonString(-1, array(), $express_company.'的收、寄件人的电话号码需必填一个');
        }*/


        $data = $kuaidi100_obj->synquery($express_no,$express_company,$phone);
        
        //duan 20221020 移动端增加翻译
        $label_arr=array(
            'EXPRESSINQUIRY',//快递查询
            'nodata',//没有数据
            'CANCEL',//取消
        );
        $data['arrFixedLabel']=TransFieldlabel($label_arr,'no');

        if (empty($express_info['returnCode']) && $express_info['message'] == 'ok') {//为空说明返回值正常
            $adb->pquery("DELETE FROM ld_expressinfo where express_no = ?",array($express_no));
            $adb->pquery("INSERT INTO ld_expressinfo(`express_no`,`express_info`,`query_time`) values(?,?,?)",array($express_no,ldcrm_json_encode($data),date("Y-m-d H:i:s")));
        }else{
            ConvertTojsonString(-1,$data,$data['message']);
        }
        ConvertTojsonString(1,$data,'success');

        break;
    default:
        break;
}

ConvertTojsonString(1,array(),'success');



?>