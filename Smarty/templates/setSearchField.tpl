<form name="selectall" method="POST">
	<input name="module" type="hidden" value="{$RETURN_MODULE}"/>
	<input name="action" type="hidden" value="{$RETURN_ACTION}"/>
	<input name="pmodule" type="hidden" value="{$MODULE}"/>
	<input type="hidden" name="curr_row" value="{$CURR_ROW}"/>	
	<input name="entityid" type="hidden" value=""/>
	<input name="popuptype" id="popup_type" type="hidden" value="{$POPUPTYPE}"/>
	<input name="idlist" type="hidden" value=""/>
	<input name="contactid" id="contactid" type="hidden" value=""/>
	<input name="accountid" id="accountid" type="hidden" value=""/>
	<input name="haveprojecet_account_num" id="haveprojecet_account_num" type="hidden" value="{$CLASSROOMACCOUNTALL}" />
	<input name="allprojecet_account_num" id="allprojecet_account_num" type="hidden" value="{$GETPROJECTGALLERYFUL}" />
	<input name="versionedu" id="versionedu" type="hidden" value="{$PROJECTSTATUS}" />
	<input type="hidden" id="fromlink" name="fromlink" value="{$FROMLINK}" />
	<input type="hidden" name="type" id="type" value="{$TYPE}">
		<div class="ld-pop-container ld-table-container ld-table-container-lines">
			<div class="divPopOverflow">
				<table class="" border="0" cellpadding="0" cellspacing="0" width="100%">
					<thead>
						<tr>
							<th width="25%">#</th>
							<th width="50%">{'FIELDNAME'|@getFixedLabel}</th>
							<th width="25%" style="text-align:center;">
								<input type="checkbox" name="select_all" value="" onClick=toggleSelect(this.checked,"popup_selected_id")>
							</th>
						</tr>
					</thead>
					<tbody>
					{foreach key=entity_id item=entity name=listentitys from=$SETFIELDLIST}
						<tr>
							<td>{$smarty.foreach.listentitys.iteration}</td>
							<td>{$entity.fieldlabel}</td>
							<td style="text-align:center;" width="20%" onclick="toggleSelectAll_parent_td(this)">
								{if $entity.columnname eq $Hreffieldname}
									<input type="checkbox" name="popup_selected_id" disabled checked value="{$entity_id}" onclick="toggleSelectAll(this.name,'select_all')"/>
								{else}
									<input type="checkbox" name="popup_selected_id" {if  $entity.searchfieldtype eq '0'}checked{/if} value="{$entity_id}" onclick="toggleSelectAll(this.name,'select_all')"/>
								{/if}
							</td>
						</tr>
					{foreachelse}
						<tr align="center">
							<td colspan="{$HEADERCOUNT}" align="center">
								{'NOTFOUNDANYRECORD'|@getFixedLabel}
							</td>
						</tr>
					{/foreach}
					</tbody>
				</table>
			</div>
		</div>
</form>