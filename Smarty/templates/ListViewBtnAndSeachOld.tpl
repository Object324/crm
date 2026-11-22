{if $MODULE neq 'Reminds' && $MODULE neq 'Approve'}
    <!--数据分类-->
    <div class="Category Category_New">
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
            <tr>
                <td valign="middle" class="C">
                    <ul>
                        {*                                    // @edit:dong @date:2020/11/09 @reason: 隐藏数据分类名称*}
                        <!--
									43893: （61mis.com/kfbcrm）客户管理-客户（需要补丁）；在客户单据列表界面，点开管理分类，保存或取消后，页面小刷新；数据分类前出现了当前模块名
									{if !$LINKMODULECUSTOM}
                                    <span class="category_span" name="hiddenlabel">{$MODULE|@getTransTab}</span>
                                    {/if}-->
                        <span class="category_span">{'DATACATEGORY'|@getFixedLabel}</span>
                        <li tag="firstnode" style="display: flex;padding: 6px 20px 0px 10px;">
                            {include file='SelectCustomView.tpl'}
                            {* // @edit:dong @date:2020/11/09 @reason:  LINKMODULECUSTOM 判断是否是数据分类设置为模块*}
                            {if $MODULE|@isPermitted:"CustomView" eq 'yes' && !$LINKMODULECUSTOM}
                                <b class="icon-categorybtn categorymanager-set cursorPointer" onclick="DataCategoryListPopup(this)" style="margin: 5px 0 0 5px;" title="{'managecustomview'|@getFixedLabel}"></b>
                            {/if}
                        </li>
                        {if $NO_CUSTOMVIEW eq 'sdw12122121312312'}
                            <li id="createCategory" tag="firstnode" class="D_menu_hova Xl" onclick="createCategory();">
                                <div style="padding-left:4px;padding-right:5px;"><a href="javascript:void(0);" onclick="DataCategoryListPopup.add()"><b class="icon-categorybtn icon-categoryAdd"></b>{'CREATECATEGORIES'|@getFixedLabel}</a></div>
                            </li>
                        {/if}
                        <li id="categorysear" tag="firstnode"><div style="padding-left:4px;padding-right:5px;"><a href="javascript:void(0);" onclick="basicsearchPopup()"><b class="icon-categorybtn categorysear-search"></b>{'BASICFIND'|@getFixedLabel}</a></div></li>
                        <li id="categoryAdvsear" tag="firstnode"><div style="padding-left:4px;padding-right:5px;"><a href="javascript:void(0);" onclick="HighersearchPopup()"><b class="icon-categorybtn categoryAdvsear-search"></b>{'CUSTOMIZESEARCH'|@getFixedLabel}</a></div></li>
                        <li id="categoryTiledSearch" tag="firstnode"><div style="padding-left:4px;padding-right:5px;"><a href="javascript:void(0);" onclick="TiledSearchShow()"><b class="icon-categorybtn categoryAdvsear-search2"></b>{'TILEDSEARCH'|@getFixedLabel}</a></div></li>
                        <li id="module_tag_list_search" tag="firstnode" style="display:none;"><div style="padding-left:4px;padding-right:5px;"><a href="javascript:void(0);" onclick="ListTagView(event,'{$MODULE}')"><b class="icon-categorybtn categoryAdvsear-search3"></b>{'Tag'|@getFixedLabel}{'SEARCH'|@getFixedLabel}</a></div></li>
                    </ul>
                </td>
            </tr>
        </table>
    </div>
    <!--列表-标签查找-->
    <div name="listtag_div" id="listtag_div" style="float:left; width: 100%;display:none "></div>
    {include file="TiledSearch.tpl"  SOURCE='customview' COLUMNS_BLOCK=$FIELDNAMES}
{/if}
<div class="clear"></div>
<div class="divButtons">
    <!--按钮、查看范围-->
    {assign var="buttonsPosition" value='up'}
    {include file="ProductListViewButtons.tpl"}
    {if $MODULE neq 'InventoryAccount' && $MODULE neq 'InventoryQuery'}
        {include file='SearchScope.tpl'}
    {/if}

    <div class="list-item">
        {if $VERSION_ACCOUNT eq 'dongmao'}
            {if $MODULE eq 'Accounts'}
                <span class="cur" title="{'list'|@getFixedLabel}"><i class="list-item-btn list-btn" onclick="changeListMap('{$MODULE}','list',0,CrmPopup.getPopupObj('last'))"></i></span>
                <span class="" title="{'MAP'|@getFixedLabel}"><i class="list-item-btn map-btn" onclick="changeListMap('{$MODULE}','map',0,CrmPopup.getPopupObj('last'))"></i></span>
            {/if}
        {else}
            {if $MODULE eq 'Accounts' || $MODULE eq 'ServiceCharge'}
                <span class="cur" title="{'list'|@getFixedLabel}"><i class="list-item-btn list-btn" onclick="changeListMap('{$MODULE}','list',0,CrmPopup.getPopupObj('last'))"></i></span>
                <span class="" title="{'MAP'|@getFixedLabel}"><i class="list-item-btn map-btn" onclick="changeListMap('{$MODULE}','map',0,CrmPopup.getPopupObj('last'))"></i></span>
            {/if}
        {/if}
        {if $MODULEADVANCESTAGESTATUS eq 'yes'}
            <span class="" title="{'PropelledFunnel'|@getFixedLabel}"><i class="list-item-btn funnel-btn" onclick="AdvanceStageHighcharts('{$MODULE}')"></i></span>
        {/if}
    </div>
    <!--销售机会序时簿 - 客户漏斗-->
    {if $CUSTOMERFUNNEL eq 'yes'}
        <div class="list-item">
            <span class="" title="{'Customerfunnel'|@getFixedLabel}"><i class="list-item-btn report-btn" onclick="getCustomerFunnel('{$MODULE}')"></i></span>
        </div>
    {/if}

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
    {if $VERSION_ACCOUNT eq 'kfbcrm81'}
        <div class="first-listset-drawer">
            <i class="icon-canvas icon-canvas-set"></i>
        </div>
    {/if}
    <!--分页-->
    <div class="PageDiv0">
        <div class="ld-flex-start">
            <div class="ld-pagenum-div">{$recordListRange}</div>
            {$NAVIGATION}
        </div>
    </div>
</div>
<div class="clear"></div>