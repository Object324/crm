<?php
//zkt 20231019 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
require_once (globalStatic::$root_directory.'include/Stock/CommonStock.php');
$arr = array();
if(isset($_REQUEST['setstock']) && $_REQUEST['setstock'] == 'yes'){
    //确认和撤销盘点
    if(isset($_REQUEST['recordid']) && $_REQUEST['recordid']>0)
    {
        $recordid = $_REQUEST['recordid'];
        updateCheckPresence($recordid);
    }
}else{
    global $currentModule;
    if(!empty($_REQUEST['recordid'])){
    	$infos = '';
    	$infos = getChecksProductInfo($_REQUEST['recordid'],1,selCheckInfo($_REQUEST['recordid'],2));
        if(sizeof($infos)>0) {
            ConvertTojsonString('-1',$infos,'error');
        } else {
            ConvertTojsonString('1',$infos,'success');
        }
//    	$arr = $infos;
    }
}
ConvertTojsonString(1,$arr,'success');
?>