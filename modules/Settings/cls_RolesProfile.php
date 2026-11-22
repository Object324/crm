<?php
/**
 * XUQIU20241031-05 【弹出框规范】角色权限界面优化
 * 2024-12-19 xxy
 */
class cls_getRolesProfile
{
    private $adb;
    private $current_user;
    private $module = '';
    private $tabid = 0;
    protected $allRolesBaseInfo_arr;
    
    public $btnposition_label_arr = []; // 按钮位置翻译
    public function __construct($adb,$current_user){

        $this->adb = $adb;
        $this->current_user = $current_user;
        if(!empty($module)){
            $this->tabid = getTabid($module);
        }
	}
    public static function getInstance($adb,$current_user)
    {
        static $getRolesProfilObj;
        if (isset($getRolesProfilObj)) {
            return $getRolesProfilObj;
        }
        $getRolesProfilObj = new cls_getRolesProfile($adb,$current_user);
        return $getRolesProfilObj;
        
    }
    public function __destruct(){

    }
    /**
     * 获取所有角色基本信息
     */
    public function getAllRolesBaseInfo():array
    {
        if(is_array($this->allRolesBaseInfo_arr)){   
            return $this->allRolesBaseInfo_arr;
        }

        $query = 'SELECT profileid,profilename,getpinyin(profilename) as pinyin,`description`,profileseq from ld_profile order by profileseq';
        $result = $this->adb->pquery($query);
        $num_rows = $this->adb->num_rows($result);

        $allRolesBaseInfo_arr = [];
        if ($num_rows > 0) {
            for ($i = 0; $i < $num_rows; $i++) {
                $profilename = (string)$this->adb->query_result($result,$i,'profilename');
		        $profileid = (int)$this->adb->query_result($result,$i,'profileid');
		        $pinyin = (string)$this->adb->query_result($result,$i,'pinyin');
		        $description = (string)$this->adb->query_result($result,$i,'description');
		        $profileseq = (int)$this->adb->query_result($result,$i,'profileseq');
                $allRolesBaseInfo_arr[$profileid]['profilename'] = $profilename;
                $allRolesBaseInfo_arr[$profileid]['profileid'] = $profileid;
                $allRolesBaseInfo_arr[$profileid]['pinyin'] = $pinyin;
                $allRolesBaseInfo_arr[$profileid]['description'] = $description;
                $allRolesBaseInfo_arr[$profileid]['profileseq'] = $profileseq;
            }
        }
        // dump($allRolesBaseInfo_arr);
        $this->allRolesBaseInfo_arr = $allRolesBaseInfo_arr;
        return $allRolesBaseInfo_arr;
    }
    /**
     * 角色权限是否存在
     */
    public function profileExists($profileid):bool
    {
        $result = $this->adb->pquery('SELECT 1 FROM ld_profile WHERE profileid = ?', array($profileid));
        if ($this->adb->num_rows($result) > 0) 
            return true;
        return false;
    }
    /**
     * 根据所选模块获取当前模块下所有自定义按钮的列表数据
     */
    public function getAllActionTab($AllActionsFortab):array
    {
        $allActionTab = [];
        foreach ($AllActionsFortab as $tabid => $actioninfo) {
            $module = strtolower(getTabname($tabid));
            foreach ($actioninfo as $actionid => $actionpresence) {
                if (($actionid == 18 || $actionid == 19) && (($module == 'cashbill' && $cashbill_approvestatusw == 0) || ($module == 'sendcashbill' && $sendcashbill_approvestatusw == 0) || ($module == 'outboundorder' && $outboundorder_approvestatusw == 0) || ($module == 'stock' && $stock_approvestatusw == 0))) {
                    continue;
                }
                // ls 2021-08-04  0047178: （https://81mis.com/kfbcrm [^]）角色权限->销售目标，操作权限中去掉【管理分类】和【推进】操作按钮
                if ($module == 'salesgoal' && ($actionid == 22 || $actionid == 37 )) {//销售目标tabid 85
                    continue;
                }
                $allActionTab[$tabid][$actionid] = $actionpresence;
            }
        }
        
        return $allActionTab;
    }
    /**
     * @version:6.0 角色权限改进
     * @reason 操作权限 生成对应操作按钮的checkbox
     * @author Chj
     */
    public function getDisplayOutput($id, $tabid, $actionid):string
    {
        // @edit:dong @date:2020/09/15 @reason: 非中孚客户 隐藏下载全部附件权限
        $versioninfo = getVersionInfo();
        //edit:duan 放开批量下载权限
        //if ($versioninfo['trade'] != 'zhongfu') {
        // if ($actionid == 49){
        //         return '';
        //     }
        // }
        if ($actionid == 3) {
            $name = $tabid . '_tab';
            $ckbox_id = 'tab_chk_com_' . $tabid;
            $jsfn = 'hideTab(' . $tabid . ')';
            $tag = 'module_tabid';
        } else {
            $temp_name = getActionname($actionid);
            $name = $tabid . '_' . $temp_name;
            $ckbox_id = 'tab_chk_' . $actionid . '_' . $tabid;
            //change and add one with 1,4,2 instead of
            if ($actionid == 11)
                $jsfn = 'unSelectCreate(' . $tabid . ')';
            elseif ($actionid == 4)
                $jsfn = 'unSelectView(' . $tabid . ')';
            elseif ($actionid == 2)
                $jsfn = 'unSelectDelete(' . $tabid . ')';
            elseif ($actionid == 1)
                $jsfn = 'unSelectEditView(' . $tabid . ')';
            elseif ($actionid == 12)
                $jsfn = 'unSelectCopy(' . $tabid . ')';
            elseif ($actionid == 42 || $actionid == 43)
                $jsfn = 'unSelectDownLoadOrPreview(' . $tabid . ',' . $actionid . ')';
            elseif ($actionid == 52 )
                $jsfn = 'unSelectInactivating(' . $tabid . ',' . $actionid . ')';
            else {
                if (isSearchCRMVersion() == 'yes') {
                    return '';
                } else
                    $jsfn = 'unSelectOthers(' . $tabid . ',' . $actionid . ')';
            }
            $tag = 'module_actionname';
        }
        $value = '';
        if ($id == '' && $id != 0) {
            $value = '';
        } elseif ($id == 0) {
            if ($_REQUEST['mode'] == 'view') {
                $value = '<input type="checkbox" disabled onClick="' . $jsfn . ';" id="' . $ckbox_id . '" name="' . $name . '" checked>';
            }
            else{
                $value = '<input type="checkbox" tag="' . $tag . '"  onClick="' . $jsfn . ';" id="' . $ckbox_id . '" name="' . $name . '" checked>';
            }

        } elseif ($id == 1) {
            if ($_REQUEST['mode'] == 'view') {
                $value = '<input type="checkbox" disabled onClick="' . $jsfn . ';" id="' . $ckbox_id . '" name="' . $name . '">';
            } else{
                if($actionid == 50 && $_REQUEST['mode'] == 'create'){
                    $value = '<input type="checkbox" tag="' .$tag. '" id="' .$ckbox_id. '"name="' .$name. '" disabled>';
                }
                    //if($actionid == 8 || $actionid == 38) $value = '<input type="checkbox" tag="' . $tag . '" onClick="' . $jsfn . ';" id="' . $ckbox_id . '" name="' . $name . '" checked>';
                else $value = '<input type="checkbox" tag="' . $tag . '" onClick="' . $jsfn . ';" id="' . $ckbox_id . '" name="' . $name . '">';
            }

        } elseif ($id == 5) {
            $value = '<input type="checkbox" disabled id="' . $ckbox_id . '" name="' . $name . '">';
        } elseif ($id == 6){
            //推进按钮增加提示
            $value = '<input type="checkbox" tag="' . $tag . '" disabled id="' . $ckbox_id . '" name="' . $name . '" >';
        }
        /**Liver 20180130 checkbox和后面文字太挤，加个空格**/
        $value .= '&nbsp;';
        if (getTabModuleName($tabid) == 'PurchaseBack' && $actionid == 15) {
            $value .= '<label for="'.$ckbox_id.'">'.getFixedLabel('DELIVERYCONFIRMATION').'</label>';
        } 
        /**
        * 2016/06/03 Liver
        * bug:0022830: 控制面板>权限管理：服务合同模块，“更改状态”修改为“更改合同状态”；
        */
        else if ($actionid == 23) {
            switch (getTabname($tabid)) {
                case 'ServiceContracts':
                    $value .= '<label for="'.$ckbox_id.'">'.getFixedLabel('SERVICECONTRACTSUPDATE').'</label>';
                    break;
                case 'SalesOrder':
                    $value .= '<label for="'.$ckbox_id.'">'.getFixedLabel('UPDATESTATE').'</label>';
                    break;
                case 'PurchaseOrder':
                    $value .= '<label for="'.$ckbox_id.'">'.getFixedLabel('PURCHASEORDERUPDATE').'</label>';
                    break;
                case 'ProjectTask':
                    $value .= '<label for="'.$ckbox_id.'">'.getFixedLabel('UPDATEPROJECTASKSTATUS').'</label>';
                    break;
                case 'Invoice':
                    $value .= '<label for="'.$ckbox_id.'">'.getFixedLabel('INVOICEUPDATE').'</label>';
                    break;
                case 'PurchaseInvoice':
                    $value .= '<label for="'.$ckbox_id.'">'.getFixedLabel('PURCHASEINVOICEUPDATE').'</label>';
                    break;
                default:
                    return '';
            }
        } else if ($actionid != 3 && $actionid != 23){
            if (getActionlabel($actionid, getTabname($tabid)) != '')

            {$value .= '<label for="'.$ckbox_id.'">'.getActionlabel($actionid, getTabname($tabid)).'</label>';}
            else
                return '';
        }

        return $value;

    }
    /**
     * @version:6.0 角色权限改进
     * @reason 角色详情页，显示，已设置的权限状态
     * @author Chj
     */
    public function getDisplayValue($id, $tabid = 0, $actionid = 0):string
    {
        global $image_path,$theme;
        if ($id == 0) {
            $value = '<img src="' . lingdang_imageurl('prvPrfSelectedTickgreen.gif', $theme) . '">&nbsp;';
        } elseif ($id == 1) {
            $value = '<img src="' . lingdang_imageurl('no.gif', $theme) . '">&nbsp;';
        } else {
            $value = '&nbsp;';
        }
        if (getTabModuleName($tabid) == 'PurchaseBack' && $actionid == 15) {
            $value .= getFixedLabel('DELIVERYCONFIRMATION');
        } else if ($actionid == 23) {
            switch (getTabname($tabid)) {
                case 'ServiceContracts':
                    $value .= getFixedLabel('SERVICECONTRACTSUPDATE');
                    break;
                case 'SalesOrder':
                    $value .= getFixedLabel('UPDATESTATE');
                    break;
                case 'PurchaseOrder':
                    $value .= getFixedLabel('PURCHASEORDERUPDATE');
                    break;
                case 'ProjectTask':
                    $value .= getFixedLabel('UPDATEPROJECTASKSTATUS');
                    break;
                case 'Invoice':
                    $value .= getFixedLabel('INVOICEUPDATE');
                    break;
                case 'PurchaseInvoice':
                    $value .= getFixedLabel('PURCHASEINVOICEUPDATE');
                    break;
                default:
                    return '';
            }
        } else if ($actionid != 3 && $actionid != 23)
            if (getActionlabel($actionid, getTabname($tabid)) != '')
                $value .= getActionlabel($actionid, getTabname($tabid));
            else//更改创建人字段隐藏0（18587: 控制面板>权限管理：新增、编辑、复制界面报错）
                return '';
        return $value;
    }
    /**
     * V6.0 角色权限改进
     * @param 判断模块下是否存在字段
     * @return 是 返回yes； 否 返回no
     * @author Chj
     */
    public function isModuleField($tabid):string
    {
        $query = 'SELECT 1 FROM ld_field WHERE tabid = ?';
        $result = $this->adb->pquery($query, array($tabid));
        $num_rows = $this->adb->num_rows($result);
        $module = getTabModuleName($tabid);
        if ($module == 'Users' || $module == 'Comprehensivereport') {
            return 'no';
        }
        if ($num_rows > 0)
            return 'yes';
        else
            return 'no';
    }
    /**
     * edit: xll
     * date: 2023/02/21
     * 获取最大actionid
     */
    public function getMaxActionId():int
    {
        global $adb;
        $sql_MaxId = 'select max(actionid) from ld_actionmapping';
        $result = $adb->pquery($sql_MaxId, array());
        $MaxId = $adb->query_result($result,0,'max(actionid)');
        return $MaxId;
    }
    /**
     * 【角色权限，操作权限增加“全选”功能】-- 转换为菜单结构的显示
     */
    public function getMenuPrivilegesStand($privileges_stand):array
    {
        //zkt 【角色权限，操作权限增加“全选”功能】--转换为菜单结构的显示
        $parenttabrelinfo = getParentTabrelInfo();
        $tmpprivileges_stand = $privileges_stand;

        $menu_privileges_stand = [];
        foreach ($parenttabrelinfo as $parenttabid => $parenttabrel) 
        {
            $tmpparenttabname = $parenttabrel['parenttabname'];
            $tmptabarr = $parenttabrel['tab'];
            $tmp_stand = [];
            foreach ($tmptabarr as $tabid => $tabinfo) {
                $tmptabname = $tabinfo['tab_tablename'];
                if ($tmptabname != 'ld_tab' || !isset($tmpprivileges_stand[$tabid])) {
                    continue;
                }
                $tmp_stand[$tabid] = $tmpprivileges_stand[$tabid];
                unset($tmpprivileges_stand[$tabid]);
            }
            $menu_privileges_stand[] = array('id' => $parenttabid, 'name' => $tmpparenttabname, 'stand' => $tmp_stand);
        }
        //成员管理
        $userstabid = getTabid('Users');
        if(isset($tmpprivileges_stand[$userstabid])){
            $menu_privileges_stand[] = array('id'=>'Settingup','name'=>'Settingup','stand'=>array($userstabid=>$tmpprivileges_stand[$userstabid]));
            unset($tmpprivileges_stand[$userstabid]);
        }
        //其他
        if(!empty($tmpprivileges_stand)){
            $menu_privileges_stand[] = array('id'=>'menuOthertab','name'=>'menuOthertab','stand'=>$tmpprivileges_stand);
        }
        return $menu_privileges_stand;
    }
    /**
     * 获取所有模块的名称和对应拼音，不传tabid_arr参就是返回所有启用未启用的模块
     */
    public function getAllModulePinyin($tabid_arr = []):array
    {
        crm_load_class_file('MenuUtils','modules/Users');
        $MenuUtilsObj = new MenuUtils();
        $allPinyinLabel = $MenuUtilsObj->getParentTabListPinyin();
        $AllModulePinyin_arr = [];

        if(!empty($tabid_arr)){
            foreach ($tabid_arr as $index => $tabid) {
                $module = getTabname($tabid);
                $modulename = getTranstab($module);
                $pinyinlabel = $allPinyinLabel[$modulename];
                $AllModulePinyin_arr[$tabid] = [
                    'label' => $modulename,
                    'pinyin' => $pinyinlabel,
                ];
            }
        }else{
            foreach ($allPinyinLabel as $label => $pinyinlabel) {
                $module = getTabByModule($label);
                $tabid = getTabid($module);
                $AllModulePinyin_arr[$tabid] = [
                    'label' => $label,
                    'pinyin' => $pinyinlabel,
                ];
            }
        }

        return $AllModulePinyin_arr;
    }
    /**
     * 
     */
    public function getAllUsersInfoByProfileid($profileid):array
    {
        $allUsersInfo_arr = [];
        $sql = 'SELECT ld_users.id,ld_users.last_name,ld_users.pinyin_name,ld_users.wx_userid,ld_user_group_set.groupid,ld_user_group_set.content from ld_users 
                    INNER JOIN ld_users2group on ld_users2group.userid = ld_users.id 
                    LEFT JOIN ld_user_group_set on ld_users.id = ld_user_group_set.userid 
                    and ld_user_group_set.groupid = ld_users2group.groupid and ld_user_group_set.type = \'userlevel\' 
                    where profileid = ?';
        $result = $this->adb->pquery($sql,[$profileid]);
        if($this->adb->num_rows($result)>0){
            $all_result_arr = $this->adb->query_result_all($result);
            foreach ($all_result_arr as $tmp_arr){
                $userid = $tmp_arr['id'];
                $wx_userid = $tmp_arr['wx_userid'];
                $last_name = $tmp_arr['last_name'];
                $userobj=new Users();
                $userobj->wx_userid=$wx_userid;
                $userobj->last_name=$last_name;
				$last_name = getUserlastName($userobj);
                $allUsersInfo_arr[$userid]['last_name'] = $last_name;
                $allUsersInfo_arr[$userid]['pinyin_name'] = $tmp_arr['pinyin_name'];

                $groupid = $tmp_arr['groupid'];
                $groupname = getGroupFullName($groupid);
                if(!isset($allUsersInfo_arr[$userid]['groupname'])){
                    $allUsersInfo_arr[$userid]['groupname'] = $groupname;
                }else{
                    $allUsersInfo_arr[$userid]['groupname'] .= ' , '.$groupname;
                }

                $userlevel = $tmp_arr['content'];
                if(!isset($allUsersInfo_arr[$userid]['userlevel'])){
                    $allUsersInfo_arr[$userid]['userlevel'] = $groupname.':'.$userlevel;
                }else{
                    $allUsersInfo_arr[$userid]['userlevel'] .= ' , '.$groupname.':'.$userlevel;
                }
            }
        }
        // dump($allUsersInfo_arr);
        return $allUsersInfo_arr;
    }
    /**
     * 获取设置用户的表头翻译
     */
    public function getSetUsersTableHeader():array
    {
        $focus = CRMEntity::getInstance('Users');
        $allfieldlabels_arr = $focus->fieldobj->getFieldLabelesByColumn();
        $header = [
            $allfieldlabels_arr['last_name']??getFixedLabel('Name'),
            $allfieldlabels_arr['groupid']??getFixedLabel('Sector'),
            $allfieldlabels_arr['userlevel']??getFixedLabel('POSITIONLEVEL'),
            getFixedLabel('OPERATING'),
        ];
        return $header;
    }

}

class cls_setRolesProfile
{
    private $adb;
    private $current_user;
    protected $selected_profileid = 0;
    public function __construct($adb,$current_user,$selected_profileid){
        $this->adb = $adb;
        $this->current_user = $current_user;
        $this->selected_profileid = $selected_profileid;
    }
    public static function getInstance($adb,$current_user,$selected_profileid)
    {
        static $setRolesProfilObj;
        if (isset($setRolesProfilObj)) {
            return $setRolesProfilObj;
        }
        $setRolesProfilObj = new cls_setRolesProfile($adb,$current_user,$selected_profileid);
        return $setRolesProfilObj;
        
    }
    /**
     * 编辑角色名称，备注
     */
    public function editRole($profileinfo_arr){
        $update_query = "update ld_profile set profilename=?,description=? where profileid=?";
        $this->adb->pquery($update_query, array($profileinfo_arr['profilename'], $profileinfo_arr['description'], $profileinfo_arr['profileid']));
    }
    /**
     * 新建角色
     */
    public function createRole($profileinfo_arr):int
    {
        $new_profileid = $this->adb->getUniqueID("ld_profile");
        $profileseq_result = $this->adb->pquery("select MAX(profileseq) as profileseq from ld_profile");
        $rows = $this->adb->num_rows($profileseq_result);
        if ($rows > 0) {
            $newprofileseq = $this->adb->query_result($profileseq_result, 0, 'profileseq');
            ++$newprofileseq;
        } else {
            $newprofileseq = 1;
        }
        $insert_profile = "insert into ld_profile(profileid, profilename, description,profileseq) values(?,?,?,?)";
        $this->adb->pquery($insert_profile, array($new_profileid, $profileinfo_arr['profilename'], $profileinfo_arr['description'], $newprofileseq));
        return $new_profileid;
    }
    /**
     * 复制角色
     */
    public function copyRole($profileinfo_arr):int
    {
        $new_profileid = $this->createRole($profileinfo_arr);
        $insertprofile_sql = "INSERT INTO ld_profile2standardpermissions ( profileid, tabid, operation, permissions, sequence, relatednames)
                        SELECT ?, tabid, operation, permissions, sequence, relatednames FROM ld_profile2standardpermissions
                        WHERE profileid = ? AND NOT EXISTS (SELECT 1 FROM ld_profile2standardpermissions WHERE profileid = ?)";
        $this->adb->pquery($insertprofile_sql, array($new_profileid, $profileinfo_arr['copied_profileid'], $new_profileid));
        // 复制字段权限
        $insertfieldprofile_sql = "INSERT INTO ld_profile2field ( profileid, tabid, fieldid, visible, `readonly`, editreadonly)
                        SELECT ?, tabid, fieldid, visible, `readonly`, editreadonly FROM ld_profile2field
                        WHERE profileid = ? AND NOT EXISTS (SELECT 1 FROM ld_profile2field WHERE profileid = ?)";
        $this->adb->pquery($insertfieldprofile_sql, array($new_profileid, $profileinfo_arr['copied_profileid'], $new_profileid));
        return $new_profileid;
    }
    /**
     * 删除角色下的用户
     */
    public function deleteUsersInRole($userid_arr):bool
    {
        if(empty($userid_arr)){
            return false;
        }
        $userid_str = implode(',',$userid_arr);
        $update_sql = 'update ld_users set profileid = 0 where id in ('.$userid_str.')';
        $this->adb->pquery($update_sql,[]);
        return true;
    }
    /**
     * 上下移动角色
     */
    public function moveUpDown($profileid,$direction){
        $query = 'SELECT profileseq FROM ld_profile WHERE profileid = ?';
        $result = $this->adb->pquery($query,[$profileid]);
        $seq_before = (int)$this->adb->query_result($result, 0, 'profileseq');
        if ($direction == 'moveup') {
            $seq_after = ($seq_before-1)>0?($seq_before-1):0;
            $this->adb->pquery('UPDATE ld_profile set profileseq=? where profileseq=?',array($seq_before,$seq_after));
			$this->adb->pquery('UPDATE ld_profile set profileseq=? where profileid=?',array($seq_after,$profileid));
		}
		else if ($direction == 'movedown') {
            $seq_after = ($seq_before+1);
            $this->adb->pquery('UPDATE ld_profile set profileseq=? where profileseq=?',array($seq_before,$seq_after));
			$this->adb->pquery('UPDATE ld_profile set profileseq=? where profileid=?',array($seq_after,$profileid));
		}
    }
}