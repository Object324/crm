<?php
//ls 2022-05-11 【1002809】页面设置，增加“快递查询组件”字段类型
//获取快递100接口信息
global $adb;
$smarty=new lingdangCRM_Smarty;
$express_company = vtlib_purify($_REQUEST['express_company']);
$phone = vtlib_purify($_REQUEST['phone']);
crm_load_class_file('KuaiDi100', 'WeiXinApp/kuaidi100');
$kuaidi_100_obj = new KuaiDi100();
if (empty($kuaidi_100_obj->key) && empty($kuaidi_100_obj->customer)){
    ConvertTojsonString(2, array(), 'success');
}
$express_no = vtlib_purify($_REQUEST['express_no']);
//查询物流信息
$result = $adb->pquery("SELECT * FROM ld_expressinfo where express_no = ?", array($express_no));
$syncquery_time = $adb->query_result($result, 0, 'query_time');
$cur_time = time();

if ($adb->num_rows($result) > 0 && ($cur_time-strtotime($syncquery_time)) < 60*40) {
    $express_info = ldcrm_json_decode($adb->query_result($result, 0, 'express_info'));
    //查询的时间点，缓存判断间隔默认40分钟以上
}else{
    $express_info = $kuaidi_100_obj->synquery($express_no, $express_company, $phone);
    if (empty($express_info['returnCode'])) {//为空说明返回值正常
        $adb->pquery("DELETE FROM ld_expressinfo where express_no = ?", array($express_no));
        $adb->pquery("INSERT INTO ld_expressinfo(`express_no`,`express_info`,`query_time`) values(?,?,?)", array($express_no, ldcrm_json_encode($express_info), date("Y-m-d H:i:s")));
    }else{
        ConvertTojsonString(-1, $express_info, 'success');
    }
}
if (!empty($express_info)){
    for ($i = 0; $i < sizeof($express_info['data']); $i++ ) {
        $statesDetail = $kuaidi_100_obj->getStatusDetail($express_info['data'][$i]['statusCode']);
        $express_info['data'][$i]['statusDetail'] = $statesDetail;
    }
}
$smarty->assign('EXPRESS_INFO', $express_info);
$arr['content']= $smarty->fetch('expressInfo.tpl');
ConvertTojsonString(1, $arr, 'success');


?>