<form id="send_email" name="send_email" method="post" onsubmit="puyoungJS_DialogBox.block()"  action="index.php" style="margin:0px" target="_blank">
    <input type='hidden' name="module" id="mmodule" value="Emails"/>
    <input type='hidden' name="action" id="aaction" value="index"/>
    <input type='hidden' name="allidsinfo_email" id="allidsinfo_email" value="{$ALLIDSINFO}"/>
    <input type='hidden' name="tabid_fieldlabelinfo_email" id="tabid_fieldlabelinfo_email" value=""/>
    <input type='hidden' name="allidsinfo_contact_email" id="allidsinfo_contact_email" value=""/>
    <input type='hidden' name="allidsinfo" id="allidsinfo" value="{$ALLIDSINFO}"/>
    <input type='hidden' name="tabid_fieldlabelinfo_contact_email" id="tabid_fieldlabelinfo_contact_email" value=""/>
    {if $MODULE eq 'Accounts'}   
        <input name="row_of_checkbox_account" id="row_of_checkbox_account" type="hidden" value="{$num_rows}">
        <input name="row_of_checkbox_account_email" id="row_of_checkbox_account_email" type="hidden" value="{$num_rows}">
    {else}
        <input name="row_of_checkbox_account" id="row_of_checkbox_account" type="hidden" value="{$num_rows}">
        <input name="row_of_checkbox_contact_email" id="row_of_checkbox_contact_email" type="hidden" value="{$num_rows}">
    {/if}
	<table class="ld-public-content-small" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <td class="ld-form-item-content padL0">{'PCWYWTSETE'|@getFixedLabel}</td>
        </tr>
        {if $MODULE eq 'Accounts'}
            {$html_account_Email}
        {else}
            {$html_contact_Email}
        {/if}
    </table>
</form>