<!--修改编码格式:统一编码：UTF-8-->
<script language="JAVASCRIPT" type="text/javascript" src="include/js/modules/Settings/wechat_minimall_setting.js"></script>
{*颜色选择器*}
<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/colpick/colpick.js"></script>
<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/colpick/plugin.js"></script>
<form action="index.php" method="post" name="company" onsubmit="puyoungJS_DialogBox.block();">
<input type="hidden" name="module" value="Settings"/>
<input type="hidden" name="parenttab" value="Settings"/>
<input type="hidden" name="action"/>
<input type="hidden" name="blockidsetting" value="{$BLOCKIDSETTING}"/>
<input type="hidden" name="fieldidsetting" value="{$FIELDIDSETTING}"/>
<div class="main_grid_top">
    <div class="grid-view-title lfloat overflow-hidden">
        <span class="grid-view-name dinline-block lfloat">
            {'LBL_APPLET_TOP_SETTINGS'|@getFixedLabel}<font>（{'LBL_APPLET_TOP_SETTINGS_DESC'|@getFixedLabel}）</font>
        </span>
    </div>
    <div class="grid_tool">
        <div class="create-entity-toolbar lfloat prelative">
            <a href="javascript:;" class="pg-btn-grey dinline-block lfloat" onclick="wechat_minimall_setting.edit()" title="{'EDIT'|@getFixedLabel}">{'EDIT'|@getFixedLabel}</a>
{*            {if 'oem_crm'|@getCommonVersion eq 'no'}
              <a class="pg-btn-grey dinline-block lfloat" href="javascript:;" onclick="getLinksUrl('','Settings','wechat_miniprogram_setting');" title="{'ONLINEHELP'|@getFixedLabel}">{'ONLINEHELP'|@getFixedLabel}</a>
            {/if}*}
        </div>
    </div>
</div>
<div class="main_grid_box">
    <div class="grid-analysis-box">
        <div class="grid-analysis-header">
        </div>
        <div class="cont_wrap clear_float">
            <div class="TitleHeading">{'LBL_APPLET_TOP_SETTINGS'|@getFixedLabel}</div>
            <table  class=" singleList" width="100%"  border="0" cellspacing="0" cellpadding="5" style="color:#555;">
                <tr>
                    <td width="20%" class="cellLabel">{'wxmall_miniprogram_title'|@getFixedLabel}</td>
                    <td width="80%" class="cellLabel">{$miniprogram_title}</td>
                </tr>
                <tr>
                    <td width="20%" class="cellLabel">{'wxmall_top_nav_font_color'|@getFixedLabel}</td>
                    <td width="80%" class="cellLabel"><span style="border:1px solid #F1F1F1;display:block;width:80px; height: 26px;background-color: {$top_nav_text_color}"></span></td>
                </tr>
                <tr>
                    <td width="20%" class="cellLabel">{'wxmall_top_nav_back_color'|@getFixedLabel}</td>
                    <td width="80%" class="cellLabel"><span style="border:1px solid #F1F1F1;display:block;width:80px; height: 26px;background-color: {$top_nav_background_color}"></span></td>
                </tr>
            </table>
        </div>
    </div>
</div>
</form>