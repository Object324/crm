{*@edit:liushuai,2021-04-28,reason:【ID1001572】增加【调查问卷】模块-第一版*}
<form name="menu" action="index.php" method="post" onSubmit="if(validate()) { puyoungJS_DialogBox.block();} else { return false; }">
	<input type="hidden" name="drag_handle_label" value="{'DragRows'|@getFixedLabel}"/>
	<input type="hidden" name="topic_id" value="{$TOPIC_ID}" />
	<input type="hidden" name="topic_json" value="{$TOPIC_JSON}" />
	<input type="hidden" name="rowindex" id="rowindex" value="{$ROWINDEX}" />
	<input type="hidden" name="blockid" id="blockid" value="{$BLOCKID}" />

	<div class="stepContent " name="step1" style="padding-right: 80px;">
		<table class="ld-createedit-tablecontent" border="0" cellpadding="0" cellspacing="0" width="100%">
			<tr class="ld-form-item">
				<td class="ld-form-item-label">{'Topictype'|@getFixedLabel}</td>
				<td class="ld-form-item-content">
					{if $STATUS=='create'}
						<select name="topic_type" class="ld-select-inner">
							<option value="one" {if $DATA['topic_type'] eq 'one'}selected{/if}>{'Multiplechoicequestions'|@getFixedLabel}</option>
							<option value="more" {if $DATA['topic_type'] eq 'more'}selected{/if}>{'Multipleschoicequestions'|@getFixedLabel}</option>
							<option value="Singleline" {if $DATA['topic_type'] eq 'Singleline'}selected{/if}>{'Singlelinetextquestion'|@getFixedLabel}</option>
							<option value="Multiline" {if $DATA['topic_type'] eq 'Multiline'}selected{/if}>{'Multilinetextquestions'|@getFixedLabel}</option>
							<option value="text" {if $DATA['topic_type'] eq 'text'}selected{/if}>{'Textdescription'|@getFixedLabel}</option>
							<option value="SelectBill" {if $DATA['topic_type'] eq 'SelectBill'}selected{/if}>{'SelectBill'|@getFixedLabel}</option>
							<option value="tel" {if $DATA['topic_type'] eq 'tel'}selected{/if}>{'Mobile'|@getFixedLabel}</option>
						</select>
					{else}
						<input name="topic_type" type="hidden" value="{$DATA['topic_type']}"/>
						<span name="topic_type_label" style="line-height: 32px;">
						{if $DATA['topic_type'] eq 'one'}
							{'Multiplechoicequestions'|@getFixedLabel}
						{elseif $DATA['topic_type'] eq 'more'}
							{'Multipleschoicequestions'|@getFixedLabel}
						{elseif $DATA['topic_type'] eq 'text'}
							{'Textdescription'|@getFixedLabel}
						{elseif $DATA['topic_type'] eq 'Singleline'}
							{'Singlelinetextquestion'|@getFixedLabel}
						{elseif $DATA['topic_type'] eq 'Multiline'}
							{'Multilinetextquestions'|@getFixedLabel}
						{elseif $DATA['topic_type'] eq 'SelectBill'}
							{'SelectBill'|@getFixedLabel}
						{elseif $DATA['topic_type'] eq 'tel'}
							{'Mobile'|@getFixedLabel}
						{/if}
						</span>
					{/if}

				</td>
			</tr>
			<tr class="ld-form-item" name="tr_topic_text" {if $DATA['topic_type'] neq 'text'}style="display:none;"{/if}>
				<td class="ld-form-item-label"><font color="red">*</font>{'CAMCARDCAPTION'|@getFixedLabel}</td>
				<td class="ld-form-item-content" align="left">
					<textarea id="text_textarea" name="text_textarea" label="{'CAMCARDCAPTION'|@getFixedLabel}" style="height:100px;margin-top:5px;margin-bottom:5px;">{$DATA['topic_name']}</textarea>
					{*					<input name="topic_name_text"   type="textarea" value="{$DATA['topic_name']}" class="detailedViewTextBox" label="{'CAMCARDCAPTION'|@getFixedLabel}" style="height:100px;margin-top:5px;margin-bottom:5px;"/>*}
				</td>
			</tr>
			<tr class="ld-form-item" name="tr_topic_name" {if $DATA['topic_type'] eq 'text'}style="display:none;"{/if}>
				<td class="ld-form-item-label"><font color="red">*</font>{'Topicname'|@getFixedLabel}</td>
				<td class="ld-form-item-content">
					<input name="topic_name" type="text" value="{$DATA['topic_name']}" label="{'Topicname'|@getFixedLabel}" class="ld-input-inner" />
				</td>
			</tr>
			<tr class="ld-form-item" name="tr_topic_referencemodule" {if $DATA['topic_type'] neq 'SelectBill'} style="display:none;"{/if}>
				<td  class="ld-form-item-label"><font color="red">*</font>{'RelateChoiceModule'|@getFixedLabel}</td>
				<td class="ld-form-item-content">
					<select class="ld-select-inner" name="topic_referencemodule" id="topic_referencemodule"  style="width: 180px;">
						{if $STATUS=='create'}
							{foreach key=key item=modulesinfo from=$CANSELECTMODULS}
								<option value="{$modulesinfo.name}">{$modulesinfo.label}</option>
							{/foreach}
						{else}
							<option value="{$DATA['referencemodule'].name}">{$DATA['referencemodule'].label}</option>
						{/if}
					</select>
				</td>
			</tr>
			<tr class="ld-form-item" name="tr_topic_referencemodule" {if $DATA['topic_type'] neq 'SelectBill'}style="display:none;"{/if}>
				<td class="ld-form-item-label"><font color="red">*</font>{'APPROVEDEMAND'|@getFixedLabel}</td>
				<td class="ld-form-item-content">
					<select class="ld-select-inner" name="topic_APPROVEDEMAND" id="topic_APPROVEDEMAND" style="width: 380px" >
						<option value="0" {if $DATA['topic_APPROVEDEMAND'] eq 0}selected{/if}>无</option>
						<option value="1" {if $DATA['topic_APPROVEDEMAND'] eq 1}selected{/if}>已批准</option>
					</select>
					<input type="hidden" id="topic_advance_demand" name="topic_advance_demand" value='{$DATA['topic_advance_demand']}'>
					<input type="hidden" id="topic_advance_demand_groups" name="topic_advance_demand_groups" value='{$DATA['topic_advance_demand_groups']}'>
					<a href="javascript:;" onclick="fun_other_conditions(this);" style="margin-left: 10px;line-height: 30px;">其他条件</a>
				</td>
			</tr>
			<tr class="ld-form-item" name="tr_topic_referencemodule" {if $DATA['topic_type'] neq 'SelectBill'}style="display:none;"{/if}>
				<td class="ld-form-item-label"><font color="red">*</font>{'MaxRowsShow'|@getFixedLabel}</td>
				<td class="ld-form-item-content">
					<select name="topic_MaxRowsShow" class="ld-select-inner" >
						<option value="5" {if $DATA['topic_MaxRowsShow'] eq 5}selected{/if}>5</option>
						<option value="10" {if $DATA['topic_MaxRowsShow'] eq 10}selected{/if}>10</option>
						<option value="15" {if $DATA['topic_MaxRowsShow'] eq 15}selected{/if}>15</option>
						<option value="20" {if $DATA['topic_MaxRowsShow'] eq 20}selected{/if}>20</option>
						<option value="50" {if $DATA['topic_MaxRowsShow'] eq 50}selected{/if}>50</option>
						<option value="100" {if $DATA['topic_MaxRowsShow'] eq 100}selected{/if}>100</option>
					</select>
				</td>
			</tr>
			<tr class="ld-form-item" name="tr_topic_fieldonly" {if $DATA['topic_type'] == 'SelectBill' || $DATA['topic_type'] == 'tel'}{else}style="display:none;"{/if}>
				<td class="ld-form-item-label">{'Allowed_to_repeat'|@getFixedLabel}</td>
				<td class="ld-form-item-content">
					<input name="topic_fieldonly" type="checkbox" class="second_switch" {if $DATA['topic_fieldonly'] eq 1}checked{else}{/if} value="0" />
				</td>
			</tr>
			<tr class="ld-form-item" name="tr_topic_description" {if $DATA['topic_type'] eq 'text'}style="display:none;"{/if}>
				<td class="ld-form-item-label">{'REMARK'|@getFixedLabel}</td>
				<td class="ld-form-item-content">
					<input name="topic_description" type="text" value="{$DATA['description']}" class="ld-input-inner"/>
				</td>
			</tr>
			<tr class="ld-form-item" name="tr_required" {if $DATA['topic_type'] eq 'text'}style="display: none;" {/if}>
				<td class="ld-form-item-label" >{'ACTIVITYMUSTFILL'|@getFixedLabel}</td>
				<td class="ld-form-item-content">
					{*					<input style="border:none;margin-top: -3px;" name="required" type="checkbox" {if $DATA['required'] eq 'yes'}checked{/if} value="0" />*}
					<input name="required" type="checkbox" class="second_switch" {if $DATA['required'] eq 'no'}{else}checked{/if} value="0" />
				</td>
			</tr>
			<tr class="ld-form-item" name="tr_telregexp" {if $DATA['topic_type'] neq 'tel'}style="display:none;"{/if}>
				<td class="ld-form-item-label">{'EnableRegExp'|@getFixedLabel}</td>
				<td class="ld-form-item-content">
					<input name="telregexp" type="checkbox" class="second_switch" {if $DATA['telregexp'] eq 'yes'}checked{else}{/if} value="0" />
				</td>
			</tr>
		</table>
		<table class="ld-createedit-tablecontent" {if $DATA['topic_type'] == 'text' || $DATA['topic_type'] == 'Singleline' || $DATA['topic_type'] == 'Multiline' || $DATA['topic_type'] == 'SelectBill' || $DATA['topic_type'] == 'tel'}style="display:none;"{/if} name="sortable" border="0" cellpadding="0" cellspacing="0" width="100%">
			{if $DATA_LEN gt 0}
				{*编辑*}
				{if $TOPIC_ID >0}
					{foreach key=key item=topic_content from=$DATA.topic_info}

						<tr class="ld-form-item dragtrrow" rowindex="{$key}">
							<td  class="ld-form-item-label" align="right">
								<span class="drag-handle icon-layout2 icon-layout2-move" title="{'DragRows'|@getFixedLabel}" style="cursor:move;"></span>
							</td>
							<td class="ld-form-item-content">
								<input name="topic_content" type="text" optionid="{$topic_content['optionid']}" value="{$topic_content['value']}" class="ld-input-inner" style="width: 430px;" />&nbsp;<a class="icon-homeimg icon-sdel" style="cursor: pointer;" name="del_question_tr" tag="{$key}" title="{'DELETE'|@getFixedLabel}"></a>
							</td>
						</tr>

					{/foreach}
					{*新建*}
				{else}
					{foreach key=key item=topic_content from=$DATA.topic_info}
						<tr class="ld-form-item dragtrrow" rowindex="{$key}">
							<td  class="ld-form-item-label" align="right">
								<span class="drag-handle icon-layout2 icon-layout2-move" title="{'DragRows'|@getFixedLabel}" style="cursor:move;"></span>
							</td>
							<td class="ld-form-item-content">
								<input name="topic_content" type="text" optionid="" value="{$topic_content}" class="ld-input-inner" style="width: 430px;" />&nbsp;<a class="icon-homeimg icon-sdel" style="cursor: pointer;" name="del_question_tr" tag="1" title="{'DELETE'|@getFixedLabel}"></a>
							</td>
						</tr>
					{/foreach}
				{/if}
			{else}
				<tr class="ld-form-item dragtrrow" rowindex="1">
					<td  class="ld-form-item-label" align="right">
						<span class="drag-handle icon-layout2 icon-layout2-move" title="{'DragRows'|@getFixedLabel}" style="cursor:move;"></span>
					</td>
					<td class="ld-form-item-content">
						<input name="topic_content" type="text" optionid="" value="" class="ld-input-inner" style="width: 430px"/>&nbsp;<a class="icon-homeimg icon-sdel" style="cursor: pointer;" name="del_question_tr" tag="1" title="{'DELETE'|@getFixedLabel}"></a>
					</td>
				</tr>
				<tr class="ld-form-item dragtrrow"  rowindex="2" >
					<td  class="ld-form-item-label" align="right">
						<span class="drag-handle icon-layout2 icon-layout2-move" title="{'DragRows'|@getFixedLabel}" style="cursor:move;"></span>
					</td>
					<td class="ld-form-item-content">
						<input name="topic_content" type="text" optionid="" value="" class="ld-input-inner" style="width: 430px"/>&nbsp;<a class="icon-homeimg icon-sdel" style="cursor: pointer;" name="del_question_tr" tag="2" title="{'DELETE'|@getFixedLabel}"></a>
					</td>
				</tr>
			{/if}
		</table>
		<table class="ld-createedit-tablecontent" {if $DATA['topic_type'] == 'text' || $DATA['topic_type'] == 'Singleline' || $DATA['topic_type'] == 'Multiline' || $DATA['topic_type'] == 'SelectBill' || $DATA['topic_type'] == 'tel'}style="display:none;"{/if} width="100%" name="add_question_table" cellspacing="0" cellpadding="0" border="0">
			<tbody>
			<tr class="ld-form-item">
				<td  class="ld-form-item-label"></td>
				<td class="ld-form-item-content">
					<a href="javascript:void(0);" name="add_question_tr">{'Newoptions'|@getFixedLabel}</a>
				</td>
			</tr>
			</tbody>
		</table>
	</div>
</form>
