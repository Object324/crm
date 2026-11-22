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
global $default_charset;

if(isset($_REQUEST['templateid']) && $_REQUEST['templateid'] !='')
{
	$templatedetails = getTemplateDetails($_REQUEST['templateid']);
}
?>
<form name="frmrepstr" onsubmit="puyoungJS_DialogBox.block();">
<input type="hidden" name="subject" value="<?php echo $templatedetails[2];?>"></input>
<textarea name="repstr" style="visibility:hidden">
<?php echo htmlentities($templatedetails[1], ENT_NOQUOTES, $default_charset); ?>
</textarea>
</form>
<script type="text/javascript">
if(typeof window.opener.document.getElementById('_mail_replyfrm_subject_') != 'undefined' &&
	window.opener.document.getElementById('_mail_replyfrm_subject_') != null){
	window.opener.document.getElementById('_mail_replyfrm_subject_').value = window.document.frmrepstr.subject.value;
	window.opener.document.getElementById('_mail_replyfrm_body_').value = window.document.frmrepstr.repstr.value;
	window.opener.MailManager.mail_reply_rteinit(window.document.frmrepstr.repstr.value);
	window.close();
}
</script>