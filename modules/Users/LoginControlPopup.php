<?php


global $adb;
global $current_user;
if(!is_admin($current_user))
{
    dump("please admin login");
    
}

$languageType=getLanguageType($current_user);


$deploy_value=90;//用户密码是否严格管理 1:否，0:是
 $sql = "select fieldlabel from ld_tranlabel where trantable='ld_systems_deploy' and languagetype='".$languageType."'
  and relateid=$deploy_value ";
      
$results = $adb->pquery($sql);
$pwdchecktitle=$adb->query_result($results,0,'fieldlabel');
$deploy_arr=getSys_deploy($deploy_value);
$pwdcheckvalue=$deploy_arr['deploy_value'];

$deploy_value=73;//设置登录时是否启用验证码 1：否
$sql = "select fieldlabel from ld_tranlabel where trantable='ld_systems_deploy' and languagetype='".$languageType."'
  and relateid=$deploy_value ";
      
$results = $adb->pquery($sql);
$checkcodetitle=$adb->query_result($results,0,'fieldlabel');
$deploy_arr=getSys_deploy($deploy_value);
$checkcodevalue=$deploy_arr['deploy_value'];
$strhtml='<div class="ld-pop-container">';
$strhtml.='<div>'.$pwdchecktitle.'</div>';
if($pwdcheckvalue==1)
{
    //用户密码是否严格管理 1:否，0:是
    $strhtml.='<div class="select-input" style="padding: 6px 0 16px 0;"><input type="radio"  value="0" name="pwdcheck" id="pwdcheck1"><label class="padR40" for="pwdcheck1">'.getFixedLabel("YES").'</label><input type="radio" name="pwdcheck" id="pwdcheck2" value="1" checked><label for="pwdcheck2">'.getFixedLabel("NO").'</label></div>';
}
else
{
    $strhtml.='<div class="select-input" style="padding: 6px 0 16px 0;"><input type="radio" value="0" checked name="pwdcheck" id="pwdcheck1"><label class="padR40" for="pwdcheck1">'.getFixedLabel("YES").'</label><input type="radio" name="pwdcheck" id="pwdcheck2" value="1" ><label for="pwdcheck2">'.getFixedLabel("NO").'</label></div>';
}
$strhtml.='<div>'.$checkcodetitle.'</div>';
if($checkcodevalue==1)
{
    //设置登录时是否启用验证码 1：否
    $strhtml.='<div class="select-input" style="padding: 6px 0 16px 0;"><input type="radio" value="0" name="checkcode" id="checkcode1"><label class="padR40" for="checkcode1">'.getFixedLabel("YES").'</label><input type="radio" name="checkcode" id="checkcode2" value="1" checked><label for="checkcode2">'.getFixedLabel("NO").'</label></div>';
}
else
{
    $strhtml.='<div class="select-input" style="padding: 6px 0 16px 0;"><input type="radio" value="0" checked name="checkcode" id="checkcode1"><label class="padR40" for="checkcode1">'.getFixedLabel("YES").'</label><input type="radio" id="checkcode2" name="checkcode" value="1" ><label for="checkcode2">'.getFixedLabel("NO").'</label></div>';
}

$deploy_value=322;
$deploy_arr=getSys_deploy($deploy_value);//设置系统登陆时密码连续输错次数
$time=$deploy_arr['deploy_value'];

$PwdErrorAllowTimesTitle=str_replace("{n}",'<input type="text" class="ld-input-inner ld-input-inner-small" name="customtime" value="'.$time.'" style="width:40px;text-align: center;margin: 0 5px;"/>',getFixedLabel('PwdErrorAllowTimes'));//3)：设置系统登陆时密码连续输错3次后，不允许登陆的限制时长（为空表示不限制时长，允许登陆）

$deploy_value=323;
$deploy_arr=getSys_deploy($deploy_value);
$timelimitvalue=$deploy_arr['deploy_value'];
$strhtml.='<div>'.$PwdErrorAllowTimesTitle.'</div>';
$inputvalue_arr=ldcrm_json_decode(html_entity_decode($deploy_arr['inputvalue']));
$strhtml.='<div class="select-input" style="padding: 6px 0 16px 0;">';

foreach($inputvalue_arr as $tmptitle)
{
    if($deploy_arr['deploy_value']==$tmptitle['value'])
    {
        $strhtml.='<input type="radio" value="'.$tmptitle['value'].'" tag="'.$tmptitle['text'].'" checked name="timelimit" id="timelimit'.$tmptitle['value'].'">';
    }
    else
    {
        $strhtml.='<input type="radio" value="'.$tmptitle['value'].'" tag="'.$tmptitle['text'].'" name="timelimit" id="timelimit'.$tmptitle['value'].'">';
    }
    if(empty($tmptitle['value']))
    {
       
        $strhtml.='<label class="padR40" for="timelimit'.$tmptitle['value'].'">'.getFixedLabel($tmptitle['text']).'</label>';
    }
    else if($tmptitle['text']=='custom')
    {
        $strhtml.='<label class="padR40" for="timelimit'.$tmptitle['value'].'">'.getFixedLabel($tmptitle['text']).'<input class="ld-input-inner ld-input-inner-small" name="customminute" type="text" value="'.$tmptitle['value'].'" style="width:40px;text-align: center;margin: 0 5px;">'.getFixedLabel('MINUTE').'</label>';
    }
    else{
        $strhtml.='<label class="padR40" for="timelimit'.$tmptitle['value'].'">'.getFixedLabel($tmptitle['text']).getFixedLabel('MINUTE').'</label>';
    }
}
$strhtml.='</div>';


crm_load_class_file('cls_Send_MassSms','include/utils');
$cls_Send_MassSms = cls_Send_MassSms::getInstance();
$platform = $cls_Send_MassSms->platform;
if ($platform == 'aliyun') {
    //获取是否已设置短息模板
    $smsdetail_arr = $cls_Send_MassSms->getSmsRelatedByScene($platform,"crmlogin_verifycode");
    $select_tempplateid = '';
    if(count($smsdetail_arr)>0){
        $select_tempplateid = $smsdetail_arr['templateid'];
    }

    $smsTemplate_arr = $cls_Send_MassSms->getSmsTemplatePresenceSingleVerifyCode($platform);
    $strhtml.='<div>'.getFixedLabel('SetLoginSMSTemplate').'</div>';
    $strhtml.='<div class="select-input" style="padding: 6px 0 20px 0;">';
    $strhtml.= '<select name="smstemplatelist" class="ld-select-inner">';
    $strhtml.= '<option value=""></option>';
    if (count($smsTemplate_arr)>0) {
        foreach ($smsTemplate_arr as $smsTemplate) {
            $selected = $smsTemplate['templateid'] == $select_tempplateid?"selected":"";
            $strhtml.='<option value="'.$smsTemplate['templateid'].'" '.$selected.'>'.$smsTemplate['templatename'].'</option>';
        }
    }
    $strhtml.= '</select>';
    $strhtml.= '</div>';

    unset($smsTemplate_arr);
}

$strhtml.='</div>';
$_REQUEST['diony']='yes';
//密码严格管理规则帮助
$labels = array('LoginControl');
foreach($labels as $label){
    $helpHtmlArr[$label] = getHelpHtmlByLabel('Settings',1,'HelpUrl_'.$label);
}
if (!empty($helpHtmlArr['LoginControl'])){
    $arr['helpHtml'] = '<div class="ld-btn-icontext-items lfloat">'.$helpHtmlArr['LoginControl'].'</div>';
}
ConvertTojsonString(1,['content'=>$strhtml,'title'=>getFixedLabel('LoginControl'),'helpHtml'=>$arr['helpHtml'],'oktext'=>getFixedLabel("CONFIRMED"),'canceltext'=>getFixedlabel("CANCEL")],'success');


?>