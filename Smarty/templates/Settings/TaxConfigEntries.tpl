<table class="settingTable fir-center" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <th>#</th>
    <th width="280" align="left" title="{'TAX'|@getFixedLabel}">{'TAX'|@getFixedLabel}</th>
    <th title="{'TAXRATE'|@getFixedLabel}">{'TAXRATE'|@getFixedLabel}</th>
    <th title="{'WHETHERTOENABLE'|@getFixedLabel}">{'WHETHERTOENABLE'|@getFixedLabel}</th>
    {if $LANUGAGETYPE eq 'en'}
        <th width="70">{'OPERATING'|@getFixedLabel}</th>
    {else}
        <th width="51">{'OPERATING'|@getFixedLabel}</th>
    {/if}
  </tr>
   {if $TAX_COUNT eq 0}
	<tr><td>{'NOTAXES'|@getFixedLabel}. {'PLEASE'|@getFixedLabel} {'ADDTAX'|@getFixedLabel}.</td></tr>
   {else}
    {assign var="i" value=0}
	{foreach item=tax key=count from=$TAX_VALUES}
        {assign var="j" value=$i++}
        {if $j mod 2 eq '0'}
            <tr id="setting_{$j}" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
        {else}
            <tr id="setting_{$j}" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
        {/if}
        <td>{$i}</td>
		<td width="25%">
            <span tag="showspan" id="span_tax_{$tax.taxid}" class="modulecontrollspan" title="{$tax.taxlabel}">{$tax.taxlabel}</span>
            <div tag="hiddendiv" id="div_tax_{$tax.taxid}" style="display:none;" class="modulecontrolldiv">
	            <input class="ld-input-inner" style="width:150px;display:inline-block;" type="text" value="{$tax.taxlabel}" maxlength="100" name="input_tax_{$tax.taxid}">
            </div>
		</td>
		<td width="35%">
            <span tag="showspan" id="span_rate_{$tax.taxid}" class="modulecontrollspan" title="{$tax.percentage}">{$tax.percentage}&nbsp;%</span>
            <div tag="hiddendiv" id="div_rate_{$tax.taxid}" style="display:none;" class="modulecontrolldiv">
	            <input class="ld-input-inner" style="width:80px;display:inline-block;" type="text" value="{$tax.percentage}" maxlength="100" name="input_rate_{$tax.taxid}">
                <div style="display:inline-block;margin-left:5px;">
                    <a class="Anu3_a" href="javascript:void(0);" onclick="saveTaxConfig('{$tax.taxid}','{$tax.taxname}')">{'SAVE'|@getFixedLabel}</a>
                    <a class="Anu3_a" href="javascript:void(0);" onclick="editTaxConfig('{$tax.taxid}',2);" >{'CANCEL'|@getFixedLabel}</a>
                </div>
            </div>
		</td>
		<td>
			{if $tax.deleted eq 0}
                <input type="checkbox" onclick="toggleTaxConfig('{$tax.taxname}',this.checked);" class="second_switch" checked="" />
            {else}
                <input type="checkbox" onclick="toggleTaxConfig('{$tax.taxname}',this.checked);" class="second_switch"  />
            {/if}
		</td>
        <td>
            <a class="Anu3_a" href="javascript:void(0);" onclick="editTaxConfig('{$tax.taxid}',1);" >{'EDIT'|@getFixedLabel}</a>
        </td>
	   </tr>
	{/foreach}
   {/if}
</table>