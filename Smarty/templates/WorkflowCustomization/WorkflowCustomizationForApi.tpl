<form action="index.php" method="post" name="workflow_actions" class="ajax_form">
	<input type="hidden" name="workflow_aciton_type" value="API" />
	<input type="hidden" name="workflow_actionsid" value="{$ACTION_DATA.workflow_actionid}" />
	<input type="hidden" name="workflow_id" value="{$WORDFLOW_ID}" />
	<input type="hidden" name="tabid" value="{$TABID}" />
	<input type="hidden" name="mode" value="save" />
	{*<input type="hidden" name="jdyisv" value="{$JDYISV}" />*}
	<input type="hidden" name="FIELDSEL" value='{$FIELDSEL}' />
	<input type="hidden" name="MAINFIELDSEL" value='{$MAINFIELDSEL}' />
	<input type="hidden" name="PLEASESELECTFIELD_label" value="{'PLEASESELECTFIELD'|@getFixedLabel}" />
	<input type="hidden" name="CURRENTDATE_label" value="{'CURRENTDATE'|@getFixedLabel}" />
	<input type="hidden" name="CurrentTime_label" value="{'CurrentTime'|@getFixedLabel}" />
	<input type="hidden" name="COMPANYADDRESS_label" value="CRM{'COMPANYADDRESS'|@getFixedLabel}" />
	<input type="hidden" name="BIll_label" value="{'BIll'|@getFixedLabel}ID" />
	<input type="hidden" name="SystemVariables_label" value="{'SystemVariables'|@getFixedLabel}" />
	<input type="hidden" name="MANUALINPUT_label" value="{'MANUALINPUT'|@getFixedLabel}" />
	<input type="hidden" name="Docmodulefields_label" value="{'Docmodulefields'|@getFixedLabel}" />
	<input type="hidden" name="Parametename_label" value="{'Parametename'|@getFixedLabel}" />
	<input type="hidden" name="Parametevalue_label" value="{'Parametevalue'|@getFixedLabel}" />
	<input type="hidden" name="Paramete_label" value="{'Paramete'|@getFixedLabel}" />
	<input type="hidden" name="Currentmodule_label" value="{'Currentmodule'|@getFixedLabel}" />
	<input type="hidden" name="DocumentNumber" value="{'DocumentNumber'|@getFixedLabel}" />
    <table class="ld-public-content-small" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <td class="ld-form-item-label">
                <font color="red">*</font>{'ActionTitle'|@getFixedLabel}
            </td>
            <td class="ld-form-item-content">
				<input class="ld-input-inner" type="text" name="action_title" tag="{'ActionTitle'|@getFixedLabel}" value="{$ACTION_DATA.action_title}" />
            </td>
        </tr>
        <tr>
            <td class="ld-form-item-label">
				<font color="red">*</font>API URL
            </td>
            <td class="ld-form-item-content">
                <input class="ld-input-inner" type="text" name="api_url" value="{$ACTION_DATA.api_url}" />
            </td>
        </tr>
		<tr>
            <td class="ld-form-item-label">
				{'InputParameter'|@getFixedLabel}
            </td>
            <td class="ld-form-item-content">
                <table class="" border="0" name="post_table" id="post_table" cellpadding="0" cellspacing="0" width="100%">
					<input type="hidden" name="post_tr_cnt" value="1">
					<thead>
					<tr>
						<td width="20%">{'Paramete'|@getFixedLabel}</td>
						<td width="20%">{'Parametevalue'|@getFixedLabel}</td>
						<td width="20%">{'ParametricDescription'|@getFixedLabel}</td>
						<td width="30%"></td>
						<td width="10%"></td>
					</tr>
					</thead>
					<tbody>
					<tr name="post_tr_1">
						<td class="padT16"><input class="ld-input-inner gwidth90" type="text" name="post_1" value="" placeholder="KEY" /></td>
						<td class="padT16">
							<select class="ld-select-inner gwidth90 lfloat" name="post_type" tag_row="1" tag="post" id="">
								<option value="manual">{'MANUALINPUT'|@getFixedLabel}</option>
								<option value="module_fields">{'Docmodulefields'|@getFixedLabel}</option>
								<option value="system_fields">{'SystemVariables'|@getFixedLabel}</option>
							</select>
							<input type="hidden" name="post_parameter_type_1" value="manual">
						</td>
						<td class="padT16">
							<input class="ld-input-inner gwidth90 marL8" type="text" name="post_manual_1" value="" placeholder="{'pleaseenter'|@getFixedLabel}" />
							<select class="ld-select-inner gwidth90 marL8" name="post_module_fields_1" style="display:none;">{$MAINFIELDSEL}</select>
							<select class="ld-select-inner gwidth90 marL8" name="post_system_fields_1" style="display:none;">
								<option>{'PLEASESELECTFIELD'|@getFixedLabel}</option>
								<option value="[sys.currentdate]">{'CURRENTDATE'|@getFixedLabel}</option>
								<option value="[sys.currenttime]">{'CurrentTime'|@getFixedLabel}</option>
								<option value="[sys.record]">{'BIll'|@getFixedLabel}ID</option>
							</select>
						</td>
						<td class="padT16"><input class="ld-input-inner gwidth90" type="text" name="post_description_1" value="" placeholder="{'ParametricDescription'|@getFixedLabel}" /></td>
						<td class="padT16">
							<input type="hidden" name="post_tr_display_1" value="yes">
							<i class="ld-fonticon ld-fonticon-del" style="margin-left: 20px;" name="api_tr_del" tag="post" tag_row="1" title="{'DELETE'|@getFixedLabel}"></i>
						</td>
					</tr>
					</tbody>
					<tfoot>
					<tr>
						<td class='padT16'>
							<i class="ld-fonticon ld-fonticon-add" name="api_tr_add" tag="post" tag_row="1" title="{'ADDITION'|@getFixedLabel}"></i>
						</td>
					</tr>
					</tfoot>
				</table>
            </td>
        </tr>
		<tr>
			<td class="ld-form-item-label">
				{'ReceiveReturnStatusAndPrompt'|@getFixedLabel}
			</td>
			<td class="ld-form-item-content">
				<input class="second_switch" type="checkbox" name="api_receive_msg" {if $ACTION_DATA.api_receive_msg eq 'yes'}checked{/if}/>
			</td>
		</tr>
		<tr name="tr_code_table" {if $ACTION_DATA.api_receive_msg neq 'yes'}style="display: none;"{/if}>
			<td class="ld-form-item-label">
				<b class="icon-homeimg icon-askgrey-help tip-items-list" data-tip="{'ReturnStateTip'|@getFixedLabel}" data-direction="top" data-type="position"></b>
				{'ReturnState'|@getFixedLabel}
			</td>
			<td class="ld-form-item-content">
				<table class="settingPopTable lasttdbordernon" border="0" name="code_table" id="code_table" cellpadding="0" cellspacing="0" width="100%">
					<input type="hidden" name="code_tr_cnt" value="1">
					<thead>
						<tr>
							<td width="10%">{'StatusCode'|@getFixedLabel}</td>
							<td width="40%">{'StatusDescription'|@getFixedLabel}</td>
							<td width="30%"></td>
						</tr>
					</thead>
					<tbody>
						<tr name="code_tr_1">
							<td><input style="width:140px" class="ld-input-inner" type="number" name="code_1" value="-1" placeholder="Status Code" /></td>
							<td><input style="width:480px" class="ld-input-inner" type="text" name="code_description_1" value="" placeholder="{'StatusDescription'|@getFixedLabel}" /></td>
							<td>
								<input type="hidden" name="code_tr_display_1" value="yes">
								<a class="icon-homeimg icon-sdel" style="cursor: pointer;margin-left: 20px;" name="api_tr_del" tag="code" tag_row="1" title="{'DELETE'|@getFixedLabel}"></a>
							</td>
						</tr>
					</tbody>
					<tfoot>
						<tr>
							<td>
								<a class="icon-homeimg icon-plus" style="cursor: pointer;margin-top: 3px;" name="api_tr_add" tag="code" tag_row="1" title="{'ADDITION'|@getFixedLabel}"></a>
							</td>
						</tr>
					</tfoot>
				</table>
			</td>
		</tr>
    </table>
</form>