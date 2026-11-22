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
<!-- Customized Reports Table Starts Here  -->
	<form>
	{if $DEL_DENIED neq ""}
	<span id="action_msg_status" align="left"><font color="red"><b>{$MOD.LBL_PERM_DENIED} {$DEL_DENIED}</b> </font></span>
	{/if}
	<input id="folder_ids" name="folderId" type="hidden" value='{$FOLDE_IDS}'>
	{assign var=poscount value=0}
	{foreach item=reportfolder from=$REPT_CUSFLDR}	
	{assign var=poscount value=$poscount+1}
		<table align="center" border="0" cellpadding="0" cellspacing="0" width="100%">		
		<tr>
    		<td class="reportsListTabHead" align="left" colspan="3" style="border-bottom:1px solid #ddd;">
    		<span id='folder{$reportfolder.id}'> {$reportfolder.name}</span>
    		</td>
		</tr>
		<tr>
			<td  class="hdrNameBg" colspan="3" style="padding: 5px;" align="right" >
				<!-- Custom Report Group's Buttons -->
				<table width="100%" border="0" cellpadding="0" cellspacing="0">
                <tr>
        		<td id="repposition{$poscount}" width="5%" align="right"><input name="newReportInThisModule" value="{'Creating_a_Report'|@getFixedLabel}" class="createauto" onclick="gcurrepfolderid={$reportfolder.id};fnvshobj(this,'reportLay')" type="button"></td>
        			<td  width="75%" align="right">
      					<input type="button" name="Edit" value="{'RENAMEFOLDER'|@getFixedLabel}" class="editauto" onClick='EditFolder("{$reportfolder.id}","{$reportfolder.fname}","{$reportfolder.fdescription}"),fnvshobj(this,"orgLay");'>&nbsp;
        			</td>
        			<td align="right">
      					<input type="button" name="delete" value="{'DELETEFOLDER'|@getFixedLabel}" class="deleteauto" onClick="DeleteFolder('{$reportfolder.id}');">
        			</td>
        		</tr>
        		</table>
			</td>
		</tr>
		<tr>
    		<td colspan="3">
    		<table class="listEntries fir-center" border="0" cellpadding="3" cellspacing="1" width="100%">
    			<tbody>
    			<tr>
        			<th>
        				<input type="checkbox" name="selectall" onclick='toggleSelect(this.checked,"selected_id{$reportfolder.id}")' value="checkbox" />
        			</th>
        			<th align="left" width="30%">{$MOD.LBL_REPORT_NAME}</th>
        			<th align="left">{$MOD.LBL_DESCRIPTION}</th>
        			{if $LANGUAGETYPE eq 'en'}
        			<th width="95" style="text-align:center;">{'OPERATING'|@getfixedLabel}</th>
                    {else}
                    <th width="85" style="text-align:center;">{'OPERATING'|@getfixedLabel}</th>
                    {/if}
                </tr>
    			{foreach name=reportdtls item=reportdetails from=$reportfolder.details}
    			<tr bgcolor="white" class="Hover">
    			<td onclick="toggleSelectAll_parent_td(this)">
    				{if $reportdetails.customizable eq '1' && $reportdetails.editable eq 'true'}
    					<input name="selected_id{$reportfolder.id}" value="{$reportdetails.reportid}" onclick='toggleSelectAll(this.name,"selectall")' type="checkbox">
    				{/if}
    			</td>
    			<td align="left"><a target="_blank" href="index.php?module=Reports&action=SaveAndRun&record={$reportdetails.reportid}&folderid={$reportfolder.id}">{$reportdetails.reportname}</a>
    			{if $reportdetails.sharingtype eq 'Shared'}
    				<img src="{'Meetings.gif'|@lingdang_imageurl:$THEME}" align="absmiddle" border=0 height=12 width=12 /> 
    			{/if}
    			</td>
    			<td align="left">{$reportdetails.description}</td>
    			<td align="right" nowrap>
    			{if $reportdetails.customizable eq '1' && $reportdetails.editable eq 'true'}
    				<a class="Anu3_a" href="javascript:;" onClick="editReport('{$reportdetails.reportid}');">{'EDIT'|@getFixedLabel}</a>
    			{/if}
    			{if $reportdetails.state neq 'SAVED' && $reportdetails.editable eq 'true'}
    			     <a class="Anu3_a" href="javascript:;" onClick="DeleteReport('{$reportdetails.reportid}');">{'DELETE'|@getFixedLabel}</a>
    			{/if}
    			</td>
    			</tr>
    			{/foreach}
    			</tbody>
    		</table>
		    </td>
		</tr>
	</table>
	<br />
	{foreachelse}
	<div style="position:relative; text-align: left;height:30px;border:1px dashed #CCCCCC;padding:15px 10px 10px;">
	<a href="javascript:;" onclick="fnvshobj(this,'orgLay');">{$MOD.LBL_CLICK_HERE}</a>&nbsp;{$MOD.LBL_TO_ADD_NEW_GROUP}
	</div>
	{/foreach}
	</form>
	<!-- Customized Reports Table Ends Here  -->

<div style="display: none;left:193px;top:106px;height:auto;background:#fff;padding-top:0px;" id="folderLay" class="D_pop_box LdPopWidth600px">
    <div class="D_pop_tit">
    	<strong class="D_ptita">{$MOD.LBL_MOVE_TO}</strong>
        <a href="javascript:fninvshnew('folderLay');" class="D_ptitc">
            <img class="D_ptitcimg" style="margin-left: 0px;" src="themes/icon/pop_close.png" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"/>
        </a>
    </div>
    <table class="D_pop_bod" cellspacing="1" cellpadding="0" border="0">
      <tr>
      <td>	
        <ul class="People-List">
            {foreach item=folder from=$REPT_FOLDERS}
                <li>  
                     <div class="Character-Names">
                        <a href="javascript:;" onClick='MoveReport("{$folder.id}","{$folder.fname}");'>- {$folder.name}</a>
                     </div>
                     <div class="clear"></div>
                </li>
            {/foreach}
        </ul>
      </td>
      </tr>
    </table>
</div>