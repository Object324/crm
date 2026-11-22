<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
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
 * $Header: /advent/projects/wesat/lingdang_crm/sugarcrm/modules/Contacts/Save.php,v 1.9 2005/03/15 09:58:21 shaw Exp $
 * Description:  TODO: To be written.
 * Portions created by SugarCRM are Copyright (C) SugarCRM, Inc.
 * All Rights Reserved.
 * Contributor(s): ______________________________________..
 ********************************************************************************/
require_once('modules/Contacts/Contacts.php');
//require_once('include/logging.php');
//require_once('include/database/PearDatabase.php');


global $adb;
global $currentModule;
$focus = CRMEntity::getInstance($currentModule);
//added to fix 4600
$search=vtlib_purify($_REQUEST['search_url']);
if($_REQUEST['record']>0)
{
    $before_columnfieldvalue=$focus->retrieve_entity_info($_REQUEST['record'],'Contacts');
    $focus->mode='edit';
}
setObjectValuesFromRequest($focus);

if($_REQUEST['salutation'] == '--None--')	$_REQUEST['salutation'] = '';
if (!isset($_REQUEST['email_opt_out'])) $focus->email_opt_out = 'off';
if (!isset($_REQUEST['do_not_call'])) $focus->do_not_call = 'off';

//Checking If image is given or not
//$image_upload_array=SaveImage($_FILES,'contact',$focus->id,$focus->mode);
$image_name_val=$image_upload_array['imagename'];
$image_error="false";
$errormessage=$image_upload_array['errormessage'];
$saveimage=$image_upload_array['saveimage'];

//code added for returning back to the current view after edit from list view
if($_REQUEST['return_viewname'] == '') $return_viewname='0';
if($_REQUEST['return_viewname'] != '')$return_viewname=vtlib_purify($_REQUEST['return_viewname']);

if($image_error=="true") //If there is any error in the file upload then moving all the data to EditView.
{
        //re diverting the page and reassigning the same values as image error occurs
        if($_REQUEST['activity_mode'] != '')$activity_mode=vtlib_purify($_REQUEST['activity_mode']);
        if($_REQUEST['return_module'] != '')$return_module=vtlib_purify($_REQUEST['return_module']);
        if($_REQUEST['return_action'] != '')$return_action=vtlib_purify($_REQUEST['return_action']);
        if($_REQUEST['return_id'] != '')$return_id=vtlib_purify($_REQUEST['return_id']);
        $field_values_passed.="";
        foreach($focus->column_fields as $fieldname => $val)
        {
                if(isset($_REQUEST[$fieldname]))
                {
			
                        $field_values_passed.="&";
                        $value = $_REQUEST[$fieldname];
                        $focus->column_fields[$fieldname] = $value;
                        $field_values_passed.=$fieldname."=".$value;

                }
        }
        $values_pass=$field_values_passed;
        $encode_field_values=base64_encode($values_pass);

        $error_module = "Contacts";
        $error_action = "EditView";

		$return_action .= '&activity_mode='.vtlib_purify($_request['activity_mode']);

        if($mode=="edit") {
			$return_id=vtlib_purify($_REQUEST['record']);
        }
        header("location: index.php?action=$error_action&module=$error_module&record=$return_id&return_id=$return_id&return_action=$return_action&return_module=$return_module&activity_mode=$activity_mode&return_viewname=$return_viewname".$search."&saveimage=$saveimage&error_msg=$errormessage&image_error=$image_error&encode_val=$encode_field_values");
}
if($saveimage=="true")
{
        $focus->column_fields['imagename']=$image_name_val;
        
}

//if image added then we have to set that $_FILES['name'] in imagename field then only the image will be displayed
if($_FILES['imagename']['name'] != '')
{
	if(isset($_REQUEST['imagename_hidden'])) {
		$focus->column_fields['imagename'] = vtlib_purify($_REQUEST['imagename_hidden']);
	} else {
		$focus->column_fields['imagename'] = $_FILES['imagename']['name'];
	}
}
elseif($focus->id != '')
{
	$result = $adb->pquery("select imagename from ld_contactdetails where contactid = ?", array($focus->id));
	$focus->column_fields['imagename'] = $adb->query_result($result,0,'imagename');
}

if($_REQUEST['assigntype'] == 'U')  {
	$focus->column_fields['assigned_user_id'] = $_REQUEST['assigned_user_id'];
} elseif($_REQUEST['assigntype'] == 'T') {
	$focus->column_fields['assigned_user_id'] = $_REQUEST['assigned_group_id'];
}
//Saving the contact
if($image_error=="false")
{
	$focus->save("Contacts");
    
	$return_id = $focus->id;
	if(isset($_REQUEST['return_module']) && $_REQUEST['return_module'] != "") $return_module = vtlib_purify($_REQUEST['return_module']);
	else $return_module = "Contacts";
	if(isset($_REQUEST['return_action']) && $_REQUEST['return_action'] != "") $return_action = vtlib_purify($_REQUEST['return_action']);
	else $return_action = "DetailView";
	if(isset($_REQUEST['return_id']) && $_REQUEST['return_id'] != "") $return_id = vtlib_purify($_REQUEST['return_id']);

	if(isset($_REQUEST['activity_mode']) && $_REQUEST['activity_mode'] != '') $activitymode = vtlib_purify($_REQUEST['activity_mode']);


        if($_REQUEST['tablerelmodule']&&$_REQUEST['tablerelmodule']=='Campaigns')
        {
            //弹出层界面保存方法
              $campaignid=$_REQUEST['tablerelid'];
              	$campContStatusResult = $adb->pquery("select campaignrelstatusid from ld_campaigncontrel where campaignid=? AND contactid=?",array($campaignid, $focus->id));
    			$contactStatus = $adb->query_result($campContStatusResult,0,'campaignrelstatusid');
    			$sql = "delete from ld_campaigncontrel where contactid = ?";
    			$adb->pquery($sql, array($focus->id));
    			if(isset($contactStatus) && $contactStatus!=''){
    				$sql = "insert into ld_campaigncontrel values (?,?,?)";
    				$adb->pquery($sql, array($campaignid, $focus->id,$contactStatus));
    			}
    			else
    			{
    				$sql = "insert into ld_campaigncontrel values (?,?,1)";
    				$adb->pquery($sql, array($campaignid, $focus->id));
    			}
        }
	if(isset($_REQUEST['return_module']) && $_REQUEST['return_module'] == "Campaigns")
	{
		if(isset($_REQUEST['return_id']) && $_REQUEST['return_id'] != "")
		{
			$campContStatusResult = $adb->pquery("select campaignrelstatusid from ld_campaigncontrel where campaignid=? AND contactid=?",array($_REQUEST['return_id'], $focus->id));
			$contactStatus = $adb->query_result($campContStatusResult,0,'campaignrelstatusid');
			$sql = "delete from ld_campaigncontrel where contactid = ?";
			$adb->pquery($sql, array($focus->id));
			if(isset($contactStatus) && $contactStatus!=''){
				$sql = "insert into ld_campaigncontrel values (?,?,?)";
				$adb->pquery($sql, array($_REQUEST['return_id'], $focus->id,$contactStatus));
			}
			else
			{
				$sql = "insert into ld_campaigncontrel values (?,?,1)";
				$adb->pquery($sql, array($_REQUEST['return_id'], $focus->id));
			}
		}

	}

	//code added for returning back to the current view after edit from list view
	if($_REQUEST['return_viewname'] == '') $return_viewname='0';
	if($_REQUEST['return_viewname'] != '')$return_viewname=vtlib_purify($_REQUEST['return_viewname']);
if($_REQUEST['SearchScope']!='')     $SearchScope=$_REQUEST['SearchScope'];



	/* editor:gyq_11  reason:新增客户更新通话记录相关信息 date:20160603 */
    /*
	if(!empty($_REQUEST['jiuweiaccount'])){
		if($_REQUEST['callcenter_switch'] == 5) {
			$adb->pquery("UPDATE ld_jiuweiak_phonerecord SET indexid = ?,modulename='Contacts' WHERE id=?", array($focus->id, $_REQUEST['jiuweiaccount']));
		}elseif($_REQUEST['callcenter_switch'] == 6){
			$adb->pquery("UPDATE ld_sopho_phonerecord SET indexid = ?,modulename='Contacts' WHERE id=?", array($focus->id, $_REQUEST['jiuweiaccount']));
		}elseif($_REQUEST['callcenter_switch'] == 4){
    	    $adb->pquery("UPDATE ld_hantian_phonerecord SET indexid = ?,modulename='Contacts' WHERE id=?", array($focus->id, $_REQUEST['jiuweiaccount']));
    	}
	}
    */

/**
 * 列表编辑后，返回列表时，增加query_session=1的参数，启用列表页面搜索session
 * @project 序时簿查询记住搜索条件
 * @author Tujt 2014-04-25
 */
if($return_module == $currentModule && $return_action != 'DetailView'){
	$return_action .= '&query_session=1';
}
$_REQUEST['diony']='diony';
$focus->column_fields['record_module']=$focus->module_name;

if($_REQUEST['refreshpage']=='no')
 {
    //保存后的返回值
    $focus->setRefreshListModules(array("Accounts"));
    
    $focus->ReturnAfterSave($before_columnfieldvalue);
  //  exit();
    
        
 }
 else if( (isset($_REQUEST['Create'])&&($_REQUEST['Create']=='true' || $_REQUEST['Create']=='yes')) ||$_REQUEST['isDuplicate']=='true')
{
    header("Location: index.php?action=$return_action&module=$return_module&SearchScope=$SearchScope&record=$return_id&Create=true&activity_mode=$activitymode&viewname=$return_viewname&start=".vtlib_purify($_REQUEST['pagenumber']));
}
else
{
    header("Location: index.php?action=$return_action&module=$return_module&SearchScope=$SearchScope&record=$return_id&activity_mode=$activitymode&viewname=$return_viewname&start=".vtlib_purify($_REQUEST['pagenumber']));
}
}
?>