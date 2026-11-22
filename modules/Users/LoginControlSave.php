<?php

global $adb;
global $current_user;
if(!is_admin($current_user))
{
    dump("please admin login");
    
}
$_REQUEST['diony']='yes';
$customtime=$_REQUEST['customtime'];
if(!is_numeric($customtime)||$customtime<=0||intval($customtime)<$customtime)
{
    ConvertTojsonString(-1,array(),'次数只能是大于1的正整数!');
}
$pwdcheckvalue=$_REQUEST['pwdcheckvalue'];
$checkcodevalue=$_REQUEST['checkcodevalue'];
$timelimitvalue=$_REQUEST['timelimitvalue'];
$timelimittag=$_REQUEST['timelimittag'];
if($timelimittag=='custom')
{
    if(!is_numeric($timelimitvalue)||$timelimitvalue<=0)
    {
        ConvertTojsonString(-1,array(),getFixedLabel('Limittimethan1'));
    }
}
$sql='update ld_systems_deploy set deploy_value=? where deploy_type=322 ';//设置系统登陆时密码连续输错的次数
$adb->pquery($sql,array($customtime));


$sql='update ld_systems_deploy set deploy_value=? where deploy_type=90 ';//90;//用户密码是否严格管理 1:否，0:是
$adb->pquery($sql,array($pwdcheckvalue));

$sql='update ld_systems_deploy set deploy_value=? where deploy_type=73 ';//73;//设置登录时是否启用验证码 1：否
$adb->pquery($sql,array($checkcodevalue));


$sql='update ld_systems_deploy set deploy_value=? where deploy_type=323 ';//323设置系统登陆时密码连续输错3次后，不允许登陆的限制时长（为空表示
$adb->pquery($sql,array($timelimitvalue));
if($timelimittag=='custom')
{
    $sql='select inputvalue from ld_systems_deploy where deploy_type=323';
    $result=$adb->pquery($sql,array());
    $inputvalue=$adb->query_result($result,0,'inputvalue');
    $inputvalue=html_entity_decode($inputvalue, ENT_QUOTES, $default_charset);
    $inputvalue_arr=ldcrm_json_decode($inputvalue);
    foreach($inputvalue_arr as &$inputinfo)
    {
        if($inputinfo['text']=='custom')
        {
            $inputinfo['value']=$timelimitvalue;
            break;
        }
    }
   
    $sql='update ld_systems_deploy set inputvalue=? where deploy_type=323 ';
    $adb->pquery($sql,array(ldcrm_json_encode($inputvalue_arr)));
    
    
}

crm_load_class_file('cls_Send_MassSms','include/utils');
$cls_Send_MassSms = cls_Send_MassSms::getInstance();
if ($cls_Send_MassSms->platform == 'aliyun') {
    $templateid=$_REQUEST['smstemplateid']??'';
    if (!empty($templateid)) {
        $smsdetail_arr = $cls_Send_MassSms->getSmsTemplateById($templateid);
        if (is_array($smsdetail_arr) && count($smsdetail_arr)>0) {
            $templateparamconf = $smsdetail_arr['templateparaminfo'];
            $sql = "select 1 from ld_smsrelated where scene=?";
            $result = $adb->pquery($sql,array("crmlogin_verifycode"));
            if ($adb->num_rows($result) > 0) {
                $sql = "update ld_smsrelated set relatedid=?,template_id=?,templateparamconf=? where scene=?";
                $adb->pquery($sql,array($templateid,$templateid,$templateparamconf,"crmlogin_verifycode"));
            }else{
                $cls_Send_MassSms->insertSmsRelated("ld_smstemplates", $templateid, '', $templateid, $templateparamconf, "crmlogin_verifycode");
            }
        }
    }else{
        $sql = "delete from ld_smsrelated where scene=?";
        $adb->pquery($sql,array("crmlogin_verifycode"));
    }

}



getSys_deploy('aa');//清空系统参数缓存



ConvertTojsonString(1,array(),'success');

?>