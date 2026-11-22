{*//editor:gyq_144 reason:钉钉  2019/9/12 13:55*}
<script language="JAVASCRIPT" type="text/javascript" src="include/js/smoothscroll.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="include/js/menu.js?v={$GLOBALMINVERSION}"></script>
<form action="index.php" method="post" name="company" onsubmit="puyoungJS_DialogBox.block();">
<input type="hidden" name="module" value="ShopSettings"/>
<input type="hidden" name="action"/>
<div class="main_grid_top">
    <div class="grid-view-title lfloat overflow-hidden">
        <span class="grid-view-name dinline-block lfloat">
            {'MerchantNumberSetting'|@getFixedLabel}
        </span>
    </div>
    <div class="grid_tool">
        <div class="displayflex">
            <a href="javascript:;" class="ld-button ld-button-primary" onclick="MerchantNoSettings_edit()" title="{'EDIT'|@getFixedLabel}">{'EDIT'|@getFixedLabel}</a>
            <a href="javascript:;" class="ld-button" onclick="MerchantNoSettings_logout()" title="{'LOGOUTS'|@getFixedLabel}">{'LOGOUTS'|@getFixedLabel}</a>
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
                    <th colspan="2">{'application_setting'|@getFixedLabel}</th>
                </tr>
                <tr id="setting_1" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
                    <td width="20%">{'application_type'|@getFixedLabel}</td>
                    <td width="80%">
{*                        gxj 230711 BUG0068696 微信支付商户号设置，查看界面“应用类型”不要将下拉框显示出来，只显示文字*}
                        {if $APPTYPE=='miniprogram'}
                            {'WECHATAPPLETHEADER'|@getFixedLabel}
                        {/if}
                        {if $APPTYPE=='offiaccount'}
                            {'WeChatofficialaccount'|@getFixedLabel}
                        {/if}
                        {if $APPTYPE=='app'}
                            App
                        {/if}
                    </td>
                </tr>
                <tr id="setting_2" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
                    <td>APPID</td>
                    <td>{$APPID}</td>
                </tr>
            </table>
            <table class="settingTable" width="100%" border="0" cellspacing="0" cellpadding="0">
                <tr>
                    <th colspan="2">{'MerchantInterfaceParam'|@getFixedLabel}</th>
                </tr>
                <tr id="setting_3" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
                    <td width="20%">{'MerchantNum'|@getFixedLabel}</td>
                    <td width="80%">{$MERCHANTNUM}</td>
                </tr>
                <tr id="setting_4" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
                    <td>{'MerchantCertificateNum'|@getFixedLabel}</td>
                    <td>{$MERCHANTCERTIFICATENUM}</td>
                </tr>
            </table>
            <table class="settingTable" width="100%" border="0" cellspacing="0" cellpadding="5">
                <tr>
                    <th colspan="2">{'ApiInterfaceParam'|@getFixedLabel}</th>
                </tr>
                <tr id="setting_5" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
                    <td width="20%">{'APIKEY'|@getFixedLabel}</td>
                    <td width="80%">{$APIKEY}</td>
                </tr>
                <tr id="setting_6" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
                    <td>{'APIV3KEY'|@getFixedLabel}</td>
                    <td>{$APIV3KEY}</td>
                </tr>
            </table>
        </div>
    </div>
</div>
</form>