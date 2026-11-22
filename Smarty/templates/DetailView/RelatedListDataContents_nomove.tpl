{*<!--
/*+********************************************************************************
  * The contents of this file are subject to the lingdang CRM Public License Version 1.0
  * ("License"); You may not use this file except in compliance with the License
  * The Original Code is:  lingdang CRM Open Source
  * The Initial Developer of the Original Code is lingdang.
  * Portions created by lingdang are Copyright (C) lingdang.
  * All Rights Reserved.
  *********************************************************************************/
-->*}
<!--修改编码格式:统一编码：UTF-8-->
<div class="DivC">
    <div class="DivCNameR" style="display:none;"><!--刘总要求隐藏-->
        <div>{$RELATEDLEFTMODHREFNAME} >> {'MOREINFORMATION'|@getFixedLabel} >> </div>
        <span class="On">
            {if $RELATED_MODULE eq 'CallButler'}
                {'CallButler'|@getFixedLabel}
            {elseif $RELATED_MODULE eq 'BoughtProduct'}
                {'BOUGHTPRODUCT'|@getFixedLabel}
            {elseif $RELATED_MODULE eq 'buyProductQuantity'}
                {'BUYPRODUCTQUANTITY'|@getFixedLabel}
            {elseif $RELATED_MODULE eq 'Kingdeeorders'}
                {'KINGDEEORDERS'|@getFixedLabel}
            {elseif $RELATED_MODULE eq 'Kingdeequotes'}
                {'KINGDEEQUOTES'|@getFixedLabel}
            {elseif $RELATED_MODULE eq 'Digiwinorders'}
                {'DIGIWINORDERS'|@getFixedLabel}
            {elseif $RELATED_MODULE eq 'Digiwintickets'}
                {'DIGIWINTICKETS'|@getFixedLabel}
            {elseif $RELATED_MODULE eq 'SharedUsers'}
                {'ShareUsers'|@getFixedLabel}
            {elseif $RELATED_MODULE eq 'Redemption'}
                {'REDEMPTION'|@getFixedLabel}
            {elseif $RELATED_MODULE eq 'Jijin_Log_Detail' }
                重算日志
            {elseif $RELATED_MODULE eq 'ViewHistory'}
                {'View History'|@getFixedLabel}
            {elseif $RELATED_MODULE eq 'ChangeView'}  
                {'SmownerChangeView'|@getFixedLabel}   
            {else}
                {$RELATED_MODULE|@getTranstab}
            {/if}
        </span>
    </div>
	<div class="Top">
		<table width="100%" border="0" cellspacing="0" cellpadding="0">
			<tr>
				<td style="height: 42px;"></td>
{*				wyt 220926 BUG0056905 kfbcrm-加班单-申请人变更历史，去掉图中的空隙*}
{*				wym 230112 BUG0060708 单据详情-销售负责人变更历史，没有记录时不显示页码（形成空隙）*}
				<td class="DivCR" valign="middle" >
				<div class="PageDiv0"  style="margin-top: 4px;margin-bottom:4px;">
					<div class="ld-flex-start">
					<div class="ld-pagenum-div">{$RELATEDLISTDATA.navigation.0}</div>
					{$RELATEDLISTDATA.navigation.1}
					</div>
				</div>
			</td>
			</tr>
		 </table>
	</div>
	<input type="hidden" id="hidden_start" name="hidden_start" value="{$START}" />
    <div id="divRelated_yy" style="width: 100%; overflow: auto;">
    
	{if $RELATED_MODULE eq 'Digiwinorders' || $RELATED_MODULE eq 'Digiwintickets' || $RELATED_MODULE eq 'Kingdeeorders' || $RELATED_MODULE eq 'Kingdeequotes'}
		<table class="listEntries" style="table-layout:auto;" border=0 cellspacing=1 cellpadding="0" width="{if $PAGEWIDTHPERCENT eq ''}100{else}{$PAGEWIDTHPERCENT}{/if}%">
	{else}
        {if $MODULE eq 'Campaigns' && ($RELATED_MODULE eq 'Contacts' || $RELATED_MODULE eq 'Leads' || $RELATED_MODULE eq 'Accounts')
    			&& $RELATEDLISTDATA.entries|@count > 0}
            <table class="listEntries fir-center" border=0 cellspacing=1 cellpadding="0" width="{if $PAGEWIDTHPERCENT eq ''}100{else}{$PAGEWIDTHPERCENT}{/if}%" >
        {else}
			<table class="listEntries" border=0 cellspacing=1 cellpadding="0" width="{if $PAGEWIDTHPERCENT eq ''}100{else}{$PAGEWIDTHPERCENT}{/if}%" >
        {/if}
	{/if}
    	<tr>
            {if $MODULE eq 'Campaigns' && ($RELATED_MODULE eq 'Contacts' || $RELATED_MODULE eq 'Leads' || $RELATED_MODULE eq 'Accounts')
    			&& $RELATEDLISTDATA.entries|@count > 0}
    		<th style="text-align:center;">
    			<input name ="{$RELATED_MODULE}_selectall" id="{$MODULE}_{$RELATED_MODULE}_selectCurrentPageRec" onclick="rel_toggleSelect(this.checked,'{$MODULE}_{$RELATED_MODULE}_selected_id','{$RELATED_MODULE}');"  type="checkbox">
    		</th>
            {/if}
    		{foreach key=index item=_HEADER_FIELD from=$RELATEDLISTDATA.header name=relheadforeach}
    		    {if $_HEADER_FIELD eq 'OPERATING'|@getFixedLabel}
                    {if $RELATED_MODULE eq 'CallButler'}
						<th width="43">{$_HEADER_FIELD}</th>
                    {else}
						<th width="{$RELATEDTABLEWIDTH}" >{$_HEADER_FIELD}</th>
                    {/if}
                {else}
                <th width="{$RELATEDLISTDATA.fieldwidth[$index]}px">{$_HEADER_FIELD}</th>
                {/if}
            {/foreach}
    	</tr>
    	{if $MODULE eq 'Campaigns'}
    	<tr>
    		<td id="{$MODULE}_{$RELATED_MODULE}_linkForSelectAll" class="linkForSelectAll" style="display:none;" colspan="200">
    			<span id="{$MODULE}_{$RELATED_MODULE}_selectAllRec" class="selectall" style="display:inline;" onClick="rel_toggleSelectAll_Records('{$MODULE}','{$RELATED_MODULE}',true,'{$MODULE}_{$RELATED_MODULE}_selected_id')">{'ALLSELECT'|@getFixedLabel} <span id={$RELATED_MODULE}_count class="folder"> </span> {'RECORDS'|@getFixedLabel}</span>
    			<span id="{$MODULE}_{$RELATED_MODULE}_deSelectAllRec" class="selectall" style="display:none;" onClick="rel_toggleSelectAll_Records('{$MODULE}','{$RELATED_MODULE}',false,'{$MODULE}_{$RELATED_MODULE}_selected_id')">{'DESELECTALL'|@getFixedLabel}</span>
    		</td>
    	</tr>
    	{/if}
        {assign var="i" value=0}
    	{foreach key=_RECORD_ID name=entriesList item=_RECORD from=$RELATEDLISTDATA.entries}
            {assign var="j" value=$i++}
    		{if $smarty.foreach.entriesList.iteration mod 2 eq '1'}
            <tr id="relation_{$RELATED_MODULE}_{$j}" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
            {else}
            <tr id="relation_{$RELATED_MODULE}_{$j}" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
            {/if}
            	{if $MODULE eq 'Campaigns' && ($RELATED_MODULE eq 'Contacts' || $RELATED_MODULE eq 'Leads' || $RELATED_MODULE eq 'Accounts')}
    			<td style="text-align:center;" onclick="rel_check_object_parent_td(this)"><input name="{$MODULE}_{$RELATED_MODULE}_selected_id" id="{$_RECORD_ID}" value="{$_RECORD_ID}" onclick="rel_check_object(this,'{$RELATED_MODULE}');" type="checkbox"  {$RELATEDLISTDATA.checked.$_RECORD_ID}></td>
            	{/if}
    			{foreach key=index item=_RECORD_DATA from=$_RECORD}
    				 {* vtlib customization: Trigger events on listview cell onmouseover="vtlib_listview.trigger('cell.onmouseover', $(this))" onmouseout="vtlib_listview.trigger('cell.onmouseout', $(this))"*}
					{if $index|@istdRight:$RELATED_MODULE==true}
						{assign var="tdalign" value='right'}
					{else}
						{assign var="tdalign" value='left'}
					{/if}
                     {if $_RECORD_DATA|count_characters:true gt 800}
                    	<td width="40%" align="{$tdalign}">{$_RECORD_DATA}</td>
                    {else}
                    	<td align="{$tdalign}">{$_RECORD_DATA}</td>
                    {/if}
                     {* END *}
    			{/foreach}
    		</tr>
    	{foreachelse}
    		<tr>
    			<td colspan='{$smarty.foreach.relheadforeach.iteration}' align='center' id="resize_content_tdid"  style="background-color:#FFF;height:0px;padding: 0;">
                    {* <i style="display:inline-block;width:100%;text-align:center;">{'NONE'|@getFixedLabel}</i> *}
                    {include file="NoRecords.tpl" NoRecords_STYLE = 'top: calc(50% - 60px);'}
                </td>
    		</tr>
    	{/foreach}
		{if $RELATEDLISTDATA.totalfldhtml !=''}
			{$RELATEDLISTDATA.totalfldhtml}
		{/if}
    </table>
    </div>
    {if $MODULE eq 'Campaigns' && ($RELATED_MODULE eq 'Contacts' || $RELATED_MODULE eq 'Leads' || $RELATED_MODULE eq 'Accounts')
    			&& $RELATEDLISTDATA.entries|@count > 0 && $RESET_COOKIE eq 'true'}
    			<script type='text/javascript'>set_cookie('{$RELATED_MODULE}_all', '');</script>
    {/if}
    {if $MODULE eq 'Campaigns'}
    <input id="{$MODULE}_{$RELATED_MODULE|replace:' ':''}_numOfRows" type="hidden" value="">
    <input id="{$MODULE}_{$RELATED_MODULE|replace:' ':''}_excludedRecords" type="hidden" value="">
    <input id="{$MODULE}_{$RELATED_MODULE|replace:' ':''}_selectallActivate" type="hidden" value="false">
    {/if}
    </form>
    
</div>
<div id="TradeHistoryDiv" class="D_pop_box LdPopWidth900px" style="display:none;z-index:99999;position:absolute"></div>
<div id="divFileCallButlerlist" style="display:none;"></div>
<div id="redemptiondiv" style="display:none;"></div>

<script>
var popupobj=CrmPopup.getPopupObj('last');
popupobj.relatelistsizeobj=new List_ResizeTable(popupobj);

popupobj.relatelistsizeobj.setRelatedResizeTable_Init('{$RELATED_MODULE}','');
popupobj.reSizePosition();//设置相关信息全屏
</script>