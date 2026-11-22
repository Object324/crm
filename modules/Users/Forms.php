<?php


/**
 * this function checks if the asterisk server details are set in the database or not
 * returns string "true" on success :: "false" on failure
 */
function checkAsteriskDetails(){
    
    return false;
    
	global $adb,$current_user;
	$sql = "select * from ld_asterisk";
	$result = $adb->query($sql);
	$count = $adb->num_rows($result);
	
	if($count > 0){
		return "true";
	}else{
		return "false";
	}
}

/**
 * this function gets the asterisk extensions assigned in lingdang
 */
function getAsteriskExtensions(){
	global $adb, $current_user;
	
    return [];
	/*$sql = "SELECT * FROM ld_asteriskextensions
            INNER JOIN ld_users ON ld_users.id = ld_asteriskextensions.userid
            AND ld_users.deleted=0 AND status = 'Active'";

	$result = $adb->pquery($sql, array());
	$count = $adb->num_rows($result);
	$data = array();
	
	for($i=0;$i<$count;$i++){
		$user = $adb->query_result($result, $i, "userid");
		$extension = $adb->query_result($result, $i, "asterisk_extension");
		if(!empty($extension)){
			$data[$user] = $extension;
		}
	}
	return $data;*/
}

/**
 * Create javascript to validate the data entered into a record.
 * Portions created by SugarCRM are Copyright (C) SugarCRM, Inc.
 * All Rights Reserved.
 * Contributor(s): ______________________________________..
 */
function get_validate_record_js () {
global $mod_strings;
global $app_strings, $current_user;

$lbl_last_name = $mod_strings['LBL_LIST_LAST_NAME'];
$lbl_user_name = $mod_strings['LBL_LIST_USER_NAME'];
$lbl_role_name = $mod_strings['LBL_ROLE_NAME'];
$lbl_new_password = $mod_strings['LBL_LIST_PASSWORD'];
$lbl_confirm_new_password = $mod_strings['LBL_LIST_CONFIRM_PASSWORD'];
$lbl_user_email1 = $mod_strings['LBL_LIST_EMAIL'];
$err_missing_required_fields = getFixedLabel('ERR_MISSING_REQUIRED_FIELDS');
$err_invalid_email_address = getFixedLabel('ERR_INVALID_EMAIL_ADDRESS');
$err_invalid_secondary_email_address = $app_strings['ERR_INVALID_SECONDARY_EMAIL_ADDRESS'];
$lbl_user_image=$mod_strings['User Image'];
$the_emailid = $app_strings['THE_EMAILID'];
$the_password = getFixedLabel('THE_PASSWORD');
$email_field_is = ' '.getFixedLabel('EMAIL_FILED_IS').' '.$err_invalid_email_address;
$other_email_field_is = $app_strings['OTHER_EMAIL_FILED_IS'].' '.$err_invalid_email_address;
$secondary_email_field_is = $app_strings['SECONDARY_EMAIL_FILED_IS'].' '.$err_invalid_secondary_email_address; 
$lbl_asterisk_details_not_set = $app_strings['LBL_ASTERISK_SET_ERROR'];

//check asteriskdetails start
$checkAsteriskDetails = checkAsteriskDetails();
// Fix : 6362
$record = ($_REQUEST['record'])?$_REQUEST['record']:'false';// used to check the asterisk extension in edit mode
 $mode = ($_REQUEST['isDuplicate'] == 'true')?'true':'false';
 $extensions = getAsteriskExtensions();
$extensions_list = Zend_Json::encode($extensions);
//check asteriskdetails end

$the_script  = <<<EOQ

<script language="JavaScript" type="text/javascript" src="include/js/json.js"></script>
<script type="text/javascript" language="Javascript">
<!--  to hide script contents from old browsers
function set_fieldfocus(errorMessage,oMiss_field){
		alert("$err_missing_required_fields");
		oMiss_field.focus();	
}

function verify_data(form) {
     puyoungJS_DialogBox.block();
     if((form.approveby!=undefined&&form.approveby.value=='')&&(form.approvestatus!=undefined&&form.approvestatus.value==0))
     {
        alert(arrJsPopLabel['APPROVINGCLIENTCANOTEMPTY']);
        puyoungJS_DialogBox.unblock();
        return false;
   }

    
        var isError = false;
	var errorMessage = "";
	
	//check if asterisk server details are set or not
	if(trim(form.asterisk_extension.value)!="" && "$checkAsteriskDetails" == "false"){
		errorMessage = "$lbl_asterisk_details_not_set";
		alert(errorMessage);
        puyoungJS_DialogBox.unblock();
		return false;
	}
	var extensions = $extensions_list;
        if(form.asterisk_extension.value != "") {
            for(var userid in extensions){
                if(trim(form.asterisk_extension.value) == extensions[userid]) {
                    if(userid == $record && $mode == false) {
                    } else {
                        alert("This extension has already been configured for another user. Please use another extension.");
                        return false;
                    }
                }
            }
        }
	//asterisk check ends

	/*if (trim(form.role_name.value) == "") {
		isError = true;
		errorMessage += "\\n$lbl_role_name";
		oField_miss =form.role_name;
	}*/
	if (trim(form.last_name.value) == "") {
		isError = true;
		errorMessage += "\\n$lbl_last_name";
		oField_miss =form.last_name;
	}
	if(form.mode.value !='edit')
	{
	/*	if (trim(form.user_password.value) == "") {
			isError = true;
			errorMessage += "\\n$lbl_new_password";
			oField_miss =form.user_password;
		}
		if (trim(form.confirm_password.value) == "") {
			isError = true;
			errorMessage += "\\n$lbl_confirm_new_password";
			oField_miss =form.confirm_password;
		}*/
	}


	if (trim(form.user_name.value) == "") {
		isError = true;
		errorMessage += "\\n$lbl_user_name";
		oField_miss =form.user_name;
	}

	if (isError == true) {
	    puyoungJS_DialogBox.unblock();
		set_fieldfocus(errorMessage,oField_miss);
		return false;
	}
	if( form.email1 != undefined){
		form.email1.value = trim(form.email1.value);
		if (form.email1.value != "" && !/^[a-zA-Z0-9]+([!"#$%&'()*+,./:;<=>?@\^_`{|}~-]?[a-zA-Z0-9])*@[a-zA-Z0-9]+([\_\-\.]?[a-zA-Z0-9]+)*\.([\-\_]?[a-zA-Z0-9])+(\.?[a-zA-Z0-9]+)?$/.test(form.email1.value)) {
			alert("$the_emailid"+form.email1.value+"$email_field_is");
			 puyoungJS_DialogBox.unblock();
			form.email1.focus();
		   
			return false;
		}
	}
	if(form.email2 != undefined){
		form.email2.value = trim(form.email2.value);
		if (form.email2.value != "" && !/^[a-zA-Z0-9]+([!"#$%&'()*+,./:;<=>?@\^_`{|}~-]?[a-zA-Z0-9])*@[a-zA-Z0-9]+([\_\-\.]?[a-zA-Z0-9]+)*\.([\-\_]?[a-zA-Z0-9])+(\.?[a-zA-Z0-9]+)?$/.test(form.email2.value)) {
			alert("$the_emailid"+form.email2.value+"$other_email_field_is");
			form.email2.focus();
			return false;
		}
	}
	if(form.secondaryemail != undefined){
		form.secondaryemail.value = trim(form.secondaryemail.value); 
		if (form.secondaryemail.value != "" && !/^[a-zA-Z0-9]+([!"#$%&'()*+,./:;<=>?@\^_`{|}~-]?[a-zA-Z0-9])*@[a-zA-Z0-9]+([\_\-\.]?[a-zA-Z0-9]+)*\.([\-\_]?[a-zA-Z0-9])+(\.?[a-zA-Z0-9]+)?$/.test(form.secondaryemail.value)){
			alert("$the_emailid"+form.secondaryemail.value+"$secondary_email_field_is");
			 puyoungJS_DialogBox.unblock();
			form.secondaryemail.focus();
			return false;
		}
	}


    if(form.imagename!= undefined){//Liver bug0027411: 控制面板>用户管理：隐藏用户头像字段，用户管理编辑无法保存。
       	if(! upload_filter("imagename", "jpg|gif|bmp|png|JPG|GIF|BMP|PNG") )
    	{
    	    puyoungJS_DialogBox.unblock();
    		form.imagename.focus();
    		return false;
    	} 
    }


	if(form.mode.value != 'edit')
	{
		if(trim(form.user_password.value) != trim(form.confirm_password.value))
		{
			 puyoungJS_DialogBox.unblock();
            alert("$the_password");
			return false;
		}
		
	}
	/**
	edit:can
	reason:12954,新增用户时，超过最大许多用户数时，程序没有判断，直接保存成功
	**/
	check_duplicate();
 
    return true;    
}

// end hiding contents from old browsers  -->
</script>

EOQ;

return $the_script;
}

?>