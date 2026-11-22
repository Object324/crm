<?php
/*+********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*} 
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ********************************************************************************/
	
global $adb,$current_user, $mod_strings,$currentModule;
$is_admin=is_admin($current_user);
$modval=trim($_REQUEST['modname']);
$dash=trim($_REQUEST['dash']);
$home=trim($_REQUEST['home']);

if(!empty($modval)){
	$tabid = getTabId($modval);
	$ssql = "select ld_customview.*, ld_users.user_name from ld_customview inner join ld_tab on ld_tab.name = ld_customview.entitytype 
				left join ld_users on ld_customview.userid = ld_users.id ";
	$ssql .= " where ld_tab.tabid=?";
	$sparams = array($tabid);
	
	if($is_admin == false){
		$ssql .= " and (ld_customview.status=0 or ld_customview.userid = ? or ld_customview.status = 3 or ld_customview.userid in(select ld_user2role.userid from ld_user2role inner join ld_users on ld_users.id=ld_user2role.userid inner join ld_role on ld_role.roleid=ld_user2role.roleid where ld_role.parentrole like '".$current_user_parent_role_seq."::%'))";
		array_push($sparams, $current_user->id);
	}
	$result = $adb->pquery($ssql, $sparams);
	
	if($adb->num_rows($result)==0){
	  echo $mod_strings['MSG_NO_FILTERS'];
	  die;
	}else{
		$html = '<select id=selFilterid name=selFiltername onchange=setPrimaryFld(this) class="detailedViewTextBox" onfocus="this.className=\'commonDetailedTextBox gwidth70 bgcolordh\'" onblur="this.className=\'detailedViewTextBox\'"  style="width:60%">';
		for($i=0;$i<$adb->num_rows($result);$i++){
			if($adb->query_result($result,$i,"viewname")=='All'){
				$html .= "<option value='".$adb->query_result($result,$i,'cvid')."'>".getTranslatedString('COMBO_ALL',$currentModule)."</option>";
			} else if($adb->query_result($result,$i,'userid')==$current_user->id){
				$html .= "<option value='".$adb->query_result($result,$i,'cvid')."'>".$adb->query_result($result,$i,"viewname")."</option>";
			} else {
				$html .= "<option value='".$adb->query_result($result,$i,'cvid')."'>".$adb->query_result($result,$i,"viewname")."[".$adb->query_result($result,$i,'user_name')."]</option>";
			}
		}
		$html .= '</select>';
	}
	echo $html;
}


if(!empty($_REQUEST['primecvid'])){
	$cvid=$_REQUEST['primecvid'];
	$fieldmodule = vtlib_purify($_REQUEST['fieldmodname']);
	$queryprime="select cvid,columnname from ld_cvcolumnlist where columnname not like '%::%' and cvid=?";
	$result=$adb->pquery($queryprime,array($cvid));
	global $current_language,$app_strings;
	$fieldmod_strings = return_module_language($current_language, $fieldmodule);
	if($adb->num_rows($result)==0){
	  echo $mod_strings['MSG_NO_FIELDS'];
	  die;
	}else{
		$html = '<select id=selPrimeFldid name=PrimeFld multiple class="detailedViewTextBox" onfocus="this.className=\'commonDetailedTextBox gwidth70 bgcolordh\'" onblur="this.className=\'detailedViewTextBox\'" style="width:60%">';
		for($i=0;$i<$adb->num_rows($result);$i++){
			$columnname=$adb->query_result($result,$i,"columnname");
			if($columnname != ''){
				$prifldarr=explode(":",$columnname);
				$fieldname = $prifldarr[2];
				$priarr=explode("_",$prifldarr[3],2); //getting field label
				$prifld = str_replace("_"," ",$priarr[1]);
				if($is_admin == false){
					$fld_permission = getFieldVisibilityPermission($fieldmodule,$current_user->id,$fieldname);
				}
				if($fld_permission == 0){
					$field_query = $adb->pquery("SELECT fieldlabel FROM ld_field WHERE fieldname = ? AND tablename = ? and ld_field.presence in (0,2)", array($fieldname,$prifldarr[0]));
					$field_label = $adb->query_result($field_query,0,'fieldlabel');
					if(trim($field_label) != '')
						$html .= "<option value='".$columnname."'>".getTranslatedString($field_label, $fieldmodule)."</option>";
				}
			}
		}
		$html .= '</select>';
	}
	echo $html;	
}

if(!empty($_REQUEST['showmaxval']) && !empty($_REQUEST['sid'])){
	$sid=$_REQUEST['sid'];
	$maxval=$_REQUEST['showmaxval'];
	global $adb;
	$query="select stufftype from ld_homestuff where stuffid=?";
	$res=$adb->pquery($query, array($sid));
	$stufftypename=$adb->query_result($res,0,"stufftype");
	if($stufftypename=="Module"){
		$qry="update ld_homemodule set maxentries=? where stuffid=?";
		$result=$adb->pquery($qry, array($maxval, $sid));
	}else if($stufftypename=="RSS"){
		$qry="update ld_homerss set maxentries=? where stuffid=?";
		$result=$adb->pquery($qry, array($maxval, $sid));
	}else if($stufftypename=="Default"){
		$qry="update ld_homedefault set maxentries=? where stuffid=?";
		$result=$adb->pquery($qry, array($maxval, $sid));
	}
	echo "loadStuff(".$sid.",'".$stufftypename."')";
}

if(!empty($_REQUEST['dashVal'])){
	$did=$_REQUEST['did'];
	global $adb;
	$qry="update ld_homedashbd set dashbdtype=? where stuffid=?";	
	$res=$adb->pquery($qry, array($_REQUEST['dashVal'], $did));
	echo "loadStuff(".$did.",'DashBoard')";
}

if(!empty($_REQUEST['reportVal'])){
	$stuffid=$_REQUEST['stuffid'];
	global $adb;
	$qry="update ld_homereportchart set reportcharttype=? where stuffid=?";
	$res=$adb->pquery($qry, array($_REQUEST['reportVal'], $stuffid));
	echo "loadStuff(".$stuffid.",'ReportCharts')";
}

if(!empty($_REQUEST['homestuffid'])){
	$sid=$_REQUEST['homestuffid'];
	global $adb;
	$query="delete from ld_homestuff where stuffid=?";
	$result=$adb->pquery($query, array($sid));
	echo "SUCCESS";
}

//Sequencing of blocks starts
/**
 * AUTHOR:BY LD KEVIN
 * DATE:20130225
 * 
 */
if(!empty($_REQUEST['matrixsequence'])){
	global $adb;
    $user_info=getuserInfoByPrivileges($current_user);
    
    $roleId=$user_info['roleid'];
    $querys='select templateid from ld_templatesrole where roleid=?';
    $results=$adb->pquery($querys,array($roleId));
    $templateId=$adb->query_result($results,0,'templateid');
    if(isset($templateId)&&$templateId!=''){
        $sequence = explode('_',$_REQUEST['matrixsequence']);
    	for($i=0, $seq=0;$i<count($sequence)-1;$i++, $seq++){
    		//$query = 'update ld_homestuff set stuffsequence=? where stuffid=?';
            $query='update ld_templatesstuff set stuffsequence=? where stuffid=? and templateid=?';
    		$result = $adb->pquery($query, array($seq, $sequence[$i],$templateId));
    	}
    }
	
	echo "<table cellpadding='10' cellspacing='0' border='0' width='100%' class='vtResultPop small'><tr><td align='center'>布局保存</td></tr></table>";
}
//Sequencing of blocks ends

if(isset($_REQUEST['act']) && $_REQUEST['act'] =="hide"){
	$stuffid=$_REQUEST['stuffid'];
	global $adb,$current_user;
	$qry="update ld_homestuff set visible=1 where stuffid=?";
	$res=$adb->pquery($qry, array($stuffid));
	echo "SUCCESS";
}

//saving layout here
if(!empty($_REQUEST['layout'])){
	global $adb, $current_user;
	
	$sql = "delete from ld_home_layout where userid=?";
	$result = $adb->pquery($sql, array($current_user->id));
	
	$sql = "insert into ld_home_layout values (?, ?)";
	$result = $adb->pquery($sql, array($current_user->id, $_REQUEST['layout']));
	if(!$result){
		echo "SUCCESS";
	}
}

if(!empty($home)){
	global $current_user,$mod_strings,$currentModule;
	$UMOD = $mod_strings;
	$focus = new Users();
	/*$homeWidgets = $focus->getHomeStuffOrder($current_user->id);
    if(!in_array("", $homeWidgets)){
			$errorMsg="LBL_NO_WIDGETS_HIDDEN";
	}
	$html='<table border="0" cellpadding="5" cellspacing="0" ><tr>';
	$COUNT = 0;
	foreach($homeWidgets as $key=>$value){
		if($value == ''){
			$html .= '<td class="dvtCellInfo" align="center" >
			<input type="checkbox" name="names" value="'.$key.'"></td>
			<td class="dvtCellLabel" align="left">'.getTranslatedString($key,"Users").'</td>';
			$COUNT++;
			if (($COUNT % 2) == 0){
				$html .= '</tr><tr>';
			}
		}
	}
	if ($errorMsg != ''){
		$html .= '<td align="center">'.getTranslatedString($errorMsg,"Home").'</td>';
	}
	$html .= '</tr></table>';*/
    
	echo $html;
}

//layout save ends here
?>