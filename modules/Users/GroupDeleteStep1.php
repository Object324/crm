<?php

/*+********************************************************************************
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ********************************************************************************/

require_once('include/utils/utils.php');

global $app_strings;
global $mod_strings;
global $theme,$default_charset;
$theme_path="themes/".$theme."/";
$delete_group_id = vtlib_purify($_REQUEST['groupid']);
//$delete_group_name = fetchGroupName($delete_group_id);


$output='';
$output ='<div id="DeleteLay" class="D_pop_box LdPopWidth300px ltextalign bgwhite">
<form name="deleteGroupForm" action="index.php" onsubmit="puyoungJS_DialogBox.block();">
<input type="hidden" name="module" value="Users">
<input type="hidden" name="action" value="DeleteGroup">
<input type="hidden" name="delete_group_id" value="'.$delete_group_id.'">
<input type="hidden" name="blockidsetting" value="'.$_REQUEST['blockidsetting'].'"/>
<input type="hidden" name="fieldidsetting" value="'.$_REQUEST['fieldidsetting'].'"/>
<div class="D_pop_tit">
    <strong class="D_ptita">'.getFixedLabel('DELETEGROUP').'</strong>
	<a class="D_ptitc" onClick="document.getElementById(\'DeleteLay\').style.display=\'none\';puyoungJS_DialogBox.unblock();">
		<img src="themes/icon/pop_close.png" class="D_ptitcimg" />
	</a>
</div>	
    <table cellspacing="1" cellpadding="0" border="0" class="D_pop_bod">
      <tr>
        <td>'.getFixedLabel('TODELETEGROUP').'</td>
        <td>'.htmlentities($delete_group_name,ENT_QUOTES,$default_charset).'</td>
     </tr>
     <tr>
        <td>'.getFixedLabel('RESPONSIBLEFORCONVERSION').'</td>
        <td>';
                global $adb;
        		$sql = "select groupid,groupname from ld_groups";
        		$result = $adb->pquery($sql, array());
        		$num_groups = $adb->num_rows($result);
        
        		$sql1 = "select * from ld_users where deleted=0";
        		$result1= $adb->pquery($sql1, array());
        		$num_users = $adb->num_rows($result1);
        
        		$output.= '<input name="assigntype" checked value="U" onclick="toggleAssignType(this.value)" type="radio">&nbsp;'.getFixedLabel('LBL_USERS').'';
        		if($num_groups > 1)
        		{
        			$output .= '<input name="assigntype"  value="T" onclick="toggleAssignType(this.value)" type="radio">&nbsp;'.getFixedLabel('USERGROUPLIST').'';
        		}
        
        		$output .= '<span id="assign_user" style="display: block;margin:3px 0px">';
        
        		$output .= '<select name="transfer_user_id">';
        
        
        		for($i=0;$i<$num_users;$i++)
        		{
        			$user_id=$adb->query_result($result1,$i,"id");
        	    	$output.='<option value="'.$user_id.'">'.  getFullNameFromQResult($result1, $i, 'Users').'</option>';
        		}
        
        		$output .='</select></span>';
        
        		if($num_groups > 1)
        		{
        			$output .= '<span id="assign_team" style="display: none;">';
        
        
        			$output.='<select class="select" name="transfer_group_id">';
        
        			$temprow = $adb->fetch_array($result);
        			do
        			{
        				$group_name= htmlentities($temprow["groupname"],ENT_QUOTES,$default_charset);
        				$group_id=$temprow["groupid"];
        				if($delete_group_id 	!= $group_id)
        				{
        					if(strlen($group_name)>20)
        					{
        						$group_name=substr($group_name,0,20)."...";
        					}
            					$output.='<option value="'.$group_id.'">'.$group_name.'</option>';
        	    			}
        			}while($temprow = $adb->fetch_array($result));
        			$output.='</select></span>';
        		}
                $output.='</td>         
      </tr>
    </table>


<div class="D_pbtn">
    
    <input class="D_pbtnok" type="submit" name="Delete" value="'.getFixedLabel('SAVE').'">
    <span>&nbsp;</span>
    <input class="D_pbtncancel" type="button" onclick="fninvshnew(\'DeleteLay\');" value="'.getFixedLabel('CANCEL').'">   
    
</div>
</form></div>';

echo $output;
?>