<div id="delgroupcontent">
	<table class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
		<tbody>
			<tr>
				<td  class="ld-form-item-label">
					{'TODELETEGROUP'|@getFixedLabel}
				</td>
				<td class="ld-form-item-content">
					<span name='delete_groupname'>{$GROUPNAME}</span>
					<input type="hidden" name='delgroupid' value='{$GROUPID}'/>
				</td>
			</tr>
			<tr>
				<td  class="ld-form-item-label">
					{'LBL_USERTOTRANSFER'|@getFixedLabel}
				</td>
				<td class="ld-form-item-content">
					<input type="text" class="ld-input-inner-div ld-input-inner-add" name='delusertogroup_name'/>
					<input type="hidden" name='delusertogroup' value=''/>
					<input type="hidden" name='olddelusertogroup' value=''/>
					<a class="ld-text-select" href="javascript:;" tag='delusertogroup' onclick="selectGroup('delusertogroup');" title="{'SELECT'|@getFixedLabel}">+</a>
					<a class="ld-text-clear" href="javascript:;" tag='cleardelusertogroup' title="{'CLEAR'|@getFixedLabel}">+</a>
				</td>
			</tr>
			<tr id='dellowertogroupTr' {if $HAVECHILD neq 'yes' && 1==2} style="display:none"{/if}>
				<td  class="ld-form-item-label">
					{'LBL_GROUPOTRANSFER'|@getFixedLabel}
				</td>
				<td class="ld-form-item-content">
					<input type="text" class="ld-input-inner-div ld-input-inner-add" name='dellowertogroup_name'/>
					<input type="hidden" name='dellowertogroup' value=''/>
					<input type="hidden" name='olddellowertogroup' value=''/>
					<a class="ld-text-select" href="javascript:;" tag='dellowertogroup'  onclick="selectGroup('dellowertogroup');" title="{'SELECT'|@getFixedLabel}">+</a>
					<a class="ld-text-clear" href="javascript:;" tag='cleardellowertogroup'  title="{'CLEAR'|@getFixedLabel}">+</a>
				</td>
			</tr>
		</tbody>
	</table>
</div>
