<?php
//zkt 20231023 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
crm_load_class_file('cls_ReportDetailInfoWX','WeiXinApp/modules/Dashboard');
$detailObj = new cls_ReportDetailInfoWX($_REQUEST['record']);
$detailObj->setBoardId($_REQUEST['selected_homeboardid']);
$name=$_REQUEST['report_name'];
$method='get'.$name;
$jsonArray=$detailObj->$method();
$selectuid = trim($_REQUEST['selectuid'],',');
 $Group_Special = crm_load_class_obj('Group_Special', 'modules/Users');
 //41040: （企业微信，can013灵当crm系统）报表->销售龙虎榜：查看范围没有显示成员值
 $userids=$selectuid;

 if($selectuid=='all'){
    $module_users = getCurSmOwnerSearchScope('MobileReport');
 
    $userids=array_key_exists($module_users['UserCombo']);
    
 }
 $userinfoArr = $Group_Special->getuserinfoStr($userids);
 $jsonArray['userinfo']=$userinfoArr;
$_REQUEST['diony']='yes';
$jsonArray['arrFixedLabel'] = $detailObj->getlabel_arr();
ConvertTojsonString(1,$jsonArray,'success');

?>