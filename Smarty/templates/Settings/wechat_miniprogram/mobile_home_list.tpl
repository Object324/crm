{*editor:gyq_141 reason:移动端增加首页标签  2019/9/3 16:39 ID1000602*}
<div class="pad10 nopadding mar-1" >
    <table class="settingTable fir-center" id="approvelisttable" border=0 cellspacing=0 cellpadding=0 width="100%">
        {* BUG0068275 txy 2023.06.18 固定表头加滚动时表头加阴影*}
        <tr style="position: sticky; top:0px;z-index:1;">
            <th>#</th>
            <th title="{'ReportName'|@getFixedLabel}">{'ReportName'|@getFixedLabel}</th>
            <th title="{'WHETHERTOENABLE'|@getFixedLabel}">{'WHETHERTOENABLE'|@getFixedLabel}</th>
        </tr>
        {assign var="i" value=0}
        {foreach key=value item=content from=$LISTCONTENT}
            {assign var="j" value=$i++}
            {if $j mod 2 eq '0'}
                <tr id="setting_{$j}" mark="content_rows" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
                    {else}
                <tr id="setting_{$j}" imark="content_rows" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
            {/if}
            <td>{$value+1}</td>
            <td><span title="{$content.labelbol}">{$content.labelbol}</span></a>
            {if $content.name eq 'customreportblock'}
                <a style="margin-left:20px;" class="Anu3_a" href="javascript:void(0);" onclick="editCustomReportBlock(this,{$content.blockid})">{'EDIT'|@getFixedLabel}</a>
            {/if}
            </td>
            <td>
                {if $content.home_presence eq 'yes'}
                    <input type="checkbox" onclick="change_active(this,'{$content.name}')" class="second_switch" checked="" />
                {else}
                    <input type="checkbox" onclick="change_active(this,'{$content.name}')" class="second_switch" />
                {/if}
            </td>
            </tr>
        {/foreach}
    </table>
</div>