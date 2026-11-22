<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Chj 2016-06-13
 */
// 部门操作方法类
class Group_Special{
	 public $group_cache_app_key = 'cache_getgrouplist_array_app';
	/**
	 * 获取用户的所在部门
	 * @param
	 * @return
	 * @author Chj
	 */
	static function getMeByGroup($userid) {
		global $adb;
		if(!empty($userid)){
			$query = 'select ld_users2group.groupid,groupname from ld_groups left join  ld_users2group  on ld_groups.groupid = ld_users2group.groupid where userid = ?';
			$result = $adb->pquery($query,array($userid));
			$num_rows = $adb->num_rows($result);
			for($i = 0; $i<$num_rows; $i++){
				$groupname=$adb->query_result($result,$i,'groupname');
				if(!empty($groupname)){
					$groupid = $adb->query_result($result,$i,'groupid');
					$groupnames[$groupid] = $adb->query_result($result,$i,'groupname');
				}
			}
		}
		return $groupnames;
	}

	/**
     * 手机端获取部门及用户信息(手机端)
     * @author diony 2016-05-18
     */
    public function getGrouplistForApp() {
		static $static_grouplist_app_array;
		if(!empty($static_grouplist_app_array)){
			return $static_grouplist_app_array;
		}
		$grouparray = Cache($this->group_cache_app_key);
		if(!$grouparray){
			$grouparray = array();
			global $adb;
			$query = 'SELECT groupid,groupname,description,depth,parentid,parentgroup 
						FROM ld_groups WHERE groupid > 0 ORDER BY CONCAT("::",parentgroup,"::");';
			$result = $adb->pquery($query,array());
			$rows = $adb->num_rows($result);
			if($rows > 0){
				for($i=0;$i<$rows;++ $i){
					$groupid = $adb->query_result($result,$i,'groupid');
					$groupname = $adb->query_result($result,$i,'groupname');
					//$description = $adb->query_result($result,$i,'description');
					$depth = $adb->query_result($result,$i,'depth');
					$parentid = $adb->query_result($result,$i,'parentid');
					$parentgroup = $adb->query_result($result,$i,'parentgroup');
					//$grouparray[$groupid]['groupid'] = $groupid;
					$grouparray[$groupid]['groupname'] = $groupname;
					//$grouparray[$groupid]['description'] = $description;
					$grouparray[$groupid]['depth'] = $depth;
					$grouparray[$groupid]['parentid'] = $parentid;
					//$grouparray[$groupid]['parentgroup'] = $parentgroup;
                    //$grouparray[$groupid]['group'] = $this->getGroupTheLowerForApp($groupid);
                    $grouparray[$groupid]['users'] = $this->getGroupOfusersForApp($groupid);
				}
				Cache($this->group_cache_app_key,$grouparray);
			}
		}
		if(!empty($grouparray)){
			return $static_grouplist_app_array = $grouparray;
		}
		return '';
    }

	 /**
	 * 获取部门对应的员工信息(手机端)
     * @author diony 2016-05-18
	 */
	public function getGroupOfusersForApp($groupid) {
	    global $adb;
		//$query = 'SELECT userid FROM ld_users2group WHERE groupid = ?;';
        $query = 'SELECT ld_users.id as userid, ld_users.user_name as username,
						ld_users.last_name as lastname,
                        ld_users.userlevel,ld_profile.profilename,ld_users.phone_mobile,ld_users.phone_home,
                        ld_attachments.`path` as userimgpath,ld_attachments.`name` as userimgname,ld_attachments.attachmentsid
					FROM ld_users 
				LEFT JOIN ld_profile ON ld_users.profileid = ld_profile.profileid
                LEFT JOIN ld_salesmanattachmentsrel 
					ON ld_users.id = ld_salesmanattachmentsrel.smid 
				LEFT JOIN ld_attachments 
					ON ld_attachments.attachmentsid = ld_salesmanattachmentsrel.attachmentsid 
				WHERE ld_users.deleted = 0 AND ld_users.status = "Active" 
                and ld_users.id in (SELECT userid FROM ld_users2group WHERE groupid = ?)';
        $query .= "ORDER BY convert(lastname using gbk) ASC"; 
		$result = $adb->pquery($query,array($groupid));
		$rows = $adb->num_rows($result);
		$userarr = array();
		if($rows > 0){
			for($i=0;$i<$rows;++ $i){
				$userid = $adb->query_result($result,$i,'userid');
				$username = $adb->query_result($result,$i,'username');
				$lastname = $adb->query_result($result,$i,'lastname');
                $profilename = $adb->query_result($result,$i,'profilename');
                if($profilename == null) $profilename = '';
                $userlevel = $adb->query_result($result,$i,'userlevel');
                if($userlevel == null) $userlevel = '';
                $phone_mobile = $adb->query_result($result,$i,'phone_mobile');
                $phone_home = $adb->query_result($result,$i,'phone_home');
				$userimgpath = $adb->query_result($result,$i,'userimgpath');
				$userimgname = $adb->query_result($result,$i,'userimgname');
				$attachmentsid = $adb->query_result($result,$i,'attachmentsid');
			    $userimgpath=$this->getUserImage($userimgpath,$userimgname,$attachmentsid,$userid);
                
                $userarr[$i]['userid']['value'] = $userid;
			    $userarr[$i]['username']['value'] = $username;
				$userarr[$i]['lastname']['value'] = $lastname;
                $userarr[$i]['profilename']['value'] = $profilename;
                $userarr[$i]['userlevel']['value'] = $userlevel;
                $userarr[$i]['phone_mobile']['value'] = $phone_mobile;
                $userarr[$i]['phone_home']['value'] = $phone_home;
				$userarr[$i]['userimgpath']['value'] = $userimgpath;
				//$userarr[$i]['userimgname']['value'] = $userimgname;
			}
		}
        if(!empty($userarr)) return $userarr;
		return '';
	}

	  /**
	 * 获取部门对应的员工信息(手机端),返回字符串
     * @author diony 2016-06-02
	 */
	public function getGroupOfusersForAppStr($groupid) {
	    global $adb;
        $query = "SELECT ld_users.id as userid, ld_users.user_name as username,
						ld_users.last_name as lastname
					FROM ld_users 
				WHERE ld_users.deleted = 0 AND ld_users.status = 'Active' 
                and ld_users.id in (SELECT userid FROM ld_users2group WHERE groupid in ($groupid))";
        $query .= 'ORDER BY convert(lastname using gbk) ASC'; 
		$result = $adb->pquery($query,array());
		$rows = $adb->num_rows($result);
        if($rows > 0){
			for($i=0;$i<$rows;++ $i){
				$userid .= $adb->query_result($result,$i,'userid').',';
			}
		}
        if(!empty($userid)) return $userid;
		return '';
	}

	/**
	 * 获取当前需要显示的图标及文字(手机端)
     * @author diony 2016-06-02
	 */
	public function getuserinfoStrForApp($userids) {
	    global $adb,$weixin_user,$current_user;
		$query = "SELECT ld_users.id as userid, ld_users.user_name as username,
						ld_users.last_name as lastname,ld_users.wx_userid,
                        ld_attachments.`path` as userimgpath,ld_attachments.`name` as userimgname,ld_attachments.attachmentsid
					FROM ld_users 
				LEFT JOIN ld_salesmanattachmentsrel 
					ON ld_users.id = ld_salesmanattachmentsrel.smid 
				LEFT JOIN ld_attachments 
					ON ld_attachments.attachmentsid = ld_salesmanattachmentsrel.attachmentsid 
				WHERE ld_users.deleted = 0";
		/** 
        * @edit:diony 
        * @date:2020-07-17
        * @reason:获取所有用户
        * @reason:设置移动端通讯录中是否显示离职人员。1:否，0:是
        * @description:$this->cls_methodObj->isactive 前端传值，目前没参考前端传值，直接读取后台参数
        */
        $deploy_values_213=getSys_deploy(213);
        if($deploy_values_213['deploy_value'] == 1){
            $query.=" AND ld_users.status = 'Active' ";
        }
        if($userids!=''){
            $query.=" and ld_users.id in ($userids) ";
        }
        $query .= " ORDER BY convert(lastname using gbk) ASC"; 
        // echo $query;die;
        $result = $adb->pquery($query,array());
		$rows = $adb->num_rows($result);
		$userarr = array();
        if($rows > 0){
            if($rows==1){                
				$lastname = $adb->query_result($result,0,'lastname');
                $wx_userid=$adb->query_result($result,0,'wx_userid');
                $userobj=new Users();
                $userobj->wx_userid=$wx_userid;
                $userobj->last_name=$lastname;
                $lastname=getUserlastName($userobj);
				$userimgpath = $adb->query_result($result,0,'userimgpath');
				$userimgname = $adb->query_result($result,0,'userimgname');
				$attachmentsid = $adb->query_result($result,0,'attachmentsid');
				$userid = $adb->query_result($result,0,'userid');
			    $userimgpath=$this->getUserImage($userimgpath,$userimgname,$attachmentsid,$userid);
                
                $userarr['lastname'] = $lastname;
				$userarr['userimgpath'] = $userimgpath;
            }
            else{
                for($i=0;$i<2;++ $i){
                    $userobj=new Users();
                    $userobj->wx_userid=$adb->query_result($result,$i,'wx_userid');
                    $userobj->last_name=$adb->query_result($result,$i,'lastname');
                    $tmplastname=getUserlastName($userobj);
    				$lastname .= $tmplastname.'、';
    			}     
                        
                $userarr['lastname'] = substr($lastname,0, strlen($lastname) - 3).'等'.$rows.'个人';
                $userarr['userimgpath'] = 'themes/images/defaultuser.png';
            }
		}
       
        if($weixin_user->environment_weixin && ($_REQUEST['module']=='Dashboard'||$_REQUEST['action']=='home_page'||$_REQUEST['action']=='DetailViewSecond')){
            $selected_user_list = explode(',',$userids);
            
            $module_users = getCurSmOwnerSearchScope('MobileReport');
           
            //editor:gyq_20191104 reason:当数据范围仅一人，而此人又不是当前操作人，则返回值应是2而不是1
            //0038404: （珞落计划）企业微信端，移动端报表数据范围按部门设置时，销售简报等报表【查看范围】无法选择用户（账户：panlulu,123）
            if(count($module_users['UserCombo'])==1 && !array_key_exists($current_user->id,$module_users['UserCombo'])){
                $userarr['permit']  = 2;
            }else{
                $userarr['permit'] = count($module_users['UserCombo']);
            }
            if($rows>1) 
            {
                 $userobj=new Users();
                 $userobj->wx_userid=$adb->query_result($result,0,'wx_userid');
                 $userobj->last_name=$adb->query_result($result,0,'lastname');
                 $tmplastname=getUserlastName($userobj);
                    //BUG0067876 txy 20230731 移动端英文版-首页查看范围，选择人员后，“xx等n人”，也应转换为英文
                $userarr['lastname'] = $tmplastname.getFixedLabel('ANDOTHER').$rows.getFixedLabel('people');
            }
            //editor:gyq_141 reason:选择全部，显示【全部】 选择1个员工，显示【姓名】
            //选择2个及以上员工，显示【姓名1等n人】  2019/9/5 17:53 ID1000602
           
            if(count($selected_user_list)==$userarr['permit']&&count($selected_user_list)>1 || 
                $_REQUEST['selectuid']=='all'&&$rows>1){
                $userarr['lastname'] = getFixedLabel('ALL');
                $userarr['viewrange'] = getFixedLabel('VIEWRANGE');
            }
            unset($userarr['userimgpath']);
        }
        if(!empty($userarr)) return $userarr;
		return '';
	}
	
	/**
	*@author:diony
	*@data:20160602
	*@reason:获取当前需要显示的图标及文字
	*@version:V6.4.0
	*/
	public function getuserinfoStr($chooseuserid)
	{
		$userinfoStr = $this->getuserinfoStrForApp($chooseuserid);
		return $userinfoStr;
	}

	 /**
     * edit:can
     * reason:获取用户头像路径
    **/
    public function getUserImage($path,$userimagename,$attachmentsid,$userid)
    {   $userimagetypes=explode('.',$userimagename);
        $userimagetype=$userimagetypes[sizeof($userimagetypes)-1];//获取用户照片的后缀名
        if(!empty($attachmentsid)&&!empty($path))
            $userfilepath=$path.$attachmentsid.'_1.'.$userimagetype;
        else{
            // ljj 20231201 XUQIU1000927 更换默认头像
            $userfilepath=getDefaultAvatar($userid);
		}
        if(!file_exists($userfilepath))
        {
            $userfilepath='themes/images/defaultuser.png';
        }
        return $userfilepath;
    }

	 /**
	 * 获取当前部门所有下级部门(手机端)
     * @author diony 2016-05-18
	 */
	public function getGroupTheLowerForApp($id) {
		global $adb;
	    $query = 'SELECT groupid,groupname,description,depth,parentid,parentgroup 
					 FROM ld_groups WHERE groupid != "'.$id.'" AND 
				  CONCAT("::",parentgroup,"::") LIKE "%::'.$id.'::%" ;';
		$result = $adb->pquery($query,array());
		$rows = $adb->num_rows($result);
		$grouparray = array();
		if($rows > 0){
			for($i=0;$i<$rows;++ $i){
				$groupid = $adb->query_result($result,$i,'groupid');
				$groupname = $adb->query_result($result,$i,'groupname');
				$description = $adb->query_result($result,$i,'description');
				$depth = $adb->query_result($result,$i,'depth');
				$parentid = $adb->query_result($result,$i,'parentid');
				$parentgroup = $adb->query_result($result,$i,'parentgroup');
				$grouparray[$groupid]['groupname'] = $groupname;
				//$grouparray[$groupid]['description'] = $description;
				//$grouparray[$groupid]['depth'] = $depth;
				//$grouparray[$groupid]['parentid'] = $parentid;
				//$grouparray[$groupid]['parentgroup'] = $parentgroup;
			}
		}
		if(!empty($grouparray)) return $grouparray;
		return '';
	}
}
?>