<?php
//zkt 20231023 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
//@edit:liushuai,2020-09-02,reason:【ID1001055】/销售线索增加审批功能(只有审批通过后才能继续升级流程),(升级时查询审批是否已批准)
global $adb;
$_REQUEST['diony']='yes';
$record = $_REQUEST['record'];
if(getSys_deploy(260)['deploy_value'] == 1){  //未开启不用判断是否已审批
    ConvertTojsonString(1,array(),"success");
}
if(isset($record) && !empty($record)){
    $sql = 'select approvestatus from ld_leads  where leadsid=? ';
    $result = $adb->pquery($sql,array((int)$record));
    if($adb->num_rows($result)>0)
    {
        $approvestatus = $adb->query_result($result, 0, 'approvestatus');
        if ($approvestatus == '已批准') {
            ConvertTojsonString(1,array(),"success");
        }
    }
}
ConvertTojsonString(-1,array(),getFixedLabel('BEFOREOPERATIONTHISRECORDAPP'));
?>