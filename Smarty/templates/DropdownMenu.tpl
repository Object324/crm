{if isset($module) && $module == 'Settings'}
    <style>
        .nav-menu{
            background: #fff !important;
        }
        .ding, .logo {
            background: #fff !important;
        }
        .page-link a, .el-menu-item.page-link span {
            color: #3B4859 !important;
        }
        .page-link.selected a, .page-link:hover a {
            color: #3B7CFF !important;
        }
        .page-link:hover {
            background-color: #EFF4FF !important;
        }
        .page-link.selected{
            background-color: #EFF4FF !important;
        }
        .nochildren.page-link.selected{
            background-color: unset !important;
        }
        #dropdownmenu ul.parenttab-items li.parenttab-li li:hover .parenttabrel-item a {
            padding-right: 0px !important;
        }
        .ld-bg-color{
            background:{$MENUSTYLEINFO.Background_color} !important;
        }
        .user-left-td{
            box-shadow: 10px 0px 0px 0px {$MENUSTYLEINFO.Background_color} !important;
        }
        .leftmenu-fonticon{
            color: #3B4859 !important;
        }
    </style>
{/if}
{if $MENUSTYLEINFO.Menufont_color == '#FFFFFF' && $module != 'Settings'}
    <style>
        input#search-module-input::-webkit-input-placeholder { /* Chrome, Opera, Safari */
            color: #FFF;
        }

        input#search-module-input:-moz-placeholder { /* Firefox 18- */
            color: #FFF;
            opacity: 1; /* 修复Firefox 18- 的不透明度问题 */
        }

        input#search-module-input::-moz-placeholder { /* Firefox 19+ */
            color: #FFF;
            opacity: 1; /* 修复Firefox 19+ 的不透明度问题 */
        }

        input#search-module-input:-ms-input-placeholder { /* Internet Explorer 10-11 */
            color: #FFF;
        }
    </style>
{/if}

<nav id="pageleft_unfold" class="nav-menu" style="{if $global_hideleftmenu eq 'yes'}display:none;{/if}background:{$MENUSTYLEINFO.Menuback_color};">
    <div id="dropdownmenu" class="pageleft_fold {if $CURRENT_USER->getHaveSetProfile("Settings")=='yes'}isshowsettings{/if}">
        <div class="nav-menu-header">
            {if isset($module) && $module == 'Settings'}
            {else}
                <div class="logo" style="padding: 15px 0;background:{$MENUSTYLEINFO.Menuback_color}">
                    <a href="javascript:;" class="logo-img" style="display: flex;align-items: center;height: 36px;text-align: center;">
                        <img class="logo-pic logo-pic-normal" style="margin: 0 auto;" tag="logo-pic" src="dataCache/test/logo/{$LOGO}?a={$RANDNUM}">
                        <img class="logo-pic logo-pic-mini" style="margin: 0 auto;" tag="logo-pic" src="dataCache/test/logo/{$SMALLLOGO}?a={$RANDNUM}">
                    </a>
                </div>
            {/if}
            <div class="search-module-area" style="position:relative;{if isset($module) && $module == 'Settings'}margin: 15px 10px 0px;{/if}{if $MENUSTYLEINFO.Menuback_color != '#FFFFFF' && $module != 'Settings'}background-color:rgba(255,255,255,0.16);{/if}">
                <div class="search-module-box">
                    <span class="leftmenu-fonticon" style="line-height: 34px;padding: 0 2px 0 8px;opacity: 0.5;color: {$MENUSTYLEINFO.Menufont_color};">&#xe623;</span>
                    <span class="searchmodule-clear-btn"></span>
                    <input id="search-module-input" type="text" {if isset($module) && $module == 'Settings'}placeholder="{'FINDSETTINGS'|@getFixedLabel}"{else}placeholder="{'SEARCHMODULE'|@getFixedLabel}"{/if} class="search-module-input" autocomplete="off" style="display: none;{if $module != 'Settings'}color:{$MENUSTYLEINFO.Menufont_color};{/if}">
                </div>
                <div id="menusearchpopup" class="menusearchpopup" style="display: none;">

                </div>
            </div>
        </div>
        <div class="nav-menu-body" {if isset($module) && $module == 'Settings'}style="height: calc(100% - 47px);"{/if}>
            <div class="sub-menu" style="height: 100%;width:100%;">
                <ul class="parenttab-items">

                </ul>
            </div>
        </div>
        {if isset($module) && $module == 'Settings'}{else}
            {if $CURRENT_USER->getHaveSetProfile("Settings")=='yes'}
                <div class="nav-menu-footer" {if $MENUSTYLEINFO.Menufont_color == '#FFFFFF'}{else}style="box-shadow:inset 0px 1px 0px 0px #DCDEE0;"{/if}>
                    <div id="leftmenu_settingsup" class="nav-menu-footer-two" {if $MENUSTYLEINFO.Menufont_color == '#FFFFFF'}{else}style="box-shadow:inset -1px 0px 0px 0px #DCDEE0;"{/if} data-tip="{'SYSTEM_DESCRIPTION'|@getFixedLabel}" data-direction="top" data-type="position">
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
        {/if}
    </div>
</nav>
