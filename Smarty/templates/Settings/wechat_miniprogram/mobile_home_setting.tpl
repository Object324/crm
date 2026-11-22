{*editor:gyq_141 reason:移动端增加首页标签  2019/9/3 16:39 ID1000602*}
<script language="JavaScript" type="text/javascript" src="include/js/modules/Settings/Settings.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="include/js/modules/Settings/wechat_miniprogram/mobile_home_setting.js?v={$GLOBALMINVERSION}"></script>
<form action="index.php" method="post" name="new" id="form" onsubmit="puyoungJS_DialogBox.block();">
{*    zxm 20231021 移动端看板定制  老看板不需要这个标题*}
{*<div class="main_grid_top">*}
{*    <div class="grid-view-title lfloat overflow-hidden">*}
{*        <span class="grid-view-name dinline-block lfloat">*}
{*            {'mobile_home_setting'|@getFixedLabel}<font>（{'mobile_home_describ'|@getFixedLabel}）</font>*}
{*        </span>*}
{*    </div>*}
{*    <div class="grid_tool">*}
{*    </div>*}
{*</div>*}
<div class="main_grid_box">
    <div class="grid-analysis-box">
        <div class="grid-analysis-header">
        </div>
        <div id="cfList" class="cont_wrap clear_float">
            {include file='Settings/wechat_miniprogram/mobile_home_list.tpl'}
        </div>
    </div>
</div>
</form>
<div id="block_sort" class="D_pop_box LdPopWidth300px" style="display:none;">
    <div id="block_sort_div"></div>
</div>
