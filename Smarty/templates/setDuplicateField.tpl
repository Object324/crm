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
<link rel="stylesheet" type="text/css" href="{$CSSURL}themes/softed/selfstyle.css">
<div class="D_pop_tit">
	<strong class="D_ptita">{'SETFIELD'|@getTranstab}</strong>
    <a href="javascript:fninvshnew('div_setDuplicates');look_check_repeat();" class="D_ptitc">
        <img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"/>
    </a>
</div>
<div class="clear"></div>
<div class="D_pop_content" style="border:none;">
<form name="selectall" method="POST">
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
    <input type="hidden" name="type" id="type" value="{$TYPE}">
    


	<div style="max-height:260px;overflow-y: scroll;">
        <div class="fixedheaderDiv" style="padding-right:0px;">
            <table class="listEntries fir-center" border="0" cellpadding="0" cellspacing="1" width="100%">
        		<tr>
                    <th>#</th>
                    <th>{'FIELDNAME'|@getFixedLabel}</th>
        		    <th style="text-align:center;" width="20%">
                        <input type="checkbox" name="select_all" value="" onClick=toggleSelect(this.checked,"dup_selected_id")>
                    </th>
        		</tr>
            </table>
        </div>
    	<table class="listEntries fir-center" border="0" cellpadding="0" cellspacing="1" width="100%">
            <tbody>
    	{foreach key=entity_id item=entity name=listentitys from=$SETDUPFIELDLIST}
            {if $smarty.foreach.listentitys.iteration mod 2 eq '1'}
            <tr bgcolor="white" class="Hover">
            {else}
            <tr bgcolor="white" class="lvtColDataBj Hover" >
            {/if}
            <td>{$smarty.foreach.listentitys.iteration}</td>
            <td>{$entity.fieldlabel}</td>
            <td align="center" width="20%" onclick="toggleSelectAll_parent_td(this)">
            {if ($MODULE eq 'Accounts'&&($entity.columnname eq 'accountname'))||
            ($MODULE eq 'Contacts'&&($entity.columnname eq 'lastname'))||
            ($MODULE eq 'Potentials'&&($entity.columnname eq 'potentialname'))||
            ($MODULE eq 'VendorContact'&&($entity.columnname eq 'lastname'))||
            ($MODULE eq 'PurchaseOrder'&&($entity.columnname eq 'subject'))||
            ($MODULE eq 'Vendors'&&($entity.columnname eq 'vendorname'))||
            ($MODULE eq 'Project'&&($entity.columnname eq 'projectname'))||
            ($MODULE eq 'ServiceContracts'&&($entity.columnname eq 'subject'))
            }
                <input type="checkbox" name="dup_selected_id" disabled checked value="{$entity_id}" onclick="toggleSelectAll(this.name,'select_all')"/>
            {else}
                <input type="checkbox" name="dup_selected_id" {if  $entity.duplicatefield eq '0'}checked{/if} value="{$entity_id}" onclick="toggleSelectAll(this.name,'select_all')"/>
            {/if}
            </td>
            </tr>
	{foreachelse}
            <tr align="center">
                <td colspan="{$HEADERCOUNT}" bgcolor="#fff">
                    <div class='popupnoResultBG' >   		 
                        <div class='noResultContent'> 
                            <div  class="divNoRecord">{'NOTFOUNDANYRECORD'|@getFixedLabel}!</div>
                        </div>      
                    </div>
                </td>
            </tr>
        {/foreach}
      	</tbody>
    	</table>
	</div>
</form>
</div>
<div class="D_pbtn">
<input class="D_pbtnok" type="button"  onclick="checkDupFieldlists('Accounts','Accounts');" value="{'CONFIRMED'|@getFixedLabel}">
<span> </span>
<input class="D_pbtncancel" type="button" onclick="fninvshnew('div_setDuplicates');look_check_repeat();" value="{'CANCEL'|@getFixedLabel}">
</div>
