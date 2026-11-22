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
 修改编码格式:统一编码：UTF-8
-->*}
{if $MODULE eq 'Events'}
{assign var=MODULE value='Calendar'}
{/if}
{if $MODULE eq 'Calendar'} 
<script type="text/javascript" src="modules/Calendar/Calendar.js"></script>
<script type="text/javascript" src="modules/Calendar/script.js"></script> 
{else}
<script type="text/javascript" src="modules/{$MODULE}/{$MODULE}.js"></script>
{/if}

<div class="ChildBotton">
<ul>
    {assign var="MODULELABEL" value=$MODULE|@getTranstab}
	{if $CATEGORY eq 'Settings'}
        <!-- No List View in Settings - Action is index -->
		<li class="Name"><a href="index.php?action=index&module={$MODULE}&parenttab={$CATEGORY}">{'CONTROLPANEL'|@getFixedLabel}</a></li>
	{elseif $MODULE eq 'Calendar'}
        <li class="Name"><a href="index.php?action=ListView&module=Calendar&parenttab={$CATEGORY}">{$MODULELABEL}</a></li>
    {elseif $MODULE eq 'Attachment'}
        <li class="Name"><a href="index.php?module=Attachment&action=index&parenttab=My Home Page">{$MODULELABEL}</a></li>
    {elseif $MODULE eq 'MailManager'}
        {assign var="MODULELABEL" value='Webmails'|@getTranslatedString:'Webmails'}
        <li class="Name"><a href="index.php?action=ListView&module=Emails&parenttab={$CATEGORY}">{$MODULELABEL|@getFixedLabel}</a></li>
    {else}
        <li class="Name"><a href="index.php?action=ListView&module={$MODULE}&parenttab={$CATEGORY}">{$MODULELABEL|@getFixedLabel}</a></li>
    {/if}
	{if $CHECK.Create eq 'yes'}                    
		{if $MODULE eq 'Calendar'}
            <li>
            <a class="Anu0_a" title="{'CREATE'|@getFixedLabel} {$MODULE|getTranstab}" href="index.php?module={$MODULE}&action=EditView&return_action=DetailView&parenttab={$CATEGORY}&Create=true">
            <img src="themes/softed/button/icon_add0.png" /><span>{'CREATE'|@getFixedLabel}</span></a>
            </li>
        {elseif  $MODULE eq 'SalesBack' || $MODULE eq 'CashBack' || $MODULE eq 'PurchaseBack' || $MODULE eq 'PurchaseCashBack'}
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
	<li>
    <a class="Anu0_a Anu0B" href="javascript:;">
    <img src="themes/softed/button/icon_search_black.png" /><span>{'SEARCH'|@getFixedLabel}</span></a>
    </li>
	{if $CALENDAR_DISPLAY eq 'true'} 
          {if $CATEGORY eq 'Settings' || $CATEGORY eq 'Tools' || $CATEGORY eq 'Analytics'} 
              {if $CHECK.Calendar eq 'yes'} 
               <li>
                    <a class="Anu0_a" title="{'CANENDAR'|@getFixedLabel}" onclick='fnvshobj(this,"miniCal");getMiniCal("parenttab=My Home Page");'>
                    <img src="themes/softed/button/icon_calendar.png" /><span>{'CANENDAR'|@getFixedLabel}</span></a>
               </li> 
		      {else}
                  <li>
                  <a class="Anu0_a" href="javascript:;">
                  <img src="themes/softed/button/icon_calendar.png" /><span>{'CANENDAR'|@getFixedLabel}</span></a>
                  </li>
              {/if}
	       {else}
		      {if $CHECK.Calendar eq 'yes'} 
                  <li>
                   <a class="Anu0_a" title="{'CANENDAR'|@getFixedLabel}" onClick='fnvshobj(this,"miniCal");getMiniCal("parenttab={$CATEGORY}");'>
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
        <a class="Anu0_a" onclick='return window.open("index.php?module=Home&action=vtchat","Chat","width=600,height=450,resizable=1,scrollbars=1");' title="{'CHAT'|@getFixedLabel}">
        <img src="themes/softed/button/icon_say.png" /><span>{'CHAT'|@getFixedLabel}</span></a>
        </li> 
    {/if} 
				
    {if $LAST_READ eq 'true' && $MODULE neq 'PublicAnnouncement'}
		<li>
        <a class="Anu0_a" onclick="fnvshobj(this,'tracker');" title="{'READEN'|@getFixedLabel}">
        <img src="themes/softed/button/icon_see.png" /><span>{'READEN'|@getFixedLabel}</span></a>
        </li>	
    {/if}
	{* vtlib customization: Hook to enable import/export button for custom modules. Added CUSTOM_MODULE *}
    {if $MODULE eq 'Vendors' || $MODULE eq 'HelpDesk' || $MODULE eq 'Contacts' ||  $MODULE eq 'Accounts' || $MODULE eq 'Potentials' || $MODULE eq 'Products' || $MODULE eq 'Documents' || $CUSTOM_MODULE eq 'true' }
   		{if $CHECK.Import eq 'yes' && $MODULE neq 'Documents'}	
			<li>
            {if $MODULE eq 'Accounts'}
                 <a name='export_link' class="Anu0_a" title="{'IMPORT'|@getFixedLabel} {$MODULE|getTranstab}" 
                     href="index.php?module={$MODULE}&action=ImportXls&step=1&return_module={$MODULE}&xlsStep=First&return_action=index&parenttab={$CATEGORY}" >
            {else}
                <a class="Anu0_a" title="{'IMPORT'|@getFixedLabel} {$MODULE|getTranstab}" 
                href="index.php?module={$MODULE}&action=Import&step=1&return_module={$MODULE}&return_action=index&parenttab={$CATEGORY}" >
           {/if}
            <img src="themes/softed/button/icon_rk.png" /><span>{'IMPORT'|@getFixedLabel}</span></a>
            </li>	
		{else}	
			<li>
            <a class="Anu0_a Anu0B" href="javascript:;">
            <img src="themes/softed/button/icon_rk_black.png" /><span>{'IMPORT'|@getFixedLabel}</span></a>
            </li>	
		{/if}	
		{if $CHECK.Export eq 'yes'}
			<li>
            <a name='export_link' class="Anu0_a" title="{'EXPORT'|@getFixedLabel} {$MODULE|getTranstab}" href="javascript:void(0)" onclick="return selectedRecords('{$MODULE}','{$CATEGORY}')" >
            <img src="themes/softed/button/icon_ck.png" /><span>{'EXPORT'|@getFixedLabel}</span></a>
            </li>
		{else}	
			<li>
            <a class="Anu0_a Anu0B" href="javascript:;">
            <img src="themes/softed/button/icon_ck_black.png" /><span>{'EXPORT'|@getFixedLabel}</span></a>
            </li>
        {/if}
	{else}             
        {if $MODULE eq 'Prdtnums'}               
        <li>
            <a name='export_link' class="Anu0_a" title="{'IMPORT'|@getFixedLabel} {$MODULE|getTranstab}" href="javascript:void(0);" onclick="importproduct();" >
            <img src="themes/softed/button/icon_rk.png" /><span>{'IMPORT'|@getFixedLabel}</span></a>
        </li>
        <li>
            <!-- <a name='export_link' class="Anu0_a" title="{'EXPORT'|@getFixedLabel} {$MODULE|getTranstab}" href="index.php?module={$MODULE}&action=ExportProduct&return_module={$MODULE}&return_action=index&parenttab={$CATEGORY}" >
            <img src="themes/softed/button/icon_ck.png" /><span>{'EXPORT'|@getFixedLabel}</span></a> -->
				<a class="Anu0_a Anu0B" href="javascript:;">
            <img src="themes/softed/button/icon_ck_black.png" /><span>{'EXPORT'|@getFixedLabel}</span></a>
        </li>
        {elseif $MODULE neq 'PublicAnnouncement'}
		<li>
            <a class="Anu0_a Anu0B" href="javascript:;">
            <img src="themes/softed/button/icon_rk_black.png" /><span>{'IMPORT'|@getFixedLabel}</span></a>
        </li>
        <li>
            <a class="Anu0_a Anu0B" href="javascript:;">
            <img src="themes/softed/button/icon_ck_black.png" /><span>{'EXPORT'|@getFixedLabel}</span></a>
        </li>
        {/if}
	{/if}
	{if $MODULE eq 'Contacts' || $MODULE eq 'Leads' || $MODULE eq 'Accounts'|| $MODULE eq 'Products'|| $MODULE eq 'HelpDesk'|| $MODULE eq 'Potentials'|| $MODULE eq 'Vendors'} 
		{if $VIEW eq true}
			<li>
            <a class="Anu0_a" title="{'FINDDUPLICATES'|@getFixedLabel}" href="index.php?module={$MODULE}&action=FindDuplicateRecords&button_view&list_view">
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
    {if $MODULE eq 'Calendar'}
        <li>
        <a class="Anu0_a" title="{'LBL_PAGE_SET'|@getFixedLabel}" href='index.php?module=Settings&action=LayoutBlockList&parenttab=Settings&formodule={$MODULE}'>
        <img src="themes/softed/button/icon_set0.png" /><span>{'LBL_PAGE_SET'|@getFixedLabel}</span></a>
        </li>
    {else}
        {if $MODULE neq 'BankAccountSet'}
            {if $CHECK.moduleSettings eq 'yes' }
        	<li>
            <a class="Anu0_a" title="{'LBL_PAGE_SET'|@getFixedLabel}" href='index.php?module=Settings&action=LayoutBlockList&parenttab=Settings&formodule={$MODULE}'>
            <img src="themes/softed/button/icon_set0.png" /><span>{'LBL_PAGE_SET'|@getFixedLabel}</span></a>
            </li>
    	   {/if}
       {/if}
    {/if}
    {if $MODULE|@get_file_address:'ProductDetails' eq 'true' && 'using_inventory'|@getDatainterface eq '1'}
        <li>
        <a class="Anu0_a" onclick="fnvshobj(this,'synchronousInventoryDiv');" href="javascript:;">
        <img src="themes/softed/button/icon_inventory.png" /><span>{'SYNCHRONOUSINVENTORY'|@getFixedLabel}</span></a>
        </li>
    {/if}
</ul>
</div>
<div id="synchronousInventoryDiv" class="LdPop_box LdPopWidth350px" style="display:none;">
	<div class="Title"><img src="themes/softed/tier/icon_loto.png" class="Logo" />
    <span class="Name">{'DATAEXCHANGE'|@getFixedLabel}——{'SYNCHRONOUSINVENTORY'|@getFixedLabel}</span>
		<a onclick="hideOptions('synchronousInventoryDiv');puyoungJS_DialogBox.unblock();">
			<img src="themes/softed/tier/icon_close.png" class="Close" />
		</a>
	</div>		
    <div class="Content_div">
    	<table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td class="Note">
        		<ul>
            		<li class="divPeople-Content">{'SYNCHRONOUSINVENTORYNOTE'|@getFixedLabel}</li>        
                    <li style="margin-top:15px;"><input type="radio" id="synchronousOne" name="Synchronous" checked="true">{'SYNCHRONOUSINVENTORYNOTEONE'|@getFixedLabel}</li>
                    <li><input type="radio" id="synchronousTwo" name="Synchronous">{'SYNCHRONOUSINVENTORYNOTETWO'|@getFixedLabel}</li>   
            	</ul>
            </td>
          </tr>
        </table>
    </div>
    <div class="Bottom">
        <div class="Bottom_div width145">
            <input type="button" value="{'SAVE'|@getFixedLabel}" class="Button_saveGreen width60" onclick="disableStyle();synchronousInventory()"/><span>&nbsp;</span>
            <a onclick="hideOptions('synchronousInventoryDiv');puyoungJS_DialogBox.unblock();" class="Button_backOrg width60">{'CANCEL'|@getFixedLabel}</a>
        </div>
    </div>
</div>