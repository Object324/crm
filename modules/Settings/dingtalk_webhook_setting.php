<?php
//@edit:liushuai,2020-08-21,reason:【ID1001020】钉钉接口参数设置增加参数“钉钉群消息推送设置”
global $adb,$current_user;
//$_SESSION[globalStatic::$root_directory.'prevmenu_modulefile'.$current_user->id]='SettingLeftRight';
//$_SESSION[globalStatic::$root_directory.'prevmenu_modilefile_childmenu'.$current_user->id]='dingtalk_webhook_setting';
//$_SESSION[globalStatic::$root_directory.'prevmenu_module'.$current_user->id]='Settings';
require(globalStatic::$root_directory.'user_privileges/user_language_'.$current_user->id.'.php');

$smarty = new lingdangCRM_Smarty;
//$module = $_REQUEST['frommodule'];
//$tabid = getTabid($module);

//已经添加的模块就不显示了
$query="SELECT * FROM ld_tab WHERE presence IN (0,2) AND (name = 'SalesOrder' OR REPLACE(name,'CustomForm','') BETWEEN 11 AND 45)
                       AND tabid NOT IN(SELECT tabid FROM ld_dingtalk_msg_conf) ORDER BY tabid;";//and ld_field.presence in (0,2)
$result=$adb->query($query);
$num_rows=$adb->num_rows($result);
$tab=array();
//$printtabs=array();
if($num_rows){
    for($i=0;$i<$num_rows;$i++){
        $tmp_tabid=$adb->query_result($result,$i,'tabid');
        $tmp_module=$adb->query_result($result,$i,'name');
//        $printtabs[$tmp_tabid]=getTranstab($tmp_module);


        $tab[]=array('tabid'=>$tmp_tabid,
            'tabname'=>getTranstab($tmp_module)
        );
    }
}
$smarty->assign('TAB',$tab);//选择模块


if(!empty($_REQUEST['ajax']) && $_REQUEST['ajax'] == true){
    if(!empty($_REQUEST['type'])){
        //把数据准备好
        $record = $_REQUEST['record'];
        $tabid = $_REQUEST['tabid'];

        $modulename = getTabname($tabid);
        $keywords = $_REQUEST['keywords'];
        $webhook = $_REQUEST['webhook'];
        $content = $_REQUEST['CKcontent'];
        $is_enable = $_REQUEST['is_enable'];

        if($_REQUEST['type'] == 'create' || $_REQUEST['type'] == 'copy'){ //新建或复制
            $sql = 'insert into ld_dingtalk_msg_conf(tabid,modulename,keywords,webhook,content,is_enable,createdby) values(?,?,?,?,?,?,?)';
            $adb->pquery($sql, array($tabid, $modulename, $keywords, $webhook, $content, $is_enable, $current_user->id));
        }else if($_REQUEST['type'] == 'edit'){	//编辑
            $sql = 'update ld_dingtalk_msg_conf set keywords=?,webhook=?,content=?,is_enable=?,modifiedby=?,tabid=?,modulename=? where id=?';
            $result = $adb->pquery($sql,array($keywords,$webhook,$content,$is_enable,$current_user->id,$tabid,$modulename,$record));

        }else if($_REQUEST['type'] == 'inactivate'){	//停用
            $adb->pquery("update ld_dingtalk_msg_conf set is_enable = 'no' where id=?",array($record));
        }else if($_REQUEST['type'] == 'activate'){	//启用
            $adb->pquery("update ld_dingtalk_msg_conf set is_enable = 'yes' where id=?",array($record));
        }else if($_REQUEST['type'] == 'delete'){	//删除
            $adb->pquery('delete from ld_dingtalk_msg_conf where id=?',array($record));
        }
    }
    $_REQUEST['diony']='yes';
    ConvertTojsonString(1,array(),"success");//因为会刷新列表，所以不用返回tpl
}

$query = 'select id,tabid,modulename,keywords,webhook,content,is_enable,createdtime,modifiedtime from ld_dingtalk_msg_conf order by tabid';
$result = $adb->pquery($query,array());
$num_rows = $adb->num_rows($result);
if($num_rows > 0){
    for($i=0;$i<$num_rows;$i++){
        $dingtalk[]=array('id'=>$adb->query_result($result,$i,'id'),
            'tabid'=>$adb->query_result($result,$i,'tabid'),
            'modulename'=>getTranstab($adb->query_result($result,$i,'modulename')),
            'keywords'=>$adb->query_result($result,$i,'keywords'),
            'webhook'=>$adb->query_result($result,$i,'webhook'),
            'content'=>$adb->query_result($result,$i,'content'),
            'is_enable'=>$adb->query_result($result,$i,'is_enable'),
            'createdby'=>$adb->query_result($result,$i,'createdby'),
            'modifiedby'=>$adb->query_result($result,$i,'modifiedby'),
            'createdtime'=>$adb->query_result($result,$i,'createdtime'),
            'modifiedtime'=>$adb->query_result($result,$i,'modifiedtime'),
        );
    }
}
$smarty->assign('DINGTALK', $dingtalk);
$smarty->assign('LANGUAGETYPE', $languageType);



/*$webhookList = array(
    "https://oapi.dingtalk.com/robot/send?access_token=13c4b8f83b4e41bf9ef628005254b38aa81917940ddd4425e57a5df2b03e0cf7",
);*/

/*$webhook = '';
$is_enable = 0;
$path = globalStatic::$root_directory."globalConfig/DingTalkWebhook.php";

if(file_exists($path)){
    $webhookList = unserialize(@file_get_contents($path));
} else {
    @fopen($path, 'w+');
    chmod($path, 0777);
}
if (isset($webhookList[0]) && !empty($webhookList[0])) {
    $webhook = $webhookList[0];
}
if (isset($webhookList[1]) && !empty($webhookList[1])) {
    $is_enable = $webhookList[1];
}

$smarty->assign('webhook',$webhook);
$smarty->assign('is_enable',$is_enable);*/
//获取帮助手册入口链接，为空则不显示
//可能有多个帮助链接需要获取
$helpHtmlArr = array();
$labels = array('DingtalkWebhookSetting');
foreach($labels as $label){
    $helpHtmlArr[$label] = getHelpHtmlByLabel('Settings',1,'HelpUrl_'.$label);
}
$smarty->assign("HelpHtml", $helpHtmlArr);
$_REQUEST['diony']='yes';
$arr['content']= $smarty->fetch('Settings/dingtalk_webhook_setting.tpl');
ConvertTojsonString(1,$arr,"success");

?>