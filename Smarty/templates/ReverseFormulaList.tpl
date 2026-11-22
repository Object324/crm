<table class="settingPopTable" border="0" cellpadding="0" cellspacing="0" style="width: 100%;">
    <tr>
        <th>{'Calculatedfields'|@getFixedLabel}</th>
        <th>{'FIELDFORMULAS'|@getFixedLabel}</th>
        <th>{'OPERATING'|@getFixedLabel}</th>
    </tr>
    {foreach from=$ReverseArr item=reverseinfo}
        <tr>
            <td>{$reverseinfo.reversefieldlabel}</td>
            <td>{$reverseinfo.formulastring}</td>
            <td><a href="javascript:;" name="settreverseformula" onclick="setreverseformula(ld(this))" module='{$MODULE}' parentid='{$reverseparentid}' tag='{$reverseinfo.reversefieldid}'>{'SettingFormula'|@getFixedLabel}</a>
            <a href="javascript:;" name="deletereverseformula" onclick="deletereverseformula(ld(this))" module='{$MODULE}' parentid='{$reverseparentid}' tag='{$reverseinfo.reversefieldid}'>{'DELETE'|@getFixedLabel}</a></td>
        </tr>
    {/foreach}
    <tr>
        <td colspan="3"><a href="javascript:;" module='{$MODULE}' parentid='{$reverseparentid}' onclick="addreversefield(ld(this))">{'NEW'|@getFixedLabel}</a></td>
    </tr>
</table>