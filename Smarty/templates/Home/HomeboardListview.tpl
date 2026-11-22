<!--修改编码格式:统一编码：UTF-8-->
<input type="hidden" id="from_module" value="{$MODULE}">
<input type="hidden" id="edithomefromlist" value="yes">
{if $MODULE=='MobileReport'}
    <script type="text/javascript" src="{$JSURL}include/js/modules/Home/Home.js?v={$GLOBALMINVERSION}"></script>
    <script type="text/javascript" src="{$JSURL}include/js/modules/Home/Homestuff.js?v={$GLOBALMINVERSION}"></script>
    <script type="text/javascript" src="{$JSURL}include/js/modules/Home/Homeboard.js?v={$GLOBALMINVERSION}"></script>
    <script type="text/javascript" src="{$JSURL}include/js/modules/Settings/mobile_home_setting/MobileHomeBoard.js?v={$GLOBALMINVERSION}"></script>
    <link rel="stylesheet" type="text/css" href="themes/softed/Homeboard.css"/>
    <!--zxm 20230919 移动端工作台定制 有个标题和新建按钮-->
    <div class="main_grid_top">
        <div class="grid-view-title lfloat overflow-hidden">
            <span class="grid-view-name dinline-block lfloat">{'mobile_home_setting'|@getFixedLabel}</span>
        </div>
        <div class="grid_tool">
            <div class="dispalyflex">
                <a href="javascript:;" class="ld-button ld-button-primary" onclick="editHomeboard(0,'{$MODULE}')" title="{'CREATE'|@getFixedLabel}">{'CREATE'|@getFixedLabel}</a>
            </div>
        </div>
    </div>
    <div class="main_grid_box">
        <div class="grid-analysis-box">
            <div class="grid-analysis-header">
            </div>
            <div class="cont_wrap clear_float" id="homeboard_listview_table">
                {include file="Home/HomeboardListview_content.tpl"}
            </div>
        </div>
    </div>
{else}
    <div class="ld-pop-container ld-table-container ld-table-container-lines" id="homeboard_listview_table">
        <div class="divPopOverflow">
            {include file="Home/HomeboardListview_content.tpl"}
        </div>
    </div>
{/if}