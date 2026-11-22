<?php
global $adb,$current_user;
require('user_privileges/user_language_'.$current_user->id.'.php');
$smarty = new lingdangCRM_Smarty;
if(!empty($_REQUEST['menu_id'])){
	$query = 'select columnname,presence,listnumber,rownumber,showtag,isforsearch from ld_cvcolumnlist_wx where id = ?';
	$result = $adb->pquery($query,array($_REQUEST['menu_id']));
	$col = $adb->query_result($result,0,'columnname');
	$cols = explode(':',$col);
	$cols_arr = explode('_',$cols[3]);
	$columnname = $cols[0] . ':' . $cols[1] . ':' . $cols[2] . ':' . $cols_arr[0];
	$presence = $adb->query_result($result,0,'presence');
	$listnumber = $adb->query_result($result,0,'listnumber');
	$rownumber = $adb->query_result($result,0,'rownumber');
    $showtag = $adb->query_result($result,0,'showtag');
    $isforsearch = $adb->query_result($result,0,'isforsearch');
    if(empty($showtag)) $showtag='no';
}
if(!empty($_REQUEST['frommodule'])){
    $frommodule = $_REQUEST['frommodule'];
	$query = 'select columnname from ld_cvcolumnlist_wx where modulename = ?' ;
	if(!empty($_REQUEST['menu_id'])){
		$query .= ' and id != ' . $_REQUEST['menu_id'];
	}
    $nonsupport = array('69','1109','1108','28','200','301');//'202'选择源单可以显示
	$result = $adb->pquery($query,array($_REQUEST['frommodule']));
	$num_rows = $adb->num_rows($result);
	for($i = 0;$i < $num_rows;$i++){
		$col = $adb->query_result($result,$i,'columnname');
		$cols = explode(':',$col);
		$cols_arr = explode('_',$cols[3]);
		$haveFields[] = $cols[0] . ':' . $cols[1] . ':' . $cols[2] . ':' . $cols_arr[0];
	}
	$fieldobj=Field::getInstance($_REQUEST['frommodule'],$adb);
	$moduleFields=$fieldobj->getModuleFields();
	foreach($moduleFields as $fieldname => $fieldinfo){
	    $tablename = $fieldinfo->getTableName();
        $uitype = $fieldinfo->getUIType();
        $save_database = $fieldinfo->getSaveDataBase();
        $big_type = $fieldinfo->getBigType();
        //editor:gyq_129 reason:引用字段不保存数据则在列表字段设置界面不显示  2019/7/26 10:25 ID1000529
        if($fieldinfo->isRelatedModuleField() && $save_database=='no')
            continue;
	    if(($tablename=='ld_contactdetails'||$tablename=='ld_contactscf')&&(!vtlib_isModuleActive('Contacts')||$_REQUEST['frommodule']=='ServiceCharge')) continue;
		$cvcustomview = $fieldinfo->getTableName() . ':' . $fieldinfo->getColumnName() . ':'.$fieldname . ':' . $_REQUEST['frommodule'];
		if(!in_array($cvcustomview,$haveFields)&&!in_array($uitype,$nonsupport)){
			$allFields[$fieldname] = array(
				'fieldlabel' => $fieldinfo->getFieldLabel(),
				'columnname' => $cvcustomview,
			);
		}
	}
    //如果该模块有字段处在第一行，除了该字段，其他字段下拉框选项从2开始，
    $array_line = array('1','2','3','4','5','6','7','8','9','10');
    $sql ="select columnname,id from ld_cvcolumnlist_wx where modulename = ?";
    $result = $adb->pquery($sql,array($frommodule));
    $num_rows = $adb->num_rows($result);
    if($num_rows >= 1){
         for($i = 0; $i < $num_rows; $i++){
            $mobile_colname=$adb->query_result($result,$i,'columnname');
            $mobile_id =$adb->query_result($result,$i,'id');
            $col_array = explode(':',$mobile_colname);
            $mobile_tabid = getTabid($frommodule);
            $query = "select presence from ld_field where tabid=? and columnname=?";
            $sql_result = $adb->pquery($query,array($mobile_tabid,$col_array[1]));
            $num_row = $adb->num_rows($sql_result);
            $mobile_presence=$adb->query_result($sql_result,0,'presence');
            if($num_row < 1 ||$mobile_presence == 1 ){
                $sql = "delete from ld_cvcolumnlist_wx where id =? ";
                $adb->pquery($sql,array($mobile_id));   
            }
        }
    }
    
    $query = "select id from ld_cvcolumnlist_wx where rownumber ='1' and modulename =?";
    $result = $adb->pquery($query,array($_REQUEST['frommodule']));
    if($adb->num_rows($result)){
        $first_menuid = $adb->query_result($result,0,'id');
        if($_REQUEST['menu_id'] == $first_menuid){
        }else{
            unset($array_line[0]);
        }
        //若该模块不存在字段处在第一行，所有字段下拉框从1开始显示
    }else{    
    }
}
// if($presence == 1){
    $isforsearch_disabled = $presence?'yes':'no';
// }
$smarty->assign('MENUID',$_REQUEST['menu_id']);
$smarty->assign('COLUMNNAME',$columnname);
$smarty->assign('PRESENCE',$presence);
$smarty->assign('SHOWTAG',$showtag);
$smarty->assign('ISFORSEARCH',$isforsearch);
$smarty->assign('ISFORSEARCH_DISABLED',$isforsearch_disabled);
$smarty->assign('ROWNUMBER',$listnumber);
$smarty->assign('LINENUMBER',$rownumber);
$smarty->assign('FROMMODULE',$_REQUEST['frommodule']);
$smarty->assign('ALLFIELDS',$allFields);
$smarty->assign('ARRAYLINE',$array_line);

$str=$smarty->fetch('MobileMenu_create.tpl');
$arr['title'] = getFixedLabel('NEWBLOCK');
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$arr['content']=$str;
ConvertTojsonString(1,$arr,'success');

exit();
?>