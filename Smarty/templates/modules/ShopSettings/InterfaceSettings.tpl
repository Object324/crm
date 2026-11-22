
<script language="JAVASCRIPT" type="text/javascript" src="include/js/smoothscroll.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="include/js/menu.js?v={$GLOBALMINVERSION}"></script>
<form action="index.php" method="post" name="company" onsubmit="puyoungJS_DialogBox.block();">
<input type="hidden" name="module" value="ShopSettings"/>
<input type="hidden" name="action"/>
<div class="main_grid_top">
    <div class="grid-view-title lfloat overflow-hidden">
        <span class="grid-view-name dinline-block lfloat">
            小程序设置
        </span>
    </div>
    <div class="grid_tool">
        <div class="create-entity-toolbar lfloat prelative">
            <a href="javascript:;" class="ld-button ld-button-primary" onclick="InterfaceSettings_edit()" title="{'EDIT'|@getFixedLabel}">{'EDIT'|@getFixedLabel}</a>
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
                    <td width="20%">appId</td>
                    <td width="80%">{$APPID}</td>
                </tr>
                <tr id="setting_2" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
                    <td>appSecret</td>
                    <td>{$APPSECRET}</td>
                </tr>
            </table>
            <table class="settingTable" width="100%" border="0" cellspacing="0" cellpadding="0">
                <tr>
                    <th colspan="2">基础设置</th>
                </tr>
                <tr id="setting_3" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
                    <td width="20%">小程序名称</td>
                    <td width="80%">{$APPNAME}</td>
                </tr>
                <tr id="setting_4" style="display: none;" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
                    <td width="20%">客服电话</td>
                    <td width="80%">{$CUSTELNO}</td>
                </tr>
            </table>
            <table class="settingTable" width="100%" border="0" cellspacing="0" cellpadding="0">
                <tr>
                    <th colspan="2">分享设置</th>
                </tr>
                <tr id="setting_5" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
                    <td width="20%">分享描述</td>
                    <td width="80%">{$SHAREDESCRIPTION}</td>
                </tr>
                <tr id="setting_6" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
                    <td width="20%">分享图片</td>
                    <td width="80%">
                        {if $SHAREPICTURE neq ''}
                            <img style="width:120px;height:80px;" src="storage/ShopSettings/{$SHAREPICTURE}"  border="0">
                        {/if}
                    </td>
                </tr>
                <tr>
                    <th colspan="2">其他设置</th>
                </tr>
                <tr id="setting_5" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
                    <td width="20%">是否显示发票信息</td>
                    <td width="80%"><input name="displayinvoice" type="checkbox" onclick="InterfaceSettingsUpdate(this)" class="second_switch" {if $DISPLAYINVOICE!='no'}checked=""{/if}></td>
                </tr>
            </table>
        </div>
    </div>
</div>
</form>