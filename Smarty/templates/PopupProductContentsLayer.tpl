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
<input type="hidden" id="rowcnt" name="rowcnt" value="{$ROWCNT}" />
<input type="hidden" id="isHaveDetailField" name="isHaveDetailField" value="{$isHaveDetailField}" />
<table width="100%" border="0" cellspacing="0" cellpadding="0" class="small">
    <tr>
        <td class="padL8" align="left">
            {if $SELECT eq 'enable'}
                {if $MODULE neq 'Productbom'}
                    {if $POPUPTYPE eq 'set_return_groupmasssms' || $POPUPTYPE eq 'set_return_emails' || $POPUPTYPE eq 'set_return_groupemails'}
                        <input class="saveauto" type="button" value="{'SELECT'|@getFixedLabel}" onclick="show_contactSMS();"/>
                    {elseif $POPUPTYPE eq 'AccountsChart'}
                        <input class="saveauto" type="button" value="{'SELECT'|@getFixedLabel}" name="selectChartRelatedRecord" id="selectChartRelatedRecord" onclick="getRelatedRecords()"/>
                    {elseif $POPUPTYPE eq 'MultiplePopup'}
                        <input style="display: none;" class="saveauto" type="button" name="MultiplePopupSelect" id="MultiplePopupSelect" value="{'SELECT'|@getFixedLabel}" onclick=""/>
                    {elseif $POPUPTYPE eq 'detailview'}<!--查看界面->相关信息->选择-->
                        <input class="saveauto" type="button" value="{'SELECT'|@getFixedLabel}" onclick="if(SelectAll('{$MODULE}','{$RETURN_MODULE}')) window.close();"/>
                    {elseif get_file_address($MODULE,'ContactsDetails') == false  && get_file_address($MODULE,'VendorsDetails') == false}
                        {if get_file_address($FROMMODULE,$FROMMODULE|cat:'DetailFieldsHtml') eq true}
                            {if ($FROMMODULE eq 'CashBill'||$FROMMODULE eq 'SendCashBill') && $WITHPRODUCTDETAIL eq 'yes'}
                                <input class="saveauto" type="button" value="{'CONFIRMED'|@getFixedLabel}" onclick="fun_selectproduct.selectMoreModuleForProduct('{$MODULE}');"/>
                            {elseif $AccountVersionInfo.account eq 'langjie'&&$MODULE eq 'Commission'}
                                  <input class="saveauto" type="button" value="{'CONFIRMED'|@getFixedLabel}" onclick="fun_selectproduct.selectMoreModuleForProduct('{$MODULE}');"/>
                            {else}
                                <input class="saveauto" type="button" value="{'CONFIRMED'|@getFixedLabel}" onclick="selectMoreModuleSource('{$FROMMODULE}');"/>

                            {/if}
                        {else}
                            {if $SELECT eq 'enable' && $MODULE eq 'Potentials' && get_file_address($MODULE,'ProductDetails') eq false }
                                <input class="saveauto" type="button" value="{'CONFIRMED'|@getFixedLabel}" onclick="if(SelectAll('{$MODULE}','{$RETURN_MODULE}')) "/>
                            {else}
                                <input class="ld-button ld-button-primary" type="button" value="{'CONFIRMED'|@getFixedLabel}" onclick="fun_selectproduct.selectMoreModuleForProduct('{$MODULE}');"/>
                            {/if}
                        {/if}
                    {elseif $SELECT eq 'enable' && $MODULE eq 'Accounts' && $POPUPTYPE neq 'AccountsChart'}
                        <input class="saveauto" type="button" value="{'CONFIRMED'|@getFixedLabel}" onclick="if(SelectAll('{$MODULE}','{$RETURN_MODULE}')) window.close();"/>
                    {/if}
                {else}
                    <input class="saveauto" type="button" value="{'CONFIRMED'|@getFixedLabel}" onclick="bom.selectBom();"/>
                {/if}
            {/if}
        </td>
        <td style="padding-right:10px;" align="right">
            <div class="PageDiv0" style="margin-top:5px;">
                <div class="ld-flex-start">
                    <div class="ld-pagenum-div" name="choosebilltotal_div" style="padding-right:30px">
                        {if $isHaveDetailField neq 'yes'}
                            {'choose'|@getFixedLabel} 0 {'numbill'|@getFixedLabel}
                        {else}
                            {'choose'|@getFixedLabel} 0 {'numbill'|@getFixedLabel} ,{'have'|@getFixedLabel} 0 {'billdetails'|@getFixedLabel}
                        {/if}
                    </div>
                    <div class="ld-pagenum-div">{$recordListRange}</div>
                    {$NAVIGATION}
                </div>
            </div>
        </td>
    </tr>
</table>
<div class="padT8">
       	<input name="module" type="hidden" value="{$RETURN_MODULE}"/>
		<input name="action" type="hidden" value="{$RETURN_ACTION}"/>
        <input name="pmodule" type="hidden" value="{$MODULE}"/>
		<input type="hidden" name="curr_row" value="{$CURR_ROW}"/>
		<input name="entityid" type="hidden" value=""/>
		<input name="popuptype" id="popup_type" type="hidden" value="{$POPUPTYPE}"/>
		<input name="idlist" type="hidden" value=""/>
        <input name="contactid" id="contactid" type="hidden" value=""/>
        <input name="accountid" id="accountid" type="hidden" value=""/>
        <input  id="popupfrommodule" type="hidden" value="{$FROMMODULE}"/>
        <input type="hidden" id="fromlink" name="fromlink" value="{$FROMLINK}" />
        <input  type="hidden" id="popup_num_rows" value="{$NUMOFROWS}"/>
        <input  type="hidden" id="popup_rows_selectall" value=""/>
        <input  type="hidden" id="popup_cur_rows_count" value="{$CURPAGECOUNT}"/>
          <input  type="hidden" value="yes" id="haveproductcolumnpop"/>
		  <input  type="hidden" value="{$VERSIONACCOUNT}" name="version_account"/>
    {if $POPUPTYPE neq 'AccountsChart'}
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
    {/if}

        <!--
        更新操作
        edit:cdw
        date:20131126
        reason：营销群发短信修改
        -->
    {if $POPUPTYPE neq 'AccountsChart'}
        <div id="SMSedit" class="D_pop_box  LdPopWidth300px" style="display:none;position: absolute; z-index:9999; left: 169px; top: 179px;">
            <div class="D_pop_tit">
                {if $POPUPTYPE neq 'set_return_groupemails'&& $POPUPTYPE neq 'set_return_emails'}
                    <strong class="D_ptita">{'PLEASESELECTPHONE'|@getFixedLabel}</strong>
           		{else}
                    <strong class="D_ptita">{'PLEASESELECTEMAIL'|@getFixedLabel}</strong>
                {/if}
                <a href="javascript:fninvshnew('SMSedit');" class="D_ptitc">
                    <img class="D_ptitcimg" src="{$IMAGEURL}themes/icon/pop_close.png?v={$GLOBALMINVERSION}" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"/>
                </a>
            </div>
            <table class="D_pop_bod" cellspacing="1" cellpadding="1" border="0">

                {if $POPUPTYPE neq 'set_return_groupemails'&& $POPUPTYPE neq 'set_return_emails'}
                    {if $MODULE eq 'Accounts'}

                            {$html_accounttype_SMS}

                    {else}

                            {$html_contact_SMS}

                    {/if}
                {else}
                    {if $MODULE eq 'Accounts'}

                            {$html_accounttype_Email}

                    {else}

                            {$html_contact_Email}

                    {/if}
                {/if}

            </table>

            <!--
            更新操作
            edit:cdw
            date:20131126
            reason：0006234: 营销>群发邮件：选择联系人点击“+”弹出的联系人调用界面没有显示联系人数据
                    下面这行漏掉半个引号
            -->
            <div class="D_pbtn">
                    {if $POPUPTYPE neq 'set_return_groupemails'&& $POPUPTYPE neq 'set_return_emails'}
                        {if $MODULE eq 'Accounts'}
                            <input class="D_pbtnok" type="button" value="{'SELECT'|@getFixedLabel}" name="button" onclick="account_btn_MassSMS();" id="chose_checkbox"/>
                        {else}
                            <input class="D_pbtnok" type="button" value="{'SELECT'|@getFixedLabel}" name="button" onclick="contact_btn_MassSMS();" id="chose_checkbox"/>
                        {/if}
                    {else}
                        {if $MODULE eq 'Accounts'}
                            <input class="D_pbtnok" type="button" value="{'SELECT'|@getFixedLabel}" name="button" onclick="account_btn_Email();" id="chose_checkbox"/>
                        {else}
                            <input class="D_pbtnok" type="button" value="{'SELECT'|@getFixedLabel}" name="button" onclick="contact_btn_Email();" id="chose_checkbox" />
                        {/if}
                    {/if}
                    <span>&nbsp;</span>
                    <input class="D_pbtncancel" type="button" value="{'CANCEL'|@getFixedLabel}" name="button" onclick="close_SMS('SMSedit');puyoungJS_DialogBox.unblock();"/>
            </div>
        </div>
    {/if}
        <!--end-->
		<div id="hdScrolllistentries_yy" name="hdScrolllistentries_yy" style="position: relative;">
			<div style=" visibility: visible; top: 194px;overflow-y:auto;overflow-x:hidden;"   id="resize_header_table_divid" name="resize_header_table_divid">
				<div  style="float:left; padding-right:20px">
					<table id="resize_header_tableid" name="resize_header_tableid" class="listEntries" border=0 cellspacing=1 cellpadding="0" style="width:{$LISTVIEWTOTALWIDTH}px" >
						<tbody>
                            <tr>
                            {if $SELECT eq 'enable'}
								<th class="firstChild" style="width:{$CHKBOXWIDTH}px" tag="0" headermodule="{$MODULE}" headername='chkbox'>
									<input type="checkbox" name="select_all" headermodule="{$MODULE}" value="" onclick="toggleSelect(this.checked,'selected_id')"/>
								</th>
							{/if}
                            {*// ljj 20231123 XUQIU1001991 选择源单优化*}
                            {if $SETSEQUENCE eq 'yes'}
                                <th style="width:50px;text-align: center" tag="sequence" headermodule="{$MODULE}">{'SEQUENCE'|@getFixedLabel}</th>
                            {/if}
							{foreach item=header key=i from=$LISTHEADER}
								<th style="width:{$LISTHEADERWIDTH[$i]}px" headermodule='{$HEADERMODULE[$i]}' headername='{$HEADERNAME[$i]}' tag="{$i+1}">{$header}</th>
							{/foreach}
							{if $SELECT eq 'enable' && ($POPUPTYPE eq 'inventory_prod' || $POPUPTYPE eq 'inventory_prod_po') || ($SRCMODULE eq 'Attachment' && $MODULE eq 'Productbom')}
								{if !$RECORD_ID}
									<th width="{$OPERATIONWIDTH}">{'OPERATING'|@getFixedLabel}</th>
								{/if}
							{/if}
							</tr>
						</tbody>
	    			</table>
				</div>
			</div>
			<div style="overflow:auto;height:400px" id="resize_content_table_divid" name="resize_content_table_divid" style="width:{$LISTVIEWTOTALWIDTH}px">
				<table border="0" cellspacing="1" cellpadding="0" id="resize_content_tableid" name="resize_content_tableid" style="width:{$LISTVIEWTOTALWIDTH}px" class="listEntries marT-53" >
					<tbody>
						<tr>
						{if $SELECT eq 'enable'}
							<th class="firstChild" style="width:{$CHKBOXWIDTH}px" tag="0" headermodule="{$MODULE}" headername='chkbox'>
								<input type="checkbox" name="select_all" headermodule="{$MODULE}" value="" onclick="toggleSelect(this.checked,'selected_id')"/>
							</th>
						{/if}
                        {*// ljj 20231123 XUQIU1001991 选择源单优化*}
                        {if $SETSEQUENCE eq 'yes'}
                            <th style="width:50px;text-align: center" tag="sequence" headermodule="{$MODULE}">{'SEQUENCE'|@getFixedLabel}</th>
                        {/if}
						{foreach item=header key=i from=$LISTHEADER}
							<th style="width:{$LISTHEADERWIDTH[$i]}px" headermodule='{$HEADERMODULE[$i]}' headername='{$HEADERNAME[$i]}' tag="{$i+1}">{$header}</th>
						{/foreach}
						{if $SELECT eq 'enable' && ($POPUPTYPE eq 'inventory_prod' || $POPUPTYPE eq 'inventory_prod_po') || ($SRCMODULE eq 'Attachment' && $MODULE eq 'Productbom')}
							{if !$RECORD_ID}
								<th width="{$OPERATIONWIDTH}">{'OPERATING'|@getFixedLabel}</th>
							{/if}
						{/if}
						</tr>
                        {if $SELECT eq 'enable'&&$MODULE eq 'ServiceCharge'}
                                <tr>
                					<td id="Popup_choose_linkForSelectAll" class="linkForSelectAll" style="display:none;" colspan="{$LISTHEADERWIDTH|@count +1}">
                						<span id="Popup_choose_selectAllRec" class="selectall" style="display:inline;" onClick="Popup_choose_SelectAll_Records('{$MODULE}',true,'selected_id')">{'SELECTALL'|@getFixedLabel} <span id="count"> {$NUMOFROWS}</span> {'RECORDNUMS'|@getFixedLabel}</span>
                						<span id="Popup_choose_deSelectAllRec" class="selectall" style="display:none;" onClick="Popup_choose_SelectAll_Records('{$MODULE}',false,'selected_id')">{'DESELECTALL'|@getFixedLabel}</span>
                					</td>
                                </tr>
                            {/if}
						{$POPHTML}
                        {if $TOTALFLDHTML != ''}
                            {$TOTALFLDHTML}
                        {/if}
					</tbody>
				</table>
			</div>
		</div>
        {if $POPUPTYPE eq 'MultiplePopup'}
            <div name="redtip_limitcount" class="redFont" style="height:20px;margin:5px">{'DSFMFFQOTSTT5OTQR'|@getVarFixedLabel:$LIMITCOUNT}</div>
        {/if}
</form>
<div id="basicsearchcolumns" style="display:none;"><select name="search_field" id="bas_searchfield" style="width:150px">{html_options  options=$SEARCHLISTHEADER}</select></div>
<script language="JavaScript" type="text/javascript" src="include/js/cls_ModuleTree.js?v={$GLOBALMINVERSION}"></script>
<script>
    var module = '{$MODULE}'
    var tree_enable= empty('{$POPUPMODULElISTTREE.enable}')?'{$tree_enable}':'{$POPUPMODULElISTTREE.enable}';
    if(tree_enable == 'yes'){
        var popupobj=CrmPopup.getPopupObj("last");
        popupobj.module = module;
        var structureTreeobj=new structureTree();
        structureTreeobj.setEvent();
        structureTreeobj.treeWidth = empty('{$POPUPMODULElISTTREE.tree_width}')?'{$tree_width}':'{$POPUPMODULElISTTREE.tree_width}';
        // ljj 2023-08-29 XUQIU1001610 树结构设置和成员管理，左侧分类名称增加计数功能
        popupobj.list_TreeWhere = '{$Encrypt_TreeWhere}';
        structureTreeobj.getPopupModuleTreeCount(popupobj);
    }
</script>