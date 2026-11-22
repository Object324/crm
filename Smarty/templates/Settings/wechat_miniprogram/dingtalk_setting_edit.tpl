{*editor:gyq_144 reason:钉钉  2019/9/12 14:41*}
<script language="JAVASCRIPT" type="text/javascript" src="include/js/smoothscroll.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="include/js/menu.js?v={$GLOBALMINVERSION}"></script>
<div class="divPopOverflow">
<form action="index.php" method="post" name="company" onsubmit="puyoungJS_DialogBox.block();">
    <input type="hidden" name="module" value="Settings"/>
    <input type="hidden" name="parenttab" value="Settings"/>
    <input type="hidden" name="ajax" value="save"/>
    <input type="hidden" name="blockidsetting" value="{$BLOCKIDSETTING}"/>
    <input type="hidden" name="fieldidsetting" value="{$FIELDIDSETTING}"/>
    <table class="ld-public-content-small" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <td colspan="2">
                <div class="ld-pop-contnet-title-items">
                    <div class="ld-pop-contnet-title-item">{'H5MICAPP'|@getFixedLabel} {'LBL_PARAMETER_SETTINGS'|@getFixedLabel}</div>
                </div>
            </td>
        </tr>
        <tr>
            <td class="ld-form-item-label"><font color="red">*</font>CorpId</td>
            <td class="ld-form-item-content">
                <input type="text" size="50" name="corpid" value="{$CORPID}" class="ld-input-inner">
            </td>
        </tr>
        <tr>
            <td class="ld-form-item-label"><font color="red">*</font>AgentId</td>
            <td class="ld-form-item-content">
                <input type="text" size="50" name="agentid" value="{$AGENTID}" class="ld-input-inner">
            </td>
        </tr>
        <tr>
            <td class="ld-form-item-label"><font color="red">*</font>Client ID</td>
            <td class="ld-form-item-content">
                <input type="text" size="100" name="key" value="{$KEY}" class="ld-input-inner">
            </td>
        </tr>
        <tr>
            <td class="ld-form-item-label"><font color="red">*</font>Client Secret</td>
            <td class="ld-form-item-content">
                <input type="text" size="100" name="secret" value="{$SECRET}" class="ld-input-inner">
            </td>
        </tr>
    </table>

    <table class="ld-public-content-small padT8" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <td colspan="2">
                <div class="ld-pop-contnet-title-items">
                    <div class="ld-pop-contnet-title-item">{'LBL_TO_LOGIN'|@getFixedLabel} {'LBL_PARAMETER_SETTINGS'|@getFixedLabel}</div>
                </div>
            </td>
        </tr>
        <tr>
            <td class="ld-form-item-label"><font color="red">*</font>Client ID</td>
            <td class="ld-form-item-content">
                <input type="text" size="50" name="login_appid" value="{$LOGIN_APPID}" class="ld-input-inner">
            </td>
        </tr>
        <tr>
            <td class="ld-form-item-label"><font color="red">*</font>Client Secret</td>
            <td class="ld-form-item-content">
                <input type="text" size="50" name="login_secret" value="{$LOGIN_SECRET}" class="ld-input-inner">
            </td>
        </tr>
        <tr>
            <td class="ld-form-item-label"><font color="red">*</font>{'WECHATAPPLETSETTINGSTITLE02'|@getFixedLabel}</td>
            <td class="ld-form-item-content">
                <input type="text" size="50" name="login_url" value="{$LOGIN_URL}" class="ld-input-inner">
            </td>
        </tr>
    </table>
</form>
</div>