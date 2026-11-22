<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @project 工作协同模板
 * @author Tujt 2015-05-05
 */
global $adb,$current_user;
require('user_privileges/user_language_'.$current_user->id.'.php');
$smarty = new lingdangCRM_Smarty;
if(!empty($_REQUEST['ajax']) && $_REQUEST['ajax'] == true){
	if(!empty($_REQUEST['type'])){
		if($_REQUEST['type'] == 'save_mobile_menu'){
			saveMobileMenu($_REQUEST['linenumber'],$_REQUEST['rownumber'],$_REQUEST['columnname'],$_REQUEST['presence'],$_REQUEST['showtag'],$_REQUEST['isforsearch'],$_REQUEST['frommodule'],$_REQUEST['menu_id']);
		}
        else if($_REQUEST['type'] == 'Inactivate'){	//停用
			$num_rows = getModulePresenceFields($_REQUEST['frommodule'],$_REQUEST['menu_id']);
			$num_rows_search = getModuleSearchFields($_REQUEST['frommodule'],$_REQUEST['menu_id']);
			if(empty($num_rows)){
				echo 'error2';	//不允许将所有字段都设置为不显示，请重新设置！
				exit();
			}
			if(empty($num_rows_search)){
				echo 'error4';	//请至少设置一个字段可用于查询！
				exit();
			}
			$adb->pquery('update ld_cvcolumnlist_wx set presence = 1 where id=?',array($_REQUEST['menu_id']));
		}
        else if($_REQUEST['type'] == 'Activate'){	//启用
			$adb->pquery('update ld_cvcolumnlist_wx set presence = 0 where id=?',array($_REQUEST['menu_id']));
		}
        else if($_REQUEST['type'] == 'deletemenu'){	//删除
			$num_rows = getModulePresenceFields($_REQUEST['frommodule'],$_REQUEST['menu_id']);
			$num_rows_search = getModuleSearchFields($_REQUEST['frommodule'],$_REQUEST['menu_id']);
			if(empty($num_rows)){
				echo 'error2';	//不允许将所有字段都设置为不显示，请重新设置！
				exit();
			}
			if(empty($num_rows_search)){
				echo 'error4';	//请至少设置一个字段可用于查询！
				exit();
			}
			$adb->pquery('delete from ld_cvcolumnlist_wx where id=?',array($_REQUEST['menu_id']));
		}
        $cachekey = 'cache_modulelist_getcvcolumnlist_' . $_REQUEST['frommodule'] . '_getcvcolumnlist_MC';
        unsetCacheDirOne('customview',$cachekey);   
	}
}
$query = "SELECT tabid,`name` from ld_tab where (mobilepresence like '%mobile%'
             or mobilepresence like '%weixin%' or name in ('Productbom')) and presence = 0 and name not in ('CooperativeWork','ChinaMap') and tabid in (select ld_field.tabid from ld_field group by ld_field.tabid) order by tabsequence";
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
$fieldobj=Field::getInstance($module,$adb);
$moduleFields=$fieldobj->getModuleFields();
$query = 'select id,rownumber,listnumber,columnname,presence,systemdefault,showtag,isforsearch from ld_cvcolumnlist_wx where modulename = ? order by rownumber,listnumber';
$result = $adb->pquery($query,array($module));
$num_rows = $adb->num_rows($result);
$del_btn = 'no';
if($num_rows > 0){
	$table = '';
	$row_number = 1;
	for($i = 0; $i<$num_rows; $i++){
		$module_name = array();
		$id = $adb->query_result($result,$i,'id');
		$rownumber = $adb->query_result($result,$i,'rownumber');
		$listnumber = $adb->query_result($result,$i,'listnumber');
		$columnname = $adb->query_result($result,$i,'columnname');
		$presence = $adb->query_result($result,$i,'presence');
		$systemdefault = $adb->query_result($result,$i,'systemdefault');
        $showtag = $adb->query_result($result,$i,'showtag');
        $isforsearch = $adb->query_result($result,$i,'isforsearch');
		$col_arr = explode(':',$columnname);
		$field = $moduleFields[$col_arr[2]];
		$isforsearch_disabled = 'no';//是否启用字段控制“是否根据此字段查询”参数
        if(empty($field))continue;
        $tablename = $field->getTableName();
        if(($tablename=='ld_contactdetails'||$tablename=='ld_contactscf')&&!vtlib_isModuleActive('Contacts')) continue;
		if ($i%2 ==0) {
			$table.='<tr id="setting_'.$i.'" class="lvtColData" onmouseover="listOnMouseOver(ld(this))" onmouseout="listOnMouseOut(ld(this),\'on\')" >';
		}
		else{
			$table.='<tr id="setting_'.$i.'" class="lvtColDataBj" onmouseover="listOnMouseOver(ld(this))" onmouseout="listOnMouseOut(ld(this),\'On\')" >';
		}
		$table .= '<td align="left">' . $row_number++ . '</td>';
		$table .= '<td align="left">' . $rownumber . '</td>';
		$table .= '<td align="left">' . $listnumber . '</td>';
		$table .= '<td align="left">' . $field->getFieldLabel() . '</td>';
        //duan 2022-2-16 关于是否启用按钮的显示优化
        $table .= '<td><input type="checkbox" onclick="change_tablefield_presence(this,'.$id.',\'cvcolumnlist_wx_presence\')" id="cvcolumnlist_wx_presence" class="second_switch" ';
		if($presence == 1){
            $table .= '/></td>';
			$isforsearch_disabled = 'yes';
		}else{
			$table .= 'checked /></td>';
		}
        //duan 2022-2-16 关于是否启用按钮的显示优化
        $table .= '<td><input type="checkbox" onclick="change_tablefield_presence(this,'.$id.',\'cvcolumnlist_wx_showtag\')" id="cvcolumnlist_wx_showtag" class="second_switch" ';
        if($showtag == 'yes'){
            $table .= 'checked /></td>';
		}else{
			$table .= '/></td>';
		}
		//xxy 2023-11-22 增加参数：是否根据此字段查询
        $table .= '<td><input type="checkbox" onclick="change_tablefield_presence(this,'.$id.',\'cvcolumnlist_wx_isforsearch\')" id="cvcolumnlist_wx_isforsearch" class="second_switch" ';
        if($isforsearch_disabled == 'yes'){
            $table .= ' disabled ';
		}
		if($isforsearch == 'yes'){
            $table .= 'checked /></td>';
		}else{
			$table .= '/></td>';
		}
		$button = '';
		$button .= '<a class="Anu3_a" btn="editBtn" record="'.$id.'" onclick="fun_mobile_menu.getInstance(\''.$id.'\').MobileMenu_edit()">'.getFixedLabel('EDIT').'</a>';
		/*if($presence == 1){
			$button .= '<a class="Anu3_a" btn="addBtn" record="'.$id.'" onclick="fun_mobile_menu.getInstance(\''.$id.'\').MobileMenu_activate()">'.getFixedLabel('ACTIVATE').'</a>';
		}else{
			$button .= '<a class="Anu3_a" btn="addBtn" record="'.$id.'" onclick="fun_mobile_menu.getInstance(\''.$id.'\').MobileMenu_inactivate()" >'.getFixedLabel('INACTIVATE').'</a>';
		}*/
		
		$button .= '<a class="Anu3_a redFont" btn="addBtn" record="'.$id.'" onclick="fun_mobile_menu.getInstance(\''.$id.'\').MobileMenu_delete()">'.getFixedLabel('DELETE').'</a>';
		
		$table .= '<td align="left">' . $button . '</td>';
		$table .= '</tr>';
	}
}
$smarty->assign('DELBTN',$del_btn);
$smarty->assign('MOBILEMODULEHTML',$table);
$smarty->assign('LANGUAGETYPE',$languageType);
$smarty->assign('ALLMODULE',$alltabs);
$_REQUEST['diony']='yes';
// require_once('SetmenuControl.php');
if($_REQUEST['ajax']&&$_REQUEST['ajax']==true){
    $smarty->display('MobileMenuListEntries.tpl');
	exit();
}
else
{
	$arr['content']= $smarty->fetch('MobileMenuList.tpl');
    ConvertTojsonString(1,$arr,"success");
}

function saveMobileMenu($linenumber,$rownumber,$columnname,$presence,$showtag,$isforsearch,$frommodule,$menu_id){
	global $adb;
	$query = 'select columnname from ld_cvcolumnlist_wx where rownumber = ? and listnumber = ? and modulename = ? and presence = 0';
	if(!empty($menu_id)){
		$query .= ' and id != ' . $menu_id;
	}
	$result = $adb->pquery($query,array($linenumber,$rownumber,$frommodule));
    $oldcolumnname = $adb->query_result($result,0,'columnname');
    $oldcols = explode(':',$oldcolumnname);
    
    $fieldobj=Field::getInstance($frommodule,$adb);
	$moduleFields=$fieldobj->getModuleFields();
    //0030379: 控制面板 > 移动端模块列表界面定制 ：当设置行列的某个字段被隐藏了时，列表中就没有显示该字段行的设置了
	if($adb->num_rows($result) >= 1&&!empty($moduleFields[$oldcols[2]])){
        $tablename = $moduleFields[$oldcols[2]]->getTableName();
        if(($tablename=='ld_contactdetails'||$tablename=='ld_contactscf')&&!vtlib_isModuleActive('Contacts')){
            $adb->pquery('delete from ld_cvcolumnlist_wx where rownumber = ? and listnumber = ? and modulename = ?',array($linenumber,$rownumber,$frommodule));
        }else{
            echo 'error1';	//所在行a，所在列b已有字段，请重新设置！
            exit();
        }
	}
	if($presence == 1){
		$num_rows = getModulePresenceFields($frommodule,$menu_id);
		if(empty($num_rows)){
			echo 'error2';	//不允许将所有字段都设置为不显示，请重新设置！
			exit();
		}
	}
	if($isforsearch == 'no'){
		$num_rows_search = getModuleSearchFields($frommodule,$menu_id);
		if(empty($num_rows_search)){
			echo 'error4';	//请至少设置一个字段可用于查询！
			exit();
		}
	}
    //控制第一行只有一列
    //0034946: 设置-系统设置-界面定制-移动端模块列表定制，第一行编辑保存，无法保存
    if($linenumber==1&&$presence==0&&empty($menu_id)){
        $sql = 'select 1 from ld_cvcolumnlist_wx where rownumber=? and presence=? and modulename=?';
        $result = $adb->pquery($sql,array(1,0,$frommodule));
        if($adb->num_rows($result)){
            echo 'error3';exit;
        }
    }
	
	$cols = explode(':',$columnname);
	$field = $moduleFields[$cols[2]];
	if(!empty($field)){
		$typeofdata = $field->getTypeOfData();
		$typeofdata_arr = explode('~',$typeofdata);
		$columnname .= '_' . $field->getFieldLabel() . ':' . $typeofdata_arr[0];
	}
	if(!empty($menu_id)){	//编辑
		$adb->pquery('update ld_cvcolumnlist_wx set rownumber = ?,listnumber=?,columnname=?,presence=?,showtag=?,isforsearch=? where id = ?',array($linenumber,$rownumber,$columnname,$presence,$showtag,$isforsearch,$menu_id));
	}else{	//新增
		$adb->pquery('insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,presence,showtag,isforsearch,systemdefault) values (?,?,?,?,?,?,?,?)',array($frommodule,$linenumber,$rownumber,$columnname,$presence,$showtag,$isforsearch,'no'));
	}
}

function getModulePresenceFields($frommodule,$menu_id){
	global $adb;
	$query = 'select 1 from ld_cvcolumnlist_wx where modulename = ? and presence <> 1';
	if(!empty($menu_id)){
		$query .= ' and id != ' . $menu_id;
	}
	$result = $adb->pquery($query,array($frommodule));
	$num_rows = $adb->num_rows($result);
	return $num_rows;
}
function getModuleSearchFields($frommodule,$menu_id){
	global $adb;
	$query = 'select 1 from ld_cvcolumnlist_wx where modulename = ? and isforsearch <> "no"';
	if(!empty($menu_id)){
		$query .= ' and id != ' . $menu_id;
	}
	$result = $adb->pquery($query,array($frommodule));
	$num_rows = $adb->num_rows($result);
	return $num_rows;
}
?>