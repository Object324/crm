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
<table width="100%" cellpadding="5" cellspacing="0" class="listTable" >
	<tr>
	<td class="colHeader small" width="5%">#</td>
	<td class="colHeader small" width="20%">{$MOD.LBL_Cron_Job}</td>
	<td class="colHeader small" width="15%">{$MOD.LBL_FREQUENCY}{$MOD.LBL_HOURMIN}</td>
	<td class="colHeader small" width="10%">{$CMOD.LBL_STATUS}</td>
        <td class="colHeader small" width="20%">{$MOD.LAST_START}</td>
        <td class="colHeader small" width="15%">{$MOD.LAST_END}</td>
        <td class="colHeader small" width='10%'>{$MOD.LBL_SEQUENCE}</td>
        <td class="colHeader small" width="5%">{$MOD.LBL_TOOLS}</td>
	</tr>
	{foreach name=cronlist item=elements from=$CRON}
	<tr>
	<td class="listTableRow">{$smarty.foreach.cronlist.iteration}</td>
	<td class="listTableRow">{$elements.cronname}</td>
	<td class="listTableRow">{$elements.days} {$elements.hours}:{$elements.mins}</td>
	{if $elements.status eq 'Active'}
	<td class="listTableRow active">{$elements.status}</td>
	{else}
	<td class="listTableRow inactive">{$elements.status}</td>
	{/if}
        <td class="listTableRow">{$elements.laststart}</td>
        <td class="listTableRow">{$elements.lastend}</td>
	{if $smarty.foreach.cronlist.first neq true}
		<td  align="center" class="listTableRow"><a class="icon-homearr icon-upfield" href="javascript:move_module('{$elements.id}','Up');" ></a>
	{/if}
	{if $smarty.foreach.cronlist.last eq true}
        <span class="place"></span>
	{/if}	
	{if $smarty.foreach.cronlist.first eq true}
		<td align="center" class="listTableRow">
            <span class="place"></span>
			<a class="icon-homearr icon-downfield" href="javascript:move_module('{$elements.id}','Down');" ></a>
        </td>
	{/if}
	
	{if $smarty.foreach.cronlist.last neq true && $smarty.foreach.cronlist.first neq true}
		<a class="icon-homearr icon-downfield" href="javascript:move_module('{$elements.id}','Down');" ></a></td>
	{/if}
        <td class="listTableRow" align="center" ><a class="icon-homearr icon-editfield" onclick="fnvshobj(this,'editdiv');fetchEditCron('{$elements.id}');" title="{$APP.LBL_EDIT}"></a></td>
        </tr>
	{/foreach}
	</table>
