<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2015-03-17
 */
// 部门操作方法类
class Group {
	public $groupid;
	public $groupname;
	public $groupno;
	public $group_cache_key = 'cache_getgrouplist_array';
	public $group_parent_key = '';
    public $grouparrayMC ;//移动端多层树 eidor:gyq date:20170324
    public $group_userid_arr=[];
    public $group_type = 'all';//部门类型,crm/prm
    public $is_hidden = '';
    public static $showgroupid_arr;//有数据范围的部门id  zxm20240625
    public static $triggertype = '';
	public $showallgroupstructure;
	
	//删除所有部门 gyq  20171222
	public function deleteAllGroup(){
		global $adb;
		$sql = 'DELETE from ld_groups WHERE parentid <> -1';
		$adb->pquery($sql, array());
	}
    public static function getInstance()
    {
        static  $static_group_arr;
        if(is_array($static_group_arr))
        {
            return $static_group_arr[0];
        }
        $static_group_arr=[];
        $static_group_arr[0]=new Group();
        return $static_group_arr[0];
    }
    /**
     * 获取所有部门信息
     * @project PROT180 角色权限改进
     * @author Tujt 2015-03-17
     */
    public function getGrouplist() {
		/*static $static_grouplist_array;
		if(!empty($static_grouplist_array)){
			return $static_grouplist_array;
		}*/
		$grouparray = Cache($this->group_cache_key);
		if(!is_array($grouparray)){
			$grouparray = array();
			global $adb;
			$query = 'SELECT groupid,groupname,description,depth,parentid,parentgroup,group_no
						FROM ld_groups WHERE groupid > 0 ORDER BY CONCAT("::",parentgroup,"::");';
			$result = $adb->pquery($query,array());
			$rows = $adb->num_rows($result);
			if($rows > 0){
				for($i=0;$i<$rows;++ $i){
					$groupid = $adb->query_result($result,$i,'groupid');
					$groupname = $adb->query_result($result,$i,'groupname');
					$description = $adb->query_result($result,$i,'description');
					$depth = $adb->query_result($result,$i,'depth');
					$parentid = $adb->query_result($result,$i,'parentid');
					$parentgroup = $adb->query_result($result,$i,'parentgroup');
                    $group_no = $adb->query_result($result,$i,'group_no');
					$grouparray[$groupid]['groupid'] = $groupid;
                 //   $this->groupid=$groupid;
                //   $this->groupname=$groupname;
                	$groupobj=new Group();
                	$groupobj->groupid=$groupid;
                	$groupobj->groupname=$groupname;
                	$groupobj->groupno=$group_no;
					$grouparray[$groupid]['groupname'] =getWx_GroupName($groupobj);// getWx_GroupName($groupobj);//$groupname;//
					$grouparray[$groupid]['description'] = $description;
					$grouparray[$groupid]['depth'] = $depth;
					$grouparray[$groupid]['parentid'] = $parentid;
					$grouparray[$groupid]['parentgroup'] = $parentgroup;
					$grouparray[$groupid]['group_no'] = $group_no;

				}
				Cache($this->group_cache_key,$grouparray);
		}
	}
       
		if(!empty($grouparray)){
			return $static_grouplist_array = $grouparray;
		}
		return '';
    }
    
	/**
	 * 清除部门缓存
	 * @project PROT180 角色权限改进
	 * @author Tujt 2015-03-19
	 */
	public function unsetGroupList() {
	    unsetCache($this->group_cache_key);
	}
    public function setshowgroupid_arr($showgroupid_arr){
        self::$showgroupid_arr = $showgroupid_arr;
    }
	/**
	 * 二维数组转多维数组
	 * @param Array $array 二维数组
	 * @param String $parentid 上级键值，默认为 parentid
	 * @returns Array 多维数组
	 * @project PROT180 角色权限改进
	 * @author Tujt 2015-03-18
	 */
	public function setOneParent($array,$parentid = '') {
		$tree = '';
		if(empty($parentid)) $parentid = 'parentid';
        foreach($array as $id=>$arr){
	    // 处理成树状结构显示的数组
           
			if($arr['parentid']){//传引用
				$array[$arr['parentid']]['children'][$id] = &$array[$id];				
			}
			if(-1 == $arr['parentid']){
			
				$tree = $arr[$parentid];
			}
		}
		if(isset($array[$tree]['children'])){
			$array = $array[$tree]['children'];
			return $array;
		}
        if($this->showallgroupstructure == 'no'&&!empty($this->group_parent_key)){
            $array[$this->group_parent_key] = self::getgrouphaveUsers2($array[$this->group_parent_key],'yes');
        }
		return $array;
	}
	//zkt 20231108 XUQIU1001871 分配与查看范围，分配时可见成员根据数据范围显示，不显示全部成员
	//若没权限看到的用户，则不显示部门组织架构
    public static function getgrouphaveUsers2($grouparray,$parentkey)
    {
        $showgroupid_arr=self::$showgroupid_arr;//在数据范围内的用户所属的部门ID zxm 20240625

        $newgroupcildren = [];
        $tmpgroupchildren = $grouparray['children'];
        if($parentkey != 'yes')
            unset($grouparray['children']);
        foreach($tmpgroupchildren as  $key=>$groupinfo )
        {

            if(stripos($key,'group_')!==false)
            {

                $tmpchildgroup = self::getgrouphaveUsers2($groupinfo,'no');
                if(!empty($tmpchildgroup)){
                    $newgroupcildren[$key] = $tmpchildgroup;
                }
            }
            else if(stripos($key,'user_')!==false)
            {
                $newgroupcildren[$key] = $groupinfo;
            }
        }//die();
        if(!empty($newgroupcildren)){
            $grouparray['children'] = $newgroupcildren;
        }
        else if(!empty($showgroupid_arr)&&empty($tmpchildgroup['children'])&&!in_array($grouparray['groupid'],$showgroupid_arr)){
            $grouparray = [];
        }else if($parentkey != 'yes'&&empty($showgroupid_arr)){
            $grouparray = [];
        }
        return $grouparray;
    }
     /**
     * 设置部门树结构
     * */
    public function setGroupChildTree($array,$treename='',$parent='',$parent_groupid='')
    {
        if(empty($array)) return false;
		if(empty($treename)) $treename = 'name';
		if(empty($parent)) $parent = 'parent';
   
		static $staticGroupChildTreeIdx;//判断是否递归调用状态

		$staticGroupChildTreeIdx = 1;
		$checkbox = '';
        $popup_inputtype = 'popup_inputtype';
        
		
		foreach($array as $id=>$arr){
		   if(isset($arr['children']) && !empty($arr['children']))
           {
              $tree.='<li><span name="group_expand_collapse" depth="'.$arr['depth'].'" class="group_node_expand tree-right"></span>';
           }
           else
           {
                $tree .= '<li>';
           }
			
            $folder = '';$children = '';
            $group_arr = explode('_',$id);
	
				if(isset($arr['children']) && !empty($arr['children'])){
					$label = '<label>'.$arr[$treename].'</b></label>';
				}else{
					$label = '<label>'.$arr[$treename].'</label>';
				}
			
         
			     $folder = '<span class="file" tag="user_group" depth="'.$arr['depth'].'" record="'.$id.'" parent="'.$arr[$parent].'">'.$label.'</span>';
			
			if(isset($arr['children']) && !empty($arr['children'])){
                //如果有下级，则递归调用
				$children = $this->setGroupChildTree($arr['children'],$treename,$parent,$group_arr[1]);
			}
			$tree .= $folder.$children;
			$tree .= '</li>';
		}
	//	$tree .= '</ul>';
		return $tree;
    }
    
    /**
     * 设置部门树结构
     * */
    public function setGroupExpandTree($array,$parent_groupid='',$nowdepth=0,$childdepth=0,$parentchild=-1)
    {
        if(empty($array)) return false;
		$treename = 'name';
		$parent = 'parent';
        $isDepartmentNubmer=getSys_deploy(478);
        $isDepartmentRemark=getSys_deploy(477);
		static $expandstaticGroupreeListIdx;//判断是否递归调用状态
		if(1 == $expandstaticGroupreeListIdx && $parent != 'selectprofileuser') { 
            if($childdepth>=($nowdepth+1)&&$childdepth!=1)
                $tree = '<ul style="display:none" depth="'.$childdepth.'">';
            else
            	$tree = '<ul depth="'.$childdepth.'">';
        }
        else{
        	$tree = '<ul class="filetree filetreeTop" id="viewuserlist">';
        }
		if($parent == 'selectprofileuser'){//选择角色、用户
			$tree = '<ul class="filetree" id="viewprofilelist">';
		}
	
		$expandstaticGroupreeListIdx = 1;
		$checkbox = '';
        $popup_inputtype = 'popup_inputtype';
        $iskehu001pc=isKehu001ServerPc();
		//	dump($array);
		foreach($array as $id=>$arr){
	        $depth=(int)($arr['depth']);
	        //部门用div封装，div头部
	        $divhtml='<div class="groupuser-treediv" name="user_group" onmouseover="showGroupMenu(this)" onmouseout="hideGroupMenu(this)">';
	        
	        //客户001用户不显示上移、下移、更多div
	        if($iskehu001pc=='yes'){
	            $opdivhtml='';
	        }
	        else{
	            //上移、下移、更多div
	            $opdivhtml='<div class="groupuser-treediv-btn" name="operate_group">
		                     <a class="gutree-btn_moveup" tag="moveup" title="'.getFixedLabel('MOVEUP').'"></a>
		                     <a class="gutree-btn_movedowm" tag="movedown" title="'.getFixedLabel('MOVEDOWN').'"></a>';
	            //至少拥有新增、编辑、删除权限之一，显示更多按钮
	            if(isPermitted("Users","Create")=='yes'||isPermitted("Users","EditView")=='yes'||isPermitted("Users","Delete")!='yes'){
	                $opdivhtml.='<a class="gutree-btn_more" tag="more" title="'.getFixedLabel('MORE').'"></a>';
	            }
	            $opdivhtml.='</div>';
	        }
	        if(isset($arr['children']) && !empty($arr['children'])){
	            if($arr['depth']=='0'||$arr['depth']=='1'){
	                $tree .= '<li>'.$divhtml.'<div class="groupuser-treediv-span"><span name="group_expand_collapse"  depth="'.$arr['depth'].'" class="group_node_collapse tree-down"></span>';
	            }
	            else{
	            	$tree .= '<li>'.$divhtml.'<div class="groupuser-treediv-span"><span name="group_expand_collapse" depth="'.$arr['depth'].'" class="group_node_expand tree-right"></span>';
	            }
	        }
	        //zkt 	0047836: （http://4192q671o7.qicp.vip:27019:85/crm [^] 本地V8438）（需要补丁）系统设置-成员管理，当系统只有一个上级部门时，编辑该部门时 提示上级部门不为空
	        else{
	            $tree .= '<li>'.$divhtml.'<div class="groupuser-treediv-span"><span group_margin_right="'.$arr['depth'].'" style="margin-right:15px" depth="'.$arr['depth'].'"></span>';
	        }   
            $folder = '';$children = '';
            $group_arr = explode('_',$id);
            
            $this->groupid=$group_arr[1];
            $this->groupname=$arr[$treename];
            $groupname = getWx_GroupName($this);
            $parentchild= $arr['parentidvalue']==-1?$this->groupid:$parentchild.'^_^'.$this->groupid;
                if($iskehu001pc=='yes')
                {
                    if(isset($arr['children']) && !empty($arr['children'])){
    					$label = '<label>'.$groupname. '</label>';
    				}
    				else{
    					$label = '<label>'.$groupname.'</label>';
    				}
                }
                else
                    // zsk2024/5/28XUQIU1001465 成员管理，组织架构->根部门，更多下拉选项中增加“字段设置”参数.将部门编号套一个span标签
                    //不启用部门编号字段
                    if($isDepartmentNubmer["deploy_value"]=='no') {
                        if (isset($arr['children']) && !empty($arr['children'])) {
                            $label = '<label>' . $groupname .'<span class="departmentNumber" style="display: none">(' . $arr["group_no"] . ')</span></label>';
                        } else {
                            $label = '<label>' . $groupname .'<span class="departmentNumber" style="display: none">(' . $arr["group_no"] . ')</span></label>';
                        }
                    }
                    //启用部门编号字段,如果为其他值(包括空)默认启用
                   else{
                       if (isset($arr['children']) && !empty($arr['children'])) {
                           $label = '<label>' . $groupname .'<span class="departmentNumber">(' . $arr["group_no"] . ')</span></label>';
                       } else {
                           $label = '<label>' . $groupname .'<span class="departmentNumber">(' . $arr["group_no"] . ')</span></label>';
                       }
                    }
			
         
			     $folder = "<span class='file' depth='".$arr['depth']."' tag='user_group' record='".$id."' parent='".$arr[$parent]."' key='".$this->groupid."' parentchild='".$parentchild."' data-tip='".$groupname."' data-direction='top' data-type='position'>".$label."</span>";
                 $folder .=$opdivhtml;
                 $folder .='</div></div>';//部门封装div尾部
			if(isset($arr['children']) && !empty($arr['children'])){
                //如果有下级，则递归调用
				$children = $this->setGroupExpandTree($arr['children'],$group_arr[1],$nowdepth,$arr['depth'],$parentchild);
			}
			$tree .= $folder.$children;
			$tree .= '</li>';
		}
		$tree .= '</ul>';
      
		return $tree;
    }
    
    /**
     * 设置部门树结构
     * */
    public function setGroupTree($array,$treename='',$parent='',$parent_groupid='')
    {
        if(empty($array)) return false;
		if(empty($treename)) $treename = 'name';
		if(empty($parent)) $parent = 'parent';
   
		static $staticGroupreeListIdx;//判断是否递归调用状态
		if(1 == $staticGroupreeListIdx && $parent != 'selectprofileuser') $tree = '<ul>';
		else $tree = '<ul class="filetree" id="viewuserlist">';
		if($parent == 'selectprofileuser'){//选择角色、用户
			$tree = '<ul class="filetree" id="viewprofilelist">';
		}
	
		$staticGroupreeListIdx = 1;
		$checkbox = '';
        $popup_inputtype = 'popup_inputtype';
      
		
		foreach($array as $id=>$arr){

         
                $tree .= '<li>';
                
            $folder = '';$children = '';
            $group_arr = explode('_',$id);
	            $this->groupid=$arr['groupid'];
                 $this->groupname=$arr['name'];
				if(isset($arr['children']) && !empty($arr['children'])){
					$label = '<label><b>'.getWx_GroupName($this).'</b></label>';
				}else{
					$label = '<label>'.getWx_GroupName($this).'</label>';
				}
			
         
			     $folder = '<span class="file" tag="user_group" record="'.$id.'" parent="'.$arr[$parent].'">'.$label.'</span>';
			
			if(isset($arr['children']) && !empty($arr['children'])){
                //如果有下级，则递归调用
				$children = $this->setGroupTree($arr['children'],$treename,$parent,$group_arr[1]);
			}
			$tree .= $folder.$children;
			$tree .= '</li>';
		}
		$tree .= '</ul>';
		return $tree;
    }
	/**
	 * 将多维数组转换为树状结构图(UL)
	 * @param Array $array 带上下级的多维数组
	 * @param String $treename 数组中名称的键值
	 * @param String $parent 数组中上下级状态的键值
	 * @returns HTML 树状结构图可以用到的ul->li结构
	 * @project PROT180 角色权限改进
	 * @author Tujt 2015-03-18
	 */
	public function setTreeList($array,$isbox,$treename='',$parent='',$parent_groupid='') {
	    if(empty($array)) return false;
		if(empty($treename)) $treename = 'name';
		if(empty($parent)) $parent = 'parent';
        if(empty($isbox)) $isbox = 'checkbox';
        // dump($array);

        $subgroupcheckbox=$_REQUEST['subgroupcheckbox'];//判断是否选择了勾选子部门默认收起：checked勾选；unchecked未勾选。
		static $staticSetTreeListIdx;//判断是否递归调用状态
		if(1 == $staticSetTreeListIdx && $parent != 'selectprofileuser')
        {
            //若勾选了子部门默认收起则子部门成员不显示
            if($subgroupcheckbox == 'checked' && $array[key($array)]['parentidvalue']!=1)
            {
                $tree = '<ul style="display:none">'; 
            }
            else
            {
                $tree = '<ul>'; 
            }
        }
		else $tree = '<ul class="filetree" id="viewuserlist">';
		if($parent == 'selectprofileuser'){//选择角色、用户
			$tree = '<ul class="filetree" id="viewprofilelist">';
		}
		if($parent == 'selectaccount'){//客户
			$tree = '<ul class="filetree" id="viewaccountlist">';
		}
		$staticSetTreeListIdx = 1;
		$checkbox = '';
	    $popup_inputtype = 'popup_inputtype';
	    //只有在选择用户时，才生效
	    if(!empty($parent_groupid) && !empty($_REQUEST['popup_selecttype']) && $_REQUEST['popup_selecttype'] == 'user'){
	        $popup_inputtype .= '_' . $parent_groupid;  
	    }
		if($parent != 'selectaccount'){
			if($isbox == 'radio'){
				$checkbox = '<input class="checkbox-item j-all-radio" type="'.$isbox.'" border="0" name="'.$popup_inputtype.'" tag="popup_inputtype" ';
			}
			// else if($isbox == 'recover'){
			// 	$checkbox = '<input class="checkbox-item" type="'.$isbox.'" border="0" name="'.$popup_inputtype.'" tag="popup_inputtype" ';
			// }
			else{
				$checkbox = '<input class="checkbox-item j-all-checkbox" type="'.$isbox.'"  border="0" name="'.$popup_inputtype.'" tag="popup_inputtype"  ';
				if(self::$triggertype == 'recover'){
					$checkbox.= 'style="display:none;"';
				}
			}			
		}
        $checkbox_display = '<input class="checkbox-item j-all-checkbox" style="display:none;" type="'.$isbox.'" border="0" name="'.$popup_inputtype.'" tag="popup_inputtype" ';

        $checkbox_end='>';
     
        //wyt 221216 BUG0058970 选人控件弹出层，点击后面文字无法选中前面选择框，建议优化  因为树结构为group时，点击会展开收起，为了同时不让其全选，所以$group_arr[0]为'group'时label不添加for属性
        foreach($array as $id=>$arr){
			$tree .= '<li';
			if(self::$triggertype !="recover" && $arr['is_hidden']=="yes"){
				$tree .= ' style="display: none;">';
			}else{
				$tree .= '>';
			}

			$folder = '';$children = '';
            $group_arr = explode('_',$id);
            $id_for_label_value='';
            if($group_arr[0]!='group'){
                if(empty($parent_groupid))
                {
                    $id_for_label='id_label_'.$group_arr[0].'_'.$group_arr[1]."_".$arr['groupid'];
//                         $id=$group_arr[0].'_'.$group_arr[1]."_".$arr['groupid'];//BUG0076910 lius 20231211 成员管理模块，太原促销组修改上级部门为晋蒙区促销组，修改后不能保存（$id表示是groupid）
                }
                else
                {
                 $id_for_label='id_label_'.$group_arr[0].'_'.$group_arr[1]."_".$parent_groupid;
//                    $id=$group_arr[0].'_'.$group_arr[1]."_".$parent_groupid;
                }
                $id_for_label_value=' id="'.$id_for_label.'"';
            }
            $tmpgroupno='groupno="'.$arr['group_no'].'"';
            if('group' == $_REQUEST['popup_selecttype']){
			     $this->groupid=$arr['groupid'];
                 $this->groupname=$arr['name'];
				if(isset($arr['children']) && !empty($arr['children'])){
					$label = '<label for="'.$id_for_label.'">'.getWx_GroupName($this).'</label>';
				}else{
					$label = '<label for="'.$id_for_label.'">'.getWx_GroupName($this).'</label>';
				}
			}else{
			    if( $group_arr[0]=='group')
			    {
			        $this->groupid=$arr['groupid'];
                    $this->groupname=$arr['name'];
                 	$label = '<label>'.getWx_GroupName($this).'</label>';
			    }
	           	else
	           	{
                    $userobj=new Users();
                    $userobj->last_name=$arr[$treename];
                    $userobj->wx_userid=$arr['wx_userid'];
                    $status=!empty($arr['status'])?explode('_',$arr['status']):[];
                    $field='';
                    if ($status[0] == 'Inactive'||$status[1] == 'Inactive')
                    {
                        $field =  "<font color='red'>（" . getFixedLabel('Quit'). "）</font>";
                    }
                    $label = '<label for="'.$id_for_label.'">'. getUserlastName($userobj).$field.'</label>';
                    //zkt 0046464: （81mis.com/kfbcrm）客户管理-客户；系统参数中设置了“新增合同后变更客户状态为成交客户”，单据中客户状态为空值时，没有变为成交客户
                    //设置无部门未离职成员名颜色为红色
                    if($status[0]=='nogroup')
                    {
                        $label= '<label for="'.$id_for_label.'" style="color:red;">'. getUserlastName($userobj).$field.'</label>';
                    }
                }
			}
		    if('group' == $group_arr[0] && $isbox == 'radio' && $_REQUEST['popup_selecttype'] == 'user'){
		        if($subgroupcheckbox == 'checked' && $array[$id]['parentidvalue']!=-1)//勾选子部门默认收起部门前图标向右
		        {
		            $folder = '<span class="file user-right-tip" record="'.$id.'" parent="'.$arr[$parent].'">&nbsp;'.$checkbox_display.$id_for_label_value.$checkbox_end.$label.'</span>';
		        }
		        else
		        {
		     		$folder = '<span class="file" record="'.$id.'" parent="'.$arr[$parent].'">&nbsp;'.$checkbox_display.$id_for_label_value.$checkbox_end.$label.'</span>';
		        }
		    }else{
			    if($subgroupcheckbox == 'checked' && $array[$id]['parentidvalue']!=-1)//勾选子部门默认收起部门前图标向右
		        {
		            $folder = '<span class="file user-right-tip" record="'.$id.'" parent="'.$arr[$parent].'">&nbsp;'.$checkbox.$id_for_label_value.$checkbox_end.$label.'</span>';
		        }
		        else
		        {
		            //edit:can 20230106 60427 中亿丰——上下级关系显示问题，例 ：客户：苏州广信置业有限公司 
		            if(empty($checkbox))
		                $folder = '<span class="file" record="'.$id.'" parent="'.$arr[$parent].'">&nbsp;'.$checkbox.$label.'</span>';
		            else
		                $folder = '<span class="file" record="'.$id.'" parent="'.$arr[$parent].'">&nbsp;'.$checkbox.$tmpgroupno.$id_for_label_value.$checkbox_end.$label.'</span>';
			    }
		    }
			if(isset($arr['children']) && !empty($arr['children'])){
                //如果有下级，则递归调用
				$children = $this->setTreeList($arr['children'],$isbox,$treename,$parent,$group_arr[1]);
			}
			$tree .= $folder.$children;
			$tree .= '</li>';
		}
		$tree .= '</ul>';
		return $tree;
	}

    /**
     * 将多维数组转换为树状结构图(UL)
     * @param Array $array 带上下级的多维数组
     * @param String $treename 数组中名称的键值
     * @param String $parent 数组中上下级状态的键值
     * @returns HTML 树状结构图可以用到的ul->li结构
     */
    //@edit:liushuai,2020-11-10,reason:【ID1001080】增加“会话存档”模块(setTreeList方法改造而来)
    public function setTreeListForWechatSession($array,$isbox,$treename='',$parent='',$parent_groupid='') {
        global $current_user;
        if(empty($array)) return false;
        if(empty($treename)) $treename = 'name';
        if(empty($parent)) $parent = 'parent';
        if(empty($isbox)) $isbox = 'checkbox';
        static $staticSetTreeListIdx;//判断是否递归调用状态
        if(1 == $staticSetTreeListIdx && $parent != 'selectprofileuser'){
        	$tree = '<ul>';
        }
        else{
        	$tree = '<ul class="filetree" id="viewuserlist">';
        }
        if($parent == 'selectprofileuser'){//选择角色、用户
            $tree = '<ul class="filetree" id="viewprofilelist">';
        }
        if($parent == 'selectaccount'){//客户
            $tree = '<ul class="filetree" id="viewaccountlist">';
        }
        $staticSetTreeListIdx = 1;
        $checkbox = '';
        $popup_inputtype = 'popup_inputtype';
        //只有在选择用户时，才生效
        if(!empty($parent_groupid) && !empty($_REQUEST['popup_selecttype']) && $_REQUEST['popup_selecttype'] == 'user'){
            $popup_inputtype .= '_' . $parent_groupid;
        }
        /*if($parent != 'selectaccount'){
            if($isbox == 'radio'){
                $checkbox = '<input  type="'.$isbox.'"  name="'.$popup_inputtype.'" tag="popup_inputtype">';
            }else if($isbox == 'hidden'){
                $checkbox = '<input  type="'.$isbox.'" name="'.$popup_inputtype.'" tag="popup_inputtype">';
            }
            else{
                $checkbox = '<input  type="'.$isbox.'" name="'.$popup_inputtype.'" tag="popup_inputtype">';
            }
        }*/
        $checkbox_display = '<input class="checkbox-item j-all-checkbox" style="display:none;" type="'.$isbox.'" border="0" name="'.$popup_inputtype.'" tag="popup_inputtype">';

        foreach($array as $id=>$arr){
            $tree .= '<li>';$folder = '';$children = '';
            $group_arr = explode('_',$id);
            if('group' == $_REQUEST['popup_selecttype']){
                $this->groupid=$arr['groupid'];
                $this->groupname=$arr['name'];
                if(isset($arr['children']) && !empty($arr['children'])){
                    $label = '<label><b>'.getWx_GroupName($this).'</b></label>';
                }
                else{
                    $label = '<label>'.getWx_GroupName($this).'</label>';
                }
            }
            else{
                if( $group_arr[0]=='group'){
                    $this->groupid=$arr['groupid'];
                    $this->groupname=$arr['name'];
                    $label = '<label>'.getWx_GroupName($this).'</label>';
                }
                else{
                    $userobj=new Users();
                    $userobj->last_name=$arr[$treename];
                    $userobj->wx_userid=$arr['wx_userid'];

                    // $label = '<span block="member"><input type="hidden" userid="'.$arr['groupid'].'" name="wx_userid" value="'.$arr['wx_userid'].'"><label>'. getUserlastName($userobj).'</label></span>';
                    $label = '<label><input type="hidden" userid="'.$arr['groupid'].'" name="wx_userid" value="'.$arr['wx_userid'].'">'. getUserlastName($userobj).'</label>';
                }
            }

            if('group' == $group_arr[0] && $isbox == 'radio' && $_REQUEST['popup_selecttype'] == 'user'){
                $folder = '<span class="file" record="'.$id.'" parent="'.$arr[$parent].'">&nbsp;'.$checkbox_display.$label.'</span>';
            }
            else{
                if ($arr['type'] == 'user') {  //成员列表头像。
                    $imagepath = $current_user->getUserImage($arr['groupid']);
                    $folder = '<div class="groupuser-treediv">';
                    $folder .= '<div class="groupuser-treediv-span">';
                    $folder .= '<span style="display:block;cursor:pointer;" block="member" class="file" record="'.$id.'" parent="'.$arr[$parent].'">'.'<img width="30px" style="padding-left:5px;" src="'.$imagepath.'"> '.$checkbox.$label.'</span>';
                    $folder .= '</div></div>';
                }
                else{
                	$folder = '<div class="groupuser-treediv">';
                    $folder .= '<div class="groupuser-treediv-span">';
                    $folder .= '<span class="file" record="'.$id.'" parent="'.$arr[$parent].'">'.$checkbox.$label.'</span>';
                    $folder .= '</div></div>';
                }
            }
            if(isset($arr['children']) && !empty($arr['children'])){
                //如果有下级，则递归调用
                $children = $this->setTreeListForWechatSession($arr['children'],$isbox,$treename,$parent,$group_arr[1]);
            }
            $tree .= $folder.$children;
            $tree .= '</li>';
        }
        $tree .= '</ul>';
        return $tree;
    }


	/**
	 * 传入部门ID，回传部门信息
	 * @param Integer $groupid 部门ID
	 * @return Array 部门信息数组
	 * @project PROT180 角色权限改进
	 * @author Tujt 2015-03-19
	 */
	public function getGroupInfoByid($groupid) {
	    $grouplist = $this->getGrouplist($groupid);
		if(isset($grouplist[$groupid])){
			return $grouplist[$groupid];
		}
		return '';
	}
	/**
	 * 获取部门表下一个ID
	 * @author Tujt 2015-03-19
	 */
	public function getGroupNextId() {
		global $adb;
	    $query = 'SELECT MAX(groupid) AS groupid FROM ld_groups ORDER BY groupid;';
		$result = $adb->pquery($query,array());
		$rows = $adb->num_rows($result);
		if($rows > 0){
			$groupid = $adb->query_result($result,0,'groupid');
			return ++ $groupid;
		}
		return '';
	}
	/**
	 * 修改部门所有下级部门的级别
	 * @param Integer $fromid 部门ID
	 * @param Integer $toid 部门上级ID
	 * @project PROT180 角色权限改进
	 * @author Tujt 2015-03-20
	 */
	public function GroupDragDrop($fromid,$toid) {
	    global $adb;
		$lowerarr = $this->getGroupTheLower($fromid);//获取部门所有下级部门信息
		$parentarr = $this->getGroupInfoByid($toid);//获取上级部门信息
		if(!empty($lowerarr)){
			foreach($lowerarr as $id=>$lower){//循环下级部门信息
				$from_parentarr = explode('::'.$fromid.'::',$lower['parentgroup']);
				$parentgroup = $parentarr['parentgroup'].'::'.$fromid.'::'.$from_parentarr[1];
				$depth = count(explode('::',$parentgroup))-1;
				$query = 'UPDATE ld_groups set parentgroup = ?,depth = ? where groupid = ? ';
				$adb->pquery($query,array($parentgroup,$depth,$id));
			}
		}
	}
	/**
	 * 获取当前部门所有下级部门
	 * @param Integer $id 部门ID
	 * @returns Array 部门信息结果集二维
	 * @project PROT180 角色权限改进
	 * @author Tujt 2015-03-20
	 */
	public function getGroupTheLower($id) {
		global $adb;
	    $query = 'SELECT groupid,groupname,description,depth,parentid,parentgroup 
					 FROM ld_groups WHERE groupid != "'.$id.'" AND 
				  CONCAT("::",parentgroup,"::") LIKE "%::'.$id.'::%" ORDER BY parentid asc, groupseq asc ;';
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
				$grouparray[$groupid]['description'] = $description;
				$grouparray[$groupid]['depth'] = $depth;
				$grouparray[$groupid]['parentid'] = $parentid;
				$grouparray[$groupid]['parentgroup'] = $parentgroup;
			}
		}
		if(!empty($grouparray)) return $grouparray;
		return '';
	}
	/**
	 * 部门保存方法
	 * @param Array $input 传递过来的值
	 * @project PROT180 角色权限改进
	 * @author Tujt 2015-03-19
	 */
	public function save($input){
		global $adb;
		$fieldarr = array('groupname'=>$input['groupname'],
				'parentid'=>$input['parentid'],
				'description'=>$input['description']);
		if('-1' == $input['parentid']){
			$query = 'update ld_groups set groupname = ?,description=? where groupid = ? ';
			$adb->pquery($query,array($input['groupname'],$input['description'],$input['groupid']));
          
           
			$this->unsetGroupList();
			return $input['groupid'];
		}
		$parentarr = $this->getGroupInfoByid($input['parentid']);
		if(empty($parentarr)) return false;
		$fieldarr['depth'] = ++ $parentarr['depth'];
		if(isset($input['groupid']) && $input['groupid'] > 0){//edit
			$fieldarr['parentgroup'] = $parentarr['parentgroup'].'::'.$input['groupid'];
			$updatesql = '';
			foreach($fieldarr as $fld=>$val){
				$updatesql .= $fld.'="'.$val.'",';
			}
			$updatesql = trim($updatesql,',');
			$query = 'update ld_groups set '.$updatesql.' where groupid = '.$input['groupid'].' ';
			$adb->pquery($query,array());
			$this->GroupDragDrop($input['groupid'],$input['parentid']);
		}elseif($_REQUEST['weixin_mark']=='txl'){//1114
            $groupid = $input['wxgroupid'];
            if(empty($groupid)) return false;//取不到下一个ID，则跳出
            $fieldarr['parentgroup'] = $parentarr['parentgroup'].'::'.$groupid;
            $fieldkey = array_keys($fieldarr);
            $fieldsql = join(',',$fieldkey);
            $valuesql = '"'.join('","',$fieldarr).'"';
            $query = 'insert into ld_groups(groupid,'.$fieldsql.') values('.$groupid.','.$valuesql.'); ';
            $adb->pquery($query,array());
            $input['groupid']=$groupid;
        }else{//create
			$groupid = $this->getGroupNextId();
			if(empty($groupid)) return false;//取不到下一个ID，则跳出
			$fieldarr['parentgroup'] = $parentarr['parentgroup'].'::'.$groupid;
			$fieldkey = array_keys($fieldarr);
			$fieldsql = join(',',$fieldkey);
			$valuesql = '"'.join('","',$fieldarr).'"';
			$query = 'insert into ld_groups(groupid,'.$fieldsql.') values('.$groupid.','.$valuesql.'); ';
			$adb->pquery($query,array());
            $input['groupid']=$groupid;
		}
		$this->unsetGroupList();
        return $input['groupid'];
	}
	/**
	 * 删除部门
	 * @param Array $input 传递过来的值
	 * @project PROT180 角色权限改进
	 * @author Tujt 2015-03-20
	 */
	public function deleted($input) {
		global $adb;
		//1、修改部门对应的用户信息
		$query = 'UPDATE ld_users2group SET groupid = ? WHERE groupid = ?;';
		$adb->pquery($query,array($input['userto'],$input['del_id']));
		//2、将部门的下级部门全都转移走
		if(!empty($input['groupto'])){
			$lowerarr = $this->getGroupTheLower($input['del_id']);//获取部门所有下级部门信息
			$parentarr = $this->getGroupInfoByid($input['groupto']);//获取上级部门信息
			foreach($lowerarr as $id=>$lower){//循环下级部门信息
				$from_parentarr = explode('::'.$input['del_id'].'::',$lower['parentgroup']);
				$parentgroup = $parentarr['parentgroup'].'::'.$from_parentarr[1];
				$parentgrouparr = explode('::', $parentgroup);
				$parentgrouplen = count($parentgrouparr);
				$depth = $parentgrouplen-1;
				$parentid = $parentgrouparr[$parentgrouplen-2];
				$query = 'UPDATE ld_groups SET parentgroup = ?,depth = ?,parentid=? WHERE groupid = ?;';
				$adb->pquery($query,array($parentgroup,$depth,$parentid,$id));
			}
		}
		//3、删除部门
		$query = 'DELETE FROM ld_groups WHERE groupid = ? ;';
		$adb->pquery($query,array($input['del_id']));
	    $this->unsetGroupList();
	}
	/**
	 * 获取部门对应的员工信息
	 * @param String $groupid 部门ID
	 * @project PROT180 角色权限改进
	 * @author Tujt 2015-03-20
	 */
	public function getGroupOfusers($groupid) {
	    global $adb;
		$query = 'SELECT userid,wx_userid,last_name FROM ld_users2group 
        inner join ld_users on ld_users.id = ld_users2group.userid WHERE ld_users2group.groupid = ?;';
		$result = $adb->pquery($query,array($groupid));
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
    
    /**
	 * 获取部门对应的员工信息 - 只返回员工的id
	 * @param String $groupid 部门ID
	 * @author Chj 2020-12-07
	 */
    public function getGroupOfusers_id($groupid) {
	    global $adb;
		$query = 'SELECT userid FROM ld_users2group 
        inner join ld_users on ld_users.id = ld_users2group.userid WHERE ld_users2group.groupid = ?;';
		$result = $adb->pquery($query,array($groupid));
		$rows = $adb->num_rows($result);
		$groupuser = array();
		if($rows > 0){
			for($i=0;$i<$rows;++ $i){
			    $userid = $adb->query_result($result,$i,'userid');
				$groupuser[$userid] = '';
			}
		}
		if(!empty($groupuser)) return $groupuser;
		return '';
	}
	/**
	 * 保存部门关联用户信息
	 * @param Array $input 传递过来的值
	 * @project PROT180 角色权限改进
	 * @author Tujt 2015-03-23
	 */
	public function saveofuser($input) {
		global $adb;
	    $delete = 'DELETE FROM ld_users2group WHERE groupid = ? ';
		$adb->pquery($delete,array($input['groupid']));
		if(!empty($input['userid'])){
			$userid = trim($input['userid'],',');
			$userarr = explode(',',$userid);
			foreach($userarr as $user){
				$insert = 'INSERT INTO ld_users2group(groupid,userid) VALUES(?,?);';
				$adb->pquery($insert,array($input['groupid'],$user));
			}
		}
	}
	/**
	 * 获取部门对应的员工信息
	 * @param Array $input 传递过来的值
	 * @return Array 关联用户结果集
	 * @project PROT180 角色权限改进
	 * @author Tujt 2015-03-20
	 */
	public function getGroupUser($input) {
	    $groupid = $input['groupid'];
		$userinfo = $this->getGroupOfusers($groupid);
		return $userinfo;
	}
	/**
	 * 获取模块对应权限用户
	 * @param String $module 模块名
	 * @return String $userid 组装过的用户ID(,)
	 * @author Tujt 2015-04-20
	 */
	public function getModuleListUser($module){
		global $adb,$current_user;
		$tabid = getTabid($module);
		//chj 2022/7/26 http://crm.yuanfusc.com/crm/）如图，旧公海设置按成员选不到孔斌，普通客户分配可以选此用户
		$query = '
                select DISTINCT id as userid from (
                SELECT  ld_users.`id` 
                					FROM ld_profile2standardpermissions 
                						INNER JOIN ld_users 
                							ON ld_users.`profileid` = ld_profile2standardpermissions.`profileid` 
                					WHERE ld_profile2standardpermissions.tabid =?
                						AND (ld_profile2standardpermissions.operation = 3 )
                					AND ld_users.`id` > 0 UNION all 
                select id from ld_users where is_admin=\'on\') as tmp;';
  
		$result = $adb->pquery($query,array($tabid));
		$rows = $adb->num_rows($result);
		$userid = '';

        if($rows >= 1){
			for($i = 0; $i < $rows; $i++){
				$userids[] = $adb->query_result($result,$i,'userid');
			}
			$userid = implode(',',$userids);
		}
		/*if(1 == $rows){
			$userid = $adb->query_result($result,0,'userid');
		}*/
		if(!empty($userid)) return $userid;
		return '';
	}
	/**
	 * 获取用户授权范围
	 * @param 2016-06-12
	 * @return
	 * @author Chj
	 */
	public function getScopeOfShareUsers($fld_module) {
		global $adb,$current_user;
        if($fld_module == 'Events') $fld_module = 'Calendar';
		$ScopOfAuthority = ScopOfAuthority::getInstance($adb,$fld_module);
		if(!empty($fld_module))//获取模块共享规则
			$moduleshare = $ScopOfAuthority->getModuleShareInfo();
		if($moduleshare == '')
			$moduleshare = SHARE_PRIVATE;//模块默认为私有
		$scopeauthority = $ScopOfAuthority->getUserModuleScoperType($fld_module);
		//is_admin='on'：管理员、data=1：授权为全部、share!=3：模块共享
		if('on' == $current_user->is_admin || SCOPE_ALL == $scopeauthority || SHARE_PRIVATE != $moduleshare){
			return 'yes';
		}else{
			if($scopeauthority == SCOPE_HIGER_USER || $scopeauthority == SCOPE_HIGHER_GROUP){
				$user_focus = CRMEntity::getInstance('Users');
				$userscope = $user_focus->getUserScopeInfo($current_user->id,$fld_module);//获取授权范围
				$userscopeid = array_flip($userscope);
			}else if($scopeauthority == SCOPE_PERSON){
				$userscopeid[] = $current_user->id;
			}
			return $userscopeid;
		}
	}
    //editor:gyq_28 date:20170323  reason:移动端增加额外限制
    protected function getGroupListUser_expansion($filterown){
        if(!empty($filterown)){//过滤自己

            global $current_user;
            $sql = ' and ld_users.id != '.$current_user->id.' ';
            return $sql;
        }else{
            return '';
        }
    }
    public function getGroupChild($groupid)
    {
        $this->group_parent_key = $groupid;
        global $adb;
         $query = 'SELECT ld_groups.groupid,ld_groups.groupname,ld_groups.parentid,
					 \'group\' AS setype,ld_groups.parentgroup,\'Active\' as status ,depth
					 FROM ld_groups WHERE ld_groups.groupid > 0  ';
          $result=$adb->pquery($query,array());
          $rows=$adb->num_rows($result);
        $parentids[]=$groupid;
        $tmpgroupid=$groupid;
         $tmpi=0;
         	for($i=0;$i<$rows;++ $i){//先取出部门ID对应的index值
				$groupid = $adb->query_result($result,$i,'groupid');
				$setype = $adb->query_result($result,$i,'setype');
   	            $parentid = $adb->query_result($result,$i,'parentid');
                $depth=$adb->query_result($result,$i,'depth');
                
                if(in_array($parentid,$parentids)||$groupid==$tmpgroupid)
                {
                     $parentids[]=$groupid;
                    $grouparr[$setype.'_'.$groupid] = $tmpi;
                    $tmpi++;
                }
			}
              $parentids[]=$tmpgroupid;
              $tmpi=0;
        	for($i=0;$i<$rows;++ $i){//循环
				$groupid = $adb->query_result($result,$i,'groupid');
				$groupname = $adb->query_result($result,$i,'groupname');
				$parentid = $adb->query_result($result,$i,'parentid');
               
                if(in_array($parentid,$parentids)||$groupid==$tmpgroupid)
                {
                    $parentids[]=$groupid;
    				$setype = $adb->query_result($result,$i,'setype');
    				$parentgroup = $adb->query_result($result,$i,'parentgroup');
    				$status = $adb->query_result($result,$i,'status');
    				//用户有可能有多个部门，未防止出错，把id值修改为这种格式
    				$key = $setype.'_'.$groupid.'_'.($tmpi+1);
    				$arr = array();
    				$arr['type'] = $setype;
    				$arr['name'] = $groupname;
                    $arr['depth']=$depth;
                    $arr['groupid']=$groupid;
                    $arr['parentidvalue']=$parentid;
    				$arr['parentid'] = 'group_'.$parentid.'_'.($grouparr['group_'.$parentid]+1);
    				$arr['parentgroup'] = $parentgroup.'_'.$status;//后面加上是否启用状态，方便实现显示停用用户功能
    				$grouparray[$key] = $arr;
    		      	$tmpi++;
                    if($groupid == $tmpgroupid) $this->group_parent_key = $key;
                    
                }
				
			}
            if(!empty($grouparray)) return $grouparray;
	       	return '';
		
    }

    public function settrigger_type($triggertype){
        self::$triggertype = $triggertype;
    }
	/**
	 * 获取部门以及用户信息，用户弹出层调用
	 * @param String $fld_module 模块名
	 * @param String $view 判断是否只显示当前用户授权范围的用户
	 * @param String $filterown 判断是否过滤掉当前用户
	 * @project PROT180 角色权限改进
	 * @author Tujt 2015-03-24
	 */
    //wyt 220920 1000061 选用户（负责人、单选用户、多选用户、团队成员）字段控制只允许选择满足一定条件的数据
	public function getGroupListUser($fld_module='',$view='',$filterown='',$selecttyp='',$ishighseaallocate='no',$filterrecordid='',$fld_fieldname='') {
		global $adb,$current_user;
		$where = '';
        $tabid = getTabid($fld_module);
        $advance_demand_groups='';
        $advance_demand='';
        $userid_other=[];
        if(!empty($fld_fieldname))
       {
        //千万不要添加presence in(0,2) 因为有共享
           $sql_field="select advance_demand,advance_demand_groups,fieldid from ld_field where    tabid= $tabid   and columnname='$fld_fieldname'";
            $result_field=$adb->query($sql_field);
            $field_num_rows = $adb->num_rows($result_field);
            if($field_num_rows>0){
                    $fieldid=$adb->query_result($result_field,0,'fieldid');
                    $advance_demand_groups=$adb->query_result($result_field,0,'advance_demand_groups')??'';
                    $advance_demand=$adb->query_result($result_field,0,'advance_demand')??'';
                    if(strpos($advance_demand,'####')&&strpos($advance_demand_groups,"####")) {
                        $tmp_demand = explode("####", $advance_demand);
                        $tmp_demand_groups = explode("####", $advance_demand_groups);
                        $memberrange_select = $tmp_demand[0];
                        $memberrange_select_type = $tmp_demand_groups[0];
                }else{
                        $memberrange_select=$advance_demand;
                        $memberrange_select_type=$advance_demand_groups;
                    }
            }
            
            crm_load_class_file('cls_EditView_OutPut','include/utils');
            $obj_cls = new cls_EditView_OutPut();
            if($fld_module!='yes'){
                $_REQUEST['frommodule']=$fld_module;
            }
            $_REQUEST['selectmodule']="Users";
            $_REQUEST['fieldname']=$fld_fieldname;
            $users_result_othercondition=$obj_cls->getUserSelect_othercondition($fieldid);
            $userid_other=$users_result_othercondition['userid'];
       }

     
        $userid_where='';
        $groupid_where='';
        if($memberrange_select_type=='Module'){
            $SmOwnerSearchScope=getCurSmOwnerSearchScope($fld_module);
            $userid=$SmOwnerSearchScope['UserCombo'];
            $userid = implode(',',array_keys($userid));
            $userid=array_intersect(explode(',',$userid),explode(',',$userid_other));
            $userid_where=' and find_in_set(ld_users.id,"'.implode(',',$userid).'")';
        }else if($memberrange_select_type=='Person'){
            $userid=array_intersect(explode(',',$memberrange_select),explode(',',$userid_other));
            $userid_where=' and find_in_set(ld_users.id,"'.implode(',',$userid).'")';
        }else if($memberrange_select_type=='Departments'){
            $sql_Departments="select u.id from ld_users u inner join ld_users2group g on u.id=g.userid where find_in_set(g.groupid,?)";
            if($this->group_type != 'all'){
                $sql_Departments .= ' and u.crm_user_type = "'.$this->group_type.'"';
            }
            $result_Departments=$adb->pquery($sql_Departments,array($memberrange_select));
            $num_rows_Departments=$adb->num_rows($result_Departments);

            if($num_rows_Departments>0){
                for($i=0;$i<$num_rows_Departments;$i++){
                    $userid[$i]=$adb->query_result($result_Departments,$i,'id');
                }
            }
            $userid=array_intersect($userid,explode(',',$userid_other));
            $userid_where=' and find_in_set(ld_users.id,"'.implode(',',$userid).'")';
        }else if($memberrange_select_type=='Roles'){
            $sql_Roles="select u.id from ld_users u left join ld_profile p on u.profileid=p.profileid where find_in_set(p.profileid,?)";
            if($this->group_type != 'all'){
                $sql_Roles .= ' and u.crm_user_type = "'.$this->group_type.'"';
            }
            $result_Roles=$adb->pquery($sql_Roles,array($memberrange_select));
            $num_rows_Roles=$adb->num_rows($result_Roles);

            if($num_rows_Roles>0){
                for($i=0;$i<$num_rows_Roles;$i++){
                    $userid[$i]=$adb->query_result($result_Roles,$i,'id');
                }
            }
            $userid=array_intersect($userid,explode(',',$userid_other));
            $userid_where=' and find_in_set(ld_users.id,"'.implode(',',$userid).'")';
        }else if($memberrange_select_type=='Position'){
            $sql_Position="SELECT u.id FROM ld_users u LEFT JOIN ld_picklist_values pv ON u.userlevel = pv.listvalue where find_in_set(pv.id,?)";
            if($this->group_type != 'all'){
                $sql_Position .= ' and u.crm_user_type = "'.$this->group_type.'"';
            }
            $result_Position=$adb->pquery($sql_Position,array($memberrange_select));
            $num_rows_Position=$adb->num_rows($result_Position);

            if($num_rows_Position>0){
                for($i=0;$i<$num_rows_Position;$i++){
                    $userid[$i]=$adb->query_result($result_Position,$i,'id');
                }
            }
            $userid=array_intersect($userid,explode(',',$userid_other));
            $userid_where=' and find_in_set(ld_users.id,"'.implode(',',$userid).'")';
        }else if($memberrange_select_type=='All'){
            $userid_where=' and find_in_set(ld_users.id,"'.$userid_other.'")';
        }

        if('averageDistribution' == $_REQUEST['popup_type']){$_REQUEST['popup_type']='Allocate';}
//		if(!empty($_REQUEST['popup_type'])){
//			if('Allocate' == $_REQUEST['popup_type']){
//				$systems_deploy=getSys_deploy(110);//分配弹出层是否显示所有用户 0是 1否
//				if($systems_deploy['deploy_value'] == 1){
//					$view = 'private';
//				}
//			}
//		}
//        if($ishighseaallocate=='yes'){
//            $deploy_values=getSys_deploy(110);// 分配弹出层是否显示所有用户设置为否
//        	if($deploy_values['deploy_value']==1){
//        		//edit:can 20220531  （https://81mis.com/kfbtest/index.php）成员yhaic，没有客户模块权限，但系统管理员在南海池进行公海分配时，仍可以选到该成员
//        		$view = 'private';
//        	}
//        }
        
        if(is_admin($current_user)){
            $view='public';
        }
        elseif(empty($fld_fieldname))
        {
            //列表查看范围高级
            if(!is_admin($current_user)){
                $view='private';
            }
        }
        else if(!empty($fld_fieldname)&&$field_num_rows>0){
            $view='';
        }

//BUG0058280 ls 20221102 某些不需要受数据范围权限控制的选人弹窗，可以添加参数 &checkprivilege=no
//edit:can BUG0073784 工作汇报设置李小娟的查看范围只有销售部华东区，但李小娟的账号可通过筛选看到其他部门的工作汇报 
        if ($_REQUEST['checkprivilege'] == 'no'  ) {
            $view='';
        }
            
//        dump($sql_field);
 		if(!empty($view)){
 			global $current_user;
             if($field_num_rows>0){
               $where=$userid_where;
             }else if(!empty($fld_module)&&$fld_module!= 'yes'){
                 $moduserid = $this->getModuleListUser($fld_module);
       
                 switch ($view) {
                     case 'private'://按照用户授权查询数据
//                         $systems_deploy=getSys_deploy(110);//分配弹出层是否显示所有用户 0是 1否
                         if(!empty($_REQUEST['popup_type']) && $_REQUEST['popup_type'] == 'Allocate'  && !empty($moduserid)){
                             $where = ' and ld_users.id in ('.$moduserid.') ';
                        }else{
                            if($this->getScopeOfShareUsers($fld_module) == 'yes'){
                                 break;
                             }else{
                               
                                 $where = ' and ld_users.id in ('.join(',',$this->getScopeOfShareUsers($fld_module)).','.$current_user->id.') ';
                             }
                         }
                        
                         break;
                     case 'public'://只显示能看到当前模块的用户
                         if($this->getScopeOfShareUsers($fld_module) == 'yes'){
                            break;
                        }else{
                            if(!empty($moduserid)){//没有非空情况，因为至少当前用户是可以搜索来的
                                 $where = ' and ld_users.id in ('.$moduserid.') ';
                             }else{//纯为了保险起见，加了这段代码。
                                 $where = ' and ld_users.id = '.$current_user->id.' ';
                             }
                        }
                        break;
                 }
             }
 
 		}
        $where .= $this->getGroupListUser_expansion($filterown);
        //过滤自己
		if(!empty($filterown)){
			global $current_user;
			$where .= ' and ld_users.id != '.$current_user->id.' ';
		}
		//获取所有已经绑定的企业微信用户
		if(!empty($_REQUEST['wx_user']) && $_REQUEST['wx_user'] == 'yes'){
			$where .= " and ld_users.wx_userid <> '' ";
		}
		//过滤当前单据的负责人
		if(!empty($filterrecordid)){
		  if($fld_module=='Attachment')
         {
            $re_module=$fld_module;//24951: 附件管理：单据共享报错
         }
         else
		  $re_module = getSalesEntityType($filterrecordid);
           
			$focus = CRMEntity::getInstance($re_module);                    
			$table_name=$focus->table_name;
			$table_index=$focus->table_index;
			$smownercolumnname=$focus->getSmownerColumName();
			$sql='SELECT  '.$smownercolumnname.' as smownerid FROM  '.$table_name.' where '.$table_index.'='.$filterrecordid ;
			$result=$adb->query($sql);
			if($adb->num_rows($result) >= 1){
				$smownerid=$adb->query_result($result,'smownerid');
				if(!empty($smownerid)){
					$where .= ' and ld_users.id != '.$smownerid.' ';
				}
			}
		}
        if($ishighseaallocate=='yes' && !empty($_REQUEST['pool_id'])){//公海分配按钮事件
        if($fld_module=='Accounts')
		{
		  crm_load_class_file('cls_PublicAccounts', 'modules/Accounts');
		  $cls_PublicAccounts = new cls_PublicAccounts($currentModule);
		}
         else
        {
            //46147: （81mis.com/kfbcrm）客户管理-销售线索，“南海”公海池，在公海未分配页签，选择单据进行公海分配，分配界面成员显示不全；
             crm_load_class_file('cls_PublicLeads', 'modules/Leads');
		    $cls_PublicAccounts = new cls_PublicLeads($currentModule);
        }
       
			$public_account = $cls_PublicAccounts->getPublicAccountConfig();
			$adminaccount = $public_account['public_account_pool'][$_REQUEST['pool_id']]['administrators'];
			$useraccount = $public_account['public_account_pool'][$_REQUEST['pool_id']]['userids'];
			//// or is_admin="on"    公海分配成员， 暂时不加系统用户管理员，跟luyx讨论
            if(!empty($adminaccount) && !empty($useraccount))
                $where ='and (ld_users.id in('.$adminaccount.') or ld_users.id in ('.$useraccount.'))' ;
            elseif(!empty($adminaccount) && empty($useraccount))
                $where ='and (ld_users.id in('.$adminaccount.'))' ;
            elseif((empty($adminaccount) && !empty($useraccount)))
                $where ='and (ld_users.id in('.$useraccount.'))' ;
            else
                $where ='and ( is_admin="on")' ;
            if($view=='private')
            {
                //edit:can 20220531  （https://81mis.com/kfbtest/index.php）成员yhaic，没有客户模块权限，但系统管理员在南海池进行公海分配时，仍可以选到该成员 
                $where.=' and ld_users.id in( '.$moduserid.')';
                
            }
        }
        
		//公海参数选人弹出层优化：普通客户转为公海后，更改客户负责人为（该参数只能选择公海成员）
		if(!empty($_REQUEST['publiaccount']) && $_REQUEST['publiaccount'] == 'yes'){
			if(!empty($_REQUEST['pool_id'])){
				$usersaccount = $public_account['public_account_pool'][$_REQUEST['pool_id']]['userids'];
				$where ='and (ld_users.id in('.$usersaccount.'))' ;
			}
			/*$usersaccount = getAccount_Set('usersaccount');
			if(!empty($usersaccount)){
				$where ='and (ld_users.id in('.$usersaccount.'))' ;
			}*/
		}
        
        if(isset($_REQUEST['recommon_designer'])&&$_REQUEST['recommon_designer']!=''){
            // 山水-特殊推荐设计师逻辑,按推荐规则筛选用户
            $recommon_userids = $_REQUEST['recommon_designer'];
            $where ='and (ld_users.id in('.implode(',',$recommon_userids).'))' ;
        }
        if(!isset(self::$triggertype) || self::$triggertype!="recover"){
            $userid_where .= ' and ld_groups.is_hidden != "yes"';
            $groupid_where.= ' and ld_groups.is_hidden != "yes"';
        }
        //hzx
        if($this->group_type != 'all'){
            $where .= ' and ld_users.crm_user_type = "'.$this->group_type.'"';
            $userid_where .= ' and ld_users.crm_user_type = "'.$this->group_type.'"';
            $groupid_where .= ' and ld_groups.group_type = "'.$this->group_type.'" or ld_groups.depth = 0';
        }
		//$where  .= ' and (ld_users.status = "Active")';
		//bug 0015315 用户管理 > 新建：高级-业务授权范围弹出层，每个部门下的用户排序希望按照用户名字母排序
        //17123: 高级弹出层，没有排序。
	    $query = 'select * from ( select * from (SELECT users.wx_userid,users.groupid,users.groupname,users.parentid, is_hidden,
					users.setype,users.parentgroup,users.STATUS from (
						SELECT 
                        ld_users.wx_userid,
                        ld_users.id AS groupid,
						ld_users.last_name AS groupname,
						ld_users2group.`groupid` AS parentid,
						\'user\' AS setype,
						concat(
							ld_groups.parentgroup,
							\'::\',
							ld_users.id
						) AS parentgroup,
						ld_groups.is_hidden,
						ld_users. STATUS
						FROM ld_users
					INNER JOIN ld_users2group ON ld_users2group.`userid` = ld_users.`id`
					LEFT JOIN ld_groups ON ld_groups.`groupid` = ld_users2group.`groupid`
				WHERE
					ld_users.deleted = 0
				AND ld_users.id > 0 '.$where.' '.$userid_where.' ORDER BY convert(ld_users.last_name using gbk)
				
				) as users
                    UNION 
                    select * from (
                	SELECT  
                    ld_users.wx_userid,
                	ld_users.id,
                	ld_users.last_name,
                	ld_groups.groupid,
                	ld_groups.is_hidden,
                	\'user\' AS setype,
                	concat(
                				ld_groups.parentgroup,
                				\'::\',
                				ld_users.id
                		) AS parentgroup,CONCAT(\'nogroup_\',ld_users.status) STATUS 
                	FROM ld_users 
                	LEFT JOIN ld_groups ON ld_groups.parentid=\'-1\'
                	WHERE 
                	id NOT IN (SELECT userid FROM ld_users2group) '.$where.'  
                	'.$userid_where.' 
                	ORDER BY convert(ld_users.last_name using gbk)  ) 
                            as no_group_users            ) as all_users ORDER BY
			CONVERT (all_users.groupname USING gbk ) limit 99999) as users
  				UNION 
                select * from 
				 ( SELECT \'\' as wx_userid,ld_groups.groupid,ld_groups.groupname,ld_groups.parentid, ld_groups.is_hidden, 
					 \'group\' AS setype,ld_groups.parentgroup,\'Active\' as status 
					 FROM ld_groups WHERE ld_groups.groupid > 0 '.$groupid_where.' order by group_type asc , depth asc ,groupseq asc ,ld_groups.groupid asc limit 99999) as tmp_groups;';
       //32481: PC端：成员管理中的部门级别和顺序和选择用户界面的部门级别和顺序不一致
        if($selecttyp == 'group'){
            $query = 'SELECT ld_groups.groupid,ld_groups.is_hidden, ld_groups.groupname,ld_groups.parentid,ld_groups.group_no,
					 \'group\' AS setype,ld_groups.parentgroup,\'Active\' as status ,depth
					 FROM ld_groups WHERE ld_groups.groupid > 0 ';
			$query .= $groupid_where.' order by group_type asc, depth asc ,groupseq asc ,ld_groups.groupid asc  ';
		}
		 // dump($query);
		$result = $adb->pquery($query,array());
		$rows = $adb->num_rows($result);
		$grouparray = array();
		//if(!empty($_REQUEST['popup_module']) && )

        //获取所有成员头像
        $useriamgearr = Users::getAllUsersImages();

		if($rows > 0){
			$grouparr = array();
			for($i=0;$i<$rows;++ $i){//先取出部门ID对应的index值
				$groupid = $adb->query_result($result,$i,'groupid');
				$setype = $adb->query_result($result,$i,'setype');
				$grouparr[$setype.'_'.$groupid] = $i;
			}
			for($i=0;$i<$rows;++ $i){//循环
                $wx_userid=$adb->query_result($result,$i,'wx_userid');
				$groupid = $adb->query_result($result,$i,'groupid');
				$is_hidden = $adb->query_result($result,$i,'is_hidden');
				$parentid = $adb->query_result($result,$i,'parentid');
				$setype = $adb->query_result($result,$i,'setype');
                $groupname = $adb->query_result($result,$i,'groupname');
                if(isKehu001ServerPc() == 'yes'){
                    if($setype == 'user'){
                        $groupname = getUserFullName($groupid);
                    }
                    elseif($setype == 'group'){
                        $groupname = getGroupFullName($groupid);
                    }
                }
				$parentgroup = $adb->query_result($result,$i,'parentgroup');
				$status = $adb->query_result($result,$i,'status');
				if($setype == 'group' && $is_hidden=='yes'){
					$status= 'Inactive';
				}
				//分配、更改创建人，不显示停用用户
				/*if(!empty($_REQUEST['popup_type']) && ($_REQUEST['popup_type'] == 'Allocate' || $_REQUEST['popup_type'] == 'averageDistribution' || $_REQUEST['popup_type'] == 'ChangeCreator' || $_REQUEST['ishighseaallocate'] == 'yes') && $status == 'Inactive'){
					continue;
				}*/
                $depth=$adb->query_result($result,$i,'depth');
                $group_no=$adb->query_result($result,$i,'group_no');
				//用户有可能有多个部门，未防止出错，把id值修改为这种格式
				$key = $setype.'_'.$groupid.'_'.($i+1);
				$arr = array();
                $arr['depth']=$depth;
				$arr['type'] = $setype;
                $arr['wx_userid']=$wx_userid;
				$arr['name'] = $groupname;
				$arr['is_hidden'] = $is_hidden;
                $arr['groupid']=$groupid;
                $arr['parentidvalue']=$parentid;
				$arr['parentid'] = 'group_'.$parentid.'_'.($grouparr['group_'.$parentid]+1);
				$arr['parentgroup'] = $parentgroup.'_'.$status;//后面加上是否启用状态，方便实现显示停用用户功能
				$arr['status'] = $status;
                $arr['group_no'] = $group_no;
                if($useriamgearr[$groupid] && !empty($useriamgearr[$groupid])){
                    $arr['imagepath'] = $useriamgearr[$groupid];
                }
				$grouparray[$key] = $arr;
				$this->grouparrayMC[$key] = $arr;//移动端多层树 eidor:gyq date:20170324
				$this->grouparrayMC[$key]['id'] = $groupid;
				if(-1 == $parentid) $this->group_parent_key = $key;
			}
		}

        if(!empty($grouparray)) return $grouparray;
		return '';
	}

    //@edit:liushuai,2020-11-10,reason:【ID1001080】增加“会话存档”模块
    public function getGroupListUserForWechatSession($wx_userid_str,$search) {
        global $adb;

        $query = 'select * from ( select * from ( select * from (SELECT users.wx_userid,users.groupid,users.groupname,users.parentid,
					users.setype,users.parentgroup,users.STATUS from (
						SELECT 
                        ld_users.wx_userid,
                        ld_users.id AS groupid,
							ld_users.last_name AS groupname,
							ld_users2group.`groupid` AS parentid,
							\'user\' AS setype,
							concat(
								ld_groups.parentgroup,
								\'::\',
								ld_users.id
							) AS parentgroup,
							ld_users. STATUS
						FROM ld_users
					INNER JOIN ld_users2group ON ld_users2group.`userid` = ld_users.`id`
					LEFT JOIN ld_groups ON ld_groups.`groupid` = ld_users2group.`groupid`
				WHERE
					ld_users.deleted = 0
				AND ld_users.id > 0  ORDER BY convert(ld_users.last_name using gbk)
				) as users
                    UNION 
                    select * from (
                	SELECT  
                    ld_users.wx_userid,
                	ld_users.id,
                	ld_users.last_name,
                	ld_groups.groupid,
                	\'user\' AS setype,
                	concat(
                				ld_groups.parentgroup,
                				\'::\',
                				ld_users.id
                		) AS parentgroup,CONCAT(\'nogroup_\',ld_users.status) STATUS 
                	FROM ld_users 
                	LEFT JOIN ld_groups ON ld_groups.parentid=\'-1\'
                	WHERE 
                	id NOT IN (SELECT userid FROM ld_users2group)  ORDER BY convert(ld_users.last_name using gbk)  ) 
                            as no_group_users            ) as all_users ORDER BY
			CONVERT (all_users.groupname USING gbk ) limit 99999) as users
  				UNION 
                select * from 
				 ( SELECT \'\' as wx_userid,ld_groups.groupid,ld_groups.groupname,ld_groups.parentid,
					 \'group\' AS setype,ld_groups.parentgroup,\'Active\' as status 
					 FROM ld_groups WHERE ld_groups.groupid > 0 order by depth asc ,groupseq asc,ld_groups.groupid asc limit 99999) as tmp_groups) AS tmptwo WHERE
	tmptwo.wx_userid IN (\''.$wx_userid_str.'\') and tmptwo.groupname like \'%'.$search.'%\' or tmptwo.setype = \'group\';';

        $result = $adb->pquery($query,array());
        $rows = $adb->num_rows($result);
        $grouparray = array();
        if($rows > 0){
            $grouparr = array();
            for($i=0;$i<$rows;++ $i){//先取出部门ID对应的index值
                $groupid = $adb->query_result($result,$i,'groupid');
                $setype = $adb->query_result($result,$i,'setype');
                $grouparr[$setype.'_'.$groupid] = $i;
            }
            for($i=0;$i<$rows;++ $i){//循环
                $wx_userid=$adb->query_result($result,$i,'wx_userid');
                $groupid = $adb->query_result($result,$i,'groupid');
                $groupname = $adb->query_result($result,$i,'groupname');
                $parentid = $adb->query_result($result,$i,'parentid');
                $setype = $adb->query_result($result,$i,'setype');
                $parentgroup = $adb->query_result($result,$i,'parentgroup');
                $status = $adb->query_result($result,$i,'status');

                $depth=$adb->query_result($result,$i,'depth');
                //用户有可能有多个部门，未防止出错，把id值修改为这种格式
                $key = $setype.'_'.$groupid.'_'.($i+1);
                $arr = array();
                $arr['depth']=$depth;
                $arr['type'] = $setype;
                $arr['wx_userid']=$wx_userid;
                $arr['name'] = $groupname;
                $arr['groupid']=$groupid;
                $arr['parentidvalue']=$parentid;
                $arr['parentid'] = 'group_'.$parentid.'_'.($grouparr['group_'.$parentid]+1);
                $arr['parentgroup'] = $parentgroup.'_'.$status;//后面加上是否启用状态，方便实现显示停用用户功能
                $arr['status'] = $status;
                $grouparray[$key] = $arr;
                $this->grouparrayMC[$key] = $arr;//移动端多层树 eidor:gyq date:20170324
                $this->grouparrayMC[$key]['id'] = $groupid;
                if(-1 == $parentid) $this->group_parent_key = $key;
            }
        }

        if(!empty($grouparray)) return $grouparray;
        return '';
    }

	public function checkGroupName($input){
		global $adb;
		$query = 'select groupid from ld_groups where groupname = \''.$input['groupname'].'\' ';
		if(isset($input['groupid']) && $input['groupid'] > 0){
			$query .= 'and groupid != '.$input['groupid'].' ';
		}
		$query .= 'order by groupid limit 1;';
		$result = $adb->pquery($query,array());
		$rows = $adb->num_rows($result);
		if(1 == $rows){
			return 1;
		}
		return 2;
	}
	/**
	 * 获取用户的所有部门
	 * @param String $userid 用户ID
	 * @project PROT180 角色权限改进
	 * @author Chj 2015/6/24
	 */
	public function getUserGroup($userid){
		global $adb;
		if(!empty($userid) && $userid > 0){
		  if(array_key_exists($userid,$this->group_userid_arr))
          {
            return $this->group_userid_arr[$userid];
          }
			$query = 'select ld_groups.groupid,groupname from ld_groups left join  ld_users2group  on ld_groups.groupid = ld_users2group.groupid where userid = ?';
			$result = $adb->pquery($query,array($userid));
			$num_rows = $adb->num_rows($result);
			for($i = 0; $i<$num_rows; $i++){
				$groupname=$adb->query_result($result,$i,'groupname');
				$groupid=$adb->query_result($result,$i,'groupid');
				if(!empty($groupname)){
					$groupnames[$groupid] = $adb->query_result($result,$i,'groupname');
				}
			}
            $this->group_userid_arr[$userid]=$groupnames;
			return $groupnames;
		}
	}
	/**
	 * 获取部门信息
	 * @author Tujt 2015-07-16
	 */
	public function getGroupIdName() {
	    $groupList = $this->getGrouplist();
		$groupObj = array();
		foreach($groupList as $id=>$group){
			$groupObj[$id] = $group['groupname'];
		}
		return $groupObj;
	}

	public function setgroup_type($type){
	    $this->group_type = $type;
    }
}
?>