{* 任务编辑界面 *}
{if $type eq 'checkbox'}
    <div name='adv_filter_div'>
    	<table width="100%" border="0" cellspacing="0" cellpadding="0" class="settingadvaceTable">
        <th>{'TASK'|@getFixedLabel}{'Text'|@getFixedLabel}</th> 
        <th style="width: 22%;">{'OPERATING'|@getFixedLabel}</th>
            {assign var=i value=0}
            {foreach item=value from = $TEXTARR}
    		<tr name="text_{$i}">
    			<td ><input name="checkboxtext_{$i}"  tag="{$i}" class="ld-input-inner" value="{$value}" type="text" placeholder="{'pleaseenter'|@getFixedLabel}{'TASK'|@getFixedLabel}{'Text'|@getFixedLabel}"></input></td>
                <td width="15%">
                <a class="icon-category category-sup marR8" index="{$i}" texttype="checkboxtext_" name="moveup_{$i}" movetype='up' style="cursor: pointer;{if $i eq 0}display:none;{/if}" onclick="AdvanceRelation.text_move(this)" title="{'MOVEUP'|@getFixedLabel}"></a>
                <a class="icon-category category-sdown marR8" index="{$i}" texttype="checkboxtext_" name="movedown_{$i}" movetype='down' style="cursor: pointer;{if $i eq $countTEXTARR-1}display:none;{/if}" onclick="AdvanceRelation.text_move(this)" title="{'MOVEDOWN'|@getFixedLabel}"></a>
                <a class="icon-homeimg icon-sdel" style="color:#2894FF;" texttype="text_" href="javascript:void(0)" onclick="AdvanceRelation.text_delete(this,'{$i}')"></a></td>
            </tr>
            {assign var=i value=$i+1}
            {/foreach}
            <tr name="add_checkbox">
            <td><a href="javascript:void(0)" onclick="AdvanceRelation.checkbox_add_text();">{'NEW'|@getFixedLabel}</a></td>
            </tr>
      	</table>    
    </div>
{elseif $type eq 'select'}
     <div style="max-height:350px;width: 100%;overflow-y:auto;" id="dv_scroll">
     <div style="margin: 10px 5px 0px 5px;font-size:12px">
     <label><font  color="red">*</font>{'LBL_AUTOMATICTASK_NAME'|@getFixedLabel}</label>
     <input name="selecttaskname" value="{$SELECTTASKNAME}" class="detailedViewTextBox" style="width:60%;text-indent:5px;margin:0 0 5px 5px;" >
     </div>
     <table class="settingadvaceTable" border="0" cellpadding="0" cellspacing="0" width="100%"> 
     
     <th>{'EDITSELECTION'|@getFixedLabel}</th> 
     <th style="width: 22%;">{'OPERATING'|@getFixedLabel}</th>
     {assign var=i value=0} 
     {foreach item = value key = index from = $SELECTARR}
         <tr name="selectinfo_{$i}">
         <td><input class="detailedViewTextBox" name="selecttext_{$i}" value="{$value}" style="padding-left:3px;" type="text" placeholder="{'pleaseenter'|@getFixedLabel}{'Text'|@getFixedLabel}" ></td> 
         <td class="sort_td"> 
         <a class="icon-category category-sup marR8" index="{$i}" texttype="selecttext_" name="moveup_{$i}" movetype='up' style="cursor: pointer;" onclick="AdvanceRelation.text_move(this)" title="{'MOVEUP'|@getFixedLabel}"></a> 
         <a class="icon-category category-sdown marR8" index="{$i}" texttype="selecttext_" name="movedown_{$i}" movetype='down' style="cursor: pointer;" onclick="AdvanceRelation.text_move(this)" title="{'MOVEDOWN'|@getFixedLabel}"></a> 
         <a class="icon-homeimg icon-sdel" style="cursor: pointer;" texttype="selectinfo_" onclick="AdvanceRelation.text_delete(this,{$i});" title="{'DELETE'|@getFixedLabel}"></a> 
         </td> 
         </tr>
     {assign var=i value=$i+1}
     {/foreach}
     <tr name="add_select"><td><a href="javascript:void(0);" onclick="AdvanceRelation.select_add_text()">{'NEW'|@getFixedLabel}</a></td>
     <td></td></tr>
     </table>
     </div>
     <div class="E_pbtn">
		<input type="button" name="save" class="E_pbtnok" value="{'SAVE'|@getFixedLabel}" onclick="AdvanceRelation.advancetask_save()"/><span>&nbsp;</span>
		<input type="button" name="delete" value="{'DELETE'|@getFixedLabel}" class="E_pbtncancel" onclick="AdvanceRelation.delete_selecttask()" /><span>&nbsp;</span>
		<input type="button" name="cancel" class="E_pbtncancel" value="{'CANCEL'|@getFixedLabel}" onclick="CrmPopup.getPopupObj('last').CancelEvent()"/>  
	</div>
{/if}
{* 保存最大值最小值等数据，用于增加删除和上移下移等操作的判断 *}
<input type="hidden" maxindex="{$i-1}" minindex="0" count="{$i}" name="tr_num" value="{$i}"/>
