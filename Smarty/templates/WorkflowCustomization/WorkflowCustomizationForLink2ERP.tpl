<form action="index.php" method="post" name="workflow_actions" class="ajax_form">
	<input type="hidden" name="workflow_aciton_type" value="Link2ERP"/>
	<input type="hidden" name="workflow_actionsid" value="{$ACTION_DATA.workflow_actionid}" />
	<input type="hidden" name="workflow_id" value="{$WORDFLOW_ID}" />
	<input type="hidden" name="tabid" value="{$TABID}" />
	<input type="hidden" name="mode" value="save" />
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
				<font color="red">*</font>{'Link2ERPUrl'|@getFixedLabel}
            </td>
            <td class="ld-form-item-content">
                <input class="ld-input-inner" type="text" name="api_url" value="{$ACTION_DATA.api_url}" tag="{'Link2ERPUrl'|@getFixedLabel}" placeholder="{'FOREXAMPLE'|@getFixedLabel}http://192.168.1.42:88/link2erp"/>
            </td>
        </tr>
		<tr>
            <td class="ld-form-item-label">
				{'InputParameter'|@getFixedLabel}
            </td>
            <td class="ld-form-item-content">
                <table class="" border="0" name="post_table" id="post_table" cellpadding="0" cellspacing="0" width="100%">
					<input type="hidden" name="post_tr_cnt" value="2">
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
						<td class="padT16"><input class="ld-input-inner gwidth90" type="text" name="post_1" value="exch_key" placeholder="KEY" readonly/></td>
						<td class="padT16">
							<select class="ld-select-inner gwidth90 lfloat" name="post_type" tag_row="1" tag="post" id="" disabled >
								<option value="manual" aria-checked="true">{'MANUALINPUT'|@getFixedLabel}</option>
								<option value="module_fields">{'Docmodulefields'|@getFixedLabel}</option>
								<option value="system_fields">{'SystemVariables'|@getFixedLabel}</option>
							</select>
							<input type="hidden" name="post_parameter_type_1" value="manual">
						</td>
						<td class="padT16">
							<input class="ld-input-inner gwidth90" type="text" name="post_manual_1" value="1" placeholder="{'pleaseenter'|@getFixedLabel}" />
						</td>
						<td class="padT16"><input class="ld-input-inner gwidth90" type="text" name="post_description_1" value="连接ERP账套ID，非多账套时无需更改" placeholder="" readonly /></td>
						<td class="padT16">
							<input type="hidden" name="post_tr_display_1" value="yes">
						</td>
					</tr>
					<tr name="post_tr_2">
						<td class="padT16"><input class="ld-input-inner gwidth90" type="text" name="post_2" value="enterprise_account" placeholder="" readonly/></td>
						<td class="padT16">
							<select class="ld-select-inner gwidth90 lfloat" name="post_type" tag_row="1" tag="post" id="" disabled >
								<option value="manual" aria-checked="true">{'MANUALINPUT'|@getFixedLabel}</option>
								<option value="module_fields">{'Docmodulefields'|@getFixedLabel}</option>
								<option value="system_fields">{'SystemVariables'|@getFixedLabel}</option>
							</select>
							<input type="hidden" name="post_parameter_type_2" value="manual">
						</td>
						<td class="padT16">
							<input class="ld-input-inner gwidth90" type="text" name="post_manual_2" value="" placeholder="{'pleaseenter'|@getFixedLabel}" />
						</td>
						<td class="padT16"><input class="ld-input-inner gwidth90" type="text" name="post_description_2" value="连接erp地址为租赁必填" placeholder="" readonly /></td>
						<td class="padT16">
							<input type="hidden" name="post_tr_display_2" value="yes">
						</td>
					</tr>
					</tbody>
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
    </table>
</form>