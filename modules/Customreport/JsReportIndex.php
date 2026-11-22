<?php
//StiLicense.loadFromString:licenseKey
if(!isset($_SESSION['authenticated_user_id'])&&!isset($_GET['crm_report_userid']))
{
    	header("Location:../../index.php?action=Login&module=Users&login_method=true");
}
$userid=$_SESSION['authenticated_user_id'];
$defaultreport=$_GET['default_report'];
$reportname=$_GET['crm_report_key'];
require_once 'stimulsoft/helper.php';

?>