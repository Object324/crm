{*<!--
/*********************************************************************************
  ** The contents of this file are subject to the lingdang CRM Public License Version 1.0
   * ("License"); You may not use this file except in compliance with the License
   * The Original Code is:  lingdang CRM Open Source
   * The Initial Developer of the Original Code is lingdang.
   * Portions created by lingdang are Copyright (C) lingdang.
   * All Rights Reserved.
 ********************************************************************************/
-->*}
<!--修改编码格式:统一编码：UTF-8-->
<script language="JAVASCRIPT" type="text/javascript" src="include/js/modules/Settings/bangwo8interface.js"></script>
<form action="index.php" method="post" name="bangwo8" >
<input type="hidden" name='mode'/>
<input type="hidden" name="module" value="Settings"/>
<input type="hidden" name="action" value="bangwo8interface"/>
<input type="hidden" name="blockidsetting" value="{$BLOCKIDSETTING}" id="blockidsetting"/>
<input type="hidden" name="fieldidsetting" value="{$FIELDIDSETTING}" id="fieldidsetting"/>
<input type="hidden" name="isshow" value="" id="isshow"/> 
{if $MODE neq 'edit'}
	<div class="main_grid_top">
		<div class="grid-view-title lfloat overflow-hidden">
			<span class="grid-view-name dinline-block lfloat">
				{'BANGWO8INTERFACE'|@getFixedLabel}{if $HelpHtml.Bangwo8Interface neq '' }{$HelpHtml.Bangwo8Interface}{/if}
			</span>
		</div>
		<div class="grid_tool">
			<div class="displayflex">
				<a href="javascript:;" class="ld-button ld-button-primary" onclick="bangwo8interface.edit()" title="{'EDIT'|@getFixedLabel}">{'EDIT'|@getFixedLabel}</a>
				{if $ISSHOW eq 'yes'}
					<a href="javascript:;" class="ld-button" onclick="bangwo8interface.Setbangwo8info('import');" title="{'CRMSYSTEMTONGBUBANGWOBASYSTEM'|@getFixedLabel}">{'CRMSYSTEMTONGBUBANGWOBASYSTEM'|@getFixedLabel}</a>
				{/if}
			</div>
		</div>
	</div>
{/if}
{if $MODE neq 'edit'}
	<div class="main_grid_box">
		<div class="grid-analysis-box">
			<div class="grid-analysis-header">
			</div>
			<div class="cont_wrap clear_float">
				<table class="settingTable" width="100%" border="0" cellspacing="0" cellpadding="0">
					<tr>
						<th colspan="2">{'BANGWO8ACCOUNT'|@getFixedLabel}</th>
					</tr>
					<tr id="setting_1001" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
						<td width="25%" style="min-width: 300px">{'WHETHERTOENABLE'|@getFixedLabel}</td>
						<td width="75%">
							<input type="checkbox" onclick="change_tablefield_presence(this,'{$ID}','bangwo8_presence')" verdorid='{$VENDORID}' class="second_switch"
								   {if $PRESENCE eq 1 || $PRESENCE eq ''}{else}checked=""{/if}/></td>
					</tr>
					<tr id="setting_1002" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
						<td>VendorID</td>
						<td>{$VENDORID}</td>
					</tr>
					<tr id="setting_1003" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
						<td>{'AUTHCODE'|@getFixedLabel}</td>
						<td>{$AUTHCODE}</td>
					</tr>
				</table>
				<table class="settingTable" width="100%" border="0" cellspacing="0" cellpadding="0">
					<tr>
						<th colspan="2">{'syncaccandcon'|@getFixedLabel}</th>
					</tr>
					<tr id="setting_1005" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
						<td width="25%" style="min-width: 300px">{'iscustomer'|@getFixedLabel}</td>
						<td width="75%">
							<input type="checkbox" onclick="change_tablefield_presence(this,'{$ID}','bangwo8_is_customer')" supportname="{$SUPPORTNAME}" class="second_switch"
								   {if $ISCUSTOMER eq 1 || $ISCUSTOMER eq ''}{else}checked=""{/if}/></td>
					</tr>
					<tr id="setting_1006" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
						<td>{'bangwowiththecustomer'|@getFixedLabel}</td>
						<td>{$SUPPORTNAME}</td>
					</tr>
					<tr id="setting_1007" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
						<td>{'bangwowiththecustomer'|@getFixedLabel}{'PASWD'|@getFixedLabel}</td>
						<td>*******</td>
					</tr>
				</table>
				<table class="settingTable" width="100%" border="0" cellspacing="0" cellpadding="0">
					<tr>
						<th colspan="2">{'Accounts'|@getTransTab}{'AND'|@getFixedLabel}{'Contacts'|@getTransTab}{'DATARANGE'|@getFixedLabel}</th>
					</tr>
				</table>
				<div id="mnuTab2" style="display: block;">
					<div style="padding:10px;">
						{include file='AutomaticReminds/AdvanceFilterRemindsdetial.tpl' SOURCE='customview'}
					</div>
				</div>
				<table class="settingTable" width="100%" border="0" cellspacing="0" cellpadding="0" style="border-top: 1px solid #dedede;">
					<tr>
						<th colspan="2">{'BANGWO8CUSTOMERSERVICE'|@getFixedLabel}</th>
					</tr>
				</table>
				{*wym 240508 BUG20240508-04 帮我把接口设置界面保持统一*}
				<table class='settingPopTable fir-center' border="0" cellspacing="0" cellpadding="0" width="100%" style="padding: 10px;">
						<tr>
							<th align="left" width="5%" >#</th>
							<th align='left' width='17%'  title="{'CUSTOMERSERVICEACCOUNT'|@getFixedLabel}">{'CUSTOMERSERVICEACCOUNT'|@getFixedLabel}</th>
							<th align='left' width='200px' title="{'SYSTEMSCOPECLIENTSANDCONTACTS'|@getFixedLabel}">{'SYSTEMSCOPECLIENTSANDCONTACTS'|@getFixedLabel}</th>
							<th align='left' width='200px' title="{'ADDOREDITRECORDONBANGWO8TOSYSTEMOPERATE'|@getFixedLabel}">{'ADDOREDITRECORDONBANGWO8TOSYSTEMOPERATE'|@getFixedLabel}</th>
							<th align='left' width='35px'  title="{'OPERATING'|@getFixedLabel}">{'OPERATING'|@getFixedLabel}</th>
						</tr>
						{foreach key=listdata_key item=data from=$LISTDATA name=listdataname}
							{assign var=i value=$smarty.foreach.listdataname.iteration}
							{if $i%2 neq 0}
								<tr id="setting_{$i}" class="lvtColData"  onmouseover="listOnMouseOver(ld(this));" onmouseout="listOnMouseOut(ld(this),'on');">
									{else}
								<tr id="setting_{$i}" class="lvtColDataBj"  onmouseover="listOnMouseOver(ld(this))" onmouseout="listOnMouseOut(ld(this),'On');">
							{/if}
							<td align="left" width="5%" >{$i}</td>
							<td title="{$data.supportname}">{$data.supportname}</td>
							<td title="{$data.view_username}">{$data.view_username}</td>
							<td title="{$data.user_name}">{$data.user_name}</td>
							<td align="left">
								<a class="Anu3_a" onclick="bangwo8interface.settingsBangwo8info(this,{$listdata_key})">{'SETTINGS'|@getFixedLabel}</a>
							</td>
							</tr>
						{/foreach}
					</table>
			</div>
		</div>
	</div>
{else}
	<div class="divPopOverflow">
		<table width="100%" border="0" cellspacing="0" cellpadding="0" class="ld-public-content-small">
			<tr>
				<td colspan="2">
					<div class="ld-pop-contnet-title-items">
						<div class="ld-pop-contnet-title-item">{'BANGWO8ACCOUNT'|@getFixedLabel}</div>
					</div>
				</td>
			</tr>
			<tr>
				<td class="ld-form-item-label">{'WHETHERTOENABLE'|@getFixedLabel}</td>
				<td class="ld-form-item-content">
					<input type="checkbox" class="second_switch"   id="presence" name="presence" onclick="bangwo8interface.setBwText()" value="{$PRESENCE}" {if $PRESENCE eq '0' && $PRESENCE neq ''}checked{/if}/>
				</td>
			</tr>
			<tr id="tr_vendorid" {if $PRESENCE neq '0' || $PRESENCE eq ''}style="display:none;"{/if}>
				<td class="ld-form-item-label">
					<font color="red">*</font>VendorID
				</td>
				<td class="ld-form-item-content">
					<input type="text" id="vendorid"  name="vendorid" title="VendorID " value="{$VENDORID}" size="60" class="ld-input-inner"/>
				</td>
			</tr>
			<tr id="tr_authcode" {if $PRESENCE neq '0' || $PRESENCE eq ''}style="display:none;"{/if}>
				<td class="ld-form-item-label">
					<font color="red">*</font>{'AUTHCODE'|@getFixedLabel}
				</td>
				<td class="ld-form-item-content">
					<input type="text" id="authcode" name="authcode" title="{'AUTHCODE'|@getFixedLabel} " value="{$AUTHCODE}" size="60" class="ld-input-inner"/>
				</td>
			</tr>
		</table>
		<table width="100%"  border="0" cellspacing="0" cellpadding="0" class="ld-public-content-small padT8">
			<tr>
				<td colspan="2">
					<div class="ld-pop-contnet-title-items">
						<div class="ld-pop-contnet-title-item">{'syncaccandcon'|@getFixedLabel}</div>
					</div>
				</td>
			</tr>
			<tr>
				<td class="ld-form-item-label">{'iscustomer'|@getFixedLabel}</td>
				<td class="ld-form-item-content">
					<input type="checkbox" class="second_switch"   id="is_customer" name="is_customer" onclick="bangwo8interface.setIsCustomer()" value="{$ISCUSTOMER}" {if $ISCUSTOMER eq '0' && $ISCUSTOMER neq ''}checked{/if}/>
				</td>
			</tr>
			<tr id="tr_supportname" {if $ISCUSTOMER neq '0'}style="display:none;"{/if}>
				<td class="ld-form-item-label" id="td_supportname_title">
					<font color="red">*</font>{'bangwowiththecustomer'|@getFixedLabel}
				</td>
				<td class="ld-form-item-content">
					<input type="text" id="supportname" name="supportname" title="{'bangwowiththecustomer'|@getFixedLabel}" value="{$SUPPORTNAME}" size="60" class="ld-input-inner"/>
				</td>
			</tr>
			<tr id="tr_supportpwd" {if $ISCUSTOMER neq '0'}style="display:none;"{/if}>
				<td class="ld-form-item-label" id="td_supportpwd_title">
					<font color="red">*</font>{'bangwowiththecustomer'|@getFixedLabel}{'PASWD'|@getFixedLabel}
				</td>
				<td class="ld-form-item-content">
					<input type="password" id="supportpwd" name="supportpwd" title="{'bangwowiththecustomer'|@getFixedLabel}{'PASWD'|@getFixedLabel}" value="{$SUPPORTPWD}" size="60" class="ld-input-inner"/>
				</td>
			</tr>
		</table>
		<div id="mnuTab2" class="" style="display: block;">
			{include file="AdvanceFilterCustViewPopup.tpl"}
		</div>
		<div style="padding: 8px 24px 0;">
			<div class="ld-pop-contnet-title-items">
				<div class="ld-pop-contnet-title-item">{'BANGWO8CUSTOMERSERVICE'|@getFixedLabel}</div>
			</div>
		</div>
		<div class="ld-pop-container ld-table-container ld-table-container-lines">
			<table width="100%" border="0" cellspacing="0" cellpadding="0" class="">
				<thead>
					<tr>
						<th>#</th>
						<th align='left' width='17%' title="{'CUSTOMERSERVICEACCOUNT'|@getFixedLabel}">{'CUSTOMERSERVICEACCOUNT'|@getFixedLabel}</th>
						<th align='left' width='200px' title="{'SYSTEMSCOPECLIENTSANDCONTACTS'|@getFixedLabel}">{'SYSTEMSCOPECLIENTSANDCONTACTS'|@getFixedLabel}</th>
						<th align='left' width='200px' title="{'ADDOREDITRECORDONBANGWO8TOSYSTEMOPERATE'|@getFixedLabel}">{'ADDOREDITRECORDONBANGWO8TOSYSTEMOPERATE'|@getFixedLabel}</th>
						<th align='left' width='65px' title="{'OPERATING'|@getFixedLabel}">{'OPERATING'|@getFixedLabel}</th>
					</tr>
				</thead>
				<tbody>
					{foreach key=listdata_key item=data from=$LISTDATA name=listdataname}
						{assign var=i value=$smarty.foreach.listdataname.iteration}
						{if $i%2 neq 0}
							<tr id="setting_{$i}" class="lvtColData"  onmouseover="listOnMouseOver(ld(this));" onmouseout="listOnMouseOut(ld(this),'on');">
								{else}
							<tr id="setting_{$i}" class="lvtColDataBj"  onmouseover="listOnMouseOver(ld(this))" onmouseout="listOnMouseOut(ld(this),'On');">
						{/if}
						<td>{$i}</td>
						<td title="{$data.supportname}">{$data.supportname}</td>
						<td title="{$data.view_username}">{$data.view_username}</td>
						<td title="{$data.user_name}">{$data.user_name}</td>
						<td align="left">
							<a class="Anu3_a" onclick="bangwo8interface.settingsBangwo8info(this,{$listdata_key})">{'SETTINGS'|@getFixedLabel}</a>
						</td>
						</tr>
					{/foreach}
				</tbody>
			</table>
		</div>
	</div>
{/if}
</form>

<div id="settingsBangwo8info"></div>