{*ls 2022-03-10 【1002521】页面设置，增加【自定义字段操作日志】标签*}
{*zkt 20220412 50927（https://81mis.com/kfbcrm/index.php）系统设置》页面设置》客户，字段列表；字段过多时，字段序号需要显示三位数字，列表处显示不全*}
<div name="loghtmltableheader">
<table border="0" cellspacing="0" cellpadding="0" width="100%" class="settingTable fir-center" style="table-layout: fixed;width=1431px;">
    <tr style="position: sticky; top:0px;z-index:1;">
        <th style="width=65">#</th>
        <th style="width=227" align="left" title="{'LBL_FIELDNAME'|@getFixedLabel}">{'LBL_FIELDNAME'|@getFixedLabel}</th>
        <th style="width=227" align="left" title="{'fieldtype'|@getFixedLabel}">{'fieldtype'|@getFixedLabel}</th>
        <th style="width=227" align="left" title="{'Createtime1'|@getFixedLabel}">{'Createtime1'|@getFixedLabel}</th>
        <th style="width=227" align="left" title="{'CFCREATEOPERATOR'|@getFixedLabel}">{'CFCREATEOPERATOR'|@getFixedLabel}</th>
        <th style="width=227" align="left" title="{'CFDELTETIME'|@getFixedLabel}">{'CFDELTETIME'|@getFixedLabel}</th>
        <th style="width=231" align="left" title="{'CFDELTEOPERATOR'|@getFixedLabel}">{'CFDELTEOPERATOR'|@getFixedLabel}</th>
    </tr>
</table>
</div>
<div name="loghtmltable" style="height: 640px; overflow: hidden auto;">
<table border=0 cellspacing=0 cellpadding=0 width=100% class="settingTable fir-center" style="table-layout: fixed; width=1431px;">
    {assign var="i" value=0}
    {foreach item=entries key=id from=$CFENTRIES name=outer}
        {assign var="j" value=$i++}
        {if $j mod 2 eq '0'}
            <tr id="setting_{$j}" record="{$entries.fieldid}" module="{$MODULE}" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
        {else}
            <tr id="setting_{$j}" record="{$entries.fieldid}" module="{$MODULE}" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
        {/if}
            <td style="width=65">{$id+1}</td>
            <td style="width=227"><span title="{$entries.fieldlabel}">{$entries.fieldlabel}</span></td>
            <td style="width=227"><span title="{$entries.type}">{$entries.type}</span></td>
            <td style="width=227"><span title="{$entries.createdtime}">{$entries.createdtime}</span></td>
            <td style="width=227"><span title="{$entries.create_operator}">{$entries.create_operator}</span></td>
            <td style="width=227"><span title="{$entries.deletedtime}">{$entries.deletedtime}</span></td>
            <td style="width=231"><span title="{$entries.delete_operator}">{$entries.delete_operator}</span></td>
            <input type="hidden" name="fieldid_{$entries.fieldid}" value="{$entries.fieldid}" uitype="{$entries.uitype}">
        </tr>
    {/foreach}
</table>
</div>