{if $MODULE neq 'Reminds'}
    <div class="Category Category_New">
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
            <tr>
                <td valign="middle" class="C">
                    <ul>
                        <span class="category_span" style="font-weight: bold;">{'DATACATEGORY'|@getFixedLabel}</span>
                        <li style="display: flex;padding: 6px 20px 0px 10px;">
                            {include file='SelectCustomView.tpl'}
                            {if $MODULE|@isPermitted:"CustomView" eq 'yes'}
                                <b class="icon-categorybtn categorymanager-set cursorPointer" onclick="DataCategoryListPopup(this)" style="margin: 5px 0 0 5px;" title="{'managecustomview'|@getFixedLabel}"></b>
                            {/if}
                        </li>
                        {if $HIDE_CUSTOM_LINKS neq '1sdsddsewewewewewrewewwrwereerwrewrewewweewwe'}
                            <li tag="firstnode" id="createCategory" style="display:none" class="D_menu_hova Xl" onclick="createCategory();">
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
    <div class="clear"></div>
{/if}
<div class="divButtons">
    <!--按钮、查看范围-->
    {assign var="buttonsPosition" value='up'}
    {include file="ListViewButtons.tpl"}
    {include file='SearchScope.tpl'}
    <div class="list-item">
        {if $MODULEADVANCESTAGESTATUS eq 'yes'}
            <span class="" title="{'PropelledFunnel'|@getFixedLabel}"><i class="list-item-btn funnel-btn" onclick="AdvanceStageHighcharts('{$MODULE}')"></i></span>
        {/if}
    </div>
    <!--分页-->
    <div class="PageDiv0">
        <div class="ld-flex-start">
            <div class="ld-pagenum-div">{$recordListRange}</div>
            {$NAVIGATION}
        </div>
    </div>
</div>