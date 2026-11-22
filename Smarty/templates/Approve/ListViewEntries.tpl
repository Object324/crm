{if $smarty.request.ajax neq ''}
&#&#&#{$ERROR}&#&#&#
{/if}
<!-- Search Approved Begin -->
{if $SEARCH_TEXT != ''}
	<div id="approvesearch" style='display:inline;'>
{else}
	<div id="approvesearch" style='display:none;'>
{/if}
	<table width="100%" cellpadding="5" cellspacing="0"  class="searchUIBasicTable" align="center" border=0>
		<tr class="basicserachtr">
			<td class="searchUIName small" align="left">
			<span class="searctype">{'Basic_queries'|@getFixedLabel}</span>
			</td>
			<td align="right" id='approve_search_close' style='cursor:pointer;padding-right:80px;' onclick='document.getElementById("approvesearch").style.display="none";'>[x]</td>
		</tr>
		<tr class="basicsearchfield">
			<td colspan="2">
			<table cellpadding="0">
			<tr>
				<td class="basicserachtrtd" >{'Find_field'|@getFixedLabel}</td>
				<td class="basicserachtrtd" >
					<div id="basicsearchcolumns_real">
					<select name="approve_search_field" id="approve_search_field" style="width:150px">
						{foreach key=header item=searchobj from=$SEARCH_ARRAY name='approve_search_opts'}
							{if $SEARCH_FIELD != '' && $SEARCH_FIELD == $header}
								{assign var="SELECTED" value="selected"}
							{else}
								{assign var="SELECTED" value=""}
							{/if}
							<option value="{$header}" {$SELECTED}>{$header|@getFixedLabel}</option>
						{/foreach}
					</select>
					</div>
				</td>
				<td class="basicserachtrtd" align=right>{'Find_Keyword'|@getFixedLabel}</td>
				<td class="basicserachtrtd" >
					<input type="text" class="txtBox" style="width:120px" 
					id="approve_search_text" value="{$SEARCH_TEXT}" onkeydown='approve_searchtxt_keydown(event)'>
				</td>
				<td nowrap>
					  <input name="button" type="button" id='approve_search_btn' class="createauto" value="{'FINDNOW'|@getFixedLabel}" onclick="approve_search_click();">&nbsp;
				</td>
				</tr>
			</table>
			</td>
		</tr>
	</table>
</div>
<!-- Search Approved End -->
<!--切换导航-->
<div class="D_Tab_div tabHieght">
    <table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
            <td valign="top" class="L">
                <ul>
                    <li>
                        <a href="index.php?module=Approve&action=ListView&approveresult=1&start=1" {if $ISAPPROVE eq 1}class="On"{/if}>{'Pending'|@getFixedLabel}</a>
                    </li>
                    <li>
                        <a href="index.php?module=Approve&action=ListView&approveresult=2&start=1" {if $ISAPPROVE neq 1}class="On"{/if}>{'Processed'|@getFixedLabel}</a>
                    </li>
                </ul>
            </td>
            <td>&nbsp;</td>
        </tr>
    </table>
</div>
<!--切换导航  end-->
<div class="clear"></div>
<div class="divButtons">
    <ul class="D_btn_box">
		{if $ISAPPROVE eq 1}
			<li class="D_anu_a">
				<a href="#" title="{'APPROVE_BATCHAPPROVED'|@getFixedLabel}" onclick='approve_batchapproved(this);'>
				<b class="icon-homeimg icon-check"></b><span>{'APPROVE_BATCHAPPROVED'|@getFixedLabel}</span></a>
			</li>
		{/if}
		{if 1 eq $MENUAPPROVAL && 1 eq $ISAPPROVE}
			<li class="D_anu_a">
				<a title="{'SEARCH'|@getFixedLabel}" onclick="approve_menuapproval(this);" >
                <b class="icon-homeimg icon-check"></b><span>{'APPROVE_USER_MENUAPPROVAL'|@getFixedLabel}</span></a>
			</li>
		{/if}
		<li class="D_anu_a">
			<a title="{'SEARCH'|@getFixedLabel}" onclick="approve_searchList();" >
            <b class="icon-homeimg icon-check"></b><span>{'SEARCH'|@getFixedLabel}</span></a>
		</li>
	</ul>
    <div class="PageDiv0">
		<div class="ld-flex-start">
			<div class="ld-pagenum-div">{$recordListRange}</div>
			{$NAVIGATION}
		</div>
	</div>
</div>
<div class="clear"></div>
<form name="massdelete" method="POST" id="massdelete" onsubmit="puyoungJS_DialogBox.block();">
    <input name="excludedRecords" type="hidden" id="excludedRecords" value="">
    <input name="numOfRows" id="numOfRows" type="hidden" value="">
    <input type="hidden" id='listcountrows' value="{$NUMOFROWS}">
    <input name="ISAPPROVE" id="ISAPPROVE" type="hidden" value="{$ISAPPROVE}">
    <input name="allselectedboxes" id="allselectedboxes" type="hidden" value="{$ALLSELECTEDIDS}">
    <input type="hidden" name="searchstring" id="searchstring" value="{$SEARCHSTRING}"/>
    <table class="listEntries fir-center" border="0" cellspacing="1" cellpadding="0" width="100%">
        <!-- Table Headers -->
        <tr>
            <th>
                {if $ISAPPROVE eq 1}
                    <input type="checkbox"  name="selectall" id="selectCurrentPageRec" onClick="approveselect_click(this,'selected_id');">
                {else}
                    #
                {/if}
            </th>
            {foreach name="listviewforeach" item=header from=$LISTHEADER}
                <th>
                    <span title="{$header|@getFixedLabel}">{$header|@getFixedLabel}</span>
                </th>
            {/foreach}
        </tr>
        <!-- Table Contents -->
        <tr>
            <td id="linkForSelectAll" class="linkForSelectAll" style="display:none;" colspan="{$smarty.foreach.listviewforeach.iteration+1}">
                <span id="selectAllRec" class="selectall" style="display:inline;" onClick="apprpveSelectAll_Records(true)">{'SELECTALL'|@getFixedLabel} <span id="count"> {$NUMOFROWS}</span> {'RECORDNUMS'|@getFixedLabel}</span>
                <span id="deSelectAllRec" class="selectall" style="display:none;" onClick="apprpveSelectAll_Records(false)">{'DESELECTALL'|@getFixedLabel}</span>
            </td>
        </tr>
        {foreach item=entity name=listentity key=entity_id from=$LISTENTITY}
            {if $smarty.foreach.listentity.iteration mod 2 eq '1'}
                <tr id="row_{$entity.CRMID}" class="lvtColData" onmouseout="listOnMouseOut({$entity.CRMID},'on');" onmouseover="listOnMouseOver({$entity.CRMID});">
            {else}
                <tr id="row_{$entity.CRMID}" class="lvtColDataBj" onmouseout="listOnMouseOut({$entity.CRMID},'On');" onmouseover="listOnMouseOver({$entity.CRMID});">
            {/if}
            <td onclick="check_objects_parent_td(this)">
                {if $ISAPPROVE eq 1}
                    <input type="checkbox" NAME="selected_id" id="{$entity.CRMID}" value= '{$entity.CRMID}'>
                {else}
                    {$smarty.foreach.listentity.iteration}
                {/if}
            </td>
            <td>
                <a href="index.php?module={$entity.MODULE}&action=DetailView&record={$entity.CRMID}&result_aprove=1" title="{$entity.SUBJECT}">{$entity.SUBJECT}</a>
            </td>
            <td>
                {if $entity.MODULE == 'PurchaseOrder' || $entity.MODULE == 'PurchaseInvoice'}
                    <a href="index.php?module=Vendors&action=DetailView&record={$entity.ACCOUNTID}" target="_blank" title="{$entity.ACCOUNTNAME}">{$entity.ACCOUNTNAME}</a>
                {else}
                    <a href="index.php?module=Accounts&action=DetailView&record={$entity.ACCOUNTID}" target="_blank" title="{$entity.ACCOUNTNAME}">{$entity.ACCOUNTNAME}</a>
                {/if}
            </td>
            <td>
                <span title="{$entity.NUM}">{$entity.NUM}</span>
            </td>
            <td>
                <span title="{$entity.MODULENAME}">{$entity.MODULENAME}</span>
            </td>
            <td>
                <span title="{$entity.APPROVENAME}">{$entity.APPROVENAME}</span>
            </td>
            <td>
                <span title="{$entity.STEPNAME}">{$entity.STEPNAME}</span>
            </td>
            {if $ISAPPROVE eq 2 }
                <td>
                    <span title="{$entity.APPROVEBY}">{$entity.APPROVEBY}</span>
                </td>  
                <td>
                    <span title="{$entity.CREATEDTIME}">{$entity.CREATEDTIME}</span>
                </td>
                <td>
                    <span title="{$entity.APPROVERESULT}">{$entity.APPROVERESULT}</span>
                </td>
                <td>
                    <span title="{$entity.SMOWERID}">{$entity.SMOWERID}</span>
                </td>
                <td width="60">
                    {if $entity.OPERATE eq 1 && $entity.idd > 0}
                        <a class="Anu3_a" href="javascript:unApprove_click({$entity.CRMID},'{$entity.MODULE}',this);" title="{'APPROVE_ANTIAPPROVAL'|@getFixedLabel}">{'APPROVE_ANTIAPPROVAL'|@getFixedLabel}</a>
                    {/if}
                </td>
            {else}
                <td>
                    <span title="{$entity.SPONSOR}">{$entity.SPONSOR}</span>
                </td>  
                <td>
                    <span title="{$entity.SMOWERID}">{$entity.SMOWERID}</span>
                </td>
                <td>
                    <span title="{$entity.CREATEDTIME}">{$entity.CREATEDTIME}</span>
                </td>
            {/if}
         </tr>
        {foreachelse}
            <tr>
                {if $ISAPPROVE eq 1}
                    <td align="center" colspan="10" style="background-color:#FFF;height:340px">
                {else}
                    <td align="center" colspan="12" style="background-color:#FFF;height:340px">
                {/if}
                <div class='noResultBG' >   		 
                    <div class='noResultContent'> 
                        <div class="divNoRecord">{'NOTFOUNDANYRECORD'|@getFixedLabel}!</div>
                        <div class="divNoRecordCreate"><!--{$MODULE_CREATE|@getTranstab}--></div>
                    </div>      
                </div>
                </td>
            </tr>
        {/foreach}
    </table>
</form>