<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author CHJ 2015-03-19
 */


$smarty = new lingdangCRM_Smarty;

global $mod_strings;
global $app_strings;
global $app_list_strings;
global $adb;
global $theme;

if(!empty($_REQUEST['tabid']))
{
	$tabid = $_REQUEST['tabid'];
	$module = getTabModuleName($tabid);
	$tabname = getTranstab($module);
	
	$profileid = $_REQUEST['profileid'];
    $field = new Field($module,$adb);
	$fieldListResult[$module] = $field->getProfileFieldPermissionFortab($profileid);
    $blockinfos = $field->getBlockInfos();  //区块信息
    $focus=CRMEntity::getInstance($module);
    
    $fieldBaseInfo_arr = [];
	for($i=0; $i<count($fieldListResult);$i++)
	{
		$module_name=key($fieldListResult);
        $returnarr = array();

		for($j=0; $j<count($fieldListResult[$module_name]); $j++)
		{
			$fldLabel= $fieldListResult[$module_name][$j][0];//fieldlabel
			$uitype = $fieldListResult[$module_name][$j][2];//uitype
            $fieldid = $fieldListResult[$module_name][$j][4];//fieldid
			$displaytype = $fieldListResult[$module_name][$j][5];//displaytype
			$typeofdata = $fieldListResult[$module_name][$j][6];//typeofdata
            $fieldname = $fieldListResult[$module_name][$j][7];//fieldname
            $tablename = $fieldListResult[$module_name][$j][8];//$tablename
            $blockid = $fieldListResult[$module_name][$j][9];//$blockid
			//chj 2021/1/19 44337: （61mis.com/kfbcrm）角色权限-客户-字段权限；客户模块中，附件的字段权限消失了，普通成员新增时没有附件上传了，只有系统管理员看得到；
            if(!in_array($tablename,$focus->tab_name) && $tablename != 'ld_attachments'&&($uitype!=28&&$uitype!=69&&$uitype!=1108&&$uitype!=1109))
            {
                //edit:can 2020-01-06 43981: (https://61mis.com/ldcrm/ [^])测试部账号；成员管理>文龙（姓名）>角色权限>客户1>字段权限>去掉勾选（联系人姓名、联系人手机）；退出系统管理员账号，登录文龙账号，客户1界面中仍然可以看到联系人的姓名和手机号
                continue;
            }
            if($uitype==301)
            {
                //edit:can 2021-01-13 44150: （61mis.com/kfbcrm）角色权限-字段权限-客户；客户字段权限中有“标签”的权限，设置查看权限是生效的；只读与读写设置未生效
                continue;
            }
            if($displaytype==3){
                continue;
            }
			$fieldtype = explode("~",$typeofdata);
			$mandatory = ''; //必填字段前*图标设置
            $checked = '';//
            $return = array();
            $disabledarr = array('','','','');
			$fieldAccessMandatory = false;
			$fieldAccessRestricted = false;
            //获取勾选内容
            if($fieldListResult[$module_name][$j][1] == 1){//ld_profile2field visible
                $checked = 'invisible'; //不可见
            }else if($fieldListResult[$module_name][$j][3] == 1){//ld_profile2field readonly=1
                $checked = 'readonly';  //只读权限
            }else if($fieldListResult[$module_name][$j][10] == 1){//ld_profile2field editreadonly
                $checked = 'readonlyduringedit';    //编辑时只读
            }else{
                $checked = 'readandwrite';  //读写权限
            }
			if($fieldtype[1] == "M")//表示必填字段
			{
				$mandatory = '<font color="red">*</font>';
			}
			if($disable_field_array[$fieldListResult[$module_name][$j][4]] == 1)
			{
				$mandatory = '<font color="blue">*</font>';
                $disabledarr[0] = 'disabled';  //不可见不可勾选
				$checked = 'invisible';
				$fieldAccessRestricted = true;
			}
            
			// Check for Read-Only or Read-Write Access for the field.
			$fieldReadOnlyAccess = $fieldListResult[$module_name][$j][3];// ld_profile2field readyonly
            
            //特殊字段权限限制设置，字段中部分权限不可勾选
            //	0018575: 普通用户对【编号】字段只有只读权限时，新增单据保存后，编号字段值就为空了；
            if($uitype==4){
                $disabledarr[2] = 'disabled';  //只读权限不可勾选
                $disabledarr[3] = 'disabled';  //编辑时只读不可勾选
  			}
            elseif($displaytype==2 ||$displaytype==4)//查看界面非编辑字段 can
            {
                //数据库非编辑字段为读写权限时，应设置非编辑字段显示权限为未读
                if($checked == 'readandwrite'){
                    $checked = 'readonly';
                }
                $disabledarr[1] = 'disabled';  //读写权限不可选择
                $disabledarr[3] = 'disabled';  //编辑时只读不可勾选
            }
	    	elseif(!$fieldAccessMandatory && !$fieldAccessRestricted) {
			     
            } elseif($fieldAccessMandatory) {
                
            } else {
                $disabledarr[1] = 'disabled';  //读写权限不可勾选
                $disabledarr[2] = 'disabled';  //只读权限不可勾选
                $disabledarr[3] = 'disabled';  //编辑时只读不可勾选
			}
            
            $return[] = $blockinfos[$blockid]; 
            $return[] = array('fieldlabel'=>$mandatory.' '.$fldLabel,'fieldid'=>$fieldid,'fieldname'=>$fieldname);
            $return[] = array('checked'=>$checked,'disabled'=>$disabledarr,'fldname'=>$fieldid.'_'.$fieldname);
            
            $returnarr[]=$return;

            $fieldBaseInfo_arr[$fieldid] = ['fieldlabel' => $fldLabel, 'fieldname' => $fieldname];
        }
		next($fieldListResult);
	}
}
$smarty->assign('PROFILEID', $profileid);
$smarty->assign('BLOCKIDSETTING', $_REQUEST['blockidsetting']);
$smarty->assign('FIELDIDSETTING', $_REQUEST['fieldidsetting']);
$smarty->assign('TABID', $tabid);
$smarty->assign('MODULENAME', $tabname);
$smarty->assign('RETURNARR', $returnarr);
$_REQUEST['diony'] = 'diony';
$arr['fieldBaseInfo_arr'] = $fieldBaseInfo_arr;
$arr['title'] = getFixedLabel('LBL_FIELDS_ACCESS');
$arr['oktext'] = getFixedLabel("SAVE");
$arr['canceltext'] = getFixedLabel("CANCEL");
$str = $smarty->fetch("editProfileField.tpl");
$arr['content'] = $str;
ConvertTojsonString(1, $arr, "success");
exit();
?>