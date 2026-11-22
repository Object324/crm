<?php
/*********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the SugarCRM Public License Version 1.1.2
 * ("License"); You may not use this file except in compliance with the
 * License. You may obtain a copy of the License at http://www.sugarcrm.com/SPL
 * Software distributed under the License is distributed on an  "AS IS"  basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
 * the specific language governing rights and limitations under the License.
 * The Original Code is:  SugarCRM Open Source
 * The Initial Developer of the Original Code is SugarCRM, Inc.
 * Portions created by SugarCRM are Copyright (C) SugarCRM, Inc.;
 * All Rights Reserved.
 * Contributor(s): ______________________________________.
 ********************************************************************************/
/*********************************************************************************
 * $Header: /advent/projects/wesat/lingdang_crm/sugarcrm/modules/Users/ChangePassword.php,v 1.2 2004/10/29 09:55:10 jack Exp $
 * Description:  TODO: To be written.
 * Portions created by SugarCRM are Copyright (C) SugarCRM, Inc.
 * All Rights Reserved.
 * Contributor(s): ______________________________________..
 ********************************************************************************/
// This file is used for all popups on this module
// The popup_picker.html file is used for generating a list from which to find and choose one instance.

global $theme;

require_once('modules/lingdang/layout_utils.php');
//require_once('include/logging.php');

global $adb,$current_user;



$mod_strings['ERR_ENTER_OLD_PASSWORD'];

insert_popup_header($theme);

$strContent='
<form name="ChangePassword" onsubmit="puyoungJS_DialogBox.block();">
    <table style="width:400px;" class="ld-public-content" border="0" cellpadding="0" cellspacing="0" width="100%">';
     if (!is_admin($current_user)) {
    	$strContent.= "<tr>";
    	$strContent.=  "<td class='ld-form-item-label'>".getFixedLabel('OLDPASSWORD')."</td>\n";
    	$strContent.=  "<td class='ld-form-item-content'><input name='old_password' id='old_password' type='password' tabindex='1' size='25' class='ld-input-inner'></td>\n";
        $strContent.=  "<input name='is_admin' type='hidden' value='1'>";
    	$strContent.=  "</tr><tr>\n";
    }
    else 
        $strContent.=  "<input name='old_password' id='old_password' type='hidden'><input name='is_admin' type='hidden' value='0'>";
  
        $strContent.='<td class="ld-form-item-label"><font style="color: red;">*</font>'. getFixedLabel('NEWPASSWORD').'</td>';
        
        $strContent.='<td class="ld-form-item-content"><input name="new_password" id="new_password" type="password" tabindex="1" size="25" class="ld-input-inner" autofocus="autofocus"/>  
    </td>
    </tr>';
    
    $strContent.=' <tr>
        <td class="ld-form-item-label"><font style="color: red;">*</font>'. getFixedLabel('Password_confirmation').'</td>
        <td class="ld-form-item-content"><input name="confirm_new_password" id="confirm_new_password" type="password" tabindex="1" size="25" class="ld-input-inner"/></td>
    </tr>
    </table>';
    
$strContent.=' </form>';
$_REQUEST['diony']='yes';
$arr['title']=getFixedLabel('CHANGEPASSWORD');
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$arr['content']=$strContent;
$arr['id']=$_REQUEST['id'];
ConvertTojsonString(1,$arr,'success');


?>