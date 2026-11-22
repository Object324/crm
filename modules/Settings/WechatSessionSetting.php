<?php
//ls  241031 XUQIU20240918-09 增加会话存档接口配置参数
global $adb;
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
$_REQUEST['diony']='yes';
$smarty = new lingdangCRM_Smarty;
$mode = $_REQUEST['mode'];
$mode = empty($mode)?'list':$mode;
$smarty->assign('mode',$mode);

//获取auth_info值
require_once (globalStatic::$root_directory . 'WeiXinApp/WeiXin_common/StaticConst.php');
$auto_info_json = doCorpInfo('get_auth_info','');
$info_arr = json_decode($auto_info_json, true);
$auth_info = $info_arr[StaticConst::$suite_crm];
if (!empty($auth_info)) {
    $sql = "select * from ld_wechatsession_conf where id = 1";
    $result = $adb->pquery($sql,array());
    if($adb->num_rows($result) < 1){
        $sql = "insert into ld_wechatsession_conf(id,corpindex,corpid,corp_link) values (?,?,?,?)";
        $adb->pquery($sql,array('1',$auth_info['corpindex'],$auth_info['auth_corp_info']['corpid'],$auth_info['corpurl']));
    }else{
        //防止auth_info信息变更，一般配置一次就很少重配了
        $sql = "update ld_wechatsession_conf set corpindex = ?, corpid=?, corp_link=? where id=1";
        $adb->pquery($sql,array($auth_info['corpindex'], $auth_info['auth_corp_info']['corpid'], $auth_info['corpurl']));
    }
}


if ($mode == 'save'){//保存设置
    $secret = trim($_REQUEST['secret']);
    $upload_way = trim($_REQUEST['upload_way']);
    $secretid = $secretkey = $bucketname = $region = "";//local时，清空配置项
    if ($upload_way == 'cos') {
        $secretid = trim($_REQUEST['secretid']);
        $secretkey = trim($_REQUEST['secretkey']);
        $bucketname =trim($_REQUEST['bucketname']);
        $region = trim($_REQUEST['region']);
    }
    $enable_remind = $_REQUEST['enable_remind'];

    $receiverids = $_REQUEST['receiverids'];
    if ($enable_remind == 'yes' && empty($receiverids)) {
        $receiverids = 1;
    }
    $remind_content = trim($_REQUEST['remind_content']);

    $is_enable = 'no';//用来控制会话存档java进程是否执行
    if (!empty($secret) && ($upload_way == 'cos' && !empty($secretid) && !empty($secretkey) && !empty($bucketname) && !empty($secretid))) {
        $is_enable = 'yes';
    }
    $sql = 'update ld_wechatsession_conf set is_enable=?, secret = ?, upload_way=?, secretid=?, secretkey=?, bucketname=?, region=?, enable_remind=?, receiverids=?, remind_content=? where id=1';
    $adb->pquery($sql, array($is_enable, $secret, $upload_way, $secretid, $secretkey, $bucketname, $region, $enable_remind, $receiverids, $remind_content));
}
elseif ($mode == 'logout') {//注销
    $sql = 'update ld_wechatsession_conf set is_enable=?, secret=?, upload_way=?, secretid=?, secretkey=?, bucketname=?, region=?, enable_remind=? where id=1';
    $adb->pquery($sql, array('no', '', 'local', '', '', '', '', 'no'));
}


$sql = "select * from ld_wechatsession_conf where id = 1";
$result = $adb->pquery($sql,array());
if($adb->num_rows($result) > 0){
    $secret = $adb->query_result($result,0,'secret');
    $is_enable = $adb->query_result($result,0,'is_enable');
    $upload_way = $adb->query_result($result,0,'upload_way');
    $secretid = $adb->query_result($result,0,'secretid');
    $secretkey = $adb->query_result($result,0,'secretkey');
    $bucketname = $adb->query_result($result,0,'bucketname');
    $region = $adb->query_result($result,0,'region');
    $enable_remind = $adb->query_result($result,0,'enable_remind');
    $receiverids = $adb->query_result($result,0,'receiverids');
    $remind_content = $adb->query_result($result,0,'remind_content');

    $receiverids_name = [];//提醒人姓名
    if (!empty($receiverids)) {
        $receiverids_arr = explode(',',$receiverids);
        foreach ($receiverids_arr as $tmp_userid) {
            $receiverids_name[] = getUserFullName($tmp_userid);
        }
    }


    $smarty->assign('secret',$secret);
    $smarty->assign('is_enable',$is_enable);//会话存档是否启用
    $smarty->assign('upload_way',$upload_way);
    $smarty->assign('secretid',$secretid);
    $smarty->assign('secretkey',$secretkey);
    $smarty->assign('bucketname',$bucketname);
    $smarty->assign('region',$region);
    $smarty->assign('enable_remind',$enable_remind);
    $smarty->assign('receiverids',$receiverids);
    $smarty->assign('receiverids_name',implode(',',$receiverids_name));
    $smarty->assign('remind_content',$remind_content);
}

$arr = [];
$arr['title'] = getFixedLabel('LBL_WECHATSESSION_SETTINGS');
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$arr['content'] = $smarty->fetch('Settings/WechatSessionSetting.tpl');
unset($smarty);
ConvertTojsonString(1,$arr,'success');

?>