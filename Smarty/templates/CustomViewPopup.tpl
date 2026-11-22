<!--*********************************************************************************
** The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
*
 ********************************************************************************/
-->
<!--修改编码格式:统一编码：UTF-8-->
<div class="ld-pop-container-second">
{$DATE_JS}
{if $MORE_LISTVIEW eq 1}
    {literal}
    <form enctype="multipart/form-data" name="CustomView" method="POST" action="index.php" onsubmit="if(productmandatoryCheck()){puyoungJS_DialogBox.block();} else{ return false; }">
    {/literal}
    <input type="hidden" name="action" value="ProductSave">
{else}
    {literal}
    <form enctype="multipart/form-data" name="CustomView" method="POST" action="index.php" onsubmit="if(mandatoryCheck()){puyoungJS_DialogBox.block();} else{ return false; }">
    {/literal}
    <input type="hidden" name="action" value="Save">
{/if}
<input type="hidden" name="ProductListView" id="ProductListView" value="">
<input type="hidden" name="SortOrderList" id="SortOrderList" value="" />
<input type="hidden" name="module" value="CustomView">
<input type="hidden" name="cvmodule" value="{$CVMODULE}">
{if $GROUPEMAIL == 'Emails' ||$GROUPEMAIL == 'MassSMS'}
    {if $GROUPEMAIL eq 'Emails'}
        <input type="hidden" name="return_module" value="Emails">
        <input type="hidden" name="return_action" value="GroupEmail">
    {elseif $GROUPEMAIL eq 'MassSMS'}
        <input type="hidden" name="return_module" value="MassSMS">
        <input type="hidden" name="return_action" value="index">
    {/if}
{else}
    <input type="hidden" name="parenttab" value="{$CATEGORY}">
    <input type="hidden" name="return_module" value="{$RETURN_MODULE}">
    <input type="hidden" name="return_action" value="{$RETURN_ACTION}">
{/if}
<input type="hidden" name="record" value="{$CUSTOMVIEWID}">
<input type="hidden" id="user_dateformat" name="user_dateformat" value="{$DATEFORMAT}">
<input type="hidden" name="group" value="{$GROUPEMAIL}">
<input type="hidden" name="SearchScope" value="{$SEARCHSCOPE}"/>
<input type="hidden" name="viewcopy" value="{$viewcopy}"/>
<input type="hidden" name="viewcopy_cvid" value="{$viewcopy_cvid}" />
<script language="javascript" type="text/javascript">
function goto_CustomAction(module)
    {ldelim}
        document.location.href = "index.php?module="+module+"&action=CustomAction&record={$CUSTOMVIEWID}";
    {rdelim}
</script>

<div id="dv_datacustomview">
	<span class="font14 fontbold" style="display: none;padding:0px 0px 7px 10px;">
        {if $GROUPEMAIL == 'Emails' || $GROUPEMAIL == 'MassSMS'}
            {if $GROUPEMAIL eq 'Emails'}
                <a href="index.php?action=GroupEmail&module={$GROUPEMAIL}&parenttab=Marketing">{'BULKMAIL'|@getFixedLabel}</a> &gt;
            {else}
                <a href="index.php?action=SendView&module={$GROUPEMAIL}">{'MassSMS'|@getTranstab}</a> &gt;
            {/if}
    		{if $EXIST eq "true" && $EXIST neq '' && $viewcopy eq "true"}
        		{'COPYATACLASS'|@getFixedLabel}
        	{elseif $EXIST eq "true" && $EXIST neq ''}
        		{'EDITDATACLASS'|@getFixedLabel}
        	{else}
        	 	{'CREATEGROUPS'|@getFixedLabel}
        	{/if}
        {else}
            <a href="index.php?action=ListView&module={$MODULE}&parenttab={$CATEGORY}">{$MODULELABEL}</a> &gt;
        	{if $EXIST eq "true" && $EXIST neq '' && $viewcopy eq "true"}
        		{'COPYATACLASS'|@getFixedLabel}
        	{elseif  $EXIST eq "true" && $EXIST neq ''}
                {'EDITDATACLASS'|@getFixedLabel}
            {else}
        	 	{'CREATEDATACLASS'|@getFixedLabel}
        	{/if}
        {/if}
	</span>
    <form name="EditView" method="post" enctype="multipart/form-data" action="index.php">
        <input type="hidden" name="SearchScope" value="{$SEARCHSCOPE}"/>
        <div class="pad10">
            <div class="ld-pop-contnet-title-items">
                <div class="ld-pop-contnet-title-item">{'BASICINFORMATION'|@getFixedLabel}</div>
            </div>
        </div>
        <table class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
    		<tr>
    			<td colspan="4" width="100%" style="padding:0;">
        			<table class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
        				<tr>
                        {if $GROUPEMAIL == 'Emails' || $GROUPEMAIL == 'MassSMS'}
                            <td width="5%" align="right" ><span class="redFont">*</span></td>
                            <td>
                                <span tag='view_title_label'>{'Group_name'|@getFixedLabel}</span><input class="commonTextBoxPop" type="text" {if $NOVIEWNAME eq 'All'} readonly {/if} name='viewName' value="{$VIEWNAME}" size="40" style="box-sizing: border-box;width: 235px;"/>
                            <td width="60%" colspan="3">
                        {else}
                            {*wym 查询分类页面优化(咨询hzx)*}
        					<td width="5%" align="left" >
                                <span class="redFont">*</span><span tag='view_title_label'>{'Category_Name'|@getFixedLabel}</span>&nbsp;&nbsp;
                            </td>
                            <td>
                                <input class="ld-input-inner width180"{if $PREVIEWNAME eq 'All'} readonly {/if} type="text" name='viewName' value="{$VIEWNAME}" size="40" style="box-sizing: border-box;"/>
                            </td>
                            {if $MODULE neq 'Reminds'}
                                <td colspan="3">
                                {* {if $CHECKED eq 'checked'} *}
                                        <input type="checkbox" style="vertical-align:middle; margin-top:-2px; margin-bottom:1px;" name="setDefault" {if $CHECKED eq 'checked'}value="1"  checked {else}value="0"{/if} id="setDefault" onclick="showPopuptips(this,'{'Set_Default'|@getFixedLabel}{'commasymbols'|@getFixedLabel}{'EFFECTIVEAFTERPRESERVATION'|@getFixedLabel}');" />
                                {* {else} *}
                                    {* <input type="checkbox" style="vertical-align:middle; margin-top:-2px; margin-bottom:1px;" name="setDefault" value="0" onclick="showPopuptips(this,'{'Set_Default'|@getFixedLabel}{'commasymbols'|@getFixedLabel}{'EFFECTIVEAFTERPRESERVATION'|@getFixedLabel}');"/> *}
                                {* {/if} *}
                                    <label for="setDefault">{'Set_Default'|@getFixedLabel}</label>
                            {/if}
                        {/if}
                            {if $MODULE neq 'Reminds'}
                                {if $CUSTOMVIEWID>0}
                                    {* 39006: pc端>单据列表界面>新建管理分类界面：“设为公开”默认为不勾选。（需要补丁）*}
                                    {if $STATUS eq 1}
                                        <input type="checkbox" style="vertical-align:middle; margin-top:-2px; margin-bottom:1px;margin-left: 25px;" name="setStatus" value="1" onclick="showPopuptips(this,'{'Make_Public'|@getFixedLabel}{'commasymbols'|@getFixedLabel}{'EFFECTIVEAFTERPRESERVATION'|@getFixedLabel}');" id="setStatus1" {if $setaslinkmodule }disabled checked{/if} /><label for="setStatus1">
                                    {elseif $STATUS eq 2 || $STATUS eq ''}
                                        <input type="checkbox" style="vertical-align:middle; margin-top:-2px; margin-bottom:1px;margin-left: 25px;" name="setStatus" value="2" checked onclick="showPopuptips(this,'{'Make_Public'|@getFixedLabel}{'commasymbols'|@getFixedLabel}{'EFFECTIVEAFTERPRESERVATION'|@getFixedLabel}');"  {if $setaslinkmodule }disabled{/if}id=""setStatus2/><label for="setStatus2">
                                    {elseif $STATUS eq 3 || $STATUS eq 0}
                                            {if $LANUGAGETYPE eq 'en'}
                                                <input type="checkbox" style="vertical-align:middle; margin-top:-2px; margin-bottom:1px;margin-left: 10px;" name="setStatus" value="3" checked onclick="showPopuptips(this,'{'Make_Public'|@getFixedLabel}{'commasymbols'|@getFixedLabel}{'EFFECTIVEAFTERPRESERVATION'|@getFixedLabel}');"  {if $NOVIEWNAME eq 'All' || $setaslinkmodule }disabled{/if} id="setStatus3"/><label for="setStatus3">
                                            {else}
                                                <input type="checkbox" style="vertical-align:middle; margin-top:-2px; margin-bottom:1px;margin-left: 25px;" name="setStatus" value="3" checked onclick="showPopuptips(this,'{'Make_Public'|@getFixedLabel}{'commasymbols'|@getFixedLabel}{'EFFECTIVEAFTERPRESERVATION'|@getFixedLabel}');"  {if $NOVIEWNAME eq 'All' || $setaslinkmodule }disabled{/if} id="setStatus3"/><label for="setStatus3">
                                            {/if}
                                    {/if}
                                {else}
                                    {if $LANUGAGETYPE eq 'en'}
                                    <input type="checkbox" style="vertical-align:middle; margin-top:-2px; margin-bottom:1px;margin-left: 10px;" name="setStatus" value="3" onclick="showPopuptips(this,'{'Make_Public'|@getFixedLabel}{'commasymbols'|@getFixedLabel}{'EFFECTIVEAFTERPRESERVATION'|@getFixedLabel}');"  id="setStatus_3" {if $setaslinkmodule }disabled checked{/if} /><label for="setStatus_3">
                                    {else}
                                    <input type="checkbox" style="vertical-align:middle; margin-top:-2px; margin-bottom:1px;margin-left: 25px;" name="setStatus" value="3" onclick="showPopuptips(this,'{'Make_Public'|@getFixedLabel}{'commasymbols'|@getFixedLabel}{'EFFECTIVEAFTERPRESERVATION'|@getFixedLabel}');"  id="setStatus_3" {if $setaslinkmodule }disabled checked{/if} /><label for="setStatus_3">
                                    {/if}
                                {/if}
                                {'Make_Public'|@getFixedLabel}</label>
                                {if $GROUPEMAIL != 'Emails' && $GROUPEMAIL != 'MassSMS' &&$MCSHOW=='yes'}
                                    {* {if $MCHECKED eq 'checked'} *}
                                    {if $LANUGAGETYPE eq 'en'}
                                        <input type="checkbox" style="vertical-align:middle; margin-top:-2px; margin-bottom:1px;margin-left: 10px;" name="setMetrics" {if $MCHECKED eq 'checked'}value="1" checked {else}value="0"{/if} id="setMetrics" onclick="showPopuptips(this,'{'DISPLAYINHOME'|@getFixedLabel}{'commasymbols'|@getFixedLabel}{'EFFECTIVEAFTERPRESERVATION'|@getFixedLabel}');"/>
                                    {* {else} *}
                                    {else}
                                        <input type="checkbox" style="vertical-align:middle; margin-top:-2px; margin-bottom:1px;margin-left: 25px;" name="setMetrics" {if $MCHECKED eq 'checked'}value="1" checked {else}value="0"{/if} id="setMetrics" onclick="showPopuptips(this,'{'DISPLAYINHOME'|@getFixedLabel}{'commasymbols'|@getFixedLabel}{'EFFECTIVEAFTERPRESERVATION'|@getFixedLabel}');"/>
                                        {* <input type="checkbox" style="vertical-align:middle; margin-top:-2px; margin-bottom:1px;margin-left: 25px;" name="setMetrics" value="0"  onclick="showPopuptips(this,'{'DISPLAYINHOME'|@getFixedLabel}{'commasymbols'|@getFixedLabel}{'EFFECTIVEAFTERPRESERVATION'|@getFixedLabel}');"/> *}
                                    {* {/if} *}
                                    {/if}
                                    <label for="setMetrics">{'DISPLAYINHOME'|@getFixedLabel}</label>
                                    <a style="cursor: pointer;" href="http://51mis.com.cn/forum.php?mod=viewthread&tid=307&fromuid=1" target="_blank"><b id="askgreyHelp" style="margin:-6px 0 -4px 0;" class="icon-homeimg icon-askgrey-help"></b></a>
                                {/if}
                                    {* @edit:dong @date:2020/12/23 @reason:  数据分类不公开 设置连接模块不可选 *}
                                    <input type="checkbox" style="vertical-align:middle; margin-top:-2px; margin-bottom:1px;{if $LANUGAGETYPE eq 'en'}margin-left: 10px;{else}margin-left: 25px;{/if}"  
                                        {if $setaslinkmodule} checked {/if}
                                        {* wym 230421 链接模块勾选时默认勾选公开*}
                                        {if $CUSTOMVIEWID>0 && ($STATUS eq 3 || $STATUS eq 0) && $NOVIEWNAME eq 'All'}  {else}onclick="changeSetaslinkmodule(this)" {/if}
                                        name="setaslinkmodule" value="1" id="setaslinkmodule"/>
                                    <label for="setaslinkmodule">{'SETASLINKMODULE'|@getFixedlabel}</label>
                                </td>
                            {/if}
        				</tr>
                        {if $MODULE neq 'Reminds'}
                            <tr>
                                <td width="5%" align="left" >
                                    <span class="redFont">*</span><span tag='view_title_label'>{'Subgroups'|@getFixedLabel}</span>&nbsp;&nbsp;
                                </td>
                                <td>
                                    {if $PREVIEWNAME eq 'All'}
                                    <input class="ld-input-inner width180"{if $PREVIEWNAME eq 'All'} readonly {/if} type="text" name='viewName' value="{'ALL'|@getFixedLabel}" size="40" style="box-sizing: border-box;"/>
                                    {else}
                                    <select class="groupSelectPop" name="groupSelectPop" id="groupSelectPop">
                                        {foreach key=sequence item=group from=$CUSTOMVIEWGROUPLIST['groupList']}
                                            <option {if $group.groupid eq $CUSTOMVIEWGROUP||($group.groupid eq 'ungrouped' && $CUSTOMVIEWGROUP eq 0)} selected {/if} value="{$group.groupid}">{$group.group_name}</option>
                                        {/foreach}
                                    </select>
                                    {/if}
                                </td>
                                <td colspan="3">
                                    {*<input type="checkbox" style="vertical-align:middle; margin-top:-2px; margin-bottom:1px;" name="setAsMyCommon" {if $COMMONCUSTOMVIEW eq 'yes'}value="1"  checked {else}value="0"{/if} id="setAsMyCommon" onclick="showPopuptips(this,'{'SETASMYCOMMON'|@getFixedLabel}{'commasymbols'|@getFixedLabel}{'EFFECTIVEAFTERPRESERVATION'|@getFixedLabel}');" />
                                    <label for="setAsMyCommon">{'SETASMYCOMMON'|@getFixedLabel}</label>*}
                                </td>
                            </tr>
                            {*wym XUQIU1001870 查询分类增加多个排序字段*}
                            {foreach key = number item = sortorderarr from =$defaultsort name=sort}
                                {if $sortorderarr.columnname eq ''}
                                    {assign var="divdisplay" value=none}
                                {else}
                                    {assign var="divdisplay" value=block}
                                {/if}
                                <tr {if $RETURN_MODULE eq 'InventoryAccount' || $RETURN_MODULE eq 'InventoryQuery'} style="display:none"{/if} id="sortorder_tr{$number}" name="sortorder_tr" rowindex="{$number}">
                                    <td width="5%" style="padding-left:10px;">{'SORTORDER'|@getFixedLabel}&nbsp;</td>
                                    <td>
                                        <select class="commonSelectPop" name="sortselect{$number}" id="sortselect{$number}">
                                            {foreach item=sortinfo from =$SORTARR}
                                                <option {if  $sortorderarr.columnname eq $sortinfo.columnname} selected {/if} value="{$sortinfo.columnname}">{$sortinfo.fieldlabel}</option>
                                            {/foreach}
                                        </select>
                                    </td>
                                    <td>
                                        <div id="sortdiv{$number}" style="display:{$divdisplay};">
                                            <input type="radio" style="margin-top: -3px;" id="sortorderasc{$number}" name="sortorder{$number}" {if $sortorderarr.sort eq 'asc'} checked {elseif $sortorderarr.columnname eq ''} checked {/if} value="asc" /><label for="sortorderasc{$number}"> {'ASCENDINGORDER'|@getFixedLabel}&nbsp;&nbsp;</label>
                                            <input type="radio" style="margin-top: -3px;" id="sortorderdesc{$number}" name="sortorder{$number}" {if $sortorderarr.sort eq 'desc'} checked {/if} value="desc" /><label for="sortorderdesc{$number}"> {'DESCENDINGORDER'|@getFixedLabel}</label>
                                            &nbsp;&nbsp;<a style="display: none" id="sortdelete{$number}"  title="{'DELETE'|@getFixedLabel}" onclick="DataCategoryListPopup.deleteCustomorder({$number})">{'DELETE'|@getFixedLabel}</a>
                                        </div>
                                    </td>
                                </tr>
                            {/foreach}
                            <tr>
                                <td colspan="3">
                                    &nbsp;&nbsp;<a title="{'ADDSORTORDER'|@getFixedLabel}" onclick="DataCategoryListPopup.addCustomorder(this)">{'ADDSORTORDER'|@getFixedLabel}</a>
                                </td>
                            </tr>
                        {/if}
        			</table>
    			</td>
    		</tr>
        </table>
        <div class="pad10">
            <div class="ld-pop-contnet-title-items">
                <div class="ld-pop-contnet-title-item">{'SETTINGS'|@getFixedLabel}{'CONDITION'|@getFixedLabel}</div>
            </div>
        </div>
        <table class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
            <tr>
                <td colspan="4" class="pad10">
                   <div id="mnuTab2" style="display: block;">
                       {if $JS_DATEFORMAT eq ''}
                           {assign var="JS_DATEFORMAT" value='YYYY-mm-ddd'|@parse_calendardate}
                       {/if}
                       <input type="hidden" id="jscal_dateformat" name="jscal_dateformat" value="{$JS_DATEFORMAT}" />
                       <input type="hidden" id="image_path" name="image_path" value="{$IMAGE_PATH}" />
                       <input type="hidden" name="advft_criteria" id="advft_criteria" value="" />
                       <input type="hidden" name="advft_criteria_groups" id="advft_criteria_groups" value="" />
                       <div style="width: 100%;" name='adv_filter_div' id="adv_filter_div" class="advanceFilterNoDashedDiv">
                       </div>
                	</div>
                </td>
            </tr>
        </table>
        {if $MORE_LISTVIEW eq 1}
            <div class="pad10">
                <div class="ld-pop-contnet-title-items">
                    <div class="ld-pop-contnet-title-item">{'DISPLAYCOLUMNSETTINGS'|@getFixedLabel}</div>
                </div>
            </div>
        {/if}
        <table class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
            <input type="hidden" id="more_listview" name="more_listview" value="{$MORE_LISTVIEW}" />
            {if $MORE_LISTVIEW eq 1}
                <tr>
                    <td colspan="4" style="border-bottom: none;">{include file="ProductListView.tpl"}</td>
                </tr>
            {else}
                <input type="hidden" value="100" id="PageWidthPercent" name="PageWidthPercent"/>
            {/if}
            {if $GROUPEMAIL == 'Emails' || $GROUPEMAIL == 'MassSMS'}
            {else}
                {if $MORE_LISTVIEW == 0}
            		<tr>
                		<td colspan="4" class="f1">
                		  {'Select_field'|@getFixedLabel}
                		</td>
            		</tr>
            		<tr>
                		<td class="padL10"></td>
                		<td class="padL10"></td>
                	    <td class="padL10"></td>
                        <td class="padL10"></td>
            		</tr>
            		<tr>
            		    <td class="padL10"></td>
                        <td class="padL10"></td>
                        <td class="padL10"></td>
                        <td class="padL10"></td>
            		</tr>
            		<tr>
            		    <td class="padL10"></td>
            		    <td>&nbsp;</td>
            		    <td>&nbsp;</td>
            		    <td>&nbsp;</td>
            		</tr>
                {/if}
            {/if}
            <tr style="display:none;">
                <td colspan="4">
                    <table align="center" border="0" cellpadding="0" cellspacing="0" width="100%" style="display:none;">
                        <tr>
                            <td>
                                <table border="0" cellpadding="3" cellspacing="0" width="100%">
                                    <tr>
                                        {if $STDCOLUMNSCOUNT neq 0}
                                            <td style="width: 100px;font-size: 15px;" nowrap class="dvtSelectedCellCommon dvtSelectedCell" id="pi" onclick="fnLoadCvValues('pi','mi','dv_customview_stdfiler','mnuTab2')">
                                                <b>{'Basic_queries'|@getFixedLabel}</b>
                                            </td>
                                            <td class="dvtUnSelectedCell" style="width: 100px;font-size: 15px;" align="center" nowrap id="mi" onclick="fnLoadCvValues('mi','pi','mnuTab2','dv_customview_stdfiler')">
                                                <b>{'Advanced_Search'|@getFixedLabel}</b>
                                            </td>
                                        {else}
                                            <td class="dvtSelectedCellCommon dvtSelectedCell" style="width: 100px;" align="center" nowrap id="mi">
                                                <b>{'Advanced_Search'|@getFixedLabel}</b>
                                            </td>
                                        {/if}
                                        <td class="dvtTabCache" nowrap style="width:55%;">&nbsp;</td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                		<tr>
                    		<td align="left" valign="top">
                        		{if $STDCOLUMNSCOUNT eq 0}
                                    {assign var=stddiv value="style=display:none"}
                                    {assign var=advdiv value="style=display:block"}
                                {else}
                                    {assign var=stddiv value="style=display:block"}
                                    {assign var=advdiv value="style=display:none"}
                                {/if}
                    		    <div id="dv_customview_stdfiler">
                        		    <table width="100%" cellspacing="0" cellpadding="5" class="dvtContentSpace">
                                        <tr>
                                            <td>
                                    			<table width="98%" border="0" cellpadding="5" cellspacing="0" align="center">
                                    			    <tr><td colspan="2" class="TitleHeading" style="font-size: 15px;display:none;"><b>{'EASYTIMEFILTER'|@getFixedLabel}</b></td></tr>
                                                    {*{include file="standardFilterPick.tpl"}*}
                                    			    <tr>
                                                        <td align="right" class="dvtCellLabel">{'Start_Date'|@getFixedLabel} </td>
                                    			        <td width="25%" align=left class="dvtCellInfo">
                                    			            {if $STDFILTERCRITERIA.0.selected eq "selected" || $CUSTOMVIEWID eq ""}
                                    				            {assign var=img_style value="visibility:visible"}
                                    				            {assign var=msg_style value=""}
                                    			            {else}
                                    				            {assign var=img_style value="visibility:hidden"}
                                    				            {assign var=msg_style value="readonly"}
                                    			            {/if}
                                    			            <input name="startdate" id="jscal_field_date_start" type="text" size="15" readonly="readonly" class="Wdate btn-radius-system" style="font-size: 13px;" value="{$STARTDATE}" {$msg_style} onClick="WdatePicker()">
                                    				     </td>
                                                    </tr>
                                    			    <tr>
                                                        <td align="right" class="dvtCellLabel">{'End_Date'|@getFixedLabel} </td>
                                      			        <td width="25%" align=left class="dvtCellInfo">
                                    			            <input name="enddate" {$msg_style} id="jscal_field_date_end" type="text" size="15" readonly="readonly" class="Wdate btn-radius-system" style="font-size: 13px;" value="{$ENDDATE}" onClick="WdatePicker()">
                                    			        </td>
                                    			    </tr>
                                    			</table>
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                                <div id="mnuTab2" {$advdiv}  style="display:none;">
                               		<table width="100%" cellspacing="0" cellpadding="5" class="dvtContentSpace">
                            			<tr><td>
                                            <table width="99%" border="0" cellpadding="5" cellspacing="0" align="center">
                                            <tr>
                                                <td>
                                                 {*{include file="AdvanceFilterCustViewPopup.tpl"}*}
                                                </td>
                                            </tr>
                                            </table>
                            			</td></tr>
                            		</table>
                            	</div>
            	            </td>
            	        </tr>
            	    </table>
	            </td>
	        </tr>
        </table>
    </form>
</div>
{$JAVASCRIPT}
</div>
<script language="javascript" type="text/javascript">
var k;
var colOpts;
var manCheck = new Array({$MANDATORYCHECK});
var viewCopy='{$viewCopy}';
</script>