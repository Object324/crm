<?php
class cls_WechatSession
{
    public function __construct($record,$module)
    {
        global $adb;
        $this->record = $record;
        $this->module = $module;
        $fieldobj = Field::getInstance($module,$adb);
        $this->modules = $fieldobj->getModuleFields();
        $this->focus = CRMEntity::getInstance($module);
        $this->tabid = getTabid($module);
    }

    public function getSessionList(){
        crm_load_class_file('WechatSession','modules/WechatSession');
        $focus = new WechatSession();
//        $focus->updateRoomName(); //更新群名  由于数据量大导致卡顿，进入模块时默认不再更新群名

        $search = $_REQUEST['searchcontent'] !== '' ? $_REQUEST['searchcontent'] : '';

        $member_wx_userid =  $this->get_weixin_external_userid();//等于是PC端根据客户搜索 左边客户列表的  微信id
//        $member_wx_userid = 'ZhangLuJun';
        if (empty($member_wx_userid))
            return '';
        $sessionListsSinglechat = $focus->getSessionListsByCustomer($member_wx_userid, $search, 'external');
//        dump($sessionListsSinglechat);
        $sessionListsGroupchat = $focus->getSessionListsByCustomer($member_wx_userid, $search, 'groupchat');
//        dump($sessionListsGroupchat);
        foreach ($sessionListsGroupchat['group_chat_list'] as $key => $row) {
            $sessionListsGroupchat['group_chat_list'][$key]['wx_userid'] = $sessionListsGroupchat['group_chat_list'][$key]['roomid'];
            $sessionListsGroupchat['group_chat_list'][$key]['last_name'] = $sessionListsGroupchat['group_chat_list'][$key]['roomname'];
            $sessionListsGroupchat['group_chat_list'][$key]['content'] = '';
        }

        $sessionLists = array_merge_recursive($sessionListsSinglechat['contacts_list'], $sessionListsGroupchat['group_chat_list']);
        unset($sessionLists['search']);
        unset($sessionLists['session_type']);

        // 取得列的列表  按照original_msgtime倒序排序
        $original_msgtime = _array_column($sessionLists,'original_msgtime');
        array_multisort($original_msgtime,SORT_DESC,$sessionLists);

        return $sessionLists;
    }
    private function get_weixin_external_userid(){
        global $adb;
        $weixin_external_userid = '';
        if ($this->module == 'Accounts') {
            $sql = "SELECT
	b.lastname,
	b.weixin_external_userid 
FROM
	ld_account a
	LEFT JOIN ld_contactdetails b ON b.accountid = a.accountid
WHERE
	a.accountid = {$this->record} 
	AND IFNULL( b.weixin_external_userid, '' ) <> ''";
            $result = $adb->pquery($sql, array());
            $weixin_external_userid = $adb->query_result($result,0,'weixin_external_userid');
        } elseif ($this->module == 'Contacts') {
            $sql = "SELECT
	b.lastname,
	b.weixin_external_userid 
FROM
	 ld_contactdetails b 
WHERE
	b.contactid = {$this->record}
	AND IFNULL( b.weixin_external_userid, '' ) <> ''";
            $result = $adb->pquery($sql, array());
            $weixin_external_userid = $adb->query_result($result,0,'weixin_external_userid');
        }

        if (!empty($weixin_external_userid))  return $weixin_external_userid;
        return '';
    }

    public function getChatdataList(){
        crm_load_class_file('WechatSession','modules/WechatSession');
        $focus = new WechatSession();

        $member_wx_userid = $_REQUEST['member_wx_userid'] ?: '';//fromid  成員列表的wx_userid
        $session_wx_userid = $_REQUEST['session_wx_userid'] ?: '';//tolist  会话列表的wx_userid（内部外部）或者roomid（群聊）
        $session_roomid = $_REQUEST['session_roomid'] ?: '';//tolist  roomid（群聊）
        $session_type = $_REQUEST['session_type'] ?: 'external';// 会话类型
        $msgtype = $_REQUEST['msgtype'] ?: 'all';// 文件类型
        $search = $_REQUEST['searchcontent'] !== '' ? $_REQUEST['searchcontent'] : '';
        $begin_date = $_REQUEST['begin_date'] ?: '';
        $end_date = $_REQUEST['end_date'] ?: '';
        $seq = $_REQUEST['seq'] ?: ''; //搜索后  查看上下文

        $data = $focus->getChatdataListsByCustomer($member_wx_userid, $session_wx_userid, $session_roomid, $session_type, $msgtype, $search, $begin_date, $end_date, $seq);
//        $data = $focus->getChatdataListsByCustomer('ZhangLuJun', 'PanLuLu', '', 'external', 'all', '', '', '', '');

        $title = '';
        if ($session_type == 'groupchat') {
            $title = $focus->get_chatdata_roomname($session_roomid);
        }else{
            $member_name = $focus->get_lastname_by_wx_userid($member_wx_userid);
            $session_name = $focus->get_lastname_by_wx_userid($session_wx_userid);
            $title = $member_name.' & '.$session_name;
        }
        $data['title'] = $title;

        return $data;
    }


    private function setDatetimeForSeconds($createdtime){
        $secord = date("H:i:s",strtotime($createdtime));
        $parsed = date_parse($secord);
        $seconds = $parsed['hour'] * 3600 + $parsed['minute'] * 60 + $parsed['second'];
        return $seconds;
    }
    private function setDatetimeArray($date){
        $this->datetime_array[strtotime($date)] = array(
            'datetime' => $date,
            'times' =>strtotime($date),
        );
    }

}



?>