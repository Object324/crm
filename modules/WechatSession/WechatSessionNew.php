<?php

class WechatSessionNew extends WechatSession {
    public $port_obj;
    public $token;
    public $inactiveMemberData;//离职成员的集合
    //public $allMemberData;
    function __construct() {
        parent::__construct();

        crm_load_class_file("StaticConst", 'WeiXinApp/WeiXin_common');
        crm_load_class_file('cls_WeixinPort','WeiXinApp/WeiXin_common');
        $this->port_obj = new cls_WeixinPort();

        $this->token = $this->port_obj->getCorpToken();

        $this->inactiveMemberData = $this->getInactiveMemberlastname();
        //$this->allMemberData = $this->getAllMemberlastname();

    }

    /*
     * 根据成员搜索  //左边成员列表
     * */
    public function getMemberLists($search = '')
    {
        global $adb;

        //通讯录单个搜索功能
        if (!empty($search)) {
            //$search_wx_useridarr =$this->port_obj->getwxUserid('like',$search);
            //dump($search_wx_useridarr);
//            $search_wx_useridarr = $this->contactSearch($search);

        }

        //1、获取会话内容存档开启成员列表
        if (empty($this->wxconfig['permit_user_list'])) {//第一次使用或者更新成员列表时走if初始化数据

            $adb->pquery("update ld_wechat_config set syncstatus=? where id=1",array('start'));

            $wx_userid_arr = $this->getPermitUserList();

            if (empty($wx_userid_arr)) {
                return '';
            }

            //去掉无效成员并转为密文
            if (!empty($this->wxconfig['invalid_userid_list'])) {
                $wx_userid_arr = array_values(array_diff($wx_userid_arr,$this->wxconfig['invalid_userid_list']));
            }

            $converuseridarr=$this->port_obj->getConvertUserId($wx_userid_arr);
//            getConvertUserId接口可能会返回无效的成员，需要去掉,故使用 $permit_wx_userid_arr 接收。  [invalid_userid_list] => array("13795378671","17717232908")
            //dump($converuseridarr);
            $permit_wx_userid_arr = [];
            if(is_array($converuseridarr)&&sizeof($converuseridarr['result'])>0) {
                foreach($converuseridarr['result'] as $info) {
                    $permit_wx_userid_arr[$info['userid']] = $info['open_userid'];
                }
                $adb->pquery("update ld_wechat_config set permit_user_list =? where id=1",array(Zend_Json::encode($permit_wx_userid_arr)));

                //dump($permit_wx_userid_arr);
                //新功能   往全员表ld_wechatuserid增量更新 //XUQIU1002135 ls 20231103 会话存档离职成员信息显示
                $alluserid_sql = "SELECT GROUP_CONCAT(wechatuserid) as all_userid FROM ld_wechatuserid";
                $alluserid_result = $adb->pquery($alluserid_sql ,array());
                $alluserid_rows = $adb->num_rows($alluserid_result);
                if($alluserid_rows > 0){
                    $alluserid_str = $adb->query_result($alluserid_result, 0, 'all_userid');
                    $alluserid_arr = explode(',',$alluserid_str);

                    //先将所有成员更新为离职状态；然后循环开启存档权限的成员，如果在全员表中的要更新状态status为active；不再全员表中的插入数据
                    $adb->pquery("update ld_wechatuserid set status='inactive'",array());

                    foreach($permit_wx_userid_arr as $tmp_wechatuserid=>$tmp_convertuserid){
                        if(in_array($tmp_wechatuserid,$alluserid_arr)){
                            $adb->pquery("update ld_wechatuserid set status='active' where wechatuserid=?",array($tmp_wechatuserid));
                        }else{
                            $adb->pquery("insert into ld_wechatuserid(wechatuserid,convertuserid,`status`) values(?,?,?)",array($tmp_wechatuserid,$tmp_convertuserid,'active'));
                        }
                    }

                }else{
                    //没有值说明是第一次初始化全员表，可以直接插入
                    foreach($permit_wx_userid_arr as $tmp_wechatuserid=>$tmp_convertuserid){
                        $adb->pquery("insert into ld_wechatuserid(wechatuserid,convertuserid,`status`) values(?,?,?)",array($tmp_wechatuserid,$tmp_convertuserid,'active'));
                    }
                }

            }

            if(is_array($converuseridarr)&&sizeof($converuseridarr['invalid_userid_list'])>0) {
                $invalid_userid_list = $converuseridarr['invalid_userid_list'];
            }else{
                $invalid_userid_list = '';
            }
            $adb->pquery("update ld_wechat_config set invalid_userid_list = ? where id=1",array(Zend_Json::encode($invalid_userid_list)));
            $sql='update   ld_wechatconvertuserid 
					inner join ld_wechatuserid on ld_wechatuserid.wechatuserid=ld_wechatconvertuserid.wechatuserid
					set ld_wechatconvertuserid.convertuserid=ld_wechatuserid.convertuserid
					where  ld_wechatuserid.convertuserid<>ld_wechatconvertuserid.convertuserid ';
            $adb->pquery($sql,array());

        }else{
            $permit_wx_userid_arr = $this->wxconfig['permit_user_list'];
        }

        if (is_array($search_wx_useridarr) && array_key_exists('userid',$search_wx_useridarr)) {
            $permit_wx_userid_arr = array_intersect($search_wx_useridarr['userid'],$permit_wx_userid_arr);//取交集
        }

        //获取部门列表
        if (empty($this->wxconfig['departmentlist'])) {
            $departmentList = $this->getDepartmentList();

            if (!empty($departmentList))
                $adb->pquery("update ld_wechat_config set departmentlist =? where id=1",array(Zend_Json::encode($departmentList)));
        }else{
            $departmentList = $this->wxconfig['departmentlist'];
        }
//        dump($departmentList);


        if(!empty($this->inactiveMemberData)){
            $departmentList[] = array(
                "id"=>1000,
                "name"=>'离职成员',
                "parentid"=>1,
                "order"=>10,//100000000
                "status"=>"inactive",
            );
        }

//dump($departmentList);
        if (!empty($departmentList)) {
            //根据order排序
            $order = array_column($departmentList, 'order');
            array_multisort($order, SORT_DESC, $departmentList);

            $j = 0;
            $grouparr = array();
            foreach ($departmentList as $id=>$items) {
                $grouparr['group_'.$items['id']] = $j;
                $j++;
            }
            //dump($grouparr);
            //组装parentgroup
            $i = 0;
            $grouparray = array();
            foreach ($departmentList as $id=>&$items) {
                $items['groupid'] = $items['id'];
                if(isset($items['status']) && $items['status'] == 'inactive'){
                    $items['groupname'] = $items['name'];
                }else{
                    $items['groupname'] = '<ww-open-data type="departmentName" name="wxopendata" openid="'.$items['name'].'"></ww-open-data>';
                }

                $items['type'] = 'group';

                if(0 == $items['parentid']){
                    $items['parentgroup'] = $items['id'];
                    $items['parentgroupid'] = 'group_0_'.($items['parentid']+1);
                }else{
                    $key = array_search($items['parentid'], array_column($departmentList, "id"));
                    if ($key !== false) {
                        $items['parentgroup'] = $departmentList[$key]["parentgroup"].'::'.$items['id'];
                        $items['parentgroupid'] = 'group_'.$items['parentid'].'_'.($grouparr['group_'.$items['parentid']]+1);
                    }
                }

                $key = 'group_'.$items['groupid'].'_'.($i+1);
                $grouparray[$key] = $items;

                $i++;
            }
            //dump($grouparray);
            $needsave_userLists = [];
            foreach ($grouparray as &$department){
                $userList = [];
                $groupid = $department['id'];
                if(isset($department['status']) && $department['status'] == 'inactive'){//离职部门时
                    //获取离职成员部门集合
                    foreach($this->inactiveMemberData as $tmp_convertuserid=>$tmp_lastname){
                        $userList[] = array("userid"=>$tmp_convertuserid,"name"=>$tmp_lastname,"open_userid"=>$tmp_convertuserid,"status"=>$department['status']);
                    }
                }else{
                    //获取部门成员详情
                    if (empty($this->wxconfig['userlist'])) {
                        $userList = $this->getUserList($groupid);
                        $needsave_userLists[$groupid] = $userList;//记录需要保存到数据库的数据
                    }else{
                        $userList = $this->wxconfig['userlist'][$groupid];
                    }
                    foreach ($userList as $key=>$user) {
                        //去掉部门下没有开启会话存档的成员
                        if (!in_array($user['userid'],$permit_wx_userid_arr)) {
                            unset($userList[$key]);
                        }
                    }
                }


                $department['userlist'] = array_values($userList);
            }

            if (!empty($needsave_userLists)) {
                $adb->pquery("update ld_wechat_config set userlist =? where id=1",array(Zend_Json::encode($needsave_userLists)));
            }

            //dump($grouparray);
            $parentarray = $this->setOneParent($grouparray,'parentgroupid');
//            dump($parentarray);
            $treehtml = $this->setTreeListGroup($parentarray);

        }else{
            //当部门列表接口无数据时
            if (empty($this->wxconfig['userinfo'])) {
                //读取成员 TODO... 待优化  感觉可以往前提，把成员信息读取到数据库方便使用，只是刚进入时速度慢点
                $userinfo_arr = [];
                foreach ($permit_wx_userid_arr as $wx_userid){
                    $userinfo = $this->getUser($wx_userid);
                    if (!empty($userinfo))
                        $userinfo_arr[$wx_userid] = $userinfo;
                }

                if (!empty($userinfo_arr))
                    $adb->pquery("update ld_wechat_config set userinfo =? where id=1",array(Zend_Json::encode($userinfo_arr)));
            }else{
                $userinfo_arr = $this->wxconfig['userinfo'];
            }


            $treehtml = $this->setTreeListUser($userinfo_arr);

        }

        $adb->pquery("update ld_wechat_config set syncstatus='' where id=1",array());

        return $treehtml;

    }
    public function setTreeListGroup($array) {
        global $current_user;
        if(empty($array)) return false;
        if(empty($parent)) $parent = 'parentgroup';
        if(empty($isbox)) $isbox = 'checkbox';
        $tree = '<ul class="filetree">';

        $folder = '';$children = '';
        foreach($array as $id=>$arr){
            $tree .= '<li>';$folder = '';$children = '';
//            $group_arr = explode('_',$id);
            if($arr['type']=='group')
            {
                $folder .= '<div class="groupuser-treediv">';
                $folder .= '<div class="groupuser-treediv-span">';
                $folder .= '<span class="file" record="'.$id.'" parent="'.$arr[$parent].'"><label>'.$arr['groupname'].'</label></span>';
                $folder .= '</div></div>';
            }

            //部门下成员
            if (!empty($arr['userlist'])) {
                $folder .= '<ul>';
                foreach ($arr['userlist'] as $user){
                    $folder .= '<li>';
                    if(isset($user['status']) && $user['status'] == 'inactive'){//离职成员
                        $lastname = $user['name'];
                        $folder .= '<div class="groupuser-treediv" onmouseover="WechatSessionobj.ChatMemberListobj.showEdit(this);" onmouseout="WechatSessionobj.ChatMemberListobj.hideEdit(this);">';
                        $folder .= '<div class="groupuser-treediv-span">';
                        $folder .= '<span class="file" style="display:block;cursor:pointer;" block="member" class="" record="'.$id.'" parent="'.$arr[$parent].'">'.
                            '<label><input type="hidden" userid="'.$arr['groupid'].'" name="wx_userid" value="'.$user['userid'].'">'.$lastname .'</label></span>';
                    }else{
                        $avatar = '<img width="30px" style="padding:0 5px;" src="'.$user['thumb_avatar'].'">';
                        $lastname = '<ww-open-data type="userName" name="wxopendata" openid="' . $user['userid'] . '"></ww-open-data>';
                        $folder .= '<div class="groupuser-treediv" onmouseover="WechatSessionobj.ChatMemberListobj.showEdit(this);" onmouseout="WechatSessionobj.ChatMemberListobj.hideEdit(this);">';
                        $folder .= '<div class="groupuser-treediv-span">';
                        $folder .= '<span class="file" style="display:block;cursor:pointer;" block="member" class="" record="'.$id.'" parent="'.$arr[$parent].'">'.$avatar.
                            '<label><input type="hidden" userid="'.$arr['groupid'].'" name="wx_userid" value="'.$user['userid'].'">'.$lastname .'</label></span>';
                    }


                    $folder .= '<div name="user_group" class="groupuser-treediv-btn" style="display:none;">';

                    $folder .=  '<a onclick="WechatSessionobj.ChatMemberListobj.editMemberlastname(this,\''.$user['userid'].'\');">编辑</a>';
                    $folder .= '</div>';
                    $folder .= '</div>';
                    $folder .= '</div>';

                    $folder .= '</li>';
                }
                $folder .= '</ul>';
            }


            if(isset($arr['children']) && !empty($arr['children'])){
                //如果有下级，则递归调用
                $children = $this->setTreeListGroup($arr['children']);
            }
            $tree .= $folder.$children;
            $tree .= '</li>';
        }
        $tree .= '</ul>';
        return $tree;
    }
    public function setOneParent($array,$parentid = '') {
        $tree = '';
        if(empty($parentid)) $parentid = 'parentid';
        foreach($array as $id=>$arr){
            // 处理成树状结构显示的数组

            if(0 == $arr['parentid']){
                $tree = $arr[$parentid];
            }
            if($arr[$parentid] /*&&  $arr['parentid'] != $id*/){//传引用
                $array[$arr[$parentid]]['children'][$id] = &$array[$id];
            }
        }

        if(isset($array[$tree]['children'])){
            $array = $array[$tree]['children'];
            return $array;
        }
        return $array;
    }
    public function setTreeListUser($array){
        $tree = '<ul>';
        foreach($array as $id=>$arr){
            $tree .= '<li>';$folder = '';$children = '';
            $label = '<label><input type="hidden" userid="'.$arr['wx_userid'].'" name="wx_userid" value="'.$arr['wx_userid'].'">'. $arr['lastname'].'</label>';

            $imagepath = $arr['thumb_avatar'];
            $folder = '<span style="display:block;cursor:pointer;" block="member" class="" record="'.$id.'">'.'<img width="30px" src="'.$imagepath.'"> '.$id.$label.'</span>';


            if(isset($arr['children']) && !empty($arr['children'])){
                //如果有下级，则递归调用
                $children = $this->setTreeListUser($arr['children']);
            }
            $tree .= $folder.$children;
            $tree .= '</li>';
        }
        $tree .= '</ul>';
        return $tree;
    }

    /* *
     * 获取会话内容存档开启成员列表
     * 权限说明：   企业需要使用会话内容存档应用secret所获取的accesstoken来调用
     * 返回值：最终以成员userid的形式返回   数组  明文，需要 转密文
     * */
    public function getPermitUserList(){
        $corpid = $this->wxconfig['corpid'];
        $secret = $this->wxconfig['secret'];
        $user_list_arr = [];
        if (!empty($corpid) && !empty($secret)) {
            include_once(globalStatic::$root_directory."vendor/weworkapi_php/api/src/CorpAPI.class.php");
            $api = new CorpAPI($corpid, $secret);
            $user_list_arr = $api->get_permit_user_list();

        }
        return $user_list_arr;
    }

    /* *
     * 获取部门列表
     * */
    public function getDepartmentList()
    {
        $departmentList = [];
        $url = "https://qyapi.weixin.qq.com/cgi-bin/department/list?access_token=".$this->token;
        $rspJson = $this->port_obj->primary_curl($url);
        $rspJson = json_decode($rspJson,true);
        if ($rspJson['errcode'] === 40014) {//token失效
            $this->token = $this->port_obj->getCorpToken();
            $rspJson = $this->port_obj->primary_curl($url);
            $rspJson = json_decode($rspJson,true);
        }

        if ($rspJson['errcode'] === 0) {
            $departmentList = $rspJson['department'];
        }

        return $departmentList;
    }

    /* *
     * 获取部门成员详情
     * */
    public function getUserList($department_id='')
    {
        $userList = array();

        if (!empty($department_id)){
            $url = "https://qyapi.weixin.qq.com/cgi-bin/user/list?access_token=" . $this->token . "&department_id=" . $department_id;
            $rspJson = $this->port_obj->primary_curl($url);
            $rspJson = json_decode($rspJson, true);
            if ($rspJson['errcode'] === 40014) {
                $this->token = $this->port_obj->getCorpToken();
                $rspJson = $this->port_obj->primary_curl($url);
                $rspJson = json_decode($rspJson, true);
            }
            if ($rspJson['errcode'] === 0) {
                $userList = $rspJson['userlist'];
                /*if (isset($userList['userid'])){
                    $userList ['lastname'] = '<ww-open-data type="userName" name="wxopendata" openid="' . $userList['userid'] . '"></ww-open-data>';
                    $userList ['wx_userid'] = $userList ['userid'];
                    $userList['type'] = 'user';
                }*/
            }
        }



        return $userList;
    }

    /* *
     * 读取成员
     * */
    public function getUser($wx_userid='')
    {
        $user = array();
        if (!empty($wx_userid)) {
            $url = "https://qyapi.weixin.qq.com/cgi-bin/user/get?access_token=".$this->token."&userid=".$wx_userid;
            $rspJson = $this->port_obj->primary_curl($url);

            $rspJson = json_decode($rspJson,true);
            if ($rspJson['errcode'] === 40014) {
                $this->token = $this->port_obj->getCorpToken();
                $rspJson = $this->port_obj->primary_curl($url);
                $rspJson = json_decode($rspJson,true);
            }

            if ($rspJson['errcode'] === 0) {
                $user = $rspJson;
                $user['lastname'] = '<ww-open-data type="userName" name="wxopendata" openid="'.$user['userid'].'"></ww-open-data>';
                $user['wx_userid'] = $user['userid'];

            }
        }

        return $user;
    }


    //中间会话列表   $session_type：会话类型 内部 外部  群聊
    public function getSessionLists($member_wx_userid, $search, $session_type)
    {
        global $adb;
        if (empty($member_wx_userid)) {
            return '';
        }

        $mapid_result = $adb->pquery("select mapid from ld_wechatmapuserid where mapuserid=? limit 1",array($member_wx_userid));//woKcoAEgAANGFHb7Q0qmwohWYQIl0IgA
        if ($adb->num_rows($mapid_result) <= 0 ) {
            return '';
        }
        $mapid =  $adb->query_result($mapid_result, 0, 'mapid');

        $where = ' ';
        $outerwhere = '';
        $limit = '';
        $groupby = '';
        $on = '';  //连接条件
//        $where .= " (ws.fromid = '".$member_wx_userid."' OR ws.tolist = '". $member_wx_userid . "')";

        if (in_array($session_type,["internal","external","groupchat"])) {
            switch ($session_type){
                case "internal":
                case "external":
                    $where .= " (ws.mapfromid = '".$mapid."' OR ws.maptolist = '". $mapid . "')";
                    $where .= " AND ws.session_type = '".$session_type."' ";
                    $groupby .= " GROUP BY ws.wechatsessionid";
                    break;
                case "groupchat":
                    $where .= " ld_wechatroomuserid.mapid = ".$mapid."";
                    /*$where .= " (ws.fromid = '".$member_wx_userid."' OR FIND_IN_SET('".$member_wx_userid."',ws.tolist))";
                    $where .= " AND ws.roomid <> ''";
                    $groupby .= " GROUP BY roomid";*/
                    break;
            }
        }

        //没有搜索，按照 内部、外部、群聊显示
        if (!empty($search)) {
            if ($session_type == 'internal') {
                $search_wx_useridarr =$this->port_obj->getwxUserid('like',$search);//需要调用通讯录搜索接口功能
                if (array_key_exists('userid',$search_wx_useridarr)) {
                    $search_wx_userid = implode("','",$search_wx_useridarr['userid']);
                    $outerwhere = " WHERE maxmsgtimetable.maptolist IN (SELECT mapid FROM ld_wechatmapuserid IN ($search_wx_userid))";
                }else{
                    $outerwhere = " WHERE 1<>1 ";//表示搜索结果为空
                }
            } elseif ($session_type == 'external') {
                $outerwhere = " WHERE c.external_name like '%".$search."%' AND ";
            } elseif ($session_type == 'groupchat') {
                $outerwhere = " WHERE wsroom.roomname like '%".$search."%' AND ";
            }
        }


        //获取成员列表成员的会话人员
        if ($session_type == 'internal' || $session_type == 'external') {
            $page_query = "SELECT
                    wechatsessionid 
                FROM
                    ld_wechatsessiontime AS ws 
                WHERE
                    ".$where.$groupby." order by ws.maxmsgtime desc ";
        }else{
            $page_query = "SELECT
                wsroom.wechatsessionid
            FROM
                ld_wechatmaproomid AS wsroom
            INNER JOIN ld_wechatroomuserid on  wsroom.groupid = ld_wechatroomuserid.groupid
            WHERE ld_wechatroomuserid.mapid = ".$mapid;
        }

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
		if(empty($outerwhere))
		{
			$where=" where ".$where;
		}
        //dump($page_query);
        if ($session_type == 'external') { //新需求  外部联系人名称需要从 ld_external_contact 查询。
            $query = "SELECT
            	'' AS internal_wx_userid,
            	c.weixin_external_userid AS external_wx_userid,
            	c.external_name AS external_last_name,
            	ws.* 
            FROM
            	ld_wechatsession ws
            	INNER JOIN (
            		".$page_query." 
            		) AS maxmsgtimetable  
            		on maxmsgtimetable.wechatsessionid = ws.id
            	LEFT JOIN ld_external_contact c ON c.session_external_userid = ws.fromid OR c.session_external_userid = ws.tolist ".$outerwhere.$where;

        } elseif($session_type == 'internal') {
            $query = "SELECT
            	'' AS internal_wx_userid,
            	c.weixin_external_userid AS external_wx_userid,
            	c.lastname AS external_last_name,
            	ws.* 
            FROM
            	ld_wechatsession ws
            	INNER JOIN (
            		".$page_query." 
            		) AS maxmsgtimetable  
            		 on  maxmsgtimetable.wechatsessionid = ws.id
            	LEFT JOIN ld_contactdetails c ON c.weixin_external_userid = ws.fromid OR c.weixin_external_userid = ws.tolist".$outerwhere.$where;

        } else {
            $query = "SELECT
                    '' AS internal_wx_userid,
                    '' AS external_wx_userid,
                    '' AS external_last_name,
                    ws.* 
                FROM
                    ld_wechatmaproomid wsroom
                INNER JOIN ld_wechatroomuserid ON  wsroom.groupid = ld_wechatroomuserid.groupid
                LEFT JOIN ld_wechatsession ws ON wsroom.wechatsessionid=ws.id".
                $outerwhere.$where."
                ORDER BY ws.msgtime DESC".$limit;

        }

//dump($query);

        $result = $adb->pquery($query,array());
        $rows = $adb->num_rows($result);
        $data = $group_chat_list = $contacts_list = [];
        if($rows > 0){
            for ($i = 0; $i < $rows; ++$i) {
                $fromid = $adb->query_result($result, $i, 'fromid');
                $tolist = $adb->query_result($result, $i, 'tolist');

                $roomid = $adb->query_result($result, $i, 'roomid');
//                $msgtime = date("Y-m-d",strtotime($adb->query_result($result, $i, 'msgtime')));



                if (empty($roomid)) { //单聊
                    if ($tolist == $member_wx_userid) {// 最新一条消息 可能是别人发给$member_wx_userid的，因此需要调换位置
                        $tolist = $fromid;
                        $fromid = $member_wx_userid;
                    }

                    //获取最后一条信息,仅仅是为了消息内容的展示。
                    /*$lastmsg_sql = "SELECT ws.* FROM ld_wechatsession AS ws
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

                    $lastmsg_result = $adb->pquery($lastmsg_sql,array());*/
                    $msgtype = $adb->query_result($result, $i, 'msgtype');
                    $content = $adb->query_result($result, $i, 'content');
                    $msgtime = $msgtime_original = $adb->query_result($result, $i, 'msgtime');
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
                        $last_name = isset($this->inactiveMemberData[$tolist])?$this->inactiveMemberData[$tolist]:'<ww-open-data type="userName" name="wxopendata" openid="' . $tolist . '"></ww-open-data>';

                        if (isset($this->wxconfig['userinfo'][$tolist]))
                            $imagepath = $this->wxconfig['userinfo'][$tolist]['thumb_avatar'];
                        else
                            $imagepath = 'themes/images/defaultuser.png';

                        $contacts_list[] = array(
                            "wx_userid" => $tolist,
                            "last_name" => $last_name,
                            "fromid" => $fromid,
                            "tolist" => $tolist,
                            "content" => decode_html($content),
                            "msgtime" => $msgtime,
                            "msgtime_original" => $msgtime_original,
                            "imagepath" => $imagepath,
                            "session_type" => $session_type,
                        );
                    }else{  //外部
                        $imagepath = 'themes/images/defaultuser.png';  //外部成员头像 （默认头像也可以）

                        $contacts_list[] = array(
                            "wx_userid" => $adb->query_result($result, $i, 'external_wx_userid'),
                            "last_name" => $adb->query_result($result, $i, 'external_last_name')?:$tolist,
                            "fromid" => $fromid,
                            "tolist" => $tolist,
                            "content" => decode_html($content),
                            "msgtime" => $msgtime,
                            "msgtime_original" => $msgtime_original,
                            "imagepath" => $imagepath,
                            "session_type" => $session_type,
                        );
                    }
                }else{  //群聊
//                    $lastmsg_sql = "select * from ld_wechatsession where roomid=? ORDER BY msgtime desc limit 1";
//                    $lastmsg_result = $adb->pquery($lastmsg_sql,array($roomid));
                    $content='';

//                    if($adb->num_rows($lastmsg_result)>0)
//                    {
                    $msgtype = $adb->query_result($result, $i, 'msgtype');
                    $content = $adb->query_result($result, $i, 'content');
                    $msgtime = $msgtime_original = $adb->query_result($result, $i, 'msgtime');
                    $lastmsg_session_type = $adb->query_result($result, $i, 'session_type');
                    if ($msgtype == 'voice') {
                        $content = '[语音]';
                    }elseif ($msgtype == 'image'){
                        $content = '[图片]';
                    }elseif ($msgtype == 'video'){
                        $content = '[视频]';
                    }elseif ($msgtype == 'file'){
                        $content = '[文件]';
                    }
//                    }

                    $tolist = $adb->query_result($result, $i, 'tolist');
                    $roomname = $adb->query_result($result, $i, 'roomname');
                    //群名为空，显示成员名称或者wx_userid ?
                    if (empty($roomname)) {
                        if($lastmsg_session_type == 'external'){
                            $roomname = "外部群";
                        }else{
                            $room_member = $member_wx_userid.','.$tolist;
                            $roomname = $this->get_roomname_by_tolist($room_member);
                        }

                    }

                    if ($session_type == 'internal') { //内部
                        $last_name = '<ww-open-data type="userName" name="wxopendata" openid="' . $adb->query_result($result, $i, 'internal_wx_userid') . '"></ww-open-data>';
                        $group_chat_list[] = array(
                            "wx_userid" => $adb->query_result($result, $i, 'internal_wx_userid'),
                            "last_name" => $last_name,
                            "fromid" => $adb->query_result($result, $i, 'fromid'),
                            "tolist" => $tolist,
                            "roomname" => decode_html($roomname),
                            "roomid" => $roomid,
                            "msgtime" => $msgtime,
                            "msgtime_original" => $msgtime_original,
                            "session_type" => $session_type,
                            "content" => urldecode($content),
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
                            "msgtime_original" => $msgtime_original,
                            "session_type" => $session_type,
                            "content" => urldecode($content),
                        );
                    }

                }
            }
        }

        $order_msgtime =_array_column($contacts_list,'msgtime_original');
        array_multisort($order_msgtime,SORT_DESC,$contacts_list);

        //dump($contacts_list);
        $data = compact("contacts_list","group_chat_list","search","session_type","page_num", "page");
        return $data;
    }

    //右边 会话列表  根据$session_type是否为groupchat判断 使用 $session_wx_userid 还是 $session_roomid
    public function getChatdataLists($member_wx_userid, $session_wx_userid, $session_roomid, $session_type, $msgtype, $search, $begin_date, $end_date, $seq)
    {
        global $adb;
        if (empty($member_wx_userid) || (empty($session_wx_userid) && empty($session_roomid))) {
            return '';
        }

        $mapfromidid_result = $adb->pquery("select mapid from ld_wechatmapuserid where mapuserid=? limit 1",array($member_wx_userid));//woKcoAEgAANGFHb7Q0qmwohWYQIl0IgA
        if ($adb->num_rows($mapfromidid_result) <= 0 ) {
            return '';
        }
        $mapfromidid =  $adb->query_result($mapfromidid_result, 0, 'mapid');





        $where = '';
        //聊天记录where
        if (in_array($session_type,["internal","external","groupchat"])) {
            switch ($session_type){
                case "internal":
                case "external":
                    $maptolist_result = $adb->pquery("select mapid from ld_wechatmapuserid where mapuserid=? limit 1",array($session_wx_userid));
                    if ($adb->num_rows($maptolist_result) <= 0 ) {
                        return '';
                    }
                    $maptolist =  $adb->query_result($maptolist_result, 0, 'mapid');
                    $where = ' 1=1 ';
                    $unionwhere .= " (ws.mapfromid = '".$mapfromidid."' AND ws.maptolist = '".$maptolist."') ";
                    $unionwhere2 .= " (ws.mapfromid = '".$maptolist."' AND ws.maptolist = '".$mapfromidid."') ";
                    break;
                case "groupchat":
                    $maproomid_result = $adb->pquery("select groupid from ld_wechatmaproomid where roomid=? limit 1",array($session_roomid));
                    if ($adb->num_rows($maproomid_result) <= 0 ) {
                        return '';
                    }
                    $maproomid =  $adb->query_result($maproomid_result, 0, 'groupid');
                    $where .= " ws.maproomid = '".$maproomid."'";
                    break;
            }
        }


        if(in_array($session_type,["internal","external"])){
            $query = "SELECT
        	'' AS internal_wx_userid,
        	c.contactid AS external_id,
        	c.weixin_external_userid AS external_wx_userid,
        	c.external_name AS external_last_name,
        	ws.*
        FROM
        	 (
			SELECT
				ws.*
			FROM
				ld_wechatsession ws
			WHERE
				".$unionwhere."
			UNION ALL 
			SELECT
				ws.*
			FROM
				ld_wechatsession ws
			WHERE
				".$unionwhere2."
			) ws
			LEFT JOIN ld_external_contact c ON c.session_external_userid = ws.fromid
        	
        WHERE ";
        }else{
            $query = "SELECT
					'' AS internal_wx_userid,
					c.contactid AS external_id,
					c.weixin_external_userid AS external_wx_userid,
					c.external_name AS external_last_name,
					ws.*
				FROM
					ld_wechatsession ws
					LEFT JOIN ld_external_contact c ON c.session_external_userid = ws.fromid
				WHERE ";
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

        $orderby = " ORDER BY ws.msgtime DESC ";
//        $orderby = " ORDER BY ws.msgtime ASC ";

        $page_size = 50;  //每页显示10条
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

                if (isset($this->wxconfig['userinfo'][$member_wx_userid]))
                    $imagepath = $this->wxconfig['userinfo'][$member_wx_userid]['thumb_avatar'];
                else
                    $imagepath = 'themes/images/defaultuser.png';

                $roomname = $adb->query_result($result, $i, 'roomname');
                /*if ($session_type == 'internal') {
                    $imagepath = 'themes/images/defaultuser.png';// 内部成员和内部成员聊天的内部成员头像
                }elseif ($session_type == 'external'){  //内部成员和外部成员聊天的外部成员头像
                    if ($member_wx_userid == $fromid) {//内部成员发送的消息
                        $imagepath = $current_user->getUserImage($adb->query_result($result, $i, 'internal_id'));
                    } else { //外部成员发送的消息  默认没有头像
                        $imagepath = $current_user->getUserImage($adb->query_result($result, $i, 'external_id'));
                    }
                }else*/
                if ($session_type == 'groupchat' && empty($roomname)){
//                    $roomname = $this->get_chatdata_roomname($session_roomid);
                }

                if ($adb->query_result($result, $i, 'external_last_name') != ''){
                    $last_name = $adb->query_result($result, $i, 'external_last_name');
                }elseif(isset($this->inactiveMemberData[$fromid])){
                    $last_name = $this->inactiveMemberData[$fromid];
                }else{
                    $last_name = '<ww-open-data type="userName" name="wxopendata" openid="' . $fromid . '"></ww-open-data>';
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
                    "roomname" => decode_html($roomname),
                    "tolist" => $adb->query_result($result, $i, 'tolist'),
                    "imagepath" => $imagepath,
                    "content" => urldecode($adb->query_result($result, $i, 'content')),
                    "filename" => $adb->query_result($result, $i, 'filename'),
                    "filepath" => urldecode($adb->query_result($result, $i, 'filepath')),
                    "upload_way" => $adb->query_result($result, $i, 'upload_way'),
                    "play_length" => $adb->query_result($result, $i, 'play_length'),//语音时长
                    "msgtime" =>$msgtime,
                    "msgtime_original" =>$msgtime_original,
                    "leftorright" => $leftorright,

                    "session_type" => $session_type,
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

    public function get_lastname_by_wx_userid($wx_userid)
    {
        global $adb;
        $last_name = '';
        //会话名称
        if (!empty($wx_userid)) {
            $query = "select external_name as last_name from ld_external_contact where session_external_userid = ? limit 1";
            $result = $adb->pquery($query, array($wx_userid));
            $num_rows = $adb->num_rows($result);
            if ($num_rows >= 1) {
                $last_name = $adb->query_result($result,0,'last_name');
            }else{
                $last_name = '<ww-open-data type="userName" name="wxopendata" openid="' . $wx_userid . '"></ww-open-data>';
            }
        }

        if (!empty($last_name)) return $last_name;
        return $wx_userid;
    }

    public function get_roomname_by_tolist($tolist)
    {
        global $adb;
        $tmp_tolist_arr = [];
        $tolist_arr = explode(',',$tolist);
        $tolist_arr = array_slice($tolist_arr, 0, 2);
        foreach ($tolist_arr as $tmp_tolist) {
            $tmp_tolist_arr[] = $this->get_lastname_by_wx_userid($tmp_tolist);
        }

        if(!empty($tmp_tolist_arr)){
            $roomname = implode(',', $tmp_tolist_arr);
        }else{
            $roomname = $tolist;
        }

        return $roomname;
    }

    /*
     * 通讯录搜索
     * */
    public function contactSearch($search)
    {
        if (!empty($search)) {
            return '';
        }

        $auto_info_json = doCorpInfo('get_auth_info','');
        $info_arr = json_decode($auto_info_json, true);
        $auth_info = $info_arr[StaticConst::$suite_crm];
        $corpid = $auth_info['auth_corp_info']['corpid'];


        $url = StaticConst::$server_api . '?action=getProvideTokenAccess';
        $url_result_json = $this->port_obj->primary_curl($url);
        $url_result_arr = json_decode($url_result_json, true);
        $provider_access_token=$url_result_arr['token'];

        $url = "https://qyapi.weixin.qq.com/cgi-bin/service/contact/search?provider_access_token=$provider_access_token";

        $post_data=array(
            'auth_corpid'=>$corpid,
            "query_word"=>$search,
            "query_type"=>1,//查询用户，返回用户userid列表
            "query_range"=>0,//查询范围，仅查询类型包含用户时有效。 0：只查询在职用户 1：同时查询在职和离职用户
            "limit"=>200,
        );

        $tmp_post_data=json_encode($post_data,JSON_UNESCAPED_UNICODE);
        $rspJson = $this->port_obj->curlPost($url,$tmp_post_data);
//        dump($rspJson);
        $rspJson = json_decode($rspJson,true);
        $wx_userid_arr = [];
        if ($rspJson['errcode'] === 0) {
            $wx_userid_arr = $rspJson['query_result']['user'];
        }
        return $wx_userid_arr;
    }

    //获取离职成员信息  格式：convertuserid=>lastname  用于左侧成员列表 显示离职成员姓名，替换fromid等
    public function getInactiveMemberlastname()
    {
        global $adb;

        $inactiveMemberData = [];
        $query = "select convertuserid,lastname from ld_wechatuserid where `status` = 'inactive' group by convertuserid";
        $result = $adb->pquery($query, array());
        $num_rows = $adb->num_rows($result);
        if ($num_rows > 0) {
            for($i = 0; $i<$num_rows; $i++){
                $convertuserid = $adb->query_result($result,$i,'convertuserid');
                $lastname = $adb->query_result($result,$i,'lastname');
                $lastname = !empty($lastname)?$lastname:getFixedLabel('UnknownName');
                $inactiveMemberData[$convertuserid] = $lastname;

            }
        }

        return $inactiveMemberData;
    }

    //获取已备注的离职成员以及在职的已备注成员     手动备注的姓名优先级高于wwopen显示的姓名时使用属性 allMemberData，否则默认使用 inactiveMemberData(中间或者右侧区块)
    public function getAllMemberlastname()
    {
        global $adb;

        $allMemberData = [];
        $query = "select convertuserid,lastname from ld_wechatuserid where `status` = 'inactive' or lastname<>'' group by convertuserid";
        $result = $adb->pquery($query, array());
        $num_rows = $adb->num_rows($result);
        if ($num_rows > 0) {
            for($i = 0; $i<$num_rows; $i++){
                $convertuserid = $adb->query_result($result,$i,'convertuserid');
                $lastname = $adb->query_result($result,$i,'lastname');
                $lastname = !empty($lastname)?$lastname:getFixedLabel('UnknownName');
                $allMemberData[$convertuserid] = $lastname;

            }
        }

        return $allMemberData;
    }

}
WechatSessionNew::require_file();

?>