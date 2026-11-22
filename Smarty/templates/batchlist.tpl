<div class="searchbatchtext">
    {if $FROMMODULE neq 'Stock'}
        <div style="margin-bottom: 10px;">
            <input type="checkbox" name="select_batch_qty" value="" {if $SELECT_BATCH_QTY eq 'yes'}checked{/if} onclick="fun_selectproduct.batchqty_settings(this)">&nbsp;
            <label>{'selectabatch'|@getFixedLabel}<label>
        </div>
    {/if}

    <div id="hdScrolllistentries_yy" name="hdScrolllistentries_yy" style="position: relative;">
        <div id="resize_header_table_divid" name="resize_header_table_divid" style="visibility: visible; top: 194px; overflow: hidden;">
            <div style="float:left; padding-right:20px">
                <table id="resize_header_tableid" name="resize_header_tableid" class="listEntries" border="0" cellspacing="1" cellpadding="0" >
                    <tbody>
                    <tr>
                        <th style="width: {$listHeaderWidth['batchtext']}px" headermodule="Stock" headername="batchtext" tag="1">{$Headdtitle.batch}</th>
                        <th  style="width: {$listHeaderWidth['wareid']}px" headermodule="Stock" headername="wareid" tag="2">{$Headdtitle.warehoursename}</th>
                        <th style="width: {$listHeaderWidth['quantity']}px" headermodule="Stock" headername="quantity" tag="3"> {$Headdtitle.quantity}</th>
                        {if $Headdtitle.productdate neq ''}
                            <th  style="width: {$listHeaderWidth['productdate']}px" headermodule="Products" headername="productdate" tag="4">{$Headdtitle.productdate}</th>
                        {/if}
                        {if $Headdtitle.protectqualitydate neq ''}
                            <th  style="width: {$listHeaderWidth['protectqualitydate']}px" headermodule="Products" headername="protectqualitydate" tag="5">{$Headdtitle.protectqualitydate}</th>
                        {/if}
                        <th  style="width: {$listHeaderWidth['expiry_date']}px" headermodule="Products" headername="expiry_date" tag="6">{$Headdtitle.expiry_date}</th>
                    </tr>
                    </tbody>
                </table>
            </div>
        </div>
        <div id="resize_content_table_divid" name="resize_content_table_divid" style="overflow: auto;" >
            <table border="0" cellspacing="1" cellpadding="0" id="resize_content_tableid" name="resize_content_tableid"  class="listEntries marT-53">
                <tbody>
                <tr>
                    <th style="width: {$listHeaderWidth['batchtext']}px" headermodule="Stock" headername="batchtext" tag="1">{$Headdtitle.batch}</th>
                    <th  style="width: {$listHeaderWidth['wareid']}px" headermodule="Stock" headername="wareid" tag="2">{$Headdtitle.warehoursename}</th>
                    <th style="width: {$listHeaderWidth['quantity']}px" headermodule="Stock" headername="quantity" tag="3"> {$Headdtitle.quantity}</th>
                    {if $Headdtitle.productdate neq ''}
                        <th  style="width: {$listHeaderWidth['productdate']}px" headermodule="Products" headername="productdate" tag="4">{$Headdtitle.productdate}</th>
                    {/if}
                    {if $Headdtitle.protectqualitydate neq ''}
                        <th  style="width: {$listHeaderWidth['protectqualitydate']}px" headermodule="Products" headername="protectqualitydate" tag="5">{$Headdtitle.protectqualitydate}</th>
                    {/if}
                    <th  style="width: {$listHeaderWidth['expiry_date']}px" headermodule="Products" headername="expiry_date" tag="6">{$Headdtitle.expiry_date}</th>
                </tr>
                {foreach from=$TMPARR.content item=content key=ky}
                    <tr>
                        <td>{if $content.batch eq ''}
                                <a href="javascript:void"
                                   onclick="fun_selectproduct.setbatchtext('',{$content.quantity})">--</a>
                            {else}
                                <a href="javascript:void"
                                   onclick="fun_selectproduct.setbatchtext('{$content.batch}',{$content.quantity})">{$content.batch}</a>
                            {/if}
                        </td>
                        <td>{$content.warehoursename} </td>
                        <td>{$content.quantity}<input type="hidden" name="quantity{$ky}"/></td>
                        {if $TMPARR.title.0.productdate neq ''}
                            <td>{$content.productdate} </td>
                        {/if}
                        {if $TMPARR.title.0.protectqualitydate}
                            <td>{$content.protectqualitydate} </td>
                        {/if}
                        <td>{$content.expiry_date}</td>
                    </tr>
                {/foreach}
                <tr height="120px" valign="center" {if $TMPARR.content neq ''}style="display:none;"{/if}>
                    <td align="center" colspan="{$COLSPAN}">{'NOTFOUNDANYRECORD'|@getFixedLabel}</td>
                </tr>
                </tbody>
            </table>
        </div>
    </div>
</div>