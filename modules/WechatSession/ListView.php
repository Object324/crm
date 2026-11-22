<?php
//@edit:liushuai,2020-10-22,reason:ID1000713/企业微信会话存档(获取相关会话数据)
//header("Content-type: audio/amr");
//header("Access-Control-Allow-Origin:*");
//header("Access-Control-Allow-Methods:GET, POST, OPTIONS, DELETE");
//header("Access-Control-Allow-Headers:DNT,X-Mx-ReqToken,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type, Accept-Language, Origin, Accept-Encoding");
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $default_charset,$currentModule, $adb, $theme;

$_REQUEST['diony'] = 'yes';
$regop=RegOp::getInstance();
$wechatprofile=0;
 if(method_exists($regop,'getwechatprofile'))
 {
            $wechatprofile=$regop->getwechatprofile();
 }  
if(empty($wechatprofile))
{
    ConvertTojsonString("-1",array(),"没有授权会话存档，请联系供应商!");
}
$smarty = new lingdangCRM_Smarty;
setGLobalURLSmarty($smarty);//设置js,css等访问路径
require_once(globalStatic::$root_directory.'/modules/WechatSession/WechatSession.php');
$focus = new WechatSession();

if (isset($focus->wxconfig['version']) && $focus->wxconfig['version'] == 'v2') {
    require_once(globalStatic::$root_directory.'/modules/WechatSession/WechatSessionNew.php');
    $focus = new WechatSessionNew();
    $focus->setWxSmarty($smarty);//通讯录组件 open-data
}

//更新ld_wechatsession表的内部群聊名称  roomname字段
//$focus->updateRoomName();

/*$result = $adb->pquery("SELECT DISTINCT roomid FROM ld_wechatsession WHERE session_type = 'internal' AND roomid <> '';", array());
//$result = $adb->pquery("SELECT DISTINCT roomid FROM ld_wechatsession WHERE roomid <> '';", array());
$num_rows = $adb->num_rows($result);
if ($num_rows >= 1) {
    for ($i = 0; $i < $num_rows; $i++) {
        $roomid = $adb->query_result($result, $i, 'roomid');
        $groupchatInfo = $focus->getGroupchatInfo($roomid);
        if (!empty($groupchatInfo) && !empty($groupchatInfo["roomname"])) { //内部群且群名不为空时更新
            $adb->pquery("UPDATE ld_wechatsession SET roomname = ? WHERE roomid = ?", array($groupchatInfo["roomname"],$roomid));
        }
    }
}*/



$searchbytype = $_REQUEST['searchbytype'];

//根据成员搜索（默认）、根据客户搜索
if ($searchbytype == 'searchbymember') { //表示是点击tpl按钮 根据成员搜索  or  根据客户搜索
    //根据成员搜索
    if ($_REQUEST['ajax'] == 'true') {
        $block = $_REQUEST['block']?:'memberlist'; //分为左中右三块
        switch ($block) {
            case 'memberlist'://左边成员列表
                $search = $_REQUEST['search'] ?: "";
                $memberLists = $focus->getMemberLists($search);//treehtml 组织架构图
                $smarty->assign('memberLists', $memberLists);
                $smarty->assign('searchbytype', $searchbytype);
                $content = $smarty->fetch('modules/WechatSession/MemberList.tpl');
                ConvertTojsonString(1, array('content' => $content, 'memberLists' => $memberLists), 'success');
                break;
            case 'sessionlist':  //中间会话列表的成员
                $member_wx_userid = $_REQUEST['member_wx_userid'] ?: '';//fromid  成員列表的wx_userid
                $search = $_REQUEST['search'] ?: '';
                $session_type = $_REQUEST['session_type'] ?: 'internal';// 会话类型
                $sessionLists = $focus->getSessionLists($member_wx_userid, $search, $session_type);
                $smarty->assign('sessionLists', $sessionLists);
                $content = $smarty->fetch('modules/WechatSession/SessionList.tpl');
                ConvertTojsonString(1, array('content' => $content, 'sessionLists'=>$sessionLists,'page_num' => $sessionLists['page_num'], 'page' => $sessionLists['page']), 'success');
                break;
            case 'chatdatalist'://右边聊天记录内容
                $member_wx_userid = $_REQUEST['member_wx_userid'] ?: '';//fromid  成員列表的wx_userid
                $session_wx_userid = $_REQUEST['session_wx_userid'] ?: '';//tolist  会话列表的wx_userid（内部外部）或者roomid（群聊）
                $session_roomid = $_REQUEST['session_roomid'] ?: '';//tolist  roomid（群聊）
                $session_type = $_REQUEST['session_type'] ?: 'internal';// 会话类型
                $msgtype = $_REQUEST['msgtype'] ?: 'all';// 文件类型
                $search = $_REQUEST['search'] !== '' ? $_REQUEST['search'] : '';
                $begin_date = $_REQUEST['begin_date'] ?: '';
                $end_date = $_REQUEST['end_date'] ?: '';
                $seq = $_REQUEST['seq'] ?: ''; //搜索后  查看上下文

                $data = $focus->getChatdataLists($member_wx_userid, $session_wx_userid, $session_roomid, $session_type, $msgtype, $search, $begin_date, $end_date, $seq);
//                dump($chatdataLists);

                $title = '';
                if ($session_type == 'groupchat') {
                    $title = $focus->get_chatdata_roomname($session_roomid);
                }else{
                    $member_name = $focus->get_lastname_by_wx_userid($member_wx_userid);
                    $session_name = $focus->get_lastname_by_wx_userid($session_wx_userid);
                    if (!empty($session_name)) {
                        $title = $member_name.' & '.$session_name. getFixedLabel('Conversation');
                    }
                }
                $smarty->assign('chatdataLists', $data['chatdataLists']); //聊天数据
                $smarty->assign('page_num', $data['page_num']); //总页数
                $smarty->assign('page', $data['page']);  //当前显示页数
                $smarty->assign('count', count($data['chatdataLists']));
                if (isset($_REQUEST['count']) && !empty($search)) {  //统计搜索框结果的相关数量
                    $content = $smarty->fetch('modules/WechatSession/ChatDataCount.tpl');
                }else{
                    $content = $smarty->fetch('modules/WechatSession/ChatData.tpl');
                }

                ConvertTojsonString(1, array('content' => $content,'title' => $title,'page_num' => $data['page_num'], 'page' => $data['page']), 'success');
                break;
            default;
                echo 'Please make a new selection...';
                break;
        }
        exit();
    } //左中右更新
    else{
        $memberLists = $focus->getMemberLists('');  //开启会话存档的成员组织架构图
        $smarty->assign('memberLists', $memberLists);
        $smarty->assign('searchbytype', $searchbytype);
        $content = $smarty->fetch('modules/WechatSession/WeChatSession.tpl');
        ConvertTojsonString(1,array('content'=>$content),'success');
    }
}elseif ($_REQUEST['searchbytype'] == 'searchbycustomer'){
    //根据客户搜索
    if ($_REQUEST['ajax'] == 'true') {
        $block = $_REQUEST['block']?:'memberlist'; //分为左中右三块
        switch ($block) {
            case 'memberlist'://左边成员列表
                $search = $_REQUEST['search'] ?: "";
                $memberLists = $focus->getMemberListsByCustomer($search);//treehtml 组织架构图
                $smarty->assign('memberLists', $memberLists);
                $smarty->assign('searchbytype', $searchbytype);
                $content = $smarty->fetch('modules/WechatSession/CustomerMemberList.tpl');
                ConvertTojsonString(1, array('content' => $content, 'memberLists' => $memberLists), 'success');
                break;
            case 'sessionlist':  //中间会话列表的成员
                $member_wx_userid = $_REQUEST['member_wx_userid'] ?: '';//成員列表的wx_userid
                $search = $_REQUEST['search'] ?: '';
                $session_type = $_REQUEST['session_type'] ?: 'external';// 会话类型 external ot groupchat
                $sessionLists = $focus->getSessionListsByCustomer($member_wx_userid, $search, $session_type);
                $smarty->assign('sessionLists', $sessionLists);
                $content = $smarty->fetch('modules/WechatSession/CustomerSessionList.tpl');
                ConvertTojsonString(1, array('content' => $content, 'sessionLists' => $sessionLists), 'success');
                break;
            case 'chatdatalist'://右边聊天记录内容
                $member_wx_userid = $_REQUEST['member_wx_userid'] ?: '';//fromid  成員列表的wx_userid
                $session_wx_userid = $_REQUEST['session_wx_userid'] ?: '';//tolist  会话列表的wx_userid（内部外部）或者roomid（群聊）
                $session_roomid = $_REQUEST['session_roomid'] ?: '';//tolist  roomid（群聊）
                $session_type = $_REQUEST['session_type'] ?: 'external';// 会话类型
                $msgtype = $_REQUEST['msgtype'] ?: 'all';// 文件类型
                $search = $_REQUEST['search'] !== '' ? $_REQUEST['search'] : '';
                $begin_date = $_REQUEST['begin_date'] ?: '';
                $end_date = $_REQUEST['end_date'] ?: '';
                $seq = $_REQUEST['seq'] ?: ''; //搜索后  查看上下文

                $data = $focus->getChatdataListsByCustomer($member_wx_userid, $session_wx_userid, $session_roomid, $session_type, $msgtype, $search, $begin_date, $end_date, $seq);
//                $chatdataLastname = $focus->getChatdataLastname($member_wx_userid, $session_wx_userid, $session_type);//获取成员列表和会话列表的名称
//dump($chatdataLists);
                $title = '';
                if ($session_type == 'groupchat') {
                    $title = $focus->get_chatdata_roomname($session_roomid);
                }else{
                    $member_name = $focus->get_lastname_by_wx_userid($member_wx_userid);
                    $session_name = $focus->get_lastname_by_wx_userid($session_wx_userid);
                    if (!empty($session_name)) {
                        $title = $member_name.' & '.$session_name. getFixedLabel('Conversation');
                    }
                }

                $smarty->assign('chatdataLists', $data['chatdataLists']); //聊天数据
                $smarty->assign('page_num', $data['page_num']); //总页数
                $smarty->assign('page', $data['page']);  //当前显示页数
                $smarty->assign('count', count($data['chatdataLists']));
//                $smarty->assign('chatdataLastname', $chatdataLastname);
                if (isset($_REQUEST['count']) && !empty($search)) {  //统计搜索框结果的相关数量
                    $content = $smarty->fetch('modules/WechatSession/CustomerChatDataCount.tpl');
                }else{
                    $content = $smarty->fetch('modules/WechatSession/CustomerChatData.tpl');
                }
                ConvertTojsonString(1, array('content' => $content, 'title' => $title,'page_num' => $data['page_num'], 'page' => $data['page']), 'success');
                break;
            default;
                echo 'Please make a new selection...';
                break;
        }
        exit();
    }
    else{
        $memberLists = $focus->getMemberListsByCustomer('');  //开启会话存档的成员组织架构图
//        dump($memberLists);
        $smarty->assign('memberLists', $memberLists);
        $smarty->assign('searchbytype', $searchbytype);
        $content = $smarty->fetch('modules/WechatSession/WeChatSession.tpl');
        ConvertTojsonString(1,array('content'=>$content),'success');
    }
}
else
    //成员列表
    $memberLists = $focus->getMemberLists('');  //开启会话存档的成员组织架构图

$smarty->assign('memberLists', $memberLists);
$smarty->assign('searchbytype', 'searchbymember');//默认
//$smarty->assign('page', 1);//当前显示页数
//$smarty->assign('page_num', 1); //总页数

$smarty->display('modules/WechatSession/WeChatSession.tpl');
exit;
