<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/modules/Settings/Settings.js"></script>
<table border="0" cellspacing="1" cellpadding="5" width="100%" class="ControlTable1 listEntries fir-center">
<tr>
	<th class="firstChild" style="width: 45px;">#</th>
	{*<th align="left" width="10%">{'SELECT'|@getFixedLabel}</th>*}
	<th align="left" width="20%">{'TEMPLATENAME'|@getFixedLabel}</th>
	<th align="left"  width="20%">{'MESSCATEGORY'|@getFixedLabel}</th>
	<th align="left">{'Content'|@getFixedLabel}</th>
	<th align="left" style="width: 100px;">{'STATUS'|@getFixedLabel}</th>
	<th width="100">{'OPERATING'|@getFixedLabel}</th>
</tr>
{assign var="i" value=0}
{foreach name=emailtemplate item=template from=$TEMPLATES}
{assign var="j" value=$i++}
{if $smarty.foreach.emailtemplate.iteration mod 2 eq '1'}
	<tr id="row_{$j}" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
{else}
	<tr id="row_{$j}" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
{/if}
	<td class="firstChild" style="width: 45px;">{$smarty.foreach.emailtemplate.iteration}</td>
	{*
	/**
	 *@edit:andy 
	 *@date:20140821
	 *@reason:页面改进
	 *@version:v5.61
	 */
	*}
	{*<td><input type="checkbox" id="selected_id" name="selected_id" value="{$template.templateid}" onClick="ifselected(this); " class=small></td>*}
	<td>
		<a href="javascript:;" onclick="ViewSMSTemplate({$template.templateid})" ><span title="{$template.templatename}">{$template.templatename}</span></a>
	</td>
	<td title="{$template.template_type}" >{$template.template_type}&nbsp;</td>
	<td title="{$template.body}" >{$template.body}&nbsp;</td>
	<td style="width: 100px;"><input type="checkbox" onclick="change_tablefield_presence(this,{$template.templateid},'smstemplate_status')" class="second_switch" {if $template.deleted neq '1'}checked{/if}></td>
	<td>
		{if $PLATFORM neq 'aliyun'}
		<a class="Anu3_a" href="javascript:void(0)" onclick="EditSMSTemplate({$template.templateid})">{'EDIT'|@getFixedLabel}</a>
		<a class="Anu3_a" href="javascript:void(0);" onclick="deleteListtmp({$template.templateid},'','','SmsPhrases')">{'DELETE'|@getFixedLabel}</a>
		{/if}
	</td>
</tr>
{/foreach}	
</table>
