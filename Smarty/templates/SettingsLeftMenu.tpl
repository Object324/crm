
<style type="text/css">
    body {literal}{overflow: hidden !important;}{/literal}
</style>
<section id="container" class="wrapper ld-language-{$LANUGAGETYPE}">
    <!--左侧导航-->
    <aside id="pageleft" style="{if $frommodule=='ReportAnalysis'}display: none;{/if}width: 200px;">
        {include file="DropdownMenu.tpl"}
    </aside>
    <!--右侧内容-->
    <section class="main-content ld-bg-color" style="left: 200px;">
        <!--右侧头部-->
        <header id="pagehead" class="header">
            <div class="detail_crumbs">
                <ul class="detail_path"><li></li></ul>
            </div>
            <form name="UnifiedSearch" id="UnifiedSearch" method="get" action="index.php" style="margin:0px" onsubmit="return UnifiedSearchSubmit();">
                <ul class="function-btn">
                    <li class="backHomeLi">
                        <div id="BackHomeBtn" class="backHomeBtn">
                            <img src="{$IMAGEURL}themes/icon2024/left/light/left_nav_home_ico.png?v={$GLOBALMINVERSION}"/>
                            <span>{'BACKTOHOMEPAGE'|@getFixedLabel}</span>
                        </div>
                    </li>
                    {if $HelpUrl.SettingsHelp neq '' }
                        <li id="helperbar" class="helper">
                            <a href="javascript:;" style = 'height: 55px;' title="{'PRODUCTHELPMANUAL'|@getFixedLabel}" onclick="OpenNewWebTab('{$HelpUrl.SettingsHelp}','_blank')">
                                {if $helpmanualsetting eq 'all' || $helpmanualsetting eq 'icon'}
                                    <i class="ld-fonticon ld-fonticon-help"></i>
                                {/if}
                                {if $helpmanualsetting eq 'all' || $helpmanualsetting eq 'text'}
                                    <span>{'PRODUCTHELPMANUAL'|@getFixedLabel}</span>
                                {/if}
                            </a>
                        </li>
                    {/if}
                    {if $trade neq 'no_userinfo'}
                        <li id="oamenubar">
                            {*data-tip='{$LASTNAME}' data-direction="left" data-type="position"*}
                            <a class="dropdown-toggle tip-items" href="javascript:void(0)" referencemodule="Users" referencerecord="{$CURRENT_USER_ID}" onclick="ListReferenceLinkClick(ld(this),event)">
                                {if $userinfosetting eq 'all' || $userinfosetting eq 'icon'}
                                    <span class="user-icon" {$IMGSTR}></span>
                                {/if}
                                {if $userinfosetting eq 'all' || $userinfosetting eq 'text'}
                                    <span class="user-name">{$LASTNAME}</span>
                                {/if}
                                <span class="ld_icon_arrowdown" style="margin-top: -10px;"></span>
                            </a>
                            <ul id="oamenu" class="dropdown-menu-rt">
                                <li><a href="javascript:void(0)" referencemodule="Users" referencerecord="{$CURRENT_USER_ID}" onclick="ListReferenceLinkClick(ld(this),event)" title="{'EDITPERSONALACCOUNT'|@getFixedLabel}">{'EDITPERSONALACCOUNT'|@getFixedLabel}</a></li>

                                {*                            <li><a href="javascript:void(0)" referencemodule="Users" referencerecord="{$CURRENT_USER_ID}" onclick="YiweiTools.getInstance().OnOpenDevice();" title="连接设备">连接设备</a></li>*}
                                <li id="OnOpenDevice" style="display: none;"><a href="javascript:void(0)" referencemodule="Users" referencerecord="{$CURRENT_USER_ID}" onclick="YiweiTools.getInstance().InitWsAndRemind();" title="连接服务">连接设备</a></li>
                                <li id="OnCloseDevice" style="display: none;"><a href="javascript:void(0)" referencemodule="Users" referencerecord="{$CURRENT_USER_ID}" onclick="YiweiTools.getInstance().OnCloseDevice();" title="断开设备">断开设备</a></li>

                                {if $ISADMIN eq 'on' && 'upgradeexplain'|@array_key_exists:$GLOBAL_LOGININFO}
                                    {if $GLOBAL_LOGININFO.upgradeexplain.isshow eq 'yes'}
                                        <li><a href="{$GLOBAL_WELCOME.updateexplain}" target="_blank" title="{'VERSIONUPDATEINFO'|@getFixedLabel}">{'VERSIONUPDATEINFO'|@getFixedLabel}</a></li>
                                    {/if}
                                {elseif $ISADMIN eq 'on' && $GLOBAL_WELCOME.updateexplain neq 'no' && $GLOBAL_WELCOME.updateexplain neq ''}
                                    <li><a href="{$GLOBAL_WELCOME.updateexplain}" target="_blank" title="{'VERSIONUPDATEINFO'|@getFixedLabel}">{'VERSIONUPDATEINFO'|@getFixedLabel}</a></li>
                                {/if}
                                {*zxm 2020-1210 电子名片小程序需求*}
                                {if $isCardOpen=='yes'}
                                    <li><a href="javascript:void(0)" onclick="detailbutton_click(this,'Users','CARDQRCODE','{$CURRENT_USER_ID}');return false;" title="{'CARDQRCODEELECTRIC'|@getFixedLabel}">{'CARDQRCODEELECTRIC'|@getFixedLabel}</a></li>
                                {/if}
                                <li><a href="javascript:void(0)" onclick="detailbutton_click(this,'Users','WECHATQRCODE','{$CURRENT_USER_ID}');return false;" title="{'LBI_MINI_SETTINGS'|@getFixedLabel}">{'LBI_MINI_SETTINGS'|@getFixedLabel}</a></li>
                                {*若授权则显示服务小程序选项*}
                                {if $isServiceOpen=='yes'}
                                    <li><a href="javascript:void(0)" onclick="detailbutton_click(this,'Users','SELFSERVICEQRCODE','{$CURRENT_USER_ID}');return false;" title="{'SELFSERVICEQRCODE'|@getFixedLabel}">{'SELFSERVICEQRCODE'|@getFixedLabel}</a></li>
                                {/if}
                                {*若授权则显示商城小程序选项*}
                                {if $isShopOpen=='yes'}
                                    <li><a href="javascript:void(0)" onclick="detailbutton_click(this,'Users','SELFSHOPQRCODE','{$CURRENT_USER_ID}');return false;" title="{'SELFSHOPQRCODE'|@getFixedLabel}">{'SELFSHOPQRCODE'|@getFixedLabel}</a></li>
                                {/if}
                                {*若授权则显示订单小程序选项*}
                                {*                                230801 wym BUG0068433成员管理查看详情界面，和右上角个人头像下拉选项中，去掉“订单小程序”操作按钮（包括后台设置和注册系统去掉“订单小程序”设置菜单栏和接口授权，“商城”在注册系统增加了另外的接口授权）
                                                                {if $isOrderOpen=='yes'}
                                                                    <li><a href="javascript:void(0)" onclick="detailbutton_click(this,'Users','SELFORDERQRCODE','{$CURRENT_USER_ID}');return false;" title="{'SELFSERVICEQRCODEORDER'|@getFixedLabel}">{'SELFSERVICEQRCODEORDER'|@getFixedLabel}</a></li>
                                                                {/if}*}
                                {*菜单风格*}
                                {*{if $ISADMIN eq 'on'}*}
                                {*wym XUQIU1002004*}
{*                                <li><a href="javascript:void(0)" onclick="detailbutton_click(this,'Home','MenuStyle','1');return false;" title="{'menustyle'|@getFixedLabel}">{'menustyle'|@getFixedLabel}</a></li>*}
                                {*{/if}*}
                                {*顶部导航定制*}
{*                                <li><a href="javascript:void(0)" style="width: 135px" onclick="detailbutton_click(this,'Home','HeaderSetting','{$CURRENT_USER_ID}');return false;" title="{'HEADERSETTINGS'|@getFixedLabel}">{'HEADERSETTINGS'|@getFixedLabel}</a></li>*}
                                {*退出登录*}
                                <li><a href="javascript:;" onclick="loginout()" title="{'LOGOUT'|@getFixedLabel}">{'LOGOUT'|@getFixedLabel}</a></li>
                            </ul>
                        </li>
                    {/if}
                </ul>
            </form>
        </header>
        <!--右侧内容-->
        <section id="pagecontent" class="wrapper-panel" >
            <div id="SettingRightContent" name="SettingRightContent" class="wrapper-panel-inner" style="overflow: hidden auto;">
            </div>
        </section>
    </section>
</section>
