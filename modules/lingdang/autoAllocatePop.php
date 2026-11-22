<?php
//zkt 20231009 XUQIU1001341 登录记住密码优化+SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
//lius 20230613 XUQIU1001607 圣拉维CRM项目：客户自动分配功能
$smarty = new lingdangCRM_Smarty;
$smarty->assign("fldname","customform24_id");//customform24_id cf_7528
$_REQUEST['diony']='diony';

$arr['title'] = getFixedLabel('AUTODISTRIBUTION').'('.getFixedLabel('CHANGETHERESPONSIBLEPERSON').')';
$arr['oktext']= getFixedLabel('CONFIRMED');
$arr['canceltext']=getFixedLabel("CANCEL");

$str=$smarty->fetch("Accounts/autoAllocatePop.tpl");
$arr['content']=$str;
ConvertTojsonString(1,$arr,"success");

?>