{if $mode neq 'getrelatedfield'}
<tr>
    <td class="ld-form-item-label">{'AUTOREFERENCEWORKCONTENTS'|@getFixedLabel}
    </td><td class="ld-form-item-content">
        <input type="checkbox" class="second_switch" value="" {if $relatedmodulefield eq 'yes'}checked{/if} name="relatedmodulefield">
        <span>({'ACCORDINGTODATARANGEOFWORKREPORT'|@getFixedLabel})</span>
    </td>
</tr>
<tr name="related_type_tr" {if $relatedmodulefield eq 'no'}style="display: none" {/if}>
    <td class="ld-form-item-label">{'SELECTREFERENCEMODULE'|@getFixedLabel}</td>
    <td class="ld-form-item-content">
        <select  name="related_type" class="ld-select-inner">
            {foreach key=key item=relatedreporttype from=$related_reporttype_arr}
                <option relatedtype="{$relatedreporttype.type}" value="{$key}" {if $relatedreporttype.type eq $related_type}selected{/if}>{$relatedreporttype.label}</option>
            {/foreach}
        </select>
    </td>
</tr>
{/if}
<tr name="related_fieldid_tr" {if $relatedmodulefield eq 'no'}style="display: none" {/if}>
    <td class="ld-form-item-label">{'SELECTREFERENCEFIELDS'|@getFixedLabel}</td>
    <td class="ld-form-item-content">
        <div name="related_fieldid_div" >
            <select  MULTIPLE id="related_fieldid" name="related_fieldid" class="ld-input-inner select2 select2-offscreen select2-hidden-accessible" style="width:100%;">
                {foreach key=fieldid item=relatedfieldid_arr from=$related_fieldid_arr}
                        <option fieldname="{$relatedfieldid_arr.name}" type="{$relatedfieldid_arr.type}" value="{$fieldid}">{$relatedfieldid_arr.label}</option>
                {/foreach}
            </select>
        </div>
    </td>
</tr>
{if $mode neq 'getrelatedfield'}
<tr name="related_time_tr" {if $relatedmodulefield eq 'no'} {/if}>
    <td class="ld-form-item-label">{'SELECTREFERENCETIME'|@getFixedLabel}</td>
    <td class="ld-form-item-content">
        <select  name="related_time" class="ld-select-inner">
            {foreach key=key item=relatedtime from=$related_time_arr}
                <option value="{$key}" {if $key eq $related_time}selected{/if}>{$relatedtime}</option>
            {/foreach}
        </select>
    </td>
</tr>
{/if}