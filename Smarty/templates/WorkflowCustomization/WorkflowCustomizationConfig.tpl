<form action="index.php" method="post" name="workflow" >
<input type="hidden" name='mode' value="save"/>
<input type="hidden" name="module" value="Settings"/>
<input type="hidden" name="action" value="WorkflowCustomizationConfig"/>
<div class="main_grid_box">
    <div class="grid-analysis-box">
        <div class="grid-analysis-header">
        </div>
        <div class="cont_wrap clear_float">
			<div class="TitleHeading">
				{'LBL_PARAMETER_SETTINGS'|@getFixedLabel}
			</div>
			<table width="100%" border="0" cellspacing="0" cellpadding="0" class="settingPopTable">
				<tr>
					<td width="20%" align="right"><font color="red">*</font>API URL</td>
					<td width="80%">
						<input type="hidden" id="apiurl" name="apiurl" value="{$DATA.api_url}" size="100" class="detailedViewTextBox gwidth50" placeholder="如：https://api.kingdee.com"/>{$DATA.api_url}
					</td>
				</tr>
				<input type="hidden" id="orgid" name="orgid" value="{$DATA.orgid}" size="100" class="detailedViewTextBox gwidth50" placeholder="如：734149182471" tag="{'APPLICATION'|@getFixedLabel}ID" />
				<tr>
					<td width="20%" align="right"><font color="red">*</font>client_id</td>
					<td width="80%">
						<input type="hidden" id="client_id" name="client_id" value="{$DATA.client_id}" size="100" class="detailedViewTextBox gwidth50" placeholder="如：734149182471"/>{$DATA.client_id}
					</td>
				</tr>
				<tr>
					<td width="20%" align="right"><font color="red">*</font>client_secret</td>
					<td width="80%">
						<input type="hidden" id="client_secret" name="client_secret" value="{$DATA.client_secret}" size="100" class="detailedViewTextBox gwidth50" placeholder="如：3e11524de5ef5432f4cc5ccd333679a7"/>{$DATA.client_secret}
					</td>
				</tr>
				<tr>
					<td width="20%" align="right"><font color="red">*</font>{'loginmobile'|@getFixedLabel}</td>
					<td width="80%">
						<input type="text" id="username" name="username" value="{$DATA.username}" size="100" class="detailedViewTextBox gwidth50" tag="{'loginmobile'|@getFixedLabel}"/>
					</td>
				</tr>
				<tr>
					<td width="20%" align="right"><font color="red">*</font>{'loginpassword'|@getFixedLabel}</td>
					<td width="80%">
						<input type="password" id="password" name="password" value="{$DATA.password}" size="100" class="detailedViewTextBox gwidth50" tag="{'loginpassword'|@getFixedLabel}"/>
					</td>
				</tr>
				<tr>
					<td width="20%" align="right"><font color="red">*</font>{'ZHANGTAOCHOOSE'|@getFixedLabel}</td>
					<td width="80%">
						<select name="erp_dbname" id="erp_dbname" onclick="WorkflowCustomization.getDBName()" style="width:250px; border-color: #d2d6de; margin-left: 5px;" tag="{'ZHANGTAOCHOOSE'|@getFixedLabel}">
							{if $DATA.dbname neq ''}
								<option value="{$DATA.dbname}">{$DATA.db_description}</option>
							{else}
								<option value="">{'NONE'|@getFixedLabel}</option>
							{/if}
						</select>
					</td>
				</tr>
				
			</table>
			<br/>

			
        </div>
    </div>
</div>
</form>