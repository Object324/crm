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
  <div class="">
    <table class="relatedListsTable" border="0" cellpadding="0" cellspacing="0">
      <tr>
        <td width="200">
    		<b>{'AllRelatedModules'|@getFixedLabel}</b>
			<input class="detailedViewTextBox width200" type="text" onkeyup="cls_input_select.getInstance('select')._onkeyup(this,'AssmablyList',event)" tag="{'pleaseenterthecategoryyouarelookingfor'|@getFixedLabel}" placeholder="{'pleaseenterthecategoryyouarelookingfor'|@getFixedLabel}" onblur="return cls_input_select.getInstance('select')._onblur(this)" onfocus="return cls_input_select.getInstance('select')._onfocus(this)" name="allmember" />
            <input type="hidden" value="" id="AssmablyColumnsString" name="AssmablyColumnsString">
    		<select  class="commonMultipleSelect width200 height250 marT10" name="AssmablyList" id="AssmablyList" multiple="" ondblclick="clickAddColumn('AssmablyList','selectedAssmablyColumns')"><!--ondblclick="addColumn();-->
                {foreach item=un_selectinfo key=related_moduleid from=$un_selectstuffle name=relinfo}                                                          
                    <option value="{$un_selectinfo.stufflabel}">
                   
                    {$un_selectinfo.label}
                    
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
            <input class="detailedViewTextBox width200" type="text" onkeyup="cls_input_select.getInstance('select')._onkeyup(this,'selectedAssmablyColumns',event)" tag="{'pleaseenterthecategoryyouarelookingfor'|@getFixedLabel}" placeholder="{'pleaseenterthecategoryyouarelookingfor'|@getFixedLabel}" onblur="return cls_input_select.getInstance('select')._onblur(this)" onfocus="return cls_input_select.getInstance('select')._onfocus(this)" name="allmember" />
            <input type="hidden" value="" id="selectedAssmablyColumnsString" name="selectedAssmablyColumnsString">
    		<select size="11" class="commonMultipleSelect width200 height250 marT10" name="selectedAssmablyColumns" id="selectedAssmablyColumns" multiple="" ondblclick="clickAddColumn('selectedAssmablyColumns','AssmablyList')">
                {foreach item=item key=itemid from=$selectstuffle name=relinfo}                                                          
                    <option value="{$item.stufflabel}">
                    {$item.label}
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
  </div>
</form>