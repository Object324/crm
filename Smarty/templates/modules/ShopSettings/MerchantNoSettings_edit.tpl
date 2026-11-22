<script language="JAVASCRIPT" type="text/javascript" src="include/js/smoothscroll.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="include/js/menu.js?v={$GLOBALMINVERSION}"></script>
<div class="divPopOverflow">
<form action="index.php" method="post" name="company" onsubmit="puyoungJS_DialogBox.block();">
    <input type="hidden" name="module" value="ShopSettings"/>
    <input type="hidden" name="ajax" value="save"/>

    <table class="ld-public-content-small" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <td colspan="2">
                <div class="ld-pop-contnet-title-items">
                    <div class="ld-pop-contnet-title-item">{'MerchantInterfaceParam'|@getFixedLabel}</div>
                </div>
            </td>
        </tr>
        <tr>
            <td class="ld-form-item-label"><font color="red">*</font>{'MerchantNum'|@getFixedLabel}</td>
            <td class="ld-form-item-content">
                <input type="text" name="merchantnum" tag="{'MerchantNum'|@getFixedLabel}" value="{$MERCHANTNUM}" class="ld-input-inner">
            </td>
        </tr>
        <tr>
            <td class="ld-form-item-label"><font color="red">*</font>{'MerchantCertificateNum'|@getFixedLabel}</td>
            <td class="ld-form-item-content">
                <input type="text" name="merchantcertificatenum" tag="{'MerchantCertificateNum'|@getFixedLabel}" value="{$MERCHANTCERTIFICATENUM}" class="ld-input-inner">
            </td>
        </tr>
    </table>
    <table class="ld-public-content-small padT8" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <td colspan="2">
                <div class="ld-pop-contnet-title-items">
                    <div class="ld-pop-contnet-title-item">{'ApiInterfaceParam'|@getFixedLabel}</div>
                </div>
            </td>
        </tr>
        <tr>
            <td class="ld-form-item-label"><font color="red">*</font>{'APIKEY'|@getFixedLabel}</td>
            <td class="ld-form-item-content">
                <input type="text" name="apikey" tag="{'APIKEY'|@getFixedLabel}" value="{$APIKEY}" class="ld-input-inner">
            </td>
        </tr>
        <tr>
            <td class="ld-form-item-label"><font color="red">*</font>{'APIV3KEY'|@getFixedLabel}</td>
            <td class="ld-form-item-content">
                <input type="text" name="apiv3key" tag="{'APIV3KEY'|@getFixedLabel}" value="{$APIV3KEY}" class="ld-input-inner">
            </td>
        </tr>
        
    </table>
</form>
</div>