<!--修改编码格式:统一编码：UTF-8-->
<div id="sortview_form_div">
<form name="EditView" id="sortview_form" action="index.php" onsubmit="puyoungJS_DialogBox.block();">
<input type="hidden" name="module" value="Settings"/>
<input type="hidden" name="action" value="ProductToolSetupField"/>
{*<div class="E_pop_tit">*}
{*	{if $TYPE eq 'Sort'}*}
{*		<strong class="E_ptita">{'LBL_CHANGEORDER'|@getFixedLabel}</strong>*}
{*	{else}*}
{*		<strong class="E_ptita">{'HIDDENFIELDS'|@getFixedLabel}</strong>*}
{*	{/if}*}
{*	<button class="E_ptitc" value="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}" onclick="fninvshnew('sortview');return false;"></button>*}
{*</div>*}
<table class="ld-pop-container-second padT2" border="0" cellpadding="0" cellspacing="0" width="100%" name="sortview_table" id="sortview_table">
    <tr>
		{if $TYPE eq 'Sort'}
			<td style="padding: 10px;width: 200px;">
                <input type="hidden" name="selectedColumnsString2">
                <input class="detailedViewTextBox" style="width: 100%;" type="text" onkeyup="cls_input_select.getInstance('field')._onkeyup(this,'selectedColumns2',event)" tag="{'pleaseenterthecategoryyouarelookingforfield'|@getFixedLabel}" placeholder="{'pleaseenterthecategoryyouarelookingforfield'|@getFixedLabel}" name="allmember" /><br>
				<select id="selectedColumns2" multiple="" class="commonMultipleSelect marT10" name="selectedColumns2" size="10" >
					{foreach item=fieldlabel key=producttoolfieldid from=$FIELDLIST}  
					<option value="{$producttoolfieldid}">{$fieldlabel}</option>
					{/foreach}
				</select>
		   </td>
		{else}
			<td style="padding: 10px;width: 200px;">
				<b>{'CHOOSEHIDDENFIELD'|@getFixedLabel}</b><br/>
                <input type="hidden" name="selectedColumnsString2">
                <input class="detailedViewTextBox marT10" style="width: 72%;" type="text" onkeyup="cls_input_select.getInstance('field')._onkeyup(this,'selectedColumns2',event)" tag="{'pleaseenterthecategoryyouarelookingforfield'|@getFixedLabel}" placeholder="{'pleaseenterthecategoryyouarelookingforfield'|@getFixedLabel}" name="allmember" /><br>
				<select id="selectedColumns2" multiple="" class="commonMultipleSelect marT10" onchange="selectedColumnClick(this);" name="selectedColumns2" size="10" >
					{foreach item=fieldlabel key=producttoolfieldid from=$FIELDLIST}  
					<option value="{$producttoolfieldid}">{$fieldlabel}</option>
					{/foreach}
				</select>
		   </td>
		{/if}
	    {if $TYPE eq 'Sort'}
		  <td width="75">
				<a class="icon-newhomearr icon-mup" href="javascript:;" title="{'MOVEUP'|@getFIxedLabel}" onclick="ModuleDetailmoveUp('selectedColumns2')"></a><br />
				<a class="icon-newhomearr icon-mdown" style="margin-top: 15px;" href="javascript:;" title="{'MOVEDOWN'|@getFIxedLabel}" onclick="ProductDetailmoveDown('selectedColumns2')"></a>
		  </td>
	    {/if}
    </tr>
</table>
{*<div class="E_pbtn">*}
{*	{if $TYPE eq 'Sort'}*}
{*		<input type="button" class="ld-button ld-button-primary" value="{'SAVE'|@getFixedLabel}" onclick="saveFieldSort(this,'sortview','{$TABID}','{$TYPE}');"/>*}
{*		<input type="button" class="ld-button ld-button-cancel" value="{'CANCEL'|@getFixedLabel}" onclick="fninvshnew('sortview');"/>*}
{*    {else}*}
{*		<input type="button" class="ld-button ld-button-primary" value="{'CANCELHIDDEN'|@getFixedLabel}" onclick="saveFieldSort(this,'sortview','{$TABID}','{$TYPE}');"/>*}
{*	{/if}*}
{*</div>*}
</form>
</div>
