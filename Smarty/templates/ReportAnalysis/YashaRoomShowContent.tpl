<div class="ld-flex-start shaya-more-shadow marT10 marB10 marL10 marR10" style="flex-wrap: wrap;">
    {foreach item=rateinfo  from=$ratelist}
    <div class="yasha-legend padL10 padR10" style="width:140px;">
        <div class="ld-flex-start">
            <div style="height: 18px;width:18px;border:1px solid #ccc;background-color:{$rateinfo['pick_color']}"></div>
            <div class="font14 padL5 padR5">{$rateinfo['listvalue']}</div>
        </div>
        <div class="font14">
            {$rateinfo['nums']}套{$rateinfo['rate']}%
        </div>
    </div>
    {/foreach}
</div>

<div id="yasha_table_content" style="overflow: auto;">
    {if $buildingnum=='别墅'||$buildingnum=='院墅'}
        <div class="ld-flex-start" style="flex-wrap: wrap;">
            {foreach item=roominfo key=k from=$roomlist}
                    <div style="background-color: {if empty($roominfo['pick_color'])}#fff{else}{$roominfo['pick_color']}{/if};width:140px;height:50px;padding:0 10px;border:1px solid #ccc;">
                        <div class="ld-flex-between" style="position: relative;align-items: center;justify-content: center;">
                            <div class="padL5 padR5" style="line-height: 50px;">{$roominfo['productname']}</div>
                            {if !empty($roominfo)&&$terminal=='pc'}
                                <div tag="show_droplist" data-pid="{$roominfo['productid']}" data-status="close" class="ld_icon_arrowdown" style="margin: 0 0 16px 0 ;">

                                </div>
                            {/if}
                        </div>
                    </div>
            {/foreach}
        </div>
    {else}
        <table class="listEntries" style="width: 100%;table-layout: auto;">
            <thead>
            <tr>
                <th class="font14" style="text-align: center;" colspan="{$numberallcols}">{$loupan}-{$buildingNum}</th>
            </tr>
            <tr class="fixed-width">
                <th class="font14" style="width:50px;" rowspan="2">楼层</th>
                <th class="font14" style="width:50px;">单元</th>
                {foreach item=danyuaninfo key=i from=$danyuan_list}
                    <th class="font14" colspan="{$danyuaninfo['cols']}">{$danyuaninfo['danyuanname']}</th>
                {/foreach}
            </tr>
            <tr class="fixed-width">
                <th class="font14">房号</th>
                {foreach item=headerinfo key=j from=$header_list}
                    <th class="font14">{$headerinfo['number']}</th>
                {/foreach}
            </tr>
            </thead>
            <tbody>
            {foreach item=roominfo key=k from=$roomlist}
                <tr class="fixed-width">
                    <th class="font14" colspan="2">{$roominfo['floor']}</th>
                    {foreach item=headerinfo1 key=jj from=$header_list}
                        <td style="background-color: {if empty($roominfo[$headerinfo1['colorkey']])}#fff{else}{$roominfo[$headerinfo1['colorkey']]}{/if};overflow: auto;">
                            <div class="ld-flex-between" style="position: relative;justify-content: center;">
                                <div class="padL5 padR5 font14">{$roominfo[$headerinfo1['namekey']]}</div>
                                {if !empty($roominfo[$headerinfo1['colorkey']])&&$terminal=='pc'}
                                    <div tag="show_droplist" data-pid="{$roominfo[$headerinfo1['pidkey']]}" data-status="close" class="ld_icon_arrowdown" style="margin:0;">

                                    </div>
                                {/if}
                            </div>
                        </td>
                    {/foreach}
                </tr>
            {/foreach}
            </tbody>
        </table>
    {/if}
</div>
{*查看明细，新建来访登记、新建客户、新建认购协议、新建销售合同、新建入伙管理*}
<ol id="yasha_droplist" class="yasha-more-shadow yasha-droplist" style="height: 185px;">
    <li class="shaya-more-li" tag="detail" href="javascript:;">
        <a class="shaya-btn-more" style="padding:0 5px;margin:0;text-align: center;">查看明细</a>
    </li>
{*    <li class="shaya-more-li" tag="Leads"  href="javascript:;">*}
{*        <a class="shaya-btn-more" style="padding:0 5px;margin:0;text-align: center;">新建来访登记</a>*}
{*    </li>*}
{*    <li class="shaya-more-li" tag="Accounts" href="javascript:;">*}
{*        <a class="shaya-btn-more" style="padding:0 5px;margin:0;text-align: center;">新建客户</a>*}
{*    </li>*}
    <li class="shaya-more-li" tag="CustomForm44" href="javascript:;">
        <a class="shaya-btn-more" style="padding:0 5px;margin:0;text-align: center;">新建认购协议</a>
    </li>
    <li class="shaya-more-li" tag="SalesOrder" href="javascript:;">
        <a class="shaya-btn-more" style="padding:0 5px;margin:0;text-align: center;">新建销售合同</a>
    </li>
    <li class="shaya-more-li" tag="CustomForm166" href="javascript:;">
        <a class="shaya-btn-more" style="padding:0 5px;margin:0;text-align: center;">新建入伙管理</a>
    </li>
</ol>