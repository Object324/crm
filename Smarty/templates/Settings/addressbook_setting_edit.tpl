{*ls 2021-12-15 【1002160】企业微信通讯录及部门同步*}
<div class="divPopOverflow">
<script language="JAVASCRIPT" type="text/javascript" src="include/js/smoothscroll.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="include/js/menu.js?v={$GLOBALMINVERSION}"></script>
<form action="index.php" method="post" name="company" onsubmit="puyoungJS_DialogBox.block();">
    <input type="hidden" name="module" value="Settings"/>
    <input type="hidden" name="parenttab" value="Settings"/>
    <input type="hidden" name="ajax" value="save"/>
    <input type="hidden" name="blockidsetting" value="{$BLOCKIDSETTING}"/>
    <input type="hidden" name="fieldidsetting" value="{$FIELDIDSETTING}"/>
    <table class="ld-public-content-small" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <td colspan="2" >
                    <div class="ld-pop-contnet-title-items">
                        <div class="ld-pop-contnet-title-item">{'ENTERPRISEID'|@getFixedLabel}({'ENTERPRISEIDREMIND'|@getFixedLabel})</div>
                    </div>
            </td>
        </tr>
        <tr>
            <td class="ld-form-item-label"><font color="red">*</font>{'ENTERPRISEID'|@getFixedLabel}</td>
            <td class="ld-form-item-content">
                <input type="text" size="50" name="addressbook_corpid" value="{$corpid}" tag="企业ID" class="ld-input-inner">
            </td>
        </tr>
    </table>
    
	<table class="ld-public-content-small" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <td colspan="2">
                <div class="ld-pop-contnet-title-items">
                    <div class="ld-pop-contnet-title-item">{'addressbook_sync'|@getFixedLabel} Secret</div>
                </div>
            </td>
        </tr>
        <tr>
            <td class="ld-form-item-label"><font color="red">*</font>Secret</td>
            <td class="ld-form-item-content">
                <input type="text" size="50" name="addressbook_secret" value="{$SECRET}" tag="{'addressbook_sync'|@getFixedLabel} Secret" class="ld-input-inner">
            </td>
        </tr>
    </table>
    <table class="ld-public-content-small padB10" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <td colspan="2" >
                <div class="ld-pop-contnet-title-items">
                    <div class="ld-pop-contnet-title-item">{'receivingeventsettings'|@getFixedLabel}</div>
                </div>
            </td>
        </tr>
        <tr>
            <td class="ld-form-item-label">{'tokenurl'|@getFixedLabel}</td>
            <td class="ld-form-item-content">
                <div class="ld-text-inner">{$TOKENURL}</div>
            </td>
        </tr>
        <tr>
            <td class="ld-form-item-label">{*<font color="red">*</font>*}Token</td>
            <td class="ld-form-item-content">
                <input type="text" size="50" name="addressbook_token" value="{$TOKEN}" class="ld-input-inner">
            </td>
        </tr>
        <tr>
            <td class="ld-form-item-label">{*<font color="red">*</font>*}EncodingAESKey</td>
            <td class="ld-form-item-content">
                <input type="text" size="50" name="addressbook_encodingaeskey" value="{$ENCODINGAESKEY}" class="ld-input-inner">
            </td>
        </tr>
    </table>
</form>
</div>