<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/PopupDrag.js?v={$GLOBALMINVERSION}"></script>
{if $FROM eq 'field'}
	<div class="divPopOverflow">
		<input type="hidden" id="field_id" name="field_id" value="{$FIELDID}" />
		<input type="hidden" id="frommodule" name="frommodule" value="{$FROMMODULE}" />
		<table class="ld-public-content-small" border="0" cellpadding="0" cellspacing="0" width="100%">
			<tr>
				<td class="ld-form-item-label">
					<font color="red">*</font>{'MPCRMFIELDS'|@getFixedLabel}
				</td>
				<td class="ld-form-item-content">
					<select onchange="SelfServiceConfig.changeMpField()" class="ld-select-inner" id="fieldname" name="fieldname" tag="{'LBL_FIELDNAME'|@getFixedLabel}">
						<option value="">--{'NONE'|@getFixedLabel}--</option>
						{* editor:gyq_74 date:20180730 reason:优化自助服务平台设置代码 *}
						{foreach key = number item = value from =$ALLFIELDS name=pname}
							<option show_type="{$value.show_type}" tabletype="{$value.tabletype}" value="{$value.fieldname}" {if $FIELDNAME eq $value.fieldname} selected {/if}>{$value.fieldlabel}</option>
						{/foreach}
					</select>
				</td>
			</tr>
			<tr>
				<td class="ld-form-item-label">
					<font color="red">*</font>{'CNTAG'|@getFixedLabel}
				</td>
				<td class="ld-form-item-content">
					<input id="fieldlabel" type="text" class="ld-input-inner" name="fieldlabel" value="{$FIELDLABEL}" />
				</td>
			</tr>
			<tr>
				<td class="ld-form-item-label">
					<font color="red">*</font>{'ENTAG'|@getFixedLabel}
				</td>
				<td class="ld-form-item-content">
					<input id="fieldlabel_en" type="text" class="ld-input-inner" name="fieldlabel_en" value="{$FIELDLABELEN}" />
				</td>
			</tr>
			<tr>
				<td class="ld-form-item-label">
					<font color="red">*</font>{'MPCREATEDISPLAY'|@getFixedLabel}
				</td>
				<td class="ld-form-item-content">
					<input name="displaytype" type="checkbox" class="second_switch" {if $DISPLAYTYPE eq 'all'}checked{/if}  {if $EDITABLE eq 'no'}disabled{/if} value="all"/>
				</td>
			</tr>
			<tr>
				<td class="ld-form-item-label">
					<font color="red">*</font>{'MPCREATEMFILLED'|@getFixedLabel}
				</td>
				<td class="ld-form-item-content">
                    <input name="typeofdata" type="checkbox" class="second_switch" {if $TYPEOFDATA eq 'm'}checked{/if} {if $EDITABLE eq 'no'}disabled{/if} value="m"/>
				</td>
			</tr>
			<tr>
				<td class="ld-form-item-label">
					{'MPCREATEDEFAULT'|@getFixedLabel}
				</td>
				<td class="ld-form-item-content">
					{if $UITYPE eq '53'}
						<input id="defaultvalue" hidden name="defaultvalue" value="{$DEFAULTVALUE}" />
						<input id="selectusername" type="text" readonly="true" value="{$DEFAULTVALUE|@getUserFullName}" class="ld-input-inner" style="width:100px"/>
						<a id="selectusername_click" class="icon-homeimg icon-select" href="javascript:;" onclick="SelfServiceConfig.set_choose_user('')"></a>
						{*editor:gyq_95 reason:微信自助平台小程序扫码绑定  2018/12/26 14:41	*}
						<a id="clearusername_click" onclick="SelfServiceConfig.clearusername()" class="icon-homeimg icon-clear inpb-reset" href="javascript:;"></a>
					{elseif $BIGTYPE eq 'picklist'}
						<select class="ld-select-inner" id="defaultvalue" name="defaultvalue">
							{foreach item=picklistvalue key=vkey from=$PickListValues}
								<option value="{$vkey}" {if $vkey eq $DEFAULTVALUE} selected {/if}>{$picklistvalue}</option>
							{/foreach}
						</select>
					{else}
						<input id="defaultvalue" type="text" class="ld-input-inner" name="defaultvalue" value="{$DEFAULTVALUE}" />
					{/if}
				</td>
			</tr>
		</table>
	</div>
{elseif $FROM eq 'listfield'}
	<div class="divPopOverflow">
		<input type="hidden" id="listfield_id" name="listfield_id" value="{$LISTFIELDID}" />
		<input type="hidden" id="frommodule" name="frommodule" value="{$FROMMODULE}" />
		<table class="ld-public-content-small" border="0" cellpadding="0" cellspacing="0" width="100%">
			<tr>
				<td class="ld-form-item-label">
					<font color="red">*</font>{'linenumber'|@getFixedLabel}
				</td>
				<td class="ld-form-item-content">
					<select class="ld-select-inner" id="linenumber" name="linenumber">
						<option value="1" {if $LINENUMBER eq 1}selected{/if}>1</option>
						<option value="2" {if $LINENUMBER eq 2}selected{/if}>2</option>
						<option value="3" {if $LINENUMBER eq 3}selected{/if}>3</option>
						<option value="4" {if $LINENUMBER eq 4}selected{/if}>4</option>
						<option value="5" {if $LINENUMBER eq 5}selected{/if}>5</option>
					</select>
				</td>
			</tr>
			<tr>
				<td class="ld-form-item-label">
					<font color="red">*</font>{'rownumber'|@getFixedLabel}
				</td>
				<td class="ld-form-item-content">
					<select class="ld-select-inner" id="rownumber" name="rownumber">
						<option value="1" {if $ROWNUMBER eq 1}selected{/if}>1</option>
						<option value="2" {if $ROWNUMBER eq 2}selected{/if}>2</option>
						<option value="3" {if $ROWNUMBER eq 3}selected{/if}>3</option>
					</select>
				</td>
			</tr>
			<tr>
				<td class="ld-form-item-label">
					<font color="red">*</font>{'LBL_FIELDNAME'|@getFixedLabel}
				</td>
				<td class="ld-form-item-content">
					<select class="ld-select-inner" id="fieldname" name="fieldname" tag="{'LBL_FIELDNAME'|@getFixedLabel}">
						<option value="">--{'NONE'|@getFixedLabel}--</option>
						{foreach key = number item = value from =$ALLFIELDS name=pname}
							<option value="{$value.fieldname}" {if $FIELDNAME eq $value.fieldname} selected {/if}>{$value.fieldlabel}</option>
						{/foreach}
					</select>
				</td>
			</tr>
			<tr>
				<td class="ld-form-item-label">
					<font color="red">*</font>{'WHETHERTODISPLAY'|@getFixedLabel}
				</td>
				<td class="ld-form-item-content">
                    <input id="presence" name="presence" {if $PRESENCE neq 1}checked{/if} type="checkbox" class="second_switch" value="0" />
				</td>
			</tr>
			<tr>
				<td class="ld-form-item-label">
					<font color="red">*</font>{'MOBILELISTSHOWFIELDNAME'|@getFixedLabel}
				</td>
				<td class="ld-form-item-content">
                    <input id="showtag" name="showtag" {if $SHOWTAG neq '1'}checked{/if} type="checkbox" class="second_switch" value="0" />
				</td>
			</tr>
		</table>
	</div>
{elseif $FROM eq 'module'}
	<div class="D_pop_box LdPopWidth600px" style="position: fixed; z-index: 9999; top: 50%; left: 50%; display: block; margin-top: -147.5px; margin-left: -202px;">
		<div class="D_pop_tit">
			<strong id="createworktpldivtitlename" class="D_ptita">{'MPMODULESET'|@getFixedLabel}</strong>
			<button id="cancel_selfconfig_module" class="E_ptitc" value="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"></button>
		</div>
		<table class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
			<tr>
				<th class="cellLabel borderLBR" align="left">{'MPMODULESET'|@getFixedLabel}</th>
				<th class="cellLabel borderLBR" align="left">{'MPSELFCONFIGPLAT'|@getFixedLabel}</th>
				<th class="cellLabel borderLBR" align="left">{'WHETHERTOENABLE'|@getFixedLabel}</th>
				<th class="cellLabel borderLBR" align="left">{'OPERATING'|@getFixedLabel}</th>
			</tr>
			{foreach item = value from =$ENTITY name=pname}
				<tr tag="module">
					<td>{$value.crmmodulelabel}</td>
					<td><input type="text" tag="mplabel" name="{$value.id}" value="{$value.mplabel}"/></td>
					<td>{if $value.presence eq 0}{'YES'|@getFixedLabel}{else}{'NO'|@getFixedLabel}{/if}</td>
					<td>
						<a class="icon-category category-sup marR8" style="cursor: pointer;" onclick="SelfServiceConfig.set_moveupmodule(this,'up')" title="{'MOVEUP'|@getFixedLabel}"></a>
						<a class="icon-category category-sdown marR8" style="cursor: pointer;" onclick="SelfServiceConfig.set_moveupmodule(this,'down')" title="{'MOVEDOWN'|@getFixedLabel}"></a>
						<a class="Anu3_a" onclick="SelfServiceConfig.set_ActiveOrInactive({$value.id},this)">{if $value.presence eq 0}{'INACTIVATE'|@getFixedLabel}{else}{'ACTIVATE'|@getFixedLabel}{/if}</a>
					</td>
				</tr>
			{/foreach}
		</table>
		<div class="E_pbtn">
			<input class="E_pbtnok" value="{'CONFIRMED'|@getFixedLabel}" type="button" id="save_selfconfig_module">
			<span> </span>
			<input class="E_pbtncancel" value="{'CANCEL'|@getFixedLabel}" type="button" id="cancel_selfconfig_module">
		</div>
	</div>
{/if}