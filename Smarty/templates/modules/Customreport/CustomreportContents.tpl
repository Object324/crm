{foreach item=report_folder key=report_folder_id from=$REPORT_FOLDER}
<div id="report-list-div-{$report_folder_id}">
	<input type="hidden" value="{$report_folder.report_info|@count}" id="report-folder-num-{$report_folder_id}">
	<div class="titleBg">
		<span id="report-name-$report_folder_id}">{$report_folder.folder_name}</span>
	</div>
	<!--按钮-->
	{if $ISADMIN eq 'on'}
	  	<div style="margin:10px;">
		    <input class="createauto" style="margin-right:12px;" type="button" value="{'Creating_a_Report'|@getFixedLabel}" onclick="fun_report_floder.getInstance({$report_folder_id}).createReport()"/>
			<input class="createauto" style="margin-right:12px;" type="button" value="{'reportsort'|@getFixedLabel}" onclick="fun_report_floder.getInstance({$report_folder_id}).sortReport()"/>
			<input class="createauto" style="margin-right:12px;" type="button" value="{'SHOWHIDDENREPORT'|@getFixedLabel}" onclick="fun_report_floder.getInstance({$report_folder_id}).showReport()"/>

		    <input class="deleteauto" {if $report_folder.systemdefault==1}style="float:right;margin-right:12px;DISPLAY:none;"{else}style="float:right;"{/if} type="button" value="{'DELETEFOLDER'|@getFixedLabel}" onclick="fun_report_floder.getInstance({$report_folder_id}).deleteFolder()"/>
		    <input class="createauto" {if $report_folder.systemdefault==1}style="float:right;margin-right:0;"{else}style="float:right;margin-right:12px;"{/if} type="button" value="{'HIDDENFOLDER'|@getFixedLabel}" onclick="fun_report_floder.getInstance({$report_folder_id}).hideFolder()"/>
		    <input class="saveauto" style="float:right;margin-right:12px;" type="button" value="{'RENAMEFOLDER'|@getFixedLabel}" onclick="fun_report_floder.getInstance({$report_folder_id}).renameFolder()"/>
		</div>
  	{/if}
	<!--报表排序-->
	<div id="report_sortview_{$report_folder_id}" class="E_pop_box LdPopWidth240px" style="display:none;">
		<div class="E_pop_tit">
			<strong class="E_ptita">{'reportsort'|@getFixedLabel}</strong>
			<button id="report-href-sort" class="E_ptitc" value="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"></button>
		</div>
		<table class="D_pop_bod" width="100%" align="center" cellspacing="1" cellpadding="2" border="0">
			<tr>	
				<td>
					<select id="select_report_{$report_folder_id}" multiple="" style="border:0px #ddd solid;width: 190px; height: 200px;padding-top: 3px;" onchange="selectedColumnClick(this);" name="select_report_{$report_folder_id}" size="10" >
						{foreach item=report_info key=num from=$report_folder.report_info}
							<option value="{$report_info.report_id}">{$report_info.report_name}</option>
						{/foreach}
					</select>
				</td>	
				<td align='center' width="50">
					<a class="icon-newhomearr icon-mup" href="javascript:;" title="{'MOVEUP'|@getFIxedLabel}" onclick="select_moveUp('select_report_{$report_folder_id}')">
					<a class="icon-newhomearr icon-mdown" href="javascript:;" style="margin-top: 15px;"title="{'MOVEDOWN'|@getFIxedLabel}" onclick="select_moveDown('select_report_{$report_folder_id}')">
				</td>
			</tr>
		</table>
		<div class="E_pbtn">
			<input type="button" class="E_pbtnok" value="{'SAVE'|@getFixedLabel}" id="report-save-sort-{$report_folder_id}"/><span>&nbsp;</span>
			<input type="button" class="E_pbtncancel" value="{'CANCEL'|@getFixedLabel}" id="report-hide-sort"/> 
		</div>
	</div>
	<!--重命名文件夹-->
	<div id="rename_folder_text_{$report_folder_id}" class="E_pop_box LdPopWidth400px" style="display:none;">
		<div class="E_pop_tit">
			<strong class="E_ptita">{'RENAMEFOLDER'|@getFixedLabel}</strong>
			<button id="rename-report-href-folder" class="E_ptitc" value="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"></button>
		</div>
		<div class="pad2010 ctextalign">
			<span class="padR10">{'Folder_name'|@getFixedLabel}</span>
			<input id="folder_name_{$report_folder_id}" name="folder_name_{$report_folder_id}" value="{$report_folder.folder_name}" type="text" class="detailedViewTextBox gwidth50" onfocus="this.className='commonDetailedTextBox gwidth50 bgcolordh'" onblur="this.className='detailedViewTextBox gwidth50'"/>
			<span class="padL10">{'50word_limit'|@getFixedLabel}</span>
		</div>
		<div class="E_pbtn">
			<input type="button" class="E_pbtnok" value="{'SAVE'|@getFixedLabel}" id="rename-report-save-folder-{$report_folder_id}" /><span>&nbsp;</span>
			<input type="button" class="E_pbtncancel" value="{'CANCEL'|@getFixedLabel}" id="rename-report-hide-folder"/> 
		</div>
	</div>
	<!--列表-->
	<table class="listEntries fir-center marB20" id="CL_Detial2" border="0" cellspacing="1" cellpadding="0" width="100%" >
		<tr>
			<th width="25">#</th>
			<th>{'ReportName'|@getFixedLabel}</th>
			<th>{'APPLICABLESCOPE'|@getFixedLabel}</th>
			<th>{'reportdescription'|@getFixedLabel}</th>
			{if $ISADMIN eq 'on'}
        {if $languageType eq 'zh'}
			   <th width="200">{'OPERATING'|@getFixedLabel}</th>
        {else}
         <th width="250">{'OPERATING'|@getFixedLabel}</th>
        {/if}
			{/if}
		</tr>
		{foreach item=report_info key=num from=$report_folder.report_info}
		<tr class="lvtColData">
			<td>{$num+1}</td>
			<td>{$report_info.report_name}</td>
			<td>{$report_info.allocatepname}</td>
			<td>{$report_info.report_describe}</td>
			{if $ISADMIN eq 'on'}
			<td>
				<a class="Anu3_a" style="white-space:nowrap;" id="report-edit-btn" onclick="editReport({$report_info.report_id})" relatedid="" href="javascript:void(0);" title="{'EDIT'|@getFixedLabel}"> {'EDIT'|@getFixedLabel}</a>
				<a class="Anu3_a" {if $report_info.systemdefault==1} style="white-space:nowrap;DISPLAY:none;"{else}style="white-space:nowrap;"{/if} onclick="deleteReport({$report_info.report_id},'{$report_info.report_type}',{$report_folder_id})" href="javascript:void(0);" title="{'DELETE'|@getFixedLabel}"> {'DELETE'|@getFixedLabel}</a>
                <a class="Anu3_a" style="white-space:nowrap;" onclick="hideReport({$report_info.report_id},'{$report_info.report_type}',{$report_folder_id})" href="javascript:void(0);" title="{'HIDDEN'|@getFixedLabel}"> {'HIDDEN'|@getFixedLabel}</a>
				<a class="Anu3_a" onclick="ReportAllocateUser({$report_info.report_id},{$report_info.allocatetype},{$report_folder_id})" title="{'ALLOCATE'|@getFixedLabel} {'APPLICABLEPERSONNEL'|@getFixedLabel}" href="javascript:void(0);">{'ALLOCATE'|@getFixedLabel}</a>
			</td>
			{/if}
		</tr>
		{/foreach}
	</table>
</div>
{/foreach}