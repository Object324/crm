<?php
//editor:gyq_135 reason:微信打卡同步至月度考勤表  2019/8/14 17:46 ID1000568
global $adb,$current_user;
require(globalStatic::$root_directory.'user_privileges/user_language_'.$current_user->id.'.php');
if(isset($_REQUEST['ajax'])&&$_REQUEST['ajax']=='save'){
    $corpid = $_REQUEST['corpid'];
    $secret = $_REQUEST['secret'];
    //editor:gyq_139 reason:月度考勤增加显示补卡  2019/8/28 11:03 
    $secret_approve = $_REQUEST['secret_approve'];
    //editor:gyq_155 reason:钉钉考勤同步  2019/10/28 17:00 ID1000624
    $interfaceType = $_REQUEST['interfaceType'];
    if($interfaceType=='dingtalk'){
        $sql = "update ld_wx_config set usertype=? where name=?";
        $adb->pquery($sql,array($interfaceType,'checkin_monthly'));
    }elseif ($interfaceType=='weixin'){
        $sql = "update ld_wx_config set usertype=?,para_one=?,para_two=?,para_three=? where name=?";
        $adb->pquery($sql,array($interfaceType,$secret_approve,$corpid,$secret,'checkin_monthly'));
    }
	$_REQUEST['diony']='diony';
    ConvertTojsonString(1,array(),"success");
}
// 注销时执行的逻辑
if(isset($_REQUEST['ajax'])&&$_REQUEST['ajax']=='delete'){
    $sql = "update ld_wx_config set usertype=?,para_one=?,para_two=?,para_three=? where name=?";
    $adb->pquery($sql,array('','','','','checkin_monthly'));
    $_REQUEST['diony']='diony';
    ConvertTojsonString(1,array(),"success");
}
$smarty = new lingdangCRM_Smarty;

$sql = "select switch,para_one,para_two,para_three,usertype from ld_wx_config where name=?";
$result = $adb->pquery($sql,array('checkin_monthly'));
if($adb->num_rows($result)){

    $corpid = $adb->query_result($result,0,'para_two');
    $secret = $adb->query_result($result,0,'para_three');
    $switch = $adb->query_result($result,0,'switch');
    $secret_approve = $adb->query_result($result,0,'para_one');
    $interfaceType = $adb->query_result($result,0,'usertype');
    $smarty->assign('SWITCH',$switch);
    $smarty->assign('CORPID',$corpid);
    $smarty->assign('SECTRET',$secret);
    $smarty->assign('SECTRET_APPROVE',$secret_approve);
    $smarty->assign('INTERFACETYPE',$interfaceType);

}
$smarty->assign('LANGUAGETYPE',$languageType);
$_REQUEST['diony']='diony';
$arr['title'] = getFixedLabel('CHECKINSETTING');
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$str=$smarty->fetch("Settings/checkin_setting_edit.tpl");
$arr['content']=$str;
ConvertTojsonString(1,$arr,"success");
exit();

?>