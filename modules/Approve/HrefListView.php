<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $theme;

$theme_path="themes/".$theme."/";

$image_path=$theme_path."images/";

global $mod_strings,$currentModule;

//zkt 20230421 BUG0064474 审批中心，点击合同订单开始处理，选择查看范围后，全部合计值没有重算----计算合计时应取当前界面显示的范围
if(!empty($_REQUEST['fromapprovemodule']) && $_REQUEST['getTotalHtml'] != 'yes'){
	$fromApproveModule = $_REQUEST['fromapprovemodule'];
	unset($_SESSION['lvs'][$currentModule.'_'.$fromApproveModule]['SearchScope']);
	unset($_SESSION['customview'][$currentModule.'_'.$fromApproveModule]['viewid']);
}
$fromapprovemodule = $_REQUEST['fromapprovemodule'];
$approvestatus = $_REQUEST['approvestatus'];
 //$location="index.php?action=ApproveAjax&file=ListView&module=Approve&"."fromapprovemodule=$fromapprovemodule&approvestatus=".$approvestatus;
//header("Location:".$location);
//41244: （61mis.com/kfbcrm）审批中心>已处理>收款单：点击翻页按钮和GO按钮没有反应。（需要补丁）
include('modules/Approve/ListView.php');
?>