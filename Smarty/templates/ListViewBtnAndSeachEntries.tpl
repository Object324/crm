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
                            {*   // @edit:dong @date:2020/11/09 @reason:  LINKMODULECUSTOM 判断是否是数据分类设置为模块*}
                            {if $MODULE|@isPermitted:"CustomView" eq 'yes' && !$LINKMODULECUSTOM}
                                <b class="icon-categorybtn categorymanager-set cursorPointer" onclick="DataCategoryListPopup(this)" style="margin: 5px 0 0 5px;" title="{'managecustomview'|@getFixedLabel}"></b>
                            {/if}
                        </li>
                        {if $NO_CUSTOMVIEW eq 'sdw12122121312312'}
                            <li id="createCategory" tag="firstnode" class="D_menu_hova Xl" onclick="createCategory();">
                                <div style="padding-left:4px;padding-right:5px;"><a href="javascript:void(0);" onclick="DataCategoryListPopup.add()"><b class="icon-categorybtn icon-categoryAdd"></b>{'CREATECATEGORIES'|@getFixedLabel}</a></div>
                            </li>
                        {/if}
                        <li tag="firstnode" id="categorysear"><div style="padding-left:4px;padding-right:5px;"><a href="javascript:void(0);" onclick="basicsearchPopup()"><b class="icon-categorybtn categorysear-search"></b>{'BASICFIND'|@getFixedLabel}</a></div></li>
                        <li tag="firstnode" id="categoryAdvsear"><div style="padding-left:4px;padding-right:5px;"><a href="javascript:void(0);" onclick="HighersearchPopup()"><b class="icon-categorybtn categoryAdvsear-search"></b>{'CUSTOMIZESEARCH'|@getFixedLabel}</a></div></li>
                        <li id="categoryTiledSearch" tag="firstnode"><div style="padding-left:4px;padding-right:5px;"><a href="javascript:void(0);" onclick="TiledSearchShow()"><b class="icon-categorybtn categoryAdvsear-search2"></b>{'TILEDSEARCH'|@getFixedLabel}</a></div></li>
                        <li id="module_tag_list_search" tag="firstnode" style="display:none;"><div style="padding-left:4px;padding-right:5px;"><a href="javascript:void(0);" onclick="ListTagView(event,'{$MODULE}')"><b class="icon-categorybtn categoryAdvsear-search3"></b>{'Tag'|@getFixedLabel}{'SEARCH'|@getFixedLabel}</a></div></li>
                    </ul>

                </td>
                {*                            zxm 2020-1029 增加公众号绑定设置*}
                {if $MODULE eq 'Articles' && $IS_ADMIN}
                    <td valign="middle" align="right" class="C">
                        <a style="line-height: 36px;padding-right:10px;" href="javascript:void(0);" onclick="weixinSetAppid()">关联公众号设置</a>
                    </td>
                {/if}
            </tr>
        </table>
    </div>
    <!--列表-标签查找-->
    <div name="listtag_div" id="listtag_div" style="float:left; width: 100%;display:none "></div>
    {include file="TiledSearch.tpl"  SOURCE='customview' COLUMNS_BLOCK=$FIELDNAMES}
    <div class="clear"></div>
{/if}
{if $MODULE neq 'Calendar'}
    <input type="hidden" id="viewname" name="viewname" value="{$VIEWID}"/>
{/if}
<div class="divButtons">
    <!--按钮、查看范围-->
    {assign var="buttonsPosition" value='up'}
    {include file="ListViewButtons.tpl"}
    {if $Merge_SmOwner|@count neq 0 &&$MODULE neq 'InventoryAccount' && $MODULE neq 'InventoryQuery' && $MODULE neq 'BankAccountSet' &&$MODULE neq 'Reminds'}
        {include file='SearchScope.tpl'}
    {else}
        <select onchange="SmOwnerSearchScopeChange(this,'{$MODULE}','{$CATEGORY}')" id="SmOwnerSearchScope" name="SmOwnerSearchScope" style="display:none">
            <option value="SmOwner_Search_All" selected="true">全部</option>
        </select>
    {/if}
    {if $MODULEADVANCESTAGESTATUS eq 'yes'}
        <div class="list-item">
            <span class="" title="{'PropelledFunnel'|@getFixedLabel}"><i class="list-item-btn funnel-btn" onclick="AdvanceStageHighcharts('{$MODULE}')"></i></span>
        </div>
    {/if}
    <!--销售机会序时簿 - 客户漏斗-->
    {if $CUSTOMERFUNNEL eq 'yes'}
        <div class="list-item">
            <span class="" title="{'Customerfunnel'|@getFixedLabel}"><i class="list-item-btn report-btn" onclick="getCustomerFunnel('{$MODULE}')"></i></span>
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