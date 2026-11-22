<?php
include(globalStatic::$root_directory . "include/mail/MailDb.php");

global $adb, $current_user;
$_REQUEST['diony'] = 'yes';
$idstring = $_REQUEST['idstring'];
$ids = explode(',', $idstring);
$ids = array_filter($ids);
$idstring = implode(',', $ids);
$deleted = $_REQUEST['email_deleted'];
$MailDbobj = new MailDb('');
if ($_REQUEST['selectallrecord'] == 'yes') {
    dump($_REQUEST['selectallrecord'] == 'yes');
    //$_SESSION['emails_list']
    $sql = $_SESSION['emails_list'];
    //$sql.= ' inner join ld_mail_accounts  on ld_mail_accounts.mail_username=ld_mailmanager_mailrecord.mailaccountname '
    $result = $adb->pquery($sql, array());
    $rows = $adb->num_rows($result);

    for ($i = 0; $i < $rows; $i++) {
        $mailrecorid = $adb->query_result($result, $i, 'mailrecordid');

        $MailDbobj->reductionEmail($mailrecorid);
    }

} else
    foreach ($ids as $mailrecorid) {
        $rows = $MailDbobj->reductionEmail($mailrecorid);
        if ($rows <= 0)//无法还原
        {
            ConverttojsonString(-1, array(), '无权限还原');

        }

    }
ConvertTojsonString(1, array(), 'success');


?>