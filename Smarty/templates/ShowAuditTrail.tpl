{*<!--
/*********************************************************************************
  ** The contents of this file are subject to the lingdang CRM Public License Version 1.0
   * ("License"); You may not use this file except in compliance with the License
   * The Original Code is:  lingdang CRM Open Source
   * The Initial Developer of the Original Code is lingdang.
   * Portions created by lingdang are Copyright (C) lingdang.
   * All Rights Reserved.
  *
 ********************************************************************************/
-->*}
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<title></title>
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
<!--修改编码格式:统一编码：UTF-8-->
<link rel="stylesheet" type="text/css" href="{$THEME_PATH}style.css">
<style type="text/css">@import url("themes/{$THEME}/global.css");</style>
<style type="text/css">@import url("themes/{$THEME}/popup.css");</style>
<style type="text/css">@import url("themes/{$THEME}/liststyle.css");</style>
<script language="javascript" type="text/javascript" src="include/scriptaculous/prototype.js"></script>
<link href="themes/softed/Control.css" rel="stylesheet" type="text/css" />

</head>
<body marginwidth=0 marginheight=0 leftmargin=0 topmargin=0 bottommargin=0 rigthmargin=0>

<form action="index.php?module=Settings&action=SettingsAjax&file=ShowAuditTrail&userid={$USERID}" method="post" id="form">
<input type='hidden' name='module' value='Settings'>
<input type='hidden' id='userid' name='userid' value='{$USERID}'>
<input type='hidden' id='pagenum' name='pagenum' value='{$PAGENUM}'>

<div style="padding:5px;">
    <div class="AuditTrailContentsHeader">{'AUDITTRAILS'|@getFixedLabel}</div>
	<div id="AuditTrailContents">
		{include file="ShowAuditTrailContents.tpl"}
	</div>
    <div style="height:20px;background-color:#fafafa;"></div>    
</div>	
	
</form>
</body>
</html>
{literal}
<script>
function getListViewEntries_js(module,url)
{
	var userid = document.getElementById('userid').value;
        new Ajax.Request(
                'index.php',
                {queue: {position: 'end', scope: 'command'},
                        method: 'post',
                        postBody: 'module=Settings&action=SettingsAjax&file=ShowAuditTrail&ajax=true&'+url+'&userid='+userid,
                        onComplete: function(response) {
                                $("AuditTrailContents").innerHTML= response.responseText;
                        }
                }
        );
}
</script>
{/literal}