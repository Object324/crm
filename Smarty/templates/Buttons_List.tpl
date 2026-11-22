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
<div class="ChildBotton">
<ul>
{if $ACTION neq ''}
{assign var="action" value=$ACTION}
{else}
    {if $MODULE eq 'MassSMS'}
	{assign var="action" value="index"}
    {else}
    {assign var="action" value="ListView"}
    {/if}
    {/if}
    {if $MASSEMAILS neq ''}    
    {assign var="MODULELABEL" value=$MASSEMAILS}
    {else}    
	{assign var="MODULELABEL" value=$MODULE|@getTranstab}	
    {/if}
	<li class="Name"><a href="index.php?action={$action}&module={$MODULE}&parenttab={$CATEGORY}">{$MODULELABEL}</a></li>
	   {if $CHECK.Create eq 'yes' && $MODULE neq 'Emails' && $MODULE neq 'Webmails' && $MODULE neq 'MassSMS' 
       && $MODULE neq 'RecycleBin' && $MODULE neq 'InventoryAccount' && $MODULE neq 'InventoryQuery'}
            {if $MODULE eq 'Calendar'}
                <li>
                <a class="Anu0_a" title="{'CREATE'|@getFixedLabel} {$MODULE|getTranstab}" href="index.php?module={$MODULE}&action=EditView&return_action=ListView&activity_mode=Events&&parenttab={$CATEGORY}&Create=true">
                <img src="themes/softed/button/icon_add0.png" /><span>{'CREATE'|@getFixedLabel}</span></a>
                </li>
	        {elseif $MODULE eq 'SalesBack' || $MODULE eq 'CashBack' || $MODULE eq 'PurchaseBack' || $MODULE eq 'PurchaseCashBack'}
                <li>
                <a class="Anu0_a Anu0B" href="javascript:;">
                <img src="themes/softed/button/icon_add0_black.png" /><span>{'CREATE'|@getFixedLabel}</span></a>
                </li>
            {else}
            	<li>
                <a class="Anu0_a" title="{'CREATE'|@getFixedLabel} {$MODULE|getTranstab}" href="index.php?module={$MODULE}&action=EditView&return_action=DetailView&parenttab={$CATEGORY}&Create=true">
                <img src="themes/softed/button/icon_add0.png" /><span>{'CREATE'|@getFixedLabel}</span></a>
                </li>
            {/if} 
		{else}
			<li>
            <a class="Anu0_a Anu0B" href="javascript:;">
            <img src="themes/softed/button/icon_add0_black.png" /><span>{'CREATE'|@getFixedLabel}</span></a>
            </li>
		{/if}
		{if $CHECK.index eq 'yes' && $MODULE neq 'Emails' && $MODULE neq 'Webmails' && $MODULE neq 'MassSMS'}
			 <li>
                <a class="Anu0_a" title="{'SEARCH'|@getFixedLabel} {$MODULE|getTranstab}" onclick="moveMe('searchAcc');searchshowhide('searchAcc','advSearch');mergehide('mergeDup')" >
                <img src="themes/softed/button/icon_search.png" /><span>{'SEARCH'|@getFixedLabel}</span></a>
            </li>
		{else}
			<li>
                <a class="Anu0_a Anu0B" href="javascript:;">
                <img src="themes/softed/button/icon_search_black.png" /><span>{'SEARCH'|@getFixedLabel}</span></a>
            </li>
		{/if}
		
		{if $CALENDAR_DISPLAY eq 'true'} 
            {if $CATEGORY eq 'Settings' || $CATEGORY eq 'Tools' || $CATEGORY eq 'Analytics'} 
                {if $CHECK.Calendar eq 'yes'} 
                    <li>
                    <a class="Anu0_a" title="{'CANENDAR'|@getFixedLabel}" href="javascript:;" onClick='fnvshobj(this,"miniCal");getMiniCal("parenttab=My Home Page");' >
                    <img src="themes/softed/button/icon_calendar.png" /><span>{'CANENDAR'|@getFixedLabel}</span></a>
                    </li> 
                {else} 
                    <li>
                    <a class="Anu0_a Anu0B" href="javascript:;">
                    <img src="themes/softed/button/icon_calendar.png" /><span>{'CANENDAR'|@getFixedLabel}</span></a>
                    </li> 
                {/if} 
			{else}
				{if $CHECK.Calendar eq 'yes'} 
                    <li>
                    <a class="Anu0_a" title="{'CANENDAR'|@getFixedLabel}" href="javascript:;" onClick='fnvshobj(this,"miniCal");getMiniCal("parenttab={$CATEGORY}");' >
                    <img src="themes/softed/button/icon_calendar.png" /><span>{'CANENDAR'|@getFixedLabel}</span></a>
                    </li> 
                {else} 
                    <li>
                    <a class="Anu0_a Anu0B" href="javascript:;">
                    <img src="themes/softed/button/icon_calendar.png" /><span>{'CANENDAR'|@getFixedLabel}</span></a>
                    </li> 
                {/if} 
            {/if}
        {/if}
        {if $WORLD_CLOCK_DISPLAY eq 'true'} 
            <li>
            <a class="Anu0_a" onclick="fnvshobj(this,'wclock');" title="{'CLOCK'|@getFixedLabel}">
            <img src="themes/softed/button/icon_clock.png" /><span>{'CLOCK'|@getFixedLabel}</span></a>
            </li> 
        {/if} 
        {if $CALCULATOR_DISPLAY eq 'true'} 
            <li>
            <a class="Anu0_a" onclick="fnvshobj(this,'calculator_cont');fetch_calc();" title="{'CALCULATORS'|@getFixedLabel}">
            <img src="themes/softed/button/icon_calculator.png" /><span>{'CALCULATORS'|@getFixedLabel}</span></a>
            </li> 
        {/if} 
        {if $CHAT_DISPLAY eq 'true' && $MODULE neq 'PublicAnnouncement'} 
            <li>
            <a class="Anu0_a" onclick='return window.open("index.php?module=Home&action=vtchat","Chat","width=600,height=450,resizable=1,scrollbars=1");' 
            title="{'CHAT'|@getFixedLabel}">
            <img src="themes/softed/button/icon_say.png" /><span>{'CHAT'|@getFixedLabel}</span></a>
            </li> 
        {/if} 
        {if $LAST_READ eq 'true' && $MODULE neq 'PublicAnnouncement'}	
			<li>
            <a class="Anu0_a" onclick="fnvshobj(this,'tracker');" title="{'READEN'|@getFixedLabel}">
            <img src="themes/softed/button/icon_see.png" /><span>{'READEN'|@getFixedLabel}</span></a>
            </li>
        {/if}	
		{if $MODULE eq 'Vendors' || $MODULE eq 'HelpDesk' || $MODULE eq 'Contacts'  || $MODULE eq 'Accounts' || $MODULE eq 'Potentials' || $MODULE eq 'Products' || $MODULE eq 'Documents'|| $CUSTOM_MODULE eq 'true' || $MODULE eq 'Calendar'}
   		    {if $CHECK.Import eq 'yes' && $MODULE neq 'Documents' && $MODULE neq 'Calendar'}	
				<li>
                {if $MODULE eq 'Accounts'}
                     <a class="Anu0_a" title="{'IMPORT'|@getFixedLabel} {$MODULE|getTranstab}" href="index.php?module={$MODULE}&action=ImportXls&xlsStep=First&return_module={$MODULE}&return_action=index&parenttab={$CATEGORY}" >
                 {else}
                     <a class="Anu0_a" title="{'IMPORT'|@getFixedLabel} {$MODULE|getTranstab}" href="index.php?module={$MODULE}&action=Import&step=1&return_module={$MODULE}&return_action=index&parenttab={$CATEGORY}" >
                 {/if}
                <img src="themes/softed/button/icon_rk.png" /><span>{'IMPORT'|@getFixedLabel}</span></a>
                </li>	
			{elseif  $CHECK.Import eq 'yes' && $MODULE eq 'Calendar'}
                <li>
                <a name='import_link' class="Anu0_a" title="{'IMPORT'|@getFixedLabel} {$MODULE|getTranstab}" 
                href="javascript:void(0);" onclick="fnvshobj(this,'CalImport');" >
                <img src="themes/softed/button/icon_rk.png" /><span>{'IMPORT'|@getFixedLabel}</span></a>
                </li>
			{else}	
				<li>
                <a class="Anu0_a Anu0B" href="javascript:;">
                <img src="themes/softed/button/icon_rk_black.png" /><span>{'IMPORT'|@getFixedLabel}</span></a>
                </li>	
			{/if}			
        {elseif $MODULE eq 'ContactRecords'}
            <li>
            <a class="Anu0_a" title="{'IMPORT'|@getFixedLabel} {$MODULE|getTranstab}" 
            href="index.php?module={$MODULE}&action=Import&step=1&return_module={$MODULE}&return_action=index&parenttab={$CATEGORY}" >
            <img src="themes/softed/button/icon_rk.png" /><span>{'IMPORT'|@getFixedLabel}</span></a>
            </li>	
		{elseif $MODULE eq 'SalesOrder' && $CHECK.Import eq 'yes'}
            <li>
                <a name='export_link' class="Anu0_a" title="{'IMPORT'|@getFixedLabel} {$MODULE|getTranstab}" 
                href="index.php?module={$MODULE}&action=ImportXls&step=1&return_module={$MODULE}&xlsStep=First&return_action=index&parenttab={$CATEGORY}" >
                <img src="themes/softed/button/icon_rk.png" /><span>{'IMPORT'|@getFixedLabel}</span></a>
            </li>            
        {elseif $MODULE eq 'PurchaseOrder' && $CHECK.Import eq 'yes'}
            <li>
            <a class="Anu0_a Anu0B" href="javascript:;">
            <img src="themes/softed/button/icon_rk_black.png" /><span>{'IMPORT'|@getFixedLabel}</span></a>
            </li>           
        {elseif $MODULE eq 'Quotes' && $CHECK.Import eq 'yes'}
            <li>
            <a class="Anu0_a Anu0B" href="javascript:;">
            <img src="themes/softed/button/icon_rk_black.png" /><span>{'IMPORT'|@getFixedLabel}</span></a>
            </li>             
        {elseif ($MODULE eq 'SalesBack' || $MODULE eq 'CashBack') && $CHECK.Import eq 'yes'}   
            <li>
            <a class="Anu0_a Anu0B" href="javascript:;">
            <img src="themes/softed/button/icon_rk_black.png" /><span>{'IMPORT'|@getFixedLabel}</span></a>
            </li>
        {elseif $MODULE neq 'PublicAnnouncement'}
			<li>
            <a class="Anu0_a Anu0B" href="javascript:;">
            <img src="themes/softed/button/icon_rk_black.png" /><span>{'IMPORT'|@getFixedLabel}</span></a>
            </li>
		{/if}

		<!-- Export Start -->
		{if $CHECK.Export eq 'yes'}
			{assign var="exportproduct" 
				value=",,SalesOrder,PurchaseOrder,Quotes,SalesBack,CashBack,Invoice,OutboundOrder,Stock,Checks,Accounts"}
			{assign var="exportmodule" 
				value=",,Accounts,Calendar,ContactRecords,InventoryLedger,"}
			{assign var="modulelab" value=,$MODULE,}
			{if strpos($exportproduct,$modulelab)}<!-- 直接导出excel的模块 -->
				<li>
					<a name='export_link' class="Anu0_a" title="{'EXPORT'|@getFixedLabel} {$MODULE|getTranstab}" 
						href="index.php?module={$MODULE}&action=Export{$MODULE}" >
					<img src="themes/softed/button/icon_ck.png" /><span>{'EXPORT'|@getFixedLabel}</span></a>
				</li>
				{if $MODULE eq 'SalesOrder' }
					<!--li>
						 <a name='export_link' class="Anu0_a" title="{'EXPORTTEMPLATES'|@getFixedLabel}" 
						 href="javascript:void(0)" onclick="return ExportFields('{$MODULE}','{$CATEGORY}')" >
						 <img src="themes/softed/button/icon_ck.png" /><span>{'EXPORTTEMPLATES'|@getFixedLabel}</span></a>
					</li-->
				{/if}
			{elseif strpos($exportmodule,$modulelab)}<!-- 特别处理的模块 -->
				{if $MODULE eq 'Accounts'}
					<li>
						<a name='export_link' class="Anu0_a" title="{'EXPORT'|@getFixedLabel} {$MODULE|getTranstab}" 
							href="javascript:void(0)" onclick="return selectedRecords('{$MODULE}','{$CATEGORY}')" >
						<img src="themes/softed/button/icon_ck.png" /><span>{'EXPORT'|@getFixedLabel}</span></a>
					</li>
                    
					<li>
						<a class="Anu0_a" title="{'EXPORTCUSTCONTACT'|@getFixedLabel}" 
						href="javascript:void(0)" onclick="return selectedRecords('Accounts','Con Accounts')" >
						<img src="themes/softed/button/icon_ck.png" /><span>{'EXPORTCUSTCONTACT'|@getFixedLabel}</span></a>
					</li>
    	           <!--li>
						 <a name='export_link' class="Anu0_a" title="{'EXPORTTEMPLATES'|@getFixedLabel}" 
						 href="javascript:void(0)" onclick="return ExportFields('{$MODULE}','{$CATEGORY}')" >
						 <img src="themes/softed/button/icon_ck.png" /><span>{'EXPORTTEMPLATES'|@getFixedLabel}</span></a>
					</li-->
				{elseif $MODULE eq 'Calendar'}
					<li>
						 <a name='export_link' class="Anu0_a" title="{'EXPORT'|@getFixedLabel} {$MODULE|getTranstab}" 
							href="javascript:void(0);" onclick="return exportCalendar();" >
						 <img src="themes/softed/button/icon_ck.png" /><span>{'EXPORT'|@getFixedLabel}</span></a>
					</li>
				{elseif $MODULE eq 'ContactRecords'}
					<li>
						<a name='export_link' class="Anu0_a" title="{'EXPORT'|@getFixedLabel} {$MODULE|getTranstab}" 
							href="javascript:void(0)" onclick="return selectedRecords('{$MODULE}','{$CATEGORY}')" >
						<img src="themes/softed/button/icon_ck.png" /><span>{'EXPORT'|@getFixedLabel}</span></a>
					</li>
				{elseif $MODULE eq 'InventoryLedger'}
					<li>
						<a name='export_link' class="Anu0_a" title="{'EXPORT'|@getFixedLabel} {$MODULE|getTranstab}" 
							href="javascript:void(0)" onclick="return exportInventoryLedger()" >
						<img src="themes/softed/button/icon_ck.png" /><span>{'EXPORT'|@getFixedLabel}</span></a>
					</li>
				{else}
					<li>
						<a name='export_link' class="Anu0_a" title="{'EXPORT'|@getFixedLabel} {$MODULE|getTranstab}" 
							href="javascript:void(0)" onclick="return selectedRecords('{$MODULE}','{$CATEGORY}')" >
						<img src="themes/softed/button/icon_ck.png" /><span>{'EXPORT'|@getFixedLabel}</span></a>
					</li>
				{/if}
			{elseif $MODULE neq 'PublicAnnouncement'}<!-- 普通模块 -->
				<li>
					<a name='export_link' class="Anu0_a" title="{'EXPORT'|@getFixedLabel} {$MODULE|getTranstab}" 
						href="javascript:void(0)" onclick="return selectedRecords('{$MODULE}','{$CATEGORY}')" >
					<img src="themes/softed/button/icon_ck.png" /><span>{'EXPORT'|@getFixedLabel}</span></a>
				</li>
			{/if}
		{else}
				<li>
					<a class="Anu0_a Anu0B" href="javascript:;">
					<img src="themes/softed/button/icon_ck_black.png" /><span>{'EXPORT'|@getFixedLabel}</span></a>
				</li>
		{/if}
		<!-- Export End -->
		
		{if $MODULE eq 'Contacts' || $MODULE eq 'Leads' || $MODULE eq 'Accounts'|| $MODULE eq 'Products'|| $MODULE eq 'Potentials'|| $MODULE eq 'HelpDesk'|| $MODULE eq 'Vendors' || $CUSTOM_MODULE eq 'true'} 
			{if $CHECK.DuplicatesHandling eq 'yes'}	
				<li>
                
                <a class="Anu0_a" title="{'FINDDUPLICATES'|@getFixedLabel}" 
                onclick="showmergeDup(this,'{$MODULE}')">
                <img src="themes/softed/button/icon_search0.png" /><span>{'FINDDUPLICATES'|@getFixedLabel}</span></a>
                </li>
			{else}
				<li>
                <a class="Anu0_a Anu0B" href="javascript:;">
                <img src="themes/softed/button/icon_search0_black.png" /><span>{'FINDDUPLICATES'|@getFixedLabel}</span></a>
                </li>	
			{/if}
		{elseif $MODULE neq 'PublicAnnouncement'}
			<li>
            <a class="Anu0_a Anu0B" href="javascript:;">
            <img src="themes/softed/button/icon_search0_black.png" /><span>{'FINDDUPLICATES'|@getFixedLabel}</span></a>
            </li>
		{/if}
        {if $MODULE neq 'BankAccountSet'}
		{if $CHECK.moduleSettings eq 'yes'}
    		<li>
            <a class="Anu0_a" title="{'LBL_PAGE_SET'|@getFixedLabel}" 
            href='index.php?module=Settings&action=LayoutBlockList&parenttab=Settings&formodule={$MODULE}'>
            <img src="themes/softed/button/icon_set0.png" /><span>{'LBL_PAGE_SET'|@getFixedLabel}</span></a>
            </li>
		{/if}
        {/if}
        {if $MODULE eq 'Products' && 'using_inventory'|@getDatainterface eq '1'}
			<li>
            <a class="Anu0_a" onclick="fnvshobj(this,'synchronousInventoryDiv');" href="javascript:;">
            <img src="themes/softed/button/icon_inventory.png" /><span>{'SYNCHRONOUSINVENTORY'|@getFixedLabel}</span></a>
            </li>		
        {/if}
	</ul>
    <input type="hidden" name="haha" id="haha" value="1" />
    <div class="R">
            {if $HELPDESK_SUPPORT_QQ neq '' && $ISCONFIG && $LANGEUAGETYPE eq 'zh'}
            <a href="http://wpa.qq.com/msgrd?V=1&Uin={$HELPDESK_SUPPORT_QQ}&Site=在线咨询&Menu=yes&ISCONFIG={$ISCONFIG}" target="_blank">
            <img src="http://wpa.qq.com/pa?p=1:{$HELPDESK_SUPPORT_QQ}:3" alt="{'ONLINECONSULTATION'|@getFixedLabel}" border="0"></a>
            {/if}
    </div>
</div>
<div id="synchronousInventoryDiv" class="D_pop_box LdPopWidth400px" style="display:none;">
	<div class="D_pop_tit">
    	<strong class="D_ptita">{'DATAEXCHANGE'|@getFixedLabel}——{'SYNCHRONOUSINVENTORY'|@getFixedLabel}</strong>
        <a class="D_ptitc" href="javascript:hideOptions('synchronousInventoryDiv');puyoungJS_DialogBox.unblock();">
            <img title="关闭" alt="关闭" src="themes/icon/pop_close.png" class="D_ptitcimg">
        </a>
    </div>

	<table class="D_pop_bod" width="100%" cellspacing="1" cellpadding="2" border="0">
	  <tr><td class="Note">{'SYNCHRONOUSINVENTORYNOTE'|@getFixedLabel}</td></tr>
	  <tr><td><input type="radio" id="synchronousOne" name="Synchronous" checked="true">{'SYNCHRONOUSINVENTORYNOTEONE'|@getFixedLabel}</td></tr>
	  <tr><td><input type="radio" id="synchronousTwo" name="Synchronous">{'SYNCHRONOUSINVENTORYNOTETWO'|@getFixedLabel}</td></tr>
	</table>

    <div class="D_pbtn">
        <input class="D_pbtnok" type="button" value="{'SAVE'|@getFixedLabel}" onclick="disableStyle();synchronousInventory()"/><span>&nbsp;</span>
            <input type="button" onclick="fninvshnew('synchronousInventoryDiv');" value="{'CANCEL'|@getFixedLabel}" class="D_pbtncancel">   

    </div>
</div>