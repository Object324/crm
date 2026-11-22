{*editor:gyq_135 reason:微信打卡同步至月度考勤表  2019/8/14 16:42 ID1000568*}
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
            {'CHECKINSETTING'|@getFixedLabel}{if $HelpHtml.CheckinSetting neq '' }{$HelpHtml.CheckinSetting}{/if}<font>（{'CHECKINSETTING_DESCRIB'|@getFixedLabel}）</font>
        </span>
    </div>
    <div class="grid_tool">
        <div class="displayflex">
            <a href="javascript:;" class="ld-button ld-button-primary" onclick="editCheckin()" title="{'EDIT'|@getFixedLabel}">{'EDIT'|@getFixedLabel}</a>
            <a href="javascript:;" class="ld-button" onclick="deleteCheckin()" title="{'LOGOUTS'|@getFixedLabel}">{'LOGOUTS'|@getFixedLabel}</a>
        </div>
    </div>
</div>
<div class="main_grid_box">
    <div class="grid-analysis-box">
        <div class="grid-analysis-header">
        </div>
        <div class="cont_wrap clear_float">
            {*editor:gyq_155 reason:钉钉考勤同步  2019/10/28 17:07 ID1000624 *}
            <table class="settingTable" width="100%" border="0" cellspacing="0" cellpadding="0">
                <tr>
                    <th colspan="2">{'CHECKINSETTINGDINGTALK1'|@getFixedLabel}</th>
                </tr>
                <tr id="setting_1" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
                    <td width="20%">{'CHECKINSETTINGDINGTALK2'|@getFixedLabel}</td>
                    <td width="80%">{$INTERFACETYPELABEL}</td>
                </tr>
            </table>
            <div {if $INTERFACETYPE eq 'dingtalk'}hidden{/if}>
                <table class="settingTable" width="100%" border="0" cellspacing="0" cellpadding="0">
                    <tr>
                        <th colspan="2">{'CHECKINSETTING'|@getFixedLabel}</th>
                    </tr>
                    <tr id="setting_3" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
                        <td width="20%">{'CHECKINSETTING_TITLE1'|@getFixedLabel}</td>
                        <td width="80%">{$CORPID}</td>
                    </tr>
                    <tr id="setting_4" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
                        <td>{'CHECKINSETTING_TITLE2'|@getFixedLabel}</td>
                        <td>{$SECTRET}</td>
                    </tr>
                    <tr id="setting_5" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
                        <td>{'CHECKINSETTING_TITLE3'|@getFixedLabel}</td>
                        <td>{$SECTRET_APPROVE}</td>
                    </tr>
                </table>
            </div>
        </div>
    </div>
</div>
</form>