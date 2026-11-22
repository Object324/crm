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
        <span class="grid-view-name dinline-block lfloat" style="color:black">
            {'FeishuInterfaceSettings'|@getFixedLabel}
        </span>
        </div>
        <div class="grid_tool">
            <div class="displayflex">
                <a href="javascript:;" class="ld-button ld-button-primary" onclick="feishu_interface_setting_edit()" title="{'EDIT'|@getFixedLabel}">{'EDIT'|@getFixedLabel}</a>
                <a href="javascript:;" class="ld-button" onclick="feishu_interface_setting_logout()" title="{'LOGOUTS'|@getFixedLabel}">{'LOGOUTS'|@getFixedLabel}</a>
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
                        <th colspan="2">{'THEINTERFACEPARAMENTERS'|@getFixedLabel}
                    </tr>
                    <tr id="setting_1" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
                        <td style="color:black" width="20%">APP ID</td>
                        <td width="80%">{$APPID}</td>
                    </tr>
                    <tr id="setting_2" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
                        <td style="color:black">APP Secret</td>
                        <td>{$APPSECRET}</td>
                    </tr>
                    <tr id="setting_3" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
                        <td style="color:black">{'WECHATAPPLETSETTINGSTITLE02'|@getFixedLabel}</td>
                        <td>{$CRMURL}</td>
                    </tr>
                    <tr id="setting_4" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
                        <td style="color:black">{'PCAccessAddress'|@getFixedLabel}</td>
                        <td>{$PCACCESSADDRESS}</td>
                    </tr>
                    <tr id="setting_5" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
                        <td style="color:black">{'MobileAccessAddress'|@getFixedLabel}</td>
                        <td>{$MobileAccessAddress}</td>
                    </tr>
                </table>
                <div class="listRloesHelp">
                    <font color="red">{'TIP'|@getFixedLabel}:</font>
                    <ul>
                        <li style="color:black">{'ZHIYUANSETTINGSREMIND01'|@getFixedLabel}</li>
                    </ul>
                </div>
            </div>
        </div>
    </div>
</form>