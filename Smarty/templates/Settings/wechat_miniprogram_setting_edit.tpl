<form action="index.php" method="post" name="company" onsubmit="puyoungJS_DialogBox.block();">
	<input type="hidden" name="module" value="Settings"/>
	<input type="hidden" name="parenttab" value="Settings"/>
    <input type="hidden" name="action"/>
    <input type="hidden" name="ajax" value="save"/>
	<input type="hidden" name="corpid" value="{$CORPID}"/>
    <input type="hidden" id="blockidsetting" name="blockidsetting" value="{$BLOCKIDSETTING}"/>
    <input type="hidden" id="fieldidsetting" name="fieldidsetting" value="{$FIELDIDSETTING}"/>
    <table class="ld-public-content-small" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <td class="ld-form-item-label">{'WECHATAPPLETSETTINGSTITLE01'|@getFixedLabel}</td>
            <td class="ld-form-item-content"><input type="text" maxlength="50" size="50" id="mini_account" name="mini_account" value="{$CONTENTONE}" class="ld-input-inner"></td>
        </tr>
        <tr>
            <td class="ld-form-item-label">{'WECHATAPPLETSETTINGSTITLE02'|@getFixedLabel}</td>
            <td class="ld-form-item-content"><input type="text" size="50" id="mini_url" name="mini_url" value="{$CONTENTTWO}" class="ld-input-inner"></td>
        </tr>
        {*//zxm  20220728 系统设置增加小程序消息提醒设置*}
        <tr>
            <td class="ld-form-item-label">{'msgsend_type'|@getFixedLabel}</td>
            <td class="ld-form-item-content">
                <select class="ld-select-inner" id="msgsend_type" name="msgsend_type" onchange="wechat_miniprogram_setting.msgsend_typechange(this)">
                    <option value="msgsend_typeld" {if $CONTENT['msgsend_type']=='msgsend_typeld'}selected{/if}>{'msgsend_typeld'|@getFixedLabel}</option>
                    <option value="msgsend_typeoem" {if $CONTENT['msgsend_type']=='msgsend_typeoem'}selected{/if}>{'msgsend_typeoem'|@getFixedLabel}</option>
                </select>
            </td>
        </tr>
        <tr {if $CONTENT['msgsend_type']=='msgsend_typeoem'}{else}style="display:none;"{/if}>
            <td class="ld-form-item-label">{'AppletAppID'|@getFixedLabel}</td>
            <td class="ld-form-item-content"><input type="text" size="50" id="mini_appid" name="mini_appid" value="{$CONTENT['mini_appid']}" class="ld-input-inner"></td>
        </tr>
        <tr {if $CONTENT['msgsend_type']=='msgsend_typeoem'}{else}style="display:none;"{/if}>
            <td class="ld-form-item-label">{'AppletSecret'|@getFixedLabel}</td>
            <td class="ld-form-item-content"><input type="text" size="50" id="mini_secret" name="mini_secret" value="{$CONTENT['mini_secret']}" class="ld-input-inner"></td>
        </tr>
        <tr {if $CONTENT['msgsend_type']=='msgsend_typeoem'}{else}style="display:none;"{/if}>
            <td class="ld-form-item-label">{'WechatofficialaccountAppId'|@getFixedLabel}</td>
            <td class="ld-form-item-content"><input type="text" size="50" id="offiaccount_appid" name="offiaccount_appid" value="{$CONTENT['offiaccount_appid']}" class="ld-input-inner"></td>
        </tr>
        <tr {if $CONTENT['msgsend_type']=='msgsend_typeoem'}{else}style="display:none;"{/if}>
            <td class="ld-form-item-label">{'WechatofficialaccountSecret'|@getFixedLabel}</td>
            <td class="ld-form-item-content"><input type="text" size="50" id="offiaccount_secret" name="offiaccount_secret" value="{$CONTENT['offiaccount_secret']}" class="ld-input-inner"></td>
        </tr>
        <tr>
            <td colspan="2">
                <div class="listRloesHelp pad0">
                    <font color="red">{'TIP'|@getFixedLabel}：</font>
                    <ul>
                        <li>1、{'WECHATAPPLETSETTINGSREMIND04'|@getFixedLabel};</li>
                        <li>2、{'WECHATAPPLETSETTINGSREMIND05'|@getFixedLabel};</li>
                        <li>3、{'CANBESCANNEDDIRECTLYWITHWECHAT'|@getFixedLabel};</li>
                        {*//zxm  20220728 系统设置增加小程序消息提醒设置*}
                        <li {if $CONTENT['msgsend_type']=='msgsend_typeoem'}{else}style="display:none;"{/if} class="oemtops">4、{'WECHATAPPLETSETTINGSREMIND06'|@getFixedLabel}；</li>
                        <li {if $CONTENT['msgsend_type']=='msgsend_typeoem'}{else}style="display:none;"{/if} class="oemtops">5、{'WECHATAPPLETSETTINGSREMIND07'|@getFixedLabel}；</li>
                        <li {if $CONTENT['msgsend_type']=='msgsend_typeoem'}{else}style="display:none;"{/if} class="oemtops">6、{'WECHATAPPLETSETTINGSREMIND08'|@getFixedLabel}；</li>
					</ul>
                </div>
            </td>
        </tr>
    </table>
 </form>