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
<table align="center" border="0" cellpadding="0" cellspacing="0" width="100%" >
	<tbody><tr>
	<td valign="top" width="50%" style="padding: 10px;border-right:1px dashed #CCCCCC">
	<!-- Reports Table Starts Here  -->
	{foreach item=reportfolder from=$REPT_FLDR}
	<table width="100%" border="0" cellpadding="0" cellspacing="0" align="center">
		<tr>
		<td class="reportsListTabHead">
		
		{if $MOD[$reportfolder.name] neq ''}
			{$MOD[$reportfolder.name]}
		{else}
			{$reportfolder.name}
		{/if}
		
		
		</td>
		</tr>
		<tr>
		<td>
		<table class="listEntries fir-center" border="0" cellpadding="0" cellspacing="1" width="100%">
			<tbody>
			<tr>
			<th>#</th>
			<th width="30%">{$MOD.LBL_REPORT_NAME}</th>
			<th>{$MOD.LBL_DESCRIPTION}</th>
            {if $LANGUAGETYPE eq 'en'}
			<th width="95" style="text-align:center;">{'OPERATING'|@getfixedLabel}</th>
            {else}
            <th width="85" style="text-align:center;">{'OPERATING'|@getfixedLabel}</th>
            {/if}
           </tr>
			{foreach name=reportdtls item=reportdetails from=$reportfolder.details}
				<tr bgcolor="white" class="Hover">
				<td>{$smarty.foreach.reportdtls.iteration}</td>
				{if $MOD[$reportdetails.reportname] neq ''}
                    {if $reportdetails.state eq 'DEFAULT'||$reportdetails.customizable neq '1'}
                    <td><a target="_blank" href="index.php?module=Reports&action=SaveAndRun&defaultReport={$reportdetails.customizable}&record={$reportdetails.reportid}&folderid={$reportfolder.id}">{$MOD[$reportdetails.reportname]}</a>
                    {else}
					<td><a target="_blank" href="index.php?module=Reports&action=SaveAndRun&record={$reportdetails.reportid}&folderid={$reportfolder.id}">{$MOD[$reportdetails.reportname]}</a>
					{/if}
                    {if $reportdetails.sharingtype eq 'Shared'}
						<img src="{'Meetings.gif'|@lingdang_imageurl:$THEME}" align="absmiddle" border=0 height=12 width=12 /> 
					{/if}
					</td>
				{else}
                    {if $reportdetails.state eq 'DEFAULT'||$reportdetails.customizable neq '1'}
                    {if $reportdetails.reportname eq '销售订单跟踪表'}
                    <td><a target="_blank" href="index.php?module=Reports&action=SaveAndRun&defaultReport={$reportdetails.customizable}&record={$reportdetails.reportid}&folderid={$reportfolder.id}">合同订单跟踪表</a>
                    {else}
                    <td><a target="_blank" href="index.php?module=Reports&action=SaveAndRun&defaultReport={$reportdetails.customizable}&record={$reportdetails.reportid}&folderid={$reportfolder.id}">{$reportdetails.reportname}</a>
                    {/if}
                    
                    {else}
					<td><a target="_blank" href="index.php?module=Reports&action=SaveAndRun&record={$reportdetails.reportid}&folderid={$reportfolder.id}">{$reportdetails.reportname}</a>
					{/if}
                    {if $reportdetails.sharingtype eq 'Shared'}
						<img src="{'Meetings.gif'|@lingdang_imageurl:$THEME}" align="absmiddle" border=0 height=12 width=12 /> 
					{/if}
					</td>
				{/if}
				{if $MOD[$reportdetails.description] neq ''}
					<td>{$MOD[$reportdetails.description]}</td>
				{else}
                    {if $reportdetails.description eq '销售订单跟踪表'}
					<td>合同订单跟踪表</td>
                    {else}
                    <td>{$reportdetails.description}</td>
                    {/if}
                {/if}
                <td align="center" nowrap>
                    {if $reportdetails.customizable eq '1' && $reportdetails.editable eq 'true'}
						<a class="Anu3_a" href="javascript:;" onClick="editReport('{$reportdetails.reportid}');">{'EDIT'|@getFixedLabel}</a>
					{/if}
					{if $reportdetails.state neq 'SAVED' && $reportdetails.state neq 'DEFAULT'&&$reportdetails.editable eq 'true'}
						<a class="Anu3_a" href="javascript:;" onclick="DeleteReport('{$reportdetails.reportid}');">{'DELETE'|@getFixedLabel}</a>
					{/if}
				</td>
				</tr>
			{/foreach}

			</tbody>
		</table>
		</td>
		</tr>
	</table>
	<br />
	{/foreach}
	<!-- Reports Table Ends Here  -->
	</td>
	<td style="padding:10px;" valign="top" align="center" width="50%">
    <div>
        <ul class="D_btn_box">   
             <li class="D_anu_a">
                <a href="javascript:;" onclick="gcurrepfolderid=0;fnvshobj(this,'reportLay');">
                <b class="icon-homeimg icon-plus"></b><span>{'Creating_a_Report'|@getFixedLabel}</span></a>
             </li>
             <li class="D_anu_a">
                <a href="javascript:;" onclick="createrepFolder(this,'orgLay');">
                <b class="icon-homeimg icon-plus"></b><span>{'ADDFOLDER'|@getFixedLabel}</span></a>
             </li>
             <li class="D_anu_a">
                <a href="javascript:;" onclick="fnvshobj(this,'folderLay');">
                <b class="icon-homeimg icon-move"></b><span>{'MOVE'|@getFixedLabel}</span></a>
             </li>
             <li class="D_anu_a">
                <a href="javascript:;" onClick="massDeleteReport();">
                <b class="icon-homeimg icon-del"></b><span>{'DELETE'|@getFixedLabel}</span></a>
             </li>
        </ul>
    </div>
    <div class="clear"></div>
	<div id="customizedrep" style="margin-top:10px;">
		{include file="ReportsCustomize.tpl"}	
	</div>
	</td>
	</tr>
	<tr>
	<td colspan="2" align="center">&nbsp;</td>
	</tr>
	</tbody>
</table>
