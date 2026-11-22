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
	      

require_once('modules/Users/Users.php');

global $adb ,$mod_strings,$currentModule ;
$userObj = new Users();
//$local_log =& LoggerManager::getLogger('UsersAjax');
$ajaxaction = $_REQUEST["ajxaction"];
if($ajaxaction == "DETAILVIEW")
{
	/*if(empty($_SESSION['Users_FORM_TOKEN']) || $_SESSION['Users_FORM_TOKEN']
			!== (int)$_REQUEST['form_token']) {
		echo ":#:ERR".(getFixedLabel('NOPERMITTEDEXECUTE'));
		die;
	}*/
    
    crm_load_class_file("DetailViewAjaxSave",'data');
     $crmid = $_REQUEST["recordid"];
     $tablename = $_REQUEST["tableName"];
     $fieldname = $_REQUEST["fldName"];
     $fieldvalue = utf8RawUrlDecode($_REQUEST["fieldValue"]); 
      $uitype=$userObj->fieldobj->getFieldInfoBykeyValue("fieldname",$fieldname,'uitype');
    	
        if($uitype==156)
        {
            if(stripos($fieldvalue,'1')!==false)
            {
                $fieldvalue='on';
            }
            else
            {
                $fieldvalue='off';
            }
        }
    
     $DetailViewAjaxSaveobj=new DetailViewAjaxSave($currentModule,$crmid,$fieldname,$fieldvalue);
     $DetailViewAjaxSaveobj->save();
     $DetailViewAjaxSaveobj->setEcho();
     
	//$userid = $_REQUEST["recordid"];
//	$tablename = $_REQUEST["tableName"];
//	$fieldname = $_REQUEST["fldName"];
//    $uitype=$userObj->fieldobj->getFieldInfoBykeyValue("fieldname",$fieldname,'uitype');
//	$fieldvalue = utf8RawUrlDecode($_REQUEST["fieldValue"]); 
//    if($uitype==156)
//    {
//        if(stripos($fieldvalue,'1')!==false)
//        {
//            $fieldvalue='on';
//        }
//        else
//        {
//            $fieldvalue='off';
//        }
//    }
//    if($uitype==1101){
//       $value=fieldValueUitype::SetMobileStyle($userid,$fieldvalue,$currentModule);
//        echo  "##mobile##".$value."##mobile##";
//    }
//     
//	if($userid != "")
//	{
//		
//		$userObj->retrieve_entity_info($userid,"Users");
//		$userObj->column_fields[$fieldname] = $fieldvalue;
//
//               /* if($fieldname=='asterisk_extension'){
//
//			$query = "select 1 from ld_asteriskextensions
//                     inner join ld_users on ld_users.id=ld_asteriskextensions.userid
//
//                     where status='Active' and asterisk_extension =?";
//			$params = array($fieldvalue);
//			
//			$result = $adb->pquery($query, $params);
//		        if($adb->num_rows($result) > 0)
//			{
//				echo ":#:ERR".$mod_strings['LBL_ASTERISKEXTENSIONS_EXIST'];
//				return false;
//			}
//	     }*/
//		if($fieldname == 'internal_mailer'){
//			
//			if(isset($_SESSION['internal_mailer']) && $_SESSION['internal_mailer'] != $userObj->column_fields['internal_mailer'])
//				$_SESSION['internal_mailer'] = $userObj->column_fields['internal_mailer'];
//		}
//		$userObj->id = $userid;
//		$userObj->mode = "edit";
//		/*$userObj->homeorder_array[] = 'Tag Cloud';
//		$homeStuffOrder = $userObj->getHomeStuffOrder($userid);
//		foreach ($homeStuffOrder as $widget=>$visible) {
//			$_REQUEST[$widget] = $visible;
//		}
//		$_REQUEST['tagcloudview'] = $homeStuffOrder['Tag Cloud'];*/
//        
//		$userObj->save("Users");
//		$cachekey = 'cache_getusercachenameinfo';
//		unsetCache($cachekey);
//		if($userObj->id != "")
//		{
//			echo ":#:SUCCESS";
//		}else
//		{
//			echo ":#:FAILURE";
//		}   
//	}else
//	{
//		echo ":#:FAILURE";
//	}
}
?>