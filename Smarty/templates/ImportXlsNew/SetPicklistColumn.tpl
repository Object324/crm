<form action="index.php" method="post" name="Saveresults" onsubmit="puyoungJS_DialogBox.block();">
<input type="hidden" name="action" value="SettingsAjax">
    {assign var=entries value=$CFENTRIES}

    <table class="relatedListsTable" id="setPicklistTable" border="0" cellpadding="0" cellspacing="0" style="0px auto;">
      <tr>
        <td width="200">
    		<b>{'Available_fields'|@getFixedLabel}</b>
			<input class="detailedViewTextBox"  style="width: 200px;margin-top: 5px;" type="text" onkeyup="clickSelectMember(this,'AssmablyList')" tag="{'pleaseenterthecategoryyouarelookingformodule'|@getFixedLabel}" placeholder="{'pleaseenterthecategoryyouarelookingformodule'|@getFixedLabel}" name="allmember" />
            <input type="hidden" value="" id="AssmablyColumnsString" name="AssmablyColumnsString">
    		<select  class="commonMultipleSelect width200 height250 marT10" name="AssmablyList" id="AssmablyList" multiple="" ondblclick="clickAddColumn('AssmablyList','selectedAssmablyColumns')"><!--ondblclick="addColumn();-->
                {foreach item=fieldinfo key=fieldlabel from=$fields }
                    <option value="{$fieldinfo}">
						{$fieldlabel}
                    </option>                                                                                                                     
                {/foreach}
            </select> 
    	</td>
    	<td width="50" class="ctextalign" style="padding: 5px;">
    		<a class="icon-newhomearr icon-mright" style="margin-top: 15px;" href="javascript:;" onclick="copySelectedOptionsSettingModule('AssmablyList','selectedAssmablyColumns');" title="{'MOVERIGHT'|@getFIxedLabel}"></a>
    		<a class="icon-newhomearr icon-mleft" style="margin-top: 25px;" href="javascript:;" onclick="copySelectedOptionsSettingModule('selectedAssmablyColumns','AssmablyList');" title="{'MOVELEFT'|@getFIxedLabel}"></a>
    	</td>
    	<td width="200">
    		<b>{'Selected_Fields'|@getFixedLabel}</b>
            <input type="hidden" value="" id="selectedAssmablyColumnsString" name="selectedAssmablyColumnsString">
    		<select size="11" class="commonMultipleSelect width200 height250 " style="margin-top: 43px;" name="selectedAssmablyColumns" id="selectedAssmablyColumns" multiple="" ondblclick="clickAddColumn('selectedAssmablyColumns','AssmablyList')">
                {foreach item=fieldinfo key=fieldlabel from=$selfields }
                    <option value="{$fieldinfo}">
						{$fieldlabel}
                    </option>
                {/foreach}
            </select>
    	</td>
    	<td width="50" class="ctextalign" style="padding-left: 5px;">
    		<a class="icon-newhomearr icon-mup" style="margin-top:15px;margin-left: -3px;" href="javascript:;" onclick="ModuleDetailmoveUp('selectedAssmablyColumns');" title="{'MOVEUP'|@getFIxedLabel}"></a>
    		<a class="icon-newhomearr icon-mdown" style="margin-top:25px;margin-left: -3px;" href="javascript:;" onclick="ProductDetailmoveDown('selectedAssmablyColumns');" title="{'MOVEDOWN'|@getFIxedLabel}"></a>
    	</td>
      </tr>
    </table>
</form>