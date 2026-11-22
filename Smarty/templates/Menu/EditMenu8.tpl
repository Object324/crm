<form name="menu" action="index.php" method="post" onSubmit="if(validate()) { puyoungJS_DialogBox.block();} else { return false; }">
    <input type="hidden" name="parenttabid" value="{$PARENTTABID}"/>
    <table class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <th colspan="2">
                {'BASICINFORMATION'|@getFixedLabel}
            </th>
        </tr>
        {*zxm 2021-1206 上传菜单图标 --start*}
        <tr>
            <td align="right">{'UnselectedIcon'|@getFixedLabel}</td>
            <td align="left" style="padding:4px 0;">
                {if $inactive_icon}
                    <div id="inactive_icon_preview" style="width:  40px;height:40px;">
                        <img src="{$inactive_icon}" style="width: 40px;height: 40px;">
                    </div>
                {/if}
                <input name="inactive_icon_size" value="1024" type="hidden">
                <input name="inactive_icon_name" value="{$inactive_icon_name}" type="hidden">
                <input name="inactive_icon"  accept="image/*" value="{$inactive_icon_name}" onchange="validateFilename(this);" type="file">
                <input name="inactive_icon_name_hidden" value="{$inactive_icon_name}" type="hidden">
                <span style="color: red;line-height: 20px;">{'menuIconUploadSizeTips'|@getFixedLabel}</span>
            </td>
        </tr>
        <tr>
            <td align="right">{'SelectedIcon'|@getFixedLabel}</td>
            <td align="left" style="padding:4px 0;">
                {if $active_icon}
                    <div id="active_icon_preview" style="width:  40px;height:40px;">
                        <img src="{$active_icon}" style="width: 40px;height: 40px;">
                    </div>
                {/if}
                <input name="active_icon_size" value="1024" type="hidden">
                <input name="active_icon_name" value="{$active_icon_name}" type="hidden">
                <input name="active_icon"  accept="image/*" value="{$active_icon_name}" onchange="validateFilename(this);" type="file">
                <input name="active_icon_name_hidden" value="{$active_icon_name}" type="hidden">
                <span style="color: red;line-height: 20px;">{'menuIconUploadSizeTips'|@getFixedLabel}</span>
            </td>
        </tr>
        {*zxm 2021-1206 上传菜单图标 --end*}
    </table>
</form>
