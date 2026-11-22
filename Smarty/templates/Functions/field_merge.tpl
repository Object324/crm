{if $EDIT_DUPLICATE eq 'permitted'}
	<div class="ld-description">
		<b class="info-icon"></b>
		<div class="ld-description-content">
			{if $mergetype && $mergetype eq 'bigmerge'}
				{'PRIMARRECORDMERGE2'|@getFixedLabel}
			{else}
				{'PRIMARRECORDMERGE'|@getFixedLabel}
			{/if}
		</div>
	</div>
	{if $mergetype && $mergetype neq ''}
		<div class="ld-pop-container padB0 ld-pop-container-mergetype">
			<input type="checkbox" id="add_teammember" class="second_switch" {$AddTeamMemberChecked}>
			<span>{'AfterMergeAddToTeamMember'|@getFixedLabel}</span>
		</div>
	{/if}
	<div id="ld-pop-container-MergeTableDiv" class="ld-pop-container">
	<div id="MergeTableDiv" class="ld-table-container ld-table-container-lines ld-table-container-bgcolor" style="overflow-y: auto;width: 100%;">
		{*<form name="merge_form" method="POST" action="index.php" id="merge_form" >*}
		<form name="merge_fields_form" method="POST" action="index.php" id="merge_fields_form" >
			<input type=hidden name="module" value="{$MODULENAME}">
			<input type=hidden name="return_module" value="{$MODULENAME}">
				{*editor:gyq_170 reason:自动查重合并返回值修改  2020/3/9 15:44 *}
			<input type="hidden" name="action" value="{$MODULENAME}Ajax">
			<input type="hidden" name="file" value="field_merge">
			<input type="hidden" name="mergemode" value="mergesave">
			<input type="hidden" name="parent" value="{$PARENT_TAB}">
			<input type="hidden" name="pass_rec" value="{$IDSTRING}">
			<input type="hidden" name="return_action" value="FindDuplicateRecords">
			{*editor:gyq_72  date:20180710	0034508: 客户、联系人、服务收费管理列表界面>更多>自动查重合并>选择字段查重>勾选单据合并：合并单据后应该回到查重界面而不是跳转到单据列表界面去。*}
			<input type="hidden" name="second_action" value="{$SECOND_ACTION}">

			{* 目前只有客户模块的合并有mergetype（自动查重合并也走else） ，XUQIU20240709-01 【日置】客户合并功能优化 *}
			{if $mergetype && $mergetype neq ''}
				{* 客户10-100条合并 *}
				{if $mergetype eq 'bigmerge'}
					<table class="" id="MergeTable" border="0" cellpadding="0" cellspacing="0" width="100%">
						<thead>
							<th width="275px">{'LISTFIELDS'|@getFixedLabel}</th>
							<th>{'SELECTPRIMARYRECORD'|@getFixedLabel}</th>
							<th width="100px">操作</th>
						</thead>
						<tbody>
						{foreach item=fieldinfo key=fieldname from=$ALLVALUES}
							<tr>
								<td class="ld-form-item-label">{$fieldinfo.label}</td>
								<td class="ld-form-item-content" name="content_{$fieldname}" style="">
									{* 可多选字段 和 富文本框 *}
									{if $fieldinfo.multichoose eq 'yes' || $fieldinfo.bigtype eq 'richtext'}
										{if $fieldinfo.bigtype neq 'fileattachment'}
											<div class="ld-input-inner-div ld-input-inner-add" id="multichoosevalue" name="multichoosevalue_{$fieldname}" style="width:100%;overflow: hidden;" value='{$fieldinfo.selected_value}'>{$fieldinfo.selected_text}</div>
											<a class="ld-text-select" name="transfervalue" data-fieldname="{$fieldname}" data-title="{$fieldinfo.label}" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick="">+</a>
											<a class="ld-text-clear" name="clearvalue" data-fieldname="{$fieldname}" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" >+</a>
										{else}
											<div class="ld-text-inner" id="multichoosevalue" name="multichoosevalue_{$fieldname}" style="width:100%;overflow: hidden;" value='{$fieldinfo.selected_value}'>{$fieldinfo.selected_text}</div>
										{/if}
									{else}
										<select class="ld-select-inner" id="selectvalue" name="selectvalue_{$fieldname}" data-fieldname="{$fieldname}">
											{foreach item=fld_value key=index from=$fieldinfo.value}
												{if $fieldinfo.selected_value neq '' && $fld_value.value|string_format:"%s" eq $fieldinfo.selected_value|string_format:"%s"}
													<option {if $fieldinfo.allowduplicate eq 'yes'}value="{$fld_value.value}_{$fld_value.recordid}" data-recordid="{$fld_value.recordid}" allowduplicate="{$fieldinfo.allowduplicate}"{else}value="{$fld_value.value}"{/if} selected>{$fld_value.text}</option>
												{else}
													<option {if $fieldinfo.allowduplicate eq 'yes'}value="{$fld_value.value}_{$fld_value.recordid}" data-recordid="{$fld_value.recordid}" allowduplicate="{$fieldinfo.allowduplicate}"{else}value="{$fld_value.value}"{/if}>{$fld_value.text}</option>
												{/if}
											{/foreach}
										</select>
									{/if}
									{if $fieldinfo.edit eq 'yes'}
										<div data-id="{$fieldname}" data-name="merge_editarea" style="display: none;">
											{* 小编辑 *}
											<input name='{$fieldname}_name' fieldname="{$fieldname}" value="{$fieldinfo.selected_value}" class="ld-input-inner"
												{if $fieldinfo.businessfuzzyquery eq 'yes'}
													onkeyup="getTianyanByKeyWord(this,1,'{$MODULENAME}',event)" onkeypress="userEnterKey(getTianyanByKeyWord,[this,1,'{$MODULENAME}',event],event)"
												{/if}
											>
											{* 工商查询 *}
											{if $fieldinfo.businessquery eq 'yes'}
												<i id="business_{$fieldname}" title="{'business'|@getFixedLabel}{'QUERYTO'|@getFixedLabel}" class="ld-fonticon ld-fonticon-gongshang" onclick="getTianyanByKeyWordForInfo('{$fieldname}','dtlview');"></i>
												{* 模糊查询 *}
												<div name="check_kewords" class="SearchResult" style="z-index:1100;max-height:220px;overflow:auto;"></div>
											{/if}
										</div>
									{/if}
								</td>
								<td data-fieldname="{$fieldname}" style="width: var(--ld-edit-padding);">
									{if $fieldinfo.edit eq 'yes'}
										<span data-id="{$fieldname}" data-name="merge_editbtn" class="" style="width: 30px;display: ;margin-left: 20px;" >
											<a align="right" href="javascript:;">{'EDIT'|@getFixedLabel}</a>
										</span>
										<div data-id="{$fieldname}" data-name="merge_editsave" style="display: none;line-height: 36px;">
											<a href="javascript:;" name="savebtn" onclick="">{'SAVE'|@getFixedLabel}</a>
											{'OR'|@getFixedLabel}
											<a href="javascript:;" name="cancelbtn" onclick="">{'CANCEL'|@getFixedLabel}</a>
										</div>
									{/if}
								</td>
							</tr>
						{/foreach}
						</tbody>
					</table>
				{* 客户10条及以内合并 *}
				{else}
					<table class="" id="MergeTable" border="0" cellpadding="0" cellspacing="0" width="100%">
						<thead>
						<tr>
							<th class="locking-left" style="width: 276px;">{'LISTFIELDS'|@getFixedLabel}</th>
							{assign var=count value=1}
							{assign var=cnt_rec value=0}
							{if $NO_EXISTING eq 1}
								{foreach key=cnt item=record from=$ID_ARRAY}
									<th style="width: 272px;">
										<div style="display: flex;align-items: center;">
											<input class="marR8" name="record" value="{$record}" onclick="select_All('{$JS_ARRAY}','{$cnt}','{$MODULENAME}');" type="radio" {if $count eq 1} checked {/if} > <span style="font-size:12px">{'SELECTPRIMARYRECORD'|@getFixedLabel}(#{$count})</span>
										</div>
									</th>
									{assign var=cnt_rec value=$cnt_rec+1}
									{assign var=count value=$count+1}
								{/foreach}
							{else}
								{foreach key=cnt item=record from=$ID_ARRAY}
									<th style="width: 272px;">
									{assign var=found value=0}
									{foreach item=child key=k from=$IMPORTED_RECORDS}
										{if $record eq $child}
											{assign var=found value=1}
										{/if}
									{/foreach}
									{if $found eq 0}
										<div style="display: flex;align-items: center;">
											<input class="marR8" name="record" value="{$record}" onclick="select_All('{$JS_ARRAY}','{$cnt}','{$MODULENAME}');" type="radio" {if $count eq 1} checked {/if} > <span style="font-size:12px">{'SELECTPRIMARYRECORD'|@getFixedLabel}(#{$count})</span>
										</div>
									{/if}
									</th>
									{assign var=cnt_rec value=$cnt_rec+1}
									{assign var=count value=$count+1}
								{/foreach}
							{/if}
						</tr>
						</thead>
						<tbody>
						{assign var=i value=1}
						{foreach item=data key=cnt from=$ALLVALUES}
							{foreach item=fld_array key=label from=$data}
							{assign var="j" value=$i++}
								<tr>
									<td class="locking-left">{$label}{$test}</td>
									{foreach item=fld_value key=cnt2 from=$fld_array}
										{if $fld_value.disp_value neq ''}
											<td style="white-space: inherit;" data-fieldname="{$FIELD_ARRAY[$cnt]}" {if $fld_value.edit eq 'yes'}data-edit="yes"{/if}>
												<div class="ld-wordwrap-listcontent bindtip" style="display: flex;align-items: center;">
													{* edit:can 42180: (https://61mis.com/KH/kh38230/ [^])客户模块>序时簿界面：“自动查重合并”界面，“销售负责人”显示为空 *}
													{if $fld_value.multichoose eq 'yes'}
														<input class="marR8" name='{$FIELD_ARRAY[$cnt]}' value='{$fld_value.org_value}' type="checkbox" onclick="CrmPopup.getPopupObj('last').listmerge_obj.multiChooseValue(this)"
															{if $fld_value.selected eq 'yes' && $fld_value.bigtype neq 'fileattachment'} checked {/if} {if $fld_value.bigtype eq 'fileattachment' } checked disabled {/if}
														/>
													{else}
														<input class="marR8" name='{$FIELD_ARRAY[$cnt]}' value='{$fld_value.org_value}' type="radio" onclick="CrmPopup.getPopupObj('last').listmerge_obj.chooseValue(this)" {if $fld_value.selected eq 'yes'} checked {/if} />
													{/if}
													<span data-id="{$FIELD_ARRAY[$cnt]}_{$cnt2}" data-name="merge_displayvalue" style="width: 70%;word-break: break-all;" class="lineheight16">{$fld_value.disp_value}</span>
													{if $fld_value.edit eq 'yes'}
														<div data-id="{$FIELD_ARRAY[$cnt]}_{$cnt2}" data-name="merge_editarea" style="display: none;">
															{* 小编辑 *}
															<input name='{$FIELD_ARRAY[$cnt]}_name' fieldname="{$FIELD_ARRAY[$cnt]}" value="{$fld_value.org_value}" class="ld-input-inner marT5"
																{if $fld_value.businessfuzzyquery eq 'yes'}
																	onkeyup="CrmPopup.getPopupObj('last').listmerge_obj.getTianyanByKeyWord(this,1,'{$MODULENAME}',event)" onkeypress="userEnterKey(CrmPopup.getPopupObj('last').listmerge_obj.getTianyanByKeyWord,[this,1,'{$MODULENAME}',event],event)"
																{/if}
															>
															{* 工商查询 *}
															{if $fld_value.businessquery eq 'yes'}
																<i id="business_{$FIELD_ARRAY[$cnt]}" title="{'business'|@getFixedLabel}{'QUERYTO'|@getFixedLabel}" class="ld-fonticon ld-fonticon-gongshang" onclick="getTianyanByKeyWordForInfo('{$FIELD_ARRAY[$cnt]}','dtlview');"></i>
																{* 模糊查询 *}
																<div name="check_kewords" class="SearchResult" style="z-index:1100;max-height:220px;min-width:300px;overflow:auto;"></div>
															{/if}
														</div>
														<span data-id="{$FIELD_ARRAY[$cnt]}_{$cnt2}" data-name="merge_editbtn" class="" style="width: 30px;display: none;margin-left: 20px;" >
															<a align="right" href="javascript:;">{'EDIT'|@getFixedLabel}</a>
														</span>
													{/if}
												</div>
												{if $fld_value.edit eq 'yes'}
													<div data-id="{$FIELD_ARRAY[$cnt]}_{$cnt2}" data-name="merge_editsave" style="display: none;line-height: 36px;padding-left: 30px;">
														<a href="javascript:;" name="savebtn" onclick="">{'SAVE'|@getFixedLabel}</a>
														{'OR'|@getFixedLabel}
														<a href="javascript:;" name="cancelbtn" onclick="">{'CANCEL'|@getFixedLabel}</a>
													</div>
												{/if}
											</td>
										{else}
											<td>
												<div style="display: flex;align-items: center;">
													{if $fld_value.multichoose eq 'yes'}
														<input class="marR8" name='{$FIELD_ARRAY[$cnt]}' value='' type="checkbox" onclick="CrmPopup.getPopupObj('last').listmerge_obj.multiChooseValue(this)" {if $fld_value.selected eq 'yes' && $fld_value.bigtype neq 'fileattachment'} checked {/if} {if $fld_value.bigtype eq 'fileattachment' } checked disabled {/if}
														/>
													{else}
														<input class="marR8" name='{$FIELD_ARRAY[$cnt]}' value='' type="radio" onclick="CrmPopup.getPopupObj('last').listmerge_obj.chooseValue(this)" {if $fld_value.selected eq 'yes'} checked {/if} />
													{/if}
													<span>--{'NONE'|@getFixedLabel}--</span>
												</div>
											</td>
										{/if}
									{/foreach}
								</tr>
							{/foreach}
						{/foreach}
						</tbody>
					</table>
				{/if}
			{else}
				<table class="" border="0" cellpadding="0" cellspacing="0" width="100%">
					<thead>
					<tr>
						<th class="locking-left" style="width: 276px;">{'LISTFIELDS'|@getFixedLabel}</th>
						{assign var=count value=1}
						{assign var=cnt_rec value=0}
						{if $NO_EXISTING eq 1}
							{foreach key=cnt item=record from=$ID_ARRAY}
								<th style="width: 272px;">
									<div style="display: flex;align-items: center;">
										<input class="marR8" name="record" value="{$record}" onclick="select_All('{$JS_ARRAY}','{$cnt}','{$MODULENAME}');" type="radio" {if $count eq 1} checked {/if} > <span style="font-size:12px">{'SELECTPRIMARYRECORD'|@getFixedLabel}(#{$count})</span>
									</div>
								</th>
								{assign var=cnt_rec value=$cnt_rec+1}
								{assign var=count value=$count+1}
							{/foreach}
						{else}
							{foreach key=cnt item=record from=$ID_ARRAY}
								<th style="width: 272px;">
								{assign var=found value=0}
								{foreach item=child key=k from=$IMPORTED_RECORDS}
									{if $record eq $child}
										{assign var=found value=1}
									{/if}
								{/foreach}
								{if $found eq 0}
									<div style="display: flex;align-items: center;">
										<input class="marR8" name="record" value="{$record}" onclick="select_All('{$JS_ARRAY}','{$cnt}','{$MODULENAME}');" type="radio" {if $count eq 1} checked {/if} > <span style="font-size:12px">{'SELECTPRIMARYRECORD'|@getFixedLabel}(#{$count})</span>
									</div>
								{/if}
								</th>
								{assign var=cnt_rec value=$cnt_rec+1}
								{assign var=count value=$count+1}
							{/foreach}
						{/if}
					</tr>
					</thead>
					<tbody>
					{assign var=i value=1}
					{foreach item=data key=cnt from=$ALLVALUES}
					{foreach item=fld_array key=label from=$data}
					{assign var="j" value=$i++}
						<tr>
							<td class="locking-left">{$label}{$test}</td>
							{foreach item=fld_value key=cnt2 from=$fld_array}
								{if $fld_value.disp_value neq ''}
									{if $fld_value.selected eq 'yes'}
									<!--edit:can 42180: (https://61mis.com/KH/kh38230/ [^])客户模块>序时簿界面：“自动查重合并”界面，“销售负责人”显示为空-->
										<td style="white-space: inherit;"><input class="marR8" name='{$FIELD_ARRAY[$cnt]}' value='{$fld_value.org_value}' type="radio" checked />{$fld_value.disp_value}</td>
									{else}
										<td style="white-space: inherit;"><input class="marR8" name='{$FIELD_ARRAY[$cnt]}' value='{$fld_value.org_value}' type="radio" />{$fld_value.disp_value}</td>
									{/if}
								{else}
									{if $fld_value.selected eq 'yes'}
										<td><input class="marR8" name='{$FIELD_ARRAY[$cnt]}' value='' type="radio" checked/>--{'NONE'|@getFixedLabel}--</td>
									{else}
										<td><input class="marR8" name='{$FIELD_ARRAY[$cnt]}' value='' type="radio"/>--{'NONE'|@getFixedLabel}--</td>
									{/if}
								{/if}
							{/foreach}
						</tr>
					{/foreach}
					{/foreach}
					</tbody>
				</table>
			{/if}
		</form>
	</div>
	</div>
{else}
	<div id="null_remindercontent" class="pop_remind_content" style="max-height: 400px;border: none;">
		<div class="qui_dialog_body ld-dialog-Boxbody" style="max-height:400px;overflow:auto;background-color: #fff;">
			<div class="ld-msgDlg-Boxtop">
				<div class="ld-commonImg ld-commonImg-BoxAlert ld-msgDlg-top-icon"></div>
			</div>
			<div class="ld-msgDlg-Boxbottom">
				<div class="ld-msgDlg-bottom-Boxtext linefeed" style="font-size:15px;padding-left: 0px;">
					{'NOPERMITTEDEXECUTE'|@getFixedLabel}
				</div>
			</div>
		</div>
	</div>
{/if}