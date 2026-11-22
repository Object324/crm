<div id="addgroupcontent">
	<table class="ld-public-content-paddingright padTB10" border="0" cellpadding="0" cellspacing="0" width="100%">
		<tbody>
			<tr>
				<td class="ld-form-item-label">
					<font color="red">*</font>{'GROUPNAME'|@getFixedLabel}
				</td>
				<td class="ld-form-item-content">
					<input type="text" name='groupname' value="{$GROUPNAME}" class="ld-input-inner" />
					<input type="hidden" name='groupid' value='{$RECORD}'/>
				</td>
			</tr>
			<tr {if $ISDEPARTMENTNUMBER eq 'no'}style="display:none"{/if}>
				{*230420 wyt XUQIU1001296 部门增加：部门编号*}
				{*zsk2024/5/28XUQIU1001465 成员管理，组织架构->根部门，更多下拉选项中增加“字段设置”参数*}
				<td class="ld-form-item-label">
					<font color="red">*</font>{'GROUPNO'|@getFixedLabel}
				</td>
				<td class="ld-form-item-content">
					<input type="text" name='groupno' value="{$GROUPNO}" class="ld-input-inner" />
					{*<input type="hidden" name='groupid' value='{$RECORD}'/>*}
				</td>
			</tr>
			<tr {if $PARENTID<=0} style="display:none"{/if}>
				<td class="ld-form-item-label">
					{if $RECORD >0&&$RECORD!=""}<font color="red">*</font>{/if}{'LBL_SUPEGROUP'|@getFixedLabel}
				</td>
				<td class="ld-form-item-content">
					<div id="groupParent" class="ld-input-inner-div ld-input-inner-add" name='parentid_name' readonly='' >{$PARENTNAME}</div>
					<input type="hidden" name='oldparentid' value='{$PARENTID}'/>
					<input type="hidden" name='parentid' value='{$PARENTID}'/>
					{if $RECORD >1}
						<a class="ld-text-select" href="javascript:;" onclick="selectGroup('parentid')" tag='selectgroup' title="{'SELECT'|@getFixedLabel}">+</a>
						<a class="ld-text-clear" href="javascript:;" tag='clearselectgroup' title="{'CLEAR'|@getFixedLabel}">+</a>
					{/if}
				</td>
			</tr>
			<tr {if $PARENTID<=0} style="display:none"{/if} {if $ISDEPARTMENTNUMBER eq 'no'}style="display:none"{/if}>
				{*新增部门编号*}
				{*zsk2024/5/28XUQIU1001465 成员管理，组织架构->根部门，更多下拉选项中增加“字段设置”参数*}
				<td class="ld-form-item-label">
					{if $RECORD >0&&$RECORD!=""}<font color="red">*</font>{/if}{'LBL_SUPEGROUPNO'|@getFixedLabel}
				</td>
				<td class="ld-form-item-content">
					<div id="groupParent" style="display:block;">
						<input type="text" class="ld-input-inner" value="{$PARENTGROUPNO}" name='parentid_no' readonly='' />
					</div>
				</td>
			</tr>
			<tr {if $group_type == 'prm' && $DEPTH > 0}{else}style="display:none"{/if}>

				<td class="ld-form-item-label">
					{'ASSOCIATEDCUSTOMERS'|@getFixedLabel}
				</td>
				<td class="ld-form-item-content">
					<div id="related_crmid_name" class="ld-input-inner-div ld-input-inner-add" name='related_crmid_name' readonly='' >{$related_crmid_name}</div>
					<input type="hidden" id="related_crmid" name='related_crmid' value='{$related_crmid}'/>
						<a class="ld-text-select" href="javascript:;" onclick="Op_UserGroup.groupRelatedAccount();" tag='selectrelated' title="{'SELECT'|@getFixedLabel}">+</a>
						<a class="ld-text-clear" href="javascript:;" tag='clearselectrelated' title="{'CLEAR'|@getFixedLabel}">+</a>
				</td>
			</tr>
			{if $ISDEPARTMENTREMARK neq 'no'}
				<tr>
					<td class="ld-form-item-label">
						{'DESCRIPTION'|@getFixedLabel}
					</td>
					<td class="ld-form-item-content">
						<textarea class="ld-textarea-inner" name='description'>{$DESCRIPTION}</textarea>
					</td>
				</tr>
			{/if}
		</tbody>
	</table>
</div>