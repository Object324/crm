{*editor:gyq_144 reason:钉钉  2019/9/12 14:41*}
<script language="JAVASCRIPT" type="text/javascript" src="include/js/smoothscroll.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="include/js/menu.js?v={$GLOBALMINVERSION}"></script>
<form action="index.php" method="post" name="company" onsubmit="puyoungJS_DialogBox.block();">
    <input type="hidden" name="module" value="Settings"/>
    <input type="hidden" name="parenttab" value="Settings"/>
    <input type="hidden" name="ajax" value="save"/>
    <input type="hidden" name="blockidsetting" value="{$BLOCKIDSETTING}"/>
    <input type="hidden" name="fieldidsetting" value="{$FIELDIDSETTING}"/>
	<table class="ld-public-content-paddingright" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <th colspan="2" class="ld-from-headblock"><div class="ld-from-headblock-title">{'account_contact'|@getFixedLabel}Secret</div></th>
        </tr>
        <tr>
            <td class="ld-form-item-label"><font color="red">*</font>Secret</td>
            <td class="ld-form-item-content">
                <input type="text" size="50" name="channelcode_secret" value="{$SECRET}" tag="{'account_contact'|@getFixedLabel}Secret" class="ld-input-inner">
            </td>
        </tr>
    </table>
    <table class="ld-public-content-paddingright padB10" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <th colspan="2" class="ld-from-headblock"><div class="ld-from-headblock-title" style="height: auto;">{'receivingeventsettings'|@getFixedLabel}</div></th>
        </tr>
        <tr>
            <td class="ld-form-item-label">{'tokenurl'|@getFixedLabel}</td>
            <td class="ld-form-item-content">
                <div class="ld-text-inner">{$TOKENURL}</div>
            </td>
        </tr>
        <tr>
            <td class="ld-form-item-label"><font color="red">*</font>Token</td>
            <td class="ld-form-item-content">
                <input type="text" size="50" name="channelcode_token" value="{$TOKEN}" class="ld-input-inner">
            </td>
        </tr>
        <tr>
            <td class="ld-form-item-label"><font color="red">*</font>EncodingAESKey</td>
            <td class="ld-form-item-content">
                <input type="text" size="50" name="channelcode_encodingaeskey" value="{$ENCODINGAESKEY}" class="ld-input-inner">
            </td>
        </tr>
    </table>
</form>