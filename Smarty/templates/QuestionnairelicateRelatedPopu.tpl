<div name="div_check_repeat">
    <div style="padding: 0 10px;margin: 10px auto 9px;">
        {'KEYWORDS'|@getFixedLabel}
        {*txy XUQIU1001546 为搜索框增加聚焦事件 调查问卷查询框*}
        <input class="ld-input-inner" type="text" value="{$SEARCH_CONTENT}" name="cheack_repeat_columnname" id="cheack_repeat_columnname" placeholder="{$SEARCHLABEL}" onfocus="cleanall()" style="width:70%;box-sizing: border-box;padding-left: 8px;"/>
        <input type="button" name="search" value="立即查找" onclick="search_relatedlist({$TOPICID},'{$MODULE}');" class="ld-button ld-button-primary ">
    </div>
    <div id="accounts_table_all" style=" overflow:auto;height:250px;margin:0 auto;">
        <table class="settingPopTable" border="0" cellpadding="0" cellspacing="0" width="100%" style="table-layout: auto;">
            <tr>
                {foreach item=fieldlabel key=ky from=$TABLEHEADER}
                    <th><span title="{$fieldlabel}">{$fieldlabel}</span></th>
                {/foreach}
            </tr>
            {if count($TABLE_DUPLICATE_VALUE) > 0}
                {assign var="i" value=0}
                {foreach item=table_value key=col from=$TABLE_DUPLICATE_VALUE}
                    {assign var="j" value=$i++}
                    {if $j mod 2 eq '0'}
                        <tr id="poprow_{$j}" class="lvtColData" onclick="choose_related({$col},{$j},{$TOPICID})" onmouseout="setPopTrColorOut('poprow_{$j}','on');" onmouseover="setPopTrColor('poprow_{$j}');">
                            {else}
                        <tr id="poprow_{$j}" class="lvtColDataBj" onclick="choose_related({$col},{$j},{$TOPICID})" onmouseout="setPopTrColorOut('poprow_{$j}','On');" onmouseover="setPopTrColor('poprow_{$j}');">
                    {/if}
                    {foreach item=fieldvalue key=columnname from=$table_value}
                        {if $fieldvalue.value neq '#&&&&&#'}
                            <td rowspan="{$fieldvalue.rowspan}">
                                {if $columnname eq 'accountname'}
                                    <a title="" style="cursor: pointer;">{$fieldvalue.value}</a>
                                {else}
                                    <span title="">{$fieldvalue.value}</span>
                                {/if}
                            </td>
                        {/if}
                    {/foreach}
                    </tr>
                {/foreach}
            {else}
                <tr height="208px" valign="center">
                    <td align="center" style="background: #fff;" colspan="{$DISPLAYCOLUMNNUMBER}">{'NOTFOUNDANYRECORD'|@getFixedLabel}</td>
                </tr>
            {/if}
        </table>
    </div>
    <div style="margin:10px 11px;">说明：支持多字段模糊查询，仅显示符合条件的前{$MAXROWSSHOW}条数据。</div>
</div>