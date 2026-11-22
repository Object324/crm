<div class="divPopOverflow">
<form enctype="multipart/form-data" method="POST" id="my_form" action="index.php" class="ajax_form">
	<input type="hidden" value="{$MODULE}" name="module">
	<input type="hidden" value="{$MODULE}Ajax" name="action">
	<input type="hidden" value="CreateReport" name="file" >
	<input type="hidden" value="" name="report_id">
	<input type="hidden" value="yes" name="report_save">
	<input type="hidden" value="{$FOLDER_ID}" id="folder_id" name="folder_id" > 
	<input type="hidden" value="{$frommodule}" id="frommodule" name="frommodule" >
	<div style="width:100%;overflow: auto">
	<table class="ld-public-content-small" border="0" cellpadding="0" cellspacing="0" width="100%">
		{if $frommodule=='ReportAnalysis'}
			{*zxm 20221109	报表分析 新增报表文件 需要选择文件夹*}
			<tr>
				<td class="ld-form-item-label"><font color="red">*</font>{'SELECTFOLDERS'|@getFixedLabel}</td>
				<td class="ld-form-item-content">
					<select name="analysisfolder_id" id="analysisfolder_id" tag="{'SELECTFOLDERS'|@getFixedLabel}" class="ld-select-inner" >
						{$folderOptions}
					</select>
				</td>
			</tr>
		{/if}
		<tr>
			<td class="ld-form-item-label"><font color="red">*</font>{'ReportName'|@getFixedLabel}</td>
			<td class="ld-form-item-content">
				<input id="report_name" name="report_name" tag="{'ReportName'|@getFixedLabel}" type="text" class="ld-input-inner" />
			</td>
		</tr>
		<tr>
			<td class="ld-form-item-label">{'reportdescription'|@getFixedLabel}</td>
			<td class="ld-form-item-content">
				<textarea id="report_describe" name="report_describe" class="ld-textarea-inner" ></textarea>
			</td>
		</tr>
	    <tr>
			<td class="ld-form-item-label"><font color="red">*</font>{'reporttype'|@getFixedLabel}</td>
			<td class="ld-form-item-content">
				<select name="report_type" id="report_type" tag="{'reporttype'|@getFixedLabel}" class="ld-select-inner">
					<option value="template" selected="true">{'STIMULSORTREPORTSPHP'|@getFixedLabel}</option>
					<option value="url">{'LINKADDRESS'|@getFixedLabel}</option>
	                {if $VERSIONACCOUNT eq 'yuwang'}
	                <option value="finereport">帆软报表</option>
	                {/if}
				</select>
			</td>
	    </tr>
	    <tr id="tr_templatereport">
			<td class="ld-form-item-label"><font color="red">*</font>{'TEMPLATEREPORT'|@getFixedLabel}</td>
			<td class="ld-form-item-content">
				<div id="template_div">
					<span id="files_list" style=" -moz-background-clip: initial; -moz-background-origin: initial; -moz-background-inline-policy: initial;">
						<input id="my_file_element" type="file" tabindex="7" style="width:150px;" name="report_file" accept=".mrt">
					</span>
				</div>
				<div id="url_div" style="display:none">
					<input id="report_url" name="report_url" placeholder="http://" tag="{'TEMPLATEREPORT'|@getFixedLabel}{'LINKADDRESS'|@getFixedLabel}"  type="text" class="ld-input-inner" />
				</div>
			</td>
	    </tr>
        {if $VERSIONACCOUNT eq 'yuwang'}
	        <tr id="tr_Reportfile" style="display:none;">
	    		<td class="ld-form-item-label"><font color="red">*</font>报表文件</td>
	    		<td class="ld-form-item-content">
	    			<input id="reportfile" name="reportfile" tag="报表文件"  type="text" class="ld-input-inner" />
	    		</td>
	    	</tr>
	        <tr id="tr_Reportserveraddress" style="display:none;">
	    		<td class="ld-form-item-label"><font color="red">*</font>报表服务器地址</td>
	    		<td class="ld-form-item-content">
	    			<input id="reportserveraddress" name="reportserveraddress" tag="报表服务器地址"  type="text" class="ld-input-inner"  />
	    		</td>
	    	</tr>
        {/if}
        <tr id="tr_DataBaseLink" >
	        <td class="ld-form-item-label"><font color="red">*</font>{'DataBaseLink'|@getFixedLabel}</td>
			<td class="ld-form-item-content">
				<select name="databaselinktype" id="databaselinktype" class="ld-select-inner" ">
	             <option value="crmlink">{'UseSysConfigParam'|@getFixedLabel}</option>
	             <option value="templatelink">{'UseTemplateParam'|@getFixedLabel}</option>
	            </select>
			</td>
        </tr>
	    <tr>
			<td class="ld-form-item-label"><font color="red">*</font>{'APPLICABLESCOPE'|@getFixedLabel}</td>
			<td id="allocate_divcontent" class="ld-form-item-content select-input">
			</td>
	    </tr>
		{*zxm 2021-0830 报表库增加可设置链接模块的功能*}
		<tr>
			<td class="ld-form-item-label">{'SETASLINKMODULE'|@getFixedLabel}</td>
			<td class="ld-form-item-content">
				<input id="setlinkmodule" type="checkbox" tabindex="8" class="second_switch" name="setlinkmodule">
			</td>
		</tr>
	</table>
	</div>
</form>
</div>