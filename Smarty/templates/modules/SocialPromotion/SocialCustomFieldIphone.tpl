{foreach key=key item=field from=$customFields}
    <div>
        <label id="show_{$field['columnname']}">
            {$field['fieldlabel']}
        </label>
        <span id="show_r_{$field['columnname']}" class="required" style ="display:{if $field['required'] eq 1}inline-block{else}none{/if}">*</span>
        {if $field['bigtype'] =='longtextarea'}
            <textarea row="2"  class="detailedViewTextBox"  name="{$field['columnname']}" data-required="1" data-only="1"></textarea>
        {elseif $field['bigtype'] =='picklist'}
{*            判断是否是级联字段 *}
            {if $field['beforecascade'] || $field['aftercascade']}
                <select class="detailedViewTextBox" {if $field['beforecascade']} onclick="checkBeforecascade(this)" {/if} {if $field['aftercascade']} onchange="setAfterCascade(this)" {/if}   beforecascade="{$field['beforecascade']}" aftercascade="{$field['aftercascade']}" name="{$field['columnname']}" id="">
                    {*如果级联没有前面字段 显示自己的value*}{* 可能有问题 待定...*}
                    {if !$field['beforecascade']}
                        {foreach  item=value from=$field['pickListValue']}
                            <option value="{$value}">{$value}</option>
                        {/foreach}
                    {/if}

                </select>
            {else}
                <select class="detailedViewTextBox" name="{$field['columnname']}" id="">
                    {foreach  item=value from=$field['pickListValue']}
                    <option value="{$value}">{$value}</option>
                    {/foreach}
                </select>
            {/if}
        {elseif $field['bigtype'] =='multipicklist' }
            <input type="text"  name="{$field['columnname']}" id="{$field['columnname']}" data-id="" class="detailedViewTextBox">
        {else}
            <input type="text"  name="{$field['columnname']}" class="detailedViewTextBox">
        {/if}
    </div>
{/foreach}