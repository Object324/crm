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
<!-- BEGIN: main -->
<link rel="stylesheet" type="text/css" href="themes/softed/selfstyle.css"/>
<script type="text/javascript" src="{$JSURL}include/js/ListView.js"></script>
<script type="text/javascript" src="{$JSURL}include/js/MassSMS.js"></script>

<form name="selectall" method="POST">
<!--分页-->
<div class="Paging_div Paging_divBjtop">
<table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
        <td valign="top" class="L">
            <div class="Showselect">
                {if $MODULE|@get_file_address:'ProductDetails' == true}
                    {if $LISTALL eq 0}
                        <input class="saveauto" type="button" value="{'SELECT'|@getFixedLabel} {$MODULE|@getTranstab} " onclick="if(SelectProductAll('{$MODULE}','{$RETURN_MODULE}')) window.close();"/>
                    {else}
                        <input class="saveauto" type="button" value="{'SELECT'|@getFixedLabel} {$MODULE|@getTranstab}" onclick="if(selectMoreModuleSource('{$FROMMODULE}'))window.close();"/>
                    {/if}
                {else}
                    <input class="saveauto" type="button" value="{'SELECT'|@getFixedLabel} {$MODULE|@getTranstab} " onclick="if(SelectListValAll('{$MODULE}','{$FROMMODULE}','{$LISTALL}')) window.close();"/>
                {/if}
            </div>
        </td>
        <!--td valign="top" class="R">
            <div class="PageDiv0" style="padding:5px 0px;">
                <ul>
                    {$NAVIGATION}
                </ul>
            </div>
        </td-->
    </tr>
</table>
</div>
<!--分页  end-->
<div class="clear"></div>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
        <td style="padding:0px;" colspan=3>
		<input type="hidden" id="rowcnt" name="rowcnt" value="{$ROWCNT}" />
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
        <input  type="hidden" value="{$HAVENOCOLUMN}" id="haveproductcolumnpop"/>
        {if $POPUPTYPE neq 'set_return_groupemails'}
            <input name="row_of_checkbox_contact_pop" id="row_of_checkbox_contact_pop" type="hidden" value="{$num_rows_contact}"/>
        {else}
            <input name="row_of_checkbox_contact_pop_email" id="row_of_checkbox_contact_pop_email" type="hidden" value="{$num_rows_contact_Email}"/>
        {/if}
        <!--end-->
        
		<table class="listEntries fir-center" border="0" cellpadding="0" cellspacing="1" width="150%" id="producttable">
		<tbody>
        <tr>
            <th>
            <input type="checkbox" name="select_all" value="" onclick="toggleSelect(this.checked,'selected_id')"/></th>
            {foreach item=header key=entity_id from=$LISTHEADER}
                <th>{$header}</th>
            {/foreach}
        </tr>
		{if $LISTENTITY != ''}
         {foreach key=entity_id item=entity name=listdatd from=$LISTENTITY}
            {assign var="redcordid" value=$entity_id}
            {if $MODULE == 'ServiceContracts'}
                {assign var="inventoryid" value=$entity_id|@getInventoryLineItem}
            {else}
                {assign var="inventoryid" value=$entity_id|@substrTd:4}
            {/if}
            {assign var="productid" value=$inventoryid|@getInventoryProId}
            {assign var="tdi" value=$entity_id|@substrTd:3}
            {if $smarty.foreach.listdatd.iteration is even}
	        <tr class="lvtColDataBj" onmouseover="setTrColor('row_{$entity_id}','{$entity_id}','{$entity_id}')" onmouseout="setTrColorOut('row_{$entity_id}','{$entity_id}','{$entity_id}','On')" id="row_{$entity_id}" >
            {else}
            <tr class="lvtColData" onmouseover="setTrColor('row_{$entity_id}','{$entity_id}','{$entity_id}')" onmouseout="setTrColorOut('row_{$entity_id}','{$entity_id}','{$entity_id}','on')" id="row_{$entity_id}" >
            {/if}
                {if $FROMMODULE eq 'PurchaseInvoice' && $MODULE neq 'ServiceContracts'}
                    {if $LISTENTITY[$entity_id][0] neq '&&'}
                        <td rowspan="{$redcordid|@getTableRowCell:$LISTENTITY}" valign="top" onclick="toggleSelectAll_parent_td(this)">
                            <input type="checkbox" name="selected_id" value="{$entity_id|@substrTd:1}" onclick="toggleSelectAll(this.name,'select_all')"/>
                        </td>
                    {/if}  
                {else}
                    {if $redcordid|@getTableRowBottom:$LISTENTITY < $redcordid|@getTableRowCell:$LISTENTITY}
                        <td valign="top" onclick="toggleSelectAll_parent_td(this)">
                            <input type="checkbox" name="selected_id" value="{$entity_id}" onclick="toggleSelectAll(this.name,'select_all')"/>
                        </td>
                    {else}
                        <td valign="top" onclick="toggleSelectAll_parent_td(this)">{*$entity_id|@substrTd:3*}
                            <input type="checkbox" name="selected_id" value="{$entity_id}" onclick="toggleSelectAll(this.name,'select_all')"/>
                        </td>
                    {/if}
                {/if}
                {if $MODULE|@get_file_address:'ProductDetails' == true}
                          {if $HAVENOCOLUMN eq 'no'}
                            {assign var="productDetails"  value=$entity_id|@substrTd:1|@getInventoryProductDetails:$LISTVAL:$MODULE:$FROMMODULE}
                             {foreach item=prodetail from=$productDetails key=proindex }
                                 {if $MODULE == 'ServiceContracts'}
                       
                                    <input type="hidden" id="popup_product_{$entity_id}" vt_prod_arr='{$prodetail}' />
                                {else}
                                    <input type="hidden" id="popup_product_{$entity_id|@substrTd:1}" vt_prod_arr='{$prodetail}'  />
                                {/if}
                             {/foreach}
                          {/if}
                {/if}
                {foreach item=data from=$entity key=entity_id}
                    {if $entity_id|@istdRight:$module==true}
                        {assign var="tdalign" value='right'}
                    {else}
                        {assign var="tdalign" value='left'}
                    {/if}
                    {*{if $entity_id <= $ROW_COUNT - 1 && $data neq '&&' && $redcordid|@getTableRowCell:$LISTENTITY > 1} *}
                    {if $entity_id <= $ROWSPAN && $data neq '&&'}
                        <td align="{$tdalign}" rowspan="{$redcordid|@getTableRowCell:$LISTENTITY}" valign="top">{$data}&nbsp;</td>
                    {elseif $data neq '&&'}
                        <td align="{$tdalign}" valign="top">
                            {$data|@getTranslatedString:$MODULE}&nbsp;
                        </td>
                    {/if}
    	        {/foreach}
            </tr>
		{foreachelse}
            <tr align="center">
                <td colspan="15" bgcolor="#efefef">
                <div class='popupnoResultBG' >  
                    <div class='noResultContent'> 
                        <div  class="divNoRecord">{'NOTFOUNDANYRECORD'|@getFixedLabel}!</div>
                    </div>
               </div>
                {*
                <div style="border: 3px solid rgb(153, 153, 153); background-color: rgb(255, 255, 255); width: 99%;position: relative; z-index: 1000;">
                    <table border="0" cellpadding="5" cellspacing="0" width="98%">
                        <tr>
                            <td rowspan="2" width="25%"><img src="{'empty.jpg'|@lingdang_imageurl:$THEME}" height="60" width="61%"></td>
                            <td style="border-bottom: 1px solid rgb(204, 204, 204);" nowrap="nowrap" width="75%"><span class="genHeaderSmall">{'NOTFOUNDANYRECORD'|@getFixedLabel}!</td>
                        </tr>
                    </table>
                </div>
                *}
                </td>
            </tr>
        {/foreach}
		{else}
			<tr align="center">
                <td colspan="14" bgcolor="#efefef">
                <div class='popupnoResultBG' >  
                    <div class='noResultContent'> 
                        <div  class="divNoRecord">{'NOTFOUNDANYRECORD'|@getFixedLabel}!</div>
                    </div>
               </div>
               {*
                <div style="border: 3px solid rgb(153, 153, 153); background-color: rgb(255, 255, 255); width: 99%;position: relative; z-index: 1000;">
                    <table border="0" cellpadding="5" cellspacing="0" width="98%">
                        <tr>
                            <td rowspan="2" width="25%"><img src="{'empty.jpg'|@lingdang_imageurl:$THEME}" height="60" width="61%"></td>
                            <td style="border-bottom: 1px solid rgb(204, 204, 204);" nowrap="nowrap" width="75%"><span class="genHeaderSmall">{'NOTFOUNDANYRECORD'|@getFixedLabel}!</td>
                        </tr>
                    </table>
                </div>
                *}
                </td>
            </tr>
		{/if}
        </tbody>
        </table>
         {if $DSNCOCOTSTP5TQR eq 'DSNCOCOTSTP5TQR'}
            {if $MODULE != 'PurchaseOrder'}
            <span  style="color:red;position:absolute;padding:15px 0px 15px 20px">{'DSFMFFQOTSTT5OTQR'|@getFixedLabel}</span>
            {else if $MODULE eq 'PurchaseOrder'}
            <span  style="color:red;position:absolute;padding:15px 0px 15px 20px">{'DSNCOVOTSTP5TQR'|@getFixedLabel}</span>
            {/if}
        {/if}
        </td>
	</tr>
</table>
</form>
<div id="basicsearchcolumns" style="display:none;"><select name="search_field" id="bas_searchfield" style="width:150px">{html_options  options=$SEARCHLISTHEADER}</select></div>