{*@edit:liushuai,2020-08-21,reason:【ID1001020】钉钉接口参数设置增加参数“钉钉群消息推送设置”*}
<script language="JAVASCRIPT" type="text/javascript" src="include/js/smoothscroll.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="include/js/menu.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="include/js/modules/Settings/Settings.js?v={$GLOBALMINVERSION}"></script>
<form action="index.php" method="post" name="company" onsubmit="puyoungJS_DialogBox.block();">
<input type="hidden" name="module" value="Settings"/>
<input type="hidden" name="parenttab" value="Settings"/>
<input type="hidden" name="action"/>
<input type="hidden" name="blockidsetting" value="{$BLOCKIDSETTING}"/>
<input type="hidden" name="fieldidsetting" value="{$FIELDIDSETTING}"/>
<div class="main_grid_top">
    <div class="grid-view-title lfloat overflow-hidden">
        <span class="grid-view-name dinline-block lfloat">
            {'dingtalk_webhook_setting'|@getFixedLabel}{if $HelpHtml.DingtalkWebhookSetting neq '' }{$HelpHtml.DingtalkWebhookSetting}{/if}
        </span>
    </div>
    <div class="grid_tool">
        <div class="displayflex">
            <a href="javascript:;" class="ld-button ld-button-primary" onclick="dingtalk_webhook_setting_create_or_edit('','','create')" title="{'CREATE'|@getFixedLabel}">{'CREATE'|@getFixedLabel}</a>
        </div>
    </div>
</div>
<div class="main_grid_box">
    <div class="grid-analysis-box">
        <div class="grid-analysis-header">
        </div>
        <div id="cfList" class="cont_wrap clear_float">
            {include file="dingtalk_webhook_setting_entries.tpl"}
        </div>

        {*<div class="cont_wrap clear_float">
            <div class="TitleHeading">
                {'dingtalk_webhook_setting'|@getFixedLabel}
            </div>
            <table class=" singleList" width="100%" border="0" cellspacing="0" cellpadding="5"
                   style="color:#555;">
                <tr>
                    <td width="20%" class="cellLabel"> Webhook {'COMPANYADDRESS'|@getFixedLabel} </td>
                    <td width="80%" class="borderBR">{$webhook}</td>
                </tr>
                <tr>
                    <td width="20%" class="cellLabel">{'WHETHERTOENABLE'|@getFixedLabel}</td>
                    <td width="80%" class="borderBR">{if $is_enable eq 1}{'YES'|@getFixedLabel}{else}{'NO'|@getFixedLabel}{/if}</td>
                </tr>
            </table>
        </div>*}

    </div>
</div>
</form>