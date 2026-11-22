<section id="container" class="wrapper ld-language-{$LANUGAGETYPE}">
    <!--左侧导航-->
    <aside id="pageleft" {if $frommodule=='ReportAnalysis'}style="display: none;"{/if}>
        {if $MENUTYPE && $MENUTYPE == 2}
            {include file="DropdownMenu.tpl"}
        {else}
            {include file="SuspensionMenu.tpl"}
        {/if}
    </aside>
    <!--右侧内容-->
    <section class="main-content ld-bg-color">
        <!--右侧头部-->
        <!-- <a href="https://baidu.com"><ww-open-data type="userName" name="wxopendata"  openid="can"></ww-open-data></a>
        <ww-open-data type="userName" name="wxopendata" openid="SuJinWen"></ww-open-data>
        <ww-open-data type="userName" name="wxopendata" openid="xiaoguang"></ww-open-data>
        <ww-open-data type="userName" name="wxopendata" openid="xiaoguang"></ww-open-data>
        <ww-open-data type="userName" name="wxopendata" openid="PanLuLu"></ww-open-data>
        <ww-open-data type="userName" name="wxopendata" openid="JinNa"></ww-open-data> -->
        <header id="pagehead" class="header">
            <div class="detail_crumbs">
                <ul class="detail_path"><li></li></ul>
            </div>
            <form name="UnifiedSearch" id="UnifiedSearch" method="get" action="index.php" style="margin:0px" onsubmit="return UnifiedSearchSubmit();">
                <input type="hidden" name="action" value="UnifiedSearch" style="margin:0px">
                <input type="hidden" name="module" value="{$MODULE_NAME}" style="margin:0px">
                <input type="hidden" name="parenttab" value="{$CATEGORY}" style="margin:0px">
                <input type="hidden" name="search_onlyin" value="{$SEARCHMODULE}" style="margin:0px">
                <input type="hidden" name="quickcreate_onlyin" value="{$QUICKCREATEMODULE}" style="margin:0px">
                <ul class="function-btn">
                    {if $versionaccount eq 'anfubao'}
                    <li class="page-topsec-box">
                        <div class="page-topsec-area">
                            <div class="page-topsec-inputbox">
                                <a href="javascript:;" class="topsec-btn" title="加密" onclick="DecryptColumn.getInstance().EncryptString(this);"></a>
                                <input id="encryptstring" type="text" placeholder="请输入待加密字符串" class="ui-autocomplete-input width120">
                            </div>
                        </div>
                    </li>
                    {/if}
                    {*@edit:liushuai,2021-05-26,reason:【ID1001533】呼叫中心接口设置，增加接口类型“灵当语音盒”(设备连接成功才显示拨号功能)*}
                    {if $isOpenYiwei eq 'yes'}
                        <li class="page-topsec-box" style="display: none;">
                            <div class="page-topsec-area">
                                <div class="page-topsec-inputbox">
                                    <!-- <a href="javascript:;" class="topset-btn" title="挂断" onclick="YiweiTools.getInstance().OnHungUp()"></a>
                                    <a href="javascript:;" class="topset-btn" title="接听" onclick="YiweiTools.getInstance().OnAnswer()"></a> -->
                                    <a href="javascript:;" class="topcall-btn" title="拨号" onclick="YiweiTools.getInstance().HeaderOnDailout()"></a>
                                    <span class="call-clear-btn"></span>
                                    <input id="callnumber_yiwei" type="text" placeholder="拨打号码" class="ui-autocomplete-input">
                                </div>
                            </div>
                        </li>
                    {/if}
                    {*  只有 all 和 hide 两个情况  *}
                    {if $quickfindsetting eq 'all'}
                        <li class="page-topsec-box">
                            <div class="page-topsec-area">
                                <div class="page-topsec-inputbox">
                                    <a href="javascript:;" class="topset-btn" title="{'SETTINGS'|@getFixedLabel}" onclick="UnifiedSearch_SelectModuleForm(this);"></a>
                                    <a href="javascript:;" class="topsec-btn" title="{'QUICKFIND'|@getFixedLabel}" onclick="UnifiedSearchClick(this);"></a>
                                    <span class="search-clear-btn"></span>
                                    <input id="query_string" type="text" onkeyup="searchSubmit(event,'quickSearch');" placeholder="{'QUICKFIND'|@getFixedLabel}" class="ui-autocomplete-input{if $versionaccount eq 'anfubao'} width120{/if}">
                                </div>
                            </div>
                        </li>
                    {/if}
                    {*  all\icon\text\hide  *}
                    {if $quickcreatesetting neq 'hide' }
                        <li id="quickcreatebar" class="quickcreate">
                            <a href="javascript:;" title="{'Quickly_create'|@getFixedLabel}">
                                {if $quickcreatesetting eq 'all'}
                                    <i class="ld-fonticon ld-fonticon-add"></i>
                                    <span>{'Quickly_create'|@getFixedLabel}</span>
                                {elseif $quickcreatesetting eq 'text'}
                                    <span>{'Quickly_create'|@getFixedLabel}</span>
                                {elseif $quickcreatesetting eq 'icon'}
                                    <i class="ld-fonticon ld-fonticon-add"></i>
                                {/if}
                            </a>
                            <div id="quickcreate" class="quickly" style="max-height: none !important;overflow: hidden;">
                                <div class="quickly-title">
                                    {'Quickly_create'|@getFixedLabel}
                                    <span class="ld-icon-set quicklyset-btn" title="{'SETTINGS'|@getFixedLabel}" style="{if $QUICKMODULE|@count > 24}display: none;{/if}">
                                    <a href="javascript:;" class="topset-btn" title="{'SETTINGS'|@getFixedLabel}" ></a>
                                </span>
                                </div>
                                <div class="page-topsec-area quickcreate-search-area" style="{if $QUICKMODULE|@count <= 24}display: none;{/if}">
                                    <div class="page-topsec-inputbox">
                                        <a href="javascript:;" class="topset-btn" id="quickcreate-setting-btn" title="{'SETTINGS'|@getFixedLabel}" style="margin-left: 0;"></a>
                                        <a href="javascript:;" class="topsec-btn" title="{'SEARCH'|@getFixedLabel}" onclick="quickCreateSearch();" style="margin-left: 0;"></a>
                                        <span class="search-clear-btn"></span>
                                        <input id="query_string" type="text" onkeyup="quickCreateSearch_Key(event);" placeholder="{'SEARCHMODULE'|@getFixedLabel}" class="ui-autocomplete-input" style="width: 200px;">
                                    </div>
                                </div>
                                <div class="list crm-clearfix quickcreate_list" name="quickcreate_list">
                                    {*@edit:liushuai,2020-12-29,reason:【ID1001225】快速创建增加设置按钮，可设置快速创建显示的模块*}
                                    {include file="PopUnifiedQuickcreateModulesEntries.tpl"}
                                </div>
                            </div>
                        </li>
                    {/if}
                    <li id="approvebar" class="approve">
                        <a href="javascript:;" name="approve_href" title="{'APPROVAL'|@getFixedLabel}" data-tabtype='{$TABTYPE}' onclick="ApproveCenterClickDrawer('flag',event);">
                            {if $approvalremindsetting eq 'all' || $approvalremindsetting eq 'icon'}
                                <i class="ld-fonticon ld-fonticon-approve"></i>
                                {if $APPROVECOUNT gt 0}
                                    <b></b>
                                {/if}
                            {/if}
                            {if $approvalremindsetting eq 'all'}
                                <span>{'APPROVAL'|@getFixedLabel}</span>
                            {elseif $approvalremindsetting eq 'text'}
                                <span>{'APPROVAL'|@getFixedLabel}</span>
                            {/if}
                            <span class="redFont" id="headerapprovecount">{if $APPROVECOUNT gt 0}({$APPROVECOUNT}){/if}</span>
                        </a>
                        {if $APPROVECOUNT gt 0}
                            <div id="approveHeader" class="approveHeader">
                                <div class="approveHeaderCon">
                                </div>
                            </div>
                        {/if}
                    </li>
                    <!-- wyt 220714 XUQIU1000448 【消息处显示未读消息数量】 -->
                    <li id="noticebar" class="notice">
                        <a href="javascript:;" name="news_href" title="{'News'|@getFixedLabel}" onclick="NewsClick(ld(this),event);">
                            {if $approvalremindsetting eq 'all' || $approvalremindsetting eq 'icon'}
                                <i class="ld-fonticon ld-fonticon-news"></i>
                                {if count($REMINDSINFO) gt 0}
                                    <b></b>
                                {/if}
                            {/if}
                            {if $approvalremindsetting eq 'all'}
                                <span>{'News'|@getFixedLabel}</span>
                            {elseif $approvalremindsetting eq 'text'}
                                <span>{'News'|@getFixedLabel}</span>
                            {/if}
                            <!--  <span class="redFont remind_notread_count hidden">{$REMINDSCOUNT}</span> -->
                            <span class="redFont remind_notread_count" id="headerremindscount">{*{if $REMINDSCOUNT gt 0}({$REMINDSCOUNT}){/if}*}</span>
                        </a>
                        <div id="noticeHeader" class="noticeHeader" style="display:none;">
                            {if count($REMINDSINFO) gt 0}
                                <div class="noticeHeaderContent">
                                    {include file='RemindContents.tpl'}
                                </div>
                            {/if}
                        </div>
                    </li>
                    {if $HelpUrl.AllHelp neq '' && $helpmanualsetting neq 'hide'}
                        <li id="helperbar" class="helper">
                            <a href="javascript:;" style = 'height: 55px;' title="{'PRODUCTHELPMANUAL'|@getFixedLabel}" onclick="OpenNewWebTab('{$HelpUrl.AllHelp}','_blank')">
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
                                <li><a href="javascript:void(0)" onclick="detailbutton_click(this,'Home','MenuStyle','1');return false;" title="{'menustyle'|@getFixedLabel}">{'menustyle'|@getFixedLabel}</a></li>
                                {*{/if}*}
                                {*顶部导航定制*}
                                <li><a href="javascript:void(0)" style="width: 135px" onclick="detailbutton_click(this,'Home','HeaderSetting','{$CURRENT_USER_ID}');return false;" title="{'HEADERSETTINGS'|@getFixedLabel}">{'HEADERSETTINGS'|@getFixedLabel}</a></li>
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
            <div id="pagecontent1" class="wrapper-panel-inner">
            </div>
        </section>
    </section>
</section>