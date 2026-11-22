<?php
/*********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 ** The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
*
 ********************************************************************************/
?>
<html>
<body>
<script>
if (document.layers)
{
	document.write("This feature requires IE 5.5 or higher for Windows on Microsoft Windows 2000, Windows NT4 SP6, Windows XP.");
	document.write("<br><br>Click <a href='#' onclick='window.history.back();'>here</a> to return to the previous page");
}	
else if (document.layers || (!document.all && document.getElementById))
{
	document.write("This feature requires IE 5.5 or higher for Windows on Microsoft Windows 2000, Windows NT4 SP6, Windows XP.");
	document.write("<br><br>Click <a href='#' onclick='window.history.back();'>here</a> to return to the previous page");	
}
else if(document.all)
{
	document.write("<br><br>Click <a href='#' onclick='window.history.back();'>here</a> to return to the previous page");
	document.write("<OBJECT Name='lingdangCRM' codebase='modules/Settings/lingdangCRM.CAB#version=1,5,0,0' id='objMMPage' classid='clsid:0FC436C2-2E62-46EF-A3FB-E68E94705126' width=0 height=0></object>");
}
</script>
<?php
require_once('include/database/PearDatabase.php');
require_once('config.php');
global $default_charset;

// Fix For: http://trac.lingdang.com/cgi-bin/trac.cgi/ticket/2107
$randomfilename = "vt_" . str_replace(array("."," "), "", microtime());

$templateid = $_REQUEST['mergefile'];

if($templateid == "")
{
	die("Select Mail Merge Template");
}
//get the particular file from db and store it in the local hard disk.
//store the path to the location where the file is stored and pass it  as parameter to the method 
$sql = "select filename,data,filesize from ld_wordtemplates where templateid=?";
$result = $adb->pquery($sql, array($templateid));
$temparray = $adb->fetch_array($result);

$fileContent = $temparray['data'];
$filename=html_entity_decode($temparray['filename'], ENT_QUOTES, $default_charset);
// Fix For: http://trac.lingdang.com/cgi-bin/trac.cgi/ticket/2107
$filename= $randomfilename . "_word.doc";

$filesize=$temparray['filesize'];
$wordtemplatedownloadpath =$root_directory ."/dataCache/test/wordtemplatedownload/";

$handle = fopen($wordtemplatedownloadpath .$filename,"wb");
fwrite($handle,base64_decode($fileContent),$filesize);
fclose($handle);


//<<<<<<<<<<<<<<<<<<<<<<<<<<<for mass merge>>>>>>>>>>>>>>>>>>>>>>>>
$mass_merge = $_REQUEST['allselectedboxes'];
$single_record = $_REQUEST['record'];

if($mass_merge != "")
{	
	$mass_merge = explode(";",$mass_merge);
	$temp_mass_merge = $mass_merge;
	if(array_pop($temp_mass_merge)=="")
		array_pop($mass_merge);
	//$mass_merge = implode(",",$mass_merge);
}else if($single_record != "")
{
	$mass_merge = $single_record;	
}else
{
	die("Record Id is not found, cannot merge the document");
}

//<<<<<<<<<<<<<<<<header for csv and select columns for query>>>>>>>>>>>>>>>>>>>>>>>>

global $current_user;

$is_admin=is_admin($current_user);
if($is_admin == true|| $module == "Users" || $module == "Emails")
{
	$query1="select ld_tab.name,ld_field.tablename,ld_field.columnname,ld_field.fieldlabel from ld_field inner join ld_tab on ld_tab.tabid = ld_field.tabid where ld_field.tabid in (4,6) and ld_field.block <> 75 order by ld_field.tablename and ld_field.presence in (0,2)";
	$params1 = array();
}
else
{
	$profileList = $current_user->profileid;
	$query1="select ld_tab.name,ld_field.tablename,ld_field.columnname,ld_field.fieldlabel from ld_field inner join ld_tab on ld_tab.tabid = ld_field.tabid INNER JOIN lingdang_profile2field ON lingdang_profile2field.fieldid=ld_field.fieldid INNER JOIN ld_def_org_field ON ld_def_org_field.fieldid=ld_field.fieldid where ld_field.tabid in (4,6) and ld_field.block <> 75 AND lingdang_profile2field.visible=0 AND ld_def_org_field.visible=0 AND lingdang_profile2field.profileid IN (". generateQuestionMarks($profileList) .") and ld_field.presence in (0,2) GROUP BY ld_field.fieldid order by ld_field.tablename";
	$params1 = array($profileList);
	//Postgres 8 fixes
	if( $adb->dbType == "pgsql")
		$query1 = fixPostgresQuery( $query1,  0);
}
$result = $adb->pquery($query1, $params1);
$y=$adb->num_rows($result);
$userNameSql = getSqlForNameInDisplayFormat(array('first_name'=>
							'ld_users.first_name', 'last_name' => 'ld_users.last_name'), 'Users');
$accountUserNameSql = getSqlForNameInDisplayFormat(array('first_name'=>'usersAccounts.first_name', 'last_name' =>
			'usersAccounts.last_name'), 'Users');
	
for ($x=0; $x<$y; $x++)
{ 
	$tablename = $adb->query_result($result,$x,"tablename");
	$columnname = $adb->query_result($result,$x,"columnname");
	$modulename = $adb->query_result($result,$x,"name");

	if($tablename == "crmentity")
	{
		if($modulename == "Accounts")
		{
			$tablename = "crmentityAccounts";
		}
	}
	$querycolumns[$x] = $tablename.".".$columnname;
	if($columnname == "smownerid")
	{
		if($modulename == "Accounts")
		{
			$querycolumns[$x]="case when (usersAccounts.user_name not like '') then $accountUserNameSql else groupsAccounts.groupname end as username";
		}
		if($modulename == "Contacts")
		{
			$querycolumns[$x]="case when (ld_users.user_name not like '') then $userNameSql else ld_groups.groupname end as usercname,ld_users.first_name,ld_users.last_name,ld_users.user_name,ld_users.secondaryemail,ld_users.title,ld_users.phone_work,ld_users.department,ld_users.phone_mobile,ld_users.phone_other,ld_users.phone_fax,ld_users.email1,ld_users.phone_home,ld_users.email2,ld_users.address_street,ld_users.address_city,ld_users.address_state,ld_users.address_postalcode,ld_users.address_country";
		}
	}
	if($columnname == "parentid")
	{
		$querycolumns[$x] = "accountAccounts.accountname";
	}
	if($columnname == "accountid")
	{
		$querycolumns[$x] = "accountContacts.accountname";
	}
	if($columnname == "reportsto")
	{
		$querycolumns[$x] = "contactdetailsContacts.lastname";
	}


	if($modulename == "Accounts")
	{
		$field_label[$x] = "ACCOUNT_".strtoupper(str_replace(" ","",$adb->query_result($result,$x,"fieldlabel")));
	}

	if($modulename == "Contacts")
	{
		$field_label[$x] = "CONTACT_".strtoupper(str_replace(" ","",$adb->query_result($result,$x,"fieldlabel")));
		if($columnname == "smownerid")
		{
			$field_label[$x] = $field_label[$x].",USER_FIRSTNAME,USER_LASTNAME,USER_USERNAME,USER_SECONDARYEMAIL,USER_TITLE,USER_OFFICEPHONE,USER_DEPARTMENT,USER_MOBILE,USER_OTHERPHONE,USER_FAX,USER_EMAIL,USER_HOMEPHONE,USER_OTHEREMAIL,USER_PRIMARYADDRESS,USER_CITY,USER_STATE,USER_POSTALCODE,USER_COUNTRY";
		}
	}


}
$csvheader = implode(",",$field_label);
//echo $csvheader;
//<<<<<<<<<<<<<<<<End>>>>>>>>>>>>>>>>>>>>>>>>
	
if(count($querycolumns) > 0)
{
	$selectcolumns = implode($querycolumns,",");
	

	$query = "select $selectcolumns from ld_contactdetails
				inner join ld_crmentity on ld_crmentity.crmid = ld_contactdetails.contactid 
				inner join ld_contactaddress on ld_contactdetails.contactid = ld_contactaddress.contactaddressid 
				inner join ld_contactsubdetails on ld_contactdetails.contactid = ld_contactsubdetails.contactsubscriptionid 
				inner join ld_contactscf on ld_contactdetails.contactid = ld_contactscf.contactid 
				inner join ld_customerdetails on ld_contactdetails.contactid = ld_customerdetails.customerid 
				left join ld_contactdetails as contactdetailsContacts on contactdetailsContacts.contactid = ld_contactdetails.reportsto
				left join ld_account as accountContacts on accountContacts.accountid = ld_contactdetails.accountid 
				left join ld_users on ld_users.id = ld_crmentity.smownerid
				LEFT JOIN ld_groups 
					ON ld_groups.groupid = ld_crmentity.smownerid
				left join ld_account on ld_account.accountid = ld_contactdetails.accountid
				left join ld_crmentity as crmentityAccounts on crmentityAccounts.crmid=ld_account.accountid
				left join ld_accountbillads on LDr_account.accountid=ld_accountbillads.accountaddressid
				left join ld_accountshipads on ld_account.accountid=ld_accountshipads.accountaddressid
				left join ld_accountscf on ld_account.accountid = ld_accountscf.accountid
				left join ld_account as accountAccounts on accountAccounts.accountid = lingdang_account.parentid
				left join ld_users as usersAccounts on usersAccounts.id = crmentityAccounts.smownerid 
				LEFT JOIN ld_groups as groupsAccounts
					ON groupsAccounts.groupid = ld_crmentity.smownerid
				where ld_crmentity.deleted=0 and (crmentityAccounts.deleted is NULL or crmentityAccounts.deleted <> 1) and ld_contactdetails.contactid in(". generateQuestionMarks($mass_merge) .")";
				

	$result = $adb->pquery($query, array($mass_merge));
	$avail_pick_arr = getAccessPickListValues('Contacts');
while($columnValues = $adb->fetch_array($result))
{
	$y=$adb->num_fields($result);	
	for($x=0; $x<$y; $x++)
	{
	$value = $columnValues[$x];
	 foreach($columnValues as $key=>$val)
	 {
		if($val == $value && $value != '')
		{
		  if(array_key_exists($key,$avail_pick_arr))
		  {
			if(!in_array($val,$avail_pick_arr[$key]))
			{
				$value = "Not Accessible";
			}
		  }
		}
	 }
  	//<<<<<<<<<<<<<<< For blank Fields >>>>>>>>>>>>>>>>>>>>>>>>>>>>
  	if(trim($value) == "--None--" || trim($value) == "--none--")
  	{
  		$value = "";
  	}
	//<<<<<<<<<<<<<<< End >>>>>>>>>>>>>>>>>>>>>>>>>>>>
		$actual_values[$x] = $value;
		$actual_values[$x] = str_replace('"'," ",$actual_values[$x]);
		//if value contains any line feed or carriage return replace the value with ".value."
		if (preg_match ("/(\r?\n)/", $actual_values[$x]))
		{
			$actual_values[$x] = '"'.$actual_values[$x].'"';
		}
		$actual_values[$x] = decode_html(str_replace(","," ",$actual_values[$x]));
	}
  $mergevalue[] = implode($actual_values,",");  	
}
$csvdata = implode($mergevalue,"###");
}else
{
	die("No fields to do Merge");
}	
// Fix for: http://trac.lingdang.com/cgi-bin/trac.cgi/ticket/2107
$datafilename = $randomfilename . "_data.csv";

$handle = fopen($wordtemplatedownloadpath.$datafilename,"wb");
fwrite($handle,$csvheader."\r\n");
fwrite($handle,str_replace("###","\r\n",$csvdata));
fclose($handle);

?>
<script>
if (window.ActiveXObject){
	try 
	{
  		olingdangVM = eval("new ActiveXObject('lingdangCRM.ActiveX');");
  		if(olingdangVM)
  		{
        	var filename = "<?php echo $filename?>";
        	if(filename != "")
        	{
        		if(objMMPage.bDLTempDoc("<?php echo $site_URL?>/dataCache/test/wordtemplatedownload/<?php echo $filename?>","MMTemplate.doc"))
        		{
        			try
        			{
        				if(objMMPage.Init())
        				{
        					objMMPage.vLTemplateDoc();
							objMMPage.bBulkHDSrc("<?php echo $site_URL;?>/dataCache/test/wordtemplatedownload/<?php echo $datafilename ?>");
        					objMMPage.vBulkOpenDoc();
        					objMMPage.UnInit()
        					window.history.back();
        				}		
        			}catch(errorObject)
        			{
        				document.write("Error while processing mail merge operation");
        			}
        		}else
        		{
        			document.write("Cannot get template document");
        		}
        	}
  		}
		}
	catch(e) {
		document.write("Requires to download ActiveX Control from lingdangCRM. Please, ensure that you have administration privilage");
	}
}
</script>
</body>
</html>