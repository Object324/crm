<tr id="show_athome_person_tr" {if $mainInfo['show_athome']!='yes'}style="display:none;"{/if}>
    <td align="right" class="DetailedTd1Label select-input padL30">
        <input id="show_athome_person" class="second_switch" name="show_athome_person" type="checkbox" {if $var_multiuser_nums==1}checked=""{/if}>

    </td>
    <td>
        <label>{'showAtPcHomeOfScope'|getFixedLabel},{'VIEWRANGE'|getFixedLabel}{'MapFields'|getFixedLabel}</label>
        <select class="custom-select" name="show_athome_person_varname">
            <option value=""></option>
            {foreach item=filterline key=j from=$sqlFilterArr}
                {if $filterline['var_type']=='multiuser'}
                    <option value="{$filterline['id']}" {if $filterline['filter_relatedtab']=='Home'}selected=""{/if}>{$filterline['display_name']}</option>
                {/if}
            {/foreach}
        </select>
    </td>
</tr>
<tr id="show_athome_timecheck_tr" {if $mainInfo['show_athome']!='yes'}style="display:none;"{/if}>
    <td  align="right" class="DetailedTd1Label select-input padL30 tdwidth150">
        <input id="show_athome_timecheck" class="second_switch" name="show_athome_timecheck" type="checkbox" {if $var_time_nums==1}checked=""{/if}>
    </td>
    <td>
        <label>{'showAtPcHomeOfTime'|getFixedLabel},{'Start_Date'|getFixedLabel}{'MapFields'|getFixedLabel}</label>
        <select style="width:100px;" name="show_athome_time1" id="show_athome_time1" class="custom-select">
            <option value=""></option>
            {foreach item=filterline key=j from=$sqlFilterArr}
                {if $filterline['var_type']=='date'|| $filterline['var_type']=='datetime'}
                    <option value="{$filterline['id']}" {if $filterline['filter_relatedtab']=='Home'&&$filterline['uses']=='start'}selected=""{/if}>{$filterline['display_name']}</option>
                {/if}
            {/foreach}
        </select>
        <label>{'ENDDATE'|getFixedLabel}{'MapFields'|getFixedLabel}</label>
        <select style="width:100px;" name="show_athome_time2" id="show_athome_time2" class="custom-select">
            <option value=""></option>
            {foreach item=filterline key=j from=$sqlFilterArr}
                {if $filterline['var_type']=='date'|| $filterline['var_type']=='datetime'}
                    <option value="{$filterline['id']}" {if $filterline['filter_relatedtab']=='Home'&&$filterline['uses']=='end'}selected=""{/if}>{$filterline['display_name']}</option>
                {/if}
            {/foreach}
        </select>
    </td>
</tr>
<tr id="show_athome_approve_tr" {if $mainInfo['show_athome']!='yes'}style="display:none;"{/if}>
    <td align="right" class="DetailedTd1Label select-input padL30 tdwidth150">
        <input id="show_athome_approve" class="second_switch" name="show_athome_approve" type="checkbox" {if $var_approvestatus_nums==1}checked=""{/if}>
    </td>
    <td>
        <label>{'showAtPcHomeOfApprove'|getFixedLabel},{'approvestatus'|getFixedLabel}{'MapFields'|getFixedLabel}</label>
        <select class="custom-select" name="show_athome_approve_varname">
            <option value=""></option>
            {foreach item=filterline key=j from=$sqlFilterArr}
                {if $filterline['var_type']=='approvestatus'}
                    <option value="{$filterline['id']}" {if $filterline['filter_relatedtab']=='Home'}selected=""{/if}>{$filterline['display_name']}</option>
                {/if}
            {/foreach}
        </select>
    </td>
</tr>