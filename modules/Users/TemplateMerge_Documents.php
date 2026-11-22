<?php
/*********************************************************************************
 *{*�޸ı����ʽ:ͳһ���룺UTF-8*}
** The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
*
 ********************************************************************************/

include('config.inc.php');
global $default_charset;

if(isset($_REQUEST['templateid']) && $_REQUEST['templateid'] !='')
{
	$templatedetails = getTemplateDetails($_REQUEST['templateid']);
}
?>
<form name="frmrepstr" onsubmit="puyoungJS_DialogBox.block();">
<input type="hidden" name="subject" id="subject" value="<?php echo $templatedetails[2];?>"></input>
<textarea name="repstr" style="visibility:hidden">
<?php echo htmlentities($templatedetails[1], ENT_NOQUOTES, $default_charset); ?>
</textarea>
</form>
<script type="text/javascript">
    //window.opener.richtextobj.innerHTML=window.document.frmrepstr.repstr.value;
   // alert( window.opener.richtextobj.innerHTML);
	//window.opener.oCKeditor.setData(window.document.frmrepstr.repstr.value);
  //  window.opener.document.getElementsByTagName("iframe")[0].contentWindow.document.body.innerHTML = window.document.frmrepstr.repstr.value;
   // window.opener.oCKeditor.html(window.document.frmrepstr.repstr.value);
  //  window.close();
  var use_rich='<?php  echo $USE_RTE;?>';//config.inc.php->$USE_RTE
 if(use_rich=='true')
 {
    window.opener.oCKeditor.execCommand('insertHtml',window.document.frmrepstr.repstr.value);
    
 }
 else{
    var value=window.document.frmrepstr.repstr.value;
    value=value.replace(/<[^>]+>/g,"");
    window.opener.document.getElementById('notecontent').value=value;
  }
  
  window.close();
</script>