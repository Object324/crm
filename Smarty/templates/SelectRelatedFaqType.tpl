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
<table class="qs-tab" width="100%" border="0" cellspacing="0" cellpadding="0" align="left" border="0">
{foreach item=faqtype_row_value key=row from=$FAQTYPE.faqtype}
	<tr>
	{foreach item=faqtype from=$faqtype_row_value}
		<td width="109">
		{if $faqtype.faqvalue neq ''}
		<input type="checkbox" value="{$faqtype.faqvalue}" id="select_faqtype" {$faqtype.ischecked} name="select_faqtype" onclick="getListViewFaqType('{$FROMMODULE}','{$SELECTMODULE}')"  />&nbsp;{$faqtype.faqvalue}
		{else}
		&nbsp;
		{/if}
		</td>	
	{/foreach}
	</tr>
{/foreach}
</table>