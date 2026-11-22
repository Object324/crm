<form id="sendinfo" name="sendinfo" method="post" onsubmit="puyoungJS_DialogBox.block()" ENCTYPE="multipart/form-data" action="index.php" style="margin:0px" target="_blank">
    <input type='hidden' name="module"  value="{$MODULE}"/>
    <input type='hidden' name="action" value="index"/>
    <input type='hidden' name="SMStype" value="{$SMStype}"/>
    <input type='hidden' name="allidsinfo" id="allidsinfo" value="{$ALLIDSINFO}"/>
    <input type='hidden' name="tabid_fieldlabelinfo" id="tabid_fieldlabelinfo" value=""/>
    <input type='hidden' name="allidsinfo_contact" id="allidsinfo_contact" value=""/>
    <input type='hidden' name="tabid_fieldlabelinfo_contact" id="tabid_fieldlabelinfo_contact" value=""/>
    {if $MODULE eq 'Accounts'||$MODULE eq 'ServiceCharge'}
        <input name="row_of_checkbox_account" id="row_of_checkbox_account_sms" type="hidden" value="{$num_rows}">
        <input name="row_of_checkbox_account_email" id="row_of_checkbox_account_email" type="hidden" value="{$num_rows}">
    {else}
        <input name="row_of_checkbox_account" id="row_of_checkbox_account_sms" type="hidden" value="{$num_rows}">
        <input name="row_of_checkbox_contact_email" id="row_of_checkbox_contact_email" type="hidden" value="{$num_rows}">
    {/if}
	<table class="ld-public-content-small" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <td class="ld-form-item-content padL0">
                {if $subtitle}
                    {$subtitle}
                {else}
                    {'PCWYWTSTMTMP'|@getFixedLabel}
                {/if}
            </td>
        </tr>
        {if $MODULE eq 'Accounts'||$MODULE eq 'ServiceCharge'}
            {$html_account_SMS}
        {else}
            {$html_contact_SMS}
        {/if}
    </table>
</form>