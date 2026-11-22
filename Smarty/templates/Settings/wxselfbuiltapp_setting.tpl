{*<script language="JAVASCRIPT" type="text/javascript" src="include/js/smoothscroll.js"></script>*}
{*<script language="JavaScript" type="text/javascript" src="include/js/menu.js"></script>*}
<form action="index.php" method="post" name="company" onsubmit="puyoungJS_DialogBox.block();">
    <input type="hidden" name="module" value="Settings"/>
    <input type="hidden" name="parenttab" value="Settings"/>
    <input type="hidden" name="action"/>
    <input type="hidden" name="blockidsetting" value="{$BLOCKIDSETTING}"/>
    <input type="hidden" name="fieldidsetting" value="{$FIELDIDSETTING}"/>
    <div class="main_grid_top">
        <div class="grid-view-title lfloat overflow-hidden">
        <span class="grid-view-name dinline-block lfloat">
            {'wxselfbuiltapp_setting'|@getFixedLabel}
        </span>
        </div>
        <div class="grid_tool">
            <div class="displayflex">
                <a href="javascript:;" class="ld-button ld-button-primary" onclick="wxselfbuiltapp_setting_edit()" title="{'EDIT'|@getFixedLabel}">{'EDIT'|@getFixedLabel}</a>
                <a href="javascript:;" class="ld-button" onclick="wxselfbuiltapp_setting_uninstall()" title="{'UNINSTALL'|@getFixedLabel}">{'UNINSTALL'|@getFixedLabel}</a>
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
                        <th colspan="2">{'THEINTERFACEPARAMENTERS'|@getFixedLabel}</th>
                    </tr>
                    <tr id="setting_1" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
                        <td width="20%" class="cellLabel"> {'WECHATAPPLETSETTINGSTITLE02'|@getFixedLabel} </td>
                        <td width="80%" class="borderBR">{$CORP_LINK}</td>
                    </tr>
                    <tr id="setting_2" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
                        <td>CorpId</td>
                        <td>{$CORPID}</td>
                    </tr>
                    <tr id="setting_3" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
                        <td>AgentId</td>
                        <td>{$AGENTID}</td>
                    </tr>
                    <tr id="setting_4" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
                        <td>Secret</td>
                        <td>{$SECRET}</td>
                    </tr>
                </table>
                <div class="listRloesHelp">
                    <font color="red">{'TIP'|@getFixedLabel}：</font>
                    <ul>
                        <li>{'WECHATAPPLETSETTINGSREMIND05'|@getFixedLabel}/</li>
{*                        <li>2、请将"{'WECHATAPPLETSETTINGSTITLE02'|@getFixedLabel}/qywxapp/wechatselfbuilt.html" 参数输入到企业微信后台->自建应用->应用主页</li>*}
                    </ul>
                </div>
            </div>
        </div>
    </div>
</form>