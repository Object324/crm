<?php
//zkt 20231023 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb,$current_user;
if(!empty($_REQUEST['commonmodules'])){
	$modules = explode(',',$_REQUEST['commonmodules']);
	if(sizeOf($modules) > 7){
		ConvertTojsonString(-1,array(),'error');
	}
	$moduleids = explode(',',$_REQUEST['commonmoduleids']);
	$delete = "delete from ld_appuiset where userid = ? and settype = 'module' and apptype = 'commonmodules'";
	$adb->pquery($delete,array($current_user->id));
	foreach($modules as $key => $mod){
        $insert = "insert into ld_appuiset(userid,settype,apptype,setname,tabid) values(?,?,?,?,?)";
        $adb->pquery($insert,array($current_user->id,'module','commonmodules',$mod,$moduleids[$key]));
    }
}
else{
	$delete = "delete from ld_appuiset where userid = ? and settype = 'module' and apptype = 'commonmodules'";
	$adb->pquery($delete,array($current_user->id));
}
ConvertTojsonString(1,array(),'success');

?>