<?php
global $adb;
$_REQUEST['diony']='diony';

crm_load_class_file('cls_Send_MassSms','include/utils');
$cls_Send_MassSms = cls_Send_MassSms::getInstance();
$platform = $cls_Send_MassSms->platform;
$operationtype = $_REQUEST['operationtype'];
if ($operationtype == 'syncsms') {
    $cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
    $cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();

    if ($platform == 'aliyun') {
        //1、接口获取模板列表详情
        $aliyunSmsTemplates_arr = $cls_Send_MassSms->QuerySmsTemplateList();

        if (!empty($cls_Send_MassSms->error)) {
            ConvertTojsonString(-1,array(),getFixedLabel("SyncMsg"));
        }

        //2、crm短信表的templatecode的集合
        $crmSmsTemplate_arr = $cls_Send_MassSms->getSmsTemplateAllByPlatform($platform);
        $crmSmsTemplateCode_arr = !empty($crmSmsTemplate_arr)?array_column($crmSmsTemplate_arr, 'templatecode'):[];

        $aliyunSmsTemplateCode_arr = [];
        if (is_array($aliyunSmsTemplates_arr) && count($aliyunSmsTemplates_arr)>0) {

            foreach ($aliyunSmsTemplates_arr as $temp) {
                $templateDetail = $cls_Send_MassSms->GetSmsTemplate($temp['TemplateCode']);//获取模板详情
                if (empty($templateDetail)) continue;
                $templatecode = $templateDetail['TemplateCode'];
                array_push($aliyunSmsTemplateCode_arr,$templatecode);//记录aliyun后台短信模板code的集合

                //3、插入新增短信模板（这里能获取到的短信模板都是启用的，存在的需要更新模板名称）
                if (in_array($templatecode,$crmSmsTemplateCode_arr)) {
                    //continue;//已存在模板不处理，因为aliyun审核通过的模板是不允许修改的。   ps：后面发现模板名称可以修改，还是更新一下比较好。
                    $sql = "UPDATE ld_smstemplates SET templatename=?, deletedreason='' WHERE templatecode=?";
                    $adb->pquery($sql,array($templateDetail['TemplateName'],$templatecode));
                }else{
                    $variableAttribute = $templateDetail['VariableAttribute'] != '{}'?$templateDetail['VariableAttribute']:'';

                    $templateid=$adb->getUniqueID('ld_smstemplates');//主键还得自己取。。
                    $sql = "INSERT IGNORE INTO ld_smstemplates (templatecode, templateid, templatename, body, template_type, templatecontent, templateparaminfo, signname, platform)
VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
                    $adb->pquery($sql,array($templatecode,$templateid,$templateDetail['TemplateName'],$templateDetail['TemplateContent'],$templateDetail['TemplateType'],$templateDetail['TemplateContent'],$variableAttribute,$templateDetail['RelatedSignName'], $platform));
                }


                /* //担心php83不支持这种写法  故需要改写
                 $sql = "INSERT INTO ld_smstemplates (templatecode, templateid, templatename, body, template_type, templatecontent, templateparaminfo, signname, platform) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?) ON DUPLICATE KEY UPDATE templatename=VALUES(templatename), deletedreason='';";
                $adb->pquery($sql,array($templatecode,$templateid,$templateDetail['TemplateName'],$templateDetail['TemplateContent'],$templateDetail['TemplateType'],$templateDetail['TemplateContent'],$variableAttribute,$templateDetail['RelatedSignName'], $platform));*/

            }


        }//没有获取到数据,1、接口错误 2、没有可用短信模板

        //4、标记阿里云后台已删除模板为不启用状态
        $disableCode_arr = array_diff($crmSmsTemplateCode_arr,$aliyunSmsTemplateCode_arr);
        if (count($disableCode_arr)>0) {
            $sql = "update ld_smstemplates set deleted = 1,deletedreason=? where templatecode in ('" . implode("', '", $disableCode_arr) . "')";
            $adb->pquery($sql,array('未通过审核'));
        }
        unset($aliyunSmsTemplates_arr);
    }


    unset($cls_Send_MassSms,$crmSmsTemplateCode_arr);
    ConvertTojsonString(1,array(),"success");

}
/**
 * edit:kevin
 * date:2013-06-25
 * reason:保存短信模板
 */

 $templatename=from_html($_REQUEST['templatename']);
 $body=fck_from_html($_REQUEST['body']);
 if(isset($_REQUEST['templateid'])&&$_REQUEST['templateid']!=""){
    $templateid=$_REQUEST['templateid'];
    $where=" templateid=".$templateid;
 }

if($templateid!=''){
    $query="update ld_smstemplates set templatename=?,body=?,template_type=? where 1=1 and ".$where;
    $adb->pquery($query,array($templatename,$body,$_REQUEST['template_type']));
}
else{
     $query="insert into ld_smstemplates(templateid,templatename,body,template_type,platform) value(?,?,?,?,?)";
     $templateid=$adb->getUniqueID('ld_smstemplates');
     $adb->pquery($query,array($templateid,$templatename,$body,$_REQUEST['template_type'],$platform));
}
 ?>