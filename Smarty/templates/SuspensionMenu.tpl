{*wym XUQIU1002004 每个用户都可以皮肤定制*}
<nav id="pageleft_unfold" class="nav-menu" {if $global_hideleftmenu eq 'yes'} style='display:none;'{/if}>
    <div id="suspensionmenu" class="pageleft_fold {if $CURRENT_USER->getHaveSetProfile("Settings")=='yes'}isshowsettings{/if}">
        <div class="nav-menu-header">
            <div class="logo">
                <a href="javascript:;" class="logo-img">
                    <img class="logo-pic logo-pic-normal" tag="logo-pic" src="dataCache/test/logo/{$LOGO}?a={$RANDNUM}">
                    <img class="logo-pic logo-pic-mini" tag="logo-pic" src="dataCache/test/logo/{$SMALLLOGO}?a={$RANDNUM}">
                </a>
            </div>
            <div class="search-module-area" style="position:relative;">
                <div class="search-module-box">
                    <span class="leftmenu-fonticon" style="line-height: 34px;padding: 0 2px 0 8px;opacity: 0.5;color: #3B4859;">&#xe623;</span>
                    <span class="searchmodule-clear-btn"></span>
                    <input id="search-module-input" type="text" placeholder="{'SEARCHMODULE'|@getFixedLabel}" class="search-module-input" autocomplete="off" style="display: none;">
                </div>
                <div id="menusearchpopup" class="menusearchpopup" style="display: none;">

                </div>
            </div>
        </div>
        <div class="nav-menu-body">
            <div class="sub-menu">
                <div class="page-menu">
                    <ul>
                    </ul>
                </div>
            </div>
        </div>
        {if $CURRENT_USER->getHaveSetProfile("Settings")=='yes'}
            <div class="nav-menu-footer" {if $MENUSTYLEINFO.Menufont_color == '#FFFFFF'}{else}style="box-shadow:inset 0px 1px 0px 0px #DCDEE0;"{/if}>
                <div id="leftmenu_settingsup" class="nav-menu-footer-two" {if $MENUSTYLEINFO.Menufont_color == '#FFFFFF'}{else}style="box-shadow:inset 0px 1px 0px 0px #DCDEE0;"{/if} data-tip="{'SYSTEM_DESCRIPTION'|@getFixedLabel}" data-direction="top" data-type="position">
                    <div class="parenttab-item page-link seleted">
                        <a>
                            <div class="leftmenu-fonticon">&#xe620;</div>
                        </a>
                    </div>
                </div>
                <div class="dropdownmenu_ding nav-menu-footer-two" tag="" data-direction="right" data-type="position">
                    <div class="parenttab-item page-link seleted">
                        <a>
                            <div class="leftmenu-fonticon">&#xe621;</div>
                        </a>
                    </div>
                </div>
            </div>
        {else}
            <div class="nav-menu-footer" {if $MENUSTYLEINFO.Menufont_color == '#FFFFFF'}{else}style="box-shadow:inset 0px 1px 0px 0px #DCDEE0;"{/if}>
                <div class="dropdownmenu_ding" tag="" data-direction="right" data-type="position">
                    <div class="parenttab-item page-link seleted">
                        <a>
                            <div class="leftmenu-fonticon marR10">&#xe621;</div>
                            <span style="min-width: 90px;">{'CollapseNavigation'|@getFixedLabel}</span>
                        </a>
                    </div>
                </div>
            </div>
        {/if}
    </div>
</nav>
<!--子菜单-->
<div class="menu-thumbnail-box" style="left: 169px;display: none;{if $versionaccount eq 'baxter'}width:260px;{/if}">
    <div class="menu-thumbnail-content">
        <div class="menu-thumbnail-body" style="position: relative;">
            <!-- <ul class="menu-thumbnail-list">
             </ul>-->
        </div>
    </div>
</div>