<?php

/**
 * Created by PhpStorm.
 * User: Administrator
 * Date: 2017/12/22 0022
 * Time: 下午 5:22
 */
class EventToApiModel
{
    public $m_rootdir;
    public $m_adb;
    public $progress_total=0;
    public $progress_step;
    public $progress_i=0;
    public $progress_width=1;
    public $progress_num=array('newcontact'=>0,'newaccount'=>0,'updatecontact'=>0);
    public $end_progress = '';
    public $wxselfbuilt_obj;

    public function __construct()
    {
        $this->m_rootdir = dirname(dirname(dirname(__FILE__))) . '/';
        include_once($this->m_rootdir . '/appCommon/appCommon.php');

        crm_load_class_file("cls_WeiXinSelfBuiltApp", 'WeiXinApp/WeiXin_common');
        $this->wxselfbuilt_obj = new cls_WeiXinSelfBuiltApp();
    }

    public function setAdb($rAdb)
    {
        $this->m_adb = $rAdb;
    }
    //控制面板-注销企业微信
    public function uninstallInCRM()
    {
        global $adb, $current_user;
        $exist_auth_arr = judgeCorpInfo('install_app');
        if ($exist_auth_arr) {
            //获取操作人信息
            $SQL = 'SELECT last_name,phone_mobile,email1 from ld_users WHERE id=' . $current_user->id;
            $result = $adb->pquery($SQL, array());
            $num_rows = $adb->num_rows($result);
            if ($num_rows > 0) {
                $userinfo['name'] = $adb->query_result($result, 0, 'last_name');
                $userinfo['mobile'] = $adb->query_result($result, 0, 'phone_mobile');
                $userinfo['email'] = $adb->query_result($result, 0, 'email1');
            }
            $userinfojson = json_encode($userinfo);
            //向API传递动作信息
            include(globalStatic::$root_directory . 'WeiXinApp/WeiXin_common/StaticConst.php');
            include(globalStatic::$root_directory . 'WeiXinApp/WeiXin_common/cls_WeixinPort.php');
            $o_port = new cls_WeixinPort();
            $corpid = $exist_auth_arr['crm']['auth_corp_info']['corpid'];
            $url = StaticConst::$server_api . '?action=uninstall_crm&corpid=' . $corpid . '&userinfo=' . $userinfojson;
            $result = $o_port->primary_curl($url);
            $kehu001 = judgeCorpInfo('kehu001');
            doCorpInfo('uninstall',$kehu001);//gyqX20180312
            //exec('rm -Rf '.globalStatic::$root_directory . 'dataCache/weixin/auth_gyq_info.txt');D:\wamp\www\ldcrm\WeiXinApp\lib\EventToApiModel.php
            ConvertTojsonString(1, array(), $mail_status);
        } else {
            ConvertTojsonString(-1, array(), 'fail:empty cache');
        }
    }
    //通讯录选人,按部门选择，返回部门内的成员ID
    public function get_department_detail($r_departid){
        //向API传递动作信息
        require_once(globalStatic::$root_directory . 'WeiXinApp/WeiXin_common/cls_WeixinPort.php');
        $o_port = new cls_WeixinPort();
        $exist_auth_arr = judgeCorpInfo('install_app');
        $corpindex = $exist_auth_arr['crm']['corpindex'];
        $url = StaticConst::$server_api . '?action=get_department_detail&corpindex='.$corpindex.'&departid='.$r_departid;
        $result = $o_port->primary_curl($url);
        echo $result;
        exit;
    }
    //外部联系人选择界面，提供前端config四个参数 editor:gyq_71 reason:外部联系人2.0 2018/6/20 17:33
    public function select_external_contact(){
        //向API传递动作信息
        $authinfo_json = doCorpInfo('get_auth_info',array());
        $authinfo_arr = json_decode($authinfo_json,true);
        $corpid = $authinfo_arr['crm']['auth_corp_info']['corpid'];
        require_once(globalStatic::$root_directory . 'WeiXinApp/WeiXin_common/cls_WeixinPort.php');
        $o_port = new cls_WeixinPort();
        $url = StaticConst::$server_api_header . 'server.php?action=select_external_contact&corpid='.$corpid;
        $result = $o_port->primary_curl($url);
        echo $result;
        exit;
    }
    public function get_externalContactList(){
		include(globalStatic::$root_directory.'WeiXinApp/WeiXin_common/cls_StaticCommonFun.php');
        $authinfo_json = doCorpInfo('get_auth_info',array());
        $authinfo_arr = json_decode($authinfo_json,true);
        $corpid = $authinfo_arr['crm']['auth_corp_info']['corpid'];
        global $adb;
        $sql = 'select id,user_name,last_name,wx_userid from ld_users where wx_userid <> \'\'';
        $result = $adb->pquery($sql,array());
        $nums = $adb->num_rows($result);
        if($nums > 0){
            $wxuserid_arr = array();
            $userid_arr = array();
            $user_permit_str = cls_StaticCommonFun::isExternalContactUser();
            $user_permit_list = explode(',',$user_permit_str);

            for($i=0;$i<$nums;$i++){
                $temp_wxuserid = $adb->query_result($result,$i,'wx_userid');
                $temp_userid = $adb->query_result($result,$i,'id');
                if(in_array($temp_userid,$user_permit_list)){
                    $wxuserid_arr[] = $temp_wxuserid;
                    $userid_arr[$temp_wxuserid] = $temp_userid;
                }
            }
            $wxuseridlist = implode(';',$wxuserid_arr);
            require_once(globalStatic::$root_directory . 'WeiXinApp/WeiXin_common/cls_WeixinPort.php');
            $o_port = new cls_WeixinPort();
            //editor:gyq_131 reason:企业微信新增服务商  2019/8/2 10:00
            $url = StaticConst::$server_api_header . 'server.php?action=get_external_contact_list&corpid='.$corpid.'&userids='.$wxuseridlist;
            $result = json_decode($o_port->primary_curl($url),true);
            //ob_clean();
            //file_put_contents('A20190103.txt',json_encode($result));
            /*$jsonresult = file_get_contents('A20190103.txt');
            $result = json_decode($jsonresult,true);*/
            if($result['code']==1){
                $contact_list = $result['result']['contact'];
            }
        }
        return $contact_list;
        
    }
    //获取系统用户信息缓存
    public function get_userinfo_session(){
        global $adb;
        include(globalStatic::$root_directory.'WeiXinApp/WeiXin_common/cls_StaticCommonFun.php');
        //缓存中没有数据则添加缓存
        if(sizeof($_SESSION['exteral_contact']['wx_userid'])<=0){
            $sql = 'select ld_users.id,user_name,ld_users.last_name,ld_users.wx_userid,lastimportdate,ld_historyexterncontact.status from ld_users 
                left join ld_historyexterncontact on ld_users.wx_userid = ld_historyexterncontact.Wx_userid 
                where ld_users.wx_userid <> \'\' ORDER BY ld_users.id' ;
            $result = $adb->pquery($sql,array());
            $nums = $adb->num_rows($result);
            if($nums > 0){
                $wxuserid_arr = array();
                $userid_arr = array();
                $user_permit_str = cls_StaticCommonFun::isExternalContactUser();
                $user_permit_list = explode(',',$user_permit_str);
                for($i=0;$i<$nums;$i++){
                    $temp_wxuserid = $adb->query_result($result,$i,'wx_userid');
                    $temp_userid = $adb->query_result($result,$i,'id');
                    $temp_last_name = $adb->query_result($result,$i,'last_name');
                    $temp_lastimportdate = $adb->query_result($result,$i,'lastimportdate');//最新导入时间
                    $status = $adb->query_result($result,$i,'status');
                    if(in_array($temp_userid,$user_permit_list)){
                        $_SESSION['exteral_contact']['wx_userid'][]=$temp_wxuserid;
                        $_SESSION['exteral_contact']['userid'][$temp_wxuserid] = $temp_userid;
                        $_SESSION['exteral_contact']['username'][$temp_wxuserid] = $temp_last_name;
                        if(!empty($temp_lastimportdate)&& $status == 'yes'){
                            $_SESSION['exteral_contact']['lastimportdate'][$temp_wxuserid]=$temp_lastimportdate;
                        }
                    }
                }
            }
        }
    }
    //批量获取外部联系人信息
    public function get_external_contact_list(){
        //读取缓存
        $this->get_userinfo_session();
        $wxuserid_arr = $_SESSION['exteral_contact']['wx_userid'];
        $userid_arr = $_SESSION['exteral_contact']['userid'];
        $username_arr = $_SESSION['exteral_contact']['username'];
        //传输参数
        $wxuserid_last = $_REQUEST['wxuserid_last'];
        $next_cursor = $_REQUEST['next_cursor'];
        $contact_listlen = $_REQUEST['maxrows'];
        //传输上次执行的结果
        $end_progress = $_REQUEST['end_progress'];
        if(!empty($_REQUEST['progress_i'])){
            $this->progress_i = $_REQUEST['progress_i'];
        }
        if(!empty($_REQUEST['progress_total'])){
            $this->progress_total = $_REQUEST['progress_total'];
        }
        if(!empty($_REQUEST['progress_num'])){
            $this->progress_num = $_REQUEST['progress_num'];
        }
        if(!empty($_REQUEST['progress_width'])){
            $this->progress_width = $_REQUEST['progress_width'];
        }
        if(!empty($_REQUEST['index_now'])){
            $index_now = $_REQUEST['index_now'];
        }else{
            $index_now = 0;
        }
        if($end_progress=='yes'||$index_now==0){
            unset($_SESSION['exteral_contact']['contact_info_arr']);
            $index_now=0;
        }
        
        $intervalrow = 10;
        $max_intervalrow = 100;
        $wxuserid = $wxuserid_last;
        $curosr = $next_cursor;
            //缓存外部联系人信息
            
        if(!$_SESSION['exteral_contact']['contact_info_arr']){
            //获取本次查询信息
            $curosr = "";
            if(empty($wxuserid_last)){
                $wxuserid = $wxuserid_arr[0];
            }else if(empty($next_cursor)|| $end_progress == 'yes'){ //上一次查询结束后切换下一个用户 
                $userid_count = array_search($wxuserid_last,$wxuserid_arr)+1;
                if($userid_count == sizeof($wxuserid_arr)){//查询结束
                    if($this->progress_total==0){
                        return -1;
                    }else{
                        return 0;
                    }
                }
                $wxuserid = $wxuserid_arr[$userid_count];
            }else{
                $wxuserid = $wxuserid_last;
                $curosr = $next_cursor;   //批量查询外部联系人的游标
            }

            if ($this->wxselfbuilt_obj->installWXSelfBuilt) {
                $result = $this->wxselfbuilt_obj->get_external_contact_list($wxuserid,$this->wxselfbuilt_obj->corpid,$curosr,$max_intervalrow);
            }else{
                $authinfo_json = doCorpInfo('get_auth_info',array());
                $authinfo_arr = json_decode($authinfo_json,true);
                $corpid = $authinfo_arr['crm']['auth_corp_info']['corpid'];
                require_once(globalStatic::$root_directory . 'WeiXinApp/WeiXin_common/cls_WeixinPort.php');
                $o_port = new cls_WeixinPort();
                //editor:gyq_131 reason:企业微信新增服务商  2019/8/2 10:00
                $url = StaticConst::$server_api_header . 'server.php?action=get_external_contact_list&corpid='.$corpid;
                $url .= '&userid='.$wxuserid.'&curosr='.$curosr.'&intervalrow='.$max_intervalrow;

                $result = json_decode($o_port->primary_curl($url),true);
            }


            if(empty($next_cursor)|| $end_progress == 'yes'){//第一次读取时返回客户列表
                $contact_listlen =  sizeof($result['result']['contact']['contact_listlen']['external_userid']);//api请求结果
                //读取客户列表数量为空时直接返回
                if($contact_listlen<=0){    
                    //过程参数传输
                    //通用参数传输
                    $_REQUEST['diony']='diony';
                    $arr['title'] = getFixedLabel('ImportExternalContacts');
                    $arr['cur_user'] = array_search($wxuserid,$wxuserid_arr)+1;
                    $arr['all_usernum'] = sizeof($wxuserid_arr);
                    $arr['wxuserid_last'] = $wxuserid;
                    $arr['username'] = $username_arr[$wxuserid];
                    $arr['progress_i'] = $this->progress_i;
                    $arr['progress_total'] = $this->progress_total;
                    $arr['progress_num'] = $this->progress_num;
                    $arr['intervalrow_last'] = $intervalrow;
                    $arr['next_cursor'] = "";
                    $arr['maxrows'] = $contact_listlen;
                    $arr['index_now'] = $index_now;
                    ConvertTojsonString(1,$arr,"success");
                    exit();
                }
                $contact_info_arr =  $result['result']['contact']['contactinfo'];
                $this->progress_total += $contact_listlen;
            }else{
                $contact_info_arr = $result['result']['contact']['contactinfo'];;
            }
            $_SESSION['exteral_contact']['contact_info_arr']= $contact_info_arr;
        }else{
            $contact_info_arr = $_SESSION['exteral_contact']['contact_info_arr'];
        }
        //通用参数传输
        
        //下一次读取的数量
        $index_next = $index_now+$intervalrow;
        $length=sizeof($contact_info_arr['external_contact_list']);
        if($index_next >= $length){ //游标大于等于本组数据长度时重置，读取下一组数据
            $index_next =0;
            $intervalrow = $length - $index_now;
            unset($_SESSION['exteral_contact']['contact_info_arr']);
        }
        $contact_info = array_slice($contact_info_arr['external_contact_list'],$index_now,$intervalrow);
        //插入联系人记录
        $this->insert_contact_record_new($contact_info,$userid_arr[$wxuserid],$wxuserid,$curosr,$contact_info_arr['next_cursor']);
        //传输过程参数
        
        $_REQUEST['diony']='diony';
        $arr['title'] = getFixedLabel('ImportExternalContacts');
        $arr['cur_user'] = array_search($wxuserid,$wxuserid_arr)+1;
        $arr['all_usernum'] = sizeof($wxuserid_arr);
        $arr['wxuserid_last'] = $wxuserid;
        $arr['username'] = $username_arr[$wxuserid];
        $arr['end_progress'] = $this->end_progress;
        $arr['progress_i'] = $this->progress_i;
        $arr['progress_total'] = $this->progress_total;
        $arr['progress_num'] = $this->progress_num;
        $arr['intervalrow_last'] = $intervalrow;
        $arr['next_cursor'] = $contact_info_arr['next_cursor'];
        $arr['maxrows'] = $contact_listlen;
        $arr['index_now'] = $index_next;
        ConvertTojsonString(1,$arr,"success");
        exit();
    }
    
	//获取外部联系人的标签
    public function get_contact_corp_tag($wxuserid) {
        require_once(globalStatic::$root_directory . 'WeiXinApp/WeiXin_common/cls_WeixinPort.php');
		$o_port = new cls_WeixinPort();
		$contact_tag = [];
		$authinfo_json = doCorpInfo('get_auth_info',array());
		$authinfo_arr = json_decode($authinfo_json,true);
		$corpid = $authinfo_arr['crm']['auth_corp_info']['corpid'];
		$url = StaticConst::$server_api_header . 'server.php?action=get_external_contact_tag&corpid='.$corpid.'&userids='.$wxuserid;
		$result = json_decode($o_port->primary_curl($url),true);
		if(!empty($result)){
			$contact_tag = $result['result']['contact_tag'];
		}
		return $contact_tag;
    }
    //循环从api获取的外部联系人信息，更新系统联系人信息
    public function insert_contact_record_new($contact_list,$r_userid,$wxuserid,$curosr,$next_cursor){
        global $adb;
        $lastimportdate = $_SESSION['exteral_contact']['lastimportdate'][$wxuserid];
        $contact_listlen = sizeof($contact_list);
        if ($this->wxselfbuilt_obj->installWXSelfBuilt) {
            $all_contact_tag = $this->wxselfbuilt_obj->get_contact_corp_tag();
        }else{
            $all_contact_tag = $this->get_contact_corp_tag($wxuserid);
        }
        for($i=$contact_listlen-1;$i>=0;$i--){
            $value = $contact_list[$i];
            $external_contact = $value['external_contact'];
			$tag_id = $value['follow_info']['tag_id'];
            $creatime = $value['follow_info']['createtime'];
            //存在时间小于上次导入时间的记录，则停止批量读取
            if(!empty($lastimportdate)&&$creatime-strtotime($lastimportdate)<=0){
                $this->end_progress = 'yes';
                continue;
            }
            
            $this->progress_i++;
            /*$focus = CRMEntity::getInstance($contactmodule);
            $focus->id=0;
            $focus->column_fields['account_id']=0;
            $focus->column_fields['reference']=0;*/
            $external_userid = $external_contact['external_userid'];
            $name = $external_contact['name'];
            $corp_name = $external_contact['corp_name'];

//            @edit:liushuai,2021-06-23,reason:通过获取外部联系人详情接口新增客户和联系人时，调用统一接口
            crm_load_class_file("WeiXinPortContacts", 'crmapi/WeiXinPort');
            $WeixinPortContactsObj = new WeiXinPortContacts();
            $WeixinPortContactsObj->setSmownerID($r_userid);
            $WeixinPortContactsObj->setWeixinExternalUserid($external_userid);
            $WeixinPortContactsObj->setLastname($name);
			$WeixinPortContactsObj->setCorpTag($tag_id,$all_contact_tag);
            $WeixinPortContactsObj->insert_contact_record($external_contact['type'],$corp_name,$external_contact['corp_full_name']);
            if ($WeixinPortContactsObj->mode == 'update'){
                $this->progress_num['updatecontact']++;
            } else {
                $this->progress_num['newcontact']++;
            }
            if($WeixinPortContactsObj->newaccount == 'yes'){
                $this->progress_num['newaccount']++;
            }
        }
        if(empty($curosr)&&!$_SESSION['exteral_contact']['createtime'][$wxuserid]){//只有第一次批量读取时更新导入时间
            $_SESSION['exteral_contact']['createtime'][$wxuserid]=$creatime;
        }
        //如果当前外部联系人信息未导入过
        if($this->end_progress != 'yes'){
            //会话存档客户外部联系人信息缓存
            if(!empty($_REQUEST['wechatsession'])&&$_REQUEST['wechatsession']=='yes'){
                if(!$_SESSION['WechatSession_syncName']['external_contact_list']){
                    $_SESSION['WechatSession_syncName']['external_contact_list'] = $contact_list;
                }else{
                    $external_contact_list = $_SESSION['WechatSession_syncName']['external_contact_list'];
                    $_SESSION['WechatSession_syncName']['external_contact_list'] = array_merge($external_contact_list,$contact_list);
                }
            }
        }
        
        //提前结束导入时设置已完成,如果当前是最后一批数据，则更新status为yes
        if(empty($next_cursor)||$this->end_progress == 'yes'){
            $status = 'yes';
        }else{
            $status = 'no';
        }
        $creatime_max = $_SESSION['exteral_contact']['createtime'][$wxuserid];
        if(!isset($num_rows)||$num_rows<=0){
            $select_sql = "select * from ld_historyexterncontact where Wx_userid = ? ";
            $result = $adb->pquery($select_sql,array($wxuserid));
            $num_rows = $adb->num_rows($result);       
        }   
        if($num_rows>0){
            $update_sql = "update ld_historyexterncontact set lastimportdate = ?,status = ? where Wx_userid = ? ";
            $adb->pquery($update_sql,array(date("Y-m-d H:i:s",$creatime_max),$status,$wxuserid));
        }else{
            $insert_sql = "insert into ld_historyexterncontact(lastimportdate,Wx_userid,status) values(?,?,?)";
            $adb->pquery($insert_sql,array(date("Y-m-d H:i:s",$creatime_max),$wxuserid,$status));
        }
    }
   
    //获取外部联系人详情
    public function get_external_contact($r_userids){
        global $adb,$PlatformMC,$current_user;
        if ($this->wxselfbuilt_obj->installWXSelfBuilt) {
            $result_arr = $this->wxselfbuilt_obj->get_external_contact($r_userids);
        }else{
            //TXT缓存读取企业号ID
            $authinfo_json = doCorpInfo('get_auth_info',array());
            $authinfo_arr = json_decode($authinfo_json,true);
            $corpid = $authinfo_arr['crm']['auth_corp_info']['corpid'];
            //CURL调用接口
            require_once(globalStatic::$root_directory . 'WeiXinApp/WeiXin_common/cls_WeixinPort.php');
            $o_port = new cls_WeixinPort();
            $url = StaticConst::$server_api_header . 'server.php?action=get_external_contact&userids='.$r_userids.'&corpid='.$corpid;
            $result_arr = json_decode($o_port->primary_curl($url),true);
        }

        $contact_list = $result_arr['result']['contact'];
//        $contactmodule = 'Contacts';
        $number_insert = 0;
        $number_update = 0;
        //循环接口返回的外部联系人详情列表
        crm_load_class_file("WeiXinPortContacts", 'crmapi/WeiXinPort');
        foreach ($contact_list as  $key=>$value){
//            $focus = CRMEntity::getInstance($contactmodule);
            $external_userid = $value['external_userid'];
            $name = $value['name'];
            $corp_name = $value['corp_name'];
            /*$mobiles = '';
            foreach ($value['follow_user'] as $followkey=>$followvalue){
                if($followvalue['userid']==$PlatformMC['userid']){
                    if(!empty($followvalue['remark_mobiles']))
                        $mobiles = implode(',',$followvalue['remark_mobiles']);
                    if(!empty($followvalue['remark_company']))
                        $corp_name = $followvalue['remark_company'];
                    $description = $followvalue['description'];
                    break;
                }
            }*/

            //@edit:liushuai,2021-06-23,reason:通过获取外部联系人详情接口新增客户和联系人时，调用统一接口
            
            $WeixinPortContactsObj = new WeiXinPortContacts();
            $WeixinPortContactsObj->setSmownerID($current_user->id);
            $WeixinPortContactsObj->setWeixinExternalUserid($external_userid);
            $WeixinPortContactsObj->setLastname($name);
            $WeixinPortContactsObj->insert_contact_record($value['type'],$corp_name,$value['corp_full_name']);
            if ($WeixinPortContactsObj->mode == 'update')
                $number_update++;
            else
                $number_insert++;

            /*//判断是否存在外部联系人对应的联系人，且未被删除
            $SQL = 'SELECT lastname,contactid,accountid from ld_contactdetails WHERE weixin_external_userid=\'' . $external_userid.'\' and deleted=0';
            $result = $adb->pquery($SQL, array());
            $num_rows = $adb->num_rows($result);
            if($num_rows > 0){
                //存在则更新联系人名称
                $accountid  = $adb->query_result($result,0,'accountid');
                $SQL = 'update ld_contactdetails set lastname=\''.$name.'\',mobile=? WHERE weixin_external_userid=\'' . $external_userid.'\' and deleted=0';
                $result = $adb->pquery($SQL, array($mobiles));
                $SQL = 'update ld_account set accountname=\''.$corp_name.'\' where accountid=?';
                $result = $adb->pquery($SQL, array($accountid));
                $number_update++;
            }else{
                //不存在，新增联系人
                $focus->column_fields['lastname'] = $name;
                //负责人为当前用户
                $focus->column_fields['assigned_user_id'] = $current_user->id;
                $focus->column_fields['mobile'] = $mobiles;
                $focus->column_fields['description'] = $description;
                if(!empty($corp_name)){
                    //判断外部联系人详情的企业名称是否对应CRM客户
                    $SQL = 'SELECT accountid from ld_account WHERE accountname=\'' . $corp_name.'\'  order by modifiedtime desc';
                    $result = $adb->pquery($SQL, array());
                    $num_rows = $adb->num_rows($result);

                    if($num_rows > 0){
                        $account_id  = $adb->query_result($result,0,'accountid');
                        $focus->column_fields['account_id'] = $account_id;
                    }else{
                        //不存在，新增客户
                        $accountmodule = 'Accounts';
                        $account_focus = CRMEntity::getInstance($accountmodule);
                        $account_focus->column_fields['accountname'] = $corp_name;
                        $account_focus->column_fields['servicecasher'] = $current_user->id;//服务收费人
                        $account_focus->column_fields['assigned_user_id'] = $current_user->id;
                        $account_focus->save($accountmodule);
                        $account_id = $account_focus->id;
                        $focus->column_fields['account_id'] = $account_id;
                    }
                }
                $focus->save($contactmodule);
                //更新联系人的外部联系人ID
                $SQL = 'update ld_contactdetails set weixin_external_userid=\''.$external_userid.'\' WHERE contactid='.$focus->id;
                $result = $adb->pquery($SQL, array());
                $number_insert++;
            }*/
        }
        //生成结果提示页内容
        //gyq_20190228 0036244: （企业微信）导入企业微信客户后，弹出的温馨提示“外部联系人”应该修改为“企业微信客户”
        $userid_arr = explode(';', rtrim($r_userids,';'));
        $fail_number = count($userid_arr)-count($contact_list);
        $message[] = '共选择'.count($userid_arr).'条企业微信客户';
        if($number_update > 0)
            $message[] =  '成功覆盖'.$number_update.'条企业微信客户';
        if($number_insert > 0)
            $message[] =  '成功导入'.$number_insert.'条企业微信客户';
        if($fail_number > 0)
            $message[] =   '同步失败'.$fail_number.'条企业微信客户';

        ConvertTojsonString(1,array('list'=>$message),'success');
    }
    
    
}
