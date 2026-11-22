<?php
exit();
global $currentModule, $adb;
$smarty = new lingdangCRM_Smarty;
$_REQUEST['diony'] = 'yes';
require_once(globalStatic::$root_directory . '/appCommon/appCommon.php');
require_once globalStatic::$root_directory.'modules/Users/AddressbookSync.class.php';
$model_obj = new AddressbookSync();
$model_obj->get_addressbookinfo();

//一、检查admin账号企业微信通讯录账号wx_userid是否为空
if(isset($_REQUEST['mode']) && $_REQUEST['mode']=='check'){
    unset($_SESSION['AddressbookSync']);
    $result = $adb->pquery("select wx_userid from ld_users where id=1 and IFNULL(wx_userid,'') <> ''");
    if($adb->num_rows($result) < 1){//为空时需要绑定
        //弹出“请输入admin账号需要绑定的企业微信通讯录成员姓名”弹出层
        $arr['title'] = getFixedLabel("SyncAddressbookStep1");
        $arr['oktext']=getFixedLabel("SAVE");
        $arr['canceltext']=getFixedLabel("CANCEL");
        $arr['content'] = "<div class='divPopOverflow' style='padding: 10px 20px;'><font color='red'>*</font>".getFixedLabel("Name")."<input name='admin_name' type='text' value='' tag='".getFixedLabel("Name")."' style='border:1px solid #dbdbdb;border-radius: 4px;line-height: 25px;margin-left: 15px;'></div>";
        ConvertTojsonString(1,$arr,"success");
    }else{
        //弹出“同步企业微信组织架构以“企业微信通讯录”为准，同步规则如下：
        $arr['title'] = getFixedLabel("SYNCHRONIZATIONRULES");
        $arr['oktext']=getFixedLabel("NEXT");
        $arr['canceltext']=getFixedLabel("CANCEL");
        $shtml = "<div class='divPopOverflow' style='padding: 10px 20px;'>";
        $shtml .= "<ul style=\"line-height:30px;\">
                        <li>1、".getFixedLabel("SyncAddressbookStep2")."</li>
                        <li>2、".getFixedLabel("SyncAddressbookStep2Rule1")."</li>
                        <li>3、".getFixedLabel("SyncAddressbookStep2Rule2")."</li>
                        <li>4、".getFixedLabel("SyncAddressbookStep2Rule3")."</li>
                        <li class='select-input'><input name='agree_rule' id='agree_rule' type='radio' value='yes' tag='".getFixedLabel("Name")."'>
                        <label for='agree_rule'><font color='red'>*</font>".getFixedLabel("SyncAddressbookStep2Agree")."</label></li>
                    </ul>";
        $shtml .="</div>";
        $arr['content'] = $shtml;
        ConvertTojsonString(2,$arr,"success");
    }

} elseif (isset($_REQUEST['admin_name']) && $_REQUEST['admin_name'] != '') {
    //二、检查CRM是否已存在该姓名，存在弹框提示；再判断是否存在企业微信里，不存在时提示企业微信通讯录成员姓名不存在，请重新输入！存在时更新admin的信息
    $admin_name = trim($_REQUEST['admin_name']);

    $result = $adb->pquery("select 1 from ld_users where last_name=? and user_name <> 'admin' and deleted=0",array($admin_name));
    if ($adb->num_rows($result) > 0) {
        ConvertTojsonString(-1, array(), getFixedLabel("SyncAddressbookStep1Msg2"));
    }

    $userid_name_list = $_SESSION['AddressbookSync']['UserList']['userid_name_list'];
    if(!in_array($admin_name, $userid_name_list)){
        ConvertTojsonString(-1, array(), getFixedLabel("SyncAddressbookStep1Msg1"));
    }

    $adb->pquery("update ld_users set last_name=?,wx_userid=? where id=1",array($admin_name,implode('',array_keys($userid_name_list,$admin_name))));
    ConvertTojsonString(1, array(), 'success');
}

$departmentList = [];
//开始同步部门
if ($_SESSION['AddressbookSync']['DepartmentList']['status'] === false) {//还未同步
    $departmentList = $_SESSION['AddressbookSync']['DepartmentList']['list'];
    if (!empty($departmentList)) {
//    echo "正在同步通讯录部门";
        //获取原部门信息   更新完成员之后还需要把ld_users2group数据更新
        require_once globalStatic::$root_directory.'modules/Users/Group.class.php';
        $group_focus = new Group();
        $old_groupname_arr = $group_focus->getGroupIdName();//所有的原部门
        unset($old_groupname_arr[1]);
        $_SESSION['AddressbookSync']['DepartmentList']['old_groupname_arr'] = $old_groupname_arr;
        $new_groupname_arr = array();//所有的新部门(同步部门第三步使用)

//        $adb->query("TRUNCATE ld_groups");//清空表数据
        //1、插入部门基础信息
        foreach ($departmentList as $department) {
            $parentid = $department['parentid'];
//            $parentid = $parentid == 0 ? -1:$parentid;
            $groupid = $department['id'];
            $groupname = $department['name'];
            $groupseq = $department['order'];//在父部门中的次序值。order值大的排序靠前。和系统里逻辑相反

            if ($parentid == 0) {//顶级部门，一般为企业公司名称
                $sql = "INSERT INTO ld_groups(groupid,groupname,parentid,depth,parentgroup,groupseq) VALUES(?,?,?,?,?,?) ON DUPLICATE KEY 
UPDATE groupname=?";
                $adb->pquery($sql,array($groupid,$groupname,-1,0,1,1,$groupname));
            }else{
                //存在groupid则更新，防止同步部门的时候关掉浏览器，组织被删除
                $sql = "INSERT INTO ld_groups(groupid,groupname,parentid,groupseq) VALUES(?,?,?,?) ON DUPLICATE KEY 
UPDATE groupid=VALUES(groupid),groupname=?,parentid=?,groupseq=?";
                $adb->pquery($sql,array($groupid,$groupname,$parentid,$groupseq,$groupname,$parentid,$groupseq));
            }

            $new_groupname_arr[$groupid] = $groupname;
//            $_SESSION['AddressbookSync']['DepartmentList']['new_groupname_arr'] = $new_groupname_arr;
        }

        //2、更新depth、parentgroup
        foreach ($departmentList as $department) {
            $parentid = $department['parentid'];
            $groupid = $department['id'];
            if ($parentid > 0) {
                $parentdepth = '';
                $result = $adb->pquery("select depth,parentgroup from ld_groups where groupid=?",array($parentid));//父部门depth、parentgroup
                $parentdepth = $adb->query_result($result,0,'depth');
                $parentgroup = $adb->query_result($result,0,'parentgroup');
                $adb->pquery("update ld_groups set depth=?,parentgroup=? where groupid=?",array($parentdepth+1,$parentgroup."::".$groupid,$groupid));//当前部门深度
            }
        }

        //3、crm有的部门，企业微信没有，则重新插入到ld_groups，放到组织架构的后面
        $pending_groupname_arr = array_diff($old_groupname_arr,$new_groupname_arr);
        $adb->pquery("delete from ld_groups where groupid>?",array(count($departmentList)));//超过组织架构的部门数量都删了。
        foreach ($pending_groupname_arr as $tmp_groupname) {
            $adb->query("set @groupid=(SELECT MAX(groupid) FROM ld_groups);");
            $adb->query("set @groupseq=(SELECT MIN(groupseq) FROM ld_groups where parentid = 1);");
            $sql = "INSERT INTO ld_groups(groupid,groupname,parentid,depth,parentgroup,groupseq) VALUES(@groupid+1,?,?,?,CONCAT('1::',@groupid+1),@groupseq-1000)";
            $adb->pquery($sql,array($tmp_groupname,1,1));
        }

        //4、更新 groupseq  //需要重新排序，因为接口返回的顺序是按groupid从小到大排序的，不是按照企业微信的组织顺序返回
        $result = $adb->pquery("SELECT parentid FROM ld_groups WHERE parentid <> -1 GROUP BY parentid ORDER BY parentid",array());
        $num_rows = $adb->num_rows($result);
        if ($num_rows > 0) {
            for($i = 0; $i<$num_rows; $i++){
                $parentid = $adb->query_result($result,$i,'parentid');
                $adb->query("set @i=0;");
                $adb->pquery("update ld_groups set groupseq=(@i:=@i+1) where parentid = ? ORDER BY groupseq DESC",array($parentid));
            }
        }

        unsetCache($group_focus->group_cache_key);//清除部门缓存
    }

    $_SESSION['AddressbookSync']['DepartmentList']['status'] = true;//部门同步完成
}

//开始同步成员
$userList = $_SESSION['AddressbookSync']['UserList']['list'];
if (!empty($userList)) {
//    echo "正在同步更新通讯录成员";
    if (!$_SESSION['AddressbookSync']['UserList']['end']) {
        //初始化进度条
        $totle = count($_SESSION['AddressbookSync']['UserList']['list']);
        $_SESSION['AddressbookSync']['UserList']['total'] = $totle;
        $_SESSION['AddressbookSync']['UserList']['intervalrow'] = ceil($totle/10);//向上取整
        $_SESSION['AddressbookSync']['UserList']['start'] = 0;
        $_SESSION['AddressbookSync']['UserList']['end'] = $_SESSION['AddressbookSync']['UserList']['intervalrow'];

    }else{
        $_SESSION['AddressbookSync']['UserList']['start'] = $_SESSION['AddressbookSync']['UserList']['end'];
        $_SESSION['AddressbookSync']['UserList']['end'] = $_SESSION['AddressbookSync']['UserList']['end'] + $_SESSION['AddressbookSync']['UserList']['intervalrow']; //当前处理到第几个
    }

    $start = $_SESSION['AddressbookSync']['UserList']['start'];
    $intervalrow = $_SESSION['AddressbookSync']['UserList']['intervalrow'];
    $pendingUserList = array_slice($userList,$start,$intervalrow);//待处理成员


//    $groupInfo = $_SESSION['AddressbookSync']['UserList']['groupInfo'];//给成员更新部门时array("groupid"=>"parentgroup")

    foreach ($pendingUserList as $key=>$user) {
        $wx_userid = $user['userid'];
        $last_name = $user['name'];
        $groupid = implode(',',$user['department']);
        $phone_mobile = $user['mobile'];
        $email1 = $user['email'];

        //查看用户是否存在(根据姓名)
        $result = $adb->pquery("select id from ld_users where last_name=? or wx_userid=? limit 1",array($last_name,$wx_userid));
        $focus = new Users();
        if ($adb->num_rows($result) > 0) {
            $focus->mode='edit';
            $focus->id = $adb->query_result($result,0,'id');
            $focus->retrieve_entity_info($focus->id,'Users');
            $focus->column_fields['last_name'] = $last_name;
            $focus->column_fields['wx_userid'] = $wx_userid;
            $focus->column_fields['groupid'] = $groupid;
            $focus->column_fields['phone_mobile'] = $phone_mobile;
            $focus->column_fields['email1'] = $email1;

        }else{
            $focus->mode='create';
            $focus->column_fields['last_name']=$last_name;
            $focus->column_fields['wx_userid'] = $wx_userid;
            $focus->column_fields['groupid'] = $groupid;
            $focus->column_fields['phone_mobile'] = $phone_mobile;
            $focus->column_fields['email1'] = $email1;

            //名字转拼音 做账号名
            require_once(globalStatic::$root_directory . '/crmapi/erp/cls_GetPingYing.php');
            $PingYing = new cls_GetPingYing();
            $all_py = $PingYing->get_all_py($last_name);
            $all_py = empty($all_py)?$wx_userid:implode('',$all_py);
            $focus->column_fields['user_name'] = $all_py;

            $focus->column_fields['viewothers'] = 1;
            $focus->column_fields['editothers'] = 1;
            $focus->column_fields['edit_me_mobile'] = 1;
            $focus->column_fields['accountallview'] = 1;
            $focus->column_fields['user_password']='123';
            $focus->column_fields['confirm_password']='123';
            $focus->column_fields['profileid']=$focus->getDefaultProfileid();
            $focus->column_fields['push_wx_reminds']=1;//新增用户默认开启提醒


            if ($_SESSION['AddressbookSync']['UserList']['usedCount'] < $_SESSION['AddressbookSync']['UserList']['regCount']) {
                $focus->column_fields['status']='Active';
                $focus->column_fields['approvestatus']=0;
            }else{
                $focus->column_fields['status']='Inactive';
                $focus->column_fields['approvestatus']=1;//新增用户时，审批委托应该赋值“停用”
            }
        }

        if(empty($focus->column_fields['approveby']))
            $focus->column_fields['approveby']=0;
        if(empty($focus->column_fields['scopeauthority']))
            $focus->column_fields['scopeauthority']=1;
        if(empty($focus->column_fields['level']))
            $focus->column_fields['level']=0;

        $focus->save("Users");
        if(isset($focus->column_fields['groupid']) && $focus->column_fields['groupid'] !=''){
            //更新部门信息ld_users2group
            $focus->insertUsersGroup($focus->column_fields['groupid'],$focus->id);
        }
        if($focus->mode == 'create'){
            $focus->change_password(null, '123');

            $_SESSION['AddressbookSync']['UserList']['usedCount']++;
        }

    }

    $arr['title'] = getFixedLabel("SyncAddressbookStep3");//同步企业微信通讯录部门和成员
    $arr['start'] = $start;
    $arr['end'] = $_SESSION['AddressbookSync']['UserList']['end'];
    $arr['total'] = $_SESSION['AddressbookSync']['UserList']['total'];
    $arr['percent'] = floor($arr['end']/($_SESSION['AddressbookSync']['UserList']['total'])*100);
    if ($_SESSION['AddressbookSync']['UserList']['end'] < $_SESSION['AddressbookSync']['UserList']['total']){  //还未结束
        ConvertTojsonString(2, $arr, 'success');//2 继续当前请求
    }else{
        //更新历史成员部门信息（老的部门id数据转为新的部门id数据）  老数据部门id转为对应的部门名称，再根据部门名称转为对应的新部门id
        $old_groupname_arr = (array)$_SESSION['AddressbookSync']['DepartmentList']['old_groupname_arr'];
        require_once globalStatic::$root_directory.'modules/Users/Group.class.php';
        $group_focus = new Group();
        $new_groupname_arr = $group_focus->getGroupIdName();//所有的新部门（包含CRM已有但企业微信组织架构没有的部门）
//        $new_groupname_arr = $_SESSION['AddressbookSync']['DepartmentList']['new_groupname_arr'];
        $result = $adb->pquery("select id,groupid from ld_users where ifnull(wx_userid,'')='' and ifnull(groupid,'')<>''",array());
        $num_rows = $adb->num_rows($result);
        if ($num_rows > 0) {
            for($i = 0; $i<$num_rows; $i++){
                $tmp_id = $adb->query_result($result,$i,'id');
                $tmp_old_groupid = $adb->query_result($result,$i,'groupid');
                $tmp_old_groupid_arr = explode(',',$tmp_old_groupid);
                $tmp_new_groupid_arr = [];
                foreach ($tmp_old_groupid_arr as $value) {
                    if (array_key_exists($value,$old_groupname_arr)) {
                        $tmp_old_groupname = $old_groupname_arr[$value];
                        if (in_array($tmp_old_groupname,$new_groupname_arr)) {//老的部门名称在新的部门名称里，则取新的部门id
                            array_push($tmp_new_groupid_arr,implode(',',array_keys($new_groupname_arr,$tmp_old_groupname)));
                        }
                    }
                }
                $tmp_new_groupid = implode(',',$tmp_new_groupid_arr);
                if (!empty($tmp_new_groupid) && $tmp_new_groupid != $tmp_old_groupid) {
                    $adb->pquery("update ld_users set groupid=? where id = ?",array($tmp_new_groupid,$tmp_id));
                    $focus = new Users();
                    $focus->insertUsersGroup($tmp_new_groupid,$tmp_id);
                }


            }
        }

        unset($_SESSION['AddressbookSync']);
        ConvertTojsonString(1, $arr, 'success');// 已结束
    }

}else{
    unset($_SESSION['AddressbookSync']);
    ConvertTojsonString(-1, $arr, getFixedLabel("SyncAddressbookStep3Msg1"));//企业微信没有需要同步的成员
}


?>