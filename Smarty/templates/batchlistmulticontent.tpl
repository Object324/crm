<div style="margin-bottom: 10px;display: flex;align-items: center">
    <input type="button" class="ld-button ld-button-primary" style="margin-right: 10px"
           value="{'CONFIRMED'|@getFixedLabel}" name="btnok"/>
    <input type="checkbox" name="select_batch_qty" value="" style="margin-right: 5px"
           {if $SELECT_BATCH_QTY eq 'yes'}checked{/if} onclick="fun_selectproduct.batchqty_settings(this)">
    <label style="margin-top: -1px">{'selectabatch'|@getFixedLabel}</label>
</div>


<div id="hdScrolllistentries_yy" name="hdScrolllistentries_yy" style="position: relative;">
    <div id="resize_header_table_divid" name="resize_header_table_divid" style="visibility: visible; top: 194px; overflow: hidden;">
        <div style="float:left; padding-right:20px">
            <table id="resize_header_tableid" name="resize_header_tableid" class="listEntries" border="0" cellspacing="1" cellpadding="0" >
                <tbody>
                <tr>
                    <th align="center" style="text-align: center; width: {$listHeaderWidth['checkbox']}px; cursor: col-resize;" headermodule="Products" headername="checkbox"  tag="0"><input type="checkbox" name="chkall"/></th>
                    <th align="center" style="width: {$listHeaderWidth['productname']}px" headermodule="Products" headername="productname" tag="1">{$Headdtitle.productnamelabel}</th>
                    {if $Headdtitle.productsheetlabel neq ''}
                        <th  style="width: {$listHeaderWidth['productsheet']}px" headermodule="Products" headername="productsheet" tag="2">{$Headdtitle.productsheetlabel}</th>
                    {/if}
                    <th  style="width: {$listHeaderWidth['wareid']}px" headermodule="Stock" headername="wareid" tag="3">{$Headdtitle.warehoursename}</th>
                    <th style="width: {$listHeaderWidth['batchtext']}px" headermodule="Stock" headername="batchtext" tag="4">{$Headdtitle.batch}</th>
                    <th style="width: {$listHeaderWidth['quantity']}px" headermodule="Stock" headername="quantity" tag="5"> {$Headdtitle.quantity}</th>
                    {if $Headdtitle.productdate neq ''}
                        <th  style="width: {$listHeaderWidth['productdate']}px" headermodule="Products" headername="productdate" tag="6">{$Headdtitle.productdate}</th>
                    {/if}
                    {if $Headdtitle.protectqualitydate neq ''}
                        <th  style="width: {$listHeaderWidth['protectqualitydate']}px" headermodule="Products" headername="protectqualitydate" tag="7">{$Headdtitle.protectqualitydate}</th>
                    {/if}
                    <th  style="width: {$listHeaderWidth['expiry_date']}px" headermodule="Products" headername="expiry_date" tag="8">{$Headdtitle.expiry_date}</th>
                </tr>
                </tbody>
            </table>
        </div>
    </div>
    <div id="resize_content_table_divid" name="resize_content_table_divid" style="overflow: auto;" >
        <table border="0" cellspacing="1" cellpadding="0" id="resize_content_tableid" name="resize_content_tableid"  class="listEntries marT-53">
            <tbody>
            <tr>
                <th align="center" style="text-align: center; width: {$listHeaderWidth['checkbox']}px; cursor: col-resize;" headermodule="Products" headername="checkbox"  tag="0"><input type="checkbox" name="chkall"/></th>
                <th align="center" style="width: {$listHeaderWidth['productname']}px" headermodule="Products" headername="productname" tag="1">{$Headdtitle.productnamelabel}</th>
                {if $Headdtitle.productsheetlabel neq ''}
                    <th  style="width: {$listHeaderWidth['productsheet']}px" headermodule="Products" headername="productsheet" tag="2">{$Headdtitle.productsheetlabel}</th>
                {/if}
                <th  style="width: {$listHeaderWidth['wareid']}px" headermodule="Stock" headername="wareid" tag="3">{$Headdtitle.warehoursename}</th>
                <th style="width: {$listHeaderWidth['batchtext']}px" headermodule="Stock" headername="batchtext" tag="4">{$Headdtitle.batch}</th>
                <th style="width: {$listHeaderWidth['quantity']}px" headermodule="Stock" headername="quantity" tag="5"> {$Headdtitle.quantity}</th>
                {if $Headdtitle.productdate neq ''}
                    <th  style="width: {$listHeaderWidth['productdate']}px" headermodule="Products" headername="productdate" tag="6">{$Headdtitle.productdate}</th>
                {/if}
                {if $Headdtitle.protectqualitydate neq ''}
                    <th  style="width: {$listHeaderWidth['protectqualitydate']}px" headermodule="Products" headername="protectqualitydate" tag="7">{$Headdtitle.protectqualitydate}</th>
                {/if}
                <th  style="width: {$listHeaderWidth['expiry_date']}px" headermodule="Products" headername="expiry_date" tag="8">{$Headdtitle.expiry_date}</th>
            </tr>
            {foreach from=$TMPARR.content item=content key=ky}
                <tr rowindex='{$ky}'>
                    <td align="center"  >
                        <input type="checkbox" name="chkrow" rowindex='{$ky}'/>
                        <input type="hidden" value="{$content.quantity}" name="row_quantity"/>
                        <input type="hidden" value="{$content.batch}" name="row_batchtext"/>
                        <input type="hidden" value="{$content.wareid}" name="row_wareid"/>
                        <input type="hidden" value="{$content.warehoursename}" name="row_warehousename"/>
                    </td>
                    <td>{$content.productname}</td>
                    {if $Headdtitle.productsheetlabel neq ''}
                        <td>{$content.productsheet}</td>
                    {/if}
                    <td>{$content.warehoursename}</td>
                    <td>
                        {if $content.batch neq "0"&&$content.batch eq ''}
                            <a href="javascript:void" onclick="fun_selectproduct.setbatchtextmulti('',{$content.quantity},'{$ky}')">--</a>
                        {else}
                            <a href="javascript:void" title="{$content.batch}" onclick="fun_selectproduct.setbatchtextmulti('{$content.batch}',{$content.quantity},'{$ky}')">{$content.batch}</a>
                        {/if}
                    </td>
                    <td>{$content.quantity}<input  type="hidden" name="quantity{$ky}"/> </td>
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
