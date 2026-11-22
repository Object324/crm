<script language="JAVASCRIPT" type="text/javascript" src="include/js/smoothscroll.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="include/js/menu.js?v={$GLOBALMINVERSION}"></script>
<div class="divPopOverflow">
<form action="index.php" method="post" name="company" onsubmit="puyoungJS_DialogBox.block();">
    <input type="hidden" name="module" value="ShopSettings"/>
    <input type="hidden" name="ajax" value="save"/>

    <table class="ld-public-content-small" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <th colspan="2">
                <div class="ld-pop-contnet-title-items">
                    <div class="ld-pop-contnet-title-item">{'application_setting'|@getFixedLabel}</div>
                </div>
            </th>
        </tr>
        <tr>
            <td class="ld-form-item-label">{'application_type'|@getFixedLabel}</td>
            <td class="ld-form-item-content">
                <select name="apptype" tag="{'application_type'|@getFixedLabel}" class="ld-select-inner">
                    <option {if $APPTYPE=='miniprogram'}selected{/if} value="miniprogram">{'WECHATAPPLETHEADER'|@getFixedLabel}</option>
                    <option {if $APPTYPE=='offiaccount'}selected{/if} value="offiaccount">{'WeChatofficialaccount'|@getFixedLabel}</option>
                    <option {if $APPTYPE=='app'}selected{/if} value="app">App</option>
                </select>
            </td>
        </tr>
        <tr>
            <td class="ld-form-item-label"><font color="red">*</font>APPID</td>
            <td class="ld-form-item-content">
                <input type="text" size="50" name="appid" tag="APPID" value="{$APPID}" class="ld-input-inner">
            </td>
        </tr>
    </table>
    <table class="ld-public-content-small padT8" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <th colspan="2">
                <div class="ld-pop-contnet-title-items">
                    <div class="ld-pop-contnet-title-item">{'MerchantInterfaceParam'|@getFixedLabel}</div>
                </div>
            </th>
        </tr>
        <tr>
            <td class="ld-form-item-label"><font color="red">*</font>{'MerchantNum'|@getFixedLabel}</td>
            <td class="ld-form-item-content">
                <input type="text" size="50" name="merchantnum" tag="{'MerchantNum'|@getFixedLabel}" value="{$MERCHANTNUM}" class="ld-input-inner">
            </td>
        </tr>
        <tr>
            <td class="ld-form-item-label"><font color="red">*</font>{'MerchantCertificateNum'|@getFixedLabel}</td>
            <td class="ld-form-item-content">
                <input type="text" size="50" name="merchantcertificatenum" tag="{'MerchantCertificateNum'|@getFixedLabel}" value="{$MERCHANTCERTIFICATENUM}" class="ld-input-inner">
            </td>
        </tr>
    </table>
    <table class="ld-public-content-small padT8" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <th colspan="2">
                <div class="ld-pop-contnet-title-items">
                    <div class="ld-pop-contnet-title-item">{'ApiInterfaceParam'|@getFixedLabel}</div>
                </div>
            </th>
        </tr>
        <tr>
            <td class="ld-form-item-label"><font color="red">*</font>{'APIKEY'|@getFixedLabel}</td>
            <td class="ld-form-item-content">
                <input type="text" size="50" name="apikey" tag="{'APIKEY'|@getFixedLabel}" value="{$APIKEY}" class="ld-input-inner">
            </td>
        </tr>
        <tr>
            <td class="ld-form-item-label"><font color="red">*</font>{'APIV3KEY'|@getFixedLabel}</td>
            <td class="ld-form-item-content">
                <input type="text" size="50" name="apiv3key" tag="{'APIV3KEY'|@getFixedLabel}" value="{$APIV3KEY}" class="ld-input-inner">
            </td>
        </tr>
    </table>
</form>
</div>