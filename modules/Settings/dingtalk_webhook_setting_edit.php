<?php
//@edit:liushuai,2020-08-21,reason:【ID1001020】钉钉接口参数设置增加参数“钉钉群消息推送设置”
global $adb,$current_user;
require(globalStatic::$root_directory.'user_privileges/user_language_'.$current_user->id.'.php');
//$path = globalStatic::$root_directory."globalConfig/DingTalkWebhook.php";
$_REQUEST['diony']='yes';
$curtabid = $_REQUEST['tabid'];
$smarty = new lingdangCRM_Smarty;

$type = 'type';

$modulename = vtlib_getModuleNameById($curtabid);
$record = 0;
if(isset($_REQUEST['record']) && !empty($_REQUEST['record'])){  //编辑、复制
    $type = $_REQUEST['type'];
    $smarty->assign('TYPE', $type);
    $record = $_REQUEST['record'];
    $sql = 'select * from ld_dingtalk_msg_conf where id=?';
    $result = $adb->pquery($sql, array($record));
//    $dingtalk_conf_info = $adb->query_result_rowdata($result);
//    $dingtalk_conf_info = $adb->fetch_array($result);

    $tmp_tabid=$adb->query_result($result,0,'tabid');
    $curtabid = $tmp_tabid;
    $smarty->assign('record',$record);
    $smarty->assign('keywords',$adb->query_result($result,0,'keywords'));
    $smarty->assign('webhook',$adb->query_result($result,0,'webhook'));
    $smarty->assign('is_enable',$adb->query_result($result,0,'is_enable'));
    if ($_REQUEST['type'] == 'edit') {
        $smarty->assign('content',$adb->query_result($result,0,'content'));
    }elseif($_REQUEST['type'] == 'copy'){
        $smarty->assign('content','');
    }


    /*$webhook = $_REQUEST['webhook'];
    $is_enable = $_REQUEST['is_enable'];
    $webhookList[] = $webhook;//[] 比array_push要好
    $webhookList[] = $is_enable;
    @file_put_contents($path,serialize($webhookList));
    ConvertTojsonString(1,array(),"success");*/
}


$query="SELECT * FROM ld_tab WHERE presence IN (0,2) AND tabid NOT IN(SELECT tabid FROM ld_dingtalk_msg_conf where id <> ? ) ORDER BY tabid";//and ld_field.presence in (0,2)
$result=$adb->pquery($query,[$record]);

$num_rows=$adb->num_rows($result);

//$tab=array();//第一区块钉钉消息推送设置
$printtabs=array();//第二区块提醒内容设置
$no_show_arr = ["Reminds","Home","MassSMS","MassEmails","SmsPhrases","EmailListtmp","CommunicationLog","ModComments",
    "RecycleBin","Cache","Emails","SalesGoal","BankAccountSet","BankCash","MailManager","Productbom","Rate","Users",
    "CooperativeWork","ChinaMap","Singin","SocialPromotion","Articles","ChannelCode","Ambassador","WechatSession",
    "Questionnaire","WeChatUser","ShopSettings","ReportAnalysis"];

//判断模块是否启用了审批
crm_load_class_file('cls_ApproveCache','modules/Approve');
$approvemodule_arr =  cls_ApproveCache::getApproveModuleInfo();

if($num_rows){
    $k = 0;
    for($i=0;$i<$num_rows;$i++){
        $tmp_tabid=$adb->query_result($result,$i,'tabid');
        $tmp_module=$adb->query_result($result,$i,'name');

        if(!in_array($tmp_module,$approvemodule_arr) || in_array($tmp_module, $no_show_arr)){
            continue;
        }

        $printtabs[$tmp_tabid] = getTranstab($tmp_module);
        if ($k == 0 && ($_REQUEST['type'] == 'create')) {
            $curtabid = $tmp_tabid;
        }
        $k ++;
//        $tab[]=array('tabid'=>$tmp_tabid,
//            'tabname'=>getTranstab($tmp_module)
//        );
    }
}

//第一区块钉钉消息推送设置 废弃
//$smarty->assign('TAB',$tab);

//第二区块提醒内容设置
$smarty->assign("PRINTTABS",$printtabs);//可选模块
$smarty->assign("TABID",$curtabid);//当前模块tabid

$wildcard = getFixedLabel('WILDCARD').':　'.getFixedLabel('APPROVALSTEP').':[step]　　　　'.getFixedLabel('APPROVER')
    .':[approver]　　　　'.getFixedLabel('APPROVALNOTE').':[description]';
//$smarty->assign('WILDCARD',$wildcard);//内容模板灰色提示      //去掉提示符




/*$webhook = '';
$is_enable = 0;
if(file_exists($path)){
//    file_put_contents($path,serialize($webhookList));
    $webhookList = unserialize(@file_get_contents($path));
}
if (isset($webhookList[0]) && !empty($webhookList[0])) {
    $webhook = $webhookList[0];
}
if (isset($webhookList[1]) && !empty($webhookList[1])) {
    $is_enable = $webhookList[1];
}
$smarty = new lingdangCRM_Smarty;
$smarty->assign('webhook',$webhook);
$smarty->assign('is_enable',$is_enable);*/


$arr['tabid'] = $curtabid;
$arr['title'] = getFixedLabel('add_remind');
if(isset($_REQUEST['record']) && !empty($_REQUEST['record'])){
    $arr['title'] = getFixedLabel('edit_remind');
}

$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$arr['content']= $smarty->fetch('Settings/dingtalk_webhook_setting_edit.tpl');
ConvertTojsonString(1,$arr,"success");

?>