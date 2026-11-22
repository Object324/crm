<div  class="pop_up_content step2_content" autofocus="autofocus">
    	<div class="pop_up_content_inner">
    	<!-- 流程进度条 start -->
    	{include file="ImportXlsNew/ImportStepTip.tpl"} 
    
    	<!-- 流程进度条 end -->
        	<div class="pop_item pop-item-plus">
            	<table border="0" cellspacing="1" id="Importtable" cellpadding="0" class="listEntries fir-center" style="width: 98%;margin: 5px auto;">
                	<tr>
                    	<th width="15%" style="padding-right:15%">{'EXCELHEADER'|@getFixedLabel}</th>
                        <th width="25%" style="padding-right:15%">{'Row'|@getFixedLabel}</th>
                        <th width="40%" style='padding-right:16%'>CRM&nbsp;{'LBL_Field'|@getFixedLabel}</th>
                        <th width="20%" style="padding-right:20%">{'Default'|@getFixedLabel}</th>
                	</tr>
                    
                   {foreach item=value key=ky from=$IMPORTDATA name=import}
                 	  {if $smarty.foreach.import.index %2 ==0}
                        <tr class="fieldIdentifier lvtColData">
                        {else}
                        <tr class="fieldIdentifier lvtColDataBj">
                        {/if}
                        {assign var='V3' value=$value.3 }
                        	<td class="tip-items-list" data-tip="{$value.0}" data-direction="bottom" data-type="position">
                                <span {if $value.5 eq 'yes'}class="redFont"{/if}>
                                    {$value.0}
                                </span>
                                <input type="hidden" name="isfieldname_{$ky}" value="{$value.0}"  /> </td>
                        	<td>{$value.1}</td>
                        	<td>
                                {assign var='fldname' value=$ky}
                                {include file="ImportXlsNew/importfielddrop.tpl"}
                            </td>
                        	<td title="">
                                <span id="{$V3}-defaultvalue-container" name="{$V3}-defaultvalue">
                                    {if $value.2 eq 15}
                                        <select id="{$V3}-defaultvalue" name="{$V3}-defaultvalue">
                                            {foreach item=drp key=drpky from=$DROPHTML.$V3}     
                                                    <option value="{$drpky}">{$drpky}</option>
                                            {/foreach}
                                        </select>
                                    {elseif $value.2 eq 56}
                                        <input  type="checkbox" id="{$V3}-defaultvalue" name="{$V3}-defaultvalue"/>
                                    {elseif $value.2 eq 5}
                                        <input type="text"  id="{$V3}-defaultvalue" name="{$V3}-defaultvalue" class="Wdate" value="" onClick="WdatePicker()" size="15" />
                                        <!--<img  class='popimg' src='themes/softed/images/btnL3Calendar.gif'  onclick='showCalendar("{$V3}-defaultvalue","%Y-%m-%d","true","12",this)'/>-->
                                    {elseif $value.2 neq 0}
                                        <input  type="text" id="{$V3}-defaultvalue" name="{$V3}-defaultvalue"/>
                                    {/if}
                                 </span>
                            </td>
                    	</tr>
                    {/foreach}
                    
            	</table>	 
        	</div>
    	</div>				 
 </div>
 