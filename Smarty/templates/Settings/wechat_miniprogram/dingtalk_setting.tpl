{*//editor:gyq_144 reason:钉钉  2019/9/12 13:55*}
<script language="JAVASCRIPT" type="text/javascript" src="include/js/smoothscroll.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="include/js/menu.js?v={$GLOBALMINVERSION}"></script>
<form action="index.php" method="post" name="company" onsubmit="puyoungJS_DialogBox.block();">
<input type="hidden" name="module" value="Settings"/>
<input type="hidden" name="parenttab" value="Settings"/>
<input type="hidden" name="action"/>
<input type="hidden" name="blockidsetting" value="{$BLOCKIDSETTING}"/>
<input type="hidden" name="fieldidsetting" value="{$FIELDIDSETTING}"/>
<div class="main_grid_top">
    <div class="grid-view-title lfloat overflow-hidden">
        <span class="grid-view-name dinline-block lfloat">
            {'dingtalk_setting'|@getFixedLabel}{if $HelpHtml.DingtalkSetting neq '' }{$HelpHtml.DingtalkSetting}{/if}
        </span>
    </div>
    <div class="grid_tool">
        <div class="displayflex">
            <a href="javascript:;" class="ld-button ld-button-primary" onclick="dingtalk_setting_edit()" title="{'EDIT'|@getFixedLabel}">{'EDIT'|@getFixedLabel}</a>
            <a href="javascript:;" class="ld-button" onclick="dingtalk_setting_delete()" title="{'LOGOUTS'|@getFixedLabel}">{'LOGOUTS'|@getFixedLabel}</a>
        </div>
    </div>
</div>
<div class="main_grid_box">
    <div class="grid-analysis-box">
        <div class="grid-analysis-header">
        </div>
        <div class="cont_wrap clear_float">
            <table class="settingTable" width="100%" border="0" cellspacing="0" cellpadding="0">
                <tr>
                    <th colspan="2">{'H5MICAPP'|@getFixedLabel} {'THEINTERFACEPARAMENTERS'|@getFixedLabel}</th>
                </tr>
                <tr id="setting_1" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
                    <td width="20%">CorpId</td>
                    <td width="80%">{$CORPID}</td>
                </tr>
                <tr id="setting_2" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
                    <td>AgentId</td>
                    <td>{$AGENTID}</td>
                </tr>
                <tr id="setting_3" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
                    <td>Client ID</td>
                    <td>{$KEY}</td>
                </tr>
                <tr id="setting_4" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
                    <td>Client Secret</td>
                    <td>{$SECRET}</td>
                </tr>
            </table>
            <table class="settingTable" width="100%" border="0" cellspacing="0" cellpadding="0">
                <tr>
                    <th colspan="2">{'LBL_TO_LOGIN'|@getFixedLabel} {'THEINTERFACEPARAMENTERS'|@getFixedLabel}</th>
                </tr>
                {*editor:gyq_165 reason:修改参数格式   2019/12/26 14:57 *}
                <tr id="setting_5" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
                    <td width="20%" class="cellLabel">Client ID</td>
                    <td width="80%" class="borderBR">{$LOGIN_APPID}</td>
                </tr>
                <tr id="setting_6" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
                    <td width="20%" class="cellLabel">Client Secret</td>
                    <td width="80%" class="borderBR">{$LOGIN_SECRET}</td>
                </tr>
                <tr id="setting_7" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
                    <td width="20%" class="cellLabel">{'WECHATAPPLETSETTINGSTITLE02'|@getFixedLabel}</td>
                    <td width="80%" class="borderBR">{$LOGIN_URL}</td>
                </tr>
                <tr id="setting_8" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
                    <td width="20%" class="cellLabel">{'PCHOMEADDRESS'|@getFixedLabel}</td>
                    <td width="80%" class="borderBR linefeed">{$AUTHLOGINURL}</td>
                </tr>
            </table>
            <div class="listRloesHelp">
                <font color="red">{'TIP'|@getFixedLabel}：</font>
                <ul>
                    <li>1、{'WECHATAPPLETSETTINGSREMIND05'|@getFixedLabel}</li>
                    <li>2、{'DINGTALKINTERFACEREMIND'|@getFixedLabel}</li>
                </ul>
            </div>
        </div>
    </div>
</div>
</form>