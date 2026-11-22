<style>
    .choosed_color{
        left: 200px;
        top: 7px;
    }
</style>

<form action="index.php" method="post" name="company" onsubmit="puyoungJS_DialogBox.block();">
	<input type="hidden" name="module" value="Settings"/>
	<input type="hidden" name="parenttab" value="Settings"/>
    <input type="hidden" name="action"/>
    <input type="hidden" name="ajax" value="save"/>
    <table class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <td width="20%" align="right">{'wxmall_miniprogram_title'|@getFixedLabel}</td>
            <td width="80%" align="left"><input type="text" maxlength="50" size="50" id="miniprogram_title" name="miniprogram_title" value="{$miniprogram_title}" class="controlInput btn-radius-system"></td>
        </tr>
        <tr>
            <td width="20%" align="right">{'wxmall_top_nav_font_color'|@getFixedLabel}</td>
            <td width="80%" align="left" style="position:relative">
                <select class="btn-radius-system" name="top_nav_text_color" id="top_nav_text_color">
                    <option value="#000000" {if $top_nav_text_color eq '#000000'}selected{/if}>{'wxmall_color_black'|@getFixedLabel}</option>
                    <option value="#fffff" {if $top_nav_text_color eq '#fffff'}selected{/if}>{'wxmall_color_white'|@getFixedLabel}</option>
                </select>
            </td>
        </tr>
        <tr>
            <td width="20%" align="right">{'wxmall_top_nav_back_color'|@getFixedLabel}</td>
            <td width="80%" align="left" style="position: relative;">
                <input type="text" size="50" id="top_nav_back_color" disabled name="top_nav_back_color" value="{$top_nav_background_color}" class="controlInput btn-radius-system">
                <div class="choosed_color" style="background: {$top_nav_background_color};" name="div_top_nav_back_color" onclick="wechat_minimall_setting.SetColpick('top_nav_back_color')"></div>
            </td>
        </tr>

    </table>
 </form>