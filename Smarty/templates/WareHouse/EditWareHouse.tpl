<div class="dvpopupsroll popupContent divPopOverflow">
    <form name="form" action="index.php" method="post" onSubmit="if(chkSubmit()) { puyoungJS_DialogBox.block();} else { return false; }" name="frmPotentialstShare">
        <input type="hidden" value="Settings" name="module"/>
        <input type="hidden" value="SaveWareHouse" name="action"/>
        <input type="hidden" value="{$MODE}" name="mode"/>
        <input type="hidden" value="{$RECORD}" name="record"/>
        <input type="hidden" value="" name="userid" id="userid"/>
        <table class="ld-public-content-small" border="0" cellpadding="0" cellspacing="0" width="100%">
          	<tr>
				<td class="ld-form-item-label"><font color="red">*</font>{'WAREHOUSENAME'|@getFixedLabel}</td>
				<td class="ld-form-item-content"><input id="wareHouseName" name="wareHouseName" type="text" value="{$WAREHOUSENAME}" class="ld-input-inner"/></td>
			</tr>
			<tr>
				<td class="ld-form-item-label">{'DESCRIPTION'|@getFixedLabel}</td>
				<td class="ld-form-item-content"><textarea name="description" class="ld-textarea-inner" style="height: 50px;margin: 5px 0;" />{$DESCRIPTION}</textarea> </td>
			</tr>
		    <tr>
                <td class="ld-form-item-label">
                    {'WAREHOUSEADMIN'|@getFixedLabel}
                </td>
                <td class="ld-form-item-content">
					 <input type="radio" {if $allocatetype eq 'all'}checked="" {/if} value="all" name="radioUser" onclick="CustomScope.setAllUser();" id="radioUser_all">
					  <label class="padR10" for="radioUser_all">{'ALLTHEUSERS'|@getFixedLabel}</label>
					  <input type="radio" {if $allocatetype eq 'group'}checked="" {/if} undefined="" onclick="CustomScope.setScopeGroup('{$UIDS}')" value="group" name="radioUser" id="radioUser_group">
					  <label class="padR10" for="radioUser_group">{'SETBYDEPARTMENT'|@getFixedLabel}</label>
					  <input type="radio" {if $allocatetype eq 'user'}checked="" {/if} undefined="" onclick="CustomScope.setScopeUser('{$UIDS}');" value="user" name="radioUser" id="radioUser_user">
					  <label class="padR10" for="radioUser_user">{'SETBYUSERS'|@getFixedLabel}</label>
					  <input type="radio" {if $allocatetype eq 'role'}checked="" {/if} undefined="" onclick="CustomScope.setScopeRole('{$UIDS}');" value="role" name="radioUser" id="radioUser_role">
					  <label class="padR10" for="radioUser_role">{'SetByRole'|@getFixedLabel}</label>
					  <input id="customscope_type" class="templateprintuser" type="hidden" value="{$allocatetype}" name="customscope_type">
					  <input id="customscope_ids" class="templateprintuser" type="hidden" value="{$UIDS}" name="customscope_ids">
                  
					<!--<input type="radio" name="radiouser" id="radiouser" value="Y" {$ALLUSER} style="margin-top: -2px;margin-right: 5px;">{'ALLTHEUSERS'|@getFixedLabel} 
                    <input type="radio" name="radiouser" id="radiouser" value="N" {$SELECTUSER} onclick="wareHouseselectUser()" style="margin-top: -2px;margin-right: 5px;margin-left: 10px;">{'SELECTTHEUSERS'|@getFixedLabel} 
                    <input type="hidden" value="{$UIDS}" name="owners" id="owners"/> -->
                </td>
            </tr>
            <tr>
				<td class="ld-form-item-label">
				</td>
                <td class="ld-form-item-content greyFont6">{'SELECTUSERWAREHOUSE'|@getFixedLabel}</td>
			</tr>
        </table>
    </form>
</div>