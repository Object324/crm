<script language="JAVASCRIPT" type="text/javascript"
    src="{$JSURL}include/js/smoothscroll.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/menu.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript"
    src="{$JSURL}include/js/picklist.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/general.js?v={$GLOBALMINVERSION}"></script>
<div class="divPopOverflow">
<form action="index.php" method="post" name="phonesettings" onsubmit="puyoungJS_DialogBox.block();">
    <input type="hidden" name="module" value="ShopSettings" />
    <input type="hidden" name="recordid" value="{$RECORDID}" />
    <input type="hidden" name="mode" value="{$OperateMode}" />
    <input type="hidden" name="version_account" value="{$version_account}" />
    <input type="hidden" name="selectproductfield" value="{$productfieldname}" />
    <input type="hidden" name="ajax" value="save" />
    <table class="ld-public-content-small" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <td class="ld-form-item-label">
                <font color="red">*</font>
                {'Name'|@getFixedLabel}
            </td>
            <td class="ld-form-item-content">
                <input class="ld-input-inner" tag="PhoneNameEdit" type="text" value="{$CUSTOMER_NAME}">
            </td>
        </tr>
        <tr>
            <td class="ld-form-item-label">
                <font color="red">*</font>
                {'Mobile'|@getFixedLabel}
            </td>
            <td class="ld-form-item-content">
                <input class="ld-input-inner" tag="PhoneNumberEdit" type="text" value="{$PHONE_NUMBER}">
            </td>
        </tr>
        <tr>
            <td class="ld-form-item-label">
                {'CUSTOMERSTATUS'|@getFixedLabel}
            </td>
            <td class="ld-form-item-content">
                {if $MODE eq 'edit' && $STATUS neq 'yes'}
                <input tag="PhoneStatus" type="checkbox" class="second_switch">
                {else}
                <input tag="PhoneStatus" type="checkbox" class="second_switch" checked>
                {/if}
            </td>
        </tr>
    </table>
</form>
</div>