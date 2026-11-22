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
    <table class="relatedListsTable" border="0" cellpadding="0" cellspacing="0">
      <tr>
        <td width="200">
    		<b>{'AllRelatedModules'|@getFixedLabel}</b>
			<input class="detailedViewTextBox"  style="width: 200px;margin-top: 5px;" type="text" onkeyup="clickSelectMember(this,'FieldList')" tag="{'pleaseenterthecategoryyouarelookingformodule'|@getFixedLabel}" placeholder="{'pleaseenterthecategoryyouarelookingformodule'|@getFixedLabel}" name="allmember" />
            <input type="hidden" value="" id="FieldColumnsString" name="FieldColumnsString">
    		<select  class="commonMultipleSelect width200 height250 marT10" name="FieldList" id="FieldList" multiple="" ondblclick="clickAddColumn('FieldList','selectedFieldColumns')"><!--ondblclick="addColumn();-->
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
    		<a class="icon-newhomearr icon-mright" style="margin-top: 15px;" href="javascript:;" onclick="copySelectedOptionsSettingModule('FieldList','selectedFieldColumns');" title="{'MOVERIGHT'|@getFIxedLabel}"></a>
    		<a class="icon-newhomearr icon-mleft" style="margin-top: 25px;" href="javascript:;" onclick="copySelectedOptionsSettingModule('selectedFieldColumns','FieldList');" title="{'MOVELEFT'|@getFIxedLabel}"></a>
    	</td>
    	<td width="200">
    		<b>{'SelectedRelateModules'|@getFixedLabel}</b>
            <input type="hidden" value="" id="selectedFieldColumnsString" name="selectedFieldColumnsString">
    		<select size="11" class="commonMultipleSelect width200 height250 " style="margin-top: 43px;" name="selectedFieldColumns" id="selectedFieldColumns" multiple="" ondblclick="clickAddColumn('selectedFieldColumns','FieldList')">
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
    		<a class="icon-newhomearr icon-mup" style="margin-top:15px;margin-left: -3px;" href="javascript:;" onclick="ModuleDetailmoveUp('selectedFieldColumns');" title="{'MOVEUP'|@getFIxedLabel}"></a>
    		<a class="icon-newhomearr icon-mdown" style="margin-top:25px;margin-left: -3px;" href="javascript:;" onclick="ProductDetailmoveDown('selectedFieldColumns');" title="{'MOVEDOWN'|@getFIxedLabel}"></a>
    	</td>
      </tr>
    </table>
</form>