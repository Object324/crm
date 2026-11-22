<?php

/**
 *整理CommonUtils.php 中 【成员信息】/【部门信息】 相关的方法到这里  zxm 20221125
 */
class UsersUtils {
    public function  getUserlastName($user){
        global $adb;
        static $static_wx_lastName;
        require_once(globalStatic::$root_directory.'appCommon/appCommon.php');
        if(isKehu001ServerPc()=='yes'){
            if(!is_array($static_wx_lastName)){
                $static_wx_lastName=array();
            }
            else if($user->id>0&&array_key_exists($user->id,$static_wx_lastName))
            {
                return $static_wx_lastName[$user->id];
            }

            if($user->wx_userid==''&&$user->id>0){
                $sql='select wx_userid from ld_users where id=?';
                $result=$adb->pquery($sql,array($user->id));
                $user->wx_userid=$adb->query_result($result,0,'wx_userid');
            }
            if($user->wx_userid==''){
                if($user->id>0)
                    $static_wx_lastName[$user->id]=$user->last_name;
                return  $user->last_name;
            }
            
            $str='<ww-open-data type="userName" name="wxopendata" openid="'.$user->wx_userid.'"></ww-open-data>';
             
            //edit: xll 2023/03/28 BUG0063489 销售目标，树状图表，下载后的图片上没有显示组织架构和姓名（所有账套打补丁） 
            ///$str = getUserRealNameBywxuserid($user->wx_userid);
            
            $static_wx_lastName[$user->id]=$str;
            return $str;
        }else{
            return $user->last_name;
        }
    }
    //duan 通过wxuserid获取用户真实姓名
    public function  getUserRealNameBywxuserid($wxuserid){
        global $adb;
        static $static_realname_arr;
        if(!is_array($static_realname_arr))
        {
            $static_realname_arr=[];
        }
        if(array_key_exists($wxuserid.'aaa',$static_realname_arr))
        {
            return $static_realname_arr[$wxuserid.'aaa'];
        }
        $sql='select real_name from ld_users where wx_userid=?';
        $result=$adb->pquery($sql,array($wxuserid));
        $static_realname_arr[$wxuserid.'aaa']=$adb->query_result($result,0,'real_name');
        return  $static_realname_arr[$wxuserid.'aaa'];
    }
    //获取用户真实姓名
    public function  getUserRealName($id){
        global $adb;
        static $static_realname_arr;
        if(!is_array($static_realname_arr))
        {
            $static_realname_arr=[];
        }
        if(array_key_exists($id.'aaa',$static_realname_arr))
        {
            return $static_realname_arr[$id.'aaa'];
        }
        if(isKehu001ServerPc()=='yes'){
            $sql='select real_name from ld_users where id=?';

            $result=$adb->pquery($sql,array($id));
            $static_realname_arr[$id.'aaa']=$adb->query_result($result,0,'real_name');
            return  $static_realname_arr[$id.'aaa'];
        }
    }
    //公共方法：获取部门名称 --CommonUtils.php中的getGroupName_new方法
    public function getGroupName($ids){
        global $adb;
        $query = 'select groupid,groupname from ld_groups where groupid in ('.$ids.')';
        $result = $adb->pquery($query,array());
        $num_rows = $adb->num_rows($result);
        if($num_rows > 0){
            require_once( globalStatic::$root_directory.'modules/Users/Group.class.php');
            $groupobj = new Group();
            $data = array();
            for($i = 0; $i < $num_rows; $i++){
                $groupid = $adb->query_result($result,$i,'groupid');
                $groupname = $adb->query_result($result,$i,'groupname');
                $groupobj->groupid=$groupid;
                $groupobj->groupname=$groupname;
                $data[] = getWx_GroupName($groupobj);
            }
            return implode('、',$data);
        }
        return $ids;
    }

    public function getGroupRealName($id)
    {
        global $adb;
        static $static_realgroupname_arr;
        if(!is_array($static_realgroupname_arr))
        {
            $static_realgroupname_arr=[];
        }
        if(array_key_exists($id.'aaa',$static_realgroupname_arr))
        {
            return $static_realgroupname_arr[$id.'aaa'];
        }
        if(isKehu001ServerPc()=='yes'){
            $sql='select realgroupname,groupid from ld_groups where groupid=?';
            $result=$adb->pquery($sql,array($id));
            //zxm 签到统计表导出 图片导出慢 adb出问题 导致result是false 这里重新new一下adb
            if($adb->num_rows($result)<=0)
            {
                $adb=new PearDatabase();
                $sql='select realgroupname,groupid from ld_groups where groupid=?';
                $result=$adb->pquery($sql,array($id));
            }
            $static_realgroupname_arr[$id.'aaa']=$adb->query_result($result,0,'realgroupname');
            return  $static_realgroupname_arr[$id.'aaa'];
        }
    }
    public function getWxMobileRemindInfo($user){
        global $adb;
        static $remind_static_wx_lastName;
        if(isKehu001ServerPc()=='yes'){
            if(!is_array($remind_static_wx_lastName)){
                $remind_static_wx_lastName=array();
            }else if($user->id>0&&array_key_exists($user->id,$remind_static_wx_lastName))
            {
                return $remind_static_wx_lastName[$user->id];
            }

            if($user->wx_userid==''&&$user->id>0){
                $sql='select wx_userid from ld_users where id=?';
                $result=$adb->pquery($sql,array($user->id));
                $user->wx_userid=$adb->query_result($result,0,'wx_userid');
            }
            if($user->wx_userid==''){
                if($user->id>0)
                    $remind_static_wx_lastName[$user->id]=$user->last_name;
                return  $user->last_name;
            }
            $str='$userName='.$user->wx_userid.'$';
            $remind_static_wx_lastName[$user->id]=$str;
            return $str;
        }else{
            return $user->last_name;
        }
    }
    /**
     * Get the user full name by giving the user id.   This method expects the user id
     * DG 30 Aug 2006
     */
    public function getUserFullName($userid) {
        /**
         * @project PROT58 速度优化：缓存
         * @author Tujt 2014-07-30
         */
         static $static_userfull_name_arr;
         $key=$userid.'aa';
         if(is_array($static_userfull_name_arr)&&array_key_exists($userid.'aa',$static_userfull_name_arr))
         {
            return $static_userfull_name_arr[$key];
            
         }
         if(!is_array($static_userfull_name_arr))
         {
            $static_userfull_name_arr=[];
         }
        $user_name = '';
        if(file_exists(globalStatic::$root_directory."user_privileges/user_privileges_$userid.php"))
        {
            $tmpuser=new Users();
            $tmpuser->id=$userid;
            $user_info=	getuserInfoByPrivileges($tmpuser);
            $user_name=$user_info['last_name'];
            if(array_key_exists($wx_userid,$user_info))
                $wx_userid=$user_info['wx_userid'];
            else
                $wx_userid='';
        }
        else
        {
            global $adb;
            $sql='select last_name,wx_userid from ld_users where id=?';
            $result=$adb->pquery($sql,array($userid));
            $wx_userid='';
            if($adb->num_rows($result)>0)
            {
                $user_name=$adb->query_result($result,0,0);
                $wx_userid=$adb->query_result($result,0,'wx_userid');

            }
        }
        $userobj=new Users();
        $userobj->last_name=$user_name;
        $userobj->wx_userid=$wx_userid;
        $userobj->id=$userid;
        $static_userfull_name_arr[$key]= $this->getUserlastName($userobj);
        return $static_userfull_name_arr[$key];
        
    }
    public function getGroupFullName($groupid){
        global $adb;
        $group_name = '';
        $sql='select groupname from ld_groups where groupid=?';
        $result=$adb->pquery($sql,array($groupid));
        if($adb->num_rows($result)>0)
        {
            $group_name=$adb->query_result($result,0,0);
        }
        require_once(globalStatic::$root_directory.'modules/Users/Group.class.php');
        $groupobj=new Group();
        $groupobj->groupid=$groupid;
        $groupobj->groupname=$group_name;
        return getWx_GroupName($groupobj);
    }
    public function UserCount() {
        global $adb;
        $result = $adb->pquery("select * from ld_users where deleted =0", array());
        $user_count = $adb->num_rows($result);
        $result = $adb->pquery("select * from ld_users where deleted =0 AND is_admin != 'on'", array());
        $nonadmin_count = $adb->num_rows($result);
        $admin_count = $user_count - $nonadmin_count;
        $count = array('user' => $user_count, 'admin' => $admin_count, 'nonadmin' => $nonadmin_count);
        return $count;
    }
    public function getUserslist($setdefval = true) {
        global  $current_user, $currentModule, $adb;
        $ScopOfAuthority = ScopOfAuthority::getInstance($adb,$currentModule);
        if (is_admin($current_user) == false && ($ScopOfAuthority->getModuleShareInfo() == SHARE_PRIVATE or $ScopOfAuthority->getModuleShareInfo() == SHARE_PUBLIC_READONLY)) {
            $users_combo = get_select_options_array(get_user_array(FALSE, "Active", $current_user->id, 'private'), $current_user->id);
        } else {
            $users_combo = get_select_options_array(get_user_array(FALSE, "Active", $current_user->id), $current_user->id);
        }
        if(!empty($users_combo)){
            foreach ($users_combo as $userid => $value) {
                foreach ($value as $username => $selected) {
                    if ($setdefval == false) {
                        $change_owner .= "<option value=$userid>" . $username . "</option>";
                    } else {
                        $change_owner .= "<option value=$userid $selected>" . $username . "</option>";
                    }
                }
            }
        }
        return $change_owner;
    }
    //获取权限下所有的启用用户
    public function getProfileForUsers($profile){
        global $adb;
        $query = "select GROUP_CONCAT(id) as a from ld_users where profileid in (".$profile.") and `status` = 'Active'";
        $result = $adb->pquery($query,array());
        if($adb->num_rows($result) >= 1){
            return $adb->query_result($result,0,0);
        }
        return 0;
    }
    /**
     * edit:yangliu
     * reason: 控制面板》操作日志、登录日志界面中，选择用户下拉框增加 模糊查找功能
     * */
    public function getUserslistSearch(){
        global $current_user, $module, $adb, $assigned_user_id;
        if (is_admin($current_user) == false) {
            $user_array=get_user_array(FALSE, "Active", $current_user->id, 'private');
            $users_combo = get_select_options_array($user_array, $current_user->id);
        } else {
            $user_array=get_user_array(FALSE, "Active", $current_user->id);
            $users_combo = get_select_options_array($user_array, $current_user->id);
        }
        return $users_combo;
    }
    //获取模块负责人字段翻译 2017-10-18
    public function getSmownerTranslate($module){
        if(!empty($module)){
            $focus =  CRMEntity::getInstance($module);
            $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey('columnname',$focus->getSmownerColumName());
            if(!empty($fieldinfo)){
                return	$fieldinfo->getFieldLabel();
            }
        }
        return '';
    }
    /**
     * @edit:chj
     * @date:2014-10-20
     * @reason:获取用户对当前仓库是否拥有使用权限
     * @description:
     */
    public function getWareHouseUser($userid,$wareid)
    {
        global $adb;
        $query = "
		select id from (
			SELECT 
				ld_warehouse.id, 
				ld_warehouse.`name`
			FROM 
			ld_warehouse 
			INNER JOIN ld_warehouse2user ON ld_warehouse.id = ld_warehouse2user.warehouseid and ld_warehouse.allocatetype = 'all' 
			where `status` = 0 and ld_warehouse.id = ?
			GROUP BY 
				ld_warehouse.id
			UNION ALL
			SELECT 
				ld_warehouse.id, 
				ld_warehouse.`name`
			FROM 
			ld_warehouse 
			INNER JOIN ld_warehouse2user ON ld_warehouse.id = ld_warehouse2user.warehouseid and ld_warehouse.allocatetype = 'user'
			INNER JOIN ld_users ON ld_warehouse2user.userid = ld_users.id 
			where ld_warehouse2user.userid = ? and ld_warehouse.`status` = 0  and ld_warehouse.id = ? 
			GROUP BY 
				ld_warehouse.id
			UNION ALL
			SELECT 
				ld_warehouse.id, 
				ld_warehouse.`name`
			FROM 
			ld_warehouse 
			INNER JOIN ld_warehouse2user ON ld_warehouse.id = ld_warehouse2user.warehouseid and ld_warehouse.allocatetype = 'group'
			INNER JOIN ld_groups ON ld_warehouse2user.userid = ld_groups.groupid 
			LEFT JOIN ld_users2group on ld_users2group.groupid = ld_groups.groupid
			where ld_users2group.userid = ? and ld_warehouse.`status` = 0  and ld_warehouse.id = ? 
			GROUP BY 
				ld_warehouse.id
			UNION ALL
			SELECT 
				 ld_warehouse.id, 
				ld_warehouse.`name`
			FROM 
			ld_warehouse 
			INNER JOIN ld_warehouse2user ON ld_warehouse.id = ld_warehouse2user.warehouseid and ld_warehouse.allocatetype = 'role'
			INNER JOIN ld_profile ON ld_warehouse2user.userid = ld_profile.profileid 
			LEFT JOIN ld_users on ld_users.profileid = ld_profile.profileid 
			where ld_users.id = ? and ld_warehouse.`status` = 0  and ld_warehouse.id = ? 
			GROUP BY 
				ld_warehouse.id
		) as temp ORDER BY id
	";
        $result = $adb->pquery($query,array($wareid,$userid,$wareid,$userid,$wareid,$userid,$wareid));
        if($adb->num_rows($result) >= 1)
            return true;
        else
            return false;
    }

    /**
     * 判断当前用户是否拥有仓库权限
     * @author Tujt 2014-11-12
     */
    public function checkWarehouseUser() {
        global $current_user;
        global $adb,$theme;
        $user_info=	getuserInfoByPrivileges($current_user);
        if(is_admin($current_user)==true){
            $query = 'select ld_warehouse.id from ld_warehouse2user 
					left join ld_warehouse on ld_warehouse2user.warehouseid=ld_warehouse.id 
				where status=0 order by ld_warehouse.id limit 1';
            $result = $adb->pquery($query,array());
        }else{
            $query = "
			select id from (
				SELECT 
					ld_warehouse.id, 
					ld_warehouse.`name`
				FROM 
				ld_warehouse 
				INNER JOIN ld_warehouse2user ON ld_warehouse.id = ld_warehouse2user.warehouseid and ld_warehouse.allocatetype = 'all' 
				where `status` = 0 
				GROUP BY 
					ld_warehouse.id
				UNION ALL
				SELECT 
					ld_warehouse.id, 
					ld_warehouse.`name`
				FROM 
				ld_warehouse 
				INNER JOIN ld_warehouse2user ON ld_warehouse.id = ld_warehouse2user.warehouseid and ld_warehouse.allocatetype = 'user'
				INNER JOIN ld_users ON ld_warehouse2user.userid = ld_users.id 
				where ld_warehouse2user.userid = ? and ld_warehouse.`status` = 0 
				GROUP BY 
					ld_warehouse.id
				UNION ALL
				SELECT 
					ld_warehouse.id, 
					ld_warehouse.`name`
				FROM 
				ld_warehouse 
				INNER JOIN ld_warehouse2user ON ld_warehouse.id = ld_warehouse2user.warehouseid and ld_warehouse.allocatetype = 'group'
				INNER JOIN ld_groups ON ld_warehouse2user.userid = ld_groups.groupid 
				LEFT JOIN ld_users2group on ld_users2group.groupid = ld_groups.groupid
				where ld_users2group.userid = ? and ld_warehouse.`status` = 0 
				GROUP BY 
					ld_warehouse.id
				UNION ALL
				SELECT 
					 ld_warehouse.id, 
					ld_warehouse.`name`
				FROM 
				ld_warehouse 
				INNER JOIN ld_warehouse2user ON ld_warehouse.id = ld_warehouse2user.warehouseid and ld_warehouse.allocatetype = 'role'
				INNER JOIN ld_profile ON ld_warehouse2user.userid = ld_profile.profileid 
				LEFT JOIN ld_users on ld_users.profileid = ld_profile.profileid 
				where ld_users.id = ? and ld_warehouse.`status` = 0 
				GROUP BY 
					ld_warehouse.id
			) as temp ORDER BY id
		";
            $result = $adb->pquery($query,array($current_user->id,$current_user->id,$current_user->id));
        }
        $num_rows = $adb->num_rows($result);
        if(!$num_rows){
            /*echo "<div id='warningTable' class='warningTable'>";
            echo "<div class='warningTableContent'>
            <div class='wtc_img'><img src='themes/images/icon-prohibit.png'></div>
            <div class='wtc_title'>".getFixedLabel('REMINDER')."</div>
            <div class='wtc_content'>".getFixedLabel('INSUFFICIENTWAREHOUSE')."</div>
            <div class='wtc_btn'><input value=".getFixedLabel('RETURN')." title=".getFixedLabel('RETURN')." class='createauto' onclick=window.location.href='index.php?module=Home&action=index&parenttab=' type='button'></div>
    			</div>";
            echo "</div>";
            echo "<script type='text/javascript' language='JavaScript'>
            var a = ld('.Header').outerHeight(),//头部高度
                c_height = 0,
                s_height = ld(window).height();
            if(a==null) a=0;
            c_height = s_height-a;
            ld('#warningTable').css('height',c_height);
            ld('.warningTableContent').css('margin-top',-a/2);
          </script>";
            exit;*/
            
            
            ConvertTojsonString(-1,[],getFixedLabel('INSUFFICIENTWAREHOUSE'));
        }
    }
    //获取在帮我吧客服端可见CRM系统客户和联系人用户范围
    public function getAllocatetypeByUserid($allocatetype,$ids){
        if('all' == $allocatetype){
            //可用成员
            $userscope = get_user_array(FALSE, "", '');
            $userscopeid = array_keys($userscope);
            $userids = implode(',',$userscopeid);
        }else if('group' == $allocatetype){
            require_once(globalStatic::$root_directory.'modules/Users/Group.class.php');
            $group = new Group();
            $groupids = explode(',',$ids);
            for($i = 0; $i<sizeOf($groupids); $i++){
                $userid_array[$i] = $group->getGroupOfusers($groupids[$i]);
            }
            foreach($userid_array as $user_info){
                foreach($user_info as $userid => $last_name){
                    $userid_arr[$userid] = $userid;
                }
            }
            $userids = implode(',',$userid_arr);
        }else{
            $userids = $ids;
        }
        return $userids;
    }
    /**
     * 获取当前用户的查询范围
     * @param $module_name
     * @return array
     * By LD Can
     * Date:20121225
     * reason:增加用户的查询范围
     */
    public function getCurSmOwnerSearchScope($module_name)
    {
        global $current_user,$adb;
        if($module_name=="Users")
        {
            return [];
        }
        $ScopOfAuthority = ScopOfAuthority::getInstance($adb,$module_name);
        /**
         * 查看范围变动
         * 1、去掉下属，增加高级（管理员 || 模块私有 || 用户授权非私有）
         * 2、能看到的用户，修改为用户授权范围用户(非管理员、模块为私有、授权范围为高级时显示，否则显示全部)
         * @project PROT180 角色权限改进
         * @author Tujt 2015-03-26
         */
        $assigned_user_id = $current_user->id;
        $moduleshare = $ScopOfAuthority->getModuleShareInfo();//获取共享规则
        $scopeauthority = $ScopOfAuthority->getUserModuleScoperType();//用户对应当前模块的授权范围类型 0个人 1全部 2高级用户 3 高级部门
        $search_senior = false;
        if($moduleshare=='')$moduleshare=SHARE_PRIVATE;
        //管理员、模块共享、用户授权非私有
        if('on' == $current_user->is_admin || SHARE_PRIVATE != $moduleshare ||  $scopeauthority> SCOPE_PERSON){
            $search_senior = true;//显示查看范围高级选项
        }
        if('on' == $current_user->is_admin || SHARE_PRIVATE != $moduleshare || SCOPE_ALL == $scopeauthority){
            //管理员、模块共享、用户授权为全部
            //49361: （http://1.117.187.41:85/crm/index.php [^]）（欧控）小程序移动端》首页销售简报》销售提货金额”和PC端不一致(出库单金额统计，路总说移动端也应该统计负责人为离职人员的单据)
            /*//ls 2022-01-11 0049599: （https://81mis.com/kfbcrm/index.php [^]）企业移动端》首页销售简报，首页简报显示的数据，应和系统参数》移动端参数》设置移动端通讯录中是否显示离职人员，结合显示
            $deploy_values_213=getSys_deploy(213);//设置移动端通讯录中是否显示离职人员。1:否，0:是
            if($module_name == 'Home'||$module_name == 'OftenUseReport'||$module_name == 'MobileReport') {//38665: （51mis.com/kfbcrm）报表>常用报表：人员范围“全部”选项中应包含离职人员
                ////CRM首页界面，“查看范围-高级”弹出层中，默认勾选显示离职人员
                if ($deploy_values_213['deploy_value'] == 0) {
                    $user_arr = get_user_array(FALSE, "", "");
                }else{
                    //移动端报表 等根据系统参数设置显示
                    $user_arr = get_user_array(FALSE, "Active", $assigned_user_id);
                }
            }else{
                //ls 2022-09-13 【XUQIU1000505】报表数据默认勾选并显示离职成员数据
                $user_arr=get_user_array(FALSE, "", "");
            }*/
            //ls 2022-09-13 【XUQIU1000505】报表数据默认勾选并显示离职成员数据（默认所有模块全部显示离职成员数据，跟系统参数“设置移动端通讯录中是否显示离职人员”无关）
            $user_arr=get_user_array(FALSE, "", "");

            $users_combo = get_select_options_array($user_arr, $assigned_user_id);
        }else if(SCOPE_HIGER_USER == $scopeauthority || SCOPE_HIGHER_GROUP == $scopeauthority){
            //非管理员、模块私有、用户授权为高级
            $user_focus = CRMEntity::getInstance('Users');
            $userscope = $user_focus->getUserScopeInfo($current_user->id,$module_name);//获取授权范围
            /*$userall = getUserCacheNameInfo();
            foreach($userscope as $userid => $username){
                if($userall[$userid]['status'] == 'Active'){
                    $user[$userid] = $username;
                }
            }*/
            $users_combo = get_select_options_array($userscope,$assigned_user_id);
        }else{//私有
            $userscope[$assigned_user_id] = getUserFullName($assigned_user_id);
            $users_combo = get_select_options_array($userscope,$assigned_user_id);
        }
        $Uservalue["UserCombo"]=$users_combo;
        if(isset($_SESSION['lvsAccount'][$module_name]['pagepublicaccounttype'])&&$_SESSION['lvsAccount'][$module_name]['pagepublicaccounttype']=='ALLACCOUNT'||$module_name=='Potentials')
        {
            $UserOther["OtherInfo"]['SmOwner_Search_All'] = array(getFixedLabel('ALL')=>'');
            //0033624: 查看范围：“我的”标签名称修改为“我负责的”，高级显示在第二个位置，我创建的显示在第三个位置
            if($search_senior)
                $UserOther["OtherInfo"]['smowner_search_senior'] = array(getFixedLabel('LBL_SENIOR')=>'');
            $UserOther["OtherInfo"]['SmOwner_Search_Me'] = array(getFixedLabel('Mine')=>'');
            $UserOther["OtherInfo"]['SmOwner_Search_Create'] = array(getFixedLabel('Icreated')=>'');
            //"SmOwner_Search_SubRole"=>array(getFixedLabel('Myteam')=>''),
        }
        else
        {
            $UserOther["OtherInfo"]['SmOwner_Search_All'] = array(getFixedLabel('ALL')=>'');
            if($search_senior)
                $UserOther["OtherInfo"]['smowner_search_senior'] = array(getFixedLabel('LBL_SENIOR')=>'');
            $UserOther["OtherInfo"]['SmOwner_Search_Me'] = array(getFixedLabel('Mine')=>'');
            $UserOther["OtherInfo"]['SmOwner_Search_Create'] = array(getFixedLabel('Icreated')=>'');
            //订货商城  我的订货
            if($module_name == 'SalesOrder'){
                $UserOther["OtherInfo"]['SmOwner_Search_MyShopcart'] = array(getFixedLabel('myshopcart')=>'');
            }
            //,"SmOwner_Search_SubRole"=>array(getFixedLabel('Myteam')=>'')
        }
        //销售目标和首页查看范围不显示  我共享的和共享给我的 选项
        if($module_name !='SalesGoal' && $module_name !='Home' && $module_name !='Reminds')
        {
            $UserOther["OtherInfo"]['SmOwer_Search_ShareMe'] = array(getFixedLabel('Sharedwithme')=>'');
            $UserOther["OtherInfo"]['SmOwer_Search_MeToShare'] = array(getFixedLabel('Ishared')=>'');
        }
        $MergeUsers=array_merge($UserOther,$Uservalue);
        return $MergeUsers;
    }
    public function get_user_array($add_blank=true, $status="Active", $assigned_user="",$private="")
    {
        static $staticuserarray;
        $statickey = 'staticgetuserarray'.$add_blank.$status.$assigned_user.$private;
        if(!empty($staticuserarray) && isset($staticuserarray[$statickey]))
            return $staticuserarray[$statickey];

        global $current_user;
        static $user_array = null;
        $module=$_REQUEST['module'];
        if($private == 'private')return '';
        if($user_array == null){
            $db = PearDatabase::getInstance();
            $temp_result = Array();
            // Including deleted lingdang_users for now.
            if (empty($status)) {
                $query = "SELECT id,user_name,first_name,last_name,wx_userid from ld_users";
                $params = array();
            }
            else
            {
                $query = "SELECT id,user_name,first_name,last_name,wx_userid from ld_users WHERE status=?";
                $params = array($status);
            }
            if (!empty($assigned_user)) {
                if (empty($status)) {
                    $query .= " where id=?";
                }else{
                    $query .= " OR id=?";
                }
                array_push($params, $assigned_user);
            }

            //$query .= " order by user_name ASC";
            $entity_field_info = getEntityFieldNames('Users');
            $fieldsName = $entity_field_info['fieldname'];
            /**
             * edit:diony
             * time:20140905
             * reason:0011066: 如客户序时簿：【查看范围】中下拉的用户名称排序不合理，应该按照姓名和姓名字母的先后顺序进行排序。
             */
            $query .= " order by CONVERT(".$fieldsName." USING gbk)  ASC";
            $result = $db->pquery($query, $params, true, "Error filling in user array: ");

            if ($add_blank==true){
                // Add in a blank row
                $temp_result[''] = '';
            }
            $userobj=new Users();
            include_once (globalStatic::$root_directory . 'appCommon/appCommon.php');
            while($row = $db->fetchByAssoc($result))
            {
                $wx_userid=$row['wx_userid'];
                //BUG0058573 ls 20221109 客户查看范围下拉选项中显示很多空白(客户001 wx_userid为空的用户默认不显示)
                if (isKehu001ServerPc()=='yes' && empty($wx_userid)) continue;
                $last_name=$row['last_name'];
                $userobj->wx_userid=$wx_userid;
                $userobj->last_name=$last_name;
                $row['last_name']=getUserlastName($userobj);
                $temp_result[$row['id']] = $row[$fieldsName];
            }

            $user_array = &$temp_result;
        }
        // dump($temp_result);
        return $staticuserarray[$statickey] = $user_array;
    }
    public function getUser_imageInfo($userid)
    {
        global $adb;
        static  $static_user_imageInfo;
        if(is_array($static_user_imageInfo))
        {
            return $static_user_imageInfo;
        }
        $focus=CRMEntity::getInstance('Users');
        $modulefields=$focus->fieldobj->getModuleFields();
        $attachmentsinfo=array();
        $sql='select ld_attachments.*  from ld_attachments 
                        inner join ld_salesmanattachmentsrel on ld_salesmanattachmentsrel.attachmentsid=ld_attachments.attachmentsid
                   WHERE   ld_salesmanattachmentsrel.smid=?
                     ';

        $result=$adb->pquery($sql,array($userid));
        $rows=$adb->num_rows($result);
        //editor:gyq_169 reason:腾讯云COS文件上传预览    2020/3/2 9:12
        for($i=0;$i<$rows;$i++)
        {
            $id=$adb->query_result($result,$i,'attachmentsid');
            $recordid = $record;
            $attname = $adb->query_result($result,$i,'name');

            $size = $adb->query_result($result,$i,'size');
            $path = $adb->query_result($result,$i,'path');
            $cloud_path = $adb->query_result($result,$i,'cloud_path');
            $file_type = $adb->query_result($result,$i,'type');
            $newfile_name=$adb->query_result($result,$i,'newfile_name');
            $attachmentcolumnname='imagename';//$adb->query_result($result,$i,'attachmentcolumnname');
            $storage_location = $adb->query_result($result,$i,'storage_location');
            $upload_from = $adb->query_result($result,$i,'upload_from');
            //if($storage_location=='cos'){
//                $file_path = $cloud_path;
//            }else{
//                $file_path = $path;
//            }
            // BUG0076853 hzx 20231207 成员管理，编辑一个有个人头像的单据，个人头像后边出现undefined
            $cls_MyCRMcrypt = new cls_MyCRMcrypt();
            $path = $cls_MyCRMcrypt->encode($path);
            $cloud_path = $cls_MyCRMcrypt->encode($cloud_path);
            $newfile_name = $cls_MyCRMcrypt->encode($newfile_name);
            $isEncrypt = 'yes';
            $httppath = $cls_MyCRMcrypt->decode($cloud_path);
            $pre_path = $cls_MyCRMcrypt->decode($path) . $cls_MyCRMcrypt->decode($newfile_name);
            $file = array('id' => $id, 'storage_location' => $storage_location, 'httppath' => $httppath,
                'pre_path' => $pre_path, 'name' => $attname, 'type' => $file_type, 'isEncrypt' => $isEncrypt,
                'path' => $path, 'cloud_path' => $cloud_path, 'newfile_name' => $newfile_name);
            crm_load_class_file('AttachmentUtils','modules/Attachment');
            $AttachmentUtils = new AttachmentUtils;
            $pre_button = $AttachmentUtils::getPreviewButton($file);

            $file_info[$attachmentcolumnname][] = array('file_name'=>$attname,'file_size'=>$size
            ,'file_type'=>$file_type,'file_path'=>$path,'newfile_name'=>$newfile_name
            ,'cloud_path'=>($cloud_path), 'isEncrypt' => $isEncrypt
            ,'fileid'=>$id,'storage_location'=>$storage_location,'upload_from'=>$upload_from,'pre_button' => $pre_button);


        }
        $static_user_imageInfo=$file_info;
        /* foreach($modulefields as $fieldname=>$fieldinfo)
         {
             $uitype=$fieldinfo->getUIType();
             $columnname=$fieldinfo->getColumnName();
             $bigtype=$fieldinfo->getBigType();
             if($bigtype=='fileattachment')
             {
                //$attachmentsinfo[$columnname]=json_decode(getAttachmentsTableInfo($record,$module,$columnname));
             }
         }*/
        return $file_info;

    }
    /***
     * 个人名片上的信息
     * @param $usid
     * @return array
     * @throws Exception
     * 以前这个方法写在C:\ldcrm\www\crm\WeiXinApp\cloudpro\CloudUsers.php中 但是因为sql注入问题 将这个文件删除或者怎么的会影响使用  故挪到这里
     */
    public function getCrmUserInfo($usid)
    {
        global $adb;
        $admin_sql = "SELECT
             u.last_name,
             u.real_name,
             g.groupname,
             u.userlevel,
             u.phone_home,
             u.phone_mobile,
             u.email1,
             a.newfile_name as name,
             a.path,
             a.storage_location,
             a.cloud_path
            FROM
             ld_users AS u
            left join ld_groups as g on g.groupid=u.groupid
            left join ld_salesmanattachmentsrel as s on u.id = s.smid
            left join ld_attachments as a on a.attachmentsid = s.attachmentsid 
            WHERE u.id =? ";
        $admin = $adb->pquery($admin_sql,array($usid));
        $company_sql = "select * from ld_organizationdetails";
        $company = $adb->pquery($company_sql);
        $rows = $adb->num_rows($admin);
        $admin_info = [];
        $iskehu001 = isKehu001ServerPc();
        if($rows>=1){
            $admin_info['username'] = $adb->query_result($admin,0,'last_name');
            if($iskehu001 == "yes"){
                $admin_info['username'] = $adb->query_result($admin,0,'real_name');
            }
            $admin_info['groupname'] = $adb->query_result($admin,0,'groupname');
            $admin_info['userlevel'] = $adb->query_result($admin,0,'userlevel');
            $admin_info['phone_mobile'] = $adb->query_result($admin,0,'phone_mobile');
            $admin_info['phone_home'] = $adb->query_result($admin,0,'phone_home');
            $admin_info['email'] = $adb->query_result($admin,0,'email1');
            $storage_location = $adb->query_result($admin,0,'storage_location');
            $admin_info['storage_location'] = $storage_location;
            if($storage_location == 'cos'){
                $admin_info['image_str'] = $adb->query_result($admin,0,'cloud_path');
            }else{
                $admin_info['image_str'] = $adb->query_result($admin,0,'path').$adb->query_result($admin,0,'name');
                //gwq 20240624 BUG20240624-17
                if(!file_exists(globalStatic::$root_directory.$adb->query_result($admin,0,'path').$adb->query_result($admin,0,'name'))){
                    $admin_info['image_str'] = 'themes/images/defaultuser.png';
                }
            }
            // ljj 20231201 XUQIU1000927 更换默认头像
            $userfilepath=getDefaultAvatar($usid);
            $admin_info['image_str'] = ($admin_info['image_str']=='')?$userfilepath:$admin_info['image_str'];
            $admin_info['company'] = $adb->query_result($company,0,'organizationname');
            $admin_info['address'] = $adb->query_result($company,0,'state') . $adb->query_result($company,0,'city').$adb->query_result($company,0,'address');
        }
        return $admin_info;
    }


    /***
     * 当前部门下所有启用成员的信息
     * @param $groupid
     * @return array
     * @throws Exception
     */
    public function getGroupOfActiveUsers($groupid) {
        global $adb;
        $query = 'SELECT userid,wx_userid,last_name FROM ld_users2group 
        inner join ld_users on ld_users.id = ld_users2group.userid WHERE ld_users2group.groupid = ? and ld_users.status = ?;';
        $result = $adb->pquery($query,array($groupid,'Active'));
        $rows = $adb->num_rows($result);
        $groupuser = array();
        if($rows > 0){
            //include_once (globalStatic::$root_directory . 'appCommon/appCommon.php');
            for($i=0;$i<$rows;++ $i){
                $userobj=new Users();
                $userid = $adb->query_result($result,$i,'userid');
                $userobj->wx_userid = $adb->query_result($result,$i,'wx_userid');
                $userobj->last_name = $adb->query_result($result,$i,'last_name');
                //BUG0058573 ls 20221109 客户查看范围下拉选项中显示很多空白(客户001 wx_userid为空的用户默认不显示)(普通成员数据范围权限为按部门时)
                if (isKehu001ServerPc()=='yes' && empty($userobj->wx_userid)) continue;
                $groupuser[$userid] = getUserlastName($userobj);
                //$groupuser[$userid] = getUserFullName($userid);
            }
        }
        if(!empty($groupuser)) return $groupuser;
        return '';
    }

}