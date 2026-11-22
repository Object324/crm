{*<!--
/*********************************************************************************
** The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ********************************************************************************/
-->*}<!--修改编码格式:统一编码：UTF-8-->
<input type="hidden" name="blockidsetting" value="{$BLOCKIDSETTING}"/>
<input type="hidden" name="fieldidsetting" value="{$FIELDIDSETTING}"/>
<div class="pad10  nopadding mar-1" >
<div id="pickListDependencyList">					
	<table border=0 cellspacing=0 cellpadding=0 width=100% class="settingTable fir-center">
		<tr style="position:sticky;top:0px;z-index:1;">
          	<th>#</th>
            <th align="left" title="{'MODULE'|@getFixedLabel}">{'MODULE'|@getFixedLabel}</th>
            <th align="left" title="{'SOURCEFIELD'|@getFixedLabel}">{'SOURCEFIELD'|@getFixedLabel}</th>
            <th align="left" title="{'TARGETFIELD'|@getFixedLabel}">{'TARGETFIELD'|@getFixedLabel}</th>
            {if $LANGUAGETYPE eq 'en'}
            <th width="110">{'OPERATING'|@getFixedLabel}</th>
            {else}
            <th width="91">{'OPERATING'|@getFixedLabel}</th>
            {/if}
        </tr>
        {if $DEPENDENT_PICKLISTS|@count gte 1}
            {assign var="i" value=0}
    		{foreach name=dependencylist item=dependencyvalues from=$DEPENDENT_PICKLISTS}
    		{assign var="FIELD_MODULE" value=$dependencyvalues.module}
            {assign var="foreachNum" value=$smarty.foreach.dependencylist.iteration}
            {assign var="j" value=$i++}
    		{if $j mod 2 eq '0'}
                <tr id="setting_{$j}" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
            {else}
                <tr id="setting_{$j}" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
            {/if}
    			<td>{$foreachNum}</td>
    			<td><span title="{$FIELD_MODULE|@getTranstab}">{$FIELD_MODULE|@getTranstab}</span></td>
    			<td><span title="{$dependencyvalues.sourcefieldlabel}">{$dependencyvalues.sourcefieldlabel}</span></td>
    			<td><span title="{$dependencyvalues.targetfieldlabel}">{$dependencyvalues.targetfieldlabel}</span></td>
    			<td align="center">
    	  			<a class="Anu3_a" href="javascript:void(0);" onclick="DepencyEditFirst('{$FIELD_MODULE}','{$dependencyvalues.sourcefield}','{$dependencyvalues.targetfield}');">{'EDIT'|@getFixedLabel}</a>
    				<a class="Anu3_a redFont" href="javascript:void(0);" onclick="deleteDependencyPicklist('{$FIELD_MODULE}','{$dependencyvalues.sourcefield}','{$dependencyvalues.targetfield}','{'SUREWANTDELETE'|@getFixedLabel}');">{'DELETE'|@getFixedLabel}</a>
    			</td>
      		</tr>
    		{/foreach}
        {else}
            <tr class="lvtColData">
                <td colspan="5" align="center">{'NOTFOUNDANYRECORD'|@getFixedLabel}</td>
            </tr>
        {/if}
	</table>
</div>
</div>
<script>
/*
var popupobj=new Object();
popupobj.module='Settings';
CrmPopup.global_listPopupObj.push(popupobj);
*/


</script>