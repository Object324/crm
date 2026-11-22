
<table border="0" cellspacing="1" id="Importtable" cellpadding="0" class="settingPopTable lasttdbordernon" style="width: 98%;margin: 5px auto;">
	<tr>
    	<th width="35%" style="padding-right:15%">{'RELFECTLBL_FIELDNAME'|@getFixedLabel}</th>
        <th width="45%" style="padding-right:15%">{'AFTERRELFECTLBL_FIELDNAME'|@getFixedLabel}</th>
	</tr>
    
   {foreach item=value key=ky from=$BACKFILLFIELD name=import}
        {assign var='tianyanchaname' value=$value.tianyanchaname}
        {assign var='trancolumnname' value=$value.trancolumnname}
        {if $smarty.foreach.import.index %2 ==0}
        <tr class="fieldIdentifier lvtColData">
        {else}
        <tr class="fieldIdentifier lvtColDataBj">
        {/if}
        	<td>{$value.label}<input type="hidden" name="isfieldname_{$ky}" tag="{$value.label}" value="{$value.tianyanchaname}" /> </td>
        	<td>
                {assign var='fldname' value=$ky}
                {assign var='optText' value=''}
                <select name="{$fldname}" id="{$tianyanchaname}"   style="display:none" >
                
				{foreach item=drp from=$SELECTOPTION}
                        {if $trancolumnname eq $drp.columnname}
                                {assign var='optText' value=$drp.fieldlabel}
                                <option value="{$drp.value}" selected="true">{$drp.fieldlabel} </option>
                        {else}
                                <option value="{$drp.value}" >{$drp.fieldlabel} </option>
                        {/if}
				{/foreach}
                
			   </select>
            </td>
        	
    	</tr>
    {/foreach}
    
</table>