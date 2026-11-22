<p><span id="apimsg" ></span><span style="float: right;margin: 8px;font-size: 14px;">{$APIMSG}</span></p>
<div class="t-table" style="overflow:auto;width: 100%;">
    <table id="CL_Detial2" class="listEntries fir-center" cellspacing="1" cellpadding="0" border="0" width="1600px;">
        <tr style="position: sticky;top: 1px;">
            <th style="width:50px"><span title="序号">序号</span></th>
            <th style="width:100px"><span title="往来单位编码">往来单位编码</span></th>
            <th style="width:180px"><span title="往来单位名称">往来单位名称</span></th>
            <th style="width:120px"><span title="销售组织">销售组织</span></th>
            <th style="width:100px"><span title="业务描述">业务描述</span></th>
            <th style="width:100px"><span title="单据类型">单据类型</span></th>
            <th style="width:100px"><span title="单据编号">单据编号</span></th>
            <th style="width:80px"><span title="业务日期">业务日期</span></th>
            <th style="width:80px"><span title="备注">备注</span></th>
            <th style="width:80px"><span title="销售组">销售组</span></th>
            <th style="width:80px"><span title="销售员">销售员</span></th>
            <th style="width:130px"><span title="本期应收（原币）">本期应收（原币）</span></th>
            <th style="width:130px"><span title="本期收款（原币）">本期收款（原币）</span></th>
            <th style="width:130px"><span title="本期冲销额（原币）">本期冲销额（原币）</span></th>
            <th style="width:130px"><span title="期末余额（原币）">期末余额（原币）</span></th>
        </tr>
        {if $DATA|@count neq 0}
            {foreach key=is_key item=row from=$DATA name=fordata}
                <tr class="lvtColData">
                    <td>{$is_key + 1}</td>
                    <td title="{$row[0]}">{$row[0]}</td>
                    <td title="{$row[1]}">{$row[1]}</td>
                    <td title="{$row[2]}">{$row[2]}</td>
                    <td title="{$row[3]}">{$row[3]}</td>
                    <td title="{$row[4]}">{$row[4]}</td>
                    <td title="{$row[5]}">{$row[5]}</td>
                    <td title="{$row[6]}">{$row[6]}</td>
                    <td title="{$row[7]}">{$row[7]}</td>
                    <td title="{$row[8]}">{$row[8]}</td>
                    <td title="{$row[9]}">{$row[9]}</td>
                    <td title="{$row[10]}">{$row[10]}</td>
                    <td title="{$row[11]}">{$row[11]}</td>
                    <td title="{$row[12]}">{$row[12]}</td>
                    <td title="{$row[13]}">{$row[13]}</td>
                </tr>
            {/foreach}

        {else}
            <tr class="lvtColData">
                <td colspan="15">
                    <i style="display:inline-block;width:100%;text-align:center;">{'NONE'|@getFixedLabel}</i>
                </td>
            </tr>
        {/if}
    </table>
</div>

<script>
    {literal}
    var windowWidth = document.documentElement.clientWidth;
    ld('.t-table').css('height', parseInt(ld(window).height()-266)+'px');
    {/literal}
</script>