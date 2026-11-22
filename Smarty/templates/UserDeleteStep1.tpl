<div id="DeleteLay" class="E_pop_box LdPopWidth450px">
	<form name="newProfileForm" style="margin:0">
		<input type="hidden" name="module" value="Users">
		<input type="hidden" name="action" value="DeleteUser">
		<input type="hidden" name="delete_user_id" value="{$delete_user_id}">
		<input type="hidden" name="blockidsetting" value="{$blockidsetting}"/>
		<input type="hidden" name="fieldidsetting" value="{$fieldidsetting}"/>
		<table class="ld-public-content-paddingright padTB10" border="0" cellpadding="0" cellspacing="0" width="100%">
		    <tr>
		        <td class="ld-form-item-label">{'To_delete_a_user'|@getFixedLabel}</td>
		        <td class="ld-form-item-content">{$delete_user_name}</td>
		    </tr>
		    <tr>
		        <td class="ld-form-item-label">{'Conversion_charge_to_the_user'|@getFixedLabel}</td>
		        <td class="ld-form-item-content" style="overflow: inherit;">
					{assign var='fldname' value='UserDelete'}
					{assign var='DISPLAYVALUE' value=''}
					{assign var='fldname_width' value='190'}
					<div class="row-fluid" id="dv_cmb_{$fldname}">
						<span class="span10">
		                    <input type="hidden" id="{$fldname}" name="{$fldname}" value="1"/>
						</span>
					</div>
		 		</td>
			</tr>
		</table>
	</form>
</div>