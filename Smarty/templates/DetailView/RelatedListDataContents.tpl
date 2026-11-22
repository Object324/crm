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
<script type="text/javascript">

DocmentWriteJs("include/js/modules/{$RELATED_MODULE}/{$RELATED_MODULE}.js","{$RELATED_MODULE}_js")
</script>
<script language="JavaScript" type="text/javascript" src="include/js/cls_RelatedAdvanceSet.js"></script>
{*// @edit:dong @date:2020/07/24 @reason: bug0042099  表单推广）表单推广明细界面-相关-客户或者销售线索-点击一下进入明细界面，推进区块，推进后界面显示异常*}
{if $MODULE == 'SocialPromotion'}
	<script type="application/javascript" src="include/js/modules/Accounts/Accounts.js"></script>
{/if}
{if $RELATED_MODULE eq 'Singin'}
<script type="text/javascript" src="include/js/modules/OftenUseReport/OftenUseReport.js"></script>
{/if}
 {if $RELATED_MODULE eq 'Products' && $MODULE eq 'PriceBooks'}
	 <script type="text/javascript" src="include/js/modules/PriceBooks/PricebooksImportProduct.js"></script>
 {/if}

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
			{elseif $RELATED_MODULE eq 'ReadRecord' }
				{'ReadingState'|@getFixedLabel}
            {else}
                {$RELATED_MODULE|@getTranstab}
            {/if}
        </span>
    </div>
    {*zkt 20220920 BUG0056731签到日志，当没有按钮的时候，不要有这个间隙*}
    <div class="Top" {if is_array($RELATEDLISTDATA.entries) && $RELATEDLISTDATA.entries|@count <= 0 && $MODULE eq 'WeChatUser'} style="display:none"{/if}>
		<table class="bgwhite" width="100%" border="0" cellspacing="0" cellpadding="0" style="100%">
			<tr>
				{if $GETEDITDETAIL eq 'yes' && $SHOWDETAILLOG neq 'yes'}
				{else}
	  			<td class="DivCL b" style="width: 70%;" >
					{* “隐藏富文本框的修改日志 ”按扭---无单据分录   zl XUQIU1000760 富文本框隐藏按钮*}
					{if $SHOWDETAILLOG eq 'no' && $RICHTEXTHIDE neq ''}
						<div class="D_btn_box b D_anu_a">
							{'RICHTEXTHIDE'|@getFixedLabel}
							{if $RICHTEXTHIDE eq 'yes'}
								<input id="Richtexthide" type="checkbox" data-module="{$MODULE}" onclick="Hiderichtext(this)" class="second_switch" checked/>
							{else}
								<input id="Richtexthide" type="checkbox" data-module="{$MODULE}" onclick="Hiderichtext(this)" class="second_switch" />
							{/if}
						</div>
					{/if}
		          	<ul class="D_btn_box b">
						<li class="D_anu_a">
							{$RELATEDLISTDATA.CUSTOM_BUTTON}
						</li>
	    				{if $HEADER eq 'Contacts' && $MODULE neq 'Campaigns' && $MODULE neq 'Accounts' && $MODULE neq 'Potentials' && $MODULE neq 'Products' && $MODULE neq 'Vendors'}
	    					{if $MODULE eq 'Calendar'}
				                <li class="D_anu_a">
				    				<input alt="{$APP.LBL_SELECT_CONTACT_BUTTON_LABEL}" title="{$APP.LBL_SELECT_CONTACT_BUTTON_LABEL}" accessKey="" class="edit" value="{$APP.LBL_SELECT_BUTTON_LABEL} {$APP.Contacts}" LANGUAGE=javascript onclick='return window.open("index.php?module=Contacts&return_module={$MODULE}&action=Popup&popuptype=detailview&select=enable&form=EditView&form_submit=false&recordid={$ID}{$search_string}","test","width=640,height=602,resizable=0,scrollbars=0");' type="button"  name="button">
				                </li>
	    					{elseif $MODULE neq 'Services' && $MOREPERMISSION eq 'yes'}
				                <li class="D_anu_a">
				      				<input title="{$APP.LBL_ADD_NEW} {$APP.Contact}" accessyKey="F" class="createauto" onclick="this.form.action.value='EditView';this.form.module.value='Contacts'" type="submit" name="button" value="{$APP.LBL_ADD_NEW} {$APP.Contact}">
				                </li>
	    					{/if}
	    				{elseif $HEADER eq 'Users' && $MODULE eq 'Calendar'}
			                <li class="D_anu_a">
			    				<input title="Change" accessKey="" tabindex="2" type="button" class="editauto" value="{$APP.LBL_SELECT_USER_BUTTON_LABEL}" name="button" LANGUAGE=javascript onclick='return window.open("index.php?module=Users&return_module=Calendar&return_action={$return_modname}&activity_mode=Events&action=Popup&popuptype=detailview&form=EditView&form_submit=true&select=enable&return_id={$ID}&recordid={$ID}","test","width=640,height=525,resizable=0,scrollbars=0")';>
			                </li>
	  					{/if}
			            <li class="D_anu_a" style="display:none">
			  				<a href="javascript:void(0);" style="display:none" id='refresh-{$RELATED_MODULE}' 
			      				onclick='resetRelated({$RELATIONID});return false;'><span>{'REFRESH'|@getFixedLabel}</span></a>
			            </li>
			            {if $CUSTOMVIEW_OPTION neq ''}
							{if $HEADER eq 'PublicAnnouncement'}
								{*@edit:liushuai,2021-04-16,reason:【ID1001520】公告增加阅读数和阅读记录*}
								<li class="D_anu_a" style="width: 280px;">
									<div class="SelectCustomViewlabel"><span>{'ReadingState'|@getFixedLabel}</span></div>
									<div class="xiangguan">{include file='SelectCustomView.tpl'}</div>
								</li>
							{elseif $RELATED_MODULE neq 'Emails'}{*模块相关信息邮件管理没有数据分类*}
								<li class="D_anu_a" style="width: 210px;">
									<div class="SelectCustomViewlabel"><span>{'DATACATEGORY'|@getFixedLabel}</span></div>
									<div class="xiangguan">{include file='SelectCustomView.tpl'}</div>
								</li>
								<li class="D_anu_a" tag="firstnode" id="categoryAdvsearr">
									<a href="javascript:void(0);" relatedid={$RELATIONID} relatetag={$RELATED_MODULE} onclick="DetailViewRelation.HighersearchPopup(event,ld(this))"><b class="icon-categorybtn categoryAdvsear-search" ></b>{'CUSTOMIZESEARCH'|@getFixedLabel}</a>
								</li>
								{*wym 240122 XUQIU1002043 单据相关信息显示数据的查询规则可定义*}
								{if $ISADMIN eq 1 && $SHOWADVANCESET eq 1}
									<li class="D_anu_a" tag="firstnode" id="categoryAdvset">
										<a href="javascript:void(0);" relatedid={$RELATIONID} relatetag={$RELATED_MODULE} onclick="cls_RelatedAdvanceSet.getInstance().create('{$MODULE}',ld(this))"><b class="icon-categorybtn categoryAdvsear-setting" ></b>{'Relatedquerycondition'|@getFixedLabel}</a>
									</li>
								{/if}
							{/if}
			            {/if}
                        {if $SHOWDETAILLOG eq 'yes'}
{*							wyt 220926 BUG0056901 图中“单据表头”，“单据分录”选项增加边框，或者鼠标悬浮的背景色*}
                            <li class="D_anu_a ld-viewhistory-Nav" style="width: 80px;">
								<div class="SelectCustomViewlabel" >
									{*wsh 2024-07-02 XUQIU20240607-08 单据查看详情界面，相关信息操作日志，“编辑”操作详情增加“修改日志详情”操作按钮*}
									{if $GETEDITDETAIL eq 'yes'}
										<a name="documentheader"  id="documentheader" {if $LOGTYPE neq 'yes'}style="color:#3B7CFF;font-weight: bold" class="current"{/if} module = "{$MODULE}" record="{$ID}" relationId="{$RELATIONID}" logId="{$LOGID}" pop="no" changedon = "{$CURLOGINFO.changedon}" whodid = "{$CURLOGINFO.username}" onclick="get_edit_detail_log(ld(this))" title="{'DOCUMENTHEADER'|@getFixedLabel}">
									{else}
										<a name="documentheader"  id="documentheader" {if $LOGTYPE neq 'yes'}style="color:#3B7CFF;font-weight: bold" class="current"{/if} onclick="getdetailviewhistory(this)" relatetag="{$RELATED_MODULE}" title="{'DOCUMENTHEADER'|@getFixedLabel}" relatedid="{$RELATIONID}">
									{/if}
                                <span>{'DOCUMENTHEADER'|@getFixedLabel}</span>
                                </a>
                                </div>
							</li>
                            <li class="D_anu_a ld-viewhistory-Nav" style="width: 80px;">
								<div class="SelectCustomViewlabel" >
									{if $GETEDITDETAIL eq 'yes'}
									<a name="documentheader"  id="documentheader" {if $LOGTYPE eq 'yes'}style="color:#3B7CFF;font-weight: bold" class="current"{/if} module = "{$MODULE}" record="{$ID}" relationId="{$RELATIONID}" logId="{$LOGID}" detaillog="yes" pop="no" changedon = "{$CURLOGINFO.changedon}" whodid = "{$CURLOGINFO.username}" onclick="get_edit_detail_log(ld(this))" title="{'DOCUMENTHEADER'|@getFixedLabel}">
									{else}
										<a name="documententry" id="documententry" {if $LOGTYPE eq 'yes'}style="color:#3B7CFF;font-weight: bold" class="current"{/if}  onclick="getdetailviewhistory(this)" relatetag="{$RELATED_MODULE}" title="{'DOCUMENTHEADER'|@getFixedLabel}" relatedid="{$RELATIONID}" detaillog="yes">
									{/if}
                                <span>{'DOCUMENTENTRY'|@getFixedLabel}</span>
                                </a>
                                </div>
							</li>
							{* 显示“隐藏富文本框的修改日志 ”按扭---有单据分录   zl XUQIU1000760 富文本框隐藏按钮*}
							{if $RICHTEXTHIDE neq ''}
								<li class="D_anu_a" {if $LOGTYPE eq 'yes'}style="display:none"{/if}>
									{'RICHTEXTHIDE'|@getFixedLabel}
									{if $RICHTEXTHIDE eq 'yes'}
										<input id="Richtexthide" type="checkbox" data-module="{$MODULE}" onclick="Hiderichtext(this)" class="second_switch" checked/>
									{else}
										<input id="Richtexthide" type="checkbox" data-module="{$MODULE}" onclick="Hiderichtext(this)" class="second_switch" />
									{/if}
								</li>
	 						{/if}
                        {/if}
					</ul>

	  			</td>
				{/if}
				{if $GETEDITDETAIL neq 'yes'}
	  			<td class="DivCR" valign="middle">
	  				<div class="PageDiv0"  style="margin-top: 4px;margin-bottom:4px;">
						<div class="ld-flex-start">
							<div class="ld-pagenum-div">{$RELATEDLISTDATA.navigation.0}</div>
	  						{$RELATEDLISTDATA.navigation.1}
	  					</div>
	  				</div>
	  			</td>
				{/if}
			</tr>
		 </table>
	</div>
	<input type="hidden" id="viewname_{$RELATED_MODULE}" name="viewname_{$RELATED_MODULE}" value= "{$VIEWID}" />
	<input type="hidden" id="hidden_related_list" name="hidden_related_list" value="yes" />
	<input type="hidden" id="hidden_related_module_{$RELATED_MODULE}" name="hidden_related_module_{$RELATED_MODULE}" value="{$RELATED_MODULE}" />
	<input type="hidden" id="hidden_related_id_{$RELATED_MODULE}" name="hidden_related_id_{$RELATED_MODULE}" value="{$RELATIONID}" />
	<input type="hidden" id="hidden_start" name="hidden_start" value="{$START}" />
	<div id="hdScrolllistentries_yy_{$RELATED_MODULE}" name="hdScrolllistentries_yy_{$RELATED_MODULE}" style="position:relative;">
        <div style=" visibility: visible; top: 194px;overflow:hidden;" id="resize_header_table_divid_{$RELATED_MODULE}">
            <div  style="float:left; padding-right:20px">
                {if $RELATED_MODULE eq 'Digiwinorders' || $RELATED_MODULE eq 'Digiwintickets' || $RELATED_MODULE eq 'Kingdeeorders' || $RELATED_MODULE eq 'Kingdeequotes'}
					<table id="resize_header_tableid_{$RELATED_MODULE}" name="resize_header_tableid_{$RELATED_MODULE}" class="listEntries" style="table-layout:auto;" border=0 cellspacing=1 cellpadding="0" style="width:{if $RELATEDLISTDATA.total_width >0}{$RELATEDLISTDATA.total_width}px;{else}100%{/if}">
				{else}
					{if $MODULE eq 'Campaigns' && ($RELATED_MODULE eq 'Contacts' || $RELATED_MODULE eq 'Leads' || $RELATED_MODULE eq 'Accounts')
							&& is_array($RELATEDLISTDATA.entries) && $RELATEDLISTDATA.entries|@count > 0}
						<table id="resize_header_tableid_{$RELATED_MODULE}" name="resize_header_tableid_{$RELATED_MODULE}" class="listEntries fir-center" style="width:{if $RELATEDLISTDATA.total_width >0}{$RELATEDLISTDATA.total_width}px {else}100%{/if}" border=0 cellspacing=1 cellpadding="0" >
					{else}
						<table id="resize_header_tableid_{$RELATED_MODULE}" name="resize_header_tableid_{$RELATED_MODULE}" class="listEntries" border=0 cellspacing=1 cellpadding="0" style="width:{if $RELATEDLISTDATA.total_width >0}{$RELATEDLISTDATA.total_width}px {else}100%{/if}" >
					{/if}
				{/if}
                    <tr>
						{if $MODULE eq 'Campaigns' && ($RELATED_MODULE eq 'Contacts' || $RELATED_MODULE eq 'Leads' || $RELATED_MODULE eq 'Accounts')
							&& is_array($RELATEDLISTDATA.entries) && $RELATEDLISTDATA.entries|@count > 0}
							<th class="firstChild" style="text-align:center;">
								<input name ="{$RELATED_MODULE}_selectall" class="checkbox-item j-all-checkbox" id="{$MODULE}_{$RELATED_MODULE}_selectCurrentPageRec" onclick="rel_toggleSelect(this.checked,'{$MODULE}_{$RELATED_MODULE}_selected_id','{$RELATED_MODULE}');"  type="checkbox">
							</th>
						{/if}
						{foreach key=index item=_HEADER_FIELD from=$RELATEDLISTDATA.header name=relheadforeach}
							{if $_HEADER_FIELD eq 'OPERATING'|@getFixedLabel}

								<th width="{$RELATEDTABLEWIDTH}" tag="{intval($index)+1}" >{$_HEADER_FIELD}</th>

							{else}
								<th style="width:{$RELATEDLISTDATA.fieldwidth[$index]}px;{if $LOGTYPE eq 'yes'}text-align:center;{/if}" {if $RELATED_MODULE eq 'ViewHistory' || $RELATED_MODULE eq 'RECORDSOFOPERATION'}tag="{$index}"{else}tag="{intval($index)+1}" {/if } 
									headermodule="{$RELATEDLISTDATA.headername.module[$index]}" headername="{$RELATEDLISTDATA.headername.fieldname[$index]}" >{$_HEADER_FIELD}</th>
							{/if}
						{/foreach}
					</tr>  
                </table>
            </div>
        </div>


		{*		没有内容增加最小高*}
		<div style="overflow:auto; {if $RELATEDLISTDATA.noofrows==0}min-height: 350px;{/if}" id="resize_content_table_divid_{$RELATED_MODULE}" name="resize_content_table_divid_{$RELATED_MODULE}">
            {*zkt 20220920 BUG0056732签到日志中，不应该有有横向滑动条*}
			<div  style="float:left; {if $RELATEDLISTDATA.total_width <= 0 && $RELATED_MODULE neq 'signlog' && $RELATED_MODULE neq 'Singin'}padding-right:0px{/if}">
			{if $RELATED_MODULE eq 'Digiwinorders' || $RELATED_MODULE eq 'Digiwintickets' || $RELATED_MODULE eq 'Kingdeeorders' || $RELATED_MODULE eq 'Kingdeequotes'}
				<table class="listEntries marT-53" style="table-layout:auto;" id="resize_content_tableid_{$RELATED_MODULE}" name="resize_content_tableid_{$RELATED_MODULE}" border=0 cellspacing=1 cellpadding="0" style="width:{if $RELATEDLISTDATA.total_width >0}{$RELATEDLISTDATA.total_width}px {else}100%{/if}" cellspacing=1 cellpadding="0">
			{else}
				{if $MODULE eq 'Campaigns' && ($RELATED_MODULE eq 'Contacts' || $RELATED_MODULE eq 'Leads' || $RELATED_MODULE eq 'Accounts')
						&& is_array($RELATEDLISTDATA.entries) && $RELATEDLISTDATA.entries|@count > 0}
					<table class="listEntries fir-center marT-53" id="resize_content_tableid_{$RELATED_MODULE}" name="resize_content_tableid_{$RELATED_MODULE}"border=0 style="width:{if $RELATEDLISTDATA.total_width >0}{$RELATEDLISTDATA.total_width}px {else}100%{/if}" cellspacing=1 cellpadding="0" >
				{else}
					<table id="resize_content_tableid_{$RELATED_MODULE}" name="resize_content_tableid_{$RELATED_MODULE}" class="listEntries marT-53" style="width:{if $RELATEDLISTDATA.total_width >0}{$RELATEDLISTDATA.total_width}px {else}100%{/if}" border=0 cellspacing=1 cellpadding="0" >
				{/if}
			{/if}
				<tr>
					{if $MODULE eq 'Campaigns' && ($RELATED_MODULE eq 'Contacts' || $RELATED_MODULE eq 'Leads' || $RELATED_MODULE eq 'Accounts')
						&& is_array($RELATEDLISTDATA.entries) && $RELATEDLISTDATA.entries|@count > 0}
						<th class="firstChild" style="text-align:center;">
							<input name ="{$RELATED_MODULE}_selectall" class="checkbox-item j-all-checkbox" id="{$MODULE}_{$RELATED_MODULE}_selectCurrentPageRec" onclick="rel_toggleSelect(this.checked,'{$MODULE}_{$RELATED_MODULE}_selected_id','{$RELATED_MODULE}');"  type="checkbox">
						</th>
					{/if}
					{foreach key=index item=_HEADER_FIELD from=$RELATEDLISTDATA.header name=relheadforeach}
						{if $_HEADER_FIELD eq 'OPERATING'|@getFixedLabel}

							<th width="{$RELATEDTABLEWIDTH}" tag="{intval($index)+1}">{$_HEADER_FIELD}</th>

						{else}
							<th style="width:{$RELATEDLISTDATA.fieldwidth[$index]}px" {if $RELATED_MODULE eq 'ViewHistory' || $RELATED_MODULE eq 'RECORDSOFOPERATION'} tag="{$index}"{else}tag="{intval($index)+1}" {/if } headermodule="{$RELATEDLISTDATA.headername.module[$index]}" headername="{$RELATEDLISTDATA.headername.fieldname[$index]}"  >{$_HEADER_FIELD}</th>
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
						<tr id="relation_{$RELATED_MODULE}_{$j}"  record="{$_RECORD_ID}" class="lvtColData" onmouseover="listOnMouseOver(ld(this), 'record')" onmouseout="listOnMouseOut(ld(this),'on', 'record')">
					{else}
						<tr id="relation_{$RELATED_MODULE}_{$j}" record="{$_RECORD_ID}" class="lvtColDataBj" onmouseover="listOnMouseOver(ld(this), 'record')" onmouseout="listOnMouseOut(ld(this),'On', 'record')">
					{/if}
						{if $MODULE eq 'Campaigns' && ($RELATED_MODULE eq 'Contacts' || $RELATED_MODULE eq 'Leads' || $RELATED_MODULE eq 'Accounts')}
							<td class="firstChild" style="text-align:center;" onclick="rel_check_object_parent_td(this)"><input class="checkbox-item j-all-checkbox" name="{$MODULE}_{$RELATED_MODULE}_selected_id" id="{$_RECORD_ID}" value="{$_RECORD_ID}" onclick="rel_check_object(this,'{$RELATED_MODULE}');" type="checkbox"  {$RELATEDLISTDATA.checked.$_RECORD_ID}></td>
						{/if}
						{foreach key=index item=_RECORD_DATA from=$_RECORD}
							 {* vtlib customization: Trigger events on listview cell onmouseover="vtlib_listview.trigger('cell.onmouseover', $(this))" onmouseout="vtlib_listview.trigger('cell.onmouseout', $(this))"*}
							{if $index|@istdRight:$RELATED_MODULE==true}
								{assign var="tdalign" value='right'}
							{else}
								{assign var="tdalign" value='left'}
							{/if}
							{if is_string($_RECORD_DATA) && $_RECORD_DATA|count_characters:true gt 800}
								<td width="40%" align="{$tdalign}">{$_RECORD_DATA}</td>
                            {elseif $index eq 'detail' && $LOGTYPE eq 'yes'}
                                {assign var=row value=0}
                                {foreach key=lineitem_id item=detailinfo from=$_RECORD_DATA}
                                    {assign var=row value=$row+1}
                                    {foreach key=columnname item=value from=$detailinfo}
                                        <td align="{$RELATEDLISTDATA.tdalign.$columnname}">
                                        <span {if $RELATEDLISTDATA.changedcolumn.$_RECORD_ID.$lineitem_id.$columnname eq 'yes'}style="color:red;"{/if}>{$value}</span></td>
                                    {/foreach}
                                    </tr>
                                    {if $row neq sizeof($_RECORD_DATA)}
										{*wym 1222 BUG0077668 带lvtColData的class listOnMouseOut传参得是小写的on*}
                                    <tr id="relation_{$RELATED_MODULE}_{$j}" record="{$_RECORD_ID}"  class="lvtColData" onmouseover="listOnMouseOver(ld(this), 'record')" onmouseout="listOnMouseOut(ld(this),'on', 'record')">
                                    {/if}
                                {/foreach}
                                </tr>
							{elseif $RELATED_MODULE eq 'ViewHistory' && $index|string_format:"%s" eq 'autowordwrap'}

							{else}
								<td {if $RELATED_MODULE eq 'SharedUsers' &&($index eq 'viewuserduty' || $index eq 'viewuserremark')} viewuserid='{$_RECORD_ID}' columnname='{$index}' onmouseover="showShareUserEdit(ld(this))"
                                             onmouseout="HideShareUseEdit(ld(this))" {/if}
                                             {if $LOGTYPE eq 'yes'}rowspan="{$RELATEDLISTDATA.rowspan.$_RECORD_ID}" align="{$RELATEDLISTDATA.tdalign.$index}"{else}align="{$tdalign}"{/if} {if count($_RECORD) eq intval($index)+1}class="lastChild"{/if}
											 {if ($RELATED_MODULE eq 'ViewHistory' && ($index eq 'prevalue' || $index eq 'postvalue') && $_RECORD.autowordwrap eq 'yes') ||($RELATED_MODULE eq 'OperationLogs' && $index eq 'operationdetails')}class="ld-wordwrap-listcontent"{/if}
											>
									{if $RELATED_MODULE eq 'SharedUsers'}
										<span name='td_content'> {if !empty($_RECORD_DATA)} {"\n"|str_replace:"<br>":$_RECORD_DATA} {/if} </span> 
                                   	{else}
                                  		{$_RECORD_DATA}
                                   	{/if}
                                    {if $RELATED_MODULE eq 'SharedUsers' }
                                        {if $index eq 'viewuserduty'}
                                            <a tag="edit"   style="float:right ;display:none">{'EDIT'|getFixedLabel}</a>
                                            <input  type="text" showtype="editshow"  class="detailedViewTextBox" name="{$index}"
                                             style="width:100%;display:none" value="{$_RECORD_DATA}" />
                                                
                                                
                                            <div  showtype='editshow' style="display:none">
                                                <a    name='save' style="float:left;">{'SAVE'|getFixedLabel}</a>
                                                <span   style="float:left;">{'OR'|getFixedLabel}</span>
                                                <a    name='cancel'   style="float:left;">{'CANCEL'|getFixedLabel}</a>
                                            </div>
                                        {else if $index eq 'viewuserremark'}
                                        
                                             <a tag="edit"  style="float:right;display:none" columnname="{$index}">{'EDIT'|getFixedLabel}</a>
                                             <textarea rows="8"  cols="10"
                                              showtype='editshow' style="width:98%;display:none;height:52px" class="detailedViewTextBox" name="{$index}" >
                                              {$_RECORD_DATA}
                                              </textarea>
                                           <div  showtype='editshow' style="display:none">
                                           
                                                <a style="float:left;" name='save'  >{'SAVE'|getFixedLabel}</a>
                                                 <span style="float:left;"  >{'OR'|getFixedLabel}</span>
                                                <a style="float:left;" name='cancel'  >{'CANCEL'|getFixedLabel}</a>
                                            </div>
                                        {/if}
                                        
                                    {/if}
                                </td>
							{/if}
							 {* END *}
						{/foreach}
					</tr>
				{foreachelse}
					{* <tr style="height: 25px;" bgcolor="white">
						<td colspan='{$smarty.foreach.relheadforeach.iteration}' align='center'><i style="display:inline-block;width:100%;text-align:center;">{'NONE'|@getFixedLabel}</i></td>
					</tr> *}
					<!--  BUG0069178 相关信息 空态优化  -->
					<tr>
						{if $GETEDITDETAIL neq 'yes'}
							{assign var=winheight value="0" }
						{else}
							{assign var=winheight value="250" }
						{/if}
						<td id="resize_content_tdid"  style="background-color:#FFF;height:{$winheight}px;padding: 0;" align="center" colspan='{$smarty.foreach.relheadforeach.iteration}'>
							{* <div class="warningTableContent" style="z-index:600;">
								<div class="wtc_img"><img src="themes/icon2023/ld-no-records.png"></div>
								<div class="wtc_content">{'NODATAFOUND'|@getFixedLabel}</div>
							</div> *}
							{include file="NoRecords.tpl"}
						</td>
					</tr>
				{/foreach}
				{if $RELATEDLISTDATA.totalfldhtml !=''}
					{$RELATEDLISTDATA.totalfldhtml}
				{/if}
			</table>
		</div>
        
        
	</div>
    {if $MODULE eq 'Campaigns' && ($RELATED_MODULE eq 'Contacts' || $RELATED_MODULE eq 'Leads' || $RELATED_MODULE eq 'Accounts')
    			&& is_array($RELATEDLISTDATA.entries) && $RELATEDLISTDATA.entries|@count > 0 && $RESET_COOKIE eq 'true'}
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
	//var popupobj=CrmPopup.getPopupObj('last');
	//40712: （http://51mis.com/demo/panlulu16/制冷行业账套 [^]）客户->客户查看详情界面，相关信息关联创建销售机会界面，输入“预计合同金额”数值保存后，该界面显示异常（后面
	//销售机会创建回款预测
	var popupobj=CrmPopup.getlastPopupObjByType(RelateListPage.type);
	popupobj.relatelistsizeobj=new List_ResizeTable(popupobj);

	popupobj.relatelistsizeobj.setRelatedResizeTable_Init('{$RELATED_MODULE}','');
	popupobj.reSizePosition();//设置相关信息全屏
	{literal}
	var crmpopupobj=CrmPopup.getPopupObj('last');
	if (ld('#'+crmpopupobj.divid+' #map_edit') && ld('#'+crmpopupobj.divid+' #map_edit').hasClass('tip-map-edit')){
		tooltip('.tip-map-edit',{transition: true, time: 200});
		crmpopupobj.mapedit_tooltip='yes';
	}
	{/literal}
</script>

	{if $MAPDATASHOW == 'yes'}
		<link type="text/css" href="{$CSSURL}themes/softed/ModuleMapView.css?v={$GLOBALMINVERSION}" rel="stylesheet"/>
		<div id="listmap_div" class="contactsmap_btndiv" data-frommodule="{$MODULE}" data-module="{$RELATED_MODULE}" date-fromrecordid="{$ID}" style="min-height: 420px;">

			<div style="background-color: #f5f5f7;width: 100%;overflow: hidden;">
				{if $RELATEDMODULEEDIT eq 'yes'}
					<input id="map_edit" type="button" data-frommodule="{$MODULE}" data-module="{$RELATED_MODULE}" data-fromrecordid="{$ID}" data-relatedid="{$RELATIONID}" data-tip="{'UNLOCKHINTSBYCLICK'|@getFixedLabel}" data-direction="bottom" data-type="position"
						   {if $LOCKSTATE eq 'yes'}
							   class="createauto tip-map-edit editBtnDisabled" disabled style="margin-left: 20px;margin-top: 10px;float:left;height: 32px"
						   {else}
							   class="createauto" style="margin-left: 20px;margin-top: 10px;float:left;height: 32px"
						   {/if}
						   onclick="editModuleMap(this);" value="{'EDIT'|@getFixedLabel}">
				{/if}
				<div id="map_show_fullScreen" style="float: left;border: 1px solid #cecece;margin-top: 12px;margin-left: 20px;cursor: pointer;height: 28px" title="{'FULLSCREEN'|@getFixedLabel}">
					<img src="themes/softed/images/fullscreen.png" style="padding: 2px;height: 26px;width: 26px;">
				</div>
				{if $RELATEDMODULEEDIT eq 'yes'}
					<div class="modulemapview-lock-div" style="height: 28px;{if $LOCKSTATE eq '-1'}display: none{/if}">
						<b id="map_lock"
								{if $LOCKSTATE eq 'yes'}
									class="modulemapview-lock"
								{else}
									class="modulemapview-unlock"
								{/if}
						   lockstate="{$LOCKSTATE}" record="{$ID}" frommodule="{$MODULE}" module="{$RELATED_MODULE}" fromrecordid="{$ID}" onclick="moduleMapLockClick(this)"></b>
					</div>
				{/if}
				<div style="float: right;height: 26px;margin-right: 20px;margin-top: 12px;">
					<div  id="map_drag" data-status="nochose"  style="float: left;border: 1px solid #cecece;margin-right: 5px;cursor: pointer;height: 28px" title="{'DRAGMAP'|@getFixedLabel}">
						<img src="themes/softed/images/Icon_grab.png" style="padding: 1px;">
					</div>
					<div style="float: left;border: 1px solid #cecece;margin-right: 5px;height: 28px">
						<div id="map_zoom_value" style="float: left;width: 50px;text-align: center;line-height: 26px;border-right: 1px solid #cecece;">100%</div>
						<div id="btu_zoom_in" title="{'AMPLIFIEDMAP'|@getFixedLabel}" data-type="in" style="float: left;border-right: 1px solid #cecece;cursor: pointer;"><img src="themes/softed/images/zoom-in.png" style="padding: 2px;width: 26px;height: 26px;"></div>
						<div id="btu_zoom_out" title="{'TEDUCETHEMAP'|@getFixedLabel}" data-type="out" style="float: left;cursor: pointer;"><img src="themes/softed/images/zoom-out.png" style="padding: 2px;width: 26px;height: 26px;"></div>
					</div>
					<div id="btu_zoom_restore" data-type="restore"  title="{'RESTOREMAPSIZE'|@getFixedLabel}"  style="float: left;border: 1px solid #cecece;height: 28px">
						<img src="themes/softed/images/collapse.png" style="padding: 2px;width: 26px;height: 26px;">
					</div>
				</div>
			</div>
			<!--模块图谱-->
			<div id="map_view_div" style="width: 100%;display: inline-block;height:100%;background-color:#f5f5f7;overflow:hidden;">

				<div class="modulemapview-design">
					<div id="modulemapview" class="modulemapview" style="transform:translate(0px,0px) scale(1); transform-origin: 50% 0px 0px;">
						<div class="node-wrap" id="node_wrap_div">
						</div>
					</div>
				</div>
			</div>
		</div>
	{/if}
</div>