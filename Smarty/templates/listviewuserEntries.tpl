
&#&#&#{$ERROR}&#&#&#

{assign var=operating value='OPERATING'|@getFixedLabel}
        <div id="hdScrolllistentries_yy" name="hdScrolllistentries_yy" style="position: relative;">
            <div style=" visibility: visible; top: 194px;overflow:hidden" id="resize_header_table_divid">
                <div  style="float:left; padding-right:20px">                    
                    {if $LIST_NOCHECKBOX neq 'no'}
                    <table class="listEntries fir-center" name="resize_header_tableid" id="resize_header_tableid"  border="0" cellspacing="1" cellpadding="0" style="width:{$TOTALWIDTH}px">
                    {else}
                    <table class="listEntries fir-center" name="resize_header_tableid" id="resize_header_tableid"  border="0" cellspacing="1" cellpadding="0" style="width:{$TOTALWIDTH}px">
                    {/if}
                        <tr>
                            {if $LIST_NOCHECKBOX neq 'no'}
                                <th style="text-align:center;width:{$CHKBOXWIDTH}px" tag="0" headermodule="{$MODULE}" headername='chkbox'>
                                    <input type="checkbox"  name="selectall" id="selectCurrentPageRec" onClick=toggleSelect_ListView(this.checked,"selected_id")>
                                </th>
                            {/if}                            
                            {foreach name="listviewforeach" item=header key=i from=$LISTHEADER}
                                {if $header neq $operating || $LIST_NOOPERATING eq 'no'}
                                    <th style="width:{$LISTHEADERWIDTH[$i]}px" tag="{$i+1}" headermodule="{$HEADERNAME.module[$i]}" headername="{$HEADERNAME.fieldname[$i]}" >{$header}</th>
                                {else}
                                    <th width="{$OPERATIONWIDTH}" tag="{$i+1}">{$header}</th>
                                {/if}     
                            {/foreach}
                        </tr>                        
                    </table>
                </div>
            </div>
            <div style="overflow:auto;height:300px;" id="resize_content_table_divid">
                {if $LIST_NOCHECKBOX neq 'no'}
                <table class="listEntries fir-center marT-53" id="resize_content_tableid" name="resize_content_tableid" style="width:{$TOTALWIDTH}px" border="0" cellspacing="1" cellpadding="0" >
                {else}
                <table class="listEntries marT-53" id="resize_content_tableid" name="resize_content_tableid" style="width:{$TOTALWIDTH}px" border="0" cellspacing="1" cellpadding="0" >
                {/if}
                    <tr>
                        {if $LIST_NOCHECKBOX neq 'no'}
                            <th style="text-align:center;width:{$CHKBOXWIDTH}px" tag="0" headermodule="{$MODULE}" headername='chkbox'></th>
                        {/if}
                        {foreach name="listviewforeach" item=header key=i from=$LISTHEADER}
                            {if $header neq $operating || $LIST_NOOPERATING eq 'no'}
                                <th style="width:{$LISTHEADERWIDTH[$i]}px" tag="{$i+1}" headermodule='{$MODULE}' headername="{$HEADERNAME[$i]}">{$header}</th>
                            {else}
                                <th width="{$OPERATIONWIDTH}" tag="{$i+1}">{$header}</th>
                            {/if}     
                        {/foreach}
                    </tr>                            
                    <tbody>
                        <tr>
                            <td id="linkForSelectAll" class="linkForSelectAll" style="display:none;" colspan="{$LISTHEADERCOUNT}" onclick="toggleSelectAll_parent_td(this)">
                                <span id="selectAllRec" class="selectall" style="display:inline;" onClick="toggleSelectAll_Records('{$MODULE}',true,'selected_id')">{'SELECTALL'|@getFixedLabel} <span id="count"> {$NUMOFROWS}</span> {'RECORDNUMS'|@getFixedLabel}</span>
                                <span id="deSelectAllRec" class="selectall" style="display:none;" onClick="toggleSelectAll_Records('{$MODULE}',false,'selected_id')">{'DESELECTALL'|@getFixedLabel}</span>
                            </td>
                        </tr>
                        {$DEAILHTML}
                        {if $MODULE == 'InventoryQuery'}
                            {if $NUMOFROWS > 0}
                                <tr bgcolor="white" onmouseout="this.className='lvtColData'" onmouseover="this.className='lvtColDataHover'" id="row_{$entity_id}">
                                    {*<td colspan="" align="right">∑&nbsp;{'TOTALTHIS'|@getFixedLabel}</td>*}
                                    {foreach item=value key=entity_id from=$INVENTORYCOUNT}
                                        <td align="right">{$value}</td>
                                    {/foreach}
                                </tr>
                                <tr bgcolor="white" onmouseout="this.className='lvtColData'" onmouseover="this.className='lvtColDataHover'" id="row_{$entity_id}"  style="color:#0070BA">
                                    {*<td colspan="" align="right">∑&nbsp;{'TOTALALL'|@getFixedLabel}</td>*}
                                    {foreach item=value key=entity_id from=$INVENTORYSUM}
                                        <td align="right">{$value}</td>
                                    {/foreach}
                                </tr>
                            {/if}
                        {else}
                            {if $TOTALFLDHTML != ''}
                                {$TOTALFLDHTML}
                            {/if}
                        {/if}
                    </tbody>
                </table>
            </div>
        </div> 