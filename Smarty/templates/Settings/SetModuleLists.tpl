{*<!--
/*********************************************************************************
  ** The contents of this file are subject to the lingdang CRM Public License Version 1.0
   * ("License"); You may not use this file except in compliance with the License
   * The Original Code is:  lingdang CRM Open Source
   * The Initial Developer of the Original Code is lingdang.
   * Portions created by lingdang are Copyright (C) lingdang.
   * All Rights Reserved.
  *
 ********************************************************************************/
-->*}
<!--修改编码格式:统一编码：UTF-8-->
<form action="index.php" method="post" name="Saveresults" onsubmit="puyoungJS_DialogBox.block();">
<input type="hidden" name="action" value="SettingsAjax">
<input  type="hidden" name="file" value="LayoutBlockList"/>
<input type="hidden" name="module" value="Settings">
<input type="hidden" name="formodule" value="{$modulename}">
<input type="hidden" name="tabid" value="{$tabid}">
<input type="hidden" name="sub_mode" value="SetRelatedlistsSave">
<input type="hidden" name="backaction" value="{$BACKACTION}"/>
<input type="hidden" name="blockidsetting" value="{$BLOCKIDSETTING}"/>
<input type="hidden" name="fieldidsetting" value="{$FIELDIDSETTING}"/>
    {assign var=entries value=$CFENTRIES}	
    <table class="relatedListsTable" border="0" cellpadding="0" cellspacing="0" style="0px auto;">
      <tr>
        <td width="200">
    		<b>{'AllRelatedModules'|@getFixedLabel}</b>
			<input class="detailedViewTextBox"  style="width: 200px;margin-top: 5px;" type="text" onkeyup="clickSelectMember(this,'AssmablyList')" tag="{'pleaseenterthecategoryyouarelookingformodule'|@getFixedLabel}" placeholder="{'pleaseenterthecategoryyouarelookingformodule'|@getFixedLabel}" name="allmember" />
            <input type="hidden" value="" id="AssmablyColumnsString" name="AssmablyColumnsString">
    		<select  class="commonMultipleSelect width200 height250 marT10" name="AssmablyList" id="AssmablyList" multiple="" ondblclick="clickAddColumn('AssmablyList','selectedAssmablyColumns')"><!--ondblclick="addColumn();-->
                {foreach item=related_module key=related_moduleid from=$related_modules name=relinfo}                                                          
                    <option value="{$related_moduleid}">
                    {if $modulename eq 'Accounts' && $related_moduleid eq '6'}
                    {'BALANCEOFACCOUNT'|@getFixedLabel}
                    {else}
                    {$related_module}
                    {/if}
                    </option>                                                                                                                     
                {/foreach}
            </select> 
    	</td>
    	<td width="50" class="ctextalign" style="padding: 5px;">
    		<a class="icon-newhomearr icon-mright" style="margin-top: 15px;" href="javascript:;" onclick="copySelectedOptionsSettingModule('AssmablyList','selectedAssmablyColumns');" title="{'MOVERIGHT'|@getFIxedLabel}"></a>
    		<a class="icon-newhomearr icon-mleft" style="margin-top: 25px;" href="javascript:;" onclick="copySelectedOptionsSettingModule('selectedAssmablyColumns','AssmablyList');" title="{'MOVELEFT'|@getFIxedLabel}"></a>
    	</td>
    	<td width="200">
    		<b>{'SelectedRelateModules'|@getFixedLabel}</b>
            <input type="hidden" value="" id="selectedAssmablyColumnsString" name="selectedAssmablyColumnsString">
    		<select size="11" class="commonMultipleSelect width200 height250 " style="margin-top: 43px;" name="selectedAssmablyColumns" id="selectedAssmablyColumns" multiple="" ondblclick="clickAddColumn('selectedAssmablyColumns','AssmablyList')">
                {foreach item=item key=itemid from=$related_module_selected name=relinfo}                                                          
                    <option value="{$itemid}">
                    {if $modulename eq 'Accounts' && $itemid eq '6'}
                    {'BALANCEOFACCOUNT'|@getFixedLabel}
                    {else}
                    {$item}
                    {/if}
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