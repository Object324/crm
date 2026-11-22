<div id='Customrules_content'>
    <div id='title_row' class="marTB16 font14" style='overflow: auto;min-height: 15px;'>
        <div class='lfloat' id='title'>{'SHARINGRULES'|@getFixedLabel}</div>
        <div class='rfloat'><a id='addcustomrules_btn' module='{$tabid}' onclick=OrgSharingDetailView.addCustomrules(this)>{'ADDRULES'|@getFixedLabel}</a></div>
    </div>
    <div id='table_row' class="padB16">
        <table id='Customrules_table_{$tabid}' width="100%" cellspacing="0" cellpadding="0" border="0" style="table-layout: fixed;">
            <tr>
                <th style="width: 5%;">#</th>
                <th style="width: 35%;">{'SHARINGCONDITIONS'|@getFixedLabel}</th>
                <th style="width: 15%;">{'SHAREDPERMISSIONS'|@getFixedLabel}</th>
                <th style="width: 35%;">{'AUTOSHARETO'|@getFixedLabel}</th>
                <th style="width: 10%;">{'OPERATING'|@getFixedLabel}</th>
            </tr>
            {if $customrulearr}
                {assign var="i" value=1}
                {foreach item=customrule from=$customrulearr}
                    {assign var="j" value=$i++}
                    <tr class="ltextalign">
                        <td>{$j}</td>
                        <td style="white-space: break-spaces;word-wrap: break-word;">{$customrule.advft}</td>
                        <td>{$customrule.permission}</td>
                        <td style="white-space: break-spaces;"><div style="white-space: break-spaces">{$customrule.shareto}</div></td>
                        <td>
                            <i name='editcustomrules_btn' record='{$customrule.customruleid}' module='{$tabid}' onclick=OrgSharingDetailView.editCustomrules(this,{$customrule.customruleid}) data-tip='{'EDIT'|@getFixedLabel}' data-direction='top' data-type='position' class='ld-fonticon ld-fonticon-edit sort-tip-items'></i>
                            <i name='deletecustomrules_btn' record='{$customrule.customruleid}' module='{$tabid}' onclick=OrgSharingDetailView.deleteCustomrules(this,{$customrule.customruleid}) data-tip='{'DELETE'|@getFixedLabel}' data-direction='top' data-type='position' class='ld-fonticon ld-fonticon-del sort-tip-items'></i>
                        </td>
                    </tr>
                {/foreach}
            {else}
                <tr><td colspan="5" class="ctextalign">{'NOTFOUNDANYRECORD'|@getFixedLabel}</td></tr>
            {/if}
        </table>
    </div>
</div>
<script>
{literal}
    tooltip('.sort-tip-items', {transition: true, time: 200});
{/literal}
</script>