<div class="divPopOverflow">
	<form enctype="multipart/form-data" method="POST" id="my_form" action="index.php" class="ajax_form">
	<input type="hidden" value="{$REPORT_ID}" name="report_id" id="report_id">
	<input type="hidden" value="{$FOLDER_ID}" name="edit_folder_id" id="edit_folder_id" />
	<input type="hidden" value="{$frommodule}" id="frommodule" name="frommodule" >
	<table class="ld-public-content-small" border="0" cellpadding="0" cellspacing="0" width="100%">
		{if $frommodule=='ReportAnalysis'}
			{*zxm 20221109	报表分析 新增报表文件 需要选择文件夹*}
			<tr>
				<td class="ld-form-item-label"><font color="red">*</font>{'SELECTFOLDERS'|@getFixedLabel}</td>
				<td class="ld-form-item-content">
					<select name="analysisfolder_id" id="analysisfolder_id" tag="{'SELECTFOLDERS'|@getFixedLabel}" class="ld-select-inner">
						{$folderOptions}
					</select>
				</td>
			</tr>
		{else}
		<tr>
			<td class="ld-form-item-label"><font color="red">*</font>{'Folder_name'|@getFixedLabel}</td>
			<td class="ld-form-item-content">
				<input type="hidden" id="hidden_select_folder" name="hidden_select_folder" value="{$FOLDER_ID}" />
				<select class="ld-select-inner" id="edit_select_folder" name="edit_select_folder">
					{foreach item=folder_info key=folder_id from=$FOLDER_ALL}
						<option value="{$folder_id}" {if $folder_id eq $FOLDER_ID} selected {/if} title="{$folder_info.folder_name}">{$folder_info.folder_name}</option>
					{/foreach}
				</select>
			</td>
		</tr>
		{/if}
		<tr>
			<td class="ld-form-item-label"><font color="red">*</font>{'ReportName'|@getFixedLabel}</td>
			<td class="ld-form-item-content">
				<input class="ld-input-inner" id="edit_report_name" name="edit_report_name" value="{$REPORT_NAME}" tag="{'ReportName'|@getFixedLabel}" type="text"/>
			</td>
		</tr>
		{if $REPORT_TYPE eq 'url'}
		<tr>
			<td class="ld-form-item-label"><font color="red">*</font>{'TEMPLATEREPORT'|@getFixedLabel}</td>
			<td class="ld-form-item-content">
				<input class="ld-input-inner" id="edit_report_url" name="edit_report_url" value="{$REPORT_URL}" tag="{'TEMPLATEREPORT'|@getFixedLabel}{'LINKADDRESS'|@getFixedLabel}" type="text"/>
			</td>
		</tr>
		{/if}
		<tr>
			<td class="ld-form-item-label">{'reportdescription'|@getFixedLabel}</td>
			<td class="ld-form-item-content">
				<textarea class="ld-textarea-inner" id="edit_report_describe" name="edit_report_describe">{$REPORT_DESCRIBE}</textarea>
			</td>
		</tr>
		<tr>
			<td class="ld-form-item-label">
				{'reporttype'|@getFixedLabel}:
			</td>
			<td class="ld-form-item-content">
				{if $REPORT_TYPE eq 'template_flex'||$REPORT_TYPE eq 'template_js'}
					<input type="text" readonly="" disabled="" class="ld-input-inner" value="{'STIMULSORTREPORTSPHP'|@getFixedLabel}"/>
				{else if $REPORT_TYPE eq 'finereport'}
					<input type="text" readonly="" disabled="" class="ld-input-inner" value="帆软报表"/>
				{else}
					<input type="text" readonly="" disabled="" class="ld-input-inner" value="{'LINKADDRESS'|@getFixedLabel}"/>
				{/if}
			</td>
		</tr>
		{if $REPORT_TYPE eq 'template_flex'||$REPORT_TYPE eq 'template_js'}
		<tr>
			<td class="ld-form-item-label">
				{'TEMPLATEREPORT'|@getFixedLabel}
			</td>
			<td class="ld-form-item-content">
				<input type="text" readonly="" class="ld-input-inner" disabled="" value="{$report_template}"/>
			</td>
		</tr>
		<tr id="tr_DataBaseLink" >
			<td class="ld-form-item-label">
				<font color="red">*</font>{'DataBaseLink'|@getFixedLabel}
			</td>
			<td class="ld-form-item-content">
				<select {if $systemdefault eq '1'} disabled=""{else}name="databaselinktype" id="databaselinktype"{/if} class="ld-select-inner" >
					<option value="crmlink" {if $databaselinktype eq 'crmlink'} selected {/if}>{'UseSysConfigParam'|@getFixedLabel}</option>
					<option value="templatelink" {if $databaselinktype eq 'templatelink'} selected {/if}>{'UseTemplateParam'|@getFixedLabel}</option>
				</select>
				{if $systemdefault eq '1'}
				<input  type="hidden" name="databaselinktype" id="databaselinktype" value="crmlink"/>
				{/if}
			</td>
		 </tr>
		 {/if}
		 {if $VERSIONACCOUNT eq 'yuwang' && $REPORT_TYPE eq 'finereport'}
			  <tr id="tr_Reportfile">
				<td class="ld-form-item-label"><font color="red">*</font>{'REPORTFILE'|@getFixedLabel}</td>
				<td class="ld-form-item-content">
					<input class="ld-input-inner" id="reportfile" name="reportfile" value="{$REPORT_FILE}" tag="报表文件" type="text" style="border:1px solid #eee;width:300px;"/>
				</td>
			  </tr>
			  <tr id="tr_Reportserveraddress">
				<td class="ld-form-item-label"><font color="red">*</font>{'REPORTSERVERADDRESS'|@getFixedLabel}</td>
				<td class="ld-form-item-content">
					<input class="ld-input-inner" id="reportserveraddress" name="reportserveraddress" value="{$REPORT_URL}" tag="报表服务器地址" type="text" style="border:1px solid #eee;width:300px;"/>
				</td>
			  </tr>

		  {/if}
		{*zxm 2021-0830 报表库增加可设置链接模块的功能*}
		<tr>
			<td class="ld-form-item-label">{'SETASLINKMODULE'|@getFixedLabel}</td>
			<td class="ld-form-item-content">
				<input id="setlinkmodule" type="checkbox" tabindex="8" class="second_switch" name="setlinkmodule" {if $setlinkmodule=="yes"}checked{/if}>
			</td>
		</tr>
	</table>
	</form>
</div>