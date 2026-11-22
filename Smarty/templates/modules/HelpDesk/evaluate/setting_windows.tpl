{*editor:gyq_127 reason:服务小程序增加评价  2019/6/26 11:31*}
<div class="D_pop_content" id="windows_content" style="max-height:400px;overflow-y:auto;">
    <form id="form" method="post">
        <div class="marT10 marB10 fontbold">
            <input type="checkbox" name="switch" {if $SWITCH eq 'open'}checked{/if}>
            {'EVALUATESETTING01'|@getFixedLabel}
        </div>
        <table class="listEntries listEvaluate" cellpadding="0" cellspacing="1" border="0" width="100%">
            <tr>
                {foreach item=content from=$TITLE}
                    <th>{$content}</th>
                {/foreach}
            </tr>
            {foreach item=content from=$MAIN}
                <tr class="lvtColData" tag="row_content">
                    <td align="center">
                        <input type="checkbox" name="{$content.field_value}__presence"
                               {if $content.presence eq 'yes'}checked{/if}>
                    </td>
                    <td>
                        <input type="text" name="{$content.field_value}" value="{$content.field_text}"
                               class="txtBox btn-radius-system"/>
                    </td>
                    <td>
                        <input type="text" name="{$content.field_value}__en" value="{$content.field_text_en}"
                               class="txtBox btn-radius-system"/>
                    </td>
                    <td>
                        <select name="{$content.field_value}__optionid" class="btn-radius-system">
                            {foreach item=option_con from=$OPTION}
                                <option value="{$option_con.value}"
                                        {if $option_con.value eq $content.option_value}selected{/if}>{$option_con.text}</option>
                            {/foreach}
                        </select>
                    </td>
                </tr>
            {/foreach}
        </table>
        <div class="marT10 marB10 fontbold">
            <div>
                {*editor:gyq_137 reason:服务小程序评价改进  2019/8/22 17:48 *}
                <p>{'EVALUATESETTING03'|@getFixedLabel}</p>
            </div>
            <div style="margin-top: 5px;">
                <table border="0" cellpadding="0" cellspacing="1" width="100" valign="top" id="conditiongrouptable_1">
                    <tr>
                        <td align="left">
                            <select name="adv_name" id="" style="margin:0;">
                                {$FIELDNAMES}
                            </select></td>
                        <td align="left"><select name="adv_symbol" id="">
                                <option value="e">{'EQ'|@getFixedLabel}</option>
                            </select></td>
                        <td align="left">
                            <input name="adv_value"  class="commonTextBoxPop" type="text"  value="{$ADVVALUE}" style="width:150px">
                        </td>
                    </tr>
                </table>
            </div>
        </div>
    </form>
</div>