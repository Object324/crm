<!--修改编码格式:统一编码：UTF-8-->
<script language="JAVASCRIPT" type="text/javascript" src="include/js/modules/Settings/wechat_miniprogram_setting.js?v={$GLOBALMINVERSION}"></script>
<form action="index.php" method="post" name="company" onsubmit="puyoungJS_DialogBox.block();">
<input type="hidden" name="module" value="Settings"/>
<input type="hidden" name="parenttab" value="Settings"/>
<input type="hidden" name="action"/>
<input type="hidden" name="blockidsetting" value="{$BLOCKIDSETTING}"/>
<input type="hidden" name="fieldidsetting" value="{$FIELDIDSETTING}"/>
<div class="main_grid_top">
    <div class="grid-view-title lfloat overflow-hidden">
        <span class="grid-view-name dinline-block lfloat">
            {'WECHATAPPLETSETTINGS'|@getFixedLabel}{if $HelpHtml.EnterpriseNumber neq '' }{$HelpHtml.EnterpriseNumber}{/if}<font>（{'WECHATAPPLETSETTINGSWEBURL'|@getFixedLabel}）</font>
        </span>
    </div>
    <div class="grid_tool">
        <div class="displayflex">
            <a href="javascript:;" class="ld-button ld-button-primary" onclick="wechat_miniprogram_setting.edit('')" title="{'EDIT'|@getFixedLabel}">{'EDIT'|@getFixedLabel}</a>
            <a href="javascript:;" class="ld-button" onclick="wechat_miniprogram_setting.logout()" title="{'LOGOUTS'|@getFixedLabel}">{'LOGOUTS'|@getFixedLabel}</a>
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
                    <th colspan="2">{'WECHATAPPLETSETTINGS'|@getFixedLabel}</th>
                </tr>
                <tr id="setting_1" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
                    <td width="20%">{'WECHATAPPLETSETTINGSTITLE01'|@getFixedLabel}</td>
                    <td width="80%">{$CONTENTONE}</td>
                </tr>
                <tr id="setting_2" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
                    <td>{'WECHATAPPLETSETTINGSTITLE02'|@getFixedLabel}</td>
                    <td>{$CONTENTTWO}</td>
                </tr>
                {*editor:gyq_20190114 0036121: 系统设置->小程序企业号设置界面：“CRM外网访问地址”下方增加一行显示“CRM微信小程序二维码下载”和“下载地址”，效果图：如附件1*}
                {*editor:gyq_20190115 0036164: （1.6登录）系统设置->小程序企业号设置界面：“下载地址”标签名称修改为“立即下载”*}
                {*editor:gyq_154 reason:小程序扫码自动绑定企业号  2019/10/19 17:53*}
                {*editor:gyq_20191025 reason:未配置参数，应隐藏动态内容*}
                {if $IMGURL neq ''}
                    <tr id="setting_3" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
                        <td>{'CRMWECHATSMALLPROGRAMTWODIMENSIONAL'|@getFixedLabel}{'DOWNLOAD'|@getFixedLabel}</td>
                        <td>
                            <img src="{$IMGURL}" alt="wechat_miniprogram_crm.jpg" class="padTB10" width="120">
                        </td>
                    </tr>
                {/if}
{*                //zxm  20220728 系统设置增加小程序消息提醒设置*}
                <tr>
                    <th colspan="2">{'Appletremindersettings'|@getFixedLabel}</th>
                </tr>
                <tr id="setting_4" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
                    <td width="20%">{'msgsend_type'|@getFixedLabel}</td>
                    <td width="80%">{$CONTENT['msgsend_typename']}</td>
                </tr>
                <tr {if $CONTENT['msgsend_type']=='msgsend_typeoem'}{else}style="display:none;"{/if} id="setting_5" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
                    <td width="20%">{'AppletAppID'|@getFixedLabel}</td>
                    <td width="80%">{$CONTENT['mini_appid']}</td>
                </tr>
                <tr {if $CONTENT['msgsend_type']=='msgsend_typeoem'}{else}style="display:none;"{/if} id="setting_6" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
                    <td width="20%">{'AppletSecret'|@getFixedLabel}</td>
                    <td width="80%">{$CONTENT['mini_secret']}</td>
                </tr>
                <tr {if $CONTENT['msgsend_type']=='msgsend_typeoem'}{else}style="display:none;"{/if} id="setting_7" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
                    <td width="20%">{'WechatofficialaccountAppId'|@getFixedLabel}</td>
                    <td width="80%">{$CONTENT['offiaccount_appid']}</td>
                </tr>
                <tr {if $CONTENT['msgsend_type']=='msgsend_typeoem'}{else}style="display:none;"{/if} id="setting_8" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
                    <td width="20%">{'WechatofficialaccountSecret'|@getFixedLabel}</td>
                    <td width="80%">{$CONTENT['offiaccount_secret']}</td>
                </tr>
            </table>
            <div class="listRloesHelp">
                <font color="red">{'TIP'|@getFixedLabel}：</font>
                <ul>
                    <li>1、{'WECHATAPPLETSETTINGSREMIND04'|@getFixedLabel}；</li>
                    <li>2、{'WECHATAPPLETSETTINGSREMIND05'|@getFixedLabel}；</li>
                    <li>3、{'CANBESCANNEDDIRECTLYWITHWECHAT'|@getFixedLabel}；</li>
{*                    //zxm  20220728 系统设置增加小程序消息提醒设置*}
                    <li {if $CONTENT['msgsend_type']=='msgsend_typeoem'}{else}style="display:none;"{/if}>4、{'WECHATAPPLETSETTINGSREMIND06'|@getFixedLabel}；</li>
                    <li {if $CONTENT['msgsend_type']=='msgsend_typeoem'}{else}style="display:none;"{/if}>5、{'WECHATAPPLETSETTINGSREMIND07'|@getFixedLabel}；</li>
                    <li {if $CONTENT['msgsend_type']=='msgsend_typeoem'}{else}style="display:none;"{/if}>6、{'WECHATAPPLETSETTINGSREMIND08'|@getFixedLabel}；</li>
                </ul>
            </div>
        </div>
    </div>
</div>
</form>