<?php

class WechatSession extends CRMEntity {

    static  function require_file($requiremodules='')
    {
        globalStatic::$arr_module_require['WechatSession']='WechatSession';

        if(!empty($requiremodules)&&empty(globalStatic::$arr_module_require[$requiremodules]))
        {
            globalStatic::$arr_module_require[$requiremodules]=$requiremodules;
            include(globalStatic::$root_directory."modules/$requiremodules/$requiremodules.php");

        }

    }

    var $log;
    var $db;
    var $module_name='WechatSession';
    var $table_name = "ld_wechatsession";
    var $table_index= 'id';
    //'ld_contactaddress','ld_contactsubdetails','ld_customerdetails'
    //'ld_contactaddress'=>'contactaddressid','ld_contactsubdetails'=>'contactsubscriptionid',
    //'ld_customerdetails'=>'customerid'
    var $tab_name = Array('ld_crmentity','ld_wechatsession');
    var $tab_name_index = Array('ld_crmentity'=>'crmid','ld_wechatsession'=>'id',);
    /**
     * Mandatory table for supporting custom fields.
     */

    public $wxconfig;
    function __construct() {

        $this->db = PearDatabase::getInstance();
        $this->fieldobj=Field::getInstance('WechatSession',$this->db);
        $this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
        $entityname=getEntitynameByModulename('WechatSession');
        $this->list_link_field=$entityname['fieldname'];

        $this->wxconfig = $this->getWxConfigForSession();
    }

    //更新 内部群聊 群名
    public function updateRoomName($roomid = '')
    {
        global $adb;
        if (empty($roomid)) {
            $result = $adb->pquery("SELECT DISTINCT roomid FROM ld_wechatsession WHERE session_type = 'internal' AND ifnull(roomid,'') <> '';", array());
            //$result = $adb->pquery("SELECT DISTINCT roomid FROM ld_wechatsession WHERE roomid <> '';", array());
            $num_rows = $adb->num_rows($result);
            if ($num_rows >= 1) {
                for ($i = 0; $i < $num_rows; $i++) {
                    $roomid = $adb->query_result($result, $i, 'roomid');
                    $groupchatInfo = $this->getGroupchatInfo($roomid);
                    if (!empty($groupchatInfo) && !empty($groupchatInfo["roomname"])) { //内部群且群名不为空时更新
                        $adb->pquery("UPDATE ld_wechatsession SET roomname = ? WHERE roomid = ?", array($groupchatInfo["roomname"],$roomid));
                    }
                }
            }
        } else {
//            $result = $adb->pquery("SELECT roomid FROM ld_wechatsession WHERE roomid = ? LIMIT 1", array($roomid));
//            $num_rows = $adb->num_rows($result);
//            if ($num_rows >= 1) {
                $groupchatInfo = $this->getGroupchatInfo($roomid);
                if (!empty($groupchatInfo) && !empty($groupchatInfo["roomname"])) { //内部群且群名不为空时更新
                    $adb->pquery("UPDATE ld_wechatsession SET roomname = ? WHERE roomid = ?", array($groupchatInfo["roomname"],$roomid));
                }
//            }
        }

    }

    //更新 外部群聊 群名  即客户群详情接口
    public function updateExternalRoomName($roomid = '', $secret='')
    {
        global $adb;
        if (empty($roomid)) {
            $result = $adb->pquery("SELECT DISTINCT roomid FROM ld_wechatsession WHERE session_type = 'external' AND ifnull(roomid,'') <> '';", array());
            $num_rows = $adb->num_rows($result);
            if ($num_rows > 0) {
                for ($i = 0; $i < $num_rows; $i++) {
                    $roomid = $adb->query_result($result, $i, 'roomid');
                    $groupchatInfo = $this->getExternalGroupchatInfo($roomid, $secret);
                    if (!empty($groupchatInfo) && !empty($groupchatInfo['group_chat']['name'])) { //外部群且群名不为空时更新
                        $adb->pquery("UPDATE ld_wechatsession SET roomname = ? WHERE roomid = ?", array($groupchatInfo["group_chat"]['name'],$roomid));
                    }
                }
            }
        } else {
//            $result = $adb->pquery("SELECT roomid FROM ld_wechatsession WHERE roomid = ? LIMIT 1", array($roomid));
//            $num_rows = $adb->num_rows($result);
//            if ($num_rows > 0) {
                $groupchatInfo = $this->getExternalGroupchatInfo($roomid, $secret);
                if (!empty($groupchatInfo) && !empty($groupchatInfo["group_chat"]['name'])) { //外部群且群名不为空时更新
                    $adb->pquery("UPDATE ld_wechatsession SET roomname = ? WHERE roomid = ?", array($groupchatInfo["group_chat"]['name'],$roomid));
                }
//            }
        }

    }

    //获取系统中所有已绑定企业微信得用户
    public function getUserName($userid)
    {
        global $adb;
        if(!empty($userid)){
//            $query = "select GROUP_CONCAT(last_name) as name from ld_users where id in ($userid) and wx_userid <> '' and `status` = 'Active'";
            $query = "select GROUP_CONCAT(last_name) as name from ld_users where id in ($userid) and wx_userid <> ''";
            $result = $adb->pquery($query,array());
            return $adb->query_result($result,0,0);
        }
        return '';
    }

    //获取会话内容存档内部群信息(只支持内部群)(通过此接口，获取会话内容存档本企业的内部群信息，包括群名称、群主id、公告、群创建时间以及所有群成员的id与加入时间)
    public function getGroupchatInfo($roomid){
        $wxconfig = $this->getWxConfigForSession();
        $corpid = $wxconfig['corpid'];
        $secret = $wxconfig['secret'];
        if (!empty($corpid) && !empty($secret)) {
            include_once(globalStatic::$root_directory."vendor/weworkapi_php/api/src/CorpAPI.class.php");
            // 实例化 API 类   之后直接调用相关方法，不必先获取access_token,接口会自动处理
            $api = new CorpAPI($corpid, $secret);
            $data = $api->get_groupchat($roomid);
            return $data;
        } else {
            return '';
        }
    }

    //获取外部联系人客户详情
    public function getExternalContactInfo($external_userid, $secret){
        $wxconfig = $this->getWxConfigForSession();
        $corpid = $wxconfig['corpid'];
        if (!empty($corpid) && !empty($secret)) {
            include_once(globalStatic::$root_directory."vendor/weworkapi_php/api/src/CorpAPI.class.php");
            $api = new CorpAPI($corpid, $secret);
            $data = $api->get_external_contact($external_userid);
            return $data;
        } else {
            return '';
        }
    }

    /*//获取外部联系人客户详情 通过接口
    public function get_external_contact_info($external_userid){
        global $adb,$PlatformMC;
        //TXT缓存读取企业号ID
        $authinfo_json = doCorpInfo('get_auth_info',array());
        $authinfo_arr = json_decode($authinfo_json,true);
        $corpid = $authinfo_arr['crm']['auth_corp_info']['corpid'];
        //CURL调用接口
        require_once(globalStatic::$root_directory . 'WeiXinApp/WeiXin_common/cls_WeixinPort.php');
        $o_port = new cls_WeixinPort();
        $url = StaticConst::$server_api_header . 'server.php?action=get_external_contact&userids='.$external_userid.'&corpid='.$corpid;
        $result_arr = json_decode($o_port->primary_curl($url),true);
        $contact_list = $result_arr['result']['contact'];
        $contactmodule = 'Contacts';
    }*/

    //获取客户群详情(通过客户群ID，获取详情。包括群名、群成员列表、群成员入群时间、入群方式。（客户群是由具有客户群使用权限的成员创建的外部群）)
    public function getExternalGroupchatInfo($chat_id, $secret){  //$chat_id  就是 外部群聊的 roomid
        $wxconfig = $this->getWxConfigForSession();
        $corpid = $wxconfig['corpid'];
//        $secret = $wxconfig['secret'];
        if (!empty($corpid) && !empty($secret)) {
            include_once(globalStatic::$root_directory."vendor/weworkapi_php/api/src/CorpAPI.class.php");
            $api = new CorpAPI($corpid, $secret);
            $data = $api->get_external_groupchat($chat_id);
            return $data;
        } else {
            return '';
        }
    }

    //获取会话内容存档开启成员列表
    public function getPermitUserList(){
        
        global $adb;
        $sql=' select wx_userid from ld_users  where wx_userid is not null and wx_userid<>""  ';
        $result=$adb->pquery($sql,array());
        $user_list_arr=[];
        for($i=0;$i<$adb->num_rows($result);$i++)
        {
            $user_list_arr[]=$adb->query_result($result,$i,'wx_userid');
            
        }
        return $user_list_arr ;
        $wxconfig = $this->getWxConfigForSession();
        $corpid = $wxconfig['corpid'];
        $secret = $wxconfig['secret'];
        
        
        if (!empty($corpid) && !empty($secret)) {
            include_once(globalStatic::$root_directory."vendor/weworkapi_php/api/src/CorpAPI.class.php");
            // 实例化 API 类   之后直接调用相关方法，不必先获取access_token,接口会自动处理
            $api = new CorpAPI($corpid, $secret);
            $user_list_arr = $api->get_permit_user_list();
//            $user_list_arr = $api->get_externalcontact_list('15821678924');
//            $user_list_arr = $api->UserGet('15821678924');//获取用户相关信息（userid，name,mobile,email等）
              //  dump($user_list_arr);
            return $user_list_arr;
        } else {
            return '';
        }
    }

    //获取企业微信会话存档设置
    public function getWxConfigForSession(){
        global $adb;
        $data = array();
        $query = "select para_one,para_two,para_three from ld_wx_config where name = 'wechatsession_setting' limit 1";
        $result = $adb->pquery($query,array());
        $num_rows = $adb->num_rows($result);
        if($num_rows >= 1){
            $data['corpindex'] = $adb->query_result($result,0,'para_one');
            $data['corpid'] = $adb->query_result($result,0,'para_two');
            $data['secret'] = $adb->query_result($result,0,'para_three');
        }

        $result = $adb->pquery("select * from ld_wechat_config where id=1",array());
        $num_rows = $adb->num_rows($result);
        if($num_rows >= 1){
            $data['version'] = $adb->query_result($result,0,'version');
            $data['syncstatus'] = $adb->query_result($result,0,'syncstatus');
            $permit_user_list = $adb->query_result($result,0,'permit_user_list');
            $data['permit_user_list'] = !empty($permit_user_list)?Zend_Json::decode($permit_user_list):'';
            $invalid_userid_list = $adb->query_result($result,0,'invalid_userid_list');
            $data['invalid_userid_list'] = !empty($invalid_userid_list)?Zend_Json::decode($invalid_userid_list):'';
            $departmentlist = $adb->query_result($result,0,'departmentlist');
            $data['departmentlist'] = !empty($departmentlist)?Zend_Json::decode($departmentlist):'';
            $userlist = $adb->query_result($result,0,'userlist');
            $data['userlist'] = !empty($userlist)?Zend_Json::decode($userlist):'';
            $userinfo = $adb->query_result($result,0,'userinfo');
            $data['userinfo'] = !empty($userinfo)?Zend_Json::decode($userinfo):'';

        }

        return $data;
    }

    /*
    * 根据成员搜索
    * */
    //左边成员列表
    public function getMemberLists($search = '')
    {
        global $current_user, $adb;
        $wx_userid_arr = $this->getPermitUserList();  //开启会话存档的成员列表
     
        // $wx_userid_arr = ["LiuShuai","15821678924"];
        include globalStatic::$root_directory.'modules/Users/Group.class.php';
        $group_focus = new Group();
        if (!empty($wx_userid_arr)) {
            $wx_userid_str = implode("','",$wx_userid_arr);
            $isbox = 'hidden'; // input的type类型
            $groupuser = $group_focus->getGroupListUserForWechatSession($wx_userid_str,$search);
        }
        else{
            return '';  //没有获取到开启会话存档的成员直接返回空
            // $groupuser = '';
        }

        $groupuserarray = $group_focus->setOneParent($groupuser);
        $groups = $group_focus->getGrouplist();
        $selecttype = $_REQUEST['selecttype'] = "group";
        //$_REQUEST['popup_type']='listselecthigher';
        //$_REQUEST['selectprofileuser'] = 'yes';

        //多维数组组装成ul->li格式
        if(isset($groups)){
            $array[$group_focus->group_parent_key] = $groupuserarray[$group_focus->group_parent_key];
            if($selecttype=='group')
            {
                $treehtml = $group_focus->setTreeListForWechatSession($array,$isbox,'','parentgroup');
            }
            else
            {
                $view = 'all';
                if($_REQUEST['popup_type']=='listselecthigher')
                {
                    $view='';
                }
                if(is_admin($current_user)){
                    $view = 'all';
                }
                if(!empty($view)){
                    $treehtml = $group_focus->setTreeListForWechatSession($array,$isbox,'','parentgroup');
                }else{
                    $keys=array_keys($array);
                    global $retgroupusers;
                    //30515: 查看范围：高级弹出层，仅显示有权限看到人员的部门，若没权限看到的用户，则不显示部门组织架构
                    getgrouphaveUsers($array[$keys[0]],$keys[0]);

                    $tmpusers[$keys[0]]['type']=$array[$keys[0]]['type'];
                    $tmpusers[$keys[0]]['name'] =$array[$keys[0]]['name'];
                    $tmpusers[$keys[0]]['parentid'] =$array[$keys[0]]['parentid'];
                    $tmpusers[$keys[0]]['parentgroup'] =$array[$keys[0]]['parentgroup'];
                    $tmpusers[$keys[0]]['children']=$retgroupusers;
                    $treehtml = $group_focus->setTreeListForWechatSession($tmpusers,$isbox,'','parentgroup');
                }
            }

            //角色权限显示
            /*if(isset($_REQUEST['selectprofileuser']) && $_REQUEST['selectprofileuser'] == 'yes'){
                $profileArray = getAllProfile();
                $treehtml .= $group_focus->setTreeListForWechatSession($profileArray,$isbox,'','selectprofileuser');
            }*/
            // $smarty->assign('treehtml', $treehtml);

            return $treehtml;

            //    $smarty->fetch('modules/WechatSession/MemberList.tpl');
            //    ConvertTojsonString(1,array('content'=>$content),'success');
            //    dump($treehtml);

        }
        else{
            // echo getFixedLabel('LBL_NOTGROUPINFO');die;
            return '';
        }
    }

    //中间会话列表   $session_type：会话类型 内部 外部  群聊
    public function getSessionLists($member_wx_userid, $search, $session_type)
    {
        global $adb,$current_user;
        if (empty($member_wx_userid)) {
            return '';
        }

        $where = '';
        $outerwhere = '';
        $limit = '';
        $groupby = '';
        $on = '';  //连接条件
        // $where .= " (ws.fromid = '".$member_wx_userid."' OR ws.tolist = '". $member_wx_userid . "')";
        $where .= " (ws.fromid = '".$member_wx_userid."' OR FIND_IN_SET('".$member_wx_userid."',ws.tolist))";
        // $where .= " (ws.fromid = '".$member_wx_userid."' OR ws.tolist = '". $member_wx_userid . "') AND ld_users.wx_userid <> '".$member_wx_userid."'";

        if (in_array($session_type,["internal","external","groupchat"])) {
            switch ($session_type){
                case "internal":
                case "external":
                    $where .= " AND ws.session_type = '".$session_type."' AND (ws.roomid = '' OR ws.roomid IS NULL)";
                    $groupby .= " GROUP BY tolist";
                    $on = " ON maxmsgtimetable.tolist = ws.tolist ";
                    break;
                case "groupchat":
                    $where .= " AND ws.roomid <> ''";
                    // $where .= " AND ws.roomid <> '' AND IFNULL(ws.roomname,'') <> ''";  //群名称为空怎么显示？
                    $groupby .= " GROUP BY roomid";
                    $on = " ON maxmsgtimetable.roomid = ws.roomid ";
                    break;
            }
        }
        /*else{
            $limit = " LIMIT 5";
        }*/

        //没有搜索，按照 内部、外部、群聊显示
        if (!empty($search)) {
            if ($session_type == 'internal') {
                $outerwhere = " WHERE ld_users.last_name like '%".$search."%'";
            }
            elseif ($session_type == 'external') {
                // $outerwhere = " WHERE c.lastname like '%".$search."%'";
                $outerwhere = " WHERE c.external_name like '%".$search."%'";
            }
            elseif ($session_type == 'groupchat') {
                $outerwhere = " WHERE ws.roomname like '%".$search."%'";
            }
        }
        
        //获取成员列表成员的会话人员
        $page_query = "SELECT
            			max( msgtime ) AS maxmsgtime,
            			tolist,
            			roomid 
            		FROM
            			ld_wechatsession AS ws 
            		WHERE
            		    ".$where.$groupby ." order by maxmsgtime desc ";

        $page_size = 15;  //每页显示条数
        //计算总页数
        $page_num =  ceil($adb->num_rows($adb->pquery($page_query,array()))/$page_size);
        $page = 1;//请求的页数 默认为第一页

        if (isset($_REQUEST['page'])) {
            $page = $_REQUEST['page'] >= 1 ? $_REQUEST['page'] : '1';  //前请求的页数
            $page = $page <= $page_num ? $page : $page_num;
        }
        $index = ($page-1) * $page_size;

        $limit = " LIMIT ".$index."," .$page_size;
        $page_query = $page_query.$limit;
        if ($session_type == 'external') { //新需求  外部联系人名称需要从 ld_external_contact 查询。
            $query = "SELECT
                ld_users.id AS internal_id,
            	ld_users.wx_userid AS internal_wx_userid,
            	ld_users.last_name AS internal_last_name,
            	c.contactid AS external_id,
            	c.weixin_external_userid AS external_wx_userid,
            	c.external_name AS external_last_name,
            	ws.* 
            FROM
            	ld_wechatsession ws
            	INNER JOIN (
            		".$page_query." 
            		) AS maxmsgtimetable ".$on." 
            		AND maxmsgtimetable.maxmsgtime = ws.msgtime
            	LEFT JOIN ld_users ON ld_users.wx_userid = ws.tolist 
            	LEFT JOIN ld_external_contact c ON c.session_external_userid = ws.tolist".$outerwhere.$groupby. ' order by    maxmsgtimetable.maxmsgtime desc';
            
                    } else {
                        $query = "SELECT
                ld_users.id AS internal_id,
            	ld_users.wx_userid AS internal_wx_userid,
            	ld_users.last_name AS internal_last_name,
            	c.contactid AS external_id,
            	c.weixin_external_userid AS external_wx_userid,
            	c.lastname AS external_last_name,
            	ws.* 
            FROM
            	ld_wechatsession ws
            	INNER JOIN (
            		".$page_query."
            		) AS maxmsgtimetable ".$on." 
            		AND maxmsgtimetable.maxmsgtime = ws.msgtime
            	LEFT JOIN ld_users ON ld_users.wx_userid = ws.tolist 
            	LEFT JOIN ld_contactdetails c ON c.weixin_external_userid = ws.tolist".$outerwhere.$groupby. ' order by    maxmsgtimetable.maxmsgtime desc';

        }




        $result = $adb->pquery($query,array());
        $rows = $adb->num_rows($result);
        $data = $group_chat_list = $contacts_list = [];
        if($rows > 0){
            $userobj = new Users();
            for ($i = 0; $i < $rows; ++$i) {
                $tolist = $adb->query_result($result, $i, 'tolist');
                if ($tolist == $member_wx_userid) {  //去掉本人
                    continue;
                }

                $roomid = $adb->query_result($result, $i, 'roomid');
                // $msgtype = $adb->query_result($result, $i, 'msgtype');
                $msgtime = date("Y-m-d",strtotime($adb->query_result($result, $i, 'msgtime')));
               
              
                $internal_id = $adb->query_result($result, $i, 'internal_id');
                $external_id = $adb->query_result($result, $i, 'external_id');
                // $content = $adb->query_result($result, $i, 'content');
                // $session_type = $adb->query_result($result, $i, 'session_type');
                if (empty($roomid)) { //单聊
                    //获取最后一条信息,仅仅是为了消息内容的展示。
                    $lastmsg_sql = "SELECT ws.* FROM ld_wechatsession AS ws 
                            WHERE
                            	(
                                    (ws.fromid = '$member_wx_userid' AND FIND_IN_SET( '$tolist', ws.tolist )) 
                                    OR (ws.fromid = '$tolist' AND FIND_IN_SET( '$member_wx_userid', ws.tolist ))
                            	) 
                            	AND ws.session_type = '$session_type' 
                            	AND ( ws.roomid = '' OR ws.roomid IS NULL ) 
                            ORDER BY
                            	msgtime DESC 
                            	LIMIT 1;";
                    $lastmsg_result = $adb->pquery($lastmsg_sql,array());
                    $msgtype = $adb->query_result($lastmsg_result, 0, 'msgtype');
                    $content = $adb->query_result($lastmsg_result, 0, 'content');
                    $msgtime = $adb->query_result($lastmsg_result, 0, 'msgtime');
                      if(date("Y-m-d")==date("Y-m-d",strtotime($msgtime)))
                        {
                          
                            $msgtime=date("H:i",strtotime($msgtime));
                            
                        }
                        
                        else if(DateOperation::addDays(date("Y-m-d"),"-1")==date("Y-m-d",strtotime($msgtime)))
                        {
                            $msgtime='昨天';
                        }
                        else
                        {
                            $msgtime=date("Y/m/d",strtotime($msgtime));
                        }
                    if ($msgtype == 'voice') {
                        $content = '[语音]';
                    }elseif ($msgtype == 'image'){
                        $content = '[图片]';
                    }elseif ($msgtype == 'video'){
                        $content = '[视频]';
                    }elseif ($msgtype == 'file'){
                        $content = '[文件]';
                    }
                    if (mb_strlen($content) > 16) {
                        $content = mb_substr($content,0,15).'...';
                    }
                    if ($session_type == 'internal') { //内部
                        $userobj->wx_userid = $adb->query_result($result, $i, 'internal_wx_userid');
                        $userobj->last_name = $adb->query_result($result, $i, 'internal_last_name');
                        $last_name = getUserlastName($userobj);

                        $imagepath = $current_user->getUserImage($internal_id);
                        $contacts_list[] = array(
                            "wx_userid" => $adb->query_result($result, $i, 'internal_wx_userid'),
                            "last_name" => $last_name?:$adb->query_result($result, $i, 'tolist'),
                            "fromid" => $adb->query_result($result, $i, 'fromid'),
                            "tolist" => $adb->query_result($result, $i, 'tolist'),
                            "content" => $content,
                            "msgtime" => $msgtime,
                            "imagepath" => $imagepath,
                            "session_type" => $session_type,
                        );
                    }else{  //外部
                        $imagepath = $current_user->getUserImage($external_id);  //外部成员头像 （默认头像也可以）
                        $contacts_list[] = array(
                            "wx_userid" => $adb->query_result($result, $i, 'external_wx_userid'),
                            "last_name" => $adb->query_result($result, $i, 'external_last_name')?:$adb->query_result($result, $i, 'tolist'),
                            "fromid" => $adb->query_result($result, $i, 'fromid'),
                            "tolist" => $adb->query_result($result, $i, 'tolist'),
                            "content" => $content,
                            "msgtime" => $msgtime,
                            "imagepath" => $imagepath,
                            "session_type" => $session_type,
                        );
                    }
                }else{  //群聊
                    $lastmsg_sql = "select * from ld_wechatsession where roomid=? ORDER BY msgtime desc limit 1";
                    $lastmsg_result = $adb->pquery($lastmsg_sql,array($roomid));
                    $content='';

                    if($adb->num_rows($lastmsg_result)>0)
                    {
                        $msgtype = $adb->query_result($lastmsg_result, 0, 'msgtype');
                        $content = $adb->query_result($lastmsg_result, 0, 'content');
                        if ($msgtype == 'voice') {
                            $content = '[语音]';
                        }elseif ($msgtype == 'image'){
                            $content = '[图片]';
                        }elseif ($msgtype == 'video'){
                            $content = '[视频]';
                        }elseif ($msgtype == 'file'){
                            $content = '[文件]';
                        }
                    }

                    $tolist = $adb->query_result($result, $i, 'tolist');
                    $roomname = $adb->query_result($result, $i, 'roomname');
                    //群名为空，显示成员名称或者wx_userid ?
                    if (empty($roomname)) {
                        $roomname = $this->get_roomname_by_tolist($tolist);
                    }

                    if ($session_type == 'internal') { //内部
                        $group_chat_list[] = array(
                            "wx_userid" => $adb->query_result($result, $i, 'internal_wx_userid'),
                            "last_name" => $adb->query_result($result, $i, 'internal_last_name'),
                            "fromid" => $adb->query_result($result, $i, 'fromid'),
                            "tolist" => $tolist,
                            "roomname" => decode_html($roomname),
                            "roomid" => $roomid,
                            "msgtime" => $msgtime,
                            "session_type" => $session_type,
                            "content" => $content,
                        );
                    }else{  //外部
                        $group_chat_list[] = array(
                            "wx_userid" => $adb->query_result($result, $i, 'external_wx_userid'),
                            "last_name" => $adb->query_result($result, $i, 'external_last_name'),
                            "fromid" => $adb->query_result($result, $i, 'fromid'),
                            "tolist" => $tolist,
                            "roomname" => decode_html($roomname), //tpl显示该值
                            "roomid" => $roomid,
                            "msgtime" => $msgtime,
                            "session_type" => $session_type,
                            "content" => $content,
                        );
                    }

                }
            }
        }

        // dump($contacts_list);
        $data = compact("contacts_list","group_chat_list","search","session_type","page_num", "page");
        return $data;
    }


    //右边 会话列表  根据$session_type是否为groupchat判断 使用 $session_wx_userid 还是 $session_roomid
    public function getChatdataLists($member_wx_userid, $session_wx_userid, $session_roomid, $session_type, $msgtype, $search, $begin_date, $end_date, $seq)
    {
        global $adb, $current_user;
        if (empty($member_wx_userid) || (empty($session_wx_userid) && empty($session_roomid))) {
            return '';
        }

       
        $query = "SELECT
            ld_users.id AS internal_id,
        	ld_users.wx_userid AS internal_wx_userid,
        	ld_users.last_name AS internal_last_name,
        	c.contactid AS external_id,
        	c.weixin_external_userid AS external_wx_userid,
        	c.external_name AS external_last_name,
        	ws.*
        FROM
        	ld_wechatsession ws
        	LEFT JOIN ld_users ON ld_users.wx_userid = ws.fromid 
        	LEFT JOIN ld_external_contact c ON c.session_external_userid = ws.fromid
        WHERE ";

        $where = '';
        //聊天记录where
        if (in_array($session_type,["internal","external","groupchat"])) {
            switch ($session_type){
                case "internal":
                case "external":
                    $where .= " ((ws.fromid = '".$member_wx_userid."' AND ws.tolist = '".$session_wx_userid."') OR (ws.fromid = '".$session_wx_userid."' AND ws.tolist = '".$member_wx_userid."')) AND ws.session_type = '".$session_type."' AND (ws.roomid = '' OR ws.roomid IS NULL)";
                    break;
                case "groupchat":
//                    $where .= " (ws.fromid = '".$member_wx_userid."' OR ws.tolist = '".$member_wx_userid."') AND ws.roomid = '".$session_wx_userid."'";
                    $where .= " ws.roomid = '".$session_roomid."'";
                    break;
            }
        }

        //若有搜索框条件搜索，则不根据消息类型搜索
        if ($search !== '') { // 让0也可以搜索
            $where .= " AND ws.content like '%".$search."%'";
        }else{
            if ($msgtype != 'all') {
                if ($msgtype == 'image')
                    $where .= " AND (ws.msgtype = 'image' OR ws.msgtype = 'video')";//图片和视频合二为一
                else
                    $where .= " AND ws.msgtype = '".$msgtype."'";
            }
        }

        //时间条件
        if (!empty($begin_date) && !empty($end_date) && $begin_date > $end_date) {
            $end_date = ''; //日期选择异常时
        }
        if (!empty($begin_date) && !empty($end_date) && $begin_date == $end_date) {
            $end_date = date('Y-m-d H:i:s',strtotime("$end_date+1day"));
        }
        if (!empty($begin_date)) {
            $begin_date = date('Y-m-d H:i:s',strtotime($begin_date));
            $where .= " AND ws.msgtime >= '".$begin_date."'";
        }
        if (!empty($end_date)) {
            $end_date = date('Y-m-d H:i:s',strtotime($end_date));
            $where .= " AND ws.msgtime <= '".$end_date."'";
        }

//        $orderby = '';
        $orderby = " ORDER BY ws.msgtime DESC ";
//        $orderby = " ORDER BY ws.msgtime ASC ";

        $page_size = 6;  //每页显示10条
        //计算总页数
        $page_num =  ceil($adb->num_rows($adb->pquery($query.$where.$orderby,array()))/$page_size);
        $page = 1;//请求的页数 默认为第一页
//        $page = $page_num >1 ? $page_num:1;//请求的页数 默认为最后一页

        if (isset($_REQUEST['page'])) {  //前端已经做过判断处理了
            $page = $_REQUEST['page'] >= 1 ? $_REQUEST['page'] : '1';  //上一页 下一页  当前请求的页数
            $page = $page <= $page_num ? $page : $page_num;
        }
        $index = ($page-1) * $page_size;

        $limit = " LIMIT ".$index."," .$page_size;

        $sql = $query.$where.$orderby.$limit;

        if (!empty($seq)) {
            $sql = "SELECT * FROM ((".$query.$where." AND ws.seq <".$seq.' ORDER BY ws.msgtime DESC '."LIMIT 3 ) UNION (".$query.$where." AND ws.seq >=".$seq.' ORDER BY ws.msgtime ASC '."LIMIT 3)) AS tmp_ws ORDER BY tmp_ws.msgtime ASC";
        }
//dump($sql);
//        file_put_contents(globalStatic::$root_directory.'modules/WechatSession/getChatdataLists.txt',"\r\n".$sql,FILE_APPEND);

        $result = $adb->pquery($sql,array());
        $rows = $adb->num_rows($result);
        $chatdataLists = [];
        if($rows > 0){
            for ($i = 0; $i < $rows; ++$i) {
                $fromid = $adb->query_result($result, $i, 'fromid');
                if ($member_wx_userid == $fromid) {  //左右布局
                    $leftorright = 'right';
                }else
                    $leftorright = 'left';

                $imagepath = 'themes/images/defaultuser.png';
                $roomname = '';
                if ($session_type == 'internal') {
                    $imagepath = $current_user->getUserImage($adb->query_result($result, $i, 'internal_id'));// 内部成员和内部成员聊天的内部成员头像
                }elseif ($session_type == 'external'){  //内部成员和外部成员聊天的外部成员头像
                    if ($member_wx_userid == $fromid ) {//内部成员发送的消息
                        $imagepath = $current_user->getUserImage($adb->query_result($result, $i, 'internal_id'));
                    } else { //外部成员发送的消息  默认没有头像
                        $imagepath = $current_user->getUserImage($adb->query_result($result, $i, 'external_id'));
                    }
                }elseif ($session_type == 'groupchat'){
                    $roomname = $this->get_chatdata_roomname($session_roomid);
                }

                //不管它是内部还是外部了，不然判断太多了，也麻烦，要是封装get_lastname_by_wx_userid去获取姓名，又要再sql查询，速度又慢了
                if ($adb->query_result($result, $i, 'internal_last_name') != '') {
                    $last_name = $adb->query_result($result, $i, 'internal_last_name');
                } elseif ($adb->query_result($result, $i, 'external_last_name') != ''){
                    $last_name = $adb->query_result($result, $i, 'external_last_name');
                }else{
                    $last_name = $this->get_lastname_by_wx_userid($fromid)?:$fromid; //容错处理
                }
                $msgtime=$msgtime_original=$adb->query_result($result, $i, 'msgtime');
                if(date("Y-m-d")==date("Y-m-d",strtotime($msgtime)))
                {
                    $msgtime=date("H:i:s",strtotime($msgtime));
                    
                }
                if(DateOperation::addDays(date("Y-m-d"),"-1")==date("Y-m-d",strtotime($msgtime)))
                {
                    $msgtime='昨天';
                }
                    
                $chatdataLists[] = array(
                    "id" => $adb->query_result($result, $i, 'id'),
                    "msgid" => $adb->query_result($result, $i, 'msgid'),
                    "msgtype" => $adb->query_result($result, $i, 'msgtype'),
                    "seq" => $adb->query_result($result, $i, 'seq'),

                    "fromid" => $fromid,
                    "roomname" => $roomname,
                    "tolist" => $adb->query_result($result, $i, 'tolist'),
                    "imagepath" => $imagepath,
                    "content" => $adb->query_result($result, $i, 'content'),
                    "filename" => $adb->query_result($result, $i, 'filename'),
                    "filepath" => $adb->query_result($result, $i, 'filepath'),
                    "upload_way" => $adb->query_result($result, $i, 'upload_way'),
                    "play_length" => $adb->query_result($result, $i, 'play_length'),//语音时长
                    "msgtime" =>$msgtime,
                    "msgtime_original" =>$msgtime_original,//按照原字段排序
                    "leftorright" => $leftorright,

                    "session_type" => $session_type,
//                    "last_name" => $this->get_lastname_by_wx_userid($fromid)?:$fromid,
                    "last_name" => $last_name,

                    "title" => $adb->query_result($result, $i, 'title'),
                    "description" => $adb->query_result($result, $i, 'description'),
                    "link_url" => $adb->query_result($result, $i, 'link_url'),
                    "image_url" => $adb->query_result($result, $i, 'image_url'),
                 );

            }
        }
//dump($chatdataLists);
       // 取得列的列表  按照 msgtime 倒序排序
        $order_msgtime =_array_column($chatdataLists,'msgtime_original');// array_column($chatdataLists,'msgtime');
        array_multisort($order_msgtime,SORT_ASC,$chatdataLists);

//        if (!empty($chatdataLists)) return $chatdataLists;
        return compact('chatdataLists', 'page_num', 'page');
    }

    //获取 名称  根据会话类型  分为  内部wx_userid 外部external_wx_userid
    public function get_lastname_by_wx_userid($wx_userid)
    {
        global $adb;
        $last_name = '';
        //会话名称
        if (!empty($wx_userid)) {
            /*$query = "select last_name from ld_users where wx_userid = ?
union
select lastname from ld_contactdetails where weixin_external_userid = ?";*/
            $query = "select last_name from ld_users where wx_userid = ?
union
select external_name as last_name from ld_external_contact where session_external_userid = ?";
            $result = $adb->pquery($query, array($wx_userid, $wx_userid));
            $num_rows = $adb->num_rows($result);
            if ($num_rows >= 1) {
                $userobj = new Users();
                $userobj->wx_userid = $wx_userid;
                $userobj->last_name = $adb->query_result($result, 0, 'last_name');
                $last_name = getUserlastName($userobj);
            }
        }

        if (!empty($last_name)) return $last_name;
        return $wx_userid;
    }

    //获取群名称
    public function get_chatdata_roomname($roomid)
    {
        global $adb;
        $roomname = '';
        if (!empty($roomid)) {
            $query = "select roomname,session_type,CONCAT_WS(',',fromid,tolist) as tolist from ld_wechatsession where roomid = ? order by msgtime desc limit 1";            $result = $adb->pquery($query, array($roomid));
            $roomname = $adb->query_result($result, 0, 'roomname');
            $session_type = $adb->query_result($result, 0, 'session_type');
            //群名为空，显示成员名称或者wx_userid ?
            if (empty($roomname)) {
                if ($session_type == 'external') {
                    $roomname = '外部群';
                }else{
                    $roomname = $this->get_roomname_by_tolist($adb->query_result($result, 0, 'tolist'));
                }
            }
        }

        if (!empty($roomname)) return $roomname;
        return $roomid;
    }

    //获取右边会话内容（聊天记录）的标题  暂不用这种方式
    public function getChatdataLastname($member_wx_userid, $session_wx_userid, $session_type)
    {
        global $adb;
        //标题
        $userobj = new Users();
        $member_name = $session_name = '';

        //成员名称
        if (!empty($member_wx_userid)) {
            $query = "select last_name from ld_users where wx_userid = ? limit 1";
            $tmp_result = $adb->pquery($query, array($member_wx_userid));
            $tmp_num_rows = $adb->num_rows($tmp_result);
            if ($tmp_num_rows >= 1) {
                $userobj->wx_userid = $member_wx_userid;
                $userobj->last_name = $adb->query_result($tmp_result, 0, 'last_name');
                $member_name = getUserlastName($userobj);
            }
        }

        //会话名称
        if (!empty($session_wx_userid) && !empty($session_type)) {
            if ($session_type == 'internal') {
                $query = "select last_name from ld_users where wx_userid = ? limit 1";
                $tmp_result = $adb->pquery($query, array($session_wx_userid));
                $tmp_num_rows = $adb->num_rows($tmp_result);
                if ($tmp_num_rows >= 1) {
                    $userobj->wx_userid = $session_wx_userid;
                    $userobj->last_name = $adb->query_result($tmp_result, 0, 'last_name');
                    $session_name = getUserlastName($userobj);
                }

            }else if ($session_type == 'external'){
                $query = "select lastname from ld_contactdetails where weixin_external_userid = ? limit 1";
                $tmp_result = $adb->pquery($query, array($session_wx_userid));
                $tmp_num_rows = $adb->num_rows($tmp_result);
                if ($tmp_num_rows >= 1) {
                    $userobj->wx_userid = $session_wx_userid;
                    $userobj->last_name = $adb->query_result($tmp_result, 0, 'lastname');
                    $session_name = getUserlastName($userobj);
                }
            }
            else if ($session_type == 'groupchat'){
                $query = "select roomname from ld_wechatsession where roomid = ? limit 1";
                $tmp_result = $adb->pquery($query, array($session_wx_userid));//$session_wx_userid 是roomid
                $session_name = $adb->query_result($tmp_result, 0, 'roomname');
            }
        }

        $chatdataLastname = compact("member_name","session_name");
        return $chatdataLastname;
    }

    //没有群名称时，显示群成员名称last_name。
    public function get_roomname_by_tolist($tolist)
    {
        global $adb;
        $sql = "SELECT last_name FROM ld_users WHERE FIND_IN_SET(?,wx_userid)
UNION
SELECT lastname FROM ld_contactdetails WHERE FIND_IN_SET(?,weixin_external_userid)";
        $result = $adb->pquery($sql,array($tolist,$tolist));
        $rows = $adb->num_rows($result);
        $tolist_arr = [];
        if($rows > 0){
            for($i=0;$i<$rows;$i++){
                $tolist_arr[] = $adb->query_result($result, $i, 'last_name');
            }
            $roomname = implode(',', $tolist_arr);
        }else{
            $roomname = $tolist;
        }

        if (mb_strlen($roomname) > 16) {
            $roomname = mb_substr($roomname,0,30).'...';
        }

        return $roomname;
    }


    /*
     * 根据客户搜索
     * */
    //左边外部联系人成员列表
    public function getMemberListsByCustomer($search = '')
    {
        global $current_user, $adb;
        $memberLists = $contacts_list = $group_chat_list = [];
        //外部联系人
        //edit:can 2021-12-15 49125: （https://61mis.com/order [^]）会话存档，根据客户检索界面，客户列表搜索“美迪”搜索不到数据
        $sql = "SELECT ld_contactdetails.weixin_external_userid,ld_external_contact.external_name as lastname,ld_contactdetails.contactid
        ,ld_external_contact.corp_name FROM ld_contactdetails 
        left join ld_external_contact on ld_contactdetails.weixin_external_userid=ld_external_contact.weixin_external_userid
        left join ld_account on ld_account.accountid=ld_contactdetails.accountid
        WHERE IFNULL(ld_contactdetails.weixin_external_userid,'') <> '' AND 
        (ld_contactdetails.lastname like '%".$search."%' or  ld_account.accountname like '%".$search."%')" ;
        $result = $adb->pquery($sql,array());
        $rows = $adb->num_rows($result);
        if($rows > 0){
            for ($i = 0; $i < $rows; $i++) {
                $imagepath = $current_user->getUserImage($adb->query_result($result, $i, 'contactid'));
                $contacts_list[] = array(
                    'weixin_external_userid' => $adb->query_result($result, $i, 'weixin_external_userid'),
                    'lastname' => $adb->query_result($result, $i, 'lastname'),
                    'corp_name'=>$adb->query_result($result,$i,'corp_name'),
                    'imagepath' => $imagepath,
                );
            }
        }

        /*$sql = "SELECT roomid,roomname,tolist FROM ld_wechatsession WHERE IFNULL(roomid,'') <> '' AND IFNULL(roomname,'') like '%".$search."%' GROUP BY roomid ORDER BY msgtime DESC";
        $result = $adb->pquery($sql,array());
        $rows = $adb->num_rows($result);
        if($rows > 0){
            for ($i = 0; $i < $rows; $i++) {
                $roomname = $adb->query_result($result, $i, 'roomname');
                $tolist = $adb->query_result($result, $i, 'tolist');
                if (empty($roomname)) {
                    $roomname = $this->get_roomname_by_tolist($tolist);
                }
                $group_chat_list[] = array(
                    'roomid' => $adb->query_result($result, $i, 'roomid'),
                    'roomname' => $roomname,
                    'tolist' => $adb->query_result($result, $i, 'tolist'),
                );
            }
        }*/
        $memberLists = compact("contacts_list","group_chat_list");
        return $memberLists;

    }

    //中间会话列表
    public function getSessionListsByCustomer($member_wx_userid, $search, $session_type)
    {
        global $adb,$current_user;
        if (empty($member_wx_userid)) {
            return '';
        }

        $where = '';
        $outerwhere = '';
        $limit = '';
        $groupby = '';
        $on = '';  //连接条件
//        $where .= " (ws.fromid = '".$member_wx_userid."' OR ws.tolist = '". $member_wx_userid . "')";
        $where .= " (ws.fromid = '".$member_wx_userid."' OR FIND_IN_SET('".$member_wx_userid."',ws.tolist))";
        if (in_array($session_type,["external","groupchat"])) {
            switch ($session_type){
                case "external":
                    $where .= " AND ws.session_type = '".$session_type."' AND (ws.roomid = '' OR ws.roomid IS NULL)";
                    $groupby .= " GROUP BY tolist";
                    $on = " ON maxmsgtimetable.tolist = ws.tolist ";
                    break;
                case "groupchat":
                    $where .= " AND ws.roomid <> ''";
//                    $where .= " AND ws.roomid <> '' AND IFNULL(ws.roomname,'') <> ''";  //群名称为空怎么显示？
                    $groupby .= " GROUP BY roomid";
                    $on = " ON maxmsgtimetable.roomid = ws.roomid ";
                    break;
            }
        }
        /*else{
            $limit = " LIMIT 5";
        }*/

        if (!empty($search)) {
            if ($session_type == 'external') {
                $outerwhere = " WHERE ld_users.last_name like '%".$search."%'";
            } elseif ($session_type == 'groupchat') {
                $outerwhere = " WHERE ws.roomname like '%".$search."%'";
            }
        }

        //根据客户检索-》会话列表-》群聊，其实只用到了群名，所以暂时不用改动（ps:下方last_name等参数实际没用上）
        $query = "SELECT
    ld_users.id AS internal_id,
	ld_users.wx_userid AS internal_wx_userid,
	ld_users.last_name AS internal_last_name,
	c.contactid AS external_id,
	c.weixin_external_userid AS external_wx_userid,
	c.lastname AS external_last_name,
	ws.* 
FROM
	ld_wechatsession ws
	INNER JOIN (
		SELECT
			max( msgtime ) AS maxmsgtime,
			tolist,
			roomid 
		FROM
			ld_wechatsession AS ws 
		WHERE
		    ".$where.$groupby." 
		) AS maxmsgtimetable ".$on." 
		AND maxmsgtimetable.maxmsgtime = ws.msgtime
	LEFT JOIN ld_users ON ld_users.wx_userid = ws.tolist 
	LEFT JOIN ld_contactdetails c ON c.weixin_external_userid = ws.tolist".$outerwhere.$groupby;
//dump($query);

        $result = $adb->pquery($query,array());
        $rows = $adb->num_rows($result);
        $data = $group_chat_list = $contacts_list = [];
        if($rows > 0){
            $userobj = new Users();
            for ($i = 0; $i < $rows; ++$i) {
                $tolist = $adb->query_result($result, $i, 'tolist');
                if ($tolist == $member_wx_userid) {  //去掉本人
                    continue;
                }
                $roomid = $adb->query_result($result, $i, 'roomid');
//                $msgtype = $adb->query_result($result, $i, 'msgtype');
                $msgtime = date("Y-m-d",strtotime($adb->query_result($result, $i, 'msgtime')));
                $internal_id = $adb->query_result($result, $i, 'internal_id');
                $external_id = $adb->query_result($result, $i, 'external_id');
//                $content = $adb->query_result($result, $i, 'content');
//                $session_type = $adb->query_result($result, $i, 'session_type');//会话类型 内部 外部  群聊
                if (empty($roomid)) { //单聊
                    //获取最后一条信息,仅仅是为了消息内容的展示。
                    $lastmsg_sql = "SELECT ws.* FROM ld_wechatsession AS ws 
                    WHERE
                    	(
                            (ws.fromid = '$member_wx_userid' AND FIND_IN_SET( '$tolist', ws.tolist )) 
                            OR (ws.fromid = '$tolist' AND FIND_IN_SET( '$member_wx_userid', ws.tolist ))
                    	) 
                    	AND ws.session_type = 'external' 
                    	AND ( ws.roomid = '' OR ws.roomid IS NULL ) 
                    ORDER BY
                    	msgtime DESC 
                    	LIMIT 1;";
                    $lastmsg_result = $adb->pquery($lastmsg_sql,array());
                    $msgtype = $adb->query_result($lastmsg_result, 0, 'msgtype');
                    $content = $adb->query_result($lastmsg_result, 0, 'content');
                    $msgtime = date("Y-m-d",strtotime($adb->query_result($lastmsg_result, 0, 'msgtime')));
//                    $msgtime = $adb->query_result($lastmsg_result, 0, 'msgtime');
                    if ($msgtype == 'voice') {
                        $content = '[语音]';
                    }elseif ($msgtype == 'image'){
                        $content = '[图片]';
                    }elseif ($msgtype == 'video'){
                        $content = '[视频]';
                    }elseif ($msgtype == 'file'){
                        $content = '[文件]';
                    }
//                    mb_internal_encoding("UTF-8");
//                    if(mb_stripos($content,'‘') === false && mb_stripos($content,'’') === false && mb_stripos($content,'“') === false && mb_stripos($content,'”') === false) {
                        if (mb_strlen($content) > 16) { //中文标点符号‘【】’、《》？：“{|}”》·~！@#￥%…… ，比如‘长度为7,汉字为1，就导致页面显示问题
                            $content = mb_substr($content, 0, 15) . '...';
                        }
//                    }
                    //根据客户搜索，会话列表就只有内部联系人
                    $userobj->wx_userid = $adb->query_result($result, $i, 'internal_wx_userid');
                    $userobj->last_name = $adb->query_result($result, $i, 'internal_last_name');
                    $last_name = getUserlastName($userobj);

                    $imagepath = $current_user->getUserImage($internal_id);
                    $contacts_list[] = array(
                        "wx_userid" => $adb->query_result($result, $i, 'internal_wx_userid'),
                        "last_name" => $last_name?:$adb->query_result($result, $i, 'tolist'),
                        "fromid" => $adb->query_result($result, $i, 'fromid'),
                        "tolist" => $adb->query_result($result, $i, 'tolist'),
                        "content" => $content,
                        "msgtime" => $msgtime,
                        "imagepath" => $imagepath,
                        "session_type" => $session_type,

                        "original_msgtime" => strtotime($adb->query_result($lastmsg_result, 0, 'msgtime')),//移动端排序
                        "member_wx_userid" => $member_wx_userid,  //移动端使用
                    );
                }else{  //群聊
                    //edit:can 2021-02-22 43747: （https://61mis.com/ldcrm [^]）会话存档，根据客户检索页签，客户列表数据“刘帅”，【群聊】会话成员列表中没有显示最新一条消息记录
                    $lastmsg_sql = "select * from ld_wechatsession where roomid=? ORDER BY msgtime desc limit 1";
                    $lastmsg_result = $adb->pquery($lastmsg_sql,array($roomid));
                    $content='';
                  
                    if($adb->num_rows($lastmsg_result)>0)
                    {
                        $msgtype = $adb->query_result($lastmsg_result, 0, 'msgtype');
                        $content = $adb->query_result($lastmsg_result, 0, 'content');
                        if ($msgtype == 'voice') {
                            $content = '[语音]';
                        }elseif ($msgtype == 'image'){
                            $content = '[图片]';
                        }elseif ($msgtype == 'video'){
                            $content = '[视频]';
                        }elseif ($msgtype == 'file'){
                            $content = '[文件]';
                        }
                    }
                    $tolist = $adb->query_result($result, $i, 'tolist');
                    $roomname = $adb->query_result($result, $i, 'roomname');
                    //群名为空，显示成员名称或者wx_userid ?
                    if (empty($roomname)) {
                        $roomname = $this->get_roomname_by_tolist($tolist);
                    }

                    if ($session_type == 'internal') { //内部   根据客户搜索时，没有internal类型
                        $group_chat_list[] = array(
                            "wx_userid" => $adb->query_result($result, $i, 'internal_wx_userid'),
                            "last_name" => $adb->query_result($result, $i, 'internal_last_name')?:$adb->query_result($result, $i, 'tolist'),
                            "fromid" => $adb->query_result($result, $i, 'fromid'),
                            "tolist" => $tolist,
                            "roomname" => $roomname,
                            "roomid" => $roomid,
                            "msgtime" => $msgtime,
                            "imagepath" => 'themes/images/defaultuser.png',
                            "session_type" => $session_type,
                            "content" => $content,
                            
                            "original_msgtime" => strtotime($adb->query_result($result, $i, 'msgtime')),
                            "member_wx_userid" => $member_wx_userid,
                        );
                    }else{  //外部
                        $group_chat_list[] = array(
                            "wx_userid" => $adb->query_result($result, $i, 'external_wx_userid'),
                            "last_name" => $adb->query_result($result, $i, 'external_last_name'),
                            "fromid" => $adb->query_result($result, $i, 'fromid'),
                            "tolist" => $tolist,
                            "roomname" => $roomname, //tpl显示该值
                            "roomid" => $roomid,
                           
                            "imagepath" => 'themes/images/defaultuser.png',
                            "session_type" => $session_type,
                             "content" => $content,
                             "msgtime" => $msgtime,
                            "original_msgtime" => strtotime($adb->query_result($result, $i, 'msgtime')),
                            "member_wx_userid" => $member_wx_userid,
                        );
                    }

                }
            }
        }
//        dump($contacts_list);
        $data = compact("contacts_list","group_chat_list","search","session_type");
        return $data;
    }


    //根据客户搜索-》右边-》会话内容（聊天记录）列表  $session_wx_userid的值为wx_userid或者roomid，根据$session_type是否为groupchat判断
    public function getChatdataListsByCustomer($member_wx_userid, $session_wx_userid, $session_roomid, $session_type, $msgtype, $search, $begin_date, $end_date, $seq)
    {
        global $adb, $current_user;
        if (empty($member_wx_userid) || (empty($session_wx_userid) && empty($session_roomid))) {
            return '';
        }

        //        $query = "SELECT ld_users.last_name,ws.* FROM ld_wechatsession ws LEFT JOIN ld_users ON ld_users.wx_userid = ws.tolist WHERE ws.fromid = 'LiuShuai' GROUP BY ws.tolist ORDER BY ws.msgtime DESC LIMIT 5";
        /*$query = "SELECT
    ld_users.id AS internal_id,
	ld_users.wx_userid AS internal_wx_userid,
	ld_users.last_name AS internal_last_name,
	c.contactid AS external_id,
	c.weixin_external_userid AS external_wx_userid,
	c.lastname AS external_last_name,
	ws.* 
FROM
	ld_wechatsession ws
	LEFT JOIN ld_users ON ld_users.wx_userid = ws.fromid 
	LEFT JOIN ld_contactdetails c ON c.weixin_external_userid = ws.fromid
WHERE ";*/

        $query = "SELECT
    ld_users.id AS internal_id,
	ld_users.wx_userid AS internal_wx_userid,
	ld_users.last_name AS internal_last_name,
	c.contactid AS external_id,
	c.weixin_external_userid AS external_wx_userid,
	c.external_name AS external_last_name,
	ws.* 
FROM
	ld_wechatsession ws
	LEFT JOIN ld_users ON ld_users.wx_userid = ws.fromid 
	LEFT JOIN ld_external_contact c ON c.session_external_userid = ws.fromid
WHERE ";

        $where = '';
        //聊天记录where
        if (in_array($session_type,["external","groupchat"])) {
            switch ($session_type){
                case "external":
                    $where .= " ((ws.fromid = '".$member_wx_userid."' AND ws.tolist = '".$session_wx_userid."') OR (ws.fromid = '".$session_wx_userid."' AND ws.tolist = '".$member_wx_userid."')) AND ws.session_type = '".$session_type."' AND (ws.roomid = '' OR ws.roomid IS NULL)";
                    break;
                case "groupchat":
//                    $where .= " (ws.fromid = '".$member_wx_userid."' OR ws.tolist = '".$member_wx_userid."') AND ws.roomid = '".$session_roomid."'";
                    $where .= " ws.roomid = '".$session_roomid."'";
                    break;
            }
        }

        //若有搜索框条件搜索，则不根据消息类型搜索
        if ($search !== '') { // 让0也可以搜索
            $where .= " AND ws.content like '%".$search."%'";
        }else{
            if ($msgtype != 'all') {
                if ($msgtype == 'image')
                    $where .= " AND (ws.msgtype = 'image' OR ws.msgtype = 'video')";//图片和视频合二为一
                else
                    $where .= " AND ws.msgtype = '".$msgtype."'";
            }
        }

        //时间条件
        if (!empty($begin_date) && !empty($end_date) && $begin_date > $end_date) {
            $end_date = ''; //日期选择异常时
        }
        if (!empty($begin_date) && !empty($end_date) && $begin_date == $end_date) {
            $end_date = date('Y-m-d H:i:s',strtotime("$end_date+1day"));
        }
        if (!empty($begin_date)) {
            $begin_date = date('Y-m-d H:i:s',strtotime($begin_date));
            $where .= " AND ws.msgtime >= '".$begin_date."'";
        }
        if (!empty($end_date)) {
            $end_date = date('Y-m-d H:i:s',strtotime($end_date));
            $where .= " AND ws.msgtime <= '".$end_date."'";
        }

//        $orderby = '';
        $orderby = " ORDER BY ws.msgtime DESC ";

        $page_size = 6;  //每页显示10条
        //计算总页数
        $page_num =  ceil($adb->num_rows($adb->pquery($query.$where.$orderby,array()))/$page_size);
        $page = 1;//请求的页数 默认为第一页
//        $page = $page_num >1 ? $page_num:1;//请求的页数 默认为最后一页

        if (isset($_REQUEST['page'])) {  //前端已经做过判断处理了
            $page = $_REQUEST['page'] >= 1 ? $_REQUEST['page'] : '1';  //上一页 下一页  当前请求的页数
            $page = $page <= $page_num ? $page : $page_num;
        }
        $index = ($page-1) * $page_size;

        $limit = " LIMIT ".$index."," .$page_size;

        $sql = $query.$where.$orderby.$limit;

        if (!empty($seq)) {  //搜索框搜索后 查看上下文
            $sql = "SELECT * FROM ((".$query.$where." AND ws.seq <".$seq.' ORDER BY ws.msgtime DESC '."LIMIT 3 ) UNION (".$query.$where." AND ws.seq >=".$seq.' ORDER BY ws.msgtime ASC '."LIMIT 3)) AS tmp_ws ORDER BY tmp_ws.msgtime ASC";
        }
//dump($sql);

        $result = $adb->pquery($sql,array());
        $rows = $adb->num_rows($result);
        $chatdataLists = [];
        if($rows > 0){
            for ($i = 0; $i < $rows; ++$i) {
                $fromid = $adb->query_result($result, $i, 'fromid');
                if ($member_wx_userid == $fromid) {  //左右布局
                    $leftorright = 'right';
                }else
                    $leftorright = 'left';

                $imagepath = 'themes/images/defaultuser.png';
                $roomname = '';
                if ($session_type == 'external'){ //外部 单聊
                    if ($session_wx_userid == $fromid ) {//内部成员发送的消息
                        $imagepath = $current_user->getUserImage($adb->query_result($result, $i, 'internal_id'));
                    } else { //外部成员发送的消息  默认没有头像
                        $imagepath = $current_user->getUserImage($adb->query_result($result, $i, 'external_id'));
                    }
                } elseif ($session_type == 'groupchat') {
                    $roomname = $this->get_chatdata_roomname($session_roomid);
                }

                if ($adb->query_result($result, $i, 'internal_last_name') != '') {  //不为空说明fromid是内部联系人
                    $last_name = $adb->query_result($result, $i, 'internal_last_name');
                } elseif ($adb->query_result($result, $i, 'external_last_name') != ''){//不为空说明fromid是外部联系人，就取外部名字
                    $last_name = $adb->query_result($result, $i, 'external_last_name');
                }else{
                    $last_name = $this->get_lastname_by_wx_userid($fromid)?:$fromid; //容错处理
                }

                $chatdataLists[] = array(
                    "id" => $adb->query_result($result, $i, 'id'),
                    "msgid" => $adb->query_result($result, $i, 'msgid'),
                    "msgtype" => $adb->query_result($result, $i, 'msgtype'),
                    "seq" => $adb->query_result($result, $i, 'seq'),

                    "fromid" => $fromid,
                    "roomname" => $roomname,
                    "tolist" => $adb->query_result($result, $i, 'tolist'),
                    "imagepath" => $imagepath,
                    "content" => $adb->query_result($result, $i, 'content'),
                    "filename" => $adb->query_result($result, $i, 'filename'),
                    "filepath" => $adb->query_result($result, $i, 'filepath'),
                    "upload_way" => $adb->query_result($result, $i, 'upload_way'),
                    "play_length" => $adb->query_result($result, $i, 'play_length'),
                    "msgtime" => $adb->query_result($result, $i, 'msgtime'),
                    "leftorright" => $leftorright,

                    "session_type" => $session_type,
//                    "last_name" => $this->get_lastname_by_wx_userid($fromid)?:$fromid,
                    "last_name" => $last_name,
                );

            }
        }
//dump($chatdataLists);
//        取得列的列表  按照 msgtime 倒序排序
        $order_msgtime =_array_column($chatdataLists,'msgtime');// array_column($chatdataLists,'msgtime');
        array_multisort($order_msgtime,SORT_ASC,$chatdataLists);
//        if (!empty($chatdataLists)) return $chatdataLists;
        return compact('chatdataLists', 'page_num', 'page');
    }

    public function setWxSmarty(&$smarty){
        global $current_user;
        $useWxOpendata = 'no';
        if(isset($this->wxconfig['version']) && $this->wxconfig['version'] == 'v2'){
            $useWxOpendata = 'yes';
        }
        $smarty->assign("useWxOpendata",$useWxOpendata);//是否使用通讯录组件 open-data
        $smarty->assign('IS_ADMIN', is_admin($current_user));

        $wx_agentid="";
        $wx_corpid="";
        $nonceStr="";
        $timestamp="";
        $agent_signature="";
        $signature="";
        $jsapi_string="";
        $agentjsapi_string="";

        if($useWxOpendata=='yes')
        {
            $wx_authinfo=doCorpInfo("get_auth_info",array());

            if($wx_authinfo!=''){
                $wx_auth_arr=  json_decode($wx_authinfo,true);
                $wx_agentid=$wx_auth_arr['crm']['auth_info']['agent'][0]['agentid'];
                $wx_corpid=$wx_auth_arr['crm']['auth_corp_info']['corpid'];
            }


            crm_load_class_file("cls_WeixinPort", 'WeiXinApp/WeiXin_common');
            $port_obj = new cls_WeixinPort();

            $agentjsapi_ticket = $port_obj->getAgentJsApiTicket();
            $jsapi_ticket=$port_obj->getJsApiTicket();

            //$http_html_url=GetCurUrl();
            $http_html_url = $_SERVER['REQUEST_SCHEME'].'://'.$_SERVER['HTTP_HOST'] . $_SERVER['PHP_SELF']."?pageto_module=WechatSession&pageto_action=index";
            $timestamp = time() ;

            //$nonceStr = StaticConst::$sWxConfig['noncestr'];
            $nonceStr =getRandChar(16);

            $agentjsapi_string = "jsapi_ticket=" . $agentjsapi_ticket . "&noncestr=" . $nonceStr . "&timestamp=" . $timestamp . "&url=".$http_html_url;
            $jsapi_string = "jsapi_ticket=" . $jsapi_ticket . "&noncestr=" . $nonceStr . "&timestamp=" . $timestamp . "&url=".$http_html_url;


            $agent_signature = sha1($agentjsapi_string);
            $signature = sha1($jsapi_string);
        }

        $smarty->assign("timestamp",$timestamp);
        $smarty->assign("nonceStr",$nonceStr);
        $smarty->assign("agentsignature",$agent_signature);
        $smarty->assign("signature",$signature);
//        $smarty->assign("agentjsapi_string",$agentjsapi_string);
//        $smarty->assign("jsapi_string",$jsapi_string);
        $smarty->assign("wx_agentid",$wx_agentid);
        $smarty->assign("wx_corpid",$wx_corpid);
    }

}
WechatSession::require_file();

?>