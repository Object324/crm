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
<script language="JavaScript" type="text/javascript" src="include/js/advancefilternew.js"></script>
<script language="JavaScript" type="text/javascript" src="include/js/search.js"></script>
<script>
	ld("#dv_popup_listhighersearch [name=pop_adv_filter_div]").html("");
</script>
<div class="">
	<!--{*
		选择产品弹出框添加套餐、产品标签
		@project PROT127 爱哆哆需求1：产品套餐
		@author tujt 2014-11-26
	*}-->
	{if $PRODBOMTAGARR && $PRODBOMTAGARR != ''}
    	<div id="probom_div" name="probom_div" class="ld-ui-tabs">
            <ul class="ld-ui-tabs-nav">
                {foreach key=key item=item from=$PRODBOMTAGARR}
                    {if $PRODBOMTAG_D == $key}
                        <li class="ld-ui-tabs-active" tag="{$key}"><a href="javascript:;">{$item}</a></li>
                    {else}
                        <li tag="{$key}"><a href="javascript:;">{$item}</a></li>
                    {/if}
                {/foreach}
            </ul>
    	</div>
	{/if}
<!-- 0049654: （https://81mis.com/kfbcrm [^]）市场活动相关信息->客户界面，点击【选择】弹出层界面，显示列出线了-->
{*{if $POPUPMODULElISTTREE.enable eq 'yes'}*}
{*<table class="ld-drag-area" border=0 cellspacing=0 cellpadding=0 >*}
{*<tr>*}
{*    <td valign="top" class="user-left-td user-left-td-{$CURRENT_USER_ID}" style="{if $POPUPMODULElISTTREE.tree_expand eq 'no'}display:none;{/if}">*}
{*        {include file="PopupModuleListTree.tpl"}*}
{*        <div class="sidebar-drag"></div>*}
{*    </td>*}
{*    <td class="tip-items-list " data-tip="" data-direction="right" data-type="position">*}
{*        <span class="tree-closeopen tree-close"></span>*}
{*    </td>*}
{*    <td valign="top" name="popuptreereightcontent">*}
{*{/if}*}
	<table id="popup_width" name="popup_width" width="100%" border="0" cellpadding="0" cellspacing="0"></table>
    <!--
    edit:andrew;
    date:20140214
    reason:添加数据分类
    -->

	<div id="status" style="position:absolute;display:none;right:135px;top:15px;height:27px;white-space:nowrap;"><img src="{'status.gif'|@lingdang_imageurl:$THEME}"></div>
	<table align="center" width="100%" name='resize_popupsearch_tableid' cellpadding="0" cellspacing="0" border="0"  class="homePageMatrixHdr">
		<tr>
			<td>
				<form name="basicSearch" action="index.php" onSubmit="callSearch('Basic');return false;">
					<input type="hidden" name="searchtype" value="BasicSearch">
					<input type="hidden" id="returnmodule" name="returnmodule" value="{$RETURNMODULE}" />
					<input type="hidden" id="frommodule" name="frommodule" value="{$FROMMODULE}" />
					<input type="hidden" name="module" id="module" value="{$MODULE}">
					<input type="hidden" name="action" value="Popup">
					<input type="hidden" name="query" value="true">
					<input type="hidden" name="select_enable" id="select_enable" value="{$SELECT}">
					<input type="hidden" name="curr_row" id="curr_row" value="{$CURR_ROW}">
					<input type="hidden" name="fldname_pb" value="{$FIELDNAME}">
					<input type="hidden" name="productid_pb" value="{$PRODUCTID}">
					<input name="popup_type" id="popup_type" type="hidden" value="{$POPUPTYPE}">
					<input name="recordid" id="recordid" type="hidden" value="{$RECORDID}">
					<input name="record_id" id="record_id" type="hidden" value="{$RECORD_ID}">
					<input name="return_module" id="return_module" type="hidden" value="{$RETURN_MODULE}">
					<input name="from_link" id="from_link" type="hidden" value="{if isset($smarty.request.fromlink.value)}{$smarty.request.fromlink.value|@vtlib_purify}{/if}">
					<input name="maintab" id="maintab" type="hidden" value="{$MAINTAB}">
					<input type="hidden" id="relmod" name="relmod" tag="{$mod_var_name}" value="{$mod_var_value}">
					<input type="hidden" id="relrecord_id" name="relrecord_id" tag="{$recid_var_name}" value="{$recid_var_value}">
					<input name="popupform"  id="popupform" type="hidden" value="{$smarty.request.form|@vtlib_purify}">
					<input name="warehouse" id="warehouse" type="hidden" value="{$WAREHOUSEID}"/>
					<input type="hidden" id="viewname" name="viewname" value="{$VIEWID}"/>
					<input type="hidden" name="publicaccounttype" value="{$ACCOUNTTYPE}" />
					<input id="popupselect" type="hidden" value="{$SELECT}"/>
					<input type="hidden" value="{$ACCOUNTID}" id="account_id"  name="account_id"/>
					<input type="hidden" value="{$VENDORID}" id="vendor_id" name="vendor_id"/>
					<input type="hidden" value="{$POPUPMODE}" name="popupmode"/>
					<input type="hidden" value="{$CALLBACK}" name="callback"/>
                    {if $smarty.request.form eq 'vtlibPopupView'}
						<input name="forfield" id="forfield" type="hidden" value="{$smarty.request.forfield|@vtlib_purify}">
						<input name="srcmodule" id="srcmodule" type="hidden" value="{$smarty.request.srcmodule|@vtlib_purify}">
						<input name="forrecord" id="forrecord" type="hidden" value="{$smarty.request.forrecord|@vtlib_purify}">
					{/if}
					{if $smarty.request.currencyid neq ''}
						<input type="hidden" name="currencyid" id="currencyid" value="{$smarty.request.currencyid|@vtlib_purify}">
					{/if}
					<input type="hidden" name='listval' id="listval" value="{$LISTVAL}" />
					{* END *}
                    <input type="hidden" name="allotaccount" id="allotaccount" value="{$ALLOTACCOUNT}" />
					<input type="hidden" name="selectSourcePopup" id="selectSourcePopup" value="yes" />
					<input type="hidden" name="withproductdetail" id="withproductdetail" value="{$WITHPRODUCTDETAIL}" />
					<div class="marLR10 ld-flex-start ld-flex-wrap {if $tree_enable eq 'yes'}marL20{/if}" id="basicSearchNewDiv">
						{if $CUSTOMVIEW_OPTION neq ''}
						<div class="marR10 ld-flex-start" {if $HIDEDATACATEGORY eq 'yes'} style="display:none"{/if}>
							<span class="category_span" style="height: 50px;line-height: 50px;">{'DATACATEGORY'|@getFixedLabel}</span>
							<div class="ld-listview-category">
								<ul>
									<li style="padding: 7px 20px 0 0;">
										{include file='SelectCustomView.tpl'}
									</li>
								</ul>
							</div>
						</div>
						{/if}
						<div class="marR10 ld-flex-start" id="basicSearchNewDiv">
							{*zxm20221212 新的基本查找组件*}
							{include file="PopupListViewBasicSearch.tpl"}
						</div>
						<div class="marL10 ld-flex-start">
							<div class="DivSearch">
								<ul>
									<li>
										<input type="button" name="search" onClick="showPopupHighSearch();" class="ld-button ld-button-primary" value="{'CUSTOMIZESEARCH'|@getFixedLabel}" style="margin-top: -1px;" />
									</li>
									{if $MODULE eq 'Products'}
										<li>
											<input class="ld-button ld-button-primary" name="search" value="{'Quickly_create'|@getFixedLabel}" onclick="QCreate('Products','select')" type="button" style="margin-top: -1px;">
										</li>
									{/if}
									<li>
										<!--快速创建-->
										{if $MODULE eq 'AAccounts' || $MODULE eq 'CContacts' || $MODULE eq 'PProducts' || $MODULE eq 'VVendors'|| $MODULE eq 'VVendorContact'}
											{*yyx 2015-4-23 在判断条件中添加VendorContact模块的判断条件*}
											{if (isPermitted($MODULE, 'Create', '') == 'yes')}
												<div name="search" onClick="QCreate('{$MODULE}');" class="saveauto">{'Quickly_create'|@getFixedLabel}</div>
											{/if}
										{/if}
										<!-- 产品套餐快速创建 -->
										{if $MODULE eq 'Productbom'}
											{if (isPermitted($MODULE, 'Create', '') == 'yes')}
												<input class="createauto" name="search" value="{'Quickly_create'|@getFixedLabel}" onclick="QCreate('Productbom','select')" type="button" style="margin-top: -1px;">
											{/if}
										{/if}
									</li>
								</ul>
							</div>
						</div>
					</div>
	                <table align="center" width="100%"  cellpadding="0" cellspacing="0">
{*						<tr class="basicsearchfield">*}
{*		                    <td>*}
{*		                        <div class="DivSearch">*}
{*			                        <ul>*}
{*			                            <li class="padL8">{'Find_field'|@getFixedLabel}</li>*}
{*			                            <li id="basicsearchcolumns_real" name="basicsearchcolumns_real">*}
{*			                                <select name ="search_field" class="btn-radius-system" style="width:164px;">*}
{*							                   {html_options  options=$SEARCHLISTHEADER selected=$SEARCHFIELDNAME}*}
{*											</select>*}
{*			                            </li>*}
{*			                            <li class="padL8">{'Find_Keyword'|@getFixedLabel}</li>*}
{*			                            <li>*}
{*			                                <input type="text" value="{$SEARCHVALUE}" name="search_text" id="search_txt" class="btn-radius-system" style="width:240px;" onkeyup="fun_setCrmPopupWindow.searchSubmit(event,'Basic')" />*}
{*			                            </li>*}
{*			                            <li>*}
{*			                                <input type="button" name="search" onClick="fun_setCrmPopupWindow.callSearch('Basic');" class="saveauto" value="{'FINDNOW'|@getFixedLabel}" style="margin-top: -1px;" />*}
{*			                            </li>*}
{*			                            <li>*}
{*			                                <input type="button" name="search" onClick="showPopupHighSearch();" class="saveauto" value="{'CUSTOMIZESEARCH'|@getFixedLabel}" style="margin-top: -1px;" />*}
{*			                            </li>*}
{*										{if $MODULE eq 'Products'}*}
{*											<li>*}
{*												<input class="createauto" name="search" value="{'Quickly_create'|@getFixedLabel}" onclick="QCreate('Products','select')" type="button" style="margin-top: -1px;">*}
{*											</li>*}
{*										{/if}*}
{*			                            <li>*}
{*			                                <!--快速创建-->*}
{*			                                {if $MODULE eq 'AAccounts' || $MODULE eq 'CContacts' || $MODULE eq 'PProducts' || $MODULE eq 'VVendors'|| $MODULE eq 'VVendorContact'}*}
{*			                                *}{*yyx 2015-4-23 在判断条件中添加VendorContact模块的判断条件*}
{*			                                    {if (isPermitted($MODULE, 'Create', '') == 'yes')}*}
{*			                                        <div name="search" onClick="QCreate('{$MODULE}');" class="saveauto">{'Quickly_create'|@getFixedLabel}</div>*}
{*			                                    {/if}*}
{*			                                {/if}*}
{*											<!-- 产品套餐快速创建 -->*}
{*											{if $MODULE eq 'Productbom'}*}
{*												{if (isPermitted($MODULE, 'Create', '') == 'yes')}*}
{*													<input class="createauto" name="search" value="{'Quickly_create'|@getFixedLabel}" onclick="QCreate('Productbom','select')" type="button" style="margin-top: -1px;">*}
{*												{/if}*}
{*											{/if}*}
{*			                            </li>*}
{*		                        </ul>*}
{*		                        </div>*}
{*							</td>*}
{*		                </tr>*}
{*		                </tr> *}
		                <!-- 界面优化 去掉拼音搜索 全部注释，查找会报错，先隐藏-->                   
						 <tr style="display:none;">
							<td colspan="4" align="center" style="padding:5px;">
								<table width="100%" class="small" cellpadding="0" cellspacing="0">
									<tr>	
										{$ALPHABETICAL}
									</tr>
								</table>
							</td>
						</tr>
					</table>
				</form>
			</td>
		</tr>
		{if $recid_var_value neq '' && $MODULE!='Contacts' && 1 eq 2}
	        <tr>
	            <td align="right"><input id="all_contacts" alt="{'SELECT'|@getFixedLabel} {$MODULE|@getTranstab}" title="{'SELECT'|@getFixedLabel} {$MODULE|@getTranstab}" class="edit autoWidth marR8" value="{'DISPLAYALL'|@getFixedLabel}{$MODULE|@getTranstab}" LANGUAGE=javascript onClick="window.location.href=showAllRecords();" type="button"  name="button"></td>
	        </tr>
        {/if}
	</table>
{*hzx 20231226 BUG0077829 群发邮件->选择客户弹出层界面，下方预留了一大片空白*}
		<div style="display: flex">
			{if $POPUPMODULElISTTREE.enable eq 'yes'}
				<div class="marL10" id="popupListViewModuleListTree" name="popupListViewModuleListTree" {if $POPUPTYPE eq 'AccountsChart'}style="height: 500px" {/if}>
					<table class="ld-drag-area" border=0 cellspacing=0 cellpadding=0 style="height: 100%" >
						<tr>
							<td valign="top" class="user-left-td user-left-td-{$CURRENT_USER_ID}" name="popupmoduletreelist_td" id="popupmoduletreelist_td" style="">
								{include file="PopupModuleListTree.tpl"}
								<div class="sidebar-drag"></div>
							</td>
							{*<td class="tip-items-list " data-tip="" data-direction="right" data-type="position">
								<span class="tree-closeopen tree-close"></span>
							</td>*}
							<td valign="top" name="popuptreereightcontent"></td>
						</tr>
					</table>
				</div>
			{/if}
			<div id="ListViewContents" name="ListViewContents" >
				{if $MODULE|@get_file_address:'ProductDetails' == true || get_file_address($MODULE,$MODULE|cat:'DetailFieldsHtml') || $MODULE|@get_file_address:'ContactsDetails' == true || $MODULE|@get_file_address:'VendorsDetails' == true}
					{include file="PopupProductContentsLayer.tpl"}
				{elseif $MODULE|@get_file_address:'ContactsDetails' == true || $MODULE|@get_file_address:'VendorsDetails' == true}
					{include file="ListPopupContentsLayer.tpl"}
				{else}
					{include file="PopupContentsLayer.tpl"}
				{/if}
			</div>
		</div>
{*{if $POPUPMODULElISTTREE.enable eq 'yes'}*}
{*</td>*}
{*</tr>*}
{*</table>*}
{*{/if}*}
</div>
<!--快速创建-->
<div id="qcformDiv" class="D_pop_box LdPopWidth800px" style="position:absolute;display:none;top:50%;left:40%;z-index:999;">
   <div id="qcform"></div>
</div>
{if $MODULE == 'Productbom'}
<!-- 产品套餐 -->
<div id="qcbomformDiv" class="D_pop_box LdPopWidth800px" style="position:absolute;display:none;top:30%;left:10%;z-index:999;"></div>

<!-- 套餐份数 -->
<div id="qcbomnumberDiv" class="D_pop_box LdPopWidth400px" style="display:none;">
	<div id="qcbomnumber">
		<div class="D_pop_tit">
			<strong class="D_ptita">{'NUMBEROFCOPIES'|@getFixedLabel}</strong>
			<a href="javascript:fninvshnew('qcbomnumberDiv');" class="D_ptitc">
				<img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="{'CLOESE'|@getFixedLabel}" title="{'CLOESE'|@getFixedLabel}">
			</a>
		</div>
		<table class="D_pop_bod" border="0" cellpadding="1" cellspacing="1" width="100%"><tbody>
			<tr align="left" style='display:none;' id='numberCopies_radiotr'>
				<td>
    					<input class="input-btn-align" type="radio" id="numberCopies_radio_1" value="1" checked/>{'SAMENUMBEROFCOPIES'|@getFixedLabel}
    					<input class="input-btn-align" type="radio" id="numberCopies_radio_2" value="0" />{'NUMBEROFDIFFERENT'|@getFixedLabel}
                </td>
			</tr>
			<tr>
				<td width="20%" style='padding:10px;'>
					<div id='numberCopies_div_1'>
                        <font color="red">*</font>
						{'NUMBEROFCOPIES'|@getFixedLabel}: 
						<input type="text" id="numberCopies_number" autocomplete='off' 
						onkeyup="this.value=this.value.replace(/\D/g,'');" class="btn-radius-system" style="    vertical-align: middle;margin-top: -2px;" maxlength='11'>
					</div>
					<div id='numberCopies_div_2' style='display:none;max-height:250px;overflow-y:auto;'>
						<table cellspacing="0" cellpadding="0" border="0" width="100%">
							<tr>
								<td>{'PRODUCTPACKAGE'|@getFixedLabel}</td>
								<td><font color="red">*</font>&nbsp;{'NUMBEROFCOPIES'|@getFixedLabel}</td>
							</tr>
						</table>
					</div>
				</td>
			</tr>
		  </tbody>
        </table>
        <div class="D_pbtn">
            <input name="button" class="D_pbtnok" value="{'CONFIRMED'|@getFixedLabel}" onclick="bom_selectProductList();" type="button"/>
			<span>&nbsp;</span>
			<input name="button" class="D_pbtncancel" value="{'CANCEL'|@getFixedLabel}" onclick="bom.selectcancel();" type="button"/>
            <input type="hidden" id="numberCopies_bomid"/>
			<input type="hidden" id="numberCopies_prodid"/>
			<input type="hidden" id="numberCopies_bomprod"/>
        </div>
	</div>

</div>
{/if}
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/modules/Productbom/Productbom.js"></script>
<script language="JavaScript" type="text/javascript" src="include/js/cls_ModuleTree.js?v={$GLOBALMINVERSION}"></script>
<script>

var hidedata='{$HIDEDATACATEGORY}';

var tmpstr='{$DATETIMESTR}';

//if(hidedata=='yes')
//{
   //  var datetimestr=  eval('('+ tmpstr +')')?eval('('+ tmpstr +')'):JSON.parse(tmpstr);

</script>

