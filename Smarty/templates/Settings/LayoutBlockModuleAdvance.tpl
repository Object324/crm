<input type="hidden" value="{$FROMMODULE}" name="frommodule" />
<table border="0" cellspacing="0" cellpadding="0" width="80%" class="DetailContentTable linefeed">
	<tbody><tr>
		<td colspan="4" class="editrelhead">
			<b>{"BASICINFO"|@getFixedLabel}</b>
		</td>
	</tr></tbody>
</table>
{*txy BUG0069250 优化自动化进度设置界面隔行换色*}
<table class="settingPopTable DetailContentTable" border="0" cellpadding="0" cellspacing="0" width="80%">
	<tr>
        <td width="20%" align="right">
			{'Enableprogresstracking'|@getFixedLabel}
        </td>
        <td width="10%" align="left">
            <input type="checkbox" name="enable" {if $MODULEADVANCE['enable'] eq 'yes'}checked{/if}/>
        </td>
        <td width="20%" align="right">
            {'Enableprogresstrackingonmobile'|@getFixedLabel}
        </td>
        <td  align="left" style="overflow: inherit;">
            <input type="checkbox" name="showadvancemobile" {if $MODULEADVANCE['showadvancemobile'] eq 'yes'}checked{/if}/>
        </td>
        
    </tr>
   	<tr>
        {*<td align="right" style="border-left: 1px solid #F1F1F1;display:none;">
            {'allowtopushback'|@getFixedLabel}
        </td>
        <td align="left" style="overflow: inherit;border-right: 1px solid #F1F1F1;display:none;">
            <input type="checkbox" name="pushback" {if $MODULEADVANCE['pushback'] eq 'yes'}checked{/if}/>
        </td>*}
        <td align="right">
            {'Progresstrackingmethod'|@getFixedLabel}
        </td>
        <td align="left" style="overflow: inherit;">
            <select class="padLR5" name="method" onchange="AdvanceRelation.change_tracking_method(this,'{$FROMMODULE}')">
				<option value="field" {if $MODULEADVANCE['method'] eq 'field' || $MODULEADVANCE['method'] eq ''}selected{/if}>{'Byspecifiedfield'|@getFixedLabel}</option>
				<option value="period" {if $MODULEADVANCE['method'] eq 'period'}selected{/if}>{'Byspecifiedperiod'|@getFixedLabel}</option>
			</select>
        </td>
        
        <td width="20%" align="right">
            {'Showadvancelog'|@getFixedLabel}
        </td>
        <td width="10%" align="left" style="overflow: inherit;">
             <select class="padLR5" name="showadvancelog">
				<option value="no" {if $MODULEADVANCE['showadvancelog'] eq 'no'}selected{/if}>{'HIDE'|@getFixedLabel}</option>
				<option value="getin" {if $MODULEADVANCE['showadvancelog'] eq 'getin'}selected{/if}>{'ENTERPUSHERTIME'|@getFixedLabel}</option>
                <option value="getout" {if $MODULEADVANCE['showadvancelog'] eq 'getout' || $MODULEADVANCE['showadvancelog'] eq ''}selected{/if}>{'LEAVEPUSHERTIME'|@getFixedLabel}</option>
            </select>
        </td>
    </tr>
    <tr id="pushstyle" {if $MODULEADVANCE['method'] neq 'field' && $MODULEADVANCE['method'] neq ''}style="display:none;"{/if}>
        {*<td align="right" style="border-left: 1px solid #F1F1F1;display:none;">
            {'allowtopushback'|@getFixedLabel}
        </td>
        <td align="left" style="overflow: inherit;border-right: 1px solid #F1F1F1;display:none;">
            <input type="checkbox" name="pushback" {if $MODULEADVANCE['pushback'] eq 'yes'}checked{/if}/>
        </td>*}
        <td align="right">
            {'PUSHOPERAATIONSTYLE'|@getFixedLabel}
        </td>
        <td  align="left" style="overflow: inherit;">
            <select class="padLR5" name="operatestyle">
				<option value="underadvance" {if $MODULEADVANCE['operatestyle'] eq 'underadvance'  || $MODULEADVANCE['operatestyle'] eq ''}selected{/if}>{'BELOWPROPULSIONLOG'|@getFixedLabel}</option>
				<option value="inpopup" {if $MODULEADVANCE['operatestyle'] eq 'inpopup' }selected{/if}>{'NEWDIALOG'|@getFixedLabel}</option>
			</select>
        </td>
        
        <td width="20%" align="right">
            {'PUSHLOGSTYLE'|@getFixedLabel}
        </td>
        <td width="10%" align="left" style="overflow: inherit;">
             <select class="padLR5" name="logshowstyle">
                <option value="inpopup" {if $MODULEADVANCE['logshowstyle'] eq 'inpopup' || $MODULEADVANCE['logshowstyle'] eq ''}selected{/if}>{'UNDERADVANCENODE'|@getFixedLabel}</option>
				<option value="underadvance" {if $MODULEADVANCE['logshowstyle'] eq 'underadvance'}selected{/if}>{'TILEBELOWNODE'|@getFixedLabel}</option>
            </select>
        </td>
    </tr>
    
    <tr>
        
        <td id="td_select_field" {if $MODULEADVANCE['method'] neq 'field' && $MODULEADVANCE['method'] neq ''}style="display:none;"{/if} align="right">
            {'Selecttrackingfield'|@getFixedLabel}
        </td>
        <td id="td_select_fields" {if $MODULEADVANCE['method'] neq 'field' && $MODULEADVANCE['method'] neq ''}style="display:none;"{/if} align="left" style="overflow: inherit;">
            <select class="padLR5" name="module_field" onchange="AdvanceRelation.fieldname_change(this,'{$FROMMODULE}','field')">
				{if $SELECTFIELD neq ''}
                    {foreach key=fieldname item=fieldlabel  from=$SELECTFIELD}
                        <option value="{$fieldname}" {if $MODULEADVANCE['module_field'] eq $fieldname}selected{/if}>{$fieldlabel}</option>
                    {/foreach}
                {else}
                    <option value="none" disabled>{'NoOptionalFields'|@getFixedLabel}</option>
                {/if}
			</select>
        </td>
    </tr>
	<tr id="tr_select_period_date" {if $MODULEADVANCE['method'] neq 'period' || $MODULEADVANCE['method'] eq ''}style="display:none;"{/if}>
        <td align="right">
            {'Selectstartdatefield'|@getFixedLabel}
        </td>
        <td align="left" style="overflow: inherit;">
            <select class="padLR5" name="module_period_start_date_field" tag="{'Selectstartdatefield'|@getFixedLabel}">
				{foreach key=fieldname item=fieldlabel  from=$SELECTFIELDDATE}
					<option value="{$fieldname}" {if $MODULEADVANCE['module_period_start_field'] eq $fieldname}selected{/if}>{$fieldlabel}</option>
				{/foreach}
			</select>
        </td>
        <td align="right">
            {'Selectenddatefield'|@getFixedLabel}
        </td>
{*       border-right: 1px solid #F1F1F1;删除的边框颜色 BUG0069250*}
        <td align="left" style="overflow: inherit;">
            <select class="padLR5" name="module_period_end_date_field" tag="{'Selectenddatefield'|@getFixedLabel}">
				{foreach key=fieldname item=fieldlabel  from=$SELECTFIELDDATE}
					<option value="{$fieldname}" {if $MODULEADVANCE['module_period_end_field'] eq $fieldname}selected{/if}>{$fieldlabel}</option>
				{/foreach}
			</select>
        </td>
    </tr>
</table>
<!-- 自动任务设置栏 --!>
<div name="advancetask" id="advancetask" style="margin:15px 0px;">
    {include file='Settings/moduleadvance.tpl'} 
</div>
