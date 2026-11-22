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
<!--修改编码格式:统一编码：UTF-8-->
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<title></title>
	<!-- diony_ico 2012-12-03   
    <link REL="SHORTCUT ICON" HREF="themes/images/lingdangcrm_icon.ico">
    -->
	<style type="text/css">@import url("themes/{$THEME}/style.css");</style>
    <style type="text/css">@import url("themes/{$THEME}/global.css");</style>
	<!-- ActivityReminder customization for callback -->
	{literal}
	<style type="text/css">div.fixedLay1 { position:fixed; }</style>
	<!--[if lte IE 6]>
	<style type="text/css">div.fixedLay { position:absolute; }</style>
	<![endif]-->
	{/literal}
	<!-- End -->
</head>

<body leftmargin=0 topmargin=0 marginheight=0 marginwidth=0 class=small>

{if $EDIT_DUPLICATE eq 'permitted'}
<script type="text/javascript" src="include/jquery/jquery.min.js"></script>
<script type="text/javascript" src="include/jquery/jquery-ui.min.js"></script>
<script type="text/javascript" language="JavaScript">
	var ld = $;
</script>
<script language="JAVASCRIPT" type="text/javascript" src="include/js/smoothscroll.js"></script>
<script language="JavaScript" type="text/javascript" src="include/js/menu.js"></script>
<script src="{$CRMCOMMONURL}crmcommon/js/scriptaculous/prototype.js" type="text/javascript"></script>
<script src="{$JSURL}include/js/general.js" type="text/javascript"></script>

<form name="merge" method="POST" action="index.php" id="form" onsubmit="validate_merge('{$MODULENAME}')">
	<input type=hidden name="module" value="{$MODULENAME}">
	<input type=hidden name="return_module" value="{$MODULENAME}">
	<input type="hidden" name="action" value="ProcessDuplicates">
	<input type="hidden" name="mergemode" value="mergesave">
	<input type="hidden" name="parent" value="{$PARENT_TAB}">
	<input type="hidden" name="pass_rec" value="{$IDSTRING}">
	<input type="hidden" name="return_action" value="FindDuplicateRecords">
	
	<div class="mergediv">
		<table class="small" border="0" cellspacing=0 cellpadding=4 width="100%">	
		<tr>
			<td align="left" colspan="2" class="moduleName" nowrap="nowrap" style="padding-left:3px;">
		
			{'MERGERECORDSIN'|@getFixedLabel} &gt; <span>{$MODULENAME|@getTranstab}</span>
			</td>
		</tr>
		<tr>
			<td class="small" style="color:#666">{'PRIMARRECORDMERGE'|@getFixedLabel}</td>
		</tr>
		</table>
	</div>
	
	<div style='margin: 0 10px;'>
		<table class="listEntries lvt small" border="0" cellpadding="3" cellspacing="1" width="100%">
		<tr >
			<th class=""><b>{'LISTFIELDS'|@getFixedLabel}</b></th>
			{assign var=count value=1}
			{assign var=cnt_rec value=0}
			{if $NO_EXISTING eq 1}
				{foreach key=cnt item=record from=$ID_ARRAY}	
					<th  class="" >
						<b>{'Numbers'|@getFixedLabel}&nbsp;#{$count}</b>
						{if $count eq 1}
							<input name="record" value="{$record}" onclick="select_All('{$JS_ARRAY}','{$cnt}','{$MODULENAME}');" type="radio" checked> <span style="font-size:12px">{'SELECTPRIMARYRECORD'|@getFixedLabel}</span>
						{else}
							<input name="record" value="{$record}" onclick="select_All('{$JS_ARRAY}','{$cnt}','{$MODULENAME}');" type="radio"> <span style="font-size:12px">{'SELECTPRIMARYRECORD'|@getFixedLabel}</span>
						{/if}
					</th>
					{assign var=cnt_rec value=$cnt_rec+1}
					{assign var=count value=$count+1}
				{/foreach}
			{else}
				{foreach key=cnt item=record from=$ID_ARRAY}	
					<th  class="" >
						<b>{'Numbers'|@getFixedLabel}&nbsp;#{$count}</b>
					{assign var=found value=0}
					{foreach item=child key=k from=$IMPORTED_RECORDS}
						{if $record eq $child}	
							{assign var=found value=1}
						{/if}
					{/foreach}
					{if $found eq 0}
						{if $count eq 1}
							<input name="record" value="{$record}" onclick="select_All('{$JS_ARRAY}','{$cnt}','{$MODULENAME}');" type="radio" checked> <span style="font-size:12px">{'SELECTPRIMARYRECORD'|@getFixedLabel}</span>
						{else}
							<input name="record" value="{$record}" onclick="select_All('{$JS_ARRAY}','{$cnt}','{$MODULENAME}');" type="radio"> <span style="font-size:12px">{'SELECTPRIMARYRECORD'|@getFixedLabel}</span>
						{/if}
					{/if}
					</th>
					{assign var=cnt_rec value=$cnt_rec+1}
					{assign var=count value=$count+1}
				{/foreach}
			{/if}
		</tr>
            {assign var=i value=1}
			{foreach item=data key=cnt from=$ALLVALUES}
			{foreach item=fld_array key=label from=$data}
            {assign var="j" value=$i++}
		<tr class="IvtColdata" {if $j mod 2 eq '0'}style="background: #f8f8f8;"{/if} onmouseover="this.className='lvtColDataHover';" onmouseout="this.className='lvtColData';" bgcolor="white">	
					<td >{$label}{$test}</td>
					{foreach item=fld_value key=cnt2 from=$fld_array}
						{if $fld_value.disp_value neq ''}
							{if $cnt2 eq 0}
								<td nowrap><input name='{$FIELD_ARRAY[$cnt]}' value='{$fld_value.org_value}' type="radio" checked>{$fld_value.disp_value|truncate:30}</td>
							{else}
								<td nowrap><input name='{$FIELD_ARRAY[$cnt]}' value='{$fld_value.org_value}' type="radio">{$fld_value.disp_value|truncate:30}</td>
							{/if}
						{else}
							{if $cnt2 eq 0}
								<td><input name='{$FIELD_ARRAY[$cnt]}' value='' type="radio" checked>--{'NONE'|@getFixedLabel}--</td>
							{else}
								<td><input name='{$FIELD_ARRAY[$cnt]}' value='' type="radio">--{'NONE'|@getFixedLabel}--</td>
							{/if}
						{/if}
					{/foreach}
		</tr>
				{/foreach}	
				{/foreach}	
		</table>
	</div>
	
	<div style='margin: 15px 5px;'>
		<table border=0 class="lvtColData"  width="100%" cellspacing=0 cellpadding="0px">	
		  <tr>
				<td align="center" >
				<input title="{'Merge'|@getFixedLabel}" class="saveauto" type="submit" name="button" value="{'Merge'|@getFixedLabel}" >	
				</td>
		  </tr>	
		</table>
	</div>
</form>

{else}
	<table border='0' cellpadding='5' cellspacing='0' width='100%' height='450px'><tr><td align='center'>
	<div style='border: 3px solid rgb(153, 153, 153); background-color: rgb(255, 255, 255); width: 55%; position: relative; z-index: 10000000;'>

		<table border='0' cellpadding='5' cellspacing='0' width='98%'>
		<tbody><tr>
		<td rowspan='2' width='11%'><img src='{'denied.gif'|@lingdang_imageurl:$THEME}' ></td>
		<td style='border-bottom: 1px solid rgb(204, 204, 204);' nowrap='nowrap' width='70%'>
			<span class='genHeaderSmall'>{'NOPERMITTEDEXECUTE'|@getFixedLabel}</span></td>
		</tr>
		<tr>
		<td class='small' align='right' nowrap='nowrap'>
		<a href='javascript:self.close();'>{'RETURN'|@getFixedLabel}</a><br>
		</td>
		</tr>
		</tbody></table>
	</div>
	</td></tr></table>
				
{/if}
</body>
</html>			