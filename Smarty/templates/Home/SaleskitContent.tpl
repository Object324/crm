{*简报每一小块的内容*}
{*变量 saleskitinfo一条简报信息相信 COLCOUNT--每行多少个简报 stuffid组件id $ShowPercent是否显示百分比 *}
<div class="ld-stuff-item-info" >
    <div class="ld-stuff-item-header">
        <div class="ld-stuff-item-header-icon {$saleskitinfo.css}">
        </div>
        <div class="ld-stuff-item-header-title">
            {$saleskitinfo.label}
        </div>
    </div>
    <div class="ld-stuff-item-content">
        <div class="ld-stuff-item-content-t">
            <div class="ld-stuff-item-c-t-c">
                <span searchtype='now' stufflabel='{$saleskitinfo.stufflabel}' onclick="homestuffObj.setSalesKitChuantou('{$saleskitinfo.stufflabel}',{$stuffid},ld(this))" class="sort-tip-items" data-tip="{$saleskitinfo.value}" data-direction="top" data-type="position">{$saleskitinfo.formatValueInt}{if $saleskitinfo.formatValueDecimal neq '' }<span style="font-size: 20px;    line-height: 14px;">.{$saleskitinfo.formatValueDecimal}</span>{/if}</span>
            </div>
        </div>
        <div class="ld-stuff-item-content-b" {if $saleskit_isshowpredata neq 'yes' || $saleskitinfo.search_date eq 'all'|| $saleskitinfo.beforelabel eq '' }style="display:none;"{/if}>
            <div class="ld-stuff-item-content-b-l" searchtype='last' stufflabel='{$saleskitinfo.stufflabel}' onclick="homestuffObj.setSalesKitChuantou('{$saleskitinfo.stufflabel}',
            {$stuffid},ld(this))">
                {'PREVIOUSDATA'|@getFixedLabel}<span class="padL8 sort-tip-items" data-tip="{$saleskitinfo.beforevalue}" data-direction="top" data-type="position">{$saleskitinfo.beforevalue}</span>
            </div>
            <b name="ld-saleskit-updown-icon" {if $ShowPercent eq 'no' || $saleskitinfo.search_date eq 'all' }style="display:none;"{/if} class="{if $saleskitinfo.percentstatus eq 'red' }ld-stuff-item-c-percent-up-second{elseif $saleskitinfo.percentstatus eq 'green'}ld-stuff-item-c-percent-down-second{elseif $saleskitinfo.percentstatus eq 'equation1'}ld-stuff-item-c-percent-eq{/if}"></b>
            {if $saleskitinfo.percentstatus eq 'red' || $saleskitinfo.percentstatus eq 'green'}
                <div class="ld-stuff-item-content-b-r"  {if $ShowPercent eq 'no' || $saleskitinfo.search_date eq 'all' }style="display:none;"{/if}>
                    <b class="ld-stuff-item-c-percent">{$saleskitinfo.percent}</b>
                </div>
            {/if}
        </div>
    </div>
</div>
