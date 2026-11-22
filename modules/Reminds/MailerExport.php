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
 * $Header:
 * Description:  TODO: To be written.
 * Portions created by SugarCRM are Copyright (C) SugarCRM, Inc.
 * All Rights Reserved.
 * Contributor(s): ______________________________________..
 ********************************************************************************/

global $app_strings;
global $mod_strings;
global $currentModule;
global $theme, $adb;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";
global $current_language,$default_charset;

$category = htmlspecialchars($_REQUEST['parenttab'],ENT_QUOTES,$default_charset);

//Function added to convert line breaks to space in description during export
function br2nl_int($str) {
   $str = preg_replace("/(\r\n)/", " ", $str);
   return $str;
}

if (isset($_SESSION['export_where']))
  $exportWhere = $_SESSION['export_where'];
else
  $exportWhere = stripslashes(htmlspecialchars_decode($_POST['exportwhere']));

if (isset($_GET['step']))
  $step = $_GET['step'];
else
  $step = $_POST['step'];
  
$export_type = $_POST['export_type'];


function getStdContactFlds(&$queryFields, $adb, $valueArray)
{
  global $current_language, $mod_strings;
  require_once('modules/Contacts/language/'.$current_language.'.lang.php');
  $query = "SELECT fieldid, columnname, fieldlabel FROM ld_field WHERE tablename='ld_contactdetails' AND uitype='56' and ld_field.presence in (0,2)";
	$result = $adb->query ($query,true,"Error: "."<BR>$query");
	for ($tmp=0; $tmp < $adb->num_rows($result); $tmp++)
	{
    $myData = $adb->fetchByAssoc ($result);
    $queryFields[] = Array('columnname'=>$myData['columnname']
      ,'uitype'=>'56','fieldlabel'=>getTranslatedString($myData['fieldlabel'], 'Contacts')
      ,'value'=> $valueArray);
  }
}

if ($step == "ask")
{
  require_once('config.php');
  require_once('include/database/PearDatabase.php');
  require_once('Smarty_setup.php');
  $smarty = new lingdangCRM_Smarty;
  $valueArray = Array('' => $mod_strings['LBL_MAILER_EXPORT_IGNORE'],
      '0' => $mod_strings['LBL_MAILER_EXPORT_NOTCHECKED'],
      '1' => $mod_strings['LBL_MAILER_EXPORT_CHECKED']);
      
  $smarty->assign("MOD", return_module_language($current_language,'Accounts'));
  $smarty->assign("CMOD", $mod_strings);
  $smarty->assign("APP", $app_strings);
  $smarty->assign("IMAGE_PATH",$image_path);
  $smarty->assign("MODULE",$currentModule);
  $smarty->assign("EXPORTWHERE",$exportWhere);
  $queryFields = Array();
	// get the Contacts CF fields
 	$cfquery = "SELECT columnname,fieldlabel,uitype FROM ld_field WHERE tablename='ld_contactscf' and ld_field.presence in (0,2)";
	$result = $adb->query ($cfquery,true,"Error: "."<BR>$cfquery");
	for ($tmp=0; $tmp < $adb->num_rows($result); $tmp++)
	{
    $cfTmp = $adb->fetchByAssoc ($result);
    $cfColName=$cfTmp['columnname'];
    if ($cfTmp['uitype'] == 1)
      $queryFields[$tmp] = $cfTmp;
    elseif ($cfTmp['uitype'] == 15)
    {
      $queryFields[$tmp] = $cfTmp;
      $queryFields[$tmp]['value'][''] = $mod_strings['LBL_MAILER_EXPORT_IGNORE'];
      $cfValues = "SELECT ".$cfColName.",".$cfColName."id FROM ld_".$cfColName;
	    $resVal = $adb->query ($cfValues,true,"Error: "."<BR>$cfValues");
	    for ($tmp1=0; $tmp1 < $adb->num_rows($resVal); $tmp1++)
	    {
	      $cfTmp=$adb->fetchByAssoc ($resVal);
        $queryFields[$tmp]['value'][$cfTmp[$cfColName]] = $cfTmp[$cfColName];
      }
    }
    elseif ($cfTmp['uitype'] == 56)
    {
      $queryFields[$tmp] = $cfTmp;
      $queryFields[$tmp]['value'] = $valueArray;
    }
  }
  // now add the standard fields
  //getStdContactFlds(&$queryFields, $adb, $valueArray);
  getStdContactFlds($queryFields, $adb, $valueArray);//by lingdang
  // get the list of fields
  $fieldList="";
  foreach ($queryFields as $myField)
  {
    if (strlen($fieldList) > 0)
      $fieldList .= ',';
    $fieldList .= $myField['columnname'];
  }
  $smarty->assign("FIELDLIST",$fieldList);
  // and their types
  $typeList ="";
  foreach ($queryFields as $myField)
  {
    if (strlen($typeList) > 0)
      $typeList .= ',';
    $typeList .= $myField['uitype'];
  }

  $smarty->assign("TYPELIST",$typeList);
  $smarty->assign("QUERYFIELDS",$queryFields);
  $smarty->assign("CATEGORY",$category);
  $smarty->display('MailerExport.tpl');


}
else
{
  require_once('../../config.php');
  chdir ($root_directory);
  require_once("include/utils/CommonUtils.php");
  require_once('include/database/PearDatabase.php');
  require_once('include/logging.php');
  $exquery = Array();
  $fields = explode(",",$_POST['fieldlist']);  
  $types = explode(",",$_POST['typelist']);  
  $escapxportWhere = $adb->sql_escape_string($exportWhere);
  if (($export_type == "email") || ($export_type == "emailplus") )
  {
	  
     $where = "";
     
	if(count($fields) > 0)
		$where .= getExpWhereClause($fields,$types);
	 $exquery[0] = "SELECT ld_crmentity.crmid, contactdetails.contactid,
	   contactdetails.salutation, contactdetails.firstname,
	   contactdetails.lastname, contactdetails.email  FROM ld_account
	   INNER JOIN ld_crmentity on ld_crmentity.crmid=ld_account.accountid
	   INNER JOIN ld_accountbillads ON ld_account.accountid=ld_accountbillads.accountaddressid
	   INNER JOIN ld_accountshipads ON ld_account.accountid=ld_accountshipads.accountaddressid
	   INNER JOIN ld_accountscf ON ld_account.accountid = ld_accountscf.accountid
	   INNER JOIN ld_contactdetails contactdetails ON ld_account.accountid = contactdetails.accountid
	   INNER JOIN ld_crmentity contactdetails_crmentity ON contactdetails.contactid = contactdetails_crmentity.crmid
	   INNER JOIN ld_contactscf contactscf ON contactscf.contactid = contactdetails.contactid
	   LEFT JOIN ld_users ON ld_crmentity.smownerid=ld_users.id
	   LEFT JOIN ld_groups ON ld_crmentity.smownerid=ld_groups.groupid
	   WHERE ld_crmentity.deleted=0 AND contactdetails_crmentity.deleted=0 AND contactdetails.email != '' ".$where;

	 if (strlen ($exportWhere))
	      $exquery[0] .= " AND ".$exportWhere;

   if ($export_type == "emailplus")
   {     
		  $exquery[1] = "SELECT ld_crmentity.crmid, contactdetails.contactid,
		    contactdetails.salutation, contactdetails.firstname,
		    contactdetails.lastname, ld_account.email1  FROM ld_account
		    INNER JOIN ld_crmentity ON ld_crmentity.crmid=ld_account.accountid
		    INNER JOIN ld_accountbillads ON ld_account.accountid=ld_accountbillads.accountaddressid
		    INNER JOIN ld_accountshipads ON ld_account.accountid=ld_accountshipads.accountaddressid
		    INNER JOIN ld_accountscf ON ld_account.accountid = ld_accountscf.accountid
		    INNER JOIN ld_contactdetails contactdetails ON ld_account.accountid = contactdetails.accountid
			INNER JOIN ld_crmentity contactdetails_crmentity ON contactdetails.contactid = contactdetails_crmentity.crmid
		    INNER JOIN ld_contactscf contactscf ON contactscf.contactid = contactdetails.contactid
	   LEFT JOIN ld_users ON ld_crmentity.smownerid=ld_users.id
	   LEFT JOIN ld_groups ON ld_crmentity.smownerid=ld_groups.groupid
		    WHERE ld_crmentity.deleted=0 AND contactdetails_crmentity.deleted=0
		    AND contactdetails.email = '' AND ld_account.email1 != '' ".$where;

     		if (strlen ($exportWhere))
	        	$exquery[1] .= " AND ".$exportWhere;
   } 
  }
	else if ($export_type == "full")
	{
		$where = '';
		if(count($fields) > 0)
		  $where .= getExpWhereClause($fields,$types);
	  $exquery[0] = "select ld_crmentity.crmid, contactdetails.contactid,
	    contactdetails.salutation, contactdetails.firstname,
	    contactdetails.lastname, contactdetails.email, ld_account.accountname,"
	      ." ld_account.phone, ld_account.website, ld_accountshipads.ship_street,"
	      ." ld_accountshipads.ship_code,"
	      ." ld_accountshipads.ship_city, ld_accountshipads.ship_state,"
	      ." ld_accountshipads.ship_country,"
	      ." ld_accountbillads.bill_street, ld_accountbillads.bill_code,"
	      ." ld_accountbillads.bill_city, ld_accountbillads.bill_state,"
	      ." ld_accountbillads.bill_country"
	      ." FROM ld_account INNER JOIN ld_crmentity ON ld_crmentity.crmid=ld_account.accountid"
	      ." LEFT JOIN ld_accountbillads ON ld_account.accountid=ld_accountbillads.accountaddressid"
	      ." LEFT JOIN ld_accountshipads ON ld_account.accountid=ld_accountshipads.accountaddressid"
	      ." INNER JOIN ld_accountscf ON ld_account.accountid = ld_accountscf.accountid"
	      ." INNER JOIN ld_contactdetails contactdetails ON ld_account.accountid = contactdetails.accountid"
		." INNER JOIN ld_crmentity contactdetails_crmentity ON contactdetails.contactid = contactdetails_crmentity.crmid"
	      ." INNER JOIN ld_contactscf contactscf ON contactscf.contactid = contactdetails.contactid
	   LEFT JOIN ld_users ON ld_crmentity.smownerid=ld_users.id
	   LEFT JOIN ld_groups ON ld_crmentity.smownerid=ld_groups.groupid"
	      ." WHERE ld_crmentity.deleted=0 AND contactdetails_crmentity.deleted=0 ".$where;

	  if (strlen ($exportWhere))
	      $exquery[0] .= " AND ".$exportWhere;
	}
  // Added for getting field labels of the fields selected in the above export queries. If any new fields added in the select clause then the below array need to be updated with the corresponding lablels
  $fld_label_arr = Array(
            "crmid"=>getTranslatedString('crmid','Accounts'),
            "contactid"=>getTranslatedString('contactid','Accounts'),
            "salutation"=>getTranslatedString('Salutation','Contacts'),
	  		"lastname"=>getTranslatedString('Last Name','Contacts'),
			"firstname"=>getTranslatedString('First Name','Contacts'),
			"email"=>getTranslatedString('Email','Contacts'),
			"accountname"=>getTranslatedString('Account Name','Accounts'),
			"phone"=>getTranslatedString('Phone','Accounts'),
			"website"=>getTranslatedString('Website','Accounts'),
			"ship_street"=>getTranslatedString('Shipping Address','Accounts'),
			"ship_code"=>getTranslatedString('Shipping Code','Accounts'),
			"ship_city"=>getTranslatedString('Shipping City','Accounts'),
			"ship_state"=>getTranslatedString('Shipping State','Accounts'),
			"ship_country"=>getTranslatedString('Shipping Country','Accounts'),
			"bill_street"=>getTranslatedString('Billing Address','Accounts'),
			"bill_code"=>getTranslatedString('Billing Code','Accounts'),
			"bill_city"=>getTranslatedString('Billing City','Accounts'),
			"bill_state"=>getTranslatedString('Billing State','Accounts'),
			"bill_country"=>getTranslatedString('Billing Country','Accounts')
		);
  
  for ($temp = 0; $temp < count($exquery); $temp++)
  {
	  $result = $adb->query ($exquery[$temp],true,"Error exporting: "."<BR>$query");	  
	  if ($temp == 0)  // We only need the headers for first query
	  {
		  $fields_array = $adb->getFieldsArray($result);
	    // Now walk through the array and replace any cf_* with the content of the
	    // name array, the index is the cf_ var name
	    for ($arraywalk = 0; $arraywalk < count($fields_array); $arraywalk++)
	    {
	      // echo "Checking: ".$fields_array[$arraywalk];
	      if (strstr ($fields_array[$arraywalk], "ld_cf_"))
	      {
	        $fields_array[$arraywalk] = $name[$fields_array[$arraywalk]];
	        // echo "Changing to: ".$fields_array[$arraywalk];
	      }
	      else
		      $fields_array[$arraywalk] = ($fld_label_arr[$fields_array[$arraywalk]]!='')?$fld_label_arr[$fields_array[$arraywalk]]:$fields_array[$arraywalk];
	    }

		
			$header = implode("\",\"",array_values($fields_array));
			$header = "\"" .$header;
			$header .= "\"\r\n";
			$content .= $header;
		
			$column_list = implode(",",array_values($fields_array));
	  }
	  
	  while($val = $adb->fetchByAssoc($result, -1, false))
		{
			$new_arr = array();
	
			// foreach (array_values($val) as $value)
			foreach ($val as $key => $value)
			{
			  $value=br2nl_int($value);
				array_push($new_arr, preg_replace("/\"/","\"\"",$value));
			}
	
			$line = implode("\",\"",$new_arr);
			$line = "\"" .$line;
			$line .= "\"\r\n";
	
			$content .= $line;
	  }
	}
  
  // echo "<br>Rows: ".$adb->num_rows($result);
  header( "Content-Disposition: inline; filename=MailerExport.csv");
	header( "Content-Type: text/csv; charset=".$app_strings['LBL_CHARSET']);
	header( "Expires: Mon, 26 Jul 2007 05:00:00 GMT" );
	header( "Last-Modified: " . gmdate("D, d M Y H:i:s") . " GMT" );
	header( "Cache-Control: post-check=0, pre-check=0", false );
	header( "Content-Length: ".strlen($content)); 
	print iconv('UTF-8','gbk',$content);
	exit ();
	
}

function getExpWhereClause($fields,$types)
{
	global $adb;
	$where_cond = "";

	foreach ($fields as $myField)
	{
		$myType = each($types);
		if (strlen($_POST[$myField]) > 0)
		{
			// type 1 should use a LIKE search
			if ($myType['value'] == 1)
			{
				$equals = " LIKE '";
				$postfix = "%'";
			}
			else
			{
				$equals = " = '";
				$postfix = "'";
			}
			// is customer field
			if (substr($myField,0,3) == 'cf_')
				$where_cond .= " AND contactscf.".$myField.$equals.$adb->sql_escape_string($_POST[$myField]).$postfix;
			else
				$where_cond .= " AND contactdetails.".$myField.$equals.$adb->sql_escape_string($_POST[$myField]).$postfix;
		}
	}
	return $where_cond;

}
?>