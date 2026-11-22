{*editor:gyq_101 reason:产品单据明细界面,查看产品所在仓库数量分布情况  2019/1/28 17:15*}
<div  class="qtyinstock">
    <table class="listEntries" cellpadding="0" cellspacing="1" border="0">
        {if $TYPE eq 'detail'}
            <tr>
                <th class="ctextalign" style="width:65px;">#</th>
                {foreach item=content key=fieldname from=$TITLE}
                    {if $fieldname eq 'product_no'||$fieldname eq 'inventory'||$fieldname eq 'productsheet' }
                        <th>{$content}</th>
                    {elseif $fieldname eq 'productname'}
                        <th>{$content}</th>
                    {else}
                        <th>{$content}</th>
                    {/if}
                {/foreach}
            </tr>
            {foreach item=content from=$LIST}
                <tr class="lvtColData" >
                    <td class="ctextalign" style="width:25px;">{$content.i}</td>
                    <td>{$content.warehouse}</td>
                    <td>{$content.batchtext}</td>
                    <td align="right">{$content.inventory_qty}</td>
                </tr>
            {foreachelse}
                <tr align="center" style="">
                    <td colspan="4" bgcolor="#ffffff" style="height:0px;padding: 10px 0px 0px 0px;">
                        {* <div class="warningTableContent" style="z-index:600;">
                            <div class="wtc_img">
                                <img src="themes/icon2023/ld-no-records.png">
                            </div>
                            <div class="wtc_content">
                                {'NOTFOUNDANYRECORD'|@getFixedLabel}
                            </div>
                            <div class="wtc_btn"></div>
                            <div></div>
                        </div> *}
                        {include file="NoRecords.tpl" NoRecords_STYLE = 'position: relative;top:0;left:0;'}
                    </td>
                </tr>
            {/foreach}
        {else}
            <tr>
                <th class="ctextalign" style="width:25px;">#</th>
                {foreach item=content key=fieldname from=$TITLE}
                    {if $fieldname eq 'product_no'||$fieldname eq 'inventory'||$fieldname eq 'productsheet' }
                        <th>{$content}</th>
                    {elseif $fieldname eq 'productname'}
                        <th>{$content}</th>
                    {else}
                        <th>{$content}</th>
                    {/if}
                {/foreach}
            </tr>
            {foreach item=content from=$LIST}
                <tr class="lvtColData" >
                    <td class="ctextalign" style="width:25px;">{$content.i}</td>
                    <td>{$content.product_no}</td>
                    <td>{$content.productname}</td>
                    <td>{$content.productsheet}</td>
                    <td>{$content.usageunit}</td>
                    <td>{$content.warehouse}</td>
                    <td>{$content.batchtext}</td>
                    <td align="right">{$content.inventory_qty}</td>
                </tr>
            {/foreach}
        {/if}
    </table>
</div>