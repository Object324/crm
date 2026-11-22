<?php
	/**
	 * 修改编码格式:统一编码：UTF-8
	 * @author Chj
	 */
    crm_load_class_file('cls_GroupWX','WeiXinApp/WeiXin_common/SearchScope');
	class cls_GroupUser{

		private $scopetype;//显示类型 User 用户 Group 部门 UserGroup用户级部门
		private $userbyinfo;	//用户关联信息
		private $method;
		private $cls_methodObj;
		private $user_obj;
        private $scope_userarray;
        private $scope_grouparray;
        private $groupobj;
        private $shareduser;//已共享的用户
        private $cancelshare;//是否可以取消共享
        private $whereuserid_arr;
        
        public function __construct($method) {
			global $mobileversion,$current_user;
            $this->groupobj = new cls_GroupWX();
            $this->cls_methodObj = crm_load_class_obj('cls_methodObj','WeiXinApp/WeiXin_common/SearchScope');
			$this->cls_methodObj->setModule($method['module']);
			$this->cls_methodObj->setSearchType($method['searchtype']);
			$this->cls_methodObj->setFilterown($method['filterown']);
			$this->cls_methodObj->setScopeType($method['scopetype']);
			$this->cls_methodObj->setCommon($method['common']);
            $this->cls_methodObj->setActive($method['isactive']);
			$this->user_obj = $current_user;
            $this->whereuserid_arr=$method['whereuserid_arr'];

		}
		//获取返回结果
		public function getGroupUser(){
            global $adb;
            $scopetype = $_REQUEST['scopetype'];
            if($scopetype == 'groupuser'){ //获取部门分级用户树
                $output = $this->getGroups();
            }elseif($scopetype == 'profile'){
                $output = $this->getProfile();
            }else{
                if(isset($_REQUEST['fieldname']) && !empty($_REQUEST['fieldname'])){
                    $fld_fieldname=$_REQUEST['fieldname'];
                    $tabid=getTabid($_REQUEST['return_module']);
                    $sql="select advance_demand,advance_demand_groups from ld_field where fieldname='".$fld_fieldname."' and tabid=".$tabid."";
                    $result=$adb->query($sql);
                    $num_rows = $adb->num_rows($result);
                    if($num_rows>0){
                    $advance_demand_groups=$adb->query_result($result,0,'advance_demand_groups');
                    $advance_demand=$adb->query_result($result,0,'advance_demand');
                    }
                }

                $users = $this->getUsers();   //获取用户列表

                $userArr = array();
                $searchContent = $_REQUEST['searchcontent'];
                if($this->cls_methodObj->scopetype=='share'){
                    $this->getSharedUsers();
                }
                foreach($users as $key=>$val){
                    //$find = strpos($val['lastname']['value'],$searchContent);
                    if($find !== false || $searchContent==''){
                        $userArr[$key]['id'] = $val['userid']['value'];
                        $userArr[$key]['name'] = $val['lastname']['value'];// 
                        $userArr[$key]['description'] = $val['description']['value'];
                        $userArr[$key]['userimg'] = $val['userimgpath']['value'];
                        $userArr[$key]['display'] = $val['display'];
                        $userArr[$key]['status'] = $val['status']['value'];
                        //共享人
                        if($this->cls_methodObj->scopetype=='share'){
                            if(in_array($key,$this->shareduser))
                                $userArr[$key]['select'] = 'yes';
                            else
                                $userArr[$key]['select'] = 'no';
                        }else{
                            $userArr[$key]['select'] = '';
                        }
                    }
                }
                $output['list'] = array_values($userArr);
                if($this->cls_methodObj->scopetype=='share'){
                    $output['cancelsharepermit'] = $this->cancelshare;
                    $output['ccuser'] = implode(',',$this->shareduser);
                }
            }
            
            if(count($output['list']) == 0){
                $output['treeData'] = [];
                $output['treeList'] = [];
                return $output;
            }
            //hzx 移动端选人控件优化
            $_REQUEST['searchcontent'] = '';
            $allusers = $this->getUsers();
            foreach($allusers as $key=>$val){
                $alluserArr[$key]['id'] = $val['userid']['value'];
                $alluserArr[$key]['name'] = $val['lastname']['value'];//
                $alluserArr[$key]['description'] = $val['description']['value'];
                $alluserArr[$key]['userimg'] = $val['userimgpath']['value'];
                $alluserArr[$key]['display'] = $val['display'];
                $alluserArr[$key]['status'] = $val['status']['value'];
            }
            $output['alllist'] = array_values($alluserArr);
            require_once globalStatic::$root_directory.'modules/Users/Group.class.php';
            $group_focus = new Group();
            $groupuser = $group_focus->getGroupListUser('yes','','','','','');

            //查询
            if($searchContent && $searchContent != ''){
                $this->parentIdArr_tree = [];
                for($i = 0;$i<count($output['list']);$i++){
                    foreach ($groupuser as $key => $groupuserinfo){
                        if($groupuserinfo['type'] == 'user' && $groupuserinfo['groupid'] == $output['list'][$i]['id']){
                            $this->getParentIdArr_tree($groupuserinfo['parentid'],$groupuser);
                        }
                    }
                }
            }
            foreach ($groupuser as $key => &$groupuserinfo){
                $groupuserinfo['parentvalue'] = 'group_'.$groupuserinfo['parentidvalue'];
                if($groupuserinfo['type'] == 'user'){
                    for ($i = 0 ;$i<count($output['list']);$i++){
                        if($groupuserinfo['groupid'] == $output['list'][$i]['id']){
                            if(is_array($this->whereuserid_arr)&&sizeof($this->whereuserid_arr)>0)
                            {
                                 if(!in_array($output['list'][$i]['id'],$this->whereuserid_arr)){
                                     unset($groupuser[$key]);
                                     continue;//轨迹定位报表 ，只显示设置轨迹组的成员
                                 }
                            }
                                $userobj=new Users();
                              $userobj->id=$groupuserinfo['groupid'];
                  
                             $userobj->last_name=$output['list'][$i]['name'];
                            $groupuserinfo['name']=$output['list'][$i]['name'];
                            $groupuserinfo['value'] = $groupuserinfo['type'].'_'.$output['list'][$i]['id'];
                            $groupuserinfo['image'] = $output['list'][$i]['userimg'];
                            $groupuserinfo['description'] = $output['list'][$i]['description'];
                            $groupuserinfo['select'] = $output['list'][$i]['select'];
                            if($_REQUEST['userarr'] == 'all'){
                                $groupuserinfo['select'] = 'yes';
                            }
                            else if($_REQUEST['userarr'] && $_REQUEST['userarr'] != ''){
                                if(in_array($groupuserinfo['groupid'],explode(',',$_REQUEST['userarr']))){
                                    $groupuserinfo['select'] = 'yes';
                                }
                            }
                            // 工作汇报抄送范围,不允许取消的成员
                            if(!empty($_REQUEST['send_range_disableduser'])){
                                if(in_array($groupuserinfo['groupid'],explode(',',$_REQUEST['send_range_disableduser']))){
                                    $groupuserinfo['disabled'] = 'yes';
                                }
                            }
                            if($isbox == 'single'){
                                $groupuserinfo['inputtype'] = 'radio';
                            }else{
                                $groupuserinfo['inputtype'] = 'checkbox';
                            }
                            break;
                        }
                    }
                    if(!$groupuserinfo['value']){
                        unset($groupuser[$key]);
                        continue;
                    }
                }
                elseif($groupuserinfo['type'] == 'group'){
                    if($this->parentIdArr_tree && !in_array($key,$this->parentIdArr_tree)){
                        unset($groupuser[$key]);
                        continue;
                    }
                    $groupuserinfo['value'] = $groupuserinfo['type'].'_'.$groupuserinfo['groupid'];

                    $groupobj=new Users();
                    $groupobj->groupid=$groupuserinfo['groupid'];
                    $groupobj->groupname=$groupuserinfo['name'];
                    $groupuserinfo['name'] = getWx_GroupName($groupobj);
                    //dump([$group_focus->getGroupOfusers($groupuserinfo['groupid']),$output['ccuser']]);
                    if($key == $group_focus->group_parent_key){
                        $groupuserinfo['image'] = 'themes/images/company.png';
                    }else{
                        $groupuserinfo['image'] = 'themes/images/group.png';
                    }
                    if($isbox == 'single'){
                    }else{
                        $groupuserinfo['inputtype'] = 'checkbox';
                    }
                }
            }
			//zkt 20231108 XUQIU1001871 分配与查看范围，分配时可见成员根据数据范围显示，不显示全部成员
            $fld_module = $this->cls_methodObj->getModule();
            if(!empty($fld_fieldname)){
                $focus = CRMEntity::getInstance($fld_module);
                if(!empty($focus->fieldobj)){
                    $fieldinfo= $focus->fieldobj->getFieldInfoobjBykey('fieldname',$fld_fieldname);
                    if(!empty($fieldinfo)&&!$fieldinfo->isshowallgroupstructure()){
                        $group_focus->showallgroupstructure = 'no';
                    }
                }
            }
            $groupuserarray = $group_focus->setOneParent($groupuser);

            //$groups = $group_focus->getGrouplist();
            $output['treeData'] = $groupuserarray[$group_focus->group_parent_key];
            $output['treeList'] = $groupuser;


            return $output;
		}
        private function getParentIdArr_tree($parentid,$groupuser){

          //  file_put_contents('text.txt',$parentid."\r\n",FILE_APPEND);
            $this->parentIdArr_tree[] = $parentid;
            if($groupuser[$parentid] && isset($groupuser[$parentid]['parentid']) && $groupuser[$parentid]['parentid'] != '' && !in_array($groupuser[$parentid]['parentid'],$this->parentIdArr_tree)){
                echo $groupuser[$parentid]['parentid'].'<br>';
                $this->getParentIdArr_tree($groupuser[$parentid]['parentid'],$groupuser);
            }
        }
        //用户角色权限弹出层
        private function getProfile(){
            $profile_focus = new Profile();
        	$allProfile = $profile_focus->getProfileArray();
            $profileArray = array();
            $searchContent = $_REQUEST['searchcontent'];
        	if(!empty($allProfile)){
        		foreach($allProfile as $profileid => $profilename){
  		            if($searchContent==''){
  		                $profileArray['list']['name'] = '所有角色';
  		                $profileArray['list']['children'][] = array('id'=>$profileid,'name'=>$profilename);
                        $profileArray['list']['groupid'] =  'role1';
                        $profileArray['list_new'][] = array('id'=>$profileid,'name'=>$profilename);
  		            }else{
  		                if(strpos($profilename,$searchContent)!==false){
  		                    $profileArray['list'][] = array('id'=>$profileid,'name'=>$profilename);
  		                }
  		            }
        		}
        	}
            return $profileArray;
        }
        
        //editor:gyq reason:微信新用户树 date:20161019    gyqTE用户弹出层整理
        private function getGroups(){
            // 分配弹出层是否显示所有用户 0:是，1:否
            // $deploy_values=getSys_deploy(110);
            // if($deploy_values['deploy_value']==1 && $_REQUEST['popup_type'] == 'Allocate'){
            //     $_REQUEST['popup_scopetype']='private';
            // }
//            dump($deploy_values);
            //默认不显示停用用户
            // $isactive = isset($_REQUEST['isactive'])?$_REQUEST['isactive']:'yes';//模块
            /** 
            * @edit:diony 
            * @date:2020-07-17
            * @reason:获取所有用户
            * @reason:设置移动端通讯录中是否显示离职人员。1:否，0:是
            * @description:$this->cls_methodObj->isactive 前端传值，目前没参考前端传值，直接读取后台参数
            */
            $deploy_values_213=getSys_deploy(213);
            if($deploy_values_213['deploy_value'] == 0){
                $isactive = 'yes';
            }
            else{
                $isactive = 'no';
            }
            $view = isset($_REQUEST['popup_scopetype'])?$_REQUEST['popup_scopetype']:'private';
            $fld_module = $_REQUEST['return_module']?$_REQUEST['return_module']:'';//模块
            $filterown = isset($_REQUEST['filterown'])?$_REQUEST['filterown']:'';//是否过滤自己
            $isbox = isset($_REQUEST['popup_inputtype'])?$_REQUEST['popup_inputtype']:1;//1 多选  2 单选
            $selecttype = isset($_REQUEST['selecttype'])?$_REQUEST['selecttype']:'';	//选择类型
            $ishighseaallocate=isset($_REQUEST['ishighseaallocate'])?$_REQUEST['ishighseaallocate']:'no';
            $filterrecordid = $_REQUEST['filterrecordid'];//共享时，过滤当前单据的负责人(只控制单个单据)


            if(isset($_REQUEST['fieldname']) && !empty($_REQUEST['fieldname'])){
                $fld_fieldname = $_REQUEST['fieldname'];//共享时，过滤当前单据的负责人(只控制单个单据)
            }
//            $groupuser = $this->groupobj->getGroupListUser($fld_module,$view,$filterown,$selecttype,$ishighseaallocate,$filterrecordid,$isactive);
            $groupuser = $this->groupobj->getGroupListUser($fld_module,$view,$filterown,$selecttype,$ishighseaallocate,$filterrecordid,$fld_fieldname);
            $searchcontent='';
            $searchuser_arr=array();
            if(isset($_REQUEST['searchcontent'])&&$_REQUEST['searchcontent']!='')
            {
               
                $iskehu001=isKehu001ServerPc();
               if($iskehu001=='yes')
               {
                  crm_load_class_file("cls_WeixinPort", 'WeiXinApp/WeiXin_common');
                    $port_obj = new cls_WeixinPort();//Eidtor:gyq_63 Reason:接口支持多应用管理 Date:2018/3/2 0002 下午 1:21
                    $wx_userarr =$port_obj->getwxUserid('like',$_REQUEST['searchcontent']);  
                    $searchcontent=$_REQUEST['searchcontent'];
                    if(array_key_exists('userid',$wx_userarr))
                    {
                            $searchuser_arr=$wx_userarr['userid'];
                            
                    }
               }
            }
            //editor:gyq_20190514 reason:企业微信部门树代码重写 0037050
            //0037050: （落落计划）企业微信>灵当CRM>报表>签约数量龙虎榜>查看范围>查看范围选择【高级按部门，选择所有的部门】、
            //时间范围选择【全部】：数据范围为个人但是还是将所有人员的数据都显示出来了。
            $group_user_num = array();
            $group_user_output = array();
            $user_output = array();
            //初始化用户列表信息
            $userobj=new Users();

            global $adb,$current_user;
            $deploy_values_213=getSys_deploy(213);
            if($deploy_values_213['deploy_value'] == 0){
                $users = get_user_array(false,'','');
            }
            else{
                $users = get_user_array(false,'Active','');
            }
            $current_module=$_REQUEST['return_module'];
            $fieldobj=Field::getInstance($current_module,$adb);
            if(isset($_REQUEST['fieldname'])&&!empty($_REQUEST['fieldname'])){
                $current_fieldname=$_REQUEST['fieldname'];
                $current_bigtype=$fieldobj->getFieldInfoBykeyValue('fieldname',$current_fieldname,'bigtype');
                $current_fieldid=$fieldobj->getFieldInfoBykeyValue('fieldname',$current_fieldname,'fieldid');
            }


            //wyt 220920 1000061 选用户（负责人、单选用户、多选用户、团队成员）字段控制只允许选择满足一定条件的数据 BUG0057215 企业微信移动端-销售线索，共享单据一直转圈
            if($current_bigtype == 'selectoneuser'||$current_bigtype == 'selectmultiuser'||
                $current_bigtype == 'users' ||(isset($_REQUEST['fieldname']) && $_REQUEST['fieldname'] == 'team_memberid')){
                crm_load_class_file('cls_EditView_OutPut','include/utils');
                $tmp_focus=new cls_EditView_OutPut();
                $module_users=$tmp_focus->getUserSelect($current_fieldid,$users,$current_module,$current_user);

                //wyt 221021 XUQIU1000764 负责人、单选用户、多选用户、团队成员字段，“设置可选择的成员范围”增加“其他条件”参数控制
                $users_result_othercondition=$tmp_focus->getUserSelect_othercondition($current_fieldid);//选择成员范围其他条件
                $users_result=array_intersect_key($module_users,(array)$users_result_othercondition['users_result']);
                $module_users=implode(',',(array_keys($users_result)));

                if(!empty($module_users)){
                    $module_users_array = explode(',',$module_users);
                    //editor:gyq  Bug:0027232: (微信端)分配弹出层用户没有按照首字母排序。
                    $module_users_array = array_intersect(array_keys($users),$module_users_array);
                    $users = array_flip($module_users_array);
                }
                else{
                    $users = [];
                }
            }
            $user_arr = array_keys($users);
            foreach ($groupuser as $key=>$value){
                if($value['type']=='user'){
                    $parentid = $value['parentid'];
                    $userid = $value['id'];
                    if(count($user_arr) > 0 && !in_array($userid,$user_arr)){
                        continue;
                    }
                    //初始化用户对应部门的部门成员ID集合
                    $group_user_num[$parentid]['userids'][] = $userid;
                    if(!isset($user_output[$userid])){
                        $userdetailinfo = cls_StaticCommonFun::getUserDetailInfo($userid);
                        $user_output[$userid]['id'] = $userid;
                        
                        $userobj->id=$userid;
                        $userobj->last_name=$value['name'];
                        $userobj->wx_userid=$value['wx_userid'];
                        $user_output[$userid]['name'] = getUserlastName($userobj);//$value['name'];
                        $user_output[$userid]['lastname'] = $user_output[$userid]['name'];
                        $user_output[$userid]['wx_userid'] = $value['wx_userid'];
                        $user_output[$userid]['userimg'] = $userdetailinfo[0]['userimg'];
                        $user_output[$userid]['description'] = $userdetailinfo[0]['description'];
                        $user_output[$userid]['display']='yes';
                        $user_output[$userid]['status']=$value['status'];
                        if($iskehu001=='yes'&&$searchcontent!=''){
                            if(!in_array($value['wx_userid'],$searchuser_arr)){
                                 $user_output[$userid]['display']='no';
                            }
                        }
                    }
                }
            }
            //递归初始化无限上级部门的成员集合
            foreach ($group_user_num as $key=>$value){
                $parentid = $groupuser[$key]['parentid'];
                //20240701 hzx BUG20240627-41 微信小程序>首页>查看范围>按组织架构查看>每个部门显示的人数不对。
                if($groupuser[$key]['userids'] && count($groupuser[$key]['userids']) > 0){
                    $groupuser[$key]['userids'] = array_unique(array_merge($value['userids'],$groupuser[$key]['userids']));
                }else{
                    $groupuser[$key]['userids'] = $value['userids'];
                }
                $this->init_tree_num($parentid,$groupuser, $value['userids']);
            }
            //初始化最终输出的部门列表
            foreach ($groupuser as $key=>$value){
                if(is_array($value)&&$value['type']=='group'&&is_array($value['userids'])&&sizeof($value['userids']) > 0){
                    $groupid = $value['id'];
                    $group_user_output[$groupid]['usernum'] = count($value['userids']);
                    $group_user_output[$groupid]['userids'] = implode(',',$value['userids']);
                    $groupobj=new Users();
                    $groupobj->groupid=$groupid;
                    $groupobj->groupname=$value['name'];
                    $group_user_output[$groupid]['name'] = getWx_GroupName($groupobj);
                    $group_user_output[$groupid]['groupid'] = $groupid;
                }
            }
            
            if(isset($_REQUEST['recommon_designer'])&&$_REQUEST['recommon_designer']!=''){
                // 山水-特殊推荐设计师逻辑，按推荐规则重新排序
                $recommon_userids = $_REQUEST['recommon_designer'];
                
                if(is_array($recommon_userids)&&sizeof($recommon_userids)>0){
                    $pre_userout = $user_output;
                    $user_output = array();
                    foreach($recommon_userids as $key=>$userid){
                        $user_output[$key] = $pre_userout[$userid];
                    }
                }
            }
            
            //按部门主键降序排列
            ksort($group_user_output);
            $TrueTree['list_new'] = array_values($user_output) ;
            $TrueTree['list1'] = array_values($group_user_output);
            $TrueTree['list'] = array();

            return $TrueTree;
            //整体删除了原有的处理代码 init_tree_num新方法后面的旧方法似乎都用不到了
        }
        //editor:gyq_20190514 reason:初始化上级部门的成员集合
        protected function init_tree_num($r_parentid,&$r_totalgroup,$r_userids){
            static  $init_tree_static_count;
            //edit:can 20220508  52292 微信小程序>报表>工作汇报日志统计表：点击查看范围提示报错 
            if($init_tree_static_count>1100)
            return ;
            $init_tree_static_count++;
      
            if( isset($r_totalgroup[$r_parentid])){
                if(empty($r_totalgroup[$r_parentid]['userids']))
                    $r_totalgroup[$r_parentid]['userids']=array();
                $r_totalgroup[$r_parentid]['userids'] =array_unique(array_merge($r_userids,$r_totalgroup[$r_parentid]['userids']));
                $parentid = $r_totalgroup[$r_parentid]['parentid'];
                $this->init_tree_num($parentid,$r_totalgroup,$r_userids);
            }
        }
        protected function getTrueTree($tree){
            static $temparr;
            foreach($tree as $key=>$val){
                if(isset($val['groupid'])){
                    $this->getTrueTree($val['children']);
                    $valinfo = $this->getGroupUserNum($val['groupid']);
                    $cval['usernum'] = $valinfo['usernum'];
                    $cval['userids'] = $valinfo['userids'];
                    $cval['name'] = $val['name'];
                    $cval['groupid'] = $val['groupid'];
                    $temparr[$val['parentidvalue']][$val['groupid']] = $cval;
                }
                //unset($tree[$key]['children']);
            }
            return $temparr;
        }
        //获取部门对于的用户数
        protected function getGroupUserNum($groupid){
            global $adb,$current_user;
            if(empty($groupid)) return 0;
            crm_load_class_file('Group','modules/Users/Group.class.php');
            $group_focus = new Group();
            $groupuser=$group_focus->getGroupChild($groupid);
            foreach($groupuser as $ky=>$content)
            {
                $groupids[]=$content['groupid'];
            }
            $sql = 'SELECT
                    	 GROUP_CONCAT(DISTINCT ld_users.id) as userids
                    FROM
                    	ld_users
                    INNER JOIN ld_users2group ON ld_users2group.userid = ld_users.id
                    WHERE
                    	ld_users.id > 0 AND `status` = \'Active\'
                    AND ld_users2group.groupid IN ('.implode(',',$groupids).')';
            $result = $adb->pquery($sql);
            $entity = array();
            if($adb->num_rows($result)){
                $userids = $adb->query_result($result,0,0);
                if(empty($userids)){
                    $entity['usernum'] = 0;
                    $entity['userids'] = '';
                }else{
                    $entity['usernum'] = count(explode(',',$userids));
                    $entity['userids'] = $userids;
                }
            }
           	return $entity;
        }
        //获取单据共享人信息
        protected function getSharedUsers(){
            if($this->cls_methodObj->scopetype=='share'){
                global $adb,$current_user;
                $recordid = $_REQUEST['filterrecordid'];
                $query = 'select GROUP_CONCAT(DISTINCT viewuserid) AS userid from ld_tabshare 
                            where crmid = '.$recordid.' ';
                $result = $adb->pquery($query,array());
                $rows = $adb->num_rows($result);
                $userid = '';
                if($rows > 0){
                    $userid = $adb->query_result($result,0,'userid');
                }
                $this->shareduser = explode(',',$userid);
                $fld_module = $this->cls_methodObj->getModule();
                $share_focus = CRMEntity::getInstance($fld_module);
                $share_focus->id = $recordid;
                $share_focus->retrieve_entity_info($recordid, $fld_module);
                $smownerid = $share_focus->column_fields['assigned_user_id'];
                $deploy = getSys_deploy('33');
                $this->cancelshare = 'yes';
                if($deploy['deploy_value']==0&&$current_user->is_admin=='off'&&$smownerid!=$current_user->id){
                    $this->cancelshare = 'no';
                }
            }
        }
        //editor:gyq
        protected function groupuserDataFilter($data){
            foreach($data as $key =>$val){
                if($val['type'] == 'group'){
                    $data[$key]['groupid'] = $data[$key]['id'];
                    $data[$key]['children'] = $this->groupuserDataFilter(array_values($val['children']));
                    unset($data[$key]['id']);
                    unset($data[$key]['parentid']);                    
                }else{
                    $userdetailinfo = cls_StaticCommonFun::getUserDetailInfo($data[$key]['id']);
                    $data[$key]['children'] = array();
                    $data[$key]['userimg'] = $userdetailinfo[0]['userimg'];
                    unset($data[$key]['groupid']);
                    unset($data[$key]['parentid']);
                }
                unset($data[$key]['type']);
            }
            return $data;
        }
        /**
    	 * 获取部门下级部门
    	 * @param 2016-06-12
    	 * @return
    	 * @author Chj
    	 */
        private function getGroupsByTheLower(){
            //获取部门对应的下级部门
            if(empty($this->scope_grouparray)){
                $this->getGroups();
            }
            if(!empty($this->scope_grouparray)){
                foreach($this->scope_grouparray as $groupid){
                    $groupthelower = $this->groupobj->getGroupTheLower($groupid);
                    if($groupthelower == null){
                        $group_array[$groupid] = '';
                    }else{
                        $intersection = array_intersect($this->scope_grouparray,array_keys($groupthelower));
                        $group_array[$groupid] = $intersection;
                    }
                    
                }
            }
            return $group_array;
        }
        /**
    	 * 获取用户信息
    	 * @param 2016-06-12
    	 * @return
    	 * @author Chj
    	 */
		private function getUsers() {
            /** 
            * @edit:diony 
            * @date:2020-07-17
            * @reason:获取所有用户
            * @reason:设置移动端通讯录中是否显示离职人员。1:否，0:是
            * @description:$this->cls_methodObj->isactive 前端传值，目前没参考前端传值，直接读取后台参数
            */
            global $adb,$current_user;
            $deploy_values_213=getSys_deploy(213);
            if($deploy_values_213['deploy_value'] == 0){
                $users = get_user_array(false,'','');
            }
            else{
                $users = get_user_array(false,'Active','');
            }


            $this->getUserInfo();
            $current_module=$_REQUEST['return_module'];
            $fieldobj=Field::getInstance($current_module,$adb);
            if(isset($_REQUEST['fieldname'])&&!empty($_REQUEST['fieldname'])){
                $current_fieldname=$_REQUEST['fieldname'];
                $current_bigtype=$fieldobj->getFieldInfoBykeyValue('fieldname',$current_fieldname,'bigtype');
                $current_fieldid=$fieldobj->getFieldInfoBykeyValue('fieldname',$current_fieldname,'fieldid');
            }



            //wyt 220920 1000061 选用户（负责人、单选用户、多选用户、团队成员）字段控制只允许选择满足一定条件的数据 BUG0057215 企业微信移动端-销售线索，共享单据一直转圈
            if($current_bigtype == 'selectoneuser'||$current_bigtype == 'selectmultiuser'||
                $current_bigtype == 'users' ||(isset($_REQUEST['fieldname']) && $_REQUEST['fieldname'] == 'team_memberid')){
                crm_load_class_file('cls_EditView_OutPut','include/utils');
                $tmp_focus=new cls_EditView_OutPut();
                $module_users=$tmp_focus->getUserSelect($current_fieldid,$users,$current_module,$current_user);

                //wyt 221021 XUQIU1000764 负责人、单选用户、多选用户、团队成员字段，“设置可选择的成员范围”增加“其他条件”参数控制
                $users_result_othercondition=$tmp_focus->getUserSelect_othercondition($current_fieldid);//选择成员范围其他条件
                $users_result=array_intersect_key($module_users, (array)$users_result_othercondition['users_result']);
                $module_users=implode(',',(array_keys($users_result)));

                if(!empty($module_users)){
                    $module_users_array = explode(',',$module_users);
                    //editor:gyq  Bug:0027232: (微信端)分配弹出层用户没有按照首字母排序。
                    $module_users_array = array_intersect(array_keys($users),$module_users_array);
                    $users = array_flip($module_users_array);
                }
                else{
                    $users = '';
                }
            }
            //显示范围
            else if(!isset($_REQUEST['checkprivilege'])||$_REQUEST['checkprivilege']!='no') //checkprivilege：工作汇报 点评  //if($this->cls_methodObj->getSearchType() != 'all'){
            {
                if($this->cls_methodObj->getModule()=='Home'){
                    $module_users = getCurSmOwnerSearchScope('Home');
                    $module_users = implode(',',array_keys($module_users['UserCombo']));
                }
                else{
                  
                    $module_users = $this->groupobj->getModuleListUser($this->cls_methodObj->getModule());
                }
                 
                if(!empty($module_users)){
                    $module_users_array = explode(',',$module_users);
                    //editor:gyq  Bug:0027232: (微信端)分配弹出层用户没有按照首字母排序。
                    $module_users_array = array_intersect(array_keys($users),$module_users_array);
                    $users = array_flip($module_users_array);
                }
                else{
                    $users = '';
                }
                //当前登录用户数据范围内的用户
                $sharebyusers = $this->groupobj->getScopeOfShareUsers($this->cls_methodObj->getModule());
				// $deploy_values=getSys_deploy(110);	//分配弹出层是否显示所有用户设置为否 1否  0是
                if($sharebyusers != 'yes'){


					//分配和选择负责人
					if((!empty($_REQUEST['popup_type']) && $_REQUEST['popup_type'] == 'Allocate') || (!empty($_REQUEST['searchtype']) && $_REQUEST['searchtype'] == 'byscope')){
						// if($deploy_values['deploy_value'] == 1){
						// 	$sharebyusers[getUserFullName($this->user_obj->id)] = $this->user_obj->id;
						// 	$sharebyusers = array_intersect($sharebyusers,array_keys($users));
						// 	$users = array_flip($sharebyusers);
						// }
					}else{
						$sharebyusers[getUserFullName($this->user_obj->id)] = $this->user_obj->id;
						$sharebyusers = array_intersect($sharebyusers,array_keys($users));
						$users = array_flip($sharebyusers);
					}
                }
            }
            $res = array_intersect_key($this->userbyinfo,$users);

            //公海分配的用户只能是公海用户
            if($_REQUEST['popup_type']=='PublicAllocate'){
                foreach($res as $key=>$val){
                    $publicids = $this->getPublicAccountUsers();
                    if(in_array($key,$publicids)){
                        $publicres[$key] = $val;
                    }
                }
                return $publicres;
            }
            return $res;
		}
		/**
		 * 获取用户信息
		 * @param
		 * @return(userid：用户id，username:用户名,lastname:用户姓名,profilename:用户权限,userlevel:用户级别,phone_mobile,phone_home,userimgpath，userimgname)
		 * @author Chj
		 */
		private function getUserInfo(){
            /*editor:gyq_29 date:20170328 reason:代码优化 */
			$workreportmoduleobj = crm_load_class_obj('WorkReportModelWX','WeiXinApp/modules/Home');
			$userinfo =  $workreportmoduleobj->getUserArray();
            if(!empty($userinfo)){
				foreach($userinfo as $info){
				    unset($info['username']);
                    if($this->cls_methodObj->getModule()!='adressbook'){
                        unset($info['phone_mobile']);
                        unset($info['phone_home']);
                    }
                    if($this->cls_methodObj->getModule()=='Work'){
                        unset($info['profilename']);
                        unset($info['userlevel']);
                    }
                    unset($info['userimgname']);
                    // unset($info['status']);
					$this->userbyinfo[$info['userid']['value']] = $info;
				}
			}        
		}
        
        //获取公海用户id(low)
        public function getPublicAccountUsers(){
            global $adb;
			$publicid = [];
			if(!empty($_REQUEST['pool_id'])){
                if($this->cls_methodObj->module == 'Accounts'){
                    crm_load_class_file('cls_PublicAccounts', 'modules/Accounts');
                    $cls_PublicAccounts = new cls_PublicAccounts($this->cls_methodObj->module);

                }
                elseif($this->cls_methodObj->module == 'Leads'){
                    crm_load_class_file('cls_PublicLeads', 'modules/Leads');
                    $cls_PublicAccounts = new cls_PublicLeads($this->cls_methodObj->module);
                }
				$public_account = $cls_PublicAccounts->getPublicAccountConfig();
				if($public_account['status'] == 'yes'){
					$adminaccount = $public_account['public_account_pool'][$_REQUEST['pool_id']]['administrators'];
					$useraccount = $public_account['public_account_pool'][$_REQUEST['pool_id']]['userids'];
					 if(!empty($adminaccount) && !empty($useraccount))
						$sql="select id  from ld_users  where ( id in ( ".$adminaccount.') or id in ('.$useraccount.') or is_admin="on" ) and status="active"';
					elseif(!empty($adminaccount) && empty($useraccount))
						$sql="select id  from ld_users  where ( id in ( ".$adminaccount.')  or is_admin="on" ) and status="active"';
					elseif((empty($adminaccount) && !empty($useraccount)))
						$sql="select id  from ld_users  where ( id in (".$useraccount.') or is_admin="on" ) and status="active"';
					else
						$sql="select id  from ld_users  where   is_admin='on'  and status='active' ";
					$result=$adb->pquery($sql,array());
					$num_rows = $adb->num_rows($result);
					for($i=0;$i<$num_rows;$i++){
						$publicid[] = $adb->query_result($result,$i,'id');
					}
				}
			}
            /*$useraccount=getAccount_Set('usersaccount');
            $adminaccount=getAccount_Set('adminaccount');
            if(!empty($adminaccount) && !empty($useraccount))
            $sql="select id  from ld_users  where ( id in ( ".$adminaccount.') or id in ('.$useraccount.') or is_admin="on" ) and status="active"';
            elseif(!empty($adminaccount) && empty($useraccount))
            $sql="select id  from ld_users  where ( id in ( ".$adminaccount.')  or is_admin="on" ) and status="active"';
            elseif((empty($adminaccount) && !empty($useraccount)))
            $sql="select id  from ld_users  where ( id in (".$useraccount.') or is_admin="on" ) and status="active"';
            else
            $sql="select id  from ld_users  where   is_admin='on'  and status='active' ";
            
            $result=$adb->pquery($sql,array());
            $num_rows = $adb->num_rows($result);
            for($i=0;$i<$num_rows;$i++){
                $publicid[] = $adb->query_result($result,$i,'id');
            }*/
            return $publicid;
        }
	}	
?>