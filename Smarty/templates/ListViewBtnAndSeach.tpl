{if $MODULE neq 'Calendar'}
    <input type="hidden" id="viewname" name="viewname" value="{$VIEWID}"/>
{/if}
<div class="ld-flex-between gwidth100 ld-flex-wrap" id="ListViewBtnAndSeach" style="position: relative;z-index: 998;padding: 0 15px 12px;{if $MODULE eq 'Reminds' && $listviewtopuitype neq 3}padding-top: 14px;{/if}">
    <div class="ld-flex-start ld-flex-wrap">
        <!--列表按钮-->
        {if $listviewtopuitype neq 1}
            {include file='ListViewNavBtn.tpl'}
        {/if}
        <!--基本查找-->
        {if $listviewtopuitype neq 3}
            <div class="marR10 ld-flex-start ld-flex-wrap" id="basicSearchNewDiv">
                {*基本查找组件 zxm 20221212*}
                {include file='ListViewBasicSearch.tpl'}
            </div>
        {/if}
        <!--高级查找-->
        <div class="Category Category_New" style="width:auto;">
            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                <tr>
                    <td valign="middle" class="C">
                        <ul>
                            {if $HIGBTNSTATUS neq 'no'}
                                <li id="categoryAdvsear" tag="firstnode"><div style="padding: 0 6px;"><a href="javascript:void(0);" onclick="HighersearchPopup()"><b class="icon-categorybtn categoryAdvsear-search tip-items-list" data-tip="{'CUSTOMIZESEARCH'|@getFixedLabel}" data-direction="top" data-type="position"></b></a></div></li>
                            {/if}
                            {*//@edit:ljj,2023-08-11,reason:XUQIU1001663 单据序时簿列表界面，“操作按钮设置”区块，高级查找下方增加“平铺查找”开启、关闭参数*}
                            {if $TILEDBTNSTATUS eq 'yes'}
                                <li id="categoryTiledSearch" tag="firstnode"><div style="padding: 0 6px;"><a href="javascript:void(0);" onclick="TiledSearchShow()"><b class="icon-categorybtn categoryAdvsear-search2 tip-items-list" data-tip="{'TILEDSEARCH'|@getFixedLabel}" data-direction="top" data-type="position"></b></a></div></li>
                            {/if}
                            {*wym BUG0076164 客户管理--将标签查找也纳入可设置隐藏*}
                            {if $MODULE neq 'Reminds' && $MODULE neq 'Approve' && $TAGBTNSTATUS eq 'yes'}
                                <li id="module_tag_list_search" tag="firstnode" style="display:none;"><div style="padding: 0 6px;"><a href="javascript:void(0);" onclick="ListTagView(event,'{$MODULE}')"><b class="icon-categorybtn categoryAdvsear-search3 tip-items-list"  data-tip="{'Tag'|@getFixedLabel}{'SEARCH'|@getFixedLabel}" data-direction="top" data-type="position"></b></a></div></li>
                            {/if}
                        </ul>
                    </td>
                </tr>
            </table>
        </div>
    </div>
    <div class="ld-flex-end ld-flex-wrap padR10">
        {*zxm 2020-1029 增加公众号绑定设置*}
        {if $MODULE eq 'Articles' && $IS_ADMIN  }
            <a href="javascript:;" onclick="weixinSetAppid();return false;" title="关联公众号设置">关联公众号设置</a>
        {/if}
    </div>
    <div class="ld-flex-end ld-flex-wrap" style="margin-left: auto;">
        {*报表按钮*}
        <div class="listviewsecond list-item" style="padding: 0;display: flex;justify-content: flex-start;align-items: center;margin-right: 10px;">
            <!-- wyt 221220 XUQIU1000540 销售机会增加“列表视图”和“看板视图”图标按钮（熊少波）-->
            {if ($MODULE eq 'Potentials' || $MODULE eq 'Project') && $SHOWKANBAN eq 'yes'}
                <div onclick="getKanbanView('{$MODULE}','kanban')">
                    <!-- wym 20240109 BUG20240109-34 销售机会，看板视图的图标错误-->
                    <span class=""><i class="list-item-btn view-btn tip-items-list" data-tip="{'KANBANVIEW'|@getFixedLabel}" data-direction="top" data-type="position"></i></span>
                </div>
            {/if}
            {*BUG0065603测试*}
            <input type="hidden" id="SHOWKANBAN" value="{$SHOWKANBANVALUE}">
            {if $VERSION_ACCOUNT eq 'dongmao'}
            {if $MODULE eq 'Accounts' && $MAPBTNSTATUS eq 'yes'}
                <div style="display: none;" id="tip_list"  onclick="changeListMap(this,'{$MODULE}','list',0,CrmPopup.getPopupObj('last'))">
                    <span class="cur"><i class="list-item-btn list-btn tip-items-list" data-tip="{'list'|@getFixedLabel}" data-direction="top" data-type="position"></i></span>
                </div>
                <div id="tip_map"  onclick="changeListMap(this,'{$MODULE}','map',0,CrmPopup.getPopupObj('last'))">
                    <span class=""><i class="list-item-btn map-btn tip-items-list" data-tip="{'MAP'|@getFixedLabel}" data-direction="top" data-type="position"></i></span>
                </div>
            {/if}
            {else}
            {if ($MODULE eq 'Accounts' || $MODULE eq 'ServiceCharge')&& $MAPBTNSTATUS eq 'yes'}
                <div style="display: none;" id="tip_list"  onclick="changeListMap(this,'{$MODULE}','list',0,CrmPopup.getPopupObj('last'))">
                    <span class="cur"><i class="list-item-btn list-btn tip-items-list" data-tip="{'list'|@getFixedLabel}" data-direction="top" data-type="position"></i></span>
                </div>
                <div id="tip_map" onclick="changeListMap(this,'{$MODULE}','map',0,CrmPopup.getPopupObj('last'))">
                    <span class=""><i class="list-item-btn map-btn tip-items-list" data-tip="{'MAP'|@getFixedLabel}" data-direction="top" data-type="position"></i></span>
                </div>
            {/if}
            {if $isShowMap eq 'yes' }
                <script language="JavaScript" type="text/javascript" src="include/js/ListViewMap.js"></script>
                <script>var listViewMap = new ListViewMap;</script>
                <div id="tip_list" onclick="ListViewMap.getInstance().changeListMap(this,'{$MODULE}','list',0,CrmPopup.getPopupObj('last'))">
                    <span class="cur"><i class="list-item-btn list-btn tip-items-list" data-tip="{'list'|@getFixedLabel}" data-direction="top" data-type="position"></i></span>
                </div>
                <div id="tip_map" onclick="ListViewMap.getInstance().changeListMap(this,'{$MODULE}','map',0,CrmPopup.getPopupObj('last'))">
                    <span class=""><i class="list-item-btn map-btn tip-items-list" data-tip="{'MAP'|@getFixedLabel}" data-direction="top" data-type="position"></i></span>
                </div>
            {/if}
                {*				230711 wym 客户“圣拉维”，自定义表单01切换日历视图*}
            {if $VERSION_ACCOUNT eq 'shenglawei' && $MODULE eq 'CustomForm01' }
                {*                    230731 wym BUG0070340 圣拉维-档期预约-刚进入系统时两个图标都会显示*}
                <div {if $customform01_type eq 'list' || $customform01_type eq ''}style="display: none;"{/if} id="tip_list_calendar" tag='list' onclick="changeListCalendar(this,'{$MODULE}',0)">
                    <span class="cur"><i class="list-item-btn list-btn tip-items-list" data-tip="{'list'|@getFixedLabel}"></i></span>
                </div>
                <div {if $customform01_type eq 'calendar'}style="display: none;"{/if} id="tip_calendar" tag='calendar' onclick="changeListCalendar(this,'{$MODULE}',0)">
                    <span class=""><i class="list-item-btn calendar-btn tip-items-list" class="tip-items-list"></i></span>
                </div>
            {/if}
            {/if}
            {*zxm 20221216 序时簿列表界面增加图表下拉框  DashboardPermitt写死的yes 并非从系统设置参数取值*}
            {*wym BUG0076167 客户管理--地图和漏斗加入设置，可设置显示或隐藏*}
            {if ($DashboardPermitt eq 'yes'||$MODULEADVANCESTAGESTATUS eq 'yes') && $CHARTBTNSTATUS neq 'no' }
                <div style="position: relative;" class="ld-listview-chartlist" width="48px">{*gxj 230710 BUG0069243 【界面优化】客户和销售机会列表页面的鼠标悬浮后，内容提示由【进度漏斗】修改为【统计报表】*}
                    <span {if $MODULEADVANCESTAGESTATUS eq 'yes'} onclick="AdvanceStageHighcharts('{$MODULE}')"{/if}><i class="list-item-btn funnel-btn tip-items-list" data-tip="{'SocialPromotionReport'|@getFixedLabel}" data-direction="top" data-type="position"></i></span>
                    {if $DashboardPermitt eq 'yes'}
                        {include file="ListChart_1020.tpl"}
                    {/if}
                </div>
            {/if}
        </div>
        {if $CUSTOM_LINKS && $CUSTOM_LINKS.LISTVIEWBASIC}
            {foreach item=CUSTOMLINK from=$CUSTOM_LINKS.LISTVIEWBASIC}
                {assign var="customlink_href" value=$CUSTOMLINK->linkurl}
                {assign var="customlink_label" value=$CUSTOMLINK->linklabel}
                <input class="edit" type="button" value="{$customlink_label}" onclick="{$customlink_href}" />
            {/foreach}
        {/if}
        {if $CUSTOM_LINKS && !empty($CUSTOM_LINKS.LISTVIEW)}
            &nbsp;
            <a href="javascript:;" onmouseover="fnvshobj(this,'vtlib_customLinksLay');" onclick="fnvshobj(this,'vtlib_customLinksLay');">
                <b>{$APP.LBL_MORE} {$APP.LBL_ACTIONS} <img src="{'arrow_down.gif'|@lingdang_imageurl:$THEME}" border="0"></b>
            </a>
            <div style="display: none; left: 193px; top: 106px;width:155px; position:absolute;" id="vtlib_customLinksLay"
                 onmouseout="fninvshnew('vtlib_customLinksLay')" onmouseover="fnvshNrm('vtlib_customLinksLay')">
                <table bgcolor="#ffffff" border="0" cellpadding="0" cellspacing="0" width="100%">
                    <tr>
                        <td style="border-bottom: 1px solid rgb(204, 204, 204); padding: 5px;">
                            <b>{$APP.LBL_MORE} {$APP.LBL_ACTIONS} &#187;</b>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            {foreach item=CUSTOMLINK from=$CUSTOM_LINKS.LISTVIEW}
                                {assign var="customlink_href" value=$CUSTOMLINK->linkurl}
                                {assign var="customlink_label" value=$CUSTOMLINK->linklabel}
                                <a href="{$customlink_href}" class="drop_down">{$customlink_label}</a>
                            {/foreach}
                        </td>
                    </tr>
                </table>
            </div>
        {/if}
        {if $MODULE eq 'Reminds'}
        <div class="listview_toprightbox">
            <div class="E_pop_tit_Second_Right ld-listview-btnscontent">
                {foreach key=btn_key item=btn_item from=$LISTBUTTON}
                {if $btn_item.permit eq 'yes'}
                {if $btn_key == 'More'}
                <div class="ld-button-more tip-items-list" data-tip="{'MORE'|@getFixedLabel}" data-direction="top" data-type="position" tag="{$btn_key}" onclick="listviewbutton_click(this,'{$MODULE}','{$btn_item.btnkey}',event);return false;"><i class="ld-button-icon-more"></i>
                    {else}
                    {if $btn_item.list neq ''}
                    <div class="ld-button ld-button-down" tag="{$btn_key}" onclick="listviewbutton_click(this,'{$MODULE}','{$btn_item.btnkey}',event);return false;">{$btn_item.label}<b class="ld-button-arrow-down"></b>
                        {else}
                        <div class="ld-button" tag="{$btn_key}" onclick="listviewbutton_click(this,'{$MODULE}','{$btn_item.btnkey}',event);return false;">{$btn_item.label}
                            {/if}
                            {/if}
                            <b name="{$btn_item.btnkey}" class="ListView_ButtonNum">{if $btn_item.num neq "" && $btn_item.num >0}[{$btn_item.num}]{/if}</b>
                            {if $btn_item.list neq ''}
                            {if $btn_key eq 'Create' && $MODULE eq 'Accounts'}
                            {if ($btn_item.list.public_ordinary neq '' && $btn_item.list.btnkey neq '') || ($btn_item.list.public_ordinary neq '' && $btn_item.list.public_allocated neq '') || ($btn_item.list.btnkey neq '' && $btn_item.list.public_allocated neq '') }
                            <ol class="D_more_menua" style="z-index:902;">
                                {else}
                                <ol class="D_more_menua" style="display: none;z-index:902;">
                                    {/if}
                                    {else}
                                    <ol class="D_more_menua" style="overflow-x: hidden;z-index:902;">
                                        {/if}
                                        {foreach key=more_key item=more_item from=$btn_item.list}
                                            {if $more_item.permit eq 'yes'}
                                                <li tag="{$more_key}" {if $more_key eq 'ContinuousDialing'}style="display: none"{/if} onclick="listviewbutton_click(this,'{$MODULE}','{$more_key}',event);return false;">
                                                    <a title="{$more_item.label}">{$more_item.label}</a>
                                                </li>
                                            {/if}
                                        {/foreach}
                                    </ol>
                                    {/if}
                        </div>
                        {/if}
                    {/foreach}
                </div>
            </div>
        {/if}
        <!--设置-->
        {if $MODULE|@isPermitted:"CustomView" eq 'yes' && !$LINKMODULECUSTOM}
            <i class="ld-listview-setting-icon tip-items-list" id="listviewrightsetting_icon" data-tip="{'SETTINGS'|@getFixedLabel}" data-direction="top" data-type="position"></i>
        {/if}
    </div>
    <div class="ld_listviewabtnrely" id="ld_listviewabtnrely" style="{if $MODULE eq 'Reminds' && $listviewtopuitype neq 3}padding-top: 14px;{/if}">
        <div class="ld_listviewchosenum">{'choose'|@getFixedLabel} <span class="chosenum">0</span> {'numbill'|@getFixedLabel}</div>
        <div class="ld_listviewchooseall" {if isset($LISTVIEWPAGECOUNT) && $LISTVIEWPAGECOUNT > 1}{else}style="display: none;"{/if}>
            <span id="selectAllRec" class="selectall" style="line-height: 32px;" onClick="toggleSelectAll_Records('{$MODULE}',true,'selected_id')">{'SELECTALL'|@getFixedLabel}&ensp; <span id="count"> {$NUMOFROWS}</span>&ensp; {'RECORDNUMS'|@getFixedLabel}</span>
            <span id="deSelectAllRec" class="selectall" style="line-height: 32px;display:none;" onClick="toggleSelectAll_Records('{$MODULE}',false,'selected_id')">{'DESELECTALL'|@getFixedLabel}</span>
        </div>
        <div class="ld_listviewabtnrelylist">
            <ul>
                {if isset($LISTBUTTONRELY)}
                    {foreach key=btn_key item=btn_item from=$LISTBUTTONRELY}
                        {if $btn_item.permit eq 'yes'}
                            {if $btn_key == 'More' || ($btn_item.list && $btn_item.list|@count > 0)}
                                {if $btn_key == 'More'}
                                    <li class="listviewbtnrely"><img class="relybtnicon" src="{$IMAGEURL}themes/icon/button/more.png?v={$GLOBALMINVERSION}" /><span>{'MORE'|@getFixedLabel}</span>
                                {else}
                                    <li class="listviewbtnrely"><img class="relybtnicon" src="themes/icon/button/{$btn_item.iconname}" /><span>{$btn_item.label}</span>
                                {/if}
                                    {if $btn_item.list|@count > 0}
                                        <ol class="D_more_menua" style="overflow-x: hidden;z-index:902;display: none;">
                                            {foreach key=more_key item=more_item from=$btn_item.list}
                                                {if $more_item.permit eq 'yes'}
                                                    {* 有btnkey就取btnkey *}
                                                    {if $more_item.btnkey && $more_item.btnkey neq ''}
                                                        {assign var="more_btnkey" value=$more_item.btnkey}
                                                    {else}
                                                        {assign var="more_btnkey" value=$more_key}
                                                    {/if}
                                                    <li tag="{$more_key}" {if $more_key eq 'ContinuousDialing'}style="display: none"{/if} onclick="listviewbutton_click(this,'{$MODULE}','{$more_btnkey}',event);return false;">
                                                        <a title="{$more_item.label}">{$more_item.label}</a>
                                                    </li>
                                                {/if}
                                            {/foreach}
                                        </ol>
                                    {/if}
                                </li>
                            {else}
                                <li class="listviewbtnrely" tag="{$btn_key}" onclick="listviewbutton_click(this,'{$MODULE}','{$btn_item.btnkey}',event);return false;"><img class="relybtnicon" src="themes/icon/button/{$btn_item.iconname}" /><span>{$btn_item.label}</span></li>
                            {/if}
                        {/if}
                    {/foreach}
                {/if}
            </ul>
        </div>
        <div class="ld_btnrelycancel" onClick="toggleSelectAll_Records('{$MODULE}',false,'selected_id')"><i class="btncloseicon"></i></div>
    </div>
</div>
<div  class="ld-flex-between gwidth100" style="padding: 0 13px 0;">
    {*平铺查找*}
    {include file="TiledSearch.tpl"  SOURCE='customview' COLUMNS_BLOCK=$FIELDNAMES}
</div>
{if $HIGBTNSTATUS neq 'no'}
<div  class="ld-flex-between gwidth100" style="padding: 0 15px 0;">
    {*高级查找-外露 // edit: xll 2024/11/22 XUQIU1001599 单据序时簿列表界面，高级查找增加“平铺”和“清除筛选值”功能*}
    {include file="AdvanceFilterTiled.tpl"  SOURCE='customview' COLUMNS_BLOCK=$FIELDNAMES}
</div>
{/if}
<div  class="ld-flex-between gwidth100" style="padding: 0 15px;">
    <!--列表-标签查找-->
    <div name="listtag_div" id="listtag_div" style="float:left; width: 100%;display:none "></div>
</div>
