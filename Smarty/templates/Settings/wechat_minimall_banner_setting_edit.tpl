<form action="index.php" method="post" name="addMallBannerForm" onsubmit="puyoungJS_DialogBox.block();">
    <table class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
        {if $TYPE =='edit'}
            <tr>
                <td></td>
                <td><img width="100" src="{$site_URL}{$IMGINFO['path']}{$IMGINFO['filename']}" alt=""></td>
            </tr>
        {/if}
        <tr>
            <td width="20%" align="right">{'FILEUPLOAD'|@getFixedLabel}</td>
            <td width="80%" align="left">
                <input type="file" maxlength="50" size="300" id="wxmall_banner_path" onchange="validateFilename(this);" name="wxmall_banner_path" value="{$wxmall_banner_path}" class=" btn-radius-system" style="width: 80%">
            </td>
        </tr>
        <tr>
            <td width="20%" align="right">{'wxmall_banner_url'|@getFixedLabel}</td>
            <td width="80%" align="left" style="position:relative">
                <input type="text" maxlength="50" size="300" id="wxmall_banner_url" name="wxmall_banner_url" value="{$wxmall_banner_url}" class=" btn-radius-system" style="width: 80%">
            </td>
        </tr>
        <tr>
            <td></td><td><a href="javascript:void(0)" onclick="getMallBannerUrl()">如何获取连接地址？</a></td>
        </tr>

    </table>
 </form>