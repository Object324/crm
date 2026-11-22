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
<form name="selectall" method="POST">
<table width="100%" border="0" cellspacing="0" cellpadding="0" class="small">
	<tr>
	{if $POPUPTYPE eq 'MultiplePopup'}
		<td class="padL8" align="left"><input style="display: none;" class="saveauto" type="button" name="MultiplePopupSelect" id="MultiplePopupSelect" value="{'SELECT'|@getFixedLabel}" onclick=""/></td>
	{elseif $RETURN_MODULE == 'Commission'}
		<td class="padL8" align="left"><input class="saveauto" type="button" value="{'SELECT'|@getFixedLabel}" onclick="if(SelectListValAll('{$MODULE}','{$RETURN_MODULE}','{$LISTALL}'))window.close();"/></td>
   	{else}
        {if $SELECT eq 'enable' && ($POPUPTYPE neq 'inventory_prod' && $POPUPTYPE neq 'set_return_groupmasssms' && $POPUPTYPE neq 'set_return_groupemails' && $POPUPTYPE neq 'inventory_prod_po' && $POPUPTYPE neq 'inventory_service' && $POPUPTYPE neq 'set_return_emails' && $POPUPTYPE neq 'selectsource')}
    		<td class="padL8" align="left"><input class="saveauto" type="button" value="{'SELECT'|@getFixedLabel}" onclick="if(SelectAll('{$MODULE}','{$RETURN_MODULE}'));"/></td>
		{elseif $SELECT eq 'enable' && ($POPUPTYPE eq 'inventory_prod' || $POPUPTYPE eq 'set_return_emails' || $POPUPTYPE eq 'set_return_groupmasssms' || $POPUPTYPE eq 'set_return_groupemails'|| $POPUPTYPE eq 'inventory_prod_po')}
    		{if $RECORD_ID}
    			<td class="padL8" align="left" width=10%><input class="saveauto" type="button" value="{'RETURN'|@getFixedLabel}" onclick="window.history.back();"/></td>
    		{/if}
            {if $POPUPTYPE neq 'set_return_groupmasssms' && $POPUPTYPE neq 'set_return_emails' && $POPUPTYPE neq 'set_return_groupemails'}
    		<td class="padL8" align="left"><input class="ld-button ld-button-primary" type="button" value="{'CONFIRMED'|@getFixedLabel}" onclick="fun_selectproduct.selectMoreModuleForProduct('{$MODULE}');"/></td>
            {else}
                {if $MODULE eq 'Users'}
                 {if $POPUPTYPE eq 'set_return_groupmasssms' }
                    <td class="padL8" align="left"><input class="saveauto" type="button" value="{'SELECT'|@getFixedLabel}" onclick="show_UserSMS();"/></td>
                 {else}
                    <td class="padL8" align="left"><input class="saveauto" type="button" value="{'SELECT'|@getFixedLabel}" onclick="show_UserEmail();"/></td>
                 {/if}
                {else}
                    <td class="padL8" align="left"><input class="saveauto" type="button" value="{'SELECT'|@getFixedLabel}" onclick="show_contactSMS();"/></td>
                {/if}
            {/if}
        {elseif $SELECT eq 'enable' && $POPUPTYPE eq 'inventory_service'}
    		<td class="padL8" align="left"><input class="saveauto" type="button" value="{'SELECT'|@getFixedLabel}" onclick="InventorySelectAllServices('{$RETURN_MODULE}','image_pth')"/></td>
		{elseif $SELECT eq 'enable' &&  $POPUPTYPE eq 'selectsource'}
			{if $LISTVAL eq 0}
				<td class="padL8" align="left"><input class="saveauto" type="button" value="{'SELECT'|@getFixedLabel}" onclick="if(selectMoreModuleSource('{$FROMMODULE}'));"/></td>
			{else}
				<input class="saveauto" type="button" value="{'SELECT'|@getFixedLabel} {$MODULE|@getTranstab}" onclick="selectMoreModuleSource('{$FROMMODULE}');"/>
			{/if}
        {else}
    		<td>&nbsp;</td>
    	{/if}
    {/if}
	<td style="padding-right:10px;" align="right" name="pagediv">
		{if $NAVI neq 'NAVI'}
			<div class="PageDiv0" style="margin-top:5.2px;">
				<div class="ld-flex-start">
					{if $FROMMODULE neq 'CooperativeWork'}
					<div class="ld-pagenum-div" name="choosebilltotal_div" style="padding-right:30px">
						{'choose'|@getFixedLabel} 0 {'numbill'|@getFixedLabel}
					</div>
					{/if}
					<div class="ld-pagenum-div">{$recordListRange}</div>
                    {$NAVIGATION}
				</div>
			</div>
		{/if}
	</td>
	</tr>
   	<tr>
	    <td class="padT10" colspan="3">
       	<input name="module" type="hidden" value="{$RETURN_MODULE}"/>
		<input name="action" type="hidden" value="{$RETURN_ACTION}"/>
        <input name="pmodule" type="hidden" value="{$MODULE}"/>
		<input type="hidden" name="curr_row" value="{$CURR_ROW}"/>
		<input name="entityid" type="hidden" value=""/>
		<input name="popuptype" id="popup_type" type="hidden" value="{$POPUPTYPE}"/>
		<input name="idlist" type="hidden" value=""/>
        <input name="contactid" id="contactid" type="hidden" value=""/>
        <input name="accountid" id="accountid" type="hidden" value=""/>
        <input name="haveprojecet_account_num" id="haveprojecet_account_num" type="hidden" value="{$CLASSROOMACCOUNTALL}" />
        <input name="allprojecet_account_num" id="allprojecet_account_num" type="hidden" value="{$GETPROJECTGALLERYFUL}" />
        <input name="versionedu" id="versionedu" type="hidden" value="{$PROJECTSTATUS}" />
        <input type="hidden" id="fromlink" name="fromlink" value="{$FROMLINK}" />
        <input  type="hidden" id="popup_rows_selectall" value=""/>
        <input  type="hidden" id="popup_num_rows" value="{$NUMOFROWS}"/>
        <input  type="hidden" id="popup_cur_rows_count" value="{$CURPAGECOUNT}"/>
        {if $MODULE eq 'Accounts'}
            {if $POPUPTYPE neq 'set_return_groupemails' && $POPUPTYPE neq 'set_return_emails'}
                <input name="row_of_checkbox_account" id="row_of_checkbox_account" type="hidden" value="{$num_rows_account}"/>
            {else}
                <input name="row_of_checkbox_account_pop_email" id="row_of_checkbox_account_pop_email" type="hidden" value="{$num_rows_account_Email}"/>
            {/if}
        {else}
            {if $POPUPTYPE neq 'set_return_groupemails' && $POPUPTYPE neq 'set_return_emails'}
                <input name="row_of_checkbox_contact_pop" id="row_of_checkbox_contact_pop" type="hidden" value="{$num_rows_contact}"/>
            {else}
                <input name="row_of_checkbox_contact_pop_email" id="row_of_checkbox_contact_pop_email" type="hidden" value="{$num_rows_contact_Email}"/>
            {/if}
        {/if}

        <!--
        更新操作
        edit:cdw
        date:20131126
        reason：营销群发短信修改
        -->
        <div id="SMSedit" class="E_pop_box LdPopWidth300px" style="display:none;position: absolute; z-index:9999; left: 169px; top: 179px;">
            <div class="E_pop_tit">
                {if $POPUPTYPE neq 'set_return_groupemails' && $POPUPTYPE neq 'set_return_emails'}
                    <strong class="E_ptita">{'PLEASESELECTPHONE'|@getFixedLabel}</strong>
           		{else}
                    <strong class="E_ptita">{'PLEASESELECTEMAIL'|@getFixedLabel}</strong>
                {/if}
                <button class="E_ptitc" value="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}" onclick="fninvshnew('SMSedit');"/>
            </div>
     	   <table class="D_pop_bod D_pop_bod_line" border="0" cellpadding="1" cellspacing="0">
              <tr>
                <td>

                <table style="color:#666;font-size:12px;">
                {if $POPUPTYPE neq 'set_return_groupemails' && $POPUPTYPE neq 'set_return_emails'}
                    <tr><td>{'PCWYWTSTMTMP'|@getFixedLabel}</td></tr>
                {else}
                    <tr><td>{'PCWYWTSETE'|@getFixedLabel}</td></tr>
                {/if}
           		 {if $POPUPTYPE neq 'set_return_groupemails' && $POPUPTYPE neq 'set_return_emails'}
                    {if $MODULE eq 'Accounts'}
                        {$html_accounttype_SMS}
                    {elseif $MODULE eq 'Contacts'}
                         {$html_contact_SMS}
                    {else}
                        {$html_contact_SMS}
                    {/if}
                {else}
                    {if $MODULE eq 'Accounts'}
                        {$html_accounttype_Email}
                    {elseif $MODULE eq 'Contacts'}
                       {$html_contact_Email}
                    {else}
                       {$html_contact_Email}
                    {/if}
                {/if}
                 </table>
                </td>
              </tr>
            </table>
            <div class="E_pbtn">
                {if $POPUPTYPE neq 'set_return_groupemails' && $POPUPTYPE neq 'set_return_emails'}
                    {if $MODULE eq 'Accounts'}
                        <input type="button" id="chose_checkbox" class="E_pbtnok" value="{'SELECT'|@getFixedLabel}" onclick="account_btn_MassSMS();"/><span>&nbsp;</span>
                    {else}
                        <input type="button" id="chose_checkbox" class="E_pbtnok" value="{'SELECT'|@getFixedLabel}" onclick="contact_btn_MassSMS();"/><span>&nbsp;</span>
                    {/if}
                {else}
                    {if $MODULE eq 'Accounts'}
                        <input type="button" id="chose_checkbox" class="E_pbtnok" value="{'SELECT'|@getFixedLabel}" onclick="account_btn_Email();"/><span>&nbsp;</span>
                    {else}
                        <input type="button" id="chose_checkbox" class="E_pbtnok" value="{'SELECT'|@getFixedLabel}" onclick="contact_btn_Email();"/><span>&nbsp;</span>
                    {/if}
                {/if}
                <input type="button" class="E_pbtncancel" value="{'CANCEL'|@getFixedLabel}" onclick="fninvshnew('SMSedit');"/>
            </div>
        </div>


	<!--end-->
	<div id="hdScrolllistentries_yy" name="hdScrolllistentries_yy" style="position: relative;">
		<div style=" visibility: visible; top: 194px;overflow:hidden" id="resize_header_table_divid" name="resize_header_table_divid">
			<div  style="float:left; padding-right:20px">
				<table id="resize_header_tableid" name="resize_header_tableid" class="listEntries" border=0 cellspacing=1 cellpadding="0" style="width:{$LISTVIEWTOTALWIDTH}px" >
					<tbody>
						<tr>
						{if $SELECT eq 'enable'}
							<th class="firstChild" style="text-align:center;width:{$CHKBOXWIDTH}px" tag="0" headermodule="{$MODULE}" headername='chkbox'>
								<input type="checkbox" name="select_all" headermodule="{$MODULE}" value="" onclick="toggleSelect(this.checked,'selected_id')"/>
							</th>
						{/if}
						{if $SETSEQUENCE eq 'yes'}
							<th style="width:50px;text-align: center" tag="sequence" headermodule="{$MODULE}">{'SEQUENCE'|@getFixedLabel}</th>
						{/if}
						{foreach item=header key=i from=$LISTHEADER}
							<th style="width:{$LISTHEADERWIDTH[$i]}px" headermodule='{$HEADERMODULE[$i]}' headername='{$HEADERNAME[$i]}' tag="{$i+1}">{$header}</th>
						{/foreach}
						{if $SELECT eq 'enable' && ($POPUPTYPE eq 'inventory_prod' || $POPUPTYPE eq 'inventory_prod_po')}
							{if !$RECORD_ID}
							<!--edit:can reason;7326: 合同订单等模块新增界面：选择产品调用界面：产品信息序列表中操作列不需要-->
								<!--<td class="lvtCol">{$APP.LBL_ACTION}</td>-->
							{/if}
						{/if}
						</tr>
					</tbody>
				</table>
			</div>
		</div>
        <!---营销群发短信-》选择联系人界面全屏了公司账套-->
		<div style="overflow:auto;height:400px;" id="resize_content_table_divid" name="resize_content_table_divid">
			<table border="0" cellspacing="1" cellpadding="0" id="resize_content_tableid" name="resize_content_tableid" style="width:{$LISTVIEWTOTALWIDTH}px" class="listEntries marT-53" >
				<tbody>
					<tr>
					{if $SELECT eq 'enable'}
						<th class="firstChild" style="width:{$CHKBOXWIDTH}px" tag="0" headermodule="{$MODULE}" headername='chkbox'>
							<input type="checkbox" name="select_all" headermodule="{$MODULE}" value="" onclick="toggleSelect(this.checked,'selected_id')"/>
						</th>
					{/if}
					{if $SETSEQUENCE eq 'yes'}
						<th style="width:50px;text-align: center" tag="sequence" headermodule="{$MODULE}">{'SEQUENCE'|@getFixedLabel}</th>
					{/if}
					{foreach item=header key=i from=$LISTHEADER}
						<th style="width:{$LISTHEADERWIDTH[$i]}px" headermodule='{$HEADERMODULE[$i]}' headername='{$HEADERNAME[$i]}' tag="{$i+1}">{$header}</th>
					{/foreach}
					{if $SELECT eq 'enable' && ($POPUPTYPE eq 'inventory_prod' || $POPUPTYPE eq 'inventory_prod_po')}
						{if !$RECORD_ID}
						<!--edit:can reason;7326: 合同订单等模块新增界面：选择产品调用界面：产品信息序列表中操作列不需要-->
							<!--<td class="lvtCol">{$APP.LBL_ACTION}</td>-->
						{/if}
					{/if}
					</tr>
					{if $SELECT eq 'enable'&&$MODULE eq 'Contacts'}
						<tr>
								<td id="Popup_choose_linkForSelectAll" class="linkForSelectAll" style="display:none;" colspan="{$LISTHEADER|@count +1}">
									<span id="Popup_choose_selectAllRec" class="selectall" style="display:inline;" onClick="Popup_choose_SelectAll_Records('{$MODULE}',true,'selected_id')">{'SELECTALL'|@getFixedLabel} <span id="count"> {$NUMOFROWS}</span> {'RECORDNUMS'|@getFixedLabel}</span>
									<span id="Popup_choose_deSelectAllRec" class="selectall" style="display:none;" onClick="Popup_choose_SelectAll_Records('{$MODULE}',false,'selected_id')">{'DESELECTALL'|@getFixedLabel}</span>
								</td>
					  </tr>
					{/if}
					{assign var="i" value=0}
					{foreach key=entity_id item=entity name=listentitys from=$LISTENTITY}
						{assign var="i" value=$i+1}
						{* // edit: xll 2024/10/24 XUQIU20240909-02 选择产品增加产品属性的选择（需求暂停）*}
						{if $MODULE eq 'Products'}
						{*	{if false}*}
							{assign var="property_status" value=$propertyStatusArr[$entity_id]}
						{else}
							{assign var="property_status" value=''}
						{/if}
						{if $smarty.foreach.listentitys.iteration mod 2 eq '1'}
							<tr class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on')" onmouseover="listOnMouseOver(ld(this))" id="row_{$entity_id}" record="{$entity_id}" {$property_status}>
						{else}
							<tr class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On')" onmouseover="listOnMouseOver(ld(this))" id="row_{$entity_id}"
								record="{$entity_id}" {$property_status} >
						{/if}
							{if $SELECT eq 'enable'}
								<td class="firstChild" align="center" onclick="toggleSelectAll_parent_td(this)" shift="yes"><input type="checkbox" billinfo="{$entity_id}" id="{$entity_id}" name="selected_id" value="{$entity_id}" onclick="toggleSelectAll(this.name,'select_all',{$entity_id})"/></td>
							{/if}
							{if $SETSEQUENCE eq 'yes'}
							<td style="text-align: center" name="sequence" index="{$i}">{$i}</td>
							{/if}
							{foreach item=data key=keyindex from=$entity}
								{if $keyindex|@istdRight:$MODULE eq 'true'}
									 <td ispopupdoubleclick="yes" align="right">{$data}</td>
								{else}
									 <td ispopupdoubleclick="yes">{$data}</td>
								{/if}
							{/foreach}
						</tr>
					{foreachelse}
							<tr id="resize_content_trid" align="center" style="">
								<td colspan="{$HEADERCOUNT}" bgcolor="#FFF" style="height:0px;padding: 0;">
									{* <div class="warningTableContent" style="z-index:600;">
										<div class="wtc_img">
											<img src="themes/icon2023/ld-no-records.png">
										</div>
										<div class="wtc_content">
											{'NOTFOUNDANYRECORD'|@getFixedLabel}
										</div>
										<div class="wtc_btn"></div>
										<div></div>
									</div> *}
									{include file="NoRecords.tpl"}
								</td>
							</tr>
						{/foreach}
				</tbody>
			</table>
		</div>
		{if $POPUPTYPE eq 'MultiplePopup'}
			<div name="redtip_limitcount" class="redFont" style="height:20px;margin:5px">{'DSFMFFQOTSTT5OTQR'|@getVarFixedLabel:$LIMITCOUNT}</div>
		{/if}
	</div>
</form>
<div id="basicsearchcolumns" name="basicsearchcolumns" style="display:none;"><select name="search_field" id="bas_searchfield" class="btn-radius-system" style="width:164px;">{html_options  options=$SEARCHLISTHEADER}</select></div>
<script language="JavaScript" type="text/javascript" src="include/js/cls_ModuleTree.js?v={$GLOBALMINVERSION}"></script>
<script>
	var module = '{$MODULE}'
	var tree_enable= empty('{$POPUPMODULElISTTREE.enable}')?'{$tree_enable}':'{$POPUPMODULElISTTREE.enable}';
	if(tree_enable == 'yes'){
		// ljj 2023-08-29 XUQIU1001610 树结构设置和成员管理，左侧分类名称增加计数功能
		var popupobj=CrmPopup.getPopupObj("last");
		popupobj.module = module;
		var structureTreeobj=new structureTree();
		structureTreeobj.setEvent();
		structureTreeobj.treeWidth = empty('{$POPUPMODULElISTTREE.tree_width}')?'{$tree_width}':'{$POPUPMODULElISTTREE.tree_width}';
		popupobj.list_TreeWhere = '{$Encrypt_TreeWhere}';
		structureTreeobj.getPopupModuleTreeCount(popupobj);
	}
</script>