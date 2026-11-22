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
			{*收款、付款、佣金 、费用报销， 选择原单没有产品明细*}
			{ if $FROMMODULE|@get_file_address:'ProductDetails' == false}
				<input class="saveauto" type="button" value="{'SELECT'|@getFixedLabel} {$MODULE|@getTranstab} " onclick="if(SelectListValAll('{$MODULE}','{$FROMMODULE}','{$LISTALL}')) window.close();"/>
			{else}
                {if $MODULE|@get_file_address:'ProductDetails' == true}
                    {if $LISTALL eq 0}
                        <input class="saveauto" type="button" value="{'SELECT'|@getFixedLabel} {$MODULE|@getTranstab} " onclick="if(SelectProductAll('{$MODULE}','{$RETURN_MODULE}')) window.close();"/>
						
                    {else}
                        <input class="saveauto" type="button" value="{'SELECT'|@getFixedLabel} {$MODULE|@getTranstab}" onclick="if(selectMoreModuleSource('{$FROMMODULE}'))window.close();"/>
						
                    {/if}
                {else}
                    <input class="saveauto" type="button" value="{'SELECT'|@getFixedLabel} {$MODULE|@getTranstab} " onclick="if(SelectListValAll('{$MODULE}','{$FROMMODULE}','{$LISTALL}')) window.close();"/>
                {/if}
			{/if}
            </div>
        </td>
        {if $NAVI neq 'NAVI'}
        <td valign="top" class="R">
            <div class="PageDiv0" style="padding:5px 0px;">
                <div class="ld-flex-start">
                    {$NAVIGATION}
                </div>
            </div>
        </td>
        {/if}
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
		<input type="hidden" value="{$LISTALL}" id="listall" name="listall" />
        {if $POPUPTYPE neq 'set_return_groupemails'}
            <input name="row_of_checkbox_contact_pop" id="row_of_checkbox_contact_pop" type="hidden" value="{$num_rows_contact}"/>
        {else}
            <input name="row_of_checkbox_contact_pop_email" id="row_of_checkbox_contact_pop_email" type="hidden" value="{$num_rows_contact_Email}"/>
        {/if}
        <!--end-->
        
		<table class="listEntries fir-center" border="0" cellpadding="0" cellspacing="1" width="{$TABLEWIDTH}%" id="producttable">
		<tbody>
        <tr>
            <th>
            <input type="checkbox" name="select_all" value="" onclick="toggleSelect(this.checked,'selected_id')"/></th>
            {foreach item=header key=entity_id from=$LISTHEADER}
                <th><span title="{$header}">{$header}</span></th>
            {/foreach}
        </tr>
		{if $LISTENTITY != ''}
         {assign var="j" value="1"}
         {assign var="old_checkvalueid" value="0"}
         {foreach key=entity_id item=entity from=$LISTENTITY}
            {assign var="redcordid" value=$entity_id}
            {if $MODULE == 'ServiceContracts'}
                {assign var="inventoryid" value=$entity_id|@getInventoryLineItem}
            {else}
                {assign var="inventoryid" value=$entity_id|@substrTd:4}
            {/if}
            {assign var="productid" value=$inventoryid|@getInventoryProId}
            {assign var="tdi" value=$entity_id|@substrTd:3}
            {if $entity_id|@substrTd:1 != $old_checkvalueid}
                {assign var="j" value=$j+1}
            {/if}
	        {if $j mod 2 eq '0'}
                <tr id="row_{$entity_id}" class="lvtColData" onmouseout="setTrColorOut('row_{$entity_id}','{$entity_id}','{$entity_id}','on')" onmouseover="setTrColor('row_{$entity_id}','{$entity_id}','{$entity_id}')">
            {else}
                <tr id="row_{$entity_id}" class="lvtColDataBj" onmouseout="setTrColorOut('row_{$entity_id}','{$entity_id}','{$entity_id}','On')" onmouseover="setTrColor('row_{$entity_id}','{$entity_id}','{$entity_id}')">
            {/if}
            {assign var="old_checkvalueid" value=$entity_id|@substrTd:1}
                {if $FROMMODULE eq 'Invoice' && $MODULE neq 'ServiceContracts'}
                    {if $LISTENTITY[$entity_id][0] neq '&&'}
                        <td rowspan="{$redcordid|@getTableRowCell:$LISTENTITY}" valign="top" onclick="toggleSelectAll_parent_td(this)">
                            <input id="{$entity_id}" type="checkbox" name="selected_id" value="{$entity_id|@substrTd:1}" onclick="toggleSelectAll(this.name,'select_all','{$entity_id}')"/>
                        </td>
                    {/if}  
                {else}
                    {if $redcordid|@getTableRowBottom:$LISTENTITY < $redcordid|@getTableRowCell:$LISTENTITY}
                        <td valign="top" onclick="toggleSelectAll_parent_td(this)">
                            <input id="{$entity_id}" type="checkbox" name="selected_id" value="{$entity_id}" onclick="toggleSelectAll(this.name,'select_all','{$entity_id}')"/>
                        </td>
                    {else}
                        <td valign="top" onclick="toggleSelectAll_parent_td(this)">{*$entity_id|@substrTd:3*}
                            <input id="{$entity_id}" type="checkbox" name="selected_id" value="{$entity_id}" onclick="toggleSelectAll(this.name,'select_all','{$entity_id}')"/>
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
                        <td align="{$tdalign}" rowspan="{$redcordid|@getTableRowCell:$LISTENTITY}" valign="top">
                            <span title="{$data}">{$data}</span>&nbsp;
                        </td>
                    {elseif $data neq '&&'}
                        <td align="{$tdalign}" valign="top">
                            <span title="{$data|@getTranslatedString:$MODULE}">{$data|@getTranslatedString:$MODULE}</span>
                            &nbsp;
                        </td>
                    {/if}
    	        {/foreach}
            </tr>
		{foreachelse}
            <tr>
                <td colspan="15" align="center" bgcolor="#efefef">
                <div class='popupnoResultBG' >  
                    <div class='noResultContent'> 
                        <div  class="divNoRecord">{'NOTFOUNDANYRECORD'|@getFixedLabel}!</div>
                    </div>
               </div>
                </td>
            </tr>
        {/foreach}
		{else}
			<tr>
                <td colspan="14" align="center" bgcolor="#efefef">
                <div class='popupnoResultBG' >  
                    <div class='noResultContent'> 
                        <div  class="divNoRecord">{'NOTFOUNDANYRECORD'|@getFixedLabel}!</div>
                    </div>
               </div>
                </td>
            </tr>
		{/if}
        </tbody>
        </table>
            {if $DSNCOCOTSTP5TQR eq 'DSNCOCOTSTP5TQR' && $MODULE neq 'PurchaseOrder'}
                <span style="color:red;position:absolute;padding:15px 0px 15px 20px;">{'DSNCOCOTSTP5TQR'|@getFixedLabel}</span>
            {/if}
            {if $DSNCOCOTSTP5TQR eq 'DSNCOCOTSTP5TQR' }
                {if $MODULE eq 'PurchaseOrder'}
                    <span style="color:red;position:absolute;padding:15px 0px 15px 20px;">{'DSNCOVOTSTP5TQR'|@getFixedLabel}</span>
                {/if}
            {/if}
        </td>
	</tr>
</table>
</form>
<div id="basicsearchcolumns" style="display:none;"><select name="search_field" id="bas_searchfield" style="width:150px">{html_options  options=$SEARCHLISTHEADER}</select></div>