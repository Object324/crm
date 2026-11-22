{*ls 2022-03-10 【1002521】页面设置，增加【字段列表】标签*}
{*zkt 20220412 50927（https://81mis.com/kfbcrm/index.php）系统设置》页面设置》客户，字段列表；字段过多时，字段序号需要显示三位数字，列表处显示不全*}
{*zsk 20240319 BUG20240314-23   页面设置，“数据字典”和“自定义字段操作日志”列头没有固定*}
<div name="dictionnaryhtmltableheader">
<table border=0 cellspacing=0 cellpadding=0 width=100% class="settingTable fir-center" style="table-layout: fixed;width=1431px;" >
    <tr style="position: sticky; top:0px;z-index:1;">
        <th style="width=65">#</th>
        <th style="width=170" align="left" title="{'LBL_FIELDNAME'|@getFixedLabel}">{'LBL_FIELDNAME'|@getFixedLabel}</th>
        <th style="width=170" align="left" title="{'FieldLocation'|@getFixedLabel}">{'FieldLocation'|@getFixedLabel}</th>
        <th style="width=170" align="left" title="{'fieldtype'|@getFixedLabel}">{'fieldtype'|@getFixedLabel}</th>
        <th style="width=170" align="left" title="{'DatabaseFieldName'|@getFixedLabel}">{'DatabaseFieldName'|@getFixedLabel}</th>
        <th style="width=170" align="left" title="{'DatabasefieldID'|@getFixedLabel}">{'DatabasefieldID'|@getFixedLabel}</th>
        <th style="width=170" align="left" title="{'TableFieldLocated'|@getFixedLabel}">{'TableFieldLocated'|@getFixedLabel}</th>
        <th style="width=170" align="left" title="{'Createtime1'|@getFixedLabel}">{'Createtime1'|@getFixedLabel}</th>
        <th style="width=178" align="left" title="{'WHETHERTOENABLE'|@getFixedLabel}">{'WHETHERTOENABLE'|@getFixedLabel}</th>
        {*{if $LANGUAGETYPE eq 'en'}
            <th style="width=0">{'OPERATING'|@getFixedLabel}</th>
        {else}
            <th style="width=0">{'OPERATING'|@getFixedLabel}</th>
        {/if}*}
    </tr>
</table>
</div>
<div name="dictionnaryhtmltable" style="height: 640px; overflow: hidden auto;">
<table border=0 cellspacing=0 cellpadding=0 width=100% class="settingTable fir-center" style="table-layout: fixed; width=1431px;">
    {assign var="i" value=0}
    {foreach item=entries key=id from=$CFENTRIES name=outer}
        {assign var="j" value=$i++}
        {if $j mod 2 eq '0'}
            <tr id="setting_{$j}" {*record="{$entries.fieldid}"*} module="{$MODULE}" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
        {else}
            <tr id="setting_{$j}" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
        {/if}
            <td style="width=65">{$id+1}</td>
            <td style="width=170"><span title="{$entries.label}">{$entries.label}</span></td>
            <td style="width=170"><span title="{$entries.documenthead}">{$entries.documenthead}</span></td>
            <td style="width=170"><span title="20">{$entries.type}</span></td>
            <td style="width=170"><span title="{$entries.columnname}">{$entries.columnname}</span></td>
            <td style="width=170"><span title="{$entries.fieldid}">{$entries.fieldid}</span></td>
            <td style="width=170"><span title="{$entries.tablename}">{$entries.tablename}</span></td>
            <td style="width=170"><span title="{$entries.createdtime}">{$entries.createdtime}</span></td>
            <td style="width=178">
                {if $entries.fieldtable eq 'ld_producttoolfield'}
                    <input type="checkbox" onclick="change_tablefield_presence(ld(this),'{$entries.fieldid}','producttoolfield_presence')" class="second_switch"
                            {if $entries.presence eq '0'|| $entries.presence eq '2'}
                                checked
                            {/if}
                            {if $entries.allowhide eq 'no'}
                                disabled
                            {/if}
                    />
                {/if}

                {if $entries.fieldtable eq 'ld_tabdetailfield'}
                    <input type="checkbox" onclick="change_tablefield_presence(ld(this),'{$entries.fieldid}','tabdetailfield_presence')" class="second_switch"
                            {if $entries.presence eq '0'|| $entries.presence eq '2'}
                                checked
                            {/if}
                            {if $entries.allowhide eq 'no'}
                                disabled
                            {/if}
                    />
                {/if}

                {if $entries.fieldtable eq ''}
                    <input type="checkbox" onclick="cls_fieldlist.getInstance().saveFieldInfo(ld(this),'updateFieldPresence','{$entries.fieldid}')" class="second_switch"
                            {if $entries.presence eq 1}
                            {else}
                                {if $entries.allowhide eq 'no'}
                                    checked  disabled
                                {else}
                                    {if $entries.displaytype eq '2'}
                                        checked
                                    {else}
                                        {if $entries.presence eq '0' || $entries.mandatory eq '0'  || $entries.mandatory eq '2'}
                                            checked
                                        {/if}
                                        {if $entries.presence eq '2'}
                                            checked
                                        {/if}
                                        {if $entries.presence eq '3'}

                                        {/if}
                                    {/if}

                                {/if}
                            {/if}
                    />
                {/if}
            </td>
{*            <td><a class="Anu3_a" onclick="ProductToolEditField(this,'dvProductToolEditField',1316,22)">编辑</a></td>*}
        <input type="hidden" name="fieldid_{$entries.fieldid}" value="{$entries.fieldid}" uitype="{$entries.uitype}">
        </tr>
    {/foreach}
</table>
</div>
