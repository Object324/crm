<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @project 工作协同模板
 * @author Tujt 2015-05-05
 */
  global $current_user;

//$_SESSION[globalStatic::$root_directory.'prevmenu_modulefile'.$current_user->id]='SettingLeftRight';
//$_SESSION[globalStatic::$root_directory.'prevmenu_modilefile_childmenu'.$current_user->id]='MobileMainInfo';
//$_SESSION[globalStatic::$root_directory.'prevmenu_module'.$current_user->id]='Settings';
global $adb,$current_user;
require('user_privileges/user_language_'.$current_user->id.'.php');
$smarty = new lingdangCRM_Smarty;
$tabid = getTabid($_REQUEST['frommodule']);

//20230316 zxm XUQIU1001134 移动端详情界面定制，增加“分录明细显示样式”参数（郭良峰）
include_once (globalStatic::$root_directory.'modules/Settings/MobileDetailInfo.php');
$MobileDetailInfoObj = new MobileDetailInfo($_REQUEST['frommodule'],$_REQUEST['mobiledetailinfoshowtype']);
$detailtype = $MobileDetailInfoObj->detailtype;
$smarty->assign('detailtype',$detailtype);
if(!empty($detailtype)&&$detailtype!='no'){

    $MobileDetailInfoObj->getAllDetailFields();
    $fieldAllInfoArr = $MobileDetailInfoObj->fieldAllInfoArr;
    $fieldSelectedArr = $MobileDetailInfoObj->fieldSelectedArr;
    $smarty->assign('fieldAllInfoArr',$fieldAllInfoArr);
    $smarty->assign('fieldSelectedArr',$fieldSelectedArr);
    $smarty->assign('mobiledetailinfoshowtype',$MobileDetailInfoObj->mobiledetailinfoshowtype);
}


if(!empty($_REQUEST['ajax']) && $_REQUEST['ajax'] == true){
	if(!empty($_REQUEST['type'])){
		if($_REQUEST['type'] == 'save_mobile_maininfo'){
			saveMobileMainInfo($_REQUEST['linenumber'],$_REQUEST['fieldname'],$_REQUEST['presence'],$tabid,$_REQUEST['showtag'],$_REQUEST['maininfo_id']);
            resetMainInfoSequence($tabid);
        }else if($_REQUEST['type'] == 'Inactivate'){	//停用
			$num_rows = getMaininfoPresenceFields($tabid,$_REQUEST['maininfo_id']);
			if(empty($num_rows)){
				echo 'error2';	//不允许将所有字段都设置为不显示，请重新设置！
				exit();
			}
			$adb->pquery('update ld_fieldwxmaininfo set presence = 1 where id=?',array($_REQUEST['maininfo_id']));
		}else if($_REQUEST['type'] == 'Activate'){	//启用
			$adb->pquery('update ld_fieldwxmaininfo set presence = 0 where id=?',array($_REQUEST['maininfo_id']));
		}else if($_REQUEST['type'] == 'deletemaininfo'){	//删除
			$num_rows = getMaininfoPresenceFields($tabid,$_REQUEST['maininfo_id']);
			if(empty($num_rows)){
				echo 'error2';	//不允许将所有字段都设置为不显示，请重新设置！
				exit();
			}
			$adb->pquery('delete from ld_fieldwxmaininfo where id=?',array($_REQUEST['maininfo_id']));
            resetMainInfoSequence($tabid);
		} else if($_REQUEST['type']=='change_mobiledetailinfoshowtype'){
            //change_mobiledetailinfoshowtype  单选change事件 20230316 zxm XUQIU1001134 移动端详情界面定制，增加“分录明细显示样式”参数（郭良峰）
            ConvertTojsonString(1, [
                'fieldAllInfoArr'=>$fieldAllInfoArr,
                'fieldSelectedArr'=>$fieldSelectedArr
                ], 'success');
        }else if($_REQUEST['type']=='save_mobiledetailinfofield'){
            // 20230316 zxm XUQIU1001134 移动端详情界面定制，增加“分录明细显示样式”参数（郭良峰）
            $msg = $MobileDetailInfoObj->saveSelectedDetailFields();
            ConvertTojsonString(1, [],$msg);
        }
	}
}
$query = "select tabid,`name` from ld_tab where mobilepresence like '%weixin%' and presence = 0 and name not in ('CooperativeWork','ChinaMap','Singin')
                                and tabid in (select ld_field.tabid from ld_field group by ld_field.tabid) order by tabsequence";
$result = $adb->pquery($query,array());
$num_rows = $adb->num_rows($result);
if($num_rows > 0){
	for($i = 0; $i<$num_rows; $i++){
		$tabid = $adb->query_result($result,$i,'tabid');
		$tabname = $adb->query_result($result,$i,'name');
		$alltabs[] = array('module'=>$tabname,'tabname'=>getTranstab($tabname));
	}
}
if(!empty($_REQUEST['frommodule'])){
	$module = $_REQUEST['frommodule'];
}else{
	$module = $alltabs[0]['module'];
}
$moduletabid = getTabid($module);
$fieldobj=Field::getInstance($module,$adb);
$moduleFields=$fieldobj->getModuleFields();
$query = 'select id,fieldname,showtag,presence from ld_fieldwxmaininfo where tabid = ? order by sequence';
$result = $adb->pquery($query,array($moduletabid));
$num_rows = $adb->num_rows($result);
$del_btn = 'no';
if($num_rows > 0){
	$table = '';
	$row_number = 1;
	for($i = 0; $i<$num_rows; $i++){
		$module_name = array();
        $id = $adb->query_result($result,$i,'id');
		$fieldname = $adb->query_result($result,$i,'fieldname');
		$showtag = $adb->query_result($result,$i,'showtag');
		$presence = $adb->query_result($result,$i,'presence');

		$field = $moduleFields[$fieldname];
		if(empty($field))continue;
		if ($i%2 ==0) {
			$table.='<tr id="setting_'.$i.'" class="lvtColData" onmouseover="listOnMouseOver(ld(this))" onmouseout="listOnMouseOut(ld(this),\'on\')" >';
		}
		else{
			$table.='<tr id="setting_'.$i.'" class="lvtColDataBj" onmouseover="listOnMouseOver(ld(this))" onmouseout="listOnMouseOut(ld(this),\'On\')" >';
		}
		$table .= '<td align="left">' . $row_number . '</td>';
		$table .= '<td align="left">' . $row_number . '</td>';
		$table .= '<td align="left">' . $field->getFieldLabel() . '</td>';
		//duan 2022-2-16 关于是否启用按钮的显示优化
        $table .= '<td id="ispresence_'.$i.'"><input type="checkbox" onclick="change_tablefield_presence(this,'.$id.',\'fieldwxmaininfo_presence\')" class="second_switch" ';
		if($presence == 1){
            $table .= '/></td>';
		}else{
			$table .= 'checked /></td>';
		}
        //duan 2022-2-16 关于是否启用按钮的显示优化
        $table .= '<td><input type="checkbox" onclick="change_tablefield_presence(this,'.$id.',\'fieldwxmaininfo_showtag\')" class="second_switch" ';
        if($showtag == 'yes'){
            $table .= 'checked /></td>';
		}else{
			$table .= '/></td>';
		}
		$button = '';
		$button .= '<a class="Anu3_a" btn="editBtn" record="'.$id.'" onclick="fun_mobile_maininfo.getInstance(\''.$id.'\').MobileMainInfo_edit()">'.getFixedLabel('EDIT').'</a>';
		/*if($presence == 1){
			$button .= '<a class="Anu3_a" btn="addBtn" record="'.$id.'" onclick="fun_mobile_maininfo.getInstance(\''.$id.'\').MobileMainInfo_activate()">'.getFixedLabel('ACTIVATE').'</a>';
		}else{
			$button .= '<a class="Anu3_a" btn="addBtn" record="'.$id.'" onclick="fun_mobile_maininfo.getInstance(\''.$id.'\').MobileMainInfo_inactivate()" >'.getFixedLabel('INACTIVATE').'</a>';
		}*/
		
		$button .= '<a class="Anu3_a redFont" btn="addBtn" record="'.$id.'" onclick="fun_mobile_maininfo.getInstance(\''.$id.'\').MobileMainInfo_delete()">'.getFixedLabel('DELETE').'</a>';
		
		$table .= '<td align="left">' . $button . '</td>';
		$table .= '</tr>';
        $row_number++;
	}
}
$smarty->assign('DELBTN',$del_btn);
$smarty->assign('num_rows',$num_rows);
$smarty->assign('MOBILEMODULEHTML',$table);
$smarty->assign('LANGUAGETYPE',$languageType);
$smarty->assign('ALLMODULE',$alltabs);
// require_once('SetmenuControl.php');
$_REQUEST['diony']='yes';
if($_REQUEST['ajax']&&$_REQUEST['ajax']==true){
    $smarty->display('MobileMainInfoEntries.tpl');
	exit();
}
else
{
	$arr['content']= $smarty->fetch('MobileMainInfo.tpl');
 	ConvertTojsonString(1,$arr,"success");
}

function saveMobileMainInfo($linenumber,$fieldname,$presence,$tabid,$showtag,$maininfo_id){
	global $adb;
    //控制最多5行 （先将隐藏的字段删除再控制20180416xxs）
    $focus = CRMEntity::getInstance($_REQUEST['frommodule']);
    $modulefields = $focus->fieldobj->getModuleFields();
    $fieldsql = 'select id,fieldname from ld_fieldwxmaininfo where tabid=?';
    $fieldresult = $adb->pquery($fieldsql,array($tabid));
    $num_rows = $adb->num_rows($fieldresult);
    for($i=0;$i<$num_rows;$i++){
        $tmp_id = $adb->query_result($fieldresult,$i,'id');
        $tmp_fieldname = $adb->query_result($fieldresult,$i,'fieldname');
        if(!array_key_exists($tmp_fieldname,$modulefields)){
            $adb->pquery('delete from ld_fieldwxmaininfo where tabid=? and id=?',array($tabid,$tmp_id));
        }
    }
    
    $sql = 'select count(1) from ld_fieldwxmaininfo where tabid=? and presence=0';
    if(!empty($maininfo_id)) $sql.=' and id!='.$maininfo_id;
    $result = $adb->pquery($sql,array($tabid));
    $count = $adb->query_result($result,0,0);
    if($count>=5){
        echo 'error1';
        exit;
    }
    //向后插入处理
    if(!empty($maininfo_id)){
        $sql = 'select sequence from ld_fieldwxmaininfo where id=?';
        $result = $adb->pquery($sql,array($maininfo_id));
        $sequence = $adb->query_result($result,0,0);
        $adb->pquery('update ld_fieldwxmaininfo set sequence=sequence-1 where sequence>? and sequence<=? and tabid=?',array($sequence,$linenumber,$tabid));
    }

    $adb->pquery('update ld_fieldwxmaininfo set sequence=sequence+1 where sequence>=? and tabid=?',array($linenumber,$tabid));
	if(!empty($maininfo_id)){	//编辑
		$adb->pquery('update ld_fieldwxmaininfo set tabid=?,fieldname=?,sequence=?,showtag=?,presence=? where id = ?',array($tabid,$fieldname,$linenumber,$showtag,$presence,$maininfo_id));
	}else{	//新增
		$adb->pquery('insert into ld_fieldwxmaininfo(tabid,fieldname,sequence,showtag,presence) values (?,?,?,?,?)',array($tabid,$fieldname,$linenumber,$showtag,$presence));
	}
}

function getMaininfoPresenceFields($tabid,$maininfo_id){
	global $adb;
	$query = 'select 1 from ld_fieldwxmaininfo where tabid = ? and presence <> 1';
	if(!empty($maininfo_id)){
		$query .= ' and id != ' . $maininfo_id;
	}
	$result = $adb->pquery($query,array($tabid));
	$num_rows = $adb->num_rows($result);
	return $num_rows;
}

function resetMainInfoSequence($tabid){
    global $adb;
    $sql = 'select id from ld_fieldwxmaininfo where tabid = ? order by sequence';
    $result = $adb->pquery($sql,array($tabid));
    $num_rows = $adb->num_rows($result);
    if($num_rows){
        for($i=0;$i<$num_rows;$i++){
            $maininfoid = $adb->query_result($result,$i,0);
            $adb->pquery('update ld_fieldwxmaininfo set sequence=? where id=?',array($i+1,$maininfoid));
        }
    }
}
?>