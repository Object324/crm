{*<script language="JAVASCRIPT" type="text/javascript" src="include/js/smoothscroll.js"></script>*}
{*<script language="JavaScript" type="text/javascript" src="include/js/menu.js"></script>*}
<div class="divPopOverflow">
<form action="index.php" method="post" name="company" onsubmit="puyoungJS_DialogBox.block();">
    <input type="hidden" name="module" value="Settings"/>
    <input type="hidden" name="parenttab" value="Settings"/>
    <input type="hidden" name="ajax" value="save"/>
    <input type="hidden" name="blockidsetting" value="{$BLOCKIDSETTING}"/>
    <input type="hidden" name="fieldidsetting" value="{$FIELDIDSETTING}"/>
    <table class="ld-public-content-small" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <td class="ld-form-item-label" style="width: 205px;"><font color="red">*</font>{'WECHATAPPLETSETTINGSTITLE02'|@getFixedLabel}</td>
            <td class="ld-form-item-content">
                <input type="text" size="100" name="corp_link" value="{$CORP_LINK}" class="ld-input-inner">
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
            <td class="ld-form-item-label"><font color="red">*</font>Secret</td>
            <td class="ld-form-item-content">
                <input type="text" size="100" name="secret" value="{$SECRET}" class="ld-input-inner">
            </td>
        </tr>
    </table>
</form>
</div>