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
{* 任务编辑界面 *}
<table class="" border="0" cellpadding="0" cellspacing="0" width="100%" style="table-layout: fixed;padding-top: 20px">
    <tr>
        <td class="ld-form-item-label">
            {'TASK'|@getFixedLabel}{'SERVICECONTRACTSTYPE'|@getFixedLabel}
        </td>
        <td class="ld-form-item-content">
            {$typelabel}
        </td>
    </tr>
    <tr>
        <td class="ld-form-item-label">{'ACTIVATE'|@getFixedLabel}</td>
        <td class="ld-form-item-content">
            <input type="checkbox" tasktype='{$type}' name="presence" onclick="AdvanceRelation.enabletask(this,'no')" checked class="second_switch"/>       
        </td>
        <td class="ld-form-item-label">{'COMPLETEREQUEST'|@getFixedLabel}</td>
        <td class="ld-form-item-content">
            <input type="checkbox" tasktype='{$type}' name="completerequest" class="second_switch"/>        
        </td>
    </tr>
    {if $type eq 'module'}
    <tr>
        <td class="ld-form-item-label">{'SCOPEOFSTATISTICALDOCUMENTS'|@getFixedLabel}</td>
        <td class="ld-form-item-content">
            <select class="ld-select-inner" tasktype='{$type}' id="effect_range" name="effect_range">
                <option value="getlast" {if $effect_range eq 'getlast'}selected{/if} >{'COUNTFIRSTAFTERENTERING'|@getFixedLabel}</option>
                <option value="getcur" {if $effect_range eq 'getcur'}selected{/if}>{'COUNTDURINGTHISSTAGE'|@getFixedLabel}</option>
                <option value="sum" {if $effect_range eq 'sum'}selected{/if}>{'COUNTALLDOCUMENTS'|@getFixedLabel}</option>
                <option value="getcurlastone" {if $effect_range eq 'getcurlastone'}selected{/if}>{'ONLYTHELATESTHISTORICALDOCUMENTS'|@getFixedLabel}</option>
            </select>
        </td>
        <td class="ld-form-item-label">{'RELATEDDOCUMENTSAPPROVED'|@getFixedLabel}</td>
        <td class="ld-form-item-content">
            <input type="checkbox" tasktype='{$type}' name="approve_demand" {if $approve_demand eq 'yes'}checked{/if} class="second_switch"/>
        </td>
    </tr>
    {/if}
    {if $type eq 'field'}
        <tr>
            <td class="ld-form-item-label">{'TASKLOGDISPLAY'|@getFixedLabel}</td>
            <td class="ld-form-item-content">
                <select class="ld-select-inner" tasktype='{$type}' id="effect_range" name="effect_range">
                    <option value="getlast" {if $effect_range eq 'getlast'}selected{/if} >{'DISPLAYCURRENTVALUE'|@getFixedLabel}</option>
                    <option value="get_history" {if $effect_range eq 'get_history'}selected{/if}>{'DISPLAYHISTORICALVALUES'|@getFixedLabel}</option>
                </select>
            </td>
            <td class="ld-form-item-label"></td>
            <td class="ld-form-item-content">
            </td>
        </tr>
    {/if}
</table>
{if $type eq 'field'}
    <table class="ContactsFieldSetting" id="EditTaskTable" border="0" cellpadding="0" cellspacing="0" style="margin: 10px auto;">
        <tr>
        <td width="200">
            <b>{'Available_fields'|@getFixedLabel}</b>
            <input class="detailedViewTextBox"  style="width: 200px;margin-top: 5px;" type="text" onkeyup="clickSelectMember(this,'AssmablyList')" tag="{'pleaseenterthecategoryyouarelookingforfield'|@getFixedLabel}" placeholder="{'pleaseenterthecategoryyouarelookingforfield'|@getFixedLabel}"  onblur="return cls_input_select.getInstance('field')._onblur(this)" onfocus="return cls_input_select.getInstance('field')._onfocus(this)" name="allmember" />
            <input type="hidden" value="" id="AssmablyColumnsString" name="AssmablyColumnsString">
            {*zkt 20220602 52454销售线索》页面设置，快速创建字段中，必填字段“客户名称”，点击向左按钮不能删除（正常逻辑），但是双击就能删除*}
            <select class="commonMultipleSelect width200 height250 marT10" name="AssmablyList" id="AssmablyList" multiple="" ondblclick="clickAddColumn('AssmablyList','selectedAssmablyColumns')"><!--ondblclick="addColumn();-->
            {foreach item=item key=itemid from=$actions_arr name=relinfo}
                <option value="{$itemid}">
                        {$item}
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
                <select size="11" style="overflow:auto; height: 250px;width:200px;font-family:Arial, Helvetica, sans-serif;font-size:12px;-webkit-appearance: none; margin-top: 43px;" class="commonMultipleSelect width200 height250" name="selectedAssmablyColumns" id="selectedAssmablyColumns" multiple="" ondblclick="clickAddColumn('selectedAssmablyColumns','AssmablyList')">
            {foreach item=item key=itemid from=$actions_arr_userd name=relinfo}
                <option value="{$itemid}">
                        {$item}
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
{elseif $type eq 'module'}
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
        <table class="relatedListsTable" id="EditTaskTable" border="0" cellpadding="0" cellspacing="0"  style="margin: 10px auto;">
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
{elseif $type eq 'checkbox'}
    <div name='adv_filter_div'>
        <table width="100%" border="0" cellspacing="0" cellpadding="0" class="settingadvaceTable ld-public-content-big">
            <th>{'TASK'|@getFixedLabel}{'Text'|@getFixedLabel}</th> 
            <th style="width: 22%;">{'OPERATING'|@getFixedLabel}</th>
            {assign var=i value=0}
            {foreach item=value from = $TEXTARR}
            <tr name="text_{$i}" style="height: 45px;">
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
    {* 保存最大值最小值等数据，用于增加删除和上移下移等操作的判断 *}
    <input type="hidden" maxindex="{$i-1}" minindex="0" count="{$i}" name="tr_num" value="{$i}"/>
{elseif $type eq 'select'}
    <div style="max-height:350px;width: 100%;overflow-y:auto;" id="dv_scroll">
        <table class="ld-public-content-paddingright" border="0" cellpadding="0" cellspacing="0" width="100%" style="table-layout: fixed;">
            <tr>
                <td class="ld-form-item-label"><font  color="red">*</font>{'LBL_AUTOMATICTASK_NAME'|@getFixedLabel}</td>
                <td class="ld-form-item-content"><input name="selecttaskname" value="{$SELECTTASKNAME}" class="ld-input-inner" style="width:100%;text-indent:5px;margin:0 0 5px 5px;" ></td>
            </tr>
        </table>
        <table class="settingadvaceTable ld-public-content-big" border="0" cellpadding="0" cellspacing="0" width="100%">
    
            <th>{'EDITSELECTION'|@getFixedLabel}</th> 
            <th style="width: 22%;">{'OPERATING'|@getFixedLabel}</th>
            {assign var=i value=0} 
            {foreach item = value key = index from = $SELECTARR}
                <tr name="selectinfo_{$i}" style="height: 45px;">
                    <td>
                        <input class="ld-input-inner" name="selecttext_{$i}" value="{$value}" style="padding-left:3px;" type="text" placeholder="{'pleaseenter'|@getFixedLabel}{'Text'|@getFixedLabel}" >
                    </td> 
                    <td class="sort_td"> 
                        <a class="icon-category category-sup marR8" index="{$i}" texttype="selecttext_" name="moveup_{$i}" movetype='up' style="cursor: pointer;" onclick="AdvanceRelation.text_move(this)" title="{'MOVEUP'|@getFixedLabel}"></a> 
                        <a class="icon-category category-sdown marR8" index="{$i}" texttype="selecttext_" name="movedown_{$i}" movetype='down' style="cursor: pointer;" onclick="AdvanceRelation.text_move(this)" title="{'MOVEDOWN'|@getFixedLabel}"></a> 
                        <a class="icon-homeimg icon-sdel" style="cursor: pointer;" texttype="selectinfo_" onclick="AdvanceRelation.text_delete(this,{$i});" title="{'DELETE'|@getFixedLabel}"></a> 
                    </td> 
                </tr>
            {assign var=i value=$i+1}
            {/foreach}
            <tr name="add_select">
                <td><a href="javascript:void(0);" onclick="AdvanceRelation.select_add_text()">{'NEW'|@getFixedLabel}</a></td>
                <td></td>
            </tr>
        </table>
    </div>
    <div class="E_pbtn">
        <input type="button" name="save" class="E_pbtnok" value="{'SAVE'|@getFixedLabel}" onclick="AdvanceRelation.advancetask_save()"/><span>&nbsp;</span>
        <input type="button" name="delete" value="{'DELETE'|@getFixedLabel}" class="E_pbtncancel" onclick="AdvanceRelation.delete_selecttask()" /><span>&nbsp;</span>
        <input type="button" name="cancel" class="E_pbtncancel" value="{'CANCEL'|@getFixedLabel}" onclick="CrmPopup.getPopupObj('last').CancelEvent()"/>  
    </div>
    {* 保存最大值最小值等数据，用于增加删除和上移下移等操作的判断 *}
    <input type="hidden" maxindex="{$i-1}" minindex="0" count="{$i}" name="tr_num" value="{$i}"/>
{/if}

