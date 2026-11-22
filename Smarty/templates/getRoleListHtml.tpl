<table class="relatedListsTable" border="0" cellpadding="0" cellspacing="0" style="margin-left:45px">
      <tr>
        <td width="200">
    		<b>{'AllRelatedModules'|@getFixedLabel}</b>
            <input type="hidden" value="" id="AssmablyColumnsString" name="AssmablyColumnsString">
    		<select  class="commonMultipleSelect width200 height250 marT10" name="AssmablyList" id="AssmablyList" multiple="" ondblclick="clickAddColumn('AssmablyList','selectedAssmablyColumns')"><!--ondblclick="addColumn();-->
                {foreach item=profilename key=profileid from=$left_profileinfo name=relinfo}                                                          
                    <option value="{$profileid}">
                    
                        {$profilename}
                    
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
    		<select size="11" class="commonMultipleSelect width200 height250 marT10" name="selectedAssmablyColumns" id="selectedAssmablyColumns" multiple="" ondblclick="clickAddColumn('selectedAssmablyColumns','AssmablyList')">
                {foreach item=profilename key=profileid from=$right_profileinfo name=relinfo}                                                          
                    <option value="{$profileid}">
                    
                        {$profilename}
                    
                    </option>                                                                                                                         
                {/foreach}
            </select>        
    	</td>
    	<td width="50" class="ctextalign" style="padding-left: 5px;">
    	
    	</td>
      </tr>
    </table>