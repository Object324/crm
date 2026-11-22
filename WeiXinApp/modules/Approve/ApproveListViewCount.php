<?php
//zkt 20231019 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb,$current_user;
crm_load_class_file('cls_Approve_CountListViewWX','WeiXinApp/modules/Approve/cls_Approve');
if(isset($_REQUEST['approvestatus']) && !empty($_REQUEST['approvestatus'])){
	$approvestatus = $_REQUEST['approvestatus'];
}else{
	$approvestatus = 0;
}
$arrapprove=array(0,1,2);
if(!in_array($approvestatus,$arrapprove))
{
    ConvertTojsonString('-1',null,getFixedLabel('PARAMETERINPUTERROR'));    
}

$cls_Approve_CountListView = new cls_Approve_CountListViewWX($approvestatus);
$approveinfo = $cls_Approve_CountListView->getapprovelist();

if(!empty($approveinfo)){
	for($i = 0; $i<count($approveinfo); $i++){
		$approveinfo[$i]['label'] = getTranstab($approveinfo[$i]['module']);
	}
}
$list['list'] = $approveinfo;
ConvertTojsonString(1,$list,'');

?>