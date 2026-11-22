<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 
////////////////////////////////////////////////////
// PHPMailer - PHP email class
//
// Class for sending email using either
// sendmail, PHP mail(), or SMTP.  Methods are
// based upon the standard AspEmail(tm) classes.
//
// Copyright (C) 2001 - 2003  Brent R. Matzelle
//
// License: LGPL, see LICENSE
////////////////////////////////////////////////////

/**
 * PHPMailer - PHP email transport class
 * @package PHPMailer
 * @author Brent R. Matzelle
 * @copyright 2001 - 2003 Brent R. Matzelle
 */

//file modified by richie
require_once('include/utils/utils.php');
//require("modules/Emails/class.phpmailer.php");
require_once('include/PHPMailer/src/PHPMailer.php');
require_once('include/PHPMailer/src/SMTP.php');
require_once('include/logging.php');
require("config.php");

$current_user = Users::getActiveAdminUser();
// Set the default sender email id
global $HELPDESK_SUPPORT_EMAIL_ID;
$from = $HELPDESK_SUPPORT_EMAIL_ID;
if(empty($from)) {
	// default configuration is empty?
	$from = "reminders@localserver.com";
}
			
// Get the list of activity for which reminder needs to be sent

global $adb;
global $log;
$log =& LoggerManager::getLogger('SendReminder');
$log->debug(" invoked SendReminder ");

// retrieve the translated strings.
if(empty($current_language))
	$current_language = 'en_us';
$app_strings = return_application_language($current_language);

//modified query for recurring events -Jag

$query="select ld_crmentity.crmid,ld_seactivityrel.crmid as setype,ld_activity.*,ld_activity_reminder.reminder_time,ld_activity_reminder.reminder_sent,ld_activity_reminder.email_remind,ld_activity_reminder.recurringid,ld_recurringevents.recurringdate from ld_activity inner join ld_crmentity on ld_crmentity.crmid=ld_activity.activityid inner join ld_activity_reminder on ld_activity.activityid=ld_activity_reminder.activity_id left outer join ld_recurringevents on ld_activity.activityid=ld_recurringevents.activityid left outer join ld_seactivityrel on ld_seactivityrel.activityid = ld_activity.activityid where DATE_FORMAT(ld_activity.date_start,'%Y-%m-%d, %H:%i:%s') >= '".date('Y-m-d')."' and ld_crmentity.crmid != 0 and ld_activity.eventstatus = '".getTranslatedString('Planned','')."' and ld_activity_reminder.reminder_sent = 0 group by ld_activity.activityid,ld_recurringevents.recurringid";

$result = $adb->pquery($query, array());

if($adb->num_rows($result) >= 1)
{
	while($result_set = $adb->fetch_array($result))
	{
		$date_start = $result_set['date_start'];
		$time_start = $result_set['time_start'];
		$reminder_time = $result_set['email_remind'];
		$date = new DateTimeField( null );
		$curr_time = strtotime($date->getDisplayDateTimeValue())/60;
		$activity_id = $result_set['activityid'];
		$activitymode = ($result_set['activitytype'] == "任务")?"Task":"Events";
		$parent_type = $result_set['setype']; 
		$activity_sub = $result_set['subject'];
		$to_addr='';
			
		if($parent_type!='')
		$parent_content = getParentInfo($parent_type)."\n";
		else
		$parent_content = "";
		//code included for recurring events by jaguar starts	
		$recur_id = $result_set['recurringid'];
		$current_date=date('Y-m-d H:i');
		if($recur_id == 0)
		{
			$date_start = $result_set['date_start'];
		}
		else
		{
			$date_start = $result_set['recurringdate'];
		}
		//code included for recurring events by jaguar ends
		$date = new DateTimeField("$date_start $time_start");
		$activity_time = strtotime($date->getDisplayDateTimeValue())/60;
                
		if (($activity_time - $curr_time) > 0 && ( $reminder_time<=$current_date))
		{
			$log->debug(" InSide  REMINDER");
			$query_user="SELECT ld_users.email1,ld_salesmanactivityrel.smid FROM ld_salesmanactivityrel inner join ld_users on ld_users.id=ld_salesmanactivityrel.smid where ld_salesmanactivityrel.activityid =? and ld_users.deleted=0"; 
			$user_result = $adb->pquery($query_user, array($activity_id));		
			if($adb->num_rows($user_result)>=1)
			{
				while($user_result_row = $adb->fetch_array($user_result))
				{
					if($user_result_row['email1']!='' || $user_result_row['email1'] !=NULL)
					{
						$to_addr[] = $user_result_row['email1'];
					}
				}
			}
		
			// Retriving the Subject and message from reminder table		
			$sql = "select active,notificationsubject,notificationbody from ld_notificationscheduler where schedulednotificationid=8";
			$result_main = $adb->pquery($sql, array());

			$subject = $app_strings['Reminder'].$result_set['activitytype']." @ ".
						$result_set['date_start']." ".$result_set['time_start']."] (". DateTimeField::getDBTimeZone() .")".
						$adb->query_result($result_main,0,'notificationsubject');

			//Set the mail body/contents here
			$contents = nl2br($adb->query_result($result_main,0,'notificationbody')) ."\n\n ".
							$app_strings['Subject']." : ".$activity_sub."\n ". $parent_content ." ".
							$app_strings['Date & Time']." : ".$date_start." ".$time_start."(". DateTimeField::getDBTimeZone() .")\n\n ".
							$app_strings['Visit_Link']." <a href='".$site_URL."/index.php?action=DetailView&module=Calendar&record=".$activity_id."&activity_mode=".$activitymode."'>".$app_strings['Click here']."</a>";

			if(count($to_addr) >=1)
			{
				send_mail($to_addr,$from,$subject,$contents,$mail_server,$mail_server_username,$mail_server_password);
				$upd_query = "UPDATE ld_activity_reminder SET reminder_sent=1 where activity_id=?";
				$upd_params = array($activity_id);

				if($recur_id!=0)
				{
					$upd_query.=" and recurringid =?";
					array_push($upd_params, $recur_id);
				}

				$adb->pquery($upd_query, $upd_params);
				
			}
		}
	}
}

/**
 This function is used to assign parameters to the mail object and send it.
 It takes the following as parameters.
	$to as string - to address
	$from as string - from address
	$subject as string - subject if the mail
	$contents as text - content of the mail
	$mail_server as string - sendmail server name 
	$mail_server_username as string - sendmail server username 
	$mail_server_password as string - sendmail server password

*/
function send_mail($to,$from,$subject,$contents,$mail_server,$mail_server_username,$mail_server_password)
{
	global $adb;
    global $log;
    $log->info("This is send_mail function in SendReminder.php(lingdang home).");
	global $root_directory;

	$mail = new PHPMailer();


	$mail->Subject = $subject;
	$mail->Body    = nl2br($contents);//"This is the HTML message body <b>in bold!</b>";


	$mail->IsSMTP();                                      // set mailer to use SMTP
	
	$mailserverresult=$adb->pquery("select * from ld_systems where server_type='email'", array());
	$mail_server = $adb->query_result($mailserverresult,0,'server');
	$mail_server_username = $adb->query_result($mailserverresult,0,'server_username');
	$mail_server_password = $adb->query_result($mailserverresult,0,'server_password');
	$smtp_auth = $adb->query_result($mailserverresult,0,'smtp_auth');

	$_REQUEST['server']=$mail_server;
	$log->info("Mail Server Details => '".$mail_server."','".$mail_server_username."','".$mail_server_password."'");


	if($smtp_auth == 'true'){
	   $mail->SMTPAuth = true;
	}else {
		$mail->SMTPAuth = false;
    }
    
    if($adb->query_result($mailserverresult,0,'smtp_ssl')=='yes')
    {  
        //$mail->Host ="ssl://".$adb->query_result($result,0,'server').":465";
        $mail->Port=465;
        $mail->Host=$adb->query_result($result,0,'server');
        $mail->SMTPSecure = 'ssl';
    }
    else{
        $mail->Port=25;
        $mail->SMTPSecure='none';
        $mail->Host=$adb->query_result($result,0,'server');
    }
    
	$mail->SMTPOptions = array(
	'ssl' => array(
		'verify_peer' => false,
		'verify_peer_name' => false,
		'allow_self_signed' => true
		)
	);
    
	$mail->Username = $mail_server_username ;	// SMTP username
	$mail->Password = $mail_server_password ;	// SMTP password
	$mail->From = $from;
	$mail->FromName = $initialfrom;
	$log->info("Mail sending process : From Name & email id => '".$initialfrom."','".$from."'");
	foreach($to as $pos=>$addr)
	{
		$mail->AddAddress($addr);                  // name is optional
		$log->info("Mail sending process : To Email id = '".$addr."' (set in the mail object)");

	}
	$mail->WordWrap = 50;                                 // set word wrap to 50 characters

	$mail->IsHTML(true);                                  // set email format to HTML
	
	$mail->AltBody = "This is the body in plain text for non-HTML mail clients";

	$flag = MailSend($mail);
	$log->info("After executing the mail->Send() function.");
}

/**
 This function is used to ensure mail has been sent sucessfully with out error.
 It takes the mail object as the input and returns true if sucess else an error messaget. 
*/
function MailSend($mail)
{
	global $log;
        if(!$mail->Send())
        {
		$log->info("Error in Mail Sending : Error log = '".$mail->ErrorInfo."'");
           $msg = $mail->ErrorInfo;
        }
	else
       	{	
		$log->info("Mail has been sent from the lingdangCRM system : Status : '".$mail->ErrorInfo."'");
		return true;
	}		
}

/**
 This function is used to get the Parent mail id
 It takes the input returnmodule as string and parentid as integer, returns the parent mailid as string. 
*/
function getParentMailId($returnmodule,$parentid)
{
	global $adb;
        if($returnmodule == 'Leads')
        {
                $tablename = 'ld_leaddetails';
                $idname = 'leadid';
        }
        if($returnmodule == 'Contacts' || $returnmodule == 'HelpDesk')
        {
		if($returnmodule == 'HelpDesk')
			$parentid = $_REQUEST['contact_id'];
                $tablename = 'ld_contactdetails';
                $idname = 'contactid';
        }
	if($parentid != '')
	{
	        $query = 'select * from '.$tablename.' where '.$idname.' = ?';
			$res = $adb->pquery($query, array($parentid));
	        $mailid = $adb->query_result($res,0,'email');
	}
        if($mailid == '' && $returnmodule =='Contacts')
        {
                $mailid = $adb->query_result($res,0,'otheremail');
                if($mailid == '')
                        $mailid = $adb->query_result($res,0,'secondaryemail');
        }
	return $mailid;
}

/**
 This function is used to get the Parent type and its Name
 It takes the input integer - crmid and returns the parent type and its name as string. 
*/
function getParentInfo($value)
{
	global $adb;
 	$parent_module = getSalesEntityType($value);
	if($parent_module == "Leads")
	{
		$sql = "select * from ld_leaddetails where leadid=?";
		$result = $adb->pquery($sql, array($value));
		$first_name = $adb->query_result($result,0,"firstname");
		$last_name = $adb->query_result($result,0,"lastname");

		$parent_name = $last_name.' '.$first_name;
	}
	elseif($parent_module == "Accounts")
	{
		$sql = "select * from  ld_account where accountid=?";
		$result = $adb->pquery($sql, array($value));
		$account_name = $adb->query_result($result,0,"accountname");

		$parent_name =$account_name;
	}
	elseif($parent_module == "Potentials")
	{
		$sql = "select * from  ld_potential where potentialid=?";
		$result = $adb->pquery($sql, array($value));
		$potentialname = $adb->query_result($result,0,"potentialname");

		$parent_name =$potentialname;
	}
	  return $parent_module ." : ".$parent_name;
}
?>