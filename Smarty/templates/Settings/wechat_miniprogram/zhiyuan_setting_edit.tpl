{*editor:gyq_144 reason:����  2019/9/12 14:41*}
<script language="JAVASCRIPT" type="text/javascript" src="include/js/smoothscroll.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="include/js/menu.js?v={$GLOBALMINVERSION}"></script>
<form action="index.php" method="post" name="company" onsubmit="puyoungJS_DialogBox.block();">
    <input type="hidden" name="module" value="Settings"/>
    <input type="hidden" name="parenttab" value="Settings"/>
    <input type="hidden" name="ajax" value="save"/>
    <input type="hidden" name="blockidsetting" value="{$BLOCKIDSETTING}"/>
    <input type="hidden" name="fieldidsetting" value="{$FIELDIDSETTING}"/>

    <table class="ld-public-content-paddingright padTB10" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <td class="ld-form-item-label" style="width: 205px;"><font color="red">*</font>{'WECHATAPPLETSETTINGSTITLE02'|@getFixedLabel}</td>
            <td class="ld-form-item-content">
                <input type="text" size="50" name="login_crmURL" value="{$CRM_URL}" class="ld-input-inner">
            </td>
        </tr>
        <tr>
            <td class="ld-form-item-label"><font color="red">*</font>{'ZhiyuanAccessAddress'|@getFixedLabel}</td>
            <td class="ld-form-item-content">
                <input type="text" size="50" name="login_zyURL" value="{$ZHIYUAN_URL}" class="ld-input-inner">
            </td>
        </tr>
        <tr>
            <td class="ld-form-item-label"><font color="red">*</font>{'ZhiyuanSystemRegistrationCode'|@getFixedLabel}</td>
            <td class="ld-form-item-content">
                <input type="text" size="50" name="login_zyCode" value="{$REGISTERCODE}" class="ld-input-inner">
            </td>
        </tr>
        <tr>
            <td class="ld-form-item-label"><font color="red">*</font>{'ZhiyuanUsername'|@getFixedLabel}</td>
            <td class="ld-form-item-content">
                <input type="text" size="50" name="login_zyUsername" value="{$USERNAME}" class="ld-input-inner">
            </td>
        </tr>
        <tr>
            <td class="ld-form-item-label"><font color="red">*</font>{'ZhiyuanUserPassword'|@getFixedLabel}</td>
            <td class="ld-form-item-content">
                <input type="text" size="50" name="login_zyUserPassword" value="{$PASSWORD}" class="ld-input-inner">
            </td>
        </tr>
    </table>
</form>